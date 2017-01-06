//
//  NOSAsyncRun.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NOSAsyncRun.h"

void NOSAsyncRun(NOSRun run) {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
	    run();
	});
}
