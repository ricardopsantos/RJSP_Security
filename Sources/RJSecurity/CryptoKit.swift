//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
public struct CryptoKit {
    private init() { }
    
    public static func newPrivateKeyInstance() -> Curve25519.KeyAgreement.PrivateKey { return Curve25519.KeyAgreement.PrivateKey() }

}

//
// MARK: - Encrypt & decrypt methods
//

public extension CryptoKit {

    static func generateSymmetricKeyBetween(_ a: Curve25519.KeyAgreement.PrivateKey, and b: Curve25519.KeyAgreement.PublicKey, salt: Data) -> SymmetricKey? {
        guard let sharedSecret = generateSecretBetween(a, and: b) else { return nil }
        return sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: salt, sharedInfo: Data(), outputByteCount: 32)
    }
        
    // data: Data -> utf8 format, salt: Data -> utf8 format
    static func encrypt(data: Data, using symmetricKey: SymmetricKey) -> Data? {
        return try! ChaChaPoly.seal(data, using: symmetricKey).combined
    }
    
    // data: Data -> utf8 format, salt: Data -> utf8 format
    static func encrypt(data: Data, sender: Curve25519.KeyAgreement.PrivateKey, receiver: Curve25519.KeyAgreement.PublicKey, salt: Data) -> Data? {
        guard let symmetricKey = generateSymmetricKeyBetween(sender, and: receiver, salt: salt) else { return nil }
        return encrypt(data: data, using: symmetricKey)
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
    
 }

//
// MARK: - PublicKey conversion utils
//

public extension CryptoKit {
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

//
// MARK: - Human friendly conversion utils
//

public extension CryptoKit {
    static func humanFriendlyPlainMessageToDataPlainMessage(_ string: String?) -> Data? {
        guard string != nil else { return nil }
        return string!.data(using: .utf8)
    }
    
    static func dataPlainMessageToHumanFriendlyPlainMessage(_ data: Data?) -> String? {
        guard data != nil else { return nil }
        return String(data: data!, encoding: .utf8)
    }
}

//
// MARK: - Network conversion utils
//

public extension CryptoKit {
    
    /// Receives encrypted Data, and converts into a String so it can be stored or sent over the network
    static func encondeForNetworkTransport(encrypted: Data) -> String {
        return encrypted.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    /// Receives an encrypted String, and converts into encrypted Data
    static func decodeFromNetworkTransport(string: String?) -> Data? {
        guard string != nil else { return nil }
        return Data(base64Encoded: string!)
    }
}

//
// MARK: - Private
//

private extension CryptoKit {
    static func generateSecretBetween(_ a: Curve25519.KeyAgreement.PrivateKey, and b: Curve25519.KeyAgreement.PublicKey) -> SharedSecret? {
        return try? a.sharedSecretFromKeyAgreement(with: b)
    }
}
