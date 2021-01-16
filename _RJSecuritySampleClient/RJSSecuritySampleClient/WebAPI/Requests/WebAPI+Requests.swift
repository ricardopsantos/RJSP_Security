//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation
import Combine
import CryptoKit

extension WebAPI {
    func session(publicKey: Curve25519.KeyAgreement.PublicKey, userID: String) -> AnyPublisher<ResponseDto.Session, APIError> {
        let urlRequest = RequestsBuilder.session(publicKey: publicKey, userID: userID).urlRequest!
        return run(urlRequest)
    }
    func secure(encrypted: Data, userID: String) -> AnyPublisher<ResponseDto.SecureRequest, APIError> {
        let urlRequest = RequestsBuilder.secure(encrypted: encrypted, userID: userID).urlRequest!
        return run(urlRequest)
    }
}
