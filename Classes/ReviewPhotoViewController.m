//
//  ReviewPhotoViewController.m
//  DoubleCamera
//
//  Created by kronick on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ReviewPhotoViewController.h"
#import "DoublePhoto.h"

@implementation ReviewPhotoViewController

@synthesize capturedImages, userDefaults, capturedDoublePhoto;
@synthesize frontImageView, backImageView, mainToolbar;
@synthesize cameraController;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		self.userDefaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *defaults = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:0] forKey:@"file_number"];
		[self.userDefaults registerDefaults:defaults];
		
		self.cameraController = [[[CameraOverlayController alloc] initWithNibName:@"CameraOverlayView" bundle:nil] autorelease];
		self.cameraController.delegate = self;		
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		
		
		[self.navigationController setNavigationBarHidden:YES];
		self.capturedImages = [NSMutableArray array];
		
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
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad {
//    [super viewDidLoad];	
//}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[self.userDefaults release];
	[self.cameraController release];
	[self.capturedImages release];
    [super dealloc];
}

#pragma -
#pragma mark Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	//NSLog(@"Touch in view: %@", [touch.view class]);
	return (![touch.view isKindOfClass:[UIButton class]] && ![touch.view.superview isKindOfClass:[UIToolbar class]] && ![touch.view isKindOfClass:[UIToolbar class]] );
}

- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer {
	NSUInteger direction;
	if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) direction = UIViewAnimationOptionTransitionFlipFromRight;
	else direction = UIViewAnimationOptionTransitionFlipFromLeft;
	
	if([backImageView isHidden])
		[UIView transitionFromView:frontImageView toView:backImageView duration:0.8 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];
	else
		[UIView transitionFromView:backImageView toView:frontImageView duration:0.8 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];
	//^(BOOL b){[self hideToolbars];}	
}

- (void)toggleToolbars {
	if(mainToolbar.hidden == YES)	[self showToolbars];
	else							[self hideToolbars];
}
- (void)hideToolbars {
	if(mainToolbar.hidden == NO) {
		[UIView animateWithDuration:0.4 animations:^{
			CGRect frame = mainToolbar.frame;
			frame.origin.y += 44;
			mainToolbar.frame = frame;
		} completion:^(BOOL b){
			mainToolbar.hidden = YES;
		}];
	}
}

- (void)showToolbars {
	if(mainToolbar.hidden == YES) {
		mainToolbar.hidden = NO;
		[UIView animateWithDuration:0.4 animations:^{
			CGRect frame = mainToolbar.frame;
			frame.origin.y -= 44;
			mainToolbar.frame = frame;
		}];
	}
}

#pragma -
#pragma mark IBActions

- (IBAction)save {
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
	
	[self.capturedDoublePhoto release];

	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)trash {
	// Just return to the last view
	//[self.navigationController popViewControllerAnimated:YES];
	[self launchCamera];

	
	[self.capturedDoublePhoto release];
}


- (void)launchCamera {
	[self presentModalViewController:self.cameraController animated:YES];
	[self.cameraController startFrontCaptureSession];
}

#pragma -
#pragma mark CameraOverlayDelegate

- (void)didTakePicture:(NSData *)pictureData {	
	NSLog(@"Adding picture to array of captured images");
	[self.capturedImages addObject:pictureData];
}
- (void)didFinishWithCamera {
	[self dismissModalViewControllerAnimated:YES];
	if ([self.capturedImages count] == 2) {		
		self.capturedDoublePhoto = [[DoublePhoto alloc] initWithFrontData:[self.capturedImages objectAtIndex:0] andBackData:[self.capturedImages objectAtIndex:1]];

		[self.capturedImages removeAllObjects];
		
		[self.frontImageView setImage:self.capturedDoublePhoto.frontScreenImage];
		[self.backImageView setImage:self.capturedDoublePhoto.backScreenImage];
		
		UIImage *image = [UIImage imageWithData:self.capturedDoublePhoto.frontJPEGData];
		NSLog(@"%f.0 x %f.0", image.size.width, image.size.height);
	}	
	else {
		[self.navigationController popViewControllerAnimated:YES];
		
	}
}



@end
