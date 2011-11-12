/*
 * CC3OpenGLES11StateTracker.m
 *
 * cocos3d 0.6.3
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
#import "CC3OpenGLES11Engine.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTracker

@implementation CC3OpenGLES11StateTracker

@synthesize parent;

-(void) dealloc {
	parent = nil;			// not retained
	[super dealloc];
}

-(CC3OpenGLES11StateTracker*) parent { return parent; }

-(CC3OpenGLES11Engine*) engine { return parent.engine; }

-(id) init {
	return [self initWithParent: nil];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [super init]) ) {
		parent = aTracker;
		isScheduledForClose = NO;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	return [[[self alloc] initWithParent: aTracker] autorelease];
}

-(void) open {}

-(void) close {
	isScheduledForClose = NO;
}

-(void) notifyTrackerAdded {
	[self.engine addTrackerToOpen: self];
}

-(void) notifyGLChanged {
	if (!isScheduledForClose) {
		isScheduledForClose = YES;
		[self.engine addTrackerToClose: self];
	}
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@", [self class]];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPrimitive

@interface CC3OpenGLES11StateTrackerPrimitive (TemplateMethods)
-(void) logGetGLValue;
-(void) logSetValue;
-(void) logReuseValue;
@end

@implementation CC3OpenGLES11StateTrackerPrimitive

@synthesize name, originalValueHandling, valueIsKnown;

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	originalValueHandling = origValueHandling;
	self.valueIsKnown = NO;
} 

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueIgnore;
}

-(BOOL) shouldAlwaysReadOriginal {
	return name && (originalValueHandling == kCC3GLESStateOriginalValueReadAlways ||
					originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore);
}

-(BOOL) shouldRestoreOriginalOnClose {
	return (originalValueHandling == kCC3GLESStateOriginalValueReadOnceAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueRestore);
}

-(BOOL) valueIsKnownOnClose {
	return originalValueHandling != kCC3GLESStateOriginalValueIgnore;
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	return [self initWithParent: aTracker forState: 0];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName {
	return [self initWithParent: aTracker
					   forState: aName
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName {
	return [[[self alloc] initWithParent: aTracker forState: aName] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker]) ) {
		self.name = aName;
		self.originalValueHandling = origValueHandling;
		[self notifyTrackerAdded];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [[[self alloc] initWithParent: aTracker
								forState: aName
				andOriginalValueHandling: origValueHandling] autorelease];
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
				valueIsKnown = YES;
				LogGLErrorState(@"opening %@", self);
			} else {
				valueIsKnown = NO;
			}
			break;
		case kCC3GLESStateOriginalValueRestore:
			[self restoreOriginalValue];
			valueIsKnown = YES;
			break;
		default:
			NSAssert3(NO, @"%@ bad original value handling definition %u for capability %@",
					  self, originalValueHandling, NSStringFromGLEnum(name));
			break;
	}
}

-(void) close {
	[super close];
	if (self.shouldRestoreOriginalOnClose) {
		[self restoreOriginalValue];
		[self setGLValue];
	}
	valueIsKnown = self.valueIsKnownOnClose;
}

-(void) restoreOriginalValue {}

-(void) setGLValueAndNotify {
	[self setGLValue];
	[self notifyGLChanged];
	valueIsKnown = YES;
	[self logSetValue];
}

-(void) getGLValue {}

-(void) setGLValue {}

-(void) logSetValue: (BOOL) wasSet {}

-(void) logSetValue {}

-(void) logReuseValue {}

-(void) logGetGLValue {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", [self class], NSStringFromGLEnum(self.name)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerBoolean

@implementation CC3OpenGLES11StateTrackerBoolean

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc {
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker
							  forState: aName
			  andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	 return [[[self alloc] initWithParent: aTracker
								 forState: aName
						 andGLSetFunction: setGLFunc
				 andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (BOOL) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (BOOL) aValue {
	value = aValue;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value ? 1 : 0);
	}
}

-(void) getGLValue {
	GLboolean glValue;
	glGetBooleanv(name, &glValue);
	originalValue = (glValue != 0);
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %@", [self class], NSStringFromGLEnum(name), (value ? @"YES" : @"NO"));
}

-(void) logReuseValue: (BOOL) wasSet {
	LogTrace("%@ reused %@ = %@", [self class], NSStringFromGLEnum(name), (value ? @"YES" : @"NO"));
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), (originalValue ? @"YES" : @"NO"),
			 (valueIsKnown ? (value ? @"YES" : @"NO") : @"UNKNOWN"));
}

-(void) restoreOriginalValue {
	value = originalValue;
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

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), (originalValue ? @"ENABLED" : @"DISABLED"),
			 (valueIsKnown ? (value ? @"ENABLED" : @"DISABLED") : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %@", [self class],
			 NSStringFromGLEnum(name), (value ? @"ENABLED" : @"DISABLED"));
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %@", [self class],
			 NSStringFromGLEnum(name), (value ? @"ENABLED" : @"DISABLED"));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFloat

@implementation CC3OpenGLES11StateTrackerFloat

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker
							  forState: aName
			  andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (GLfloat) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (GLfloat) aValue {
	value = aValue;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value);
	}
}

-(void) getGLValue {
	glGetFloatv(name, &originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %.2f (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%.2f", value] : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %.2f", [self class], NSStringFromGLEnum(name), value);
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %.2f", [self class], NSStringFromGLEnum(name), value);
}

-(void) restoreOriginalValue {
	value = originalValue;
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

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker
							  forState: aName
			  andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (GLint) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (GLint) aValue {
	value = aValue;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value);
	}
}

-(void) getGLValue {
	glGetIntegerv(name, &originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %i (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%i", value] : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %i", [self class], NSStringFromGLEnum(name), value);
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %i", [self class], NSStringFromGLEnum(name), value);
}

-(void) restoreOriginalValue {
	value = originalValue;
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

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker
							  forState: aName
			  andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (GLenum) aValue {
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (GLenum) aValue {
	value = aValue;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value);
	}
}

-(void) getGLValue {
	glGetIntegerv(name, (GLint*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), NSStringFromGLEnum(originalValue),
			 (valueIsKnown ? NSStringFromGLEnum(value) : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromGLEnum(value));
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromGLEnum(value));
}

-(void) restoreOriginalValue {
	value = originalValue;
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

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker
							  forState: aName
			  andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (ccColor4F) aColor {
	if (!valueIsKnown || !CCC4FAreEqual(aColor, value)) {
		value = aColor;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (ccColor4F) aValue {
	value = aValue;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value.r, value.g, value.b, value.a);
	}
}

-(void) getGLValue {
	glGetFloatv(name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCCC4F(originalValue),
			 (valueIsKnown ? NSStringFromCCC4F(value) : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCCC4F(value));
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCCC4F(value));
}

-(void) restoreOriginalValue {
	value = originalValue;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
				[super description], NSStringFromCCC4F(self.value), NSStringFromCCC4F(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerColorFixedAndFloat

@interface CC3OpenGLES11StateTrackerColorFixedAndFloat (TemplateMethods)
-(void) logSetFixedValue;
-(void) logReuseFixedValue;
@end

@implementation CC3OpenGLES11StateTrackerColorFixedAndFloat

@synthesize fixedValue, setGLFunctionFixed;

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
		  andGLSetFunctionFixed: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
		  andGLSetFunctionFixed: setGLFuncFixed
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
  andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	// cast setGLFunc & setGLFuncFixed to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				   andGLSetFunctionFixed: (void*)setGLFuncFixed] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker
							  forState: aName
					  andGLSetFunction: setGLFunc
			  andOriginalValueHandling: origValueHandling]) ) {
		setGLFunctionFixed = setGLFuncFixed;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
  andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				   andGLSetFunctionFixed: setGLFuncFixed
				andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (ccColor4F) aColor {
	if (!valueIsKnown || !CCC4FAreEqual(aColor, value)) {
		value = aColor;
		[self setGLValueAndNotify];
		fixedValueIsKnown = NO;
	} else {
		[self logReuseValue];
	}	
}

-(void) setFixedValue: (ccColor4B) aColor {
	if (!fixedValueIsKnown || fixedValue.r != aColor.r || fixedValue.g != aColor.g
		|| fixedValue.b != aColor.b || fixedValue.a != aColor.a) {
		fixedValue = aColor;
		[self setGLFixedValue];
		[self notifyGLChanged];
		fixedValueIsKnown = YES;
		valueIsKnown = NO;
		[self logSetFixedValue];
	} else {
		[self logReuseFixedValue];
	}	
}

-(void) setFixedValueRaw: (ccColor4B) aValue {
	fixedValue = aValue;
}

-(void) setGLFixedValue {
	if( setGLFunctionFixed ) {
		setGLFunctionFixed(fixedValue.r, fixedValue.g, fixedValue.b, fixedValue.a);
	}
}

-(void) logSetFixedValue {
	LogTrace("%@ set %@ = (%u, %u, %u, %u)", [self class],
			 NSStringFromGLEnum(name), fixedValue.r, fixedValue.g, fixedValue.b, fixedValue.a);
}

-(void) logReuseFixedValue {
	LogTrace("%@ reuse %@ = (%u, %u, %u, %u)", [self class],
			 NSStringFromGLEnum(name), fixedValue.r, fixedValue.g, fixedValue.b, fixedValue.a);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerViewport

@implementation CC3OpenGLES11StateTrackerViewport

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	if ( (self = [super initWithParent: aTracker
							  forState: aName
			  andOriginalValueHandling: origValueHandling]) ) {
		setGLFunction = setGLFunc;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				andOriginalValueHandling: origValueHandling] autorelease];
}

-(void) setValue: (CC3Viewport) aViewport {
	if (!valueIsKnown || !CC3ViewportsAreEqual(aViewport, value)) {
		value = aViewport;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (CC3Viewport) aValue {
	value = aValue;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(value.x, value.y, value.w, value.h);
	}
}

-(void) getGLValue {
	glGetIntegerv(name, (GLint*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCC3Viewport(originalValue),
			 (valueIsKnown ? NSStringFromCC3Viewport(value) : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCC3Viewport(value));
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCC3Viewport(value));
}

-(void) restoreOriginalValue {
	value = originalValue;
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
	if (!valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (GLvoid*) aValue {
	value = aValue;
}

-(void) getGLValue {
	glGetIntegerv(name, (GLint*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %p (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%p", value] : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %p", [self class], NSStringFromGLEnum(name), value);
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %p", [self class], NSStringFromGLEnum(name), value);
}

-(void) restoreOriginalValue {
	value = originalValue;
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
	if (!valueIsKnown || !CC3VectorsAreEqual(aVector, value)) {
		value = aVector;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (CC3Vector) aValue {
	value = aValue;
}

-(void) getGLValue {
	glGetFloatv(name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector(originalValue),
			 (valueIsKnown ? NSStringFromCC3Vector(value) : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector(value));
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector(value));
}

-(void) restoreOriginalValue {
	value = originalValue;
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
	if (!valueIsKnown || !CC3Vector4sAreEqual(aVector, value)) {
		value = aVector;
		[self setGLValueAndNotify];
	} else {
		[self logReuseValue];
	}	
}

-(void) setValueRaw: (CC3Vector4) aValue {
	value = aValue;
}

-(void) getGLValue {
	glGetFloatv(name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector4(originalValue),
			 (valueIsKnown ? NSStringFromCC3Vector4(value) : @"UNKNOWN"));
}

-(void) logSetValue {
	LogTrace("%@ set %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector4(value));
}

-(void) logReuseValue {
	LogTrace("%@ reuse %@ = %@", [self class], NSStringFromGLEnum(name), NSStringFromCC3Vector4(value));
}

-(void) restoreOriginalValue {
	value = originalValue;
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

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
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

-(BOOL) valueIsKnownOnClose {
	return originalValueHandling != kCC3GLESStateOriginalValueIgnore;
}

-(BOOL) shouldRestoreOriginalOnClose {
	return (originalValueHandling == kCC3GLESStateOriginalValueReadOnceAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueRestore);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerManager

@implementation CC3OpenGLES11StateTrackerManager

-(void) initializeTrackers {}

-(id) initMinimalWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	return [super initWithParent: aTracker];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		[self initializeTrackers];
	}
	return self;
}

@end
