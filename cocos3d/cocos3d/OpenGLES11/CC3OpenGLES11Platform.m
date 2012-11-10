/*
 * CC3OpenGLES11Platform.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLES11Platform.h for full API documentation.
 */

#import "CC3OpenGLES11Platform.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPlatformInteger

@implementation CC3OpenGLES11StateTrackerPlatformInteger

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnce;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Platform

@implementation CC3OpenGLES11Platform

@synthesize maxLights;
@synthesize maxClipPlanes;
@synthesize maxPaletteMatrices;
@synthesize maxTextureUnits;
@synthesize maxVertexUnits;
@synthesize maxPixelSamples;

-(void) dealloc {
	[maxLights release];
	[maxClipPlanes release];
	[maxPaletteMatrices release];
	[maxTextureUnits release];
	[maxVertexUnits release];
	[maxPixelSamples release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.maxLights = [CC3OpenGLES11StateTrackerPlatformInteger trackerWithParent: self
																forState: GL_MAX_LIGHTS];
	self.maxClipPlanes = [CC3OpenGLES11StateTrackerPlatformInteger trackerWithParent: self
																	forState: GL_MAX_CLIP_PLANES];
	self.maxPaletteMatrices = [CC3OpenGLES11StateTrackerPlatformInteger trackerWithParent: self
																		 forState: GL_MAX_PALETTE_MATRICES_OES];
	self.maxTextureUnits = [CC3OpenGLES11StateTrackerPlatformInteger trackerWithParent: self
																	  forState: GL_MAX_TEXTURE_UNITS];
	self.maxVertexUnits = [CC3OpenGLES11StateTrackerPlatformInteger trackerWithParent: self
																	 forState: GL_MAX_VERTEX_UNITS_OES];
	self.maxPixelSamples = [CC3OpenGLES11StateTrackerPlatformInteger trackerWithParent: self
																			  forState: GL_MAX_SAMPLES_APPLE];

	[self open];		// Automatically load the GL values at start-up
}

// Invoked during initialization to ensure that these values are loaded first
-(void) open {
	LogTrace(@"@Opening %@", [self class]);
	[maxLights open];
	[maxClipPlanes open];
	[maxPaletteMatrices open];
	[maxTextureUnits open];
	[maxVertexUnits open];
	[maxPixelSamples open];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", maxLights];
	[desc appendFormat: @"\n    %@ ", maxClipPlanes];
	[desc appendFormat: @"\n    %@ ", maxPaletteMatrices];
	[desc appendFormat: @"\n    %@ ", maxTextureUnits];
	[desc appendFormat: @"\n    %@ ", maxVertexUnits];
	[desc appendFormat: @"\n    %@ ", maxPixelSamples];
	return desc;
}

@end
