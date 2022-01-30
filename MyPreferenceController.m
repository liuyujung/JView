#import "MyPreferenceController.h"

@interface MyPreferenceController (PrivateMethods)
- (void)setDefaults;
@end

static MyPreferenceController *_sharedPreference;

@implementation MyPreferenceController

+ (id)sharedPreferenceWindow
{
    if (!_sharedPreference)
        _sharedPreference = [[MyPreferenceController allocWithZone:[self zone]] init];
    return _sharedPreference;
}

- (id)init
{
    if (self = [super initWithWindowNibName:@"MyPreference"]) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(textDidEndEditing:)
        name:NSControlTextDidEndEditingNotification object:defaultLocationTxf];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(textDidChange:)
        name:NSControlTextDidChangeNotification object:defaultLocationTxf];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyTextDidEndEditing:)
        name:NSControlTextDidEndEditingNotification object:imageNavigationKeysForm];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(randomKeyDidEndEditing:)
		name:NSControlTextDidEndEditingNotification object:randomKeysForm];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyTextDidChange:)
        name:NSControlTextDidChangeNotification object:imageNavigationKeysForm];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(randomKeyDidChange:)
		name:NSControlTextDidChangeNotification object:randomKeysForm];
}

- (void)windowDidLoad
{
    [[self window] makeFirstResponder:nil];
    [zoomTxf setIntValue:df_DEFAULT_RATIO * 100];
    [zoomTxf setEnabled:!df_RESIZE_TO_FIT];
    [resizeFitWindowBtn setState:df_RESIZE_TO_FIT];
	[allowToExpandBtn setState:df_ALLOW_TO_EXPAND];
	[allowToExpandBtn setEnabled:df_RESIZE_TO_FIT];
	
    [defaultLocationTxf setStringValue:df_DEFAULT_LOCATION];
	[defaultLocationTxf setToolTip:df_DEFAULT_LOCATION];
    [[imageNavigationKeysForm cellWithTag:0] setStringValue:[NSString stringWithCharacters:(unichar *) &df_NEXT_IMAGE_KEY length:1]];
    [[imageNavigationKeysForm cellWithTag:1] setStringValue:[NSString stringWithCharacters:(unichar *) &df_PREVIOUS_IMAGE_KEY length:1]];
	[[randomKeysForm cellWithTag:0] setStringValue:[NSString stringWithCharacters:(unichar *) &df_NEXT_RANDOM_KEY length:1]];
    [[randomKeysForm cellWithTag:1] setStringValue:[NSString stringWithCharacters:(unichar *) &df_PREVIOUS_RANDOM_KEY length:1]];
	
    [depthTxf setIntValue:df_NAVIGATION_FOLDER_DEPTH];
    [depthStepper setIntValue:df_NAVIGATION_FOLDER_DEPTH];
	[autoBrowseIntervalTxf setFloatValue:df_AUTO_BROWSE_INTERVAL];
	[autoBrowseIntervalStepper setFloatValue:df_AUTO_BROWSE_INTERVAL];
	
	[disableCacheBtn setState:!df_ENABLE_CACHE];
	[cacheSizeTxf setEnabled:df_ENABLE_CACHE];
	[cacheSizeStepper setEnabled:df_ENABLE_CACHE];
	[cacheSizeTxf setIntValue:df_CACHE_SIZE2_MB];
    [cacheSizeStepper setIntValue:df_CACHE_SIZE2_MB];
	
    [cascadeImageBtn setState:df_OPEN_WINDOW_CASCADE];
	[centerImageBtn setState:df_OPEN_WINDOW_CENTER];
	
	if (df_OPEN_WINDOW_CASCADE) {
		[centerImageBtn setState:NSOffState];
		[centerImageBtn setEnabled:NO];
	} else if (df_OPEN_WINDOW_CENTER) {
		[cascadeImageBtn setState:NSOffState];
		[cascadeImageBtn setEnabled:NO];
	}
	
    [backgroundImageBtn setState:df_OPEN_WINDOW_IN_BACKGROUND];
    [warnDeleteBtn setState:df_WARN_BEFORE_DELETE];
	[hideImageClosedBtn setState:df_HIDE_IMAGE_CLOSED];
	
    [[self window] makeFirstResponder:zoomTxf];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [self windowDidLoad];
}

// what for?
/*- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	[zoomTxf setIntValue:df_DEFAULT_RATIO * 100];
}*/

- (void)setDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
    [userDefaults setFloat:df_MOUSE_SPEEdf_X_FACTOR forKey:@"df_MOUSE_SPEEdf_X_FACTOR"];
    [userDefaults setFloat:df_MOUSE_SPEEdf_Y_FACTOR forKey:@"df_MOUSE_SPEEdf_Y_FACTOR"];
    [userDefaults setFloat:df_DEFAULT_RATIO forKey:@"df_DEFAULT_RATIO"];
	
    [userDefaults setBool:df_RESIZE_TO_FIT forKey:@"df_RESIZE_TO_FIT"];
	[userDefaults setBool:df_ALLOW_TO_EXPAND forKey:@"df_ALLOW_TO_EXPAND"];
    [userDefaults setBool:df_WARN_BEFORE_DELETE forKey:@"df_WARN_BEFORE_DELETE"];
	[userDefaults setBool:df_HIDE_IMAGE_CLOSED forKey:@"df_HIDE_IMAGE_CLOSED"];
    [userDefaults setBool:df_OPEN_WINDOW_CASCADE forKey:@"df_OPEN_WINDOW_CASCADE"];
    [userDefaults setBool:df_OPEN_WINDOW_CENTER forKey:@"df_OPEN_WINDOW_CENTER"];
    [userDefaults setBool:df_OPEN_WINDOW_IN_BACKGROUND forKey:@"df_OPEN_WINDOW_IN_BACKGROUND"];
	[userDefaults setBool:df_ENABLE_CACHE forKey:@"df_ENABLE_CACHE"];
	
    [userDefaults setObject:df_DEFAULT_LOCATION forKey:@"df_DEFAULT_LOCATION"];
	
	[userDefaults setInteger:df_CACHE_SIZE2_MB forKey:@"df_CACHE_SIZE2_MB"];
	[userDefaults setFloat:df_AUTO_BROWSE_INTERVAL forKey:@"df_AUTO_BROWSE_INTERVAL"];
    [userDefaults setInteger:df_NAVIGATION_FOLDER_DEPTH forKey:@"df_NAVIGATION_FOLDER_DEPTH"];
    [userDefaults setInteger:df_VERTICAL_LINE_PIXELS forKey:@"df_VERTICAL_LINE_PIXELS"];
    [userDefaults setInteger:df_VERTICAL_PAGE_PIXELS forKey:@"df_VERTICAL_PAGE_PIXELS"];
    [userDefaults setInteger:df_HORIZONTAL_LINE_PIXELS forKey:@"df_HORIZONTAL_LINE_PIXELS"];
    [userDefaults setInteger:df_NEXT_IMAGE_KEY forKey:@"df_NEXT_IMAGE_KEY"];
    [userDefaults setInteger:df_PREVIOUS_IMAGE_KEY forKey:@"df_PREVIOUS_IMAGE_KEY"];
	[userDefaults setInteger:df_NEXT_RANDOM_KEY forKey:@"df_NEXT_RANDOM_KEY"];
    [userDefaults setInteger:df_PREVIOUS_RANDOM_KEY forKey:@"df_PREVIOUS_RANDOM_KEY"];
	
    [userDefaults synchronize];
}

- (IBAction)click:(id)sender
{
	if ([sender tag]) {
	
        df_RESIZE_TO_FIT = [resizeFitWindowBtn state];
        if (!df_RESIZE_TO_FIT) {
			int zoom = [zoomTxf intValue] < 1 ? 1 : [zoomTxf intValue];
            df_DEFAULT_RATIO = zoom / 100.0;
		} else {
			df_ALLOW_TO_EXPAND = [allowToExpandBtn state];
		}
		
		df_WARN_BEFORE_DELETE = [warnDeleteBtn state];
		df_HIDE_IMAGE_CLOSED = [hideImageClosedBtn state];
        df_OPEN_WINDOW_CASCADE = [cascadeImageBtn state];
		df_OPEN_WINDOW_CENTER = [centerImageBtn state];
        df_OPEN_WINDOW_IN_BACKGROUND = [backgroundImageBtn state];
		
		NSString *defaultLocation = [defaultLocationTxf stringValue];
		if ([[[NSApp delegate] mostRecentPath] isEqualToString:df_DEFAULT_LOCATION]) {
			[[NSApp delegate] setMostRecentPath:defaultLocation];
		}
        [df_DEFAULT_LOCATION autorelease];
        df_DEFAULT_LOCATION = [defaultLocation copy];
		
        df_NEXT_IMAGE_KEY = [[[imageNavigationKeysForm cellWithTag:0] stringValue] characterAtIndex:0];
        df_PREVIOUS_IMAGE_KEY = [[[imageNavigationKeysForm cellWithTag:1] stringValue] characterAtIndex:0];
		df_NEXT_RANDOM_KEY = [[[randomKeysForm cellWithTag:0] stringValue] characterAtIndex:0];
        df_PREVIOUS_RANDOM_KEY = [[[randomKeysForm cellWithTag:1] stringValue] characterAtIndex:0];
		
		df_ENABLE_CACHE = ![disableCacheBtn state];
		df_CACHE_SIZE2_MB = [cacheSizeTxf intValue];
		if (!df_ENABLE_CACHE) {
			[imageCache reset];
		} else {
			if (df_CACHE_SIZE2_MB < 30) df_CACHE_SIZE2_MB = 30;
			//else if (df_CACHE_SIZE_MB > 150) df_CACHE_SIZE_MB = 150;
			[imageCache setCacheSizeMBytes:df_CACHE_SIZE2_MB];
		}
		
		df_AUTO_BROWSE_INTERVAL = [autoBrowseIntervalTxf floatValue];
		if (df_AUTO_BROWSE_INTERVAL < 0) df_AUTO_BROWSE_INTERVAL = 0;
		
        df_NAVIGATION_FOLDER_DEPTH = [depthTxf intValue];
		if (df_NAVIGATION_FOLDER_DEPTH < 0) df_NAVIGATION_FOLDER_DEPTH = 0;
		
        [self setDefaults];
	}
	
	[[self window] close];
}

- (IBAction)toggleResizeToFitWindow:(id)sender
{
    [zoomTxf setIntValue:[zoomTxf intValue]];
    [zoomTxf setEnabled:![zoomTxf isEnabled]];
	[allowToExpandBtn setEnabled:![allowToExpandBtn isEnabled]];
}

- (IBAction)toggleEnableCache:(id)sender
{
	[cacheSizeTxf setEnabled:![disableCacheBtn state]];
	[cacheSizeStepper setEnabled:![disableCacheBtn state]];
}

- (IBAction)toggleCascadeImage:(id)sender
{
	BOOL state = [(NSButton *) sender state];
	if (state) {
		[cascadeImageBtn setState:NSOffState];
	}
	[cascadeImageBtn setEnabled:!state];
}

- (IBAction)toggleCenterImage:(id)sender
{
	BOOL state = [(NSButton *) sender state];
	if (state) {
		[centerImageBtn setState:NSOffState];
	}
	[centerImageBtn setEnabled:!state];
}

// used to quick set zoom defaults in the main menu
/*- (void)toggleFit
{
    df_RESIZE_TO_FIT = !df_RESIZE_TO_FIT;
    [resizeFitWindowBtn setState:df_RESIZE_TO_FIT];
    [self toggleResizeToFitWindow:self];
}*/

- (IBAction)selectDefaultLocation:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel beginSheetForDirectory:[defaultLocationTxf stringValue] file:nil types:[NSArray array]
        modalForWindow:[self window] modalDelegate:self
        didEndSelector:@selector(selectSheetDidEnd:returnCode:contextInfo:)
        contextInfo:NULL];
}

- (void)selectSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton) {
		NSString *filename = [(NSOpenPanel *)sheet filename];
        [defaultLocationTxf setStringValue:filename];
		[defaultLocationTxf setToolTip:filename];
        [self textDidEndEditing:nil];
    }    
    [sheet close];
}

- (IBAction)stepperAction:(id)sender
{
	NSTextField *textField = nil;
	int tag = [sender tag];
	if (tag == 1) {
		textField = depthTxf;
	} else if (tag == 2) {
		textField = autoBrowseIntervalTxf;
	} else if (tag == 3) {
		textField = cacheSizeTxf;
	}
	[textField setFloatValue:[sender currentValue:[textField floatValue]]];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    if (![okBtn isEnabled]) {
        [defaultLocationTxf setStringValue:df_DEFAULT_LOCATION];
        [okBtn setEnabled:YES];
    }
}

- (void)textDidChange:(NSNotification *)aNotification
{
    BOOL isDir, exist = [fileManager fileExistsAtPath:[defaultLocationTxf stringValue] isDirectory:&isDir] && isDir;
    [okBtn setEnabled:exist];
}

- (void)keyTextDidEndEditing:(NSNotification *)aNotification
{
    NSCell *cell = [imageNavigationKeysForm selectedCell];
    if (![okBtn isEnabled]) { // why?
        [cell setStringValue:[cell tag] ?
			[NSString stringWithCharacters:(unichar *) &df_PREVIOUS_IMAGE_KEY length:1] :
			[NSString stringWithCharacters:(unichar *) &df_NEXT_IMAGE_KEY length:1]];
        [okBtn setEnabled:YES];
    }
}

- (void)randomKeyDidEndEditing:(NSNotification *)aNotification
{
    NSCell *cell = [randomKeysForm selectedCell];
    if (![okBtn isEnabled]) { // why?
        [cell setStringValue:[cell tag] ?
		 [NSString stringWithCharacters:(unichar *) &df_PREVIOUS_RANDOM_KEY length:1] :
		 [NSString stringWithCharacters:(unichar *) &df_NEXT_RANDOM_KEY length:1]];
        [okBtn setEnabled:YES];
    }
}

- (void)keyTextDidChange:(NSNotification *)aNotification
{
    NSCell *cell = [imageNavigationKeysForm selectedCell];
    int tag = [cell tag];
    NSString *enter = [cell stringValue];
    if ([enter length] == 0) {
        [okBtn setEnabled:NO];
        return;
    } else {
        [okBtn setEnabled:YES];
    }
    unichar keyChar = [enter characterAtIndex:0];
    NSString *key = [NSString stringWithCharacters:&keyChar length:1];
    [cell setStringValue:key];
    NSString *other = [[imageNavigationKeysForm cellAtIndex:tag ? 0 : 1] stringValue];
    if (![key compare:other] || [key isEqualToString:@" "]) {
        NSBeep();
        [cell setStringValue:tag ?
			[NSString stringWithCharacters:(unichar *) &df_PREVIOUS_IMAGE_KEY length:1] :
			[NSString stringWithCharacters:(unichar *) &df_NEXT_IMAGE_KEY length:1]];
    }
    [imageNavigationKeysForm selectTextAtIndex:tag];
}

- (void)randomKeyDidChange:(NSNotification *)aNotification
{
    NSCell *cell = [randomKeysForm selectedCell];
    int tag = [cell tag];
    NSString *enter = [cell stringValue];
    if ([enter length] == 0) {
        [okBtn setEnabled:NO];
        return;
    } else {
        [okBtn setEnabled:YES];
    }
    unichar keyChar = [enter characterAtIndex:0];
    NSString *key = [NSString stringWithCharacters:&keyChar length:1];
    [cell setStringValue:key];
    NSString *other = [[randomKeysForm cellAtIndex:tag ? 0 : 1] stringValue];
    if (![key compare:other] || [key isEqualToString:@" "]) {
        NSBeep();
        [cell setStringValue:tag ?
		 [NSString stringWithCharacters:(unichar *) &df_PREVIOUS_RANDOM_KEY length:1] :
		 [NSString stringWithCharacters:(unichar *) &df_NEXT_RANDOM_KEY length:1]];
    }
    [randomKeysForm selectTextAtIndex:tag];
}

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
	return YES;
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:WindowBecomeMainNotification object:self];
}

@end
