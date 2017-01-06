//
//  NOSTempFile.h
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/18.
//  Copyright (c) 2015年 Nos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOSTempFile : NSObject

+ (NSURL *)createTempfileWithSize:(int)size;
+ (void)removeTempfile:(NSURL *)path;

@end
