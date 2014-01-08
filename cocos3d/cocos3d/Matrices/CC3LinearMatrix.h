/*
 * CC3LinearMatrix.h
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


#pragma mark CC3LinearMatrix

/**
 * CC3LinearMatrix is a 3x3 matrix that can represent 3D linear transforms such as rotation,
 * scaling, reflection and shearing. Matrices of this class cannot represent 3D translation.
 *
 * Internally, the dimensions of this matrix are three columns by three rows. Data is held in a
 * CC3Matrix3x3 structure of 9 GLfloat elements in column-major order. For situations requiring
 * only 3D linear transformations, this offers a storage savings over using a full 4x4 matrix.
 */
@interface CC3LinearMatrix : CC3Matrix {
	CC3Matrix3x3 _contents;
}


#pragma mark Population

/**
 * Populates this instance from the specified translation vector.
 * 
 * Since linear matrices are unaffected by translation, the effect of this method is to populate
 * this matrix as a identity matrix.
 */
-(void) populateFromTranslation: (CC3Vector) aTranslation;

/**
 * Populates this matrix so that it will transform a vector between the targetLocation and the eyeLocation
 * to point along the negative Z-axis, and transform the specified upDirection to the positive Y-axis.
 *
 * This transform works in the direction from model-space to view-space, and therefore includes an
 * implied inversion relative to the directToward:withUp: method. When applied to the camera, this
 * has the effect of locating the camera at the eyeLocation and pointing it at the targetLocation,
 * while orienting it so that 'up' appears to be in the upDirection, from the viewer's perspective.
 * 
 * Since linear matrices are unaffected by translation, this matrix will be populated to look in
 * the correct direction as if the eye were at the specified coordinate, but will not be looking
 * at the target location, as the matrix cannot be translated to the location of the eye. In order
 * to bring the targetLocation into view, this matrix must be applied to a matrix that can support
 * translation to the eyeLocation.
 */
-(void) populateToLookAt: (CC3Vector) targetLocation
			   withEyeAt: (CC3Vector) eyeLocation
				  withUp: (CC3Vector) upDirection;

/**
 * Populates this matrix as a perspective projection matrix with the specified frustum dimensions.
 *
 * Linear matrices cannot support perspective projection. This method throws an assertion exception.
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
 * Linear matrices cannot support perspective projection. This method throws an assertion exception.
 */
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near;

/**
 * Populates this matrix as a parallel orthographic matrix with the specified frustum dimensions.
 *
 * Linear matrices cannot support orthographic projection. This method throws an assertion exception.
 */
-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
							  andTop: (GLfloat) top  
						   andBottom: (GLfloat) bottom
							 andNear: (GLfloat) near
							  andFar: (GLfloat) far;

/**
 * Populates this matrix as an infinite-depth orthographic projection matrix with the specified
 * frustum dimensions, where the far clipping plane is set at an infinite distance.
 *
 * Linear matrices cannot support orthographic projection. This method throws an assertion exception.
 */
-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
							  andTop: (GLfloat) top  
						   andBottom: (GLfloat) bottom
							 andNear: (GLfloat) near;


#pragma mark Matrix operations

/**
 * Transforms the specified location vector using this matrix, and returns the transformed location.
 * 
 * Since linear matrices have no translation component, the location is transformed as if it
 * were a direction.
 *
 * This matrix and the original specified location remain unchanged.
 */
-(CC3Vector) transformLocation: (CC3Vector) aLocation;

/**
 * Transforms the specified homogeneous vector using this matrix, and returns the transformed vector.
 * 
 * Since linear matrices have no translation component, the vector is transformed as a direction,
 * regardless of the W component of the homogeneous vector. However, the W component of the returned
 * vector will be the same as that of the incoming vector.
 *
 * This matrix and the original specified homogeneous vector remain unchanged.
 */
-(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector;

@end

