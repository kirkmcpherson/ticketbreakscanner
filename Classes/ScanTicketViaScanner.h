//
//  ScanTicketViaScanner.h
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-11-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineaSDK.h"
#import "ZBarSDK.h"
#import "sqlite3.h"
#import "SelectMultipleEventTableViewController.h"
#import "InfoViewPasswordController.h"

@interface ScanTicketViaScanner : UIViewController <NSXMLParserDelegate, LineaDelegate> {
    IBOutlet UILabel *scanningLabel;
    IBOutlet UILabel *eventsLabel;
    IBOutlet UITextField *barCode;
    IBOutlet UILabel *voltageLabel;
    
    SelectMultipleEventTableViewController *selectMultipleEventTableViewController;
    InfoViewPasswordController *infoViewPasswordController;
    
	NSString *eventNames;
//	NSString *eventIDs;
	NSString *authUserID;
	NSString *email;
	NSString *url;
    NSString *venueID;
    
    NSString *userInfo;
    NSString *ticketInfo;
    NSString *eventID;
    
	NSMutableData *webData;
	NSMutableString *soapResults;
	NSURLConnection *conn;
    
	NSXMLParser *xmlParser;
	BOOL elementFound;
	BOOL scanSuccessful;
	BOOL validBarcode;
	BOOL redeemedBarcode;
	sqlite3 *db;
    
    Linea *linea;
}

-(NSString *) filepath;

@property (nonatomic, retain) NSString *eventNames;
//@property (nonatomic, retain) NSString *eventIDs;
@property (nonatomic, retain) NSString *authUserID;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *venueID;
@property (nonatomic, retain) SelectMultipleEventTableViewController *selectMultipleEventTableViewController;
@property (nonatomic, retain) InfoViewPasswordController *infoViewPasswordController;

-(IBAction) selectEvents:(id)sender;
-(IBAction) btnScanViaCamera:(id)sender;
//-(IBAction) backgroundTouched:(id)sender;
-(IBAction) btnManualScanTicket:(id)sender;
-(IBAction) showInfo:(id)sender;

@end
