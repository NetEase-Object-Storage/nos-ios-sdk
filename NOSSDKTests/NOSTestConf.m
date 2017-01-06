//
//  NOSTestConf.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSTestConf.h"

NSString *const kNOSTestBucket = @"futh";
NSString *const kNOSTestAccessKey = @"3d3d1f4a085243d6ab4d9cb9242ec266"; //
NSString *const kNOSTestSecretKey = @"015cef348a714467bc1328c5e7b97345"; //

const UInt32 kNOSTestSoTimeout = 30;

const UInt32 kNOSTestConnectionTimeout = 30;

const UInt32 kNOSTestChunkSize = 128 * 1024;

const UInt32 kNOSTestMoniterInterval = 5;

const UInt32 kNOSTestRetryCount = 3;

const UInt32 kNOSTestRefreshInterval = 5; // for test, so the interval set to small

NSString *const kNOSTestLbsHost = @"https://lbs-eastchina1.126.net/lbs";


@implementation NOSTestConf

+ (NOSConfig *) testNOSConf {
    return [[NOSConfig alloc] initWithLbsHost:kNOSTestLbsHost
                           withSoTimeout:kNOSTestSoTimeout
                   //withConnectionTimeout:kNOSTestConnectionTimeout
                     withRefreshInterval:kNOSTestRefreshInterval
                           withChunkSize:kNOSTestChunkSize
                     withMoniterInterval:kNOSTestMoniterInterval
                          withRetryCount:kNOSTestRetryCount];
}

@end
