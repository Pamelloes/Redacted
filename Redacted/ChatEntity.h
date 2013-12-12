//
//  ChatEntity.h
//  Redacted
//
//  Created by Joshua Brot on 12/9/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Configuration, Message, User;

@interface ChatEntity : RHManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Configuration *config;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *users;
@end

@interface ChatEntity (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
