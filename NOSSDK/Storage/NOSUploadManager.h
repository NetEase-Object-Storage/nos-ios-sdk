//
//  NOSUploader.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/16.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NOSRecorderDelegate.h"
#import "NOSConfig.h"

@class NOSResponseInfo;
@class NOSUploadOption;

/**
 *    上传完成后的回调函数
 *
 *    @param info 上下文信息，包括状态码，错误值
 *    @param key  上传时指定的key，原样返回
 *    @param resp 上传成功会返回文件信息，失败为nil; 可以通过此值是否为nil 判断上传结果
 */
typedef void (^NOSUpCompletionHandler)(NOSResponseInfo *info, NSString *key, NSDictionary *resp);

/**
 *    为持久化上传记录，根据上传的key以及文件名 生成持久化的记录key
 *
 *    @param uploadKey 上传的key
 *    @param filePath  文件名
 *
 *    @return 根据uploadKey, filepath 算出的记录key
 */
typedef NSString *(^NOSRecorderKeyGenerator)(NSString *uploadKey, NSString *filePath);

/**
   管理上传的类，可以生成一次，持续使用，不必反复创建。
 */
@interface NOSUploadManager : NSObject

/**
 *    默认构造方法，没有持久化记录
 *
 *    @return 上传管理类实例
 */
- (instancetype)init;

/**
 *    使用一个持久化的记录接口进行记录的构造方法
 *
 *    @param recorder 持久化记录接口实现
 *
 *    @return 上传管理类实例
 */
- (instancetype)initWithRecorder:(id <NOSRecorderDelegate> )recorder;

/**
 *    使用持久化记录接口以及持久化key生成函数的构造方法，默认情况下使用上传存储的key, 如果key为nil或者有特殊字符比如/，建议使用自己的生成函数
 *
 *    @param recorder             持久化记录接口实现
 *    @param recorderKeyGenerator 持久化记录key生成函数
 *
 *    @return 上传管理类实例
 */
- (instancetype)initWithRecorder:(id <NOSRecorderDelegate> )recorder
            recorderKeyGenerator:(NOSRecorderKeyGenerator)recorderKeyGenerator;

/**
 *    方便使用的单例方法
 *
 *    @param recorder             持久化记录接口实现
 *    @param recorderKeyGenerator 持久化记录key生成函数
 *
 *    @return 上传管理类实例
 */
+ (instancetype)sharedInstanceWithRecorder:(id <NOSRecorderDelegate> )recorder
                      recorderKeyGenerator:(NOSRecorderKeyGenerator)recorderKeyGenerator;

/**
 *    用http上传文件
 *
 *    @param filePath          文件路径
 *    @param key               上传到云存储的key
 *    @param token             上传需要的token, 由服务器生成
 *    @param completionHandler 上传完成后的回调函数
 *    @param option            上传时传入的可选参数
 */
- (void)putFileByHttp:(NSString *)filePath
         bucket:(NSString*)bucket
            key:(NSString *)key
          token:(NSString *)token
       complete:(NOSUpCompletionHandler)completionHandler
         option:(NOSUploadOption *)option;

/**
 *    用https上传文件
 *
 *    @param filePath          文件路径
 *    @param key               上传到云存储的key
 *    @param token             上传需要的token, 由服务器生成
 *    @param completionHandler 上传完成后的回调函数
 *    @param option            上传时传入的可选参数
 */
- (void)putFileByHttps:(NSString *)filePath
               bucket:(NSString*)bucket
                  key:(NSString *)key
                token:(NSString *)token
             complete:(NOSUpCompletionHandler)completionHandler
               option:(NOSUploadOption *)option;

/**
 *    configuration is global
 */
+ (void)setGlobalConf:(NOSConfig*) conf;

@end