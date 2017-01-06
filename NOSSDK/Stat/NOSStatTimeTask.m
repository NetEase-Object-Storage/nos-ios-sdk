//
//  NOSStatTimeTask.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/15.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSStatTimeTask.h"
#import "NOSUploadManager+Private.h"
#import "GZIP.h"

@interface NOSStatTimeTask()

@property NSMutableArray *statPool;
@property NSTimer *timer;


- (void) timerTask:(NSTimer *)timer;

@end

@implementation NOSStatTimeTask

+ (instancetype)sharedInstanceAndRun {
    static NOSStatTimeTask *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initAndRun];
    });
    
    return sharedInstance;
}

- (void) addAnStatItem:(NOSStatisticsItems *)item {
    @synchronized(self) {
        [self.statPool addObject:item];
    }
}

- (NSString *) toJson {
    @synchronized(self) {
        if ([self.statPool count] <= 0) {
            return nil;
        }
        NSMutableString *json = [NSMutableString stringWithFormat:@"{\"items\":["];
        for (int i = 0; i < [self.statPool count ]; ++i) {
            NSString *itemJson = [(NOSStatisticsItems *)self.statPool[i] toJson];
            if (i != 0) {
                [json appendString:@",\n"];
            }
            [json appendString:itemJson];
        }
        [json appendFormat:@"]}"];
        [self.statPool removeAllObjects];
        return json;
    }
}

- (void) timerTask:(NSTimer *)timer {
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSLog(@"stat task!");
            NSURL *url = [[NSURL alloc] initWithString:[[NOSUploadManager globalConf] statUrl]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            NSString *jsonStr = [self toJson];
            if (!jsonStr) return;
            //NSLog(@"%@", jsonStr);
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPMethod:@"POST"];
            [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
            [request setTimeoutInterval:[[NOSUploadManager globalConf] NOSSoTimeout]];
            [request setHTTPBody:[jsonData gzippedData]];
            
            UInt32 retriedTimes = 0;
            
            while (true) {
                NSURLResponse *response;
                NSError *error;
                NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                if (error) {
                    NSString *errorDesc = [error localizedDescription];
                    NSLog(@"push stat data error: %@", errorDesc);
                    if (retriedTimes >= [NOSUploadManager globalConf].NOSRetryCount) {
                       return;
                    }
                    retriedTimes++;
                } else {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    int statusCode = (int)[httpResponse statusCode];
                    
                    if (statusCode != 200) {
                        NSLog(@"stat return %d", statusCode);
                        NSLog(@"%@", [[NSString alloc] initWithData:result  encoding:NSUTF8StringEncoding]);
                    } else {
                        NSLog(@"push stat successfully");
                    }
                    return;
                }
            }
        });
    }
}

- (instancetype)initAndRun {
    if (self = [super init]) {
        _statPool = [[NSMutableArray alloc] init];
        _timer = [NSTimer scheduledTimerWithTimeInterval:[NOSUploadManager globalConf].NOSMoniterInterval
                                                  target:self
                                                selector:@selector(timerTask:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    
    return self;
}


@end
