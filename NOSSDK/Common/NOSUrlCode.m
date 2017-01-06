//
//  NOSUrlCode.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/21.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSUrlCode.h"

@implementation NOSUrlCode

+ (NSString *) urlEncode:(NSString *)source {
    NSString *escapedString = (NSString *)CFBridgingRelease(
                                    CFURLCreateStringByAddingPercentEscapes(
                                                NULL,
                                                (__bridge CFStringRef) source,
                                                NULL,
                                                CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                kCFStringEncodingUTF8));
    return escapedString;
}

@end
