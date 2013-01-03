/*
 * CC3OpenGLESCapabilities.h
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


#import "CC3OpenGLESStateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerCapability

/**
 * CC3OpenGLESStateTrackerCapability tracks a boolean GL capability, indicating whether
 * the capability is enabled or disabled.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerCapability : CC3OpenGLESStateTrackerBoolean {}

/** Enables the capability. This is the same as setting the value property to YES. */
-(void) enable;

/** Disables the capability. This is the same as setting the value property to NO. */
-(void) disable;

@end

	
#pragma mark -
#pragma mark CC3OpenGLESCapabilities
	
/**
 * CC3OpenGLESCapabilities manages trackers that read and remember OpenGL ES 1.1
 * server capabilities once, and restore that capability when the close method is invoked.
 */
@interface CC3OpenGLESCapabilities : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerCapability* alphaTest;
	CC3OpenGLESStateTrackerCapability* blend;
	CCArray* clipPlanes;
	CC3OpenGLESStateTrackerCapability* colorLogicOp;
	CC3OpenGLESStateTrackerCapability* colorMaterial;
	CC3OpenGLESStateTrackerCapability* cullFace;
	CC3OpenGLESStateTrackerCapability* depthTest;
	CC3OpenGLESStateTrackerCapability* dither;
	CC3OpenGLESStateTrackerCapability* fog;
	CC3OpenGLESStateTrackerCapability* lighting;
	CC3OpenGLESStateTrackerCapability* lineSmooth;
	CC3OpenGLESStateTrackerCapability* matrixPalette;
	CC3OpenGLESStateTrackerCapability* multisample;
	CC3OpenGLESStateTrackerCapability* normalize;
	CC3OpenGLESStateTrackerCapability* pointSmooth;
	CC3OpenGLESStateTrackerCapability* pointSprites;
	CC3OpenGLESStateTrackerCapability* polygonOffsetFill;
	CC3OpenGLESStateTrackerCapability* rescaleNormal;
	CC3OpenGLESStateTrackerCapability* sampleAlphaToCoverage;
	CC3OpenGLESStateTrackerCapability* sampleAlphaToOne;
	CC3OpenGLESStateTrackerCapability* sampleCoverage;
	CC3OpenGLESStateTrackerCapability* scissorTest;
	CC3OpenGLESStateTrackerCapability* stencilTest;
}

/** Tracks the alpha testing capability (GL capability name GL_ALPHA_TEST). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* alphaTest;

/** Tracks the blending capability (GL capability name GL_BLEND). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* blend;

/**
 * Tracks the capability for each clip plane (GL capability name GL_CLIP_PLANEi).
 *
 * Do not access individual clip plane trackers through this property.
 * Use the clipPlaneAt: method instead.
 *
 * The number of available clip planes is retrieved from
 * [CC3OpenGLESEngine engine].platform.maxClipPlanes.value.
 */
@property(nonatomic, retain) CCArray* clipPlanes;

/** Tracks the color logic operation capability (GL capability name GL_COLOR_LOGIC_OP). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* colorLogicOp;

/** Tracks the color material capability (GL capability name GL_COLOR_MATERIAL). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* colorMaterial;

/** Tracks the face culling capability (GL capability name GL_CULL_FACE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* cullFace;

/** Tracks the depth testing capability (GL capability name GL_DEPTH_TEST). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* depthTest;

/** Tracks the dithering capability (GL capability name GL_DITHER). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* dither;

/** Tracks the fog capability (GL capability name GL_FOG). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* fog;

/** Tracks the lighting capability (GL capability name GL_LIGHTING). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* lighting;

/** Tracks the line smoothing capability (GL capability name GL_LINE_SMOOTH). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* lineSmooth;

/** Tracks the matrix palette capability (GL capability name GL_MATRIX_PALETTE_OES). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* matrixPalette;

/** Tracks the multi-sampling capability (GL capability name GL_MULTISAMPLE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* multisample;

/** Tracks the normalizing capability (GL capability name GL_NORMALIZE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* normalize;

/** Tracks the point smoothing capability (GL capability name GL_POINT_SMOOTH). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* pointSmooth;

/** Tracks the point sprite capability (GL capability name GL_POINT_SPRITE_OES). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* pointSprites;

/** Tracks the polygon offset fill capability (GL capability name GL_POLYGON_OFFSET_FILL). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* polygonOffsetFill;

/** Tracks the rescale normals capability (GL capability name GL_RESCALE_NORMAL). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* rescaleNormal;

/** Tracks the sampling alpha coverage capability (GL capability name GL_SAMPLE_ALPHA_TO_COVERAGE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* sampleAlphaToCoverage;

/** Tracks the sampling alpha to one capability (GL capability name GL_SAMPLE_ALPHA_TO_ONE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* sampleAlphaToOne;

/** Tracks the sampling coverage capability (GL capability name GL_SAMPLE_COVERAGE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* sampleCoverage;

/** Tracks the scissor testing capability (GL capability name GL_SCISSOR_TEST). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* scissorTest;

/** Tracks the stencil testing capability (GL capability name GL_STENCIL_TEST). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* stencilTest;

/**
 * Returns the tracker for the clip plane with the specified index.
 *
 * Index cpIndx corresponds to i in the GL capability name GL_CLIP_PLANEi, and must
 * be between zero and the number of available clip planes minus one, inclusive.
 *
 * The number of available clip planes can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxClipPlanes.value.
 */
-(CC3OpenGLESStateTrackerCapability*) clipPlaneAt: (GLint) cpIndx;

@end
