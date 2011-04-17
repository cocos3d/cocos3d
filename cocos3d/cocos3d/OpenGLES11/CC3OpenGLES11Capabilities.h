/*
 * CC3OpenGLES11Capabilities.h
 *
 * cocos3d 0.5.4
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
#pragma mark CC3OpenGLES11StateTrackerCapability

/**
 * CC3OpenGLES11StateTrackerCapability tracks a boolean GL capability, indicating whether
 * the capability is enabled or disabled.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerCapability : CC3OpenGLES11StateTrackerBoolean {}

/** Enables the capability. This is the same as setting the value property to YES. */
-(void) enable;

/** Disables the capability. This is the same as setting the value property to NO. */
-(void) disable;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerServerCapability

/**
 * CC3OpenGLES11StateTrackerServerCapability is a type of CC3OpenGLES11StateTrackerCapability
 * that tracks a GL server capability.
 *
 * To change the GL value, this implementation uses GL functions glEnable and glDisable.
 */
@interface CC3OpenGLES11StateTrackerServerCapability : CC3OpenGLES11StateTrackerCapability {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerClientCapability

/**
 * CC3OpenGLES11StateTrackerClientCapability is a type of CC3OpenGLES11StateTrackerCapability
 * that tracks a GL client capability.
 *
 * To change the GL value, this implementation uses GL functions glEnableClientState
 * and glDisableClientState.
 */
@interface CC3OpenGLES11StateTrackerClientCapability : CC3OpenGLES11StateTrackerCapability {}
@end

	
#pragma mark -
#pragma mark CC3OpenGLES11ServerCapabilities
	
/**
 * CC3OpenGLES11ServerCapabilities manages trackers that read and remember OpenGL ES 1.1
 * server capabilities once, and restore that capability when the close method is invoked.
 */
@interface CC3OpenGLES11ServerCapabilities : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerServerCapability* alphaTest;
	CC3OpenGLES11StateTrackerServerCapability* blend;
	NSMutableArray* clipPlanes;
	CC3OpenGLES11StateTrackerServerCapability* colorLogicOp;
	CC3OpenGLES11StateTrackerServerCapability* colorMaterial;
	CC3OpenGLES11StateTrackerServerCapability* cullFace;
	CC3OpenGLES11StateTrackerServerCapability* depthTest;
	CC3OpenGLES11StateTrackerServerCapability* dither;
	CC3OpenGLES11StateTrackerServerCapability* fog;
	CC3OpenGLES11StateTrackerServerCapability* lighting;
	NSMutableArray* lights;
	CC3OpenGLES11StateTrackerServerCapability* lineSmooth;
	CC3OpenGLES11StateTrackerServerCapability* multisample;
	CC3OpenGLES11StateTrackerServerCapability* normalize;
	CC3OpenGLES11StateTrackerServerCapability* pointSmooth;
	CC3OpenGLES11StateTrackerServerCapability* pointSpriteOES;
	CC3OpenGLES11StateTrackerServerCapability* polygonOffsetFill;
	CC3OpenGLES11StateTrackerServerCapability* rescaleNormal;
	CC3OpenGLES11StateTrackerServerCapability* sampleAlphaToCoverage;
	CC3OpenGLES11StateTrackerServerCapability* sampleAlphaToOne;
	CC3OpenGLES11StateTrackerServerCapability* sampleCoverage;
	CC3OpenGLES11StateTrackerServerCapability* scissorTest;
	CC3OpenGLES11StateTrackerServerCapability* stencilTest;
	CC3OpenGLES11StateTrackerServerCapability* texture2D;
}

/** Tracks the alpha testing capability (GL capability name GL_ALPHA_TEST). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* alphaTest;

/** Tracks the blending capability (GL capability name GL_BLEND). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* blend;

/**
 * Tracks the capability for each clip plane (GL capability name GL_CLIP_PLANEi).
 *
 * Do not access individual clip plane trackers through this property.
 * Use the clipPlaneAt: method instead.
 *
 * The number of available clip planes is retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxClipPlanes.value.
 */
@property(nonatomic, retain) NSMutableArray* clipPlanes;

/** Tracks the color logic operation capability (GL capability name GL_COLOR_LOGIC_OP). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* colorLogicOp;

/** Tracks the color material capability (GL capability name GL_COLOR_MATERIAL). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* colorMaterial;

/** Tracks the face culling capability (GL capability name GL_CULL_FACE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* cullFace;

/** Tracks the depth testing capability (GL capability name GL_DEPTH_TEST). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* depthTest;

/** Tracks the dithering capability (GL capability name GL_DITHER). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* dither;

/** Tracks the fog capability (GL capability name GL_FOG). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* fog;

/** Tracks the lighting capability (GL capability name GL_LIGHTING). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* lighting;

/**
 * Tracks the capability for each light (GL capability name GL_LIGHTi).
 *
 * Do not access individual light trackers through this property.
 * Use the lightAt: method instead.
 *
 * The number of available lights is retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
@property(nonatomic, retain) NSMutableArray* lights;

/** Tracks the line smoothing capability (GL capability name GL_LINE_SMOOTH). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* lineSmooth;

/** Tracks the multi-sampling capability (GL capability name GL_MULTISAMPLE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* multisample;

/** Tracks the normalizing capability (GL capability name GL_NORMALIZE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* normalize;

/** Tracks the point smoothing capability (GL capability name GL_POINT_SMOOTH). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* pointSmooth;

/** Tracks the point sprite capability (GL capability name GL_POINT_SPRITE_OES). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* pointSpriteOES;

/** Tracks the polygon offset fill capability (GL capability name GL_POLYGON_OFFSET_FILL). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* polygonOffsetFill;

/** Tracks the rescale normals capability (GL capability name GL_RESCALE_NORMAL). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* rescaleNormal;

/** Tracks the sampling alpha coverage capability (GL capability name GL_SAMPLE_ALPHA_TO_COVERAGE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* sampleAlphaToCoverage;

/** Tracks the sampling alpha to one capability (GL capability name GL_SAMPLE_ALPHA_TO_ONE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* sampleAlphaToOne;

/** Tracks the sampling coverage capability (GL capability name GL_SAMPLE_COVERAGE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* sampleCoverage;

/** Tracks the scissor testing capability (GL capability name GL_SCISSOR_TEST). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* scissorTest;

/** Tracks the stencil testing capability (GL capability name GL_STENCIL_TEST). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* stencilTest;

/** Tracks the texturing capability (GL capability name GL_TEXTURE_2D). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* texture2D;

/**
 * Returns the tracker for the clip plane with the specified index.
 *
 * Index cpIndx corresponds to i in the GL capability name GL_CLIP_PLANEi, and must
 * be between zero and the number of available clip planes minus one, inclusive.
 *
 * The number of available clip planes can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxClipPlanes.value.
 */
-(CC3OpenGLES11StateTrackerServerCapability*) clipPlaneAt: (GLint) cpIndx;

/**
 * Returns the tracker for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
-(CC3OpenGLES11StateTrackerServerCapability*) lightAt: (GLint) ltIndx;

@end


#pragma mark -
#pragma mark CC3OpenGLES11ClientCapabilities

/**
 * CC3OpenGLES11ClientCapabilities manages trackers that read and remember OpenGL ES 1.1
 * client capabilities once, and restore that capability when the close method is invoked.
 */
@interface CC3OpenGLES11ClientCapabilities : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerServerCapability* colorArray;
	CC3OpenGLES11StateTrackerServerCapability* normalArray;
	CC3OpenGLES11StateTrackerServerCapability* pointSizeArrayOES;
	CC3OpenGLES11StateTrackerServerCapability* textureCoordArray;
	CC3OpenGLES11StateTrackerServerCapability* vertexArray;
}

/** Tracks the color array capability (GL capability name GL_COLOR_ARRAY). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* colorArray;

/** Tracks the normal array capability (GL capability name GL_NORMAL_ARRAY). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* normalArray;

/** Tracks the point size array capability (GL capability name GL_POINT_SIZE_ARRAY_OES). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* pointSizeArrayOES;

/** Tracks the texture coordinate array capability (GL capability name GL_TEXTURE_COORD_ARRAY). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* textureCoordArray;

/** Tracks the vertex array capability (GL capability name GL_VERTEX_ARRAY). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* vertexArray;

@end
