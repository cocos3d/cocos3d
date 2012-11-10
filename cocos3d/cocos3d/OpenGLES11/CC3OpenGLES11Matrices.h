/*
 * CC3OpenGLES11Matrices.h
 *
 * cocos3d 0.7.2
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


#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11MatrixStack

/**
 * CC3OpenGLES11MatrixStack provides access to several commands that operate
 * on one of the matrix stacks, none of which require state tracking.
 *
 * Even though this class does not track any state, it does rely on the
 * tracker for the matrix mode, to ensure that the matrix mode associated
 * with this matrix stack is active before calling a GL function.
 */
@interface CC3OpenGLES11MatrixStack : CC3OpenGLES11StateTracker {
	GLenum mode;
	GLenum topName;
	GLenum depthName;
	CC3OpenGLES11StateTrackerEnumeration* modeTracker;
}

/**
 * Activates the matrix mode for this matrix in GL, by setting the
 * value of the matrix mode tracker to the mode for this matrix stack.
 *
 * Most of the command methods will first invoke this method, to ensure
 * that the correct matrix mode is active before issuing a GL command
 * to operate on a matrix stack.
 */
-(void) activate;

/** Activates this matrix mode, then pushes this matrix stack. */
-(void) push;

/** Activates this matrix mode, then pops this matrix stack. */
-(void) pop;

/** Returns the depth this matrix stack. */
-(GLuint) getDepth;

/** Loads the identity matrix onto the top of this matrix stack. */
-(void) identity;

/** Loads the specified matrix onto the top of this matrix stack. */
-(void) load: (GLvoid*) glMatrix;

/**
 * Retrieves the matrix at the top of this matrix stack,
 * and populates the specified matrix with its contents.
 */
-(void) getTop: (GLvoid*) glMatrix;

/** Multiplies the matrix at top of this matrix stack with the specified matrix. */
-(void) multiply: (GLvoid*) glMatrix;

/**
 * Initializes this instance for the specified matrix mode.
 * The specified tName is used to query the matrix at the top of this matrix stack.
 * The specified dName is used to query the depth of this matrix stack.
 * The specified aModeTracker is used to ensure that the matrix mode of this matrix
 * is active before issuing any commands.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			withMode: (GLenum) matrixMode
		  andTopName: (GLenum) tName
		andDepthName: (GLenum) dName
	  andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker;

/**
 * Allocates and initializes an autoreleased instance for the specified matrix mode.
 * The specified tName is used to query the matrix at the top of this matrix stack.
 * The specified dName is used to query the depth of this matrix stack.
 * The specified aModeTracker is used to ensure that the matrix mode of this matrix
 * is active before issuing any commands.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   withMode: (GLenum) matrixMode
			 andTopName: (GLenum) tName
		   andDepthName: (GLenum) dName
		 andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker;

@end


#pragma mark -
#pragma mark CC3OpenGLES11MatrixPalette

/**
 * CC3OpenGLES11MatrixPalette provides access to several commands that operate on
 * one matrix the matrix palette. None of these commands require state tracking.
 *
 * Even though this class does not track any state, it does rely on the
 * tracker for the matrix mode, to ensure that the matrix mode associated
 * with this matrix stack is active before calling a GL function.
 */
@interface CC3OpenGLES11MatrixPalette : CC3OpenGLES11MatrixStack {
	GLuint index;
}

/** Loads this matrix palette from the current modelview matrix. */
-(void) loadFromModelView;

/**
 * Initializes this instance for the GL_MATRIX_PALETTE_OES matrix mode and specified
 * palette index. The specified aModeTracker is used to ensure that the matrix mode
 * of this matrix is active before issuing any commands.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
		  forPalette: (GLint) paletteIndex
	  andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker;

/**
 * Allocates and initializes an autoreleased instance for the GL_MATRIX_PALETTE_OES
 * matrix mode and specified palette index. The specified aModeTracker is used to
 * ensure that the matrix mode of this matrix is active before issuing any commands.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			 forPalette: (GLint) paletteIndex
		 andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker;

@end


#pragma mark -
#pragma mark CC3OpenGLES11Matrices

/** CC3OpenGLES11Matrices manages trackers for matrix state. */
@interface CC3OpenGLES11Matrices : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerEnumeration* mode;
	CC3OpenGLES11MatrixStack* modelview;
	CC3OpenGLES11MatrixStack* projection;
	CC3OpenGLES11StateTrackerEnumeration* activePalette;
	CCArray* paletteMatrices;
}

/** Tracks matrix mode (GL get name GL_MATRIX_MODE and set function glMatrixMode). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* mode;

/** Manages the modelview matrix stack. */
@property(nonatomic, retain) CC3OpenGLES11MatrixStack* modelview;

/** Manages the projection matrix stack. */
@property(nonatomic, retain) CC3OpenGLES11MatrixStack* projection;

/** Tracks active palette matrix (GL get name not applicable and set function glCurrentPaletteMatrixOES). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* activePalette;

/**
 * Manages the palette of matrices.
 *
 * Do not access individual texture unit trackers through this property.
 * Use the paletteAt: method instead.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxPaletteMatrices.value.
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
 * determined from [CC3OpenGLES11Engine engine].platform.maxPaletteMatrices.value.
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
 * retrieved from [CC3OpenGLES11Engine engine].platform.maxPaletteMatrices.value.
 *
 * To conserve memory and processing, palette matrices are lazily allocated when
 * requested by this method.
 */
-(CC3OpenGLES11MatrixPalette*) paletteAt: (GLuint) index;

@end
