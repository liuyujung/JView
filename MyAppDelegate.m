
@interface MyAppDelegate (PrivateMethods)
- (BOOL)openWithController:(MyDocumentController *)controller;
- (NSArray *)prepareCloseWindowsWithFilename:(NSString *)_filename controller:(TimerableController <Operatable> *)_controller;
- (NSWindow *)depestWindow:(NSWindow *)window;
- (NSWindow *)frontMostWindow:(NSWindow *)window;
- (NSPoint)nextCascadePoint:(NSWindow *)window;
- (void)stopTimer;
@end

@implementation MyAppDelegate

- (id)init
{
    if (self = [super init]) {
        windows = [[NSMutableArray alloc] init];
		mostRecentPath = [df_DEFAULT_LOCATION copy];
		
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(close:)
            name:NSWindowWillCloseNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [windows release];
    [mostRecentPath release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	// dealloc global variables
	[imageCache release];
	[df_DEFAULT_LOCATION release];
	[df_SLIDE_BG_COLOR release];
	// end of global variables
    [super dealloc];
}

- (void)awakeFromNib
{
	//[self setNextImageKey:df_NEXT_IMAGE_KEY previousImageKey:df_PREVIOUS_IMAGE_KEY];
	//[autoBrowseMenuItem setTitle:b_AUTO_BROWSE];
}

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];

	// slide show
	[appDefaults setObject:@"NO" forKey:@"df_SLIDE_BROWSE_RANDOM"];
	[appDefaults setObject:@"YES" forKey:@"df_SLIDE_EXPAND_SCREEN"];
	[appDefaults setObject:@"3" forKey:@"df_SLIDE_BROWSE_FOLDER_DEPTH"];
	[appDefaults setObject:@"0" forKey:@"df_SLIDE_BROWSE_OPTION"];
    [appDefaults setObject:@"0.5" forKey:@"df_SLIDE_BROWSE_SECONDS"];
	[appDefaults setObject:[[SpUtil sharedUtil] componentArrayWithColor:[NSColor blackColor]] forKey:@"df_SLIDE_BG_COLOR"];
	
	// saveas
	[appDefaults setObject:@"0" forKey:@"df_SAVEAS_SIZE"];
	[appDefaults setObject:@"NO" forKey:@"df_SAVEAS_INTERLACE"];
	[appDefaults setObject:@"1" forKey:@"df_SAVEAS_COMPRESSION"];
	[appDefaults setObject:@"3" forKey:@"df_SAVEAS_FORMAT"];
	[appDefaults setObject:@"0.8" forKey:@"df_SAVEAS_QUALITY"];
	
	// regular
	[appDefaults setObject:NSHomeDirectory() forKey:@"df_DEFAULT_LOCATION"];
	[appDefaults setObject:@"46" forKey:@"df_NEXT_IMAGE_KEY"];
	[appDefaults setObject:@"44" forKey:@"df_PREVIOUS_IMAGE_KEY"];
	[appDefaults setObject:@"93" forKey:@"df_NEXT_RANDOM_KEY"];
	[appDefaults setObject:@"91" forKey:@"df_PREVIOUS_RANDOM_KEY"];
	
	[appDefaults setObject:@"2" forKey:@"df_NAVIGATION_FOLDER_DEPTH"];
	[appDefaults setObject:@"900" forKey:@"df_CACHE_SIZE2_MB"];
	[appDefaults setObject:@"10" forKey:@"df_VERTICAL_LINE_PIXELS"];
	[appDefaults setObject:@"171" forKey:@"df_VERTICAL_PAGE_PIXELS"];
	[appDefaults setObject:@"10" forKey:@"df_HORIZONTAL_LINE_PIXELS"];
	[appDefaults setObject:@"0.5" forKey:@"df_AUTO_BROWSE_INTERVAL"];
	
	[appDefaults setObject:@"1.0" forKey:@"df_DEFAULT_RATIO"];
	[appDefaults setObject:@"1.1" forKey:@"df_MOUSE_SPEEdf_X_FACTOR"];
    [appDefaults setObject:@"1.1" forKey:@"df_MOUSE_SPEEdf_Y_FACTOR"];
	[appDefaults setObject:@"1.2" forKey:@"df_SCROLL_ACCE_FACTOR"];
	
	[appDefaults setObject:@"YES" forKey:@"df_RESIZE_TO_FIT"];
	[appDefaults setObject:@"NO" forKey:@"df_ALLOW_TO_EXPAND"];
	[appDefaults setObject:@"YES" forKey:@"df_WARN_BEFORE_DELETE"];
	[appDefaults setObject:@"NO" forKey:@"df_HIDE_IMAGE_CLOSED"];
	[appDefaults setObject:@"NO" forKey:@"df_OPEN_WINDOW_IN_BACKGROUND"];
	[appDefaults setObject:@"NO" forKey:@"df_OPEN_WINDOW_CASCADE"];
	[appDefaults setObject:@"NO" forKey:@"df_OPEN_WINDOW_CENTER"];
	//[appDefaults setObject:@"NO" forKey:@"df_ENABLE_AUTO_ZOOM"];
	[appDefaults setObject:@"NO" forKey:@"df_ENABLE_CACHE"];
	
    [defaults registerDefaults:appDefaults];
	[JwBundle class];
}

- (NSMutableArray *)windowArray
{
    return windows;
}

- (void)setMostRecentPath:(NSString *)_mostRecentPath
{
	[mostRecentPath autorelease];
	mostRecentPath = [_mostRecentPath copy];
}

- (NSString *)mostRecentPath
{
	return mostRecentPath;
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    int tag = [anItem tag];
	
    NSWindow *mainWindow = [NSApp mainWindow];
	id controller = [mainWindow windowController];
	
	BOOL isImage = [controller isKindOfClass:[MyDocumentController class]],
		hasSheet = [mainWindow attachedSheet] ? YES : NO;
		
    switch (tag) {
	
		case 15: // reload, reveal
			return isImage && ![[controller filename] isEqualToString:b_UNTITLED];
			
		case 49: // slide show
			return !hasSheet;
			
        case 1:
		case 42: // zoom in
		case 44: // zoom out
		case 43: // previous image
		case 45: // rotate left
		case 46: // rotate right
		case 47: // rotate horizontal
		case 48: // rotate vertical
		case 102: // copy original size
		case 103: // copy visible area
            return isImage;
			
        case 27: // fit <= 100%
			[anItem setState:!df_ALLOW_TO_EXPAND];
			return isImage;
			
		case 28: // fit >= 100%
			[anItem setState:df_ALLOW_TO_EXPAND];
			return isImage;
			
        case 2:
            [anItem setState:(int)([[NSUserDefaults standardUserDefaults] floatForKey:@"df_DEFAULT_RATIO"] * 100) ==
                [[anItem title] floatValue]];
            return isImage && (int)([controller ratio] * 100) != [[anItem title] floatValue];
			
        case 3: // cascade, rearrange
            return [windows count] > 0;
		
		case 41: // autobrowse
			if (isImage && [controller isTimer])
				[autoBrowseMenuItem setTitle:b_STOP_BROWSE];
			else
				[autoBrowseMenuItem setTitle:b_AUTO_BROWSE];
			
		case 17: // move
		case 18: // move to
		case 13: // delete
		case 51: // next image
		case 52: // previous image
		case 53: // up 1 level
		case 54: // up 2 levels
		case 55: // up to top
		case 561: // random next
		case 562: // random previous
		case 563: // random up 1 level
		case 564: // random up 2 levels
		case 565: // random up to top
		case 57: // shuffle
		case 58: // lock folder
			return isImage ? (hasSheet ? NO : ![[controller filename] isEqualToString:b_UNTITLED]) : NO;
			
		case 26: // lock frame
			if (isImage && [controller frameLocked]) [lockFrameMenuItem setTitle:b_UNLOCK_FRAME];
			else [lockFrameMenuItem setTitle:b_LOCK_FRAME];
			
		case 23: // get info
        case 12: // save as
		case 29: // other zoom, fram esize
			return isImage ? !hasSheet : NO;
			
        case 16: // close all, center
            return mainWindow ? YES : NO;
			
        case 22: // paste
            return [NSImage canInitWithPasteboard:[NSPasteboard generalPasteboard]];
			
		//case 21: // auto zoom
			//[anItem setState:df_ENABLE_AUTO_ZOOM];
			//break;
			
    }
    return YES;
}

- (void)close:(NSNotification *)notification
{
    id controller = [[notification object] windowController];
    if ([controller isKindOfClass:[MyDocumentController class]]) {
		[controller stopTimer];  // have to stop the timer before releasing the instance or it wont release
        [windows removeObject:[controller window]];
        [controller release];
		if ([windows count] == 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:WindowBecomeMainNotification object:nil];
			if (df_HIDE_IMAGE_CLOSED) [NSApp hide:self];
		}
    }
}

- (IBAction)about:(id)sender
{
    [[MyAboutController sharedAboutPanel] showWindow:sender];
}

- (IBAction)preference:(id)sender
{
	[self stopTimer];
    [[MyPreferenceController sharedPreferenceWindow] showWindow:sender];
}

- (IBAction)slide:(id)sender
{
	[self stopTimer];
	SlideController *slideController = [[SlideController alloc] init];
	[slideController showWindow:sender];
	[slideController openOptionPanel];
}

/*
	Open the 'Open Panel' to open folders and images
*/
- (IBAction)openFile:(id)sender
{
	[self stopTimer];
    int i, result;
    NSArray *filenames;
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:YES];
    result = [openPanel runModalForDirectory:mostRecentPath file:nil types:fileTypes];
    if (result == NSOKButton) {
        filenames = [openPanel filenames];
        for (i = 0; i < [filenames count]; i++)
            [self application:sender openFile:[filenames objectAtIndex:i]];
    }
}

/*
	Dropping folders or images to the app, this method will be called
*/
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	return [self openWithController:[[MyDocumentController alloc] initWithFilename:filename]];
}

/*
	Open the actual image window and set it to the desired position
*/
- (BOOL)openWithController:(MyDocumentController *)controller
{
    if (!controller) return NO;
	
	NSWindow *window = [controller window];
    [windows addObject:window];
	
    if ([windows count] > 1) {
		
        if (df_OPEN_WINDOW_IN_BACKGROUND) {
			
            NSWindow *depestWindow = [self depestWindow:window];
			
			if (!df_OPEN_WINDOW_CENTER) {
				[window setFrameTopLeftPoint:[self nextCascadePoint:df_OPEN_WINDOW_CASCADE ? depestWindow : nil]];
			}
            [window orderWindow:NSWindowBelow relativeTo:[depestWindow windowNumber]];
			
        } else {
			
			if (!df_OPEN_WINDOW_CENTER) {
				[window setFrameTopLeftPoint:[self nextCascadePoint:
					df_OPEN_WINDOW_CASCADE ? [self frontMostWindow:window] : nil]];
			}
            [controller showWindow:NSApp];
        }
		
    } else {
		
		if (!df_OPEN_WINDOW_CENTER) {
			[window setFrameTopLeftPoint:[self nextCascadePoint:nil]];
		}
        [controller showWindow:NSApp];
    }
	
    if (![[controller filename] isEqualToString:b_UNTITLED])
		[self setMostRecentPath:[[[controller navigator] baseFolder] filePath]];
	
    return YES;
}

- (IBAction)saveAs:(id)sender
{
	[self stopTimer];
	id controller = [[NSApp mainWindow] windowController];
    [controller saveAs];
}

- (IBAction)moveTo:(id)sender
{
	id controller = [[NSApp mainWindow] windowController];
	[controller moveCurrentImage:[sender tag] == 17 ? NO : YES];
}

- (NSWindow *)depestWindow:(NSWindow *)window
{
    int i;
    NSArray *wins = [NSApp orderedWindows];
    NSWindow *win = nil;
    for (i=[wins count]-1; i>=0; i--) {
        win = [wins objectAtIndex:i];
        if ([[win windowController] isKindOfClass:[MyDocumentController class]] && win != window) break;
    }
    return win;
}

- (NSWindow *)frontMostWindow:(NSWindow *)window
{
    int i;
    NSArray *wins = [NSApp orderedWindows];
    NSWindow *win = nil;
    for (i=0; i<[wins count]; i++) {
        win = [wins objectAtIndex:i];
        if ([[win windowController] isKindOfClass:[MyDocumentController class]] && win != window) break;
    }
    return win;
}

- (IBAction)copy:(id)sender
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:nil];
	id controller = [[NSApp mainWindow] windowController];
	
	switch ([sender tag]) {
	
		case 102:
			[pboard setData:[controller currentImageData:NO originalSize:YES] forType:NSTIFFPboardType];
			return;
		case 103:
			[pboard setData:[controller currentImageData:YES originalSize:NO] forType:NSTIFFPboardType];
			return;
		default:
			[pboard setData:[controller currentImageData:NO originalSize:NO] forType:NSTIFFPboardType];
	}
}

- (IBAction)paste:(id)sender
{
    NSImage *image = [[NSImage alloc] initWithPasteboard:[NSPasteboard generalPasteboard]];
    [self openWithController:[[MyDocumentController alloc] initWithImage:[image autorelease]]];
}

- (IBAction)duplicate:(id)sender
{
    [self copy:sender];
    [self paste:sender];
}

- (IBAction)closeAllFiles:(id)sender
{
    NSWindow *w;
    while (w = [NSApp mainWindow]) [w close];
}

- (IBAction)scaleZoom:(id)sender
{
    MyDocumentController *controller = [[NSApp mainWindow] windowController];
	int tag = [sender tag];
    float ratio;
    BOOL resize = NO;
	
    if (tag == 27 || tag == 28) { // resize/expand to fit
		
		if (tag == 27) df_ALLOW_TO_EXPAND = NO;
		else df_ALLOW_TO_EXPAND = YES;
		
        resize = YES;
		
    } else if (tag == 42 || tag == 44) { // zoom out/in
	
		float currentRatio = [controller ratio];
		
		SpImageUtil *spImageUtil = [SpImageUtil sharedImageUtil];
		
		if (tag == 42) {
			ratio = [spImageUtil nextZoomRatioWithRatio:currentRatio zoomIn:YES];
		} else {
			ratio = [spImageUtil nextZoomRatioWithRatio:currentRatio zoomIn:NO];
		}
		[controller setRatio:ratio];
	
	} else {
		
        ratio = [[sender title] floatValue] / 100;
        [controller setRatio:ratio];
    }
	
    [controller render:resize];
}

- (IBAction)otherZoom:(id)sender
{
    [[[NSApp mainWindow] windowController] otherZoom];
}

- (IBAction)frameSize:(id)sender
{
	[[[NSApp mainWindow] windowController] frameSize];
}

- (IBAction)toggleLockFrame:(id)sender
{
	[[[NSApp mainWindow] windowController] toggleLockFrame];
}

- (IBAction)getInfo:(id)sender
{
    [[[NSApp mainWindow] windowController] getInfo];
}

/*- (IBAction)autoZoom:(id)sender
{
    int i;
	df_ENABLE_AUTO_ZOOM = ![sender state];
    [[NSUserDefaults standardUserDefaults] setBool:df_ENABLE_AUTO_ZOOM forKey:@"df_ENABLE_AUTO_ZOOM"];
    [sender setState:df_ENABLE_AUTO_ZOOM];
    for (i = 0; i < [windows count]; i++) {
        id window = [windows objectAtIndex:i];
        [[window windowController] toggleAutoZoom];
    }
}*/

- (void)traverseNextImage:(BOOL)_reverse
{
	int index = [windows indexOfObject:[NSApp mainWindow]];
    (!_reverse) ? index++ : index--;
    if (index < 0)
        index = [windows count] - 1;
    else if (index >= [windows count])
        index = 0;
    [[windows objectAtIndex:index] makeKeyAndOrderFront:self];
}

- (IBAction)cascade:(id)sender
{
    int i;
    NSPoint point;
    NSWindow *window = nil;
    for (i = 0; i < [windows count]; i++) {
        point = [self nextCascadePoint:window];
        window = [windows objectAtIndex:i];
        [window setFrameTopLeftPoint:point];
        [window makeKeyAndOrderFront:sender];
    }
}

- (IBAction)rearrange:(id)sender
{
    NSPoint point = [self nextCascadePoint:nil];
    int i;
    NSWindow *window;
    for (i = 0; i < [windows count]; i++) {
        window = [windows objectAtIndex:i];
        [window setFrameTopLeftPoint:point];
        [window makeKeyAndOrderFront:sender];
    }
}

- (IBAction)deleteFile:(id)sender
{
	[[[NSApp mainWindow] windowController] deleteCurrentImage];
}

- (NSImage *)performOperationForController:(TimerableController <Operatable> *)_controller operation:(Operation)_operation
{
	NSString *filename = [[[[_controller navigator] currentFile] filePath] copy];
	[filename autorelease];
	
	NSArray *preparedWindows = [self prepareCloseWindowsWithFilename:filename controller:_controller];
	
	int i;
	for (i = 0 ; i < [preparedWindows count]; i++) {
		id controller = [[preparedWindows objectAtIndex:i] windowController];
		[[controller navigator] prepareCurrentFolderContent];
	}
	
	NSImage *image = [imageCache performActionForNavigator:[_controller navigator] operation:_operation
		destination:(_operation == moveOperation ? [[_controller moveToObject] folder] : nil)];
	
	if (!image) return nil;
	
	for (i = 0 ; i < [preparedWindows count]; i++) {
		id controller = [[preparedWindows objectAtIndex:i] windowController];
		[imageCache resetCurrentFolderModifcationDateForNavigator:[controller navigator]];
		[controller performOperation:removeOperation contextPath:nil];
	}
	
	return image;
}

- (NSArray *)prepareCloseWindowsWithFilename:(NSString *)_filename controller:(TimerableController <Operatable> *)_controller
{
    int i, c = [windows count];
    NSMutableArray *winArray = [[NSMutableArray alloc] init];
    NSWindow *window;
    for (i = 0; i < c; i++) {
        window = [windows objectAtIndex:i];
		id controller = [window windowController];
        if (controller != _controller && [[controller filename] isEqualToString:_filename])
            [winArray addObject:window];
    }
    return [winArray autorelease];
}

- (NSPoint)nextCascadePoint:(NSWindow *)window
{
    NSPoint point;
    if (!window || [windows count] == 0) {
        NSRect vr = [[NSScreen mainScreen] visibleFrame], fr = [[NSScreen mainScreen] frame];
        int x = vr.origin.x, y = fr.size.height;
        //if (x > 0) // left dock
        //    x += SIDEDOCK_ADJUSTMENT;
        //else if (vr.origin.y == 0 && vr.size.width == fr.size.width) // top dock
        //    y = vr.size.height - DOCK_ADJUSTMENT;
        y -= WINDOW_TITLEBAR_HEIGHT;
        point = NSMakePoint(x, y);
    } else {
        NSRect winFrame = [window frame];
        point.x = winFrame.origin.x + CASCADE_X;
        point.y = winFrame.origin.y + winFrame.size.height - CASCADE_Y;
    }
    return point;
}

- (IBAction)transform:(id)sender
{
    int tag = [sender tag];
    id controller = [[NSApp mainWindow] windowController];
    switch(tag) {
        case 45:
            [controller transformImage:rotateLeft];
            break;
        case 46:
            [controller transformImage:rotateRight];
            break;
        case 47:
            [controller transformImage:flipHorizontal];
            break;
        case 48:
            [controller transformImage:flipVertical];
            break;
    }
}

- (IBAction)originalImage:(id)sender
{
	[[[NSApp mainWindow] windowController] originalImage];
}

- (IBAction)autoBrowse:(id)sender
{
	TimerableController *controller = [[NSApp mainWindow] windowController];
	if ([controller isTimerValid]) {
		[controller stopTimer];
	} else {
		[controller startTimer];
	}
}

- (void)stopTimer
{
	int i, c = [windows count];
	NSWindow *window;
    for (i=0; i<c; i++) {
        window = [windows objectAtIndex:i];
        [[window windowController] stopTimer];
    }
}

- (IBAction)reload:(id)sender
{
	[[[NSApp mainWindow] windowController] reload];
}

- (IBAction)revealInFinder:(id)sender
{
	[[[NSApp mainWindow] windowController] revealInFinder];
}

- (IBAction)fullScreen:(id)sender
{
	SlideController *slideController;
	id controller = [[NSApp mainWindow] windowController];
	NSString *filename = [controller filename];
	[self stopTimer];
	if ([filename isEqualToString:b_UNTITLED]) {
		slideController = [[SlideController alloc] initWithImage:[controller image]];
	} else {
		slideController = [[SlideController alloc] initWithFile:filename];
	}
	[slideController showWindow:sender];
	[slideController start:df_ALLOW_TO_EXPAND useTimer:NO];
}

- (IBAction)centerWindow:(id)sender
{
	[[NSApp mainWindow] center];
}

- (IBAction)navigation:(id)sender
{
	int tag = [sender tag];
	id controller = [[NSApp mainWindow] windowController];
	
	if (tag == 58) { // lock
		[controller lockCurrentFolder];
		return;
	}
	
	Navigation *navigation = [SpFolder navigation];
	
    switch(tag) {
			
		case 562: // random previous
			navigation->random = YES;
		case 52: // previous image
			navigation->reverse = YES;
			break;
			
		case 563: // random up 1 level
			navigation->random = YES;
		case 53: // up 1 level
			navigation->jumpup = YES;
			break;
			
		case 564: // random up 2 levels
			navigation->random = YES;
		case 54: // up 2 levels
			navigation->jumpup = YES;
			navigation->uptwice = YES;
			break;
			
		case 565: // random up to top
			navigation->random = YES;
		case 55: // up to top
			navigation->jumpup = YES;
			navigation->uptotop = YES;
			break;
			
		case 561:
			navigation->random = YES;
			break;
			
		case 57: // shuffle
			navigation->random = YES;
			navigation->reshuffle = YES;
			break;
    }
	
	[controller navigate:navigation];
	free(navigation);
}

- (IBAction)previewPanel:(id)sender
{
	NSArray *allWindows = [NSApp windows];
	int i;
	NSWindow *window;
	for (i = 0; i < [allWindows count]; i++) {
		window = [allWindows objectAtIndex:i];
		if ([[window windowController] isKindOfClass:[PreviewController class]]) {
			[window makeKeyAndOrderFront:self];
			return;
		}
	}
	PreviewController *previewController = [[PreviewController alloc] init];
	[previewController showWindow:NSApp];
	[[NSNotificationCenter defaultCenter] postNotificationName:WindowBecomeMainNotification object:[[NSApp mainWindow] windowController]];
}

- (void)hideWindows
{
	NSArray *allWindows = [NSApp windows];
	int i;
	NSWindow *window;
	id controller;
	for (i = 0; i < [allWindows count]; i++) {
		window = [allWindows objectAtIndex:i];
		controller = [window windowController];
		if ([controller isKindOfClass:[MyDocumentController class]]
			|| [controller isKindOfClass:[PreviewController class]]
			|| [controller isKindOfClass:[MyPreferenceController class]]) {
			
			[window orderOut:self];
		}
	}
}

- (void)unhideWindows
{
	NSArray *allWindows = [NSApp windows];
	int i;
	NSWindow *window;
	id controller;
	for (i = 0; i < [allWindows count]; i++) {
		window = [allWindows objectAtIndex:i];
		controller = [window windowController];
		if ([controller isKindOfClass:[MyDocumentController class]]
			|| [controller isKindOfClass:[PreviewController class]]
			|| [controller isKindOfClass:[MyPreferenceController class]]) {
			
			//[window orderBack:self];
			[window makeKeyAndOrderFront:self];
		}
	}
	[NSApp arrangeInFront:self];
}

@end
