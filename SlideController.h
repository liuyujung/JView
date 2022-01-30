//
//  SlideController.h
//
//  Created by Allan Liu on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SlideController : TimerableController {
	//IBOutlet NSPanel *optionPanel;
	IBOutlet OptionsDelegate *optionsDelegate;
	MyImageView *imageView;
	SpNavigator *navigator;
	NSImage *image;
	NSString *filename;
	float ratio;
	BOOL allowToExpand;
}

- (id)init;
- (id)initWithImage:(NSImage *)_image;
- (id)initWithFile:(NSString *)_filename;
- (void)openOptionPanel;
- (void)start:(BOOL)_allowToExpand useTimer:(BOOL)useTimer;
- (SpNavigator *)navigator;
- (void)setNavigator:(SpNavigator *)_navigator;

@end
