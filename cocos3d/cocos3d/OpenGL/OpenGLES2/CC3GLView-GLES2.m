/*
 * CC3GLView-GLES2.m
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
 * See header file CC3GLView-GLES2.h for full API documentation.
 */

#import "CC3GLView-GLES2.h"

#if CC3_OGLES_2

#if COCOS2D_VERSION < 0x020100
#	define CC2_REQUESTED_SAMPLES requestedSamples_
#	define CC2_RENDERER renderer_
#	define CC2_SIZE size_
#	define CC2_BACKING_WIDTH backingWidth_
#	define CC2_BACKING_HEIGHT backingHeight_
#	define CC2_SAMPLES_TO_USE samplesToUse_
#	define CC2_DEPTH_BUFFER depthBuffer_
#	define CC2_DEPTH_FORMAT depthFormat_
#	define CC2_MULTISAMPLING multiSampling_
#else
#	define CC2_REQUESTED_SAMPLES _requestedSamples
#	define CC2_RENDERER _renderer
#	define CC2_SIZE _size
#	define CC2_BACKING_WIDTH _backingWidth
#	define CC2_BACKING_HEIGHT _backingHeight
#	define CC2_SAMPLES_TO_USE _samplesToUse
#	define CC2_DEPTH_BUFFER _depthBuffer
#	define CC2_DEPTH_FORMAT _depthFormat
#	define CC2_MULTISAMPLING _multiSampling
#endif

#import "CC3Logging.h"
#import "CCConfiguration.h"
#import "CC3IOSExtensions.h"


#pragma mark -
#pragma mark CCGLView extensions

@implementation CCGLView (CC3)

-(GLuint) pixelSamples { return CC2_REQUESTED_SAMPLES; }

-(void) openPicking {
	CC3Assert( !self.multiSampling, @"%@ does not support node picking when configured for multisampling. Use the %@ class instead.",
				 [self class], [CC3GLView class]);
}

-(void) closePicking {}

@end


#pragma mark -
#pragma mark CCGLView

@interface CCGLView (TemplateMethods)
-(BOOL) setupSurfaceWithSharegroup: (EAGLSharegroup*) sharegroup;
@end

@implementation CC3GLView

-(GLuint) pixelSamples { return ((CC3ES2Renderer*)CC2_RENDERER).pixelSamples; }

-(void) openPicking { [((CC3ES2Renderer*)CC2_RENDERER) openPicking]; }

-(void) closePicking { [((CC3ES2Renderer*)CC2_RENDERER) closePicking]; }

/** Forces the underlying renderer to be created as a CC3ES2Renderer. */
-(BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup {
	CCES2Renderer.instantiationClass = CC3ES2Renderer.class;
	BOOL rslt = [super setupSurfaceWithSharegroup: sharegroup];
	CCES2Renderer.instantiationClass = nil;
	return rslt;
}

/** Overridden to notify controller after the new window size is set. */
-(void) layoutSubviews {
	[CC2_RENDERER resizeFromLayer: (CAEAGLLayer*)self.layer];
	CC2_SIZE = [CC2_RENDERER backingSize];
	[CCDirector.sharedDirector reshapeProjection: CC2_SIZE];		// Issue #914 #924
	
	// Notify controller...already done in iOS5 & above
	if(CCConfiguration.sharedConfiguration.OSVersion < kCCiOSVersion_5_0 )
		[self.viewController viewDidLayoutSubviews];
}

@end


#pragma mark -
#pragma mark CCES2Renderer extension

@implementation CCES2Renderer (CC3ES2Renderer)

/** The CCES2Renderer cluster class to be instantiated when the alloc method is invoked. */
static Class _instantiationClass = nil;

+(Class) instantiationClass { return _instantiationClass; }

+(void) setInstantiationClass: (Class) aClass  {
	CC3Assert(aClass == nil || [aClass isSubclassOfClass: [CCES2Renderer class]],
			  @"%@ is not a subclass of CCES2Renderer.", aClass);
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
#pragma mark CC3ES2Renderer

@interface CC3ES2Renderer (TemplateMethods)
-(void) deletePickerBuffers;
@end

@implementation CC3ES2Renderer

- (void)dealloc {
	[self deletePickerBuffers];
	[super dealloc];
}

/** Bypass the superclass alloc, which can redirect back here, causing an infinite loop. */
+(id) alloc { return [self allocBase]; }

-(GLuint) pixelSamples { return CC2_SAMPLES_TO_USE; }

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
		_pickerFrameBuffer = 0;
		_pickerDepthBuffer = 0;
    }
    return self;
}

-(BOOL) resizeFromLayer: (CAEAGLLayer*) layer {
	[self deletePickerBuffers];
	BOOL wasSuccessful = [super resizeFromLayer: layer];
	
	// If we want a stencil buffer, it must be combined with the depth buffer (GL_DEPTH24_STENCIL8_OES).
	// Attach it to the framebuffer.
	if (wasSuccessful && (CC2_DEPTH_FORMAT == GL_DEPTH24_STENCIL8_OES || CC2_DEPTH_FORMAT == GL_UNSIGNED_INT_24_8_OES)) {
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, CC2_DEPTH_BUFFER);
	}
	return wasSuccessful;
}

-(void) deletePickerBuffers {
	if(_pickerFrameBuffer) {
		glDeleteFramebuffers(1, &_pickerFrameBuffer);
		_pickerFrameBuffer = 0;
	}
	if(_pickerDepthBuffer) {
		glDeleteRenderbuffers(1, &_pickerDepthBuffer);
		_pickerDepthBuffer = 0;
	}
}

-(void) openPicking {
	if ( !CC2_MULTISAMPLING ) return;

	if ( !_pickerFrameBuffer ) {
		
		// Generate a new picker FBO and bind existing resolve color buffer to it
		glGenFramebuffers(1, &_pickerFrameBuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, _pickerFrameBuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderBuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
		
		// Generate a new depth render buffer and bind it to picker FBO
		if (CC2_DEPTH_FORMAT) {
			glGenRenderbuffers(1, &_pickerDepthBuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _pickerDepthBuffer);
			glRenderbufferStorage(GL_RENDERBUFFER, CC2_DEPTH_FORMAT, CC2_BACKING_WIDTH, CC2_BACKING_HEIGHT);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _pickerDepthBuffer);
			LogTrace(@"Picker depth buffer %u format: %x, w: %i h: %i", _pickerDepthBuffer, CC2_DEPTH_FORMAT, CC2_BACKING_WIDTH, CC2_BACKING_HEIGHT);
		}
		// Verify the framebuffer
		GLenum fbStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		if (fbStatus != GL_FRAMEBUFFER_COMPLETE) {
			LogError(@"Failed to make complete picker framebuffer object %x", fbStatus);
			[self deletePickerBuffers];
		}
	}
	
	// Bind the dedicated picker framebuffer to which drawing operations will be directed
	// during node rendering during node picking.
	if(_pickerFrameBuffer) {
		glBindFramebuffer(GL_FRAMEBUFFER, _pickerFrameBuffer);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
}

-(void) closePicking { if (CC2_MULTISAMPLING) glBindFramebuffer(GL_FRAMEBUFFER, self.msaaFrameBuffer); }

@end

#endif	// CC3_OGLES_2
