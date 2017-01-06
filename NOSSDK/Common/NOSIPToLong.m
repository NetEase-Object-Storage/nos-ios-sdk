//
//  NOSIPToLong.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/27.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSIPToLong.h"

@implementation NOSIPToLong

+ (long long)ipToLong:(NSString *)ip {
    if (!ip || [ip length] < 1) return 0;
    long long result = 0;
    @try {
        for (int i = 0; i < 3; ++i) {
            NSRange pos = [ip rangeOfString:@"."];
            int temp = [[ip substringToIndex:pos.location] intValue];
            result = (result << 8) + temp;
            ip = [ip substringFromIndex:pos.location + 1];
            if (i == 2) {
                result = (result << 8) + [ip intValue];
            }
        }
    } @catch (NSException *e) {
        return 0;
    }
   
    return result;
}

@end
