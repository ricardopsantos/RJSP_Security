import Vapor
import RJSecurity

let privateKey = CryptoKit.newPrivateKeyInstance()
let sharedSalt = "ba00524d-ad11-46ac-a596-0a2998588b5a".utf8Data

func routes(_ app: Application) throws {
    
    app.post("session") { req -> String in
        guard let userId = req.headerValue("USER_ID") else {
            // User id must be sent on the request header
            throw Abort(.badRequest)
        }
        
        // Store user public key
        let sessionModel = try req.content.decode(SessionModel.self)
        CryptoKit.PublicKeysHotStorage.store(publicKey: sessionModel.publicKey, for: userId)

        // Return the web server public key
        return privateKey.publicKey.toBase64String
    }
    
    app.post("secureRequest") { req -> String in
        guard let userId = req.headerValue("USER_ID"),
              let clientPublicKey = CryptoKit.PublicKeysHotStorage.get(for: userId) else {
            // User id must be sent on header and
            // the server must know the user public key allready
            throw Abort(.badRequest)
        }
        let secureRequestBody = try req.content.decode(SecureRequestModel.self)
        
        let encryptedData = secureRequestBody.secretData
        
        guard let decryptData = CryptoKit.decrypt(encryptedData: encryptedData!,
                                                  receiver: privateKey,
                                                  sender: clientPublicKey,
                                                  salt: sharedSalt!) else {
            throw Abort(.notAcceptable)
        }
        let humanFriendlyPlainMessage = CryptoKit.dataPlainMessageToHumanFriendlyPlainMessage(decryptData)

        return "Your secret was [\(humanFriendlyPlainMessage ?? "")]"

    }
    

    
    

}

