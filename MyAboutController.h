/* MyAboutController */

#import <Cocoa/Cocoa.h>

@interface MyAboutController : NSWindowController
{
    IBOutlet NSTextField *titleTxf;
    IBOutlet NSTextField *copyrightTxf;
    IBOutlet NSTextField *emailTxf;
    NSString *auther;
    NSString *title;
    NSString *copyright;
    NSString *email;
}

+ (id)sharedAboutPanel;

@end
