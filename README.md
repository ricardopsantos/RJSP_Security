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

```swift

struct AliceSender {
    private init() { }
    static let privateKey = CryptoKit.generatePrivateKey()
    static let publicKey  = privateKey.publicKey
}
 
struct BobReceiver {
    private init() { }
    static let privateKey = CryptoKit.generatePrivateKey()
    static let publicKey  = privateKey.publicKey
}

let secret = "my secret!"

guard let salt = "ba00524d-ad11-46ac-a596-0a2998588b5a".utf8Data,
      let message = secret.utf8Data else {
    // Invalid salt or secret
    return ""
}

// Enconding public key so that it can be sent to the receiver
let base64String = CryptoKit.base64String(with: BobReceiver.publicKey)
let bobPublicKey = CryptoKit.publicKey(with: base64String)!

let senderSymmetricKey = CryptoKit.generateSymmetricKeyBetween(AliceSender.privateKey, and: bobPublicKey, salt: salt)!
let encryptedData      = CryptoKit.encrypt(plainSecret: message, using: senderSymmetricKey)!

let reveiverSymmetricKey = CryptoKit.generateSymmetricKeyBetween(BobReceiver.privateKey, and: AliceSender.publicKey, salt: salt)!
let decryptedData        = CryptoKit.decrypt(encryptedData: encryptedData, using: reveiverSymmetricKey)

```

## Sample working rojects

Inside the folders __RJSecuritySampleClient__ and __RJSecuritySampleServer__ can be found sample app (Swift) and WebServer (Vapor) ready to use. Booth the app and server have RJSP_Security lib installed via SPM and work as a live example.

Open both projects on Xcode, start the server, and then start the app.

![alt text](_Documents/image1.png)

The flow is as follows:

* The app (client) send is public key to the server (on the request body) and his user id (on the request header)
* The server store the user id and the user public key and returns his public key
* The app (client) receives the server public key, and then do a secure/encripted request to the server
* The server receives the encripted request, decript it using the client public key and his (server) private key and returns the decripted message