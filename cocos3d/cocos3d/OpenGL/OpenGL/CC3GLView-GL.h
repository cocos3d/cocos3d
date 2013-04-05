/*
 * CC3GLView-GL.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Environment.h"

#if CC3_OGL

#import "CC3OpenGLFoundation.h"
#import "CC3CC2Extensions.h"


#pragma mark -
#pragma mark CCGLView extensions

/**
 * This extension category adds support for node-picking while multisampling antialiasing
 * is active, by defining the interface required by that support.
 */
@interface CCGLView (CC3)

/** Returns the number of samples used to define each pixel. */
@property(nonatomic, readonly) GLuint pixelSamples;

/**
 * Invoked before the rendering pass used during node-picking, which uses a specialized
 * coloring and pixel-reading algorithm to detect which node is under a touched pixel.
 *
 * This implementation does nothing other than log an error message if multisampling
 * antialiasing is active. Subclasses that support node-picking when multisampling is
 * active will override.
 */
-(void) openPicking;

/**
 * Invoked after the rendering pass used during node-picking to restore normal rendering
 * operations.
 *
 * This implementation does nothing. Subclasses that support node-picking when multisampling
 * is active will override.
 */
-(void) closePicking;

/** 
 * Adds the specified gesture recognizer.
 *
 * Gesture recognizers are not supported in OSX, so this method does nothing. 
 */
-(void) addGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer;

/**
 * Removes the specified gesture recognizer.
 *
 * Gesture recognizers are not supported in OSX, so this method does nothing.
 */
-(void) removeGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer;

@end


#pragma mark -
#pragma mark CC3GLView

/**
 * If your application supports BOTH multisampling AND node-picking from touch events,
 * you should use this class instead of EAGLView.
 *
 * The multisampling framebuffer used when multisampling antialiasing is active interferes
 * with node-picking from touch events, because the multisampling framebuffer does not support
 * the pixel reading operation required by the node-picking algorithm.
 *
 * This subclass adds support for node-picking while multisampling is active by adding an
 * additional framebuffer that links the existing resolve color buffer to a newly created
 * depth buffer. Rendering during node picking is directed to this specialized framebuffer,
 * which does support pixel reading, by invoking the openPicking method. Once node-picking
 * is complete, the multisampling framebuffer can be made active again for normal rendering
 * operations by invoking the closePicking method.
 *
 * The additional depth and frame buffers are only added if BOTH multisampling is active and
 * node-picking is being used. To preserve memory, the additional buffers will not be created
 * unless both multisampling and node-picking are active.
 *
 * The heavy lifting of this mechanism is handled by a specialized CC3ES1Renderer, which this
 * class creates and wraps.
 */
@interface CC3GLView : CCGLView
@end

#endif	// CC3_OGL