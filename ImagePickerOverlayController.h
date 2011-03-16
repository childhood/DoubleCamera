//
//  ImagePickerOverlayController.h
//  DoubleCamera
//
//  Created by kronick on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImagePickerOverlayController : UIViewController {
	UIImagePickerController *picker;

}

@property (nonatomic,retain)UIImagePickerController *picker;

- (void)setupOverlayForPicker:(UIImagePickerController *)picker;

- (IBAction)flip;
- (IBAction)trigger;
- (IBAction)cancel;

- (IBAction)launchOrganizer;


@end
