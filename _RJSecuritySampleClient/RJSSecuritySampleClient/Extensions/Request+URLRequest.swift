//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

extension RequestModel {
    
    private var serverURL: String { "http://127.0.0.1:5678" }

    var urlRequest: URLRequest? {
        guard let theURL = URL(string: "\(serverURL)/\(path)") else { return nil }
        var request = URLRequest(url: theURL)
        request.httpMethod = httpMethod.rawValue.uppercased()
        
        if let httpBody = try? JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted) {
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue(userId, forHTTPHeaderField: "USER_ID")
        return request
    }
}

