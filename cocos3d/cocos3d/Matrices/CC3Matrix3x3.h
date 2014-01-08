/*
 * CC3Matrix3x3.h
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

#import "CC3Foundation.h"

/**
 * Returns the determinant of the specified 2x2 matrix values.
 *
 *   | a1 b1 |
 *   | a2 b2 |
 */
static inline GLfloat CC3Det2x2(GLfloat a1, GLfloat a2, GLfloat b1, GLfloat b2) {
	return a1 * b2 - b1 * a2;
}


#pragma mark -
#pragma mark CC3Matrix3x3 structure and functions

/** The number of GLfloat elements in a CC3Matrix3x3 structure. */
#define kCC3Matrix3x3ElementCount	9

/** The number of columns in a CC3Matrix3x3 structure. */
#define kCC3Matrix3x3ColumnCount	3

/** The number of rows in a CC3Matrix3x3 structure. */
#define kCC3Matrix3x3RowCount		3

/**
 * A structure representing a 3x3 matrix, with data stored in column-major order.
 *
 * CC3Matrix3x3 offers several ways to access the matrix content. Content can be accessed
 * by element array index, by element column and row number, or as column vectors.
 */
typedef union {
	/** The elements in array form. You can also simply cast the entire union to an array of GLfloats. */
	GLfloat elements[kCC3Matrix3x3ElementCount];
	
	/** The elements as zero-based indexed columns and rows. */
	GLfloat colRow[kCC3Matrix3x3ColumnCount][kCC3Matrix3x3RowCount];

	struct {
		GLfloat c1r1;		/**< The element at column 1, row 1 */
		GLfloat c1r2;		/**< The element at column 1, row 2 */
		GLfloat c1r3;		/**< The element at column 1, row 3 */
		
		GLfloat c2r1;		/**< The element at column 2, row 1 */
		GLfloat c2r2;		/**< The element at column 2, row 2 */
		GLfloat c2r3;		/**< The element at column 2, row 3 */
		
		GLfloat c3r1;		/**< The element at column 3, row 1 */
		GLfloat c3r2;		/**< The element at column 3, row 2 */
		GLfloat c3r3;		/**< The element at column 3, row 3 */
	};
	
	/** The three columns as zero-based indexed 3D vectors. */
	CC3Vector columns[kCC3Matrix3x3ColumnCount];

	struct {
		CC3Vector col1;		/**< The first column as a 3D vector. */
		CC3Vector col2;		/**< The second column as a 3D vector. */
		CC3Vector col3;		/**< The third column as a 3D vector. */
	};
} CC3Matrix3x3;

/** Returns a string description of the specified CC3Matrix3x3, including contents. */
NSString* NSStringFromCC3Matrix3x3(CC3Matrix3x3* mtxPtr);


#pragma mark Matrix population

// Static content for populating linear matrix as an identity matrix
static const CC3Matrix3x3 kCC3Matrix3x3Identity = { {1.0f, 0.0f, 0.0f,
													 0.0f, 1.0f, 0.0f,
													 0.0f, 0.0f, 1.0f} };

/** Returns whether the specified matrix is an identity matrix (ones on the diagonal, zeros elsewhere). */
static inline BOOL CC3Matrix3x3IsIdentity(const CC3Matrix3x3* mtx) {
	return (memcmp(mtx, &kCC3Matrix3x3Identity, sizeof(CC3Matrix3x3)) == 0);
}

/** Populates the specified matrix so that all elements are zero. */
static inline void CC3Matrix3x3PopulateZero(CC3Matrix3x3* mtx) {
	memset(mtx, 0, sizeof(CC3Matrix3x3));
}

/** Populates the specified matrix as an identity matrix (ones on the diagonal, zeros elsewhere). */
static inline void CC3Matrix3x3PopulateIdentity(CC3Matrix3x3* mtx) {
	memcpy(mtx, &kCC3Matrix3x3Identity, sizeof(CC3Matrix3x3));
}

/** Populates the specified matrix from the specified source matrix. */
static inline void CC3Matrix3x3PopulateFrom3x3(CC3Matrix3x3* mtx, const CC3Matrix3x3* mtxSrc) {
	memcpy(mtx, mtxSrc, sizeof(CC3Matrix3x3));
}

/**
 * Populates the specified matrix as a rotation around three axes, y (yaw), x (pitch) and z (roll),
 * in that order, from the specified Euler angle rotation. Each Euler angle is specified in degrees.
 *
 * This rotation places 'up' along the positive Y axis, which is the OpenGL ES default.
 */
void CC3Matrix3x3PopulateFromRotationYXZ(CC3Matrix3x3* mtx, CC3Vector aRotation);

/**
 * Populates the specified matrix as a rotation around three axes, z (roll), y (yaw), and x (pitch),
 * in that order, from the specified Euler angle rotation. Each Euler angle is specified in degrees.
 *
 * This rotation places 'up' along the positive Z axis, which is used by some commercial 3D editors.
 */
void CC3Matrix3x3PopulateFromRotationZYX(CC3Matrix3x3* mtx, CC3Vector aRotation);

/** Populates the specified matrix as a rotation around the X-axis, in degrees. */
void CC3Matrix3x3PopulateFromRotationX(CC3Matrix3x3* mtx, const GLfloat degrees);

/** Populates the specified matrix as a rotation around the Y-axis, in degrees. */
void CC3Matrix3x3PopulateFromRotationY(CC3Matrix3x3* mtx, const GLfloat degrees);

/** Populates the specified matrix as a rotation around the Z-axis, in degrees. */
void CC3Matrix3x3PopulateFromRotationZ(CC3Matrix3x3* mtx, const GLfloat degrees);

/** Populates the specified matrix from the specified quaternion. */
void CC3Matrix3x3PopulateFromQuaternion(CC3Matrix3x3* mtx, CC3Quaternion q);

/**
 * Populates the specified matrix so that it will transform a vector pointed down the negative
 * Z-axis to point in the specified forwardDirection, and transform the positive Y-axis to point
 * in the specified upDirection.
 */
void CC3Matrix3x3PopulateToPointTowards(CC3Matrix3x3* mtx, const CC3Vector fwdDirection, const CC3Vector upDirection);

/** Populates the specified matrix from the specified scale. */
void CC3Matrix3x3PopulateFromScale(CC3Matrix3x3* mtx, const CC3Vector aScale);


#pragma mark Accessing vector content

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in YXZ order, which is the OpenGL default.
 * Each element of the returned rotation vector represents an Euler angle in degrees.
 */
CC3Vector CC3Matrix3x3ExtractRotationYXZ(const CC3Matrix3x3* mtx);

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in ZYX order. Each element of the returned
 * rotation vector represents an Euler angle in degrees.
 */
CC3Vector CC3Matrix3x3ExtractRotationZYX(const CC3Matrix3x3* mtx);

/**
 * Extracts and returns a unit rotation quaternion from the specified matrix.
 *
 * This algorithm uses the technique of finding the largest combination of the diagonal elements
 * to select which quaternion element (w,x,y,z) to solve for from the diagonal, and then using
 * that value along with pairs of diagonally-opposite matrix elements to derive the other three
 * quaternion elements. For example, if we want to solve for the quaternion w value first:
 *   - sum of diagonal elements = c1r1 + c2r2 + c3r3 = (4w^2 - 1).
 *   - Therefore w = sqrt(c1r1 + c2r2 + c3r3 + 1) / 2.
 *   - And c3r2 - c2r3 = 4wx, therefore x = (c3r2 - c2r3) / 4w
 *   - And c1r3 - c3r1 = 4wy, therefore y = (c2r3 - c3r1) / 4w
 *   - And c3r1 - c1r2 = 4wz, therefore z = (c2r1 - c1r2) / 4w
 *
 * Similar equations exist for the other combinations of the diagonal elements. Selecting the largest
 * combination helps numerical stability and avoids divide-by-zeros and square roots of negative numbers.
 */
CC3Quaternion CC3Matrix3x3ExtractQuaternion(const CC3Matrix3x3* mtx);

/** Extracts and returns the 'forward' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix3x3ExtractForwardDirection(const CC3Matrix3x3* mtx) {
	return CC3VectorNegate(mtx->col3);
}

/** Extracts and returns the 'up' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix3x3ExtractUpDirection(const CC3Matrix3x3* mtx) { return mtx->col2; }

/** Extracts and returns the 'right' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix3x3ExtractRightDirection(const CC3Matrix3x3* mtx) { return mtx->col1; }


#pragma mark Matrix transformations

/** Multiplies mL on the left by mR on the right, and stores the result in mOut. */
void CC3Matrix3x3Multiply(CC3Matrix3x3* mOut, const CC3Matrix3x3* mL, const CC3Matrix3x3* mR);

/**
 * Rotates the specified matrix by the specified Euler angles in degrees. Rotation is performed
 * in YXZ order, which is the OpenGL default.
 *
 * Since this operation rotates a matrix that potentially already contains rotations, the new
 * rotation is performed first, followed by the rotation already contained within the specified
 * matrix elements. If the matrix rotations were performed first, the new rotation would be
 * performed in the rotated coordinate system defined by the matrix.
 *
 * In mathematical terms, the incoming rotation is converted to matrix form, and is
 * left-multiplied to the specified matrix elements. 
 */
static inline void CC3Matrix3x3RotateYXZBy(CC3Matrix3x3* mtx, CC3Vector aRotation) {
	CC3Matrix3x3 rotMtx, mRslt;
	CC3Matrix3x3PopulateFromRotationYXZ(&rotMtx, aRotation);
	CC3Matrix3x3Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix3x3PopulateFrom3x3(mtx, &mRslt);
}

/**
 * Rotates the specified matrix by the specified Euler angles in degrees. Rotation is performed
 * in ZYX order, which is used by some commercial 3D editors
 *
 * Since this operation rotates a matrix that potentially already contains rotations, the new
 * rotation is performed first, followed by the rotation already contained within the specified
 * matrix elements. If the matrix rotations were performed first, the new rotation would be
 * performed in the rotated coordinate system defined by the matrix.
 *
 * In mathematical terms, the incoming rotation is converted to matrix form, and is
 * left-multiplied to the specified matrix elements. 
 */
static inline void CC3Matrix3x3RotateZYXBy(CC3Matrix3x3* mtx, CC3Vector aRotation) {
	CC3Matrix3x3 rotMtx, mRslt;
	CC3Matrix3x3PopulateFromRotationZYX(&rotMtx, aRotation);
	CC3Matrix3x3Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix3x3PopulateFrom3x3(mtx, &mRslt);
}

/**
 * Rotates the specified matrix by the rotation specified in the given quaternion.
 *
 * Since this operation rotates a matrix that potentially already contains rotations, the new
 * rotation is performed first, followed by the rotation already contained within the specified
 * matrix elements. If the matrix rotations were performed first, the new rotation would be
 * performed in the rotated coordinate system defined by the matrix.
 *
 * In mathematical terms, the incoming rotation is converted to matrix form, and is
 * left-multiplied to the specified matrix elements.
 */
static inline void CC3Matrix3x3RotateByQuaternion(CC3Matrix3x3* mtx, CC3Quaternion aQuaternion) {
	CC3Matrix3x3 rotMtx, mRslt;
	CC3Matrix3x3PopulateFromQuaternion(&rotMtx, aQuaternion);
	CC3Matrix3x3Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix3x3PopulateFrom3x3(mtx, &mRslt);
}

/**
 * Scales the specified matrix in three dimensions by the specified scaling vector. Non-uniform
 * scaling can be achieved by specifying different values for each element of the scaling vector.
 */
static inline void CC3Matrix3x3ScaleBy(CC3Matrix3x3* mtx, CC3Vector aScale) {
	mtx->col1 = CC3VectorScaleUniform(mtx->col1, aScale.x);
	mtx->col2 = CC3VectorScaleUniform(mtx->col2, aScale.y);
	mtx->col3 = CC3VectorScaleUniform(mtx->col3, aScale.z);
}


#pragma mark Matrix operations

/**
 * Transforms the specified 3D vector using the specified matrix, and returns the transformed vector.
 *
 * The specified matrix and the original specified vector remain unchanged.
 */
CC3Vector CC3Matrix3x3TransformCC3Vector(const CC3Matrix3x3* mtx, CC3Vector v);

/**
 * Orthonormalizes the specified matrix, using a Gram-Schmidt process, and using the column
 * indicated by the specified column number as the starting point of the orthonormalization process.
 *
 * The specified column number should be between 1 and 3.
 *
 * Upon completion, each column in the specified matrix will be a unit vector that is
 * orthagonal to the other two columns.
 * 
 * Since the Gram-Schmidt process is biased towards the starting column, if this function
 * will be invoked repeatedly on the same matrix, it is recommended that the starting
 * column number be changed on each invocation of this function, to ensure that the starting
 * bias be averaged across each of the columns over the long term.
 */
void CC3Matrix3x3Orthonormalize(CC3Matrix3x3* mtx, NSUInteger startColNum);

/** Transposes the specified matrix. The contents of the matrix are changed. */
void CC3Matrix3x3Transpose(CC3Matrix3x3* mtx);

/**
 * Inverts the specified matrix by using the algorithm of calculating the classical
 * adjoint and dividing by the determinant. The contents of the matrix are changed.
 *
 * Not all matrices are invertable. Returns whether the matrix was inverted.
 * If this function returns NO, then the matrix was not inverted, and remains unchanged.
 *
 * Matrix inversion using the classical adjoint algorithm is computationally-expensive.
 * If it is known that the matrix contains only rotation, the inverse of the matrix is
 * equal to its transpose. In this case, use the CC3Matrix3x3InvertRigid function instead,
 * which is some 10 to 100 times faster than this function.
 */
BOOL CC3Matrix3x3InvertAdjoint(CC3Matrix3x3* mtx);

/**
 * Inverts the specified matrix using transposition. The contents of this matrix are changed.
 *
 * This function assumes that the matrix represents a rigid transformation, containing only
 * rotation. Use this function only if it is known that this is the case.
 *
 * Inversion of a rigid transform matrix via transposition is very fast, and is consistently
 * 10 to 100 times faster than the classical adjoint algorithm used in the CC3Matrix3x3InvertAdjoint
 * function. It is recommended that this function be used whenever possible.
 */
static inline void CC3Matrix3x3InvertRigid(CC3Matrix3x3* mtx) { CC3Matrix3x3Transpose(mtx); }

/**
 * Inverts the specified matrix by using the algorithm of calculating the classical adjoint and
 * dividing by the determinant, and then transposes the result. The contents of the matrix are changed.
 *
 * Not all matrices are invertable. Returns whether the matrix was inverted.
 * If this function returns NO, then the matrix was not inverted, and remains unchanged.
 *
 * Matrix inversion using the classical adjoint algorithm is computationally-expensive.
 * If it is known that the matrix contains only rotation, the inverse of the matrix is
 * equal to its transpose. In this case, use the CC3Matrix3x3InvertRigid function instead,
 * which is some 10 to 100 times faster than this function.
 */
static inline BOOL CC3Matrix3x3InvertAdjointTranspose(CC3Matrix3x3* mtx) {
	BOOL rslt = CC3Matrix3x3InvertAdjoint(mtx);
	if (rslt) CC3Matrix3x3Transpose(mtx);
	return rslt;
}

/**
 * Inverts the specified matrix using transposition, and then transposes the result.
 *
 * Since rigid inversion uses transposition, this operation amounts to two consecutive
 * transpositions, which leaves the original matrix as the result. Because of this,
 * this function actually does nothing to the specified matrix.
 */
static inline void CC3Matrix3x3InvertRigidTranspose(CC3Matrix3x3* mtx)  {}


