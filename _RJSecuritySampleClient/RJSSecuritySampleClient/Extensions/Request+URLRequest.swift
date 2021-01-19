//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

extension RequestModel {

    fileprivate static func toJSON<T:Codable>(some : T) -> String? {
        guard let data = try? JSONEncoder().encode(some.self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private var serverURL: String { "http://127.0.0.1:5678" }

    var urlRequest: URLRequest? {
        guard let theURL = URL(string: "\(serverURL)/\(path)") else { return nil }
        var request = URLRequest(url: theURL)
        request.httpMethod = httpMethod.rawValue.uppercased()
        
        var httpBody: Data?
        if let httpBodyDic = httpBodyDic {
            httpBody = try? JSONSerialization.data(withJSONObject: httpBodyDic, options: .prettyPrinted)
        }
        
        if let httpBodyCodable = httpBodyCodable {
            httpBody = try? JSONEncoder().encode(httpBodyCodable.self)
        }
        
        if httpBody != nil {
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue(userId, forHTTPHeaderField: "USER_ID")
        return request
    }
}

