//
//  AppDelegate.m
//  OnionBrowser
//
//  Copyright (c) 2012 Mike Tigas. All rights reserved.
//

#import "AppDelegate.h"
#include <openssl/sha.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#import "RedactedCrypto.h"
#import "ConnectViewController.h"
#import "UsernameRegistrationViewController.h"
#import "RedactedHTTPConnection.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "Configuration.h"
#import "User.h"
#import "UserManager.h"
#import "Contact.h"

@interface AppDelegate ()

-(void) startWebserver;

-(void) loadPersistantData;
-(void) loadConfiguration;
-(void) loadRootContact;

- (void) updateUserData;

-(void) showInitialWindow;

@end

@implementation AppDelegate

@synthesize tor, httpServer, crypto, config, local, usermanager, window, rootNavigationController,
    spoofUserAgent,
    dntHeader,
    usePipelining,
    sslWhitelistedDomains,
    doPrepopulateBookmarks;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	[self showInitialWindow];
	
	crypto = [[RedactedCrypto alloc] initWithDelegate:self];
	//[crypto deleteLocalKeys];
	[crypto loadLocalKeys];
	
	NSLog(@"%@", [crypto hashSha256:[@"abc" dataUsingEncoding:NSASCIIStringEncoding]]);
	abort();
	
	[self loadPersistantData];
	//[User deleteWithPredicate:[NSPredicate predicateWithFormat:@"name like \"test\""] error:nil];
	
	[self startWebserver];
	
   /* // Detect bookmarks file.
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Settings.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    doPrepopulateBookmarks = (![fileManager fileExistsAtPath:[storeURL path]]);
    
    // Wipe all cookies & caches from previous invocations of app (in case we didn't wipe
    // cleanly upon exit last time)
    [self wipeAppData];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    appWebView = [[WebViewController alloc] init];
    [_window setRootViewController:appWebView];
    [_window makeKeyAndVisible];*/
    
    [self updateTorrc];
    tor = [[TorController alloc] init];
    [tor startTor];

    /* sslWhitelistedDomains = [[NSMutableArray alloc] init];
    
    spoofUserAgent = UA_SPOOF_NO;
    dntHeader = DNT_HEADER_UNSET;
    usePipelining = YES;
    
    // Start the spinner for the "connecting..." phase
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    / ******************* /
    // Clear any previous caches/cookies
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }*/
	
    return YES;
}

- (void) startWebserver {
	httpServer = [[HTTPServer alloc] init];
	
	// Tell server to use our custom RedactedHTTPConnection class.
	[httpServer setConnectionClass:[RedactedHTTPConnection class]];
	
	// Serve files from our embedded Web folder
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
	DDLogInfo(@"Setting document root: %@", webPath);
	[httpServer setDocumentRoot:webPath];
	
	// Start the server (and check for problems)
	NSError *error;
	if(![httpServer start:&error]) DDLogError(@"Error starting HTTP Server: %@", error);
}

-(void) showInitialWindow {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Connect-iphone" bundle:nil];
	rootNavigationController = (UINavigationController *) [storyboard instantiateInitialViewController];
	
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.rootViewController = rootNavigationController;
	[window makeKeyAndVisible];
}

- (void)updateTorrc {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *destTorrc = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"torrc"] relativePath];
    if ([fileManager fileExistsAtPath:destTorrc]) {
        [fileManager removeItemAtPath:destTorrc error:NULL];
    }
    NSString *sourceTorrc = [[NSBundle mainBundle] pathForResource:@"torrc" ofType:nil];
	
    NSError *error = nil;
	NSMutableString *torrc = [NSMutableString stringWithContentsOfFile:sourceTorrc encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        if (![fileManager fileExistsAtPath:sourceTorrc]) {
            DDLogError(@"(Source torrc %@ doesnt exist)", sourceTorrc);
        }
    }
	
	[torrc replaceOccurrencesOfString:@"{dir}" withString:[self applicationDocumentsDirectory].path options:0 range:NSMakeRange(0, [torrc length])];
	[torrc replaceOccurrencesOfString:@"{port}" withString:[NSString stringWithFormat:@"%d", httpServer.listeningPort] options:0 range:NSMakeRange(0, [torrc length])];
    
    /*NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bridge" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults != nil && [mutableFetchResults count] > 0) {
		[torrc appendString:@"UserBridges 1\n"];
        for (Bridge *bridge in mutableFetchResults)
            if (![bridge.conf isEqualToString:@"Tap Here To Edit"] && ![bridge.conf isEqualToString:@""]) [torrc appendFormat:@"bridge %@\n", bridge.conf];
    }*/
	
	error = nil;
	[torrc writeToFile:destTorrc atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
}

- (void)wipeAppData {
    /* This is probably incredibly redundant since we just delete all the files, below */
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    /* Delete all Caches, Cookies, Preferences in app's "Library" data dir. (Connection settings
     * & etc end up in "Documents", not "Library".) */
    NSArray *dataPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if ((dataPaths != nil) && ([dataPaths count] > 0)) {
        NSString *dataDir = [dataPaths objectAtIndex:0];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if ((dataDir != nil) && [fm fileExistsAtPath:dataDir isDirectory:nil]){
            NSString *cookiesDir = [NSString stringWithFormat:@"%@/Cookies", dataDir];
            if ([fm fileExistsAtPath:cookiesDir isDirectory:nil]){
                //NSLog(@"COOKIES DIR");
                [fm removeItemAtPath:cookiesDir error:nil];
            }
            NSString *cachesDir = [NSString stringWithFormat:@"%@/Caches", dataDir];
            if ([fm fileExistsAtPath:cachesDir isDirectory:nil]){
                //NSLog(@"CACHES DIR");
                [fm removeItemAtPath:cachesDir error:nil];
            }
            NSString *prefsDir = [NSString stringWithFormat:@"%@/Preferences", dataDir];
            if ([fm fileExistsAtPath:prefsDir isDirectory:nil]){
                //NSLog(@"PREFS DIR");
                [fm removeItemAtPath:prefsDir error:nil];
            }
        }
    } // TODO: otherwise, WTF
}

- (void) loadPersistantData {
	[self loadConfiguration];
	usermanager = [[UserManager alloc] initWithConfiguration:config Crypto:crypto];
	[self loadRootContact];
}

- (void) loadConfiguration {
	NSError *error;
	NSArray *configs = [Configuration fetchAllWithError:&error];
	
	if (error) {
		DDLogError(@"Error retrieving configuration: %@", error);
		error = nil;
	} else if ([configs count] <= 0){
		DDLogInfo(@"Could not find existing configuration...");
	} else {
		if ([configs count] > 1) DDLogWarn(@"Found multiple configurations. Using the first one. This may lead to an inconsistant state.");
		config = (Configuration *) [configs objectAtIndex:0];
		return;
	}
	
	DDLogInfo(@"Generating new configuration...");
	error = nil;
	config = [Configuration newEntityWithError:&error];
	if (error) DDLogError(@"Error creating configuration: %@", error);
	config.registered = [NSNumber numberWithBool:NO];
	
	error = [Configuration commit];
	if (error) DDLogError(@"Error saving database: %@", error);
}

- (void) loadRootContact {
	local = config.lcontact;
	if (local) return;
	
	DDLogInfo(@"Could not find root contact...");
	DDLogInfo(@"Generating new root contact...");
	
	NSError *error;
	local = [Contact newEntityWithError:&error];
	if (error) DDLogError(@"Error creating contact: %@", error);
	//root.pkey = crypto.publicKeyString;
	local.lcontact = config;
	local.config = config;
	
	config.lcontact = local;
	[config addContactsObject:local];
	
	error = [Configuration commit];
	if (error) DDLogError(@"Error saving database: %@", error);
}


- (void) updateProgress:(NSString *)statusLine {
	ConnectViewController *cvc = (ConnectViewController *) rootNavigationController.topViewController;
	if (cvc && [cvc isKindOfClass:[ConnectViewController class]]) [cvc updateProgress:statusLine];
}

- (void) updateProgressComplete {
	NSError *error;
	NSString *hostname = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"hostname" relativeToURL:[self applicationDocumentsDirectory]] encoding:NSUTF8StringEncoding error:&error];
	if (error) DDLogError(@"Unable to retrieve hostname: %@", error);
	usermanager.local.addr = [[hostname componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
	if (config.registered.boolValue) {
		[self updateUserData];
		[self showChatWindow];
	} else {
		[self showWelcomeWindow];
	}
}

- (void) updateUserData {
	//TODO sync with server.
}

- (void) storyboardTransitionComplete: (UIViewController *) controller {
	[rootNavigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
	window.rootViewController = rootNavigationController;
}

- (void) recievedRegistrationKey:(NSString *)key {
	UsernameRegistrationViewController *urc = (UsernameRegistrationViewController *) rootNavigationController.topViewController;
	if (urc && [urc isKindOfClass:[UsernameRegistrationViewController class]]) [urc recievedKey:key];
}

- (void) registrationComplete {
	config.registered = [NSNumber numberWithBool:YES];
	
	NSError *error = [Configuration commit];
	if (error) DDLogError(@"Error saving database: %@", error);
	
	[self showChatWindow];
}

- (void) failureWithString:(NSString *)error {
	UsernameRegistrationViewController *urc = (UsernameRegistrationViewController *) rootNavigationController.topViewController;
	if (urc && [urc isKindOfClass:[UsernameRegistrationViewController class]]) [urc failureWithString:error];
}

- (void) failureWithError:(NSError *)error {
	UsernameRegistrationViewController *urc = (UsernameRegistrationViewController *) rootNavigationController.topViewController;
	if (urc && [urc isKindOfClass:[UsernameRegistrationViewController class]]) [urc failureWithError:error];
}

- (void) showChatWindow {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat-iphone" bundle:nil];
	UINavigationController *ornc = rootNavigationController;
	rootNavigationController = [storyboard instantiateInitialViewController];
	[ornc pushViewController:rootNavigationController.topViewController animated:YES];
	rootNavigationController = [storyboard instantiateInitialViewController]; //Basically, because we have a navigation bar this needs to happen for control to transfer correctly.
}

- (void) showWelcomeWindow {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Welcome-iphone" bundle:nil];
	UINavigationController *ornc = rootNavigationController;
	rootNavigationController = [storyboard instantiateInitialViewController];
	[ornc pushViewController:rootNavigationController.topViewController animated:YES];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark App lifecycle

- (void)applicationWillResignActive:(UIApplication *)application {
    [tor disableTorCheckLoop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (!tor.didFirstConnect) {
        // User is trying to quit app before we have finished initial
        // connection. This is basically an "abort" situation because
        // backgrounding while Tor is attempting to connect will almost
        // definitely result in a hung Tor client. Quit the app entirely,
        // since this is also a good way to allow user to retry initial
        // connection if it fails.
        #ifdef DEBUG
            DDLogError(@"Went to BG before initial connection completed: exiting.");
        #endif
        exit(0);
    } else {
        [tor disableTorCheckLoop];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Don't want to call "activateTorCheckLoop" directly since we
    // want to HUP tor first.
    [tor appDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Wipe all cookies & caches on the way out.
    [self wipeAppData];
}

- (NSUInteger) deviceType{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);

    //NSLog(@"%@", platform);

    if (([platform rangeOfString:@"iPhone"].location != NSNotFound)||([platform rangeOfString:@"iPod"].location != NSNotFound)) {
        return 0;
    } else if ([platform rangeOfString:@"iPad"].location != NSNotFound) {
        return 1;
    } else {
        return 2;
    }
}


@end
