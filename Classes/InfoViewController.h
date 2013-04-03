//
//  InfoViewController.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface InfoViewController : UIViewController {
    IBOutlet UILabel *infoLabel;
    
	sqlite3 *db;
    
}

-(NSString *) filepath;

-(IBAction) clearInfo:(id)sender;

@end
