/* MyApplication */

#import <Cocoa/Cocoa.h>

@interface MyApplication : NSApplication
{
	NSWindow *slideWindow;
}
- (void)setSlideWindow:(NSWindow *)_slideWindow;
- (NSWindow *)slideWindow;
@end
