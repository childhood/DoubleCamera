//
//  LoginViewController.m
//  DoubleCamera
//
//  Created by kronick on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Utilities.h"
#import "SyncManager.h"

@implementation LoginViewController

@synthesize usernameField, passwordField, activityIndicator;
@synthesize registerView, registerWebView;
@synthesize returnController;


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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	usernameField.delegate = self;
	passwordField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) signIn {
    NSURL *url =   [[SyncManager sharedSyncManager] URLForScript:@"user-info"];
	__block ASIFormDataRequest *authenticateRequest = [ASIFormDataRequest requestWithURL:url];
	[authenticateRequest addPostValue:self.usernameField.text forKey:@"username"];
	[authenticateRequest addPostValue:[Utilities MD5:self.passwordField.text] forKey:@"password"];
	
	[authenticateRequest setCompletionBlock:^{	
		[self.activityIndicator stopAnimating];
		
		NSString *responseString = [authenticateRequest responseString];
		NSDictionary *responseDict = [responseString JSONValue];
		NSNumber *userIDObject = [responseDict objectForKey:@"user-id"];
		
		if(userIDObject) {
			[[NSUserDefaults standardUserDefaults] setObject:userIDObject forKey:@"user_id"];
			[[NSUserDefaults standardUserDefaults] setObject:self.usernameField.text forKey:@"username"];
			[[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"password"];
			
			NSLog(@"Stored user ID: %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"user_id"]);
            
            [[SyncManager sharedSyncManager] reloadPhotoListWithCompletionBlock:nil];        

			// Pop this view, and push the return destination
            if(self.returnController != nil) {
                NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
                [controllers removeLastObject];
                [controllers addObject:self.returnController];
                [self.navigationController setViewControllers:controllers animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
		}
		else {
			// Unsuccessful
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"user_id"];
			[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
			[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
			
			UIAlertView *errorAlert = [[[UIAlertView alloc] initWithTitle: @"Could Not Log In"
																	 message: @"Sorry, try again!"
																	delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
            NSLog(@"Response: %@", responseString);
			[errorAlert show];			
			
		}
	}];
	
	[authenticateRequest startAsynchronous];
	[self.activityIndicator startAnimating];
}

- (IBAction)launchRegisterView {
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:[[SyncManager sharedSyncManager] URLForScript:@"register-user"]];
	[registerWebView loadRequest:requestObj];
    
	[registerView setAlpha:0];
	[registerView setHidden:NO];
	[UIView animateWithDuration:0.2 animations:^{
		[registerView setAlpha:1];
	} completion:^(BOOL b){}];
}
- (IBAction)dismissRegisterView {
    [UIView animateWithDuration:0.2 animations:^{
        [registerView setAlpha:0];
    } completion:^(BOOL b) { registerView.hidden = YES; }];
    NSString *username = [registerWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('username').attributes.getNamedItem('value').value"];
    NSString *password = [registerWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('password').attributes.getNamedItem('value').value"];
    NSString *user_id = [registerWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('id').attributes.getNamedItem('value').value"];
    NSLog(@"Username: %@ / Password: %@ / ID: %@", username, password, user_id); 
    
    if(![username isEqualToString:@""] && ![password isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
        
        NSLog(@"Stored user ID: %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"user_id"]);
        
        [[SyncManager sharedSyncManager] reloadPhotoListWithCompletionBlock:nil];        
        
        // Pop this view, and push the return destination
        
        if(self.returnController != nil) {
            NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
            [controllers removeLastObject];
            [controllers addObject:self.returnController];
            [self.navigationController setViewControllers:controllers animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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
#pragma mark UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if(textField == usernameField)
		[passwordField becomeFirstResponder];
	if(textField == passwordField && ![usernameField.text isEqualToString:@""])
		[self signIn];
		
	return YES;
}

@end
