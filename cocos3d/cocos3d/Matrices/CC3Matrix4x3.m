/*
 * CC3Matrix4x3.m
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
 * See header file CC3Matrix4x3.h for full API documentation.
 */

#import "CC3Matrix4x3.h"


NSString* NSStringFromCC3Matrix4x3(CC3Matrix4x3* mtxPtr) {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"\n\t[%.6f, %.6f, %.6f, %.6f", mtxPtr->c1r1, mtxPtr->c2r1, mtxPtr->c3r1, mtxPtr->c4r1];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f", mtxPtr->c1r2, mtxPtr->c2r2, mtxPtr->c3r2, mtxPtr->c4r2];
	[desc appendFormat: @"\n\t %.6f, %.6f, %.6f, %.6f]", mtxPtr->c1r3, mtxPtr->c2r3, mtxPtr->c3r3, mtxPtr->c4r3];
	return desc;
}


#pragma mark Heterogeneous matrix population

void CC3Matrix4x3PopulateOrthoFrustum(CC3Matrix4x3* mtx,
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

void CC3Matrix4x3PopulateInfiniteOrthoFrustum(CC3Matrix4x3* mtx,
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


#pragma mark Matrix transformations

void CC3Matrix4x3Multiply(CC3Matrix4x3* mOut, const CC3Matrix4x3* mL, const CC3Matrix4x3* mR) {
	
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


#pragma mark Matrix operations

CC3Vector4 CC3Matrix4x3TransformCC3Vector4(const CC3Matrix4x3* mtx, CC3Vector4 v) {
	CC3Vector4 vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z) + (mtx->c4r1 * v.w);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z) + (mtx->c4r2 * v.w);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z) + (mtx->c4r3 * v.w);
	vOut.w = v.w;
	return vOut;
}

CC3Vector CC3Matrix4x3TransformLocation(const CC3Matrix4x3* mtx, CC3Vector v) {
	CC3Vector vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z) + mtx->c4r1;
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z) + mtx->c4r2;
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z) + mtx->c4r3;
	return vOut;
}

CC3Vector CC3Matrix4x3TransformDirection(const CC3Matrix4x3* mtx, CC3Vector v) {
	CC3Vector vOut;
	vOut.x = (mtx->c1r1 * v.x) + (mtx->c2r1 * v.y) + (mtx->c3r1 * v.z);
	vOut.y = (mtx->c1r2 * v.x) + (mtx->c2r2 * v.y) + (mtx->c3r2 * v.z);
	vOut.z = (mtx->c1r3 * v.x) + (mtx->c2r3 * v.y) + (mtx->c3r3 * v.z);
	return vOut;
}


