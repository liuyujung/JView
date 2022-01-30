//
//  MyBundle.m
//  JView
//
//  Created by Allan on Thu Jan 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SpUtil.h"

@implementation JwBundle

/****************************
	Global variables
****************************/
NSMutableArray *fileTypes;
NSWorkspace *workSpace;
NSFileManager *fileManager;

SpImageCache *imageCache;

BOOL isSpecialAlert;
int scroller_pixel;
float mouseSpeedX, mouseSpeedY;

NSString *WindowSizeChangeNotification = @"WindowSizeChangeNotification",
		 *VisibleRectChangeNotification = @"VisibleRectChangeNotification",
		 *PreviewImageChangeNotification = @"PreviewImageChangeNotification",
		 *WindowBecomeMainNotification = @"WindowBecomeMainNotification";

/****************************
	Localized bundle strings
****************************/
NSString *b_UNTITLED,
		 *b_OK,
 		 *b_CANCEL,
		 *b_SAVE_FAILED,
		 *b_OPERATION_FAILED,
		 *b_MOVE_FAILED,
		 *b_DELETE_FAILED,
		 *b_RECYCLE_FAILED,
		 *b_DELETE_SHEET_TITLE,
		 *b_RECYCLE_SHEET_TITLE,
		 *b_DELETE_CONFIRM,
		 *b_RECYCLE_CONFIRM,
		 *b_UNKNOWN_VALUE,
		 *b_DIMENSION_WIDTH,
		 *b_DIMENSION_HEIGHT,
		 *b_NO_IMAGE,
		 *b_AUTO_BROWSE,
		 *b_STOP_BROWSE,
		 *b_LOCK_FRAME,
		 *b_UNLOCK_FRAME,
		 *b_SKIP_FILE,
		 *b_REVEAL_FILE,
		 *b_TRASH_FILE,
		 *b_CANNOT_OPEN_FILE,
		 *b_MOVE_FILE_MESSAGE;

/****************************
	User defaults
****************************/
BOOL df_RESIZE_TO_FIT,
	 df_WARN_BEFORE_DELETE,
	 df_HIDE_IMAGE_CLOSED,
	 df_OPEN_WINDOW_IN_BACKGROUND,
	 df_OPEN_WINDOW_CASCADE,
	 df_OPEN_WINDOW_CENTER,
	 df_ALLOW_TO_EXPAND,
	 //df_ENABLE_AUTO_ZOOM,
	 df_ENABLE_CACHE;

int df_NAVIGATION_FOLDER_DEPTH,
	df_CACHE_SIZE2_MB,
	df_VERTICAL_LINE_PIXELS,
	df_VERTICAL_PAGE_PIXELS,
	df_HORIZONTAL_LINE_PIXELS,
	df_NEXT_IMAGE_KEY,
	df_PREVIOUS_IMAGE_KEY,
	df_NEXT_RANDOM_KEY,
	df_PREVIOUS_RANDOM_KEY;

float df_MOUSE_SPEEdf_X_FACTOR,
	  df_MOUSE_SPEEdf_Y_FACTOR,
	  df_DEFAULT_RATIO,
	  df_AUTO_BROWSE_INTERVAL,
	  df_SCROLL_ACCE_FACTOR;
	 
NSString *df_DEFAULT_LOCATION;

/****************************
	SaveAs defaults
****************************/
BOOL df_SAVEAS_INTERLACE;

int df_SAVEAS_COMPRESSION, df_SAVEAS_FORMAT, df_SAVEAS_SIZE;

float df_SAVEAS_QUALITY;
		 
/****************************
	Slide options
****************************/
NSColor *df_SLIDE_BG_COLOR;

BOOL df_SLIDE_IS_SLIDE,
	 df_SLIDE_BROWSE_RANDOM,
	 df_SLIDE_EXPAND_SCREEN;

float df_SLIDE_BROWSE_SECONDS;
	 
int df_SLIDE_BROWSE_FOLDER_DEPTH,
	df_SLIDE_BROWSE_OPTION;

NSString *df_SLIDE_BG_COLOR_TITLE;

+ (void)initialize
{
	/****************************
		User defaults
	****************************/
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	df_RESIZE_TO_FIT = [userDefaults boolForKey:@"df_RESIZE_TO_FIT"];
	df_ALLOW_TO_EXPAND = [userDefaults boolForKey:@"df_ALLOW_TO_EXPAND"];
	df_WARN_BEFORE_DELETE = [userDefaults boolForKey:@"df_WARN_BEFORE_DELETE"];
	df_HIDE_IMAGE_CLOSED = [userDefaults boolForKey:@"df_HIDE_IMAGE_CLOSED"];
	df_OPEN_WINDOW_IN_BACKGROUND = [userDefaults boolForKey:@"df_OPEN_WINDOW_IN_BACKGROUND"];
	df_OPEN_WINDOW_CASCADE = [userDefaults boolForKey:@"df_OPEN_WINDOW_CASCADE"];
	df_OPEN_WINDOW_CENTER = [userDefaults boolForKey:@"df_OPEN_WINDOW_CENTER"];
	//df_ENABLE_AUTO_ZOOM = [userDefaults boolForKey:@"df_ENABLE_AUTO_ZOOM"];
	df_ENABLE_CACHE = [userDefaults boolForKey:@"df_ENABLE_CACHE"];
	
	df_DEFAULT_LOCATION = [[userDefaults stringForKey:@"df_DEFAULT_LOCATION"] copy];
	
	df_MOUSE_SPEEdf_X_FACTOR = [userDefaults floatForKey:@"df_MOUSE_SPEEdf_X_FACTOR"];
	df_MOUSE_SPEEdf_Y_FACTOR = [userDefaults floatForKey:@"df_MOUSE_SPEEdf_Y_FACTOR"];
	df_DEFAULT_RATIO = [userDefaults floatForKey:@"df_DEFAULT_RATIO"];
	df_AUTO_BROWSE_INTERVAL = [userDefaults floatForKey:@"df_AUTO_BROWSE_INTERVAL"];
	df_SCROLL_ACCE_FACTOR = [userDefaults floatForKey:@"df_SCROLL_ACCE_FACTOR"];
	
	df_NAVIGATION_FOLDER_DEPTH = [userDefaults integerForKey:@"df_NAVIGATION_FOLDER_DEPTH"];
	df_CACHE_SIZE2_MB = [userDefaults integerForKey:@"df_CACHE_SIZE2_MB"];
	df_VERTICAL_LINE_PIXELS = [userDefaults integerForKey:@"df_VERTICAL_LINE_PIXELS"];
	df_VERTICAL_PAGE_PIXELS = [userDefaults integerForKey:@"df_VERTICAL_PAGE_PIXELS"];
	df_HORIZONTAL_LINE_PIXELS = [userDefaults integerForKey:@"df_HORIZONTAL_LINE_PIXELS"];
	df_NEXT_IMAGE_KEY = [userDefaults integerForKey:@"df_NEXT_IMAGE_KEY"]; // if 0? necesary?
	df_PREVIOUS_IMAGE_KEY = [userDefaults integerForKey:@"df_PREVIOUS_IMAGE_KEY"];
	df_NEXT_RANDOM_KEY = [userDefaults integerForKey:@"df_NEXT_RANDOM_KEY"];
	df_PREVIOUS_RANDOM_KEY = [userDefaults integerForKey:@"df_PREVIOUS_RANDOM_KEY"];

	/****************************
		Global variables
	****************************/
    workSpace = [NSWorkspace sharedWorkspace];
    fileManager = [NSFileManager defaultManager];
    fileTypes = (NSMutableArray *)[NSImage imageFileTypes];
    [fileTypes removeObject:@"'PDF '"];
    [fileTypes removeObject:@"PDF"];
    [fileTypes removeObject:@"pdf"];
    [fileTypes removeObject:@"'EPSF'"];
    [fileTypes removeObject:@"eps"];
	
	imageCache = [[SpImageCache alloc] initWithCapacityMBytes:(df_ENABLE_CACHE ? df_CACHE_SIZE2_MB : 0)];
	scroller_pixel = [NSScroller scrollerWidth];
	isSpecialAlert = NO;
	
	[JwBundle setMouseSpeedX:df_MOUSE_SPEEdf_X_FACTOR];
	[JwBundle setMouseSpeedY:df_MOUSE_SPEEdf_Y_FACTOR];
	
	//handCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"hand.tif"] hotSpot:NSMakePoint(7, 7)];
	//grabCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"grab.tif"] hotSpot:NSMakePoint(7, 7)];
	
	/****************************
		Localized bundle strings
	****************************/
	b_UNTITLED = NSLocalizedString(@"b_UNTITLED", @"Untitled");
	b_UNKNOWN_VALUE = NSLocalizedString(@"b_UNKNOWN_VALUE", @"unknown");
	b_DIMENSION_WIDTH = NSLocalizedString(@"b_DIMENSION_WIDTH", @"W:");
	b_DIMENSION_HEIGHT = NSLocalizedString(@"b_DIMENSION_HEIGHT", @"H:");
	
	b_OK = NSLocalizedString(@"b_OK", @"OK");
	b_CANCEL = NSLocalizedString(@"b_CANCEL", @"Cancel");
	
	b_DELETE_CONFIRM = NSLocalizedString(@"b_DELETE_CONFIRM", @"This item will be delete immediately You can't undo this action.");
	b_RECYCLE_CONFIRM = NSLocalizedString(@"b_RECYCLE_CONFIRM", @"This item will be recycled.");
	b_OPERATION_FAILED = NSLocalizedString(@"b_OPERATION_FAILED", @"Operation failed.");
	b_SAVE_FAILED = NSLocalizedString(@"b_SAVE_FAILED", @"Save failed.");
	b_DELETE_FAILED = NSLocalizedString(@"b_DELETE_FAILED", @"Delete failed.");
	b_RECYCLE_FAILED = NSLocalizedString(@"b_RECYCLE_FAILED", @"Recycle failed.");
	b_MOVE_FAILED =	NSLocalizedString(@"b_MOVE_FAILED", @"Move failed.");
	b_DELETE_SHEET_TITLE = NSLocalizedString(@"b_DELETE_SHEET_TITLE", @"Are you sure you want to delete ");
	b_RECYCLE_SHEET_TITLE = NSLocalizedString(@"b_RECYCLE_SHEET_TITLE", @"Are you sure you want to recycle ");
	
	b_NO_IMAGE = NSLocalizedString(@"b_NO_IMAGE", @"There is no image in the folder.");
	
	b_AUTO_BROWSE = NSLocalizedString(@"b_AUTO_BROWSE", @"Auto Browse");
	b_STOP_BROWSE = NSLocalizedString(@"b_STOP_BROWSE", @"Stop Browse");
	b_LOCK_FRAME = NSLocalizedString(@"b_LOCK_FRAME", @"Lock Frame");
	b_UNLOCK_FRAME = NSLocalizedString(@"b_UNLOCK_FRAME", @"Unlock Frame");
	
	b_SKIP_FILE = NSLocalizedString(@"b_SKIP_FILE", @"Skip");
	b_REVEAL_FILE = NSLocalizedString(@"b_REVEAL_FILE", @"Reveal in Finder");
	b_TRASH_FILE = NSLocalizedString(@"b_TRASH_FILE", @"Trash It");
	b_CANNOT_OPEN_FILE = NSLocalizedString(@"b_CANNOT_OPEN_FILE", @"Cannot open the file. Use 'ESC' to cancel.");
	b_MOVE_FILE_MESSAGE = NSLocalizedString(@"b_MOVE_FILE_MESSAGE", @"(Use 'm' key to bring back this window)");
	
	/****************************
		Slide options
	****************************/
	df_SLIDE_BG_COLOR = [[[SpUtil sharedUtil] colorWithComponentArray:[userDefaults objectForKey:@"df_SLIDE_BG_COLOR"]] copy];
	
	df_SLIDE_IS_SLIDE = NO;
	df_SLIDE_BROWSE_RANDOM = [userDefaults boolForKey:@"df_SLIDE_BROWSE_RANDOM"];
	df_SLIDE_EXPAND_SCREEN = [userDefaults boolForKey:@"df_SLIDE_EXPAND_SCREEN"];
	
	df_SLIDE_BROWSE_FOLDER_DEPTH = [userDefaults integerForKey:@"df_SLIDE_BROWSE_FOLDER_DEPTH"];
	df_SLIDE_BROWSE_OPTION = [userDefaults integerForKey:@"df_SLIDE_BROWSE_OPTION"];
	df_SLIDE_BROWSE_SECONDS = [userDefaults floatForKey:@"df_SLIDE_BROWSE_SECONDS"];
	
	df_SLIDE_BG_COLOR_TITLE = NSLocalizedString(@"df_SLIDE_BG_COLOR_TITLE", @"Background Color");
	
	/****************************
		SaveAs defaults
	****************************/
	df_SAVEAS_INTERLACE = [userDefaults boolForKey:@"df_SAVEAS_INTERLACE"];

	df_SAVEAS_COMPRESSION = [userDefaults integerForKey:@"df_SAVEAS_COMPRESSION"];
	df_SAVEAS_FORMAT = [userDefaults integerForKey:@"df_SAVEAS_FORMAT"];
	df_SAVEAS_SIZE = [userDefaults integerForKey:@"df_SAVEAS_SIZE"];

	df_SAVEAS_QUALITY = [userDefaults floatForKey:@"df_SAVEAS_QUALITY"];

}

/*
	0.1 - 2.0, standard = 1.1
*/
+ (void)setMouseSpeedX:(float)_mouseSpeedXFactor
{
	if (_mouseSpeedXFactor >= 1.1) mouseSpeedX = _mouseSpeedXFactor * 10 - 10;
    else mouseSpeedX = _mouseSpeedXFactor;
}

+ (void)setMouseSpeedY:(float)_mouseSpeedYFactor
{
	if (_mouseSpeedYFactor >= 1.1) mouseSpeedY = _mouseSpeedYFactor * 10 - 10;
    else mouseSpeedY = _mouseSpeedYFactor;
}

@end
