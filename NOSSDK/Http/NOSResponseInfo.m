//
//  NOSResponseInfo.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//


#import "NOSResponseInfo.h"
#import "NOSBase64.h"


const int kNOSFileError = -4;
const int kNOSInvalidArgument = -3;
const int kNOSRequestCancelled = -2;
const int kNOSNetworkError = -1;

static NOSResponseInfo *cancelledInfo = nil;

static NSString *domain = @"nos.netease.com";

@implementation NOSResponseInfo

+ (instancetype)cancel {
	return [[NOSResponseInfo alloc] initWithCancelled];
}

+ (instancetype)responseInfoWithInvalidArgument:(NSString *)text {
	return [[NOSResponseInfo alloc] initWithStatus:kNOSInvalidArgument errorDescription:text];
}

+ (instancetype)responseInfoWithNetError:(NSError *)error {
	return [[NOSResponseInfo alloc] initWithStatus:kNOSNetworkError error:error];
}

+ (instancetype)responseInfoWithFileError:(NSError *)error {
	return [[NOSResponseInfo alloc] initWithStatus:kNOSFileError error:error];
}

- (instancetype)initWithCancelled {
	return [self initWithStatus:kNOSRequestCancelled errorDescription:@"cancelled by user"];
}

- (instancetype)initWithStatus:(int)status
                         error:(NSError *)error {
	if (self = [super init]) {
		_statusCode = status;
		_error = error;
	}
	return self;
}

- (instancetype)initWithStatus:(int)status
              errorDescription:(NSString *)text {
	NSError *error = [[NSError alloc] initWithDomain:domain code:status userInfo:@{ @"error":text }];
	return [self initWithStatus:status error:error];
}

- (instancetype)init:(int)status
            withBody:(NSData *)body {
	if (self = [super init]) {
		_statusCode = status;

		if (status != 200) {
			if (body == nil) {
				_error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:nil];
			} else {
				NSError *tmp;
				NSDictionary *uInfo = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableLeaves error:&tmp];
				if (tmp != nil) {
					uInfo = @{ @"error":[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] };
                } else {
                    _requestID = uInfo[@"requestID"];
                }
				_error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:uInfo];
			}
		} else if (body == nil || body.length == 0) {
			NSDictionary *uInfo = @{ @"error":@"no response json" };
			_error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:uInfo];
        } else {
            NSError *tmp;
            NSDictionary *uInfo = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableLeaves error:&tmp];
            if (tmp != nil) {
                uInfo = @{ @"error":[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] };
                _error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:uInfo];
            } else {
                _requestID = uInfo[@"requestID"];
                _callbackRetMsg = uInfo[@"callbackRetMsg"];
                if (_callbackRetMsg) {
                    _callbackRetMsg = [NOSBase64 decodeString:_callbackRetMsg];
                }
            }
        }
	}
	return self;
}

- (NSString *)description {
	/*return [NSString stringWithFormat:@"<%@: %p, status: %d, requestId: %@, error: %@>", NSStringFromClass([self class]), self, _statusCode, _requestID, _error];*/
    return [NSString stringWithFormat:@"status: %d, requestId: %@, error: %@", self.statusCode, self.requestID, self.error];
}

- (BOOL)isCancelled {
	return _statusCode == kNOSRequestCancelled;
}

- (BOOL)isOK {
    // if return 200 but no body, then it is not a successful request!
    return _statusCode == 200 && _error == nil;
}

- (BOOL)isConnectionBroken {
    return _statusCode == kNOSNetworkError;
}

// will consider this method later
- (BOOL)couldRetry {
	/*return (_statusCode >= 500 && _statusCode < 600 && _statusCode != 579) || _statusCode == kNOSNetworkError || _statusCode == 996 || _statusCode == 406 || (_statusCode == 200 && _error != nil);*/
    return _statusCode == kNOSNetworkError || (_statusCode >= 500 && _statusCode != 520);
}

- (BOOL)isContextNotExist {
    return _statusCode == 404;
}

- (BOOL)isCallbackFailed {
    return _statusCode == 520;
}

@end
