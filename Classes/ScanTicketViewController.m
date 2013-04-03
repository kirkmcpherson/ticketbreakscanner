//
//  ScanTicketViewController.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScanTicketViewController.h"


@implementation ScanTicketViewController

@synthesize label;
@synthesize eventNames;
@synthesize eventIDs;
@synthesize barcode;
@synthesize authUserID;
@synthesize email;
@synthesize viewBarcodesTableViewController;
@synthesize selectMultipleEventTableViewController;
@synthesize url;
@synthesize venueID;
@synthesize scanTicketViaScanner;

-(void) viewDidAppear:(BOOL)animated {
	label.text = self.selectMultipleEventTableViewController.eventsSelected;
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(void) scanTicket {	
	validBarcode = FALSE;
	redeemedBarcode = FALSE;
	NSString *soapMsg =
	[NSString stringWithFormat: 
	 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
	 "<soap:Body>"
	 "<ValidateBarcodesAndRedeemThem xmlns=\"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx\">"
	 "<Token>"
	 "<UserName>%@</UserName>"
	 "<Token>%@</Token>"
	 "</Token>"
	 "<Barcode>%@</Barcode>"
	 "<EventIDs>%@</EventIDs>"
	 "</ValidateBarcodesAndRedeemThem>"
	 "</soap:Body>"
	 "</soap:Envelope>", self.email, self.authUserID, self.barcode.text, self.selectMultipleEventTableViewController.eventIDsSelected];
	
	
    //—-print it to the Debugger Console for verification—-	
    NSLog(@"%@",soapMsg);	
	
	
	/*
	 NSURL *url = [NSURL URLWithString:				  
	 @"http://www.ticketbreak.com/webservices/ShoppingCart.asmx"];		
	 */
	/*
	 NSURL *url = [NSURL URLWithString:@"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx"];
	 */
	NSString *urlString = [NSString stringWithFormat:@"http://%@/poswebservice/V3DataAccess.asmx", self.url];
	
	//NSURL *url = [NSURL URLWithString:@"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx"];
	NSURL *requesturl = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:requesturl];
	
    //—-set the various headers—-				  
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMsg length]];				  
	[req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];				  
	[req addValue:@"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx/ValidateBarcodesAndRedeemThem"
forHTTPHeaderField:@"SOAPAction"];
	
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];		  
	
	//—-set the HTTP method and body—-				  
	[req setHTTPMethod:@"POST"];				  
	[req setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
	
	//[activityIndicator startAnimating];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	
	if (conn) {					  
	    webData = [[NSMutableData data] retain];					  
	}				  
	
}

-(void) connection:(NSURLConnection *) connection
didReceiveResponse:(NSURLResponse *) response {
    [webData setLength: 0];
}

-(void) connection:(NSURLConnection *) connection
    didReceiveData:(NSData *) data {
    [webData appendData:data];
}

-(void) connection:(NSURLConnection *) connection
  didFailWithError:(NSError *) error {
    [webData release];
    [connection release];
}


-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
    NSLog(@"DONE. Received Bytes: %d", [webData length]);
    NSString *theXML = [[NSString alloc]						
                        initWithBytes: [webData mutableBytes]						
                        length:[webData length]						
                        encoding:NSUTF8StringEncoding];
	
    //—-shows the XML—-	
    NSLog(@"%@",theXML);	
    [theXML release];
	
    //[activityIndicator stopAnimating];
	
	if (xmlParser) {		
        [xmlParser release];		
    }	
	
    xmlParser = [[NSXMLParser alloc] initWithData: webData];	
    [xmlParser setDelegate:self];	
    [xmlParser setShouldResolveExternalEntities:YES];	
    [xmlParser parse];	
	
	//else {
	if(validBarcode == YES ) {
		if(redeemedBarcode == NO) {
            //Get the filename of the sound file:
            NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/jad0010a.wav"];
            
            //declare a system sound
            SystemSoundID soundID;
            //id SystemSoundID soundID;
            
            //Get a URL for the sound file
            NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
            
            //Use audio sevices to create the sound
            AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
            //Use audio services to play the sound
            AudioServicesPlaySystemSound(soundID);
            
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Barcode good!"							  
		 message:soapResults							  
		 delegate:self							  
		 cancelButtonTitle:@"OK"							  
		 otherButtonTitles:nil];		
		 [alert show];		
		 [alert release];	
		
		//[self insertRecordIntoTableNamed:@"Barcodes" withField1:@"barcode" field1Value:barcode.text andField2:@"success" field2Value:@"true"];
		} else {
            //Get the filename of the sound file:
            NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/jad0013a.wav"];
            
            //declare a system sound
            SystemSoundID soundID;
            //id SystemSoundID soundID;
            
            //Get a URL for the sound file
            NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
            
            //Use audio sevices to create the sound
            AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
            //Use audio services to play the sound
            AudioServicesPlaySystemSound(soundID);
            
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ticket redeemed!"							  
															message:soapResults							  
														   delegate:self							  
												  cancelButtonTitle:@"OK"							  
												  otherButtonTitles:nil];		
			[alert show];		
			[alert release];	
			
		}
		
	} else {
        //Get the filename of the sound file:
        NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/jad0013a.wav"];
        
        //declare a system sound
        SystemSoundID soundID;
        //id SystemSoundID soundID;
        
        //Get a URL for the sound file
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
        //Use audio sevices to create the sound
        AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
        //Use audio services to play the sound
        AudioServicesPlaySystemSound(soundID);
        
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid barcode!"							  
                                                        message:@"Please try again."							  
                                                       delegate:self							  
                                              cancelButtonTitle:@"OK"							  
                                              otherButtonTitles:nil];		
        [alert show];		
        [alert release];		
		
	}
	
    [connection release];	
    [webData release];	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.barcode resignFirstResponder];
    }
}

//—-when the start of an element is found—-

-(void) parser:(NSXMLParser *) parser
didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI
 qualifiedName:(NSString *) qName
	attributes:(NSDictionary *) attributeDict {	
	
    if( [elementName isEqualToString:@"ValidateBarcodesAndRedeemThemResult"]) {		
        if (!soapResults) {			
            soapResults = [[NSMutableString alloc] init];			
        }		
        elementFound = YES;		
    }	
}

//—-when the text in an element is found—-
-(void)parser:(NSXMLParser *) parser 
foundCharacters:(NSString *)string {	
    if (elementFound) {
        [soapResults appendString: string];
    }
}

//—-when the end of element is found—-
-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName {
	
	
    //if ([elementName isEqualToString:@"ValidateBarcodeResult"]) {		
	if ([elementName isEqualToString:@"ValidateBarcodesAndRedeemThemResult"]) {		
        //—-displays the country—-	
		
        NSLog(@"%@", soapResults);	
		
		if ([soapResults rangeOfString:@"RedeemedStatus"].location == NSNotFound) {
			NSLog(@"Invalid");
		} else {
			//RedeemedStatus&gt;False&lt;
			NSLog(@"Valid");
			validBarcode = TRUE;

			if ([soapResults rangeOfString:@"<RedeemedStatus>True"].location != NSNotFound) {
				NSLog(@"Redeemed");
                redeemedBarcode = TRUE;
			} else {
				//RedeemedStatus&gt;False&lt;
				NSLog(@"Not Redeemed");
				redeemedBarcode = FALSE;
			}
			
		}
		
		//NSString *auth =
		//[NSString stringWithFormat:@"%@", soapResults];
		
		//validateBarcodeResult = auth;
		
		/*
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Result found!"							  
		 message:authUserID							  
		 delegate:self							  
		 cancelButtonTitle:@"OK"							  
		 otherButtonTitles:nil];		
		 [alert show];		
		 [alert release];	
		 */
		
        [soapResults setString:@""];		
        elementFound = FALSE;	
		//validBarcode = TRUE;
		//authUserID = [[NSString alloc]soapResults];
    } 
}

- (IBAction)scanViaScanner:(id)sender {	
    if(self.selectMultipleEventTableViewController.eventIDsSelected == nil || self.selectMultipleEventTableViewController.eventIDsSelected == @"") {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please select an event first"							  
                                                        message:soapResults							  
                                                       delegate:self							  
                                              cancelButtonTitle:@"OK"							  
                                              otherButtonTitles:nil];		
        [alert show];		
        [alert release];	
       
        
    } else {
        if(self.scanTicketViaScanner == nil)
        {
            ScanTicketViaScanner  *d = [[ScanTicketViaScanner alloc]initWithNibName:@"ScanTicketViaScanner" bundle:[NSBundle mainBundle]];
            self.scanTicketViaScanner = d;
            [d release];
        
        }
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        self.scanTicketViaScanner.url = [defaults objectForKey:@"url"];
        
        self.scanTicketViaScanner.email = email;
        self.scanTicketViaScanner.authUserID = authUserID;
        //self.scanTicketViaScanner.eventIDs = self.selectMultipleEventTableViewController.eventIDsSelected;
        self.scanTicketViaScanner.eventNames = eventNames;
        self.scanTicketViaScanner.url = url;
    
        //self.selectMultipleEventTableViewController.authUserID = authUserID;
        //self.selectMultipleEventTableViewController.email = email;
        //self.selectMultipleEventTableViewController.venueID = venueID;
    
        [self.navigationController pushViewController:self.scanTicketViaScanner animated:YES];
    }
}

- (IBAction)btnScan:(id)sender {	
	[self scanTicket];
}

- (IBAction)selectEvents:(id)sender {	
        
	if(self.selectMultipleEventTableViewController == nil)
    {
        SelectMultipleEventTableViewController  *d = [[SelectMultipleEventTableViewController alloc]initWithNibName:@"SelectMultipleEventTableViewController" bundle:[NSBundle mainBundle]];
        self.selectMultipleEventTableViewController = d;
        [d release];
    
    }
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    self.venueID = [defaults objectForKey:@"venue_id"];
    
    self.selectMultipleEventTableViewController.authUserID = authUserID;
    self.selectMultipleEventTableViewController.email = email;
    self.selectMultipleEventTableViewController.venueID = [defaults objectForKey:@"venue_id"];
    self.selectMultipleEventTableViewController.url = [defaults objectForKey:@"url"];
 
    [self.selectMultipleEventTableViewController.tableView reloadData];    
    //[self.selectMultipleEventTableViewController loadEvents];
    
    [self.navigationController pushViewController:self.selectMultipleEventTableViewController animated:YES];
}

-(IBAction) btnViewBarcodes:(id)sender {
    if(self.selectMultipleEventTableViewController.eventIDsSelected == nil || self.selectMultipleEventTableViewController.eventIDsSelected == @"") {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please select an event first"							  
                                                        message:soapResults							  
                                                       delegate:self							  
                                              cancelButtonTitle:@"OK"							  
                                              otherButtonTitles:nil];		
        [alert show];		
        [alert release];	
        
        
    } else {
    
        if(self.viewBarcodesTableViewController == nil) {
            //ViewBarcodesTableViewController *d = [[ViewBarcodesTableViewController alloc]initWithNibName:@"ViewBarcodesTableViewController" bundle:[NSBundle mainBundle]];
            //self.viewBarcodesTableViewController = d;
            //[d release];
		
            ZBarReaderViewController *reader = [ZBarReaderViewController new];
            reader.readerDelegate = self;
		
            [reader.scanner setSymbology: ZBAR_I25
							  config: ZBAR_CFG_ENABLE
								  to: 0];
            reader.readerView.zoom = 1.0;
            [self presentModalViewController: reader
								animated: YES];
            [reader release];
		
	}
	
	[self.navigationController pushViewController:self.viewBarcodesTableViewController animated:YES];
	}
	//[self.view addSubview:viewBarcodesTableViewController.view];
}


- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
	
	ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;

    self.barcode.text = symbol.data;
    
    [self scanTicket];
    
    /*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IBarcode!"							  
													message:symbol.data							  
												   delegate:self							  
										  cancelButtonTitle:@"OK"							  
										  otherButtonTitles:nil];		
	[alert show];		
	[alert release];
     */
	
    //UIImage *image =
	//[info objectForKey: UIImagePickerControllerOriginalImage];
}

-(IBAction)backgroundTouched:(id)sender
{
	//[textField resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = @"Scan Ticket";
	
    self.view.userInteractionEnabled = YES;
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	self.url = [defaults objectForKey:@"url"];
    self.venueID = [defaults objectForKey:@"venue_id"];
	    
	self.title = @"Scan Ticket";

	[self openDB];
	[self createTabledNamed:@"Barcodes" withField1:@"barcode" withField2:@"success"];
	//label.text = self.eventSelected;
	
    [super viewDidLoad];
}

- (NSString *) filePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"tb_database.sql"];
}

- (void) openDB {
    NSLog(@"%@",@"Opening database.");	
	
	if(sqlite3_open([[self filePath] UTF8String], &db) != SQLITE_OK ) {
		sqlite3_close(db);
		NSAssert(0, @"Database failed to open.");
	}
}

- (void) createTabledNamed:(NSString *)tableName withField1:(NSString *) field1 withField2:(NSString *) field2 {
	
    NSLog(@"Creating table %@",tableName);	
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT);", tableName, field1, field1];

    NSLog(@"%@",sql);	
	
	if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK ) {
		sqlite3_close(db);
		NSLog(@"Creating table failure %@",tableName);	
		
		NSAssert(0, @"Tabled failed to create.");
	}
}

-(void) insertRecordIntoTableNamed:(NSString *) tableName
                        withField1:(NSString *) field1
                       field1Value:(NSString *) field1Value
                         andField2:(NSString *) field2
                       field2Value:(NSString *) field2Value {		
	
	NSString *sqlStr = [NSString stringWithFormat:						
						@"INSERT OR REPLACE INTO '%@' ('%@', '%@') VALUES (?,?)",						
						tableName, field1, field2];
	NSLog(@"%@", sqlStr);
	
	const char *sql = [sqlStr UTF8String];
	sqlite3_stmt *statement;	
	
    if (sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK) {		
        sqlite3_bind_text(statement, 1, [field1Value UTF8String], -1, NULL);		
        sqlite3_bind_text(statement, 2, [field2Value UTF8String], -1, NULL);		
    }
	
	if (sqlite3_step(statement) != SQLITE_DONE)	{	
		NSLog(@"Error inserting");
        NSAssert(0, @"Error updating table.");
	}
    sqlite3_finalize(statement);		
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[url release];
	[eventNames release];
	[eventIDs release];
	[label release];
	[barcode release];
	[viewBarcodesTableViewController release];
    [selectMultipleEventTableViewController release];
    [scanTicketViaScanner release];
    [super dealloc];
}


@end
