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


@implementation DoublePhoto 

@synthesize frontScreenImage, frontThumbnailImage, frontJPEGData, frontThumbnailJPEGData, backScreenImage, backThumbnailImage, backJPEGData, backThumbnailJPEGData;
@synthesize filePrefix, filePath;

- initWithFrontData:(NSData *)frontData andBackData:(NSData *)backData {
	if(self = [super init]) {
		screenSize = CGSizeMake(640, 960);
		thumbnailSize = CGSizeMake(148, 148);
		
		self.frontJPEGData = frontData;
		self.backJPEGData = backData;
		
		[self generateScreenImages];
		[self generateThumbnails];
	}
	return self;
}
- initWithPath:(NSString *)path andPrefix:(NSString *)prefix {
	if(self = [super init]) {
		screenSize = CGSizeMake(640, 960);
		thumbnailSize = CGSizeMake(148, 148);
		
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
	if(self = [super init]) {
		screenSize = CGSizeMake(640, 960);
		thumbnailSize = CGSizeMake(148, 148);
		
		self.filePath = path;
		self.filePrefix = prefix;
		
		self.frontThumbnailJPEGData = [NSData dataWithContentsOfFile:[self frontThumbnailPath]];
		self.backThumbnailJPEGData = [NSData dataWithContentsOfFile:[self backThumbnailPath]];
		
		[self generateThumbnails];
		
		return self;
	}
	return self;	
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
		if([[NSData dataWithData:UIImageJPEGRepresentation(self.frontThumbnailImage, 0.9)] writeToFile:[self frontThumbnailPath] atomically:YES]) savedFiles++;
		if([[NSData dataWithData:UIImageJPEGRepresentation(self.backThumbnailImage, 0.9)] writeToFile:[self backThumbnailPath] atomically:YES]) savedFiles++;
	}
	
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
	
	[super dealloc];
}

#pragma mark -
#pragma mark Upload functions
- (BOOL)uploadWithAlert:(UIAlertView *)alertView {
	// Upload back photo to S3
	// -----------------------
	__block ASIS3ObjectRequest *backRequest = [ASIS3ObjectRequest PUTRequestForFile:[self backImagePath]
																		 withBucket:@"doublecamera"
																				key:[NSString stringWithFormat:@"photos/%@%@-back-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix]];
	
	backRequest.shouldStreamPostDataFromDisk = YES;
	[backRequest setAccessPolicy:@"public-read"];
	[backRequest setDelegate:self];
	
	[backRequest setCompletionBlock:^{
		// Upload front photo to S3
		// ------------------------
		__block ASIS3ObjectRequest *frontRequest = [ASIS3ObjectRequest PUTRequestForFile:[self frontImagePath]
																			  withBucket:@"doublecamera"
																					 key:[NSString stringWithFormat:@"photos/%@%@-front-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix]];
		
		NSLog(@"photos/%@%@-front-o.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix);
		frontRequest.shouldStreamPostDataFromDisk = YES;
		[frontRequest setAccessPolicy:@"public-read"];
		[frontRequest setDelegate:self];
		[frontRequest setCompletionBlock:^{
			// Make a POST request to the script that inserts a new record in the database
			// ---------------------------------------------------------------------------
			NSURL *url = [NSURL URLWithString:@"http://benjaminlotan.com/doublecamera/newphoto.php"];
			__block ASIFormDataRequest *insertRequest= [ASIFormDataRequest requestWithURL:url];
			//[insertRequest addPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"] forKey:@"user-id"];
			[insertRequest addPostValue:filePrefix forKey:@"photo-id"];
			[insertRequest addPostValue:@"kronick" forKey:@"username"];
			[insertRequest addPostValue:[Utilities MD5:@"123f"] forKey:@"password"];
			[insertRequest addPostValue:[NSString stringWithFormat:@"http://doublecamera.s3.amazonaws.com/photos/%@%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"], filePrefix] forKey:@"url-base"];
			[insertRequest addPostValue:@"" forKey:@"date-taken"];
			[insertRequest addPostValue:@"" forKey:@"caption-front"];
			[insertRequest addPostValue:@"" forKey:@"caption-back"];
			
			[insertRequest setDelegate:self];
			[insertRequest setCompletionBlock:^{
				NSString *responseString = [insertRequest responseString];
				NSDictionary *responseDict = [responseString JSONValue];
				NSInteger statusCode = [[responseDict valueForKey:@"status"] integerValue];
				NSLog(@"Status code: %i Reason: %@", statusCode, [responseDict valueForKey:@"reason"]);
				switch(statusCode) {
					case 200:{	// All OK
						UIAlertView *completeAlert = [[[UIAlertView alloc] initWithTitle: @"Upload Complete"
																				 message: @"Your photos have been uploaded."
																				delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
						[completeAlert show];
						break;}
					case 500:{	// Server error
						UIAlertView *completeAlert = [[[UIAlertView alloc] initWithTitle: @"Server Error"
																				 message: @"There was an error processing your upload. Please try again later."
																				delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
						[completeAlert show];
						break;}						
					case 409:{	// Duplicate
						UIAlertView *completeAlert = [[[UIAlertView alloc] initWithTitle: @"Duplicate upload"
																				 message: @"This photo has already been uploaded!"
																				delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
						[completeAlert show];
						break;}												
					case 401:	// Not Authorized
					case 403:{
						UIAlertView *completeAlert = [[[UIAlertView alloc] initWithTitle: @"Login Failure"
																				 message: @"Your username or password is no longer valid. Please login again from the settings screen."
																				delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
						[completeAlert show];
						break;}												
				}
			}];
			
			[insertRequest startAsynchronous];						
		}];
		[frontRequest setFailedBlock: ^{
			NSLog(@"Front upload failed: %@", [frontRequest error]);
		}];
		
		[frontRequest startAsynchronous];
	}];
	[backRequest setFailedBlock: ^{
		NSLog(@"Back upload failed: %@", [backRequest error]);
	}];
	
	[backRequest startAsynchronous];
}


@end
