//
//  ChatToolbar.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "ChatToolbar.h"

@interface ChatToolbar () {
	UIBarButtonItem *mbutton;
}

- (void) setup;

@end

@implementation ChatToolbar

@synthesize camera, message, send;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (void) awakeFromNib {
	[self setup];
}

- (void) setup {
	camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:nil];
	camera.tintColor = [UIColor darkGrayColor];
	
	message = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
	message.backgroundColor = [UIColor whiteColor];
	[message setBorderStyle: UITextBorderStyleRoundedRect];
	mbutton = [[UIBarButtonItem alloc] initWithCustomView:message];
	
	send = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:nil action:nil];
	send.enabled = NO;
	
	[self setItems: [NSArray arrayWithObjects:camera, mbutton, send, nil]];
}

@end
