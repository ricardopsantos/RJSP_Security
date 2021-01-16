//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import UIKit
import CryptoKit
//
import RJSecurity

let privateKey = CryptoKit.newPrivateKeyInstance()
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
            
            let plainHumanMessage = "Hi! \(Date())"
            let plainDataMessage = CryptoKit.humanFriendlyPlainMessageToDataPlainMessage(plainHumanMessage)!
            let encryptedMessage = CryptoKit.encrypt(data: plainDataMessage,
                                                  sender: privateKey,
                                                  receiver: serverPublicKey,
                                                  salt: sharedSalt)
                
            let secureRequest = WebAPI.RequestBuilder.secure(encrypted: encryptedMessage!,
                                                             userID: userID)
            
            // Do SECURE request
            WebAPI.executeRequest(requestModel: secureRequest) { (result) -> (Void) in
                self.showAlert(with: result)
            }
        
        }

    }


}
