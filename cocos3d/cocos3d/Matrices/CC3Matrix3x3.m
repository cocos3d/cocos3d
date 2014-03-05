/*
 * CC3Matrix3x3.m
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
 *
 * See header file CC3Matrix3x3.h for full API documentation.
 */

#import "CC3Matrix3x3.h"


NSString* NSStringFromCC3Matrix3x3(CC3Matrix3x3* mtxPtr) {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"\n\t[%.6f, %.6f, %.6f", mtxPtr->c1r1, mtxPtr->c2r1, mtxPtr->c3r1];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f", mtxPtr->c1r2, mtxPtr->c2r2, mtxPtr->c3r2];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f]", mtxPtr->c1r3, mtxPtr->c2r3, mtxPtr->c3r3];
	return desc;
}


#pragma mark Matrix population

void CC3Matrix3x3PopulateFromRotationYXZ(CC3Matrix3x3* mtx, CC3Vector aRotation) {
/*
     |  cycz + sxsysz   czsxsy - cysz   cxsy  |
 M = |  cxsz            cxcz           -sx    |
     |  cysxsz - czsy   cyczsx + sysz   cxcy  |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
*/
	CC3Vector rotRads = CC3VectorScaleUniform(aRotation, kCC3DegToRadFactor);
	
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

void CC3Matrix3x3PopulateFromRotationZYX(CC3Matrix3x3* mtx, CC3Vector aRotation) {
/*
     |  cycz  -cxsz + sxsycz   sxsz + cxsycz  |
 M = |  cysz   cxcz + sxsysz  -sxcz + cxsysz  |
     | -sy     sxcy            cxcy           |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
*/
	CC3Vector rotRads = CC3VectorScaleUniform(aRotation, kCC3DegToRadFactor);
	
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

void CC3Matrix3x3PopulateFromRotationX(CC3Matrix3x3* mtx, const GLfloat degrees) {
/*
     |  1  0       0       |
 M = |  0  cos(A) -sin(A)  |
     |  0  sin(A)  cos(A)  |
*/
	GLfloat radians = CC3DegToRad(degrees);
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

void CC3Matrix3x3PopulateFromRotationY(CC3Matrix3x3* mtx, const GLfloat degrees) {
/*
     |  cos(A)  0   sin(A)  |
 M = |  0       1   0       |
     | -sin(A)  0   cos(A)  |
*/
	GLfloat radians = CC3DegToRad(degrees);
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

void CC3Matrix3x3PopulateFromRotationZ(CC3Matrix3x3* mtx, const GLfloat degrees) {
/*
     |  cos(A)  -sin(A)   0  |
 M = |  sin(A)   cos(A)   0  |
     |  0        0        1  |
*/
	GLfloat radians = CC3DegToRad(degrees);
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


void CC3Matrix3x3PopulateFromQuaternion(CC3Matrix3x3* mtx, CC3Quaternion q) {
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

void CC3Matrix3x3PopulateToPointTowards(CC3Matrix3x3* mtx, const CC3Vector fwdDirection, const CC3Vector upDirection) {
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

void CC3Matrix3x3PopulateFromScale(CC3Matrix3x3* mtx, const CC3Vector aScale) {
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

CC3Vector CC3Matrix3x3ExtractRotationYXZ(const CC3Matrix3x3* mtx) {
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
	return CC3VectorScaleUniform(cc3v(radX, radY, radZ), kCC3RadToDegFactor);
}

CC3Vector CC3Matrix3x3ExtractRotationZYX(const CC3Matrix3x3* mtx) {
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
	return CC3VectorScaleUniform(cc3v(radX, radY, radZ), kCC3RadToDegFactor);
}

CC3Quaternion CC3Matrix3x3ExtractQuaternion(const CC3Matrix3x3* mtx) {
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
	return CC3QuaternionNormalize(quat);
}


#pragma mark Matrix transformations

void CC3Matrix3x3Multiply(CC3Matrix3x3* mOut, const CC3Matrix3x3* mL, const CC3Matrix3x3* mR) {
	
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


#pragma mark Matrix operations

CC3Vector CC3Matrix3x3TransformCC3Vector(const CC3Matrix3x3* mtx, CC3Vector v) {
	CC3Vector vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z);
	return vOut;
}

void CC3Matrix3x3Orthonormalize(CC3Matrix3x3* mtx, NSUInteger startColNum) {
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

void CC3Matrix3x3Transpose(CC3Matrix3x3* mtx) {
	GLfloat tmp;
	tmp = mtx->c1r2;   mtx->c1r2 = mtx->c2r1;   mtx->c2r1 = tmp;
	tmp = mtx->c1r3;   mtx->c1r3 = mtx->c3r1;   mtx->c3r1 = tmp;
	tmp = mtx->c2r3;   mtx->c2r3 = mtx->c3r2;   mtx->c3r2 = tmp;
}

BOOL CC3Matrix3x3InvertAdjoint(CC3Matrix3x3* mtx) {
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
	CC3AssertC(det != 0.0f, @"%@ is singular and cannot be inverted", NSStringFromCC3Matrix3x3(mtx));
	if (det == 0.0f) return NO;
	
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


