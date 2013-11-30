//
//  Chat.h
//  Redacted
//
//  Created by Joshua Brot on 11/28/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Configuration, User;

@interface Chat : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Configuration *config;
@property (nonatomic, retain) NSSet *users;
@end

@interface Chat (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
