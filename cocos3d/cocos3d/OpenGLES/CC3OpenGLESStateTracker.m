/*
 * CC3OpenGLESStateTracker.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLESStateTracker.h for full API documentation.
 */

#import "CC3OpenGLESStateTracker.h"
#import "CC3OpenGLESEngine.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTracker

@implementation CC3OpenGLESStateTracker

@synthesize parent;

-(void) dealloc {
	parent = nil;			// not retained
	[super dealloc];
}

-(CC3OpenGLESStateTracker*) parent { return parent; }

-(CC3OpenGLESEngine*) engine { return parent.engine; }

-(id) init { return [self initWithParent: nil]; }

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker {
	if ( (self = [super init]) ) {
		parent = aTracker;
		isScheduledForClose = NO;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker {
	return [[[self alloc] initWithParent: aTracker] autorelease];
}

-(void) open {}

-(void) close { isScheduledForClose = NO; }

-(void) notifyTrackerAdded {}

-(void) notifyGLChanged {
	if (!isScheduledForClose) isScheduledForClose = YES;
}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerPrimitive

@implementation CC3OpenGLESStateTrackerPrimitive

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
	CC3Assert(NO, @"%@ does not implement the valueNeedsRestoration property.", self);
	return NO;
}

-(BOOL) valueIsKnownOnClose { return originalValueHandling != kCC3GLESStateOriginalValueIgnore; }

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker {
	return [self initWithParent: aTracker forState: GL_ZERO];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName {
	return [self initWithParent: aTracker
					   forState: aName
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName {
	return [[[self alloc] initWithParent: aTracker forState: aName] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: GL_ZERO
	   andOriginalValueHandling: origValueHandling];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [[[self alloc] initWithParent: aTracker
				andOriginalValueHandling: origValueHandling] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
			CC3Assert(NO, @"%@ bad original value handling definition %u for capability %@",
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
#pragma mark CC3OpenGLESStateTrackerBoolean

@implementation CC3OpenGLESStateTrackerBoolean

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc {
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
#pragma mark CC3OpenGLESStateTrackerFloat

@implementation CC3OpenGLESStateTrackerFloat

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
#pragma mark CC3OpenGLESStateTrackerInteger

@implementation CC3OpenGLESStateTrackerInteger

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
#pragma mark CC3OpenGLESStateTrackerEnumeration

@implementation CC3OpenGLESStateTrackerEnumeration

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
#pragma mark CC3OpenGLESStateTrackerColor

@implementation CC3OpenGLESStateTrackerColor

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
#pragma mark CC3OpenGLESStateTrackerColorFixedAndFloat

@implementation CC3OpenGLESStateTrackerColorFixedAndFloat

@synthesize setGLFunctionFixed;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
		  andGLSetFunctionFixed: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
		  andGLSetFunctionFixed: setGLFuncFixed
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
  andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	// cast setGLFunc & setGLFuncFixed to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				   andGLSetFunctionFixed: (void*)setGLFuncFixed] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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

-(ccColor4F) value {
	if (valueIsKnown) return value;
	if (fixedValueIsKnown) return CCC4FFromCCC4B(fixedValue);
	return kCCC4FWhite;
}

-(ccColor4B) fixedValue {
	if (fixedValueIsKnown) return fixedValue;
	return CCC4BFromCCC4F(self.value);
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

/*
@implementation CC3OpenGLESStateTrackerColorFixedAndFloat

@synthesize fixedValue, setGLFunctionFixed;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
		  andGLSetFunctionFixed: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
		  andGLSetFunctionFixed: setGLFuncFixed
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
  andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed {
	// cast setGLFunc & setGLFuncFixed to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc
				   andGLSetFunctionFixed: (void*)setGLFuncFixed] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
*/

#pragma mark -
#pragma mark CC3OpenGLESStateTrackerViewport

@implementation CC3OpenGLESStateTrackerViewport

@synthesize value, originalValue, setGLFunction;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: NULL
	   andOriginalValueHandling: origValueHandling];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc {
	return [self initWithParent: aTracker
					   forState: aName
			   andGLSetFunction: setGLFunc
	   andOriginalValueHandling: [[self class] defaultOriginalValueHandling]];
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc {
	// cast setGLFunc to void to remove bogus compiler warning
	return [[[self alloc] initWithParent: aTracker
								forState: aName
						andGLSetFunction: (void*)setGLFunc] autorelease];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
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

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
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
#pragma mark CC3OpenGLESStateTrackerPointer

@implementation CC3OpenGLESStateTrackerPointer

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
#pragma mark CC3OpenGLESStateTrackerVector

@implementation CC3OpenGLESStateTrackerVector

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
#pragma mark CC3OpenGLESStateTrackerVector4

@implementation CC3OpenGLESStateTrackerVector4

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
#pragma mark CC3OpenGLESStateTrackerComposite

@implementation CC3OpenGLESStateTrackerComposite

@synthesize shouldAlwaysSetGL;

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		[self initializeTrackers];
		self.shouldAlwaysSetGL = [[self class] defaultShouldAlwaysSetGL];
		self.originalValueHandling = [[self class] defaultOriginalValueHandling];
	}
	return self;
}

-(id) initMinimalWithParent: (CC3OpenGLESStateTracker*) aTracker {
	return [super initWithParent: aTracker];
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
	CC3Assert(NO, @"%@ does must implement the valueNeedsRestoration property.", self);
	return NO;
}

-(void) restoreOriginalValues { CC3Assert(NO, @"%@ does must implement the restoreOriginalValues method.", self); }

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerManager

@implementation CC3OpenGLESStateTrackerManager

-(void) initializeTrackers {}

-(id) initMinimalWithParent: (CC3OpenGLESStateTracker*) aTracker {
	return [super initWithParent: aTracker];
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		[self initializeTrackers];
	}
	return self;
}

@end
