//
//  NOSConfig.m
//  NOSSDK
//
//  Created by NetEase on 2015/1/15.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSConfig.h"

NSString *const kNOSplatform = @"ios";

const UInt32 kNOSSoTimeout = 30;

//const UInt32 kNOSConnectionTimeout = 30;

const UInt32 kNOSChunkSize = 128 * 1024;

const UInt32 kNOSMoniterInterval = 120;

const UInt32 kNOSRetryCount = 2;

const UInt32 kNOSRefreshInterval = 2 * 60 * 60;

NSString *const kNOSLbsHost = @"https://lbs-eastchina1.126.net";

int const KNOSLbsHostNum = 1;
NSString const *kNOSLbsHostArray[KNOSLbsHostNum] = {
    @"https://lbs-eastchina1.126.net/lbs",
};

NSString *const kNOSLbsVersion = @"version=1.0";

static NSArray * kNOSUploaderDefaultHosts;

@implementation NOSConfig

+ (void)initialize {
    kNOSUploaderDefaultHosts = [NSArray arrayWithObjects:@"https://nosup-eastchina1.126.net", nil];
}

+ (NSArray* )uploaderDefaultHosts {
    return kNOSUploaderDefaultHosts;
}

- (instancetype)init {
    if (self = [super init]) {
        return [self initWithLbsHost:kNOSLbsHost
                withSoTimeout:kNOSSoTimeout
        //withConnectionTimeout:kNOSConnectionTimeout
          withRefreshInterval:kNOSRefreshInterval
                withChunkSize:kNOSChunkSize
          withMoniterInterval:kNOSMoniterInterval
               withRetryCount:kNOSRetryCount];
    }
    return self;
}

- (instancetype)initWithLbsHost:(NSString*) lbsHost
                  withSoTimeout:(UInt32) soTimeout
          //withConnectionTimeout:(UInt32) connectionTimeout
            withRefreshInterval:(UInt32) refreshInterval
                  withChunkSize:(UInt32) chunkSize
            withMoniterInterval:(UInt32) moniterInterval
                 withRetryCount:(UInt32) retryCount {
    if (self = [super init]) {
        _NOSLbsHost = [lbsHost copy];
        _NOSSoTimeout = soTimeout;
        //_NOSConnectionTimeout = connectionTimeout;
        _NOSRefreshInterval = refreshInterval;
        _NOSChunkSize = chunkSize;
        _NOSMoniterInterval = moniterInterval;
        _NOSRetryCount = retryCount;
    }
    return self;
}

/*- (NSString *)lbsUrl {
    NSMutableString * url = [NSMutableString stringWithString:self.NOSLbsHost];
    [url appendString:@"/lbs?"];
    [url appendString:kNOSLbsVersion];
    return url;
}*/

- (NSString *)statUrl {
    NSMutableString * url = [NSMutableString stringWithString:@"https://"];
    if ([self.NOSLbsHost hasPrefix:@"http://"]) {
        [url appendString: [self.NOSLbsHost substringFromIndex:[@"http://" length]]];
    } else if ([self.NOSLbsHost hasPrefix:@"https://"]) {
        url = [NSMutableString stringWithString:self.NOSLbsHost];
    } else {
        [url appendString:self.NOSLbsHost];
    }
    
    [url appendString:@"/stat/sdk?"];
    [url appendString:kNOSLbsVersion];
    return url;
}


@end
