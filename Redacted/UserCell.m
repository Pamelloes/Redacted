//
//  SelectUserCell.m
//  Redacted
//
//  Created by Joshua Brot on 12/7/13.
//
//

#import "UserCell.h"

#import "AppDelegate.h"
#import "User.h"
#import "UserManager.h"
#import "Result.h"
#import "ContactViewController.h"

@interface UserCell () {
	NSTimer *timer;
	NSTimer *loop;
	
	Result *res;
	BOOL cancel;
}

- (void) checkUsername: (NSTimer *) timer;
- (void) checkStatus:(NSTimer *)timer;

- (UILabel *) makeLabel;

@end

@implementation UserCell

@synthesize controller, textField, status, user, editmode;

- (instancetype) initWithController:(ContactViewController *)ctrlr User: (User *) usr Editing: (BOOL) editing {
	if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil])) {
		controller = ctrlr;
		user = usr;
		editmode = editing;
		
		self.editingAccessoryType = UITableViewCellAccessoryNone;
		
		self.textLabel.text = usr ? usr.name : @"[Invalid User]";
		self.textLabel.textColor = usr ? [UIColor blackColor] : [UIColor grayColor];
		self.textLabel.alpha = editmode ? 0.0f : 1.0f;
		self.detailTextLabel.text = usr.primary ? @"me" : @"";
		self.detailTextLabel.alpha = editmode ? 0.0f : 1.0f;
		
		textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
		textField.placeholder = @"Username";
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		textField.delegate = self;
		textField.translatesAutoresizingMaskIntoConstraints = NO;
		textField.alpha = editmode ? 1.0f : 0.0f;
		
		status = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
		status.translatesAutoresizingMaskIntoConstraints = NO;
		status.alpha = editmode ? 1.0f : 0.0f;
		
		[self.contentView addSubview:textField];
		[self.contentView addSubview:status];
		
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[textField]-[status(==100)]-|" options:0 metrics:nil views:@{@"textField":textField, @"status":status}]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[textField]|" options:0 metrics:nil views:@{@"textField":textField}]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[status]|" options:0 metrics:nil views:@{@"status":status}]];
	}
	return self;
}

- (void) willMoveToSuperview:(UIView *)ns {
	[loop invalidate];
	if (ns) loop = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkStatus:) userInfo:nil repeats:YES];
	else cancel = YES;
}

- (void) setEditmode:(BOOL)edit Animated:(BOOL)animate {
	if (animate) {
		[UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setEditmode:edit];
		} completion: nil];
	} else {
		[self setEditmode:edit];
	}
}

- (void) setEditmode:(BOOL)edit {
	editmode = edit;
	
	if (editmode) {
		self.textLabel.alpha = 0.0f;
		self.detailTextLabel.alpha = 0.0f;
		
		textField.alpha = 1.0f;
		textField.text = user ? user.name : @"";
		status.alpha = 1.0f;
		[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
		if (user) {
			UILabel *label = [self makeLabel];
			label.text = @"User exists!";
			label.textColor = [UIColor colorWithRed:(11/255.0) green:(128/255.0) blue:(0/255.0) alpha:1];
			[status addSubview:label];
		}
	} else {
		self.textLabel.text = user ? user.name : @"[Invalid User]";
		self.textLabel.textColor = user ? [UIColor blackColor] : [UIColor grayColor];
		self.textLabel.alpha = 1.0f;
		self.detailTextLabel.text = user.primary ? @"me" : @"";
		self.detailTextLabel.alpha = 1.0f;
		
		cancel = YES;
		res = nil;
		
		textField.alpha = 0.0f;
		status.alpha = 0.0f;
	}
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)tf {
	[controller focus:tf Duration:0.2 Curve:UIViewAnimationCurveEaseInOut];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[timer invalidate];
	cancel = YES;
	res = nil;
	
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	user = nil;
	[controller checkStatus];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkUsername:) userInfo:nil repeats:NO];
	return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)tf {
	[textField resignFirstResponder];
	[timer fire];
	return NO;
}

- (void) checkUsername: (NSTimer *) timer {
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	user = nil;
	[controller checkStatus];
	
	if ([textField.text isEqualToString:@""]) return;
	
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	
	cancel = NO;
	user = [ad.usermanager userWithName:textField.text];
	if (!user) {
		UIActivityIndicatorView *prog = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		CGFloat height = status.frame.size.height;
		prog.frame = CGRectMake((status.frame.size.width - height) / 2, 0, height, height);
		[status addSubview:prog];
		[prog startAnimating];
		res = [ad.usermanager retrieveUser:textField.text Cancel:&cancel];
	} else {
		res = nil;
		UILabel *label = [self makeLabel];
		if (user.contact && user.contact != controller.contact) {
			label.text = @"User is already a contact!";
			label.textColor = [UIColor colorWithRed:(252/255.0) green:(2/255.0) blue:(7/255.0) alpha:1];
			user = nil;
		} else {
			label.text = @"User exists!";
			label.textColor = [UIColor colorWithRed:(11/255.0) green:(128/255.0) blue:(0/255.0) alpha:1];
		}
		[status addSubview:label];
		[controller checkStatus];
	}
}

- (void) checkStatus:(NSTimer *)timer {
	if (!res ||  ![Result isResolved:res]) return;
	
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	user = nil;
	NSString *msg = nil;
	UIColor *color = [UIColor colorWithRed:(252/255.0) green:(2/255.0) blue:(7/255.0) alpha:1];
	if (res.error) {
		msg = res.error.localizedDescription;
	} else if (res.result == FAILURE) {
		msg = @"User does not exist!";
	} else if (res.result == SUCCESS) {
		msg = @"User exists!";
		color = [UIColor colorWithRed:(11/255.0) green:(128/255.0) blue:(0/255.0) alpha:1];
		user = res.data;
	}
	
	UILabel *label = [self makeLabel];
	label.text = msg;
	label.textColor = color;
	[status addSubview:label];
	[controller checkStatus];
	
	res = nil;
}

- (UILabel *) makeLabel {
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.bounds.size.width, status.bounds.size.height)];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:12.0f];
	label.lineBreakMode = NSLineBreakByWordWrapping;
	label.numberOfLines = 0;
	return label;
}

@end
