//
//  MyMoveToObject.h
//  JViewbt
//
//  Created by Allan Liu on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TimerableController;


@interface MyMoveToObject : NSObject {

	IBOutlet NSView *moveToUtilityView;
	IBOutlet NSButton *defaultLocationBtn;
	IBOutlet NSTextField *messageTxf;
	TimerableController <Operatable> *controller;
	NSString *folder;
	BOOL usePreviousFolder, useAlertPanel, forceToOpen;
	
}

- (id)initWithDocumentController:(TimerableController <Operatable> *)_controller;
- (IBAction)click:(id)sender;
- (BOOL)prepareMove;
- (void)setUseAlertPanel:(BOOL)_useAlertPanel;
- (void)setForceToOpen:(BOOL)_forceToOpen;
- (NSString *)folder;

@end
