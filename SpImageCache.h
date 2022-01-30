//
//  SpCache.h
//  FileNavigator
//
//  Created by Allan on Sun Dec 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SpNavigator.h"


@interface SpImageCache : NSObject {
	// capacity size in mega bytes, 100M physical = 5M here
	unsigned long capacity, currentCapacity;
	// paths or keys sorted by the time of access, 0 has the latest access
	NSMutableArray *keys;
	// sizes has the size of the key value
	// cache contains the real content of image data
	// dates contains the last modified date of image data
	NSMutableDictionary *sizes, *cache, *dates;
}

- (id)initWithCapacityMBytes:(int)_capacity;
- (void)setCacheSizeMBytes:(int)_capacity;
- (void)reset;
- (NSImage *)nextImageForNavigator:(SpNavigator *)_navigator navigation:(Navigation *)_navigation;
- (NSImage *)performActionForNavigator:(SpNavigator *)_navigator operation:(Operation)_operation destination:(NSString *)_destination;
- (NSImage *)removeImageForNavigator:(SpNavigator *)_navigator;
- (void)resetCurrentFolderModifcationDateForNavigator:(SpNavigator *)_navigator;
- (NSImage *)currentImageForNavigator:(SpNavigator *)_navigator;
- (SpNavigator *)navigatorForImageData:(NSData *)_data filePath:(NSString *)_filePath;

@end
