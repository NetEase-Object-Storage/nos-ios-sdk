//
//  NOSUploadOption.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/11.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *    上传进度回调函数
 *
 *    @param key     上传时指定的存储key
 *    @param percent 进度百分比
 */
typedef void (^NOSUpProgressHandler)(NSString *key, float percent);

/**
 *    上传中途取消函数
 *
 *    @return 如果想取消，返回True, 否则返回No
 */
typedef BOOL (^NOSUpCancellationSignal)(void);

/**
 *    可选参数集合，此类初始化后sdk上传使用时 不会对此进行改变；如果参数没有变化以及没有使用依赖，可以重复使用。
 */
@interface NOSUploadOption : NSObject

/**
 *    用户自定义元数据，key必须以x-nos-meta-开头
 */
@property (copy, nonatomic, readonly) NSDictionary *metas;

/**
 *    指定文件的mime类型
 */
@property (copy, nonatomic, readonly) NSString *mimeType;

/**
 *    是否进行md5校验
 */
//@property (readonly) BOOL checkMd5;

/**
 *    进度回调函数
 */
@property (copy, readonly) NOSUpProgressHandler progressHandler;

/**
 *    中途取消函数
 */
@property (copy, readonly) NOSUpCancellationSignal cancellationSignal;

/**
 *    可选参数的初始化方法
 *
 *    @param mimeType     mime类型
 *    @param progress     进度函数
 *    @param params       自定义服务器回调参数
 *    @param check        是否进行md5检查
 *    @param cancellation 中途取消函数
 *
 *    @return 可选参数类实例
 */
- (instancetype)initWithMime:(NSString *)mimeType
             progressHandler:(NOSUpProgressHandler)progress
                      metas:(NSDictionary *)metas
                    //checkMd5:(BOOL)check
          cancellationSignal:(NOSUpCancellationSignal)cancellation;

- (instancetype)initWithProgessHandler:(NOSUpProgressHandler)progress;

@end
