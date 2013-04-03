//
//  ViewBarcodesTableViewController.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"


@interface ViewBarcodesTableViewController : UITableViewController 
{
	NSMutableArray *listOfBarcodes;
	
	sqlite3 *db;

}

-(NSString *) filePath;

@end
