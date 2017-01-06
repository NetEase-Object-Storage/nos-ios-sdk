//
//  NOSMd5Test.m
//  NOSSDK
//
//  Created by NetEase on 2015/1/20.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NOSMd5.h"
#import "NOSTempFile.h"

@interface NOSMd5Test : XCTestCase

@end

@implementation NOSMd5Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testString {
    // This is an example of a functional test case.
    NSString *source = @"你好/+=";
    NSLog(@"%@", [NOSMd5 md5:source]);
    XCTAssert([[NOSMd5 md5:source] isEqual:@"086093d4a291f6e94d123085b47a2c12"], @"Pass");
    XCTAssert(YES, @"Pass");
}

- (void)testData {
    NSString *source = @"你好/+=";
    
    NSData *data = [NSData dataWithBytes:[source UTF8String]
                   length:[source lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
                           
    XCTAssert([[NOSMd5 getMD5WithData:data]                                                                                  isEqual:@"086093d4a291f6e94d123085b47a2c12"], @"Pass");
    XCTAssert(YES, @"Pass");
}

- (void)testfile {
    NSError *error = nil;
    //NSURL *tempFile = [NOSTempFile createTempfileWithSize:1 * 1024];
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/netease/Documents/mytest.jpg" options:NSDataReadingMappedIfSafe error:&error];
    NSLog(@"%@", [NOSMd5 getMD5WithData:data]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
