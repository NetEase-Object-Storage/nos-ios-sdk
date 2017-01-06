//
//  NOSBucketLBSMap.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2016/2/29.
//  Copyright (c) 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NOSLbsInfo.h"

@interface NOSBucketLBSMap : NSObject

@property (nonatomic) NSString *net;
@property NSMutableDictionary *bucketLbsMap;
@property NSUserDefaults *persistentMap;


- (void) addLbsInfo:(NOSLbsInfo*)lbsInfo
          forBucket:(NSString *)bucketName;

- (NOSLbsInfo*) lbsInfoSnapshot:(NSString *)bucketName;

- (NOSLbsInfo*) lbsInfoNewest:(NSString*)bucketName;

- (void) invalidLBSInfoForBucket:(NSString *)bucketName;

- (void) invalidLBSInfo;
@end
