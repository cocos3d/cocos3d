/*
 * CC3AffineMatrix.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3Matrix.h"

/**
 * CC3AffineMatrix is a 4x3 matrix that can represent affine transforms such as rotation,
 * scaling, reflection, shearing, and translation.
 *
 * Affine matrices differ from linear matrices in that affine matrices can perform
 * translation transformations.
 *
 * Internally, the dimensions of this matrix are four columns by three rows. Data is held in a
 * CC3Matrix4x3 structure of 12 GLfloat elements in column-major order. For situations requiring
 * only 3D affine transformations, this offers a storage savings over using a full 4x4 matrix.
 *
 * Although this matrix has only three rows, it behaves like a square matrix with four columns
 * and four rows, with the missing row always taken to contain (0, 0, 0, 1). Since all affine
 * transforms never change this last row, the requirement to store this last row is dropped in
 * order to reduce memory and calculation overhead. Where operations require this last row to
 * be present, it is temporarily generated automatically.
 */
@interface CC3AffineMatrix : CC3Matrix {
	CC3Matrix4x3 _contents;
}


#pragma mark Population

/**
 * Populates this matrix as a perspective projection matrix with the specified frustum dimensions.
 *
 * Affine matrices cannot support perspective projection. This method throws an assertion exception.
 */
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near
						 andFar: (GLfloat) far;

/**
 * Populates this matrix as an infinite-depth perspective projection matrix with the specified
 * frustum dimensions, where the far clipping plane is set at an infinite distance.
 *
 * Affine matrices cannot support perspective projection. This method throws an assertion exception.
 */
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near;

#pragma mark Matrix operations

/**
 * Transposes this matrix. The contents of this matrix are changed.
 *
 * Since the affine matrix does not store the fourth row, transposing an affine matrix will
 * result in the contents of the fourth column being lost. After the transposition, the
 * contents of both the forth column and the (implied) fourth row will contain (0,0,0,1).
 * 
 * If this is not the desired result, use the contents of this matrix to populate either an instance
 * of CC3ProjectionMatrix, or a CC3Matrix4x4 structure, and take the transpose of that matrix.
 */
-(void) transpose;

@end
