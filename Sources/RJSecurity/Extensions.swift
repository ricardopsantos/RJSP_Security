//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit

//
// MARK: - PublicKey -> String -> PublicKey
//

public extension Curve25519.KeyAgreement.PublicKey {
    var toBase64String: String { CryptoKit.base64String(with: self) }
}

public extension String {
    var toPublicKey: Curve25519.KeyAgreement.PublicKey? { CryptoKit.publicKey(with: self) }
}
