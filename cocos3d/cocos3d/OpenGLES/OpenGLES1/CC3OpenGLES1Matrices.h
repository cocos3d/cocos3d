/*
 * CC3OpenGLES1Matrices.h
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


#import "CC3OpenGLESMatrices.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1MatrixStack

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1MatrixStack : CC3OpenGLESMatrixStack {
	GLenum _mode;
	GLenum _topName;
	GLenum _depthName;
	CC3OpenGLESStateTrackerEnumeration* _modeTracker;
}

/**
 * Activates the matrix mode for this matrix in GL, by setting the
 * value of the matrix mode tracker to the mode for this matrix stack.
 *
 * Most of the command methods will first invoke this method, to ensure that the correct
 * matrix mode is active before issuing a GL command to operate on a matrix stack.
 */
-(void) activate;


#pragma mark Allocation and initialization

/**
 * Initializes this instance for the specified matrix mode.
 * The specified tName is used to query the matrix at the top of this matrix stack.
 * The specified dName is used to query the depth of this matrix stack.
 * The specified aModeTracker is used to ensure that the matrix mode of this matrix
 * is active before issuing any commands.
 */
-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			withMode: (GLenum) matrixMode
		  andTopName: (GLenum) tName
		andDepthName: (GLenum) dName
	  andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker;

/**
 * Allocates and initializes an autoreleased instance for the specified matrix mode.
 * The specified tName is used to query the matrix at the top of this matrix stack.
 * The specified dName is used to query the depth of this matrix stack.
 * The specified aModeTracker is used to ensure that the matrix mode of this matrix
 * is active before issuing any commands.
 */
+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   withMode: (GLenum) matrixMode
			 andTopName: (GLenum) tName
		   andDepthName: (GLenum) dName
		 andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker;

@end


#pragma mark -
#pragma mark CC3OpenGLES1MatrixPalette

/**
 * CC3OpenGLES1MatrixPalette provides access to several commands that operate on
 * one matrix the matrix palette. None of these commands require state tracking.
 *
 * Even though this class does not track any state, it does rely on the
 * tracker for the matrix mode, to ensure that the matrix mode associated
 * with this matrix stack is active before calling a GL function.
 */
@interface CC3OpenGLES1MatrixPalette : CC3OpenGLES1MatrixStack {
	GLuint _index;
}

/**
 * Initializes this instance for the GL_MATRIX_PALETTE_OES matrix mode and specified
 * palette index. The specified aModeTracker is used to ensure that the matrix mode
 * of this matrix is active before issuing any commands.
 */
-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
		  forPalette: (GLint) paletteIndex
	  andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker;

/**
 * Allocates and initializes an autoreleased instance for the GL_MATRIX_PALETTE_OES
 * matrix mode and specified palette index. The specified aModeTracker is used to
 * ensure that the matrix mode of this matrix is active before issuing any commands.
 */
+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			 forPalette: (GLint) paletteIndex
		 andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker;

@end


#pragma mark -
#pragma mark CC3OpenGLES1Matrices

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1Matrices : CC3OpenGLESMatrices {
	GLuint _maxPaletteSize;
}
@end

#endif
