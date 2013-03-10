/*
 * CC3OpenGLES2State.m
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

#import "CC3OpenGLES2State.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLES2State

@implementation CC3OpenGLES2State

-(void) initializeTrackers {
	self.clearColor = [CC3OpenGLESStateTrackerColor trackerWithParent: self
															 forState: GL_COLOR_CLEAR_VALUE
													 andGLSetFunction: glClearColor
											 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.clearDepth = [CC3OpenGLESStateTrackerFloat trackerWithParent: self
															 forState: GL_DEPTH_CLEAR_VALUE
													 andGLSetFunction: glClearDepthf
											 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.clearStencil = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_STENCIL_CLEAR_VALUE
														 andGLSetFunction: glClearStencil
												 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	
	self.color = [CC3OpenGLESStateTrackerColorFixedAndFloat trackerWithParent: self
													 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.colorMask = [CC3OpenGLESStateTrackerColorFixedAndFloat trackerWithParent: self
																		 forState: GL_DEPTH_WRITEMASK
																 andGLSetFunction: NULL
															andGLSetFunctionFixed: glColorMask
														 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.cullFace = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																 forState: GL_CULL_FACE_MODE
														 andGLSetFunction: glCullFace
												 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.depthFunction = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	  forState: GL_DEPTH_FUNC
															  andGLSetFunction: glDepthFunc
													  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.depthMask = [CC3OpenGLESStateTrackerBoolean trackerWithParent: self
															  forState: GL_DEPTH_WRITEMASK
													  andGLSetFunction: glDepthMask
											  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.frontFace = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																  forState: GL_FRONT_FACE
														  andGLSetFunction: glFrontFace
												  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.lineWidth = [CC3OpenGLESStateTrackerFloat trackerWithParent: self
															forState: GL_LINE_WIDTH
													andGLSetFunction: glLineWidth
											andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.pointSize = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	self.pointSizeAttenuation = [CC3OpenGLESStateTrackerVector trackerWithParent: self];
	self.pointSizeFadeThreshold = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	self.pointSizeMaximum = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	self.pointSizeMinimum = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	
	self.polygonOffset = [CC3OpenGLESStateTrackerPolygonOffset trackerWithParent: self];

	self.scissor = [CC3OpenGLESStateTrackerViewport trackerWithParent: self
															 forState: GL_SCISSOR_BOX
													 andGLSetFunction: glScissor
											 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.shadeModel = nil;
	
	self.stencilFunction = [CC3OpenGLESStateTrackerStencilFunction trackerWithParent: self];

	self.stencilOperation = [CC3OpenGLESStateTrackerStencilOperation trackerWithParent: self];
	
	self.viewport = [CC3OpenGLESStateTrackerViewport trackerWithParent: self
															  forState: GL_VIEWPORT
													  andGLSetFunction: glViewport
											  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
}

@end

#endif
