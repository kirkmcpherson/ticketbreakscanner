//
//  InfoViewController.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController

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

-(void) deleteAllFromTableNamed: (NSString *) tableName {
    
    NSString *qsql = [NSString stringWithFormat:@"delete FROM %@", tableName];	
    sqlite3_stmt *statement;	
	
    //NSString *info = @"";
    
    if (sqlite3_exec(db, [qsql UTF8String], nil, nil, nil) != SQLITE_OK ) {
        infoLabel.text = @"Error!";
        
    //if (sqlite3_prepare_v2( db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {		

    }
}

-(void) getAllRowsFromTableNamed: (NSString *) tableName {
    //—-retrieve rows—-	
    NSString *qsql = [NSString stringWithFormat:@"SELECT eventid, count(*) FROM %@ group by eventid", tableName];	
    sqlite3_stmt *statement;	
	
    NSString *info = @"";
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {		
        while (sqlite3_step(statement) == SQLITE_ROW) {			
            char *field1 = (char *) sqlite3_column_text(statement, 0);	
            NSString *field1Str;
            
            if(field1 != NULL) {
                field1Str = [[NSString alloc] initWithUTF8String: field1];
			}
            
            char *field2 = (char *) sqlite3_column_text(statement, 1);	
            NSString *field2Str;
            
            if(field2 != NULL) {
                field2Str = [[NSString alloc] initWithUTF8String: field2];
			}
            
			NSString *str = [[NSString alloc] initWithFormat:@"%@ - %@",							 
							 field1Str, field2Str];			
            NSLog(@"%@", str);			
			  
            info = [NSString stringWithFormat:@"%@ %@", info, str];
            
            [field1Str release];			
            [field2Str release];			
            [str release];			
        }
		
        infoLabel.text = info;
        
        //[info release];
        
        //—-deletes the compiled statement from memory—-		
        sqlite3_finalize(statement);		
    }	
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
	self.navigationItem.title = @"Info";
	
    //self.view.userInteractionEnabled = YES;
    
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//self.url = [defaults objectForKey:@"url"];
	
	self.title = @"Info";
    
    [super viewDidLoad];

    
}

-(void) viewDidAppear:(BOOL)animated {
    infoLabel.text = @"Nothing Scanned";
    
    [self openDB];
    
    [self getAllRowsFromTableNamed:@"Barcodes"];
    sqlite3_close(db);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)clearInfo:(id)sender {	
    [self openDB];
    
    [self deleteAllFromTableNamed:@"Barcodes"];
    sqlite3_close(db);
    
    infoLabel.text = @"Nothing Scanned";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
