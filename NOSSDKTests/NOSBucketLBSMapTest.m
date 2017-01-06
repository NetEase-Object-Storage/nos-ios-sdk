//
//  NOSBucketLBSMapTest.m
//  NOSSDK
//
//  Created by NetEase on 16-3-6.
//  Copyright (c) 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NOSBucketLBSMap+Private.h"
#import "NOSUploadManager+Private.h"
#import "NOSTestConf.h"

@interface NOSBucketLBSMapTest : XCTestCase
@property NOSUploadManager *upManager;
@end

//extern NSString* const kNOSUploadHostsStr;
//extern NSString* const kNOSLbsIpStr;
//extern NSString* const kNOSLastModified;

@implementation NOSBucketLBSMapTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [NOSUploadManager setGlobalConf:[NOSTestConf testNOSConf]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NOSBucketLBSMap bucketStrInPersistent:kNOSTestBucket]];
    
    _upManager = [[NOSUploadManager alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testExample {
    // This is an example of a functional test case.
    NOSBucketLBSMap *bucketLbsMap = [NOSUploadManager bucketLbsMap];
    
    // 1. empty
    NOSLbsInfo* lbsInfo = [bucketLbsMap lbsInfoSnapshot:kNOSTestBucket];
    XCTAssert(!lbsInfo, @"Pass");
    XCTAssert(![[NSUserDefaults standardUserDefaults] objectForKey:[NOSBucketLBSMap bucketStrInPersistent:kNOSTestBucket]], @"Pass" );
    
    // 2. add lbs info
    lbsInfo = [[NOSLbsInfo alloc] init];
    lbsInfo.lastModified = 1;
    lbsInfo.uploaderHosts = [NSArray arrayWithObjects:@"http://223.252.196.40", nil];
    lbsInfo.lbsIP = @"ip";
    
    [bucketLbsMap addLbsInfo:lbsInfo forBucket:kNOSTestBucket];
    
    // 3. get lbs info and check
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NOSBucketLBSMap bucketStrInPersistent:kNOSTestBucket]];
    XCTAssert(dic, @"Pass");
    
    NSArray *uploadHosts = [dic objectForKey:@"uploadHosts"];
    long long lastModified = [[dic objectForKey:@"lastModified"] longLongValue];
    NSLog(@"%@", uploadHosts);
    XCTAssert(lastModified == lbsInfo.lastModified, @"Pass");
    
    NOSLbsInfo* resLbsInfo = [bucketLbsMap lbsInfoSnapshot:kNOSTestBucket];
    XCTAssert(resLbsInfo, @"Pass");
    XCTAssert(resLbsInfo.lastModified==lbsInfo.lastModified, @"Pass");
    XCTAssert([[resLbsInfo.uploaderHosts description] isEqualToString:[lbsInfo.uploaderHosts description]], @"Pass");
    
    // 4. invalid the lbs info
    [bucketLbsMap invalidLBSInfoForBucket:kNOSTestBucket];
    resLbsInfo = [bucketLbsMap lbsInfoSnapshot:kNOSTestBucket];
    XCTAssert(resLbsInfo.lastModified==0, @"Pass");
    dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NOSBucketLBSMap bucketStrInPersistent:kNOSTestBucket]];
    XCTAssert([[dic objectForKey:@"lastModified"] longLongValue]==0, @"Pass");
    
    // 5. get newest lbs info
    resLbsInfo = [bucketLbsMap lbsInfoNewest:kNOSTestBucket];
    XCTAssert(resLbsInfo, @"Pass");
    NSLog(@"%@", resLbsInfo);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
