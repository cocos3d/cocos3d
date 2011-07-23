/*
 * CC3OpenGLES11StateTracker.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://en.wikipedia.org/wiki/MIT_License
 * 
 * See header file CC3OpenGLES11StateTracker.h for full API documentation.
 */

#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTracker

@implementation CC3OpenGLES11StateTracker

+(id) tracker {
	return [[[self alloc] init] autorelease];
}

-(void) open {}

-(void) close {}

-(void) openTrackers: (NSArray*) trackers {
	for (CC3OpenGLES11StateTracker* t in trackers) {
		[t open];
	}
}

-(void) closeTrackers: (NSArray*) trackers {
	for (CC3OpenGLES11StateTracker* t in trackers) {
		[t close];
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPrimitive

@implementation CC3OpenGLES11StateTrackerPrimitive

@synthesize name, originalValueHandling, valueIsKnown;

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	originalValueHandling = origValueHandling;
	self.valueIsKnown = NO;
} 

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueIgnore;
}

-(id) init {
	return [self initForState: 0];
}

-(id) initForState: (GLenum) aName {
	return [self initForState: aName andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName {
	return [[[self alloc] initForState: aName] autorelease];
}

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super init]) ) {
		self.name = aName;
		self.originalValueHandling = origValueHandling;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [[[self alloc] initForState: aName andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) open {
	switch (originalValueHandling) {
		case kCC3GLESStateOriginalValueIgnore:
			valueIsKnown = NO;
			break;
		case kCC3GLESStateOriginalValueReadOnce:
		case kCC3GLESStateOriginalValueReadOnceAndRestore:
			if (valueIsKnown) break;
		case kCC3GLESStateOriginalValueReadAlways:
		case kCC3GLESStateOriginalValueReadAlwaysAndRestore:
			if (name) {
				[self getGLValue];
				[self logGetGLValue];
				[self restoreOriginalValue];
			} else {
				valueIsKnown = NO;
			}
			break;
		default:
			NSAssert3(NO, @"%@ bad original value handling definition %u for capability %@",
					  self, originalValueHandling, NSStringFromGLEnum(name));
			break;
	}
}

-(void) close {
	if (originalValueHandling == kCC3GLESStateOriginalValueReadOnceAndRestore ||
		originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore) {
		[self restoreOriginalValue];
	}
}

-(void) restoreOriginalValue {}

-(void) getGLValue {}

-(void) logGetGLValue {}

-(void) setGLValue {}

-(void) logSetValue: (BOOL) wasSet {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", [self class], NSStringFromGLEnum(self.name)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerBoolean

@implementation CC3OpenGLES11StateTrackerBoolean

@synthesize value, originalValue, setGLFunction;

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initForState: aName
			 andGLSetFunction: NULL
	 andOriginalValueHandling: origValueHandling];
}

-(id) initForState: (GLenum) aName andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc {
	return [self initForState: aName
			 andGLSetFunction: setGLFunc
	 andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc {
	return [[[self alloc] initForState: aName andGLSetFunction: setGLFunc] autorelease];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initForState: aName andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	 return [[[self alloc] initForState: aName
					   andGLSetFunction: setGLFunc
			   andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (BOOL) aValue {
	BOOL wasSet = [self attemptSetValue: aValue];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (BOOL) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value ? 1 : 0);
	}
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), (value ? @"YES" : @"NO"));
}

-(void) getGLValue {
	GLboolean glValue;
	glGetBooleanv(name, &glValue);
	originalValue = (glValue != 0);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), (originalValue ? @"YES" : @"NO"),
			 (valueIsKnown ? (value ? @"YES" : @"NO") : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)", [super description],
				NSStringFromBoolean(self.value), NSStringFromBoolean(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerCapability

@implementation CC3OpenGLES11StateTrackerCapability

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) enable {
	self.value = YES;
}

-(void) disable {
	self.value = NO;
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), (value ? @"ENABLED" : @"DISABLED"));
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), (originalValue ? @"ENABLED" : @"DISABLED"),
			 (valueIsKnown ? (value ? @"ENABLED" : @"DISABLED") : @"UNKNOWN"));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFloat

@implementation CC3OpenGLES11StateTrackerFloat

@synthesize value, originalValue, setGLFunction;

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initForState: aName
			 andGLSetFunction: NULL
	 andOriginalValueHandling: origValueHandling];
}

-(id) initForState: (GLenum) aName andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc {
	return [self initForState: aName
			 andGLSetFunction: setGLFunc
	 andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initForState: aName andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName
					  andGLSetFunction: (void*)setGLFunc
			  andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (GLfloat) aValue {
	BOOL wasSet = [self attemptSetValue: aValue];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (GLfloat) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value);
	}
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %.2f", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), value);
}

-(void) getGLValue {
	glGetFloatv(name, &originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %.2f (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%.2f", value] : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %.3f (orig %.3f)",
			[super description], self.value, self.originalValue];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerInteger

@implementation CC3OpenGLES11StateTrackerInteger

@synthesize value, originalValue, setGLFunction;

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initForState: aName
			 andGLSetFunction: NULL
	 andOriginalValueHandling: origValueHandling];
}

-(id) initForState: (GLenum) aName andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc {
	return [self initForState: aName
			 andGLSetFunction: setGLFunc
	 andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initForState: aName andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName
					  andGLSetFunction: (void*)setGLFunc
			  andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (GLint) aValue {
	BOOL wasSet = [self attemptSetValue: aValue];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (GLint) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value);
	}
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %i", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), value);
}

-(void) getGLValue {
	glGetIntegerv(name, &originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %i (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%i", value] : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %i (orig %i)",
				[super description], self.value, self.originalValue];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerEnumeration

@implementation CC3OpenGLES11StateTrackerEnumeration

@synthesize value, originalValue, setGLFunction;

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initForState: aName
			 andGLSetFunction: NULL
	 andOriginalValueHandling: origValueHandling];
}

-(id) initForState: (GLenum) aName andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc {
	return [self initForState: aName
			 andGLSetFunction: setGLFunc
	 andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initForState: aName andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName
					  andGLSetFunction: (void*)setGLFunc
			  andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (GLenum) aValue {
	BOOL wasSet = [self attemptSetValue: aValue];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (GLenum) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value);
	}
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), NSStringFromGLEnum(value));
}

-(void) getGLValue {
	glGetIntegerv(name, (GLint*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), NSStringFromGLEnum(originalValue),
			 (valueIsKnown ? NSStringFromGLEnum(value) : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
				[super description], NSStringFromGLEnum(self.value), NSStringFromGLEnum(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerColor

@implementation CC3OpenGLES11StateTrackerColor

@synthesize value, originalValue, setGLFunction;

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initForState: aName
			 andGLSetFunction: NULL
	 andOriginalValueHandling: origValueHandling];
}

-(id) initForState: (GLenum) aName andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc {
	return [self initForState: aName
			 andGLSetFunction: setGLFunc
	 andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initForState: aName andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName
					  andGLSetFunction: (void*)setGLFunc
			  andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (ccColor4F) aColor {
	BOOL wasSet = [self attemptSetValue: aColor];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (ccColor4F) aColor {
	if (!valueIsKnown || !CCC4FAreEqual(aColor, value)) {
		value = aColor;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value.r, value.g, value.b, value.a);
	}
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), NSStringFromCCC4F(value));
}

-(void) getGLValue {
	glGetFloatv(name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCCC4F(originalValue),
			 (valueIsKnown ? NSStringFromCCC4F(value) : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
				[super description], NSStringFromCCC4F(self.value), NSStringFromCCC4F(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerColorFixedAndFloat

@implementation CC3OpenGLES11StateTrackerColorFixedAndFloat

@synthesize fixedValue, setGLFunctionFixed;

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initForState: aName
			 andGLSetFunction: NULL
		andGLSetFunctionFixed: NULL
	 andOriginalValueHandling: origValueHandling];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	return [self initForState: aName
			 andGLSetFunction: setGLFunc
		andGLSetFunctionFixed: setGLFuncFixed
	 andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	// cast setGLFunc & setGLFuncFixed to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName
					  andGLSetFunction: (void*)setGLFunc
				 andGLSetFunctionFixed: (void*)setGLFuncFixed] autorelease];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initForState: aName
					andGLSetFunction: setGLFunc
			andOriginalValueHandling: origValueHandling]) ) {
		setGLFunctionFixed = setGLFuncFixed;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName
					  andGLSetFunction: (void*)setGLFunc
				 andGLSetFunctionFixed: setGLFuncFixed
			  andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setFixedValue: (ccColor4B) aColor {
	BOOL wasSet = [self attemptSetFixedValue: aColor];
	[self logSetFixedValue: wasSet];
}

-(BOOL) attemptSetValue: (ccColor4F) aColor {
	BOOL wasSet = [super attemptSetValue: aColor];
	if (wasSet) {
		fixedValueIsKnown = NO;
	}
	return wasSet;
}

-(BOOL) attemptSetFixedValue: (ccColor4B) aColor {
	if (!fixedValueIsKnown || fixedValue.r != aColor.r || fixedValue.g != aColor.g
						   || fixedValue.b != aColor.b || fixedValue.a != aColor.a) {
		fixedValue = aColor;
		fixedValueIsKnown = YES;
		valueIsKnown = NO;
		[self setGLFixedValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) setGLFixedValue {
	if( setGLFunctionFixed ) {
		setGLFunctionFixed(fixedValue.r, fixedValue.g, fixedValue.b, fixedValue.a);
	}
}

-(void) logSetFixedValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = (%u, %u, %u, %u)", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), fixedValue.r, fixedValue.g, fixedValue.b, fixedValue.a);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerViewport

@implementation CC3OpenGLES11StateTrackerViewport

@synthesize value, originalValue, setGLFunction;

-(id) initForState: (GLenum) aName andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initForState: aName
			 andGLSetFunction: NULL
	 andOriginalValueHandling: origValueHandling];
}

-(id) initForState: (GLenum) aName andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc {
	return [self initForState: aName
			 andGLSetFunction: setGLFunc
	 andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerForState: (GLenum) aName andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initForState: (GLenum) aName
  andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initForState: aName andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerForState: (GLenum) aName
	 andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initForState: aName
					  andGLSetFunction: (void*)setGLFunc
			  andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (CC3Viewport) aViewport {
	BOOL wasSet = [self attemptSetValue: aViewport];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (CC3Viewport) aViewport {
	if (!valueIsKnown || !CC3ViewportsAreEqual(aViewport, value)) {
		value = aViewport;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value.x, value.y, value.w, value.h);
	}
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), NSStringFromCC3Viewport(value));
}

-(void) getGLValue {
	glGetIntegerv(name, (GLint*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCC3Viewport(originalValue),
			 (valueIsKnown ? NSStringFromCC3Viewport(value) : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
			[super description], NSStringFromCC3Viewport(self.value), NSStringFromCC3Viewport(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPointer

@implementation CC3OpenGLES11StateTrackerPointer

@synthesize value, originalValue;

-(void) setValue: (GLvoid*) aValue {
	BOOL wasSet = [self attemptSetValue: aValue];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (GLvoid*) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %p", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), value);
}

-(void) getGLValue {
	glGetIntegerv(name, (GLint*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %p (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%p", value] : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %p (orig %p)",
			[super description], self.value, self.originalValue];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVector

@implementation CC3OpenGLES11StateTrackerVector

@synthesize value, originalValue;

-(void) setValue: (CC3Vector) aVector {
	BOOL wasSet = [self attemptSetValue: aVector];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (CC3Vector) aVector {
	if (!valueIsKnown || !CC3VectorsAreEqual(aVector, value)) {
		value = aVector;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), NSStringFromCC3Vector(value));
}

-(void) getGLValue {
	glGetFloatv(name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector(originalValue),
			 (valueIsKnown ? NSStringFromCC3Vector(value) : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
			[super description], NSStringFromCC3Vector(self.value), NSStringFromCC3Vector(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVector4

@implementation CC3OpenGLES11StateTrackerVector4

@synthesize value, originalValue;

-(void) setValue: (CC3Vector4) aVector {
	BOOL wasSet = [self attemptSetValue: aVector];
	[self logSetValue: wasSet];
}

-(BOOL) attemptSetValue: (CC3Vector4) aVector {
	if (!valueIsKnown || !CC3Vector4sAreEqual(aVector, value)) {
		value = aVector;
		valueIsKnown = YES;
		[self setGLValue];
		return YES;
	} else {
		return NO;
	}	
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), NSStringFromCC3Vector4(value));
}

-(void) getGLValue {
	glGetFloatv(name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector4(originalValue),
			 (valueIsKnown ? NSStringFromCC3Vector4(value) : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	self.value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
			[super description], NSStringFromCC3Vector4(self.value), NSStringFromCC3Vector4(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerComposite

@implementation CC3OpenGLES11StateTrackerComposite

@synthesize originalValueHandling, shouldAlwaysSetGL;

-(id) init {
	if ( (self = [super init]) ) {
		[self initializeTrackers];
		self.shouldAlwaysSetGL = [[self class] defaultShouldAlwaysSetGL];
		self.originalValueHandling = [[self class] defaultOriginalValueHandling];
	}
	return self;
}

-(void) initializeTrackers {}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	originalValueHandling = origValueHandling;
	self.valueIsKnown = NO;
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueIgnore;
}

-(void) setShouldAlwaysSetGL: (BOOL) aBoolean {
	shouldAlwaysSetGL = aBoolean;
	self.valueIsKnown = NO;
}

+(BOOL) defaultShouldAlwaysSetGL {
	return NO;
}

-(BOOL) valueIsKnown {
	return NO;
}

-(void) setValueIsKnown:(BOOL) aBoolean {}

-(void) close {
	if (originalValueHandling == kCC3GLESStateOriginalValueReadOnceAndRestore ||
		originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore) {
		[self restoreOriginalValue];
	}
}

-(void) restoreOriginalValue {}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerManager

@implementation CC3OpenGLES11StateTrackerManager

-(void) initializeTrackers {}

-(id) initMinimal {
	return [super init];
}

-(id) init {
	if ( (self = [super init]) ) {
		[self initializeTrackers];
	}
	return self;
}

@end
