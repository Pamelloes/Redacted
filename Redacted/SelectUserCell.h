//
//  SelectUserCell.h
//  Redacted
//
//  Created by Joshua Brot on 12/7/13.
//
//

#import <UIKit/UIKit.h>

@class User, NewContactViewController;

@interface SelectUserCell : UITableViewCell <UITextFieldDelegate> {
	__weak NewContactViewController *controller;
	
	UITextField *textField;
	UIView *status;
	User *user;
}

- (instancetype) initWithController: (NewContactViewController *) ctrlr;

@property (nonatomic, weak, readonly) NewContactViewController *controller;

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong, readonly) UIView *status;

@property (nonatomic, strong, readonly) User *user;

@end
