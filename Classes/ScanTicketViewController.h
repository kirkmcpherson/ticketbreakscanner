//
//  ScanTicketViewController.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "sqlite3.h"
#import "ViewBarcodesTableViewController.h"
#import "ZBarSDK.h"
#import "SelectMultipleEventTableViewController.h"
#import "ScanTicketViaScanner.h"

//@interface ScanTicketViewController : UIViewController <NSXMLParserDelegate>
@interface ScanTicketViewController : UIViewController <NSXMLParserDelegate, ZBarReaderDelegate>
{
	ViewBarcodesTableViewController *viewBarcodesTableViewController;
    SelectMultipleEventTableViewController *selectMultipleEventTableViewController;
    ScanTicketViaScanner *scanTicketViaScanner;
	IBOutlet UILabel *label;
	IBOutlet UITextField *barcode;
	NSString *eventNames;
	NSString *eventIDs;
	NSString *authUserID;
	NSString *email;
	NSString *url;
	NSString *venueID;
    
	NSMutableData *webData;
	NSMutableString *soapResults;
	NSURLConnection *conn;
	
	NSXMLParser *xmlParser;
	BOOL elementFound;
	BOOL scanSuccessful;
	BOOL validBarcode;
	BOOL redeemedBarcode;
	
	sqlite3 *db;
	
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UITextField *barcode;
@property (nonatomic, retain) NSString *eventNames;
@property (nonatomic, retain) NSString *eventIDs;
@property (nonatomic, retain) NSString *authUserID;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *venueID;
@property (nonatomic, retain) ViewBarcodesTableViewController *viewBarcodesTableViewController;
@property (nonatomic, retain) SelectMultipleEventTableViewController *selectMultipleEventTableViewController;
@property (nonatomic, retain) ScanTicketViaScanner *scanTicketViaScanner;

-(IBAction) btnScan:(id)sender;
-(IBAction) btnViewBarcodes:(id)sender;
-(IBAction) backgroundTouched:(id)sender;
-(IBAction) selectEvents:(id)sender;
-(IBAction) scanViaScanner:(id)sender;

-(NSString *) filePath;

@end
