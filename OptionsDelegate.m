//
//  OptionsDelegate.m
//
//  Created by Allan Liu on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OptionsDelegate.h"

@implementation OptionsDelegate

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib
{
	[pathTxf setStringValue:[[NSApp delegate] mostRecentPath]];
	[pathTxf setToolTip:[[NSApp delegate] mostRecentPath]];
	
    [bgColorWell setColor:df_SLIDE_BG_COLOR];
    [[NSColorPanel sharedColorPanel] setDelegate:self];
	
    [browseOptionMatrix selectCellWithTag:df_SLIDE_BROWSE_OPTION];
    [self browseOptionChange:browseOptionMatrix];
	
    [randomBtn setState:df_SLIDE_BROWSE_RANDOM];
	[expandToScreenBtn setState:df_SLIDE_EXPAND_SCREEN];
	
    [depthStepper setIntValue:df_SLIDE_BROWSE_FOLDER_DEPTH];
    [depthTxf setIntValue:df_SLIDE_BROWSE_FOLDER_DEPTH];
    [secondsStepper setFloatValue:df_SLIDE_BROWSE_SECONDS];
    [secondsTxf setFloatValue:df_SLIDE_BROWSE_SECONDS];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:pathTxf];
}

- (void)setWindow:(NSWindow *)_window
{
	window = _window;
}

- (NSColorWell *)backgroundColorWell
{
    return bgColorWell;
}

- (NSPanel *)optionPanel
{
	return optionPanel;
}

- (void)windowWillClose:(NSNotification *)notification
{
	// shared by the panel and color wells
	if ([notification object] == optionPanel) {
		// handle the color panel here
		if ([[NSColorPanel sharedColorPanel] isVisible]) [[NSColorPanel sharedColorPanel] close];
	}
}

- (IBAction)start:(id)sender
{
    if (sender == startBtn) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		
        df_SLIDE_BROWSE_RANDOM = [randomBtn state];
        [userDefaults setBool:df_SLIDE_BROWSE_RANDOM forKey:@"df_SLIDE_BROWSE_RANDOM"];
		df_SLIDE_EXPAND_SCREEN = [expandToScreenBtn state];
		[userDefaults setBool:df_SLIDE_EXPAND_SCREEN forKey:@"df_SLIDE_EXPAND_SCREEN"];
		
		df_SLIDE_BROWSE_SECONDS = [secondsTxf floatValue];
		if (df_SLIDE_BROWSE_SECONDS < 0) df_SLIDE_BROWSE_SECONDS = 0;
		[userDefaults setFloat:df_SLIDE_BROWSE_SECONDS forKey:@"df_SLIDE_BROWSE_SECONDS"];
        df_SLIDE_BROWSE_FOLDER_DEPTH = [depthTxf intValue];
        [userDefaults setInteger:df_SLIDE_BROWSE_FOLDER_DEPTH forKey:@"df_SLIDE_BROWSE_FOLDER_DEPTH"];
		
		[df_SLIDE_BG_COLOR autorelease];
		df_SLIDE_BG_COLOR = [[bgColorWell color] copy];
        [userDefaults setObject:[[SpUtil sharedUtil] componentArrayWithColor:df_SLIDE_BG_COLOR] forKey:@"df_SLIDE_BG_COLOR"];
		
		df_SLIDE_BROWSE_OPTION = [[browseOptionMatrix selectedCell] tag];
        [userDefaults setInteger:df_SLIDE_BROWSE_OPTION forKey:@"df_SLIDE_BROWSE_OPTION"];
		
		SpNavigator *navigator = [[SpNavigator alloc] initWithPath:[[pathTxf stringValue] stringByExpandingTildeInPath] depth:df_SLIDE_BROWSE_FOLDER_DEPTH];
		[navigator setSlideRandom:df_SLIDE_BROWSE_RANDOM];
		
		[optionPanel close];
		
		SlideController *controller = [window windowController];
		[controller setNavigator:navigator];
		[controller start:df_SLIDE_EXPAND_SCREEN useTimer:df_SLIDE_BROWSE_OPTION];
		
    } else {
		[optionPanel close];
		[window close];
	}
	
}

- (IBAction)select:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel beginSheetForDirectory:[pathTxf stringValue] file:nil types:[NSArray array]
		modalForWindow:optionPanel modalDelegate:self
		didEndSelector:@selector(selectSheetDidEnd:returnCode:contextInfo:)
		contextInfo:NULL];
}

- (void)selectSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton) {
		NSString *filename = [(NSOpenPanel *)sheet filename];
        [pathTxf setStringValue:filename];
		[pathTxf setToolTip:filename];
    }
    [sheet close];
}

- (IBAction)browseOptionChange:(id)sender
{
    if ([[sender selectedCell] tag]) {
        [secondsTxf setEnabled:YES];
        [secondsStepper setEnabled:YES];
        [optionPanel makeFirstResponder:secondsTxf];
    } else {
        [secondsTxf setEnabled:NO];
        [secondsStepper setEnabled:NO];
        [optionPanel makeFirstResponder:pathTxf];
    }
}

- (void)textDidChange:(NSNotification *)aNotification
{
    BOOL isDir;
    if ([[pathTxf stringValue] isEqualToString:@"~/"]) [pathTxf setStringValue:NSHomeDirectory()];
    if ([fileManager fileExistsAtPath:[[pathTxf stringValue] stringByExpandingTildeInPath] isDirectory:&isDir] && isDir) {
        if (![startBtn isEnabled]) [startBtn setEnabled:YES];
    } else {
        if ([startBtn isEnabled]) [startBtn setEnabled:NO];
    }
}

- (IBAction)stepperAction:(id)sender
{
	NSTextField *textField = nil;
	int tag = [sender tag];
	if (tag == 1) {
		textField = depthTxf;
	} else if (tag == 2) {
		textField = secondsTxf;
	}
	[textField setFloatValue:[sender currentValue:[textField floatValue]]];
}

- (void)changeColor:(id)sender
{
	NSColor *color = [sender color];
	[bgColorWell setColor:color];
	[[window contentView] setBackgroundColor:color];
}

@end
