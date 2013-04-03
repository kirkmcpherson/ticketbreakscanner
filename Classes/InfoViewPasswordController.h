//
//  InfoViewPasswordController.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 12-06-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoViewController.h"

@interface InfoViewPasswordController : UIViewController {

    IBOutlet UITextField *password;
    
    InfoViewController *infoViewController;
    
}

@property (nonatomic, retain) InfoViewController *infoViewController;

-(IBAction) enterPassword:(id)sender;

@end
