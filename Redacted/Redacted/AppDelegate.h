//
//  AppDelegate.h
//  OnionBrowser
//
//  Copyright (c) 2012 Mike Tigas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "TorController.h"

#define DNT_HEADER_UNSET 0
#define DNT_HEADER_CANTRACK 1
#define DNT_HEADER_NOTRACK 2

#define UA_SPOOF_NO 0
#define UA_SPOOF_WIN7_TORBROWSER 1
#define UA_SPOOF_SAFARI_MAC 2

#define X_DEVICE_IS_IPHONE 0
#define X_DEVICE_IS_IPAD 1
#define X_DEVICE_IS_SIM 2

@class HTTPServer, RedactedCrypto;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
	TorController *tor;
	HTTPServer *httpServer;
	
	RedactedCrypto *crypto;
	
	UIWindow *window;
	
	UINavigationController *rootNavigationController;
}

- (void) updateProgress: (NSString *) statusLine;
- (void) updateProgressComplete;

- (void) storyboardTransitionComplete: (UIViewController *) controller;

- (void)updateTorrc;
- (NSURL *)applicationDocumentsDirectory;
- (void)wipeAppData;
- (NSUInteger) deviceType;

@property (nonatomic, strong, readonly) TorController *tor;
@property (nonatomic, strong, readonly) HTTPServer *httpServer;

@property (nonatomic, strong, readonly) RedactedCrypto *crypto;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *rootNavigationController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) Byte spoofUserAgent;
@property (nonatomic) Byte dntHeader;
@property (nonatomic) Boolean usePipelining;

@property (nonatomic) NSMutableArray *sslWhitelistedDomains; // for self-signed

@property (nonatomic) Boolean doPrepopulateBookmarks;

@end
