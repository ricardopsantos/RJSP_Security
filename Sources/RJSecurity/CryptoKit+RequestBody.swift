//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
public extension CryptoKit {

    fileprivate static func toJSON<T:Codable>(some : T) -> String? {
        guard let data = try? JSONEncoder().encode(some.self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    
    struct StringRequestBody: Codable {
        public let secret: String
    }
    
    struct DataRequestBody: Codable {
        public let secret: Data
    }
}
 
public extension CryptoKit.StringRequestBody {
    var toJSON: String? { return CryptoKit.toJSON(some: self) }
}

public extension CryptoKit.DataRequestBody {
    
    var toJSON: String? { return CryptoKit.toJSON(some: self) }

    // Maps a [DataRequestBody] into a [StringRequestBody]
    var toStringRequestBody: CryptoKit.StringRequestBody {
        let secret = CryptoKit.encondeFroNetworkTransport(encrypted: self.secret)
        return CryptoKit.StringRequestBody(secret: secret)
    }
    
}

