//
//  InfoViewPasswordController.m
//  TicketBreakScanner
//
//  Created by Kirk McPherson on 12-06-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewPasswordController.h"

@implementation InfoViewPasswordController

@synthesize infoViewController;

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
	self.navigationItem.title = @"Password";
	
    //self.view.userInteractionEnabled = YES;
    
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//self.url = [defaults objectForKey:@"url"];
	
	self.title = @"Password";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)enterPassword:(id)sender {	
    
    if([password.text isEqualToString:@"123"])
    {
	if(self.infoViewController == nil)
    {
        InfoViewController  *d = [[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:[NSBundle mainBundle]];
        self.infoViewController = d;
        [d release];
        
    }
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    //self.venueID = [defaults objectForKey:@"venue_id"];
    
    //self.selectMultipleEventTableViewController.authUserID = authUserID;
    //self.selectMultipleEventTableViewController.email = email;
    //self.selectMultipleEventTableViewController.venueID = [defaults objectForKey:@"venue_id"];
    //self.selectMultipleEventTableViewController.url = [defaults objectForKey:@"url"];
    
    //[self.selectMultipleEventTableViewController.tableView reloadData];    
    //[self.selectMultipleEventTableViewController loadEvents];
    
    [self.navigationController pushViewController:self.infoViewController animated:YES];
    } else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid password."							  
                                                        message:@"Please try again."							  
                                                       delegate:self							  
                                              cancelButtonTitle:@"OK"							  
                                              otherButtonTitles:nil];		
        [alert show];		
        [alert release];		
        
        
    }
}

- (void)dealloc {
    [password release];
    [infoViewController release];
}

@end
