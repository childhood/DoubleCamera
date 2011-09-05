//
//  Utilities.h
//  DoubleCamera
//
//  Created by kronick on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


@interface Utilities : UIView {

}

+ (NSString *) MD5:(NSString *)inString;
+ (BOOL) connectedToTheNet;

@end

@interface Reachability (addons) 
    + (BOOL) connectedToTheNet;
@end

@interface NSString (hash)
- (NSString *) MD5;
@end