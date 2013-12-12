//
//  UserEntity.h
//  Redacted
//
//  Created by Joshua Brot on 12/9/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Chat, Contact, Message;

@interface UserEntity : RHManagedObject

@property (nonatomic, retain) NSString * addr;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pkey;
@property (nonatomic, retain) NSSet *chats;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) Contact *primary;
@property (nonatomic, retain) NSSet *received;
@property (nonatomic, retain) NSSet *sent;
@end

@interface UserEntity (CoreDataGeneratedAccessors)

- (void)addChatsObject:(Chat *)value;
- (void)removeChatsObject:(Chat *)value;
- (void)addChats:(NSSet *)values;
- (void)removeChats:(NSSet *)values;

- (void)addReceivedObject:(Message *)value;
- (void)removeReceivedObject:(Message *)value;
- (void)addReceived:(NSSet *)values;
- (void)removeReceived:(NSSet *)values;

- (void)addSentObject:(Message *)value;
- (void)removeSentObject:(Message *)value;
- (void)addSent:(NSSet *)values;
- (void)removeSent:(NSSet *)values;

@end
