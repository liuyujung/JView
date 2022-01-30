#import "BgColorWell.h"

@implementation BgColorWell

- (void)activate:(BOOL)exclusive
{
	[[NSColorPanel sharedColorPanel] setTitle:df_SLIDE_BG_COLOR_TITLE];
    [[NSColorPanel sharedColorPanel] makeKeyAndOrderFront:self];
}

@end
