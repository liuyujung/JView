//
//  main.m
//  JView
//
//  Created by Allan on Sat Feb 16 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyApplication.h"

int main(int argc, const char *argv[])
{
    //return NSApplicationMain(argc, argv);
	[MyApplication sharedApplication];
    [NSBundle loadNibNamed:@"JView" owner:NSApp];
    [NSApp run];
	return 0;
}
