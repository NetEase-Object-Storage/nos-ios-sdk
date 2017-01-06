//
//  NOSBase64Test.m
//  NOSSDK
//
//  Modified by hzzhenghuabin on 2015/1/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NosSDK.h"

@interface NOSBase64Test : XCTestCase

@end

@implementation NOSBase64Test

- (void)testEncode {
	// This is an example of a functional test case.
	NSString *source = @"你好/+=";
    NSLog(@"%@", [[source dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]);
	XCTAssert([[NOSBase64 encodeString:source] isEqual:@"5L2g5aW9Lys9"], @"Pass");
    
    XCTAssert([[NOSBase64 decodeString:@"5L2g5aW9Lys9"] isEqual:source], @"Pass");
}

@end
