//
//  MessageEntity.h
//  Redacted
//
//  Created by Joshua Brot on 12/9/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Chat, User;

@interface MessageEntity : RHManagedObject

@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) Chat *chat;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) User *to;

@end
