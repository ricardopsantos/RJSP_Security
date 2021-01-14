//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit

/*
public struct RJSecurityExtension<Target> {
    let target: Target
    init(_ target: Target) { self.target = target }
}

public protocol RJSecurityExtensionCompatible { }

public extension RJSecurityExtensionCompatible {
    var rjs: RJSecurityExtension<Self> { return RJSecurityExtension(self) }
}

extension NSObject: RJSecurityExtensionCompatible { }
*/

//
// Extensions
//

public extension Data {
    var stringFromUtf8: String? { return String(data: self, encoding: .utf8) }
    var base64String: String { self.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) }
}

public extension String {
    var utf8Data: Data? { return self.data(using: .utf8) }
    var publicKey: Curve25519.KeyAgreement.PublicKey? { CryptoKit.publicKey(with: self) }
}

public extension Curve25519.KeyAgreement.PublicKey {
    var base64String: String { CryptoKit.base64String(with: self) }
}
