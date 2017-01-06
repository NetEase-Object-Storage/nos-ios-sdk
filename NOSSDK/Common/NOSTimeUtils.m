//
//  NOSTimeUtils.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/27.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSTimeUtils.h"

@implementation NOSTimeUtils

+ (long long) currentMil {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

@end
