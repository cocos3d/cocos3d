/*
 * CC3OpenGLES1Textures.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3OpenGLESTextures.h"
#import "CC3OpenGLES1Matrices.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTexEnvEnumeration

/**
 * CC3OpenGLES1StateTrackerTexEnvEnumeration tracks an enumerated GL state value for the texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES1StateTrackerTexEnvEnumeration : CC3OpenGLESStateTrackerEnumeration
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTexEnvColor

/**
 * CC3OpenGLES1StateTrackerTexEnvColor tracks a color GL state value for the texture environment.
 *
 * This implementation uses GL function glGetTexEnvfv to read the value from the
 * GL engine, and GL function glTexEnvfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 *
 */
@interface CC3OpenGLES1StateTrackerTexEnvColor : CC3OpenGLESStateTrackerColor
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTexEnvPointSpriteCapability

/**
 * CC3OpenGLES1StateTrackerTexEnvPointSpriteCapability tracks a boolean GL capability for
 * the point sprite texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES1StateTrackerTexEnvPointSpriteCapability : CC3OpenGLESStateTrackerTextureCapability
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTextureClientCapability

/**
 * CC3OpenGLES1StateTrackerTextureClientCapability tracks a boolean GL capability for
 * the point sprite texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES1StateTrackerTextureClientCapability : CC3OpenGLES1StateTrackerClientCapability
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexTexCoordsPointer

/**
 * CC3OpenGLES1StateTrackerVertexTexCoordsPointer tracks the parameters
 * of the vertex texture coordinates pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_TEXTURE_COORD_ARRAY_SIZE.
 *   - elementType uses GL name GL_TEXTURE_COORD_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_TEXTURE_COORD_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glTexCoordPointer method
 */
@interface CC3OpenGLES1StateTrackerVertexTexCoordsPointer : CC3OpenGLESStateTrackerVertexPointer
@end


#pragma mark -
#pragma mark CC3OpenGLES1TextureMatrixStack

/**
 * CC3OpenGLESMatrixStack provides access to several commands that operate
 * on the texture matrix stacks, none of which require state tracking.
 *
 * Even though this class does not track any state, it does rely on the
 * tracker for the matrix mode, to ensure that the matrix mode associated
 * with this matrix stack is active before calling a GL function.
 */
@interface CC3OpenGLES1TextureMatrixStack : CC3OpenGLES1MatrixStack
@end


#pragma mark -
#pragma mark CC3OpenGLES1TextureUnit

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1TextureUnit : CC3OpenGLESTextureUnit
@end


#pragma mark -
#pragma mark CC3OpenGLES1Textures

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1Textures : CC3OpenGLESTextures
@end

#endif

