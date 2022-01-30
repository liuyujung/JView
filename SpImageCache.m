//
//  SpCache.m
//  FileNavigator
//
//  Created by Allan on Sun Dec 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpImageCache.h"
#import "SpFile.h"
#import "SpFileUtil.h"
#import "SpImageUtil.h"
#import "MyDocumentController.h"
#import "MyApplication.h"

@interface SpImageCache (PrivateMethods)
- (id)initWithCapacityBytes:(long)_capacity;
- (NSImage *)getImageForNavigator:(SpNavigator *)_navigator withSpFile:(SpFile *)_file reverse:(BOOL)_reverse;
- (NSImage *)getImageForKey:(NSString *)_key;
- (void)putImage:(NSImage *)_image size:(unsigned)_size date:(NSDate *)_date forKey:(NSString *)_key;
- (void)removeImageForKey:(NSString *)_key;
- (BOOL)isImageModified:(NSString *)_key;
- (NSImage *)loadImageForKey:(NSString *)_key size:(unsigned *)_size;
//- (void)printDebugInfo;
@end


@implementation SpImageCache

//BOOL debug = NO;

- (id)initWithCapacityBytes:(long)_capacity
{
	if (self = [super init]) {
		capacity = _capacity;
		currentCapacity = 0;
		keys = [[NSMutableArray alloc] init];
		sizes = [[NSMutableDictionary alloc] init];
		cache = [[NSMutableDictionary alloc] init];
		dates = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithCapacityMBytes:(int)_capacity
{
	return [self initWithCapacityBytes:_capacity / 30.0 * 1024 * 1024];
}

- (void)dealloc
{
	[dates release];
	[cache release];
	[sizes release];
	[keys release];
	[super dealloc];
}

- (void)setCacheSizeMBytes:(int)_capacity
{
	capacity = _capacity / 30.0 * 1024 * 1024;
}

- (void)reset
{
	currentCapacity = 0;
	[keys removeAllObjects];
	[sizes removeAllObjects];
	[cache removeAllObjects];
	[dates removeAllObjects];
}

- (NSImage *)nextImageForNavigator:(SpNavigator *)_navigator navigation:(Navigation *)_navigation
{
	SpFile *file = [_navigator nextFile:_navigation];
	if (!file) return nil;
	return [self getImageForNavigator:_navigator withSpFile:file reverse:_navigation->reverse];
}

- (NSImage *)performActionForNavigator:(SpNavigator *)_navigator operation:(Operation)_operation destination:(NSString *)_destination
{
	// there may not be current file yet if the current file is the fist image loaded in window
	[_navigator prepareCurrentFolderContent];
	SpFile *currentFile = [_navigator currentFile];

	BOOL success = NO;
	NSString *errorMessage = nil;
	
	if (_operation == recycleOperation) {
		
		success = [[SpFileUtil sharedFileUtil] trashFileWithFilename:[currentFile filePath]];
		if (!success) {
			errorMessage = b_RECYCLE_FAILED;
			NSMutableString *title = [NSMutableString stringWithString:b_DELETE_SHEET_TITLE];
			[title appendString:@"\""];
			[title appendString:[[currentFile filePath] lastPathComponent]];
			[title appendString:@"\""];
			if (df_SLIDE_IS_SLIDE) [NSCursor unhide];
			NSInteger returnCode = NSRunAlertPanel(title, b_DELETE_CONFIRM, b_OK, b_CANCEL, nil);
			if (df_SLIDE_IS_SLIDE) [NSCursor hide];
			if (returnCode == NSAlertDefaultReturn) {
				success = [[SpFileUtil sharedFileUtil] deleteFileWithFilename:[currentFile filePath]];
				if (!success) errorMessage = b_DELETE_FAILED;
			}
		}
		
	} else if (_operation == moveOperation) {
		
		success = [[SpFileUtil sharedFileUtil] moveFileWithFilename:[currentFile filePath] to:_destination];
		if (!success) errorMessage = b_MOVE_FAILED;
	}
	
	if (!success) {
		if (df_SLIDE_IS_SLIDE) [NSCursor unhide];
		NSRunAlertPanel(errorMessage, b_OPERATION_FAILED, b_OK, nil, nil);
		if (df_SLIDE_IS_SLIDE) [NSCursor hide];
		//return [self getImageForNavigator:_navigator withSpFile:currentFile reverse:NO];
		return nil;
	}
	
	// to avoid reload after delete
	[self resetCurrentFolderModifcationDateForNavigator:_navigator];
	[self removeImageForKey:[currentFile realPath]];
	return [self removeImageForNavigator:_navigator];
}

// method used by delete to avoid isModified check to reload the content
- (void)resetCurrentFolderModifcationDateForNavigator:(SpNavigator *)_navigator
{
	[[_navigator currentFolder] setModifiedDate:[[SpFileUtil sharedFileUtil] folderModifiedDate:[[_navigator currentFolder] realPath]]];
}

- (NSImage *)removeImageForNavigator:(SpNavigator *)_navigator
{
	SpFile *nextFile = [_navigator removeCurrentFile:NO nextFile:YES];
	if (nextFile) return [self getImageForNavigator:_navigator withSpFile:nextFile reverse:NO];
	return nil;
}

/*
	PRIVATE Methods
*/

- (NSImage *)getImageForNavigator:(SpNavigator *)_navigator withSpFile:(SpFile *)_file reverse:(BOOL)_reverse
{	
	/*
		multithread to prefecth?
	*/
	NSImage *image = [self getImageForKey:[_file realPath]];
	while (!image && _file) {
	
		if ([[NSFileManager defaultManager] fileExistsAtPath:[_file realPath]]) {
			// warning goes here!
			if (df_SLIDE_IS_SLIDE) [NSCursor unhide];
			isSpecialAlert = YES;
			int result = NSRunAlertPanel([_file fileName], b_CANNOT_OPEN_FILE, b_SKIP_FILE, b_REVEAL_FILE, b_TRASH_FILE);
			isSpecialAlert = NO; // even if the modal is stopped, the flow still comes back here
			if (result == 0) {
				//[[NSWorkspace sharedWorkspace] selectFile:[_file realPath] inFileViewerRootedAtPath:nil];
				[[NSWorkspace sharedWorkspace] selectFile:[_file filePath] inFileViewerRootedAtPath:nil];
			} else if (result == -1) { // trash it
				[[SpFileUtil sharedFileUtil] trashFileWithFilename:[_file realPath]];
			}
			if (df_SLIDE_IS_SLIDE) [NSCursor hide];

			// if not skip, need to return nil
			if (result != 1) {
		
				// still need to remove the current file but not retrieve the next file and do not reset the modification date in case there is a modification
				//[_navigator removeCurrentFile:NO nextFile:NO];
			
				if (result == -1) {
				
					[_navigator removeCurrentFile:NO nextFile:NO]; // could be from 'stop modal', which is -1000 in Leopard
			
					// if trash it, need to modify the modified date to avoid is modified check
					//[[_navigator currentFolder] setModifiedDate:[[SpFileUtil sharedFileUtil] folderModifiedDate:[[_navigator currentFolder] realPath]]];
					[self resetCurrentFolderModifcationDateForNavigator:_navigator];
				
				} else if (result == 0) {
				
					[_navigator removeCurrentFile:NO nextFile:NO];
			
					/*
						Test for slideshow has to be first, otherwise, if coming from display, the main window controller will be MyDocumentController
					*/
					if (df_SLIDE_IS_SLIDE) {
						[[[NSApp slideWindow] delegate] stopTimer];
					} else {
						id controller = [[NSApp mainWindow] windowController];
						if ([controller isKindOfClass:[MyDocumentController class]]) {
							// if reveal in finder, need to stop the timer for either the main window or the slideshow
							if ([controller isTimer]) [controller stopTimer];
						}
					}
				}
				
				// esc -1000
				//return nil;
				Navigation *navigation = [SpFolder navigation];
				_file = [_navigator nextFile:navigation];
				image = [self getImageForKey:[_file realPath]];
				free(navigation);
				continue;
			}
		}
		_file = [_navigator removeCurrentFile:_reverse nextFile:YES];
		image = [self getImageForKey:[_file realPath]];
	}
	return image;
}

- (SpNavigator *)navigatorForImageData:(NSData *)_data filePath:(NSString *)_filePath
{
	SpNavigator *navigator = [SpNavigator navigatorWithPath:_filePath depth:df_NAVIGATION_FOLDER_DEPTH];
	[self removeImageForKey:_filePath];
	
	NSImage *image = [[NSImage alloc] initWithData:_data];
	//if (!image) return nil; // should never happen
	
	[self putImage:[image autorelease] size:[_data length] date:[[SpFileUtil sharedFileUtil] fileModifiedDate:_filePath] forKey:_filePath];	
	return navigator;
}

- (NSImage *)loadImageForKey:(NSString *)_key size:(unsigned *)_size
{
	NSData *data = [NSData dataWithContentsOfFile:_key];
	if (data) {
		if (_size) *_size = [data length];
		return [[SpImageUtil sharedImageUtil] imageWithData:data];
	}
	return nil;
}

- (NSImage *)getImageForKey:(NSString *)_key
{
	if (!df_ENABLE_CACHE) {
		return [self loadImageForKey:_key size:NULL];
	}

	NSImage *image = (NSImage *)[cache objectForKey:_key];
	if (image) {
		if ([self isImageModified:_key]) {
		
			/*if (debug) {
				NSLog(@"***** isImageModified *****");
				NSLog(_key);
			}*/
		
			[self removeImageForKey:_key];
			return [self getImageForKey:_key];
		}
		unsigned index = [keys indexOfObject:_key];
		[keys removeObjectAtIndex:index];
		[keys insertObject:_key atIndex:0];
	} else {
		unsigned size;
		image = [self loadImageForKey:_key size:&size];
		if (image) {
			[self putImage:image size:size date:[[SpFileUtil sharedFileUtil] fileModifiedDate:_key] forKey:_key];
		}
	}
	
	/*if (debug) {
		NSLog(@"***** getImageForKey *****");
		NSLog(_key);
		[self printDebugInfo];
	}*/
	
	return image;
}

- (void)putImage:(NSImage *)_image size:(unsigned)_size date:(NSDate *)_date forKey:(NSString *)_key
{
	// do not cache image size bigger than the cache
	if (_size >= capacity) return;

	// assume no duplicate key will be used
	//while (capacity < currentCapacity + _size && [keys count] != 0) {
	while (capacity < currentCapacity + _size) {
		// too big, get rid of the last one, until there is enough room
		NSString *key = (NSString *)[keys lastObject];
		unsigned size = [(NSNumber *)[sizes objectForKey:key] unsignedIntValue];
		currentCapacity -= size;
		[dates removeObjectForKey:key];
		[sizes removeObjectForKey:key];
		[cache removeObjectForKey:key];
		[keys removeLastObject];
	}
	
	currentCapacity += _size;
	[keys insertObject:_key atIndex:0];
	[dates setObject:_date forKey:_key];
	[sizes setObject:[NSNumber numberWithUnsignedInt:_size] forKey:_key];
	[cache setObject:_image forKey:_key];
	
	/*if (debug) {
		NSLog(@"***** putImage *****");
		NSLog([[NSNumber numberWithUnsignedInt:_size] stringValue]);
		NSLog(_key);
		[self printDebugInfo];
	}*/
}

- (void)removeImageForKey:(NSString *)_key
{
	NSNumber *number = (NSNumber *)[sizes objectForKey:_key];
	if (number) {
		unsigned size = [number unsignedIntValue];
		currentCapacity -= size;
		[dates removeObjectForKey:_key];
		[sizes removeObjectForKey:_key];
		[cache removeObjectForKey:_key];
		[keys removeObject:_key];
	}
	
	/*if (debug) {
		NSLog(@"***** removeImageForKey *****");
		NSLog(_key);
		[self printDebugInfo];
	}*/
}

- (NSImage *)currentImageForNavigator:(SpNavigator *)_navigator
{
	return [self getImageForNavigator:_navigator withSpFile:[_navigator currentFile] reverse:NO];
}

- (BOOL)isImageModified:(NSString *)_key
{
	return ![[dates objectForKey:_key] isEqualToDate:[[SpFileUtil sharedFileUtil]fileModifiedDate:_key]];
}

/*- (void)printDebugInfo
{
	NSLog([[NSString stringWithString:@"Capacity = "] stringByAppendingString:[[NSNumber numberWithLong:capacity] stringValue]]);
	NSLog([[NSString stringWithString:@"CurrentCapacity = "] stringByAppendingString:[[NSNumber numberWithLong:currentCapacity] stringValue]]);
	NSLog([keys description]);
	NSLog([sizes description]);
	NSLog([dates description]);
	NSLog([[cache allKeys] description]);
}*/

@end
