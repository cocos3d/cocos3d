/*
 * CC3OpenGLES11State.m
 *
 * cocos3d 0.6.0-sp
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
	[scissor release];
	[shadeModel release];
	[viewport release];

	[super dealloc];
}

-(void) initializeTrackers {
	self.color = [CC3OpenGLES11StateTrackerColorFixedAndFloat trackerForState: GL_CURRENT_COLOR
															 andGLSetFunction: glColor4f
														andGLSetFunctionFixed: glColor4ub
													 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.clearColor = [CC3OpenGLES11StateTrackerColor trackerForState: GL_COLOR_CLEAR_VALUE
													 andGLSetFunction: glClearColor
											 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.clearDepth = [CC3OpenGLES11StateTrackerFloat trackerForState: GL_DEPTH_CLEAR_VALUE
													 andGLSetFunction: glClearDepthf
											 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.clearStencil = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_STENCIL_CLEAR_VALUE
														 andGLSetFunction: glClearStencil
												 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.cullFace = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_CULL_FACE_MODE
														 andGLSetFunction: glCullFace
												 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.depthFunction = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_DEPTH_FUNC
															  andGLSetFunction: glDepthFunc
													  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.depthMask = [CC3OpenGLES11StateTrackerBoolean trackerForState: GL_DEPTH_WRITEMASK
													  andGLSetFunction: glDepthMask
											  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.frontFace = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_FRONT_FACE
														  andGLSetFunction: glFrontFace
												  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.lineWidth = [CC3OpenGLES11StateTrackerFloat trackerForState: GL_LINE_WIDTH
													 andGLSetFunction: glLineWidth
											 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.pointSize = [CC3OpenGLES11StateTrackerFloat trackerForState: GL_POINT_SIZE
													andGLSetFunction: glPointSize
											andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.pointSizeAttenuation = [CC3OpenGLES11StateTrackerPointParameterVector trackerForState: GL_POINT_DISTANCE_ATTENUATION];

	self.scissor = [CC3OpenGLES11StateTrackerViewport trackerForState: GL_SCISSOR_BOX
													 andGLSetFunction: glScissor
											 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	
	self.shadeModel = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_SHADE_MODEL
														   andGLSetFunction: glShadeModel
												   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	
	self.viewport = [CC3OpenGLES11StateTrackerViewport trackerForState: GL_VIEWPORT
													  andGLSetFunction: glViewport
											  andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[color open];
	[clearColor open];
	[clearDepth open];
	[clearStencil open];
	[cullFace open];
	[depthFunction open];
	[depthMask open];
	[frontFace open];
	[lineWidth open];
	[pointSize open];
	[pointSizeAttenuation open];
	[scissor open];
	[shadeModel open];
	[viewport open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[color close];
	[clearColor close];
	[clearDepth close];
	[clearStencil close];
	[cullFace close];
	[depthFunction close];
	[depthMask close];
	[frontFace close];
	[lineWidth close];
	[pointSize close];
	[pointSizeAttenuation close];
	[scissor close];
	[shadeModel close];
	[viewport close];
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
