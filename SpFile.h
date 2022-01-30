//
//  SpFile.h
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SpFile : NSObject {
    NSString *fileName, *filePath, *realPath;
}

- (id)initWithFilePath:(NSString *)_filePath realPath:(NSString *)_realPath;
- (NSString *)fileName;
- (NSString *)realPath;
- (NSString *)filePath;

@end
