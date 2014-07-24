/*
 * CC3EAGLView.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3EAGLView.h for full API documentation.
 */

#import "CC3EAGLView.h"

#if CC3_OGLES_1


#pragma mark -
#pragma mark CC3EAGLView

@interface EAGLView (TemplateMethods)
- (GLuint) convertPixelFormat:(NSString*) pixelFormat;
@end

@implementation CC3EAGLView

/**
 * This template method is an exact copy of the superclass implementation except
 * that this implementation instantiates CC3ES1Renderer instead of ES1Renderer.
 */
-(BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup {
	CAEAGLLayer *eaglLayer = (CAEAGLLayer*)self.layer;
	
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:preserveBackbuffer_], kEAGLDrawablePropertyRetainedBacking,
									pixelformat_, kEAGLDrawablePropertyColorFormat, nil];
	
	renderer_ = [[CC3ES1Renderer alloc] initWithDepthFormat: depthFormat_
											withPixelFormat: [self convertPixelFormat: pixelformat_]
											 withSharegroup: sharegroup
										  withMultiSampling: self.multiSampling
										withNumberOfSamples: requestedSamples_];
	if (!renderer_)
		return NO;
	
	context_ = [renderer_ context];
	
	discardFramebufferSupported_ = [[CCConfiguration sharedConfiguration] supportsDiscardFramebuffer];
	
	return YES;
}

@end


#pragma mark -
#pragma mark CC3ES1Renderer

@implementation CC3ES1Renderer

-(BOOL) resizeFromLayer: (CAEAGLLayer*) layer {
	BOOL wasSuccessful = [super resizeFromLayer: layer];

	// If we want a stencil buffer, it must be combined with the depth buffer (GL_DEPTH24_STENCIL8_OES).
	// Attach it to the framebuffer.
	if (wasSuccessful && (depthFormat_ == GL_DEPTH24_STENCIL8_OES || depthFormat_ == GL_UNSIGNED_INT_24_8_OES)) {
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_STENCIL_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthBuffer_);
	}
	return wasSuccessful;
}

@end

#endif	// CC3_OGLES_1
