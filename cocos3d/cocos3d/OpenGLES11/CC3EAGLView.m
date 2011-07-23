/*
 * CC3EAGLView.m
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
 * See header file CC3EAGLView.h for full API documentation.
 */

#import "CC3EAGLView.h"
#import "CC3Logging.h"
#import "CCConfiguration.h"


#pragma mark -
#pragma mark EAGLView extensions

@implementation EAGLView (CC3Picking)

-(void) openPicking {
	if (self.multiSampling) {
		LogError(@"%@ does not support node picking when configured for multisampling. Use the %@ class instead.",
				 [self class], [CC3EAGLView class]);
	}
}

-(void) closePicking {}

@end


#pragma mark -
#pragma mark CC3EAGLView

@interface EAGLView (TemplateMethods)
- (GLuint) convertPixelFormat:(NSString*) pixelFormat;
@end

@implementation CC3EAGLView

-(void) openPicking {
	[((CC3ES1Renderer*)renderer_) openPicking];
}

-(void) closePicking {
	[((CC3ES1Renderer*)renderer_) closePicking];
}

/**
 * This template method is an exact copy of the superclass implementation except
 * that this implementation instantiates CC3ES1Renderer instead of ES1Renderer.
 */
-(BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup {
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:preserveBackbuffer_], kEAGLDrawablePropertyRetainedBacking,
									pixelformat_, kEAGLDrawablePropertyColorFormat, nil];
	
	
	renderer_ = [[CC3ES1Renderer alloc] initWithDepthFormat: depthFormat_
											withPixelFormat: [self convertPixelFormat:pixelformat_]
											 withSharegroup: sharegroup
										  withMultiSampling: self.multiSampling
										withNumberOfSamples: requestedSamples_];
	if (!renderer_)
		return NO;
	
	context_ = [renderer_ context];
	[context_ renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer];
	
	discardFramebufferSupported_ = [[CCConfiguration sharedConfiguration] supportsDiscardFramebuffer];
	
	return YES;
}

@end


#pragma mark -
#pragma mark CC3ES1Renderer

@interface CC3ES1Renderer (TemplateMethods)
-(void) deletePickerBuffers;
@end

@implementation CC3ES1Renderer

- (void)dealloc {
	[self deletePickerBuffers];
	[super dealloc];
}

-(id) initWithDepthFormat: (GLuint) depthFormat
		   withPixelFormat: (GLuint) pixelFormat
			withSharegroup: (EAGLSharegroup*) sharegroup
		 withMultiSampling: (BOOL) multiSampling
	   withNumberOfSamples: (GLuint) requestedSamples {

    if ((self = [super initWithDepthFormat: depthFormat
						   withPixelFormat: pixelFormat
							withSharegroup: sharegroup
						 withMultiSampling: multiSampling
					   withNumberOfSamples: requestedSamples])) {
		pickerFrameBuffer = 0;
		pickerDepthBuffer = 0;
    }
    return self;
}

- (BOOL)resizeFromLayer: (CAEAGLLayer*) layer {
	[self deletePickerBuffers];
	return [super resizeFromLayer: layer];
}

-(void) deletePickerBuffers {
	if(pickerFrameBuffer) {
		glDeleteFramebuffersOES(1, &pickerFrameBuffer);
		pickerFrameBuffer = 0;
	}
	if(pickerDepthBuffer) {
		glDeleteRenderbuffersOES(1, &pickerDepthBuffer);
		pickerDepthBuffer = 0;
	}
}

-(void) openPicking {
	if (multiSampling_) {

		if ( !pickerFrameBuffer ) {
			
			// Generate a new picker FBO and bind existing resolve color buffer to it
			glGenFramebuffersOES(1, &pickerFrameBuffer);
			glBindFramebufferOES(GL_FRAMEBUFFER_OES, pickerFrameBuffer);
			glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer_);
			glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer_);
			
			// Generate a new depth render buffer and bind it to picker FBO
			if (depthFormat_) {
				glGenRenderbuffersOES(1, &pickerDepthBuffer);
				glBindRenderbufferOES(GL_RENDERBUFFER_OES, pickerDepthBuffer);
				glRenderbufferStorageOES(GL_RENDERBUFFER_OES, depthFormat_, backingWidth_, backingHeight_);
				glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, pickerDepthBuffer);
				LogTrace(@"Picker depth buffer %u format: %x, w: %i h: %i", pickerDepthBuffer, depthFormat_, backingWidth_, backingHeight_);
			}
			// Verify the framebuffer
			if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
				LogError(@"Failed to make complete picker framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
				[self deletePickerBuffers];
			}
		}

		// Bind the dedicated picker framebuffer to which drawing operations will be directed
		// during node rendering during node picking.
		if(pickerFrameBuffer) {
			glBindFramebufferOES(GL_FRAMEBUFFER_OES, pickerFrameBuffer);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		}
	}
}

-(void) closePicking {
	if (multiSampling_) {
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer_);
	}
}

@end
