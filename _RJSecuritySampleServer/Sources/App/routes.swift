import Vapor
import RJSecurity

let privateKey = CryptoKit.generatePrivateKey()
var publicKeys: [String: String] = [:]
let sharedSalt = "ba00524d-ad11-46ac-a596-0a2998588b5a".utf8Data

func routes(_ app: Application) throws {
    
    app.post("session") { req -> String in
        guard let userId = req.headerValue("USER_ID") else {
            // User id must be sent on header
            throw Abort(.badRequest)
        }
        
        // Store user public key
        let sessionModel = try req.content.decode(SessionModel.self)
        publicKeys[userId] = sessionModel.publicKey
        
        // Return public key
        return CryptoKit.base64String(with: privateKey.publicKey)
    }
    

    app.post("secureRequest") { req -> String in
        guard let userId = req.headerValue("USER_ID"),
              let clientPublicKeyB64 = publicKeys[userId],
              let clientPublicKey = CryptoKit.publicKey(with: clientPublicKeyB64) else {
            // User id must be sent on header and
            // the server must know the user public key allready
            throw Abort(.badRequest)
        }
        let secureRequestBody = try req.content.decode(SecureRequestModel.self)
        
        let encryptedData = Data(base64Encoded: secureRequestBody.secret)
        guard let plain = CryptoKit.decrypt(encryptedData: encryptedData!,
                                            receiver: privateKey,
                                            sender: clientPublicKey,
                                            salt: sharedSalt!)?.stringFromUtf8 else {
            throw Abort(.notAcceptable)
        }
        
        return "Your secret was [\(plain)]"

    }
    

    
    

}

