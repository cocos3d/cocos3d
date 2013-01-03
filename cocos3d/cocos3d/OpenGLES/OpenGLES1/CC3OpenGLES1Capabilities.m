/*
 * CC3OpenGLES1Capabilities.m
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

#import "CC3OpenGLES1Capabilities.h"
#import "CC3OpenGLESEngine.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerClientCapability

@implementation CC3OpenGLES1StateTrackerClientCapability

-(void) setGLValue {
	if (value) {
		glEnableClientState(name);
	} else {
		glDisableClientState(name);
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1Capabilities

@implementation CC3OpenGLES1Capabilities

-(void) initializeTrackers {
	self.alphaTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																 forState: GL_ALPHA_TEST];
	self.blend = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
															 forState: GL_BLEND];
	self.clipPlanes = [CCArray array];
	GLint platformMaxClipPlanes = self.engine.platform.maxClipPlanes.value;
	for (int i = 0; i < platformMaxClipPlanes; i++) {
		[clipPlanes addObject: [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																				 forState: GL_CLIP_PLANE0 + i]];
	}
	
	self.colorLogicOp = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																	forState: GL_COLOR_LOGIC_OP];
	self.colorMaterial = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																	 forState: GL_COLOR_MATERIAL];
	self.cullFace = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																forState: GL_CULL_FACE];
	self.depthTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																 forState: GL_DEPTH_TEST];
	self.dither = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
															  forState: GL_DITHER];
	self.fog = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
														   forState: GL_FOG];
	self.lighting = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																forState: GL_LIGHTING];
	self.lineSmooth = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																  forState: GL_LINE_SMOOTH];
	
	// Crashes when attempting to read the GL value.
	self.matrixPalette = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																	 forState: GL_MATRIX_PALETTE_OES
													 andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.matrixPalette.originalValue = NO;		// Assume starts out disabled
	
	self.multisample = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																   forState: GL_MULTISAMPLE];
	self.normalize = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																 forState: GL_NORMALIZE];
	self.pointSmooth = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																   forState: GL_POINT_SMOOTH];
	
	// Illegal GL enum when trying to read GL value.
	self.pointSprites = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																	forState: GL_POINT_SPRITE_OES
													andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.pointSprites.originalValue = NO;		// Assume starts out disabled
	
	self.polygonOffsetFill = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																		 forState: GL_POLYGON_OFFSET_FILL];
	self.rescaleNormal = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																	 forState: GL_RESCALE_NORMAL];
	self.sampleAlphaToCoverage = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																			 forState: GL_SAMPLE_ALPHA_TO_COVERAGE];
	self.sampleAlphaToOne = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																		forState: GL_SAMPLE_ALPHA_TO_ONE];
	self.sampleCoverage = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																	  forState: GL_SAMPLE_COVERAGE];
	self.scissorTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																   forState: GL_SCISSOR_TEST];
	self.stencilTest = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
																   forState: GL_STENCIL_TEST];
}

@end

#endif


