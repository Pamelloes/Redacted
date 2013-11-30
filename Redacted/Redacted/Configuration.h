//
//  Configuration.h
//  Redacted
//
//  Created by Joshua Brot on 11/28/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat, User;

@interface Configuration : NSManagedObject

@property (nonatomic, retain) NSNumber * registered;
@property (nonatomic, retain) NSSet *chats;
@property (nonatomic, retain) User *luser;
@property (nonatomic, retain) NSSet *users;
@end

@interface Configuration (CoreDataGeneratedAccessors)

- (void)addChatsObject:(Chat *)value;
- (void)removeChatsObject:(Chat *)value;
- (void)addChats:(NSSet *)values;
- (void)removeChats:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
