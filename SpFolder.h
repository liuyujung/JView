//
//  SpFolder.h
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpFile.h"

typedef struct {
	BOOL reverse;
	BOOL random;
	BOOL reshuffle;
	BOOL jumpup;
	BOOL uptwice;
	BOOL uptotop;
} Navigation;


@interface SpFolder : SpFile {
	BOOL isLocked, slideRandom;
    int folderLevel, depth, currentIndex, *randomIndex;
	NSDate *modifiedDate;
    NSMutableArray *folderContent;
    SpFolder *parent, *currentFolder;
}

+ (Navigation *)navigation;
- (id)initWithFolderPath:(NSString *)_folderPath realPath:(NSString *)_realPath;
- (int)folderLevel;
- (void)setFolderLevel:(int)_folderLevel;
- (void)setDepth:(int)_depth;
- (void)setCurrentIndex:(int)_currentIndex;
- (void)setParent:(SpFolder *)_parent;
- (void)setCurrentFolder:(SpFolder *)_currentFolder;
- (void)setIndexForFile:(SpFile *)_file;
- (NSString *)folderName;
- (void)setFolderContent:(NSMutableArray *)_folderContent;
- (NSMutableArray *)folderContent;
- (void)loadFolderContent;
- (void)checkFolderContent:(BOOL)_forceReload;
- (void)removeCurrentFile:(BOOL)_reverse;
- (SpFolder *)currentFolder;
- (NSDate *)modifiedDate;
- (void)setModifiedDate:(NSDate *)_modifiedDate;
- (BOOL)isModified;
- (int)currentIndex;
- (BOOL)isLocked;
- (void)setLocked;
- (SpFile *)currentFile;
- (SpFile *)nextFile:(Navigation *)_navigation;
- (BOOL)slideRandom;
- (void)setSlideRandom:(BOOL)_slideRandom;

@end
