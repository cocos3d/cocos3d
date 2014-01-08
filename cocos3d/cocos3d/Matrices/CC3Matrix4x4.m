/*
 * CC3Matrix4x4.m
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
 * See header file CC3Matrix4x4.h for full API documentation.
 */

#import "CC3Matrix4x4.h"


NSString* NSStringFromCC3Matrix4x4(CC3Matrix4x4* mtxPtr) {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"\n\t[%.6f, %.6f, %.6f, %.6f", mtxPtr->c1r1, mtxPtr->c2r1, mtxPtr->c3r1, mtxPtr->c4r1];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f", mtxPtr->c1r2, mtxPtr->c2r2, mtxPtr->c3r2, mtxPtr->c4r2];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f", mtxPtr->c1r3, mtxPtr->c2r3, mtxPtr->c3r3, mtxPtr->c4r3];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f]", mtxPtr->c1r4, mtxPtr->c2r4, mtxPtr->c3r4, mtxPtr->c4r4];
	return desc;
}


#pragma mark Heterogeneous matrix population

void CC3Matrix3x3PopulateFrom4x4(CC3Matrix3x3* mtx, const CC3Matrix4x4* mtxSrc) {
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

void CC3Matrix4x3PopulateFrom4x4(CC3Matrix4x3* mtx, const CC3Matrix4x4* mtxSrc) {
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

void CC3Matrix4x4PopulateFrom3x3(CC3Matrix4x4* mtx, const CC3Matrix3x3* mtxSrc) {
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

void CC3Matrix3x3CopyInto4x4(const CC3Matrix3x3* mtxSrc, CC3Matrix4x4* mtx) {
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

void CC3Matrix4x4PopulateFrom4x3(CC3Matrix4x4* mtx, const CC3Matrix4x3* mtxSrc) {
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

void CC3Matrix4x3CopyInto4x4(const CC3Matrix4x3* mtxSrc, CC3Matrix4x4* mtx) {
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

void CC3Matrix4x4PopulatePerspectiveFrustum(CC3Matrix4x4* mtx,
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

void CC3Matrix4x4PopulateInfinitePerspectiveFrustum(CC3Matrix4x4* mtx,
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

void CC3Matrix4x4PopulateOrthoFrustum(CC3Matrix4x4* mtx,
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

void CC3Matrix4x4PopulateInfiniteOrthoFrustum(CC3Matrix4x4* mtx,
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


#pragma mark Matrix transformations

void CC3Matrix4x4Multiply(CC3Matrix4x4* mOut, const CC3Matrix4x4* mL, const CC3Matrix4x4* mR) {
	
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


#pragma mark Matrix operations

CC3Vector4 CC3Matrix4x4TransformCC3Vector4(const CC3Matrix4x4* mtx, CC3Vector4 v) {
	CC3Vector4 vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z) + (mtx->c4r1 * v.w);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z) + (mtx->c4r2 * v.w);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z) + (mtx->c4r3 * v.w);
	vOut.w = (mtx->c1r4 * v.x) + (mtx->c2r4 * v.y) + (mtx->c3r4 * v.z) + (mtx->c4r4 * v.w);
	return vOut;
}

CC3Vector CC3Matrix4x4TransformLocation(const CC3Matrix4x4* mtx, CC3Vector v) {
	CC3Vector vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z) + mtx->c4r1;
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z) + mtx->c4r2;
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z) + mtx->c4r3;
	return vOut;
}

CC3Vector CC3Matrix4x4TransformDirection(const CC3Matrix4x4* mtx, CC3Vector v) {
	CC3Vector vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z);
	return vOut;
}

void CC3Matrix4x4Transpose(CC3Matrix4x4* mtx) {
	GLfloat tmp;
	tmp = mtx->c1r2;   mtx->c1r2 = mtx->c2r1;   mtx->c2r1 = tmp;
	tmp = mtx->c1r3;   mtx->c1r3 = mtx->c3r1;   mtx->c3r1 = tmp;
	tmp = mtx->c1r4;   mtx->c1r4 = mtx->c4r1;   mtx->c4r1 = tmp;
	tmp = mtx->c2r3;   mtx->c2r3 = mtx->c3r2;   mtx->c3r2 = tmp;
	tmp = mtx->c2r4;   mtx->c2r4 = mtx->c4r2;   mtx->c4r2 = tmp;
	tmp = mtx->c3r4;   mtx->c3r4 = mtx->c4r3;   mtx->c4r3 = tmp;
}

BOOL CC3Matrix4x4InvertAdjoint(CC3Matrix4x4* m) {
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
	CC3AssertC(det != 0.0f, @"%@ is singular and cannot be inverted", NSStringFromCC3Matrix4x4(m));
	if (det == 0.0f) return NO;
	
	// Divide the classical adjoint matrix by the determinant and set back into original matrix.
	GLfloat ooDet = 1.0 / det;		// Turn div into mult for speed
	m->c1r1 = adj.c1r1 * ooDet;
	m->c1r2 = adj.c1r2 * ooDet;
	m->c1r3 = adj.c1r3 * ooDet;
	m->c1r4 = adj.c1r4 * ooDet;
	m->c2r1 = adj.c2r1 * ooDet;
	m->c2r2 = adj.c2r2 * ooDet;
	m->c2r3 = adj.c2r3 * ooDet;
	m->c2r4 = adj.c2r4 * ooDet;
	m->c3r1 = adj.c3r1 * ooDet;
	m->c3r2 = adj.c3r2 * ooDet;
	m->c3r3 = adj.c3r3 * ooDet;
	m->c3r4 = adj.c3r4 * ooDet;
	m->c4r1 = adj.c4r1 * ooDet;
	m->c4r2 = adj.c4r2 * ooDet;
	m->c4r3 = adj.c4r3 * ooDet;
	m->c4r4 = adj.c4r4 * ooDet;
	
	return YES;
}

void CC3Matrix4x4InvertRigid(CC3Matrix4x4* mtx) {
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


