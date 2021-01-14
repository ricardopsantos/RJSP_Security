//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import Foundation

public struct WebAPI {
    
    private init() { }
    
    static let serverURL = "http://127.0.0.1:5678"

    static func executeRequest(requestModel: Request, completionHandler: @escaping (String)->(Void)) {
        guard let theURL = URL(string: "\(serverURL)/\(requestModel.route)") else { return }
        var request = URLRequest(url: theURL)
        request.httpMethod = requestModel.httpMethod.uppercased()
        
        if let httpBody = try? JSONSerialization.data(withJSONObject: requestModel.httpBody, options: .prettyPrinted) {
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue(requestModel.userId, forHTTPHeaderField: "USER_ID")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler("Error: \(error)")
                } else if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    completionHandler("\(dataString)")
                }
            }

        }
        task.resume()
    }
}

