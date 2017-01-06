//
//  NOSHttpTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGAsyncTestHelper.h>

#import "NOSHttpManager.h"
#import "NOSResponseInfo.h"
#import "NOSTestConf.h"
#import "NOSUploadManager+Private.h"

@interface NOSHttpTest : XCTestCase
@property NOSHttpManager *httpManager;
@end

@implementation NOSHttpTest

- (void)setUp {
	[super setUp];
    [NOSUploadManager setGlobalConf:[NOSTestConf testNOSConf]];
	_httpManager = [[NOSHttpManager alloc] init];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testPost {
	__block NOSResponseInfo *testInfo = nil;
	NSData *data = [@"Hello, World!" dataUsingEncoding : NSUTF8StringEncoding];
	[_httpManager post:@"http://www.baidu.com" withData:data withParams:nil withHeaders:nil withCompleteBlock: ^(NOSResponseInfo *info, NSDictionary *resp) {
	    testInfo = info;
	} withProgressBlock:nil withCancelBlock:nil];
	AGWW_WAIT_WHILE(testInfo == nil, 100.0);
	NSLog(@"%@", testInfo);

	XCTAssert(testInfo.requestID == nil, @"Pass");

	testInfo = nil;

	[_httpManager post:@"http://httpbin.org/status/500" withData:nil withParams:nil withHeaders:nil withCompleteBlock: ^(NOSResponseInfo *info, NSDictionary *resp) {
	    testInfo = info;
	} withProgressBlock:nil withCancelBlock:nil];

	AGWW_WAIT_WHILE(testInfo == nil, 100.0);
	NSLog(@"%@", testInfo);
	XCTAssert(testInfo.statusCode == 500, @"Pass");
	XCTAssert(testInfo.error != nil, @"Pass");

	testInfo = nil;
	[_httpManager post:@"http://httpbin.org/status/418" withData:nil withParams:nil withHeaders:nil withCompleteBlock: ^(NOSResponseInfo *info, NSDictionary *resp) {
	    testInfo = info;
	} withProgressBlock:nil withCancelBlock:nil];

	AGWW_WAIT_WHILE(testInfo == nil, 100.0);
	NSLog(@"%@", testInfo);
	XCTAssert(testInfo.statusCode == 418, @"Pass");
	XCTAssert(testInfo.error != nil, @"Pass");

	testInfo = nil;
	[_httpManager post:@"http://httpbin.org/status/200" withData:nil withParams:nil withHeaders:nil withCompleteBlock: ^(NOSResponseInfo *info, NSDictionary *resp) {
	    testInfo = info;
	} withProgressBlock:nil withCancelBlock:nil];

	AGWW_WAIT_WHILE(testInfo == nil, 100.0);
	NSLog(@"%@", testInfo);
	XCTAssert(testInfo.statusCode == 200, @"Pass");
	XCTAssert(!testInfo.isOK, @"Pass");
	XCTAssert(testInfo.error != nil, @"Pass");
}

@end
