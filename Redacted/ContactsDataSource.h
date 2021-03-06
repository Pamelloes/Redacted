//
//  ContactsDataSource.h
//  Redacted
//
//  Created by Joshua Brot on 12/6/13.
//
//

#import <Foundation/Foundation.h>

@class Contact;

@interface ContactsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype) initObject;

- (Contact *) contactForIndexPath: (NSIndexPath *) indexPath;

- (void) reloadData;

@end
