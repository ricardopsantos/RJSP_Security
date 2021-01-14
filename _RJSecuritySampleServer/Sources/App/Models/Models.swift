import Vapor

final class SecureRequestModel: Content {
    var secret: String
    init() {
        secret = ""
    }
}

final class SessionModel: Content {
    var publicKey: String
    init() {
        publicKey = ""
    }
}

