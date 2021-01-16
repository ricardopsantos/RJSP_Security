//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
typealias PublicKeysHotStorage = CryptoKit.PublicKeysHotStorage
public extension CryptoKit {

    struct PublicKeysHotStorage {
        
        private init() { }
        
        static func store(publicKey: String, for userID: String) {
            HotStorage.add(object: publicKey, withKey: userID)
        }
        
        static func get(for userID: String) -> Curve25519.KeyAgreement.PublicKey? {
            guard let pk64String = HotStorage.get(key: userID),
                  let pk = CryptoKit.publicKey(with: pk64String as String) else  {
                return nil
            }
            return pk
        }
        
        static func delete(for userID: String) {
            HotStorage.delete(key: userID)
        }
        
        static func cleanAll() {
            HotStorage.clean()
        }
    }
 }
 
fileprivate struct HotStorage {
    private init() {}
    
    private static var _cache = NSCache<NSString, NSString>()
    
    public static func add(object: String, withKey: String) {
        objc_sync_enter(_cache); defer { objc_sync_exit(_cache) }
        _cache.setObject(object as NSString, forKey: withKey as NSString)
    }
    
    public static func get(key: String) -> NSString? {
        objc_sync_enter(_cache); defer { objc_sync_exit(_cache) }
        if let object = _cache.object(forKey: key as NSString) { return object }
        return nil
    }
    
    public static func delete(key: String) {
        objc_sync_enter(_cache); defer { objc_sync_exit(_cache) }
        _cache.removeObject(forKey: key as NSString)
    }
    
    public static func clean() {
        objc_sync_enter(_cache); defer { objc_sync_exit(_cache) }
        _cache.removeAllObjects()
    }
    
}
