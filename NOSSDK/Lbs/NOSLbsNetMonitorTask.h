//
//  NOSLbsNetMonitorTask.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSLbsTask.h"

/**
 *    内部使用类
 */
@interface NOSLbsNetMonitorTask : NOSLbsTask

+ (instancetype)sharedInstanceAndRunWithCompleteHandler:(NOSLbsCompletionHandler) completeHandler;

@end
