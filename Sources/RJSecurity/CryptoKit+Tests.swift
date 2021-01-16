//
//  Created by Ricardo Santos on 10/01/2021.
//

import Foundation
import CryptoKit
 
fileprivate struct TestVars {
    private init() { }
    
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

    static let salt = "6beab91f-4a1a-4449-96cb-b6e0edb30776".data(using: .utf8)!
    static let secretPlain = "my secret"
    static let secretPlainData = CryptoKit.humanFriendlyPlainMessageToDataPlainMessage(secretPlain)!
}

extension CryptoKit {
    
    //
    // Encrypt and decrypt using shared symmetric key
    //
    static func sampleUsage1() -> Bool {
    
        // Sender: Generating symmetric key and encrpting data USING shared symmetric key
        let senderSymmetricKey = CryptoKit.generateSymmetricKeyBetween(TestVars.AliceSender.privateKey, and: TestVars.BobReceiver.publicKey, salt: TestVars.salt)!
        let encryptedData      = CryptoKit.encrypt(data: TestVars.secretPlainData, using: senderSymmetricKey)!
        
        // Receiver: Generating symmetric key and decrypting data USING shared symmetric key
        let reveiverSymmetricKey = CryptoKit.generateSymmetricKeyBetween(TestVars.BobReceiver.privateKey, and: TestVars.AliceSender.publicKey, salt: TestVars.salt)!
        let decryptedData        = CryptoKit.decrypt(encryptedData: encryptedData, using: reveiverSymmetricKey)
    
        // The decripted data, should be equals with the secret
        return CryptoKit.dataPlainMessageToHumanFriendlyPlainMessage(decryptedData) == TestVars.secretPlain
    }
    
    //
    // Encrypt and decrypt using shared public and private keys
    //
    static func sampleUsage2() -> Bool {
    
        // Sender: Generating symmetric key and encrpting data USING public and private keys
        let encryptedData = CryptoKit.encrypt(data: TestVars.secretPlainData,
                                              sender: TestVars.AliceSender.privateKey,
                                              receiver: TestVars.BobReceiver.publicKey,
                                              salt: TestVars.salt)!
        
        // Receiver: Generating symmetric key and decrypting data USING public and private keys
        let decryptedData = CryptoKit.decrypt(encryptedData: encryptedData,
                                              receiver: TestVars.BobReceiver.privateKey,
                                              sender: TestVars.AliceSender.publicKey,
                                              salt: TestVars.salt)
    
        // The decripted data, should be equals with the secret
        return CryptoKit.dataPlainMessageToHumanFriendlyPlainMessage(decryptedData) ?? "" == TestVars.secretPlain
    }
    
    //
    // Test same symetric keys generation with Alice and Bob public and private keys
    //
    static func testSymetricKeysGeneration() -> Bool {
        let senderSymmetricKey   = CryptoKit.generateSymmetricKeyBetween(TestVars.AliceSender.privateKey, and: TestVars.BobReceiver.publicKey, salt: TestVars.salt)!
        let reveiverSymmetricKey = CryptoKit.generateSymmetricKeyBetween(TestVars.BobReceiver.privateKey, and: TestVars.AliceSender.publicKey, salt: TestVars.salt)!
        return senderSymmetricKey == reveiverSymmetricKey
    }
    
    //
    // Test 
    //
    static func testDataToStringConversions() -> Bool {
        
        let plainSecretUtf8Data = CryptoKit.humanFriendlyPlainMessageToDataPlainMessage(TestVars.secretPlain)
        
        let aliceEncryptedData = CryptoKit.encrypt(data: plainSecretUtf8Data!,
                                                   sender: TestVars.AliceSender.privateKey,
                                                   receiver: TestVars.BobReceiver.publicKey,
                                                   salt: TestVars.salt)!
        
        let aliceEncryptedDataOverTheNetwork = CryptoKit.encodeToSendOverNetwork(encrypted: aliceEncryptedData)
        
        guard let bobEncryptedData = CryptoKit.decodeFromNetwork(string: aliceEncryptedDataOverTheNetwork) else { return false }

        let bobDecryptedData = CryptoKit.decrypt(encryptedData: bobEncryptedData,
                                                 receiver: TestVars.BobReceiver.privateKey,
                                                 sender: TestVars.AliceSender.publicKey,
                                                 salt: TestVars.salt)

        let secretPlain = CryptoKit.dataPlainMessageToHumanFriendlyPlainMessage(bobDecryptedData)
        return secretPlain == TestVars.secretPlain
    }
    
    //
    // Test conventing public key into base 64 string, and again from base 64 into public key
    //
    static func testPublicKeyToBase64AndThenBackToPublicKey() -> Bool {
        let publicKeyIntoBase64String = CryptoKit.base64String(with: TestVars.BobReceiver.publicKey)
        let publicKeyFromBase64String = CryptoKit.publicKey(with: publicKeyIntoBase64String)!
        return publicKeyIntoBase64String == CryptoKit.base64String(with: publicKeyFromBase64String)
    }
    
    static func testPublicKeysHotStorage() -> Bool {
        
        let userId = "\(UUID())"
        let publicKey = CryptoKit.generatePrivateKey().publicKey
        
        // Test : After a clean up, no keys should exist
        CryptoKit.PublicKeysHotStorage.store(publicKey: publicKey.toBase64String, for: userId)
        CryptoKit.PublicKeysHotStorage.cleanAll()
        guard CryptoKit.PublicKeysHotStorage.get(for: userId) == nil else { return false }
        
        // Test : After fetching a stored Public Key, should have the same value that the key that was used to store it
        CryptoKit.PublicKeysHotStorage.store(publicKey: publicKey.toBase64String, for: userId)
        let storedPublicKey = CryptoKit.PublicKeysHotStorage.get(for: userId)
        guard storedPublicKey?.toBase64String == publicKey.toBase64String else { return false }
        
        // Test : Deleting a key
        CryptoKit.PublicKeysHotStorage.store(publicKey: publicKey.toBase64String, for: userId)
        CryptoKit.PublicKeysHotStorage.delete(for: userId)
        guard CryptoKit.PublicKeysHotStorage.get(for: userId) == nil else { return false }

        return true
    }
    
}

