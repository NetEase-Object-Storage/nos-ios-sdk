//
//  NOSBucketLBSMap+Private.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2016.3.7.
//  Copyright (c) 2016年 NetEase. All rights reserved.
//


#import "NOSBucketLBSMap.h"

@interface NOSBucketLBSMap (Private)

+ (NSDictionary *) dicWithLbsInfo:(NOSLbsInfo*)lbsInfo;

+ (NSString *) bucketStrInPersistent:(NSString *) bucketName;

@end