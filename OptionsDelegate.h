//
//  OptionsDelegate.h
//
//  Created by Allan Liu on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OptionsDelegate : NSObject {
	IBOutlet NSPanel *optionPanel;
	IBOutlet NSStepper *depthStepper, *secondsStepper;
    IBOutlet NSColorWell *bgColorWell;
    IBOutlet NSTextField *pathTxf, *depthTxf, *secondsTxf;
    IBOutlet NSMatrix *browseOptionMatrix;
    IBOutlet NSButton *startBtn, *randomBtn, *expandToScreenBtn;
	NSWindow *window;
	
}

- (IBAction)start:(id)sender;
- (IBAction)select:(id)sender;
- (IBAction)browseOptionChange:(id)sender;
- (IBAction)stepperAction:(id)sender;
- (void)changeColor:(id)sender;
- (void)setWindow:(NSWindow *)_window;
- (NSColorWell *)backgroundColorWell;
- (NSPanel *)optionPanel; 

@end
