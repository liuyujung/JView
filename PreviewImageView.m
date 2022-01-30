//
//  PreviewImageView.m
//
//  Created by Allan Liu on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreviewImageView.h"

@interface PreviewImageView (PrivateMethods)
- (void)visibleRectDidChange:(NSNotification *)aNotification;
- (void)previewImageDidChange:(NSNotification *)aNotification;
@end

@implementation PreviewImageView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        previewImage = nil;
		scaleFactor = 1.0;
		inDrag = NO;
    }
    return self;
}

- (void)dealloc {
	[previewImage release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)awakeFromNib {
	[self previewImageDidChange:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(visibleRectDidChange:) name:VisibleRectChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(previewImageDidChange:) name:PreviewImageChangeNotification object:nil];
}

- (void)visibleRectDidChange:(NSNotification *)aNotification {
	[super setNeedsDisplay:YES];
}

- (void)previewImageDidChange:(NSNotification *)aNotification {
	NSImage *image = [[[[super window] windowController] myImageView] image];
	[previewImage autorelease];
	if (image) {
		previewImage = [image retain];
	} else {
		previewImage = nil;
	}
	NSRect frame = [[super window] frame];
	[self adjustFrameWidth:frame.size.width height:frame.size.height];
	[[super window] displayIfNeeded];
}

- (void)adjustFrameWidth:(float)width height:(float)height {
	
	NSSize size;
	width -= 40;
	height -= 40;
	
	MyImageView *myImageView = [[[super window] windowController] myImageView];
	if (myImageView) {
		size = [[myImageView image] size];
	} else {
		size = NSMakeSize(width, height);
	}
	
	scaleFactor = 1.0;
	
	if (size.width > width) {
		scaleFactor = width / size.width;
	}
	
	if (size.height * scaleFactor > height) {
		scaleFactor *= height / (size.height * scaleFactor);
	}
	
	NSSize frameSize = NSMakeSize(size.width * scaleFactor, size.height * scaleFactor);
	NSPoint frameOrigin = NSMakePoint((width - frameSize.width) / 2.0 + 20.0, (height - frameSize.height) / 2.0 + 20.0);
	[super setFrame:NSMakeRect(frameOrigin.x, frameOrigin.y, frameSize.width, frameSize.height)];
}

- (void)drawRect:(NSRect)rect
{
	if (!previewImage) return;
	
	MyImageView *myImageView = [[[super window] windowController] myImageView];
	id controller = [[myImageView window] windowController];
	float ratio = [controller ratio];
	NSSize currentSize = [[myImageView image] size];
	NSRect visibleRect = [myImageView visibleRect];
	
	//drawVisibleRect = NSMakeRect(visibleRect.origin.x, (currentSize.height - visibleRect.size.height - visibleRect.origin.y),
		//visibleRect.size.width, visibleRect.size.height);
	
	drawVisibleRect = NSMakeRect(visibleRect.origin.x / ratio, (currentSize.height * ratio - visibleRect.size.height - visibleRect.origin.y) / ratio,
		visibleRect.size.width / ratio, visibleRect.size.height / ratio);
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:scaleFactor yBy:scaleFactor];
	[transform concat];
	
	[previewImage drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, currentSize.width, currentSize.height)
		operation:NSCompositeCopy fraction:0.5];
	
	[previewImage drawInRect:drawVisibleRect fromRect:drawVisibleRect operation:NSCompositeCopy fraction:1];
	
	[[NSColor lightGrayColor] set];
	NSFrameRect(drawVisibleRect);
}

// if set to hidden, this will not be called
- (BOOL)mouseDownCanMoveWindow {
	return NO;
}

- (void)mouseDown:(NSEvent *)theEvent {
	
	downPoint = [super convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSRect previewVisibleRect = NSMakeRect(drawVisibleRect.origin.x * scaleFactor, drawVisibleRect.origin.y * scaleFactor,
										   drawVisibleRect.size.width * scaleFactor, drawVisibleRect.size.height * scaleFactor);
	
	if ([super mouse:downPoint inRect:previewVisibleRect]) {
		inDrag = YES;
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	
	if (inDrag) {
		
		MyImageView *myImageView = [[[super window] windowController] myImageView];
		float ratio = [[[myImageView window] windowController] ratio];
		NSPoint point = [super convertPoint:[theEvent locationInWindow] fromView:nil];
		
		NSPoint point1 = NSMakePoint(downPoint.x / scaleFactor * ratio, downPoint.y / scaleFactor * ratio);
		NSPoint point2 = NSMakePoint(point.x / scaleFactor * ratio, point.y / scaleFactor * ratio);
		//NSPoint point1 = NSMakePoint(downPoint.x / scaleFactor, downPoint.y / scaleFactor);
		//NSPoint point2 = NSMakePoint(point.x / scaleFactor, point.y / scaleFactor);
		
		NSPoint origin = [myImageView visibleRect].origin;
		
		origin.x += (point2.x - point1.x);
		origin.y += (point1.y - point2.y);
		
		downPoint = point;
		
		[myImageView scrollPoint:origin];
		[super setNeedsDisplay:YES];
	}
}

- (void)mouseUp:(NSEvent *)theEvent {
	downPoint = NSZeroPoint;
	inDrag = NO;
}

@end
