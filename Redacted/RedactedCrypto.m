//
//  RedactedCrypto.m
//  Redacted
//
//  Created by Joshua Brot on 11/25/13.
//
//

#import "RedactedCrypto.h"

#import "AppDelegate.h"
#import <stdio.h>
#import "DDLog.h"

// HUGE portions derived (copied) from SecKeyWrapper.m: https://developer.apple.com/library/ios/samplecode/CryptoExercise/Listings/Classes_SecKeyWrapper_m.html

#define kPaddingType kSecPaddingPKCS1

// Identifiers used to find public and private key.
static const uint8_t publicKeyIdentifier[]      = kPublicKeyTag;
static const uint8_t privateKeyIdentifier[]     = kPrivateKeyTag;

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface RedactedCrypto () {
	CFTypeRef pkeypref;
}

- (void) validate: (BOOL) condition Error: (NSString *) error;

@end

@implementation RedactedCrypto

@synthesize delegate, publicTag, privateTag, publicKeyRef, privateKeyRef;

- (instancetype) initWithDelegate: (AppDelegate *) ad {
	self = [super init];
	if (self) {
		delegate = ad;
		
		// Tag data to search for keys.
		privateTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
		publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
		
		// Put in NULL default keys.
		pkeypref = NULL;
		privateKeyRef = NULL;
		publicKeyRef = NULL;
	}
	return self;
}

- (void) dealloc {
	if (pkeypref) CFRelease(pkeypref);
	if (publicKeyRef) CFRelease(publicKeyRef);
    if (privateKeyRef) CFRelease(privateKeyRef);
}

- (void) validate:(BOOL)condition Error:(NSString *)error {
	if (condition) return;
	DDLogError(@"%@", error);
}

#pragma mark - Local Key Methods

- (void) loadLocalKeys {
	//Clear current references.
	if (pkeypref) CFRelease(pkeypref);
	if (publicKeyRef) CFRelease(publicKeyRef);
	if (privateKeyRef) CFRelease(privateKeyRef);
	
    OSStatus sanityCheck = noErr;
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnRef];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnRef];
	
	publicKeyRef = NULL;
	sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef) queryPublicKey,  (CFTypeRef *) &publicKeyRef);
	[self validate: (sanityCheck == noErr && publicKeyRef != NULL) || sanityCheck == errSecItemNotFound Error: [NSString stringWithFormat: @"Error retrieving public key, OSStatus == %d.", (int) sanityCheck]];
	BOOL regen = sanityCheck == errSecItemNotFound;
	
	privateKeyRef = NULL;
	sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef) queryPrivateKey,  (CFTypeRef *) &privateKeyRef);
	[self validate: (sanityCheck == noErr && privateKeyRef != NULL) || sanityCheck == errSecItemNotFound Error: [NSString stringWithFormat: @"Error retrieving public key, OSStatus == %d.", (int) sanityCheck]];
	regen = regen || sanityCheck == errSecItemNotFound;
	
	if (regen) {
		 //If we somehow loaded one key, we need to release it.
		if (publicKeyRef) CFRelease(publicKeyRef);
		if (privateKeyRef) CFRelease(privateKeyRef);
		
		DDLogInfo(@"Could not retrieve keypair - generating new one!");
		[self generateLocalKeys:1024];
	} else {
		pkeypref = [self persistentKeyRefWithKeyRef:publicKeyRef];
		DDLogInfo(@"Retrieved keypair!");
	}
}

- (void)deleteLocalKeys {
    OSStatus sanityCheck = noErr;
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Delete the private key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    [self validate: sanityCheck == noErr || sanityCheck == errSecItemNotFound Error: [NSString stringWithFormat: @"Error removing private key, OSStatus == %d.", (int) sanityCheck]];
    
    // Delete the public key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    [self validate: sanityCheck == noErr || sanityCheck == errSecItemNotFound Error: [NSString stringWithFormat: @"Error removing public key, OSStatus == %d.", (int) sanityCheck]];
    
	if (pkeypref) CFRelease(pkeypref);
    if (publicKeyRef) CFRelease(publicKeyRef);
    if (privateKeyRef) CFRelease(privateKeyRef);
	
	// Put in NULL values just in case.
	pkeypref = NULL;
	publicKeyRef = NULL;
	privateKeyRef = NULL;
}

- (void)generateLocalKeys:(NSUInteger)keySize {
    OSStatus sanityCheck = noErr;
    publicKeyRef = NULL;
    privateKeyRef = NULL;
    
    [self validate: keySize == 512 || keySize == 1024 || keySize == 2048 Error: [NSString stringWithFormat: @"%d is an invalid and unsupported key size.", keySize]];
    
    // First delete current keys.
    [self deleteLocalKeys];
    
    // Container dictionaries.
    NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
    
    // Set top level dictionary for the keypair.
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:keySize] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    // Set the private key dictionary.
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set the public key dictionary.
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set attributes to top level dictionary.
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
    // SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
    sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
    [self validate: sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL Error: @"Something really bad went wrong with generating the key pair."];
	
	pkeypref = [self persistentKeyRefWithKeyRef:publicKeyRef];
}

- (NSData *)publicKeyBits {
    return [self bitsForPersistantKeyRef: pkeypref];
}

- (NSString *) publicKeyString {
	return [self stringForPublicKey:[self publicKeyBits]];
}

#pragma mark - Remote Keys Methods

- (SecKeyRef)addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey {
    OSStatus sanityCheck = noErr;
    SecKeyRef peerKeyRef = NULL;
    CFTypeRef persistPeer = NULL;
    
    [self validate:peerName != nil Error:@"Peer name parameter is nil."];
    [self validate:publicKey != nil Error:@"Public key parameter is nil."];
    
    NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
    NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
    
    [peerPublicKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [peerPublicKeyAttr setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];
    [peerPublicKeyAttr setObject:publicKey forKey:(__bridge id)kSecValueData];
    [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&persistPeer);
    
    // The nice thing about persistent references is that you can write their value out to disk and
    // then use them later. I don't do that here but it certainly can make sense for other situations
    // where you don't want to have to keep building up dictionaries of attributes to get a reference.
    //
    // Also take a look at SecKeyWrapper's methods (CFTypeRef)getPersistentKeyRefWithKeyRef:(SecKeyRef)key
    // & (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef.
    
    [self validate:sanityCheck == noErr || sanityCheck == errSecDuplicateItem Error: [NSString stringWithFormat:@"Problem adding the peer public key to the keychain, OSStatus == %d.", (int) sanityCheck]];
    
    if (persistPeer) {
        peerKeyRef = [self keyRefWithPersistentKeyRef:persistPeer];
    } else {
        [peerPublicKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
        [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        // Let's retry a different way.
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&peerKeyRef);
    }
    
    [self validate:sanityCheck == noErr && peerKeyRef != NULL Error: [NSString stringWithFormat:@"Problem acquiring reference to the public key, OSStatus == %d.", (int) sanityCheck]];
    
    if (persistPeer) CFRelease(persistPeer);
    return peerKeyRef;
}

- (void)removePeerPublicKey:(NSString *)peerName {
    OSStatus sanityCheck = noErr;
    
    [self validate:peerName != nil Error:@"Peer name parameter is nil."];
    
    NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
    NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
    
    [peerPublicKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [peerPublicKeyAttr setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef) peerPublicKeyAttr);
    
	[self validate:sanityCheck == noErr || sanityCheck == errSecItemNotFound Error: [NSString stringWithFormat:@"Problem deleting the peer public key to the keychain, OSStatus == %d.", (int) sanityCheck]];
}

#pragma mark - Data Encryption Methods

- (NSData *) encryptData: (NSData *) data key: (SecKeyRef) key {
    OSStatus sanityCheck = noErr;
	
    [self validate: key != NULL Error: @"key object cannot be NULL."];
    [self validate: data != NULL Error: @"data object cannot be NULL."];
	
    const uint8_t *dataToEncrypt = [data bytes];
    size_t dataLength = [data length];
	
	size_t cipherBufferSize = SecKeyGetBlockSize(key);
	uint8_t *cipherBuffer = malloc( ceil(dataLength/(double)cipherBufferSize) * cipherBufferSize);
	
	size_t pos = 0;
	size_t epos = 0;
	size_t enpos = cipherBufferSize;
	while (pos < dataLength) {
		//NSLog(@"Encrypt: %lu %lu %lu", pos, epos, enpos);
		sanityCheck = SecKeyEncrypt(key, kPaddingType, dataToEncrypt + pos * sizeof(uint8_t), MIN(cipherBufferSize - 11, dataLength - pos),  cipherBuffer + epos * sizeof(uint8_t), &enpos);
		[self validate:sanityCheck == noErr Error: [NSString stringWithFormat:@"Could not encrypt data! OSStatus == %d.", (int) sanityCheck]];
		
		pos += cipherBufferSize - 11;
		epos += enpos;
		enpos = cipherBufferSize;
	}
	
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:epos];
	
    free(cipherBuffer);
	
    return encryptedData;
}

- (NSData *) decryptData: (NSData *) data key: (SecKeyRef) key {
    OSStatus sanityCheck = noErr;
	
    [self validate: key != NULL Error: @"key object cannot be NULL."];
    [self validate: data != NULL Error: @"data object cannot be NULL."];
	
    size_t cipherBufferSize = [data length];
    uint8_t *cipherBuffer = (uint8_t *)[data bytes];
	
    size_t plainBufferSize;
    uint8_t *plainBuffer;
	
    //  Allocate the buffer
    plainBufferSize = SecKeyGetBlockSize(key);
    plainBuffer = malloc(ceil(cipherBufferSize/(double)plainBufferSize) * plainBufferSize);
	
	size_t pos = 0;
	size_t epos = 0;
	size_t enpos = plainBufferSize;
	while (pos < cipherBufferSize) {
		//NSLog(@"Decrypt: %lu %lu %lu", pos, epos, enpos);
		sanityCheck = SecKeyDecrypt(key, kPaddingType, cipherBuffer + pos * sizeof(uint8_t), MIN(plainBufferSize, cipherBufferSize - pos), plainBuffer + epos * sizeof(uint8_t), &enpos);
		[self validate:sanityCheck == noErr Error: [NSString stringWithFormat:@"Could not decrypt data! OSStatus == %d.", (int) sanityCheck]];
		
		pos += plainBufferSize;
		epos += enpos;
		enpos = plainBufferSize;
	}
	
	
	NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:epos];
	
	free (plainBuffer);
	
	return decryptedData;
}

#pragma mark - Utility Methods

- (CFTypeRef)persistentKeyRefWithKeyRef:(SecKeyRef)keyRef {
    OSStatus sanityCheck = noErr;
    CFTypeRef persistentRef = NULL;
    
    [self validate: keyRef != NULL Error: @"keyRef object cannot be NULL."];
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    
    // Set the PersistentKeyRef key query dictionary.
    [queryKey setObject:(__bridge id)keyRef forKey:(__bridge id)kSecValueRef];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    // Get the persistent key reference.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&persistentRef);
    
    return persistentRef;
}

- (SecKeyRef)keyRefWithPersistentKeyRef:(CFTypeRef)persistentRef {
    OSStatus sanityCheck = noErr;
    SecKeyRef keyRef = NULL;
    
    [self validate: persistentRef != NULL Error: @"persistentRef object cannot be NULL."];
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    
    // Set the SecKeyRef query dictionary.
    [queryKey setObject:(__bridge id)persistentRef forKey:(__bridge id)kSecValuePersistentRef];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    // Get the persistent key reference.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&keyRef);
    
    return keyRef;
}

- (NSData *)bitsForPersistantKeyRef:(CFTypeRef)keyRef {
    OSStatus sanityCheck = noErr;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
	
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)keyRef forKey:(__bridge id)kSecValuePersistentRef];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
	
    // Get the key bits.
	CFTypeRef ref = NULL;
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, &ref);
    NSData * publicKeyBits = (__bridge NSData *) ref;
	
    if (sanityCheck != noErr)
    {
        publicKeyBits = nil;
    }
    
    return publicKeyBits;
}

size_t encodeLength(unsigned char * buf, size_t length) {
	
    // encode length in ASN.1 DER format
    if (length < 128) {
        buf[0] = length;
        return 1;
    }
	
    size_t i = (length / 256) + 1;
    buf[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j) {         buf[i - j] = length & 0xFF;         length = length >> 8;
    }
	
    return i + 1;
}

-(NSString *) stringForPublicKey:(NSData *) publicKeyBits {
	
    static const unsigned char _encodedRSAEncryptionOID[15] = {
        /* Sequence of length 0xd made up of OID followed by NULL */
        0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
    };
	
    // OK - that gives us the "BITSTRING component of a full DER
    // encoded RSA public key - we now need to build the rest
	
    unsigned char builder[15];
    NSMutableData * encKey = [[NSMutableData alloc] init];
    int bitstringEncLength;
	
    // When we get to the bitstring - how will we encode it?
    if  ([publicKeyBits length ] + 1  < 128 )
        bitstringEncLength = 1 ;
    else
        bitstringEncLength = (([publicKeyBits length ] + 1 ) / 256 ) + 2;
	
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of -
    // size of OID + size of bitstring encoding + size of actual key
    size_t i = sizeof(_encodedRSAEncryptionOID) + 2 + bitstringEncLength + [publicKeyBits length];
    size_t j = encodeLength(&builder[1], i);
    [encKey appendBytes:builder length:j + 1];
	
    // First part of the sequence is the OID
    [encKey appendBytes:_encodedRSAEncryptionOID length:sizeof(_encodedRSAEncryptionOID)];
	
    // Now add the bitstring
    builder[0] = 0x03;
    j = encodeLength(&builder[1], [publicKeyBits length] + 1);
    builder[j+1] = 0x00;
    [encKey appendBytes:builder length:j + 2];
	
    // Now the actual key
    [encKey appendData:publicKeyBits];
	
    // Now translate the result to a Base64 string
	NSString *encoded = [[NSString alloc] initWithData: [encKey base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed]
											  encoding:NSUTF8StringEncoding];
	
	return [NSString stringWithFormat: @"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----", encoded];
}

@end
