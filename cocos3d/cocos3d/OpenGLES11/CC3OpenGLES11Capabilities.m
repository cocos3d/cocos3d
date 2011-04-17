/*
 * CC3OpenGLES11Capabilities.m
 *
 * cocos3d 0.5.4
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
 * See header file CC3OpenGLES11Capabilities.h for full API documentation.
 */

#import "CC3OpenGLES11Capabilities.h"
#import "CC3OpenGLES11Engine.h"


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
#pragma mark CC3OpenGLES11StateTrackerServerCapability

@implementation CC3OpenGLES11StateTrackerServerCapability

-(void) setGLValue {
	if (value) {
		glEnable(name);
	} else {
		glDisable(name);
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerClientCapability

@implementation CC3OpenGLES11StateTrackerClientCapability

-(void) setGLValue {
	if (value) {
		glEnableClientState(name);
	} else {
		glDisableClientState(name);
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11ServerCapabilities

@implementation CC3OpenGLES11ServerCapabilities

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
@synthesize lights;
@synthesize lineSmooth;
@synthesize multisample;
@synthesize normalize;
@synthesize pointSmooth;
@synthesize pointSpriteOES;
@synthesize polygonOffsetFill;
@synthesize rescaleNormal;
@synthesize sampleAlphaToCoverage;
@synthesize sampleAlphaToOne;
@synthesize sampleCoverage;
@synthesize scissorTest;
@synthesize stencilTest;
@synthesize texture2D;

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
	[lights release];
	[lineSmooth release];
	[multisample release];
	[normalize release];
	[pointSmooth release];
	[pointSpriteOES release];
	[polygonOffsetFill release];
	[rescaleNormal release];
	[sampleAlphaToCoverage release];
	[sampleAlphaToOne release];
	[sampleCoverage release];
	[scissorTest release];
	[stencilTest release];
	[texture2D release];
	[super dealloc];
}

-(CC3OpenGLES11StateTrackerServerCapability*) clipPlaneAt: (GLint) cpIndx {
	return [clipPlanes objectAtIndex: cpIndx];
}

-(CC3OpenGLES11StateTrackerServerCapability*) lightAt: (GLint) ltIndx {
	return [lights objectAtIndex: ltIndx];
}

-(void) initializeTrackers {
	self.alphaTest = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_ALPHA_TEST];
	self.blend = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_BLEND];
	self.clipPlanes = [NSMutableArray array];
	
	GLint platformMaxClipPlanes = [CC3OpenGLES11Engine engine].platform.maxClipPlanes.value;
	for (int i = 0; i < platformMaxClipPlanes; i++) {
		[clipPlanes addObject: [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_CLIP_PLANE0 + i]];
	}

	self.colorLogicOp = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_COLOR_LOGIC_OP];
	self.colorMaterial = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_COLOR_MATERIAL];
	self.cullFace = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_CULL_FACE];
	self.depthTest = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_DEPTH_TEST];
	self.dither = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_DITHER];
	self.fog = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_FOG];
	self.lighting = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_LIGHTING];
	self.lights = [NSMutableArray array];

	GLint platformMaxLights = [CC3OpenGLES11Engine engine].platform.maxLights.value;
	for (int i = 0; i < platformMaxLights; i++) {
		[lights addObject: [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_LIGHT0 + i]];
	}

	self.lineSmooth = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_LINE_SMOOTH];
	self.multisample = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_MULTISAMPLE];
	self.normalize = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_NORMALIZE];
	self.pointSmooth = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_POINT_SMOOTH];

	// Illegal GL enum when trying to read value of GL_POINT_SPRITE_OES.
	self.pointSpriteOES = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_POINT_SPRITE_OES
															andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	self.polygonOffsetFill = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_POLYGON_OFFSET_FILL];
	self.rescaleNormal = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_RESCALE_NORMAL];
	self.sampleAlphaToCoverage = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_SAMPLE_ALPHA_TO_COVERAGE];
	self.sampleAlphaToOne = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_SAMPLE_ALPHA_TO_ONE];
	self.sampleCoverage = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_SAMPLE_COVERAGE];
	self.scissorTest = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_SCISSOR_TEST];
	self.stencilTest = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_STENCIL_TEST];
	self.texture2D = [CC3OpenGLES11StateTrackerServerCapability trackerForState: GL_TEXTURE_2D];
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[alphaTest open];
	[blend open];
	[self openTrackers: clipPlanes];
	[colorLogicOp open];
	[colorMaterial open];
	[cullFace open];
	[depthTest open];
	[dither open];
	[fog open];
	[lighting open];
	[self openTrackers: lights];
	[lineSmooth open];
	[multisample open];
	[normalize open];
	[pointSmooth open];
	[pointSpriteOES open];
	[polygonOffsetFill open];
	[rescaleNormal open];
	[sampleAlphaToCoverage open];
	[sampleAlphaToOne open];
	[sampleCoverage open];
	[scissorTest open];
	[stencilTest open];
	[texture2D open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[alphaTest close];
	[blend close];
	[self closeTrackers: clipPlanes];
	[colorLogicOp close];
	[colorMaterial close];
	[cullFace close];
	[depthTest close];
	[dither close];
	[fog close];
	[lighting close];
	[self closeTrackers: lights];
	[lineSmooth close];
	[multisample close];
	[normalize close];
	[pointSmooth close];
	[pointSpriteOES close];
	[polygonOffsetFill close];
	[rescaleNormal close];
	[sampleAlphaToCoverage close];
	[sampleAlphaToOne close];
	[sampleCoverage close];
	[scissorTest close];
	[stencilTest close];
	[texture2D close];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11ClientCapabilities

@implementation CC3OpenGLES11ClientCapabilities

@synthesize colorArray;
@synthesize normalArray;
@synthesize pointSizeArrayOES;
@synthesize textureCoordArray;
@synthesize vertexArray;

-(void) dealloc {
	[colorArray release];
	[normalArray release];
	[pointSizeArrayOES release];
	[textureCoordArray release];
	[vertexArray release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.colorArray = [CC3OpenGLES11StateTrackerClientCapability trackerForState: GL_COLOR_ARRAY];
	self.normalArray = [CC3OpenGLES11StateTrackerClientCapability trackerForState: GL_NORMAL_ARRAY];
	self.pointSizeArrayOES = [CC3OpenGLES11StateTrackerClientCapability trackerForState: GL_POINT_SIZE_ARRAY_OES];
	self.textureCoordArray = [CC3OpenGLES11StateTrackerClientCapability trackerForState: GL_TEXTURE_COORD_ARRAY];
	self.vertexArray = [CC3OpenGLES11StateTrackerClientCapability trackerForState: GL_VERTEX_ARRAY];
}	

-(void) open {
	LogTrace("Opening %@", [self class]);
	[colorArray open];
	[normalArray open];
	[pointSizeArrayOES open];
	[textureCoordArray open];
	[vertexArray open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[colorArray close];
	[normalArray close];
	[pointSizeArrayOES close];
	[textureCoordArray close];
	[vertexArray close];
}

@end
