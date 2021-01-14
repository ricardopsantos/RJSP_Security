//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation

public extension String {
    var environmentValue: String? { return ConfigManager.valueWith(key: self) }
    var utf8Data: Data? { return self.data(using: .utf8) }
}
