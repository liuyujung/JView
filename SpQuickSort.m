//
//  SpQuickSort.m
//  FileNavigator
//
//  Created by Allan Liu on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "SpQuickSort.h"
#import "SpFile.h"

@interface SpQuickSort (PrivateMethod)
- (void)quickSort:(NSMutableArray *)array start:(int)start end:(int)end;
- (int)partitionArray:(NSMutableArray *)array start:(int)start end:(int)end;
- (int)sortByFilename:(NSString *)string1 with:(NSString *)string2;
- (int)compareleft:(NSString *)string1 at:(int *)n1 with:(NSString *)string2 at:(int *)n2;
@end

static SpQuickSort *quickSort;


@implementation SpQuickSort

+ (id)sharedQuickSort
{
    if (!quickSort) {
        quickSort = [[SpQuickSort allocWithZone:[self zone]] init];
    }
    return quickSort;
}

- (void)shuffleArray:(NSMutableArray *)array
{
	int i, n, count = [array count];
    srand(time(NULL));
    for (i = 0; i < count; i++) {
        n = rand() % count;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)sortArray:(NSMutableArray *)array
{
    [self quickSort:array start:0 end:[array count]-1];
}

- (void)quickSort:(NSMutableArray *)array start:(int)start end:(int)end
{
    if (start < end) {
        int index = [self partitionArray:array start:start end:end];
        [self quickSort:array start:start end:index];
        [self quickSort:array start:index + 1 end:end];
    }
}

- (int)partitionArray:(NSMutableArray *)array start:(int)start end:(int)end
{
    NSString *x = [(SpFile *)[array objectAtIndex:start] fileName];
    int i = start - 1, j = end + 1;
    while (YES) {
        do {
            j--;
        } while ([self sortByFilename:[(SpFile *)[array objectAtIndex:j] fileName] with:x] == 1);
        do {
            i++;
        } while ([self sortByFilename:x with:[(SpFile *)[array objectAtIndex:i] fileName]] == 1);
        if (i < j) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:j];
        } else {
            return j;
        }
    }
}

- (int)sortByFilename:(NSString *)string1 with:(NSString *)string2
{
    int length1 = [string1 length], length2 = [string2 length], i, j;
    unichar c1, c2, r1, r2;
    
    for (i=0, j=0; i<length1 && j<length2; i++, j++) {
        c1 = [string1 characterAtIndex:i];
        c2 = [string2 characterAtIndex:j];
        if (isdigit(c1) && isdigit(c2)) {
            int result = [self compareleft:string1 at:&i with:string2 at:&j];
            if (result == 0) continue;
            return result;
        }
        r1 = isascii(c1) ? toupper(c1) : c1;
        r2 = isascii(c2) ? toupper(c2) : c2;
        if (r1 > r2) return 1;
        if (r1 < r2) return -1;
    }
    if (length1 == length2)  return 0;
    if (length1 > length2) return 1;
    return -1;
}

- (int)compareleft:(NSString *)string1 at:(int *)n1 with:(NSString *)string2 at:(int *)n2
{
    char s1[255], s2[255], c1, c2;
    int length1 = [string1 length], length2 = [string2 length], i = 0, j = 0, r1, r2;
    do {
        c1 = [string1 characterAtIndex:(*n1)];
        if (!isdigit(c1)) break;
        s1[i++] = c1;
        (*n1)++;
    } while ((*n1)<length1);
    do {
        c2 = [string2 characterAtIndex:(*n2)];
        if (!isdigit(c2)) break;
        s2[j++] = c2;
        (*n2)++;
    } while ((*n2)<length2);
    s1[i] = '\0';
    s2[j] = '\0';
    r1 = [[NSString stringWithUTF8String:s1] intValue];
    r2 = [[NSString stringWithUTF8String:s2] intValue];
    if (r1 > r2) return 1;
    if (r1 < r2) return -1;
    (*n1)--;
    (*n2)--;
    return 0;
}

@end
