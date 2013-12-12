//
//  NewContactViewController.h
//  Redacted
//
//  Created by Joshua Brot on 12/6/13.
//
//

#import <UIKit/UIKit.h>

@interface NewContactViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
	UIScrollView *scrollView;
	
	UIBarButtonItem *cancel;
	UIBarButtonItem *done;
	
	UIView *card;
	UIButton *image;
	UITextField *first;
	UITextField *last;
	UITextField *company;
	
	UIView *header;
	UIButton *edit;
	UIButton *add;
	UITableView *users;
	NSLayoutConstraint *ubottom;
}

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;

- (IBAction) add:(id)sender;
- (IBAction) edit:(id)sender;

- (void) checkStatus;

- (IBAction) bgTap:(id)sender;
- (void) focus: (UIView *) tf Duration: (NSTimeInterval) dur Curve: (UIViewAnimationCurve) curve;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *done;

@property (nonatomic, strong) IBOutlet UIView *card;
@property (nonatomic, strong) IBOutlet UIButton *image;
@property (nonatomic, strong) IBOutlet UITextField *first;
@property (nonatomic, strong) IBOutlet UITextField *last;
@property (nonatomic, strong) IBOutlet UITextField *company;

@property (nonatomic, strong) IBOutlet UIView *header;
@property (nonatomic, strong) IBOutlet UIButton *edit;
@property (nonatomic, strong) IBOutlet UIButton *add;
@property (nonatomic, strong) IBOutlet UITableView *users;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *ubottom;

@end
