//
//  ChatUtil.h
//  Redacted
//
//  Created by Joshua Brot on 12/15/13.
//
//

#import <Foundation/Foundation.h>

@class AppDelegate, Chat, User, Message;

@interface ChatUtil : NSObject {
	__weak AppDelegate *ad;
}

- (instancetype) initWithAppDelegate: (AppDelegate *) ad;

- (NSDictionary *) encryptMessage:(NSString *)msg From:(User *)user Chat:(Chat *)chat Duration: (NSInteger) count;
- (Message *) validateMessage:(NSString *)msg From:(User *)user;
- (NSString *) decryptMessage: (Message *)msg;


@property (nonatomic, weak, readonly) AppDelegate *ad;

@end
