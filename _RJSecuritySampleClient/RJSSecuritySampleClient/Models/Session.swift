//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

struct ResponseDto {
    private init() { }
    public struct Session: Codable {
        let publicKey: String
    }

    public struct SecureRequest: Codable {
        let message: String
    }
}

