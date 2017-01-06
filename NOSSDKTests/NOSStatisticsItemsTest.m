//
//  NOSStatisticsItemsTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/23.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NOSStatisticsItems.h"

@interface NOSStatisticsItemsTest : XCTestCase

@end

@implementation NOSStatisticsItemsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NOSStatisticsItems *statItems = [[NOSStatisticsItems alloc] init];
    statItems.clientIP = nil;//@"1.1.1.1";
    statItems.lbsIP = @"http://2.2.2.2/lbs";
    statItems.uploaderHosts = [NSArray arrayWithObjects:@"http://3.3.3.3", nil];
    statItems.uploaderIndex = 0;
    statItems.dataSize = 1;
    statItems.netEnv = @"wifi";
    statItems.lbsUseTime = 2;
    statItems.uploaderStartTime = 3;
    statItems.uploaderEndTime = 8;
    statItems.lbsSucc = 1;
    statItems.uploaderSucc = 0;
    statItems.lbsHttpCode = 200;
    statItems.uploaderHttpCode = 403;
    statItems.chunkRetryCount = 3;
    statItems.queryRetryCount = 4;
    NSLog(@"%@", [statItems toJson]);
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
