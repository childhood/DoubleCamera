//
//  ReviewPhotoViewController.m
//  DoubleCamera
//
//  Created by kronick on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ReviewPhotoViewController.h"


@implementation ReviewPhotoViewController

@synthesize capturedImages, userDefaults;
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
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	
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
	NSString *fileNumber = [NSString stringWithFormat:@"%.4i", fileInteger];
	NSString *frontFilename = [fileNumber stringByAppendingString:@"_front.jpg"];
	NSString *backFilename = [fileNumber stringByAppendingString:@"_back.jpg"];
	NSData *frontImageData = [NSData dataWithData:UIImageJPEGRepresentation([self.capturedImages objectAtIndex:0], 0.9)];
	NSString *frontImagePath = [NSString pathWithComponents: [NSArray arrayWithObjects: NSHomeDirectory(),  @"Documents", frontFilename, nil]];
	NSData *backImageData = [NSData dataWithData:UIImageJPEGRepresentation([self.capturedImages objectAtIndex:1], 0.9)];
	NSString *backImagePath = [NSString pathWithComponents: [NSArray arrayWithObjects: NSHomeDirectory(),  @"Documents", backFilename, nil]];
	
	[frontImageData writeToFile:frontImagePath atomically:YES];
	[backImageData writeToFile:backImagePath atomically:YES];
	
	[userDefaults setInteger:(fileInteger+1) forKey:@"file_number"];

	[self.capturedImages removeAllObjects];
	
	NSLog(@"Saved!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)trash {
	// Just return to the last view
	//[self.navigationController popViewControllerAnimated:YES];
	[self launchCamera];
	[self.capturedImages removeAllObjects];
}


- (void)launchCamera {
	[self presentModalViewController:self.cameraController animated:YES];
	[self.cameraController startFrontCaptureSession];
}

#pragma -
#pragma mark CameraOverlayDelegate

- (void)didTakePicture:(UIImage *)picture {	
	NSLog(@"Adding picture to array of captured images");
	[self.capturedImages addObject:picture];
	
	NSLog(@"Picture %i added: %f x %f", [self.capturedImages count], picture.size.width, picture.size.height);
}
- (void)didFinishWithCamera {
	[self dismissModalViewControllerAnimated:YES];
	
	if ([self.capturedImages count] > 0) {
		NSLog(@"Displaying %i captured images...", [self.capturedImages count]);
		
		[self.frontImageView setImage:[self.capturedImages objectAtIndex:0]];
		if([self.capturedImages count] > 1)
			[self.backImageView setImage:[self.capturedImages objectAtIndex:1]];
	}	
	else {
		[self.navigationController popViewControllerAnimated:YES];
		
	}
}



@end
