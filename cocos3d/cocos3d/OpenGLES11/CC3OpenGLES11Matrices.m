/*
 * CC3OpenGLES11Matrices.m
 *
 * cocos3d 0.6.2
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
	LogTrace("%@ pushed", self);
}

-(void) pop {
	[self activate];
	glPopMatrix();
	LogTrace("%@ popped", self);
}

-(GLuint) getDepth {
	[self activate];
	GLuint depth;
	glGetIntegerv(depthName, (GLint*)&depth);
	LogTrace("%@ read GL stack depth %u", self, depth);
	return depth;
}

-(void) identity {
	[self activate];
	glLoadIdentity();
	LogTrace("%@ loaded identity", self);
}

-(void) load: (GLvoid*) glMatrix {
	[self activate];
	glLoadMatrixf(glMatrix);
	LogTrace("%@ loaded matrix at %p", self, glMatrix);
}

-(void) getTop: (GLvoid*) glMatrix {
	[self activate];
	glGetFloatv(topName, glMatrix);
	LogTrace("%@ read top into %p", self, glMatrix);
}

-(void) multiply: (GLvoid*) glMatrix {
	[self activate];
	glMultMatrixf(glMatrix);
	LogTrace("%@ multiplied matrix at %p", self, glMatrix);
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			withMode: (GLenum) matrixMode
		  andTopName: (GLenum) tName
		andDepthName: (GLenum) dName
	  andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) tracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		mode = matrixMode;
		topName = tName;
		depthName = dName;
		modeTracker = [tracker retain];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   withMode: (GLenum) matrixMode
			 andTopName: (GLenum) tName
		   andDepthName: (GLenum) dName
		 andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) tracker {
	return [[[self alloc] initWithParent: aTracker
								withMode: matrixMode
							  andTopName: tName
							andDepthName: dName
						  andModeTracker: tracker] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", [super description], NSStringFromGLEnum(mode)];
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
	self.mode = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
															   forState: GL_MATRIX_MODE
													   andGLSetFunction: glMatrixMode
											   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.modelview = [CC3OpenGLES11MatrixStack trackerWithParent: self
														withMode: GL_MODELVIEW 
													  andTopName: GL_MODELVIEW_MATRIX
													andDepthName: GL_MODELVIEW_STACK_DEPTH
												  andModeTracker: mode];

	self.projection = [CC3OpenGLES11MatrixStack trackerWithParent: self
														 withMode: GL_PROJECTION 
													   andTopName: GL_PROJECTION_MATRIX
													 andDepthName: GL_PROJECTION_STACK_DEPTH
												   andModeTracker: mode];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", mode];
	[desc appendFormat: @"\n    %@ ", modelview];
	[desc appendFormat: @"\n    %@ ", projection];
	return desc;
}

@end
