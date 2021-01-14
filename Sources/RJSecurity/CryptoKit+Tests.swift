//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
extension CryptoKit {
    
    static func doTestWith(secret: String) -> String {
        
        struct AliceSender {
            private init() { }
            static let privateKey = CryptoKit.generatePrivateKey()
            static let publicKey  = privateKey.publicKey
        }
         
        struct BobReceiver {
            private init() { }
            static let privateKey = CryptoKit.generatePrivateKey()
            static let publicKey  = privateKey.publicKey
        }
        
        // Client and server must share the same salt
        guard let salt = "ba00524d-ad11-46ac-a596-0a2998588b5a".utf8Data,
              let message = secret.utf8Data else {
            // Invalid salt or secret
            return ""
        }

        // Enconding public key so that it can be sent to the receiver
        let base64String = CryptoKit.base64String(with: BobReceiver.publicKey)
        let bobPublicKey = CryptoKit.publicKey(with: base64String)!
        
        let senderSymmetricKey = CryptoKit.generateSymmetricKeyBetween(AliceSender.privateKey, and: bobPublicKey, salt: salt)!
        let encryptedData      = CryptoKit.encrypt(plainSecret: message, using: senderSymmetricKey)!
        
        let reveiverSymmetricKey = CryptoKit.generateSymmetricKeyBetween(BobReceiver.privateKey, and: AliceSender.publicKey, salt: salt)!
        let decryptedData        = CryptoKit.decrypt(encryptedData: encryptedData, using: reveiverSymmetricKey)
        
        if (decryptedData?.stringFromUtf8 ?? "") != secret {
            fatalError("Fix me")
        }

        return decryptedData?.stringFromUtf8 ?? ""
    }
    
}

