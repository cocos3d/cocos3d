/*
 * CC3Matrix3x3.h
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
static inline NSString* NSStringFromCC3Matrix3x3(CC3Matrix3x3* mtxPtr) {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"\n\t[%.6f, %.6f, %.6f", mtxPtr->c1r1, mtxPtr->c2r1, mtxPtr->c3r1];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f", mtxPtr->c1r2, mtxPtr->c2r2, mtxPtr->c3r2];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f]", mtxPtr->c1r3, mtxPtr->c2r3, mtxPtr->c3r3];
	return desc;
}


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
static inline void CC3Matrix3x3PopulateFromRotationYXZ(CC3Matrix3x3* mtx, CC3Vector aRotation) {
/*
     |  cycz + sxsysz   czsxsy - cysz   cxsy  |
 M = |  cxsz            cxcz           -sx    |
     |  cysxsz - czsy   cyczsx + sysz   cxcy  |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
*/
	CC3Vector rotRads = CC3VectorScaleUniform(aRotation, DegreesToRadiansFactor);
	
	GLfloat cx = cosf(rotRads.x);
	GLfloat sx = sinf(rotRads.x);
	GLfloat cy = cosf(rotRads.y);
	GLfloat sy = sinf(rotRads.y);
	GLfloat cz = cosf(rotRads.z);
	GLfloat sz = sinf(rotRads.z);
	
	mtx->c1r1 = (cy * cz) + (sx * sy * sz);
	mtx->c1r2 = cx * sz;
	mtx->c1r3 = (cy * sx * sz) - (cz * sy);
	
	mtx->c2r1 = (cz * sx * sy) - (cy * sz);
	mtx->c2r2 = cx * cz;
	mtx->c2r3 = (cy * cz * sx) + (sy * sz);
	
	mtx->c3r1 = cx * sy;
	mtx->c3r2 = -sx;
	mtx->c3r3 = cx * cy;
}

/**
 * Populates the specified matrix as a rotation around three axes, z (roll), y (yaw), and x (pitch),
 * in that order, from the specified Euler angle rotation. Each Euler angle is specified in degrees.
 *
 * This rotation places 'up' along the positive Z axis, which is used by some commercial 3D editors.
 */
static inline void CC3Matrix3x3PopulateFromRotationZYX(CC3Matrix3x3* mtx, CC3Vector aRotation) {
/*
     |  cycz  -cxsz + sxsycz   sxsz + cxsycz  |
 M = |  cysz   cxcz + sxsysz  -sxcz + cxsysz  |
     | -sy     sxcy            cxcy           |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
*/
	CC3Vector rotRads = CC3VectorScaleUniform(aRotation, DegreesToRadiansFactor);
	
	GLfloat cx = cosf(rotRads.x);
	GLfloat sx = sinf(rotRads.x);
	GLfloat cy = cosf(rotRads.y);
	GLfloat sy = sinf(rotRads.y);
	GLfloat cz = cosf(rotRads.z);
	GLfloat sz = sinf(rotRads.z);
	
	mtx->c1r1 = cy * cz;
	mtx->c1r2 = cy * sz;
	mtx->c1r3 = -sy;
	
	mtx->c2r1 = -(cx * sz) + (sx * sy * cz);
	mtx->c2r2 = (cx * cz) + (sx * sy * sz);
	mtx->c2r3 = sx * cy;
	
	mtx->c3r1 = (sx * sz) + (cx * sy * cz);
	mtx->c3r2 = -(sx * cz) + (cx * sy * sz);
	mtx->c3r3 = cx * cy;
}

/** Populates the specified matrix as a rotation around the X-axis, in degrees. */
static inline void CC3Matrix3x3PopulateFromRotationX(CC3Matrix3x3* mtx, const GLfloat degrees) {
/*
     |  1  0       0       |
 M = |  0  cos(A) -sin(A)  |
     |  0  sin(A)  cos(A)  |
*/
	GLfloat radians = DegreesToRadians(degrees);
	GLfloat c = cosf(radians);
	GLfloat s = sinf(radians);
	
	mtx->c1r1 = 1.0f;
	mtx->c1r2 = 0.0f;
	mtx->c1r3 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = c;
	mtx->c2r3 = s;
	
	mtx->c3r1 = 0.0f;
	mtx->c3r2 = -s;
	mtx->c3r3 = c;
}

/** Populates the specified matrix as a rotation around the Y-axis, in degrees. */
static inline void CC3Matrix3x3PopulateFromRotationY(CC3Matrix3x3* mtx, const GLfloat degrees) {
/*
     |  cos(A)  0   sin(A)  |
 M = |  0       1   0       |
     | -sin(A)  0   cos(A)  |
*/
	GLfloat radians = DegreesToRadians(degrees);
	GLfloat c = cosf(radians);
	GLfloat s = sinf(radians);
	
	mtx->c1r1 = c;
	mtx->c1r2 = 0.0f;
	mtx->c1r3 = -s;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = 1.0f;
	mtx->c2r3 = 0.0f;
	
	mtx->c3r1 = s;
	mtx->c3r2 = 0.0f;
	mtx->c3r3 = c;
}

/** Populates the specified matrix as a rotation around the Z-axis, in degrees. */
static inline void CC3Matrix3x3PopulateFromRotationZ(CC3Matrix3x3* mtx, const GLfloat degrees) {
/*
     |  cos(A)  -sin(A)   0  |
 M = |  sin(A)   cos(A)   0  |
     |  0        0        1  |
*/
	GLfloat radians = DegreesToRadians(degrees);
	GLfloat c = cosf(radians);
	GLfloat s = sinf(radians);
	
	mtx->c1r1 = c;
	mtx->c1r2 = s;
	mtx->c1r3 = 0.0f;
	
	mtx->c2r1 = -s;
	mtx->c2r2 = c;
	mtx->c2r3 = 0.0f;
	
	mtx->c3r1 = 0.0f;
	mtx->c3r2 = 0.0f;
	mtx->c3r3 = 1.0f;
}


/** Populates the specified matrix from the specified quaternion. */
static inline void CC3Matrix3x3PopulateFromQuaternion(CC3Matrix3x3* mtx, CC3Quaternion q) {
/*
     |       2     2                                |
     | 1 - 2Y  - 2Z    2XY + 2ZW      2XZ - 2YW     |
     |                                              |
     |                       2     2                |
 M = | 2XY - 2ZW       1 - 2X  - 2Z   2YZ + 2XW     |
     |                                              |
     |                                      2     2 |
     | 2XZ + 2YW       2YZ - 2XW      1 - 2X  - 2Y  |
*/
	
	GLfloat twoXX = 2.0f * q.x * q.x;
	GLfloat twoXY = 2.0f * q.x * q.y;
	GLfloat twoXZ = 2.0f * q.x * q.z;
	GLfloat twoXW = 2.0f * q.x * q.w;
	
	GLfloat twoYY = 2.0f * q.y * q.y;
	GLfloat twoYZ = 2.0f * q.y * q.z;
	GLfloat twoYW = 2.0f * q.y * q.w;
	
	GLfloat twoZZ = 2.0f * q.z * q.z;
	GLfloat twoZW = 2.0f * q.z * q.w;
	
	mtx->c1r1 = 1.0f - twoYY - twoZZ;
	mtx->c1r2 = twoXY - twoZW;
	mtx->c1r3 = twoXZ + twoYW;
	
	mtx->c2r1 = twoXY + twoZW;
	mtx->c2r2 = 1.0f - twoXX - twoZZ;
	mtx->c2r3 = twoYZ - twoXW;
	
	mtx->c3r1 = twoXZ - twoYW;
	mtx->c3r2 = twoYZ + twoXW;
	mtx->c3r3 = 1.0f - twoXX - twoYY;
}

/**
 * Populates the specified matrix so that it will transform a vector pointed down the negative
 * Z-axis to point in the specified forwardDirection, and transform the positive Y-axis to point
 * in the specified upDirection.
 */
static inline void CC3Matrix3x3PopulateToPointTowards(CC3Matrix3x3* mtx, const CC3Vector fwdDirection, const CC3Vector upDirection) {
/*
     | rx  ux  -fx |
 M = | ry  uy  -fy |
     | rz  uz  -fz |
	 
	 where f is the normalized Forward vector (the direction being pointed to)
	 and u is the normalized Up vector in the rotated frame
	 and r is the normalized Right vector in the rotated frame
*/
	CC3Vector f, u, r;
	f = CC3VectorNormalize(fwdDirection);
	r = CC3VectorNormalize(CC3VectorCross(f, upDirection));
	u = CC3VectorCross(r, f);			// already normalized since f & r are orthonormal

	mtx->col1 = r;
	mtx->col2 = u;
	mtx->col3 = CC3VectorNegate(f);
}

/** Populates the specified matrix from the specified scale. */
static inline void CC3Matrix3x3PopulateFromScale(CC3Matrix3x3* mtx, const CC3Vector aScale) {
/*
     | x  0  0 |
 M = | 0  y  0 |
     | 0  0  z |
 */
	mtx->c1r1 = aScale.x;
	mtx->c1r2 = 0.0f;
	mtx->c1r3 = 0.0f;
	
	mtx->c2r1 = 0.0f;
	mtx->c2r2 = aScale.y;
	mtx->c2r3 = 0.0f;
	
	mtx->c3r1 = 0.0f;
	mtx->c3r2 = 0.0f;
	mtx->c3r3 = aScale.z;
}


#pragma mark Accessing vector content

/**
 * Returns the column at the specified index from the specified matrix, as a 3D vector
 * suitable for use in use with a 3x3 matrix.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector CC3VectorFromCC3Matrix3x3Col(const CC3Matrix3x3* mtx, NSUInteger colIdx) {
	return mtx->columns[--colIdx];	// Convert to zero-based.
}

/**
 * Returns the row at the specified index from the specified matrix, as a 3D vector
 * suitable for use in use with a 3x3 matrix.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector CC3VectorFromCC3Matrix3x3Row(const CC3Matrix3x3* mtx, NSUInteger rowIdx) {
	rowIdx--;	// Convert to zero-based.
	return cc3v(mtx->colRow[0][rowIdx], mtx->colRow[1][rowIdx], mtx->colRow[2][rowIdx]);
}

/**
 * Returns the column at the specified index from the specified matrix, as a 4D vector suitable
 * for use in use with a 4x4 matrix. The W component of the returned vector will always be zero.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector4 CC3Vector4FromCC3Matrix3x3Col(const CC3Matrix3x3* mtx, NSUInteger colIdx) {
	return CC3Vector4FromCC3Vector(mtx->columns[--colIdx], 0.0f);	// Convert to zero-based.
}

/**
 * Returns the row at the specified index from the specified matrix, as a 4D vector suitable
 * for use in use with a 4x4 matrix. The W component of the returned vector will always be zero.
 *
 * In keeping with matrix math terminology, the index is one-based.
 * The first column of the matrix has an index of one.
 */
static inline CC3Vector4 CC3Vector4FromCC3Matrix3x3Row(const CC3Matrix3x3* mtx, NSUInteger rowIdx) {
	rowIdx--;	// Convert to zero-based.
	return CC3Vector4Make(mtx->colRow[0][rowIdx], mtx->colRow[1][rowIdx], mtx->colRow[2][rowIdx], 0);
}

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in YXZ order, which is the OpenGL default.
 * Each element of the returned rotation vector represents an Euler angle in degrees.
 */
static inline CC3Vector CC3Matrix3x3ExtractRotationYXZ(const CC3Matrix3x3* mtx) {
/*
     |  cycz + sxsysz   czsxsy - cysz   cxsy  |
 M = |  cxsz            cxcz           -sx    |
     |  cysxsz - czsy   cyczsx + sysz   cxcy  |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
*/
	GLfloat radX, radY, radZ;
	GLfloat cxsz = mtx->c1r2;
	GLfloat cxcz = mtx->c2r2;
	GLfloat cxsy = mtx->c3r1;
	GLfloat sx  = -mtx->c3r2;
	GLfloat cxcy = mtx->c3r3;

	if (sx < +1.0) {
		if (sx > -1.0) {
			radX = asinf(sx);
			radY = atan2f(cxsy, cxcy);
			radZ = atan2f(cxsz, cxcz);
		}
		else {		// sx = -1 (cx = 0). Not a unique solution: radZ + radY = atan2(-m01,m00).
			radX = -M_PI_2;
			radY = atan2f(-mtx->c2r1, mtx->c1r1);
			radZ = 0.0;
		}
	}
	else {			// sx = +1 (cx = 0). Not a unique solution: radZ - radY = atan2(-m01,m00).
		radX = +M_PI_2;
		radY = -atan2f(-mtx->c2r1, mtx->c1r1);
		radZ = 0.0;
	}	
	return cc3v(RadiansToDegrees(radX), RadiansToDegrees(radY), RadiansToDegrees(radZ));
}

/**
 * Extracts the rotation component of the specified matrix and returns it as an Euler rotation
 * vector, assuming the rotations should be applied in ZYX order. Each element of the returned
 * rotation vector represents an Euler angle in degrees.
 */
static inline CC3Vector CC3Matrix3x3ExtractRotationZYX(const CC3Matrix3x3* mtx) {
/*
     |  cycz  -cxsz + sxsycz   sxsz + cxsycz  |
 M = |  cysz   cxcz + sxsysz  -sxcz + cxsysz  |
     | -sy     sxcy            cxcy           |
 	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
 */
	GLfloat radX, radY, radZ;
	GLfloat cycz = mtx->c1r1;
	GLfloat cysz = mtx->c1r2;
	GLfloat sy  = -mtx->c1r3;
	GLfloat sxcy = mtx->c2r3;
	GLfloat cxcy = mtx->c3r3;

	if (sy < +1.0) {
		if (sy > -1.0) {
			radY = asinf(sy);
			radZ = atan2f(cysz, cycz);
			radX = atan2f(sxcy, cxcy);
		}
		else {		// sy = -1. Not a unique solution: radX + radZ = atan2(-m12,m11).
			radY = -M_PI_2;
			radZ = atan2f(-mtx->c3r2, mtx->c2r2);
			radX = 0.0;
		}
	}
	else {			// sy = +1. Not a unique solution: radX - radZ = atan2(-m12,m11).
		radY = +M_PI_2;
		radZ = -atan2f(-mtx->c3r2, mtx->c2r2);
		radX = 0.0;
	}	
	return cc3v(RadiansToDegrees(radX), RadiansToDegrees(radY), RadiansToDegrees(radZ));
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
static inline CC3Quaternion CC3Matrix3x3ExtractQuaternion(const CC3Matrix3x3* mtx) {
	enum {W,X,Y,Z} bigType;
	CC3Quaternion quat;
	
	// From the matrix diagonal element, calc (4q^2 - 1),
	// where q is each of the quaternion components: w, x, y & z.
	GLfloat fourWSqM1 =  mtx->c1r1 + mtx->c2r2 + mtx->c3r3;
	GLfloat fourXSqM1 =  mtx->c1r1 - mtx->c2r2 - mtx->c3r3;
	GLfloat fourYSqM1 = -mtx->c1r1 + mtx->c2r2 - mtx->c3r3;
	GLfloat fourZSqM1 = -mtx->c1r1 - mtx->c2r2 + mtx->c3r3;
	GLfloat bigFourSqM1;
	
	// Determine the biggest quaternion component from the above options.
	bigType = W;
	bigFourSqM1 = fourWSqM1;
	if (fourXSqM1 > bigFourSqM1) {
		bigFourSqM1 = fourXSqM1;
		bigType = X;
	}
	if (fourYSqM1 > bigFourSqM1) {
		bigFourSqM1 = fourYSqM1;
		bigType = Y;
	}
	if (fourZSqM1 > bigFourSqM1) {
		bigFourSqM1 = fourZSqM1;
		bigType = Z;
	}
	
	// Isolate that biggest component value, q from the above formula
	// (4q^2 - 1), and calculate the factor  (1 / 4q).
	GLfloat bigVal = sqrtf(bigFourSqM1 + 1.0f) * 0.5f;
	GLfloat oo4BigVal = 1.0f / (4.0f * bigVal);
	
	switch (bigType) {
		case W:
			quat.w = bigVal;
			quat.x = (mtx->c3r2 - mtx->c2r3) * oo4BigVal;
			quat.y = (mtx->c1r3 - mtx->c3r1) * oo4BigVal;
			quat.z = (mtx->c2r1 - mtx->c1r2) * oo4BigVal;
			break;
		case X:
			quat.w = (mtx->c3r2 - mtx->c2r3) * oo4BigVal;
			quat.x = bigVal;
			quat.y = (mtx->c2r1 + mtx->c1r2) * oo4BigVal;
			quat.z = (mtx->c1r3 + mtx->c3r1) * oo4BigVal;
			break;
		case Y:
			quat.w = (mtx->c1r3 - mtx->c3r1) * oo4BigVal;
			quat.x = (mtx->c2r1 + mtx->c1r2) * oo4BigVal;
			quat.y = bigVal;
			quat.z = (mtx->c3r2 + mtx->c2r3) * oo4BigVal;
			break;
		case Z:
			quat.w = (mtx->c2r1 - mtx->c1r2) * oo4BigVal;
			quat.x = (mtx->c1r3 + mtx->c3r1) * oo4BigVal;
			quat.y = (mtx->c3r2 + mtx->c2r3) * oo4BigVal;
			quat.z = bigVal;
			break;
	}
	return quat;
}

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
static inline void CC3Matrix3x3Multiply(CC3Matrix3x3* mOut, const CC3Matrix3x3* mL, const CC3Matrix3x3* mR) {
	
	mOut->c1r1 = (mL->c1r1 * mR->c1r1) + (mL->c2r1 * mR->c1r2) + (mL->c3r1 * mR->c1r3);
	mOut->c1r2 = (mL->c1r2 * mR->c1r1) + (mL->c2r2 * mR->c1r2) + (mL->c3r2 * mR->c1r3);
	mOut->c1r3 = (mL->c1r3 * mR->c1r1) + (mL->c2r3 * mR->c1r2) + (mL->c3r3 * mR->c1r3);
	
	mOut->c2r1 = (mL->c1r1 * mR->c2r1) + (mL->c2r1 * mR->c2r2) + (mL->c3r1 * mR->c2r3);
	mOut->c2r2 = (mL->c1r2 * mR->c2r1) + (mL->c2r2 * mR->c2r2) + (mL->c3r2 * mR->c2r3);
	mOut->c2r3 = (mL->c1r3 * mR->c2r1) + (mL->c2r3 * mR->c2r2) + (mL->c3r3 * mR->c2r3);
	
	mOut->c3r1 = (mL->c1r1 * mR->c3r1) + (mL->c2r1 * mR->c3r2) + (mL->c3r1 * mR->c3r3);
	mOut->c3r2 = (mL->c1r2 * mR->c3r1) + (mL->c2r2 * mR->c3r2) + (mL->c3r2 * mR->c3r3);
	mOut->c3r3 = (mL->c1r3 * mR->c3r1) + (mL->c2r3 * mR->c3r2) + (mL->c3r3 * mR->c3r3);
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
static inline CC3Vector CC3Matrix3x3TransformCC3Vector(const CC3Matrix3x3* mtx, CC3Vector v) {
	CC3Vector vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z);
	return vOut;
}

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
static inline void CC3Matrix3x3Orthonormalize(CC3Matrix3x3* mtx, NSUInteger startColNum) {
	CC3Vector basisVectors[3];
	switch (startColNum) {
			
			// Start Gram-Schmidt orthonormalization with the first column.
		case 1:
			basisVectors[0] = mtx->col1;
			basisVectors[1] = mtx->col2;
			basisVectors[2] = mtx->col3;
			CC3VectorOrthonormalizeTriple(basisVectors);
			mtx->col1 = basisVectors[0];
			mtx->col2 = basisVectors[1];
			mtx->col3 = basisVectors[2];
			break;
			
			// Start Gram-Schmidt orthonormalization with the second column.
		case 2:
			basisVectors[0] = mtx->col2;
			basisVectors[1] = mtx->col3;
			basisVectors[2] = mtx->col1;
			CC3VectorOrthonormalizeTriple(basisVectors);
			mtx->col2 = basisVectors[0];
			mtx->col3 = basisVectors[1];
			mtx->col1 = basisVectors[2];
			break;
			
			// Start Gram-Schmidt orthonormalization with the third column.
		case 3:
			basisVectors[0] = mtx->col3;
			basisVectors[1] = mtx->col1;
			basisVectors[2] = mtx->col2;
			CC3VectorOrthonormalizeTriple(basisVectors);
			mtx->col3 = basisVectors[0];
			mtx->col1 = basisVectors[1];
			mtx->col2 = basisVectors[2];
			break;
			
		default:	// Don't do any orthonormalization
			break;
	}
}

/** Transposes the specified matrix. The contents of the matrix are changed. */
static inline void CC3Matrix3x3Transpose(CC3Matrix3x3* mtx) {
	GLfloat tmp;
	tmp = mtx->c1r2;   mtx->c1r2 = mtx->c2r1;   mtx->c2r1 = tmp;
	tmp = mtx->c1r3;   mtx->c1r3 = mtx->c3r1;   mtx->c3r1 = tmp;
	tmp = mtx->c2r3;   mtx->c2r3 = mtx->c3r2;   mtx->c3r2 = tmp;
}

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
static inline BOOL CC3Matrix3x3InvertAdjoint(CC3Matrix3x3* mtx) {
	CC3Matrix3x3 adj;	// The adjoint matrix (inverse after dividing by determinant)
	
	// Create the transpose of the cofactors, as the classical adjoint of the matrix.
    adj.c1r1 =  CC3Det2x2(mtx->c2r2, mtx->c2r3, mtx->c3r2, mtx->c3r3);	// c1r1+
    adj.c1r2 = -CC3Det2x2(mtx->c1r2, mtx->c1r3, mtx->c3r2, mtx->c3r3);	// c2r1-
    adj.c1r3 =  CC3Det2x2(mtx->c1r2, mtx->c1r3, mtx->c2r2, mtx->c2r3);	// c3r1+
	
    adj.c2r1 = -CC3Det2x2(mtx->c2r1, mtx->c2r3, mtx->c3r1, mtx->c3r3);	// c1r2-
    adj.c2r2 =  CC3Det2x2(mtx->c1r1, mtx->c1r3, mtx->c3r1, mtx->c3r3);	// c2r2+
    adj.c2r3 = -CC3Det2x2(mtx->c1r1, mtx->c1r3, mtx->c2r1, mtx->c2r3);	// c3r2-
	
    adj.c3r1 =  CC3Det2x2(mtx->c2r1, mtx->c2r2, mtx->c3r1, mtx->c3r2);	// c1r3+
    adj.c3r2 = -CC3Det2x2(mtx->c1r1, mtx->c1r2, mtx->c3r1, mtx->c3r2);	// c2r3-
    adj.c3r3 =  CC3Det2x2(mtx->c1r1, mtx->c1r2, mtx->c2r1, mtx->c2r2);	// c3r3+
	
	// Calculate the determinant as a combination of the cofactors of the first row.
	GLfloat det = (mtx->c1r1 * adj.c1r1) + (mtx->c2r1 * adj.c1r2) + (mtx->c3r1 * adj.c1r3);
	
	// If determinant is zero, matrix is not invertable.
	if (det == 0.0f) {
		LogError(@"%@ is singular and cannot be inverted", NSStringFromCC3Matrix3x3(mtx));
		return NO;
	}
	
	// Divide the classical adjoint matrix by the determinant and set back into original matrix.
	GLfloat ooDet = 1.0 / det;		// Turn div into mult for speed
	mtx->c1r1  = adj.c1r1 * ooDet;
	mtx->c1r2  = adj.c1r2 * ooDet;
	mtx->c1r3  = adj.c1r3 * ooDet;
	mtx->c2r1  = adj.c2r1 * ooDet;
	mtx->c2r2  = adj.c2r2 * ooDet;
	mtx->c2r3  = adj.c2r3 * ooDet;
	mtx->c3r1  = adj.c3r1 * ooDet;
	mtx->c3r2  = adj.c3r2 * ooDet;
	mtx->c3r3  = adj.c3r3 * ooDet;
	
	return YES;
}

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


