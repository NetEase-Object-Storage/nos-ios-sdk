//
//  NOSUploadOption+Private.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/11.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSUploadOption.h"

@interface NOSUploadOption (Private)

@property (nonatomic, getter = priv_isCancelled, readonly) BOOL cancelled;

@end
