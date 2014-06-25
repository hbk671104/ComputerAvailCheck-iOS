//
//  BKAppDelegate.m
//  ComputerAvailCheck
//
//  Created by BK on 3/17/14.
//  Copyright (c) 2014 Penn State. All rights reserved.
//

#import "BKAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation BKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Google Map API Key
	[GMSServices provideAPIKey:@"AIzaSyBN4zruy1K9WlecuSy2pjuPAvqaATp9_kY"];
	
	// Initialize the main window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Sliding drawer is not open yet
	sliding_view_is_open = NO;
	
	// Create the map view controller
	self.map_view_controller = [[BKMapViewController alloc] init];
	// Create the menu view controller
	self.menu_view_controller = [[BKBuildingMenuViewController alloc] init];
	
	// Create the navigation controller and initialize it with map view controller
	self.navi_controller = [[UINavigationController alloc] initWithRootViewController:self.map_view_controller];
	
	// Add two bar buttons: on the top left, the other on the top right
    UIBarButtonItem *anchorRightButton = [[UIBarButtonItem alloc] initWithTitle:@"Buildings" style:UIBarButtonItemStylePlain target:self action:@selector(anchorNavigationController)];
	
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(showAboutAlert)];
	
	// Configure the navigation bar
    self.map_view_controller.navigationItem.title = @"Map View";
    self.map_view_controller.navigationItem.leftBarButtonItem  = anchorRightButton;
    self.map_view_controller.navigationItem.rightBarButtonItem = anchorLeftButton;
	[self.map_view_controller.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
	
	// Set the color of the status bar to light color
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	// Customize the navigation title
	[self.map_view_controller.navigationController.navigationBar setTitleTextAttributes:
	 [NSDictionary dictionaryWithObjectsAndKeys:
						[UIColor whiteColor], NSForegroundColorAttributeName,
						[UIFont fontWithName:@"ArialMT"
										size:20.0], NSFontAttributeName,
						nil]];
	
	// Set the sliding view controller to the navigation controller
	self.slidingViewController = [ECSlidingViewController slidingWithTopViewController:self.navi_controller];
	// Set the left view controller to the menu view controller
	self.slidingViewController.underLeftViewController = self.menu_view_controller;
	
	// Grant the access of sliding view controller to BKBuildingMenuViewController
	[BKBuildingMenuViewController setSlidingViewController:self.slidingViewController];
	
	// Add pan gesture
	[self.navi_controller.view addGestureRecognizer:self.slidingViewController.panGesture];
	
	// configure anchored layout
    self.slidingViewController.anchorRightRevealAmount = 175.0;
	
	// Set the root view controller as the navigation controller
	self.window.rootViewController = self.slidingViewController;
	
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
	 
    return YES;
	
}

/*
 * Anchor the top view to the left
 */
- (void)anchorNavigationController {
	
	if (sliding_view_is_open && [BKBuildingMenuViewController getSlidingViewIsOpen]) {
		
		// Reset top view
		[self.slidingViewController resetTopViewAnimated:YES];
		// Sliding view is now closed
		sliding_view_is_open = NO;
		
	} else {
		
		// Anchor top view to the right
		[self.slidingViewController anchorTopViewToRightAnimated:YES];
		// Sliding view is now open
		sliding_view_is_open = YES;
		// Tell BKBuildingViewController the sliding view is open
		[BKBuildingMenuViewController setSlidingViewIsOpen:YES];
		
	}

}

/*
 * Show alert box
 */
- (void)showAboutAlert {
	
	NSString *msg = @"Thanks for your support! Penn State Available Computers is made by Bokang Huang\n\nSpecial thanks to: \n 1. Derek Morr for providing computer availability data \n 2. Chloe Yangqingqing Hu for logo design and optimization \n 3. Manikanth Challa for GUI design inspiration";
	
	// Instantiate a UIAlertView object
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About"
													message:msg
												   delegate:nil
										  cancelButtonTitle:@"Okay"
										  otherButtonTitles:nil];
	// show it
	[alert show];
	
	// release the memory
	alert = nil;
	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	
	// If user press the home button after seeing the alert while simultaneously the device has no internet connection, kill it
	//if (![BKMapViewController getConnectionStatus]) {
		//exit(0);
	//}

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end