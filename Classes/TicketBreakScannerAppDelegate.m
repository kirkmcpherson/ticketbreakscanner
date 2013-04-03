//
//  TicketBreakScannerAppDelegate.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TicketBreakScannerAppDelegate.h"
#import "TicketBreakScannerViewController.h"
#import "SelectEventTableViewController.h"

@implementation TicketBreakScannerAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize selectEventTableViewController;

#pragma mark -
#pragma mark Application lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	/*
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if(![defaults objectForKey:@"login_name"])
		[defaults setObject:@"login_name" forKey:@"login_name"];

	if(![defaults objectForKey:@"venue_id"])
		[defaults setObject:@"venue_id" forKey:@"venue_id"];
	
	[defaults synchronize];
	*/
	// Set the view controller as the window's root view controller and display.
    //self.window.rootViewController = self.viewController;
	
	
	/* klm
	[window addSubview:viewController.view];
	
    [self.window makeKeyAndVisible];

    return YES;
	 */
	tabBarController = [[UITabBarController alloc] init];          // creates your tab bar so you can add everything else to it
	
	viewController = [[TicketBreakScannerViewController alloc] init];               // creates your table view - this should be a UIViewController with a table view in it, or UITableViewController
	UINavigationController *tableNavController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	[viewController release];                                                              // creates your table view's navigation controller, then adds the view controller you made. Note I then let go of the view controller as the navigation controller now holds onto it for me. This saves memory.
	
	//selectEventTableViewController = [[SelectEventTableViewController alloc] init];   
	//UINavigationController *table2NavController = [[[UINavigationController alloc] initWithRootViewController:selectEventTableViewController] autorelease];
	//[selectEventTableViewController release];                                                    // does exactly the same as the first round, but for your second tab at the bottom of the bar.
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:tableNavController, nil, nil]; //add both of your navigation controllers to the tab bar. You can put as many controllers on as you like, but they will turn into the more button like in the iPod program.
	
	[window addSubview:tabBarController.view];                                              // adds the tab bar's view property to the window
	[window makeKeyAndVisible]; 
	
	return YES;
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
    //[viewController release];
	//[selectEventTableViewController release];
	[tabBarController release];
    [window release];
    [super dealloc];
}


@end
