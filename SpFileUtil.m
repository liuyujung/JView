//
//  SpFileUtil.m
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpFileUtil.h"
#import "SpFile.h"
#import "SpFolder.h"
#import "SpQuickSort.h"

static SpFileUtil *fileUtil;

@interface SpFileUtil (PrivateMethods)
- (void)folderContentAtFolder:(SpFolder *)_parent depth:(int)_depth content:(NSMutableArray *)_content; // only used by allContentAtFolder
@end

@implementation SpFileUtil

+ (id)sharedFileUtil
{
    if (!fileUtil) {
        fileUtil = [[SpFileUtil allocWithZone:[self zone]] init];
    }
    return fileUtil;
}

- (SpFile *)fileWithPath:(NSString *)_filePath
{
    BOOL isDirectory = NO;
    NSString *realPath;
    SpFile *spFile = nil;
    
    // get the realpath
    if ([[fileManager fileAttributesAtPath:_filePath traverseLink:NO] objectForKey:NSFileType] == NSFileTypeSymbolicLink) {
        realPath = [_filePath stringByResolvingSymlinksInPath];
        [fileManager fileExistsAtPath:realPath isDirectory:&isDirectory];
    } else {
		Boolean isDir, isSymbolic;
        FSRef fileRef;
        FSPathMakeRef((const UInt8 *)[_filePath UTF8String], &fileRef, &isDir);
        FSResolveAliasFile(&fileRef, TRUE, &isDir, &isSymbolic);
		if (isDir) isDirectory = YES;
        if (isSymbolic) {
            UInt8 target[256];
            FSRefMakePath(&fileRef, target, sizeof(target));
			realPath = [NSString stringWithUTF8String:(char *) target];
        } else {
            realPath = _filePath;
        }
    }
    
    // return the right instance
    if (isDirectory) {
        spFile = [[SpFolder alloc] initWithFolderPath:_filePath realPath:realPath];
    } else {
        if ([fileTypes containsObject:[realPath pathExtension]] || [fileTypes containsObject:NSHFSTypeOfFile(realPath)]) {
            spFile = [[SpFile alloc] initWithFilePath:_filePath realPath:realPath];
        }
    }
    return [spFile autorelease];
}

- (NSMutableArray *)folderContentAtPath:(NSString *)_folderPath parent:(SpFolder *)_parent level:(int)_level depth:(int)_depth slideRandom:(BOOL)_slideRandom
{
    NSMutableArray *content = [NSMutableArray array];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:_folderPath error:NULL];
	
    if (files) {
		
        int i;
        _level++;
		
        for (i = 0; i < [files count]; i++) {
			
            SpFile *spFile = [self fileWithPath:[_folderPath stringByAppendingPathComponent:[files objectAtIndex:i]]];
			
            if (spFile) {
                if ([spFile isKindOfClass:[SpFolder class]]) {
                    if (_level > _depth && _depth != 0) continue;
                    [(SpFolder *)spFile setFolderLevel:_level];
                    [(SpFolder *)spFile setDepth:_depth];
                    [(SpFolder *)spFile setParent:_parent];
					[(SpFolder *)spFile setSlideRandom:_slideRandom];
                }
                [content addObject:spFile];
            }
        }
		[[SpQuickSort sharedQuickSort] sortArray:content];
    }
    return content;
}

- (NSMutableArray *)allContentAtFolder:(SpFolder *)_baseFolder depth:(int)_depth
{
	NSMutableArray *content = [NSMutableArray array];
	[self folderContentAtFolder:_baseFolder depth:_depth content:content];
	[[SpQuickSort sharedQuickSort] shuffleArray:content];
	return content;
}

- (void)folderContentAtFolder:(SpFolder *)_parent depth:(int)_depth content:(NSMutableArray *)_content
{
	NSString *folderPath = [_parent realPath];
	int level = [_parent folderLevel];
	NSArray *files = [fileManager contentsOfDirectoryAtPath:folderPath error:NULL];
    if (files) {
        int i;
        level++;
        for (i=0; i<[files count]; i++) {
            SpFile *spFile = [self fileWithPath:[folderPath stringByAppendingPathComponent:[files objectAtIndex:i]]];
            if (spFile) {
                if ([spFile isKindOfClass:[SpFolder class]]) {
                    if (level > _depth && _depth != 0) continue;
                    [(SpFolder *)spFile setFolderLevel:level];
                    [(SpFolder *)spFile setDepth:_depth];
                    [(SpFolder *)spFile setParent:_parent];
					[(SpFolder *)spFile setSlideRandom:YES];
					[self folderContentAtFolder:(SpFolder *)spFile depth:_depth content:_content];
                } else {
					[_content addObject:spFile];
				}
            }
        }
    }
}

- (NSDate *)fileModifiedDate:(NSString *)_filePath
{
	return [self folderModifiedDate:_filePath];
}

- (NSDate *)folderModifiedDate:(NSString *)_folderPath
{
	return [[fileManager fileAttributesAtPath:_folderPath traverseLink:NO] objectForKey:NSFileModificationDate];
}

// the destination has to be nil
- (BOOL)trashFileWithFilename:(NSString *)_filename
{
    return [workSpace performFileOperation:NSWorkspaceRecycleOperation source:[_filename stringByDeletingLastPathComponent] destination:nil
        files:[NSArray arrayWithObject:[_filename lastPathComponent]] tag:NULL];
}

// the destination has to be nil
- (BOOL)deleteFileWithFilename:(NSString *)_filename
{
	return [workSpace performFileOperation:NSWorkspaceDestroyOperation source:[_filename stringByDeletingLastPathComponent] destination:nil
		files:[NSArray arrayWithObject:[_filename lastPathComponent]] tag:NULL];
}

- (BOOL)moveFileWithFilename:(NSString *)_filename to:(NSString *)_destination
{
	return [workSpace performFileOperation:NSWorkspaceMoveOperation source:[_filename stringByDeletingLastPathComponent] destination:_destination
        files:[NSArray arrayWithObject:[_filename lastPathComponent]] tag:NULL];
}

@end
