//
//  Created by Ricardo Santos on 19/12/2020.
//

import Vapor
import Foundation

public extension Request {
        
    func headerValue(_ id: String) -> String? {
        return self.headers.first(name: id)
    }
    
    func paramValueForFieldWith(_ id: String) -> String? {
        return self.parameters.get(id)
    }
        
    func log(_ app: Application?) {
        print("###############################")
        print("REQUEST: \(self)")
    }
}
