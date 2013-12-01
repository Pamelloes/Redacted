//
//  UserManager.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "UserManager.h"

#import "AppDelegate.h"
#import "User.h"
#import "URLUtil.h"

#import "DDLog.h"

@interface UserManager ()

@end

const int ddLogLevel = LOG_LEVEL_INFO;

@implementation UserManager

- (instancetype) initWithAppDelegate: (AppDelegate *) apd Context: (NSManagedObjectContext *) ctxt {
	if (self = [super init]) {
		ad = apd;
		context = ctxt;
	}
	return self;
}

- (void) validateUserExists: (NSString *) user Callback: (callback) callback {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"exists.php?name=%@", [URLUtil urlencode:user]] relativeToURL:[URLUtil serverURL]];
	[URLUtil retrieveURL:url Completed:^{
		
	} Failure:^(NSError *error){
		DDLogError(@"Error validating user existance: %@", url);
	}];
}

- (void) retrieveUser: (NSString *) user Callback: (callback) callback {
	
}

- (User *) userWithName: (NSString *) name {
	
}

- (void) removeUser: (User *) user Callback: (callback) callback {
	
}

@end
