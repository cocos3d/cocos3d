/*
 * CC3OpenGLES11State.h
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


#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPointParameterFloat

/**
 * CC3OpenGLES11StateTrackerPointParameterFloat tracks a float GL point parameter state value.
 *
 * This implementation uses GL function glGetFloatv to read the value from the
 * GL engine, and GL function glPointParameterf to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerPointParameterFloat : CC3OpenGLES11StateTrackerFloat {}
@end


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
#pragma mark CC3OpenGLES11StateTrackerStencilFunction

/**
 * CC3OpenGLES11StateTrackerStencilFunction is a type of CC3OpenGLES11StateTrackerComposite
 * that tracks the stencil function, reference and mask GL state values.
 *
 * The function, reference and mask values are read from GL individually, using distinct 
 * primitive trackers for each value. All three values are set into the GL engine together
 * using a single call to the GL set function glStencilFunc.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and
 * will not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerStencilFunction : CC3OpenGLES11StateTrackerComposite {
	CC3OpenGLES11StateTrackerEnumeration* function;
	CC3OpenGLES11StateTrackerInteger* reference;
	CC3OpenGLES11StateTrackerInteger* mask;
}

/** Tracks the stencil function (GL get name GL_STENCIL_FUNC) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* function;

/** Tracks the stencil function reference value (GL get name GL_STENCIL_REF) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerInteger* reference;

/** Tracks the stencil function mask (GL get name GL_STENCIL_VALUE_MASK) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerInteger* mask;

/**
 * Sets the stencil function, reference, and mask values together. The values will
 * be set in the GL engine only if at least one of the values has actually changed.
 *
 * Uses the GL set function glStencilFunc to set the values in the GL engine.
 */
-(void) applyFunction: (GLenum) func
		 andReference: (GLint) refValue
			  andMask: (GLuint) maskValue;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerStencilOperation

/**
 * CC3OpenGLES11StateTrackerStencilOperation is a type of CC3OpenGLES11StateTrackerComposite
 * that tracks the stencil operations that occur when the stencil test fails, the depth test
 * fails, and the depth test passes.
 *
 * The fail, depthFail and depthPass values are read from GL individually, using distinct 
 * primitive trackers for each value. All three values are set into the GL engine together
 * using a single call to the GL set function glStencilOp.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and
 * will not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerStencilOperation : CC3OpenGLES11StateTrackerComposite {
	CC3OpenGLES11StateTrackerEnumeration* stencilFail;
	CC3OpenGLES11StateTrackerEnumeration* depthFail;
	CC3OpenGLES11StateTrackerEnumeration* depthPass;
}

/** Tracks the stencil operation when the stencil test fails (GL get name GL_STENCIL_FAIL) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* stencilFail;

/** Tracks the stencil operation when the depth test fails (GL get name GL_STENCIL_PASS_DEPTH_FAIL) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* depthFail;

/** Tracks the stencil operation when the depth test passes (GL get name GL_STENCIL_PASS_DEPTH_PASS) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* depthPass;

/**
 * Sets the stencil fail, depth fail, and depth pass values together. The values will
 * be set in the GL engine only if at least one of the values has actually changed.
 *
 * Uses the GL set function glStencilOp to set the values in the GL engine.
 */
-(void) applyStencilFail: (GLenum) failOp
			andDepthFail: (GLenum) zFailOp
			andDepthPass: (GLenum) zPassOp;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPolygonOffset

/**
 * CC3OpenGLES11StateTrackerPolygonOffset is a type of CC3OpenGLES11StateTrackerComposite
 * that tracks the polygon offset factor and units GL state values.
 *
 * The factor and units values are read from GL individually, using distinct primitive
 * trackers for each value. All three values are set into the GL engine together using
 * a single call to the GL set function glPolygonOffset.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerPolygonOffset : CC3OpenGLES11StateTrackerComposite {
	CC3OpenGLES11StateTrackerFloat* factor;
	CC3OpenGLES11StateTrackerFloat* units;
}

/** Tracks the offset factor value (GL get name GL_POLYGON_OFFSET_FACTOR) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* factor;

/** Tracks the offset units value (GL get name GL_POLYGON_OFFSET_UNITS) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* units;

/**
 * Sets the polygon offset factor and units values together. The values will
 * be set in the GL engine only if at least one of the values has actually changed.
 *
 * Uses the GL set function glPolygonOffset to set the values in the GL engine.
 */
-(void) applyFactor: (GLfloat) factorValue andUnits: (GLfloat) unitsValue;

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
	CC3OpenGLES11StateTrackerColor* clearColor;
	CC3OpenGLES11StateTrackerFloat* clearDepth;
	CC3OpenGLES11StateTrackerFloat* clearStencil;
	CC3OpenGLES11StateTrackerColorFixedAndFloat* color;
	CC3OpenGLES11StateTrackerColorFixedAndFloat* colorMask;
	CC3OpenGLES11StateTrackerEnumeration* cullFace;
	CC3OpenGLES11StateTrackerEnumeration* depthFunction;
	CC3OpenGLES11StateTrackerBoolean* depthMask;
	CC3OpenGLES11StateTrackerEnumeration* frontFace;
	CC3OpenGLES11StateTrackerFloat* lineWidth;
	CC3OpenGLES11StateTrackerFloat* pointSize;
	CC3OpenGLES11StateTrackerPointParameterVector* pointSizeAttenuation;
	CC3OpenGLES11StateTrackerPointParameterFloat* pointSizeFadeThreshold;
	CC3OpenGLES11StateTrackerPointParameterFloat* pointSizeMaximum;
	CC3OpenGLES11StateTrackerPointParameterFloat* pointSizeMinimum;
	CC3OpenGLES11StateTrackerPolygonOffset* polygonOffset;
	CC3OpenGLES11StateTrackerViewport* scissor;
	CC3OpenGLES11StateTrackerEnumeration* shadeModel;
	CC3OpenGLES11StateTrackerStencilFunction* stencilFunction;
	CC3OpenGLES11StateTrackerStencilOperation* stencilOperation;
	CC3OpenGLES11StateTrackerViewport* viewport;
}

/** Tracks color used to clear color buffer (GL get name GL_COLOR_CLEAR_VALUE and set function glClearColor). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerColor* clearColor;

/** Tracks value used to clear depth buffer (GL get name GL_DEPTH_CLEAR_VALUE and set function glClearDepthf). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* clearDepth;

/** Tracks value used to clear stencil buffer (GL get name GL_STENCIL_CLEAR_VALUE and set function glClearStencil). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* clearStencil;

/** Tracks drawing color (GL get name GL_CURRENT_COLOR and set function glColor4f and set fixed function glColor4ub). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerColorFixedAndFloat* color;

/** Tracks drawing color (GL get name GL_COLOR_WRITEMASK set fixed function glColorMask). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerColorFixedAndFloat* colorMask;

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

/** Tracks point size (GL get name GL_POINT_SIZE and set function glPointSize). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFloat* pointSize;

/** Tracks point distance attenuation (GL get name GL_POINT_DISTANCE_ATTENUATION and set function glPointParameterfv). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPointParameterVector* pointSizeAttenuation;

/** Tracks point fading threshold (GL get name GL_POINT_FADE_THRESHOLD_SIZE and set function glPointParameterf). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPointParameterFloat* pointSizeFadeThreshold;

/** Tracks maximum points size (GL get name GL_POINT_SIZE_MAX and set function glPointParameterf). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPointParameterFloat* pointSizeMaximum;

/** Tracks minimum points size (GL get name GL_POINT_SIZE_MIN and set function glPointParameterf). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPointParameterFloat* pointSizeMinimum;

/** Tracks polygon offset factor and units using set function glPolygonOffset). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPolygonOffset* polygonOffset;

/** Tracks viewport (GL get name GL_SCISSOR_BOX and set function glScissor). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerViewport* scissor;

/** Tracks shade model (GL get name GL_SHADE_MODEL and set function glShadeModel). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* shadeModel;

/** Tracks stencil function using set function glStencilFunc). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerStencilFunction* stencilFunction;

/** Tracks stencil operation using set function glStencilOp). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerStencilOperation* stencilOperation;

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
