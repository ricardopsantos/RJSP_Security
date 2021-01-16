import Vapor
import RJSecurity

let privateKey = CryptoKit.newPrivateKeyInstance()
let sharedSalt = "ba00524d-ad11-46ac-a596-0a2998588b5a".utf8Data

func routes(_ app: Application) throws {
    
    app.post(Session.path) { req -> Session.ResponseModel in
        guard let userId = req.headerValue("USER_ID") else {
            // User id must be sent on the request header
            throw Abort(.badRequest)
        }
        
        // Store user public key
        let requestModel = try req.content.decode(Session.RequestModel.self)
        
        CryptoKit.PublicKeysHotStorage.store(publicKey: requestModel.publicKey, for: userId)

        // Return the web server public key
        return Session.ResponseModel(publicKey: privateKey.publicKey.toBase64String)
    }
    
    app.post(SecureRequest.path) { req -> SecureRequest.ResponseModel in
        guard let userId = req.headerValue("USER_ID"),
              let clientPublicKey = CryptoKit.PublicKeysHotStorage.get(for: userId) else {
            // User id must be sent on header and
            // the server must know the user public key allready
            throw Abort(.badRequest)
        }
        let requestModel = try req.content.decode(SecureRequest.RequestModel.self)
        
        let encryptedData = requestModel.secretData
        
        guard let decryptData = CryptoKit.decrypt(encryptedData: encryptedData!,
                                                  receiver: privateKey,
                                                  sender: clientPublicKey,
                                                  salt: sharedSalt!) else {
            throw Abort(.notAcceptable)
        }
        
        // Decode the secret message
        let humanFriendlyPlainMessage = CryptoKit.dataPlainMessageToHumanFriendlyPlainMessage(decryptData)!
        let message = "Sure!\n\n\(humanFriendlyPlainMessage.uppercased())"
        return SecureRequest.ResponseModel(message: message)
    }
    

    
    

}

