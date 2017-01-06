//
//  NOSLbsInfo.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/23.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOSLbsInfo : NSObject

@property (nonatomic) NSString *lbsIP;
@property (nonatomic) NSArray *uploaderHosts;
@property (nonatomic) long long lbsUseTime;
@property (nonatomic) int lbsSucc;
@property (nonatomic) int lbsHttpCode;
@property (nonatomic) NSString *net;
@property (nonatomic) long long lastModified;
@property (nonatomic) BOOL hasPushed;

- (instancetype) init;
- (NOSLbsInfo *) clone;

@end
