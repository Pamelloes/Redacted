//
//  NewChatViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "NewChatViewController.h"

#import "ChatToolbar.h"
#import "Contact.h"

@interface NewChatViewController () {
	TITokenFieldView *field;
	UIView *placeholder;
	
	ChatToolbar *acc;
	
	CGFloat _keyboardHeight;
}

@end

@implementation NewChatViewController

@synthesize toolbar;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error;
	NSArray *ctcts = [Contact fetchAllWithError:&error];
	if (error) DDLogError(@"Could not fetch contacts: %@", error);
	NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:[ctcts count]];
	for (Contact *c in ctcts) {
		if (c.primary) continue;
		[contacts addObject:[c name]];
	}
	
	field = (TITokenFieldView *) self.view;
	field.sourceArray = contacts;
	placeholder = [[UIView alloc] initWithFrame:field.contentView.bounds];
	[field.contentView addSubview:placeholder];
	
	[field.tokenField setDelegate:self];
	[field setShouldSearchInBackground:NO];
	[field setShouldSortResults:NO];
	[field.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(NSUInteger)TITokenFieldControlEventFrameDidChange];
	[field.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]]; // Default is a comma
    [field.tokenField setPromptText:@"To:"];
	[field.tokenField setPlaceholder:@"Type a name"];
	
	acc = [[ChatToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
	field.tokenField.inputAccessoryView = acc;
	
	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
	[field.tokenField setRightView:addButton];
	[field.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
	[field.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
	
	/*_messageView = [[UITextView alloc] initWithFrame:_tokenFieldView.contentView.bounds];
	[_messageView setScrollEnabled:NO];
	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
	[_messageView setDelegate:self];
	[_messageView setFont:[UIFont systemFontOfSize:15]];
	[_messageView setText:@"Some message. The whole view resizes as you type, not just the text view."];
	[_tokenFieldView.contentView addSubview:_messageView];*/
	
	// You can call this on either the view on the field.
	// They both do the same thing.
	//[field becomeFirstResponder];
	
	/*CALayer *layer = toolbar.layer;
	layer.masksToBounds = NO;
	layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowRadius = 1.0f;
	layer.shadowOpacity = 0.8;
	layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(toolbar.bounds.origin.x, toolbar.bounds.origin.y + toolbar.bounds.size.height - 1, toolbar.bounds.size.width, 1)].CGPath;
	layer.shouldRasterize = YES;
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
	label.text = @"To:";
	label.textColor = [UIColor darkGrayColor];
	label.font = [UIFont systemFontOfSize:20];
	lbutton = [[UIBarButtonItem alloc] initWithCustomView:label];
	
	
	field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
	field.inputAccessoryView = acc;
	fbutton = [[UIBarButtonItem alloc] initWithCustomView: field];
	
	newcontact = [UIButton buttonWithType:UIButtonTypeContactAdd];
	nbutton = [[UIBarButtonItem alloc] initWithCustomView:newcontact];
	
	[toolbar setItems: [NSArray arrayWithObjects:lbutton, fbutton, nbutton, nil] animated:NO];*/
	
}

- (IBAction) close:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated {
	[field becomeFirstResponder];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self resizeViews];}]; // Make it pweeetty.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeViews];
}

- (void)showContactsPicker:(id)sender {
	
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
	
	NSArray * names = [NSArray arrayWithObjects:@"test", @"test2", @"Pamelloes", @"test1", @"o3o", nil];
	
	TIToken * token = [field.tokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
	// If the size of the token might change, it's a good idea to layout again.
	[field.tokenField layoutTokensAnimated:YES];
	
	NSUInteger tokenCount = field.tokenField.tokens.count;
	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
    int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
	[field setFrame:((CGRect){field.frame.origin, {self.view.bounds.size.width, self.view.bounds.size.height + tabBarOffset - _keyboardHeight}})];
	[placeholder setFrame:field.contentView.bounds];
}

- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
	
	if ([token.title isEqualToString:@"Tom Irving"]){
		return NO;
	}
	
	return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
	//[self textViewDidChange:_messageView];
}

- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat oldHeight = field.frame.size.height - field.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = field.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < oldHeight){
		newTextFrame.size.height = oldHeight;
		newFrame.size.height = oldHeight;
	}
	
	[field.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[field updateContentSize];
}

@end
