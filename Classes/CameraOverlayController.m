    //
//  CameraOverlayController.m
//  DoubleCamera
//
//  Created by kronick on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraOverlayController.h"
#import "DoublePhoto.h"

@implementation CameraOverlayController

@synthesize takePictureButton, cancelButton, frontView, backView, cameraPreviewLayer, activityIndicator, delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicator.frame = CGRectMake(0,0,40,40);
	activityIndicator.center = self.view.center;
	[self.view addSubview:activityIndicator];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

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
		cameraCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
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
	cameraCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
	[cameraCaptureSession commitConfiguration];	
	
	if(![cameraCaptureSession isRunning]) {
		[cameraCaptureSession startRunning];
		NSLog(@"Camera capture session running.");		
	}
	
	// Initialize the preview layer
	if(self.cameraPreviewLayer == nil) {
		NSLog(@"Initializing preview layers...");
		CALayer *viewPreviewLayer = self.backView.layer;
		//for(int i=0; i<self.backView.layer.sublayers.count; i++) {
		//	[[self.backView.layer.sublayers objectAtIndex:i] removeFromSuperlayer];
		//}
		self.cameraPreviewLayer = [[[AVCaptureVideoPreviewLayer alloc] initWithSession:cameraCaptureSession] autorelease];
		self.cameraPreviewLayer.frame = self.backView.bounds;
		self.cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		[viewPreviewLayer addSublayer:self.cameraPreviewLayer];
	}

}


- (IBAction)takePhoto:(id)sender {
	NSLog(@"Attempting front camera photo capture...");
	[cameraOutput captureStillImageAsynchronouslyFromConnection:[cameraOutput.connections objectAtIndex:0] completionHandler:
	 ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
		 readyForNext = YES;
		 NSLog(@"Image data received in completionHandler block");		 
		 // Convert CMSampleBufferRef into UIImage
		 NSLog(@"%i", [UIDevice currentDevice].orientation);
		 [self.delegate didTakePicture:[self imageDataFromSampleBuffer:imageSampleBuffer orientation:[UIDevice currentDevice].orientation mirrored:NO]];
	 }];
	
	// Set a timer to wait until the camera is ready to take another picture
	// *** This is a big hack! Changing cameras sometimes causes the app to freeze if it is called from the completionHandler
	//		block above. Calling it this way seems to be the best work around...
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(readyForNext:) userInfo:nil repeats:YES];
}

- (void)readyForNext:(NSTimer *)theTimer {
	if(readyForNext) {
		[self takeAnotherPhoto];	
		[theTimer invalidate];
		readyForNext = NO;
	}
}

- (void)takeAnotherPhoto {
	NSLog(@"Switching cameras...");
	[self switchView:nil];
	NSLog(@"Taking photo from back facing camera...");
	[cameraOutput captureStillImageAsynchronouslyFromConnection:[cameraOutput.connections objectAtIndex:0] completionHandler:
	 ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
		 NSLog(@"Image data received in completionHandler block");
		 // Convert CMSampleBufferRef into UIImage
		 NSLog(@"%i", [UIDevice currentDevice].orientation);
		 [self.delegate didTakePicture:[self imageDataFromSampleBuffer:imageSampleBuffer orientation:[UIDevice currentDevice].orientation mirrored:YES]];
		 
		 [self.delegate didFinishWithCamera];
	 }];
	
	//[self switchView:nil];
	[activityIndicator startAnimating];
	
	//for(int i=0; i<self.backView.layer.sublayers.count; i++) {
	//	[[self.backView.layer.sublayers objectAtIndex:i] removeFromSuperlayer];
	//}
}

- (IBAction)cancel:(id)sender {
	if(self.delegate)
		[self.delegate didFinishWithCamera];
}

- (IBAction)switchView:(id)sender {
	NSLog(@"Switching view...");
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
	//if(inputToAdd == backCameraDeviceInput)
	//	cameraCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;	// AVCaptureSessionPresetPhoto
	//else
	//	cameraCaptureSession.sessionPreset = AVCaptureSessionPreset640x480; 
	[cameraCaptureSession commitConfiguration];	
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
	NSLog(@"Memory warning!");
}

- (void)viewDidUnload {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[activityIndicator release];
	
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
	
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"Deallocing CamOverlayController");
	[cameraCaptureSession release];
	[self.cameraPreviewLayer release];
    [super dealloc];
}

#pragma mark -
#pragma mark Utilities

- (NSData *)imageDataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer orientation:(UIDeviceOrientation)orientation mirrored:(BOOL)mirrored {
	if(sampleBuffer != nil) {
		// Check if the photo needs to be manipulated at all
		if(YES || orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationPortraitUpsideDown || mirrored) {
			/*

			CGContextRef newImageContext;
			if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
				newImageContext = CGBitmapContextCreate(nil, CGImageGetHeight(image), CGImageGetWidth(image), <#size_t bitsPerComponent#>, <#size_t bytesPerRow#>, <#CGColorSpaceRef space#>, <#CGBitmapInfo bitmapInfo#>)
			}
			
			CGImageRelease(image);
			 */
			// Below is adapted from http://www.platinumball.net/blog/2010/01/31/iphone-uiimage-rotation-and-scaling/
			
			// Turn the sample buffer into a CGImageRef
			CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData ((CFDataRef)[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer]);
			CGImageRef image = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);

			CGRect             bnds = CGRectZero;					// The boundary of the new drawing context
			CGContextRef       ctxt = nil;							// The drawing context for the new image
			CGRect             rect = CGRectZero;					// Original Image rectangle
			CGAffineTransform  tran = CGAffineTransformIdentity;	// The transform to be performed on the original image ref
			
			rect.size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
			
			// Set the new image context's dimensions according to the orientation
			if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
				bnds.size = CGSizeMake(rect.size.height, rect.size.width);
			else
				bnds.size = rect.size;
			
			NSLog(@"%f, %f", bnds.size.width, bnds.size.height);
			
			// Set up transforms based on orientation
			switch (orientation) {
				case UIDeviceOrientationLandscapeRight:
					if(mirrored) {
						tran = CGAffineTransformMakeTranslation(0, rect.size.width);
						tran = CGAffineTransformScale(tran, -1.0, 1.0);
					}
					else
						tran = CGAffineTransformMakeTranslation(0,0);
						
					tran = CGAffineTransformRotate(tran, M_PI/2);
					break;
				
				case UIDeviceOrientationLandscapeLeft:
					if(mirrored) {
						tran = CGAffineTransformMakeTranslation(rect.size.height, rect.size.width);
						tran = CGAffineTransformScale(tran, -1.0, 1.0);
					}
					else
						tran = CGAffineTransformMakeTranslation(rect.size.height,0);
						
					tran = CGAffineTransformRotate(tran, -M_PI/2);
					break;
				
				case UIDeviceOrientationPortraitUpsideDown:
					if(mirrored) {
						tran = CGAffineTransformMakeTranslation(0,rect.size.height);
						tran = CGAffineTransformScale(tran, -1.0, 1.0);
					}
					else
						tran = CGAffineTransformMakeTranslation(rect.size.width,rect.size.height);
					
					tran = CGAffineTransformRotate(tran, M_PI);
					break;
				
				case UIDeviceOrientationPortrait:
				default:
					if(mirrored) {
						NSLog(@"Portrait, mirrored");
						tran = CGAffineTransformMakeTranslation(rect.size.width,0);
						tran = CGAffineTransformScale(tran, -1.0, 1.0);
					}
					else
						tran = CGAffineTransformMakeTranslation(0,0);
					break;
			}

				
			// Set up the graphics context
			UIGraphicsBeginImageContext(bnds.size);
			ctxt = UIGraphicsGetCurrentContext();	
			CGContextConcatCTM(ctxt, tran);
			CGContextDrawImage(ctxt, rect, image);
			CGImageRelease(image);

			NSData *out = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 1);	// UIImage *
			UIGraphicsEndImageContext();
			return out;
					
		}
		else {
			return [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
		}
	}
	else return nil;
}
NSData *imageDataFromSampleBuffer(CMSampleBufferRef sampleBuffer) {
	if(sampleBuffer != nil) {
		return [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
	}
	else return nil;
}


@end
