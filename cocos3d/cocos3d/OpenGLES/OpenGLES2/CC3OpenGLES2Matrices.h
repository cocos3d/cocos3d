/*
 * CC3OpenGLES2Matrices.h
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


#import "CC3OpenGLESMatrices.h"
#import "CC3Matrix4x4.h"

#if CC3_OGLES_2

/** The initial maximum depth of a matrix stack under OpenGL ES 2. */
#define kCC3OpenGLES2MatrixStackMaxDepth		8

#pragma mark -
#pragma mark CC3OpenGLES2MatrixStack

/** Provides specialized behaviour for OpenGL ES 2 implementations. */
@interface CC3OpenGLES2MatrixStack : CC3OpenGLESMatrixStack {
	GLuint _depth;
	GLuint _maxDepth;
	CC3Matrix4x4* _mtxStack;
}
@end

#pragma mark -
#pragma mark CC3OpenGLES2Matrices

/** Provides specialized behaviour for OpenGL ES 2 implementations. */
@interface CC3OpenGLES2Matrices : CC3OpenGLESMatrices {
	CC3Matrix4x4 _viewMatrix;
	CC3Matrix4x4 _modelViewMatrix;
	CC3Matrix3x3 _modelViewInverseTransposeMatrix;
	CC3Matrix4x4 _projectionMatrix;
	CC3Matrix4x4 _modelViewProjectionMatrix;
	BOOL _modelViewInverseTransposeMatrixIsDirty : 1;
	BOOL _modelViewProjectionMatrixIsDirty : 1;
}
@end

#endif
