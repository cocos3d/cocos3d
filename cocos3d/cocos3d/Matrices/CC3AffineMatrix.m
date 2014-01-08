/*
 * CC3AffineMatrix.m
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
 * See header file CC3AffineMatrix.h for full API documentation.
 */

#import "CC3AffineMatrix.h"


#pragma mark -
#pragma mark CC3AffineMatrix implementation

@interface CC3Matrix (TemplateMethods)
-(void) implPopulateFrom: (CC3Matrix*) aMatrix;
-(void) implMultiplyBy: (CC3Matrix*) aMatrix;
-(void) implLeftMultiplyBy: (CC3Matrix*) aMatrix;
+(void) implPopulateYXZ: (GLfloat*) mtxElems fromRotation: (CC3Vector) aVector;
+(void) implPopulateZYX: (GLfloat*) mtxElems fromRotation: (CC3Vector) aVector;
+(void) implPopulate: (GLfloat*) mtxElems fromQuaternion: (CC3Quaternion) aQuaternion;
+(void) implPopulate: (GLfloat*) mtxElems fromScale: (CC3Vector) aScale;
+(void) implPopulate: (GLfloat*) mtxElems fromTranslation: (CC3Vector) aTranslation;
+(void) implRotateYXZ: (GLfloat*) mtxElems by: (CC3Vector) aRotation;
+(void) implRotateZYX: (GLfloat*) mtxElems by: (CC3Vector) aRotation;
+(void) implRotate: (GLfloat*) mtxElems byQuaternion: (CC3Quaternion) aQuaternion;
+(void) implScale: (GLfloat*) mtxElems by: (CC3Vector) aScale;
+(void) implTranslate: (GLfloat*) mtxElems by: (CC3Vector) aTranslation;
@end

@implementation CC3AffineMatrix


#pragma mark Allocation and initialization

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", self.class, NSStringFromCC3Matrix4x3(&_contents)];
}


#pragma mark Population

-(void) implPopulateZero { CC3Matrix4x3PopulateZero(&_contents); }

-(void) implPopulateIdentity { CC3Matrix4x3PopulateIdentity(&_contents); }

// Double-dispatch to the other matrix
-(void) implPopulateFrom: (CC3Matrix*) aMatrix { [aMatrix populateCC3Matrix4x3: &_contents]; }

-(void) implPopulateFromCC3Matrix3x3: (CC3Matrix3x3*) mtx { CC3Matrix4x3PopulateFrom3x3(&_contents, mtx); }

-(void) populateCC3Matrix3x3: (CC3Matrix3x3*) mtx { CC3Matrix3x3PopulateFrom4x3(mtx, &_contents); }

-(void) implPopulateFromCC3Matrix4x3: (CC3Matrix4x3*) mtx { CC3Matrix4x3PopulateFrom4x3(&_contents, mtx); }

-(void) populateCC3Matrix4x3: (CC3Matrix4x3*) mtx { CC3Matrix4x3PopulateFrom4x3(mtx, &_contents); }

-(void) implPopulateFromCC3Matrix4x4: (CC3Matrix4x4*) mtx { CC3Matrix4x3PopulateFrom4x4(&_contents, mtx); }

-(void) populateCC3Matrix4x4: (CC3Matrix4x4*) mtx { CC3Matrix4x4PopulateFrom4x3(mtx, &_contents); }

-(void) implPopulateFromRotation: (CC3Vector) aRotation {
	CC3Matrix4x3PopulateFromRotationYXZ(&_contents, aRotation);
}

-(void) implPopulateFromQuaternion: (CC3Quaternion) aQuaternion {
	CC3Matrix4x3PopulateFromQuaternion(&_contents, aQuaternion);
}

-(void) implPopulateFromScale: (CC3Vector) aScale {
	CC3Matrix4x3PopulateFromScale(&_contents, aScale);
}

-(void) implPopulateFromTranslation: (CC3Vector) aTranslation {
	CC3Matrix4x3PopulateFromTranslation(&_contents, aTranslation);
}

-(void) implPopulateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection {
	CC3Matrix4x3PopulateToPointTowards(&_contents, fwdDirection, upDirection);
}

// Keep the compiler happy with the interface re-declaration
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near
						 andFar: (GLfloat) far {
	[super populateFromFrustumLeft: left andRight: right andTop: top
						 andBottom: bottom andNear: near andFar: far];
}

// Keep the compiler happy with the interface re-declaration
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near {
	[super populateFromFrustumLeft: left andRight: right andTop: top andBottom: bottom andNear: near];
}

-(void) implPopulateOrthoFromFrustumLeft: (GLfloat) left
								andRight: (GLfloat) right
								  andTop: (GLfloat) top  
							   andBottom: (GLfloat) bottom
								 andNear: (GLfloat) near
								  andFar: (GLfloat) far {
	CC3Matrix4x3PopulateOrthoFrustum(&_contents, left, right, top, bottom, near, far);
}

-(void) implPopulateOrthoFromFrustumLeft: (GLfloat) left
								andRight: (GLfloat) right
								  andTop: (GLfloat) top  
							   andBottom: (GLfloat) bottom
								 andNear: (GLfloat) near {
	CC3Matrix4x3PopulateInfiniteOrthoFrustum(&_contents, left, right, top, bottom, near);
}


#pragma mark Accessing content

-(CC3Vector) extractRotation { return CC3Matrix4x3ExtractRotationYXZ(&_contents); }

-(CC3Quaternion) extractQuaternion { return CC3Matrix4x3ExtractQuaternion(&_contents); }

-(CC3Vector) extractForwardDirection { return CC3Matrix4x3ExtractForwardDirection(&_contents); }

-(CC3Vector) extractUpDirection { return CC3Matrix4x3ExtractUpDirection(&_contents); }

-(CC3Vector) extractRightDirection { return CC3Matrix4x3ExtractRightDirection(&_contents); }

-(CC3Vector) extractTranslation { return CC3Matrix4x3ExtractTranslation(&_contents); }


#pragma mark Matrix transformations

-(void) implRotateBy: (CC3Vector) aRotation { CC3Matrix4x3RotateYXZBy(&_contents, aRotation); }

-(void) implRotateByQuaternion: (CC3Quaternion) aQuaternion {
	CC3Matrix4x3RotateByQuaternion(&_contents, aQuaternion);
}

-(void) orthonormalizeRotationStartingWith: (NSUInteger) startColNum {
	CC3Matrix4x3Orthonormalize(&_contents, startColNum);
}

-(void) implScaleBy: (CC3Vector) aScale { CC3Matrix4x3ScaleBy(&_contents, aScale); }

-(void) implTranslateBy: (CC3Vector) aTranslation { CC3Matrix4x3TranslateBy(&_contents, aTranslation); }


#pragma mark Matrix multiplication

-(void) implMultiplyBy: (CC3Matrix*) aMatrix {
	[aMatrix multiplyIntoCC3Matrix4x3: &_contents];
}

-(void) multiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x3 mRslt, mtx4;
	CC3Matrix4x3PopulateFrom3x3(&mtx4, mtx);
	CC3Matrix4x3Multiply(&mRslt, &mtx4, &_contents);
	CC3Matrix3x3PopulateFrom4x3(mtx, &mRslt);
}

-(void) multiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) {
		CC3Matrix4x3PopulateFrom3x3(&_contents, mtx);
	} else {
		CC3Matrix4x3 mRslt, mtx4;
		CC3Matrix4x3PopulateFrom3x3(&mtx4, mtx);
		CC3Matrix4x3Multiply(&mRslt, &_contents, &mtx4);
		CC3Matrix4x3PopulateFrom4x3(&_contents, &mRslt);
	}
}

-(void) multiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x3 mRslt;
	CC3Matrix4x3Multiply(&mRslt, mtx, &_contents);
	CC3Matrix4x3PopulateFrom4x3(mtx, &mRslt);
}

-(void) multiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) {
		CC3Matrix4x3PopulateFrom4x3(&_contents, mtx);
	} else {
		CC3Matrix4x3 mRslt;
		CC3Matrix4x3Multiply(&mRslt, &_contents, mtx);
		CC3Matrix4x3PopulateFrom4x3(&_contents, &mRslt);
	}
}

-(void) multiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x4 mRslt, mMine;
	CC3Matrix4x4PopulateFrom4x3(&mMine, &_contents);
	CC3Matrix4x4Multiply(&mRslt, mtx, &mMine);
	CC3Matrix4x4PopulateFrom4x4(mtx, &mRslt);
}

-(void) multiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) {
		CC3Matrix4x3PopulateFrom4x4(&_contents, mtx);
	} else {
		CC3Matrix4x4 mRslt, mMine;
		CC3Matrix4x4PopulateFrom4x3(&mMine, &_contents);
		CC3Matrix4x4Multiply(&mRslt, &mMine, mtx);
		CC3Matrix4x3PopulateFrom4x4(&_contents, &mRslt);
	}
}

-(void) implLeftMultiplyBy: (CC3Matrix*) aMatrix {
	[aMatrix leftMultiplyIntoCC3Matrix4x3: &_contents];
}

-(void) leftMultiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x3 mRslt, mtx4;
	CC3Matrix4x3PopulateFrom3x3(&mtx4, mtx);
	CC3Matrix4x3Multiply(&mRslt, &_contents, &mtx4);
	CC3Matrix3x3PopulateFrom4x3(mtx, &mRslt);
}

-(void) leftMultiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) {
		CC3Matrix4x3PopulateFrom3x3(&_contents, mtx);
	} else {
		CC3Matrix4x3 mRslt, mtx4;
		CC3Matrix4x3PopulateFrom3x3(&mtx4, mtx);
		CC3Matrix4x3Multiply(&mRslt, &mtx4, &_contents);
		CC3Matrix4x3PopulateFrom4x3(&_contents, &mRslt);
	}
}

-(void) leftMultiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x3 mRslt;
	CC3Matrix4x3Multiply(&mRslt, &_contents, mtx);
	CC3Matrix4x3PopulateFrom4x3(mtx, &mRslt);
}

-(void) leftMultiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) {
		CC3Matrix4x3PopulateFrom4x3(&_contents, mtx);
	} else {
		CC3Matrix4x3 mRslt;
		CC3Matrix4x3Multiply(&mRslt, mtx, &_contents);
		CC3Matrix4x3PopulateFrom4x3(&_contents, &mRslt);
	}
}

-(void) leftMultiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x4 mRslt, mMine;
	CC3Matrix4x4PopulateFrom4x3(&mMine, &_contents);
	CC3Matrix4x4Multiply(&mRslt, &mMine, mtx);
	CC3Matrix4x4PopulateFrom4x4(mtx, &mRslt);
}

-(void) leftMultiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) {
		CC3Matrix4x3PopulateFrom4x4(&_contents, mtx);
	} else {
		CC3Matrix4x4 mRslt, mMine;
		CC3Matrix4x4PopulateFrom4x3(&mMine, &_contents);
		CC3Matrix4x4Multiply(&mRslt, mtx, &mMine);
		CC3Matrix4x3PopulateFrom4x4(&_contents, &mRslt);
	}
}


#pragma mark Matrix operations	 

// Short-circuit if this is an identity matrix
-(CC3Vector) transformLocation: (CC3Vector) v {
	if (_isIdentity) return v;
	return CC3Matrix4x3TransformLocation(&_contents, v);
}

// Short-circuit if this is an identity matrix
-(CC3Vector) transformDirection: (CC3Vector) v {
	if (_isIdentity) return v;
	return CC3Matrix4x3TransformDirection(&_contents, v);
}

// Short-circuit if this is an identity matrix
-(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector {
	if (_isIdentity) return aVector;
	return CC3Matrix4x3TransformCC3Vector4(&_contents, aVector);
}

// Short-circuit if this is an identity matrix
-(void) transpose { if ( !_isIdentity ) CC3Matrix4x3Transpose(&_contents); }

// Short-circuit if this is an identity matrix
-(BOOL) invertAdjoint {
	if (_isIdentity) return YES;
	return CC3Matrix4x3InvertAdjoint(&_contents);
}

// Short-circuit if this is an identity matrix
-(void) invertRigid { if ( !_isIdentity ) CC3Matrix4x3InvertRigid(&_contents); }

@end



