//
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *    base64 编码类
 */
@interface NOSBase64 : NSObject

/**
 *    字符串编码
 *
 *    @param source 字符串
 *
 *    @return base64 字符串
 */
+ (NSString *)encodeString:(NSString *)source;

/**
 *    二进制数据编码
 *
 *    @param source 二进制数据
 *
 *    @return base64字符串
 */
+ (NSString *)encodeData:(NSData *)source;

/**
 *    将base64字符串反编码
 *
 *    @param base64Str base64字符串
 *
 *    @return base64字符串反编码后的结果
 */
+ (NSString *)decodeString:(NSString *)base64Str;

@end
