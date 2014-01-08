/*
 * CC3MatrixMath.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 *
 * Kazmath functions copyright (c) 2008, Luke Benstead. All rights reserved.
 *
 * http://www.kazade.co.uk/kazmath/
 *
 * Augmented and modified for use with Objective-C in cocos3d by Bill Hollings.
 * Additions and modifications copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/** @file */	// Doxygen marker

#import "CC3Foundation.h"


/**
 * Builds a rotation matrix that rotates around all three axes, y (yaw), x (pitch) and z (roll),
 * in that order, stores the result in 4x4 GL matrix m and returns the result.
 * This algorithm matches up along the positive Y axis, which is the OpenGL ES default.
 */
static inline void CC3KMMat4RotationYXZ(GLfloat* m, CC3Vector aRotation) {
/*
     |  cycz + sxsysz   czsxsy - cysz   cxsy  0 |
 M = |  cxsz            cxcz           -sx    0 |
     |  cysxsz - czsy   cyczsx + sysz   cxcy  0 |
     |  0               0               0     1 |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
 */
	CC3Vector rotRads = CC3VectorScaleUniform(aRotation, kCC3DegToRadFactor);
	
	GLfloat cx = cosf(rotRads.x);
	GLfloat sx = sinf(rotRads.x);
	GLfloat cy = cosf(rotRads.y);
	GLfloat sy = sinf(rotRads.y);
	GLfloat cz = cosf(rotRads.z);
	GLfloat sz = sinf(rotRads.z);
	
	m[0] = (cy * cz) + (sx * sy * sz);
	m[1] = cx * sz;
	m[2] = (cy * sx * sz) - (cz * sy);
	m[3] = 0.0;
	
	m[4] = (cz * sx * sy) - (cy * sz);
	m[5] = cx * cz;
	m[6] = (cy * cz * sx) + (sy * sz);
	m[7] = 0.0;
	
	m[8] = cx * sy;
	m[9] = -sx;
	m[10] = cx * cy;
	m[11] = 0.0;
	
	m[12] = 0.0;
	m[13] = 0.0;
	m[14] = 0.0;
	m[15] = 1.0;
}

/**
 * Builds a rotation matrix that rotates around all three axes z (roll), y (yaw), and x (pitch),
 * in that order, stores the result in pOut and returns the result
 * This algorithm matches up along the positive Z axis, which is used by some commercial 3D editors.
 */
static inline void CC3KMMat4RotationZYX(GLfloat* m, CC3Vector aRotation) {
/*
     |  cycz  -cxsz + sxsycz   sxsz + cxsycz  0 |
 M = |  cysz   cxcz + sxsysz  -sxcz + cxsysz  0 |
     | -sy     sxcy            cxcy           0 |
     |  0      0               0              1 |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
 */
	CC3Vector rotRads = CC3VectorScaleUniform(aRotation, kCC3DegToRadFactor);
	
	GLfloat cx = cosf(rotRads.x);
	GLfloat sx = sinf(rotRads.x);
	GLfloat cy = cosf(rotRads.y);
	GLfloat sy = sinf(rotRads.y);
	GLfloat cz = cosf(rotRads.z);
	GLfloat sz = sinf(rotRads.z);
	
	m[0] = cy * cz;
	m[1] = cy * sz;
	m[2] = -sy;
	m[3] = 0.0;
	
	m[4] = -(cx * sz) + (sx * sy * cz);
	m[5] = (cx * cz) + (sx * sy * sz);
	m[6] = sx * cy;
	m[7] = 0.0;
	
	m[8] = (sx * sz) + (cx * sy * cz);
	m[9] = -(sx * cz) + (cx * sy * sz);
	m[10] = cx * cy;
	m[11] = 0.0;
	
	m[12] = 0.0;
	m[13] = 0.0;
	m[14] = 0.0;
	m[15] = 1.0;
}

/** Builds a rotation matrix around the X-axis, stores the result in pOut and returns the result */
static inline void CC3KMMat4RotationX(GLfloat* m, const GLfloat degrees) {
/*
     |  1  0       0       0 |
 M = |  0  cos(A) -sin(A)  0 |
     |  0  sin(A)  cos(A)  0 |
     |  0  0       0       1 |
 */
	GLfloat radians = CC3DegToRad(degrees);
	GLfloat c = cosf(radians);
	GLfloat s = sinf(radians);
	
	m[0] = 1.0f;
	m[1] = 0.0f;
	m[2] = 0.0f;
	m[3] = 0.0f;
	
	m[4] = 0.0f;
	m[5] = c;
	m[6] = s;
	m[7] = 0.0f;
	
	m[8] = 0.0f;
	m[9] = -s;
	m[10] = c;
	m[11] = 0.0f;
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
}

/** Builds a rotation matrix around the Y-axis, stores the result in pOut and returns the result */
static inline void CC3KMMat4RotationY(GLfloat* m, const GLfloat degrees) {
/*
     |  cos(A)  0   sin(A)  0 |
 M = |  0       1   0       0 |
     | -sin(A)  0   cos(A)  0 |
     |  0       0   0       1 |
 */
	GLfloat radians = CC3DegToRad(degrees);
	GLfloat c = cosf(radians);
	GLfloat s = sinf(radians);
	
	m[0] = c;
	m[1] = 0.0f;
	m[2] = -s;
	m[3] = 0.0f;
	
	m[4] = 0.0f;
	m[5] = 1.0f;
	m[6] = 0.0f;
	m[7] = 0.0f;
	
	m[8] = s;
	m[9] = 0.0f;
	m[10] = c;
	m[11] = 0.0f;
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
}

/** Builds a rotation matrix around the Z-axis, stores the result in pOut and returns the result */
static inline void CC3KMMat4RotationZ(GLfloat* m, const GLfloat degrees) {
/*
     |  cos(A)  -sin(A)   0   0 |
 M = |  sin(A)   cos(A)   0   0 |
     |  0        0        1   0 |
     |  0        0        0   1 |
 */
	GLfloat radians = CC3DegToRad(degrees);
	GLfloat c = cosf(radians);
	GLfloat s = sinf(radians);
	
	m[0] = c;
	m[1] = s;
	m[2] = 0.0f;
	m[3] = 0.0f;
	
	m[4] = -s;
	m[5] = c;
	m[6] = 0.0f;
	m[7] = 0.0f;
	
	m[8] = 0.0f;
	m[9] = 0.0f;
	m[10] = 1.0f;
	m[11] = 0.0f;
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
}

/**
 * Builds a rotation matrix from a quaternion to a rotation matrix,
 * stores the result in pOut and returns the result.
 */
static inline void CC3KMMat4RotationQuaternion(GLfloat* m, const CC3Vector4 q) {
/*
     |       2     2									|
     | 1 - 2Y  - 2Z    2XY + 2ZW      2XZ - 2YW		 0	|
     |													|
     |                       2     2					|
 M = | 2XY - 2ZW       1 - 2X  - 2Z   2YZ + 2XW		 0	|
     |													|
     |                                      2     2		|
     | 2XZ + 2YW       2YZ - 2XW      1 - 2X  - 2Y	 0	|
     |													|
     |     0			   0			  0          1  |
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
	
	m[0] = 1.0f - twoYY - twoZZ;
	m[1] = twoXY - twoZW;
	m[2] = twoXZ + twoYW;
	m[3] = 0.0f;
	
	m[4] = twoXY + twoZW;
	m[5] = 1.0f - twoXX - twoZZ;
	m[6] = twoYZ - twoXW;
	m[7] = 0.0f;
	
	m[8] = twoXZ - twoYW;
	m[9] = twoYZ + twoXW;
	m[10] = 1.0f - twoXX - twoYY;
	m[11] = 0.0f;
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
}

/**
 * Builds a transformation matrix that translates, rotates and scales according to the specified vectors,
 * stores the result in pOut and returns the result.
 */
static inline void CC3KMMat4Transformation(GLfloat* m,
										const CC3Vector aTranslation,
										const CC3Vector aRotation,
										const CC3Vector aScale) {
/*
     |  gxR0  gyR4  gzR8   tx |
 M = |  gxR1  gyR5  gzR9   ty |
     |  gxR2  gyR6  gzR10  tz |
     |  0     0     0      1  |
	 
     where Rn is an element of the aRotation matrix (R0 - R15).
     where tx = aTranslation.x, ty = aTranslation.y, tz = aTranslation.z
     where gx = aScale.x, gy = aScale.y, gz = aScale.z
 */	
	
	// Start with basic rotation matrix
	CC3KMMat4RotationYXZ(m, aRotation);
	
	// Adjust for scale and translation
	
	m[0] *= aScale.x;
	m[1] *= aScale.x;
	m[2] *= aScale.x;
	m[3] = 0.0;
	
	m[4] *= aScale.y;
	m[5] *= aScale.y;
	m[6] *= aScale.y;
	m[7] = 0.0;
	
	m[8] *= aScale.z;
	m[9] *= aScale.z;
	m[10] *= aScale.z;
	m[11] = 0.0;
	
	m[12] = aTranslation.x;
	m[13] = aTranslation.y;
	m[14] = aTranslation.z;
	m[15] = 1.0;
}

/**
 * Multiplies mL on the left by mR on the right, and stores the result in mOut.
 *   - mOut is 4x4 matrix
 *   - mL   is 4x4 matrix
 *   - mR   is 4x4 matrix
 */
static inline void CC3Mat4Multiply(GLfloat* mOut, const GLfloat* mL, const GLfloat* mR) {
	mOut[0] = (mL[0] * mR[0]) + (mL[4] * mR[1]) + (mL[8] * mR[2]) + (mL[12] * mR[3]);
	mOut[1] = (mL[1] * mR[0]) + (mL[5] * mR[1]) + (mL[9] * mR[2]) + (mL[13] * mR[3]);
	mOut[2] = (mL[2] * mR[0]) + (mL[6] * mR[1]) + (mL[10] * mR[2]) + (mL[14] * mR[3]);
	mOut[3] = (mL[3] * mR[0]) + (mL[7] * mR[1]) + (mL[11] * mR[2]) + (mL[15] * mR[3]);
	
	mOut[4] = (mL[0] * mR[4]) + (mL[4] * mR[5]) + (mL[8] * mR[6]) + (mL[12] * mR[7]);
	mOut[5] = (mL[1] * mR[4]) + (mL[5] * mR[5]) + (mL[9] * mR[6]) + (mL[13] * mR[7]);
	mOut[6] = (mL[2] * mR[4]) + (mL[6] * mR[5]) + (mL[10] * mR[6]) + (mL[14] * mR[7]);
	mOut[7] = (mL[3] * mR[4]) + (mL[7] * mR[5]) + (mL[11] * mR[6]) + (mL[15] * mR[7]);
	
	mOut[8] = (mL[0] * mR[8]) + (mL[4] * mR[9]) + (mL[8] * mR[10]) + (mL[12] * mR[11]);
	mOut[9] = (mL[1] * mR[8]) + (mL[5] * mR[9]) + (mL[9] * mR[10]) + (mL[13] * mR[11]);
	mOut[10] = (mL[2] * mR[8]) + (mL[6] * mR[9]) + (mL[10] * mR[10]) + (mL[14] * mR[11]);
	mOut[11] = (mL[3] * mR[8]) + (mL[7] * mR[9]) + (mL[11] * mR[10]) + (mL[15] * mR[11]);
	
	mOut[12] = (mL[0] * mR[12]) + (mL[4] * mR[13]) + (mL[8] * mR[14]) + (mL[12] * mR[15]);
	mOut[13] = (mL[1] * mR[12]) + (mL[5] * mR[13]) + (mL[9] * mR[14]) + (mL[13] * mR[15]);
	mOut[14] = (mL[2] * mR[12]) + (mL[6] * mR[13]) + (mL[10] * mR[14]) + (mL[14] * mR[15]);
	mOut[15] = (mL[3] * mR[12]) + (mL[7] * mR[13]) + (mL[11] * mR[14]) + (mL[15] * mR[15]);
}

