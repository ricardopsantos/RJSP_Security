//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import UIKit
import CryptoKit
//
import RJSecurity

let privateKey = CryptoKit.generatePrivateKey()
let sharedSalt = "ba00524d-ad11-46ac-a596-0a2998588b5a".utf8Data!
let userID = "\(UUID())"

class AutenticationVC: UIViewController {
    
    func showAlert(with: String) {
        let alert = UIAlertController(title: "Server response", message: with, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sessionRequest = WebAPI.RequestBuilder.session(publicKey: privateKey.publicKey,
                                                           userID: userID)
        
        WebAPI.executeRequest(requestModel: sessionRequest) { (result) -> (Void) in
            
            // Extract server public key to encript our message, and map it into Base64 string
            let serverPublicKey = CryptoKit.publicKey(with: result)!

            // Setup SECURE request
            
            let plainSecret = "my secret!".utf8Data!
            let secureSecret = CryptoKit.encrypt(plainSecret: plainSecret,
                                                  sender: privateKey,
                                                  receiver: serverPublicKey,
                                                  salt: sharedSalt)?.base64String
                
            let secureRequest = WebAPI.RequestBuilder.secure(secret: secureSecret!,
                                                             userID: userID)
            
            // Do SECURE request
            WebAPI.executeRequest(requestModel: secureRequest) { (result) -> (Void) in
                self.showAlert(with: result)
            }
        
        }

    }


}
