//
//  User.m
//  Redacted
//
//  Created by Joshua Brot on 12/1/13.
//
//

#import "User.h"

#import "Configuration.h"
#import "Chat.h"
#import "Contact.h"

@implementation User

+(NSString *)entityName {
	return @"UserEntity";
}

+(NSString *)modelName {
	return @"Redacted";
}

- (void)prepareForDeletion {
	// If we are the local user, then shit hit the fan and we will abort.
	if (self.primary != nil) {
		DDLogError(@"Tried to delete local contact!");
		DDLogError(@"Aborting!");
		abort();
	}
	
	for (Chat *chat in self.chats) {
		if (!chat || chat.isDeleted) continue;
		
		// Delete the chat if we are the last user (besides the local user) in it
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDeleted == NO"];
		NSSet *users = [chat.users filteredSetUsingPredicate:predicate];
		
		if ([users count] == 0) [chat delete];
		else if ([users count] == 1) {
			User *user = users.anyObject; // Since there is only one object, this is gauranteed to return the correct object.
			if (user.primary != nil) [chat delete]; // Only the local user remains.
		}
	}
}

@end
