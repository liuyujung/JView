//
//  PreviewController.m
//
//  Created by Allan Liu on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreviewController.h"

@implementation PreviewController

- (id)init
{
	if (self = [super initWithWindowNibName:@"Preview"]) {
		myImageView = nil;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)windowDidLoad {
	NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
	NSRect frame = [[super window] frame];
	NSPoint origin = NSMakePoint(screenRect.size.width - frame.size.width, screenRect.size.height - frame.size.height);
	[[super window] setFrameOrigin:origin];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(windowBecomeMain:) name:WindowBecomeMainNotification object:nil];
	
}

- (void)windowBecomeMain:(NSNotification *)notification {
	
	id controller = [notification object];
	if ([controller isKindOfClass:[MyDocumentController class]]) {
		if (myImageView == [controller imageView]) return;
		myImageView = [controller imageView];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(visibleBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[myImageView superview]];
	} else {
		myImageView = nil;
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PreviewImageChangeNotification object:nil];
}

- (void)visibleBoundsDidChange:(NSNotification *)notification {
	// only handles scrolling
	[[NSNotificationCenter defaultCenter] postNotificationName:VisibleRectChangeNotification object:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self autorelease];
}

- (MyImageView *)myImageView {
	return myImageView;
}

// for instant drag after clicking on the panel, no second click is needed for dragging
- (void)windowDidBecomeKey:(NSNotification *)aNotification {
	
	NSEvent *event = [NSApp currentEvent];
	
	if ([event type] == NSLeftMouseDown) {
		
		NSPoint point = [event locationInWindow];
		
		if ([previewImageView mouse:point inRect:[previewImageView frame]]) {
			[NSApp postEvent:event atStart:YES];
		}
	}
}

- (void)windowDidResize:(NSNotification *)aNotification {
	
	if ([previewImageView isHidden]) return; // ???
	
	NSPanel *panel = (NSPanel *) [aNotification object];
	NSRect frame = [panel frame];
	
	[previewImageView adjustFrameWidth:frame.size.width height:frame.size.height];
}

@end
