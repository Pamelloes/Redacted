//
//  NewContactViewController.h
//  Redacted
//
//  Created by Joshua Brot on 12/6/13.
//
//

#import <UIKit/UIKit.h>

@class Contact;

@interface ContactViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
	BOOL editing;
	Contact *contact;
	
	UIScrollView *scrollView;
	
	UIBarButtonItem *cancel;
	UIBarButtonItem *done;
	UIBarButtonItem *editd;
	
	UIView *card;
	UIButton *image;
	UIImageView *imaged;
	UITextField *first;
	UILabel *firstd;
	UITextField *last;
	UILabel *lastd;
	UITextField *company;
	UILabel *companyd;
	
	UIView *header;
	UIButton *edit;
	UIButton *add;
	UITableView *users;
	NSLayoutConstraint *ubottom;
}

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;
- (IBAction) beginEditing:(id)sender;

- (IBAction) add:(id)sender;
- (IBAction) edit:(id)sender;

- (void) setEditing:(BOOL)editing Animated:(BOOL)animated;

- (void) checkStatus;

- (IBAction) navigationBarTapped:(id)sender;
- (IBAction) bgTap:(id)sender;
- (void) focus: (UIView *) tf Duration: (NSTimeInterval) dur Curve: (UIViewAnimationCurve) curve;

@property (nonatomic) BOOL editing;
@property (nonatomic, strong) Contact *contact;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *done;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editd;

@property (nonatomic, strong) IBOutlet UIView *card;
@property (nonatomic, strong) IBOutlet UIButton *image;
@property (nonatomic, strong) IBOutlet UIImageView *imaged;
@property (nonatomic, strong) IBOutlet UITextField *first;
@property (nonatomic, strong) IBOutlet UILabel *firstd;
@property (nonatomic, strong) IBOutlet UITextField *last;
@property (nonatomic, strong) IBOutlet UILabel *lastd;
@property (nonatomic, strong) IBOutlet UITextField *company;
@property (nonatomic, strong) IBOutlet UILabel *companyd;

@property (nonatomic, strong) IBOutlet UIView *header;
@property (nonatomic, strong) IBOutlet UIButton *edit;
@property (nonatomic, strong) IBOutlet UIButton *add;
@property (nonatomic, strong) IBOutlet UITableView *users;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *ubottom;

@end
