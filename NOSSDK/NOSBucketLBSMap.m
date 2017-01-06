//
//  NOSBucketLBSMap.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2016/2/29.
//  Copyright (c) 2016年 NetEase. All rights reserved.
//

#import "NOSBucketLBSMap.h"
#import "NOSUploadManager+Private.h"
#import "NOSTimeUtils.h"

static NSString* const kNOSUploadHostsStr = @"uploadHosts";
static NSString* const kNOSLbsIpStr = @"lbsIp";
static NSString* const kNOSLastModified = @"lastModified";
static NSString* const kNOSBucketPrifix = @"NOSBucketName_";


@implementation NOSBucketLBSMap

- (instancetype)init {
    if (self = [super init]) {
        _bucketLbsMap = [[NSMutableDictionary alloc] init];
        _persistentMap = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void) addLbsInfo:(NOSLbsInfo*)lbsInfo
          forBucket:(NSString *)bucketName {
    if (!bucketName || !lbsInfo) {
        return;
    }
    
    NSDictionary *dic = [NOSBucketLBSMap dicWithLbsInfo:lbsInfo];
    
    @synchronized(_bucketLbsMap) {
        //NOSLbsInfo *temp = [_bucketLbsMap objectForKey:bucketName];
        //if (temp) {
        //    lbsInfo.net = temp.net;
        //}
        [_bucketLbsMap setObject:lbsInfo
                      forKey:bucketName];
        [_persistentMap setObject:dic
                           forKey:[NOSBucketLBSMap bucketStrInPersistent:bucketName]];
    }
}

+ (NSDictionary *) dicWithLbsInfo:(NOSLbsInfo*)lbsInfo {
    if (!lbsInfo) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:lbsInfo.uploaderHosts, kNOSUploadHostsStr,
            lbsInfo.lbsIP, kNOSLbsIpStr, [NSNumber numberWithLongLong:lbsInfo.lastModified], kNOSLastModified, nil];
}

+ (NSString *) bucketStrInPersistent:(NSString *) bucketName {
    return [NSString stringWithFormat:@"%@%@", kNOSBucketPrifix, bucketName];
}

- (void) invalidLBSInfoForBucket:(NSString *)bucketName {
    @synchronized(_bucketLbsMap) {
        NOSLbsInfo *lbsInfo = [_bucketLbsMap objectForKey:bucketName];
        if (lbsInfo) {
            lbsInfo.lastModified = 0;
            NSDictionary *dic = [NOSBucketLBSMap dicWithLbsInfo:lbsInfo];
            [_persistentMap setObject:dic
                               forKey:[NOSBucketLBSMap bucketStrInPersistent:bucketName]];
        }
    }
}

- (void) invalidLBSInfo {
    @synchronized(_bucketLbsMap) {
        for (NSString * bucket in _bucketLbsMap) {
            NOSLbsInfo *lbsInfo = [_bucketLbsMap objectForKey:bucket];
            lbsInfo.lastModified = 0;
            NSDictionary *dic = [NOSBucketLBSMap dicWithLbsInfo:lbsInfo];
            [_persistentMap setObject:dic
                               forKey:[NOSBucketLBSMap bucketStrInPersistent:bucket]];
        }
    }
}

- (NOSLbsInfo*) lbsInfoSnapshot:(NSString *)bucketName {
    NOSLbsInfo *lbsInfo = [_bucketLbsMap objectForKey:bucketName];
        
    if (!lbsInfo) {
        NSDictionary *dic = [_persistentMap dictionaryForKey:[NOSBucketLBSMap bucketStrInPersistent:bucketName]];
        if (dic) {
            lbsInfo = [[NOSLbsInfo alloc] init];
            lbsInfo.uploaderHosts = [dic objectForKey:kNOSUploadHostsStr];
            lbsInfo.lbsIP = [dic objectForKey:kNOSLbsIpStr];
            lbsInfo.lastModified = [[dic objectForKey:kNOSLastModified] longLongValue];
            lbsInfo.hasPushed = YES;
            [self addLbsInfo:lbsInfo forBucket:bucketName];
        }
    }
    
    if (!lbsInfo) {
        return nil;
    }
        
    NOSLbsInfo *tempInfo = [lbsInfo clone];
    //lbsInfo.hasPushed = YES;
    return tempInfo;
}

- (NOSLbsInfo*) lbsInfoNewest:(NSString*)bucketName {
    NOSLbsInfo *lbsInfo = [self lbsInfoSnapshot:bucketName];
    
    BOOL isNew = NO;
    if (!lbsInfo || lbsInfo.lastModified + 1000 * [[NOSUploadManager globalConf] NOSRefreshInterval] <= [NOSTimeUtils currentMil]) {
        NOSLbsTask* lbsTask = [NOSUploadManager lbsTask];
        [lbsTask fetchUploaderHosts: bucketName];
        isNew = YES;
    }
    
    NOSLbsInfo *resLbsInfo = [self lbsInfoSnapshot:bucketName];
    if (isNew) {
        resLbsInfo.hasPushed = NO;
    }
    return resLbsInfo;
}


@end
