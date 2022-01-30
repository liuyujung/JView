#import "MyZoomController.h"

@implementation MyZoomController

- (id)init
{
    if (self = [super initWithWindowNibName:@"Zoom"]) {
		MyDocumentController *controller = [[NSApp mainWindow] windowController];
        percentage = [controller ratio] * 100;
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(ratioChange:)
            name:WindowSizeChangeNotification object:controller];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidLoad
{
    [[self window] makeFirstResponder:nil];
    [percentTxf setFloatValue:percentage];
}

- (IBAction)click:(id)sender
{
    id controller;
    if ([sender tag]) {
        percentage = [percentTxf floatValue] == 0 ? percentage : [percentTxf floatValue];
        controller = [[NSApp mainWindow] windowController];
        [controller setRatio:percentage / 100.0];
        [controller render:NO];
    }
    [[self window] close];
	[self windowDidLoad];
    [NSApp endSheet:[self window]];
}

- (void)ratioChange:(NSNotification *)notification
{
    [percentTxf setFloatValue:[[notification object] ratio] * 100];
}

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
	[percentTxf setFloatValue:percentage];
	return YES;
}

@end
