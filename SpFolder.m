//
//  SpFolder.m
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpFolder.h"
#import "SpFileUtil.h"
#import "SpQuickSort.h"

@interface SpFolder (PrivateMethod)
- (int)nextRandomIndex:(Navigation *)_navigation;
- (int)nextIndex:(Navigation *)_navigation;
- (BOOL)checkNavigation:(Navigation *)_navigation;
+(int)indexOfArray:(int *)_array size:(int)_size integer:(int)_number;
+ (int *)makeRandomIndexArray:(int)_count;
+ (void)shuffleIndexArray:(int *)_array count:(int)_count;
@end


@implementation SpFolder

- (id)initWithFolderPath:(NSString *)_folderPath realPath:(NSString *)_realPath
{
    if (self = [super initWithFilePath:_folderPath realPath:_realPath]) {
		isLocked = NO;
        currentIndex = -1;
        folderLevel = 1;
        depth = 1;
        parent = nil;
		currentFolder = self;
		modifiedDate = nil;
        folderContent = nil;
		randomIndex = NULL;
		slideRandom = NO;
    }
    return self;
}

- (void)dealloc
{
	free(randomIndex);
    [folderContent release];
	//[modifiedDate autorelease];
	[modifiedDate release];
    [super dealloc];
}

+ (Navigation *)navigation
{
	Navigation *navigation = (Navigation *)malloc(sizeof(Navigation));
	navigation->reverse = NO;
	navigation->random = NO;
	navigation->reshuffle = NO;
	navigation->jumpup = NO;
	navigation->uptwice = NO;
	navigation->uptotop = NO;
	return navigation;
}

- (int)folderLevel
{
	return folderLevel;
}

- (void)setFolderLevel:(int)_folderLevel
{
    folderLevel = _folderLevel;
}

- (void)setDepth:(int)_depth
{
    depth = _depth;
}

- (void)setCurrentIndex:(int)_currentIndex
{
    currentIndex = _currentIndex;
}

- (void)setParent:(SpFolder *)_parent
{
	parent = _parent;
}

- (void)setCurrentFolder:(SpFolder *)_currentFolder
{
	currentFolder = _currentFolder;
}

- (void)setIndexForFile:(SpFile *)_file
{
	int index = [folderContent indexOfObject:_file];
	currentIndex = index;
	//NSLog(@"%d", currentIndex);
}

- (NSString *)folderName
{
    return fileName;
}

- (void)checkFolderContent:(BOOL)_forceReload
{
	if (!folderContent) {
        [self loadFolderContent];
    } else if (_forceReload || [self isModified]) {
		SpFile *currentFile = [[self currentFile] retain];
		[self loadFolderContent];
		[self setIndexForFile:[currentFile autorelease]];
		free(randomIndex);
		randomIndex = NULL;
	}
}

- (NSMutableArray *)folderContent
{
	return folderContent;
}

- (void)setFolderContent:(NSMutableArray *)_folderContent
{
	[folderContent autorelease];
	folderContent = [_folderContent retain];
}

- (void)removeCurrentFile:(BOOL)_reverse
{
	//NSLog(@"removeCurrentFile");
	// access folder content directly before it gets reloaded due to folder content change
    [folderContent removeObjectAtIndex:currentIndex];
	free(randomIndex);
	randomIndex = NULL;
    if (!_reverse) currentIndex--; // no way to know random or not
}

- (void)loadFolderContent
{
    [folderContent autorelease];
	
	if (slideRandom) {
		folderContent = [[[SpFileUtil sharedFileUtil] allContentAtFolder:self depth:depth] retain];
	} else {
		folderContent = [[[SpFileUtil sharedFileUtil] folderContentAtPath:realPath parent:self level:folderLevel depth:depth slideRandom:slideRandom] retain];
	}
	
	// set last modified date
	[self setModifiedDate:[[SpFileUtil sharedFileUtil] folderModifiedDate:realPath]];
}

- (BOOL)isModified
{
	return ![modifiedDate isEqualToDate:[[SpFileUtil sharedFileUtil] folderModifiedDate:realPath]];
}

- (NSDate *)modifiedDate;
{
	return modifiedDate;
}

- (void)setModifiedDate:(NSDate *)_modifiedDate
{
	[modifiedDate autorelease];
	modifiedDate = [_modifiedDate copy];
}

- (SpFolder *)currentFolder
{
	if (currentFolder != self) return [currentFolder currentFolder];
	return currentFolder;
}

- (int)currentIndex
{
	return currentIndex;
}

- (SpFile *)currentFile
{
	if (currentFolder != self) return [currentFolder currentFile];
	return [folderContent objectAtIndex:currentIndex];
}

- (SpFile *)nextFile:(Navigation *)_navigation
{
	BOOL reload = NO;
    SpFile *spFile;
	
	// find current folder navigated
    if (currentFolder != self) return [currentFolder nextFile:_navigation];
	
	if (folderLevel > df_NAVIGATION_FOLDER_DEPTH && df_NAVIGATION_FOLDER_DEPTH != 0) {
		[parent removeCurrentFile:_navigation->reverse];
        [parent setCurrentFolder:parent];
        return [parent nextFile:_navigation];
	}
	
	if (depth != df_NAVIGATION_FOLDER_DEPTH) {
		depth = df_NAVIGATION_FOLDER_DEPTH;
		reload = YES;
	}
	
	[self checkFolderContent:reload];
    
	int count = [folderContent count];
	
    if (!count) {
        if (folderLevel == 1) return nil;
        [parent removeCurrentFile:_navigation->reverse];
        [parent setCurrentFolder:parent];
        return [parent nextFile:_navigation];
    }

	if (_navigation->random && count > 2) {
		currentIndex = [self nextRandomIndex:_navigation];
	} else {
		currentIndex = [self nextIndex:_navigation];
	}
	
	if (currentIndex == -1) { // go back to parent
		//NSLog(@"back to parent");
		if (randomIndex) [SpFolder shuffleIndexArray:randomIndex count:count]; // needed?
		[parent setCurrentFolder:parent];
		return [parent nextFile:_navigation];
	}

    spFile = [folderContent objectAtIndex:currentIndex];
    if ([spFile isKindOfClass:[SpFolder class]]) {
		if (isLocked) {
			return [self nextFile:_navigation];
		} else {
			[self setCurrentFolder:(SpFolder *)spFile];
			return [(SpFolder *)spFile nextFile:_navigation];
		}
    }
    return spFile;
}

- (int)nextIndex:(Navigation *)_navigation
{
	if (![self checkNavigation:_navigation]) return -1;

	int nextIndex = currentIndex, count = [folderContent count];
	if (_navigation->reverse) nextIndex--;
	else nextIndex++;
    
	if (nextIndex == -2) {
		nextIndex = count - 1;
	} else if (nextIndex >= count || nextIndex < 0) {
		if (folderLevel == 1 || isLocked) {
			if (slideRandom) {
				[[SpQuickSort sharedQuickSort] shuffleArray:folderContent];
			}
			if (_navigation->reverse) {
				nextIndex = count - 1;
			} else {
				nextIndex = 0;
			}
		} else {
			nextIndex = -1;
		}
	}
	return nextIndex;
}

- (int)nextRandomIndex:(Navigation *)_navigation
{
	if (![self checkNavigation:_navigation]) return -1;
	
	int currentRandomIndex, nextIndex = currentIndex, count = [folderContent count];
	//NSLog(@"current index: %d", currentIndex);
	
	if (!randomIndex) {
		randomIndex = [SpFolder makeRandomIndexArray:count];
	} else if (_navigation->reshuffle) {
		[SpFolder shuffleIndexArray:randomIndex count:count];
	}

	if (nextIndex == -1) nextIndex = 0;
	
	currentRandomIndex = [SpFolder indexOfArray:randomIndex size:count integer:nextIndex];
	//NSLog(@"random index: %d", currentRandomIndex);
	
	if (_navigation->reverse) currentRandomIndex--;
	else  currentRandomIndex++;
	
	if (currentRandomIndex >= count) {
		if (folderLevel == 1 || isLocked) {
			//NSLog(@"level one");
			[SpFolder shuffleIndexArray:randomIndex count:count];
			nextIndex = *randomIndex;
		} else { // go back to parent
			//NSLog(@"random -1");
			nextIndex = -1;
		}
	} else if (currentRandomIndex < 0) {
		if (folderLevel == 1 || isLocked) {
			[SpFolder shuffleIndexArray:randomIndex count:count];
			nextIndex = randomIndex[count - 1];
		} else {
			nextIndex = -1;
		}
	} else {
		nextIndex = randomIndex[currentRandomIndex];
	}
	return nextIndex;
}

- (BOOL)checkNavigation:(Navigation *)_navigation
{
	if (_navigation->jumpup) {
		if (folderLevel != 1) {
			if (_navigation->uptotop) return NO; // until it goes to the top, and it will fall to the else clause to reset the flags
			if (_navigation->uptwice) {
				_navigation->uptwice = NO; // set uptwice to NO to jump one more time
				return NO;
			}
			_navigation->jumpup = NO; // set jump to NO, return NO to jump once
			return NO;
		} else {
			// here is level 1, reset those jump flags
			_navigation->jumpup = NO;
			_navigation->uptwice = NO;
			_navigation->uptotop = NO;
		}
	}
	// jump flags were not set
	return YES;
}

- (BOOL)isLocked
{
	return isLocked;
}

- (void)setLocked
{
	isLocked = !isLocked;
}

- (BOOL)slideRandom
{
	return slideRandom;
}

- (void)setSlideRandom:(BOOL)_slideRandom
{
	slideRandom = _slideRandom;
}

+(int)indexOfArray:(int *)_array size:(int)_size integer:(int)_number
{
	int i;
	for (i = 0; i < _size; i++) {
		if (_number == _array[i]) return i;
	}
	return -1;
}

+ (int *)makeRandomIndexArray:(int)_count
{
	int i, *array = (int *) malloc(sizeof(int) * _count);
	for (i = 0; i < _count; i++) {
		array[i] = i;
	}
	[SpFolder shuffleIndexArray:array count:_count];
	
	/*NSLog(@"makeRandomIndexArray");
	int j, *p = array;
	for (j = 0; j < _count; j++) {
		NSLog(@"%d", p[j]);
	}*/
	
	return array;
}

+ (void)shuffleIndexArray:(int *)_array count:(int)_count
{
	int i, n, t;
    srand(time(NULL));
	
    for (i = 0; i < _count; i++) {
        n = rand() % _count;
		t = _array[i];
		_array[i] = _array[n];
		_array[n] = t;
    }
}

@end
