//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
typealias PublicKeysHotStorage = CryptoKit.PublicKeysHotStorage
public extension CryptoKit {

    struct PublicKeysHotStorage {
        
        private init() { }
        
        public static func store(publicKey base64String: String, for userID: String) {
            guard let publicKey = CryptoKit.publicKey(with: base64String) else { return } // Not a valid public key
            store(publicKey: publicKey, for: userID)
        }
        
        public static func store(publicKey: Curve25519.KeyAgreement.PublicKey, for userID: String) {
            HotStorage.add(object: publicKey.toBase64String, withKey: userID)
        }
        
        public static func get(for userID: String) -> Curve25519.KeyAgreement.PublicKey? {
            guard let pk64String = HotStorage.get(key: userID),
                  let pk = CryptoKit.publicKey(with: pk64String as String) else  {
                return nil
            }
            return pk
        }
        
        public static func delete(for userID: String) {
            HotStorage.delete(key: userID)
        }
        
        public static func cleanAll() {
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
