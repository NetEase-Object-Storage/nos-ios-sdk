//
//  NOSLbsNetMonitorTask.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSLbsNetMonitorTask.h"
#import "NOSReachability.h"
#import "NOSUploadManager+Private.h"

@interface NOSLbsNetMonitorTask()

@property (nonatomic) NOSNetworkStatus status;
@property (nonatomic) NOSReachability *internetReachability;

@end

@implementation NOSLbsNetMonitorTask

+ (instancetype)sharedInstanceAndRunWithCompleteHandler:(NOSLbsCompletionHandler) completeHandler {
    static NOSLbsNetMonitorTask *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithCompleteHandler:completeHandler];
    });
    
    return sharedInstance;
}

- (instancetype) initWithCompleteHandler:(NOSLbsCompletionHandler) completeHandler {
    if (self = [super initWithCompleteHandler:completeHandler]) {
        _status = NOSNotReachable;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNOSReachabilityChangedNotification object:nil];
        
        // use internet connection for now, if test fails, I'll try others
        _internetReachability = [NOSReachability reachabilityForInternetConnection];
        [_internetReachability startNotifier];
        [self updateUploaderHostsWithReachability:_internetReachability];
    }
    return self;
}

- (void) reachabilityChanged:(NSNotification *)note
{
    NOSReachability* curReach = [note object];
    [self updateUploaderHostsWithReachability:curReach];
}

- (void)updateUploaderHostsWithReachability:(NOSReachability *)reachability {
    if (reachability == self.internetReachability) {
        NOSNetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        switch (netStatus)
        {
            case NOSNotReachable: {
                break;
            }
                
            case NOSReachableViaWWAN: {
                if (self.status != netStatus) {
                    @autoreleasepool {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                            //[self fetchUploaderHosts:@"3g"];
                            [[NOSUploadManager bucketLbsMap] invalidLBSInfo];
                        });
                    }
                }
                self.status = netStatus;
                [NOSUploadManager bucketLbsMap].net = @"3g";
                break;
            }
            case NOSReachableViaWiFi: {
                if (self.status != netStatus) {
                    @autoreleasepool {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                            //[self fetchUploaderHosts:@"wifi"];
                            [[NOSUploadManager bucketLbsMap] invalidLBSInfo];
                        });
                    }
                }
                self.status = netStatus;
                [NOSUploadManager bucketLbsMap].net = @"wifi";
                break;
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOSReachabilityChangedNotification object:nil];
}

@end
