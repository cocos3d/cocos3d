/*
 * CC3LinearMatrix.m
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
 * See header file CC3LinearMatrix.h for full API documentation.
 */

#import "CC3LinearMatrix.h"


#pragma mark CC3LinearMatrix

@implementation CC3LinearMatrix


#pragma mark Allocation and initialization

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", self.class, NSStringFromCC3Matrix3x3(&_contents)];
}


#pragma mark Population

-(void) implPopulateZero { CC3Matrix3x3PopulateZero(&_contents); }

-(void) implPopulateIdentity { CC3Matrix3x3PopulateIdentity(&_contents); }

// Double-dispatch to the other matrix
-(void) implPopulateFrom: (CC3Matrix*) aMatrix { [aMatrix populateCC3Matrix3x3: &_contents]; }

-(void) implPopulateFromCC3Matrix3x3: (CC3Matrix3x3*) mtx { CC3Matrix3x3PopulateFrom3x3(&_contents, mtx); }

-(void) populateCC3Matrix3x3: (CC3Matrix3x3*) mtx { CC3Matrix3x3PopulateFrom3x3(mtx, &_contents); }

-(void) implPopulateFromCC3Matrix4x3: (CC3Matrix4x3*) mtx { CC3Matrix3x3PopulateFrom4x3(&_contents, mtx); }

-(void) populateCC3Matrix4x3: (CC3Matrix4x3*) mtx { CC3Matrix4x3PopulateFrom3x3(mtx, &_contents); }

-(void) implPopulateFromCC3Matrix4x4: (CC3Matrix4x4*) mtx { CC3Matrix3x3PopulateFrom4x4(&_contents, mtx); }

-(void) populateCC3Matrix4x4: (CC3Matrix4x4*) mtx { CC3Matrix4x4PopulateFrom3x3(mtx, &_contents); }

-(void) implPopulateFromRotation: (CC3Vector) aRotation {
	CC3Matrix3x3PopulateFromRotationYXZ(&_contents, aRotation);
}

-(void) implPopulateFromQuaternion: (CC3Quaternion) aQuaternion {
	CC3Matrix3x3PopulateFromQuaternion(&_contents, aQuaternion);
}

-(void) implPopulateFromScale: (CC3Vector) aScale { CC3Matrix3x3PopulateFromScale(&_contents, aScale); }

// Keep the compiler happy about interface re-declaration
-(void) populateFromTranslation: (CC3Vector) aTranslation { [super populateFromTranslation: aTranslation]; }

// Linear matrix unaffected by translation
-(void) implPopulateFromTranslation: (CC3Vector) aTranslation { [self implPopulateIdentity]; }

-(void) implPopulateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection {
	CC3Matrix3x3PopulateToPointTowards(&_contents, fwdDirection, upDirection);
}

// Keep the compiler happy about interface re-declaration
-(void) populateToLookAt: (CC3Vector) targetLocation
			   withEyeAt: (CC3Vector) eyeLocation
				  withUp: (CC3Vector) upDirection {
	[self populateToLookAt: targetLocation withEyeAt: eyeLocation withUp: upDirection];
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

// Keep the compiler happy with the interface re-declaration
-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
							  andTop: (GLfloat) top  
						   andBottom: (GLfloat) bottom
							 andNear: (GLfloat) near
							  andFar: (GLfloat) far {
	[super populateOrthoFromFrustumLeft: left andRight: right andTop: top
							  andBottom: bottom andNear: near andFar: far];
}

// Keep the compiler happy with the interface re-declaration
-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
							  andTop: (GLfloat) top  
						   andBottom: (GLfloat) bottom
							 andNear: (GLfloat) near {
	[super populateOrthoFromFrustumLeft: left andRight: right andTop: top andBottom: bottom andNear: near];
}


#pragma mark Accessing content

-(CC3Vector) extractRotation { return CC3Matrix3x3ExtractRotationYXZ(&_contents); }

-(CC3Quaternion) extractQuaternion { return CC3Matrix3x3ExtractQuaternion(&_contents); }

-(CC3Vector) extractForwardDirection { return CC3Matrix3x3ExtractForwardDirection(&_contents); }

-(CC3Vector) extractUpDirection { return CC3Matrix3x3ExtractUpDirection(&_contents); }

-(CC3Vector) extractRightDirection { return CC3Matrix3x3ExtractRightDirection(&_contents); }

-(CC3Vector) extractTranslation { return kCC3VectorZero; }


#pragma mark Matrix transformations

-(void) implRotateBy: (CC3Vector) aRotation { CC3Matrix3x3RotateYXZBy(&_contents, aRotation); }

-(void) implRotateByQuaternion: (CC3Quaternion) aQuaternion {
	CC3Matrix3x3RotateByQuaternion(&_contents, aQuaternion);
}

-(void) orthonormalizeRotationStartingWith: (NSUInteger) startColNum {
	CC3Matrix3x3Orthonormalize(&_contents, startColNum);
}

-(void) implScaleBy: (CC3Vector) aScale { CC3Matrix3x3ScaleBy(&_contents, aScale); }

// Linear matrix unaffected by translation
-(void) implTranslateBy: (CC3Vector) aTranslation {}


#pragma mark Matrix multiplication

-(void) implMultiplyBy: (CC3Matrix*) aMatrix {
	[aMatrix multiplyIntoCC3Matrix3x3: &_contents];
}

-(void) multiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix3x3 mRslt;
	CC3Matrix3x3Multiply(&mRslt, mtx, &_contents);
	CC3Matrix3x3PopulateFrom3x3(mtx, &mRslt);
}

-(void) multiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) {
		CC3Matrix3x3PopulateFrom3x3(&_contents, mtx);
	} else {
		CC3Matrix3x3 mRslt;
		CC3Matrix3x3Multiply(&mRslt, &_contents, mtx);
		CC3Matrix3x3PopulateFrom3x3(&_contents, &mRslt);
	}
}

-(void) multiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x3 mRslt, mMine;
	CC3Matrix4x3PopulateFrom3x3(&mMine, &_contents);
	CC3Matrix4x3Multiply(&mRslt, mtx, &mMine);
	CC3Matrix4x3PopulateFrom4x3(mtx, &mRslt);
}

-(void) multiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) {
		CC3Matrix3x3PopulateFrom4x3(&_contents, mtx);
	} else {
		CC3Matrix4x3 mRslt, mMine;
		CC3Matrix4x3PopulateFrom3x3(&mMine, &_contents);
		CC3Matrix4x3Multiply(&mRslt, &mMine, mtx);
		CC3Matrix3x3PopulateFrom4x3(&_contents, &mRslt);
	}
}

-(void) multiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x4 mRslt, mMine;
	CC3Matrix4x4PopulateFrom3x3(&mMine, &_contents);
	CC3Matrix4x4Multiply(&mRslt, mtx, &mMine);
	CC3Matrix4x4PopulateFrom4x4(mtx, &mRslt);
}

-(void) multiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) {
		CC3Matrix3x3PopulateFrom4x4(&_contents, mtx);
	} else {
		CC3Matrix4x4 mRslt, mMine;
		CC3Matrix4x4PopulateFrom3x3(&mMine, &_contents);
		CC3Matrix4x4Multiply(&mRslt, &mMine, mtx);
		CC3Matrix3x3PopulateFrom4x4(&_contents, &mRslt);
	}
}

-(void) implLeftMultiplyBy: (CC3Matrix*) aMatrix {
	[aMatrix leftMultiplyIntoCC3Matrix3x3: &_contents];
}

-(void) leftMultiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix3x3 mRslt;
	CC3Matrix3x3Multiply(&mRslt, &_contents, mtx);
	CC3Matrix3x3PopulateFrom3x3(mtx, &mRslt);
}

-(void) leftMultiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	if (_isIdentity) {
		CC3Matrix3x3PopulateFrom3x3(&_contents, mtx);
	} else {
		CC3Matrix3x3 mRslt;
		CC3Matrix3x3Multiply(&mRslt, mtx, &_contents);
		CC3Matrix3x3PopulateFrom3x3(&_contents, &mRslt);
	}
}

-(void) leftMultiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x3 mRslt, mMine;
	CC3Matrix4x3PopulateFrom3x3(&mMine, &_contents);
	CC3Matrix4x3Multiply(&mRslt, &mMine, mtx);
	CC3Matrix4x3PopulateFrom4x3(mtx, &mRslt);
}

-(void) leftMultiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	if (_isIdentity) {
		CC3Matrix3x3PopulateFrom4x3(&_contents, mtx);
	} else {
		CC3Matrix4x3 mRslt, mMine;
		CC3Matrix4x3PopulateFrom3x3(&mMine, &_contents);
		CC3Matrix4x3Multiply(&mRslt, mtx, &mMine);
		CC3Matrix3x3PopulateFrom4x3(&_contents, &mRslt);
	}
}

-(void) leftMultiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) return;
	CC3Matrix4x4 mRslt, mMine;
	CC3Matrix4x4PopulateFrom3x3(&mMine, &_contents);
	CC3Matrix4x4Multiply(&mRslt, &mMine, mtx);
	CC3Matrix4x4PopulateFrom4x4(mtx, &mRslt);
}

-(void) leftMultiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	if (_isIdentity) {
		CC3Matrix3x3PopulateFrom4x4(&_contents, mtx);
	} else {
		CC3Matrix4x4 mRslt, mMine;
		CC3Matrix4x4PopulateFrom3x3(&mMine, &_contents);
		CC3Matrix4x4Multiply(&mRslt, mtx, &mMine);
		CC3Matrix3x3PopulateFrom4x4(&_contents, &mRslt);
	}
}


#pragma mark Matrix operations	 

// Short-circuit if this is an identity matrix
-(CC3Vector) transformLocation: (CC3Vector) aLocation {
	if (_isIdentity) return aLocation;
	return CC3Matrix3x3TransformCC3Vector(&_contents, aLocation);
}

// Short-circuit if this is an identity matrix
-(CC3Vector) transformDirection: (CC3Vector) aDirection {
	if (_isIdentity) return aDirection;
	return CC3Matrix3x3TransformCC3Vector(&_contents, aDirection);
}

// Short-circuit if this is an identity matrix
-(CC3Vector4) transformHomogeneousVector: (CC3Vector4) v {
	if (_isIdentity) return v;
	
	CC3Vector4 vOut;
	vOut.x = (_contents.c1r1 * v.x) + (_contents.c2r1 * v.y) + (_contents.c3r1 * v.z);
	vOut.y = (_contents.c1r2 * v.x) + (_contents.c2r2 * v.y) + (_contents.c3r2 * v.z);
	vOut.z = (_contents.c1r3 * v.x) + (_contents.c2r3 * v.y) + (_contents.c3r3 * v.z);
	vOut.w = v.w;
	return vOut;
}

// Short-circuit if this is an identity matrix
-(void) transpose {
	if (_isIdentity) return;
	CC3Matrix3x3Transpose(&_contents);
}

// Short-circuit if this is an identity matrix
-(BOOL) invertAdjoint {
	if (_isIdentity) return YES;
	return CC3Matrix3x3InvertAdjoint(&_contents);
}

// Short-circuit if this is an identity matrix
// The inverse of a rigid linear matrix is equal to its transpose.
-(void) invertRigid {
	if (_isIdentity) return;
	CC3Matrix3x3Transpose(&_contents);
}

@end



