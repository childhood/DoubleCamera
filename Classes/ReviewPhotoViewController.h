//
//  ReviewPhotoViewController.h
//  DoubleCamera
//
//  Created by kronick on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraOverlayController.h"
#import "ImagePickerOverlayController.h"
#import "DoublePhoto.h"
#import "OrganizerViewController.h"

@interface ReviewPhotoViewController : UIViewController <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	UIImageView *frontImageView;
	UIImageView *backImageView;
	
	NSMutableDictionary *capturedImages;
	
	NSUserDefaults *userDefaults;

	DoublePhoto *capturedDoublePhoto;
	
	UIImagePickerController *imagePickerController;
	ImagePickerOverlayController *imagePickerOverlay;

	OrganizerViewController *organizerController;
	
	NSTimer *secondPictureTimer;
	
	UIView *processingView;
	
	BOOL firstLaunch;
	BOOL justTookPicture;
}
@property (nonatomic, retain) ImagePickerOverlayController *imagePickerOverlay;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

@property (nonatomic, retain) OrganizerViewController *organizerController;

@property (nonatomic, retain) NSMutableDictionary *capturedImages;
@property (nonatomic, retain) NSUserDefaults *userDefaults;

@property (nonatomic, retain) DoublePhoto *capturedDoublePhoto;

@property (nonatomic, retain) IBOutlet UIImageView *frontImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backImageView;
@property (nonatomic, retain) IBOutlet UIToolbar *mainToolbar;

@property (nonatomic, retain) IBOutlet UIView *processingView;

@property (nonatomic,retain)NSTimer *secondPictureTimer;

- (IBAction)save;
- (IBAction)trash;
- (void)saveFiles;

- (void)launchCamera;

- (void)toggleToolbars;
- (void)hideToolbars;
- (void)showToolbars;
- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

- (void)tryAnotherPicture:(NSTimer *)theTimer;
- (void)startSecondPictureTimer;
- (void)stopSecondPictureTimer;


@end
