//
//  DoubleCameraViewController.h
//  DoubleCamera
//
//  Created by kronick on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "ReviewPhotoViewController.h"
#import "OrganizerViewController.h"

@interface DoubleCameraViewController : UIViewController <UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
	UIImageView *frontImageView;
	UIImageView *backImageView;
	
	ReviewPhotoViewController *reviewController;
	OrganizerViewController *organizerController;
	
	NSTimer *slideTimer;
}

@property (nonatomic, retain) ReviewPhotoViewController *reviewController;
@property (nonatomic, retain) OrganizerViewController *organizerController;

@property (nonatomic, retain) NSTimer *slideTimer;

@property (nonatomic, retain) IBOutlet UIImageView *frontImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) IBOutlet UIToolbar *mainToolbar;

- (IBAction)launchCameraAction:(id)sender;
- (IBAction)flipImage;
- (IBAction)launchOrganizer;

- (void)toggleToolbars;
- (void)hideToolbars;
- (void)showToolbars;
- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

- (void)flipImage:(UIViewAnimationOptions)direction;
- (void)updateSlides:(NSTimer *)timer;

- (void)writeToConfig:(NSString *)value forKey:(NSString *)key;
- (NSMutableDictionary *)readConfiguration;

@end

