//
//  WelcomeUsernameViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/22/13.
//
//

#import <UIKit/UIKit.h>

@interface WelcomeUsernameViewController : UIViewController <UITextFieldDelegate> {
	UIScrollView *scrollView;
	
	UIView *status;
	
	UITextField *username;
	UIView *accessory;
	
	UIButton *continueButton;
	UIBarButtonItem *continueBarButton;
}

- (IBAction) bgTap:(id)sender;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIView *status;

@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UIView *accessory;

@property (nonatomic, strong) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *continueBarButton;

@end
