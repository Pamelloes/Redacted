//
//  UserManager.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import <Foundation/Foundation.h>

@class Configuration, RedactedCrypto, User, Result;

@interface UserManager : NSObject {
	__weak Configuration *config;
	
	User *local;
}

- (instancetype) initWithConfiguration: (Configuration *) config  Crypto: (RedactedCrypto *) crypto;

- (Result *) validateUserExists: (NSString *) user Cancel: (BOOL *) cancel;
- (Result *) retrieveUser: (NSString *) user Cancel: (BOOL *) cancel;
- (User *) userWithName: (NSString *) name;
- (User *) fetchOrRetrieveUser: (NSString *) user;

@property (nonatomic, weak, readonly) Configuration *config;

@property (nonatomic, strong, readonly) User *local;

@end
