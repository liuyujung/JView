/* MyPreferenceController */

#import <Cocoa/Cocoa.h>

@interface MyPreferenceController : NSWindowController
{
	IBOutlet NSButton *okBtn,
					  *resizeFitWindowBtn,
					  *allowToExpandBtn,
					  *disableCacheBtn,
					  *warnDeleteBtn,
					  *hideImageClosedBtn,
					  *cascadeImageBtn,
				      *centerImageBtn,
					  *backgroundImageBtn;
					  
	IBOutlet NSTextField *defaultLocationTxf,
						 *depthTxf,
						 *cacheSizeTxf,
						 *zoomTxf,
						 *autoBrowseIntervalTxf;
						 
    IBOutlet NSStepper *depthStepper, *cacheSizeStepper, *autoBrowseIntervalStepper;
	
	IBOutlet NSForm *imageNavigationKeysForm, *randomKeysForm;
}

+ (id)sharedPreferenceWindow;

- (IBAction)click:(id)sender;
- (IBAction)toggleResizeToFitWindow:(id)sender;
- (IBAction)toggleCascadeImage:(id)sender;
- (IBAction)toggleCenterImage:(id)sender;
- (IBAction)toggleEnableCache:(id)sender;
- (IBAction)selectDefaultLocation:(id)sender;
- (IBAction)stepperAction:(id)sender;

@end
