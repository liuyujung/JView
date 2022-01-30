//
//  MyFrameController.m
//
//  Created by Allan Liu on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyFrameController.h"

@implementation MyFrameController

- (id)init
{
    if (self = [super initWithWindowNibName:@"MyFrame"]) {
		controller = [[NSApp mainWindow] windowController];
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(windowSizeChange:)
			name:NSWindowDidResizeNotification object:[controller window]];
    }
    return self;
}

- (IBAction)click:(id)sender
{
    if ([sender tag]) {        
        
		int width = [[dimension cellWithTag:0] intValue];
		int height = [[dimension cellWithTag:1] intValue];
		
		if (width > 0 && height > 0) {
			[controller setFrameLocked:[lockBtn state]];
			[controller setCustomFrameSize:NSMakeSize(width, height)];
		}
		
    }
    [[self window] close];
    [NSApp endSheet:[self window]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self autorelease];
}

- (void)windowDidLoad
{
    [lockBtn setState:[controller frameLocked]];
	NSSize size = [[controller imageView] visibleRect].size;
	[[dimension cellWithTag:0] setStringValue:[[NSNumber numberWithInt:size.width] stringValue]];
	[[dimension cellWithTag:1] setStringValue:[[NSNumber numberWithInt:size.height] stringValue]];
}

- (void)windowSizeChange:(NSNotification *)notification
{
	[self windowDidLoad];
}

@end
