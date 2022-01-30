#import "MyApplication.h"

@implementation MyApplication

- (void)sendEvent:(NSEvent *)anEvent
{
	id keyWindow = [NSApp keyWindow];
	id mainWindow = [NSApp mainWindow];
	id mainController = [mainWindow windowController];
	id attachedSheet = [mainWindow attachedSheet];
	
	BOOL isImage = [mainController isKindOfClass:[MyDocumentController class]],
		 isSlidePanel = [[keyWindow delegate] isKindOfClass:[OptionsDelegate class]],
		 isPrefsWindow = [mainController isKindOfClass:[MyPreferenceController class]],
		 isSheetAttached = attachedSheet != nil,
		 isFrameSheet = isSheetAttached && [[attachedSheet windowController] isKindOfClass:[MyFrameController class]],
		 isInfoSheet = isSheetAttached && [[attachedSheet windowController] isKindOfClass:[MyInfoController class]];
	
	if ([anEvent type] == NSRightMouseDown && isImage && [anEvent clickCount] >= 3) {
		[mainWindow close];
		return;
	}
	
	if ([anEvent type] == NSKeyDown) {
		 
		// for option-key, the length is 0
		unichar key = [[anEvent characters] length] ? [[anEvent characters] characterAtIndex:0] : 0;
		//NSLog(@"%x", key);
		
		// modal windows only, like open panel and alerts, not the sheets
		if ([NSApp modalWindow]) {
			if (isSpecialAlert && key == 0x1b) {
				[NSApp stopModal];
				return;
			}
			[super sendEvent:anEvent];
			return;
		}
		
		if (df_SLIDE_IS_SLIDE) {
			[[slideWindow windowController] keyDown:anEvent];
			return;
		}
		
		BOOL next;
		
		switch (key) {
			case NSTabCharacter:
				next = YES;
			case NSBackTabCharacter:
				if (isImage && !isSlidePanel && !isFrameSheet) {
					[[NSApp delegate] traverseNextImage:!next];
					return;
				}
				break;
			case 0x1b: // ESC
				
				if (isInfoSheet) {
					[attachedSheet close];
					[NSApp endSheet:attachedSheet];
					return;
				}
			
				if (!(isSlidePanel || isSheetAttached || isPrefsWindow)) {
					[self hide:self];
					return;
				}
				break;
		}
		
	} else if ([anEvent type] == NSScrollWheel) {
		
		if (isImage && !isSlidePanel) {
			[[mainController imageView] scrollWheel:anEvent];
		}
		return;
	}
	[super sendEvent:anEvent];
}

- (void)setSlideWindow:(NSWindow *)_slideWindow
{
	slideWindow = _slideWindow;
}

- (NSWindow *)slideWindow
{
	return slideWindow;
}

@end
