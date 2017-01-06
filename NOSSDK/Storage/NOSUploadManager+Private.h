//
//  NOSUploadManager+Private.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/16.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSUploadManager.h"
#import "NOSStatTimeTask.h"
#import "NOSBucketLBSMap.h"
#import "NOSLbsTask.h"

@interface NOSUploadManager (Private)

/**
 *    get global configuration
 */
+ (NOSConfig*) globalConf;

+ (NOSBucketLBSMap*) bucketLbsMap;

+ (NOSStatTimeTask*) statTimeTask;

+ (NOSLbsTask*) lbsTask;

@end
