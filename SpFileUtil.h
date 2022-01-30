//
//  SpFileUtil.h
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@class SpFile, SpFolder;

@interface SpFileUtil : NSObject {

}

+ (id)sharedFileUtil;
- (SpFile *)fileWithPath:(NSString *)_filePath;
- (NSMutableArray *)folderContentAtPath:(NSString *)_folderPath parent:(SpFolder *)_parent level:(int)_level depth:(int)_depth slideRandom:(BOOL)_slideRandom;
- (NSDate *)fileModifiedDate:(NSString *)_filePath;
- (NSDate *)folderModifiedDate:(NSString *)_folderPath;
- (BOOL)trashFileWithFilename:(NSString *)_filename;
- (BOOL)deleteFileWithFilename:(NSString *)_filename;
- (BOOL)moveFileWithFilename:(NSString *)_filename to:(NSString *)_destination;
- (NSMutableArray *)allContentAtFolder:(SpFolder *)_baseFolder depth:(int)_depth;

@end
