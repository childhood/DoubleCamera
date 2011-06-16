//
//  LoginViewController.h
//  DoubleCamera
//
//  Created by kronick on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	UIViewController *returnController;
}

@property (nonatomic,retain) IBOutlet UITextField *usernameField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic,retain) UIViewController *returnController;

- (IBAction) signIn;

@end
