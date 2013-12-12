//
//  NewContactViewController.m
//  Redacted
//
//  Created by Joshua Brot on 12/6/13.
//
//

#import "NewContactViewController.h"

#import "User.h"
#import "Contact.h"
#import "Configuration.h"
#import "Result.h"
#import "AppDelegate.h"
#import "UserManager.h"
#import "SelectUserCell.h"

@interface NewContactViewController () {
	UIView *content;
	
	NSMutableArray *cells;
	
	BOOL kb;
	CGSize kbSize;
}

- (void) keyboardWillShow: (NSNotification *) notif;
- (void) keyboardWillHide: (NSNotification *) notif;

- (UIView *) firstResponderForView: (UIView *) view;

@end

@implementation NewContactViewController

@synthesize scrollView,cancel,done;
@synthesize card,image,first,last,company;
@synthesize header,edit,add,users,ubottom;

- (void) viewDidLoad {
	kb = NO;
	
	content = self.view;
	content.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	scrollView = [[UIScrollView alloc] init];
	scrollView.frame = content.frame;
	scrollView.contentSize = content.frame.size;
	scrollView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
	scrollView.scrollEnabled = NO;
	[scrollView addSubview:content];
	
	cells = [[NSMutableArray alloc] initWithCapacity: 3];
	[cells addObject:[[SelectUserCell alloc] initWithController:self]];
	
	const double rotate = 0.01;
	
	image.transform = CGAffineTransformMakeRotation(rotate);
	first.transform = CGAffineTransformMakeRotation(rotate);
	last.transform = CGAffineTransformMakeRotation(rotate);
	company.transform = CGAffineTransformMakeRotation(rotate);
	
	card.transform = CGAffineTransformMakeRotation(-rotate);
	
	CALayer *layer = card.layer;
	layer.allowsEdgeAntialiasing = YES;
	layer.cornerRadius = 5.0f;
	layer.masksToBounds = NO;
	layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowRadius = 1.0f;
	layer.shadowOpacity = 0.8f;
	//layer.shadowPath = [UIBezierPath bezierPathWithRect:card.bounds].CGPath;
	
	layer = header.layer;
	layer.zPosition = 1;
	layer.masksToBounds = NO;
	layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowRadius = 1.0f;
	layer.shadowOpacity = 0.8f;
	layer.shadowPath = [UIBezierPath bezierPathWithRect:header.bounds].CGPath;
	
	image.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	image.titleLabel.textAlignment = NSTextAlignmentCenter;
	image.titleLabel.font = [UIFont systemFontOfSize:18.0f];
	layer = image.layer;
	layer.allowsEdgeAntialiasing = YES;
	layer.cornerRadius = 38.0f;
	layer.borderColor = [UIColor lightGrayColor].CGColor;
	layer.borderWidth = 2.0f;
	
	users.separatorInset = UIEdgeInsetsZero;
	users.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
	users.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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

- (void) checkStatus {
	BOOL enabled = YES;
	for (SelectUserCell *cell in cells) if (!cell.user) {
		enabled = NO;
		break;
	}
	done.enabled = enabled;
}

#pragma mark - Keyboard Methods

- (void) keyboardWillShow: (NSNotification *) notif {
	kb = YES;
	
	NSDictionary* info = [notif userInfo];
	kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	[self focus: [self firstResponderForView:scrollView] Duration:((NSNumber *)info[UIKeyboardAnimationDurationUserInfoKey]).doubleValue Curve:((NSNumber *)info[UIKeyboardAnimationCurveUserInfoKey]).intValue];
}

- (void) keyboardWillHide: (NSNotification *) notif {
	kb = NO;
	
	NSDictionary* info = [notif userInfo];
	kbSize = CGSizeZero;
	
	[self focus: nil Duration:((NSNumber *)info[UIKeyboardAnimationDurationUserInfoKey]).doubleValue Curve:((NSNumber *)info[UIKeyboardAnimationCurveUserInfoKey]).intValue];
}

- (void) focus:(UIView *) view Duration: (NSTimeInterval) dur Curve: (UIViewAnimationCurve) curve {
	if ([view isDescendantOfView:users]) {
		UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0, kbSize.height, 0.0);
		if (UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInsets) && UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, contentInsets)) return;

		ubottom.constant = 17;
		[users setNeedsUpdateConstraints];
		
		CGRect frame = [users convertRect: CGRectMake(users.bounds.origin.x, users.bounds.origin.y - 17, users.bounds.size.width, users.bounds.size.height) toView:scrollView];
		
		[UIView beginAnimations:@"Expand" context:nil];
		[UIView setAnimationCurve: curve];
		[UIView setAnimationDuration: dur];
		[users layoutIfNeeded];
		scrollView.contentInset = contentInsets;
		scrollView.scrollIndicatorInsets = contentInsets;
		[self.scrollView scrollRectToVisible:frame animated:NO];
		[UIView commitAnimations];
	} else {
		UIEdgeInsets contentInsets = UIEdgeInsetsZero;
		if (UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInsets) && UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, contentInsets)) return;
		
		if (ubottom.constant != 0) {
			ubottom.constant = 0;
			[users setNeedsUpdateConstraints];
		}
		
		[UIView beginAnimations:@"Reset" context:nil];
		[UIView setAnimationCurve: curve];
		[UIView setAnimationDuration: dur];
		[users layoutIfNeeded];
		scrollView.contentInset = contentInsets;
		scrollView.scrollIndicatorInsets = contentInsets;
		[self.scrollView scrollRectToVisible:CGRectZero animated:NO];
		[UIView commitAnimations];
	}
	
}

- (UIView *) firstResponderForView:(UIView *)view {
	if ([view isFirstResponder]) return view;
	for (UIView *vw in view.subviews) {
		UIView *fr = [self firstResponderForView:vw];
		if (fr) return fr;
	}
	return nil;
}

#pragma mark - IBActions

- (IBAction) cancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) done:(id)sender {
	NSError *error;
	Contact *c = [Contact newEntityWithError:&error];
	if (error) DDLogError(@"Unable to create new contact: %@", error);
	c.first = first.text;
	c.last = last.text;
	c.company = company.text;
	for (SelectUserCell *cell in cells) {
		[c addUsersObject:[cell.user objectInCurrentThreadContext]];
		((User *)[cell.user objectInCurrentThreadContext]).contact = c;
	}
	
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	[ad.usermanager.config addContactsObject:c];
	error = [Contact commit];
	if (error) DDLogError(@"Unavle to commit new contact: %@", error);
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) bgTap:(id)sender {
	[[self firstResponderForView:self.scrollView] resignFirstResponder];
}

- (IBAction) add:(id)sender {
	[cells addObject:[[SelectUserCell alloc] initWithController:self]];
	[users insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[cells count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	edit.enabled = YES;
}

- (IBAction) edit:(id)sender {
	if (users.isEditing) {
		[edit setTitle:@"Edit" forState:UIControlStateNormal];
		[users setEditing:NO animated:YES];
	} else {
		[edit setTitle:@"Done" forState:UIControlStateNormal];
		[users setEditing:YES animated:YES];
	}
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self focus:textField Duration:0.2 Curve:UIViewAnimationCurveEaseInOut];
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if (CGRectContainsPoint(users.bounds, [touch locationInView:users])) return false;
	return true;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [cells count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cells count] == 1) return UITableViewCellEditingStyleNone;
	else return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [cells removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		if ([cells count] == 1) {
			if (users.isEditing) [self edit:nil];
			edit.enabled = NO;
		}
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells count] != 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells count] != 1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
