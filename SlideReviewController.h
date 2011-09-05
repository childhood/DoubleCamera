//
//  SlideReviewController.h
//  DoubleCamera
//
//  Created by kronick on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoublePhoto.h"


@interface SlideReviewController : UIViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
	IBOutlet UIImageView *frontImageView;
	IBOutlet UIImageView *backImageView;
	UIActivityIndicatorView *loadingView;
    UIButton *linkButton;
    UIButton *uploadButton;
    UIBarButtonItem *actionButton;
	
	DoublePhoto *currentDoublePhoto;
	DoublePhoto *nextDoublePhoto;
	DoublePhoto *prevDoublePhoto;
	
	NSMutableDictionary *doublePhotos;
	NSMutableArray		*orderedPhotoKeys;
	
	NSString	*basePath;
	
	BOOL nextDoneLoading;
	BOOL prevDoneLoading;
	BOOL updateNextRightAway;
	BOOL updatePrevRightAway;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, retain) IBOutlet UIImageView *frontImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backImageView;
@property (nonatomic, retain) IBOutlet UIToolbar *mainToolbar;
@property (nonatomic, retain) UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) UIButton *linkButton;
@property (nonatomic, retain) UIButton *uploadButton;


@property (nonatomic, retain) DoublePhoto *currentDoublePhoto;
@property (nonatomic, retain) NSMutableDictionary *doublePhotos;
@property (nonatomic, retain) DoublePhoto *nextDoublePhoto;
@property (nonatomic, retain) DoublePhoto *prevDoublePhoto;

@property (nonatomic, retain) NSMutableArray *orderedPhotoKeys;

@property (nonatomic, retain) NSString *basePath;

- (void)loadDoublePhoto:(DoublePhoto *)dp;
- (void)updateImageViews;


- (void)reloadKeys;
- (void)toggleToolbars;
- (void)hideToolbars;
- (void)showToolbars;
- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

- (void)hideLinkButton;
- (void)showLinkButton;

- (IBAction)copyLink;
- (IBAction)nextPhoto;
- (IBAction)previousPhoto;
- (IBAction)startSlideshow;
- (IBAction)trash;
- (IBAction)showActionSheet;

@end
