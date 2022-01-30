//
//  SpUtil.h
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SpUtil : NSObject {

}

+ (id)sharedUtil;
- (NSArray *)componentArrayWithColor:(NSColor *)_color;
- (NSColor *)colorWithComponentArray:(NSArray *)_components;

@end
