/*
 * CC3EAGLView.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3OpenGLES11Foundation.h"
#import "EAGLView.h"
#import "ES1Renderer.h"


#pragma mark -
#pragma mark EAGLView extensions

/**
 * This extension category adds support for node-picking while multisampling antialiasing
 * is active, by defining the interface required by that support.
 */
@interface EAGLView (CC3)

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

@end


#pragma mark -
#pragma mark CC3EAGLView

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
@interface CC3EAGLView : EAGLView
@end


#pragma mark -
#pragma mark CC3ES1Renderer

/**
 * Specialized renderer that supports node-picking while multisampling antialiasing is active.
 *
 * If multisampling antialiasing is active, all rendering operations are directed to a
 * specialized multisampling framebuffer. Because it does not directly represent the screen,
 * this multisampling framebuffer does not support the pixel reading operation required by
 * the node-picking algorithm.
 *
 * This specialized renderer subclass adds an additional framebuffer that links the existing
 * resolve color buffer to a newly created depth buffer. Rendering during node picking is
 * directed to this specialized framebuffer, which does support pixel reading, by invoking
 * the openPicking method.  Once node-picking is complete, the multisampling framebuffer can
 * be made active again for normal rendering operations by invoking the closePicking method.
 *
 * The additional depth and frame buffers are only added if BOTH multisampling is active and
 * node-picking is being used. To preserve memory, the additional buffers will not be created
 * unless both multisampling and node-picking are active.
 */
@interface CC3ES1Renderer : ES1Renderer {
    GLuint pickerFrameBuffer;
	GLuint pickerDepthBuffer;
}

/** Returns the number of samples used to define each pixel. */
@property(nonatomic, readonly) GLuint pixelSamples;

/**
 * Sets up the rendering framework to support rendering custom colors and reading a pixel
 * color during node picking operation.
 *
 * The multisampling framebuffer does not permit the pixel reading used by the node-picking
 * algorithm. So, if multisampling is active, a separate non-multisampling framebuffer is
 * created to link together the resolve color buffer and a newly created non-multisampling
 * depth buffer. This dedicated framebuffer is then made active so that the node drawing that
 * occurs during node picking is rendered to this dedicated, non-multisampling framebuffer.
 *
 * The additional buffers are only used if BOTH multisampling and node-picking are in use.
 * It is also safe to invoke this method if this is not the case.
 */
-(void) openPicking;

/**
 * Restores the rendering framework to normal rendering.
 *
 * If multisampling is active, the multisampling framebuffer is made active.
 *
 * It is safe to invoke this method even if multisampling is not active.
 */
-(void) closePicking;

@end
