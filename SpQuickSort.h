//
//  SpQuickSort.h
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SpQuickSort : NSObject {

}

+ (id)sharedQuickSort;
- (void)sortArray:(NSMutableArray *)array;
- (void)shuffleArray:(NSMutableArray *)array;

@end
