//
//  ContactEntity.h
//  Redacted
//
//  Created by Joshua Brot on 12/9/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Configuration, Image, User;

@interface ContactEntity : RHManagedObject

@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * first;
@property (nonatomic, retain) NSString * last;
@property (nonatomic, retain) Configuration*config;
@property (nonatomic, retain) Image *image;
@property (nonatomic, retain) Configuration *lcontact;
@property (nonatomic, retain) User *primary;
@property (nonatomic, retain) NSSet *users;
@end

@interface ContactEntity (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
