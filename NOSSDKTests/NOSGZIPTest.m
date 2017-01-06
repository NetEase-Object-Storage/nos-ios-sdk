//
//  NOSGZIPTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/26.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GZIP.h"

@interface NOSGZIPTest : XCTestCase

@end

@implementation NOSGZIPTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NSString *localFileName = @"/Users/netease/Documents/mytest.jpg";
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:localFileName options:NSDataReadingMappedIfSafe error:&error];
    [[data gzippedData] writeToFile:@"/Users/netease/Documents/mytest.jpg.gzip" atomically:YES];
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
