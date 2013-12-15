//
//  SelectUserCell.h
//  Redacted
//
//  Created by Joshua Brot on 12/7/13.
//
//

#import <UIKit/UIKit.h>

@class User, ContactViewController;

@interface UserCell : UITableViewCell <UITextFieldDelegate> {
	__weak ContactViewController *controller;
	
	BOOL editmode;
	
	UITextField *textField;
	UIView *status;
	User *user;
}

- (instancetype) initWithController: (ContactViewController *) ctrlr User: (User *) usr Editing: (BOOL) editing;

- (void) setEditmode: (BOOL) edit Animated: (BOOL) animate;

@property (nonatomic, weak, readonly) ContactViewController *controller;

@property (nonatomic) BOOL editmode;

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong, readonly) UIView *status;

@property (nonatomic, strong, readonly) User *user;

@end
