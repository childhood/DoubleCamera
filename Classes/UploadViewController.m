//
//  UploadViewController.m
//  DoubleCamera
//
//  Created by kronick on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadViewController.h"


@implementation UploadViewController
@synthesize toUpload;
@synthesize sideADescriptionCell, sideBDescriptionCell, twitterCell, tumblrCell, facebookCell;
@synthesize sideAImageView, sideBImageView;
@synthesize sideADescriptionLabel, sideBDescriptionLabel;
@synthesize sideADescription, sideBDescription;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)init {
	return [self initWithNibName:@"UploadViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set up navigation bar stuff
		self.title = @"Upload";
		UIBarButtonItem *rightBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(startUpload)] autorelease];
		self.navigationItem.rightBarButtonItem = rightBarButton;	
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	self.sideAImageView.image = self.toUpload.frontThumbnailImage;
	self.sideBImageView.image = self.toUpload.backThumbnailImage;
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
	[self.navigationController setNavigationBarHidden:NO];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	self.wantsFullScreenLayout = NO;
}
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


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
    [super dealloc];
}

#pragma mark -
#pragma mark Uploading actions

- (void)startUpload {
	NSLog(@"Calling the upload function of the photo...");
	if(self.toUpload != nil) {
		// TODO: Build metadata dictionary
		[self.toUpload uploadWithAlert:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark UITableView Delegates + Data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch([indexPath section]) {
		case 0:	// Description section			
			switch([indexPath row]) {
				case 0:
					return sideADescriptionCell;
				case 1:
					return sideBDescriptionCell;
			}
			break;
		case 1: // Sharing section
			switch([indexPath row]) {
				case 0:
					return twitterCell;
				case 1:
					return facebookCell;
				case 2:
					return tumblrCell;
			}
	}
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return @"";
		case 1:
			return @"Sharing";
	}
	return @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
		case 0: // Description section
			return 2;
		case 1:	// Sharing section
			return 3;
	}
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch([indexPath section]) {
		case 0: // Description Section
			return tableView.rowHeight * 2;
		case 1:	// Sharing Section
			return tableView.rowHeight;
	}
	return tableView.rowHeight;			
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
	if(textView == sideADescription)
		sideADescriptionLabel.alpha = 0;
	if(textView == sideBDescription)
		sideBDescriptionLabel.alpha = 0;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
	if(textView == sideADescription && ![textView hasText])
		sideADescriptionLabel.alpha = 1;
	if(textView == sideBDescription && ![textView hasText])
		sideBDescriptionLabel.alpha = 1;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
	else if([[textView text] length] <= 60 || [text isEqualToString:@""]) return YES;
	else return NO;
}

@end