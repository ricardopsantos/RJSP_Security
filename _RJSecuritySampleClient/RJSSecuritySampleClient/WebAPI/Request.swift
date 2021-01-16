//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

public struct Request {
    public let route: String
    public let httpMethod: String
    public let httpBody: [String: String]
    public let userId: String
}
