/* MyImageView */

#import <Cocoa/Cocoa.h>
#import "MyAppDelegate.h"

@interface MyImageView : NSImageView
{
	NSTimer *scrollWheelTimer;
    NSPoint downPoint;
    float correctFactor;
    int currentDegree;
    BOOL a, b, c, sx, sy, hasAlpha;
}
- (BOOL)a;
- (BOOL)b;
- (BOOL)sx;
- (BOOL)sy;
- (int)currentDegree;
- (void)timeUp:(NSTimer *)_timer;
- (void)resetTransform;
- (void)prepareTransformView:(Type)_type;
- (BOOL)oddDegree;
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (BOOL)isTransformed;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)scrollWheel:(NSEvent *)event;
- (int)resolution;
@end
