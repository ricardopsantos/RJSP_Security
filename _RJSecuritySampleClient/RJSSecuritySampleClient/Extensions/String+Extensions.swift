//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

public extension String {
    var utf8Data: Data? { return self.data(using: .utf8) }
}

