//
//  DoublePhoto.m
//  DoubleCamera
//
//  Created by kronick on 12/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DoublePhoto.h"
#import "UIImageExtras.h"
#import "ASIS3ObjectRequest.h"
#import "Utilities.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "SyncManager.h"

@implementation DoublePhoto 

@synthesize frontScreenImage, frontThumbnailImage, frontJPEGData, frontThumbnailJPEGData, backScreenImage, backThumbnailImage, backJPEGData, backThumbnailJPEGData;
@synthesize filePrefix, filePath;
@synthesize uploadQueue;

- (id) init {
	if(self = [super init]) {
		screenSize = CGSizeMake(640, 960);
		thumbnailSize = CGSizeMake(148, 148);
		
		return self;
	}
	else return nil;
}
- initWithFrontData:(NSData *)frontData andBackData:(NSData *)backData {
	if(self = [self init]) {		
		self.frontJPEGData = frontData;
		self.backJPEGData = backData;
		
		[self generateScreenImages];
		[self generateThumbnails];
	}
	return self;
}
- initWithPath:(NSString *)path andPrefix:(NSString *)prefix {
	if(self = [self init]) {		
		self.filePath = path;
		self.filePrefix = prefix;

		self.frontJPEGData = [NSData dataWithContentsOfFile:[self frontImagePath]];
		self.frontThumbnailJPEGData = [NSData dataWithContentsOfFile:[self frontThumbnailPath]];
		self.backJPEGData = [NSData dataWithContentsOfFile:[self backImagePath]];
		self.backThumbnailJPEGData = [NSData dataWithContentsOfFile:[self backThumbnailPath]];
		
		[self generateScreenImages];
		[self generateThumbnails];
		return self;
	}
	return self;
}

- initThumbnailsWithPath:(NSString *)path andPrefix:(NSString *)prefix {
	if(self = [self init]) {
		self.filePath = path;
		self.filePrefix = prefix;
		
		self.frontThumbnailJPEGData = [NSData dataWithContentsOfFile:[self frontThumbnailPath]];
		self.backThumbnailJPEGData = [NSData dataWithContentsOfFile:[self backThumbnailPath]];
		
		[self generateThumbnails];
		
		return self;
	}
	return self;	
}

- (void) setMetaData:(UploadMetaData)data {
	if(data.frontCaption != nil) {
		[metaData.frontCaption autorelease];
		metaData.frontCaption = data.frontCaption;
		[metaData.frontCaption retain];
	}
	if(data.backCaption != nil) {
		[metaData.backCaption autorelease];
		metaData.backCaption = data.backCaption;
		[metaData.backCaption retain];
	}
	if(data.timeTaken != nil) {
		[metaData.timeTaken autorelease];
		metaData.timeTaken = data.timeTaken;
		[metaData.timeTaken retain];
	}
	metaData.shareOnTumblr = data.shareOnTumblr;
	metaData.shareOnFacebook = data.shareOnTumblr;
	metaData.shareOnTwitter = data.shareOnTwitter;
}
	
- (void) updateMetaData {
	if([self frontImagePath] != nil) {
		[metaData.timeTaken autorelease];
		NSTimeInterval seconds = [[[[NSFileManager defaultManager] attributesOfItemAtPath:[self frontImagePath]error:nil] objectForKey:NSFileCreationDate] timeIntervalSince1970];
		metaData.timeTaken = [NSString stringWithFormat:@"%i", (int)seconds];
		[metaData.timeTaken retain];
	}
}

- (BOOL) releaseJPEGData {
	if(self.frontJPEGData != nil || self.backJPEGData != nil) {
		if(self.frontJPEGData != nil) [self.frontJPEGData release];
		if(self.backJPEGData != nil) [self.backJPEGData release];
		return YES;
	}
	else return NO;
}

- (NSInteger)saveToDisk {
	NSInteger savedFiles = 0;
	// Make sure there's good data for the full size images
	if(self.frontJPEGData != nil && self.backJPEGData != nil) {
		if([self.frontJPEGData writeToFile:[self frontImagePath] atomically:YES]) savedFiles++;
		if([self.backJPEGData writeToFile:[self backImagePath] atomically:YES]) savedFiles++;
	}
	
	// Make sure there's good data for the thumbnail images
	if(self.frontThumbnailImage != nil && self.backThumbnailImage != nil) {
		if([[NSData dataWithData:UIImageJPEGRepresentation(self.frontThumbnailImage, 0.8)] writeToFile:[self frontThumbnailPath] atomically:YES]) savedFiles++;
		if([[NSData dataWithData:UIImageJPEGRepresentation(self.backThumbnailImage, 0.8)] writeToFile:[self backThumbnailPath] atomically:YES]) savedFiles++;
	}
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"save-diptych"])
        UIImageWriteToSavedPhotosAlbum([self generateDiptych], nil, nil, nil);
	
	return savedFiles;
}

- (NSInteger)deleteFromDisk {
	NSInteger deletedFiles = 0;
	if([[NSFileManager defaultManager] removeItemAtPath:[self frontImagePath] error:nil]) deletedFiles++;
	if([[NSFileManager defaultManager] removeItemAtPath:[self backImagePath] error:nil]) deletedFiles++;
	if([[NSFileManager defaultManager] removeItemAtPath:[self backThumbnailPath] error:nil]) deletedFiles++;
	if([[NSFileManager defaultManager] removeItemAtPath:[self frontThumbnailPath] error:nil]) deletedFiles++;
	
	return deletedFiles;
}

- (BOOL)loadJPEGData {
	if(self.frontJPEGData == nil || self.backJPEGData == nil) {
		self.frontJPEGData = [NSData dataWithContentsOfFile:[self frontImagePath]];
		self.backJPEGData = [NSData dataWithContentsOfFile:[self backImagePath]];
		return YES;
	}
	else return NO;
}

#pragma mark -
#pragma mark Resizing, etc

- (BOOL)generateScreenImages {
	if(!generatingScreenImages) {
		// If the files haven't been loaded yet, create images directly from files
		if(self.frontScreenImage == nil || self.backScreenImage == nil) {
			generatingScreenImages = YES;
			if(self.frontJPEGData == nil || self.backJPEGData == nil) {
				UIImage *fullFront = [UIImage imageWithContentsOfFile:[self frontImagePath]];
				UIImage *fullBack = [UIImage imageWithContentsOfFile:[self backImagePath]];
				
				if(fullFront.size.width > fullFront.size.height) {
					screenSize = CGSizeMake(screenSize.height, screenSize.width);
				}
				
				self.frontScreenImage = [fullFront imageByScalingAndCroppingForSize:screenSize];
				self.backScreenImage = [fullBack imageByScalingAndCroppingForSize:screenSize];
				//self.frontScreenImage = fullFront;
				//self.backScreenImage  = fullBack;
			}
			else {
				UIImage *fullFront = [UIImage imageWithData:self.frontJPEGData];
				UIImage *fullBack = [UIImage imageWithData:self.backJPEGData];
				
				if(fullFront.size.width > fullFront.size.height) {
					screenSize = CGSizeMake(screenSize.height, screenSize.width);
				}
				
				self.frontScreenImage = [fullFront imageByScalingAndCroppingForSize:screenSize];
				self.backScreenImage = [fullBack imageByScalingAndCroppingForSize:screenSize];
			}
		}
		generatingScreenImages = NO;
	}
	
	if(self.frontScreenImage != nil && self.backScreenImage != nil)
		return YES;
	else
		return NO;
}

- (BOOL)freeScreenImages {
	self.frontJPEGData = nil;
	self.backJPEGData  = nil;
	self.frontScreenImage = nil;
	self.backScreenImage = nil;
	return YES;
}

- (BOOL)generateThumbnails {
	if(self.frontThumbnailJPEGData == nil || self.backThumbnailJPEGData == nil) {
		// If there is no thumbnail file data, create a thumbnail from the full JPEG image data
		if(self.frontJPEGData != nil && self.backJPEGData != nil) {
			// Use JPEG data already in memory if it exists
			self.frontThumbnailImage = [[UIImage imageWithData:self.frontJPEGData] imageByScalingAndCroppingForSize:thumbnailSize];
			self.backThumbnailImage = [[UIImage imageWithData:self.backJPEGData] imageByScalingAndCroppingForSize:thumbnailSize];
		}
		else {
			// Temporarily load JPEG data if it's not already in memory
			self.frontThumbnailImage = [[UIImage imageWithContentsOfFile:[self frontImagePath]] imageByScalingAndCroppingForSize:thumbnailSize];
			self.backThumbnailImage = [[UIImage imageWithContentsOfFile:[self backImagePath]] imageByScalingAndCroppingForSize:thumbnailSize];
		}
		if(self.filePath != nil) [self saveToDisk];
	}
	else {
		// If thumbnail JPEG data exists, use that
		self.frontThumbnailImage = [UIImage imageWithData:self.frontThumbnailJPEGData];
		self.backThumbnailImage = [UIImage imageWithData:self.backThumbnailJPEGData];
	}
	
	if(self.frontThumbnailImage != nil && self.backThumbnailImage != nil)
		return YES;
	else
		return NO;
}

- (UIImage *) generateDiptych {
    [self generateScreenImages];
    CGImageRef front_image = [frontScreenImage CGImage];
    CGImageRef back_image  = [backScreenImage CGImage];
    
    CGFloat width = CGImageGetWidth(front_image) + CGImageGetWidth(back_image);
    CGFloat height = MAX(CGImageGetHeight(front_image), CGImageGetHeight(back_image));
    
    void *diptych_data = malloc(width * height * 4);
    CGContextRef diptych_context = CGBitmapContextCreate(diptych_data, width, height, 8,
                                                         width*4, CGImageGetColorSpace(front_image), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(diptych_context, CGRectMake(0, 0, CGImageGetWidth(back_image), CGImageGetHeight(back_image)), back_image);
    CGContextDrawImage(diptych_context, CGRectMake(CGImageGetWidth(back_image), 0, CGImageGetWidth(front_image), CGImageGetHeight(front_image)), front_image);

    CGImageRef diptych_image = CGBitmapContextCreateImage(diptych_context);
    UIImage *diptychImage = [UIImage imageWithCGImage:diptych_image];
    CFRelease(diptych_image);
    CGContextRelease(diptych_context);
    
    return diptychImage;
}

#pragma -
#pragma mark Getters for generated paths

- (NSString *)backImagePath {
	return [filePath stringByAppendingFormat:@"/%@_back.jpg", filePrefix];
}
- (NSString *)frontImagePath {
	return [filePath stringByAppendingFormat:@"/%@_front.jpg", filePrefix];
}
- (NSString *)frontThumbnailPath {
	return [filePath stringByAppendingFormat:@"/%@_front_thumb.jpg", filePrefix];
}
- (NSString *)backThumbnailPath {
	return [filePath stringByAppendingFormat:@"/%@_back_thumb.jpg", filePrefix];
}

- (void)dealloc {
	[frontScreenImage release];
	[backScreenImage release];
	[frontThumbnailImage release];
	[backThumbnailImage release];
	[frontJPEGData release];
	[backJPEGData release];
	[filePrefix release];
	[filePath release];
	
	uploadQueue = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Upload functions
- (BOOL)uploadWithAlert:(UIAlertView *)alertView {
	[self updateMetaData];
	
	// Create upload queue
	self.uploadQueue = [ASINetworkQueue queue];
	self.uploadQueue.delegate = self;
	self.uploadQueue.requestDidFinishSelector	= @selector(requestComplete:);
	self.uploadQueue.requestDidFailSelector		= @selector(requestFailed:);
	self.uploadQueue.queueDidFinishSelector		= @selector(uploadComplete:);
	self.uploadQueue.shouldCancelAllRequestsOnFailure = YES;
	[self.uploadQueue setMaxConcurrentOperationCount:1];
	
	// Upload back photo to S3
	// -----------------------
	__block ASIS3ObjectRequest *backRequest = [ASIS3ObjectRequest PUTRequestForFile:[self backImagePath]
																		 withBucket:@"doublecamera"
																				key:[NSString stringWithFormat:@"photos/%@%@-back-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix]];
	NSLog(@"Back image file size: %@ (bytes)", [[[NSFileManager defaultManager] attributesOfItemAtPath:[self backImagePath] error:nil] objectForKey:NSFileSize]);
	
	backRequest.shouldStreamPostDataFromDisk = YES;
	[backRequest setAccessPolicy:@"public-read"];
	[backRequest setNumberOfTimesToRetryOnTimeout:3];
	[backRequest setShouldContinueWhenAppEntersBackground:YES];
	[backRequest setUploadProgressDelegate:self];
	backRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"back",@"id",
                                                                  filePrefix, @"prefix", nil];
	
	ASIS3ObjectRequest *frontRequest = [ASIS3ObjectRequest PUTRequestForFile:[self frontImagePath]
																  withBucket:@"doublecamera"
																		 key:[NSString stringWithFormat:@"photos/%@%@-front-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix]];
	
	frontRequest.shouldStreamPostDataFromDisk = YES;
	[frontRequest setAccessPolicy:@"public-read"];
	[frontRequest setNumberOfTimesToRetryOnTimeout:3];
	[frontRequest setShouldContinueWhenAppEntersBackground:YES];
	frontRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"front",@"id",
                                                                filePrefix, @"prefix", nil];
	
	NSURL *url = [[SyncManager sharedSyncManager] URLForScript:@"new-photo"];
	ASIFormDataRequest *insertRequest= [ASIFormDataRequest requestWithURL:url];
	[ASIHTTPRequest setShouldThrottleBandwidthForWWAN:NO];
	[insertRequest addPostValue:filePrefix forKey:@"photo-id"];
	[insertRequest addPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] forKey:@"username"];
	[insertRequest addPostValue:[Utilities MD5:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]] forKey:@"password"];
	[insertRequest addPostValue:[NSString stringWithFormat:@"%@%@%@",
                                 [[SyncManager sharedSyncManager] URLStringForScript:@"s3-base"],
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"],
                                 filePrefix]
                         forKey:@"url-base"];
	[insertRequest addPostValue:metaData.timeTaken forKey:@"time-taken"];
	[insertRequest addPostValue:metaData.frontCaption forKey:@"caption-front"];
	[insertRequest addPostValue:metaData.backCaption forKey:@"caption-back"];
	[insertRequest setShouldContinueWhenAppEntersBackground:YES];
	insertRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"insert",@"id",
                                                                filePrefix, @"prefix", nil];
	
	[self.uploadQueue addOperation:backRequest];
	[self.uploadQueue addOperation:frontRequest];
	[self.uploadQueue addOperation:insertRequest];
	
	backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
		backgroundTask = UIBackgroundTaskInvalid;
	}];
	[self.uploadQueue go];
	
    [[[SyncManager sharedSyncManager] pendingUploads] addObject:filePrefix];
	
}

- (void)request:(ASIHTTPRequest *) req didSendBytes:(int) bytes {
	NSLog(@"%i bytes uploaded", bytes);
}

#pragma mark -
#pragma mark ASINetworkQueue Deletgate

- (void)requestComplete:(ASIHTTPRequest *)request {
	if([(NSString *)[request.userInfo objectForKey:@"id"] isEqualToString:@"insert"]) {
		NSString *responseString = [request responseString];
		NSDictionary *responseDict = [responseString JSONValue];
		NSInteger statusCode = [[responseDict valueForKey:@"status"] integerValue];
		NSLog(@"Status code: %i Reason: %@", statusCode, [responseDict valueForKey:@"reason"]);
		NSString *alertTitle, *alertMessage;
        BOOL showAlert = YES;
		switch(statusCode) {
			case 200:{	// All OK
				alertTitle = @"Upload complete";
				alertMessage = @"Your double photo has been uploaded!";
                showAlert = NO;
				break;}				
			case 409:{	// Duplicate
				alertTitle = @"Duplicate upload";
				alertMessage = @"This double photo already exists.";
                // TODO: Reload definitions of which photos are uploaded    
				break;}												
			case 401:	// Not Authorized
			case 403:{
				alertTitle = @"Login Failure";
				alertMessage = @"Your username or password is no longer valid. Please login again from the settings screen.";
				break;}
            default:
			case 500:{	// Server error
				alertTitle = @"Server Error";
				alertMessage = @"There was an error processing your upload.";
                NSLog(@"Response was: %@", responseString);
				break;}		                
		}
        if(showAlert) {
            UIAlertView *completeAlert = [[[UIAlertView alloc] initWithTitle: alertTitle
                                                                     message: alertMessage
                                                                    delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
            [completeAlert show];
                
        }
        
        [[[SyncManager sharedSyncManager] pendingUploads]
            removeObject:[request.userInfo objectForKey:@"prefix"]];
        [[SyncManager sharedSyncManager] reloadPhotoListWithCompletionBlock:nil];
	}
	
	// Release the queue if this was the last request
	if ([self.uploadQueue requestsCount] == 0) {
		self.uploadQueue = nil;
		[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
		backgroundTask = UIBackgroundTaskInvalid;
	}
	else {
		backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
			backgroundTask = UIBackgroundTaskInvalid;
		}];
	}
	NSLog(@"Request complete: %@", [[request userInfo] objectForKey:@"id"]);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if(request.retryCount == request.numberOfTimesToRetryOnTimeout) {
        UIAlertView *completeAlert = [[[UIAlertView alloc] initWithTitle: @"Server Error"
                                                                 message: @"There was an error processing your upload. Please try again later."
                                                                delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
        [completeAlert show];
        NSLog(@"Request failed at: %@", [[request userInfo] objectForKey:@"id"]);
        
        [self.uploadQueue cancelAllOperations];
        
        self.uploadQueue = nil;
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;	
        
        [[[SyncManager sharedSyncManager] pendingUploads]
         removeObject:[request.userInfo objectForKey:@"prefix"]];
    }
}
- (void)uploadComplete:(ASIHTTPRequest *)request {
	// Release the queue if this was the last request
	if ([self.uploadQueue requestsCount] == 0) {
		self.uploadQueue = nil;
		[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
		backgroundTask = UIBackgroundTaskInvalid;
	}
	else {
		backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
			backgroundTask = UIBackgroundTaskInvalid;
		}];
	}
	NSLog(@"Upload complete.");
}
@end
