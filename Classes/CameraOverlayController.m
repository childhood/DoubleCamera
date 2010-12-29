    //
//  CameraOverlayController.m
//  DoubleCamera
//
//  Created by kronick on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraOverlayController.h"


@implementation CameraOverlayController

@synthesize takePictureButton, cancelButton, frontView, backView, delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)startFrontCaptureSession {
	NSLog(@"Finding capture devices...");
	NSArray *devices = [AVCaptureDevice devices];
	AVCaptureDevice *frontCameraDevice = nil;
	AVCaptureDevice *backCameraDevice = nil;
	for(AVCaptureDevice *device in devices) {
		if(device.position == AVCaptureDevicePositionFront) {
			frontCameraDevice = device;
			NSLog(@"Found front camera device");
		}
		if(device.position == AVCaptureDevicePositionBack) {
			backCameraDevice = device;
			NSLog(@"Found back camera device");
		}		
		
	}		
	
	if(frontCameraDeviceInput == nil)
		frontCameraDeviceInput = [[AVCaptureDeviceInput deviceInputWithDevice:frontCameraDevice error:nil] retain];
	if(backCameraDeviceInput == nil)
		backCameraDeviceInput = [[AVCaptureDeviceInput deviceInputWithDevice:backCameraDevice error:nil] retain];

	NSLog(@"Initiating camera session...");
	if(cameraCaptureSession == nil) {
		cameraOutput =  [[AVCaptureStillImageOutput alloc] init];
		cameraCaptureSession = [[AVCaptureSession alloc] init];
		[cameraCaptureSession beginConfiguration];
		[cameraCaptureSession addInput:backCameraDeviceInput];
		[cameraCaptureSession addOutput:cameraOutput];
		cameraCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
		[cameraCaptureSession commitConfiguration];
	}
	else {
		NSLog(@"Camera capture session already set up");
	}
	
	
	// Reset the input device every time
	[cameraCaptureSession beginConfiguration];
	for(AVCaptureDeviceInput *inp in cameraCaptureSession.inputs) {
		[cameraCaptureSession removeInput:inp];
	}
	[cameraCaptureSession addInput:backCameraDeviceInput];	// Back camera first!
	[cameraCaptureSession commitConfiguration];	
	
	if(![cameraCaptureSession isRunning]) {
		[cameraCaptureSession startRunning];
		NSLog(@"Camera capture session running.");		
	}
	
	// Initialize the preview layer
	if(cameraPreviewLayer == nil) {
		NSLog(@"Initializing preview layers...");
		CALayer *viewPreviewLayer = self.backView.layer;
		cameraPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:cameraCaptureSession];
		cameraPreviewLayer.frame = self.backView.bounds;
		cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		[viewPreviewLayer addSublayer:cameraPreviewLayer];
	}

}


- (IBAction)takePhoto:(id)sender {
	NSLog(@"Attempting front camera photo capture...");
	[cameraOutput captureStillImageAsynchronouslyFromConnection:[cameraOutput.connections objectAtIndex:0] completionHandler:
	 ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
		 NSLog(@"Image data received in completionHandler block");		 
		 // Convert CMSampleBufferRef into UIImage
		 if (self.delegate)
			 [self.delegate didTakePicture:imageFromSampleBuffer(imageSampleBuffer)];
		 
		 [self takeAnotherPhoto];		 
	 }];

	
}

- (void)takeAnotherPhoto {
	NSLog(@"Switching cameras...");
	[self switchView:nil];
	NSLog(@"Taking photo from back facing camera...");
	[cameraOutput captureStillImageAsynchronouslyFromConnection:[cameraOutput.connections objectAtIndex:0] completionHandler:
	 ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
		 NSLog(@"Image data received in completionHandler block");
		 // Convert CMSampleBufferRef into UIImage
		 if (self.delegate)
			 [self.delegate didTakePicture:imageFromSampleBuffer(imageSampleBuffer)];
		 
		 [self.delegate didFinishWithCamera];
	 }];	
}

- (IBAction)cancel:(id)sender {
	if(self.delegate)
		[self.delegate didFinishWithCamera];
}

- (IBAction)switchView:(id)sender {
	AVCaptureDeviceInput *inputToAdd;
	if([cameraCaptureSession.inputs containsObject:backCameraDeviceInput])
		inputToAdd = frontCameraDeviceInput;
	else
		inputToAdd = backCameraDeviceInput;

	[cameraCaptureSession beginConfiguration];
	for(AVCaptureDeviceInput *inp in cameraCaptureSession.inputs) {
		[cameraCaptureSession removeInput:inp];
	}
	[cameraCaptureSession addInput:inputToAdd];	// Back camera first!
	if(inputToAdd == backCameraDeviceInput)
		cameraCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;	// AVCaptureSessionPresetPhoto
	else
		cameraCaptureSession.sessionPreset = AVCaptureSessionPreset640x480; 
	[cameraCaptureSession commitConfiguration];	
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
	NSLog(@"Memory warning!");
}

- (void)viewDidUnload {
    [super viewDidUnload];
	NSLog(@"Stopping capture sessions...");
	if(cameraCaptureSession != nil) {
		if([cameraCaptureSession isRunning]) {
			[cameraCaptureSession stopRunning];
		}
		[cameraCaptureSession release];
	}
	if(cameraCaptureSession != nil) {
		if([cameraCaptureSession isRunning]) {
			[cameraCaptureSession stopRunning];
		}
		[cameraCaptureSession release];
	}	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"Deallocing CamOverlayController");
	cameraCaptureSession = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Utilities

UIImage *imageFromSampleBuffer(CMSampleBufferRef sampleBuffer) {
	NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
	UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];	
	
    return image;
}


@end
