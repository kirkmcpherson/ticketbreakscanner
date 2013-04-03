//
//  TicketBreakScannerViewController.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectEventTableViewController.h"

@interface TicketBreakScannerViewController : UIViewController <NSXMLParserDelegate> {
	IBOutlet UITextField *userID;
	IBOutlet UITextField *password;
	IBOutlet UIActivityIndicatorView *activityIndicator;

	NSMutableData *webData;
	NSMutableString *soapResults;
	NSURLConnection *conn;
	
	NSXMLParser *xmlParser;
	BOOL elementFound;
	BOOL loginSuccessful;
	NSString *authUserID;
	NSString *venueID;
	NSString *url;
	
	//SelectEventTableViewController *selectEventTableViewController;
    //SelectEventTableViewController *selectMultipleEventViewController;
    ScanTicketViaScanner *scanTicketViaScanner;
}

@property (nonatomic, retain) UITextField *userID;
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSString *authUserID;
@property (nonatomic, retain) NSString *venueID;
@property (nonatomic, retain) NSString *url;

//@property (nonatomic, retain) SelectEventTableViewController *selectEventTableViewController;
@property (nonatomic, retain) ScanTicketViaScanner *scanTicketViaScanner;

-(IBAction) btnLogin:(id)sender;

@end

