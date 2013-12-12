//
//  UserManager.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "UserManager.h"

#import "Configuration.h"
#import "RedactedCrypto.h"
#import "URLUtil.h"
#import "MAFuture.h"
#import "Result.h"
#import "JSONKit.h"
#import "User.h"
#import "Contact.h"

@interface UserManager ()

@end

@implementation UserManager

@synthesize config, local;

- (instancetype) initWithConfiguration: (Configuration *) conf Crypto: (RedactedCrypto *) crypto {
	if (self = [super init]) {
		config = conf;
		
		if (!config.lcontact) {
			DDLogError(@"No local contact defined - cannot instantiate UserManager!");
			self = nil;
			return self;
		}
		
		local = config.lcontact.primary;
		if (!local) {
			DDLogInfo(@"Could not find root user...");
			DDLogInfo(@"Generating new root user...");
			
			NSError *error;
			local = [User newEntityWithError:&error];
			if (error) DDLogError(@"Error creating user: %@", error);
			local.pkey = crypto.publicKeyString;
			local.primary = config.lcontact;
			
			config.lcontact.primary = local;
			[config.lcontact addUsersObject:local];
			
			error = [Configuration commit];
			if (error) DDLogError(@"Error saving database: %@", error);
		}
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
		User *usr = [self userWithName:user];
		if (usr) return [[Result alloc] initWithResult:SUCCESS Error:nil Data:usr];
		
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
		usr = [User newEntityWithError:&err];
		if (err || !usr || (cancel != NULL && *cancel)) return [[Result alloc] initWithResult:FAILURE Error:err Data:nil]; //Last chance to cancel
		usr.name = user;
		usr.addr = address;
		usr.pkey = pubkey;
		
		err = [User commit];
		if (err) return [[Result alloc] initWithResult:FAILURE Error:err Data:nil];
		
		return [[Result alloc] initWithResult:SUCCESS Error:nil Data:usr];
	});
}

- (User *) userWithName: (NSString *) name {
	NSError *error;
	NSArray *result = [User fetchWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name LIKE[c] \"%@\"",name]] error:&error];
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
