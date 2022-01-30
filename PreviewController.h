//
//  PreviewController.h
//
//  Created by Allan Liu on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreviewController : NSWindowController {
	MyImageView *myImageView;
	IBOutlet PreviewImageView *previewImageView;
}

- (MyImageView *)myImageView;

@end
