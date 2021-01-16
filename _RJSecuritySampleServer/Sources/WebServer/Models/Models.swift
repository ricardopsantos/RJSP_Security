import Vapor
import CryptoKit
import RJSecurity

final class SecureRequestModel: Content {
    var secret: String?
    var secretData: Data? { CryptoKit.decodeFromNetwork(string: secret) }

    init(plain: Data, sender: Curve25519.KeyAgreement.PrivateKey, receiver: Curve25519.KeyAgreement.PublicKey, salt: Data) {
        let encrypted = CryptoKit.encrypt(data: plain, sender: sender, receiver: receiver, salt: salt)!
        secret = CryptoKit.encodeToSendOverNetwork(encrypted: encrypted)
    }
    
}

final class SessionModel: Content {
    var publicKey: String
    init() {
        publicKey = ""
    }
}

