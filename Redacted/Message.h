//
//  Message.h
//  Redacted
//
//  Created by Joshua Brot on 11/25/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSManagedObject *from;
@property (nonatomic, retain) NSManagedObject *to;

@end
