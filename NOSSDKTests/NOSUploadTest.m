//
//  NOSResumeUploadTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGAsyncTestHelper.h>

#import "NOSSDK.h"
#import "NOSTempFile.h"
#import "NOSTestConf.h"
#import "NOSTokenUtils.h"
#import "NOSUrlCode.h"

@interface NOSUploadTest : XCTestCase
@property NOSUploadManager *upManager;
@property BOOL inTravis;
@end

@implementation NOSUploadTest

- (void)setUp {
	[super setUp];
    [NOSUploadManager setGlobalConf:[NOSTestConf testNOSConf]];
	_upManager = [[NOSUploadManager alloc] init];
}

- (void)tearDown {
	[super tearDown];
}

/**
 * 1. test cancel upload
 */
- (void)testCancel {
	int size = 6 * 1024;
	NSURL *tempFile = [NOSTempFile createTempfileWithSize:size * 1024];
	NSString *keyUp = [NSString stringWithFormat:@"%dk", size];
	__block NSString *key = nil;
	__block NOSResponseInfo *info = nil;
    __block NSDictionary *res = nil;
	__block BOOL flag = NO;
	NOSUploadOption *opt = [[NOSUploadOption alloc] initWithMime:nil progressHandler: ^(NSString *key, float percent) {
	    flag = YES;
	} metas:nil /*checkMd5:NO*/ cancellationSignal: ^BOOL () {
	    return flag;
	}];
    [_upManager putFileByHttp:tempFile.path
                       bucket:kNOSTestBucket
                          key:keyUp
                        token:[NOSTokenUtils genTokenWithBucket:kNOSTestBucket withKey:keyUp withElipse:1000
                                                  withAccessKey:kNOSTestAccessKey
                                                  withSecretKey:kNOSTestSecretKey]
                     complete:^(NOSResponseInfo *i, NSString *k, NSDictionary *resp) {
	    key = k;
	    info = i;
        res = resp;
	} option:opt];

	AGWW_WAIT_WHILE(key == nil && res == nil, 60 * 30);
	NSLog(@"info %@", info);
	XCTAssert(info.isCancelled, @"Pass");
	XCTAssert([keyUp isEqualToString:key], @"Pass");

	[NOSTempFile removeTempfile:tempFile];
}

- (void)test1k {
	[self template:1];
}

- (void)test0k {
    [self template:0];
}

/**
 * 1. test http 2. test multiple chunk upload 3. test progress
 */
- (void)test600k {
	[self template:600];
    //[NSThread sleepForTimeInterval:20];
    //[self template:700];
}

/**
 * test upload two files, one by one
 */
- (void)testMultipleUpload {
    [self template:100000];
    [self template:12000];
}

- (void)template:(int)size {
    NSURL *tempFile = [NOSTempFile createTempfileWithSize:size * 1024];
    
    NSString *keyUp = [NSString stringWithFormat:@"%dk", size];
    __block NSString *key = nil;
    __block NOSResponseInfo *info = nil;
    
    NOSUploadOption *opt = [[NOSUploadOption alloc] initWithProgessHandler: ^(NSString *key, float percent) {
        //NSLog(@"progress %f", percent);
    }];
    
    [_upManager putFileByHttp:tempFile.path
                       bucket:kNOSTestBucket
                          key:keyUp
                        token:[NOSTokenUtils genTokenWithBucket:kNOSTestBucket withKey:keyUp withElipse:1000
                                                  withAccessKey:kNOSTestAccessKey
                                                  withSecretKey:kNOSTestSecretKey]
                     complete: ^(NOSResponseInfo *i, NSString *k, NSDictionary *resp) {
                         key = k;
                         info = i;
                     }
                       option:opt];
    
    AGWW_WAIT_WHILE(key == nil, 60 * 30);
    XCTAssert(info, @"PASS");
    XCTAssert(!info.isCancelled, @"Pass");
    XCTAssert(!info.isConnectionBroken, @"Pass");
    NSLog(@"info %@", info);
    XCTAssert(info.isOK, @"Pass");
    XCTAssert(info.statusCode == 200, @"Pass");
    XCTAssert(info.error == nil, @"Pass");
    XCTAssert([keyUp isEqualToString:key], @"Pass");
    
    [NOSTempFile removeTempfile:tempFile];
}

/**
 * 1. test https  2. test mime type
 */
- (void)testUploadByHttps {
    NSDictionary *meta = [NSDictionary dictionaryWithObjectsAndKeys:@"100", @"x-nos-meta-width", nil];
    NOSUploadOption *option = [[NOSUploadOption alloc] initWithMime:@"image/jpeg"
                                                    progressHandler:^(NSString *key, float percent) {
                                                        NSLog(@"current progress:%f", percent);
                                                    }
                                                              metas:meta
                                                           /*checkMd5:YES*/
                                                 cancellationSignal:^BOOL{
                                                     return NO;
                                                 }];
    NSString *localFileName = @"/Users/future/Desktop/aa.gif";
    NSString *key = @"zhbtest.jpg";
    NSString* token = [NOSTokenUtils genTokenWithBucket:kNOSTestBucket
                                                withKey:key
                                             withElipse:1000
                                          withAccessKey:kNOSTestAccessKey
                                          withSecretKey:kNOSTestSecretKey];
    
    BOOL __block finished = NO;
    [_upManager putFileByHttps:localFileName bucket:kNOSTestBucket key:key
                        token:token
                     complete:^(NOSResponseInfo *info, NSString *key, NSDictionary *resp) {
                         NSLog(@"finished!");
                         NSLog(@"%@", info);
                         NSLog(@"%@", resp);
                         XCTAssert([info isOK], @"PASS");
                         finished = YES;
                     }
                       option:option];
    
    AGWW_WAIT_WHILE(!finished, 100);
}

/**
 * 测试特殊字符上传
 */
- (void)testKeyWithSpecialChar {
    NSDictionary *meta = [NSDictionary dictionaryWithObjectsAndKeys:@"100", @"x-nos-meta-width", nil];
    NOSUploadOption *option = [[NOSUploadOption alloc] initWithMime:@"image/jpeg"
                                                    progressHandler:^(NSString *key, float percent) {
                                                        NSLog(@"current progress:%f", percent);
                                                    }
                                                              metas:meta
                                                           /*checkMd5:YES*/
                                                 cancellationSignal:^BOOL{
                                                     return NO;
                                                 }];
    NSString *localFileName = @"/Users/future/Desktop/aa.gif";
    NSString *key = @"特殊字符`-=[]\\;',./ ~!@#$%^&*()_+{}|:\"<>?.jpg";
    NSString* token = [NOSTokenUtils genTokenWithBucket:kNOSTestBucket
                                                withKey:@"特殊字符`-=[]\\\\;',./ ~!@#$%^&*()_+{}|:\\\"<>?.jpg"
                                             withElipse:1000
                                          withAccessKey:kNOSTestAccessKey
                                          withSecretKey:kNOSTestSecretKey];
    
    BOOL __block finished = NO;
    [_upManager putFileByHttp:localFileName bucket:kNOSTestBucket key:key
                         token:token
                      complete:^(NOSResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"finished!");
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          XCTAssert([info isOK], @"PASS");
                          finished = YES;
                      }
                        option:option];
    
    AGWW_WAIT_WHILE(!finished, 100);
}

@end
