//
//  NOSStatisticsItems.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/22.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOSStatisticsItems : NSObject

@property NSString *clientIP;


@property NSArray* uploaderHosts;
@property int uploaderIndex;

@property long long dataSize;

@property long long uploaderStartTime;
@property long long uploaderEndTime;

@property int uploaderSucc;
@property int uploaderHttpCode;

@property NSString *lbsIP;
@property NSString *netEnv;
@property long long lbsUseTime;
@property int lbsSucc;
@property int lbsHttpCode;


@property int chunkRetryCount;

// query offset重试次数
@property int queryRetryCount;

// 本次上传共试了多少个upload hosts
//@property int uploadRetryCount; 使用uploadIndex

@property NSString *bucketName;

@property BOOL hasLbsPushed;


- (NSString*) toJson;

@end
