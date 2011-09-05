//
//  UploadViewController.m
//  DoubleCamera
//
//  Created by kronick on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadViewController.h"
#import "LoginViewController.h"
#import "Reachability.h"
#import "Utilities.h"


@implementation UploadViewController
@synthesize toUpload;
@synthesize tableView, sideADescriptionCell, sideBDescriptionCell, twitterCell, tumblrCell, facebookCell;
@synthesize twitterSwitch, tumblrSwitch, facebookSwitch;
@synthesize facebookConnectView, facebookConnectWebView, facebookConnectCloseButton;
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
		UIBarButtonItem *rightBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleDone target:self action:@selector(startUpload)] autorelease];
		self.navigationItem.rightBarButtonItem = rightBarButton;	
		self.navigationItem.leftBarButtonItem.title = @"Cancel";
		
		// Set back navigation title
		UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
		temporaryBarButtonItem.title = @"Cancel";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;		
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	self.sideAImageView.image = self.toUpload.frontThumbnailImage;
	self.sideBImageView.image = self.toUpload.backThumbnailImage;
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,200,0)];
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
    if(![Reachability connectedToTheNet]) {
        UIAlertView *notConnectedAlert = [[[UIAlertView alloc] initWithTitle: @"No Connection"
                                                                 message: @"You are not connected to the 'net. Please try again later!"
                                                                delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
        [notConnectedAlert show];        
    }
	// Ask user to log in if they haven't already
	else if([[NSUserDefaults standardUserDefaults] integerForKey:@"user_id"] == 0 || [[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] isEqualToString:@""]) {
		LoginViewController *loginView = [[[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil] autorelease];
		loginView.title = @"Sign In";
		loginView.returnController = self;
		[self.navigationController pushViewController:loginView animated:YES];
	}
	else if(self.toUpload != nil) {
		NSLog(@"Calling the upload function of the photo...");
		NSLog(@"Building metadata...");
		UploadMetaData metaData;
		metaData.frontCaption = [sideADescription.text copy];
		metaData.backCaption = [sideBDescription.text copy];
		metaData.shareOnTwitter = self.twitterSwitch.isOn;
		metaData.shareOnFacebook = self.facebookSwitch.isOn;
		metaData.shareOnTumblr = self.tumblrSwitch.isOn;
		metaData.timeTaken = @"000000";
		
		[self.toUpload setMetaData:metaData];

		[self.toUpload uploadWithAlert:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		NSLog(@"toUpload was nil for some reason.");
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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return @"";
		case 1:
            return @"\n\n";
			//return @"Sharing";
	}
	return @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
		case 0: // Description section
			return 2;
		case 1:	// Sharing section
            return 0;
			//return 3;
	}
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch([indexPath section]) {
		case 0: // Description Section
			//return tableView.rowHeight * 4;
            return 158;
		case 1:	// Sharing Section
			return tableView.rowHeight;
	}
	return tableView.rowHeight;			
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch([indexPath section]) {
		case 0:	// Description section			
			// Nothing to do here
			break;
		case 1: // Sharing section
			switch([indexPath row]) {
				case 0:
					// TODO: Configure Twitter
					break;
				case 1:
					[self facebookConnect];
					break;
				case 2:
					// TODO: Configure Tumblr
					break;
			}
	}	
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

#pragma mark -
#pragma mark Handle connections

- (void) facebookConnect {
	NSURL *url = [NSURL URLWithString:@"http://www.facebook.com/connect/uiserver.php?app_id=160548430646821&next=http://socialprintshop.com/doublecam/connect.php&display=page&cancel_url=http://socialprintshop.com/doublecam/connect.php&locale=en_US&perms=email,offline_access&return_session=1&session_version=3&fbconnect=1&canvas=0&legacy_return=1&method=permissions.request&display=wap"];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[facebookConnectWebView loadRequest:requestObj];

	[facebookConnectView setAlpha:0];
	[facebookConnectView setHidden:NO];
	[UIView animateWithDuration:0.2 animations:^{
		[facebookConnectView setAlpha:1];
	} completion:^(BOOL b){}];
	
}

- (IBAction) closeFacebookConnect {
	[UIView animateWithDuration:0.2 animations:^{
		[facebookConnectView setAlpha:0];
	} completion:^(BOOL b){ [facebookConnectView setHidden:YES]; }];
	
	NSLog(@"Page at close: %@", [facebookConnectWebView stringByEvaluatingJavaScriptFromString:@"document.title"]);
}

@end