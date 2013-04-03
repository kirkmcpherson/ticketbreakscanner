//
//  TicketBreakScannerAppDelegate.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectEventTableViewController.h"

@class TicketBreakScannerViewController;

@interface TicketBreakScannerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController *tabBarController;
    TicketBreakScannerViewController *viewController;
    SelectEventTableViewController *selectEventTableViewController;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIWindow *tabBarController;
@property (nonatomic, retain) IBOutlet TicketBreakScannerViewController *viewController;
@property (nonatomic, retain) IBOutlet SelectEventTableViewController *selectEventTableViewController;

@end

