//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation

extension Data {
    var stringFromUtf8: String? {
        return String(data: self, encoding: .utf8)
    }
}

 
