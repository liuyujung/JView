//
//  SpUtil.m
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpUtil.h"

static SpUtil *util;


@implementation SpUtil

+ (id)sharedUtil
{
    if (!util) {
        util = [[SpUtil allocWithZone:[self zone]] init];
    }
    return util;
}

- (NSArray *)componentArrayWithColor:(NSColor *)_color
{
    NSColor *color = [_color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:4];
    [components addObject:[NSNumber numberWithFloat:[color alphaComponent]]];
    [components addObject:[NSNumber numberWithFloat:[color redComponent]]];
    [components addObject:[NSNumber numberWithFloat:[color greenComponent]]];
    [components addObject:[NSNumber numberWithFloat:[color blueComponent]]];
    return components;
}

- (NSColor *)colorWithComponentArray:(NSArray *)_components
{
    return [NSColor colorWithDeviceRed:[[_components objectAtIndex:1] floatValue]
                                 green:[[_components objectAtIndex:2] floatValue]
                                  blue:[[_components objectAtIndex:3] floatValue]
                                 alpha:[[_components objectAtIndex:0] floatValue]];
}

@end
