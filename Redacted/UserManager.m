//
//  UserManager.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "UserManager.h"

#import "Configuration.h"
#import "URLUtil.h"
#import "MAFuture.h"
#import "Result.h"
#import "JSONKit.h"
#import "User.h"
#import "DDLog.h"

@interface UserManager ()

@end

const int ddLogLevel = LOG_LEVEL_INFO;

@implementation UserManager

@synthesize config;

- (instancetype) initWithConfiguration: (Configuration *) conf {
	if (self = [super init]) {
		config = conf;
	}
	return self;
}

- (Result *) validateUserExists: (NSString *) user Cancel: (BOOL *) cancel {
	return MABackgroundFuture(^{
		Result *url = [URLUtil retrieveURL:[NSURL URLWithString:[NSString stringWithFormat:@"exists.php?name=%@", [URLUtil urlencode:user]] relativeToURL:[URLUtil serverURL]] Cancel:cancel];
		if (url.result == FAILURE || url.result == UNKNOWN || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:UNKNOWN Error:url.error Data:nil];
		
		NSError *err = nil;
		NSData *dl = url.data;
		NSDictionary *json = [dl objectFromJSONDataWithParseOptions:JKParseOptionNone error:&err];
		if (err || !json || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:UNKNOWN Error:err Data:dl];
		
		if ([json objectForKey:@"error"]) return [[Result alloc] initWithResult:UNKNOWN Error: [NSError errorWithDomain:@"Redacted" code:-1
																											   userInfo:@{NSLocalizedDescriptionKey: [json objectForKey:@"error"]}]  Data:dl];
		else return [[Result alloc] initWithResult:([(NSNumber *)[json objectForKey:@"exists"] boolValue]) ? SUCCESS : FAILURE Error:nil Data:dl];
	});
}

- (Result *) retrieveUser: (NSString *) user Cancel: (BOOL *) cancel {
	return MABackgroundFuture(^{
		Result *exists = [self validateUserExists:user Cancel:cancel];
		if (exists.result != SUCCESS || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:FAILURE Error:exists.error Data:nil];
		
		Result *addr = [URLUtil retrieveURL:[NSURL URLWithString:[NSString stringWithFormat:@"addr.php?name=%@", [URLUtil urlencode:user]] relativeToURL:[URLUtil serverURL]] Cancel:cancel];
		if (addr.result == FAILURE || addr.result == UNKNOWN || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:FAILURE Error:addr.error Data:nil];
		
		NSError *err = nil;
		NSData *dl = addr.data;
		NSDictionary *json = [dl objectFromJSONDataWithParseOptions:JKParseOptionNone error:&err];
		if (err || !json || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:FAILURE Error:err Data:dl];
		
		if ([json objectForKey:@"error"]) return [[Result alloc] initWithResult:UNKNOWN Error: [NSError errorWithDomain:@"Redacted" code:-1
																											   userInfo:@{NSLocalizedDescriptionKey: [json objectForKey:@"error"]}]  Data:dl];
		NSString *address = [json objectForKey:@"addr"];
		
		Result *pkey = [URLUtil retrieveURL:[NSURL URLWithString:[NSString stringWithFormat:@"exists.php?name=%@", [URLUtil urlencode:user]] relativeToURL:[URLUtil serverURL]] Cancel:cancel];
		if (pkey.result == FAILURE || pkey.result == UNKNOWN || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:FAILURE Error:pkey.error Data:nil];
		
		err = nil;
		dl = pkey.data;
		json = [dl objectFromJSONDataWithParseOptions:JKParseOptionNone error:&err];
		if (err || !json || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:FAILURE Error:err Data:dl];
		
		if ([json objectForKey:@"error"]) return [[Result alloc] initWithResult:FAILURE Error: [NSError errorWithDomain:@"Redacted" code:-1
																											   userInfo:@{NSLocalizedDescriptionKey: [json objectForKey:@"error"]}]  Data:dl];
		NSString *pubkey = [json objectForKey:@"pkey"];
		
		err = nil;
		User *usr = [User newEntityWithError:&err];
		if (err || !usr || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:FAILURE Error:err Data:nil]; //Last chance to cancel
		usr.name = user;
		usr.addr = address;
		usr.pkey = pubkey;
		usr.config = config;
		[config addUsersObject:usr];
		
		err = [User commit];
		if (err) return [[Result alloc] initWithResult:FAILURE Error:err Data:nil];
		
		return [[Result alloc] initWithResult:SUCCESS Error:nil Data:nil];
	});
}

- (User *) userWithName: (NSString *) name {
	NSError *error;
	NSArray *result = [User fetchWithPredicate:[NSPredicate predicateWithFormat:@"name like \"%@\"", name] error:&error];
	if (error) {
		DDLogError(@"Could not retrieve user from database: %@", error);
		return nil;
	}
	if (!result || result.count <= 0) return nil;
	if (result.count > 1) DDLogWarn(@"Multiple users found for name: %@", name);
	return result.firstObject;
}

- (User *) fetchOrRetrieveUser: (NSString *) user {
	User *res = [self userWithName:user];
	if (res) return res;
	[self retrieveUser:user Cancel:NULL];
	return [self userWithName:user]; //This will still be nil if retrieval was unsuccessful.
}

@end
