//
//  ChatUtil.m
//  Redacted
//
//  Created by Joshua Brot on 12/15/13.
//
//

#import "ChatUtil.h"

#import "AppDelegate.h"
#import "Chat.h"
#import "Contact.h"
#import "User.h"
#import "Message.h"
#import "UserManager.h"
#import "RedactedCrypto.h"

#define MESSAGE_VERSION @"1.0"

@interface ChatUtil ()

- (NSString *) headerForChat: (Chat *) chat;
- (NSString *) encryptMessage: (NSString *) msg  Duration: (int) count Key: (NSData *) key;

- (NSData *) constantWithOffset: (int) offset;

@end

@implementation ChatUtil

@synthesize ad;

- (instancetype) initWithAppDelegate: (AppDelegate *) add {
	if ((self = [super init])) {
		ad = add;
	}
	return self;
}

- (NSDictionary *) encryptMessage:(NSString *)msg From:(User *)user Chat:(Chat *)chat Duration: (NSInteger) count {
	NSData *key = [ad.crypto generateSymmetricKey];
	
	//Generate message
	NSString *decrypted = [NSString stringWithFormat:@"MSG\0%@\0%@\0%@\0%@", MESSAGE_VERSION, chat.uuid, [ad.crypto hashSha256:[[self headerForChat:chat] dataUsingEncoding:NSUTF8StringEncoding]],
						   [self encryptMessage:msg Duration:count Key:key]];
	
	//Encrypt message with session key
	CCOptions options = kCCOptionPKCS7Padding;
	NSString *encrypted = [[ad.crypto doCipher:[decrypted dataUsingEncoding:NSUTF8StringEncoding] key: key context: kCCEncrypt padding: &options] base64EncodedStringWithOptions: 0];
	
	//Encrypt session key on a per user basis.
	NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[chat.users count]];
	for (User *u in chat.users) {
		SecKeyRef ukey = [ad.usermanager keyForUser:u];
		//Encrypt with our key first, then theirs.
		NSString *enc = [[ad.crypto encryptData:[ad.crypto encryptData:key key:ad.crypto.privateKeyRef] key:ukey] base64EncodedStringWithOptions: 0];
		[result setObject:[NSString stringWithFormat:@"%@\0%@", enc, encrypted] forKey:u.name];
	}
	return result;
}

- (Message *) validateMessage:(NSString *)msg From:(User *)user {
	NSArray *parts = [msg componentsSeparatedByString:@"\0"];
	if ([parts count] != 2) return nil;
	
	//Attempt to decrypt session key.
	NSData *enkey = [[NSData alloc] initWithBase64EncodedString:[parts objectAtIndex:0] options:0];
	if (enkey == nil) return nil; //Bad base64 encoding.
	//Decrypt with our key first
	NSData *deckey = [ad.crypto decryptData:enkey key:ad.crypto.privateKeyRef];
	if (deckey == nil) return nil; //Not encrypted for us.
	//Then decrypt with theirs
	NSData *key = [ad.crypto decryptData:deckey key:[ad.usermanager keyForUser: user]];
	if (key == nil) return nil; //Not encrypted from them.
	
	//Attempt to decrypt message body.
	NSData *enbody = [[NSData alloc] initWithBase64EncodedString:[parts objectAtIndex:1] options:0];
	if (enbody == nil) return nil; //Bad base64 encoding.
	CCOptions options = kCCOptionPKCS7Padding;
	NSData *decbody = [ad.crypto doCipher:enbody key:key context: kCCDecrypt padding: &options];
	if (decbody == nil) return nil; //Bad session key.
	NSString *body = [[NSString alloc] initWithData:decbody encoding:NSUTF8StringEncoding];
	if (body == nil || ![body hasPrefix:@"MSG\0"]) return nil; //Bad session key.
	
	parts = [body componentsSeparatedByString:@"\0"];
	if ([parts count] < 6) return nil; //Bad message format.
	
	//Validate version
	if (![MESSAGE_VERSION isEqualToString:[parts objectAtIndex:1]]) {
		DDLogError(@"Recieved message in version %@. We are in version %@! Some compatibility code should exist...", [parts objectAtIndex: 1], MESSAGE_VERSION);
		return nil;
	}
	
	//Retrieve Chat object
	NSError *error;
	NSString *uuid = [parts objectAtIndex:2];
	NSArray *chats = [Chat fetchWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"uuid LIKE \"%@\"",uuid]] error:&error];
	if (error || chats == nil) {
		DDLogError(@"Error retrieving Chat with uuid %@: %@", uuid, error);
		return nil;
	} else if ([chats count] < 1) {
		DDLogError(@"No Chat found with uuid %@!", uuid);
		return nil;
	} else if ([chats count] > 1) {
		DDLogWarn(@"Found multiple chats with uuid %@! Using first.", uuid);
	}
	Chat *chat = [chats objectAtIndex:0];
	if (chat == nil) return nil; //Whatever... :/
	
	//Verify headers
	NSString *hash = [ad.crypto hashSha256:[[self headerForChat:chat] dataUsingEncoding:NSUTF8StringEncoding]];
	if (![hash isEqualToString:[parts objectAtIndex:3]]) {
		DDLogWarn(@"Header mismatch for chat %@! Ignoring...", chat);
		//TODO alert caller of hash mismatch, queue message while headers are synced. Then continue with decryption after the inconsistancy is resolved.
	}
	
	Message *message = [Message newEntityWithError:&error];
	if (error) {
		DDLogError(@"Could not create new message entity: %@", error);
		return nil;
	}
	
	message.from = user;
	message.to = ad.local.primary;
	message.chat = chat;
	message.payload = msg;
	return message;
}

- (NSString *) decryptMessage:(Message *)msg {
	NSArray *parts = [msg.payload componentsSeparatedByString:@"\0"];
	if ([parts count] != 2) return nil;
	
	//Attempt to decrypt session key.
	NSData *enkey = [[NSData alloc] initWithBase64EncodedString:[parts objectAtIndex:0] options:0];
	if (enkey == nil) return nil; //Bad base64 encoding.
	//Decrypt with our key first
	NSData *deckey = [ad.crypto decryptData:enkey key:ad.crypto.privateKeyRef];
	if (deckey == nil) return nil; //Not encrypted for us.
	//Then decrypt with theirs
	NSData *key = [ad.crypto decryptData:deckey key:[ad.usermanager keyForUser: msg.from]];
	if (key == nil) return nil; //Not encrypted from them.
	
	//Attempt to decrypt message body.
	NSData *enbody = [[NSData alloc] initWithBase64EncodedString:[parts objectAtIndex:1] options:0];
	if (enbody == nil) return nil; //Bad base64 encoding.
	CCOptions options = kCCOptionPKCS7Padding;
	NSData *decbody = [ad.crypto doCipher:enbody key:key context: kCCDecrypt padding: &options];
	if (decbody == nil) return nil; //Bad session key.
	NSString *body = [[NSString alloc] initWithData:decbody encoding:NSUTF8StringEncoding];
	if (body == nil || ![body hasPrefix:@"MSG\0"]) return nil; //Bad session key.
	
	parts = [body componentsSeparatedByString:@"\0"];
	if ([parts count] < 6) return nil; //Bad message format.
	
	//Validate version
	if (![MESSAGE_VERSION isEqualToString:[parts objectAtIndex:1]]) {
		DDLogError(@"Recieved message in version %@. We are in version %@! Some compatibility code should exist...", [parts objectAtIndex: 1], MESSAGE_VERSION);
		return nil;
	}
	
	//We can skip finding the Chat object (it was already found)
	
	//Header doesn't need to be validated (it was already validated)
	
	//Find and decode the message for right now.
	NSData *mkey = [ad.crypto deriveKey:key Constant:[self constantWithOffset:0]];
	for (int i = 4; i < [parts count]; i++) {
		NSData *enmsg = [[NSData alloc] initWithBase64EncodedString:[parts objectAtIndex:i] options:0];
		if (enmsg == nil) continue; //Bad format.
		NSData *decmsg = [ad.crypto doCipher:enmsg key:mkey context:kCCDecrypt padding:&options];
		if (decmsg == nil) continue; //Not encrpted for now.
		NSString *msg = [[NSString alloc] initWithData:decmsg encoding:NSUTF8StringEncoding];
		if (msg == nil || ![msg hasPrefix:@"MSG\0"]) continue; //Not encrpted for now.
		return [msg substringFromIndex:4]; //Found it!
	}
	
	return nil;
}

- (NSString *)headerForChat:(Chat *)chat {
	NSArray *users = [chat.users sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
	NSMutableString *str = [[NSMutableString alloc] initWithCapacity:50];
	for (User *u in users) [str appendString:[u.name lowercaseString]];
	return [NSString stringWithFormat:@"%@%@%ld",chat.name,str,chat.update.longValue];
}

- (NSString *)encryptMessage:(NSString *)msg Duration:(int)count Key:(NSData *)key {
	//Some food for thought: Because the message is encoded separately for each time slot, it is quite easy
	//to imagine that an imposter [or future version] could send a "transient" message that would display'
	//something different depending on what time interval it was decrypted in.
	NSString *message = [NSString stringWithFormat:@"MSG\0%@", msg];
	NSMutableString *encrypted = [[NSMutableString alloc] initWithCapacity:[msg length] * 8 * count];
	//TODO we need to randomize the order of the messages so that an attacker can't immediately know the
	//timestamp for every section once he or she finds one of them. It would also be a good idea to throw
	//in "decoy" sections that will be random text that doesn't start with "MSG\0" encoded for arbitrary
	//time intervals. Since the message doesn't start with "MSG\0" then the client will ignore it if the
	//message is decrypted during the randomly selected time. As a side effect, it can put a significant
	//slowdown in an attacker trying to brute force his or her way into the messages. Albeit, once an
	//attacker finds one message the others can still be relatively easily found but this will make it
	//slightly harder.
	for (int i = 0; i < count; i++) {
		CCOptions options = kCCOptionPKCS7Padding;
		[encrypted appendString: [[ad.crypto doCipher:[message dataUsingEncoding:NSUTF8StringEncoding] key: [ad.crypto deriveKey:key Constant:[self constantWithOffset:i]]
											  context: kCCEncrypt padding: &options] base64EncodedStringWithOptions: 0]];
		if (i < count - 1) [encrypted appendString:@"\0"];
	}
	return encrypted;
}

- (NSData *) constantWithOffset:(int)offset {
	return [@"o3o" dataUsingEncoding:NSUTF8StringEncoding];
}

@end
