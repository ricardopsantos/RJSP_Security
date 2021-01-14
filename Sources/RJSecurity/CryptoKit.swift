//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
public struct CryptoKit {
    private init() { }
}

public extension CryptoKit {

    static func generateSymmetricKeyBetween(_ a: Curve25519.KeyAgreement.PrivateKey, and b: Curve25519.KeyAgreement.PublicKey, salt: Data) -> SymmetricKey? {
        guard let sharedSecret = generateSecretBetween(a, and: b) else { return nil }
        return sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: salt, sharedInfo: Data(), outputByteCount: 32)
    }
        
    static func encrypt(plainSecret: Data, using symmetricKey: SymmetricKey) -> Data? {
        return try! ChaChaPoly.seal(plainSecret, using: symmetricKey).combined
    }
    
    static func encrypt(plainSecret: Data, sender: Curve25519.KeyAgreement.PrivateKey, receiver: Curve25519.KeyAgreement.PublicKey, salt: Data) -> Data? {
        guard let symmetricKey = generateSymmetricKeyBetween(sender, and: receiver, salt: salt) else { return nil }
        return encrypt(plainSecret: plainSecret, using: symmetricKey)
    }
    
    static func decrypt(encryptedData: Data, using symmetricKey: SymmetricKey) -> Data? {
        guard let sealedBox = try? ChaChaPoly.SealedBox(combined: encryptedData),
              let decryptedData = try? ChaChaPoly.open(sealedBox, using: symmetricKey) else {
            return nil
        }
        return decryptedData
    }
    
    static func decrypt(encryptedData: Data, receiver: Curve25519.KeyAgreement.PrivateKey, sender: Curve25519.KeyAgreement.PublicKey, salt: Data) -> Data? {
        guard let symmetricKey = generateSymmetricKeyBetween(receiver, and: sender, salt: salt) else { return nil }
        return decrypt(encryptedData: encryptedData, using: symmetricKey)
    }
    
    static func generatePrivateKey() -> Curve25519.KeyAgreement.PrivateKey { return Curve25519.KeyAgreement.PrivateKey() }
    
    static func base64String(with publicKey: Curve25519.KeyAgreement.PublicKey) -> String {
        publicKey.rawRepresentation.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    static func publicKey(with base64String: String) -> Curve25519.KeyAgreement.PublicKey? {
        guard let data = Data(base64Encoded: base64String), let publicKey = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: data) else {
            return nil
        }
        return publicKey
    }
 }
 
private extension CryptoKit {
    static func generateSecretBetween(_ a: Curve25519.KeyAgreement.PrivateKey, and b: Curve25519.KeyAgreement.PublicKey) -> SharedSecret? {
        return try? a.sharedSecretFromKeyAgreement(with: b)
    }
    
}
