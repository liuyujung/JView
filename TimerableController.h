//
//  TimerableController.h
//  JView
//
//  Created by Allan on Wed Apr 14 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@class MyMoveToObject;

@interface TimerableController : NSWindowController <Operatable>
{
	NSTimer *myTimer;
	BOOL isPaused;
	
	@protected
	MyMoveToObject *moveToObject;
}
- (void)showNextImage:(Navigation *)_navigation;
- (void)startTimer;
- (void)stopTimer;
- (void)pauseTimer;
- (void)resumeTimer;
- (BOOL)isTimer;
- (BOOL)isTimerValid;
- (MyMoveToObject *)moveToObject;
@end
