//
//  SlideController.m
//
//  Created by Allan Liu on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SlideController.h"

@interface SlideController (PrivateMethods)
- (void)render:(BOOL)expand;
- (void)setRatio:(float)_ratio;
- (NSString *)filename;
- (void)setFilename:(NSString *)_filename;
- (NSString *)description;
- (void)navigate:(Navigation *)navigation;
- (void)transformImage:(Type)transformType;
@end

@implementation SlideController

- (id)init
{
    if (self = [super initWithWindowNibName:@"Slide"]) {
		ratio = 1;
		allowToExpand = NO;
		imageView = nil;
		navigator = nil;
		image = nil;
		filename = nil;
    }
    return self;
}

// used by full screen untitled image
- (id)initWithImage:(NSImage *)_image
{
	if (self = [super initWithWindowNibName:@"Slide"]) {
		ratio = 1;
		allowToExpand = NO;
		imageView = nil;
		navigator = nil;
		image = [_image retain];
		[self setFilename:b_UNTITLED];
	}
	return self;
}

// used by full screen
- (id)initWithFile:(NSString *)_filename
{
	if (self = [super initWithWindowNibName:@"Slide"]) {
		ratio = 1;
		allowToExpand = NO;
		imageView = nil;
		image = nil;
		filename = nil;
		navigator = [[SpNavigator alloc] initWithPath:_filename depth:df_NAVIGATION_FOLDER_DEPTH];
	}
	return self;
}

- (void)dealloc
{
	[image release];
	[filename release];
	[imageView release];
	[navigator release];
	[super dealloc];
}

- (void)awakeFromNib
{
	NSWindow *window = [[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame]
		styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
	[window setReleasedWhenClosed:YES];
	[window useOptimizedDrawing:YES];
	[super setWindow:window];
	[window setDelegate:self];
	
	NSClipView *clipView = [[NSClipView alloc] initWithFrame:[window frame]];
	[clipView setBackgroundColor:df_SLIDE_BG_COLOR];
	[window setContentView:[clipView autorelease]];
	
	imageView = [[MyImageView alloc] initWithFrame:[window frame]];
	[imageView setAnimates:YES];
	[imageView setImageFrameStyle:NSImageFrameNone];
	[imageView setImageAlignment:NSImageAlignCenter];
	[imageView setImageScaling:NSImageScaleAxesIndependently];
	[clipView addSubview:imageView];
	[imageView setHidden:YES];
	
	[[NSApp delegate] hideWindows];
	
	//[NSApp addWindowsItem:window title:@"Slideshow" filename:NO];
	HideMenuBar();
}

- (void)openOptionPanel
{
	NSPanel *optionPanel = [optionsDelegate optionPanel];
	[optionsDelegate setWindow:[super window]];
	//[[optionPanel delegate] setWindow:[super window]];
	[optionPanel center];
	[optionPanel makeKeyAndOrderFront:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
	// has to stop it before releasing this instance
	[super stopTimer];
	df_SLIDE_IS_SLIDE = NO;
	[NSApp setSlideWindow:nil];
	[NSCursor unhide];
	[[NSApp delegate] unhideWindows];
	ShowMenuBar();
	[self autorelease];
}

- (SpNavigator *)navigator
{
	return navigator;
}

- (void)setNavigator:(SpNavigator *)_navigator
{
	[navigator autorelease];
	navigator = [_navigator retain];
}

- (void)setRatio:(float)_ratio
{
	ratio = _ratio;
}

- (NSString *)filename
{
	return filename;
}

- (void)setFilename:(NSString *)_filename
{
	[filename autorelease];
	filename = [_filename copy];
}

// override
- (MyMoveToObject *)moveToObject
{
	if (!moveToObject) {
		moveToObject = [[MyMoveToObject alloc] initWithDocumentController:self];
		[moveToObject setUseAlertPanel:YES];
	}
	return moveToObject;
}

// override
- (void)deleteCurrentImage
{
	[super pauseTimer];
	int result = 1;
	if (df_WARN_BEFORE_DELETE) {
		[NSCursor unhide];
		NSMutableString *title = [NSMutableString stringWithString:b_RECYCLE_SHEET_TITLE];
		[title appendString:@"\""];
		[title appendString:[filename lastPathComponent]];
		[title appendString:@"\""];
		result = NSRunAlertPanel(title, b_RECYCLE_CONFIRM, b_OK, b_CANCEL, nil);
		[NSCursor hide];
	}
	if (result == 1) [super deleteCurrentImage];
	[super resumeTimer];
}

// override
- (void)finishOperation:(NSImage *)_image
{
	[image autorelease];
	if (!_image) {
		[imageView setImage:nil];
		[imageView setNeedsDisplay:YES];
		[NSCursor unhide];
		NSRunAlertPanel(nil, b_NO_IMAGE, b_OK, nil, nil);
		[[super window] close];
	} else {
		image = [_image retain];
		[self setFilename:[[navigator currentFile] filePath]];
		[imageView setImage:image];
		[self render:allowToExpand];
	}
}

- (void)start:(BOOL)_allowToExpand useTimer:(BOOL)useTimer
{
	//initialize the views
	NSWindow *window = [super window];
	//[[window contentView] setBackgroundColor:df_SLIDE_BG_COLOR];
	[imageView setHidden:NO];
	[window makeKeyAndOrderFront:self];
	
	// set initial state
	if ([filename isEqualToString:b_UNTITLED]) {
		useTimer = NO;
	} else {
		
		Navigation *navigation = [SpFolder navigation];
		image = [[imageCache nextImageForNavigator:navigator navigation:navigation] retain];
		free(navigation);
		
		if (image) {
			[[NSApp delegate] setMostRecentPath:[[navigator baseFolder] filePath]];
			[self setFilename:[[navigator currentFile] filePath]];
		} else {
			[NSCursor unhide];
			NSRunAlertPanel(nil, b_NO_IMAGE, b_OK, nil, nil);
			// the window will be closed automatically at this point
			// when the option panel is closed and released
			// no slideshow has started/global variable set
			return;
		}
	}
	
	[imageView setImage:image];
	
	df_SLIDE_IS_SLIDE = YES;
	allowToExpand = _allowToExpand;
	[NSApp setSlideWindow:window];
	[NSCursor hide];
	[self render:allowToExpand];
	
	if (useTimer) {
		[super startTimer];
	}
	
}

- (void)render:(BOOL)expand
{	
	if (expand) ratio = 1.0;
	NSSize currentSize = NSMakeSize([imageView image].size.width * ratio, [imageView image].size.height * ratio),
		   screenSize = [[super window] frame].size;
	
	float r;
	if (currentSize.width > screenSize.width || expand) {
		r = screenSize.width / currentSize.width;
		currentSize.width = screenSize.width;
		currentSize.height *= r;
		ratio *= r;
	}
	
	if (currentSize.height > screenSize.height) {
		r = screenSize.height / currentSize.height;
		currentSize.height = screenSize.height;
		currentSize.width *= r;
		ratio *= r;
	}
	
	float offsetX = floor((screenSize.width - currentSize.width) / 2);
	float offsetY = floor((screenSize.height - currentSize.height) / 2);
	
	NSRect frameRect = NSMakeRect(offsetX, offsetY, currentSize.width, currentSize.height);
	//[[imageView superview] setFrame:frameRect];
	//[imageView setFrameSize:frameRect.size];
	[imageView setFrame:frameRect];
}

- (void)keyDown:(NSEvent *)event
{	
	NSUInteger modifierFlags = [event modifierFlags];
	NSString *characters = [event characters];
	unsigned short keyCode = [event keyCode];
	//NSLog(@"keycode = %d", keyCode);
	
	unichar key = ([characters length] ? [characters characterAtIndex:0] : (keyCode == 32 ? 'u' : 0)); // for opt-U
	if (key == 0) return;
	
	if (modifierFlags & NSCommandKeyMask) {
		switch (keyCode) {
			case 12: // cmd-Q
				[NSApp terminate:self];
				return;
			case 13: // cmd-W
				[[super window] close];
				return;
		}
	}
	
	if ([event modifierFlags] & NSAlternateKeyMask) {
		switch(keyCode) {
			case 37: // L
				[self transformImage:rotateLeft];
				return;
			case 15: // R
				[self transformImage:rotateRight];
				return;
			case 4: // H
				[self transformImage:flipHorizontal];
				return;
			case 9: // V
				[self transformImage:flipVertical];
				return;
			case 31: // O
				[imageView resetTransform];
				[imageView setImage:image];
				[self render:allowToExpand];
				return;
		}
	}
	
	switch (key) {
		
		case 'w':
		case 'W':
			allowToExpand = NO;
		case '1':
			[self setRatio:1.0];
			[self render:NO];
			return;
			
		case '2':
			[self setRatio:2.0];
			[self render:NO];
			return;
			
		case '3':
			[self setRatio:0.25];
			[self render:NO];
			return;
			
		case '5':
			[self setRatio:0.5];
			[self render:NO];
			return;
			
		case '7':
			[self setRatio:0.75];
			[self render:NO];
			return;
			
		case '-':
		case '_':
			[self setRatio:[[SpImageUtil sharedImageUtil] nextZoomRatioWithRatio:ratio zoomIn:NO]];
			[self render:NO];
			return;
			
		case '=':
		case '+':
			[self setRatio:[[SpImageUtil sharedImageUtil] nextZoomRatioWithRatio:ratio zoomIn:YES]];
			[self render:NO];
			return;
			
		case 'e':
		case 'E':
			allowToExpand = YES;
			[self render:YES];
			return;
			
		case 'i':
		case 'I':
			[NSCursor unhide];
			isSpecialAlert = YES;
			NSRunAlertPanel(nil, [self description], b_OK, nil, nil);
			isSpecialAlert = NO;
			[NSCursor hide];
			return;
			
		case 0x1b: // esc
			if ([NSApp modalWindow]) {
				[NSApp stopModal];
			} else {
				[[super window] close];
			}
			return;
	}
	
	if ([filename isEqualToString:b_UNTITLED]) return;
	
	if (key == df_NEXT_IMAGE_KEY || (key == NSRightArrowFunctionKey && modifierFlags & NSCommandKeyMask)) {
		key = '>';
	} else if (key == df_PREVIOUS_IMAGE_KEY || (key == NSLeftArrowFunctionKey && modifierFlags & NSCommandKeyMask)) {
		key = '<';
	} else if (key == df_NEXT_RANDOM_KEY || (key == NSRightArrowFunctionKey && modifierFlags & NSControlKeyMask)) {
		key = ']';
	} else if (key == df_PREVIOUS_RANDOM_KEY || (key == NSLeftArrowFunctionKey && modifierFlags & NSControlKeyMask)) {
		key = '[';
	}
	
	Navigation *navigation = [SpFolder navigation];
	
	switch (key) {
		case ']':
			navigation->random = YES;
			[self navigate:navigation];
			free(navigation);
			return;
			
		case 0x20: // space
		case '>':
			[self navigate:navigation];
			free(navigation);
			return;
			
		case '[':
			navigation->random = YES;
			navigation->reverse = YES;
			[self navigate:navigation];
			free(navigation);
			return;
			
		case '<':
			navigation->reverse = YES;
			[self navigate:navigation];
			free(navigation);
			return;
			
		case 'r':
		case 'R':
			navigation->random = YES;
			navigation->reshuffle = YES;
			[self navigate:navigation];
			free(navigation);
			return;
		
		case 0x15: // crtl-U to trap ctrl key
		case 'U':
			navigation->uptwice = YES;
		case 'u':
			if (modifierFlags & NSControlKeyMask) {
				navigation->random = YES;
			}
			if (modifierFlags & NSAlternateKeyMask) {
				navigation->uptwice = NO; // does not matter
				navigation->uptotop = YES;
			}
			navigation->jumpup = YES;
			[self navigate:navigation];
			free(navigation);
			return;
	}
	free(navigation);
		
	switch (key) {
			
		case 'l':
		case 'L':
			[[navigator currentFolder] setLocked];
			break;
			
		case 'x':
		case 'X':
			if (modifierFlags & NSCommandKeyMask) {
				if ([super isTimerValid]) [super stopTimer];
				else [super startTimer];
			}
			break;
		
		case 'p':
        case 'P':
			if ([super isTimerValid]) [super stopTimer];
			else [super startTimer];
			break;
			
		case NSDeleteCharacter:
		case NSDeleteFunctionKey:
        case 'd':
        case 'D':
			[self deleteCurrentImage];
			break;
			
		case 'm':
		case 'M':
			if (modifierFlags & NSCommandKeyMask) {
				[super moveCurrentImage:YES];
			}
			break;
			
		case 't':
		case 'T':
			[super moveCurrentImage:NO];
			break;
	}
}

- (void)showNextImage:(Navigation *)_navigation
{
	[image autorelease];
	image = [imageCache nextImageForNavigator:navigator navigation:_navigation];
	if (!image) {
		[[super window] close];
		return;
	} else {
		[image retain];
		[self setFilename:[[navigator currentFile] filePath]];
		[imageView setImage:image];
		ratio = 1.0;
		[self render:allowToExpand];
	}
}

- (void)navigate:(Navigation *)navigation
{
	[super pauseTimer];
	[self showNextImage:navigation];
	[super resumeTimer];
}

- (void)transformImage:(Type)transformType
{
	[imageView prepareTransformView:transformType];
	[imageView setImage:image];
    [self render:allowToExpand];
}

- (NSString *)description
{
	NSMutableString *description = [NSMutableString string];
	NSSize size = [[imageView image] size];
	BOOL isLocked = [[navigator currentFolder] isLocked];
	
	if (isLocked) {
		[description appendString:@"["];
		[description appendString:[filename stringByDeletingLastPathComponent]];
		[description appendString:@"]"];
		[description appendString:@"/"];
		[description appendString:[filename lastPathComponent]];
	} else {
		[description appendString:filename];
	}
	
	[description appendString:@" "];
	[description appendString:[[NSNumber numberWithInt:size.width] stringValue]];
	[description appendString:@"x"];
	[description appendString:[[NSNumber numberWithInt:size.height] stringValue]];
	 
	[description appendString:@" @ "];
	[description appendString:[[NSNumber numberWithFloat:floor(ratio * 10000) / 100] stringValue]];
	[description appendString:@"%%"];
	
	return [description description];
}

@end
