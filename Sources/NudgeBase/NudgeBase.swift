//
//  HttpClientApi.swift
//
//  Created by Evan Snyder.
//

import UserNotifications
import CoreLocation
import MessageUI
import KeyValueStore
import NudgeAnalytics
import EnvironmentUtils


private let fileName = "NudgeBase.swift"

@objc open class NudgeBase : NSObject {
    public static let bundleId = Bundle.main.bundleIdentifier
    
    @objc public init(options: Dictionary<String,Any> = [:]) {
        super.init()
        
        if (options["apiKey"] == nil) {
            return
        }

        // fetch server data for dynamic config
        KeyValueStore.registerObjects(defaults: [
            KeyValueStore.isNudgeEnabled: false,
            KeyValueStore.showLocationDialog: false,
            KeyValueStore.orgDesiredAccuracy: 2,
            KeyValueStore.orgDistanceFilter: 100.0,
            KeyValueStore.lastPermissionsPromptTime: 0.0,
            KeyValueStore.howManyTimesPrompted: 0,
            "location_permission": "Not Applicable"

        ])
        
        let apiKey = options["apiKey"] as! String
        let enabled = options["enabled"] != nil ? options["enabled"] as! Bool : false
        let federationId = options["federationId"] != nil ? (options["federationId"] as! String).trimmingCharacters(in: .whitespacesAndNewlines) : ""

        self.checkIfEnabled(enabled: enabled)
        
        let userId = KeyValueStore.getString(key: KeyValueStore.userId)
        let deviceId = KeyValueStore.getString(key: KeyValueStore.deviceId)
        
        self.initializeNudge(apiKey: apiKey,
                             federationId: federationId,
                             userId: userId,
                             deviceId: deviceId,
                             success: {(newUserId, newDeviceId) in
                                self.initializeNudgeSuccess(newDeviceId: newDeviceId)},
                             failure: {(message) in
            NSLog("initializeNudge error:" + message)
        })
    }
    
    func checkIfEnabled(enabled: Bool) -> Void {
        //        let showLocationDialog = options["showLocationDialog"] != nil ? options["showLocationDialog"] as! Bool : false
        //  KeyValueStore.putString(key: KeyValueStore.showLocationDialog, value: showLocationDialog)
        
        if (!enabled){
            NudgeBase.toggleEnabled(enabled: enabled, success: { res in }, failure: { (message) in NSLog(message)})
            KeyValueStore.putBoolean(key: KeyValueStore.isNudgeEnabled, value: enabled)
//            let locMgr = LocationManagerDelegate.SharedManager
//            if (callback != nil){
//                locMgr.locationCallback = callback
//            }
//            locMgr.stopMonitorinLocation()
            NSLog("nudge is disabled")
            return
        }
    }
    
    func initializeNudgeSuccess(newDeviceId: String) -> Void {
        print("=======================NUDGEBASE=======================")
        let deviceId = KeyValueStore.getString(key: KeyValueStore.deviceId)
        NudgeAnalytics.setupAnalytics()
        NudgeAnalytics.track(eventName: NudgeAnalytics.INTIALIZE_NUDGE, data: [:])
               
        KeyValueStore.putBoolean(key: KeyValueStore.isNudgeEnabled, value: true)
                            
        let APNtoken = KeyValueStore.getString(key: KeyValueStore.APNtoken)
        if (APNtoken != nil) {
            print("APNtoken is \(String(describing: APNtoken))")
            NudgeBase.registerToken(deviceId: newDeviceId, token: APNtoken, bundleId: NudgeBase.bundleId, success: {() in
                KeyValueStore.putString(key: KeyValueStore.APNtoken, value: APNtoken)
            DispatchQueue.main.async {
    //                        let locMgr = LocationManagerDelegate.SharedManager
    //                        if (callback != nil){
    //                            locMgr.locationCallback = callback
    //                        }
    //                        locMgr.startMonitoringLocation()
                NSLog("You've been nudged!")
            }
            }, failure: {(message) in
                NSLog("registerToken error:" + message)
            })
        }
    }
    
    public static func toggleEnabled(enabled: Bool, success: @escaping (Bool) -> Void,
                             failure: @escaping (String) -> Void) {
        let userId = KeyValueStore.getString(key: KeyValueStore.userId)

//        if (userId == nil) {
//            return
//        }
        
        NSLog("toggleEnabled:" + userId! + " => " + String(enabled))
        
        let url = Constants.Core.url + Constants.Core.Endpoints.toggleNotifications + "/" + userId!

        var paramsDict = [String:Any]()
        paramsDict[Constants.Core.PostData.toggle] = enabled ? Constants.Core.PostData.enable : Constants.Core.PostData.disable
        
        HttpClientApi.instance().makeAPICall(url: url, params: paramsDict, method: .POST,
                                             success: { (data, response, error) in
            do {
                let responseJson = try JSONSerialization.jsonObject(with: data!) as? NSDictionary
                let res = responseJson![Constants.Core.GetData.notifications] as! String
                success(res == Constants.Core.PostData.enable)
            } catch {
                NudgeAnalytics.trackError(error: response.debugDescription, file: fileName, function: "setIsEnabled")
                failure("Cannot update user notificationsEnabled")
            }
        }, failure: { (data, response, error) in
            NudgeAnalytics.trackError(error: response.debugDescription, file: fileName, function: "setIsEnabled")
            failure("Cannot update user notificationsEnabled")
        })
    }
    
    public func isEnabled() -> Bool {
        return KeyValueStore.getBoolean(key: KeyValueStore.isNudgeEnabled)
    }
    
    public enum NudgeErrors : Error {
        case unsupportediOSVersion
    }
    
    @objc public static func registerForPushNotifications() throws{
        NudgeAnalytics.setupAnalytics()
        print("------------registerForPushNotifications------------")
        if #available(iOS 10.0, *) {
            print("------------registerForPushNotifications #available(iOS 10.0, *) ------------")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("------------ in UNUserNotificationCenter.current().requestAuthorization ------------")
                if (granted){
                    NudgeAnalytics.track(eventName: NudgeAnalytics.NOTIFICATION_PERMISSION, data: ["notification_permission" : "Accept"])
                    KeyValueStore.putString(key: KeyValueStore.notificationPermission, value: "Accept")
                    print("------------Accepted Notification Permissions------------")
                    print("------------Now registerForRemoteNotification ------------")
                }
                else{
                    NudgeAnalytics.track(eventName: NudgeAnalytics.NOTIFICATION_PERMISSION, data: ["notification_permission" : "Decline"])
                    KeyValueStore.putString(key: KeyValueStore.notificationPermission, value: "Decline")
                    print("------------Decined Notification Permissions------------")
                }
                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            NudgeAnalytics.trackError(error: "Unsupported version of iOS", file: fileName, function: "registerForPushNotifications")
            throw NudgeErrors.unsupportediOSVersion
        }
    }
    
    @objc public static func onRegisteredForNotifications(deviceToken: Data) {
        NudgeAnalytics.setupAnalytics()
        let tokenParts = deviceToken.map { data -> String in
            // Convert from Data to base-16 encoded hex string. More info here: https://stackoverflow.com/a/40031342
            // and here: https://www.raywenderlich.com/156966/push-notifications-tutorial-getting-started
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        KeyValueStore.putString(key: KeyValueStore.APNtoken, value: token)
        print("---------- onRegisteredForNotifications(deviceToken: " + token + " --------------")
    }
    
    @objc public static func onFailedToRegisterForNotifications(error: Error){
        NudgeAnalytics.setupAnalytics()
        print("Failed to register: \(error)")
    }
    
    @objc public static func receivedPush(notificationPayload: [AnyHashable:Any], application: UIApplication) {
        NudgeAnalytics.setupAnalytics()
        NSLog("receivedPush called");
        NudgeAnalytics.pushAnalytics(eventName: NudgeAnalytics.RECEIVED_NOTIFICATION, notificationPayload: notificationPayload)
    }
    
    @available(iOS 10.0, *)
    @objc public static func tappedNotification(notification: UNNotification) {
        NudgeAnalytics.pushAnalytics(eventName: NudgeAnalytics.TAPPED_NOTIFICATION, notificationPayload: notification.request.content.userInfo)
        if let url = (notification.request.content.userInfo[KeyValueStore.MessageData.messageUrl] as? String) {
            redirectToUrl(messageUrl: url)
            NSLog("nudge tapped - redirecting to url")
        }
        else {
            NSLog("nudge tapped")
        }
    }
    
    public func initializeNudge(apiKey: String, federationId: String, userId: String?,
                                 deviceId: String?, success: @escaping (String, String) -> Void,
                                 failure: @escaping (String) -> Void) {
        var paramsDict = [String:Any]()
        paramsDict[Constants.Core.PostData.apiKey] = apiKey
        paramsDict[Constants.Core.PostData.federationId] = federationId
        paramsDict[Constants.Core.PostData.userId] = userId
        paramsDict[Constants.Core.PostData.deviceId] = deviceId
        paramsDict[KeyValueStore.notificationPermission] = KeyValueStore.getString(key: KeyValueStore.notificationPermission)
        paramsDict[KeyValueStore.locationPermission] = KeyValueStore.getString(key: KeyValueStore.locationPermission)
        paramsDict[Constants.Core.PostData.timezone] = KeyValueStore.timezoneValue
        paramsDict[Constants.Core.PostData.manufacturer] = KeyValueStore.deviceManufacturer
        paramsDict[Constants.Core.PostData.model] = NudgeAnalytics.deviceModel
        paramsDict[Constants.Core.PostData.devicePlatform] = Constants.Core.PostData.iosPlatform
        paramsDict[Constants.Core.PostData.platformVersion] = KeyValueStore.deviceVersion
        
        print("initializeNudge called!")
        
    //    let url = Constants.Core.url + Constants.Core.Endpoints.initializeNudge
        let url = EnvironmentUtils.getNudgeURL(service: EnvironmentUtils.Service.CORE.rawValue) + Constants.Core.Endpoints.initializeNudge
        print("initialization url is " + url)
        print("initialization postData is " + paramsDict.description)
        
        HttpClientApi.instance().makeAPICall(url: url, params:paramsDict, method: .POST,
                                             success: { (data, response, error) in
            do {
                let responseJson = try JSONSerialization.jsonObject(with: data!) as? NSDictionary
                let userId = responseJson![Constants.Core.GetData.userId] as! String
                let deviceId = responseJson![Constants.Core.GetData.deviceId] as! String
                let organizationId = responseJson![Constants.Core.GetData.organizationId] as! String
                let libraryConfig = responseJson![Constants.Core.GetData.libraryConfig] as! NSArray

                for config in libraryConfig {
                    let elem = config as! NSDictionary
                    if elem["variable"] as! String == Constants.Core.LibraryConfigVariables.desiredAccuracy {
                        KeyValueStore.putString(key: KeyValueStore.orgDesiredAccuracy, value: elem["value"] as? String)
                    }
                    if elem["variable"] as! String == Constants.Core.LibraryConfigVariables.distanceFilter {
                        KeyValueStore.putString(key: KeyValueStore.orgDistanceFilter, value: elem["value"] as? String)
                    }
                    if elem["variable"] as! String == Constants.Core.LibraryConfigVariables.analyticsApiKey {
                        KeyValueStore.putString(key: KeyValueStore.orgAnalyticsApiKey, value: elem["value"] as? String)
                    }
                    if elem["variable"] as! String == Constants.Core.LibraryConfigVariables.tokenDealerSecret {
                        KeyValueStore.putString(key: KeyValueStore.orgTokenDealerSecret, value: elem["value"] as? String)
                    }
                    if elem["variable"] as! String == Constants.Core.LibraryConfigVariables.locationDialogTitle {
                        KeyValueStore.putString(key: KeyValueStore.orgLocationDialogTitle , value: elem["value"] as? String)
                    }
                    if elem["variable"] as! String == Constants.Core.LibraryConfigVariables.locationDialogBody {
                        KeyValueStore.putString(key: KeyValueStore.orgLocationDialogBody, value: elem["value"] as? String)
                    }
                }
                
                KeyValueStore.putString(key: KeyValueStore.userId, value: userId)
                KeyValueStore.putString(key: KeyValueStore.deviceId, value: deviceId)
                KeyValueStore.putString(key: KeyValueStore.organizationId, value: organizationId)
                
                NudgeBase.toggleEnabled(enabled: true, success: { res in
                    success(userId, deviceId)
                }, failure: { (message) in failure(message) })
                
            } catch {
                NudgeAnalytics.trackError(error: response.debugDescription, file: fileName, function: "initializeNudge")
                failure("Cannot parse initializeNudge response to JSON")
            }
        }, failure: { (data, response, error) in
            NudgeAnalytics.trackError(error: response.debugDescription, file: fileName, function: "initializeNudge")
  //          print("makeApiCall error is " + response.debugDescription)
            KeyValueStore.removeObject(key: KeyValueStore.coreServerToken)
            failure(String(data: data!, encoding: String.Encoding.utf8)!)
        })
    }
    
    public static func registerToken(deviceId: String?, token: String?, bundleId: String?,
                               success: @escaping () -> Void,
                               failure: @escaping (String) -> Void) {
        NudgeAnalytics.track(eventName: NudgeAnalytics.REGISTER_TOKEN, data: [:])

        var paramsDict = [String:Any]()
        paramsDict[Constants.Core.PostData.deviceId] = deviceId
        paramsDict[Constants.Core.PostData.token] = token
        paramsDict[Constants.Core.PostData.bundleId] = bundleId
        paramsDict[Constants.Core.PostData.platform] = Constants.Core.PostData.iosPlatform
        
        let url = EnvironmentUtils.getNudgeURL(service: EnvironmentUtils.Service.CORE.rawValue) + Constants.Core.Endpoints.registerToken
        print("registerToken url is " + url)
        print("registerToken postData is " + paramsDict.description)
        
        HttpClientApi.instance().makeAPICall(url: url, params:paramsDict, method: .POST,
                                             success: { (data, response, error) in
            success()
        }, failure: { (data, response, error) in
            NudgeAnalytics.trackError(error: response.debugDescription, file: fileName, function: "registerToken")
            failure(data == nil ? response.debugDescription : String(data: data!, encoding: String.Encoding.utf8)!)
        })
    }

    private static func getNotificationSettings(){
        NudgeAnalytics.setupAnalytics()
        // This #available check has to be included, but the only place this is called is within registerForPushNotifications, which already has the if#available block
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private static func redirectToUrl(messageUrl: String) {
        guard let url = URL(string: messageUrl) else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
}
