/*
 * CC3OpenGLES11Matrices.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLES11Matrices.h for full API documentation.
 */

#import "CC3OpenGLES11Matrices.h"


#pragma mark -
#pragma mark CC3OpenGLES11MatrixStack

@implementation CC3OpenGLES11MatrixStack

-(void) dealloc {
	[modeTracker release];
	[super dealloc];
}

-(void) activate {
	modeTracker.value = mode;
}

-(void) push {
	[self activate];
	glPushMatrix();
	LogTrace("%@ %@ pushed", [self class], NSStringFromGLEnum(mode));
}

-(void) pop {
	[self activate];
	glPopMatrix();
	LogTrace("%@ %@ popped", [self class], NSStringFromGLEnum(mode));
}

-(GLuint) getDepth {
	[self activate];
	GLuint depth;
	glGetIntegerv(depthName, (GLint*)&depth);
	LogTrace("%@ %@ read GL stack depth %u", [self class], NSStringFromGLEnum(mode), depth);
	return depth;
}

-(void) identity {
	[self activate];
	glLoadIdentity();
	LogTrace("%@ %@ loaded identity", [self class], NSStringFromGLEnum(mode));
}

-(void) load: (GLvoid*) glMatrix {
	[self activate];
	glLoadMatrixf(glMatrix);
	LogTrace("%@ %@ loaded matrix at %p", [self class], NSStringFromGLEnum(mode), glMatrix);
}

-(void) getTop: (GLvoid*) glMatrix {
	[self activate];
	glGetFloatv(topName, glMatrix);
	LogTrace("%@ %@ read top into %p", [self class], NSStringFromGLEnum(mode), glMatrix);
}

-(void) multiply: (GLvoid*) glMatrix {
	[self activate];
	glMultMatrixf(glMatrix);
	LogTrace("%@ %@ multiplied matrix at %p", [self class], NSStringFromGLEnum(mode), glMatrix);
}

-(id) initWithMode: (GLenum) matrixMode
		andTopName: (GLenum) tName
	  andDepthName: (GLenum) dName
	andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) tracker {
	if ( (self = [super init]) ) {
		mode = matrixMode;
		topName = tName;
		depthName = dName;
		modeTracker = [tracker retain];
	}
	return self;
}

+(id) trackerWithMode: (GLenum) matrixMode
		   andTopName: (GLenum) tName
		 andDepthName: (GLenum) dName
	   andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) tracker {
	return [[[self alloc] initWithMode: matrixMode
							andTopName: tName
						  andDepthName: dName
						andModeTracker: tracker] autorelease];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Matrices

@implementation CC3OpenGLES11Matrices

@synthesize mode;
@synthesize modelview;
@synthesize projection;

-(void) dealloc {
	[mode release];
	[modelview release];
	[projection release];

	[super dealloc];
}

-(void) initializeTrackers {
	// Matrix mode tracker needs to read and restore
	self.mode = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_MATRIX_MODE
													 andGLSetFunction: glMatrixMode
											 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.modelview = [CC3OpenGLES11MatrixStack trackerWithMode: GL_MODELVIEW 
													andTopName: GL_MODELVIEW_MATRIX
												  andDepthName: GL_MODELVIEW_STACK_DEPTH
												andModeTracker: mode];

	self.projection = [CC3OpenGLES11MatrixStack trackerWithMode: GL_PROJECTION 
													andTopName: GL_PROJECTION_MATRIX
												  andDepthName: GL_PROJECTION_STACK_DEPTH
												andModeTracker: mode];
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[mode open];
	[modelview open];
	[projection open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[mode close];
	[modelview close];
	[projection close];
}

@end
