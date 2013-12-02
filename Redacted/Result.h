//
//  Result.h
//  Redacted
//
//  Created by Joshua Brot on 12/1/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	SUCCESS,
	FAILURE,
	UNKNOWN
} restype;

@interface Result : NSObject {
	NSError *error;
	id data;
	restype result;
}

- (instancetype) initWithResult: (restype) result Error: (NSError *) error Data: (id) data;

+ (BOOL) isResolved: (Result *) res;

@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) id data;
@property (nonatomic, readonly) restype result;

@end
