/*
 * CC3Matrix.h
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

#import "CC3Matrix4x4.h"

/**
 * CC3Matrix is the abstract base class for a mathematical matrix.
 *
 * Subclasses provide concrete implementations for a variety of matrix sizes and operations.
 * Providing a variety of matrix subclasses allows the size (and hence storage requirments)
 * of the matrix to be selected appropriately for each situation.
 *
 * All matrix functionaly is defined by this base class, and you can use this base class in
 * declarations, and then instantiate the appropriate subclass, depending on operational needs.
 *
 * Where a particular operation is not applicable to a subclass, the interface declaration for that
 * subclass will make note of the limitation. Depending on the nature of the operation, the subclass
 * may choose to silently ignore the request (eg- attempting to translate a linear matrix), will
 * provide limited functionality (eg- transposing an affine matrix), or, where the missing functionaly
 * might cause confusing or unpredictable results, will raise an assertion exception (eg- attempting
 * to apply a perspective projection to a linear or affine matrix).
 */
@interface CC3Matrix : NSObject <NSCopying> {
	BOOL _isIdentity : 1;
	BOOL _isRigid : 1;
	BOOL _isDirty : 1;
}

/** 
 * Indicates whether this matrix is an identity matrix.
 *
 * This can be useful for short-circuiting many otherwise consumptive calculations. For example,
 * matrix multiplication is not performed as a raw calculation if one of the matrices is an
 * identity matrix. In addition, transposition and inversion of an identity matrix are no-ops.
 *
 * This values is set to YES after the matrix is initialized or populated as an identity matrix,
 * or populated by an identity transform. It is set to NO whenever an operation is performed on
 * this matrix that no longer results in it being an identity matrix.
 *
 * This flag is only set to YES if the matrix is deliberately populated as an identity matrix.
 * It will not be set to YES if an operation results in the contents of this matrix matching
 * those of an identity matrix by accident.
 */
@property(nonatomic, readonly) BOOL isIdentity;

/** 
 * Indicates whether this matrix containes only rigid transforms.
 *
 * Rigid transforms are those that change the rotation and translation of the matrix, but do
 * not change the size or shape.
 *
 * This property is used to determine the method to use when inverting this matrix. If the matrix
 * contains only rigid transforms, this matrix can be inverted using an optimized algorithm.
 * 
 * This values is set to YES after the matrix is initialized or populated as an identity matrix,
 * or populated by an identity transform. It is set to NO whenever the matrix is transformed by
 * any operation that is not a rotation or translation.
 *
 * This flag is only set to YES if the matrix is deliberately populated as an identity matrix.
 * It will not be set to YES if an operation results in the contents of this matrix matching
 * those of an identity matrix by accident.
 */
@property(nonatomic, readonly) BOOL isRigid;

/**
 * Indicates whether this matrix needs to be populated with transform data.
 *
 * Matrices are populated from transform data, such as translation, rotation & scale data.
 * This property can be used to indicate that the transform data that populates this matrix
 * has changed and this matrix needs to be re-populated in order to represent that data.
 *
 * This property is provided as a convenience, for managing the population of this matrix.
 * This property is neither set, not used, by this matrix.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL isDirty;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with all elements populated as an identity matrix
 * (ones on the diagonal, zeros elsewhere).
 */
-(id) init;

/**
 * Allocates and initializes an autoreleased instance with all elements populated as an
 * identity matrix (ones on the diagonal, zeros elsewhere).
 */
+(id) matrix;

/**
 * Allocates and initializes an autoreleased instance constructed by multiplying the
 * specified matrices together, where, in the matrix multiplication equation, mL is
 * on the left, and mR is on the right (M = mL x mR).
 *
 * This is a convenience method, useful during development testing and verification.
 */
+(id) matrixByMultiplying: (CC3Matrix*) mL by: (CC3Matrix*) mR;


#pragma mark Population

/** Populates this instance so that all elements are zero. */
-(void) populateZero;

/** Populates this instance as an identity matrix (ones on the diagonal, zeros elsewhere). */
-(void) populateIdentity;

/**
 * Populates this instance from elements copied from the specified matrix instance.
 *
 * The elements of this matrix are populated from the specified matrix starting at the top-left
 * of both matrices. If either dimension of the specified matrix are smaller than this matrix,
 * the remaining elements of this matrix are populated as in an identity matrix.
 *
 * If the specified matrix is nil, it is treated as the identity matrix, and this
 * matrix will be populated as an identity matrix.
 */
-(void) populateFrom: (CC3Matrix*) aMatrix;

/**
 * Populates this matrix from the specified 3x3 matrix structure.
 *
 * The elements of this matrix are populated from the specified matrix structure starting at the
 * top-left of both matrices. If this matrix is larger than 3x3, the remaining elements of this
 * matrix are populated as in an identity matrix.
 */
-(void) populateFromCC3Matrix3x3: (CC3Matrix3x3*) mtx;

/**
 * Populates the specified 3x3 matrix structure from the contents of this matrix.
 *
 * The elements of the specified matrix structure are populated from this matrix starting at the
 * top-left of both matrices. If this matrix is larger than 3x3, the additional elements are ignored.
 */
-(void) populateCC3Matrix3x3: (CC3Matrix3x3*) mtx;

/**
 * Populates this matrix from the specified 4x3 matrix structure.
 *
 * The elements of this matrix are populated from the specified matrix structure starting at the
 * top-left of both matrices. If this matrix is smaller than 4x3, the additional elements are ignored.
 * If this matrix is larger than 4x3, the remaining elements of this matrix are populated as in an
 * identity matrix.
 */
-(void) populateFromCC3Matrix4x3: (CC3Matrix4x3*) mtx;

/**
 * Populates the specified 4x3 matrix structure from the contents of this matrix.
 *
 * The elements of the specified matrix structure are populated from this matrix starting at the
 * top-left of both matrices. If this matrix is larger than 4x3, the additional elements are ignored.
 * If this matrix is smaller than 4x3, the remaining elements of the specified matrix structure are
 * populated as in an idendity matrix.
 */
-(void) populateCC3Matrix4x3: (CC3Matrix4x3*) mtx;

/**
 * Populates this matrix from the specified 4x4 matrix structure.
 *
 * The elements of this matrix are populated from the specified matrix structure starting at the
 * top-left of both matrices. If this matrix is smaller than 4x4, the additional elements are ignored.
 */
-(void) populateFromCC3Matrix4x4: (CC3Matrix4x4*) mtx;

/**
 * Populates the specified 4x4 matrix structure from the contents of this matrix.
 *
 * The elements of the specified matrix structure are populated from this matrix starting at the
 * top-left of both matrices. If this matrix is smaller than 4x4, the remaining elements of the
 * specified matrix structure are populated as in an idendity matrix.
 */
-(void) populateCC3Matrix4x4: (CC3Matrix4x4*) mtx;

/**
 * Populates this instance from the specified rotation vector, containing three Euler angles,
 * each measured in degrees. Rotation is performed in YXZ order, which is the OpenGL default.
 *
 * The contents of this matrix will be the same as if this matrix were populated as an identity
 * matrix, and then transformed by the specified rotation. Elements that are not affected by
 * the specified rotation will be populated as in an identity matrix.
 */
-(void) populateFromRotation: (CC3Vector) aRotation;

/**
 * Populates this instance from the specified quaternion.
 *
 * The contents of this matrix will be the same as if this matrix were populated as an identity
 * matrix, and then transformed by the specified quaternion. Elements that are not affected by
 * the specified quaternion will be populated as in an identity matrix.
 */
-(void) populateFromQuaternion: (CC3Quaternion) aQuaternion;

/**
 * Populates this instance from specified scaling vector.
 *
 * The contents of this matrix will be the same as if this matrix were populated as an identity
 * matrix, and then transformed by the specified scale vector. Elements that are not affected by
 * the specified scale vector will be populated as in an identity matrix.
 */
-(void) populateFromScale: (CC3Vector) aScale;

/**
 * Populates this instance from the specified translation vector.
 *
 * The contents of this matrix will be the same as if this matrix were populated as an identity
 * matrix, and then transformed by the specified translation vector. Elements that are not affected
 * by the specified translation vector will be populated as in an identity matrix.
 * 
 * If this matrix is of a subclass type that does not support translation, this matrix will be
 * populated as an identity matrix.
 */
-(void) populateFromTranslation: (CC3Vector) aTranslation;

/**
 * Populates this matrix so that it will transform a vector pointed down the negative Z-axis to
 * point in the specified forwardDirection, and transforms the positive Y-axis to point in the
 * specified upDirection.
 *
 * When applied to a targetting object (such as a camera, light, gun, etc), this has the effect of
 * pointing that object in a direction and orienting it so that 'up' is in the upDirection.
 *
 * This method works in model-space, and does not include an implied inversion. So, when applied to
 * the camera, this matrix must be subsequently inverted to transform from model-space to view-space.
 */
-(void) populateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection;

/**
 * Populates this matrix so that it will transform a vector between the targetLocation and the eyeLocation
 * to point along the negative Z-axis, and transforms the specified upDirection to the positive Y-axis.
 *
 * This transform works in the direction from model-space to view-space, and therefore includes an
 * implied inversion relative to the directToward:withUp: method. When applied to the camera, this
 * has the effect of locating the camera at the eyeLocation and pointing it at the targetLocation,
 * while orienting it so that 'up' appears to be in the upDirection, from the viewer's perspective.
 * 
 * If this matrix is of a subclass type that does not support translation, this matrix will be
 * populated to look in the correct direction, but will not be looking at the target location,
 * as the matrix cannot be translated to the location of the eye.
 */
-(void) populateToLookAt: (CC3Vector) targetLocation
			   withEyeAt: (CC3Vector) eyeLocation
				  withUp: (CC3Vector) upDirection;

/**
 * Populates this matrix as a perspective projection matrix with the specified frustum dimensions.
 *
 * If this matrix is of a subclass type that does not support perspective projection, this method
 * will throw an assertion exception.
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
 * If this matrix is of a subclass type that does not support perspective projection, this method
 * will throw an assertion exception.
 */
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near;

/**
 * Populates this matrix as a parallel orthographic matrix with the specified frustum dimensions.
 *
 * If this matrix is of a subclass type that does not support orthographic projection, this
 * method will throw an assertion exception.
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
 * If this matrix is of a subclass type that does not support orthographic projection, this
 * method will throw an assertion exception.
 */
-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
							  andTop: (GLfloat) top  
						   andBottom: (GLfloat) bottom
							 andNear: (GLfloat) near;


#pragma mark Accessing content

/**
 * Extracts the rotation component of this matrix and returns it as an Euler rotation vector,
 * assuming the rotations should be applied in YXZ order, which is the OpenGL default.
 * Each element of the returned rotation vector represents an Euler angle in degrees.
 */
-(CC3Vector) extractRotation;

/** Extracts the rotation component of this matrix and returns it as a unit quaternion. */
-(CC3Quaternion) extractQuaternion;

/** Extracts and returns the 'forward' direction vector from the rotation component of this matrix. */
-(CC3Vector) extractForwardDirection;

/** Extracts and returns the 'up' direction vector from the rotation component of this matrix. */
-(CC3Vector) extractUpDirection;

/** Extracts and returns the 'right' direction vector from the rotation component of this matrix. */
-(CC3Vector) extractRightDirection;

/** Extracts and returns the translation vector from this matrix. */
-(CC3Vector) extractTranslation;


#pragma mark Matrix transformations
	
/**
 * Rotates this matrix by the specified amount. Each element of the rotation vector represents
 * an Euler angle in degrees, and rotation is performed in YXZ order, which is the OpenGL default.
 *
 * Since this matrix may potentially already contains rotations, the new rotation is performed
 * first, followed by the rotation already contained within this matrix. If the existing rotations
 * were performed first, the new rotation would be performed in the rotated coordinate system
 * defined by this matrix, which is almost always not the desired effect.
 *
 * In mathematical terms, the incoming rotation is converted to matrix form, and is
 * left-multiplied to this matrix. 
 */
-(void) rotateBy: (CC3Vector) aVector;

/**
 * Rotates this matrix by the rotation specified in the given quaternion.
 *
 * Since this matrix may potentially already contains rotations, the new rotation is performed
 * first, followed by the rotation already contained within this matrix. If the existing rotations
 * were performed first, the new rotation would be performed in the rotated coordinate system
 * defined by this matrix, which is almost always not the desired effect.
 *
 * In mathematical terms, the incoming rotation is converted to matrix form, and is
 * left-multiplied to this matrix. 
 */
-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion;

/**
 * Orthonormalizes the rotation component of this matrix, using a Gram-Schmidt process, and
 * using the column indicated by the specified column number as the starting point of the
 * orthonormalization process.
 *
 * The specified column number should be between 1 and 3.
 *
 * Upon completion, the first three elements of each of the first three columns in this matrix
 * will be a unit vector that is orthagonal to the first three elements of the other two columns.
 * 
 * Since the Gram-Schmidt process is biased towards the starting column, if this method will
 * be invoked repeatedly, it is recommended that the starting column number be changed on each
 * invocation of this method, to ensure that the starting bias be averaged across each of the
 * columns over the long term.
 */
-(void) orthonormalizeRotationStartingWith: (NSUInteger) startColNum;

/**
 * Scales this matrix in three dimensions by the specified scaling vector. Non-uniform scaling
 * can be achieved by specifying different values for each element of the scaling vector.
 */
-(void) scaleBy: (CC3Vector) aVector;

/**
 * Translates this matrix in three dimensions by the specified translation vector.
 * 
 * If this matrix is of a subclass type that does not support translation, this method will have no effect on the matrix.
 */
-(void) translateBy: (CC3Vector) aVector;


#pragma mark Matrix multiplication

/**
 * Multiplies this matrix by the specified matrix, where, in the matrix multiplication equation,
 * this matrix is on the left, and the specified matrix is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified matrix remain unchanged.
 *
 * If the specified matrix is nil, it is treated as an identity matrix, and this matrix remains unchanged.
 */
-(void) multiplyBy: (CC3Matrix*) aMatrix;

/**
 * Multiplies the specified 3x3 matrix structure by the contents of this matrix, where, in the matrix
 * multiplication equation, the specified 3x3 matrix structure is on the left and this matrix is on the right.
 *
 * The contents of the specified 3x3 matrix structure are changed. The contents of this matrix remain unchanged.
 */
-(void) multiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx;

/**
 * Multiplies the contents of this matrix by the specified 3x3 matrix structure, where, in the matrix
 * multiplication equation, this matrix is on the left and the specified 3x3 matrix structure is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified 3x3 matrix structure remain unchanged.
 */
-(void) multiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx;

/**
 * Multiplies the specified 4x3 matrix structure by the contents of this matrix, where, in the matrix
 * multiplication equation, the specified 4x3 matrix structure is on the left and this matrix is on the right.
 *
 * The contents of the specified 4x3 matrix structure are changed. The contents of this matrix remain unchanged.
 */
-(void) multiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx;

/**
 * Multiplies the contents of this matrix by the specified 4x3 matrix structure, where, in the matrix
 * multiplication equation, this matrix is on the left and the specified 4x3 matrix structure is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified 4x3 matrix structure remain unchanged.
 */
-(void) multiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx;

/**
 * Multiplies the specified 4x4 matrix structure by the contents of this matrix, where, in the matrix
 * multiplication equation, the specified 4x4 matrix structure is on the left and this matrix is on the right.
 *
 * The contents of the specified 4x4 matrix structure are changed. The contents of this matrix remain unchanged.
 */
-(void) multiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx;

/**
 * Multiplies the contents of this matrix by the specified 4x4 matrix structure, where, in the matrix
 * multiplication equation, this matrix is on the left and the specified 4x4 matrix structure is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified 4x4 matrix structure remain unchanged.
 */
-(void) multiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx;

/**
 * Multiplies this matrix by the specified matrix, where, in the matrix multiplication equation,
 * the specified matrix is on the left and this matrix is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified matrix remain unchanged.
 *
 * If the specified matrix is nil, it is treated as an identity matrix, and this matrix remains unchanged.
 */
-(void) leftMultiplyBy: (CC3Matrix*) aMatrix;

/**
 * Multiplies the specified 3x3 matrix structure by the contents of this matrix, where, in the matrix
 * multiplication equation, this matrix is on the left and the specified 3x3 matrix structure is on the right.
 *
 * The contents of the specified 3x3 matrix structure are changed. The contents of this matrix remain unchanged.
 */
-(void) leftMultiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx;

/**
 * Multiplies the contents of this matrix by the specified 3x3 matrix structure, where, in the matrix
 * multiplication equation, the specified 3x3 matrix structure is on the left and this matrix is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified 3x3 matrix structure remain unchanged.
 */
-(void) leftMultiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx;

/**
 * Multiplies the specified 4x3 matrix structure by the contents of this matrix, where, in the matrix
 * multiplication equation, this matrix is on the left and the specified 4x3 matrix structure is on the right.
 *
 * The contents of the specified 4x3 matrix structure are changed. The contents of this matrix remain unchanged.
 */
-(void) leftMultiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx;

/**
 * Multiplies the contents of this matrix by the specified 4x3 matrix structure, where, in the matrix
 * multiplication equation, the specified 4x3 matrix structure is on the left and this matrix is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified 4x3 matrix structure remain unchanged.
 */
-(void) leftMultiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx;

/**
 * Multiplies the specified 4x4 matrix structure by the contents of this matrix, where, in the matrix
 * multiplication equation, this matrix is on the left and the specified 4x4 matrix structure is on the right.
 *
 * The contents of the specified 4x4 matrix structure are changed. The contents of this matrix remain unchanged.
 */
-(void) leftMultiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx;

/**
 * Multiplies the contents of this matrix by the specified 4x4 matrix structure, where, in the matrix
 * multiplication equation, the specified 4x4 matrix structure is on the left and this matrix is on the right.
 *
 * The contents of this matrix are changed. The contents of the specified 4x4 matrix structure remain unchanged.
 */
-(void) leftMultiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx;


#pragma mark Matrix operations

/**
 * Transforms the specified location vector using this matrix, and returns the transformed location.
 *
 * If the matrix supports homogeneous coordinates, the fourth element of the location vector is
 * taken to have a value of one.
 *
 * This matrix and the original specified location vector remain unchanged.
 */
-(CC3Vector) transformLocation: (CC3Vector) aLocation;

/**
 * Transforms the specified direction vector using this matrix, and returns the transformed direction.
 *
 * If the matrix supports homogeneous coordinates, the fourth element of the location vector is
 * taken to have a value of zero.
 *
 * This matrix and the original specified location vector remain unchanged.
 */
-(CC3Vector) transformDirection: (CC3Vector) aDirection;

/**
 * Transforms the specified homogeneous vector using this matrix, and returns the transformed vector.
 *
 * This matrix and the original specified homogeneous vector remain unchanged.
 */
-(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector;

/**
 * Transforms the specified ray using this matrix, and returns the transformed ray.
 *
 * Since a ray is a composite of a location and a direction, this implementation invokes the
 * transformLocation: method on the location component of the ray, and the transformDirection:
 * method on the direction component of the ray.
 *
 * This matrix and the original specified direction vector remain unchanged.
 */
-(CC3Ray) transformRay: (CC3Ray) aRay;

/** Transposes this matrix. The contents of this matrix are changed. */
-(void) transpose;

/**
 * Inverts this matrix using the most appropriate and efficient algorithm. The contents of
 * this matrix are changed.
 *
 * Not all matrices are invertable. Returns whether this matrix was inverted. If this method
 * returns NO, then this matrix was not inverted, and its contents remain unchanged.
 *
 * Matrix inversion can be computationally-expensive. This method uses the value of the isRigid
 * property to determine the most appropriate algorithm to use. If the isRigid property has
 * a value of YES, this method will invoke the invertRigid method. If the isRigid property has
 * a value of NO, this method will invoke the invertAdjoint method.
 */
-(BOOL) invert;

/**
 * Inverts this matrix by using the algorithm of calculating the classical adjoint and dividing
 * by the determinant. The contents of the matrix are changed.
 *
 * Not all matrices are invertable. Returns whether this matrix was inverted. If this method
 * returns NO, then this matrix was not inverted, and its contents remain unchanged.
 *
 * Matrix inversion using the classical adjoint algorithm is computationally-expensive. If it
 * is known that the matrix contains only rotation and translation, consider using the invertRigid
 * method instead, which is consistently 10 to 100 times faster than this method.
 *
 * You can also use the invert method, which will use the invertRigid method if the isRigid property
 * has a value of YES, and this invertAdjoint method if the isRigid property has a value of NO.
 */
-(BOOL) invertAdjoint;

/**
 * Inverts this matrix using transposition and/or translation. The contents of this matrix are changed.
 *
 * This method assumes that the matrix represents a rigid transformation, containing only
 * rotation and/or translation. Use this method only if it is known that this is the case.
 *
 * Inversion of a rigid transform matrix can be accomplished very quickly using transposition
 * and translation, and this method is consistently 10 to 100 times faster than using the
 * invertAdjoint method. It is recommended that this method be used whenever possible.
 *
 * You can also use the invert method, which will use this invertRigid method if the isRigid property
 * has a value of YES, and the invertAdjoint method if the isRigid property has a value of NO.
 */
-(void) invertRigid;

@end
