#import "MyInfoController.h"

@interface MyInfoController (PrivateMethods)
- (void)updateDimensions;
- (void)updateVisibleDimensions;
+ (NSString *)dimensionStringForSize:(NSSize)_dimension;
@end

@implementation MyInfoController

- (id)init
{
    if (self = [super initWithWindowNibName:@"Info"]) {
		controller = [[NSApp mainWindow] windowController];
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(ratioChange:)
            name:WindowSizeChangeNotification object:controller];
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(windowSizeChange:)
			name:NSWindowDidResizeNotification object:[controller window]];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)ratioChange:(NSNotification *)notification
{
	[self updateDimensions];
}

- (void)windowSizeChange:(NSNotification *)notification
{
	[self updateVisibleDimensions];
}

- (void)windowDidLoad
{	
	[self updateDimensions];
	[self updateVisibleDimensions];
	
	MyImageView *imageView = [controller imageView];
	NSImageRep *rep = [[[imageView image] representations] objectAtIndex:0];
	
    [resolutionTxf setIntValue:[imageView resolution]]; // need to check! Problem!
	
	if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
		short bit = [(NSBitmapImageRep *)rep bitsPerPixel];
		if (bit) {
			[bitTxf setIntValue:bit];
		} else {
			[bitTxf setStringValue:b_UNKNOWN_VALUE]; // work?
		}
		
		NSDictionary *properties = [(NSBitmapImageRep *)rep valueForProperty:NSImageEXIFData];
		if (properties) {
			NSNumber *digitalZoom = [properties objectForKey:(NSString *) kCGImagePropertyExifDigitalZoomRatio];
			if (digitalZoom) {
				[digitalZoomRatioTxf setObjectValue:digitalZoom];
			}
			NSString *dateOriginal = [properties objectForKey:(NSString *) kCGImagePropertyExifDateTimeOriginal];
			if (dateOriginal) {
				[dateOriginalTxf setStringValue:dateOriginal];
			}
		}
	}
		
	NSString *filename = [[[controller navigator] currentFile] realPath];
		
    if (![filename isEqualToString:b_UNTITLED]) {        
		NSDictionary *attributes = [fileManager fileAttributesAtPath:filename traverseLink:NO];
		[fileSizeTxf setFloatValue:[[attributes objectForKey:NSFileSize] intValue]];
		[dateModifiedTxf setObjectValue:[attributes objectForKey:NSFileModificationDate]];
		[dateCreatedTxf setObjectValue:[attributes objectForKey:NSFileCreationDate]];		
    }
	
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self autorelease];
}

- (void)updateDimensions
{
	MyImageView *imageView = [controller imageView];
	float ratio = [controller ratio];
	NSSize imageSize = [[imageView image] size];
	[dimensionTxf setStringValue:[MyInfoController dimensionStringForSize:imageSize]];
	[currentDimensionTxf setStringValue:[MyInfoController dimensionStringForSize:NSMakeSize(imageSize.width * ratio, imageSize.height * ratio)]];
}

- (void)updateVisibleDimensions
{
	NSRect visilbeRect = [[[controller scrollView] documentView] visibleRect];
	[visibleTxf setStringValue:[MyInfoController dimensionStringForSize:NSMakeSize(visilbeRect.size.width, visilbeRect.size.height)]];
}

- (IBAction)click:(id)sender
{
    [[self window] close];
    [NSApp endSheet:[self window]];
}

+ (NSString *)dimensionStringForSize:(NSSize)_dimension
{
    NSMutableString *string = [NSMutableString stringWithString:b_DIMENSION_WIDTH];
    [string appendString:[[NSNumber numberWithInt:_dimension.width] stringValue]];
    [string appendString:@" "];
    [string appendString:b_DIMENSION_HEIGHT];
    [string appendString:[[NSNumber numberWithInt:_dimension.height] stringValue]];
    return string;
}

@end
