//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation
import CryptoKit
//
import RJSecurity

public struct RequestsBuilder {
    
    static func session(publicKey: Curve25519.KeyAgreement.PublicKey, userID: String) -> RequestModel {
        let httpBody = [
            "publicKey": CryptoKit.base64String(with: publicKey),
            "userId": userID
        ]
        
        return RequestModel(path: "session",
                            httpMethod: .post,
                            httpBody: httpBody,
                            userId: userID)
    }
    
    static func secure(encrypted: Data, userID: String) -> RequestModel {
        let httpBody = ["secret": CryptoKit.encodeToSendOverNetwork(encrypted: encrypted)]
        return RequestModel(path: "secureRequest",
                            httpMethod: .post,
                            httpBody: httpBody,
                            userId: userID)
    }
    
}
