//
//  Configuration.h
//  Redacted
//
//  Created by Joshua Brot on 12/1/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Chat, User;

@interface ConfigurationEntity : RHManagedObject

@property (nonatomic, retain) NSNumber * registered;
@property (nonatomic, retain) NSSet *chats;
@property (nonatomic, retain) User *luser;
@property (nonatomic, retain) NSSet *users;
@end

@interface ConfigurationEntity (CoreDataGeneratedAccessors)

- (void)addChatsObject:(Chat *)value;
- (void)removeChatsObject:(Chat *)value;
- (void)addChats:(NSSet *)values;
- (void)removeChats:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
