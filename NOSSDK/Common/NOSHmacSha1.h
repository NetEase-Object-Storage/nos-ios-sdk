//
//  NOSHmacSha1.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOSHmacSha1 : NSObject

/**
 *   get base64 encoded HmacSha1 value for (data, key)
 *
 */
+ (NSString *)hmacsha1:(NSString *)data
                secret:(NSString *)key;

@end
