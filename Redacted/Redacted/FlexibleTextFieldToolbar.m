//
//  FlexibleTextFieldToolbar.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "FlexibleTextFieldToolbar.h"

@implementation FlexibleTextFieldToolbar

- (void)layoutSubviews {
    CGFloat totalItemsWidth = 0.0;
    CGFloat itemsMargin     = 8.0;
    UIBarButtonItem *textFieldBarButtonItem;
    for (UIBarButtonItem *barButtonItem in self.items) {
        // Get width of bar button item (hack from other SO question)
        UIView *view = [barButtonItem valueForKey:@"view"];
        if(view) {
            if([view isKindOfClass:[UITextField class]]) {
                textFieldBarButtonItem = barButtonItem;
            } else
				if(view.bounds.size.width > 0) {
					// Docs say width can be negative for variable size items
					totalItemsWidth += view.bounds.size.width + itemsMargin;
				}
        }
        totalItemsWidth += itemsMargin;
    }
	
    textFieldBarButtonItem.width = (self.bounds.size.width - totalItemsWidth) - itemsMargin;
	
    [super layoutSubviews];
}

@end
