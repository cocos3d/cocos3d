/*
 * CC3OpenGLES1State.m
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

#import "CC3OpenGLES1State.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerPointParameterFloat

@implementation CC3OpenGLES1StateTrackerPointParameterFloat

-(void) setGLValue { glPointParameterf(name, value); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerPointParameterVector

@implementation CC3OpenGLES1StateTrackerPointParameterVector

-(void) setGLValue { glPointParameterfv(name, (GLfloat*)&value); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1State

@implementation CC3OpenGLES1State

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
																	 forState: GL_CURRENT_COLOR
															 andGLSetFunction: glColor4f
														andGLSetFunctionFixed: glColor4ub
													 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
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
	
	self.pointSize = [CC3OpenGLESStateTrackerFloat trackerWithParent: self
															forState: GL_POINT_SIZE
													andGLSetFunction: glPointSize
											andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	// Crashes OpenGL Analyzer when attempting to read the GL value
	self.pointSizeAttenuation = [CC3OpenGLES1StateTrackerPointParameterVector trackerWithParent: self
																					   forState: GL_POINT_DISTANCE_ATTENUATION
																	   andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];

	
	// Crashes OpenGL Analyzer when attempting to read the GL value
	self.pointSizeFadeThreshold = [CC3OpenGLES1StateTrackerPointParameterFloat trackerWithParent: self
																						forState: GL_POINT_FADE_THRESHOLD_SIZE
																		andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	
	// Crashes OpenGL Analyzer when attempting to read the GL value
	self.pointSizeMaximum = [CC3OpenGLES1StateTrackerPointParameterFloat trackerWithParent: self
																				  forState: GL_POINT_SIZE_MAX
																  andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];

	// Crashes OpenGL Analyzer when attempting to read the GL value
	self.pointSizeMinimum = [CC3OpenGLES1StateTrackerPointParameterFloat trackerWithParent: self
																				  forState: GL_POINT_SIZE_MIN
																  andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	
	self.polygonOffset = [CC3OpenGLESStateTrackerPolygonOffset trackerWithParent: self];

	self.scissor = [CC3OpenGLESStateTrackerViewport trackerWithParent: self
															 forState: GL_SCISSOR_BOX
													 andGLSetFunction: glScissor
											 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.shadeModel = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																   forState: GL_SHADE_MODEL
														   andGLSetFunction: glShadeModel
												   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.stencilFunction = [CC3OpenGLESStateTrackerStencilFunction trackerWithParent: self];

	self.stencilOperation = [CC3OpenGLESStateTrackerStencilOperation trackerWithParent: self];
	
	self.viewport = [CC3OpenGLESStateTrackerViewport trackerWithParent: self
															  forState: GL_VIEWPORT
													  andGLSetFunction: glViewport
											  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
}

@end

#endif
