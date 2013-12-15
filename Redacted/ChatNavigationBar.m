//
//  ChatNavigationBar.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "ChatNavigationBar.h"

@interface ChatNavigationBar () {
	UITapGestureRecognizer *tap;
}

- (void) navigationBarTapped: (id) sender;

@end

@implementation ChatNavigationBar

- (void) awakeFromNib {
	tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarTapped:)];
	tap.delegate = self;
	NSMutableArray *gestures = self.gestureRecognizers.mutableCopy;
	[gestures addObject:tap];
	self.gestureRecognizers = gestures;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	CGPoint pt = [touch locationInView:self];
	//TODO make sure not over back button
	if (pt.x < 100) return NO;
	return YES;
}

- (void) navigationBarTapped:(id)sender {
	UINavigationController *nav = (UINavigationController *) self.delegate;
	UIViewController *vc = nav.topViewController;
	if ([vc respondsToSelector:@selector(navigationBarTapped:)]) [vc performSelector:@selector(navigationBarTapped:) withObject:sender];
}

@end
