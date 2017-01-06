//
//  NOSLbsInfo.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/23.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSLbsInfo.h"

@implementation NOSLbsInfo

- (instancetype) init {
    if (self = [super init]) {
        _hasPushed = NO;
    }
    return self;
}

- (NOSLbsInfo *) clone {
    NOSLbsInfo *cloneOne = [[NOSLbsInfo alloc] init];
    cloneOne.lbsIP = self.lbsIP;
    cloneOne.uploaderHosts = self.uploaderHosts;
    cloneOne.lbsHttpCode = self.lbsHttpCode;
    cloneOne.lbsSucc = self.lbsSucc;
    cloneOne.lbsUseTime = self.lbsUseTime;
    cloneOne.net = self.net;
    cloneOne.hasPushed = self.hasPushed;
    cloneOne.lastModified = self.lastModified;
    return cloneOne;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"lbsIP=%@,uploadHosts=%@, lbsHttpCode=%d, lbsSucc=%d, lbsUseTime=%lld,net=%@, hasPushed=%d, lastmodified=%lld",
            _lbsIP, _uploaderHosts, _lbsHttpCode, _lbsSucc, _lbsUseTime, _net, _hasPushed, _lastModified];
}

@end
