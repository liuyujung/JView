#import "MyImageView.h"
#import "TimerableController.h"
#import "MyDocumentController.h"

@interface MyImageView (PrivateMethods)
- (NSImage *)transformFromImage:(NSImage *)image;
- (void)transformImage;
@end

@implementation MyImageView

// only called by manually initialization
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self resetTransform];
    }
    return self;
}

- (void)dealloc
{
	if (scrollWheelTimer) {
		[scrollWheelTimer invalidate];
		//[scrollWheelTimer release];
	}
    [super dealloc];
}

- (void)awakeFromNib
{
    [self resetTransform];
}

- (void)setImage:(NSImage *)image
{
    NSImageRep *rep = [[image representations] objectAtIndex:0];
    NSSize origSize = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
	correctFactor = origSize.width / [rep size].width;
	[rep setSize:origSize];
	hasAlpha = [rep hasAlpha];
	
    if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
		NSNumber *frameDuration;
		if (frameDuration = [(NSBitmapImageRep *)rep valueForProperty:NSImageCurrentFrameDuration]) {
			if ([frameDuration floatValue] == 0.0) [(NSBitmapImageRep *)rep setProperty:NSImageCurrentFrameDuration withValue:[NSNumber numberWithFloat:0.01]];
		}
		
		/*NSDictionary *properties = [(NSBitmapImageRep *)rep valueForProperty:NSImageEXIFData];
		if (properties) {
			NSLog(@"yes");
			NSLog(@"%d", [properties count]);
			
			NSLog([properties description]);
			
		} else {
			NSLog(@"no");
		}*/
	}
	
    [image setSize:origSize];
	if ([self isTransformed]) {
		[super setImage:[self transformFromImage:image]];
	} else {
		[super setImage:image];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PreviewImageChangeNotification object:nil];
	
	/*NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	[pboard declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:nil];
	[pboard setData:[[super image] TIFFRepresentation] forType:NSTIFFPboardType];*/
}

- (void)resetTransform
{
    a = NO;
    b = NO;
    sx = YES;
    sy = YES;
    currentDegree = 0;
}

- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)isOpaque
{
    return !hasAlpha;
}

- (void)mouseDown:(NSEvent *)event
{
	if (![[[super window] windowController] hasAnyScroller]) return;
    downPoint = [event locationInWindow];
    [(NSClipView *)[self superview] setDocumentCursor:[NSCursor closedHandCursor]];
}

- (void)mouseUp:(NSEvent *)event
{
	if (![[[super window] windowController] hasAnyScroller]) return;
    downPoint = NSZeroPoint;
    [(NSClipView *)[self superview] setDocumentCursor:[NSCursor openHandCursor]];
}

- (void)mouseDragged:(NSEvent *)event
{
	if (![[[super window] windowController] hasAnyScroller]) return;
    NSPoint point = [event locationInWindow];
    NSRect visibleRect = [(NSClipView *)[self superview] documentVisibleRect];
    visibleRect.origin.x += (downPoint.x - point.x) * mouseSpeedX;
    visibleRect.origin.y += (point.y - downPoint.y) * mouseSpeedY;
    downPoint = point;
    [self scrollPoint:visibleRect.origin];
	//[super autoscroll:event]; // problem for flipped coord, no need
}

- (void)scrollWheel:(NSEvent *)event
{
	float y = [event deltaY], ratio;
	MyDocumentController *controller;
	//NSLog(@"deltaX = %f", [event deltaX]);
	//NSLog(@"deltaY = %f", [event deltaY]);
	
	NSUInteger modifierFlags = [event modifierFlags];
	
	if (modifierFlags & NSCommandKeyMask) {
		
		if ([scrollWheelTimer isValid]) return;
			
		controller = [[super window] windowController];
		float x = [event deltaX];
			
		if (y < 0 || x < 0) {
			Navigation *navigation = [SpFolder navigation];
			[controller navigate:navigation];
			free(navigation);
		} else if (y > 0 || x > 0) {
			Navigation *navigation = [SpFolder navigation];
			navigation->reverse = YES;
			[controller navigate:navigation];
			free(navigation);
		}
			
		scrollWheelTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timeUp:) userInfo:nil repeats:NO];
		return;
	}
	
	if (modifierFlags & NSShiftKeyMask) {
		controller = [[super window] windowController];
		ratio = [controller ratio];
		ratio -= y / 20;
		[controller setRatio:ratio];
		[controller render:NO];
		return;
	}
	
	[super scrollWheel:event];
}

- (void)timeUp:(NSTimer *)_timer
{
	// cannot use _timer directly?!
	[scrollWheelTimer invalidate];
	//[scrollWheelTimer release];
	scrollWheelTimer = nil;
}

- (void)prepareTransformView:(Type)_type
{
	switch (_type) {
        case rotateLeft:
            currentDegree = (currentDegree + 90) % 360;
            c = !a;
            a = b;
            b = c;
            break;
        case rotateRight:
            currentDegree = (currentDegree - 90) % 360;
            c = !b;
            b = a;
            a = c;
            break;
        case flipHorizontal:
            sx = !sx;
            if ([self oddDegree]) b = !b;
            else a = !a;
            break;
        case flipVertical:
            sy = !sy;
            if ([self oddDegree]) a = !a;
            else b = !b;
            break;
    }
}

- (BOOL)isTransformed
{
    return !(a == 0 && b == 0 && sx == sy);
}

- (NSImage *)transformFromImage:(NSImage *)image
{
	NSAffineTransform *trans = [NSAffineTransform transform];
    NSImage *img = [[NSImage alloc] initWithSize:[image size]];
	
    NSRect drawRect;
    if ([self oddDegree]) {
        drawRect.size.width = [img size].height;
        drawRect.size.height = [img size].width;
    } else {
        drawRect.size = [img size];
    }
    drawRect.origin = NSMakePoint(a ? -drawRect.size.width : 0, b ? -drawRect.size.height : 0);
    
    [trans scaleXBy:(sx ? 1 : -1) yBy:(sy ? 1 : -1)];
    [trans rotateByDegrees:currentDegree];
    
    [img lockFocus];
    [trans concat];    
    [image drawInRect:drawRect fromRect:NSMakeRect(0, 0, [img size].width, [img size].height)
		operation:NSCompositeSourceOver fraction:1.0];
    [img unlockFocus];
	[img setSize:drawRect.size];
	
	return [img autorelease];
}

/*- (NSImage *)transformFromImage:(NSImage *)image
{
	NSAffineTransform *trans = [NSAffineTransform transform];
    NSImage *img = [[NSImage alloc] initWithSize:[image size]];
	
    NSRect drawRect;
    if ([self oddDegree]) {
        drawRect.size.width = [img size].height;
        drawRect.size.height = [img size].width;
    } else {
        drawRect.size = [img size];
    }
    drawRect.origin = NSMakePoint(a ? -drawRect.size.width : 0, b ? -drawRect.size.height : 0);
    
    [trans scaleXBy:(sx ? 1 : -1) yBy:(sy ? 1 : -1)];
    [trans rotateByDegrees:currentDegree];
    
    [img lockFocus];
    [trans concat];    
    [image drawInRect:drawRect fromRect:NSMakeRect(0, 0, [img size].width, [img size].height)
        operation:NSCompositeSourceOver fraction:1.0];
    [img unlockFocus];
	[img setSize:drawRect.size];
	
	return [img autorelease];
}*/

- (BOOL)a
{
	return a;
}

- (BOOL)b
{
	return b;
}

- (BOOL)sx
{
	return sx;
}

- (BOOL)sy
{
	return sy;
}

- (int)currentDegree
{
	return currentDegree;
}

- (BOOL)oddDegree
{
    return currentDegree % 180;
}

- (int)resolution
{
    return (int)(72 * correctFactor);
}

- (id)copyWithZone:(NSZone *)zone
{
	MyImageView *copy = [[MyImageView allocWithZone:zone] init];
	
	[copy setImageFrameStyle:[super imageFrameStyle]];
	[copy setImageAlignment:[super imageAlignment]];
	[copy setImageScaling:[super imageScaling]];
	[copy setEditable:[super isEditable]];
	
	copy->a = a;
	copy->b = b;
	copy->sx = sx;
	copy->sy = sy;
	copy->currentDegree = currentDegree;
	
	 // has to be before setFrameSize and after setting transform factors
	[copy setImage:[super image]];
	[copy setFrameSize:[[copy image] size]];
	
	return copy;
}

@end
