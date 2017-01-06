//
//  NOSResumeUpload.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/11.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSResumeUpload.h"
#import "NOSUploadManager+Private.h"
#import "NOSBase64.h"
#import "NOSConfig.h"
#import "NOSResponseInfo.h"
#import "NOSHttpManager.h"
#import "NOSUploadOption+Private.h"
#import "NOSRecorderDelegate.h"
#import "NOSMd5.h"
#import "NOSUrlCode.h"
#import "NOSStatisticsItems.h"
#import "NOSIPUtils.h"
#import "NOSTimeUtils.h"

typedef void (^task)(void);

@interface NOSConfig()
+ (NSArray* )uploaderDefaultHosts;
@end

@interface NOSResumeUpload ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NOSHttpManager *httpManager;
@property UInt32 size;
@property (nonatomic, strong) NSString *protocal;
@property (nonatomic, strong) NSString *bucket;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *recorderKey;
@property (nonatomic) NSMutableDictionary *headers;
@property (nonatomic, strong) NOSUploadOption *option;
@property (nonatomic, strong) NOSUpCompletionHandler complete;
@property (nonatomic, strong) NSString *context;
@property (nonatomic, readonly, getter = isCancelled) BOOL cancelled;

@property int64_t modifyTime;
@property (nonatomic, strong) id <NOSRecorderDelegate> recorder;

@property NSString *chunkMd5;

- (void)putChunk:(NSString *)uphost
          offset:(UInt32)offset
            size:(UInt32)size
        complete:(NSString *)finished
        progress:(NOSInternalProgressBlock)progressBlock
        complete:(NOSCompleteBlock)complete;

@end

@implementation NOSResumeUpload

- (instancetype)initWithData:(NSData *)data
                    withSize:(UInt32)size
                withProtocal:(NSString *)protocal
                  withBucket:(NSString*)bucket
                     withKey:(NSString *)key
                   withToken:(NSString *)token
       withCompletionHandler:(NOSUpCompletionHandler)block
                  withOption:(NOSUploadOption *)option
              withModifyTime:(NSDate *)time
                withRecorder:(id <NOSRecorderDelegate> )recorder
             withRecorderKey:(NSString *)recorderKey
             withHttpManager:(NOSHttpManager *)http {
	if (self = [super init]) {
		_data = data;
		_size = size;
        _protocal = protocal;
        _bucket = [NOSUrlCode urlEncode:bucket];
		_key = [NOSUrlCode urlEncode:key];
		_option = option;
		_complete = block;
        _headers = [NSMutableDictionary dictionary];
        _headers[@"x-nos-token"] = token;
        _headers[@"Host"] = @"nosup-eastchina1.126.net";
        if (self.option && self.option.mimeType ) {
            _headers[@"Content-Type"] = self.option.mimeType;
        } else {
            _headers[@"Content-Type"] = @"";
        }
		_recorder = recorder;
		_httpManager = http;
		if (time != nil) {
			_modifyTime = [time timeIntervalSince1970];
		}
		_recorderKey = recorderKey;
	}
	return self;
}

/** 
 *  save json value, the format is as follows:
 *  {
 *      "size":filesize,
 *      "offset":lastSuccessOffset,
 *      "modify_time": lastFileModifyTime,
 *      "contexts": contexts
 *  }
 */
- (void)record:(UInt32)offset {
	NSString *key = self.recorderKey;
	if (offset == 0 || _recorder == nil || key == nil || [key isEqualToString:@""]) {
		return;
	}
	NSNumber *n_size = @(self.size);
	NSNumber *n_offset = @(offset);
	NSNumber *n_time = [NSNumber numberWithLongLong:_modifyTime];
	NSMutableDictionary *rec = [NSMutableDictionary dictionaryWithObjectsAndKeys:n_size, @"size", n_offset, @"offset", n_time, @"modify_time", _context, @"context", nil];

	NSError *error;
	NSData *data = [NSJSONSerialization dataWithJSONObject:rec options:NSJSONWritingPrettyPrinted error:&error];
	if (error != nil) {
		NSLog(@"up record json error %@ %@", key, error);
		return;
	}
	error = [_recorder set:key data:data];
	if (error != nil) {
		NSLog(@"up record set error %@ %@", key, error);
	}
}

- (void)removeRecord {
	if (_recorder == nil) {
		return;
	}
	[_recorder del:self.recorderKey];
}

/**
 *  因为续传要恢复,返回上传起始地址。
 *  返回0表示重新开始传
 *  1. size不一样了，说明文件大小变了，即本地文件改变了，所以要重新开始传，即返回0
 *  2. 文件的修改时间变了，这种情况下也是一样的，需要重新上传
 */
- (UInt32)recoveryFromRecord {
	NSString *key = self.recorderKey;
	if (_recorder == nil || key == nil || [key isEqualToString:@""]) {
		return 0;
	}

	NSData *data = [_recorder get:key];
	if (data == nil) {
		return 0;
	}

	NSError *error;
	NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
	if (error != nil) {
		NSLog(@"recovery error %@ %@", key, error);
		[_recorder del:self.key];
		return 0;
	}
	NSNumber *n_offset = info[@"offset"];
	NSNumber *n_size = info[@"size"];
	NSNumber *time = info[@"modify_time"];

    NSString *context = info[@"context"];
	if (n_offset == nil || n_size == nil || time == nil || context == nil) {
		return 0;
	}

	UInt32 offset = [n_offset unsignedIntValue];
	UInt32 size = [n_size unsignedIntValue];
	if (offset > size || size != self.size) {
		return 0;
	}
	UInt64 t = [time unsignedLongLongValue];
	if (t != _modifyTime) {
		NSLog(@"modify time changed %llu, %llu", t, _modifyTime);
		return 0;
	}
    _context = context;
	return offset;
}

- (void)nextTask:(UInt32)offset
    retriedTimes:(int)retried
        statInfo:(NOSStatisticsItems *)statItems
     fetchOffset:(BOOL)offsetTask {
	if (self.isCancelled) {
        statItems.uploaderSucc = 2;
        statItems.uploaderEndTime = [NOSTimeUtils currentMil];;
        [[NOSUploadManager statTimeTask] addAnStatItem:statItems];
		self.complete([NOSResponseInfo cancel], self.key, nil);
		return;
	}
    NSLog(@"retried: %d", retried);
	NOSInternalProgressBlock progressBlock = nil;

    if (!offsetTask && self.option && self.option.progressHandler) {
        // test show that: once a tcp package was sent, the progress block will be called.
        progressBlock = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            float percent = (float)(offset + totalBytesWritten) / (float)self.size;
            self.option.progressHandler(self.key, percent);
        };
    };
    
    NOSCompleteBlock completionHandler = ^(NOSResponseInfo *info, NSDictionary *resp) {
        statItems.uploaderHttpCode = info.statusCode;
        
		if (info.error != nil) {
            int nextIndex = statItems.uploaderIndex + 1;
            int nextRetried = retried + 1;
            
            // error happens, if do not need to retry, terminate;
            // else if had try max times and had tried all hosts, terminate;
            // else if had try max times and next host available, send request to it;
            // else retry
            if (!info.couldRetry || ((nextRetried >= [[NOSUploadManager globalConf] NOSRetryCount]) &&
                                     nextIndex >= [statItems.uploaderHosts count])) {
                statItems.uploaderSucc = 1;
                statItems.uploaderEndTime = [NOSTimeUtils currentMil];
                [[NOSUploadManager statTimeTask] addAnStatItem:statItems];
                if (info.isContextNotExist || info.isCallbackFailed) {
                    [self removeRecord];
                }
                
                if (info.couldRetry) {
                    [[NOSUploadManager bucketLbsMap] invalidLBSInfoForBucket:self.bucket];
                }
                
                self.complete(info, self.key, resp);
                return;
            } else if (nextRetried >= [[NOSUploadManager globalConf] NOSRetryCount]) {
                statItems.uploaderIndex = statItems.uploaderIndex + 1;
                nextRetried = 0;
            }
            
            if (offsetTask) {
                statItems.queryRetryCount = statItems.queryRetryCount + 1;
            } else {
                statItems.chunkRetryCount = statItems.chunkRetryCount + 1;
            }

            // retry
            [self nextTask:offset retriedTimes:nextRetried statInfo:statItems fetchOffset:offsetTask];
			return;
        }
        
        if (!offsetTask) {
            _context = resp[@"context"];
        }
        
        UInt32 nextOffset = [resp[@"offset"] unsignedIntValue];
        
        if (nextOffset > offset) {
            statItems.dataSize += nextOffset - offset;
        }
        
        if (nextOffset == self.size) {
            // upload finished: 1. remove record; 2. do upload callback
            [self removeRecord];
            statItems.uploaderEndTime = [NOSTimeUtils currentMil];
            statItems.uploaderSucc = 0;
            [[NOSUploadManager statTimeTask] addAnStatItem:statItems];
            self.complete(info, self.key, resp);
        } else {
            // the current chunk upload success，so 1. record it， 2. upload next chunk
            [self record:nextOffset];
            [self nextTask:nextOffset retriedTimes:0 statInfo:statItems fetchOffset:NO];
        }
        
        
	};
    
    if (offsetTask) {
        [self fetchOffsetAccordingContext:statItems.uploaderHosts[statItems.uploaderIndex]
                                 complete:completionHandler];
    } else {
        UInt32 chunkSize = [self calcPutSize:offset];
        
        NSString *finished = @"false";
        if (offset + chunkSize == self.size) {
            finished = @"true";
        }
    
        [self putChunk:statItems.uploaderHosts[statItems.uploaderIndex]
                offset:offset size:chunkSize complete:finished
              progress:progressBlock
              complete:completionHandler];
    }
}

- (UInt32)calcPutSize:(UInt32)offset {
	UInt32 left = self.size - offset;
	return left < [[NOSUploadManager globalConf] NOSChunkSize] ? left : [[NOSUploadManager globalConf] NOSChunkSize];
}

- (void)putChunk:(NSString *)uphost
          offset:(UInt32)offset
            size:(UInt32)size
        complete:(NSString *)finished
        progress:(NOSInternalProgressBlock)progressBlock
        complete:(NOSCompleteBlock)complete {
    uphost = [uphost substringFromIndex:[@"http://" length]];
	NSData *data = [self.data subdataWithRange:NSMakeRange(offset, (unsigned int)size)];
    
    /*if (self.option && self.option.checkMd5) {
        _headers[@"Content-MD5"] = [NOSMd5 getMD5WithData:data];
    }*/
    
    NSMutableString *url = [[NSMutableString alloc] init];
    [url appendString:[self protocal]];
    [url appendFormat:@"://%@/%@/%@?offset=%u&complete=%@&", uphost, self.bucket, self.key, (unsigned int)offset, finished];
    if (self.context) {
        [url appendFormat:@"context=%@&version=1.0", self.context];
    } else {
        [url appendFormat:@"version=1.0"];
    }
  
    [self post:url withData:data withCompleteBlock:complete withProgressBlock:progressBlock];
}

- (BOOL)isCancelled {
	return self.option && self.option.priv_isCancelled;
}


- (void)         post:(NSString *)url
             withData:(NSData *)data
    withCompleteBlock:(NOSCompleteBlock)completeBlock
    withProgressBlock:(NOSInternalProgressBlock)progressBlock {
	[_httpManager post:url withData:data withParams:nil withHeaders:_headers withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:nil];
}

- (void) fetchOffsetAccordingContext:(NSString *)uphost
                            complete:(NOSCompleteBlock)complete {
    uphost = [uphost substringFromIndex:[@"http://" length]];
    
    NSMutableString *url = [[NSMutableString alloc] init];
    [url appendString:[self protocal]];
    
    [url appendFormat:@"://%@/%@/%@?uploadContext&context=%@&version=1.0", uphost, self.bucket, self.key, self.context];
    
    [_httpManager   get:url  withParams:nil
             withHeaders:self.headers
       withCompleteBlock:complete];
}

- (void)run {
	@autoreleasepool {
		UInt32 offset = [self recoveryFromRecord];
        
        NOSStatisticsItems *statItems = [[NOSStatisticsItems alloc] init];
        NOSLbsInfo *curLbsInfo = [[NOSUploadManager bucketLbsMap] lbsInfoNewest:self.bucket];
        if (curLbsInfo) {
            statItems.lbsHttpCode = curLbsInfo.lbsHttpCode;
            statItems.lbsIP = curLbsInfo.lbsIP;
            statItems.lbsSucc = curLbsInfo.lbsSucc;
            statItems.lbsUseTime = curLbsInfo.lbsUseTime;
            statItems.uploaderHosts = curLbsInfo.uploaderHosts;
            statItems.uploaderIndex = 0;
            statItems.netEnv = [NOSUploadManager bucketLbsMap].net;
            statItems.hasLbsPushed = curLbsInfo.hasPushed;
        }
        statItems.clientIP = [NOSIPUtils localIP:YES];
        statItems.bucketName = self.bucket;
        statItems.uploaderStartTime = [NOSTimeUtils currentMil];
       
        // if non uploader hosts from lbs, use default
        if (statItems.uploaderHosts == nil) {
            statItems.uploaderHosts = [NOSConfig uploaderDefaultHosts];
        }
    
        if (self.context) {
            [self nextTask:offset retriedTimes:0 statInfo:statItems fetchOffset:YES];
        } else {
            [self nextTask:offset retriedTimes:0 statInfo:statItems fetchOffset:NO];
        }
        
	}
}

@end
