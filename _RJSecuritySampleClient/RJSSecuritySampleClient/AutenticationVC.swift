//
//  Created by Ricardo P Santos on 2020.
//  2020 © 2019 Ricardo P Santos. All rights reserved.
//

import UIKit
import CryptoKit
import Combine
//
import RJSecurity

let privateKey = CryptoKit.newPrivateKeyInstance()
let sharedSalt = "ba00524d-ad11-46ac-a596-0a2998588b5a".utf8Data!
let userID = "\(UUID())"

class AutenticationVC: UIViewController {
    
    private var cancelBag = CancelBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webAPI = WebAPI()

        //
        // STEP 1 : The app (client) sends its Public key to the server (on the request body).
        // It also sends its userID (on the request header).
        //
        let sessionPublisher = webAPI.session(publicKey: privateKey.publicKey, userID: userID)

        //
        // STEPS 3: The client app receives the server Public key, and then with its (client) Private key
        // executes a secure/encrypted request to the server.
        //
        let serverPublicKeyPublisher = sessionPublisher.compactMap { $0.publicKey }
        
        // Secure request...
        let secureRequestPublisher = serverPublicKeyPublisher.flatMap { (publicKey) -> AnyPublisher<ResponseDto.SecureRequest, APIError> in
            let plainHumanMessage = "Hi server. Can you uppercase me? \(Date())"
            let serverPublicKey   = CryptoKit.publicKey(with: publicKey)!
            let plainDataMessage  = CryptoKit.humanFriendlyPlainMessageToDataPlainMessage(plainHumanMessage)!
            let encryptedMessage  = CryptoKit.encrypt(data: plainDataMessage,
                                                  sender: privateKey,
                                                  receiver: serverPublicKey,
                                                  salt: sharedSalt)
            return webAPI.secure(encrypted: encryptedMessage!, userID: userID)
        }
        
        // Handle secure request response
        secureRequestPublisher.sink { (result) in
            print(result)
        } receiveValue: { (secureResponse) in
            self.showAlert(with: secureResponse.message)
        }.store(in: cancelBag)


    }

    func showAlert(with: String) {
        let alert = UIAlertController(title: "Server response", message: with, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }

}







