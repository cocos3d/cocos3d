/*
 * CC3OpenGLESMatrices.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3Matrix4x4.h"


#pragma mark -
#pragma mark CC3OpenGLESMatrixStack

/**
 * CC3OpenGLESMatrixStack provides access to several commands that operate
 * on one of the matrix stacks, none of which require state tracking.
 *
 * Even though this class does not track any state, it does rely on the
 * tracker for the matrix mode, to ensure that the matrix mode associated
 * with this matrix stack is active before calling a GL function.
 */
@interface CC3OpenGLESMatrixStack : CC3OpenGLESStateTracker

/** Activates this matrix mode, then pushes this matrix stack. */
-(void) push;

/** Activates this matrix mode, then pops this matrix stack. */
-(void) pop;

/** Loads the identity matrix onto the top of this matrix stack. */
-(void) identity;

/** Loads the specified matrix onto the top of this matrix stack. */
-(void) load: (CC3Matrix4x4*) mtx;

/**
 * Retrieves the matrix at the top of this matrix stack,
 * and populates the specified matrix with its contents.
 */
-(void) getTop: (CC3Matrix4x4*) mtx;

/** Multiplies the matrix at top of this matrix stack with the specified matrix. */
-(void) multiply: (CC3Matrix4x4*) mtx;

/** 
 * If this matrix stack is a palette matrix, loads this matrix palette from the current
 * modelview matrix. Does nothing if this matrix stack is not a palette matrix.
 */
-(void) loadFromModelView;

/** Returns the current depth this matrix stack. */
@property(nonatomic, readonly) GLuint depth;

/** 
 * Indicates the maximum depth this matrix stack.
 *
 * For OpenGL ES 1, this value is fixed by the platform and attempts to set it will be ignored.
 * For OpenGL ES 2, this value can be set. The initial value is kCC3OpenGLES2MatrixStackMaxDepth.
 */
@property(nonatomic, assign) GLuint maxDepth;

/** @deprecated Use depth property instead. */
-(GLuint) getDepth DEPRECATED_ATTRIBUTE;

/**
 * Callback method invoked automatically when the stack is changed.
 *
 * Invokes the stackChanged: method on the parent CC3OpenGLESMatrices instance.
 */
-(void) wasChanged;

@end


#pragma mark -
#pragma mark CC3OpenGLESMatrices

/** CC3OpenGLESMatrices manages trackers for matrix state. */
@interface CC3OpenGLESMatrices : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerEnumeration* mode;
	CC3OpenGLESMatrixStack* modelview;
	CC3OpenGLESMatrixStack* projection;
	CC3OpenGLESStateTrackerEnumeration* activePalette;
	CCArray* paletteMatrices;
}

/** Tracks matrix mode (GL get name GL_MATRIX_MODE and set function glMatrixMode). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* mode;

/** Manages the modelview matrix stack. */
@property(nonatomic, retain) CC3OpenGLESMatrixStack* modelview;

/** Manages the projection matrix stack. */
@property(nonatomic, retain) CC3OpenGLESMatrixStack* projection;

/** Tracks active palette matrix (GL get name not applicable and set function glCurrentPaletteMatrixOES). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* activePalette;

/**
 * Manages the palette of matrices.
 *
 * Do not access individual texture unit trackers through this property.
 * Use the paletteAt: method instead.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxPaletteMatrices.value.
 *
 * To conserve memory and processing, palette units are lazily allocated when
 * requested by the paletteAt: method. The array returned by this property will
 * initially be empty, and will subsequently contain a number of palette matrices
 * one more than the largest value passed to paletteAt:.
 */
@property(nonatomic, retain) CCArray* paletteMatrices;

/**
 * Returns the number of active palette matrices.
 *
 * This value will be between zero and the maximum number of palette matrices, as
 * determined from [CC3OpenGLESEngine engine].platform.maxPaletteMatrices.value.
 *
 * To conserve memory and processing, palette matrices are lazily allocated when
 * requested by the paletteAt: method. The value of this property will initially
 * be zero, and will subsequently be one more than the largest value passed to
 * paletteAt:.
 */
@property(nonatomic, readonly) GLuint paletteMatrixCount;

/**
 * Returns the tracker for the palette matrix with the specified index.
 *
 * The index parameter must be between zero and the number of available palette
 * matrices minus one, inclusive. The number of available palette matrices can be
 * retrieved from [CC3OpenGLESEngine engine].platform.maxPaletteMatrices.value.
 *
 * To conserve memory and processing, palette matrices are lazily allocated when
 * requested by this method.
 */
-(CC3OpenGLESMatrixStack*) paletteAt: (GLuint) index;


#pragma mark Accessing matrices

/** Callback invoked when the specified stack has changed. */
-(void) stackChanged: (CC3OpenGLESMatrixStack*) stack;

/** Returns a pointer to the current view matrix. */
-(CC3Matrix4x4*) viewMatrix;

/** Returns a pointer to the current model-view matrix. */
-(CC3Matrix4x4*) modelViewMatrix;

/** Returns a pointer to the inverse-transpose of the current model-view matrix. */
-(CC3Matrix3x3*) modelViewInverseTransposeMatrix;

/** Returns a pointer to the current projection matrix. */
-(CC3Matrix4x4*) projectionMatrix;

/** Returns a pointer to the current model-view projection matrix. */
-(CC3Matrix4x4*) modelViewProjectionMatrix;

@end
