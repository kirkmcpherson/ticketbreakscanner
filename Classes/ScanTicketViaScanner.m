//
//  ScanTicketViaScanner.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-11-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScanTicketViaScanner.h"
#import "XMLReader.h"

@implementation ScanTicketViaScanner

@synthesize eventNames;
//@synthesize eventIDs;
@synthesize authUserID;
@synthesize email;
@synthesize url;
@synthesize venueID;
@synthesize selectMultipleEventTableViewController;
@synthesize infoViewPasswordController;

//@synthesize userInfo;
//@synthesize ticketInfo;

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
	NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT);", tableName, field1, field2];
    
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

-(void) getAllRowsFromTableNamed: (NSString *) tableName {
    //—-retrieve rows—-	
    NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];	
    sqlite3_stmt *statement;	
	
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {		
        while (sqlite3_step(statement) == SQLITE_ROW) {			
            char *field1 = (char *) sqlite3_column_text(statement, 0);			
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
			
            char *field2 = (char *) sqlite3_column_text(statement, 1);			
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
			
			NSString *str = [[NSString alloc] initWithFormat:@"%@ - %@",							 
							 field1Str, field2Str];			
            NSLog(@"%@", str);			
			
            [field1Str release];			
            [field2Str release];			
            [str release];			
        }
		
        //—-deletes the compiled statement from memory—-		
        sqlite3_finalize(statement);		
    }	
}

-(void)updateBattery
{
    NS_DURING
	int percent=[linea getBatteryCapacity];
    int voltage=[linea getBatteryVoltage];
    //[voltageLabel setText:[NSString stringWithFormat:@"%d.%dv",voltage/10,voltage%10]];
    //klm[voltageLabel setText:[NSString stringWithFormat:@"%d",percent]];
    //	[battery setHidden:FALSE];
    //	[voltageLabel setHidden:FALSE];
    //	if(percent<10)
    //		[battery setImage:[UIImage imageNamed:@"0.png"]];
    //	else if(percent<40)
    //		[battery setImage:[UIImage imageNamed:@"25.png"]];
    //	else if(percent<60)
    //		[battery setImage:[UIImage imageNamed:@"50.png"]];
    //	else if(percent<80)
    //		[battery setImage:[UIImage imageNamed:@"75.png"]];
    //	else
    //		[battery setImage:[UIImage imageNamed:@"100.png"]];
    NS_HANDLER
    //	[battery setHidden:TRUE];
    //	[voltageLabel setHidden:TRUE];
    NS_ENDHANDLER
}

-(void) scanTicket:(NSString *)barcode {	
	validBarcode = FALSE;
	redeemedBarcode = FALSE;
    
    self.view.backgroundColor = [UIColor whiteColor];
    scanningLabel.Text = @"Wait...";
    
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
	 "</soap:Envelope>", self.email, self.authUserID, barcode, self.selectMultipleEventTableViewController.eventIDsSelected];
	
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

- (IBAction)showInfo:(id)sender {
	if(self.infoViewPasswordController == nil)
    {
        InfoViewPasswordController  *d = [[InfoViewPasswordController alloc]initWithNibName:@"InfoViewPasswordController" bundle:[NSBundle mainBundle]];
        self.infoViewPasswordController = d;
        [d release];
        
    }
    
    [self.navigationController pushViewController:self.infoViewPasswordController animated:YES];
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
	self.navigationItem.title = @"Scan Ticket";
	
    //self.view.userInteractionEnabled = YES;
    
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//self.url = [defaults objectForKey:@"url"];
	
	self.title = @"Scan Ticket";
    
	linea=[Linea sharedDevice];
	[linea addDelegate:self];
    [linea connect];
    
    [self openDB];
        
	[self createTabledNamed:@"Barcodes" withField1:@"barcode" withField2:@"eventid"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewDidAppear:(BOOL)animated {
    //if no events selected, open that page
    if(self.selectMultipleEventTableViewController == nil || [self.selectMultipleEventTableViewController.eventIDsSelected length] == 0)
    {
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
        
        //[self.navigationController presentModalViewController:self.selectMultipleEventTableViewController animated:YES];
        return;
    }
        
	eventsLabel.text = self.selectMultipleEventTableViewController.eventsSelected;
    //[self 
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
            //SystemSoundID soundID;
            //id SystemSoundID soundID;
            
            //Get a URL for the sound file
            NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
            
            //Use audio sevices to create the sound
            //AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
            //Use audio services to play the sound
            //AudioServicesPlaySystemSound(soundID);
            
            scanningLabel.textColor = [UIColor blackColor];
            //scanningLabel.Text = @"Valid ticket.";
            scanningLabel.Text = [NSString stringWithFormat:@"Hello %@.<br/>%@", userInfo, ticketInfo];
            
            self.view.backgroundColor = [UIColor greenColor];
            
            //[self insertRecordIntoTableNamed:@"Barcodes" withField1:@"barcode" field1Value:barcode.text andField2:@"success" field2Value:@"true"];
		} else {
            //Get the filename of the sound file:
            NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/jad0013a.wav"];
            
            //declare a system sound
            //SystemSoundID soundID;
            //id SystemSoundID soundID;
            
            //Get a URL for the sound file
            NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
            
            //Use audio sevices to create the sound
            //AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
            //Use audio services to play the sound
            //AudioServicesPlaySystemSound(soundID);
            
            scanningLabel.textColor = [UIColor blackColor];
            scanningLabel.Text = @"Ticket already redeemed.";
            scanningLabel.Text = [NSString stringWithFormat:@"Hello %@.<br/>Ticket already Redeemed", userInfo];
            
            self.view.backgroundColor = [UIColor yellowColor];
			
		}
		
	} else {
        //Get the filename of the sound file:
        NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/jad0013a.wav"];
        
        //declare a system sound
        //SystemSoundID soundID;
        //id SystemSoundID soundID;
        
        //Get a URL for the sound file
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
        //Use audio sevices to create the sound
        //AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
        //Use audio services to play the sound
        //AudioServicesPlaySystemSound(soundID);
        
		//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid barcode!"							  
        //                                                message:@"Please try again."							  
        //                                               delegate:self							  
        //                                      cancelButtonTitle:@"OK"							  
        //                                      otherButtonTitles:nil];		
        //[alert show];		
        //[alert release];		
        scanningLabel.textColor = [UIColor whiteColor];
        
        scanningLabel.Text = @"Invalid Barcode!  Please try again.";
		
        self.view.backgroundColor = [UIColor redColor];
        
	}
	
    [connection release];	
    [webData release];	
}

-(IBAction) btnManualScanTicket:(id)sender {
    [self scanTicket:barCode.text];

}

-(IBAction) btnScanViaCamera:(id)sender {
    if(self.selectMultipleEventTableViewController.eventIDsSelected == nil || self.selectMultipleEventTableViewController.eventIDsSelected == @"") {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please select an event first"							  
                                                        message:soapResults							  
                                                       delegate:self							  
                                              cancelButtonTitle:@"OK"							  
                                              otherButtonTitles:nil];		
        [alert show];		
        [alert release];	
        
        
    } else {
        
        //if(self.viewBarcodesTableViewController == nil) {
            //ViewBarcodesTableViewController *d = [[ViewBarcodesTableViewController alloc]initWithNibName:@"ViewBarcodesTableViewController" bundle:[NSBundle mainBundle]];
            //self.viewBarcodesTableViewController = d;
            //[d release];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if(![defaults objectForKey:@"camera_flash"])
            [defaults setObject:@"camera_flash" forKey:@"camera_flash"];
        
        [defaults synchronize];
        
        bool cameraFlash = [defaults boolForKey:@"camera_flash"];
        
        //userID.text = [defaults boolForKey:@"camera_flash"];
            
            ZBarReaderViewController *reader = [ZBarReaderViewController new];
            reader.readerDelegate = self;
        
            if(cameraFlash == true)
                reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            else
                reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
            [reader.scanner setSymbology: ZBAR_I25
                                  config: ZBAR_CFG_ENABLE
                                      to: 0];
            reader.readerView.zoom = 1.0;
            [self presentModalViewController: reader
                                    animated: YES];
            [reader release];
            
        //}
        
        //[self.navigationController pushViewController:self.viewBarcodesTableViewController animated:YES];
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
    
    barCode.text = symbol.data;
    //scanningLabel.text = symbol.data;
    [self scanTicket:symbol.data];
    
    [reader dismissModalViewControllerAnimated: YES];
    
    //[self scanTicket];
    
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
    
    /*
    if([elementName isEqualToString:@"EventID"]) {
        NSString* eventID = @"blah"; 
    
    }
    
    if ([elementName isEqualToString:@"BOOK"]) {
        
        NSString* title = [attributeDict valueForKey:@"title"];    
        int id = [[attributeDict valueForKey:@"id"] intValue];
        NSLog(@"Title: %@, ID: %i", title, id);
    }
    */
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
		
        NSDictionary *dic = [XMLReader dictionaryForXMLString:soapResults error:nil];
        
        NSLog(@"%@", [dic valueForKeyPath:@"NewDataSet.Table1.EventID.text"]);
        NSLog(@"%@", [dic valueForKeyPath:@"NewDataSet.Table1.UserInfo.text"]);
        NSLog(@"%@", [dic valueForKeyPath:@"NewDataSet.Table1.TicketInfo.text"]);
        
        userInfo = [dic valueForKeyPath:@"NewDataSet.Table1.UserInfo.text"];
        ticketInfo = [dic valueForKeyPath:@"NewDataSet.Table1.TicketInfo.text"];
        eventID = [dic valueForKeyPath:@"NewDataSet.Table1.EventID.text"];
        
        //if([event isKindOfClass:[NSString class]]) {
                    
        //}
        //id event = [dic retrieveForPath:@"NewDataSet.Table1.EventID"];
        /*
        for(id key in dic) {
            NSLog(@"Key: %@, Value %@", key, [dic objectForKey:key]);
            
            NSDictionary *subDictionary = [dic objectForKey:key];
            
            for(id key2 in subDictionary) {
                NSLog(@"Key: %@, Value %@", key2, [subDictionary objectForKey:key2]);  
                
                NSDictionary *subsubDictionary = [subDictionary objectForKey:key2];
                
                for(id key3 in subsubDictionary) {
                    NSLog(@"Key: %@, Value %@", key3, [subsubDictionary objectForKey:key3]);  
                    
                    if(key3 == @"EventID") {
                        NSString* eventID = [subsubDictionary objectForKey:key3]; 
                    
                        NSString* blah = @"blah";
                    }
                }
            }
        }
        */
        NSDate* now = [NSDate date];
        NSString *dateStr = @"20120727";
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        NSDate *expiryDate = [dateFormat dateFromString:dateStr];
        
        //NSDate *expiryDate = [NSDate dateWithNaturalLanguageString:@"31/08/12"];
        NSComparisonResult result;
        
        result = [now compare:expiryDate];
        
        if(result == NSOrderedDescending)
        {
            validBarcode = FALSE;
        } else {
            if ([soapResults rangeOfString:@"RedeemedStatus"].location == NSNotFound) {
                NSLog(@"Invalid");
            
            } else {
                //RedeemedStatus&gt;False&lt;
                NSLog(@"Valid");
                        
                //NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar
            
                if ([soapResults rangeOfString:@"<RedeemedStatus>True"].location != NSNotFound) {
                    NSLog(@"Redeemed");
                    redeemedBarcode = TRUE;
                } else {
                    //RedeemedStatus&gt;False&lt;
                    NSLog(@"Not Redeemed");
                
                    //store in database
                    [self insertRecordIntoTableNamed:@"Barcodes" withField1:@"barcode" field1Value:barCode.text andField2:@"eventid" field2Value:[dic valueForKeyPath:@"NewDataSet.Table1.EventID.text"]];
                    redeemedBarcode = FALSE;
                }
			
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

//-(IBAction)backgroundTouched:(id)sender
//{
//	[barCode resignFirstResponder];
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [barCode resignFirstResponder];
    }
}

-(void)buttonPressed:(int)which {
    //scanningLabel.text = @"Trying to Scan";
	//label.text = self.selectMultipleEventTableViewController.eventsSelected;

	//[debug setString:@""];
	//[self cleanPrintInfo];
	
	//[displayText setText:@""];
	//[statusImage setImage:[UIImage imageNamed:@"scanning.png"]];
}

-(void)enableCharging {
	NS_DURING
    [linea setCharging:[[NSUserDefaults standardUserDefaults] boolForKey:@"AutoCharging"]];
    NS_HANDLER
    NS_ENDHANDLER
}

-(void)connectionState:(int)state {
	switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
#if TARGET_IPHONE_SIMULATOR
			//[self setViewControllers:[NSArray arrayWithObjects:scannerViewController,settingsViewController,cryptoViewController,mifareViewController,iso15693ViewController,nil] animated:TRUE];
#else
			//[self setViewControllers:[NSArray arrayWithObject:scannerViewController] animated:FALSE];
#endif
            scanningLabel.text = @"Connecting Scanner";
			break;
		case CONN_CONNECTED:            
			NS_DURING
            scanningLabel.text = @"Scanner Connected";
			[linea msStartScan];
            //keep the egine on by default, this is useful for 2D barcode engine that takes several seconds to power on
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"BarcodeEngineOn"])
            {
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"BarcodeEngineOn"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [linea barcodeEnginePowerControl:[[NSUserDefaults standardUserDefaults] boolForKey:@"BarcodeEngineOn"]];
            [linea setCharging:[[NSUserDefaults standardUserDefaults] boolForKey:@"AutoCharging"]];
            [linea setBarcodeTypeMode:BARCODE_TYPE_DEFAULT];
			[linea setScanButtonMode:BUTTON_ENABLED];
            //[linea setScanTimeout:6];
            
            scanningLabel.text = @"Scanner Connected";

            [self updateBattery];

			//calling this function last, after all notifications has been called in all registered deleegates, 
			//because enabling/disabling charge in firmware versions <2.34 will force disconnect and reconnect
			[self performSelectorOnMainThread:@selector(enableCharging) withObject:nil waitUntilDone:NO];
			NS_HANDLER
            scanningLabel.text = @"Scanner Connected";
			//[scannerViewController debug:[NSString stringWithFormat:@"***%@ - %@",[localException name],[localException reason]]];
            //[linea btmSetEnabled:TRUE];
			NS_ENDHANDLER
			
            //scanningLabel.text = @"blah";
			//[self setViewControllers:[NSArray arrayWithObjects:scannerViewController,settingsViewController,cryptoViewController,mifareViewController,iso15693ViewController,nil] animated:FALSE];
			break;
	}
}

-(void)barcodeData:(NSString *)barcode type:(int)type {
	//[self cleanPrintInfo];
	//ScanTicketViaScanner
    barCode.text = barcode;
    //scanningLabel.text = barcode;
    //scanTick
    //scanT
    [self scanTicket:barcode];
    
    [self updateBattery];

	//self.lastBarcode=barcode;
	//self.lastBarcodeType=[linea barcodeType2Text:type];
	
	//[status setString:@""];
	//[status appendFormat:@"Type: %d\n",type];
	//[status appendFormat:@"Type text: %@\n",[linea barcodeType2Text:type]];
	//[status appendFormat:@"Barcode: %@",barcode];
	//[displayText setText:status];
	//if(!settings_values[SET_MULTI_SCAN_MODE])
	//	[statusImage setImage:[UIImage imageNamed:@"normal.png"]];
}


- (void)dealloc {
	[linea disconnect];
	[scanningLabel release];
    [eventsLabel release];
    [barCode release];
    [voltageLabel release];
    [selectMultipleEventTableViewController release];
    [infoViewPasswordController release];
}

@end
