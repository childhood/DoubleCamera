//
//  SyncManager.h
//  DoubleCamera
//
//  Created by kronick on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncManager : NSObject {
    BOOL loadingPhotolist;
    BOOL photoListInitialized;
    
    NSMutableArray *pendingUploads;
    NSDictionary *urlStrings;
}

@property (retain) NSMutableArray *pendingUploads;
@property (retain) NSDictionary *urlStrings;

+(SyncManager*)sharedSyncManager;
-(void)reloadPhotoListWithCompletionBlock:(void (^)(void)) completeBlock;
-(BOOL)isPhotoOnline:(NSString *)key;
-(NSDictionary *)onlineInfoForPhoto:(NSString *)key;
-(NSURL *)URLForScript:(NSString *)script;
-(NSString *)URLStringForScript:(NSString *)script;
@end  