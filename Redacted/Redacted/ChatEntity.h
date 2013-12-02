//
//  Chat.h
//  Redacted
//
//  Created by Joshua Brot on 12/1/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Configuration, Message, User;

@interface ChatEntity : RHManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Configuration *config;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *messages;
@end

@interface ChatEntity (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
