//
//  CameraOverlayController.h
//  DoubleCamera
//
//  Created by kronick on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol CameraOverlayDelegate;

@interface CameraOverlayController : UIViewController <UINavigationControllerDelegate> {

	id <CameraOverlayDelegate> delegate;
	
	AVCaptureDeviceInput *frontCameraDeviceInput;
	AVCaptureDeviceInput *backCameraDeviceInput;
	AVCaptureStillImageOutput *cameraOutput;
	AVCaptureSession *cameraCaptureSession;
	AVCaptureVideoPreviewLayer *cameraPreviewLayer;

	
}

@property (nonatomic, assign) id <CameraOverlayDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

@property (nonatomic, retain) IBOutlet UIView *frontView;
@property (nonatomic, retain) IBOutlet UIView *backView;

- (void)startFrontCaptureSession;

//- (UIImage)imageFromSampleBuffer(CMSampleBufferRef sampleBuffer);

- (IBAction)cancel:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)switchView:(id)sender;

- (void)takeAnotherPhoto;

UIImage *imageFromSampleBuffer(CMSampleBufferRef sampleBuffer);

@end

@protocol CameraOverlayDelegate
- (void)didTakePicture:(UIImage *)picture;
- (void)didFinishWithCamera;
@end
