//
//  NOSIPToLongTest.m
//  NOSSDK
//
//  Created by NetEase on 15-1-27.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NOSIPToLong.h"

@interface NOSIPToLongTest : XCTestCase

@end

@implementation NOSIPToLongTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTAssert([NOSIPToLong ipToLong:@"1.1.1.1"] == 16843009, @"PASS");
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
