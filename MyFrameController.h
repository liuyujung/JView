//
//  MyFrameController.h
//
//  Created by Allan Liu on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyDocumentController;

@interface MyFrameController : NSWindowController {
	
	IBOutlet NSForm *dimension;
	IBOutlet NSButton *lockBtn;
	
	MyDocumentController *controller;

}

- (IBAction)click:(id)sender;

@end
