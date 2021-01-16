import Vapor
import CryptoKit
import RJSecurity

public struct Session {
    
    private init() { }
    static let path = PathComponent(stringLiteral: "session")
    
    final class RequestModel: Content {
        public var publicKey: String
        init() {
            publicKey = ""
        }
    }
    
    final class ResponseModel: Content {
        public var publicKey: String
        init(publicKey: String) {
            self.publicKey = publicKey
        }
    }
    
}




