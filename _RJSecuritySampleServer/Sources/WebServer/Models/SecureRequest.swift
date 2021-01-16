import Vapor
import CryptoKit
import RJSecurity

public struct SecureRequest {
    
    private init() { }
    static let path = PathComponent(stringLiteral: "secureRequest")

    final class RequestModel: Content {
        public var secret: String?
        public var secretData: Data? { CryptoKit.decodeFromNetwork(string: secret) }

        init(plain: Data, sender: Curve25519.KeyAgreement.PrivateKey, receiver: Curve25519.KeyAgreement.PublicKey, salt: Data) {
            let encrypted = CryptoKit.encrypt(data: plain, sender: sender, receiver: receiver, salt: salt)!
            secret = CryptoKit.encodeToSendOverNetwork(encrypted: encrypted)
        }
    }

    final class ResponseModel: Content {
        public var message: String
        init(message: String) {
            self.message = message
        }
    }
    
}




