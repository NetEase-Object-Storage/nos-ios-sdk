//
//  TokenUtils.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSTokenUtils.h"
#import "NOSBase64.h"
#import "NOSHmacSha1.h"

@implementation NOSTokenUtils

+ (NSString *)genTokenWithBucket:(NSString *)bucket
                         withKey:(NSString *)key
                      withElipse:(UInt32)elipse
                   withAccessKey:(NSString *)accesskey
                   withSecretKey:(NSString *)secretkey {
    long long lTime = [[NSDate date] timeIntervalSince1970];
    lTime += elipse;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[@"Bucket"] = bucket;
    dic[@"Object"] = key;
    dic[@"Expires"] = [NSNumber numberWithInt:(int)elipse];
    NSString* policy = [NSString stringWithFormat:@"{\"Bucket\":\"%@\",\"Object\":\"%@\",\"Expires\":%llu}",
                        bucket, key, lTime];
    /*NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString* policy = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];*/
    NSLog(@"uploadPolicy = %@", policy);
    
    NSString* encodePutPolicy = [NOSBase64 encodeString: policy];
    NSString* encodedSign = [NOSHmacSha1 hmacsha1:encodePutPolicy
                                           secret:secretkey];
    NSString* token = [NSString stringWithFormat:@"UPLOAD %@:%@:%@", accesskey, encodedSign, encodePutPolicy];
    NSLog(@"token = %@", token);
    return token;
}

@end
