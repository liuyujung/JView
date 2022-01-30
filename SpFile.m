//
//  SpFile.m
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpFile.h"


@implementation SpFile

- (id)initWithFilePath:(NSString *)_filePath realPath:(NSString *)_realPath
{
    if (self = [super init]) {
        fileName = [[_filePath lastPathComponent] copy];
        realPath = [_realPath copy];
		filePath = [_filePath copy];
    }
    return self;
}

- (void)dealloc
{
    [fileName release];
    [realPath release];
	[filePath release];
    [super dealloc];
}

- (NSString *)description
{
    return [[fileName stringByAppendingString:@" : "] stringByAppendingString:realPath];
}

- (BOOL)isEqual:(id)anObject
{
    if ([anObject isKindOfClass:[SpFile class]]) {
		//NSLog(filePath);
		//NSLog([(SpFile *)anObject realPath]);
        return [filePath isEqualToString:[(SpFile *)anObject filePath]] && [realPath isEqualToString:[(SpFile *)anObject realPath]];
    }
    return NO;
}

- (NSString *)fileName
{
    return fileName;
}

- (NSString *)realPath
{
    return realPath;
}

- (NSString *)filePath
{
	return filePath;
}

@end
