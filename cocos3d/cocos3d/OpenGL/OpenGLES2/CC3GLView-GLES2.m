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

#import "CC3Logging.h"
#import "CC3IOSExtensions.h"

#if COCOS2D_VERSION < 0x020100
#	define CC2_REQUESTED_SAMPLES requestedSamples_
#	define CC2_PIXEL_FORMAT pixelformat_
#	define CC2_DEPTH_FORMAT depthFormat_
#	define CC2_CONTEXT context_
#	define CC2_SIZE size_
#else
#	define CC2_REQUESTED_SAMPLES _requestedSamples
#	define CC2_PIXEL_FORMAT _pixelformat
#	define CC2_DEPTH_FORMAT _depthFormat
#	define CC2_CONTEXT _context
#	define CC2_SIZE _size
#endif


#pragma mark -
#pragma mark CCGLView

@interface CCGLView (TemplateMethods)
-(unsigned int) convertPixelFormat:(NSString*) pixelFormat;
@end

@implementation CC3GLView

-(void) dealloc {
	[_surfaceManager release];
	[super dealloc];
}

-(CAEAGLLayer*) layer { return (CAEAGLLayer*)super.layer; }

-(CC3GLViewSurfaceManager*) surfaceManager { return _surfaceManager; }

-(GLuint) pixelSamples { return _surfaceManager.pixelSamples; }

-(BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup {
	self.layer.opaque = YES;
	self.layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithBool:preserveBackbuffer_],
									 kEAGLDrawablePropertyRetainedBacking,
									 pixelformat_,
									 kEAGLDrawablePropertyColorFormat,
									 nil];

	CC2_CONTEXT = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2 sharegroup: sharegroup];
	if ( !CC2_CONTEXT || ![EAGLContext setCurrentContext: CC2_CONTEXT] ) {
		CC3Assert(NO, @"Could not create EAGLContext. OpenGL ES 2.0 is required.");
		[self release];
		return NO;
	}
	
	GLenum colorFormat = [self convertPixelFormat: CC2_PIXEL_FORMAT];
	_surfaceManager = [[CC3GLViewSurfaceManager alloc] initWithColorFormat: colorFormat
															andDepthFormat: CC2_DEPTH_FORMAT
														   andPixelSamples: CC2_REQUESTED_SAMPLES];
	return YES;
}

-(void) layoutSubviews {
	[_surfaceManager resizeFromCALayer: self.layer withContext: CC2_CONTEXT];
	CC2_SIZE = CGSizeFromCC3IntSize(_surfaceManager.size);
	[CCDirector.sharedDirector reshapeProjection: CC2_SIZE];		// Issue #914 #924
	
	// Notify controller...already done in iOS5 & above
	if(CCConfiguration.sharedConfiguration.OSVersion < kCCiOSVersion_5_0 )
		[self.viewController viewDidLayoutSubviews];
}

-(void) swapBuffers { [_surfaceManager presentToContext: CC2_CONTEXT]; }

@end

#endif	// CC3_OGLES_2
