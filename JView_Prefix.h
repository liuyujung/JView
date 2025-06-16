/*
 *  JView_Prefix.h
 *  JView
 *
 *  Created by Allan on Thu Jan 01 2004.
 *  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
 *
 */

//#define DOCK_ADJUSTMENT 32
//#define SIDEDOCK_ADJUSTMENT 4

#define WINDOW_TITLEBAR_HEIGHT 28
#define CASCADE_X 26
#define CASCADE_Y 28

typedef enum {
    rotateLeft = 0,
    rotateRight,
    flipHorizontal,
    flipVertical
} Type;

typedef enum {
	deleteOperation,
	recycleOperation,
	moveOperation,
	removeOperation,
	copyOperaion
} Operation;
 
#import <Cocoa/Cocoa.h>
#import "JwBundle.h"
#import "SpImageUtil.h"
#import "SpUtil.h"
#import "SpNavigator.h"
#import "SpFile.h"
#import "SpFolder.h"
#import "SpFileUtil.h"
#import "SpImageCache.h"
#import "Operatable.h"
#import "TimerableController.h"
#import "MyMoveToObject.h"
#import "MyImageView.h"
#import "MyStepper.h"
#import "MyDocumentController.h"
#import "MyZoomController.h"
#import "MyFrameController.h"
#import "MyInfoController.h"
#import "MyPreferenceController.h"
#import "MyAboutController.h"
#import "MySaveAsObject.h"
#import "MyAppDelegate.h"
#import "MyApplication.h"
#import "PreviewImageView.h"
#import "PreviewController.h"
#import "OptionsDelegate.h"
#import "SlideController.h"

extern void HideMenuBar();
extern void ShowMenuBar();

/****************************
	Global variables
****************************/
extern NSMutableArray *fileTypes;
extern NSWorkspace *workSpace;
extern NSFileManager *fileManager;

extern SpImageCache *imageCache;

extern BOOL isSpecialAlert;
extern int scroller_pixel;
extern float mouseSpeedX, mouseSpeedY;

extern NSString *WindowSizeChangeNotification,
				*VisibleRectChangeNotification,
				*PreviewImageChangeNotification,
				*WindowBecomeMainNotification;

/****************************
	Localized bundle strings
****************************/
extern NSString *b_UNTITLED,
				*b_OK,
				*b_CANCEL,
				*b_DELETE_FAILED,
				*b_RECYCLE_FAILED,
				*b_SAVE_FAILED,
				*b_MOVE_FAILED,
				*b_OPERATION_FAILED,
				*b_DELETE_CONFIRM,
				*b_RECYCLE_CONFIRM,
				*b_DELETE_SHEET_TITLE,
				*b_RECYCLE_SHEET_TITLE,
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
extern BOOL df_RESIZE_TO_FIT,
		    df_WARN_BEFORE_DELETE,
			df_HIDE_IMAGE_CLOSED,
			df_OPEN_WINDOW_IN_BACKGROUND,
			df_OPEN_WINDOW_CASCADE,
		    df_OPEN_WINDOW_CENTER,
			df_ALLOW_TO_EXPAND,
			//df_ENABLE_AUTO_ZOOM,
			df_ENABLE_CACHE;
			
extern int df_NAVIGATION_FOLDER_DEPTH,
		   df_CACHE_SIZE2_MB,
		   df_VERTICAL_LINE_PIXELS,
		   df_VERTICAL_PAGE_PIXELS,
		   df_HORIZONTAL_LINE_PIXELS,
		   df_NEXT_IMAGE_KEY,
		   df_PREVIOUS_IMAGE_KEY,
		   df_NEXT_RANDOM_KEY,
		   df_PREVIOUS_RANDOM_KEY;

extern float df_MOUSE_SPEEdf_X_FACTOR,
			 df_MOUSE_SPEEdf_Y_FACTOR,
			 df_DEFAULT_RATIO,
			 df_AUTO_BROWSE_INTERVAL,
			 df_SCROLL_ACCE_FACTOR;

extern NSString *df_DEFAULT_LOCATION;
				
/****************************
	Slide options
****************************/
extern NSColor *df_SLIDE_BG_COLOR;

extern BOOL df_SLIDE_IS_SLIDE,
			df_SLIDE_BROWSE_RANDOM,
			df_SLIDE_EXPAND_SCREEN;

extern float df_SLIDE_BROWSE_SECONDS;
			
extern int df_SLIDE_BROWSE_FOLDER_DEPTH,
		   df_SLIDE_BROWSE_OPTION;
		   
extern NSString *df_SLIDE_BG_COLOR_TITLE,
				*df_SLIDE_TXT_COLOR_TITLE;

/****************************
	SaveAs defaults
****************************/
extern BOOL df_SAVEAS_INTERLACE;
extern int df_SAVEAS_COMPRESSION, df_SAVEAS_FORMAT, df_SAVEAS_SIZE;
extern float df_SAVEAS_QUALITY;
				
