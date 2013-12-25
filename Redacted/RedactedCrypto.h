//
//  RedactedCrypto.h
//  Redacted
//
//  Created by Joshua Brot on 11/25/13.
//
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCrypto.h>

// HUGE portions derived (copied) from SecKeyWrapper.m: https://developer.apple.com/library/ios/samplecode/CryptoExercise/Listings/Classes_SecKeyWrapper_m.html

// constants used to find public, and private keys.
#define kPublicKeyTag           "com.pamelloes.Redacted.publickey"
#define kPrivateKeyTag          "com.pamelloes.Redacted.privatekey"

@class AppDelegate;

@interface RedactedCrypto : NSObject {
	__weak AppDelegate *delegate;
	
    NSData * publicTag;
    NSData * privateTag;
	
    SecKeyRef publicKeyRef;
    SecKeyRef privateKeyRef;
}

- (instancetype) initWithDelegate: (AppDelegate *) delegate;

/*!
 Loads already existing keys, or creates them if necessary.
 */
- (void) loadLocalKeys;
- (void) generateLocalKeys:(NSUInteger)keySize;
- (void) deleteLocalKeys;
- (NSData *) publicKeyBits;
- (NSString *) publicKeyString;

- (SecKeyRef) addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey;
- (void) removePeerPublicKey:(NSString *)peerName;

- (NSData *) encryptData: (NSData *) data key: (SecKeyRef) key;
- (NSData *) decryptData: (NSData *) data key: (SecKeyRef) key;

- (CFTypeRef) persistentKeyRefWithKeyRef:(SecKeyRef)keyRef;
- (SecKeyRef) keyRefWithPersistentKeyRef:(CFTypeRef)persistentRef;
- (NSData *) bitsForPersistantKeyRef:(CFTypeRef)keyRef;
- (NSString *) stringForPublicKey: (NSData *) publicKeyBits;
- (NSData *) publicKeyForString: (NSString *) publicKeyString;

- (NSData *) generateSymmetricKey;
- (NSData *) deriveKey: (NSData *) key Constant: (NSData *) constant;
- (NSData *) signData:(NSData *)plainText withKey: (SecKeyRef) key;
- (BOOL) verifySignature:(NSData *)plainText secKeyRef:(SecKeyRef)publicKey signature:(NSData *)sig;
- (NSData *) doCipher:(NSData *)plainText key:(NSData *)symmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7;

- (NSData *) hashSha256Raw: (NSData *)data;
- (NSString *) hashSha256: (NSData *) data;

@property (nonatomic, weak, readonly) AppDelegate *delegate;

@property (nonatomic, strong, readonly) NSData * publicTag;
@property (nonatomic, strong, readonly) NSData * privateTag;

@property (nonatomic, readonly) SecKeyRef publicKeyRef;
@property (nonatomic, readonly) SecKeyRef privateKeyRef;

@end
