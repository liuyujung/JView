/* MyZoomController */

#import <Cocoa/Cocoa.h>

@interface MyZoomController : NSWindowController
{
    IBOutlet NSTextField *percentTxf;
    float percentage;
}

- (IBAction)click:(id)sender;
- (void)ratioChange:(NSNotification *)notification;

@end
