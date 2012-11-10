/*
 * CC3Matrix4x4.h
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

#import "CC3Matrix4x3.h"


#pragma mark -
#pragma mark CC3Matrix4x4 structure and functions

/** The number of GLfloat elements in a CC3Matrix4x4 structure. */
#define kCC3Matrix4x4ElementCount	16

/** The number of columns in a CC3Matrix4x4 structure. */
#define kCC3Matrix4x4ColumnCount	4

/** The number of rows in a CC3Matrix4x4 structure. */
#define kCC3Matrix4x4RowCount		4

/**
 * Returns the determinant of the specified 3x3 matrix values.
 * 
 *  | a1 b1 c1 |
 *  | a2 b2 c2 |
 *  | a3 b3 c3 |
 */
static inline GLfloat CC3Det3x3(GLfloat a1, GLfloat a2, GLfloat a3,
							    GLfloat b1, GLfloat b2, GLfloat b3, 
							    GLfloat c1, GLfloat c2, GLfloat c3) {
	return	a1 * CC3Det2x2(b2, b3, c2, c3) -
	b1 * CC3Det2x2(a2, a3, c2, c3) +
	c1 * CC3Det2x2(a2, a3, b2, b3);
}

/**
 * A structure representing a 4x4 matrix, with data stored in column-major order.
 *
 * CC3Matrix4x4 offers several ways to access the matrix content. Content can be accessed
 * by element array index, by element column and row number, or as column vectors.
 */
typedef union {
	/** The elements in array form. You can also simply cast the entire union to an array of GLfloats. */
	GLfloat elements[kCC3Matrix4x4ElementCount];
	
	/** The elements as zero-based indexed columns and rows. */
	GLfloat colRow[kCC3Matrix4x4ColumnCount][kCC3Matrix4x4RowCount];

	struct {
		GLfloat c1r1;		/**< The element at column 1, row 1 */
		GLfloat c1r2;		/**< The element at column 1, row 2 */
		GLfloat c1r3;		/**< The element at column 1, row 3 */
		GLfloat c1r4;		/**< The element at column 1, row 4 */

		GLfloat c2r1;		/**< The element at column 2, row 1 */
		GLfloat c2r2;		/**< The element at column 2, row 2 */
		GLfloat c2r3;		/**< The element at column 2, row 3 */
		GLfloat c2r4;		/**< The element at column 2, row 4 */

		GLfloat c3r1;		/**< The element at column 3, row 1 */
		GLfloat c3r2;		/**< The element at column 3, row 2 */
		GLfloat c3r3;		/**< The element at column 3, row 3 */
		GLfloat c3r4;		/**< The element at column 3, row 4 */

		GLfloat c4r1;		/**< The element at column 4, row 1 */
		GLfloat c4r2;		/**< The element at column 4, row 2 */
		GLfloat c4r3;		/**< The element at column 4, row 3 */
		GLfloat c4r4;		/**< The element at column 3, row 4 */
	};
	
	/** The four columns as zero-based indexed 4D vectors. */
	CC3Vector4 columns[kCC3Matrix4x4ColumnCount];
	
	struct {
		CC3Vector4 col1;	/**< The first column as a 4D vector. */
		CC3Vector4 col2;	/**< The second column as a 4D vector. */
		CC3Vector4 col3;	/**< The third column as a 4D vector. */
		CC3Vector4 col4;	/**< The fourth column as a 4D vector. */
	};
} CC3Matrix4x4;

/** Returns a string description of the specified CC3Matrix4x4, including contents. */
static inline NSString* NSStringFromCC3Matrix4x4(CC3Matrix4x4* mtxPtr) {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"\n\t[%.6f, %.6f, %.6f, %.6f", mtxPtr->c1r1, mtxPtr->c2r1, mtxPtr->c3r1, mtxPtr->c4r1];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f", mtxPtr->c1r2, mtxPtr->c2r2, mtxPtr->c3r2, mtxPtr->c4r2];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f", mtxPtr->c1r3, mtxPtr->c2r3, mtxPtr->c3r3, mtxPtr->c4r3];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f]", mtxPtr->c1r4, mtxPtr->c2r4, mtxPtr->c3r4, mtxPtr->c4r4];
	return desc;
}


#pragma mark Heterogeneous matrix population

/**
 * Populates the specified 3x3 matrix from the specified 4x4 matrix.
 *
 * The fourth column and row are dropped.
 */
static inline void CC3Matrix3x3PopulateFrom4x4(CC3Matrix3x3* mtx, const CC3Matrix4x4* mtxSrc) {
	mtx->c1r1 = mtxSrc->c1r1;
	mtx->c1r2 = mtxSrc->c1r2;
	mtx->c1r3 = mtxSrc->c1r3;
	
	mtx->c2r1 = mtxSrc->c2r1;
	mtx->c2r2 = mtxSrc->c2r2;
	mtx->c2r3 = mtxSrc->c2r3;
	
	mtx->c3r1 = mtxSrc->c3r1;
	mtx->c3r2 = mtxSrc->c3r2;
	mtx->c3r3 = mtxSrc->c3r3;
}

/**
 * Populates the specified 4x3 matrix from the specified 4x4 matrix.
 * 
 * The fourth row is dropped.
 */
static inline void CC3Matrix4x3PopulateFrom4x4(CC3Matrix4x3* mtx, const CC3Matrix4x4* mtxSrc) {
	mtx->c1r1 = mtxSrc->c1r1;
	mtx->c1r2 = mtxSrc->c1r2;
	mtx->c1r3 = mtxSrc->c1r3;
	
	mtx->c2r1 = mtxSrc->c2r1;
	mtx->c2r2 = mtxSrc->c2r2;
	mtx->c2r3 = mtxSrc->c2r3;
	
	mtx->c3r1 = mtxSrc->c3r1;
	mtx->c3r2 = mtxSrc->c3r2;
	mtx->c3r3 = mtxSrc->c3r3;
	
	mtx->c4r1 = mtxSrc->c4r1;
	mtx->c4r2 = mtxSrc->c4r2;
	mtx->c4r3 = mtxSrc->c4r3;
}

/**
 * Populates the specified 4x4 matrix from the specified 3x3 matrix.
 *
 * A fourth column and row, each containing (0,0,0,1) are added.
 */
static inline void CC3Matrix4x4PopulateFrom3x3(CC3Matrix4x4* mtx, const CC3Matrix3x3* mtxSrc) {
	mtx->c1r1 = mtxSrc->c1r1;
	mtx->c1r2 = mtxSrc->c1r2;
	mtx->c1r3 = mtxSrc->c1r3;
	mtx->c1r4 = 0.0f;
	
	mtx->c2r1 = mtxSrc->c2r1;
	mtx->c2r2 = mtxSrc->c2r2;
	mtx->c2r3 = mtxSrc->c2r3;
	mtx->c2r4 = 0.0f;
	
	mtx->c3r1 = mtxSrc->c3r1;
	mtx->c3r2 = mtxSrc->c3r2;
	mtx->c3r3 = mtxSrc->c3r3;
	mtx->c3r4 = 0.0f;
	
	mtx->c4r1 = 0.0f;
	mtx->c4r2 = 0.0f;
	mtx->c4r3 = 0.0f;
	mtx->c4r4 = 1.0f;
}

/**
 * Copies the specified 3x3 matrix into the specified 4x4 matrix, without changing content
 * within the 4x4 matrix that is outside the first three rows and columns.
 *
 * The fourth column and fourth row of the 4x4 matrix are left unchanged.
 */
static inline void CC3Matrix3x3CopyInto4x4(const CC3Matrix3x3* mtxSrc, CC3Matrix4x4* mtx) {
	mtx->c1r1 = mtxSrc->c1r1;
	mtx->c1r2 = mtxSrc->c1r2;
	mtx->c1r3 = mtxSrc->c1r3;
	
	mtx->c2r1 = mtxSrc->c2r1;
	mtx->c2r2 = mtxSrc->c2r2;
	mtx->c2r3 = mtxSrc->c2r3;
	
	mtx->c3r1 = mtxSrc->c3r1;
	mtx->c3r2 = mtxSrc->c3r2;
	mtx->c3r3 = mtxSrc->c3r3;
}

/**
 * Populates the specified 4x4 matrix from the specified 4x3 matrix.
 *
 * A fourth row, containing (0,0,0,1) is added.
 */
static inline void CC3Matrix4x4PopulateFrom4x3(CC3Matrix4x4* mtx, const CC3Matrix4x3* mtxSrc) {
	mtx->c1r1 = mtxSrc->c1r1;
	mtx->c1r2 = mtxSrc->c1r2;
	mtx->c1r3 = mtxSrc->c1r3;
	mtx->c1r4 = 0.0f;
	
	mtx->c2r1 = mtxSrc->c2r1;
	mtx->c2r2 = mtxSrc->c2r2;
	mtx->c2r3 = mtxSrc->c2r3;
	mtx->c2r4 = 0.0f;
	
	mtx->c3r1 = mtxSrc->c3r1;
	mtx->c3r2 = mtxSrc->c3r2;
	mtx->c3r3 = mtxSrc->c3r3;
	mtx->c3r4 = 0.0f;
	
	mtx->c4r1 = mtxSrc->c4r1;
	mtx->c4r2 = mtxSrc->c4r2;
	mtx->c4r3 = mtxSrc->c4r3;
	mtx->c4r4 = 1.0f;
}

/**
 * Copies the specified 4x3 matrix into the specified 4x4 matrix, without changing content
 * within the 4x4 matrix that is outside the first three rows.
 *
 * The fourth row of the 4x4 matrix is left unchanged.
 */
static inline void CC3Matrix4x3CopyInto4x4(const CC3Matrix4x3* mtxSrc, CC3Matrix4x4* mtx) {
	mtx->c1r1 = mtxSrc->c1r1;
	mtx->c1r2 = mtxSrc->c1r2;
	mtx->c1r3 = mtxSrc->c1r3;
	
	mtx->c2r1 = mtxSrc->c2r1;
	mtx->c2r2 = mtxSrc->c2r2;
	mtx->c2r3 = mtxSrc->c2r3;
	
	mtx->c3r1 = mtxSrc->c3r1;
	mtx->c3r2 = mtxSrc->c3r2;
	mtx->c3r3 = mtxSrc->c3r3;
	
	mtx->c4r1 = mtxSrc->c4r1;
	mtx->c4r2 = mtxSrc->c4r2;
	mtx->c4r3 = mtxSrc->c4r3;
}


#pragma mark Matrix population

// Static content for populating linear matrix as an identity matrix.
static const CC3Matrix4x4 kCC3Matrix4x4Identity = { {1.0f, 0.0f, 0.0f, 0.0f,
	0.0f, 1.0f, 0.0f, 0.0f,
	0.0f, 0.0f, 1.0f, 0.0f,
	0.0f, 0.0f, 0.0f, 1.0f} };

/** Returns whether the specified matrix is an identity matrix (ones on the diagonal, zeros elsewhere). */
static inline BOOL CC3Matrix4x4IsIdentity(const CC3Matrix4x4* mtx) {
	return (memcmp(mtx, &kCC3Matrix4x4Identity, sizeof(CC3Matrix4x4)) == 0);
}

/** Populates the specified matrix so that all elements are zero. */
static inline void CC3Matrix4x4PopulateZero(CC3Matrix4x4* mtx) {
	memset(mtx, 0, sizeof(CC3Matrix4x4));
}

/** Populates the specified matrix as an identity matrix (ones on the diagonal, zeros elsewhere). */
static inline void CC3Matrix4x4PopulateIdentity(CC3Matrix4x4* mtx) {
	memcpy(mtx, &kCC3Matrix4x4Identity, sizeof(CC3Matrix4x4));
}

/** Populates the specified matrix from the specified source matrix. */
static inline void CC3Matrix4x4PopulateFrom4x4(CC3Matrix4x4* mtx, const CC3Matrix4x4* mtxSrc) {
	memcpy(mtx, mtxSrc, sizeof(CC3Matrix4x4));
}

/**
 * Populates the specified matrix as a rotation around three axes, y (yaw), x (pitch) and z (roll),
 * in that order, from the specified Euler angle rotation. Each Euler angle is specified in degrees.
 *
 * This rotation places 'up' along the positive Y axis, which is the OpenGL ES default.
 */
static inline void CC3Matrix4x4PopulateFromRotationYXZ(CC3Matrix4x4* mtx, CC3Vector aRotation) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFromRotationYXZ(&mtx3, aRotation);
	CC3Matrix4x4PopulateFrom3x3(mtx, &mtx3);
}

/**
 * Populates the specified matrix as a rotation around three axes, z (roll), y (yaw), and x (pitch),
 * in that order, from the specified Euler angle rotation. Each Euler angle is specified in degrees.
 *
 * This rotation places 'up' along the positive Z axis, which is used by some commercial 3D editors.
 */
static inline void CC3Matrix4x4PopulateFromRotationZYX(CC3Matrix4x4* mtx, CC3Vector aRotation) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFromRotationZYX(&mtx3, aRotation);
	CC3Matrix4x4PopulateFrom3x3(mtx, &mtx3);
}

/** Populates the specified matrix as a rotation around the X-axis, in degrees. */
static inline void CC3Matrix4x4PopulateFromRotationX(CC3Matrix4x4* mtx, const GLfloat degrees) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFromRotationX(&mtx3, degrees);
	CC3Matrix4x4PopulateFrom3x3(mtx, &mtx3);
}

/** Populates the specified matrix as a rotation around the Y-axis, in degrees. */
static inline void CC3Matrix4x4PopulateFromRotationY(CC3Matrix4x4* mtx, const GLfloat degrees) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFromRotationY(&mtx3, degrees);
	CC3Matrix4x4PopulateFrom3x3(mtx, &mtx3);
}

/** Populates the specified matrix as a rotation around the Z-axis, in degrees. */
static inline void CC3Matrix4x4PopulateFromRotationZ(CC3Matrix4x4* mtx, const GLfloat degrees) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFromRotationZ(&mtx3, degrees);
	CC3Matrix4x4PopulateFrom3x3(mtx, &mtx3);
}

/** Populates the specified matrix from the specified quaternion. */
static inline void CC3Matrix4x4PopulateFromQuaternion(CC3Matrix4x4* mtx, CC3Quaternion aQuaternion) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFromQuaternion(&mtx3, aQuaternion);
	CC3Matrix4x4PopulateFrom3x3(mtx, &mtx3);
}

/**
 * Populates the specified matrix so that it will transform a vector pointed down the negative
 * Z-axis to point in the specified forwardDirection, and transform the positive Y-axis to point
 * in the specified upDirection.
 */
static inline void CC3Matrix4x4PopulateToPointTowards(CC3Matrix4x4* mtx, const CC3Vector fwdDirection, const CC3Vector upDirection) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateToPointTowards(&mtx3, fwdDirection, upDirection);
	CC3Matrix4x4PopulateFrom3x3(mtx, &mtx3);
}

/** Populates the specified matrix from the specified scale. */
static inline void CC3Matrix4x4PopulateFromScale(CC3Matrix4x4* mtx, const CC3Vector aScale) {
	CC3Matrix4x4PopulateIdentity(mtx);
	mtx->c1r1 = aScale.x;
	mtx->c2r2 = aScale.y;
	mtx->c3r3 = aScale.z;
}

/** Populates the specified matrix from the specified translation. */
static inline void CC3Matrix4x4PopulateFromTranslation(CC3Matrix4x4* mtx, const CC3Vector aTranslation) {
	CC3Matrix4x4PopulateIdentity(mtx);
	mtx->c4r1 = aTranslation.x;
	mtx->c4r2 = aTranslation.y;
	mtx->c4r3 = aTranslation.z;
}

/**
 * Populates the specified matrix as a perspective projection matrix with the specified
 * frustum dimensions.
 */
static inline void CC3Matrix4x4PopulatePerspectiveFrustum(CC3Matrix4x4* mtx,
														  const GLfloat left,
														  const GLfloat right,
														  const GLfloat top,
														  const GLfloat bottom,
														  const GLfloat near,
														  const GLfloat far) {
	GLfloat twoNear = 2.0f * near;
	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	GLfloat ooDepth = 1.0f / (far - near);
	
	mtx->c1r1 = twoNear * ooWidth;
	mtx->c1r2 = 0.0f;
	mtx->c1r3 = 0.0f;
	mtx->c1r4 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = twoNear * ooHeight;
	mtx->c2r3 = 0.0f;
	mtx->c2r4 = 0.0f;
	
	mtx->c3r1 = (right + left) * ooWidth;
	mtx->c3r2 = (top + bottom) * ooHeight;
	mtx->c3r3 = -(far + near) * ooDepth;
	mtx->c3r4 = -1.0f;
	
	mtx->c4r1 = 0.0f;
	mtx->c4r2 = 0.0f;
	mtx->c4r3 = -(twoNear * far) * ooDepth;
	mtx->c4r4 = 0.0f;
}	

/**
 * Populates the specified matrix as an infinite-depth perspective projection matrix with the
 * specified frustum dimensions, where the far clipping plane is set at an infinite distance.
 */
static inline void CC3Matrix4x4PopulateInfinitePerspectiveFrustum(CC3Matrix4x4* mtx,
																  const GLfloat left,
																  const GLfloat right,
																  const GLfloat top,
																  const GLfloat bottom,
																  const GLfloat near) {
	GLfloat twoNear = 2.0f * near;
	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	
	GLfloat epsilon = 0.0f;
	
	mtx->c1r1 = twoNear * ooWidth;
	mtx->c1r2 = 0.0f;
	mtx->c1r3 = 0.0f;
	mtx->c1r4 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = twoNear * ooHeight;
	mtx->c2r3 = 0.0f;
	mtx->c2r4 = 0.0f;
	
	mtx->c3r1 = (right + left) * ooWidth;
	mtx->c3r2 = (top + bottom) * ooHeight;
	mtx->c3r3 = epsilon - 1.0f;
	mtx->c3r4 = -1.0f;
	
	mtx->c4r1 = 0.0f;
	mtx->c4r2 = 0.0f;
	mtx->c4r3 = near * (epsilon - 2);
	mtx->c4r4 = 0.0f;
}

/**
 * Populates the specified matrix as a orthographic projection matrix with the specified
 * frustum dimensions.
 */
static inline void CC3Matrix4x4PopulateOrthoFrustum(CC3Matrix4x4* mtx,
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
	mtx->c1r4 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = 2.0f * ooHeight;
	mtx->c2r3 = 0.0f;
	mtx->c2r4 = 0.0f;
	
	mtx->c3r1 = 0.0f;
	mtx->c3r2 = 0.0f;
	mtx->c3r3 = -2.0f * ooDepth;
	mtx->c3r4 = 0.0f;
	
	mtx->c4r1 = -(right + left) * ooWidth;
	mtx->c4r2 = -(top + bottom) * ooHeight;
	mtx->c4r3 = -(far + near) * ooDepth;
	mtx->c4r4 = 1.0f;
}

/**
 * Populates the specified matrix as an infinite-depth orthographic projection matrix with the
 * specified frustum dimensions, where the far clipping plane is set at an infinite distance.
 */
static inline void CC3Matrix4x4PopulateInfiniteOrthoFrustum(CC3Matrix4x4* mtx,
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
	mtx->c1r4 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = 2.0f * ooHeight;
	mtx->c2r3 = 0.0f;
	mtx->c2r4 = 0.0f;
	
	mtx->c3r1 = 0.0f;
	mtx->c3r2 = 0.0f;
	mtx->c3r3 = 0.0f;
	mtx->c3r4 = 0.0f;
	
	mtx->c4r1 = -(right + left) * ooWidth;
	mtx->c4r2 = -(top + bottom) * ooHeight;
	mtx->c4r3 = -1.0f;
	mtx->c4r4 = 1.0f;
}


#pragma mark Accessing vector content

/**
 * Returns the column at the specified index from the specified matrix, as a 3D vecto suitable for
 * use in use with a 3x3 matrix. The returned vector contains the first 3 elements of the column.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector CC3VectorFromCC3Matrix4x4Col(const CC3Matrix4x4* mtx, NSUInteger colIdx) {
	return CC3VectorFromTruncatedCC3Vector4(mtx->columns[--colIdx]);	// Convert to zero-based.
}

/**
 * Returns the row at the specified index from the specified matrix, as a 3D vector suitable
 * for use in use with a 3x3 matrix. The returned vector contains the first 3 elements of the row.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector CC3VectorFromCC3Matrix4x4Row(const CC3Matrix4x4* mtx, NSUInteger rowIdx) {
	rowIdx--;	// Convert to zero-based.
	return cc3v(mtx->colRow[0][rowIdx], mtx->colRow[1][rowIdx], mtx->colRow[2][rowIdx]);
}

/**
 * Returns the column at the specified index from the specified matrix, as a 4D vector suitable
 * for use in use with a 4x4 matrix.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector4 CC3Vector4FromCC3Matrix4x4Col(const CC3Matrix4x4* mtx, NSUInteger colIdx) {
	return mtx->columns[--colIdx];	// Convert to zero-based.
}

/**
 * Returns the row at the specified index from the specified matrix, as a 4D vector
 * suitable for use in use with a 4x4 matrix.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector4 CC3Vector4FromCC3Matrix4x4Row(const CC3Matrix4x4* mtx, NSUInteger rowIdx) {
	rowIdx--;	// Convert to zero-based.
	return CC3Vector4Make(mtx->colRow[0][rowIdx], mtx->colRow[1][rowIdx],
						  mtx->colRow[2][rowIdx], mtx->colRow[3][rowIdx]);
}

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in YXZ order, which is the OpenGL default.
 * Each element of the returned rotation vector represents an Euler angle in degrees.
 */
static inline CC3Vector CC3Matrix4x4ExtractRotationYXZ(const CC3Matrix4x4* mtx) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFrom4x4(&mtx3, mtx);
	return CC3Matrix3x3ExtractRotationYXZ(&mtx3);
}

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in ZYX order. Each element of the returned
 * rotation vector represents an Euler angle in degrees.
 */
static inline CC3Vector CC3Matrix4x4ExtractRotationZYX(const CC3Matrix4x4* mtx) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFrom4x4(&mtx3, mtx);
	return CC3Matrix3x3ExtractRotationZYX(&mtx3);
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
static inline CC3Quaternion CC3Matrix4x4ExtractQuaternion(const CC3Matrix4x4* mtx) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFrom4x4(&mtx3, mtx);
	return CC3Matrix3x3ExtractQuaternion(&mtx3);
}

/** Extracts and returns the 'forward' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix4x4ExtractForwardDirection(const CC3Matrix4x4* mtx) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFrom4x4(&mtx3, mtx);
	return CC3Matrix3x3ExtractForwardDirection(&mtx3);
}

/** Extracts and returns the 'up' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix4x4ExtractUpDirection(const CC3Matrix4x4* mtx) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFrom4x4(&mtx3, mtx);
	return CC3Matrix3x3ExtractUpDirection(&mtx3);
}

/** Extracts and returns the 'right' direction vector from the rotation component of the specified matrix. */
static inline CC3Vector CC3Matrix4x4ExtractRightDirection(const CC3Matrix4x4* mtx) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFrom4x4(&mtx3, mtx);
	return CC3Matrix3x3ExtractRightDirection(&mtx3);
}


#pragma mark Matrix transformations

/** Multiplies mL on the left by mR on the right, and stores the result in mOut. */
static inline void CC3Matrix4x4Multiply(CC3Matrix4x4* mOut, const CC3Matrix4x4* mL, const CC3Matrix4x4* mR) {
	
	mOut->c1r1 = (mL->c1r1 * mR->c1r1) + (mL->c2r1 * mR->c1r2) + (mL->c3r1 * mR->c1r3) + (mL->c4r1 * mR->c1r4);
	mOut->c1r2 = (mL->c1r2 * mR->c1r1) + (mL->c2r2 * mR->c1r2) + (mL->c3r2 * mR->c1r3) + (mL->c4r2 * mR->c1r4);
	mOut->c1r3 = (mL->c1r3 * mR->c1r1) + (mL->c2r3 * mR->c1r2) + (mL->c3r3 * mR->c1r3) + (mL->c4r3 * mR->c1r4);
	mOut->c1r4 = (mL->c1r4 * mR->c1r1) + (mL->c2r4 * mR->c1r2) + (mL->c3r4 * mR->c1r3) + (mL->c4r4 * mR->c1r4);
	
	mOut->c2r1 = (mL->c1r1 * mR->c2r1) + (mL->c2r1 * mR->c2r2) + (mL->c3r1 * mR->c2r3) + (mL->c4r1 * mR->c2r4);
	mOut->c2r2 = (mL->c1r2 * mR->c2r1) + (mL->c2r2 * mR->c2r2) + (mL->c3r2 * mR->c2r3) + (mL->c4r2 * mR->c2r4);
	mOut->c2r3 = (mL->c1r3 * mR->c2r1) + (mL->c2r3 * mR->c2r2) + (mL->c3r3 * mR->c2r3) + (mL->c4r3 * mR->c2r4);
	mOut->c2r4 = (mL->c1r4 * mR->c2r1) + (mL->c2r4 * mR->c2r2) + (mL->c3r4 * mR->c2r3) + (mL->c4r4 * mR->c2r4);
	
	mOut->c3r1 = (mL->c1r1 * mR->c3r1) + (mL->c2r1 * mR->c3r2) + (mL->c3r1 * mR->c3r3) + (mL->c4r1 * mR->c3r4);
	mOut->c3r2 = (mL->c1r2 * mR->c3r1) + (mL->c2r2 * mR->c3r2) + (mL->c3r2 * mR->c3r3) + (mL->c4r2 * mR->c3r4);
	mOut->c3r3 = (mL->c1r3 * mR->c3r1) + (mL->c2r3 * mR->c3r2) + (mL->c3r3 * mR->c3r3) + (mL->c4r3 * mR->c3r4);
	mOut->c3r4 = (mL->c1r4 * mR->c3r1) + (mL->c2r4 * mR->c3r2) + (mL->c3r4 * mR->c3r3) + (mL->c4r4 * mR->c3r4);
	
	mOut->c4r1 = (mL->c1r1 * mR->c4r1) + (mL->c2r1 * mR->c4r2) + (mL->c3r1 * mR->c4r3) + (mL->c4r1 * mR->c4r4);
	mOut->c4r2 = (mL->c1r2 * mR->c4r1) + (mL->c2r2 * mR->c4r2) + (mL->c3r2 * mR->c4r3) + (mL->c4r2 * mR->c4r4);
	mOut->c4r3 = (mL->c1r3 * mR->c4r1) + (mL->c2r3 * mR->c4r2) + (mL->c3r3 * mR->c4r3) + (mL->c4r3 * mR->c4r4);
	mOut->c4r4 = (mL->c1r4 * mR->c4r1) + (mL->c2r4 * mR->c4r2) + (mL->c3r4 * mR->c4r3) + (mL->c4r4 * mR->c4r4);
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
static inline void CC3Matrix4x4RotateYXZBy(CC3Matrix4x4* mtx, CC3Vector aRotation) {
	CC3Matrix4x4 rotMtx, mRslt;
	CC3Matrix4x4PopulateFromRotationYXZ(&rotMtx, aRotation);
	CC3Matrix4x4Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix4x4PopulateFrom4x4(mtx, &mRslt);
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
static inline void CC3Matrix4x4RotateZYXBy(CC3Matrix4x4* mtx, CC3Vector aRotation) {
	CC3Matrix4x4 rotMtx, mRslt;
	CC3Matrix4x4PopulateFromRotationZYX(&rotMtx, aRotation);
	CC3Matrix4x4Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix4x4PopulateFrom4x4(mtx, &mRslt);
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
static inline void CC3Matrix4x4RotateByQuaternion(CC3Matrix4x4* mtx, CC3Quaternion aQuaternion) {
	CC3Matrix4x4 rotMtx, mRslt;
	CC3Matrix4x4PopulateFromQuaternion(&rotMtx, aQuaternion);
	CC3Matrix4x4Multiply(&mRslt, &rotMtx, mtx);
	CC3Matrix4x4PopulateFrom4x4(mtx, &mRslt);
}

/**
 * Scales the specified matrix in three dimensions by the specified scaling vector. Non-uniform
 * scaling can be achieved by specifying different values for each element of the scaling vector.
 */
static inline void CC3Matrix4x4ScaleBy(CC3Matrix4x4* mtx, CC3Vector aScale) {
	mtx->col1 = CC3Vector4ScaleUniform(mtx->col1, aScale.x);
	mtx->col2 = CC3Vector4ScaleUniform(mtx->col2, aScale.y);
	mtx->col3 = CC3Vector4ScaleUniform(mtx->col3, aScale.z);
}

/** Translates the specified matrix in three dimensions by the specified translation vector. */
static inline void CC3Matrix4x4TranslateBy(CC3Matrix4x4* mtx, CC3Vector aTranslation) {
	mtx->c4r1 += CC3VectorDot(CC3VectorFromCC3Matrix4x4Row(mtx, 1), aTranslation);
	mtx->c4r2 += CC3VectorDot(CC3VectorFromCC3Matrix4x4Row(mtx, 2), aTranslation);
	mtx->c4r3 += CC3VectorDot(CC3VectorFromCC3Matrix4x4Row(mtx, 3), aTranslation);
}


#pragma mark Matrix operations

/**
 * Transforms the specified 4D vector using the specified matrix, and returns the transformed vector.
 *
 * The specified matrix and the original specified vector remain unchanged.
 */
static inline CC3Vector4 CC3Matrix4x4TransformCC3Vector4(const CC3Matrix4x4* mtx, CC3Vector4 v) {
	CC3Vector4 vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z) + (mtx->c4r1 * v.w);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z) + (mtx->c4r2 * v.w);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z) + (mtx->c4r3 * v.w);
	vOut.w = (mtx->c1r4 * v.x) + (mtx->c2r4 * v.y) + (mtx->c3r4 * v.z) + (mtx->c4r4 * v.w);
	return vOut;
}

/**
 * Orthonormalizes the rotation component of the specified matrix, using a Gram-Schmidt process,
 * and using the column indicated by the specified column number as the starting point of the
 * orthonormalization process.
 *
 * The specified column number should be between 1 and 3.
 *
 * Upon completion, the first three elements of each of the first three columns in the specified
 * matrix will be a unit vector that is orthagonal to the first three elements of the other two columns.
 * 
 * Since the Gram-Schmidt process is biased towards the starting column, if this function
 * will be invoked repeatedly on the same matrix, it is recommended that the starting
 * column number be changed on each invocation of this function, to ensure that the starting
 * bias be averaged across each of the columns over the long term.
 */
static inline void CC3Matrix4x4Orthonormalize(CC3Matrix4x4* mtx, NSUInteger startColNum) {
	CC3Matrix3x3 mtx3;
	CC3Matrix3x3PopulateFrom4x4(&mtx3, mtx);
	CC3Matrix3x3Orthonormalize(&mtx3, startColNum);
	CC3Matrix3x3CopyInto4x4(&mtx3, mtx);
}

/** Transposes the specified matrix. The contents of the matrix are changed. */
static inline void CC3Matrix4x4Transpose(CC3Matrix4x4* mtx) {
	GLfloat tmp;
	tmp = mtx->c1r2;   mtx->c1r2 = mtx->c2r1;   mtx->c2r1 = tmp;
	tmp = mtx->c1r3;   mtx->c1r3 = mtx->c3r1;   mtx->c3r1 = tmp;
	tmp = mtx->c1r4;   mtx->c1r4 = mtx->c4r1;   mtx->c4r1 = tmp;
	tmp = mtx->c2r3;   mtx->c2r3 = mtx->c3r2;   mtx->c3r2 = tmp;
	tmp = mtx->c2r4;   mtx->c2r4 = mtx->c4r2;   mtx->c4r2 = tmp;
	tmp = mtx->c3r4;   mtx->c3r4 = mtx->c4r3;   mtx->c4r3 = tmp;
}

/**
 * Inverts the specified matrix by using the algorithm of calculating the classical
 * adjoint and dividing by the determinant. The contents of the matrix are changed.
 *
 * Not all matrices are invertable. Returns whether the matrix was inverted.
 * If this function returns NO, then the matrix was not inverted, and remains unchanged.
 *
 * Matrix inversion using the classical adjoint algorithm is computationally-expensive. If it is
 * known that the matrix contains only rotation and translation, use the CC3Matrix4x4InvertRigid
 * function instead, which is some 10 to 100 times faster than this function.
 */
static inline BOOL CC3Matrix4x4InvertAdjoint(CC3Matrix4x4* m) {
	CC3Matrix4x4 adj;	// The adjoint matrix (inverse after dividing by determinant)
	
	// Create the transpose of the cofactors, as the classical adjoint of the matrix.
    adj.c1r1 =  CC3Det3x3(m->c2r2, m->c2r3, m->c2r4, m->c3r2, m->c3r3, m->c3r4, m->c4r2, m->c4r3, m->c4r4);
    adj.c1r2 = -CC3Det3x3(m->c1r2, m->c1r3, m->c1r4, m->c3r2, m->c3r3, m->c3r4, m->c4r2, m->c4r3, m->c4r4);
    adj.c1r3 =  CC3Det3x3(m->c1r2, m->c1r3, m->c1r4, m->c2r2, m->c2r3, m->c2r4, m->c4r2, m->c4r3, m->c4r4);
    adj.c1r4 = -CC3Det3x3(m->c1r2, m->c1r3, m->c1r4, m->c2r2, m->c2r3, m->c2r4, m->c3r2, m->c3r3, m->c3r4);
	
    adj.c2r1 = -CC3Det3x3(m->c2r1, m->c2r3, m->c2r4, m->c3r1, m->c3r3, m->c3r4, m->c4r1, m->c4r3, m->c4r4);
    adj.c2r2 =  CC3Det3x3(m->c1r1, m->c1r3, m->c1r4, m->c3r1, m->c3r3, m->c3r4, m->c4r1, m->c4r3, m->c4r4);
    adj.c2r3 = -CC3Det3x3(m->c1r1, m->c1r3, m->c1r4, m->c2r1, m->c2r3, m->c2r4, m->c4r1, m->c4r3, m->c4r4);
    adj.c2r4 =  CC3Det3x3(m->c1r1, m->c1r3, m->c1r4, m->c2r1, m->c2r3, m->c2r4, m->c3r1, m->c3r3, m->c3r4);
	
    adj.c3r1 =  CC3Det3x3(m->c2r1, m->c2r2, m->c2r4, m->c3r1, m->c3r2, m->c3r4, m->c4r1, m->c4r2, m->c4r4);
    adj.c3r2 = -CC3Det3x3(m->c1r1, m->c1r2, m->c1r4, m->c3r1, m->c3r2, m->c3r4, m->c4r1, m->c4r2, m->c4r4);
    adj.c3r3 =  CC3Det3x3(m->c1r1, m->c1r2, m->c1r4, m->c2r1, m->c2r2, m->c2r4, m->c4r1, m->c4r2, m->c4r4);
    adj.c3r4 = -CC3Det3x3(m->c1r1, m->c1r2, m->c1r4, m->c2r1, m->c2r2, m->c2r4, m->c3r1, m->c3r2, m->c3r4);
	
    adj.c4r1 = -CC3Det3x3(m->c2r1, m->c2r2, m->c2r3, m->c3r1, m->c3r2, m->c3r3, m->c4r1, m->c4r2, m->c4r3);
    adj.c4r2 =  CC3Det3x3(m->c1r1, m->c1r2, m->c1r3, m->c3r1, m->c3r2, m->c3r3, m->c4r1, m->c4r2, m->c4r3);
    adj.c4r3 = -CC3Det3x3(m->c1r1, m->c1r2, m->c1r3, m->c2r1, m->c2r2, m->c2r3, m->c4r1, m->c4r2, m->c4r3);
    adj.c4r4 =  CC3Det3x3(m->c1r1, m->c1r2, m->c1r3, m->c2r1, m->c2r2, m->c2r3, m->c3r1, m->c3r2, m->c3r3);
	
	// Calculate the determinant as a combination of the cofactors of the first row.
	GLfloat det = (adj.c1r1 * m->c1r1) + (adj.c1r2 * m->c2r1) + (adj.c1r3 * m->c3r1) + (adj.c1r4 * m->c4r1);

	// If determinant is zero, matrix is not invertable.
	if (det == 0.0f) {
		LogError(@"%@ is singular and cannot be inverted", NSStringFromCC3Matrix4x4(m));
		return NO;
	}
	
	// Divide the classical adjoint matrix by the determinant and set back into original matrix.
	GLfloat ooDet = 1.0 / det;		// Turn div into mult for speed
	m->c1r1 = adj.c1r1  * ooDet;
	m->c1r2 = adj.c1r2  * ooDet;
	m->c1r3 = adj.c1r3  * ooDet;
	m->c1r4 = adj.c1r4  * ooDet;
	m->c2r1 = adj.c2r1  * ooDet;
	m->c2r2 = adj.c2r2  * ooDet;
	m->c2r3 = adj.c2r3  * ooDet;
	m->c2r4 = adj.c2r4  * ooDet;
	m->c3r1 = adj.c3r1  * ooDet;
	m->c3r2 = adj.c3r2  * ooDet;
	m->c3r3 = adj.c3r3 * ooDet;
	m->c3r4 = adj.c3r4 * ooDet;
	m->c4r1 = adj.c4r1 * ooDet;
	m->c4r2 = adj.c4r2 * ooDet;
	m->c4r3 = adj.c4r3 * ooDet;
	m->c4r4 = adj.c4r4 * ooDet;
	
	return YES;
}

/**
 * Inverts the specified matrix using transposition. The contents of this matrix are changed.
 *
 * This function assumes that the matrix represents a rigid transformation, containing only
 * rotation and translation. Use this function only if it is known that this is the case.
 *
 * Inversion of a rigid transform matrix via transposition is very fast, and is consistently
 * 10 to 100 times faster than the classical adjoint algorithm used in the CC3Matrix4x4InvertAdjoint
 * function. It is recommended that this function be used whenever possible.
 *
 * For an matrix that contains only rigid transforms, we can invert the 3x3 linear matrix by
 * transposing it, and use it to transform the negated translation vector:
 * 
 * M(-1) = |  LT  -LT(t) |
 *
 * where LT is the transposed 3x3 linear matrix, and t is the translation vector, both extracted
 * from the 4x4 matrix. For a matrix containing only rigid transforms: L(-1) = LT,
 */
static inline void CC3Matrix4x4InvertRigid(CC3Matrix4x4* mtx) {
	// Extract and transpose the 3x3 linear matrix 
	CC3Matrix3x3 linMtx;
	CC3Matrix3x3PopulateFrom4x4(&linMtx, mtx);
	CC3Matrix3x3Transpose(&linMtx);

	// Extract the translation and transform it by the transposed linear matrix
	CC3Vector t = CC3VectorFromCC3Matrix4x4Col(mtx, 4);
	t = CC3Matrix3x3TransformCC3Vector(&linMtx, CC3VectorNegate(t));
	
	// Populate the 4x4 matrix with the transposed rotation and transformed translation
	CC3Matrix4x4PopulateFrom3x3(mtx, &linMtx);
	mtx->c4r1 = t.x;
	mtx->c4r2 = t.y;
	mtx->c4r3 = t.z;
}


