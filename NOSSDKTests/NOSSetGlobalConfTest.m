//
//  NOSSetGlobalConfTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/20.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NOSUploadManager+Private.h"
#import "NOSTestConf.h"

@interface NOSSetGlobalConfTest : XCTestCase

@end

@implementation NOSSetGlobalConfTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    [NOSUploadManager setGlobalConf:[NOSTestConf testNOSConf]];
    NOSConfig *conf = [NOSUploadManager globalConf];
    XCTAssert(conf.NOSChunkSize == kNOSTestChunkSize, @"PASS");
    conf.NOSChunkSize = 64 * 1024;
    XCTAssert([NOSUploadManager globalConf].NOSChunkSize == 64 * 1024, @"PASS");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
