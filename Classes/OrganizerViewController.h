//
//  OrganizerViewController.h
//  DoubleCamera
//
//  Created by kronick on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideReviewController.h"
#import "ASIHTTPRequest.h"

#define CHECK_ICON_TAG 222

typedef enum {
	OrganizerModeSelectOneToView,
	OrganizerModeSelectToDelete,
	OrganizerModeSelectToUpload,
	OrganizerModeSelectToPrint
} OrganizerMode;

@interface OrganizerViewController : UIViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, UIScrollViewDelegate> {
	NSString *baseImageDirectory;
	
	UIScrollView *frontScrollView;
	UIScrollView *backScrollView;
	
	UIToolbar *mainToolbar;
	UIToolbar *multipleSelectionToolbar;
	
	NSMutableDictionary *doublePhotos;
	NSMutableArray		*orderedPhotoKeys;

	
	NSMutableArray *selectedImages;
	
	UIImage *checkImage;
	
	OrganizerMode mode;
}

@property (nonatomic, retain) IBOutlet UIScrollView *frontScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *backScrollView;
@property (nonatomic, retain) IBOutlet UIToolbar *mainToolbar;

@property (nonatomic, retain) UIImage *checkImage;

@property (nonatomic, retain) NSString *baseImageDirectory;
@property (nonatomic, retain) NSMutableArray *selectedImages;

@property (nonatomic, retain) NSMutableDictionary	*doublePhotos;
@property (nonatomic, retain) NSMutableArray		*orderedPhotoKeys;

- (void)flipGesture:(UISwipeGestureRecognizer *)recognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

- (IBAction)showActionSheet;
- (IBAction)imageTouched:(id)sender; 

- (void)deleteSelectedPhotos;

- (void)reloadThumbnails;
- (void)resetToolbars;
- (void)showToolbar;
- (void)hideToolbar;
- (void)updateMode:(OrganizerMode)newMode;
- (void)doneWithSelection;
- (void)updateNavbarTitle;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

- (UIButton *)flipsideButton:(UIButton *)button;
- (void)addCheck:(UIButton *)button;
- (void)removeCheck:(UIButton *)button;
- (BOOL)toggleSelection:(UIButton *)button;
- (void)clearSelection;


@end
