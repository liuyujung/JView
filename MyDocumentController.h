/* MyDocumentController */

#import <Cocoa/Cocoa.h>

// to avoid recursive includes
@class MyImageView, MyZoomController, MyInfoController, MySaveAsObject, MyMoveToObject;

@interface MyDocumentController : TimerableController
{
    IBOutlet NSScrollView *scrollView;
    IBOutlet MyImageView *imageView;
    NSImage *image;
    NSString *filename;
	MyZoomController *zoomController;
	MySaveAsObject *saveAsObject;
	
	int repeatCount;
    float ratio;
    BOOL flag, wasRepeat, frameLocked, hasVertical, hasHorizontal;
	NSSize lockedFrameSize;
	
	SpNavigator *navigator;
}

- (id)initWithFilename:(NSString *)_filename;
- (id)initWithImage:(NSImage *)_image;
- (void)render:(BOOL)resize;
- (void)otherZoom;
- (void)frameSize;
- (void)getInfo;
- (void)resetScrollers;
- (void)windowDidResize:(NSNotification *)notification;
- (void)keyDown:(NSEvent *)event;
- (void)transformImage:(Type)transformType;
- (void)originalImage;
- (void)saveAs;
- (NSString *)filename;
- (NSImage *)image;
- (NSData *)currentImageData:(BOOL)visibleArea originalSize:(BOOL)originalSize;
- (NSImage *)currentImage;
- (MyImageView *)imageView;
- (NSScrollView *)scrollView;
- (void)setFilename:(NSString *)_filename;
- (float)ratio;
- (void)setRatio:(float)_ratio;
- (void)setNavigator:(SpNavigator *)_navigator;
- (void)reload;
- (void)revealInFinder;
- (void)lockCurrentFolder;
- (void)navigate:(Navigation *)navigation;
- (BOOL)hasVertical;
- (BOOL)hasHorizontal;
- (BOOL)hasAnyScroller;
- (BOOL)frameLocked;
- (void)toggleLockFrame;
- (void)setFrameLocked:(BOOL)_frameLocked;
- (void)setCustomFrameSize:(NSSize)size;
- (NSSize)currentSize;

@end
