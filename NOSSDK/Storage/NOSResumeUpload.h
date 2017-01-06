//
//  NOSResumeUpload.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/11.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NOSUploadManager.h"

@class NOSHttpManager;
@interface NOSResumeUpload : NSObject

- (instancetype)initWithData:(NSData *)data
                    withSize:(UInt32)size
                withProtocal:(NSString *)protocal
                  withBucket:(NSString *)bucket
                     withKey:(NSString *)key
                   withToken:(NSString *)token
       withCompletionHandler:(NOSUpCompletionHandler)block
                  withOption:(NOSUploadOption *)option
              withModifyTime:(NSDate *)time
                withRecorder:(id <NOSRecorderDelegate> )recorder
             withRecorderKey:(NSString *)recorderKey
             withHttpManager:(NOSHttpManager *)http;

- (void)run;

@end
