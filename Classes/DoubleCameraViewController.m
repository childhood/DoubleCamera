//
//  DoubleCameraViewController.m
//  DoubleCamera
//
//  Created by kronick on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DoubleCameraViewController.h"

@implementation DoubleCameraViewController

@synthesize reviewController, organizerController, slideTimer, frontImageView, backImageView, loadingView, mainToolbar;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

# pragma -
# pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if(viewController == self) {
		[self.navigationController setNavigationBarHidden:NO];
	}
	if(viewController == self.reviewController) {
		[self.navigationController setNavigationBarHidden:YES];
	}
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationController.delegate = self;
	
	[loadingView startAnimating];
	loadingView.hidden = NO;
	
	// Load default images
	NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] error:nil];
	NSLog(@"%@", directoryContents);
	NSString *frontImagePath = [NSString pathWithComponents: [NSArray arrayWithObjects: NSHomeDirectory() ,  @"Documents", @"01_front.jpg", nil]];
	NSString *backImagePath = [NSString pathWithComponents: [NSArray arrayWithObjects: NSHomeDirectory() ,  @"Documents", @"01_back.jpg", nil]];	
	//self.frontImageView.image = [UIImage imageWithContentsOfFile:frontImagePath];
	//self.backImageView.image = [UIImage imageWithContentsOfFile:backImagePath];
	
	//self.slideTimer = [NSTimer scheduledTimerWithTimeInterval: 2 target:self selector:@selector(updateSlides:) userInfo:nil repeats:YES];
	
	// Initialize children view controllers
	self.reviewController = [[[ReviewPhotoViewController alloc] initWithNibName:@"ReviewView" bundle:nil] autorelease];
	self.organizerController = [[[OrganizerViewController alloc] initWithNibName:@"OrganizerView" bundle:nil] autorelease];
	self.organizerController.title = @"Double Album";

	
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	NSLog(@"Loaded main view controller.");
	
	// Set up gestures
	UISwipeGestureRecognizer *switchPhotoGestureRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipGesture:)] autorelease];
	switchPhotoGestureRight.delegate = self;
	[self.view addGestureRecognizer:switchPhotoGestureRight];
	UISwipeGestureRecognizer *switchPhotoGestureLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipGesture:)] autorelease];
	switchPhotoGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	switchPhotoGestureLeft.delegate = self;
	[self.view addGestureRecognizer:switchPhotoGestureLeft];
	
	//UITapGestureRecognizer *tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleToolbars)] autorelease];
	//tapGestureRecognizer.delegate = self;
	//[self.view addGestureRecognizer:tapGestureRecognizer];	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	//NSLog(@"Touch in view: %@", [touch.view class]);
	return (![touch.view isKindOfClass:[UIButton class]] && ![touch.view.superview isKindOfClass:[UIToolbar class]] && ![touch.view isKindOfClass:[UIToolbar class]] );
}


- (IBAction)launchCameraAction:(id)sender {
	[self.navigationController pushViewController:self.reviewController animated:YES];
	[self.reviewController launchCamera];
	[loadingView stopAnimating];
}

- (IBAction)launchOrganizer {
	[[self navigationController] pushViewController:self.organizerController animated:YES];
}

- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer {
	NSUInteger direction;
	if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) direction = UIViewAnimationOptionTransitionFlipFromRight;
	else direction = UIViewAnimationOptionTransitionFlipFromLeft;
	
	[self flipImage:direction];
}

- (void)flipImage:(UIViewAnimationOptions)direction {
	if([backImageView isHidden])
		[UIView transitionFromView:frontImageView toView:backImageView duration:0.8 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];
	else
		[UIView transitionFromView:backImageView toView:frontImageView duration:0.8 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];
}


- (void)updateSlides:(NSTimer *)timer {
	[self flipImage:UIViewAnimationOptionTransitionFlipFromRight];
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

- (IBAction)flipImage {
	NSLog(@"Flipping images...");
	if([backImageView isHidden])
		[UIView transitionFromView:frontImageView toView:backImageView duration:0.4 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
	else
		[UIView transitionFromView:backImageView toView:frontImageView duration:0.4 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight completion:nil];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[self.slideTimer invalidate];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	NSLog(@"Exiting program...");
}


- (void)dealloc {
    [super dealloc];
}

@end
