//
//  DoubleCameraAppDelegate.h
//  DoubleCamera
//
//  Created by kronick on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReviewPhotoViewController;

@interface DoubleCameraAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ReviewPhotoViewController *viewController;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet ReviewPhotoViewController *viewController;

@end

