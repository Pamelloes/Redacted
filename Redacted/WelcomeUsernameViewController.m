//
//  WelcomeUsernameViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/22/13.
//
//

#import "WelcomeUsernameViewController.h"

#import "JSONKit.h"
#import "AppDelegate.h"
#import "User.h"
#import "Result.h"
#import "UserManager.h"
#import "UsernameRegistrationViewController.h"

@interface WelcomeUsernameViewController () {
	NSTimer *timer;
	NSTimer *loop;
	
	Result *res;
	BOOL cancel;
	
	BOOL uvalid;
}

- (void) keyboardWillShow: (NSNotification *) notif;
- (void) keyboardWillHide: (NSNotification *) notif;

- (void) checkUsername: (NSTimer *) timer;

- (void) checkStatus: (NSTimer *) timer;

- (void) updateButton;

@end

@implementation WelcomeUsernameViewController

@synthesize scrollView, username, accessory, continueButton, continueBarButton, status;

- (void) viewDidLoad {
	uvalid = NO;
	cancel = NO;
	
	UIView *view = self.view;
	view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	scrollView = [[UIScrollView alloc] init];
	scrollView.frame = view.frame;
	scrollView.contentSize = view.frame.size;
	scrollView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
	scrollView.scrollEnabled = NO;
	[scrollView addSubview:view];
	
	username.inputAccessoryView = accessory;
}

- (UIView *) view {
	return scrollView ? scrollView : [super view];
}

- (void) viewWillAppear:(BOOL)animated {
	loop = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkStatus:) userInfo:nil repeats:TRUE];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
	[loop invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue destinationViewController] isKindOfClass:[UsernameRegistrationViewController class]]) ((AppDelegate *)[UIApplication sharedApplication].delegate).root.name = username.text;
}

- (void) updateButton {
	continueButton.enabled = uvalid;
	continueBarButton.enabled = uvalid;
}

#pragma mark - Keyboard Methods

- (void) keyboardWillShow: (NSNotification *) notif {
	NSDictionary* info = [notif userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
	scrollView.contentInset = contentInsets;
	scrollView.scrollIndicatorInsets = contentInsets;
	
	// If active text field is hidden by keyboard, scroll it so it's visible
	// Your app might not need or want this behavior.
	CGRect aRect = self.view.frame;
	aRect.size.height -= kbSize.height;
	if (!CGRectContainsPoint(aRect, username.frame.origin) ) {
		[UIView beginAnimations:@"Expand" context:nil];
		[UIView setAnimationCurve:((NSNumber *)info[UIKeyboardAnimationCurveUserInfoKey]).intValue];
		[UIView setAnimationDuration:((NSNumber *)info[UIKeyboardAnimationDurationUserInfoKey]).doubleValue];
		[self.scrollView scrollRectToVisible:username.frame animated:NO];
		[UIView commitAnimations];
	}
}

- (void) keyboardWillHide: (NSNotification *) notif {
	NSDictionary* info = [notif userInfo];
	
	[UIView beginAnimations:@"Reset" context:nil];
	[UIView setAnimationCurve:((NSNumber *)info[UIKeyboardAnimationCurveUserInfoKey]).intValue];
	[UIView setAnimationDuration:((NSNumber *)info[UIKeyboardAnimationDurationUserInfoKey]).doubleValue];
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
	[UIView commitAnimations];
}

#pragma mark - IBActions

- (IBAction) bgTap:(id)sender {
	[username resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[timer invalidate];
	cancel = YES;
	res = nil;
	
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	uvalid = NO;
	[self updateButton];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkUsername:) userInfo:nil repeats:FALSE];
	return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[timer fire];
	return NO;
}

- (void) checkUsername: (NSTimer *) timer {
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	uvalid = NO;
	[self updateButton];
	
	UIActivityIndicatorView *prog = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	CGFloat height = status.frame.size.height;
	prog.frame = CGRectMake((status.frame.size.width - height) / 2, 0, height, height);
	[status addSubview:prog];
	[prog startAnimating];
	
	cancel = NO;
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	res = [ad.usermanager validateUserExists:username.text Cancel:&cancel];
}

- (void) checkStatus:(NSTimer *)timer {
	if (!res ||  ![Result isResolved:res]) return;
	
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	uvalid = NO;
	NSString *msg = nil;
	UIColor *color = [UIColor colorWithRed:(252/255.0) green:(2/255.0) blue:(7/255.0) alpha:1];
	if (res.error) {
		msg = res.error.localizedDescription;
	} else if (res.result == SUCCESS) {
		msg = @"Username already exists!";
	} else if (res.result == FAILURE) {
		color = [UIColor colorWithRed:(11/255.0) green:(128/255.0) blue:(0/255.0) alpha:1];
		msg = @"Valid Username!";
		uvalid = YES;
	}
	
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.frame.size.width, status.frame.size.height)];
	label.text = msg;
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = color;
	[status addSubview:label];
	[self updateButton];
	
	res = nil;
}

@end
