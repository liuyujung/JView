//
//  MySaveAsObject.h
//  JViewbt
//
//  Created by Allan on 4/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MySaveAsObject : NSObject {

	IBOutlet NSView *saveUtilityView;
    IBOutlet NSPopUpButton *fileTypeBtn;
    IBOutlet NSButton *interlacedBtn;
    IBOutlet NSMatrix *compressionMatrix, *sizeMatrix;
    IBOutlet NSSlider *imageQualitySlider;
	
	MyDocumentController *controller;
}

- (IBAction)fileTypeChanged:(id)sender;
- (id)initWithDocumentController:(MyDocumentController *)_controller;
- (void)saveAs;

@end
