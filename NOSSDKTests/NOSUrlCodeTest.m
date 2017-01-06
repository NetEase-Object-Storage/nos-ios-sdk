//
//  NOSUrlCodeTest.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/21.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NOSUrlCode.h"

@interface NOSUrlCodeTest : XCTestCase

@end

@implementation NOSUrlCodeTest

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
    NSString *encodedStr = [NOSUrlCode urlEncode:@"特殊   字符`-=[]\\;',./ ~!@#$%^&*()_+{}|:\"<>?.jpg"];
    NSLog(@"%@",encodedStr);
    XCTAssert([encodedStr isEqual:@"%E7%89%B9%E6%AE%8A%20%20%20%E5%AD%97%E7%AC%A6%60-%3D%5B%5D%5C%3B%27%2C.%2F%20~%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%7C%3A%22%3C%3E%3F.jpg"], @"PASS");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
