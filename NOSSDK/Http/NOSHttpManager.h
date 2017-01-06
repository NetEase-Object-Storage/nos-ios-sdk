//
//  HttpManager.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NOSResponseInfo;

typedef void (^NOSInternalProgressBlock)(long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^NOSCompleteBlock)(NOSResponseInfo *info, NSDictionary *resp);
typedef BOOL (^NOSCancelBlock)(void);

@interface NOSHttpManager : NSObject

- (void)         post:(NSString *)url
             withData:(NSData *)data
           withParams:(NSDictionary *)params
          withHeaders:(NSDictionary *)headers
    withCompleteBlock:(NOSCompleteBlock)completeBlock
    withProgressBlock:(NOSInternalProgressBlock)progressBlock
      withCancelBlock:(NOSCancelBlock)cancelBlock;

- (void)         get:(NSString *)url
           withParams:(NSDictionary *)params
          withHeaders:(NSDictionary *)headers
    withCompleteBlock:(NOSCompleteBlock)completeBlock;

@end
