//
//  NOSHttpManager.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSAFNetworking.h"

#import "NOSConfig.h"
#import "NOSHttpManager.h"
#import "NOSUserAgent.h"
#import "NOSResponseInfo.h"
#import "NOSUploadManager+Private.h"

@interface NOSHttpManager ()
@property (nonatomic) NOSAFHTTPRequestOperationManager *httpManager;
@end

static NSString *userAgent = nil;

@implementation NOSHttpManager

+ (void)initialize {
	userAgent = NOSUserAgent();
}

- (instancetype)init {
	if (self = [super init]) {
		_httpManager = [[NOSAFHTTPRequestOperationManager alloc] init];
		_httpManager.responseSerializer = [NOSAFJSONResponseSerializer serializer];
        
        // lbs server return json with uncorrect Content-Type(not text/json or application/json), we sadly have to add
        // the following statement. took much time to find the problem and its solution
        _httpManager.responseSerializer.acceptableContentTypes = nil;
        
        NOSAFSecurityPolicy *securityPolicy = [[NOSAFSecurityPolicy alloc] init];
        //[securityPolicy setAllowInvalidCertificates:YES];
        [_httpManager setSecurityPolicy:securityPolicy];
	}

	return self;
}

+ (NOSResponseInfo *)buildResponseInfo:(NOSAFHTTPRequestOperation *)operation
                            withError:(NSError *)error
                         withResponse:(id)responseObject {
	NOSResponseInfo *info;
	if (operation.response) {
		int status =  (int)[operation.response statusCode];
		info = [[NOSResponseInfo alloc] init:status withBody:responseObject];
	}
	else {
		info = [NOSResponseInfo responseInfoWithNetError:error];
	}
	return info;
}

- (void)  sendRequest:(NSMutableURLRequest *)request
    withCompleteBlock:(NOSCompleteBlock)completeBlock
    withProgressBlock:(NOSInternalProgressBlock)progressBlock {
	NOSAFHTTPRequestOperation *operation = [_httpManager
	                                     HTTPRequestOperationWithRequest:request
	                                                             success: ^(NOSAFHTTPRequestOperation *operation, id responseObject) {
	    NOSResponseInfo *info = [NOSHttpManager buildResponseInfo:operation withError:nil withResponse:operation.responseData];
	    NSDictionary *resp = nil;
	    if (info.isOK) {
	        resp = responseObject;
		}
	    completeBlock(info, resp);
	}                                                            failure: ^(NOSAFHTTPRequestOperation *operation, NSError *error) {
	    NOSResponseInfo *info = [NOSHttpManager buildResponseInfo:operation withError:error withResponse:operation.responseData];
	    completeBlock(info, nil);
	}];

	if (progressBlock) {
		[operation setUploadProgressBlock: ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		    progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
		}];
	}
	
	[_httpManager.operationQueue addOperation:operation];
}

- (void)         post:(NSString *)url
             withData:(NSData *)data
           withParams:(NSDictionary *)params
          withHeaders:(NSDictionary *)headers
    withCompleteBlock:(NOSCompleteBlock)completeBlock
    withProgressBlock:(NOSInternalProgressBlock)progressBlock
      withCancelBlock:(NOSCancelBlock)cancelBlock {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
	if (headers) {
		[request setAllHTTPHeaderFields:headers];
	}
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];

	[request setHTTPMethod:@"POST"];

	if (params) {
		[request setValuesForKeysWithDictionary:params];
	}
    
    if (data) {
        [request setHTTPBody:data];
    }
    
    // have not found a way to set connection time out, will try later.
    [request setTimeoutInterval:[[NOSUploadManager globalConf] NOSSoTimeout]];
    
	[self       sendRequest:request
          withCompleteBlock:completeBlock
          withProgressBlock:progressBlock];
}

- (void)         get:(NSString *)url
          withParams:(NSDictionary *)params
         withHeaders:(NSDictionary *)headers
   withCompleteBlock:(NOSCompleteBlock)completeBlock {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    if (headers) {
        [request setAllHTTPHeaderFields:headers];
    }
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [request setHTTPMethod:@"GET"];
    
    if (params) {
        [request setValuesForKeysWithDictionary:params];
    }
    
    // have not found a way to set connection time out, will try later.
    [request setTimeoutInterval:[[NOSUploadManager globalConf] NOSSoTimeout]];
    
    [self       sendRequest:request
          withCompleteBlock:completeBlock
          withProgressBlock:nil];}

@end
