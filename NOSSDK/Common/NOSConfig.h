//
//  NOSConfig.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/15.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOSConfig : NSObject

/**
 *    lbs地址
 */
@property (nonatomic, copy) NSString *NOSLbsHost;

/**
 *    socket 超时时间
 */
@property (nonatomic) UInt32 NOSSoTimeout;

/**
 *    连接超时时间
 */
//@property (nonatomic) UInt32 NOSConnectionTimeout;

/**
 *    刷新边缘节点地址的时间间隔
 */
@property (nonatomic) UInt32 NOSRefreshInterval;

/**
 *    断点上传时的分片大小
 */
@property (nonatomic) UInt32 NOSChunkSize;

/**
 *    统计监控程序统计发送间隔
 */
@property (nonatomic) UInt32 NOSMoniterInterval;

/**
 *    失败重试次数
 */
@property (nonatomic) UInt32 NOSRetryCount;

- (instancetype)init;

- (instancetype)initWithLbsHost:(NSString*) lbsHost
                  withSoTimeout:(UInt32) soTimeout
          //withConnectionTimeout:(UInt32) connectionTimeout
            withRefreshInterval:(UInt32) refreshInterval
                  withChunkSize:(UInt32) chunkSize
            withMoniterInterval:(UInt32) moniterInterval
                 withRetryCount:(UInt32) retryCount;

//- (NSString *)lbsUrl;
- (NSString *)statUrl;

@end
