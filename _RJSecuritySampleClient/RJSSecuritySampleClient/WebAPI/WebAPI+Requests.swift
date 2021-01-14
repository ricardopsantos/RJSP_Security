//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation
import CryptoKit
//
import RJSecurity

public extension WebAPI {
    struct RequestBuilder { private init() { } }
}

public extension WebAPI.RequestBuilder {
    
    static func session(publicKey: Curve25519.KeyAgreement.PublicKey, userID: String) -> Request {

        let httpBody = [
            "publicKey": CryptoKit.base64String(with: publicKey),
            "userId": userID
        ]
        
        return Request(route: "session",
                       httpMethod: "post",
                       httpBody: httpBody,
                       userId: userID)
    }
    
    static func secure(secret: String, userID: String) -> Request {
        let httpBody = ["secret": secret]
        return Request(route: "secureRequest",
                       httpMethod: "post",
                       httpBody: httpBody,
                       userId: userID)
    }
    
}
