//
//  TicketBreakScannerViewController.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TicketBreakScannerViewController.h"

@implementation TicketBreakScannerViewController

@synthesize userID;
@synthesize password;
@synthesize activityIndicator;
@synthesize scanTicketViaScanner;
@synthesize authUserID;
@synthesize venueID;
@synthesize url;

- (IBAction)btnLogin:(id)sender {	
    loginSuccessful = FALSE;
	//authUserID = "";
	
	NSString *soapMsg =
	[NSString stringWithFormat: 
	 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
	 "<soap:Body>"
	 "<Login xmlns=\"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx\">"
	 "<UserName>%@</UserName>"
	 "<Password>%@</Password>"
	 "</Login>"
	 "</soap:Body>"
	 "</soap:Envelope>", userID.text, password.text];
	
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
	
	NSURL *theurl = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:theurl];
	
    //—-set the various headers—-				  
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMsg length]];				  
	[req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];	
	//NSString *urlString2 = [NSString stringWithFormat:@"http://%@/poswebservice/V3DataAccess.asmx/Login", self.url];
	
	[req addValue:@"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx/Login" forHTTPHeaderField:@"SOAPAction"];
	
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];		  
	
	//—-set the HTTP method and body—-				  
	[req setHTTPMethod:@"POST"];				  
	[req setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
	
	[activityIndicator startAnimating];
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
	
    [activityIndicator stopAnimating];
	
	if (xmlParser) {		
        [xmlParser release];		
    }	
	
    xmlParser = [[NSXMLParser alloc] initWithData: webData];	
    [xmlParser setDelegate:self];	
    [xmlParser setShouldResolveExternalEntities:YES];	
    [xmlParser parse];	
	
	//else {
	if(loginSuccessful == YES ) {
        
		if(self.scanTicketViaScanner == nil) {
			ScanTicketViaScanner *d = [[ScanTicketViaScanner alloc]initWithNibName:@"ScanTicketViaScanner" bundle:[NSBundle mainBundle]];
			self.scanTicketViaScanner = d;
			[d release];
		}
			
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        self.scanTicketViaScanner.url = [defaults objectForKey:@"url"];
        self.scanTicketViaScanner.authUserID = authUserID;
		self.scanTicketViaScanner.email = userID.text;
		self.scanTicketViaScanner.venueID = self.venueID;
		//[self.view addSubview:selectEventTableViewController.view];

		
		[self.navigationController pushViewController:self.scanTicketViaScanner animated:YES];
		
		
        //if no events selected, open that page
        //if(self.selectMultipleEventTableViewController == nil )
        //{
        /*
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
        //}
         */
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed!"							  
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

//—-when the start of an element is found—-

-(void) parser:(NSXMLParser *) parser
didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI
 qualifiedName:(NSString *) qName
	attributes:(NSDictionary *) attributeDict {	
	
    if( [elementName isEqualToString:@"AuthUserID"]) {		
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
	
    if ([elementName isEqualToString:@"AuthUserID"]) {		
        //—-displays the country—-	
		
        NSLog(@"%@", soapResults);	
		
		NSString *auth =
		[NSString stringWithFormat:@"%@", soapResults];
		
		authUserID = auth;
		
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
		loginSuccessful = TRUE;
		//authUserID = [[NSString alloc]soapResults];
    } 
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*
- (void)loadView {
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.userID resignFirstResponder];
        [self.password resignFirstResponder];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = @"Login";
    
    self.view.userInteractionEnabled = YES;

	
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 
 if(![defaults objectForKey:@"login_name"])
 [defaults setObject:@"login_name" forKey:@"login_name"];
 
  if(![defaults objectForKey:@"password"])
    [defaults setObject:@"password" forKey:@"password"];
    
 if(![defaults objectForKey:@"venue_id"])
 [defaults setObject:@"venue_id" forKey:@"venue_id"];

	if(![defaults objectForKey:@"url"])
		[defaults setObject:@"url" forKey:@"url"];
	
 [defaults synchronize];
 
 userID.text = [defaults objectForKey:@"login_name"];
 
    password.text = [defaults objectForKey:@"password"];
    
 self.venueID = [defaults objectForKey:@"venue_id"];
	self.url = [defaults objectForKey:@"url"];
	
 [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[url release];
	[venueID release];
	[authUserID release];
	[scanTicketViaScanner release];
	[userID release];
	[password release];
	[activityIndicator release];
    [super dealloc];
}

@end
