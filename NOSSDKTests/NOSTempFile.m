//
//  NOSTempFile.m
//  NOSSDK
//
//  Created by hzzhenghuabin on 2015/1/18.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NOSTempFile.h"

@implementation NOSTempFile

+ (NSURL *)createTempfileWithSize:(int)size {
	NSString *filePath = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"file.txt"];
	NSURL *fileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath]];
	NSData *data = [NSMutableData dataWithLength:size];
	NSError *error = nil;
	[data writeToURL:fileUrl options:NSDataWritingAtomic error:&error];
	return fileUrl;
}

+ (void)removeTempfile:(NSURL *)fileUrl {
	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
}

@end
