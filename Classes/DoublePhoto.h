//
//  DoublePhoto.h
//  DoubleCamera
//
//  Created by kronick on 12/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DoublePhoto : NSObject {
	UIImage *frontScreenImage;
	UIImage *frontThumbnailImage;
	NSData *frontJPEGData;
	NSData *frontThumbnailJPEGData;
	
	UIImage *backScreenImage;
	UIImage *backThumbnailImage;
	NSData *backJPEGData;
	NSData *backThumbnailJPEGData;
	
	NSString *filePrefix;
	NSString *filePath;
	
	CGSize screenSize;
	CGSize thumbnailSize;
	
	BOOL generatingScreenImages;
}

@property (nonatomic, retain) UIImage *frontScreenImage;
@property (nonatomic, retain) UIImage *frontThumbnailImage;
@property (nonatomic, retain) NSData *frontJPEGData;
@property (nonatomic, retain) NSData *frontThumbnailJPEGData;
@property (nonatomic, retain) UIImage *backScreenImage;
@property (nonatomic, retain) UIImage *backThumbnailImage;
@property (nonatomic, retain) NSData *backJPEGData;
@property (nonatomic, retain) NSData *backThumbnailJPEGData;

@property (nonatomic, retain) NSString *filePrefix;
@property (nonatomic, retain) NSString *filePath;

- initWithFrontData:(NSData *)frontData andBackData:(NSData *)backData;
- initWithPath:(NSString *)path andPrefix:(NSString *)prefix;

- initThumbnailsWithPath:(NSString *)path andPrefix:(NSString *)prefix;

- (BOOL)loadJPEGData;
- (BOOL)releaseJPEGData;

- (NSInteger)deleteFromDisk;
- (NSInteger)saveToDisk;
- (BOOL)generateThumbnails;
- (BOOL)generateScreenImages;
- (BOOL)freeScreenImages;

- (NSString *)backImagePath;
- (NSString *)frontImagePath;
- (NSString *)backThumbnailPath;
- (NSString *)frontThumbnailPath;

- (BOOL)uploadWithAlert:(UIAlertView *)alertView;


@end
