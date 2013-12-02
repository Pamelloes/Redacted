//
//  Result.m
//  Redacted
//
//  Created by Joshua Brot on 12/1/13.
//
//

#import "Result.h"

#import "MABaseFuture.h"

@implementation Result

@synthesize result, error, data;

- (instancetype) initWithResult: (restype) rst Error: (NSError *) err Data: (id) dt {
	if (self = [super init]) {
		result = rst;
		error = err;
		data = dt;
	}
	return self;
}

+ (BOOL) isResolved:(Result *)res {
	if (![res isProxy]) return YES;
	return [((MABaseFuture *) res) futureHasResolved];
}

@end
