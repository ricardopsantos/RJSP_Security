//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

public struct RequestModel {
    public let path: String
    public let httpMethod: HttpMethod
    public let httpBodyDic: [String: String]?
    public let httpBodyCodable: Codable?
    public let userId: String
}


