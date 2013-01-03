/*
 * CC3OpenGLESCapabilities.m
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
 * See header file CC3OpenGLESCapabilities.h for full API documentation.
 */

#import "CC3OpenGLESCapabilities.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerCapability

@implementation CC3OpenGLESStateTrackerCapability

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) enable { self.value = YES; }

-(void) disable { self.value = NO; }

-(void) setGLValue {
	if (name) {
		if (value)
			glEnable(name);
		else
			glDisable(name);
	}
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@ = %@ (orig %@)",
			[self class], NSStringFromGLEnum(self.name),
			(self.value ? @"ENABLED" : @"DISABLED"), (self.originalValue ? @"ENABLED" : @"DISABLED")];
}

@end


#pragma mark -
#pragma mark CC3OpenGLESCapabilities

@implementation CC3OpenGLESCapabilities

@synthesize alphaTest;
@synthesize blend;
@synthesize clipPlanes;
@synthesize colorLogicOp;
@synthesize colorMaterial;
@synthesize cullFace;
@synthesize depthTest;
@synthesize dither;
@synthesize fog;
@synthesize lighting;
@synthesize lineSmooth;
@synthesize matrixPalette;
@synthesize multisample;
@synthesize normalize;
@synthesize pointSmooth;
@synthesize pointSprites;
@synthesize polygonOffsetFill;
@synthesize rescaleNormal;
@synthesize sampleAlphaToCoverage;
@synthesize sampleAlphaToOne;
@synthesize sampleCoverage;
@synthesize scissorTest;
@synthesize stencilTest;

-(void) dealloc {
	[alphaTest release];
	[blend release];
	[clipPlanes release];
	[colorLogicOp release];
	[colorMaterial release];
	[cullFace release];
	[depthTest release];
	[dither release];
	[fog release];
	[lighting release];
	[lineSmooth release];
	[matrixPalette release];
	[multisample release];
	[normalize release];
	[pointSmooth release];
	[pointSprites release];
	[polygonOffsetFill release];
	[rescaleNormal release];
	[sampleAlphaToCoverage release];
	[sampleAlphaToOne release];
	[sampleCoverage release];
	[scissorTest release];
	[stencilTest release];

	[super dealloc];
}

-(CC3OpenGLESStateTrackerCapability*) clipPlaneAt: (GLint) cpIndx {
	return [clipPlanes objectAtIndex: cpIndx];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 1000];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", alphaTest];
	[desc appendFormat: @"\n    %@ ", blend];
	for (id t in clipPlanes) {
		[desc appendFormat: @"\n    %@ ", t];
	}
	[desc appendFormat: @"\n    %@ ", colorLogicOp];
	[desc appendFormat: @"\n    %@ ", colorMaterial];
	[desc appendFormat: @"\n    %@ ", cullFace];
	[desc appendFormat: @"\n    %@ ", depthTest];
	[desc appendFormat: @"\n    %@ ", dither];
	[desc appendFormat: @"\n    %@ ", fog];
	[desc appendFormat: @"\n    %@ ", lighting];
	[desc appendFormat: @"\n    %@ ", lineSmooth];
	[desc appendFormat: @"\n    %@ ", matrixPalette];
	[desc appendFormat: @"\n    %@ ", multisample];
	[desc appendFormat: @"\n    %@ ", normalize];
	[desc appendFormat: @"\n    %@ ", pointSmooth];
	[desc appendFormat: @"\n    %@ ", pointSprites];
	[desc appendFormat: @"\n    %@ ", polygonOffsetFill];
	[desc appendFormat: @"\n    %@ ", rescaleNormal];
	[desc appendFormat: @"\n    %@ ", sampleAlphaToCoverage];
	[desc appendFormat: @"\n    %@ ", sampleAlphaToOne];
	[desc appendFormat: @"\n    %@ ", sampleCoverage];
	[desc appendFormat: @"\n    %@ ", scissorTest];
	[desc appendFormat: @"\n    %@ ", stencilTest];

	return desc;
}

@end
