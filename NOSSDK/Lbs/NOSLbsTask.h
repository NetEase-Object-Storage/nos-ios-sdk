//
//  NOSLbsTask.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NOSHttpManager.h"

typedef void (^NOSLbsCompletionHandler)(NSDictionary *resp, long long lbsUseTime, int lbsHttpCode, int lbsSucc, NSString *net);

/**
 *    内部使用类
 */
@interface NOSLbsTask : NSObject

- (instancetype) initWithCompleteHandler:(NOSLbsCompletionHandler) completeHandler;
- (void) fetchUploaderHosts:(NSString *)bucketName;

@end
