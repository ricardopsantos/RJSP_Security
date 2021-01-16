//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

struct UserSessionModel: Decodable {
    var id: UUID?
    var username: String
    var password: String
    var name: String?
    var publicKey: String?
    
    enum CodingKeys: String, CodingKey {
         case id, username, password
         case name, publicKey
     }
    
    static func user(with json: String) -> UserSessionModel? {
        guard let data = json.utf8Data else { return nil }
        return try? JSONDecoder().decode(UserSessionModel.self, from: data)
    }
}
