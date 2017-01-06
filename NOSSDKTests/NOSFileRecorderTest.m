//
//  NOSFileRecorderTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/19.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGAsyncTestHelper.h>

#import "NOSSDK.h"
#import "NOSFileRecorder.h"
#import "NOSTempFile.h"
#import "NOSTestConf.h"
#import "NOSTokenUtils.h"
#import "NOSMd5.h"

@interface NOSFileRecorderTest : XCTestCase
@property NOSUploadManager *upManager;
@end

@implementation NOSFileRecorderTest

- (void)setUp {
	[super setUp];
    [NOSUploadManager setGlobalConf:[NOSTestConf testNOSConf]];
	NSError *error = nil;
    NSString *dir = [NSTemporaryDirectory() stringByAppendingString:@"nos-ios-sdk-test"];
    NSLog(@"%@", dir);
	NOSFileRecorder *file = [NOSFileRecorder fileRecorderWithFolder:dir error:&error];
	NSLog(@"recoder error %@", error);
    NOSRecorderKeyGenerator keyGen = ^(NSString *uploadKey, NSString *filePath) {
        return [NOSMd5 md5:uploadKey];
    };
    _upManager = [[NOSUploadManager alloc] initWithRecorder:file recorderKeyGenerator:keyGen];
}

- (void)testInit {
	NSError *error = nil;
	[NOSFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:@"nos-ios-sdk-test"] error:&error];
	XCTAssert(error == nil, @"Pass");
	[NOSFileRecorder fileRecorderWithFolder:@"/nos-ios-sdk-test" error:&error];
	NSLog(@"file recorder %@", error);
	XCTAssert(error != nil, @"Pass");
	[NOSFileRecorder fileRecorderWithFolder:@"/nos-ios-sdk-test" error:nil];
}

- (void)template:(int)size pos:(float)pos {
	NSURL *tempFile = [NOSTempFile createTempfileWithSize:size * 1024];
    NSLog(@"%@", tempFile.path);
    
	NSString *keyUp = [NSString stringWithFormat:@"r-%dk", size];
	__block NSString *key = nil;
	__block NOSResponseInfo *info = nil;
	__block BOOL flag = NO;
    
    NSString* token = [NOSTokenUtils genTokenWithBucket:kNOSTestBucket
                                                withKey:keyUp
                                             withElipse:10000
                                          withAccessKey:kNOSTestAccessKey
                                          withSecretKey:kNOSTestSecretKey];
    
	NOSUploadOption *opt = [[NOSUploadOption alloc] initWithMime:nil progressHandler: ^(NSString *key, float percent) {
	    if (percent >= pos) {
	        flag = YES;
		}
	    NSLog(@"progress %f", percent);
	} metas:nil /*checkMd5:NO*/ cancellationSignal: ^BOOL () {
	    return flag;
	}];
    
    [_upManager putFileByHttp:tempFile.path bucket:kNOSTestBucket key:keyUp
                        token:token
                     complete:^(NOSResponseInfo *i, NSString *k, NSDictionary *resp) {
                         key = k;
                         info = i;
                     }
                       option:opt];
    
	AGWW_WAIT_WHILE(key == nil, 60 * 30);
	NSLog(@"info %@", info);
	XCTAssert(info.statusCode == kNOSRequestCancelled, @"Pass");
	XCTAssert([keyUp isEqualToString:key], @"Pass");

	// continue
	key = nil;
	info = nil;
	__block BOOL failed = NO;
    
	opt = [[NOSUploadOption alloc] initWithMime:nil progressHandler: ^(NSString *key, float percent) {
	    if (percent < pos/* - kNOSTestChunkSize / (size * 1024.0)*/) {
	        failed = YES;
		}
	    NSLog(@"continue progress %f", percent);
	} metas:nil /*checkMd5:NO*/ cancellationSignal:nil];
    
    [_upManager putFileByHttp:tempFile.path bucket:kNOSTestBucket key:keyUp
                        token:token
                     complete:^(NOSResponseInfo *i, NSString *k, NSDictionary *resp) {
                         key = k;
                         info = i;
                     }
                       option:opt];
    
	AGWW_WAIT_WHILE(key == nil, 60 * 30);
	NSLog(@"info %@", info);
	XCTAssert(info.isOK, @"Pass");
	XCTAssert(!failed, @"Pass");
	XCTAssert([keyUp isEqualToString:key], @"Pass");
	[NOSTempFile removeTempfile:tempFile];
}

- (void)tearDown {
	[super tearDown];
}

/**
 *  测试断点续传
 */
- (void)test600k {
	[self template:600 pos:0.7];
}

- (void)test700k {
	[self template:700 pos:0.1];
}

@end
