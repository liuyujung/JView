//
//  SpImageUtil.m
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpImageUtil.h"

#import <Math.h>

static SpImageUtil *imageUtil;


@implementation SpImageUtil

+ (id)sharedImageUtil
{
    if (!imageUtil) {
        imageUtil = [[SpImageUtil allocWithZone:[self zone]] init];
    }
    return imageUtil;
}

- (NSImage *)imageWithFilename:(NSString *)_filename
{
    return [self imageWithData:[NSData dataWithContentsOfFile:_filename]];
}

// for copy and paste
- (NSImage *)imageWithData:(NSData *)_data
{
    NSImage *image = [[NSImage alloc] initWithData:_data];
    if (image) {
        if (![[image representations] count]) {
            NSMutableData *data = [NSMutableData dataWithData:_data];
            unsigned char *pointer = (unsigned char *)[_data bytes];
            unsigned char eoi = 0xd9;
            if (pointer[[_data length] - 1] == 0xff) {
                [data appendBytes:&eoi length:1];
            } else {
                unsigned char ff = 0xff;
                [data appendBytes:&ff length:1];
                [data appendBytes:&eoi length:1];
            }
            [image release];
            image = [[NSImage alloc] initWithData:data];
            if (image) {
                if (![[image representations] count]) {
                    [image release];
                    return nil;
                }
            } else return nil;
        }
        return [image autorelease];
    }
    return nil;
}

- (float)nextZoomRatioWithRatio:(float)_currentRatio zoomIn:(BOOL)_in
{
	float currentPosition = log10f(_currentRatio * 100 * 2.2361) / 0.209;
	//float nextPosition = _in ? ceilf(currentPosition) : floorf(currentPosition);
	float nextPosition = _in ? currentPosition + 0.209: currentPosition - 0.209;
	float ratio = roundf(pow(1.61803, nextPosition) / 2.2361);
	if (ratio < 1) ratio = 1;
	return floor(ratio) / 100.0;
}

@end
