//
//  PreviewImageView.h
//
//  Created by Allan Liu on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreviewImageView : NSView {
	NSImage *previewImage;
	BOOL inDrag;
	float scaleFactor;
	NSPoint downPoint;
	NSRect drawVisibleRect;
}

- (void)adjustFrameWidth:(float)width height:(float)height;

@end
