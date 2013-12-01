//
//  UserManager.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import <Foundation/Foundation.h>


typedef enum {
	VALIDATED,
	INVALIDATED,
	FAILURE
} result;

typedef void (^callback) (result);



@class AppDelegate, User;

@interface UserManager : NSObject {
	AppDelegate *ad;
	NSManagedObjectContext *context;
}

- (instancetype) initWithAppDelegate: (AppDelegate *) ad Context: (NSManagedObjectContext *) context;

- (void) validateUserExists: (NSString *) user Callback: (callback) callback;
- (void) retrieveUser: (NSString *) user Callback: (callback) callback;

- (User *) userWithName: (NSString *) name;
- (void) removeUser: (User *) user Callback: (callback) callback;

@property (nonatomic, weak, readonly) AppDelegate *ad;
@property (nonatomic, weak, readonly) NSManagedObjectContext *context;

@end
