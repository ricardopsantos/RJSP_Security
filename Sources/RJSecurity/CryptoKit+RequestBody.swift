//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
public extension CryptoKit {

    struct StringRequestBody: Codable {
        let secret: String
    }
    
    struct DataRequestBody: Codable {
        let secret: Data
    }
 }
 

extension CryptoKit.StringRequestBody {
    var toJSON: String {
        return (String(data: try! JSONEncoder().encode(self), encoding: .utf8)!)
    }
}

extension CryptoKit.DataRequestBody {
    
    // Maps a [DataRequestBody] into a [StringRequestBody]
    var toStringRequestBody: CryptoKit.StringRequestBody {
        let secret = CryptoKit.encondeFroNetworkTransport(encrypted: self.secret)
        return CryptoKit.StringRequestBody(secret: secret)
    }
    
    var toJSON: String {
        return (String(data: try! JSONEncoder().encode(self), encoding: .utf8)!)
    }
}
