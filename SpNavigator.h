//
//  SpNavigator.h
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpFile.h"
#import "SpFolder.h"
#import "SpFileUtil.h"


@interface SpNavigator : NSObject {
    BOOL isFirst, slideRandom;
    SpFolder *baseFolder;
    SpFile *currentFile;
}

+ (SpNavigator *)navigatorWithPath:(NSString *)_path depth:(int)_depth;
- (id)initWithPath:(NSString *)_path depth:(int)_depth;
- (SpFile *)nextFile:(Navigation *)_navigation;
- (SpFile *)currentFile;
- (SpFolder *)currentFolder;
- (SpFolder *)baseFolder;
- (void)prepareCurrentFolderContent;
- (SpFile *)removeCurrentFile:(BOOL)_reverse nextFile:(BOOL)_next;
- (void)setSlideRandom:(BOOL)_slideRandom;

@end
