//
//  NOSLbsTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/15.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <AGAsyncTestHelper.h>
#import "NOSUploadManager+Private.h"
#import "NOSTestConf.h"

@interface NOSLbsTest : XCTestCase

@end

@implementation NOSLbsTest

- (void)setUp {
    [super setUp];
    [NOSUploadManager setGlobalConf:[NOSTestConf testNOSConf]];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLbsTimerTask {
    BOOL __block inProgess = YES;
    
    /*
    NOSLbsTimerTask *timerTask = [[NOSLbsTimerTask alloc] initWithCompleteHandler:^(NSDictionary *resp,
                                                    long long lbsUseTime, int lbsHttpCode, int lbsSucc, NSString *net) {
                                         NSLog(@"%@", resp);
                                         XCTAssert(resp[@"upload"], @"PASS");
                                         inProgess = NO;
                                  }];
    timerTask = nil;
     

    AGWW_WAIT_WHILE(inProgess, 20);
    */
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}



@end
