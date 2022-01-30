//
//  Operatable.h
//  JViewbt
//
//  Created by Allan Liu on 12/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol Operatable
- (SpNavigator *)navigator;
- (void)deleteCurrentImage;
- (void)moveCurrentImage:(BOOL)_forceToOpen;
- (void)performOperation:(Operation)_operation contextPath:(NSString *)_contextPath;
- (void)finishOperation:(NSImage *)_image;
@end
