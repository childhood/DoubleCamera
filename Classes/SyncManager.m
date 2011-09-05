//
//  SyncManager.m
//  DoubleCamera
//
//  Created by kronick on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SyncManager.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Utilities.h"

@implementation SyncManager
@synthesize pendingUploads, urlStrings;

static SyncManager* _sharedSyncManager = nil;

+(SyncManager*)sharedSyncManager {
    @synchronized([SyncManager class]) {
        if (!_sharedSyncManager)
			[[self alloc] init];
        
		return _sharedSyncManager;
	}
    
	return nil;
}

+(id)alloc {
	@synchronized([SyncManager class]) {
		NSAssert(_sharedSyncManager == nil, @"Attempted to allocate second instance of singleton.");
		_sharedSyncManager = [super alloc];
		return _sharedSyncManager;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		loadingPhotolist = NO;
        
        photoListInitialized = ([(NSDictionary *)[[NSUserDefaults standardUserDefaults] 
                                                  objectForKey:@"photolist"] count] != 0);
        
        self.pendingUploads = [NSMutableArray array];
        self.urlStrings = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"URLs" ofType:@"plist"]];
	}
    
	return self;
}

-(void)reloadPhotoListWithCompletionBlock:(void (^)(void)) completeBlock {
    if(!loadingPhotolist) {
        NSURL *url = [[SyncManager sharedSyncManager] URLForScript:@"photo-list"];
        __block ASIFormDataRequest *photolistRequest= [ASIFormDataRequest requestWithURL:url];
        [photolistRequest addPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]
                                forKey:@"username"];
        [photolistRequest addPostValue:[[[NSUserDefaults standardUserDefaults]
                                         stringForKey:@"password"] MD5] forKey:@"password"];
        
        [photolistRequest setCompletionBlock:^{			
            NSString *responseString = [photolistRequest responseString];
            NSDictionary *responseDict = [responseString JSONValue];
            
            NSNumber *statusCode = [responseDict objectForKey:@"status"];
            if([statusCode intValue] == 200) {
                // Success
                [[NSUserDefaults standardUserDefaults] setObject:[responseDict
                                                                  objectForKey:@"photos"]
                                                          forKey:@"photolist"];
                [[NSUserDefaults standardUserDefaults] setObject:[responseDict
                                                                  objectForKey:@"web-base"]
                                                          forKey:@"web-base"];
                photoListInitialized = YES;
                
                if(completeBlock != nil)
                    completeBlock();
            }
            else {
                // Some problem. Probably just ignore it.
                NSLog(@"Couldn't load photo list: %@", responseString);
            }
            
            loadingPhotolist = NO;
        }];
        
        [photolistRequest setFailedBlock:^{
            NSLog(@"Couldn't load photo list.");
            loadingPhotolist = NO;
        }];
        
        if([Reachability connectedToTheNet] && !loadingPhotolist) {
            loadingPhotolist = YES;
            [photolistRequest startAsynchronous];
            NSLog(@"Loading photo list.");
        }
    }
    else {
        NSLog(@"Already loading photo list.");
    }
}

-(BOOL)isPhotoOnline:(NSString *)key {
    // First try to grab the dictionary if it's not already stored
    if(!photoListInitialized) {
        //[self reloadPhotoListWithCompletionBlock:nil];
        return NO;
    }
    
    int userID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] intValue];
    NSString *onlineID = [NSString stringWithFormat:@"%i%@",
                          userID,key];
    
    return ([(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"photolist"]
                objectForKey:onlineID] != nil);
    
}

-(NSDictionary *)onlineInfoForPhoto:(NSString *)key {
    // First try to grab the dictionary if it's not already stored
    if(!photoListInitialized) {
        //[self reloadPhotoListWithCompletionBlock:nil];
        return nil;
    }
    
    NSString *onlineID = [NSString stringWithFormat:@"%i%@",
                          [[NSUserDefaults standardUserDefaults] integerForKey:@"user_id"],key];
    
    NSLog(@"Online ID: %@", onlineID);
    return [(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"photolist"]
             objectForKey:onlineID];    
}

-(NSURL *) URLForScript:(NSString *)script {
    return [NSURL URLWithString:[urlStrings objectForKey:script]];
}
-(NSString *) URLStringForScript:(NSString *)script {
    return [urlStrings objectForKey:script];
}
@end
