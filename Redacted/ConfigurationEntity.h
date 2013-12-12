//
//  ConfigurationEntity.h
//  Redacted
//
//  Created by Joshua Brot on 12/9/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Chat, Contact;

@interface ConfigurationEntity : RHManagedObject

@property (nonatomic, retain) NSNumber * registered;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) Contact *lcontact;
@property (nonatomic, retain) NSSet *chats;
@end

@interface ConfigurationEntity (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addChatsObject:(Chat *)value;
- (void)removeChatsObject:(Chat *)value;
- (void)addChats:(NSSet *)values;
- (void)removeChats:(NSSet *)values;

@end
