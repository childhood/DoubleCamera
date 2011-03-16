//
//  ImagePickerOverlayController.m
//  DoubleCamera
//
//  Created by kronick on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImagePickerOverlayController.h"
#import "OrganizerViewController.h"

@implementation ImagePickerOverlayController

@synthesize picker;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		//CGRect  rect = [[UIScreen mainScreen] bounds];
		//[self.view setFrame:rect];
    }
    return self;
}

	
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)setupOverlayForPicker:(UIImagePickerController *)_picker {
	self.picker = _picker;
	if (self.picker.cameraOverlayView != self.view) {
		CGRect overlayViewFrame = self.picker.cameraOverlayView.frame;
		CGRect newFrame = CGRectMake(0.0,
									 CGRectGetHeight(overlayViewFrame) -
									 self.view.frame.size.height - 9.0,
									 CGRectGetWidth(overlayViewFrame),
									 self.view.frame.size.height + 9.0);
		self.view.frame = newFrame;
		self.picker.cameraOverlayView = self.view;
	}
}

- (IBAction)flip {
	NSLog(@"device before: %i", picker.cameraDevice);
	picker.cameraDevice = picker.cameraDevice == UIImagePickerControllerCameraDeviceRear ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
	NSLog(@"device after: %i", picker.cameraDevice);
	//picker.cameraDevice = picker.cameraDevice == UIImagePickerControllerCameraDeviceRear ? UIImagePickerControllerCameraDeviceFront
	//												  									 : UIImagePickerControllerCameraDeviceRear;
}

- (IBAction)cancel {
	[self.picker.delegate imagePickerController:self.picker didFinishPickingMediaWithInfo:nil];
}

- (IBAction)trigger {
	//if(picker.cameraDevice == UIImagePickerControllerCameraDeviceRear)
		[self.picker takePicture];
	//else {
	//	[self flip];
	//	[self performSelector:@selector(trigger) withObject:nil afterDelay:2];
	//}
}

- (IBAction)launchOrganizer {
	[self.picker.delegate imagePickerControllerDidCancel:self.picker];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
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


@end
