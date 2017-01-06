//
//  NOSStatTimeTask.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/15.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NOSStatisticsItems.h"

@interface NOSStatTimeTask : NSObject

- (void) addAnStatItem:(NOSStatisticsItems *)item;
+ (instancetype)sharedInstanceAndRun;

@end
