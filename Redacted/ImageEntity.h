//
//  ImageEntity.h
//  Redacted
//
//  Created by Joshua Brot on 12/9/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

@class Contact;

@interface ImageEntity : RHManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) Contact *contact;

@end
