//
//  ContactsDataSource.h
//  Redacted
//
//  Created by Joshua Brot on 12/6/13.
//
//

#import <Foundation/Foundation.h>

@interface ContactsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype) initObject;

- (void) reloadData;

@end
