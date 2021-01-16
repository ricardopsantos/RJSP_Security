import Vapor
import Foundation

public struct ConfigManager { private init() { } }

public extension ConfigManager {
    
    static func valueWith(key: String) -> String? {
        if let value = Environment.get(key), !value.isEmpty {
            return value
        }
        return nil
    }
}

