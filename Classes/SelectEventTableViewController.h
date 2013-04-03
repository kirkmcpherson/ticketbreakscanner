//
//  SelectEventTableViewController.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanTicketViewController.h"

@interface SelectEventTableViewController : UITableViewController <NSXMLParserDelegate> {

	ScanTicketViewController *scanTicketViewController;
	NSMutableData *webData;
	NSMutableString *soapResults;
	NSMutableString *soapResults2;
	NSURLConnection *conn;
	NSMutableArray *listOfEvents;
	NSMutableArray *listOfEventIDs;
	
	
	NSXMLParser *xmlParser;
	BOOL elementFound;
	BOOL elementFound2;
	NSString *authUserID;
	NSString *venueID;
	NSString *url;
	
}

@property (nonatomic, retain) ScanTicketViewController *scanTicketViewController;
@property (nonatomic, retain) NSString *authUserID;
@property (nonatomic, retain) NSString *venueID;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *url;

-(void) loadEvents;

@end
