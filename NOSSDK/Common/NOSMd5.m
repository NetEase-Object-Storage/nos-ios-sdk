//
//  NOSMd5.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/19.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSMd5.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NOSMd5

+ (NSString*)md5:(NSString *)source {
    const char *cStr = [source UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString*)getMD5WithData:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (int)data.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++)
    { [ret appendFormat:@"%02x",result[i]]; }
    return ret;
}

@end
