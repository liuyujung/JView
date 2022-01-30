//
//  SpImageUtil.h
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SpImageUtil : NSObject {

}

+ (id)sharedImageUtil;
- (NSImage *)imageWithFilename:(NSString *)_filename;
- (NSImage *)imageWithData:(NSData *)_data;
- (float)nextZoomRatioWithRatio:(float)_currentRatio zoomIn:(BOOL)_in;

@end
