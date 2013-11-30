//
//  Message.h
//  Redacted
//
//  Created by Joshua Brot on 11/28/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) User *to;

@end
