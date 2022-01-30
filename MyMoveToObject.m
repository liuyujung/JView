//
//  MyMoveToObject.m
//  JViewbt
//
//  Created by Allan Liu on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MyMoveToObject.h"

@interface MyMoveToObject (PrivateMethods)
- (void)setFolder:(NSString *)_defaultFolder;
@end


@implementation MyMoveToObject

- (id)initWithDocumentController:(TimerableController <Operatable> *)_controller
{
	if (self = [super init]) {
		controller = _controller;
		[NSBundle loadNibNamed:@"MoveTo" owner:self];
		folder = nil;
		useAlertPanel = NO;
		usePreviousFolder = NO;
		forceToOpen = NO;
	}
	return self;
}

- (void)dealloc
{
	[folder release];
	[super dealloc];
}

- (NSString *)folder
{
	return folder;
}

- (void)setFolder:(NSString *)_folder
{
	[folder autorelease];
	folder = [_folder copy];
}

- (void)setUseAlertPanel:(BOOL)_useAlertPanel
{
	useAlertPanel = _useAlertPanel;
}

- (void)setForceToOpen:(BOOL)_forceToOpen
{
	forceToOpen = _forceToOpen;
}

- (BOOL)prepareMove
{
	NSString *filename = [[[controller navigator] currentFile] filePath];
	
	if (forceToOpen) {
		forceToOpen = NO;
	} else if (usePreviousFolder && [[NSFileManager defaultManager] fileExistsAtPath:folder]) {
		return YES;
	}
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAccessoryView:moveToUtilityView];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[defaultLocationBtn setState:usePreviousFolder];
	[self click:defaultLocationBtn];
	
	if (useAlertPanel) {
		[NSCursor unhide];
		int result = [openPanel runModalForDirectory:(folder ? folder : filename) file:nil types:[NSArray array]];
		[NSCursor hide];
		if (result == NSOKButton) {
			NSString *destination = [openPanel filename];
			if ([destination isEqualToString:[filename stringByDeletingLastPathComponent]]) return NO;
			[self setFolder:destination];
			usePreviousFolder = [defaultLocationBtn state];
			return YES;
		}
	} else {
		// it wont block the current flow, the action needs to be performed when the sheet is closed
		[openPanel beginSheetForDirectory:(folder ? folder : filename) file:nil types:[NSArray array] modalForWindow:[controller window] modalDelegate:self
			didEndSelector:@selector(openSheetDidEnd:returnCode:contextInfo:) contextInfo:filename];
	}
	return NO;
}

- (void)openSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		NSString *destination = [(NSOpenPanel *)sheet filename];
		if (![destination isEqualToString:[(NSString *)contextInfo stringByDeletingLastPathComponent]]) {
			[self setFolder:destination];
			usePreviousFolder = [defaultLocationBtn state];
			[controller performOperation:moveOperation contextPath:folder];
		}
	}
	[sheet close];
	[controller resumeTimer];
}

- (IBAction)click:(id)sender
{
	if ([defaultLocationBtn state]) {
		[messageTxf setStringValue:b_MOVE_FILE_MESSAGE];
	} else {
		[messageTxf setStringValue:@""];
	}
}

@end
