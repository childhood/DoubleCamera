//
//  DoubleCameraAppDelegate.m
//  DoubleCamera
//
//  Created by kronick on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DoubleCameraAppDelegate.h"
#import "DoubleCameraViewController.h"
#import "ASIS3Request.h"
#import "passwords.h"


@implementation DoubleCameraAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application { 
	NSLog(@"Launch successful.");
    
	// Load user settings into defaults dictionary
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithObject: [NSNumber numberWithInt:0] forKey:@"file_number"];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:@"user_id"];
	[defaults setObject:@"" forKey:@"username"];
	[defaults setObject:@"" forKey:@"password"];
	[defaults setObject:[NSDictionary dictionary] forKey:@"photolist"];
    [defaults setObject:@"" forKey:@"web-base"];

    [defaults setObject:@"YES" forKey:@"save-diptych"];
    
	[userDefaults registerDefaults:defaults];	
    
    //[userDefaults setObject:[NSDictionary dictionary] forKey:@"photolist"];
	
	//[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
	
    // Set Amazon S3 keys
	[ASIS3Request setSharedSecretAccessKey:S3_SECRET_ACCESS_KEY];
	[ASIS3Request setSharedAccessKey:S3_SHARED_ACCESS_KEY];
	
	// Fill the screen for universal support
	CGRect  rect = [[UIScreen mainScreen] bounds];
    [window setFrame:rect];
	
    // Add the view controller's view to the window and display.
    [self.window addSubview:navigationController.view];
	NSLog(@"Tried to launch camera...");
    [self.window makeKeyAndVisible];

}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
