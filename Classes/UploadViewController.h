//
//  UploadViewController.h
//  DoubleCamera
//
//  Created by kronick on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoublePhoto.h"


@interface UploadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
	IBOutlet UITableViewCell *sideADescriptionCell;
	IBOutlet UITableViewCell *sideBDescriptionCell;
	IBOutlet UIImageView *sideAImageView;
	IBOutlet UIImageView *sideBImageView;
	IBOutlet UILabel *sideADescriptionLabel;
	IBOutlet UILabel *sideBDescriptionLabel;
	IBOutlet UITextView *sideADescription;
	IBOutlet UITextView *sideBDescription;
	
	IBOutlet UITableViewCell *twitterCell;
	IBOutlet UITableViewCell *facebookCell;
	IBOutlet UITableViewCell *tumblrCell;
	
	DoublePhoto *toUpload;
}

@property (nonatomic,retain) DoublePhoto *toUpload;

@property (nonatomic,retain) IBOutlet UITableViewCell *sideADescriptionCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *sideBDescriptionCell;
@property (nonatomic,retain) IBOutlet UIImageView *sideAImageView;
@property (nonatomic,retain) IBOutlet UIImageView *sideBImageView;
@property (nonatomic,retain) IBOutlet UILabel *sideADescriptionLabel;
@property (nonatomic,retain) IBOutlet UILabel *sideBDescriptionLabel;
@property (nonatomic,retain) IBOutlet UITextView *sideADescription;
@property (nonatomic,retain) IBOutlet UITextView *sideBDescription;

@property (nonatomic,retain) IBOutlet UITableViewCell *twitterCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *facebookCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *tumblrCell;

- (id)init;
- (void)startUpload;

@end
