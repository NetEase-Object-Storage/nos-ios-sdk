//
//  NOSTestConf.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NOSConfig.h"

extern NSString *const kNOSTestBucket;
extern NSString *const kNOSTestAccessKey;
extern NSString *const kNOSTestSecretKey;
extern const UInt32 kNOSTestSoTimeout;

extern const UInt32 kNOSTestConnectionTimeout;
extern const UInt32 kNOSTestChunkSize;
extern const UInt32 kNOSTestMoniterInterval;
extern const UInt32 kNOSTestRetryCount;
extern const UInt32 kNOSTestRefreshInterval;
extern NSString *const kNOSTestLbsHost;

@interface NOSTestConf : NSObject

+ (NOSConfig *) testNOSConf;

@end
