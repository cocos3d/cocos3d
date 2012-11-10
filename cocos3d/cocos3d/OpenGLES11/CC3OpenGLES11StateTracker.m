/*
 * CC3OpenGLES11StateTracker.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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

-(void) close { isScheduledForClose = NO; }

-(void) notifyTrackerAdded { [self.engine addTrackerToOpen: self]; }

-(void) notifyGLChanged {
	if (!isScheduledForClose) {
		isScheduledForClose = YES;
		[self.engine addTrackerToClose: self];
	}
}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPrimitive

@implementation CC3OpenGLES11StateTrackerPrimitive

@synthesize name, valueIsKnown, shouldAlwaysSetGL;

-(CC3GLESStateOriginalValueHandling) originalValueHandling { return originalValueHandling; }

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

+(BOOL) defaultShouldAlwaysSetGL { return NO; }

-(BOOL) shouldAlwaysReadOriginal {
	return name && (originalValueHandling == kCC3GLESStateOriginalValueReadAlways ||
					originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore);
}

-(BOOL) shouldRestoreOriginalOnClose {
	return (originalValueHandling == kCC3GLESStateOriginalValueReadOnceAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueRestore) && self.valueNeedsRestoration;
}

-(BOOL) valueNeedsRestoration {
	NSAssert1(NO, @"%@ does must implement the valueNeedsRestoration property.", self);
	return NO;
}

-(BOOL) valueIsKnownOnClose { return originalValueHandling != kCC3GLESStateOriginalValueIgnore; }

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
		self.shouldAlwaysSetGL = [[self class] defaultShouldAlwaysSetGL];
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
			[self readOriginalValue];
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
		LogGLErrorTrace(@"while setting GL value for %@", self);
	}
	valueIsKnown = self.valueIsKnownOnClose;
}

-(void) readOriginalValue {
	if (name) {
		LogTrace(@"Getting GL value for %@", self);
		[self getGLValue];
		LogGLErrorTrace(@"while getting GL value for %@", self);
		LogTrace(@"Retrieved GL value for %@", self);
		[self restoreOriginalValue];
		valueIsKnown = YES;
	} else {
		valueIsKnown = NO;
	}
}

-(void) restoreOriginalValue {}

-(void) setGLValueAndNotify {
	LogTrace(@"Setting GL value for %@", self);
	[self setGLValue];
	LogGLErrorTrace(@"while setting GL value for %@", self);
	[self notifyGLChanged];
	valueIsKnown = YES;
}

-(void) getGLValue {}

-(void) setGLValue {}

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
	if (shouldAlwaysSetGL || !valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (BOOL) aValue { value = aValue; }

-(void) setGLValue { if(setGLFunction) setGLFunction(value ? GL_TRUE : GL_FALSE); }

-(void) getGLValue {
	GLboolean glValue;
	glGetBooleanv(name, &glValue);
	originalValue = (glValue != GL_FALSE);
}

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return (value != originalValue); }

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

-(void) enable { self.value = YES; }

-(void) disable { self.value = NO; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@ = %@ (orig %@)",
			[self class], NSStringFromGLEnum(self.name),
			(self.value ? @"ENABLED" : @"DISABLED"), (self.originalValue ? @"ENABLED" : @"DISABLED")];
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
	if (shouldAlwaysSetGL || !valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (GLfloat) aValue { value = aValue; }

-(void) setGLValue { if(setGLFunction) setGLFunction(value); }

-(void) getGLValue { glGetFloatv(name, &originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return (value != originalValue); }

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
	if (shouldAlwaysSetGL || !valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (GLint) aValue { value = aValue; }

-(void) setGLValue { if(setGLFunction) setGLFunction(value); }

-(void) getGLValue { glGetIntegerv(name, &originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return (value != originalValue); }

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
	if (shouldAlwaysSetGL || !valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (GLenum) aValue { value = aValue; }

-(void) setGLValue { if(setGLFunction) setGLFunction(value); }

-(void) getGLValue { glGetIntegerv(name, (GLint*)&originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return (value != originalValue); }

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
	if (shouldAlwaysSetGL || !valueIsKnown || !CCC4FAreEqual(aColor, value)) {
		value = aColor;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (ccColor4F) aValue { value = aValue; }

-(void) setGLValue { if(setGLFunction) setGLFunction(value.r, value.g, value.b, value.a); }

-(void) getGLValue { glGetFloatv(name, (GLfloat*)&originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return !CCC4FAreEqual(value, originalValue); }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
				[super description], NSStringFromCCC4F(self.value), NSStringFromCCC4F(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerColorFixedAndFloat

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
	if (shouldAlwaysSetGL || !valueIsKnown || !CCC4FAreEqual(aColor, value)) {
		value = aColor;
		[self setGLValueAndNotify];
		fixedValueIsKnown = NO;
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setFixedValue: (ccColor4B) aColor {
	if (!fixedValueIsKnown ||
		fixedValue.r != aColor.r ||
		fixedValue.g != aColor.g ||
		fixedValue.b != aColor.b || 
		fixedValue.a != aColor.a) {

		fixedValue = aColor;
		LogTrace(@"Setting fixed GL value for %@", self);
		[self setGLFixedValue];
		LogGLErrorTrace(@"while setting fixed GL value for %@", self);
		[self notifyGLChanged];
		fixedValueIsKnown = YES;
		valueIsKnown = NO;
	} else {
		LogTrace(@"Reusing fixed GL value for %@", self);
	}
}

-(void) setFixedValueRaw: (ccColor4B) aValue { fixedValue = aValue; }

-(void) setGLFixedValue { if( setGLFunctionFixed ) setGLFunctionFixed(fixedValue.r, fixedValue.g, fixedValue.b, fixedValue.a); }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (as byte color %@)", [super description], NSStringFromCCC4B(fixedValue)];
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
	if (shouldAlwaysSetGL || !valueIsKnown || !CC3ViewportsAreEqual(aViewport, value)) {
		value = aViewport;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (CC3Viewport) aValue { value = aValue; }

-(void) setGLValue { if( setGLFunction ) setGLFunction(value.x, value.y, value.w, value.h); }

-(void) getGLValue { glGetIntegerv(name, (GLint*)&originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return !CC3ViewportsAreEqual(value, originalValue); }

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
	if (shouldAlwaysSetGL || !valueIsKnown || aValue != value) {
		value = aValue;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (GLvoid*) aValue { value = aValue; }

-(void) getGLValue { glGetIntegerv(name, (GLint*)&originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return (value != originalValue); }

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
	if (shouldAlwaysSetGL || !valueIsKnown || !CC3VectorsAreEqual(aVector, value)) {
		value = aVector;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self);
	}
}

-(void) setValueRaw: (CC3Vector) aValue { value = aValue; }

-(void) getGLValue { glGetFloatv(name, (GLfloat*)&originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return !CC3VectorsAreEqual(value, originalValue); }

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
	if (shouldAlwaysSetGL || !valueIsKnown || !CC3Vector4sAreEqual(aVector, value)) {
		value = aVector;
		[self setGLValueAndNotify];
	} else {
		LogTrace(@"Reusing GL value for %@", self); 
	}
}

-(void) setValueRaw: (CC3Vector4) aValue { value = aValue; }

-(void) getGLValue { glGetFloatv(name, (GLfloat*)&originalValue); }

-(void) restoreOriginalValue { value = originalValue; }

-(BOOL) valueNeedsRestoration { return !CC3Vector4sAreEqual(value, originalValue); }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ = %@ (orig %@)",
			[super description], NSStringFromCC3Vector4(self.value), NSStringFromCC3Vector4(self.originalValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerComposite

@implementation CC3OpenGLES11StateTrackerComposite

@synthesize shouldAlwaysSetGL;

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		[self initializeTrackers];
		self.shouldAlwaysSetGL = [[self class] defaultShouldAlwaysSetGL];
		self.originalValueHandling = [[self class] defaultOriginalValueHandling];
	}
	return self;
}

-(void) initializeTrackers {}

-(CC3GLESStateOriginalValueHandling) originalValueHandling { return originalValueHandling; }

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

+(BOOL) defaultShouldAlwaysSetGL { return NO; }

-(void) setGLValues {}

-(BOOL) valueIsKnown { return NO; }

-(void) setValueIsKnown:(BOOL) aBoolean {}

-(BOOL) valueIsKnownOnClose { return originalValueHandling != kCC3GLESStateOriginalValueIgnore; }

-(void) close {
	[super close];
	if (self.shouldRestoreOriginalOnClose) {
		[self restoreOriginalValues];
		[self setGLValues];
		LogGLErrorTrace(@"while setting GL values for %@", self);
	}
	self.valueIsKnown = self.valueIsKnownOnClose;
}

-(BOOL) shouldRestoreOriginalOnClose {
	return (originalValueHandling == kCC3GLESStateOriginalValueReadOnceAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueReadAlwaysAndRestore ||
			originalValueHandling == kCC3GLESStateOriginalValueRestore) && self.valueNeedsRestoration;
}

-(BOOL) valueNeedsRestoration {
	NSAssert1(NO, @"%@ does must implement the valueNeedsRestoration property.", self);
	return NO;
}

-(void) restoreOriginalValues { NSAssert1(NO, @"%@ does must implement the restoreOriginalValues method.", self); }

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
