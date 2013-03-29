/*
 * CC3GLView-GL.m
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
 * See header file CC3GLView-GL.h for full API documentation.
 */

#import "CC3GLView-GL.h"

#if CC3_OGL

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


#pragma mark -
#pragma mark CCGLView extensions

@implementation CCGLView (CC3)

-(GLuint) pixelSamples { return 1; }
//-(GLuint) pixelSamples { return CC2_REQUESTED_SAMPLES; }

-(void) openPicking {
//	CC3Assert( !self.multiSampling, @"%@ does not support node picking when configured for multisampling. Use the %@ class instead.",
//				 [self class], [CC3GLView class]);
}

-(void) closePicking {}

-(void) addGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer {}

-(void) removeGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer {}

@end


#pragma mark -
#pragma mark CCGLView

@implementation CC3GLView


@end


#endif	// CC3_OGL
