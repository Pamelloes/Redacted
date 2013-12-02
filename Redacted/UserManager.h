//
//  UserManager.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import <Foundation/Foundation.h>

@class Configuration, User, Result;

@interface UserManager : NSObject {
	__weak Configuration *config;
}

- (instancetype) initWithConfiguration: (Configuration *) config;

- (Result *) validateUserExists: (NSString *) user Cancel: (BOOL *) cancel;
- (Result *) retrieveUser: (NSString *) user Cancel: (BOOL *) cancel;
- (User *) userWithName: (NSString *) name;
- (User *) fetchOrRetrieveUser: (NSString *) user;

@property (nonatomic, weak, readonly) Configuration *config;

@end
