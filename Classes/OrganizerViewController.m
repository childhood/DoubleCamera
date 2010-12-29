//
//  OrganizerViewController.m
//  DoubleCamera
//
//  Created by kronick on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OrganizerViewController.h"
#import "UIImageExtras.h"

@implementation OrganizerViewController

@synthesize backScrollView, frontScrollView, selectedImages, baseImageDirectory, mainToolbar;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.baseImageDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self clearSelection];
	mode = OrganizerModeSelectOneToView;
	[self reloadThumbnails];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	mode = OrganizerModeSelectOneToView;
	self.selectedImages = [NSMutableArray array];
	
	// Load icons
	checkImage = [[UIImage imageNamed:@"check.png"] retain];
	if(checkImage == nil) NSLog(@"Could not load check image file.");
	
	frontThumbs = [[NSMutableDictionary dictionary] retain];
	backThumbs = [[NSMutableDictionary dictionary] retain];
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
	for(UIView *subview in frontScrollView.subviews) {
		[subview removeFromSuperview];
	}
	for(UIView *subview in backScrollView.subviews) {
		[subview removeFromSuperview];
	}	
	
	// Load images from directory and add UIImage thumbnails
	NSLog(@"Getting directroy contents for %@", baseImageDirectory);
	NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:baseImageDirectory error:nil];
	NSLog(@"Directory contents retrieved.");
	
	// Make thumbnails for front and back
	NSMutableDictionary *newFrontThumbs = [NSMutableDictionary dictionary];
	NSMutableDictionary *newBackThumbs = [NSMutableDictionary dictionary];
	for(NSString *filename in directoryContents) {
		NSString *key;
		NSMutableDictionary *oldThumbDictionary;
		NSMutableDictionary *newThumbDictionary;
		if([filename hasSuffix:@"_front.jpg"]) {
			key = [filename substringToIndex:[filename rangeOfString:@"_front.jpg" options:NSBackwardsSearch].location];
			oldThumbDictionary = frontThumbs;
			newThumbDictionary = newFrontThumbs;
		}
		else if([filename hasSuffix:@"_back.jpg"]) {
			key = [filename substringToIndex:[filename rangeOfString:@"_back.jpg" options:NSBackwardsSearch].location];
			oldThumbDictionary = backThumbs;
			newThumbDictionary = newBackThumbs;
		}
		
		if([oldThumbDictionary objectForKey:key] == nil) {	// Don't create a new UIImage thumbnail if it already exists!
			NSString *imagePath =  [baseImageDirectory stringByAppendingFormat:@"/%@",filename];
			UIImage *thumbImage = [[UIImage imageWithContentsOfFile:imagePath] imageByScalingAndCroppingForSize: CGSizeMake(148,148)];
			[newThumbDictionary setObject:thumbImage forKey:key];
			NSLog(@"Added new key: %@", key);
		}
		else {
			[newThumbDictionary setObject:[oldThumbDictionary objectForKey:key] forKey:key];
		}
	}
	
	[frontThumbs setDictionary:newFrontThumbs];
	[backThumbs setDictionary:newBackThumbs];
	
	// Make buttons for each image
	int i=0;
	for(NSString* key in frontThumbs) {
		if([backThumbs objectForKey:key] != nil) {		// Make sure there's a matching back
			CGRect buttonFrame = CGRectMake((i%4) * 78 + 6, (int)(i/4)*78 + 6, 74, 74);
			UIButton *frontButton = [UIButton buttonWithType:UIButtonTypeCustom];
			frontButton.frame = buttonFrame;
			[frontButton setImage:(UIImage*)[frontThumbs objectForKey:key] forState:UIControlStateNormal];
			[frontButton setTitle:key forState:UIControlStateNormal];
			[frontButton addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
			[frontScrollView addSubview:frontButton];
			
			UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
			backButton.frame = buttonFrame;
			[backButton setImage:(UIImage*)[backThumbs objectForKey:key] forState:UIControlStateNormal];
			[backButton setTitle:key forState:UIControlStateNormal];
			[backButton addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
			[backScrollView addSubview:backButton];
			i++;
		}
	}
	
	[frontScrollView setContentSize:CGSizeMake(320,  (int)(frontThumbs.count/4 + 1) * 78 + 6)];
	[backScrollView setContentSize:CGSizeMake(320,  (int)(frontThumbs.count/4 + 1) * 78 + 6)];
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

	[UIView transitionFromView:thisView toView:thatView duration:0.4 options:UIViewAnimationOptionShowHideTransitionViews | direction completion:nil];						
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}


#pragma -
#pragma mark IBActions

- (IBAction)showActionSheet {
	UIActionSheet *organizerActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photos" otherButtonTitles:@"Upload Photos",@"Order Prints",nil];
	organizerActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[organizerActionSheet showInView:self.view];
	[organizerActionSheet release];
}

- (IBAction)imageTouched:(id)sender {
	UIButton *button = (UIButton *)sender;
	switch (mode) {
		case OrganizerModeSelectOneToView:
			// Push slideshow view controller
			// Set slideshow image nubmer based on image selected
			break;
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
		default:
			break;
	}	
}

- (void)deleteSelectedPhotos {
	for(NSString *filePrefix in selectedImages) {
		NSLog(@"Deleting %@", [baseImageDirectory stringByAppendingFormat:@"/%@_front.jpg",filePrefix]);
		[[NSFileManager defaultManager] removeItemAtPath:[baseImageDirectory stringByAppendingFormat:@"/%@_front.jpg",filePrefix] error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:[baseImageDirectory stringByAppendingFormat:@"/%@_back.jpg",filePrefix] error:nil];
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
			case 2:
				[self updateMode:OrganizerModeSelectToPrint];
				break;
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
	[backThumbs release];
	[frontThumbs release];
	NSLog(@"Cleared thumbnails.");
	[checkImage release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
