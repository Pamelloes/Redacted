//
//  Contact.h
//  Redacted
//
//  Created by Joshua Brot on 12/7/13.
//
//

#import <Foundation/Foundation.h>

#import "ContactEntity.h"

@interface Contact : ContactEntity

- (NSString *) name;
- (NSAttributedString *) attributedNameWithSize: (CGFloat) size;

@end
