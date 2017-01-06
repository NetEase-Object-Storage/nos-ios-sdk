//
//  NOSMd5.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/19.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOSMd5 : NSObject

+ (NSString*)md5:(NSString *)source;
+ (NSString*)getMD5WithData:(NSData *)data;

@end
