//
//  LoginViewController.h
//  DoubleCamera
//
//  Created by kronick on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController {
	UITextField *userIDField;
}

@property (nonatomic,retain) IBOutlet UITextField *userIDField;

- (IBAction) save;

@end
