<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat" alt="Swift 5.3">
   </a>
    <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Xcode-12.0.1-blue.svg" alt="Swift 5.3">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>
   <a href="https://twitter.com/ricardo_psantos/">
      <img src="https://img.shields.io/badge/Twitter-@ricardo_psantos-blue.svg?style=flat" alt="Twitter">
   </a>
</p>

## About

Utilities framework and sample [__client app__](https://github.com/ricardopsantos/RJSP_Security/tree/master/_RJSecuritySampleClient) and [__web server__](https://github.com/ricardopsantos/RJSP_Security/tree/master/_RJSecuritySampleServer) providing end-to-end encrypted communication using [__Apple CryptoKit__](https://developer.apple.com/documentation/cryptokit) concepts.

![image](_Documents/preview.1.gif)

## Sample Usage

### Given...

```swift 
struct AliceSender {
    private init() { }
    static let privateKey = CryptoKit.newPrivateKeyInstance()
    static let publicKey  = privateKey.publicKey
}
 
struct BobReceiver {
    private init() { }
    static let privateKey = CryptoKit.newPrivateKeyInstance()
    static let publicKey  = privateKey.publicKey
}

static let salt = "6beab91f-4a1a-4449-96cb-b6e0edb30776".data(using: .utf8)!
static let secretPlain = "my secret"
static let secretPlainData = CryptoKit.humanFriendlyPlainMessageToDataPlainMessage(secretPlain)!
```

### Sample Usage 1 : Encrypt and decrypt using symmetric keys

```swift
// Sender: Generating symmetric key and encrpting data USING shared symmetric key
let senderSymmetricKey = CryptoKit.generateSymmetricKeyBetween(AliceSender.privateKey, and: BobReceiver.publicKey, salt: salt)!
let encryptedData      = CryptoKit.encrypt(data: secretPlainData, using: senderSymmetricKey)!

// Receiver: Generating symmetric key and decrypting data USING shared symmetric key
let reveiverSymmetricKey = CryptoKit.generateSymmetricKeyBetween(BobReceiver.privateKey, and: AliceSender.publicKey, salt: salt)!
let decryptedData        = CryptoKit.decrypt(encryptedData: encryptedData, using: reveiverSymmetricKey)

```

### Sample Usage 2 : Encrypt and decrypt using public and private keys


```swift
// Sender: Generating symmetric key and encrpting data USING public and private keys
let encryptedData = CryptoKit.encrypt(data: secretPlainData,
                                      sender: AliceSender.privateKey,
                                      receiver: BobReceiver.publicKey,
                                      salt: salt)!

// Receiver: Generating symmetric key and decrypting data USING public and private keys
let decryptedData = CryptoKit.decrypt(encryptedData: encryptedData,
                                      receiver: BobReceiver.privateKey,
                                      sender: AliceSender.publicKey,
                                      salt: salt)
```

## Sample working projects

Inside the folders [__RJSecuritySampleClient__](https://github.com/ricardopsantos/RJSP_Security/tree/master/_RJSecuritySampleClient) and [__RJSecuritySampleServer__](https://github.com/ricardopsantos/RJSP_Security/tree/master/_RJSecuritySampleServer) a sample client app (Swift) and sample server web app (Vapor Swift) can be found. These applications are ready to use. 

Both the client app and the server use the [__RJSP_Security__](https://github.com/ricardopsantos/RJSP_Security) lib installed via SPM and are a live working example of the key exchange process, followed by a secure communication.

![alt text](_Documents/image1.png)

Open both projects on Xcode

* Start the server.
* Start the app.

The project's sample flow is as follows:

Step 1 : The app (client) sends its public key to the server (on the request body). It also sends its userID (on the request header).

```swift
static func session(publicKey: Curve25519.KeyAgreement.PublicKey, userID: String) -> RequestModel {
    let httpBody = [
        "publicKey": CryptoKit.base64String(with: publicKey),
        "userId": userID
    ]
    
    return RequestModel(path: "session",
                        httpMethod: .post,
                        httpBody: httpBody,
                        userId: userID)
}
```

```swift
let sessionPublisher = webAPI.session(publicKey: privateKey.publicKey, userID: userID)
```

Step 2: The server stores the userID and the user's public key (for future secure communication) and returns the server public key to the client app.

```swift
app.post(Session.path) { req -> Session.ResponseModel in
    guard let userId = req.headerValue("USER_ID") else {
        // User id must be sent on the request header
        throw Abort(.badRequest)
    }
    
    // Store user public key
    let requestModel = try req.content.decode(Session.RequestModel.self)
    
    CryptoKit.PublicKeysHotStorage.store(publicKey: requestModel.publicKey, for: userId)

    // Return the web server public key
    return Session.ResponseModel(publicKey: privateKey.publicKey.toBase64String)
}
```
    
Step 3: The client app receives the server public key, and then with its (client) private key executes a secure/encrypted request to the server.

```swift
static func secure(encrypted: Data, userID: String) -> RequestModel {
    let httpBody = ["secret": CryptoKit.encodeToSendOverNetwork(encrypted: encrypted)]
    return RequestModel(path: "secureRequest",
                        httpMethod: .post,
                        httpBody: httpBody,
                        userId: userID)
}
```

```swift
// Session response with server public key...
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
```

Step 4: The server receives the encrypted request, and decrypts it using the client public key (stored on step 1) and its (server) private key. After decrypting the message, the server just returns it as a "proof" of success.

```swift
app.post(SecureRequest.path) { req -> SecureRequest.ResponseModel in
    guard let userId = req.headerValue("USER_ID"),
          let clientPublicKey = CryptoKit.PublicKeysHotStorage.get(for: userId) else {
        // User id must be sent on header and
        // the server must know the user public key allready
        throw Abort(.badRequest)
    }
    let requestModel = try req.content.decode(SecureRequest.RequestModel.self)
    
    let encryptedData = requestModel.secretData
    
    guard let decryptData = CryptoKit.decrypt(encryptedData: encryptedData!,
                                              receiver: privateKey,
                                              sender: clientPublicKey,
                                              salt: sharedSalt!) else {
        throw Abort(.notAcceptable)
    }
    
    // Decode the secret message
    let humanFriendlyPlainMessage = CryptoKit.dataPlainMessageToHumanFriendlyPlainMessage(decryptData)!
    let message = "Sure!\n\n\(humanFriendlyPlainMessage.uppercased())"
    return SecureRequest.ResponseModel(message: message)
}
```
