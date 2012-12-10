/*
 * CC3OpenGLESMaterials.m
 *
 * cocos3d 2.0.0
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
 * See header file CC3OpenGLESMaterials.h for full API documentation.
 */

#import "CC3OpenGLESMaterials.h"


@interface CC3OpenGLESStateTrackerEnumeration (TemplateMethods)
-(void) setValueRaw:(GLenum) value;
@end

@interface CC3OpenGLESStateTrackerFloat (TemplateMethods)
-(void) setValueRaw:(GLfloat) value;
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerMaterialBlend

@implementation CC3OpenGLESStateTrackerMaterialBlend

@synthesize sourceBlend, destinationBlend;

-(void) dealloc {
	[sourceBlend release];
	[destinationBlend release];
	[super dealloc];
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	sourceBlend.originalValueHandling = origValueHandling;
	destinationBlend.originalValueHandling = origValueHandling;
	[super setOriginalValueHandling: origValueHandling];
} 

-(BOOL) valueIsKnown { return sourceBlend.valueIsKnown && destinationBlend.valueIsKnown; }

-(void) setValueIsKnown:(BOOL) aBoolean {
	sourceBlend.valueIsKnown = aBoolean;
	destinationBlend.valueIsKnown = aBoolean;
}

-(void) applySource: (GLenum) srcBlend andDestination: (GLenum) dstBlend {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= (!sourceBlend.valueIsKnown || srcBlend != sourceBlend.value);
	shouldSetGL |= (!destinationBlend.valueIsKnown || dstBlend != destinationBlend.value);
	if (shouldSetGL) {
		[sourceBlend setValueRaw: srcBlend];
		[destinationBlend setValueRaw: dstBlend];
		[self setGLValues];
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
	LogGLErrorTrace(@"while setting GL values for %@", self);
}

-(void) setGLValues { glBlendFunc(sourceBlend.value, destinationBlend.value); }

-(BOOL) valueNeedsRestoration {
	return (sourceBlend.valueNeedsRestoration || destinationBlend.valueNeedsRestoration);
}

-(void) restoreOriginalValues {
	[sourceBlend restoreOriginalValue];
	[destinationBlend restoreOriginalValue];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:\n    %@\n    %@", [self class], sourceBlend, destinationBlend];
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerAlphaFunction

@implementation CC3OpenGLESStateTrackerAlphaFunction

@synthesize function, reference;

-(void) dealloc {
	[function release];
	[reference release];
	[super dealloc];
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	function.originalValueHandling = origValueHandling;
	reference.originalValueHandling = origValueHandling;
	[super setOriginalValueHandling: origValueHandling];
} 

-(BOOL) valueIsKnown { return function.valueIsKnown && reference.valueIsKnown; }

-(void) setValueIsKnown:(BOOL) aBoolean {
	function.valueIsKnown = aBoolean;
	reference.valueIsKnown = aBoolean;
}

-(void) applyFunction: (GLenum) func andReference: (GLfloat) refValue {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= (!function.valueIsKnown || func != function.value);
	shouldSetGL |= (!reference.valueIsKnown || refValue != reference.value);
	if (shouldSetGL) {
		[function setValueRaw: func];
		[reference setValueRaw: refValue];
		[self setGLValues];
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
	LogGLErrorTrace(@"while setting GL values for %@", self);
}

-(BOOL) valueNeedsRestoration {
	return (function.valueNeedsRestoration || reference.valueNeedsRestoration);
}

-(void) restoreOriginalValues {
	[function restoreOriginalValue];
	[reference restoreOriginalValue];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:\n    %@\n    %@", [self class], function, reference];
}

@end


#pragma mark -
#pragma mark CC3OpenGLESMaterials

@implementation CC3OpenGLESMaterials

@synthesize ambientColor;
@synthesize diffuseColor;
@synthesize specularColor;
@synthesize emissionColor;
@synthesize shininess;
@synthesize alphaFunc;
@synthesize blendFunc;

-(void) dealloc {
	[ambientColor release];
	[diffuseColor release];
	[specularColor release];
	[emissionColor release];
	[shininess release];
	[alphaFunc release];
	[blendFunc release];
	[super dealloc];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", ambientColor];
	[desc appendFormat: @"\n    %@ ", diffuseColor];
	[desc appendFormat: @"\n    %@ ", specularColor];
	[desc appendFormat: @"\n    %@ ", emissionColor];
	[desc appendFormat: @"\n    %@ ", shininess];
	[desc appendFormat: @"\n    %@ ", alphaFunc];
	[desc appendFormat: @"\n    %@ ", blendFunc];
	return desc;
}

@end
