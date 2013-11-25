//
//  WelcomeUsernameViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/22/13.
//
//

#import <UIKit/UIKit.h>

@interface WelcomeUsernameViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDataDelegate> {
	UIScrollView *scrollView;
	
	UIView *status;
	
	UITextField *username;
	UIButton *continueButton;
}

- (IBAction) bgTap:(id)sender;

- (IBAction) registerUsername:(id)sender;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIView *status;

@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UIButton *continueButton;

@end
