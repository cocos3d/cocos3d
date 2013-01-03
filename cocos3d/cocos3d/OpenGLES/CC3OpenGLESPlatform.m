/*
 * CC3OpenGLESPlatform.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLESPlatform.h for full API documentation.
 */

#import "CC3OpenGLESPlatform.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerPlatformInteger

@implementation CC3OpenGLESStateTrackerPlatformInteger

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnce;
}

@end


#pragma mark -
#pragma mark CC3OpenGLESPlatform

@implementation CC3OpenGLESPlatform

@synthesize maxLights=_maxLights;
@synthesize maxClipPlanes=_maxClipPlanes;
@synthesize maxPaletteMatrices=_maxPaletteMatrices;
@synthesize maxTextureUnits=_maxTextureUnits;
@synthesize maxVertexAttributes=_maxVertexAttributes;
@synthesize maxVertexUnits=_maxVertexUnits;
@synthesize maxPixelSamples=_maxPixelSamples;

-(void) dealloc {
	[_maxLights release];
	[_maxClipPlanes release];
	[_maxPaletteMatrices release];
	[_maxTextureUnits release];
	[_maxVertexAttributes release];
	[_maxVertexUnits release];
	[_maxPixelSamples release];
	[super dealloc];
}

// Invoked during initialization to ensure that these values are loaded first
-(void) open {
	LogTrace(@"@Opening %@", [self class]);
	[_maxLights open];
	[_maxClipPlanes open];
	[_maxPaletteMatrices open];
	[_maxTextureUnits open];
	[_maxVertexAttributes open];
	[_maxVertexUnits open];
	[_maxPixelSamples open];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", _maxLights];
	[desc appendFormat: @"\n    %@ ", _maxClipPlanes];
	[desc appendFormat: @"\n    %@ ", _maxPaletteMatrices];
	[desc appendFormat: @"\n    %@ ", _maxTextureUnits];
	[desc appendFormat: @"\n    %@ ", _maxVertexAttributes];
	[desc appendFormat: @"\n    %@ ", _maxVertexUnits];
	[desc appendFormat: @"\n    %@ ", _maxPixelSamples];
	return desc;
}

@end
