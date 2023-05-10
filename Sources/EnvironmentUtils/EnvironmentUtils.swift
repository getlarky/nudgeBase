//
//  EnvironmentUtils.swift
//
//  Created by Dana Haukoos on 3/17/22.
//


import Foundation

public class EnvironmentUtils {

    // default to production environment
    private static var _env: Environment = Environment.PROD
    
    public enum Environment: String {
        case DEV = "dev"
        case STAGING = "staging"
        case STAGING2 = "staging2"
        case PROD = "prod"
    }

    public enum Service: String {
        case CORE = "core"
        case TOKENDEALER = "tokendealer"
    }
    
    // default to production environment
    public init() {}

    public static func getEnv() -> String {
        return _env.rawValue
    }
    
    public static func setEnv(envIn: Environment) {
        _env = envIn
    }
    
    public static func setEnvByName(rawValueIn: String) {
        let envIn: Environment? = Environment(rawValue: rawValueIn)
        _env = envIn ?? Environment.PROD
    }
    
    // return the proper URL given a desired environment and service (i.e. core or tokendealer endpoint)
    public static func getNudgeURL(service: String) -> String {
        if(Service(rawValue: service) == nil) {
            return "Service name not valid.";
        }
        switch (_env) {
            case Environment.DEV:       return "https://" + service + ".dev.nudge.rocks/"
            case Environment.STAGING:   return "https://" + service + ".staging.nudge.rocks/"
            case Environment.STAGING2:   return "https://" + service + ".staging2.nudge.rocks/"
            case Environment.PROD:      return "https://" + service + ".nudge.larky.cloud/"
        }
    }
    
}
    
