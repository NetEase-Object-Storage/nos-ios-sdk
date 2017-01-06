//
//  NOSLbsTask.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSLbsTask.h"
#import "NOSResponseInfo.h"
#import "NOSUploadManager+Private.h"
#import "NOSTimeUtils.h"
#import "NOSBucketLBSMap.h"

@interface NOSLbsTask()

@property (nonatomic, strong) NOSLbsCompletionHandler completeHandler;

@end

extern int const KNOSLbsHostNum;
extern NSString const *kNOSLbsHostArray[];
extern NSString *const kNOSLbsVersion;

@implementation NOSLbsTask

- (instancetype) initWithCompleteHandler:(NOSLbsCompletionHandler) completeHandler {
    if (self = [super init]) {
        _completeHandler = completeHandler;
    }
    return self;
}

- (void) fetchUploaderHosts:(NSString *)bucketName {
    // get from cache
    NOSLbsInfo *lbsInfo = [[NOSUploadManager bucketLbsMap] lbsInfoSnapshot:bucketName] ;
    NSMutableArray *lbsHosts = [NSMutableArray arrayWithCapacity:KNOSLbsHostNum + 1];
    
    /*if (lbsInfo && lbsInfo.lbsIP) {
        if ([lbsInfo.lbsIP hasPrefix:@"http://"]) {
            NSMutableString * url = [NSMutableString stringWithString:@"https://"];
            [url appendString: [lbsInfo.lbsIP substringFromIndex:[@"http://" length]]];
            [lbsHosts addObject:url];
        }
        else {
            [lbsHosts addObject:lbsInfo.lbsIP];
        }
    }*/
    
    for (int i = 0; i < KNOSLbsHostNum; ++i) {
        [lbsHosts addObject:kNOSLbsHostArray[i]];
    }
    
    long long startTime = [NOSTimeUtils currentMil];
    
    NSURLResponse *response;
    NSError *error;
    
    for (NSString *host in lbsHosts) {
        NSMutableString * lbsUrl = [NSMutableString stringWithString:host];
        [lbsUrl appendString:@"?"];
        [lbsUrl appendString:kNOSLbsVersion];
        [lbsUrl appendString:@"&bucketname="];
        [lbsUrl appendString:bucketName];
        
        NSURL *url = [[NSURL alloc] initWithString:lbsUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:[[NOSUploadManager globalConf] NOSSoTimeout]];
        
        UInt32 retriedTimes = 0;//[[NOSUploadManager globalConf] NOSRetryCount];
        
        while (true) {
            response = nil;
            error = nil;
            NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (error) {
                NSString *errorDesc = [error localizedDescription];
                NSLog(@"fetch uploader host from lbs error: %@", errorDesc);
                //NSLog(@"%d", [NOSUploadManager globalConf].NOSRetryCount);
                if (retriedTimes >= [NOSUploadManager globalConf].NOSRetryCount) {
                    break;
                }
                retriedTimes++;
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                int statusCode = (int)[httpResponse statusCode];
                
                if (statusCode == 200) {
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:result
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&error];
                    if (error) {
                        NSLog(@"lbs return non json");
                        long long endTime = [NOSTimeUtils currentMil];
                        self.completeHandler(nil, endTime - startTime, statusCode, 1, bucketName);
                        return;
                    }
                    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *jsonDictionary = (NSDictionary*)jsonObject;
                        NSArray* arrayResult = [jsonDictionary valueForKey:@"upload"];
                        NSLog(@"lbs return uploader hosts:%@", arrayResult);
                        long long endTime = [NOSTimeUtils currentMil];
                        self.completeHandler(jsonDictionary, endTime - startTime, statusCode, 0, bucketName);
                        return;
                    }
                } else {
                    NSLog(@"lbs return %d", statusCode);
                    long long endTime = [NOSTimeUtils currentMil];
                    self.completeHandler(nil, endTime - startTime, statusCode, 1, bucketName);
                    return;
                }
            } // End of if (error)
        } // End of while
    } // End of For
    
    long long endTime = [NOSTimeUtils currentMil];
    self.completeHandler(nil, endTime - startTime, -1, 1, bucketName);
    return;
}

@end
