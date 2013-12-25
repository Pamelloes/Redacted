//
//  RedactedCrypto.m
//  Redacted
//
//  Created by Joshua Brot on 11/25/13.
//
//

#import "RedactedCrypto.h"

#import "AppDelegate.h"
#import <CommonCrypto/CommonCrypto.h>
#import "DDLog.h"

// HUGE portions derived (copied) from SecKeyWrapper.m: https://developer.apple.com/library/ios/samplecode/CryptoExercise/Listings/Classes_SecKeyWrapper_m.html

#define kPaddingType kSecPaddingPKCS1

#define kChosenCipherBlockSize  kCCBlockSizeAES128
#define kChosenCipherKeySize    kCCKeySizeAES256
#define kChosenDigestLength     CC_SHA1_DIGEST_LENGTH

#define kTypeOfSigPadding       kSecPaddingPKCS1SHA1

// (See cssmtype.h and cssmapple.h on the Mac OS X SDK.)

enum {
    CSSM_ALGID_NONE =                   0x00000000L,
    CSSM_ALGID_VENDOR_DEFINED =         CSSM_ALGID_NONE + 0x80000000L,
    CSSM_ALGID_AES
};

// Identifiers used to find public and private key.
static const uint8_t publicKeyIdentifier[]      = kPublicKeyTag;
static const uint8_t privateKeyIdentifier[]     = kPrivateKeyTag;

@interface RedactedCrypto () {
	CFTypeRef pkeypref;
}

- (void) validate: (BOOL) condition Error: (NSString *) error;

- (NSString *)hexString: (NSData *) data;

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
	NSLog(@"%@", error);
	abort();
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

- (NSData *) publicKeyForString:(NSString *)publicKeyString {
	if (![publicKeyString hasPrefix:@"-----BEGIN PUBLIC KEY-----\n"] || ![publicKeyString hasSuffix:@"\n-----END PUBLIC KEY-----"]) return nil;
	NSString *b64enc = [publicKeyString substringWithRange:NSMakeRange(27, [publicKeyString length] - 25 - 27)];
	NSData *data = [[NSData alloc] initWithBase64EncodedString:b64enc options:NSDataBase64Encoding64CharacterLineLength | NSDataBase64DecodingIgnoreUnknownCharacters];
	
	/* Now strip the uncessary ASN encoding guff at the start */
    unsigned char * bytes = (unsigned char *) data.bytes;
    size_t bytesLen = [data length];
    
    /* Strip the initial stuff */
    size_t i = 0;
    if (bytes[i++] != 0x30) return nil;
    
    /* Skip size bytes */
    if (bytes[i] > 0x80) i += bytes[i] - 0x80 + 1;
    else i++;
    
    if (i >= bytesLen) return nil;
    
    if (bytes[i] != 0x30) return nil;
	
    /* Skip OID */
    i += 15;
    
    if (i >= bytesLen - 2) return nil;
	
    if (bytes[i++] != 0x03) return nil;
    
    /* Skip length and null */
    if (bytes[i] > 0x80) i += bytes[i] - 0x80 + 1;
    else i++;
	
    if (i >= bytesLen) return nil;
	
    if (bytes[i++] != 0x00) return nil;

    if (i >= bytesLen) return nil;
    
   return [NSData dataWithBytes:&bytes[i] length:bytesLen - i];
}

#pragma mark - Symmetric Methods

- (NSData *) generateSymmetricKey {
    OSStatus sanityCheck = noErr;
    uint8_t * symmetricKey = NULL;
	
    // Allocate some buffer space. I don't trust calloc.
    symmetricKey = malloc( kChosenCipherKeySize * sizeof(uint8_t) );
    
    [self validate:symmetricKey != NULL Error: @"Problem allocating buffer space for symmetric key generation."];
    
    memset((void *)symmetricKey, 0x0, kChosenCipherKeySize);
    
    sanityCheck = SecRandomCopyBytes(kSecRandomDefault, kChosenCipherKeySize, symmetricKey);
    [self validate:sanityCheck == noErr Error: [NSString stringWithFormat: @"Problem generating the symmetric key, OSStatus == %d.", (int)sanityCheck]];
    
    NSData *res = [[NSData alloc] initWithBytes:(const void *)symmetricKey length:kChosenCipherKeySize];
    
    if (symmetricKey) free(symmetricKey);
	return res;
}


- (NSData *) deriveKey: (NSData *) key Constant: (NSData *) constant {
	// Open CommonKeyDerivation.h for help
    uint8_t * derived = NULL;
	
    // Allocate some buffer space. I don't trust calloc.
    derived = malloc( kChosenCipherKeySize * sizeof(uint8_t) );
    
    [self validate:derived != NULL Error: @"Problem allocating buffer space for symmetric key generation."];
    
    memset((void *)derived, 0x0, kChosenCipherKeySize);
	
	CCKeyDerivationPBKDF(kCCPBKDF2, constant.bytes, constant.length, key.bytes, key.length, kCCPRFHmacAlgSHA256, 10000, derived, 32);
	
    NSData *res = [[NSData alloc] initWithBytes:(const void *)derived length:kChosenCipherKeySize];
    
    if (derived) free(derived);
	return res;
}

- (NSData *) signData:(NSData *)plainText withKey:(SecKeyRef)privateKey {
    OSStatus sanityCheck = noErr;
    NSData * signedHash = nil;
    
    uint8_t * signedHashBytes = NULL;
    size_t signedHashBytesSize = 0;
    
    signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    
    // Malloc a buffer to hold signature.
    signedHashBytes = malloc( signedHashBytesSize * sizeof(uint8_t) );
    memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
    
    // Sign the SHA1 hash.
    sanityCheck = SecKeyRawSign(    privateKey,
								kTypeOfSigPadding,
								(const uint8_t *)[[self hashSha256Raw:plainText] bytes],
								kChosenDigestLength,
								(uint8_t *)signedHashBytes,
								&signedHashBytesSize
                                );
    
    [self validate: sanityCheck == noErr Error: [NSString stringWithFormat: @"Problem signing the SHA1 hash, OSStatus == %d.", (int)sanityCheck]];
    
    // Build up signed SHA1 blob.
    signedHash = [NSData dataWithBytes:(const void *)signedHashBytes length:(NSUInteger)signedHashBytesSize];
    
    if (signedHashBytes) free(signedHashBytes);
    
    return signedHash;
}

- (BOOL)verifySignature:(NSData *)plainText secKeyRef:(SecKeyRef)publicKey signature:(NSData *)sig {
    size_t signedHashBytesSize = 0;
    OSStatus sanityCheck = noErr;
    
    // Get the size of the assymetric block.
    signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    
    sanityCheck = SecKeyRawVerify(  publicKey,
								  kTypeOfSigPadding,
								  (const uint8_t *)[[self hashSha256Raw:plainText] bytes],
								  kChosenDigestLength,
								  (const uint8_t *)[sig bytes],
								  signedHashBytesSize
                                  );
    
    return (sanityCheck == noErr) ? YES : NO;
}

- (NSData *)doCipher:(NSData *)plainText key:(NSData *)symmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7 {
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[kChosenCipherBlockSize];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    [self validate:plainText != nil Error: @"PlainText object cannot be nil." ];
    [self validate:symmetricKey != nil Error: @"Symmetric key object cannot be nil." ];
    [self validate:pkcs7 != NULL Error: @"CCOptions * pkcs7 cannot be NULL." ];
    [self validate:[symmetricKey length] == kChosenCipherKeySize Error: @"Disjoint choices for key size." ];
	
    plainTextBufferSize = [plainText length];
    
    [self validate:plainTextBufferSize > 0 Error: @"Empty plaintext passed in." ];
    
    // We don't want to toss padding on if we don't need to
    if (encryptOrDecrypt == kCCEncrypt) {
        if (*pkcs7 != kCCOptionECBMode) {
            if ((plainTextBufferSize % kChosenCipherBlockSize) == 0) {
                *pkcs7 = 0x0000;
            } else {
                *pkcs7 = kCCOptionPKCS7Padding;
            }
        }
    } else if (encryptOrDecrypt != kCCDecrypt) {
		[self validate: NO Error: [NSString stringWithFormat: @"Invalid CCOperation parameter [%d] for cipher context.", *pkcs7]];
    }
    
    // Create and Initialize the crypto reference.
    ccStatus = CCCryptorCreate( encryptOrDecrypt,
							   kCCAlgorithmAES128,
							   *pkcs7,
							   (const void *)[symmetricKey bytes],
							   kChosenCipherKeySize,
							   (const void *)iv,
							   &thisEncipher
							   );
    
    [self validate: ccStatus == kCCSuccess Error: [NSString stringWithFormat: @"Problem creating the context, ccStatus == %d.", ccStatus]];
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate( thisEncipher,
							   (const void *) [plainText bytes],
							   plainTextBufferSize,
							   ptr,
							   remainingBytes,
							   &movedBytes
							   );
    
    [self validate: ccStatus == kCCSuccess Error: [NSString stringWithFormat: @"Problem with CCCryptorUpdate, ccStatus == %d.", ccStatus ]];
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(  thisEncipher,
							  ptr,
							  remainingBytes,
							  &movedBytes
							  );
    
    totalBytesWritten += movedBytes;
    
    if (thisEncipher) {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
    [self validate: ccStatus == kCCSuccess Error: [NSString stringWithFormat: @"Problem with encipherment ccStatus == %d", ccStatus ]];
    
    cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
	
    if (bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;
    
    /*
     Or the corresponding one-shot call:
     
     ccStatus = CCCrypt(    encryptOrDecrypt,
	 kCCAlgorithmAES128,
	 typeOfSymmetricOpts,
	 (const void *)[self getSymmetricKeyBytes],
	 kChosenCipherKeySize,
	 iv,
	 (const void *) [plainText bytes],
	 plainTextBufferSize,
	 (void *)bufferPtr,
	 bufferPtrSize,
	 &movedBytes
	 );
     */
}

#pragma mark - Hashing methods

- (NSString *)hexString: (NSData *) data {
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    if (!dataBuffer)  return [NSString string];
    NSUInteger dataLength = [data length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i)  [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    return [NSString stringWithString:hexString];
}

- (NSData *)hashSha256Raw:(NSData *)data {
	unsigned char result[32];
	CC_SHA256([data bytes], [data length], result);
	return [NSData dataWithBytes:result length:32];
}

- (NSString *)hashSha256:(NSData *)data {
	return [self hexString:[self hashSha256Raw:data]];
}

@end
