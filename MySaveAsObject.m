//
//  MySaveAsObject.m
//  JViewbt
//
//  Created by Allan on 4/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MySaveAsObject.h"

@interface MySaveAsObject (PrivateMethods)
+ (NSString *)extensionByFormat:(NSBitmapImageFileType)_foramt;
- (void)saveSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
@end


@implementation MySaveAsObject

- (id)initWithDocumentController:(MyDocumentController *)_controller
{
	if (self = [super init]) {
		controller = _controller;
		[NSBundle loadNibNamed:@"SaveAs" owner:self];
	}
	return self;
}

- (void)saveAs
{
    NSSavePanel *sp = [NSSavePanel savePanel];
	
	NSString *defaultName, *defaultDirectory, *filename = [controller filename];
	
	if ([filename isEqualToString:b_UNTITLED]) {
		defaultDirectory = [[NSApp delegate] mostRecentPath];
		defaultName = b_UNTITLED;
	} else {
		defaultDirectory = [filename stringByDeletingLastPathComponent];
		defaultName = [[filename lastPathComponent] stringByDeletingPathExtension]; // no need the extension, the extension will be added later
		
		//defaultName = [[[filename lastPathComponent] stringByDeletingPathExtension]
		//	stringByAppendingPathExtension:[MySaveAsObject extensionByFormat:df_SAVEAS_FORMAT]];
	}

    [self fileTypeChanged:fileTypeBtn]; // needed for setting the options for each type, not the file extension
	[fileTypeBtn selectItemAtIndex:[fileTypeBtn indexOfItemWithTag:df_SAVEAS_FORMAT]];
	
	[sizeMatrix selectCellWithTag:df_SAVEAS_SIZE];
	[compressionMatrix selectCellWithTag:df_SAVEAS_COMPRESSION];
	[interlacedBtn setState:df_SAVEAS_INTERLACE];
	[imageQualitySlider setFloatValue:df_SAVEAS_QUALITY];

    [sp setAccessoryView:saveUtilityView];
	
    [sp beginSheetForDirectory:defaultDirectory file:defaultName modalForWindow:[controller window] modalDelegate:self
        didEndSelector:@selector(saveSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

+ (NSString *)extensionByFormat:(NSBitmapImageFileType)_foramt
{
    switch(_foramt) {
        case NSTIFFFileType:
            return @"tiff";
        /*case NSBMPFileType:
            return @"bmp";
        case NSGIFFileType:
            return @"gif";*/
        case NSJPEGFileType:
            return @"jpg";
        case NSPNGFileType:
            return @"png";
        default:
            return @"jpg";
    }
}

- (IBAction)fileTypeChanged:(id)sender
{
    int tag = [[sender selectedItem] tag];
	
    NSSavePanel *panel = (NSSavePanel *)[[controller window] attachedSheet];

    [imageQualitySlider setEnabled:NO];
    [compressionMatrix setEnabled:NO];
    [interlacedBtn setEnabled:NO];
	
    switch(tag) {
        case 0: // tiff
            [compressionMatrix setEnabled:YES];
            break;
        /*case 1: // bmp
            break;
        case 2: // gif
            [dither setEnabled:YES];
            break;*/
        case 3: // jpeg
            [imageQualitySlider setEnabled:YES];
            break;
        case 4: // png
            [interlacedBtn setEnabled:YES];
            break;
    }
    [panel setRequiredFileType:[MySaveAsObject extensionByFormat:tag]];
}

- (void)saveSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton) {
	
        NSData *data;
        NSString *filename = [(NSSavePanel *)sheet filename];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		
		// get user defaults
		df_SAVEAS_FORMAT = [[fileTypeBtn selectedItem] tag];
		df_SAVEAS_SIZE = [[sizeMatrix selectedCell] tag];
		df_SAVEAS_COMPRESSION = [[compressionMatrix selectedCell] tag];
		df_SAVEAS_QUALITY = [imageQualitySlider floatValue];
		df_SAVEAS_INTERLACE = [interlacedBtn state];
		
		switch (df_SAVEAS_SIZE) {
		
			case 1: // original size
				data = [controller currentImageData:NO originalSize:YES];
				break;
			case 2: // visible area
				data = [controller currentImageData:YES originalSize:NO];
				break;
			default: // current size
				data = [controller currentImageData:NO originalSize:NO];
				break;
		}
		
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:data];
		NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
		
        switch (df_SAVEAS_FORMAT) {
            case 0: // tiff
				[attributes setObject:[NSNumber numberWithInt:df_SAVEAS_COMPRESSION] forKey:NSImageCompressionMethod];
                break;
            /*case 2: // gif
                [attributes setObject:[NSNumber numberWithBool:[dither state]] forKey:NSImageDitherTransparency];
                break;*/
            case 3: // jpeg
				[attributes setObject:[NSNumber numberWithFloat:df_SAVEAS_QUALITY] forKey:NSImageCompressionFactor];
                break;
            case 4: // png
				[attributes setObject:[NSNumber numberWithBool:df_SAVEAS_INTERLACE] forKey:NSImageInterlaced];
                break;
        }
		data = [rep representationUsingType:df_SAVEAS_FORMAT properties:attributes];
		
		filename = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:[MySaveAsObject extensionByFormat:df_SAVEAS_FORMAT]];
        
        if (!data || ![data writeToFile:filename atomically:YES]) {
            NSRunAlertPanel(b_SAVE_FAILED, b_OPERATION_FAILED, b_OK, nil, nil);
        } else {
			
			// reset navigator
			[controller setNavigator:[imageCache navigatorForImageData:data filePath:filename]];
        }
		
		// set user defaults
		[userDefaults setInteger:df_SAVEAS_FORMAT forKey:@"df_SAVEAS_FORMAT"];
		[userDefaults setBool:df_SAVEAS_SIZE forKey:@"df_SAVEAS_SIZE"];
		[userDefaults setInteger:df_SAVEAS_COMPRESSION forKey:@"df_SAVEAS_COMPRESSION"];
		[userDefaults setFloat:df_SAVEAS_QUALITY forKey:@"df_SAVEAS_QUALITY"];
		[userDefaults setBool:df_SAVEAS_INTERLACE forKey:@"df_SAVEAS_INTERLACE"];
    }
    [sheet close];
}

@end
