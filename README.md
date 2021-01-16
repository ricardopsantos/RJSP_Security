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

Utilities arround [Apple CryptoKit](https://developer.apple.com/documentation/cryptokit)

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

### Sample Usage 1 : Using symmetric keys

```swift
// Sender: Generating symmetric key and encrpting data USING shared symmetric key
let senderSymmetricKey = CryptoKit.generateSymmetricKeyBetween(AliceSender.privateKey, and: BobReceiver.publicKey, salt: salt)!
let encryptedData      = CryptoKit.encrypt(data: secretPlainData, using: senderSymmetricKey)!

// Receiver: Generating symmetric key and decrypting data USING shared symmetric key
let reveiverSymmetricKey = CryptoKit.generateSymmetricKeyBetween(BobReceiver.privateKey, and: AliceSender.publicKey, salt: salt)!
let decryptedData        = CryptoKit.decrypt(encryptedData: encryptedData, using: reveiverSymmetricKey)

```

### Sample Usage 2 : Using public and private keys


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

Inside the folders __RJSecuritySampleClient__ and __RJSecuritySampleServer__ can be found sample client app (Swift) and sample server web app (Vapor Swift) ready to use. 

Booth the client app and server use RJSP_Security lib installed via SPM and are a live working example of the key exchange process, and then a secure comunication.

Open both projects on Xcode, start the server (first), and then start the app.

![alt text](_Documents/image1.png)

The example flow is as follows:

__Step 1 :__ The app (client) send is public key to the server (on the request body). It also sends his userID (on the request header). 

```swift
static func session(publicKey: Curve25519.KeyAgreement.PublicKey, userID: String) -> Request {
    let httpBody = [
        "publicKey": CryptoKit.base64String(with: publicKey),
        "userId": userID
    ]
    
    return Request(route: "session",
                   httpMethod: "post",
                   httpBody: httpBody,
                   userId: userID)
}
```
__Step 2:__ The server store the userID and the user public key (for future secure comunication) and returns to the client app the server public key.

```swift
app.post("session") { req -> String in
  guard let userId = req.headerValue("USER_ID") else {
    // User id must be sent on the request header
    throw Abort(.badRequest)
  }
        
  // Store user public key
  let sessionModel = try req.content.decode(SessionModel.self)
  CryptoKit.PublicKeysHotStorage.store(publicKey: sessionModel.publicKey, for: userId)

  // Return the web server public key
  return privateKey.publicKey.toBase64String
}
```
    
__Step 3:__ The client app receives the server public key, and then with is (client) private key do a secure/encripted request to the server.

```swift
static func secure(encrypted: Data, userID: String) -> Request {
    let httpBody = ["secret": CryptoKit.encodeToSendOverNetwork(encrypted: encrypted)]
    return Request(route: "secureRequest",
                   httpMethod: "post",
                   httpBody: httpBody,
                   userId: userID)
}
```

__Step 4:__ The server receives the encripted request, and decript it using the client public key (stored on setep 1) and his (server) private key. After decripting the message, the server just return it as a "proof" of sucess.

```swift
app.post("secureRequest") { req -> String in
  guard let userId = req.headerValue("USER_ID"),
        let clientPublicKey = CryptoKit.PublicKeysHotStorage.get(for: userId) else {
          // User id must be sent on header and
          // the server must know the user public key allready
          throw Abort(.badRequest)
      }
      let secureRequestBody = try req.content.decode(SecureRequestModel.self)
        
      let encryptedData = secureRequestBody.secretData
        
      guard let decryptData = CryptoKit.decrypt(encryptedData: encryptedData!,
                                                receiver: privateKey,
                                                sender: clientPublicKey,
                                                salt: sharedSalt!) else {
          throw Abort(.notAcceptable)
      }
      let humanFriendlyPlainMessage = CryptoKit.dataPlainMessageToHumanFriendlyPlainMessage(decryptData)

      return "Your secret was [\(humanFriendlyPlainMessage ?? "")]"

}
```
