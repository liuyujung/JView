//
//  SpNavigator.m
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpNavigator.h"


@implementation SpNavigator

+ (SpNavigator *)navigatorWithPath:(NSString *)_path depth:(int)_depth
{
	SpNavigator *navigator = [[SpNavigator alloc] initWithPath:_path depth:_depth];
	return [navigator autorelease];
}

- (id)initWithPath:(NSString *)_path depth:(int)_depth
{
    if (self = [super init]) {
        SpFile *spFile = [[SpFileUtil sharedFileUtil] fileWithPath:_path];
        if (!spFile) {
            [self release];
            return nil;
        }
        
        if (![spFile isKindOfClass:[SpFolder class]]) {
            isFirst = YES;
            currentFile = [spFile retain];
            baseFolder = [[[SpFileUtil sharedFileUtil] fileWithPath:[_path stringByDeletingLastPathComponent]] retain];
        } else {
            isFirst = NO;
            currentFile = nil;
            baseFolder = [spFile retain];
        }
        [baseFolder setDepth:_depth];
    }
    return self;
}

- (void)dealloc
{
    [currentFile release];
    [baseFolder release];
    [super dealloc];
}

- (SpFile *)nextFile:(Navigation *)_navigation
{
    if (isFirst) {
        isFirst = NO;
        return currentFile;
    }
    [self prepareCurrentFolderContent];
    return [baseFolder nextFile:_navigation];
}

- (SpFile *)currentFile
{
	return (currentFile ? currentFile : [baseFolder currentFile]);
}

- (SpFolder *)currentFolder
{
	return [baseFolder currentFolder];
}

- (SpFolder *)baseFolder
{
	return baseFolder;
}

- (void)prepareCurrentFolderContent
{
	if (currentFile) {
        [baseFolder loadFolderContent];
		[baseFolder setIndexForFile:currentFile];
		[baseFolder setSlideRandom:slideRandom];
        [currentFile autorelease];
        currentFile = nil;
    }
}

- (SpFile *)removeCurrentFile:(BOOL)_reverse nextFile:(BOOL)_next
{
	[[baseFolder currentFolder] removeCurrentFile:_reverse];
	if (_next) {
		Navigation *navigation = [SpFolder navigation];
		SpFile *nextFile = [self nextFile:navigation];
		free(navigation);
		return nextFile ;
	}
	return nil;
}

- (void)setSlideRandom:(BOOL)_slideRandom
{
	slideRandom = _slideRandom;
	[baseFolder setSlideRandom:slideRandom];
}

@end
