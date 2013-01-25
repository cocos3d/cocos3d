/*
 * CC3OpenGLES2Capabilities.m
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

#import "CC3OpenGLES2Capabilities.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLES2Capabilities

@implementation CC3OpenGLES2Capabilities

-(void) initializeTrackers {
	self.alphaTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self];
	
	self.blend = [CC3OpenGLESStateTrackerCapability trackerWithParent: self forState: GL_BLEND];

	self.clipPlanes = nil;
	self.colorLogicOp = nil;
	self.colorMaterial = nil;
	
	self.cullFace = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																forState: GL_CULL_FACE];
	self.depthTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																 forState: GL_DEPTH_TEST];
	self.dither = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
															  forState: GL_DITHER];
	self.fog = [CC3OpenGLESStateTrackerCapability trackerWithParent: self];;

	self.lighting = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
												andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	self.lineSmooth = nil;
	self.matrixPalette = nil;
	self.multisample = nil;

	self.normalize = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
												 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.pointSmooth = [CC3OpenGLESStateTrackerCapability trackerWithParent: self];
	
	self.pointSprites = [CC3OpenGLESStateTrackerCapability trackerWithParent: self];
	
	self.polygonOffsetFill = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																		 forState: GL_POLYGON_OFFSET_FILL];
	self.rescaleNormal = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
													 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.sampleAlphaToCoverage = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																			 forState: GL_SAMPLE_ALPHA_TO_COVERAGE];
	self.sampleAlphaToOne = nil;
	
	self.sampleCoverage = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																	  forState: GL_SAMPLE_COVERAGE];
	self.scissorTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																   forState: GL_SCISSOR_TEST];
	self.stencilTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																   forState: GL_STENCIL_TEST];
}

@end

#endif


