//
//  SlideReviewController.h
//  DoubleCamera
//
//  Created by kronick on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoublePhoto.h"


@interface SlideReviewController : UIViewController <UIGestureRecognizerDelegate> {
	IBOutlet UIImageView *frontImageView;
	IBOutlet UIImageView *backImageView;
	IBOutlet UIActivityIndicatorView *loadingView;
	
	DoublePhoto *currentDoublePhoto;
	DoublePhoto *nextDoublePhoto;
	DoublePhoto *prevDoublePhoto;
	
	NSDictionary *doublePhotos;
	NSArray		*orderedPhotoKeys;
	
	NSString	*basePath;
	
	BOOL nextDoneLoading;
	BOOL prevDoneLoading;
	BOOL updateNextRightAway;
	BOOL updatePrevRightAway;
}

@property (nonatomic, retain) IBOutlet UIImageView *frontImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) IBOutlet UIToolbar *mainToolbar;

@property (nonatomic, retain) DoublePhoto *currentDoublePhoto;
@property (nonatomic, retain) NSDictionary *doublePhotos;
@property (nonatomic, retain) DoublePhoto *nextDoublePhoto;
@property (nonatomic, retain) DoublePhoto *prevDoublePhoto;

@property (nonatomic, retain) NSArray *orderedPhotoKeys;

@property (nonatomic, retain) NSString *basePath;

- (void)loadDoublePhoto:(DoublePhoto *)dp;
- (void)updateImageViews;

- (void)toggleToolbars;
- (void)hideToolbars;
- (void)showToolbars;
- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

- (IBAction)nextPhoto;
- (IBAction)previousPhoto;
- (IBAction)startSlideshow;
- (IBAction)trash;
- (IBAction)showActionSheet;

@end
