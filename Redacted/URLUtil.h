//
//  URLUtil.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import <Foundation/Foundation.h>

@interface URLUtil : NSObject <NSURLConnectionDataDelegate>

+ (NSString *) serverURLString;
+ (NSURL *) serverURL;

+ (NSString *) urlencode: (NSString *) encode;

+ (NSURLConnection *) retrieveURLString: (NSString *) string Completed: (void (^)(NSData *)) completed;
+ (NSURLConnection *) retrieveURLString: (NSString *) string Completed: (void (^)(NSData *)) completed Failure: (void (^)(NSError *)) failure;

+ (NSURLConnection *) retrieveURL: (NSURL *) url Completed: (void (^)(NSData *)) completed;
+ (NSURLConnection *) retrieveURL: (NSURL *) url Completed: (void (^)(NSData *)) completed Failure: (void (^)(NSError *)) failure;

+ (NSURLConnection *) retrieveRequest: (NSURLRequest *) request Completed: (void (^)(NSData *)) completed;
+ (NSURLConnection *) retrieveRequest: (NSURLRequest *) request Completed: (void (^)(NSData *)) completed Failure: (void (^)(NSError *)) failure;

@end
