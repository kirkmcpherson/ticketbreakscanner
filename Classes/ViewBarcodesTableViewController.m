//
//  ViewBarcodesTableViewController.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 11-09-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewBarcodesTableViewController.h"


@implementation ViewBarcodesTableViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
	self.navigationItem.title = @"View Barcodes";
	
	[self openDB];
	[self getAllRowsFromTableNamed:@"Barcodes"];
	
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listOfBarcodes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Barcodes Scanned";
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

-(void) getAllRowsFromTableNamed: (NSString *) tableName {
	listOfBarcodes = [[NSMutableArray alloc] init];
	
    //—-retrieve rows—-	
    NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];	
    sqlite3_stmt *statement;	
	
	NSLog(@"%@", qsql);
	
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {		
        while (sqlite3_step(statement) == SQLITE_ROW) {			
            char *field1 = (char *) sqlite3_column_text(statement, 0);			
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
			
            //char *field2 = (char *) sqlite3_column_text(statement, 1);			
            //NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
			
			//NSString *str = [[NSString alloc] initWithFormat:@"%@ - %@",							 
			//				 field1Str, field2Str];			
            NSLog(@"ViewBarcodes: %@", field1Str);
			
			[listOfBarcodes addObject:field1Str];
			
            //[field1Str release];			
            //[field2Str release];			
            //[str release];			
        }
		
		
        //—-deletes the compiled statement from memory—-		
        sqlite3_finalize(statement);		
    }
	
	[self.tableView reloadData];
	
	NSLog(@"barcodes array has %d items", [listOfBarcodes count]);	
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString *cellValue = [listOfBarcodes objectAtIndex:indexPath.row];
	
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
    // Navigation logic may go here. Create and push another view controller.
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
	[listOfBarcodes release];
    [super dealloc];
}


@end

