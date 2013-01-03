/*
 * CC3OpenGLES2Platform.m
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

#import "CC3OpenGLES2Platform.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLES2Platform

@implementation CC3OpenGLES2Platform

-(void) initializeTrackers {
	self.maxLights = [CC3OpenGLESStateTrackerPlatformInteger trackerWithParent: self
													  andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.maxLights.originalValue = kCC3MaxGL2Lights;

	self.maxClipPlanes = [CC3OpenGLESStateTrackerPlatformInteger trackerWithParent: self
														  andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.maxClipPlanes.originalValue = kCC3MaxGL2ClipPlanes;
	
	self.maxPaletteMatrices = [CC3OpenGLESStateTrackerPlatformInteger trackerWithParent: self
															   andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.maxPaletteMatrices.originalValue = kCC3MaxGL2PaletteMatrices;
	
	self.maxTextureUnits = [CC3OpenGLESStateTrackerPlatformInteger trackerWithParent: self
															andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.maxTextureUnits.originalValue = kCC3MaxGL2TextureUnits;

	self.maxVertexAttributes = [CC3OpenGLESStateTrackerPlatformInteger trackerWithParent: self
																				forState: GL_MAX_VERTEX_ATTRIBS];
	
	self.maxVertexUnits = [CC3OpenGLESStateTrackerPlatformInteger trackerWithParent: self
														   andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.maxVertexUnits.originalValue = kCC3MaxGL2VertexUnits;
	
	self.maxPixelSamples = [CC3OpenGLESStateTrackerPlatformInteger trackerWithParent: self
																			forState: GL_MAX_SAMPLES_APPLE];
	
	[self open];		// Automatically load the GL values at start-up
}

@end

#endif
