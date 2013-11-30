//
//  User.h
//  Redacted
//
//  Created by Joshua Brot on 11/28/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat, Configuration, Message;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * addr;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pkey;
@property (nonatomic, retain) NSSet *chats;
@property (nonatomic, retain) Configuration *config;
@property (nonatomic, retain) Configuration *luser;
@property (nonatomic, retain) NSSet *received;
@property (nonatomic, retain) NSSet *sent;
@end

@interface User (CoreDataGeneratedAccessors)

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
