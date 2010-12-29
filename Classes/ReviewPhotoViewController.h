//
//  ReviewPhotoViewController.h
//  DoubleCamera
//
//  Created by kronick on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraOverlayController.h"


@interface ReviewPhotoViewController : UIViewController <CameraOverlayDelegate, UIGestureRecognizerDelegate> {
	UIImageView *frontImageView;
	UIImageView *backImageView;
	
	NSMutableArray *capturedImages;
	
	NSUserDefaults *userDefaults;
	
	CameraOverlayController *cameraController;
}
@property (nonatomic,retain) CameraOverlayController *cameraController;

@property (nonatomic, retain) NSMutableArray *capturedImages;
@property (nonatomic, retain) NSUserDefaults *userDefaults;

@property (nonatomic, retain) IBOutlet UIImageView *frontImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backImageView;
@property (nonatomic, retain) IBOutlet UIToolbar *mainToolbar;

- (IBAction)save;
- (IBAction)trash;

- (void)launchCamera;

- (void)toggleToolbars;
- (void)hideToolbars;
- (void)showToolbars;
- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;


@end
