//
//  NewChatViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "NewChatViewController.h"

#import "ChatToolbar.h"

@interface NewChatViewController () {
	UIBarButtonItem *lbutton;
	UILabel *label;
	UIBarButtonItem *fbutton;
	UITextField *field;
	UIBarButtonItem *nbutton;
	UIButton *newcontact;
	
	ChatToolbar *acc;
}

@end

@implementation NewChatViewController

@synthesize toolbar;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	CALayer *layer = toolbar.layer;
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
	
	acc = [[ChatToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
	
	field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
	field.inputAccessoryView = acc;
	fbutton = [[UIBarButtonItem alloc] initWithCustomView: field];
	
	newcontact = [UIButton buttonWithType:UIButtonTypeContactAdd];
	nbutton = [[UIBarButtonItem alloc] initWithCustomView:newcontact];
	
	[toolbar setItems: [NSArray arrayWithObjects:lbutton, fbutton, nbutton, nil] animated:NO];
}

- (void) viewWillAppear:(BOOL)animated {
	[field becomeFirstResponder];
}

@end
