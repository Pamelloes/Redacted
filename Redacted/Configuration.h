//
//  Configuration.h
//  Redacted
//
//  Created by Joshua Brot on 11/25/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Configuration : NSManagedObject

@property (nonatomic, retain) NSManagedObject *luser;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *chats;

@end

@interface Configuration (CoreDataGeneratedAccessors)

- (void)addUsersObject:(NSManagedObject *)value;
- (void)removeUsersObject:(NSManagedObject *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

- (void)addChatsObject:(NSManagedObject *)value;
- (void)removeChatsObject:(NSManagedObject *)value;
- (void)addChats:(NSSet *)values;
- (void)removeChats:(NSSet *)values;

@end
