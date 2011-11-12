/*
 * CC3OpenGLES11State.m
 *
 * cocos3d 0.6.3
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
 * See header file CC3OpenGLES11State.h for full API documentation.
 */

#import "CC3OpenGLES11State.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPointParameterFloat

@implementation CC3OpenGLES11StateTrackerPointParameterFloat

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) setGLValue {
	glPointParameterf(name, value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPointParameterVector

@implementation CC3OpenGLES11StateTrackerPointParameterVector

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) setGLValue {
	glPointParameterfv(name, (GLfloat*)&value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11State

@implementation CC3OpenGLES11State

@synthesize color;
@synthesize clearColor;
@synthesize clearDepth;
@synthesize clearStencil;
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
@synthesize scissor;
@synthesize shadeModel;
@synthesize viewport;

-(void) dealloc {
	[color release];
	[clearColor release];
	[clearDepth release];
	[clearStencil release];
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
	[scissor release];
	[shadeModel release];
	[viewport release];

	[super dealloc];
}

-(void) initializeTrackers {
	self.color = [CC3OpenGLES11StateTrackerColorFixedAndFloat trackerWithParent: self
																	   forState: GL_CURRENT_COLOR
															   andGLSetFunction: glColor4f
														  andGLSetFunctionFixed: glColor4ub
													   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.clearColor = [CC3OpenGLES11StateTrackerColor trackerWithParent: self
															   forState: GL_COLOR_CLEAR_VALUE
													   andGLSetFunction: glClearColor
											   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.clearDepth = [CC3OpenGLES11StateTrackerFloat trackerWithParent: self
															   forState: GL_DEPTH_CLEAR_VALUE
													   andGLSetFunction: glClearDepthf
											   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.clearStencil = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																   forState: GL_STENCIL_CLEAR_VALUE
														   andGLSetFunction: glClearStencil
												   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.cullFace = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																   forState: GL_CULL_FACE_MODE
														   andGLSetFunction: glCullFace
												   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.depthFunction = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																		forState: GL_DEPTH_FUNC
																andGLSetFunction: glDepthFunc
														andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.depthMask = [CC3OpenGLES11StateTrackerBoolean trackerWithParent: self
																forState: GL_DEPTH_WRITEMASK
														andGLSetFunction: glDepthMask
												andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.frontFace = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	forState: GL_FRONT_FACE
															andGLSetFunction: glFrontFace
													andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.lineWidth = [CC3OpenGLES11StateTrackerFloat trackerWithParent: self
															  forState: GL_LINE_WIDTH
													  andGLSetFunction: glLineWidth
											  andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.pointSize = [CC3OpenGLES11StateTrackerFloat trackerWithParent: self
															  forState: GL_POINT_SIZE
													  andGLSetFunction: glPointSize
											  andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.pointSizeAttenuation = [CC3OpenGLES11StateTrackerPointParameterVector trackerWithParent: self
																						forState: GL_POINT_DISTANCE_ATTENUATION];
	
	self.pointSizeFadeThreshold = [CC3OpenGLES11StateTrackerPointParameterFloat trackerWithParent: self
																						 forState: GL_POINT_FADE_THRESHOLD_SIZE];
	
	self.pointSizeMaximum = [CC3OpenGLES11StateTrackerPointParameterFloat trackerWithParent: self
																				   forState: GL_POINT_SIZE_MAX];
	
	self.pointSizeMinimum = [CC3OpenGLES11StateTrackerPointParameterFloat trackerWithParent: self
																				   forState: GL_POINT_SIZE_MIN];

	self.scissor = [CC3OpenGLES11StateTrackerViewport trackerWithParent: self
															   forState: GL_SCISSOR_BOX
													   andGLSetFunction: glScissor
											   andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.shadeModel = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	 forState: GL_SHADE_MODEL
															 andGLSetFunction: glShadeModel
													 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.viewport = [CC3OpenGLES11StateTrackerViewport trackerWithParent: self
																forState: GL_VIEWPORT
														andGLSetFunction: glViewport
												andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", color];
	[desc appendFormat: @"\n    %@ ", clearColor];
	[desc appendFormat: @"\n    %@ ", clearDepth];
	[desc appendFormat: @"\n    %@ ", clearStencil];
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
	[desc appendFormat: @"\n    %@ ", scissor];
	[desc appendFormat: @"\n    %@ ", shadeModel];
	[desc appendFormat: @"\n    %@ ", viewport];
	return desc;
}

-(void) clearBuffers: (GLbitfield) mask {
	glClear(mask);
}

-(void) clearColorBuffer {
	[self clearBuffers: GL_COLOR_BUFFER_BIT];
}

-(void) clearDepthBuffer {
	[self clearBuffers: GL_DEPTH_BUFFER_BIT];
}

-(void) clearStencilBuffer {
	[self clearBuffers: GL_STENCIL_BUFFER_BIT];
}

-(ccColor4B) readPixelAt: (CGPoint) pixelPosition {
	ccColor4B pixColor;
	glReadPixels((GLint)pixelPosition.x, (GLint)pixelPosition.y,
				 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &pixColor);
	return pixColor;
}

@end
