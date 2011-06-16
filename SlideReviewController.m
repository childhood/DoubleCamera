//
//  SlideReviewController.m
//  DoubleCamera
//
//  Created by kronick on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SlideReviewController.h"
#import "DoublePhoto.h"
#import "QuartzCore/QuartzCore.h"
#import "UploadViewController.h"

@implementation SlideReviewController

@synthesize frontImageView, backImageView, loadingView, mainToolbar, currentDoublePhoto, doublePhotos, nextDoublePhoto, prevDoublePhoto;
@synthesize orderedPhotoKeys, basePath;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
		
		// Set back navigation title
		UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
		temporaryBarButtonItem.title = @"Back";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		
		self.loadingView = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20,20)] autorelease];
		self.loadingView.hidesWhenStopped = YES;
		UIBarButtonItem *activityButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.loadingView] autorelease];
		self.navigationItem.rightBarButtonItem = activityButtonItem;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.wantsFullScreenLayout = YES;
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
    
	// Iterate through doublePhotos, free screen images for ones far away from the current one
	int i = 0;
	for(NSString *key in orderedPhotoKeys) {
		NSInteger dpIndex = [orderedPhotoKeys indexOfObject:self.currentDoublePhoto.filePrefix];
		if(abs(dpIndex - i) > 5)
			[[doublePhotos objectForKey:key] freeScreenImages];
		i++;
	}
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

- (void)loadDoublePhoto:(DoublePhoto *)dp {
	self.currentDoublePhoto = dp;
	if(self.currentDoublePhoto.frontScreenImage == nil || self.currentDoublePhoto.backScreenImage == nil)
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self.currentDoublePhoto generateScreenImages]; });
	
	
	if(self.orderedPhotoKeys != nil) {
		// Set the title based on the index #
		NSInteger dpIndex = [orderedPhotoKeys indexOfObject:self.currentDoublePhoto.filePrefix];
		self.navigationItem.title = [NSString stringWithFormat:@"%i of %i", dpIndex+1, [orderedPhotoKeys count]];
		// Asynchronously generate screen images for the next and previous doublephoto objects
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			for(int i=0; i<5; i++) {
				if(dpIndex + i+1 < [orderedPhotoKeys count])
					[[self.doublePhotos objectForKey:[orderedPhotoKeys objectAtIndex:(dpIndex+i+1)]] generateScreenImages];
				if(dpIndex > i)
					[[self.doublePhotos objectForKey:[orderedPhotoKeys objectAtIndex:(dpIndex-(i+1))]] generateScreenImages];
			}
			
			//self.frontImageView.image = self.currentDoublePhoto.frontScreenImage;
			//self.backImageView.image = self.currentDoublePhoto.backScreenImage;
			//[self.frontImageView setNeedsDisplay];
			//[self.backImageView setNeedsDisplay];
			//[self.view setNeedsDisplay];
			
		}); 		
	}
	
	[self updateImageViews];
}


- (void)updateImageViews {
	if(self.currentDoublePhoto != nil) {
		if(self.currentDoublePhoto.frontScreenImage != nil && self.currentDoublePhoto.backScreenImage != nil) {
			self.frontImageView.image = self.currentDoublePhoto.frontScreenImage;
			self.backImageView.image = self.currentDoublePhoto.backScreenImage;
			
			// Stop the spinner
			[self.loadingView stopAnimating];
		}
		else {
			// If the full rez images aren't loaded yet, load the thumbnails in and try again in a little bit
			self.frontImageView.image = self.currentDoublePhoto.frontThumbnailImage;
			self.backImageView.image = self.currentDoublePhoto.backThumbnailImage;
			[self performSelector:@selector(updateImageViews) withObject:nil afterDelay:0.05];
			
			// Show the spinner	
			[self.loadingView startAnimating];
		}
	}
	[self.frontImageView setNeedsDisplay];
	[self.backImageView setNeedsDisplay];
	[self.view setNeedsDisplay];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)nextPhoto {
	NSLog(@"Going to the next photo...");
	if(self.orderedPhotoKeys != nil) {
		NSInteger dpIndex = [orderedPhotoKeys indexOfObject:self.currentDoublePhoto.filePrefix];
		if(dpIndex+1 < [orderedPhotoKeys count]) {
			[self loadDoublePhoto:[self.doublePhotos objectForKey:[orderedPhotoKeys objectAtIndex:(dpIndex+1)]]];
			
			CATransition *animation = [CATransition animation];
			[animation setDuration:0.6];
			[animation setType:kCATransitionPush];
			[animation setSubtype:kCATransitionFromRight];
			[animation setDelegate:self];
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			[[[self.frontImageView superview] layer] addAnimation:animation forKey:[NSString stringWithFormat:@"switch to %i", dpIndex+1]];
			[self performSelector:@selector(updateImageViews) withObject:nil afterDelay:0.7];
		}
	}	
}

- (IBAction)previousPhoto {
	if(self.orderedPhotoKeys != nil) {
		NSInteger dpIndex = [orderedPhotoKeys indexOfObject:self.currentDoublePhoto.filePrefix];
		if(dpIndex > 0) {
			[self loadDoublePhoto:[self.doublePhotos objectForKey:[orderedPhotoKeys objectAtIndex:(dpIndex-1)]]];
			
			CATransition *animation = [CATransition animation];
			[animation setDuration:0.6];
			[animation setType:kCATransitionPush];
			[animation setSubtype:kCATransitionFromLeft];
			[animation setDelegate:self];
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			[[[self.frontImageView superview] layer] addAnimation:animation forKey:[NSString stringWithFormat:@"switch to %i", dpIndex-1]];			
			[self performSelector:@selector(updateImageViews) withObject:nil afterDelay:0.7];
		}		
	}
}

- (IBAction)startSlideshow {

}

- (IBAction)trash {
	UIActionSheet *deleteActionSheet = [[[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Selected" otherButtonTitles:nil] autorelease];
	deleteActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[deleteActionSheet showInView:self.view];
}

- (IBAction)showActionSheet {
	NSLog(@"Starting upload...");
	/*
	DoublePhoto *dp = self.currentDoublePhoto;
	NSString *filePrefix = dp.filePrefix;
	[dp loadJPEGData];
	 */
	UploadViewController *uploadView = [[[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil] autorelease];
	uploadView.toUpload = self.currentDoublePhoto;
	[self.navigationController pushViewController:uploadView animated:YES];
	//uploadView.sideAImageView.image = self.currentDoublePhoto.frontThumbnailImage;
	//uploadView.sideBImageView.image = self.currentDoublePhoto.backThumbnailImage;

}

#pragma mark -
#pragma mark Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return (![touch.view isKindOfClass:[UIButton class]] && ![touch.view.superview isKindOfClass:[UIToolbar class]] && ![touch.view isKindOfClass:[UIToolbar class]] );
}

- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer {
	NSUInteger direction;
	if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) direction = UIViewAnimationOptionTransitionFlipFromRight;
	else direction = UIViewAnimationOptionTransitionFlipFromLeft;
	
	NSInteger dpIndex = [orderedPhotoKeys indexOfObject:self.currentDoublePhoto.filePrefix];
	if([backImageView isHidden]) {
		if(recognizer.direction == UISwipeGestureRecognizerDirectionRight && dpIndex > 0) {
			[backImageView setHidden:NO];
			[frontImageView setHidden:YES];
			[self previousPhoto];
		}
		else {
			[UIView transitionFromView:frontImageView toView:backImageView duration:0.6 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:^(BOOL b) { [self updateImageViews]; } ];
		}
	}
	else { 
		if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft && dpIndex+1 < [self.orderedPhotoKeys count]) {
			[backImageView setHidden:YES];
			[frontImageView setHidden:NO];
			[self nextPhoto];
		}
		else {
			[UIView transitionFromView:backImageView toView:frontImageView duration:0.6 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:^(BOOL b) { [self updateImageViews]; }];
		}
	}
}

- (void)toggleToolbars {
	if(mainToolbar.hidden == YES)	[self showToolbars];
	else							[self hideToolbars];
}
- (void)hideToolbars {
	if(mainToolbar.hidden == NO) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		[UIView animateWithDuration:0.4 animations:^{
			mainToolbar.alpha = 0;
			self.navigationController.navigationBar.alpha = 0;
		} completion:^(BOOL b){
			mainToolbar.hidden = YES;
			self.navigationController.navigationBar.hidden = YES;
		}];
	}
}

- (void)showToolbars {
	if(mainToolbar.hidden == YES) {
		mainToolbar.hidden = NO;
		self.navigationController.navigationBar.hidden = NO;
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		[UIView animateWithDuration:0.4 animations:^{
			mainToolbar.alpha = 1;
			self.navigationController.navigationBar.alpha = 1;
		} completion:^(BOOL b) { }];
	}
}

#pragma -
#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet.title == @"Are you sure?") {
		switch (buttonIndex) {
			case 0: {
				// Delete
				NSInteger currentIndex = [self.orderedPhotoKeys indexOfObject:self.currentDoublePhoto.filePrefix];
				[self.doublePhotos removeObjectForKey:self.currentDoublePhoto.filePrefix];
				[self.orderedPhotoKeys removeObject:self.currentDoublePhoto.filePrefix];
				[self.currentDoublePhoto deleteFromDisk];
				if([self.orderedPhotoKeys count] > 0) {
					if(currentIndex > 0) {	// Go to the previous
						[self loadDoublePhoto:[self.doublePhotos objectForKey:[self.orderedPhotoKeys objectAtIndex:currentIndex-1]]];
					}
					else {	// Go to the next
						[self loadDoublePhoto:[self.doublePhotos objectForKey:[self.orderedPhotoKeys objectAtIndex:currentIndex]]];
					}
					[self updateImageViews];
				}
				else {
					[self.navigationController popViewControllerAnimated:YES];
				}
				
				break;
			}
			default: case 1:
				// Do nothing
				break;
		}			
	}
}

@end
