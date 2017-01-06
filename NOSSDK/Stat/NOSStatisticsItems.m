//
//  NOSStatisticsItmes.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/22.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSStatisticsItems.h"
#import "NOSVersion.h"
#import "NOSIPToLong.h"

extern NSString *const kNOSplatform;

@implementation NOSStatisticsItems

- (NSString*) toJson {
    NSMutableString *jsonStr = [[NSMutableString alloc] init];
    [jsonStr appendString:@"{\n"];
    [jsonStr appendFormat:@"\"a\":\"%@\"", kNOSplatform];
    [jsonStr appendFormat:@",\n\"b\":%lld", [NOSIPToLong ipToLong:self.clientIP]];
    [jsonStr appendFormat:@",\n\"c\":\"%@\"", kNosVersion];
    if (self.lbsIP) {
        if ([self.lbsIP hasPrefix:@"http://"]) {
            self.lbsIP = [self.lbsIP substringFromIndex:[@"http://" length]];
        }
        if ([self.lbsIP hasSuffix:@"/lbs"]) {
            self.lbsIP = [self.lbsIP substringToIndex:[self.lbsIP length] - [@"/lbs" length]];
        }
    }
    
    if (!self.hasLbsPushed && self.lbsIP && self.lbsIP.length > 0) {
        [jsonStr appendFormat:@",\n\"d\":%lld", [NOSIPToLong ipToLong:self.lbsIP]];
    }
    
    NSString *uploadHost = nil;
    if (self.uploaderHosts) {
        uploadHost = self.uploaderHosts[self.uploaderIndex];
        if ([uploadHost hasPrefix:@"http://"]) {
            uploadHost = [uploadHost substringFromIndex:[@"http://" length]];
        }
    }
    [jsonStr appendFormat:@",\n\"e\":%lld", [NOSIPToLong ipToLong:uploadHost]];
    
    [jsonStr appendFormat:@",\n\"f\":%lld", self.dataSize];
    if (self.netEnv) {
        [jsonStr appendFormat:@",\n\"g\":\"%@\"", self.netEnv];
    }
    
    if (!self.hasLbsPushed) {
        [jsonStr appendFormat:@",\n\"h\":%lld", self.lbsUseTime];
    }
    [jsonStr appendFormat:@",\n\"i\":%lld", self.uploaderEndTime - self.uploaderStartTime];
    
    
    if (!self.hasLbsPushed && self.lbsSucc != 0) {
        [jsonStr appendFormat:@",\n\"j\":%d", self.lbsSucc];
    }
    
    if (self.uploaderSucc != 0) {
        [jsonStr appendFormat:@",\n\"k\":%d", self.uploaderSucc];
    }
    
    if (!self.hasLbsPushed && self.lbsHttpCode != 200) {
        [jsonStr appendFormat:@",\n\"l\":%d", self.lbsHttpCode];
    }
    
    if (self.uploaderHttpCode != 200) {
        [jsonStr appendFormat:@",\n\"m\":%d", self.uploaderHttpCode];
    }
    
    if (self.uploaderIndex != 0 ) {
        [jsonStr appendFormat:@",\n\"n\":%d", self.uploaderIndex];
    }
    
    if (self.chunkRetryCount != 0) {
        [jsonStr appendFormat:@",\n\"o\":%d", self.chunkRetryCount];
    }
    
    if (self.queryRetryCount != 0) {
        [jsonStr appendFormat:@",\n\"p\":%d", self.queryRetryCount];
    }
    
    [jsonStr appendFormat:@",\n\"q\":\"%@\"", self.bucketName];
    
    [jsonStr appendFormat:@"\n}"];
    return jsonStr;
}

@end