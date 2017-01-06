//
//  NOSUserAgent.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MIN_REQUIRED
  #import <MobileCoreServices/MobileCoreServices.h>
  #import <UIKit/UIKit.h>
#else
  #import <CoreServices/CoreServices.h>
#endif

#import "NOSUserAgent.h"
#import "NOSVersion.h"

static NSString *clientId(void) {
	long long now_timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
	int r = arc4random() % 1000;
	return [NSString stringWithFormat:@"%lld%u", now_timestamp, r];
}

NSString *NOSUserAgent(void) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
	return [NSString stringWithFormat:@"NosObject-C/%@ (%@; iOS %@; %@)", kNosVersion, [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], clientId()];
#else
	return [NSString stringWithFormat:@"NosObject-C/%@ (Mac OS X %@; %@)", kNosVersion, [[NSProcessInfo processInfo] operatingSystemVersionString], clientId()];
#endif
}
