//
//  NOSAsyncRun.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

typedef void (^NOSRun)(void);

void NOSAsyncRun(NOSRun run);
