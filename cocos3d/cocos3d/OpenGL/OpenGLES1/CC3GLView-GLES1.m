/*
 * CC3GLView-GLES1.m
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
 * See header file CC3GLView-GLES1.h for full API documentation.
 */


#import "CC3GLView-GLES1.h"

#if CC3_OGLES_1
#import "CC3Logging.h"
#import "CCConfiguration.h"
#import "CC3IOSExtensions.h"
#import "cocos2d.h"


#pragma mark -
#pragma mark EAGLView extensions

@interface EAGLView (TemplateMethods)
-(BOOL) setupSurfaceWithSharegroup: (EAGLSharegroup*) sharegroup;
@end

@implementation EAGLView (CC3)

-(GLuint) pixelSamples { return requestedSamples_; }

-(void) openPicking {
	CC3Assert( !self.multiSampling, @"%@ does not support node picking when configured for multisampling. Use the %@ class instead.",
			  [self class], [CC3GLView class]);
}

-(void) closePicking {}

@end


#pragma mark -
#pragma mark CC3GLView

@implementation CC3GLView

-(GLuint) pixelSamples { return ((CC3ES1Renderer*)renderer_).pixelSamples; }

-(void) openPicking { [((CC3ES1Renderer*)renderer_) openPicking]; }

-(void) closePicking { [((CC3ES1Renderer*)renderer_) closePicking]; }

/** Forces the underlying renderer to be created as a CC3ES2Renderer. */
-(BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup {
	ES1Renderer.instantiationClass = CC3ES1Renderer.class;
	BOOL rslt = [super setupSurfaceWithSharegroup: sharegroup];
	ES1Renderer.instantiationClass = nil;
	return rslt;
}

/** Overridden to remove the unnecessary redraw while still in old orientation. */
-(void) layoutSubviews {
	[renderer_ resizeFromLayer: (CAEAGLLayer*)self.layer];
	size_ = [renderer_ backingSize];
	[CCDirector.sharedDirector reshapeProjection: size_];			// Issue #914 #924
	
	// Notify controller...already done in iOS5 & above
	if(CCConfiguration.sharedConfiguration.OSVersion < kCCiOSVersion_5_0_0 )
		[self.viewController viewDidLayoutSubviews];
}

@end


#pragma mark -
#pragma mark ES1Renderer extension

@implementation ES1Renderer (CC3ES1Renderer)

/** The ES1Renderer cluster class to be instantiated when the alloc method is invoked. */
static Class _instantiationClass = nil;

+(Class) instantiationClass { return _instantiationClass; }

+(void) setInstantiationClass: (Class) aClass  {
	CC3Assert(aClass == nil || [aClass isSubclassOfClass: [ES1Renderer class]],
			  @"%@ is not a subclass of ES1Renderer.", aClass);
	_instantiationClass = aClass;
}

/** Invoke the superclass alloc method, bypassing the alloc method of this class. */
+(id) allocBase { return [super alloc]; }

/**
 * If the instantiationClass property is not nil, allocates an instance of that
 * subclass, so that additional state and behaviour can be added to renderers,
 * without having to change where they are instantiated.
 *
 * If the instantiationClass property is nil, allocates an instance of this class.
 */
+(id) alloc { return _instantiationClass ? [_instantiationClass alloc] : [self allocBase]; }

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

/** Bypass the superclass alloc, which can redirect back here, causing an infinite loop. */
+(id) alloc { return [self allocBase]; }

-(GLuint) pixelSamples { return samplesToUse_; }

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

-(BOOL) resizeFromLayer: (CAEAGLLayer*) layer {
	[self deletePickerBuffers];
	BOOL wasSuccessful = [super resizeFromLayer: layer];

	// If we want a stencil buffer, it must be combined with the depth buffer (GL_DEPTH24_STENCIL8_OES).
	// Attach it to the framebuffer.
	if (wasSuccessful && (depthFormat_ == GL_DEPTH24_STENCIL8_OES || depthFormat_ == GL_UNSIGNED_INT_24_8_OES)) {
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_STENCIL_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthBuffer_);
	}
	return wasSuccessful;
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
	if ( !multiSampling_ ) return;

	if ( !pickerFrameBuffer ) {
		
		// Generate a new picker FBO and bind existing resolve color buffer to it
		glGenFramebuffersOES(1, &pickerFrameBuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, pickerFrameBuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, self.colorRenderBuffer);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, self.colorRenderBuffer);
		
		// Generate a new depth render buffer and bind it to picker FBO
		if (depthFormat_) {
			glGenRenderbuffersOES(1, &pickerDepthBuffer);
			glBindRenderbufferOES(GL_RENDERBUFFER_OES, pickerDepthBuffer);
			glRenderbufferStorageOES(GL_RENDERBUFFER_OES, depthFormat_, backingWidth_, backingHeight_);
			glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, pickerDepthBuffer);
			LogTrace(@"Picker depth buffer %u format: %x, w: %i h: %i", pickerDepthBuffer, depthFormat_, backingWidth_, backingHeight_);
		}
		// Verify the framebuffer
		GLenum fbStatus = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
		if (fbStatus != GL_FRAMEBUFFER_COMPLETE_OES) {
			LogError(@"Failed to make complete picker framebuffer object %x", fbStatus);
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

-(void) closePicking { if (multiSampling_) glBindFramebufferOES(GL_FRAMEBUFFER_OES, self.msaaFrameBuffer); }

@end

// Deprecated
@implementation CC3EAGLView
@end

#endif	// CC3_OGLES_1
