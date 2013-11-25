//
//  WelcomeViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/24/13.
//
//

#import "WelcomeViewController.h"

#import "AppDelegate.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
}

- (void) viewDidAppear:(BOOL)animated {
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	[ad storyboardTransitionComplete: self];
}

@end
