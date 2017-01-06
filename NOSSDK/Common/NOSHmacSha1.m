//
//  NOSHmacSha1.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSHmacSha1.h"
#import "NOSBase64.h"

#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation NOSHmacSha1

+ (NSString *)hmacsha1:(NSString *)data
                secret:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hash = [NOSBase64 encodeData: HMACData];
    return hash;
}

@end
