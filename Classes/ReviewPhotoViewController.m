//
//  ReviewPhotoViewController.m
//  DoubleCamera
//
//  Created by kronick on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ReviewPhotoViewController.h"
#import "ImagePickerOverlayController.h"
#import "DoublePhoto.h"
#import "UploadViewController.h"

@implementation ReviewPhotoViewController

@synthesize capturedImages, userDefaults, capturedDoublePhoto;
@synthesize frontImageView, backImageView, mainToolbar;
@synthesize imagePickerOverlay, imagePickerController, organizerController;
@synthesize secondPictureTimer;
@synthesize processingView;

- (void)viewDidLoad {
	NSLog(@"View Did Load");
    [super viewDidLoad];	
	
	// Set this class to handle navigation events
	self.navigationController.delegate = self;
	
	// Load user settings into defaults dictionary
	self.userDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithObject: [NSNumber numberWithInt:0] forKey:@"file_number"];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:@"user_id"];
	[self.userDefaults registerDefaults:defaults];
	
	// HARDCODED USER ID
	//[userDefaults setInteger:0 forKey:@"user_id"];
	
	self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

	if(self.capturedImages == nil) {
		NSLog(@"Creating captured images dictionary...");
		// Initialize captured images dictionary
		self.capturedImages = [NSMutableDictionary dictionary];
	}
	else {
		self.frontImageView.image = [self.capturedImages objectForKey:@"front"];
		self.backImageView.image = [self.capturedImages objectForKey:@"rear"];
	}
	
	// Set up camera picker and overlay contorller
	if(self.imagePickerController == nil) {
		NSLog(@"Setting up image picker...");
		self.imagePickerController = [[UIImagePickerController alloc] init];
		self.imagePickerController.delegate = self;
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.imagePickerController.allowsEditing = NO;
		self.imagePickerController.showsCameraControls = NO;
		
		firstLaunch = YES;
	}
	
	if(self.imagePickerOverlay == nil) {
		NSLog(@"Setting image picker overlay...");
		self.imagePickerOverlay = [[ImagePickerOverlayController alloc] initWithNibName:@"ImagePickerOverlay" bundle:nil];
		[self.imagePickerOverlay setupOverlayForPicker:self.imagePickerController];	
	}
	
	if(self.organizerController == nil) {
		NSLog(@"Setting up organizer...");
		// Initialize organizer view controller
		self.organizerController = [[OrganizerViewController alloc] initWithNibName:@"OrganizerView" bundle:nil];
		self.organizerController.title = @"Double Album";
	}
	
	self.title = @"Camera";

	
	// Set up gestures
	UISwipeGestureRecognizer *switchPhotoGestureRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipGesture:)] autorelease];
	switchPhotoGestureRight.delegate = self;
	[self.view addGestureRecognizer:switchPhotoGestureRight];
	UISwipeGestureRecognizer *switchPhotoGestureLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipGesture:)] autorelease];
	switchPhotoGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	switchPhotoGestureLeft.delegate = self;
	[self.view addGestureRecognizer:switchPhotoGestureLeft];
	
	UITapGestureRecognizer *tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleToolbars)] autorelease];
	tapGestureRecognizer.delegate = self;
	[self.view addGestureRecognizer:tapGestureRecognizer];		
	
	if(firstLaunch) {
		[self launchCamera];
		//[[UIApplication sharedApplication] _performMemoryWarning];
	}
}


- (void)viewWillAppear:(BOOL)animated {
	if(!justTookPicture) [self launchCamera];
	else justTookPicture = NO;
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	self.wantsFullScreenLayout = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning in ReviewPhotoViewController.");
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"Deallocing ReviewPhotoViewController");
	self.imagePickerController = nil;
	self.imagePickerOverlay = nil;
	self.userDefaults = nil;
	self.capturedImages = nil;	
	/*
	[self.imagePickerController release];
	[self.imagePickerOverlay release];
	[self.userDefaults release];
	[self.capturedImages release];
	 */
    [super dealloc];
}

# pragma -
# pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if(viewController == self) {
		[self.navigationController setNavigationBarHidden:YES];
	}
	else if(viewController == self.organizerController) {
		[self.navigationController setNavigationBarHidden:NO];

	}

}


#pragma -
#pragma mark Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return (![touch.view isKindOfClass:[UIButton class]] && ![touch.view.superview isKindOfClass:[UIToolbar class]] && ![touch.view isKindOfClass:[UIToolbar class]] );
}

- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer {
	NSUInteger direction;
	if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) direction = UIViewAnimationOptionTransitionFlipFromRight;
	else direction = UIViewAnimationOptionTransitionFlipFromLeft;
	
	if([backImageView isHidden]) {
		[UIView transitionFromView:frontImageView toView:backImageView duration:0.6 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];
	}
	else {
		[UIView transitionFromView:backImageView toView:frontImageView duration:0.6 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];
	}
	//^(BOOL b){[self hideToolbars];}	
}

- (void)toggleToolbars {
	if(mainToolbar.hidden == YES)	[self showToolbars];
	else							[self hideToolbars];
}
- (void)hideToolbars {
	if(mainToolbar.hidden == NO) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		[UIView animateWithDuration:0.2 animations:^{
			mainToolbar.alpha = 0;
		} completion:^(BOOL b){
			mainToolbar.hidden = YES;
		}];
	}
}

- (void)showToolbars {
	if(mainToolbar.hidden == YES) {
		mainToolbar.hidden = NO;
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		[UIView animateWithDuration:0.2 animations:^{
			mainToolbar.alpha = 1;
		} completion:^(BOOL b) { }];
	}
}

#pragma -
#pragma mark IBActions

- (IBAction)save {
	self.processingView.alpha = 0;
	self.processingView.center = self.view.center;
	[self.view addSubview:self.processingView];
	[UIView animateWithDuration:0.2 animations:^{ self.processingView.alpha = 1; }];
	[self performSelector:@selector(saveFiles) withObject:nil afterDelay:0.05];

}

- (IBAction)trash {
	// Just return to the last view
	//[self.navigationController popViewControllerAnimated:YES];
	[self launchCamera];

	[self.capturedImages removeAllObjects];
	[self.capturedDoublePhoto release];
}


- (void)saveFiles {
	self.capturedDoublePhoto = [[DoublePhoto alloc] initWithFrontData:UIImageJPEGRepresentation([self.capturedImages objectForKey:@"front"], 1) andBackData:UIImageJPEGRepresentation([self.capturedImages objectForKey:@"rear"], 1)];
	NSInteger fileInteger = [userDefaults integerForKey:@"file_number"];
	NSString *filePrefix = [NSString stringWithFormat:@"%.4i", fileInteger];
	
	self.capturedDoublePhoto.filePrefix = filePrefix;
	self.capturedDoublePhoto.filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	if([self.capturedDoublePhoto saveToDisk] == 4) {
		[userDefaults setInteger:(fileInteger+1) forKey:@"file_number"];
		NSLog(@"Saved!");
	}
	else {
		NSLog(@"Error saving.");
	}
	
	[self.capturedImages removeAllObjects];
	
	//[self.navigationController popViewControllerAnimated:YES];
	
	// Back to picture-taking mode
	[UIView animateWithDuration:0.2 animations:^{ self.processingView.alpha = 0; }
					 completion: ^(BOOL b){
						 [self.processingView removeFromSuperview];
						 //[self launchCamera];
						 
						 UploadViewController *uploadView = [[[UploadViewController alloc] init] autorelease];
						 uploadView.toUpload = self.capturedDoublePhoto;
						 [self.navigationController pushViewController:uploadView animated:YES];
 						 self.capturedDoublePhoto = nil;
					 }];
}

- (void)launchCamera {
	NSLog(@"Launching camera...");
	[self presentModalViewController:self.imagePickerController animated:firstLaunch ? NO : YES];
	firstLaunch = NO;
}


- (void)tryAnotherPicture:(NSTimer *)theTimer {
	NSLog(@"Trying to take a picture...");
	//[self.imagePickerController performSelectorOnMainThread:@selector(takePicture) withObject:nil waitUntilDone:NO];

	[self.imagePickerController takePicture];
	NSLog(@"Is view loaded? %d", [self isViewLoaded]);
}
- (void)startSecondPictureTimer {
	self.secondPictureTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tryAnotherPicture:) userInfo:nil repeats:YES];
}
- (void)stopSecondPictureTimer {
	[secondPictureTimer invalidate];
}


#pragma -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if([self.capturedImages count] == 0 && info != nil) {
		//[self dismissModalViewControllerAnimated:NO];
		//[self presentModalViewController:picker animated:NO];
		
		NSString *key = (picker.cameraDevice == UIImagePickerControllerCameraDeviceRear ? @"rear" : @"front");
		// Switch the camera device
		picker.cameraDevice = picker.cameraDevice == UIImagePickerControllerCameraDeviceRear ? UIImagePickerControllerCameraDeviceFront
																							 : UIImagePickerControllerCameraDeviceRear;
		
		[self startSecondPictureTimer];
		[self.capturedImages setValue:pickedImage forKey:key];
	}
	else {
		NSLog(@"Second picture taken.");
		[self stopSecondPictureTimer];
		
		NSLog(@"Processing images.");
		[self.capturedImages setValue:pickedImage forKey:(picker.cameraDevice == UIImagePickerControllerCameraDeviceRear ? @"rear" : @"front")];
		
		NSLog(@"%i", self.capturedImages.count);
		
		if ([self.capturedImages count] == 2) {		
			// TODO: Figure out which image comes from
			//NSLog(@"Creating doublePhoto object");
			
			
			NSLog(@"Updating references");
			self.frontImageView.image = [self.capturedImages objectForKey:@"front"];
			self.backImageView.image = [self.capturedImages objectForKey:@"rear"];
			
			
			if(picker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {				
				self.frontImageView.hidden = YES;
				self.backImageView.hidden = NO;
			}
			else {
				self.frontImageView.hidden = NO;
				self.backImageView.hidden = YES;
			}
			
			
		}
		
		justTookPicture = YES;
		
		self.imagePickerController.view.superview.backgroundColor = [UIColor blackColor];
		[UIView animateWithDuration:0.4 delay:0.4 options:nil animations:^{ self.imagePickerController.view.alpha = 0; }
				completion:^(BOOL b) { [self dismissModalViewControllerAnimated:NO]; self.imagePickerController.view.alpha = 1; }];
		
		
	}
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
	
	[[self navigationController] pushViewController:self.organizerController animated:YES];
}

@end
