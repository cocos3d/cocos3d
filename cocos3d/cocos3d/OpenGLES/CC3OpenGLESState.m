/*
 * CC3OpenGLESState.m
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
 * See header file CC3OpenGLESState.h for full API documentation.
 */

#import "CC3OpenGLESState.h"


@interface CC3OpenGLESStateTrackerEnumeration (TemplateMethods)
-(void) setValueRaw:(GLenum) value;
@end

@interface CC3OpenGLESStateTrackerInteger (TemplateMethods)
-(void) setValueRaw:(GLint) value;
@end

@interface CC3OpenGLESStateTrackerFloat (TemplateMethods)
-(void) setValueRaw:(GLfloat) value;
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerStencilFunction

@implementation CC3OpenGLESStateTrackerStencilFunction

@synthesize function, reference, mask;

-(void) dealloc {
	[function release];
	[reference release];
	[mask release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.function = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																 forState: GL_STENCIL_FUNC];
	self.reference = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
															  forState: GL_STENCIL_REF];
	self.mask = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
														 forState: GL_STENCIL_VALUE_MASK];
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueIgnore;
}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	function.originalValueHandling = origValueHandling;
	reference.originalValueHandling = origValueHandling;
	mask.originalValueHandling = origValueHandling;
	[super setOriginalValueHandling: origValueHandling];
} 

-(BOOL) valueIsKnown {
	return function.valueIsKnown &&
			reference.valueIsKnown &&
			mask.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	function.valueIsKnown = aBoolean;
	reference.valueIsKnown = aBoolean;
	mask.valueIsKnown = aBoolean;
}

-(void) applyFunction: (GLenum) func
		 andReference: (GLint) refValue
			  andMask: (GLuint) maskValue {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= (!function.valueIsKnown || func != function.value);
	shouldSetGL |= (!reference.valueIsKnown || refValue != reference.value);
	shouldSetGL |= (!mask.valueIsKnown || maskValue != mask.value);
	if (shouldSetGL) {
		[function setValueRaw: func];
		[reference setValueRaw: refValue];
		[mask setValueRaw: maskValue];
		[self setGLValues];
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
	LogGLErrorTrace(@"while setting GL values for %@", self);
}

-(void) setGLValues { glStencilFunc(function.value, reference.value, mask.value); }

-(BOOL) valueNeedsRestoration {
	return (function.valueNeedsRestoration || reference.valueNeedsRestoration || mask.valueNeedsRestoration);
}

-(void) restoreOriginalValues {
	[function restoreOriginalValue];
	[reference restoreOriginalValue];
	[mask restoreOriginalValue];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:\n\t    %@\n\t    %@\n\t    %@",
			[self class], function, reference, mask];
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerStencilOperation

@implementation CC3OpenGLESStateTrackerStencilOperation

@synthesize stencilFail, depthFail, depthPass;

-(void) dealloc {
	[stencilFail release];
	[depthFail release];
	[depthPass release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.stencilFail = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_STENCIL_FAIL];
	self.depthFail = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																  forState: GL_STENCIL_PASS_DEPTH_FAIL];
	self.depthPass = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																  forState: GL_STENCIL_PASS_DEPTH_PASS];
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueIgnore;
}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	stencilFail.originalValueHandling = origValueHandling;
	depthFail.originalValueHandling = origValueHandling;
	depthPass.originalValueHandling = origValueHandling;
	[super setOriginalValueHandling: origValueHandling];
} 

-(BOOL) valueIsKnown {
	return stencilFail.valueIsKnown &&
			depthFail.valueIsKnown &&
			depthPass.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	stencilFail.valueIsKnown = aBoolean;
	depthFail.valueIsKnown = aBoolean;
	depthPass.valueIsKnown = aBoolean;
}

-(void) applyStencilFail: (GLenum) failOp
			andDepthFail: (GLenum) zFailOp
			andDepthPass: (GLenum) zPassOp {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= (!stencilFail.valueIsKnown || failOp != stencilFail.value);
	shouldSetGL |= (!depthFail.valueIsKnown || zFailOp != depthFail.value);
	shouldSetGL |= (!depthPass.valueIsKnown || zPassOp != depthPass.value);
	if (shouldSetGL) {
		[stencilFail setValueRaw: failOp];
		[depthFail setValueRaw: zFailOp];
		[depthPass setValueRaw: zPassOp];
		[self setGLValues];
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
	LogGLErrorTrace(@"while setting GL values for %@", self);
}

-(void) setGLValues { glStencilOp(stencilFail.value, depthFail.value, depthPass.value); }

-(BOOL) valueNeedsRestoration {
	return (stencilFail.valueNeedsRestoration || depthFail.valueNeedsRestoration || depthPass.valueNeedsRestoration);
}

-(void) restoreOriginalValues {
	[stencilFail restoreOriginalValue];
	[depthFail restoreOriginalValue];
	[depthPass restoreOriginalValue];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:\n\t    %@\n\t    %@\n\t    %@",
			[self class], stencilFail, depthFail, depthPass];
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerPolygonOffset

@implementation CC3OpenGLESStateTrackerPolygonOffset

@synthesize factor, units;

-(void) dealloc {
	[factor release];
	[units release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.factor = [CC3OpenGLESStateTrackerFloat trackerWithParent: self
														 forState: GL_POLYGON_OFFSET_FACTOR];
	self.units = [CC3OpenGLESStateTrackerFloat trackerWithParent: self
														forState: GL_POLYGON_OFFSET_UNITS];
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	factor.originalValueHandling = origValueHandling;
	units.originalValueHandling = origValueHandling;
	[super setOriginalValueHandling: origValueHandling];
} 

-(BOOL) valueIsKnown {
	return factor.valueIsKnown && units.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	factor.valueIsKnown = aBoolean;
	units.valueIsKnown = aBoolean;
}

-(void) applyFactor: (GLfloat) factorValue andUnits: (GLfloat) unitsValue {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= (!factor.valueIsKnown || factorValue != factor.value);
	shouldSetGL |= (!units.valueIsKnown || unitsValue != units.value);
	if (shouldSetGL) {
		[factor setValueRaw: factorValue];
		[units setValueRaw: unitsValue];
		[self setGLValues];
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
	LogGLErrorTrace(@"while setting GL values for %@", self);
}

-(void) setGLValues { glPolygonOffset(factor.value, units.value); }

-(BOOL) valueNeedsRestoration { return (factor.valueNeedsRestoration || units.valueNeedsRestoration); }

-(void) restoreOriginalValues {
	[factor restoreOriginalValue];
	[units restoreOriginalValue];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:\n\t    %@\n\t    %@", [self class], factor, units];
}

@end


#pragma mark -
#pragma mark CC3OpenGLESState

@implementation CC3OpenGLESState

@synthesize clearColor;
@synthesize clearDepth;
@synthesize clearStencil;
@synthesize color;
@synthesize colorMask;
@synthesize cullFace;
@synthesize depthFunction;
@synthesize depthMask;
@synthesize frontFace;
@synthesize lineWidth;
@synthesize pointSize;
@synthesize pointSizeAttenuation;
@synthesize pointSizeFadeThreshold;
@synthesize pointSizeMaximum;
@synthesize pointSizeMinimum;
@synthesize polygonOffset;
@synthesize scissor;
@synthesize shadeModel;
@synthesize stencilFunction;
@synthesize stencilOperation;
@synthesize viewport;

-(void) dealloc {
	[clearColor release];
	[clearDepth release];
	[clearStencil release];
	[color release];
	[colorMask release];
	[cullFace release];
	[depthFunction release];
	[depthMask release];
	[frontFace release];
	[lineWidth release];
	[pointSize release];
	[pointSizeAttenuation release];
	[pointSizeFadeThreshold release];
	[pointSizeMaximum release];
	[pointSizeMinimum release];
	[polygonOffset release];
	[scissor release];
	[shadeModel release];
	[stencilFunction release];
	[stencilOperation release];
	[viewport release];

	[super dealloc];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", clearColor];
	[desc appendFormat: @"\n    %@ ", clearDepth];
	[desc appendFormat: @"\n    %@ ", clearStencil];
	[desc appendFormat: @"\n    %@ ", color];
	[desc appendFormat: @"\n    %@ ", colorMask];
	[desc appendFormat: @"\n    %@ ", cullFace];
	[desc appendFormat: @"\n    %@ ", depthFunction];
	[desc appendFormat: @"\n    %@ ", depthMask];
	[desc appendFormat: @"\n    %@ ", frontFace];
	[desc appendFormat: @"\n    %@ ", lineWidth];
	[desc appendFormat: @"\n    %@ ", pointSize];
	[desc appendFormat: @"\n    %@ ", pointSizeAttenuation];
	[desc appendFormat: @"\n    %@ ", pointSizeFadeThreshold];
	[desc appendFormat: @"\n    %@ ", pointSizeMaximum];
	[desc appendFormat: @"\n    %@ ", pointSizeMinimum];
	[desc appendFormat: @"\n    %@ ", polygonOffset];
	[desc appendFormat: @"\n    %@ ", scissor];
	[desc appendFormat: @"\n    %@ ", shadeModel];
	[desc appendFormat: @"\n    %@ ", stencilFunction];
	[desc appendFormat: @"\n    %@ ", stencilOperation];
	[desc appendFormat: @"\n    %@ ", viewport];
	return desc;
}

-(void) clearBuffers: (GLbitfield) mask { glClear(mask); }

-(void) clearColorBuffer { [self clearBuffers: GL_COLOR_BUFFER_BIT]; }

-(void) clearDepthBuffer { [self clearBuffers: GL_DEPTH_BUFFER_BIT]; }

-(void) clearStencilBuffer { [self clearBuffers: GL_STENCIL_BUFFER_BIT]; }

-(ccColor4B) readPixelAt: (CGPoint) pixelPosition {
	ccColor4B pixColor;
	glReadPixels((GLint)pixelPosition.x, (GLint)pixelPosition.y,
				 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &pixColor);
	return pixColor;
}

@end
