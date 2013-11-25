//
//  WelcomeUsernameViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/22/13.
//
//

#import "WelcomeUsernameViewController.h"

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

@end

@implementation WelcomeUsernameViewController

@synthesize scrollView, username, continueButton, status;

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
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	UIBarButtonItem *s1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	continueBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStylePlain target:self action:@selector(registerUsername:)];
	continueBarButton.enabled = NO;
	UIBarButtonItem *s2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	toolbar.items = [NSArray arrayWithObjects:s1,continueBarButton,s2,nil];
	username.inputAccessoryView = toolbar;
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
		[UIView beginAnimations:@"Reset" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.2];
		[self.scrollView scrollRectToVisible:username.frame animated:NO];
		[UIView commitAnimations];
	}
}

- (void) keyboardWillHide: (NSNotification *) notif {
	[UIView beginAnimations:@"Reset" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.2];
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
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	if (timer && [timer.fireDate timeIntervalSinceNow] > 0) [timer invalidate];
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
	NSString *text = username.text;
	uvalid = NO;
	
	UIActivityIndicatorView *prog = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	CGFloat height = status.frame.size.height;
	prog.frame = CGRectMake((status.frame.size.width - height) / 2, 0, height, height);
	[status addSubview:prog];
	[prog startAnimating];
	
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://rqs5owaukvnh37b4.onion/exists.php?name=%@", text]]];
	if (conn && active) [conn cancel];
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
	
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.frame.size.width, status.frame.size.height)];
	label.text = [[[NSString stringWithFormat:@"An error occured: %@, %@", error, error.userInfo] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor= [UIColor colorWithRed:(252/255.0) green:(2/255.0) blue:(7/255.0) alpha:1];
	[status addSubview:label];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	active = NO;
	
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[status.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	if (valid) {
		uvalid = YES;
		UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.frame.size.width, status.frame.size.height)];
		label.text = @"Valid Username!";
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor= [UIColor colorWithRed:(11/255.0) green:(128/255.0) blue:(0/255.0) alpha:1];
		[status addSubview:label];
		//[self updateCloneButton];
	} else {
		uvalid = NO;
		UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, status.frame.size.width, status.frame.size.height)];
		label.text = [[str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor= [UIColor colorWithRed:(252/255.0) green:(2/255.0) blue:(7/255.0) alpha:1];
		[status addSubview:label];
		//[self updateCloneButton];
	}
}

@end
