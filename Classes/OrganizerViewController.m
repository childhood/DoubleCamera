//
//  OrganizerViewController.m
//  DoubleCamera
//
//  Created by kronick on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OrganizerViewController.h"
#import "SlideReviewController.h"
#import "UIImageExtras.h"
#import "DoublePhoto.h"
#import "LoginViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIS3ObjectRequest.h"
#import "Utilities.h"

@implementation OrganizerViewController

@synthesize backScrollView, frontScrollView, selectedImages, checkImage, baseImageDirectory, mainToolbar, doublePhotos, orderedPhotoKeys;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.baseImageDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		self.doublePhotos = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
	// Ask user to log in if they haven't already
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"user_id"] == 0) {
		LoginViewController *loginView = [[[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil] autorelease];
		[self.navigationController pushViewController:loginView animated:YES];
	}
	
	[super viewWillAppear:animated];
	[self clearSelection];
	mode = OrganizerModeSelectOneToView;
	[self reloadThumbnails];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.wantsFullScreenLayout = YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	mode = OrganizerModeSelectOneToView;
	self.selectedImages = [NSMutableArray array];
	
	// Load icons
	self.checkImage = [UIImage imageNamed:@"check.png"];
	if(self.checkImage == nil) NSLog(@"Could not load check image file.");
	
	[self reloadThumbnails];
	
	frontScrollView.delegate = self;
	backScrollView.delegate = self;
	
	UISwipeGestureRecognizer *switchPhotoGestureRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipGesture:)] autorelease];
	switchPhotoGestureRight.delegate = self;
	[self.view addGestureRecognizer:switchPhotoGestureRight];
	UISwipeGestureRecognizer *switchPhotoGestureLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipGesture:)] autorelease];
	switchPhotoGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	switchPhotoGestureLeft.delegate = self;
	[self.view addGestureRecognizer:switchPhotoGestureLeft];
}

- (void)reloadThumbnails {
	// Remove subviews
	for(UIView *subview in [[[frontScrollView subviews] copy] autorelease]) {
		if([subview isKindOfClass:[UIButton class]])
			[subview removeFromSuperview];
	}
	for(UIView *subview in [[[backScrollView subviews] copy] autorelease]) {
		if([subview isKindOfClass:[UIButton class]])
			[subview removeFromSuperview];
	}	
	
	self.orderedPhotoKeys = [NSMutableArray array];
	
	// Load images from directory and add UIImage thumbnails
	NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:baseImageDirectory error:nil];
	
	// Make thumbnails for front and back
	NSMutableDictionary *newDoublePhotos = [NSMutableDictionary dictionary];
	for(NSString *filename in directoryContents) {
		if([filename hasSuffix:@"_front.jpg"]) {
			NSString *key = [filename substringToIndex:[filename rangeOfString:@"_front.jpg" options:NSBackwardsSearch].location];
			[orderedPhotoKeys addObject:key];
			if([doublePhotos objectForKey:key] == nil) {	// Don't create a new object if one already exists!
				DoublePhoto *newDoublePhoto = [[DoublePhoto alloc] initThumbnailsWithPath:baseImageDirectory andPrefix:key];
				[newDoublePhotos setObject:newDoublePhoto forKey:key];
				[newDoublePhoto release];
			}
			else {
				// Copy over the doublephoto object pointer from the old dictionary
				[newDoublePhotos setObject:[doublePhotos objectForKey:key] forKey:key];
			}
		}
	}
	
	[doublePhotos setDictionary:newDoublePhotos];
	

	// Sort the keys array
	[self.orderedPhotoKeys sortUsingComparator: ^(id obj1, id obj2) {
		
		if ([obj1 integerValue] > [obj2 integerValue]) {
			return (NSComparisonResult)NSOrderedDescending;
		}
		
		if ([obj1 integerValue] < [obj2 integerValue]) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		return (NSComparisonResult)NSOrderedSame;
	}];
	
	// Make buttons for each image
	int i=0;
	for(NSString* key in orderedPhotoKeys) {
		DoublePhoto *doublePhoto = (DoublePhoto *)[doublePhotos objectForKey:key];
		if(doublePhoto.frontThumbnailImage != nil && doublePhoto.backThumbnailImage != nil) {
			CGRect buttonFrame = CGRectMake((i%4) * 78 + 6, (int)(i/4)*78 + 4 + 64, 74, 74);
			UIButton *frontButton = [UIButton buttonWithType:UIButtonTypeCustom];
			frontButton.frame = buttonFrame;
			[frontButton setImage:doublePhoto.frontThumbnailImage forState:UIControlStateNormal];
			[frontButton setTitle:key forState:UIControlStateNormal];
			[frontButton addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
			[frontScrollView insertSubview:frontButton atIndex:0];
			
			UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
			backButton.frame = buttonFrame;
			[backButton setImage:doublePhoto.backThumbnailImage forState:UIControlStateNormal];
			[backButton setTitle:key forState:UIControlStateNormal];
			[backButton addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
			[backScrollView insertSubview:backButton atIndex:0];
			i++;
		}
		else {
			NSLog(@"Thumbnail images are nil.");
		}
	}
	
	// Set the scroll view sizes
	[frontScrollView setContentSize:CGSizeMake(320, (int)(doublePhotos.count/4 + 2) * 78 + 6 + 44)];
	[backScrollView setContentSize:CGSizeMake(320, (int)(doublePhotos.count/4 + 2) * 78 + 6 + 44)];
}


- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer {
	NSUInteger direction;
	if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) direction = UIViewAnimationOptionTransitionFlipFromRight;
	else direction = UIViewAnimationOptionTransitionFlipFromLeft;
	
	UIScrollView *thisView;
	UIScrollView *thatView;
	if([backScrollView isHidden]) {
		thisView = frontScrollView;
		thatView = backScrollView;
	}
	else {
		thisView = backScrollView;
		thatView = frontScrollView;
	}

	[UIView transitionFromView:thisView toView:thatView duration:0.6 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];						
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}


#pragma -
#pragma mark IBActions

- (IBAction)showActionSheet {
	UIActionSheet *organizerActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photos" otherButtonTitles:@"Upload Photos",@"Change User ID",nil];
	organizerActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[organizerActionSheet showInView:self.view];
	[organizerActionSheet release];
}

- (IBAction)imageTouched:(id)sender {
	UIButton *button = (UIButton *)sender;
	switch (mode) {
		case OrganizerModeSelectOneToView: {
			// Push slideshow view controller
			// Set slideshow image nubmer based on image selected
			SlideReviewController *slideController = [[[SlideReviewController alloc] initWithNibName:@"SlideView" bundle:nil] autorelease];
			slideController.orderedPhotoKeys = self.orderedPhotoKeys;
			slideController.basePath = self.baseImageDirectory;
			slideController.doublePhotos = self.doublePhotos;
			
			[slideController loadDoublePhoto:[doublePhotos objectForKey:button.currentTitle]];
			[[self navigationController] pushViewController:slideController animated:YES];
			break;
		}
		case OrganizerModeSelectToDelete:
		case OrganizerModeSelectToPrint:
		case OrganizerModeSelectToUpload:
			[self toggleSelection:button];
			break;			
		default:
			break;
	}
}

- (UIButton *)flipsideButton:(UIButton *)button {
	UIScrollView *otherSide = button.superview == frontScrollView ? backScrollView : frontScrollView;
	
	// Loop through subviews on otherSide, find the one with the same title as button
	for(int i=0; i<otherSide.subviews.count; i++) {
		if(((UIButton *)[otherSide.subviews objectAtIndex:i]).currentTitle == button.currentTitle)
			return (UIButton *) [otherSide.subviews objectAtIndex:i]; 
	}
	
	return nil;
}

- (BOOL)toggleSelection:(UIButton *)button {
	UIButton *otherButton = [self flipsideButton:button];
	if(!button.selected) {
		[self addCheck:button];
		[self addCheck:otherButton];
		[selectedImages addObject:button.currentTitle];
		[self updateNavbarTitle];
		return YES;
	}
	else {
		[self removeCheck:button];
		[self removeCheck:otherButton];
		[selectedImages removeObject:button.currentTitle];
		[self updateNavbarTitle];
		return NO;
	}
}

- (void)addCheck:(UIButton *)button {
	button.selected = YES;
	NSInteger checkSize = [checkImage size].width;
	CGRect checkFrame = CGRectMake(button.frame.size.width-checkSize,button.frame.size.height-checkSize, checkSize, checkSize);
	UIImageView *checkView = [[UIImageView alloc] initWithImage:checkImage];
	checkView.frame = checkFrame;
	checkView.tag = CHECK_ICON_TAG;
	[button addSubview:checkView];
	[checkView release];	
}

- (void)removeCheck:(UIButton *)button {
	button.selected = NO;
	[[button viewWithTag:CHECK_ICON_TAG] removeFromSuperview];
}

- (void)clearSelection {
	[selectedImages removeAllObjects];
	// Loop through UIButtons, remove all checks
	void (^removeAllChecks)(UIScrollView *) = ^(UIScrollView *scrollView) {
		UIButton *_button;
		for(int i=0; i<scrollView.subviews.count; i++) {
			if([[scrollView.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]) {
				_button = (UIButton *)[scrollView.subviews objectAtIndex:i];
				[self removeCheck:_button];
			}
		}
	};
	removeAllChecks(frontScrollView);
	removeAllChecks(backScrollView);
	
	[self updateNavbarTitle];
}

- (void)doneWithSelection {
	switch (mode) {
		case OrganizerModeSelectToDelete: {
			UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Selected" otherButtonTitles:nil];
			deleteActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
			[deleteActionSheet showInView:self.view];
			[deleteActionSheet release];
			break;
		}
		case OrganizerModeSelectToUpload: {
			NSLog(@"Starting upload...");
			for(NSString *filePrefix in selectedImages) {
				DoublePhoto *dp = (DoublePhoto*)[self.doublePhotos objectForKey:filePrefix];

				// Upload back photo to S3
				// -----------------------
				__block ASIS3ObjectRequest *backRequest = [ASIS3ObjectRequest PUTRequestForFile:[dp backImagePath]
																		 withBucket:@"doublecamera"
																				key:[NSString stringWithFormat:@"photos/%@%@-back-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix]];
				
				backRequest.shouldStreamPostDataFromDisk = YES;
				[backRequest setAccessPolicy:@"public-read"];
				[backRequest setDelegate:self];
				
				[backRequest setCompletionBlock:^{
					// Upload front photo to S3
					// ------------------------
					__block ASIS3ObjectRequest *frontRequest = [ASIS3ObjectRequest PUTRequestForFile:[dp frontImagePath]
																						 withBucket:@"doublecamera"
																								key:[NSString stringWithFormat:@"photos/%@%@-front-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix]];
					
					NSLog(@"photos/%@%@-front-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix);
					frontRequest.shouldStreamPostDataFromDisk = YES;
					[frontRequest setAccessPolicy:@"public-read"];
					[frontRequest setDelegate:self];
					[frontRequest setCompletionBlock:^{
						// Make a POST request to the script that inserts a new record in the database
						// ---------------------------------------------------------------------------
						NSURL *url = [NSURL URLWithString:@"http://benjaminlotan.com/doublecamera/newphoto.php"];
						__block ASIFormDataRequest *insertRequest= [ASIFormDataRequest requestWithURL:url];
						//[insertRequest addPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"] forKey:@"user-id"];
						[insertRequest addPostValue:filePrefix forKey:@"photo-id"];
						[insertRequest addPostValue:@"kronick" forKey:@"username"];
						[insertRequest addPostValue:[Utilities MD5:@"123f"] forKey:@"password"];
						[insertRequest addPostValue:[NSString stringWithFormat:@"http://doublecamera.s3.amazonaws.com/photos/%@%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix] forKey:@"url-base"];
						[insertRequest addPostValue:@"" forKey:@"date-taken"];
						[insertRequest addPostValue:@"" forKey:@"caption-front"];
						[insertRequest addPostValue:@"" forKey:@"caption-back"];
						
						[insertRequest setDelegate:self];
						[insertRequest setCompletionBlock:^{
							NSString *responseString = [insertRequest responseString];
							NSLog(@"%@",responseString);
							
							UIAlertView *completeAlert = [[UIAlertView alloc] initWithTitle: @"Upload complete" message: @"Your photos have been uploaded." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
							[completeAlert show];
							[completeAlert release];							
						}];
						
						[insertRequest startAsynchronous];						
					}];
					[frontRequest setFailedBlock: ^{
						NSLog(@"Front upload failed: %@", [frontRequest error]);
					}];
					
					[frontRequest startAsynchronous];
				}];
				[backRequest setFailedBlock: ^{
					NSLog(@"Back upload failed: %@", [backRequest error]);
				}];
				
				[backRequest startAsynchronous];
			}

			[self updateMode:OrganizerModeSelectOneToView];
		}
		default:
			break;
	}	
}

- (void)requestFinished:(ASIHTTPRequest *)request {

}
- (void)requestFailed:(ASIHTTPRequest *)request {
	UIAlertView *completeAlert = [[UIAlertView alloc] initWithTitle: @"Could not connect" message: [NSString stringWithFormat:@"%@", [request error]] delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	NSLog(@"%@", [request error]);
	[completeAlert show];
	[completeAlert release];		
}

- (void)deleteSelectedPhotos {
	for(NSString *filePrefix in selectedImages) {
		NSInteger del = [((DoublePhoto*)[self.doublePhotos objectForKey:filePrefix]) deleteFromDisk];
		NSLog(@"Deleted %i files.", del);
		//NSLog(@"Deleting %@", [baseImageDirectory stringByAppendingFormat:@"/%@_front.jpg",filePrefix]);
		//[[NSFileManager defaultManager] removeItemAtPath:[baseImageDirectory stringByAppendingFormat:@"/%@_front.jpg",filePrefix] error:nil];
		//[[NSFileManager defaultManager] removeItemAtPath:[baseImageDirectory stringByAppendingFormat:@"/%@_back.jpg",filePrefix] error:nil];
	}
}

#pragma -
#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet.title == @"Are you sure?") {
		switch (buttonIndex) {
			case 0:
				// Delete
				[self deleteSelectedPhotos];
				[self reloadThumbnails];
				[self updateMode:OrganizerModeSelectOneToView];
				break;
			default: case 1:
				[self updateMode:OrganizerModeSelectOneToView];
				break;
		}			
	}
	else {
		[self.selectedImages removeAllObjects];	// Clear the selected images array
		switch (buttonIndex) {
			case 0:
				[self updateMode:OrganizerModeSelectToDelete];
				break;
			case 1:
				[self updateMode:OrganizerModeSelectToUpload];
				break;
			case 2: {
				//[self updateMode:OrganizerModeSelectToPrint];
				LoginViewController *loginView = [[[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil] autorelease];
				[self.navigationController pushViewController:loginView animated:YES];
				break;
			}
			default: case 3:
				[self updateMode:OrganizerModeSelectOneToView];
				break;
		}
	}
}


- (void)updateMode:(OrganizerMode)newMode {
	if(mode != newMode) {
		mode = newMode;
		[self updateNavbarTitle];
		switch (mode) {
			case OrganizerModeSelectOneToView:
				// Reset
				self.navigationItem.leftBarButtonItem = nil;
				self.navigationItem.rightBarButtonItem = nil;
				[self clearSelection];
				[self showToolbar];
				break;
			case OrganizerModeSelectToUpload: {
				UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(resetToolbars)];
				self.navigationItem.leftBarButtonItem = leftBarButton;
				UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithSelection)];
				self.navigationItem.rightBarButtonItem = rightBarButton;				
				[self hideToolbar];
				break;
			}
			case OrganizerModeSelectToPrint: {
				UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(resetToolbars)];
				self.navigationItem.leftBarButtonItem = leftBarButton;
				UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithSelection)];
				self.navigationItem.rightBarButtonItem = rightBarButton;				
				[self hideToolbar];
				break;				
			}
			case OrganizerModeSelectToDelete: {
				UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(resetToolbars)];
				self.navigationItem.leftBarButtonItem = leftBarButton;
				UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithSelection)];
				self.navigationItem.rightBarButtonItem = rightBarButton;				
				[self hideToolbar];
				break;				
			}
			default:
				break;
		}
	}
}

- (void)resetToolbars {
	[self updateMode:OrganizerModeSelectOneToView];
}

- (void)hideToolbar {
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

- (void)showToolbar {
	if(mainToolbar.hidden == YES) {
		mainToolbar.hidden = NO;
		[UIView animateWithDuration:0.4 animations:^{
			CGRect frame = mainToolbar.frame;
			frame.origin.y -= 44;
			mainToolbar.frame = frame;
		}];
	}
}

- (void)updateNavbarTitle {
	if(mode != OrganizerModeSelectOneToView) {
		NSLog(@"Updating title: %i", [selectedImages count]);
		self.navigationItem.title = [NSString stringWithFormat:@"%i Selected", [selectedImages count]];
	}
	else {
		self.navigationItem.title = @"Double Album";
	}
}


#pragma -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// Syncrhonize front and back scroll views whenever one moves.
	UIScrollView *otherScrollView = scrollView == frontScrollView ? backScrollView : frontScrollView;
	[otherScrollView setContentOffset:[scrollView contentOffset]];
}


#pragma -

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

	checkImage = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.doublePhotos = nil;
    [super dealloc];
}


@end
