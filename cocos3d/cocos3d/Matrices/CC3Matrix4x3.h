/*
 * CC3Matrix4x3.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3Matrix3x3.h"


#pragma mark -
#pragma mark CC3Matrix4x3 structure and functions

/** The number of GLfloat elements in a CC3Matrix4x3 structure. */
#define kCC3Matrix4x3ElementCount	12

/** The number of columns in a CC3Matrix4x3 structure. */
#define kCC3Matrix4x3ColumnCount	4

/** The number of rows in a CC3Matrix4x3 structure. */
#define kCC3Matrix4x3RowCount		3

/**
 * A structure representing a 4x3 matrix, with data stored in column-major order.
 *
 * This structure can be used to describe an affine 4x4, where the last row is always (0,0,0,1),
 * and can be left off for storage optimization, and recreated only when necessary.
 *
 * CC3Matrix4x3 offers several ways to access the matrix content. Content can be accessed
 * by element array index, by element column and row number, or as column vectors.
 */
typedef union {
	 /** The elements in array form. You can also simply cast the entire union to an array of GLfloats. */
	GLfloat elements[kCC3Matrix4x3ElementCount];
	
	/** The elements as zero-based indexed columns and rows. */
	GLfloat colRow[kCC3Matrix4x3ColumnCount][kCC3Matrix4x3RowCount];
	
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
		
		GLfloat c4r1;		/**< The element at column 4, row 1 */
		GLfloat c4r2;		/**< The element at column 4, row 2 */
		GLfloat c4r3;		/**< The element at column 4, row 3 */
	};
	
	/** The four columns as zero-based indexed 3D vectors. */
	CC3Vector columns[kCC3Matrix4x3ColumnCount];
	
	struct {
		CC3Vector col1;		/**< The first column as a 3D vector. */
		CC3Vector col2;		/**< The second column as a 3D vector. */
		CC3Vector col3;		/**< The third column as a 3D vector. */
		CC3Vector col4;		/**< The fourth column as a 3D vector. */
	};
} CC3Matrix4x3;

/** Returns a string description of the specified CC3Matrix4x3, including contents. */
static inline NSString* NSStringFromCC3Matrix4x3(CC3Matrix4x3* mtxPtr) {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"\n\t[%.6f, %.6f, %.6f, %.6f", mtxPtr->c1r1, mtxPtr->c2r1, mtxPtr->c3r1, mtxPtr->c4r1];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f", mtxPtr->c1r2, mtxPtr->c2r2, mtxPtr->c3r2, mtxPtr->c4r2];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f]", mtxPtr->c1r3, mtxPtr->c2r3, mtxPtr->c3r3, mtxPtr->c4r3];
	return desc;
}


#pragma mark Heterogeneous matrix population

/**
 * Populates the specified 3x3 matrix from the specified 4x3 matrix.
 * 
 * The fourth column is dropped.
 */
static inline void CC3Matrix3x3PopulateFrom4x3(CC3Matrix3x3* mtx, const CC3Matrix4x3* mtxSrc) {
	memcpy(mtx, mtxSrc, sizeof(CC3Matrix3x3));
}

/**
 * Populates the specified 4x3 matrix from the specified 3x3 matrix.
 *
 * A fourth column, containing (0,0,0) is added.
 */
static inline void CC3Matrix4x3PopulateFrom3x3(CC3Matrix4x3* mtx, const CC3Matrix3x3* mtxSrc) {
	memcpy(mtx, mtxSrc, sizeof(CC3Matrix3x3));
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/**
 * Copies the specified 3x3 matrix into the specified 4x3 matrix, without changing content
 * within the 4x3 matrix that is outside the first three rows and columns.
 *
 * The fourth column of the 4x3 matrix is left unchanged.
 */
static inline void CC3Matrix3x3CopyInto4x3(const CC3Matrix3x3* mtxSrc, CC3Matrix4x3* mtx) {
	memcpy(mtx, mtxSrc, sizeof(CC3Matrix3x3));
}


#pragma mark Matrix population

// Static content for populating linear matrix as an identity matrix (the literal formatted here is transposed)
static const CC3Matrix4x3 kCC3Matrix4x3Identity = { {1.0f, 0.0f, 0.0f,
													 0.0f, 1.0f, 0.0f,
													 0.0f, 0.0f, 1.0f,
													 0.0f, 0.0f, 0.0f} };

/** Returns whether the specified matrix is an identity matrix (ones on the diagonal, zeros elsewhere). */
static inline BOOL CC3Matrix4x3IsIdentity(const CC3Matrix4x3* mtx) {
	return (memcmp(mtx, &kCC3Matrix4x3Identity, sizeof(CC3Matrix4x3)) == 0);
}

/** Populates the specified matrix so that all elements are zero. */
static inline void CC3Matrix4x3PopulateZero(CC3Matrix4x3* mtx) {
	memset(mtx, 0, sizeof(CC3Matrix4x3));
}

/** Populates the specified matrix as an identity matrix (ones on the diagonal, zeros elsewhere). */
static inline void CC3Matrix4x3PopulateIdentity(CC3Matrix4x3* mtx) {
	memcpy(mtx, &kCC3Matrix4x3Identity, sizeof(CC3Matrix4x3));
}

/** Populates the specified matrix from the specified source matrix. */
static inline void CC3Matrix4x3PopulateFrom4x3(CC3Matrix4x3* mtx, const CC3Matrix4x3* mtxSrc) {
	memcpy(mtx, mtxSrc, sizeof(CC3Matrix4x3));
}

/**
 * Populates the specified matrix as a rotation around three axes, y (yaw), x (pitch) and z (roll),
 * in that order, from the specified Euler angle rotation. Each Euler angle is specified in degrees.
 *
 * This rotation places 'up' along the positive Y axis, which is the OpenGL ES default.
 */
static inline void CC3Matrix4x3PopulateFromRotationYXZ(CC3Matrix4x3* mtx, CC3Vector aRotation) {
	CC3Matrix3x3PopulateFromRotationYXZ((CC3Matrix3x3*)mtx, aRotation);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/**
 * Populates the specified matrix as a rotation around three axes, z (roll), y (yaw), and x (pitch),
 * in that order, from the specified Euler angle rotation. Each Euler angle is specified in degrees.
 *
 * This rotation places 'up' along the positive Z axis, which is used by some commercial 3D editors.
 */
static inline void CC3Matrix4x3PopulateFromRotationZYX(CC3Matrix4x3* mtx, CC3Vector aRotation) {
	CC3Matrix3x3PopulateFromRotationZYX((CC3Matrix3x3*)mtx, aRotation);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/** Populates the specified matrix as a rotation around the X-axis, in degrees. */
static inline void CC3Matrix4x3PopulateFromRotationX(CC3Matrix4x3* mtx, const GLfloat degrees) {
	CC3Matrix3x3PopulateFromRotationX((CC3Matrix3x3*)mtx, degrees);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/** Populates the specified matrix as a rotation around the Y-axis, in degrees. */
static inline void CC3Matrix4x3PopulateFromRotationY(CC3Matrix4x3* mtx, const GLfloat degrees) {
	CC3Matrix3x3PopulateFromRotationY((CC3Matrix3x3*)mtx, degrees);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/** Populates the specified matrix as a rotation around the Z-axis, in degrees. */
static inline void CC3Matrix4x3PopulateFromRotationZ(CC3Matrix4x3* mtx, const GLfloat degrees) {
	CC3Matrix3x3PopulateFromRotationZ((CC3Matrix3x3*)mtx, degrees);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/** Populates the specified matrix from the specified quaternion. */
static inline void CC3Matrix4x3PopulateFromQuaternion(CC3Matrix4x3* mtx, CC3Quaternion aQuaternion) {
	CC3Matrix3x3PopulateFromQuaternion((CC3Matrix3x3*)mtx, aQuaternion);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/**
 * Populates the specified matrix so that it will transform a vector pointed down the negative
 * Z-axis to point in the specified forwardDirection, and transform the positive Y-axis to point
 * in the specified upDirection.
 */
static inline void CC3Matrix4x3PopulateToPointTowards(CC3Matrix4x3* mtx, const CC3Vector fwdDirection, const CC3Vector upDirection) {
	CC3Matrix3x3PopulateToPointTowards((CC3Matrix3x3*)mtx, fwdDirection, upDirection);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/** Populates the specified matrix from the specified scale. */
static inline void CC3Matrix4x3PopulateFromScale(CC3Matrix4x3* mtx, const CC3Vector aScale) {
	CC3Matrix3x3PopulateFromScale((CC3Matrix3x3*)mtx, aScale);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/** Populates the specified matrix from the specified translation. */
static inline void CC3Matrix4x3PopulateFromTranslation(CC3Matrix4x3* mtx, const CC3Vector aTranslation) {
	CC3Matrix3x3PopulateIdentity((CC3Matrix3x3*)mtx);
	mtx->col4 = aTranslation;
}

/**
 * Populates the specified matrix as a orthographic projection matrix with the specified
 * frustum dimensions.
 */
static inline void CC3Matrix4x3PopulateOrthoFrustum(CC3Matrix4x3* mtx,
													const GLfloat left,
													const GLfloat right,
													const GLfloat top,
													const GLfloat bottom,
													const GLfloat near,
													const GLfloat far) {
	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	GLfloat ooDepth = 1.0f / (far - near);
	
	mtx->c1r1 = 2.0f * ooWidth;
	mtx->c1r2 = 0.0f;
	mtx->c1r3 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = 2.0f * ooHeight;
	mtx->c2r3 = 0.0f;
	
	mtx->c3r1 = 0.0f;
	mtx->c3r2 = 0.0f;
	mtx->c3r3 = -2.0f * ooDepth;
	
	mtx->c4r1 = -(right + left) * ooWidth;
	mtx->c4r2 = -(top + bottom) * ooHeight;
	mtx->c4r3 = -(far + near) * ooDepth;
}

/**
 * Populates the specified matrix as an infinite-depth orthographic projection matrix with the
 * specified frustum dimensions, where the far clipping plane is set at an infinite distance.
 */
static inline void CC3Matrix4x3PopulateInfiniteOrthoFrustum(CC3Matrix4x3* mtx,
															const GLfloat left,
															const GLfloat right,
															const GLfloat top,
															const GLfloat bottom,
															const GLfloat near) {
	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	
	mtx->c1r1 = 2.0f * ooWidth;
	mtx->c1r2 = 0.0f;
	mtx->c1r3 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = 2.0f * ooHeight;
	mtx->c2r3 = 0.0f;
	
	mtx->c3r1 = 0.0f;
	mtx->c3r2 = 0.0f;
	mtx->c3r3 = 0.0f;
	
	mtx->c4r1 = -(right + left) * ooWidth;
	mtx->c4r2 = -(top + bottom) * ooHeight;
	mtx->c4r3 = -1.0f;
}


#pragma mark Accessing vector content

/**
 * Returns the column at the specified index from the specified matrix, as a 3D vector
 * suitable for use in use with a 3x3 matrix.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector CC3VectorFromCC3Matrix4x3Col(const CC3Matrix4x3* mtx, NSUInteger colIdx) {
	return mtx->columns[--colIdx];	// Convert to zero-based.
}

/**
 * Returns the row at the specified index from the specified matrix, as a 3D vector suitable
 * for use in use with a 3x3 matrix. The returned vector contains the first 3 elements of the row.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector CC3VectorFromCC3Matrix4x3Row(const CC3Matrix4x3* mtx, NSUInteger rowIdx) {
	rowIdx--;	// Convert to zero-based.
	return cc3v(mtx->colRow[0][rowIdx], mtx->colRow[1][rowIdx], mtx->colRow[2][rowIdx]);
}

/**
 * Returns the column at the specified index from the specified matrix, as a 4D vector
 * suitable for use in use with a 4x4 matrix. The W component of the returned vector will be
 * zero for the first three columns, and one for the fourth column.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector4 CC3Vector4FromCC3Matrix4x3Col(const CC3Matrix4x3* mtx, NSUInteger colIdx) {
	GLfloat w = (colIdx == kCC3Matrix4x3ColumnCount) ? 1.0f : 0.0f;
	return CC3Vector4FromCC3Vector(mtx->columns[--colIdx], w);	// Convert to zero-based.
}

/**
 * Returns the row at the specified index from the specified matrix, as a 4D vector
 * suitable for use in use with a 4x4 matrix.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector4 CC3Vector4FromCC3Matrix4x3Row(const CC3Matrix4x3* mtx, NSUInteger rowIdx) {
	rowIdx--;	// Convert to zero-based.
	return CC3Vector4Make(mtx->colRow[0][rowIdx], mtx->colRow[1][rowIdx],
						  mtx->colRow[2][rowIdx], mtx->colRow[3][rowIdx]);
}

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in YXZ order, which is the OpenGL default.
 * Each element of the returned rotation vector represents an Euler angle in degrees.
 */
static inline CC3Vector CC3Matrix4x3ExtractRotationYXZ(const CC3Matrix4x3* mtx) {
	return CC3Matrix3x3ExtractRotationYXZ((CC3Matrix3x3*) mtx);
}

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in ZYX order. Each element of the returned
 * rotation vector represents an Euler angle in degrees.
 */
static inline CC3Vector CC3Matrix4x3ExtractRotationZYX(const CC3Matrix4x3* mtx) {
	return CC3Matrix3x3ExtractRotationZYX((CC3Matrix3x3*) mtx);
}

/**
 * Extracts and returns the rotation quaternion from the specified matrix.
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
static inline CC3Quaternion CC3Matrix4x3ExtractQuaternion(const CC3Matrix4x3* mtx) {
	return CC3Matrix3x3ExtractQuaternion((CC3Matrix3x3*) mtx);
}

/** Extracts and returns the 'forward' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix4x3ExtractForwardDirection(const CC3Matrix4x3* mtx) {
	return CC3Matrix3x3ExtractForwardDirection((CC3Matrix3x3*) mtx);
}

/** Extracts and returns the 'up' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix4x3ExtractUpDirection(const CC3Matrix4x3* mtx) {
	return CC3Matrix3x3ExtractUpDirection((CC3Matrix3x3*) mtx);
}

/** Extracts and returns the 'right' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix4x3ExtractRightDirection(const CC3Matrix4x3* mtx) {
	return CC3Matrix3x3ExtractRightDirection((CC3Matrix3x3*) mtx);
}


#pragma mark Matrix transformations

/** Multiplies mL on the left by mR on the right, and stores the result in mOut. */
static inline void CC3Matrix4x3Multiply(CC3Matrix4x3* mOut, const CC3Matrix4x3* mL, const CC3Matrix4x3* mR) {
	
	mOut->c1r1 = (mL->c1r1 * mR->c1r1) + (mL->c2r1 * mR->c1r2) + (mL->c3r1 * mR->c1r3);
	mOut->c1r2 = (mL->c1r2 * mR->c1r1) + (mL->c2r2 * mR->c1r2) + (mL->c3r2 * mR->c1r3);
	mOut->c1r3 = (mL->c1r3 * mR->c1r1) + (mL->c2r3 * mR->c1r2) + (mL->c3r3 * mR->c1r3);
	
	mOut->c2r1 = (mL->c1r1 * mR->c2r1) + (mL->c2r1 * mR->c2r2) + (mL->c3r1 * mR->c2r3);
	mOut->c2r2 = (mL->c1r2 * mR->c2r1) + (mL->c2r2 * mR->c2r2) + (mL->c3r2 * mR->c2r3);
	mOut->c2r3 = (mL->c1r3 * mR->c2r1) + (mL->c2r3 * mR->c2r2) + (mL->c3r3 * mR->c2r3);
	
	mOut->c3r1 = (mL->c1r1 * mR->c3r1) + (mL->c2r1 * mR->c3r2) + (mL->c3r1 * mR->c3r3);
	mOut->c3r2 = (mL->c1r2 * mR->c3r1) + (mL->c2r2 * mR->c3r2) + (mL->c3r2 * mR->c3r3);
	mOut->c3r3 = (mL->c1r3 * mR->c3r1) + (mL->c2r3 * mR->c3r2) + (mL->c3r3 * mR->c3r3);
	
	mOut->c4r1 = (mL->c1r1 * mR->c4r1) + (mL->c2r1 * mR->c4r2) + (mL->c3r1 * mR->c4r3) + mL->c4r1;
	mOut->c4r2 = (mL->c1r2 * mR->c4r1) + (mL->c2r2 * mR->c4r2) + (mL->c3r2 * mR->c4r3) + mL->c4r2;
	mOut->c4r3 = (mL->c1r3 * mR->c4r1) + (mL->c2r3 * mR->c4r2) + (mL->c3r3 * mR->c4r3) + mL->c4r3;
}

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
static inline void CC3Matrix4x3RotateYXZBy(CC3Matrix4x3* mtx, CC3Vector aRotation) {
	CC3Matrix4x3 rotMtx, mRslt;
	CC3Matrix4x3PopulateFromRotationYXZ(&rotMtx, aRotation);
	CC3Matrix4x3Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix4x3PopulateFrom4x3(mtx, &mRslt);
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
static inline void CC3Matrix4x3RotateZYXBy(CC3Matrix4x3* mtx, CC3Vector aRotation) {
	CC3Matrix4x3 rotMtx, mRslt;
	CC3Matrix4x3PopulateFromRotationZYX(&rotMtx, aRotation);
	CC3Matrix4x3Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix4x3PopulateFrom4x3(mtx, &mRslt);
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
static inline void CC3Matrix4x3RotateByQuaternion(CC3Matrix4x3* mtx, CC3Quaternion aQuaternion) {
	CC3Matrix4x3 rotMtx, mRslt;
	CC3Matrix4x3PopulateFromQuaternion(&rotMtx, aQuaternion);
	CC3Matrix4x3Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix4x3PopulateFrom4x3(mtx, &mRslt);
}

/**
 * Scales the specified matrix in three dimensions by the specified scaling vector. Non-uniform
 * scaling can be achieved by specifying different values for each element of the scaling vector.
 */
static inline void CC3Matrix4x3ScaleBy(CC3Matrix4x3* mtx, CC3Vector aScale) {
	mtx->col1 = CC3VectorScaleUniform(mtx->col1, aScale.x);
	mtx->col2 = CC3VectorScaleUniform(mtx->col2, aScale.y);
	mtx->col3 = CC3VectorScaleUniform(mtx->col3, aScale.z);
}

/** Translates the specified matrix in three dimensions by the specified translation vector. */
static inline void CC3Matrix4x3TranslateBy(CC3Matrix4x3* mtx, CC3Vector aTranslation) {
	mtx->c4r1 += CC3VectorDot(CC3VectorFromCC3Matrix4x3Row(mtx, 1), aTranslation);
	mtx->c4r2 += CC3VectorDot(CC3VectorFromCC3Matrix4x3Row(mtx, 2), aTranslation);
	mtx->c4r3 += CC3VectorDot(CC3VectorFromCC3Matrix4x3Row(mtx, 3), aTranslation);
}


#pragma mark Matrix operations

/**
 * Transforms the specified 4D vector using the specified matrix, and returns the transformed vector.
 *
 * The specified matrix and the original specified vector remain unchanged.
 */
static inline CC3Vector4 CC3Matrix4x3TransformCC3Vector4(const CC3Matrix4x3* mtx, CC3Vector4 v) {
	CC3Vector4 vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z) + (mtx->c4r1 * v.w);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z) + (mtx->c4r2 * v.w);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z) + (mtx->c4r3 * v.w);
	vOut.w = v.w;
	return vOut;
}

/**
 * Orthonormalizes the rotation component of the specified matrix, using a Gram-Schmidt process,
 * and using the column indicated by the specified column number as the starting point of the
 * orthonormalization process.
 *
 * The specified column number should be between 1 and 3.
 *
 * Upon completion, each of the first three columns in the specified matrix will be a unit
 * vector that is orthagonal to the other two columns.
 * 
 * Since the Gram-Schmidt process is biased towards the starting column, if this function
 * will be invoked repeatedly on the same matrix, it is recommended that the starting
 * column number be changed on each invocation of this function, to ensure that the starting
 * bias be averaged across each of the columns over the long term.
 */
static inline void CC3Matrix4x3Orthonormalize(CC3Matrix4x3* mtx, NSUInteger startColNum) {
	CC3Matrix3x3Orthonormalize((CC3Matrix3x3*)mtx, startColNum);
}

/**
 * Transposes the specified matrix. The contents of the matrix are changed.
 *
 * Since a 4x3 matrix is not square, transposing an affine matrix will result in the contents
 * of the fourth column being lost. After the transposition, the contents of both the forth
 * column and the (implied) fourth row will contain (0,0,0,1).
 * 
 * If this is not the desired result, use the contents of this matrix to populate a CC3Matrix4x4
 * structure, and take the transpose of that matrix.
 */
static inline void CC3Matrix4x3Transpose(CC3Matrix4x3* mtx) {
	CC3Matrix3x3Transpose((CC3Matrix3x3*)mtx);
	mtx->col4 = (CC3Vector){0.0f, 0.0f, 0.0f};
}

/**
 * Inverts the specified matrix by using the algorithm of calculating the classical
 * adjoint and dividing by the determinant. The contents of the matrix are changed.
 *
 * Not all matrices are invertable. Returns whether the matrix was inverted.
 * If this function returns NO, then the matrix was not inverted, and remains unchanged.
 *
 * Matrix inversion using the classical adjoint algorithm is computationally-expensive. If it is
 * known that the matrix contains only rotation and translation, use the CC3Matrix4x3InvertRigid
 * function instead, which is some 10 to 100 times faster than this function.
 *
 * For an affine matrix, we can invert the 3x3 linear matrix, and use it to transform
 * the negated translation vector:
 * 
 * M(-1) = |  L(-1)  -L(-1)(t) |
 *
 * where L(-1) is the inverted 3x3 linear matrix, and t is the translation vector,
 * both extracted from the 4x3 matrix.
 */
static inline BOOL CC3Matrix4x3InvertAdjoint(CC3Matrix4x3* mtx) {
	CC3Matrix3x3* linMtx = (CC3Matrix3x3*)mtx;
	BOOL didInvLinMtx = CC3Matrix3x3InvertAdjoint(linMtx);
	
	if (!didInvLinMtx) return NO;	// Some matrices can't be inverted
	
	mtx->col4 = CC3Matrix3x3TransformCC3Vector(linMtx, CC3VectorNegate(mtx->col4));
	
	return YES;
}

/**
 * Inverts the specified matrix using transposition. The contents of this matrix are changed.
 *
 * This function assumes that the matrix represents a rigid transformation, containing only
 * rotation and translation. Use this function only if it is known that this is the case.
 *
 * Inversion of a rigid transform matrix via transposition is very fast, and is consistently
 * 10 to 100 times faster than the classical adjoint algorithm used in the CC3Matrix4x3InvertAdjoint
 * function. It is recommended that this function be used whenever possible.
 *
 * For an affine matrix that contains only rigid transforms, we can invert the 3x3 linear
 * matrix by transposing it, and use it to transform the negated translation vector:
 * 
 * M(-1) = |  LT  -LT(t) |
 *
 * where LT is the transposed 3x3 linear matrix, and t is the translation vector, both extracted
 * from the 4x3 matrix. For a matrix containing only rigid transforms: L(-1) = LT,
 */
static inline void CC3Matrix4x3InvertRigid(CC3Matrix4x3* mtx) {
	CC3Matrix3x3* linMtx = (CC3Matrix3x3*)mtx;
	CC3Matrix3x3Transpose(linMtx);
	mtx->col4 = CC3Matrix3x3TransformCC3Vector(linMtx, CC3VectorNegate(mtx->col4));
}


