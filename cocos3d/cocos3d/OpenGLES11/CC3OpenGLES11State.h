/*
 * CC3OpenGLES11State.h
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
 */

/** @file */	// Doxygen marker


#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPointParameterVector

/**
 * CC3OpenGLES11StateTrackerPointParameterVector tracks a 3D vector GL point parameter state value.
 *
 * This implementation uses GL function glGetFloatv to read the value from the
 * GL engine, and GL function glPointParameterfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerPointParameterVector : CC3OpenGLES11StateTrackerVector {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11State

/**
 * CC3OpenGLES11State manages trackers that read and remember OpenGL ES 1.1 state
 * and restore that state when the close method is invoked.
 *
 * The originalValueHandling property of each contained tracker is set to
 * kCC3GLESStateOriginalValueReadOnceAndRestore, which will cause the state to be
 * automatically read once, on the first invocation of the open method, and to be
 * automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11State : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerColorFixedAndFloat* color;
	CC3OpenGLES11StateTrackerColor* clearColor;
	CC3OpenGLES11StateTrackerFloat* clearDepth;
	CC3OpenGLES11StateTrackerFloat* clearStencil;
	CC3OpenGLES11StateTrackerEnumeration* cullFace;
	CC3OpenGLES11StateTrackerEnumeration* depthFunction;
	CC3OpenGLES11StateTrackerBoolean* depthMask;
	CC3OpenGLES11StateTrackerEnumeration* frontFace;
	CC3OpenGLES11StateTrackerFloat* lineWidth;
	CC3OpenGLES11StateTrackerFloat* pointSize;
	CC3OpenGLES11StateTrackerPointParameterVector* pointSizeAttenuation;
	CC3OpenGLES11StateTrackerViewport* scissor;
	CC3OpenGLES11StateTrackerEnumeration* shadeModel;
	CC3OpenGLES11StateTrackerViewport* viewport;
}

/** Tracks drawing color (GL get name GL_CURRENT_COLOR and set function glColor4f and set fixed function glColor4ub). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerColorFixedAndFloat* color;

/** Tracks clear buffer color (GL get name GL_COLOR_CLEAR_VALUE and set function glClearColor). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerColor* clearColor;

/** Tracks clear buffer color (GL get name GL_DEPTH_CLEAR_VALUE and set function glClearDepthf). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* clearDepth;

/** Tracks clear buffer color (GL get name GL_STENCIL_CLEAR_VALUE and set function glClearStencil). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* clearStencil;

/** Tracks face culling (GL get name GL_CULL_FACE_MODE and set function glCullFace). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* cullFace;

/** Tracks depth function (GL get name GL_DEPTH_FUNC and set function glDepthFunc). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* depthFunction;

/** Tracks depth mask (GL get name GL_DEPTH_WRITEMASK and set function glDepthMask). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerBoolean* depthMask;

/** Tracks front face (GL get name GL_FRONT_FACE and set function glFrontFace). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* frontFace;

/** Tracks line width (GL get name GL_LINE_WIDTH and set function glLineWidth). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* lineWidth;

/** Tracks line width (GL get name GL_POINT_SIZE and set function glPointSize). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* pointSize;

/** Tracks line width (GL get name GL_POINT_DISTANCE_ATTENUATION and set function glPointParameterfv). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPointParameterVector* pointSizeAttenuation;

/** Tracks viewport (GL get name GL_SCISSOR_BOX and set function glScissor). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerViewport* scissor;

/** Tracks shade model (GL get name GL_SHADE_MODEL and set function glShadeModel). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* shadeModel;

/** Tracks viewport (GL get name GL_VIEWPORT and set function glViewport). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerViewport* viewport;

/**
 * Clears the buffers identified by the specified bitmask, which is a bitwise OR
 * combination of one or more of the following masks: GL_COLOR_BUFFER_BIT,
 * GL_DEPTH_BUFFER_BIT, and GL_STENCIL_BUFFER_BIT
 */
-(void) clearBuffers: (GLbitfield) mask;

/**
 * Clears the color buffer.
 *
 * This is a convenience method. To clear more than one buffer, use the clearBuffers:
 * method, passing in the buffers to clear, instead of invoking several distinct
 * clear*Buffer methods.
 */
-(void) clearColorBuffer;

/**
 * Clears the depth buffer.
 *
 * This is a convenience method. To clear more than one buffer, use the clearBuffers:
 * method, passing in the buffers to clear, instead of invoking several distinct
 * clear*Buffer methods.
 */
-(void) clearDepthBuffer;

/**
 * Clears the stencil buffer.
 *
 * This is a convenience method. To clear more than one buffer, use the clearBuffers:
 * method, passing in the buffers to clear, instead of invoking several distinct
 * clear*Buffer methods.
 */
-(void) clearStencilBuffer;

/**
 * Returns the color value of the pixel at the specified position in the GL color buffer.
 *
 * This method should be used with care, since it involves making a synchronous call to
 * query the state of the GL engine. This method will not return until the GL engine has
 * executed all previous drawing commands in the pipeline. Excessive use of this method
 * will reduce GL throughput and performance.
 */
-(ccColor4B) readPixelAt: (CGPoint) pixelPosition;

@end
