#import "MyAboutController.h"

@implementation MyAboutController

- (id)init
{
    self = [super initWithWindowNibName:@"About"];
    if (self) {
        auther = @" Allan Liu";
        email = @"shopton@gmail.com";
        title = NSLocalizedStringFromTable(@"CFBundleShortVersionString", @"InfoPlist", @"JView version 2.x");
        copyright = NSLocalizedStringFromTable(@"NSHumanReadableCopyright", @"InfoPlist", @"Copyright 2007");
    }
    return self;
}

- (void)windowDidLoad
{
    [[self window] center];
    [titleTxf setStringValue:title];
    [copyrightTxf setStringValue:[copyright stringByAppendingString:auther]];
    [emailTxf setStringValue:email];
}

+ (id)sharedAboutPanel
{
    static MyAboutController *myAboutController = nil;
    if (!myAboutController)
        myAboutController = [[MyAboutController alloc] init];
    return myAboutController;
}

@end
