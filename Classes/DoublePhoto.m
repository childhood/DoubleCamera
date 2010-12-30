//
//  DoublePhoto.m
//  DoubleCamera
//
//  Created by kronick on 12/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DoublePhoto.h"
#import "UIImageExtras.h"


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

- (BOOL)generateScreenImages {
	// If the files haven't been loaded yet, create images directly from files
	if(self.frontJPEGData == nil || self.backJPEGData == nil) {
		self.frontScreenImage = [[UIImage imageWithContentsOfFile:[self frontImagePath]] imageByScalingAndCroppingForSize:screenSize];
		self.backScreenImage = [[UIImage imageWithContentsOfFile:[self backImagePath]] imageByScalingAndCroppingForSize:screenSize];
	}
	else {
		self.frontScreenImage = [[UIImage imageWithData:self.frontJPEGData] imageByScalingAndCroppingForSize:screenSize];
		self.backScreenImage = [[UIImage imageWithData:self.backJPEGData] imageByScalingAndCroppingForSize:screenSize];
	}
	
	if(self.frontScreenImage != nil && self.backScreenImage != nil)
		return YES;
	else
		return NO;
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


@end
