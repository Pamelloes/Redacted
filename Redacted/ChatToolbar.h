//
//  ChatToolbar.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "FlexibleTextFieldToolbar.h"

@interface ChatToolbar : FlexibleTextFieldToolbar {
	UIBarButtonItem *camera;
	UITextField *message;
	UIBarButtonItem *send;
}

@property (nonatomic, strong) UIBarButtonItem *camera;
@property (nonatomic, strong) UITextField *message;
@property (nonatomic, strong) UIBarButtonItem *send;

@end
