//
//  SelectMultipleEventTableViewController.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-11-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectMultipleEventTableViewController : UITableViewController <NSXMLParserDelegate> {

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
NSString *eventsSelected;
NSString *eventIDsSelected;

}

@property (nonatomic, retain) NSString *authUserID;
@property (nonatomic, retain) NSString *venueID;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *eventIDsSelected;
@property (nonatomic, retain) NSString *eventsSelected;

-(void) loadEvents;

@end
