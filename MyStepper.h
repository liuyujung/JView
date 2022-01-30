/* MyStepper */

#import <Cocoa/Cocoa.h>

@interface MyStepper : NSStepper
{
	float originalValue;
}
- (float)currentValue:(float)_value;
@end
