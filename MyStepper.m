#import "MyStepper.h"

@interface MyStepper (PrivateMethods)
- (BOOL)isIncrement;
@end

@implementation MyStepper

- (BOOL)isIncrement
{
	float value = [super floatValue];
	return (value > originalValue && !(value == [super maxValue] && originalValue == [super minValue]))
		|| (value == [super minValue] && originalValue == [super maxValue]);
}

- (float)currentValue:(float)_value
{
	float increment = [super increment];
	_value = _value + ([self isIncrement] ? increment : -increment);
	if (_value > [super maxValue]) {
		_value = [super minValue];
	} else if (_value < [super minValue]) {
		_value = [super maxValue];
	}
	originalValue = [super floatValue];
	return _value;
}

- (void)setIntValue:(int)_intValue
{
	originalValue = _intValue;
	[super setIntValue:_intValue];
}

- (void)setFloatValue:(float)_intValue
{
	originalValue = _intValue;
	[super setFloatValue:_intValue];
}

@end
