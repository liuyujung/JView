/* MyAppDelegate */

#import <Cocoa/Cocoa.h>

@interface MyAppDelegate : NSObject
{
	IBOutlet NSMenuItem *autoBrowseMenuItem, *lockFrameMenuItem;
    NSMutableArray *windows;
    NSString *mostRecentPath;
}

- (IBAction)about:(id)sender;
- (IBAction)preference:(id)sender;
- (IBAction)slide:(id)sender;
- (IBAction)openFile:(id)sender;
- (IBAction)saveAs:(id)sender;
- (IBAction)deleteFile:(id)sender;
- (IBAction)closeAllFiles:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)duplicate:(id)sender;
- (IBAction)scaleZoom:(id)sender;
- (IBAction)otherZoom:(id)sender;
- (IBAction)cascade:(id)sender;
- (IBAction)rearrange:(id)sender;
- (IBAction)transform:(id)sender;
- (IBAction)originalImage:(id)sender;
- (IBAction)getInfo:(id)sender;
- (IBAction)autoBrowse:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)fullScreen:(id)sender;
- (IBAction)centerWindow:(id)sender;
- (IBAction)moveTo:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)navigation:(id)sender;
- (IBAction)frameSize:(id)sender;
- (IBAction)toggleLockFrame:(id)sender;
- (IBAction)previewPanel:(id)sender;

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (void)close:(NSNotification *)notification;
- (BOOL)validateMenuItem:(NSMenuItem *)anItem;
- (NSMutableArray *)windowArray;
- (void)setMostRecentPath:(NSString *)_mostRecentPath;
- (NSString *)mostRecentPath;
- (void)hideWindows;
- (void)unhideWindows;
- (void)traverseNextImage:(BOOL)_reverse;
- (NSImage *)performOperationForController:(TimerableController <Operatable> *)_controller operation:(Operation)_operation;

@end
