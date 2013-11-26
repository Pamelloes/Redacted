//
//  WelcomeUsernameViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/22/13.
//
//

#import "WelcomeUsernameViewController.h"

#import "JSONKit.h"

@interface WelcomeUsernameViewController () {
	UIBarButtonItem *continueBarButton;
	
	NSTimer *timer;
	
	NSMutableData *data;
	NSURLConnection *conn;
	BOOL active;
	
	BOOL uvalid;
}

- (void) keyboardWillShow: (NSNotification *) notif;
- (void) keyboardWillHide: (NSNotification *) notif;

- (void) checkUsername: (NSTimer *) timer;

- (void) updateButton;

@end

@implementation WelcomeUsernameViewController

@synthesize scrollView, username, accessory, continueButton, status;

- (void) viewDidLoad {
	uvalid = NO;
	active = NO;
	
	UIView *view = self.view;
	view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	scrollView = [[UIScrollView alloc] init];
	scrollView.frame = view.frame;
	scrollView.contentSize = view.frame.size;
	scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
	scrollView.scrollEnabled = NO;
	[scrollView addSubview:view];
	
	username.inputAccessoryView = accessory;
}

- (UIView *) view {
	return scrollView ? scrollView : [super view];
}

- (void) viewWillAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

- (IBAction) registerUsername:(id)sender {
	
}

- (IBAction) bgTap:(id)sender {
	[username resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (timer && [timer.fireDate timeIntervalSinceNow] > 0) [timer invalidate];
	if (conn && active) [conn cancel];
	
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
	NSString *text = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) username.text, NULL, CFSTR("!*'();:@&=+$,/?%#[]\" "), kCFStringEncodingUTF8));
	uvalid = NO;
	
	[self updateButton];
	
	UIActivityIndicatorView *prog = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	CGFloat height = status.frame.size.height;
	prog.frame = CGRectMake((status.frame.size.width - height) / 2, 0, height, height);
	[status addSubview:prog];
	[prog startAnimating];
	
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://rqs5owaukvnh37b4.onion/exists.php?name=%@", text]]];
	active = YES;
	data = [[NSMutableData alloc] init];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dat {
	[data appendData:dat];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	active = NO;
	uvalid = NO;
	
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.frame.size.width, status.frame.size.height)];
	label.text = [[[NSString stringWithFormat:@"An error occured: %@", error.description] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor= [UIColor colorWithRed:(252/255.0) green:(2/255.0) blue:(7/255.0) alpha:1];
	[status addSubview:label];
	[self updateButton];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	active = NO;
	
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	NSError *error;
	NSDictionary *json = [(NSData *)data objectFromJSONDataWithParseOptions:JKParseOptionNone error:&error];
	if (error != nil) {
		[self connection:connection didFailWithError:error];
		return;
	}
	
	NSString *msg = nil;
	if ([json objectForKey:@"error"]) msg = [json objectForKey:@"error"];
	else if ([(NSNumber *)[json objectForKey:@"exists"] boolValue]) msg = @"Username already exists!";
	
	if (msg) {
		UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.frame.size.width, status.frame.size.height)];
		label.text = [[msg componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor= [UIColor colorWithRed:(252/255.0) green:(2/255.0) blue:(7/255.0) alpha:1];
		[status addSubview:label];
		[self updateButton];
		return;
	}
	
	uvalid = YES;
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.frame.size.width, status.frame.size.height)];
	label.text = @"Valid Username!";
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor= [UIColor colorWithRed:(11/255.0) green:(128/255.0) blue:(0/255.0) alpha:1];
	[status addSubview:label];
	[self updateButton];
}

@end
