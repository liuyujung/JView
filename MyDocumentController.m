
@interface MyDocumentController (PrivateMethods)
- (NSSize)contentSizeForImageSize:(NSSize)size;
- (void)configureScrollPolicy:(NSSize)size frameSize:(NSSize)frameSize;
- (void)configureCursor;
- (void)start;
- (NSString *)description;
- (NSString *)sizeDescription:(NSSize)size;
- (void)updateTitle;
- (void)centerWindowFrame:(NSRect *)frameRect screenRect:(NSRect)screenRect;
- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)render:(BOOL)resizeToFit expand:(BOOL)expand;
@end

@implementation MyDocumentController

- (id)initWithFilename:(NSString *)_filename
{
    if (self = [super initWithWindowNibName:@"MyDocument"]) {
		navigator = [[SpNavigator alloc] initWithPath:_filename depth:df_NAVIGATION_FOLDER_DEPTH];
		Navigation *navigation = [SpFolder navigation];
		image = [imageCache nextImageForNavigator:navigator navigation:navigation];
		free(navigation);
		if (!image) {
			[self release];
			return nil;
		}
		[image retain];
		[self setFilename:[[navigator currentFile] filePath]];
		zoomController = nil;
		saveAsObject = nil;
		frameLocked = NO;
		hasVertical = NO;
		hasHorizontal = NO;
		flag = NO;
		wasRepeat = NO;
		repeatCount = 0;
    }
    return self; 
}

// for paste only
- (id)initWithImage:(NSImage *)_image
{
    if (self = [super initWithWindowNibName:@"MyDocument"]) {
		image = [_image retain];
        [self setFilename:b_UNTITLED];
		zoomController = nil;
		saveAsObject = nil;
		frameLocked = NO;
        hasVertical = NO;
		hasHorizontal = NO;
		flag = NO;
		wasRepeat = NO;
		repeatCount = 0;
    }
    return self;
}

- (void)dealloc
{
	//NSLog(@"dealloc_mydoc");
	[saveAsObject release];
	[zoomController release];
	[navigator release];
    [filename release];
    [image release];
    [super dealloc];
}

- (MyImageView *)imageView
{
    return imageView;
}

- (NSScrollView *)scrollView
{
	return scrollView;
}

- (SpNavigator *)navigator
{
	return navigator;
}

- (BOOL)hasVertical
{
	return hasVertical;
}

- (BOOL)hasHorizontal
{
	return hasHorizontal;
}

- (BOOL)hasAnyScroller
{
	return hasVertical || hasHorizontal;
}

- (BOOL)frameLocked
{
	return frameLocked;
}

- (void)setFrameLocked:(BOOL)_frameLocked
{
	frameLocked = _frameLocked;
}

- (void)setNavigator:(SpNavigator *)_navigator
{
	[navigator autorelease];
	navigator = [_navigator retain];
	
	[image autorelease];
	Navigation *navigation = [SpFolder navigation];
	image = [[imageCache nextImageForNavigator:navigator navigation:navigation] retain];
	free(navigation);
	
	[imageView resetTransform];
	
	ratio = 1;
	[self setFilename:[[navigator currentFile] filePath]];
	[self start]; // simplify with only setting the represented file?
}

- (void)setFilename:(NSString *)_filename
{
    [filename autorelease];
    filename = [_filename copy];
}

- (NSString *)filename
{
	// always the current full 'file path', if it's untitled, it's 'untitled'
	// [[navigator currentFile] filePath] gives the current image path, it won't be untitled
    return filename;
}

- (NSImage *)image
{
    return image;
}

- (void)revealInFinder
{
	[[NSWorkspace sharedWorkspace] selectFile:filename inFileViewerRootedAtPath:nil];
}

// current representation
- (NSImage *)currentImage
{
    NSImage *currentImage = [[NSImage alloc] initWithData:[imageView dataWithPDFInsideRect:[imageView frame]]];
    return [currentImage autorelease];
}

- (NSData *)currentImageData:(BOOL)visibleArea originalSize:(BOOL)originalSize
{
	if (visibleArea) {
		
		/*
        [imageView lockFocus];
		NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[imageView visibleRect]];
		[imageView unlockFocus];
		
		[newRep autorelease];
		
		return [newRep TIFFRepresentation];
        */
        
        NSImage *visibleImage = [[NSImage alloc] initWithData:[imageView dataWithPDFInsideRect:[imageView visibleRect]]];
        [visibleImage autorelease];
        return [visibleImage TIFFRepresentation];
		
	} else if (originalSize) {

		MyImageView *newImageView = [imageView copy];
	
		NSImage *newImage = [[NSImage alloc] initWithData:[newImageView dataWithPDFInsideRect:[newImageView frame]]];
		
		[newImageView autorelease];
		[newImage autorelease];
		
		return [newImage TIFFRepresentation];
	}
	
	NSImage *currentImage = [[NSImage alloc] initWithData:[imageView dataWithPDFInsideRect:[imageView frame]]];
	[currentImage autorelease];
	return [currentImage TIFFRepresentation];
}

- (NSSize)currentSize
{
	NSSize imageSize = [[imageView image] size];
    return NSMakeSize(floor(imageSize.width * ratio), floor(imageSize.height * ratio));
	//return NSMakeSize(imageSize.width * ratio, imageSize.height * ratio);
}

- (float)ratio
{
    return ratio;
}

- (void)setRatio:(float)_ratio
{
    ratio = _ratio;
}

- (void)windowDidLoad
{    
    [super windowDidLoad];
    [self setShouldCascadeWindows:NO];
    [[self window] useOptimizedDrawing:YES];
	//[[self window] setStyleMask:NSBorderlessWindowMask];
    [self start];
}

- (NSString *)description
{
    //NSSize size = [imageView imageSize];
	NSSize size = [[imageView image] size];
	BOOL isLocked = [[navigator currentFolder] isLocked];
	
    NSMutableString *title = [[NSMutableString alloc] init];
	
	if (isLocked) [title appendString:@"["];
    [title appendString:[filename lastPathComponent]];
	if (isLocked) [title appendString:@"]"];
	
    [title appendString:@" @ "];
    [title appendString:[[NSNumber numberWithFloat:(ratio * 100)] stringValue]];
    [title appendString:@"% "];
	
    [title appendString:[[NSNumber numberWithInt:size.width] stringValue]];
    [title appendString:@"x"];
    [title appendString:[[NSNumber numberWithInt:size.height] stringValue]];
	
	NSRect visibleRect = [[scrollView documentView] visibleRect]; 
	if (frameLocked) [title appendString:@" ["];
	else [title appendString:@" ("];
	[title appendString:[[NSNumber numberWithInt:visibleRect.size.width] stringValue]];
	[title appendString:@"x"];
	[title appendString:[[NSNumber numberWithInt:visibleRect.size.height] stringValue]];
	if (frameLocked) [title appendString:@"]"];
	else [title appendString:@") "];
	[title appendString:[self sizeDescription:size]];
    return [title autorelease];
}

- (NSString *)sizeDescription:(NSSize)size
{
	float quality = size.width > size.height ? size.width : size.height;
	NSMutableString *title = [[NSMutableString alloc] init];
	[title appendString:@" ("];
	if (quality >= 5000) { [title appendString:@"Mega"]; }
	else if (quality >= 4000) { [title appendString:@"Super"]; }
	else if (quality >= 3000) { [title appendString:@"High"]; }
	else if (quality >= 2000) { [title appendString:@"Medium"]; }
	else if (quality >= 1200) { [title appendString:@"Low"]; }
	else if (quality >= 900) { [title appendString:@"Small"]; }
	else if (quality >= 640) { [title appendString:@"Tiny"]; }
	else [title appendString:@"Bad"];
	[title appendString:@") "];
	if (quality >= 2000) { [title appendString:@"Good"];}
	else if (quality >= 1024) { [title appendString:@"Regular"];}
	else if (quality >= 640) { [title appendString:@"Medium"];}
	else { [title appendString:@"Small"];}
	return [title autorelease];
}

- (void)otherZoom
{
	if (!zoomController) zoomController = [[MyZoomController alloc] init];
    [NSApp beginSheet:[zoomController window] modalForWindow:[self window] modalDelegate:nil
        didEndSelector:nil contextInfo:NULL];
}

- (void)frameSize
{
	MyFrameController *frameController = [[MyFrameController alloc] init];
    [NSApp beginSheet:[frameController window] modalForWindow:[self window] modalDelegate:nil
	   didEndSelector:nil contextInfo:NULL];
}

- (void)getInfo
{
	MyInfoController *infoController = [[MyInfoController alloc] init];
    [NSApp beginSheet:[infoController window] modalForWindow:[self window] modalDelegate:nil
        didEndSelector:nil contextInfo:NULL];
}

- (void)start
{
    //[imageView setCustomImage:image];
	[imageView setImage:image];
    if (df_RESIZE_TO_FIT) ratio = 1.0;
    else ratio = df_DEFAULT_RATIO;
	BOOL untitled = [filename isEqualToString:b_UNTITLED];
    if (!untitled) [[self window] setRepresentedFilename:filename];
	[self resetScrollers];
    [self render:df_RESIZE_TO_FIT expand:untitled ? NO : df_ALLOW_TO_EXPAND];
}

- (void)render:(BOOL)resizeToFit
{
	[self render:resizeToFit expand:df_ALLOW_TO_EXPAND];
}

- (void)render:(BOOL)resizeToFit expand:(BOOL)expand
{
    NSSize contentSize, imageSizeToRender;
    NSRect origFrameRect, frameRect, screenRect = [[[self window] screen] visibleFrame];
    NSWindow *window = [self window];
    
	if (resizeToFit) {
		
        float r;
        
        if (resizeToFit) ratio = 1.0;
		NSSize currentSize = [self currentSize];
        imageSizeToRender = currentSize;
		
        if (imageSizeToRender.width > screenRect.size.width || expand) {
            r = screenRect.size.width / imageSizeToRender.width;
            imageSizeToRender.width = screenRect.size.width;
            imageSizeToRender.height *= r;
            ratio *= r;
        }
		
        if (imageSizeToRender.height > screenRect.size.height - WINDOW_TITLEBAR_HEIGHT) {
            r = (screenRect.size.height - WINDOW_TITLEBAR_HEIGHT) / imageSizeToRender.height;
            imageSizeToRender.height = screenRect.size.height - WINDOW_TITLEBAR_HEIGHT;
            imageSizeToRender.width *= r;
            ratio *= r;
        }
		
		ratio = floor(ratio * 10000);
		ratio /= 10000;
		
		//ratio = floor(ratio * 100);
		//ratio /= 100;
		
		//imageSizeToRender.width = currentSize.width * ratio;
		//imageSizeToRender.height = currentSize.height * ratio;
		
		imageSizeToRender.width = floor(imageSizeToRender.width);
		imageSizeToRender.height = floor(imageSizeToRender.height);
		
		contentSize = imageSizeToRender;
        
		if (!frameLocked) {
			[[self window] setShowsResizeIndicator:NO];
			[self resetScrollers];
		}
		
    } else {
		
        imageSizeToRender = [self currentSize];
        contentSize = [self contentSizeForImageSize:imageSizeToRender];
		
        [self configureScrollPolicy:imageSizeToRender frameSize:contentSize];
		
        if ((hasVertical || hasHorizontal) && !(hasVertical && hasHorizontal)) {
            if (hasVertical) contentSize.width += scroller_pixel;
            else contentSize.height += scroller_pixel;
		}		
    }
	
    [imageView setFrameSize:imageSizeToRender];
	
	NSSize maxSize = [NSWindow frameRectForContentRect:
		NSMakeRect(0, 0, imageSizeToRender.width, imageSizeToRender.height)
			styleMask:NSTitledWindowMask].size;
	if (hasHorizontal) maxSize.height += scroller_pixel;
	if (hasVertical) maxSize.width += scroller_pixel;
	[window setMaxSize:maxSize];
	
	if (frameLocked) {
		
		//NSSize size = [imageView visibleRect].size; // not reliable!
		[self setCustomFrameSize:lockedFrameSize];
		[[NSNotificationCenter defaultCenter] postNotificationName:WindowSizeChangeNotification object:self userInfo:nil];
		
	} else {
	
		flag = YES;
		origFrameRect = [window frame];
	
		frameRect = [NSWindow frameRectForContentRect:
			NSMakeRect(origFrameRect.origin.x, origFrameRect.origin.y, contentSize.width, contentSize.height)
				styleMask:NSTitledWindowMask];
	
		if (df_OPEN_WINDOW_CENTER) {
			[self centerWindowFrame:&frameRect screenRect:screenRect];
		} else {
			frameRect.origin.y = frameRect.origin.y + origFrameRect.size.height - frameRect.size.height;
		}
	
		[self configureCursor];
		[window setFrame:frameRect display:YES];
		[self updateTitle];
		[[NSNotificationCenter defaultCenter] postNotificationName:VisibleRectChangeNotification object:nil];
	}
	//[[NSNotificationCenter defaultCenter] postNotificationName:PreviewImageChangeNotification object:nil];
}

- (void)centerWindowFrame:(NSRect *)frameRect screenRect:(NSRect)screenRect
{
	frameRect->origin.x = floor(screenRect.origin.x + (screenRect.size.width - frameRect->size.width) / 2);
	frameRect->origin.y = floor(screenRect.origin.y + (screenRect.size.height - frameRect->size.height) / 4.0 * 3.0);
}

- (NSSize)contentSizeForImageSize:(NSSize)size
{
    NSSize contentSize = [[[self window] screen] visibleFrame].size;
	contentSize.height -= WINDOW_TITLEBAR_HEIGHT;
    if (size.height < contentSize.height)
        contentSize.height = size.height;
    if (size.width < contentSize.width)
        contentSize.width = size.width;
    return contentSize;
}

- (void)resetScrollers
{
    [scrollView setHasVerticalScroller:NO];
    [scrollView setHasHorizontalScroller:NO];
    hasVertical = NO;
    hasHorizontal = NO;
}

- (void)configureScrollPolicy:(NSSize)size frameSize:(NSSize)frameSize
{
	//NSLog(@"size height = %f", size.height);
	//NSLog(@"frame height = %f", frameSize.height);
    if (size.height > frameSize.height)
        hasVertical = YES;
    else
        hasVertical = NO;
    [scrollView setHasVerticalScroller:hasVertical];
	
	//NSLog(@"size width = %f", size.width);
	//NSLog(@"frame width = %f", frameSize.width);
    //if (size.width - 1 > frameSize.width) // hack!
	if (size.width > frameSize.width)
        hasHorizontal = YES;
    else
        hasHorizontal = NO;
    [scrollView setHasHorizontalScroller:hasHorizontal];
	
    [[self window] setShowsResizeIndicator:(hasVertical || hasHorizontal)];
}

- (void)configureCursor
{
	if (!hasVertical && !hasHorizontal) {
		[[scrollView contentView] setDocumentCursor:[NSCursor arrowCursor]];
	} else {
		[[scrollView contentView] setDocumentCursor:[NSCursor openHandCursor]];
	}
}

- (void)windowDidResize:(NSNotification *)notification
{
    BOOL changed, hadVertical, hadHorizontal;
    NSSize maxSize;
    NSRect frameRect;
    if (flag) {
        flag = NO;
        return;
    }
	
	changed = NO;
	hadVertical = hasVertical;
	hadHorizontal = hasHorizontal;
	[self configureScrollPolicy:[self currentSize] frameSize:[scrollView documentVisibleRect].size];
	frameRect = [[notification object] frame];
	maxSize = [[notification object] maxSize];
	if (hasVertical) {
		if (!hadVertical) {
			// add
			changed = YES;
			frameRect.size.width += scroller_pixel;
			maxSize.width += scroller_pixel;
		}
	} else {
		if (hadVertical) {
			// remove
			changed = YES;
			frameRect.size.width -= scroller_pixel;
			maxSize.width -= scroller_pixel;
		}
	}
	if (hasHorizontal) {
		if (!hadHorizontal) {
			// add
			changed = YES;
			frameRect.size.height += scroller_pixel;
			frameRect.origin.y -= scroller_pixel;
			maxSize.height += scroller_pixel;
		}
	} else {
		if (hadHorizontal) {
			// remove
			changed = YES;
			frameRect.size.height -= scroller_pixel;
			frameRect.origin.y += scroller_pixel;
			maxSize.height -= scroller_pixel;
		}
	}
	if (changed) {
		flag = YES;
		[[notification object] setMaxSize:maxSize];
		[[notification object] setFrame:frameRect display:NO];
	}

	[self configureCursor];
	[[self window] setTitle:[self description]];
	[[NSNotificationCenter defaultCenter] postNotificationName:VisibleRectChangeNotification object:nil];
}

- (void)updateTitle
{
    [[self window] setTitle:[self description]];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:WindowSizeChangeNotification object:self userInfo:nil];
}

// override
- (void)deleteCurrentImage
{
	[super pauseTimer];
	if (df_WARN_BEFORE_DELETE) {
		NSMutableString *title = [NSMutableString stringWithString:b_RECYCLE_SHEET_TITLE];
		[title appendString:@"\""];
		[title appendString:[filename lastPathComponent]];
		[title appendString:@"\""];
        NSBeginAlertSheet(title, b_OK, b_CANCEL, nil, [self window], self,
            @selector(deleteSheetDidEnd:returnCode:contextInfo:), NULL, nil, b_RECYCLE_CONFIRM, nil);
    } else {
		[super deleteCurrentImage];
		[super resumeTimer];
    }
}

- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) {
		[super performOperation:recycleOperation contextPath:nil];
    }
    [sheet close];
	[super resumeTimer];
}

// override
- (void)finishOperation:(NSImage *)_image
{
	[image autorelease];
	if (!_image) {
		[[self window] close];
	} else {
		image = [_image retain];
		[self setFilename:[[navigator currentFile] filePath]];
		[self start];
	}
}

- (void)showNextImage:(Navigation *)_navigation
{
    if ([filename isEqualToString:b_UNTITLED]) return;
	
	[image autorelease];
	image = [imageCache nextImageForNavigator:navigator navigation:_navigation];
	if (!image) {
		[[super window] close];
	} else {
		[image retain];
		[self setFilename:[[navigator currentFile] filePath]];
		[self start];
	}
}

- (void)saveAs
{
	if (!saveAsObject) saveAsObject = [[MySaveAsObject alloc] initWithDocumentController:self];
	[saveAsObject saveAs];
}

- (void)transformImage:(Type)transformType
{
	[imageView prepareTransformView:transformType];
	[imageView setImage:image];
    [self render:df_RESIZE_TO_FIT expand:df_ALLOW_TO_EXPAND];
}

- (void)originalImage
{
	//if (![imageView isTransformed]) return;
	ratio = 1.0;
	[imageView resetTransform];
	[imageView setImage:image];
	[self render:NO expand:NO];
}

- (void)keyDown:(NSEvent *)event
{	
	NSString *characters = [event characters];
	NSUInteger modifierFlags = [event modifierFlags];

	unichar key = ([characters length] ? [characters characterAtIndex:0] : ([event keyCode] == 32 ? 'u' : 0)); // for opt-U
	if (key == 0) return;
	
	if (hasVertical || hasHorizontal) {
		NSRect visibleRect = [scrollView documentVisibleRect];
		switch (key) {
			case NSUpArrowFunctionKey:
				if ([event isARepeat]) {
					if (wasRepeat) repeatCount++;
					else wasRepeat = YES;
					visibleRect.origin.y -= df_VERTICAL_LINE_PIXELS * pow(df_SCROLL_ACCE_FACTOR, repeatCount);
				} else {
					wasRepeat = NO;
					repeatCount = 0;
					visibleRect.origin.y -= df_VERTICAL_LINE_PIXELS;
				}
				[imageView scrollPoint:visibleRect.origin];
				return;
			case NSDownArrowFunctionKey:
				if ([event isARepeat]) {
					if (wasRepeat) repeatCount++;
					else wasRepeat = YES;
					visibleRect.origin.y += df_VERTICAL_LINE_PIXELS * pow(df_SCROLL_ACCE_FACTOR, repeatCount);
				} else {
					wasRepeat = NO;
					repeatCount = 0;
					visibleRect.origin.y += df_VERTICAL_LINE_PIXELS;
				}
				[imageView scrollPoint:visibleRect.origin];
				return;
			case NSLeftArrowFunctionKey:
				if ([event isARepeat]) {
					if (wasRepeat) repeatCount++;
					else wasRepeat = YES;
					visibleRect.origin.x -= df_HORIZONTAL_LINE_PIXELS * pow(1.2, repeatCount);
				} else {
					wasRepeat = NO;
					repeatCount = 0;
					visibleRect.origin.x -= df_HORIZONTAL_LINE_PIXELS;
				}
				[imageView scrollPoint:visibleRect.origin];
				return;
			case NSRightArrowFunctionKey:
				if ([event isARepeat]) {
					if (wasRepeat) repeatCount++;
					else wasRepeat = YES;
					visibleRect.origin.x += df_HORIZONTAL_LINE_PIXELS * pow(1.2, repeatCount);
				} else {
					wasRepeat = NO;
					repeatCount = 0;
					visibleRect.origin.x += df_HORIZONTAL_LINE_PIXELS;
				}
				[imageView scrollPoint:visibleRect.origin];
				return;
			case NSPageUpFunctionKey:
				visibleRect.origin.y -= df_VERTICAL_PAGE_PIXELS;
				[imageView scrollPoint:visibleRect.origin];
				return;
			case NSPageDownFunctionKey:
				visibleRect.origin.y += df_VERTICAL_PAGE_PIXELS;
				[imageView scrollPoint:visibleRect.origin];
				return;
			case NSHomeFunctionKey:
				visibleRect.origin.y = 0;
				[imageView scrollPoint:visibleRect.origin];
				return;
			case NSEndFunctionKey:
				visibleRect.origin.y = [imageView bounds].size.height;
				[imageView scrollPoint:visibleRect.origin];
				return;
		}		
	}
	wasRepeat = NO;
	repeatCount = 0;
	
	switch (key) {
		case 'g':
			frameLocked = YES;
			[self setCustomFrameSize:NSMakeSize(512, 512)];
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
	
	Navigation *navigation;
	
	switch (key) {
			
		case ']':
			navigation = [SpFolder navigation];
			navigation->random = YES;
			[self navigate:navigation];
			free(navigation);
			break;
			
		case 0x20: // space
		case '>':
			navigation = [SpFolder navigation];
			[self navigate:navigation];
			free(navigation);
			break;
			
		case '[':
			navigation = [SpFolder navigation];
			navigation->random = YES;
			navigation->reverse = YES;
			[self navigate:navigation];
			free(navigation);
			break;
			
		case '<':
			navigation = [SpFolder navigation];
			navigation->reverse = YES;
			[self navigate:navigation];
			free(navigation);
			break;
			
		case 'd':
		case 'D':
		case NSDeleteFunctionKey:
		case NSDeleteCharacter:
			if (![filename isEqualToString:b_UNTITLED]) {
				[self deleteCurrentImage];
			}
			return;
			
		case 'p':
        case 'P':
			if ([super isTimerValid]) [super stopTimer];
			else [super startTimer];
			break;
			
		/*default:
			if (!(hasVertical || hasHorizontal)) {
                [super keyDown:event];
            } else {
                visibleRect = [scrollView documentVisibleRect];
                switch (key) {
                    case NSUpArrowFunctionKey:
						if ([event isARepeat]) {
							if (wasRepeat) repeatCount++;
							else wasRepeat = YES;
							visibleRect.origin.y -= df_VERTICAL_LINE_PIXELS * pow(df_SCROLL_ACCE_FACTOR, repeatCount);
						} else {
							wasRepeat = NO;
							repeatCount = 0;
							visibleRect.origin.y -= df_VERTICAL_LINE_PIXELS;
						}
                        break;
                    case NSDownArrowFunctionKey:
						if ([event isARepeat]) {
							if (wasRepeat) repeatCount++;
							else wasRepeat = YES;
							visibleRect.origin.y += df_VERTICAL_LINE_PIXELS * pow(df_SCROLL_ACCE_FACTOR, repeatCount);
						} else {
							wasRepeat = NO;
							repeatCount = 0;
							visibleRect.origin.y += df_VERTICAL_LINE_PIXELS;
						}
                        break;
                    case NSLeftArrowFunctionKey:
						if ([event isARepeat]) {
							if (wasRepeat) repeatCount++;
							else wasRepeat = YES;
							visibleRect.origin.x -= df_HORIZONTAL_LINE_PIXELS * pow(1.2, repeatCount);
						} else {
							wasRepeat = NO;
							repeatCount = 0;
							visibleRect.origin.x -= df_HORIZONTAL_LINE_PIXELS;
						}
                        break;
                    case NSRightArrowFunctionKey:
						if ([event isARepeat]) {
							if (wasRepeat) repeatCount++;
							else wasRepeat = YES;
							visibleRect.origin.x += df_HORIZONTAL_LINE_PIXELS * pow(1.2, repeatCount);
						} else {
							wasRepeat = NO;
							repeatCount = 0;
							visibleRect.origin.x += df_HORIZONTAL_LINE_PIXELS;
						}
                        break;
                    case NSPageUpFunctionKey:
                        visibleRect.origin.y -= df_VERTICAL_PAGE_PIXELS;
                        break;
                    case NSPageDownFunctionKey:
                        visibleRect.origin.y += df_VERTICAL_PAGE_PIXELS;
                        break;
                    case NSHomeFunctionKey:
                        visibleRect.origin.y = 0;
                        break;
                    case NSEndFunctionKey:
                        visibleRect.origin.y = [imageView bounds].size.height;
                        break;
                    default:
						wasRepeat = NO;
						repeatCount = 0;
                        [super keyDown:event];
                        return;
                }
                [imageView scrollPoint:visibleRect.origin];
            }
			return;*/
	}
}

- (void)reload
{
	if (![filename isEqualToString:b_UNTITLED]) {
		[image autorelease];
		image = [imageCache currentImageForNavigator:navigator];
		if (!image) [[self window] close];
		[image retain];
		[self setFilename:[[navigator currentFile] filePath]];
		[self start];
	}
}

- (void)lockCurrentFolder
{
	[[navigator currentFolder] setLocked];
	[[self window] setTitle:[self description]];
}

- (void)navigate:(Navigation *)navigation
{
	[super pauseTimer];
	[self showNextImage:navigation];
	[super resumeTimer];
}

- (void)setCustomFrameSize:(NSSize)size
{
	lockedFrameSize = size;
	NSSize currentSize = [self currentSize], screenSize = [[[self window] screen] visibleFrame].size;
	
	if (size.width > currentSize.width) size.width = currentSize.width;
	if (size.width > screenSize.width) size.width = screenSize.width;
	
	if (size.height > currentSize.height) size.height = currentSize.height;
	if (size.height > screenSize.height - WINDOW_TITLEBAR_HEIGHT) size.height = screenSize.height - WINDOW_TITLEBAR_HEIGHT;
	
	BOOL hadVertical = hasVertical, hadHorizontal = hasHorizontal;
	[self resetScrollers];
	[self configureScrollPolicy:[self currentSize] frameSize:size];
	
	// after configureScrollPolicy, add the extra space for the frame
	size.height += WINDOW_TITLEBAR_HEIGHT;
	if (hasVertical) size.width += scroller_pixel;
	if (hasHorizontal) size.height += scroller_pixel;
	
	NSWindow *window = [super window];
	NSRect frameRect = [window frame];
	frameRect.origin.y += (frameRect.size.height - size.height);
	frameRect.size = size;
	flag = YES;
	[window setFrame:frameRect display:YES];
	
	NSSize maxSize = [window maxSize];
	if (hasHorizontal) {
		if (!hadHorizontal) maxSize.height += scroller_pixel;
	} else {
		if (hadHorizontal) maxSize.height -= scroller_pixel;
	}
	if (hasVertical) {
		if (!hadVertical) maxSize.width += scroller_pixel;
	} else {
		if (hadVertical) maxSize.width -= scroller_pixel;
	}
	[window setMaxSize:maxSize];
	
	[self configureCursor];
	[[self window] setTitle:[self description]];
	[[NSNotificationCenter defaultCenter] postNotificationName:VisibleRectChangeNotification object:nil];
}

- (void)toggleLockFrame
{
	frameLocked = !frameLocked;
	if (frameLocked) lockedFrameSize = [imageView visibleRect].size;
	[[self window] setTitle:[self description]];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:WindowBecomeMainNotification object:self];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification {
	NSEvent *event = [NSApp currentEvent];
	if ([event type] == NSLeftMouseDown) {
		NSPoint point = [event locationInWindow];
		if ([imageView mouse:point inRect:[imageView frame]]) {
			[NSApp postEvent:event atStart:YES];
		}
	}
}

@end
