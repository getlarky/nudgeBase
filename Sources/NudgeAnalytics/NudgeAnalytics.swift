//
//  NudgeAnalytics.swift
//  NudgeAnalytics
//
//  Created by Evan Snyder on 3/18/19.
//

import Foundation
import Segment
import EnvironmentUtils
import KeyValueStore

private let fileName = "NudgeAnalytics.swift"

open class NudgeAnalytics: NSObject {
    static let ANALYTICS_API_KEY = "yK7oqWuyB8RUrPYqxyR7n2FjD32Av666"
    public static let deviceModel = getDeviceModel()
    public static let osVersion = getOSInfo()
    public static let platform = "ios"
    private static var initialized = false

    enum Connection: String {
        case wifi = "wifi", data = "data", none = "none"
    }
    
    public static let RECEIVED_NOTIFICATION = "User Received Notification"
    public static let TAPPED_NOTIFICATION = "User Tapped Notification"
    public static let APPLICATION_ERROR = "Application Error"
    public static let USER_CREATED = "User Created"
    public static let NOTIFICATION_PERMISSION = "Notification Permission"
    public static let LOCATION_PERMISSION = "Location Permission"
    public static let INTIALIZE_NUDGE = "Initialize Nudge"
    public static let REGISTER_TOKEN = "Register Token"
    
    public static func track(eventName: String, data: [String: Any]) {
        isInitialized {
            let fullProperties = data.merging(getConstAnalyticsData(), uniquingKeysWith: {(first, _ ) in first})
            Analytics.shared().track(eventName, properties: fullProperties)
        }
    }
    
    public static func setup() {
        let apiKey = ANALYTICS_API_KEY
        let config = AnalyticsConfiguration(writeKey: apiKey)
        config.trackApplicationLifecycleEvents = false
        Analytics.setup(with: config)
        NudgeAnalytics.initialized = true
    }
    
    public static func trackError(error: Any, file: Any, function: Any) {
        isInitialized {
            print(error)
            self.track(eventName: APPLICATION_ERROR, data: [
                "message": error,
                "file": file,
                "function": function
            ])
        }
    }
    
    public static func pushAnalytics(eventName: String, notificationPayload: [AnyHashable:Any]) {
        isInitialized {
            DispatchQueue.main.async {
                NSLog("pushAnalytics called")
            }
            let messageConstants = KeyValueStore.MessageData.self
            let messageId = notificationPayload[messageConstants.messageId] as Any;
            let messageBody = notificationPayload[messageConstants.messageBody] as Any;
            let messageTitle = notificationPayload[messageConstants.messageTitle] as Any;
            let messageDescription = notificationPayload[messageConstants.messageDescription] as Any;
            let messageName = notificationPayload[messageConstants.messageName] as Any;
            let messageUrl = notificationPayload[messageConstants.messageUrl] as Any;
            let messageSuppress = notificationPayload[messageConstants.messageSuppress] as Any;
            NSLog("MessageTitle is \(messageTitle)")
            let messageBreadcrumbs = notificationPayload[messageConstants.messageBreadcrumbs] as Any;
            NSLog("MessageBreadcrumbs are: \(messageConstants.messageBreadcrumbs)")
            
            NudgeAnalytics.track(eventName: eventName, data: [
                messageConstants.messageId: messageId,
                messageConstants.messageTitle: messageTitle,
                messageConstants.messageBody: messageBody,
                messageConstants.messageDescription: messageDescription,
                messageConstants.messageName: messageName,
                messageConstants.messageUrl: messageUrl,
                messageConstants.messageSuppress: messageSuppress,
                messageConstants.messageBreadcrumbs: messageBreadcrumbs,
                KeyValueStore.Location.userLatitude: KeyValueStore.getFloat(key: KeyValueStore.Location.latitude),
                KeyValueStore.Location.userLongitude: KeyValueStore.getFloat(key: KeyValueStore.Location.longitude)
            ])
        }
    }
    
    private static func getConstAnalyticsData() -> [String: Any] {
        var build = ""
        #if DEBUG
            build = "debug"
        #else
            build = "release"
        #endif
        return [
            "user_id": KeyValueStore.getString(key: KeyValueStore.userId) as Any,
            "user_email": KeyValueStore.getString(key: KeyValueStore.email) as Any,
            "organization_id": KeyValueStore.getString(key: KeyValueStore.organizationId) as Any,
            "organization_name": KeyValueStore.getString(key: KeyValueStore.organizationName) as Any,
            "user_name": KeyValueStore.getString(key: KeyValueStore.userName) as Any,
            "device_id": KeyValueStore.getString(key: KeyValueStore.deviceId) as Any,
            "device_model": getDeviceModel(),
            "device_platform": platform,
            KeyValueStore.nudgeLibraryVersionHeader: KeyValueStore.nudgeLibraryVersion,
            "device_platform_version": osVersion,
            "timestamp": Date(),
            "network": getNetworkStatus(),
            "build": build,
            "tokendealer_url": EnvironmentUtils.getNudgeURL(service: EnvironmentUtils.Service.TOKENDEALER.rawValue),  //Config.tokendealerServerUrl,
            "core_url": EnvironmentUtils.getNudgeURL(service: EnvironmentUtils.Service.CORE.rawValue),  //Config.coreServerUrl,
            "location_permission": KeyValueStore.getString(key: KeyValueStore.locationPermission) as Any,
            "notification_permission": KeyValueStore.getString(key: KeyValueStore.notificationPermission) as Any
        ]
    }
    
    public static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
        
    }
    
    private static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    public static func getNetworkStatus() -> String {
        if Network.reachability.isReachableViaWiFi {
            return Connection.wifi.rawValue
        } else if Network.reachability.isReachableOnWWAN {
            return Connection.data.rawValue
        } else {
            return Connection.none.rawValue
        }
    }
    
    private static func isInitialized(tries:Double = 1.0, closure: @escaping () -> Void) {
        if !NudgeAnalytics.initialized && tries <= 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 * tries) {
                isInitialized(tries:tries + 1.0, closure:closure)
           }
            return
        }
        closure()
    }
    
    public static func setupAnalytics() {
        if Network.reachability == nil {
            initializeReachibility()
            NudgeAnalytics.setup()
        }
    }

    private static func initializeReachibility() {
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            var errorMessage = ""
            switch error as? Network.Error {
                case let .failedToCreateWith(hostname)?:
                    errorMessage = "Network error:\nFailed to create reachability object With host named:" + hostname
                case.failedToInitializeWith(_)?:
                    errorMessage = "Network error:\nFailed to initialize reachability object With address"
                case .failedToSetCallout?:
                    errorMessage = "Network error:\nFailed to set callout"
                case .failedToSetDispatchQueue?:
                    errorMessage = "Network error:\nFailed to set DispatchQueue"
                case .none:
                    errorMessage = error.localizedDescription
            }
            NudgeAnalytics.trackError(error: errorMessage, file: fileName, function: "initializeReachibility")
        }
    }
}
