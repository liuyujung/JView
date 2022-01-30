//
//  TimerableController.m
//  JView
//
//  Created by Allan on Wed Apr 14 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "TimerableController.h"

@interface TimerableController (PrivateMethods)
- (void)fireNextImage:(NSTimer *)_timer;
@end


@implementation TimerableController

- (id)initWithWindowNibName:(NSString *)_nibName
{
	if (self = [super initWithWindowNibName:_nibName]) {
		myTimer = nil;
		moveToObject = nil;
		isPaused = NO;
	}
	return self;
}

- (void)dealloc
{
	[myTimer release];
	[moveToObject release];
	[super dealloc];
}

- (void)startTimer
{
	[myTimer invalidate];
	[myTimer autorelease];
    myTimer = [[NSTimer scheduledTimerWithTimeInterval:(df_SLIDE_IS_SLIDE ? df_SLIDE_BROWSE_SECONDS : df_AUTO_BROWSE_INTERVAL) target:self
		selector:@selector(fireNextImage:) userInfo:nil repeats:YES] retain];
}

- (void)resumeTimer
{
	if ([self isTimer]) {
		[self stopTimer];
		[self startTimer];
	}
}

- (void)stopTimer
{
	[myTimer invalidate];
	isPaused = NO;
}

- (void)pauseTimer
{
	/*BOOL isTimer = [self isTimer];
	isPaused = isPaused || isTimer;
	if (isTimer) {
		[myTimer invalidate];
	}*/
	BOOL isTimer = [myTimer isValid];
	isPaused = isPaused || isTimer;
	if (isTimer) {
		[myTimer invalidate];
	}
}

- (BOOL)isTimer
{
	return isPaused || [myTimer isValid];
}

- (BOOL)isTimerValid
{
	return [myTimer isValid];
}

- (void)fireNextImage:(NSTimer *)_timer
{
	Navigation *navigation = [SpFolder navigation];
	[self showNextImage:navigation];
	free(navigation);
}

- (void)performOperation:(Operation)_operation contextPath:(NSString *)_contextPath
{
	NSImage *image = nil;
	switch (_operation) {
		case recycleOperation:
			image = [[NSApp delegate] performOperationForController:self operation:recycleOperation];
			if (!image) return;
			break;
		case moveOperation:
			image = [[NSApp delegate] performOperationForController:self operation:moveOperation];
			if (!image) return;
			break;
		case removeOperation:
			image = [imageCache removeImageForNavigator:[self navigator]];
			break;
		case deleteOperation:
			break;
		case copyOperaion:
			
			break;
	}
	[self finishOperation:image];
}

- (void)moveCurrentImage:(BOOL)_forceToOpen
{
	[self pauseTimer];
	moveToObject = [self moveToObject];
	if (_forceToOpen) [moveToObject setForceToOpen:YES];
	if ([moveToObject prepareMove]) {
		[self performOperation:moveOperation contextPath:[moveToObject folder]];
		[self resumeTimer];
	}
}

// default implementation
- (SpNavigator *)navigator
{
	return nil;
}

// default implementation
- (void)showNextImage:(Navigation *)_navigation
{
}

// default implementation
- (void)finishOperation:(NSImage *)_image
{
}

// default implementation
- (MyMoveToObject *)moveToObject
{
	if (!moveToObject) moveToObject = [[MyMoveToObject alloc] initWithDocumentController:self];
	return moveToObject;
}
 
// default implementation
- (void)deleteCurrentImage
{
	[self performOperation:recycleOperation contextPath:nil];
}

@end
