//
//  SelectMultipleEventTableViewController.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-11-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectMultipleEventTableViewController.h"

@implementation SelectMultipleEventTableViewController

@synthesize authUserID;
@synthesize email;
@synthesize venueID;
@synthesize url;
@synthesize eventsSelected;
@synthesize eventIDsSelected;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.navigationItem.title = @"Select Events";
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	self.url = [defaults objectForKey:@"url"];
	
	//[listOfEvents addObject:@"Event 1"];
	//[listOfEvents addObject:@"Event 2"];
	
	
	[super viewDidLoad];
    
//	if([listOfEvents count] == 0) {
		
		//[self loadEvents];
		
		//cellSize = CGSizeMake(<#CGFloat width#>, <#CGFloat height#>)
//	}
	
	
}

- (void)refreshDisplay:(UITableView *)tableView {
    [tableView reloadData]; 
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadEvents];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}
-(void) loadEvents {
	listOfEvents = [[NSMutableArray alloc] init];
	listOfEventIDs = [[NSMutableArray alloc] init];
	
	NSString *soapMsg =
	[NSString stringWithFormat: 
	 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
	 "<soap:Body>"
	 "<GetEventListForScanner xmlns=\"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx\">"
	 "<Token>"
	 "<UserName>%@</UserName>"
	 "<Token>%@</Token>"
	 "</Token>"
	 "<VenueID>%@</VenueID>"
	 "</GetEventListForScanner>"
	 "</soap:Body>"
	 "</soap:Envelope>", self.email, self.authUserID, self.venueID];
	
    
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
	
	NSURL *requesturl = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:requesturl];
	
    //—-set the various headers—-				  
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMsg length]];				  
	[req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];		
	
	[req addValue:@"http://www.ticketbreak.com/poswebservice/V3DataAccess.asmx/GetEventListForScanner" forHTTPHeaderField:@"SOAPAction"];
	
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
    
	NSLog(@"events array has %d items", [listOfEventIDs count]);	
	[self.tableView reloadData];
	
    [connection release];	
    [webData release];	
}

//—-when the start of an element is found—-

-(void) parser:(NSXMLParser *) parser
didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI
 qualifiedName:(NSString *) qName
	attributes:(NSDictionary *) attributeDict {	
	
    if( [elementName isEqualToString:@"Name"]) {		
        if (!soapResults) {			
            soapResults = [[NSMutableString alloc] init];			
        }		
        elementFound = YES;		
    }	
    else if( [elementName isEqualToString:@"EventID"]) {		
        if (!soapResults2) {			
            soapResults2 = [[NSMutableString alloc] init];			
        }		
        elementFound2 = YES;		
    }	
}

//—-when the text in an element is found—-
-(void)parser:(NSXMLParser *) parser 
foundCharacters:(NSString *)string {	
    if (elementFound) {
        [soapResults appendString: string];
    } else if (elementFound2) {
		[soapResults2 appendString: string];
	}
}

//—-when the end of element is found—-
-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName {
	
    if ([elementName isEqualToString:@"Name"]) {		
        //—-displays the country—-	
		
        NSLog(@"%@", soapResults);	
		
		NSString *name =
		[NSString stringWithFormat:@"%@", soapResults];
        
		[listOfEvents addObject:name];
        
		/*
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Name found!"							  
         message:name							  
         delegate:self							  
         cancelButtonTitle:@"OK"							  
         otherButtonTitles:nil];		
         [alert show];		
         [alert release];	
         */
		
        [soapResults setString:@""];		
        elementFound = FALSE;	
    } 
    else if ([elementName isEqualToString:@"EventID"]) {		
        //—-displays the country—-	
		
        NSLog(@"ID: %@", soapResults2);	
		
		NSString *name2 =
		[NSString stringWithFormat:@"%@", soapResults2];
		
		[listOfEventIDs addObject:name2];
		
		/*
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Name found!"							  
		 message:name							  
		 delegate:self							  
		 cancelButtonTitle:@"OK"							  
		 otherButtonTitles:nil];		
		 [alert show];		
		 [alert release];	
		 */
		
        [soapResults2 setString:@""];		
        elementFound2 = FALSE;	
    } 
	
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 // Return the number of sections.
 return 0;
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listOfEvents count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Select Event";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSString *cellValue = [listOfEvents objectAtIndex:indexPath.row];
	
	cell.textLabel.text = cellValue;
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	NSString *eventSelected = [listOfEvents objectAtIndex:[indexPath row]];
	//NSString *message = [[NSString alloc]initWithFormat:@"%@", eventSelected];
    
    
     UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
     
     
     if (thisCell.accessoryType == UITableViewCellAccessoryNone) {
     thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
     
     }else{
     thisCell.accessoryType = UITableViewCellAccessoryNone;
     
     }
   
    NSString *temp = @"";
    NSString *temp2 = @"";
    
    NSMutableArray *selectedRows = [[NSMutableArray alloc] init];
    
    
    for (int i=0; i<[listOfEvents count]; i++) {
        
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *aCell = (UITableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath2];
        if (aCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [selectedRows addObject:indexPath2];
            NSString *eventIDWasSelected = [listOfEventIDs objectAtIndex:[indexPath2 row]];
            NSString *eventWasSelected = [listOfEvents objectAtIndex:[indexPath2 row]];
            //if(temp != @"")
            //    temp = [temp stringByAppendingString:@", "];
            if(temp2 != @"")
                temp2 = [temp2 stringByAppendingString:@", "];
            
            temp = [temp stringByAppendingString:@"<int>"];
            
            temp = [temp stringByAppendingString:eventIDWasSelected]; 
            temp2 = [temp2 stringByAppendingString:eventWasSelected]; 
            //NSLog(@"Group Selected %@", eventIDWasSelected);

            temp = [temp stringByAppendingString:@"</int>"];
           
        }
    }
    
    
	NSString *eventIDSelected = [listOfEventIDs objectAtIndex:[indexPath row]];
	//NSString *message2 = [[NSString alloc]initWithFormat:@"%@", eventIDSelected];

    NSLog(@"Group IDs Selected %@", temp);
    NSLog(@"Group Selected %@", temp2);
    
    self.eventsSelected = temp2;
    //self.eventIDsSelected = temp;
    self.eventIDsSelected = temp;
    
    
    
	//NSLog(@"Selected %@", message);	
	
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[url release];
	[venueID release];
	[authUserID release];
	[email release];
	[listOfEvents release];
	[listOfEventIDs release];
    [super dealloc];
}


@end
