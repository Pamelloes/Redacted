//
//  Contact.m
//  Redacted
//
//  Created by Joshua Brot on 12/7/13.
//
//

#import "Contact.h"
#import "User.h"

@implementation Contact

+(NSString *)entityName {
	return @"ContactEntity";
}

+(NSString *)modelName {
	return @"Redacted";
}

- (NSString *) name {
	return [self attributedNameWithSize:10].string;
}

- (NSAttributedString *) attributedNameWithSize: (CGFloat) size {
	if ([self.last length] > 0 && [self.first length] > 0) {
		NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", self.first] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:size]}];
		[text appendAttributedString:[[NSAttributedString alloc] initWithString:self.last attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]}]];
		return text;
	} else if ([self.first length] > 0) return[[NSAttributedString alloc] initWithString:self.first attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]}];
	else if ([self.last length] > 0) return [[NSAttributedString alloc] initWithString:self.last attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]}];
	else return [[NSAttributedString alloc] initWithString:((User *) self.users.anyObject).name attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]}];
}

@end
