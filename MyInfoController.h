/* MyInfoController */

#import <Cocoa/Cocoa.h>


@interface MyInfoController : NSWindowController
{
    IBOutlet NSTextField *dimensionTxf, *resolutionTxf, *visibleTxf, *bitTxf, *fileSizeTxf, *currentDimensionTxf,
		*digitalZoomRatioTxf, *dateCreatedTxf, *dateModifiedTxf, *dateOriginalTxf;
	MyDocumentController *controller;
}
- (IBAction)click:(id)sender;
- (void)ratioChange:(NSNotification *)notification;
@end
