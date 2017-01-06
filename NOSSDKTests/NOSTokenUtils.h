//
//  TokenUtils.h
//  NOSSDK
//
//  Created by NetEase on 2015/1/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOSTokenUtils : NSObject

+ (NSString *)genTokenWithBucket:(NSString *)bucket
                         withKey:(NSString *)key
                      withElipse:(UInt32)elipse
                   withAccessKey:(NSString *)accesskey
                   withSecretKey:(NSString *)secretkey;

@end
