//
//  NOSUploadOption.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/11.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSUploadOption+Private.h"

@implementation NOSUploadOption

- (instancetype)initWithProgessHandler:(NOSUpProgressHandler)progress {
	if (self = [super init]) {
		_progressHandler = progress;
	}
	return self;
}

+ (NSDictionary *)filteParam:(NSDictionary *)params {
	if (params == nil) {
		return nil;
	}
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];

	[params enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *obj, BOOL *stop) {
	    if ([key hasPrefix:@"x-nos-meta-"] && ![obj isEqualToString:@""]) {
	        ret[key] = obj;
		}
	}];

	return ret;
}

- (instancetype)initWithMime:(NSString *)mimeType
             progressHandler:(NOSUpProgressHandler)progress
                      metas:(NSDictionary *)metas
                    //checkMd5:(BOOL)check
          cancellationSignal:(NOSUpCancellationSignal)cancel {
	if (self = [super init]) {
		_mimeType = mimeType;
		_progressHandler = progress;
		_metas = [NOSUploadOption filteParam:metas];
        //_checkMd5 = check;
		_cancellationSignal = cancel;
	}

	return self;
}

- (BOOL)priv_isCancelled {
	return _cancellationSignal && _cancellationSignal();
}

@end
