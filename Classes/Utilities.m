//
//  Utilities.m
//  DoubleCamera
//
//  Created by kronick on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Utilities


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


+ (NSString *) MD5:(NSString *)inString {
	const char *inString_c = [inString UTF8String];  // Get data as C language string.
	unsigned char md5_result[16];   // storage for checksum result
	CC_MD5(inString_c, strlen(inString_c), md5_result);
	NSString *hex_str = [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						 md5_result[0], md5_result[1],
						 md5_result[2], md5_result[3],
						 md5_result[4], md5_result[5],
						 md5_result[6], md5_result[7],
						 md5_result[8], md5_result[9],
						 md5_result[10], md5_result[11],
						 md5_result[12], md5_result[13],
						 md5_result[14], md5_result[15]];
	
	return hex_str;
}	

@end
