/*
 * CC3Matrix.m
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
 *
 * See header file CC3Matrix.h for full API documentation.
 */

#import "CC3Matrix.h"


#pragma mark CC3Matrix implementation

@interface CC3Matrix (TemplateMethods)
-(void) implPopulateZero;
-(void) implPopulateIdentity;
-(void) implPopulateFrom: (CC3Matrix*) aMatrix;
-(void) implPopulateFromCC3Matrix3x3: (CC3Matrix3x3*) mtx;
-(void) implPopulateFromCC3Matrix4x3: (CC3Matrix4x3*) mtx;
-(void) implPopulateFromCC3Matrix4x4: (CC3Matrix4x4*) mtx;
-(void) implPopulateFromRotation: (CC3Vector) aRotation;
-(void) implPopulateFromQuaternion: (CC3Quaternion) aQuaternion;
-(void) implPopulateFromScale: (CC3Vector) aScale;
-(void) implPopulateFromTranslation: (CC3Vector) aTranslation;
-(void) implPopulateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection;
-(void) implPopulateFromFrustumLeft: (GLfloat) left andRight: (GLfloat) right andTop: (GLfloat) top  
						  andBottom: (GLfloat) bottom andNear: (GLfloat) near andFar: (GLfloat) far;
-(void) implPopulateFromFrustumLeft: (GLfloat) left andRight: (GLfloat) right andTop: (GLfloat) top  
						  andBottom: (GLfloat) bottom andNear: (GLfloat) near;
-(void) implPopulateOrthoFromFrustumLeft: (GLfloat) left andRight: (GLfloat) right andTop: (GLfloat) top  
							   andBottom: (GLfloat) bottom andNear: (GLfloat) near andFar: (GLfloat) far;
-(void) implPopulateOrthoFromFrustumLeft: (GLfloat) left andRight: (GLfloat) right andTop: (GLfloat) top  
							   andBottom: (GLfloat) bottom andNear: (GLfloat) near;
-(void) implRotateBy: (CC3Vector) aRotation;
-(void) implRotateByQuaternion: (CC3Quaternion) aQuaternion;
-(void) implScaleBy: (CC3Vector) aScale;
-(void) implTranslateBy: (CC3Vector) aTranslation;
-(void) implMultiplyBy: (CC3Matrix*) aMatrix;
-(void) implLeftMultiplyBy: (CC3Matrix*) aMatrix;
@end

@implementation CC3Matrix

@synthesize isIdentity, isRigid;


#pragma mark Allocation and initialization

-(id) init {
	if( (self = [super init]) ) {
		[self populateIdentity];
	}
	return self;
}

+(id) matrix { return [[[self alloc] init] autorelease]; }

+(id) matrixByMultiplying: (CC3Matrix*) mL by: (CC3Matrix*) mR {
	CC3Matrix* m = [mL copy];
	[m multiplyBy: mR];
	return [m autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	CC3Matrix* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }


#pragma mark Population

-(void) populateZero {
	[self implPopulateZero];
	isIdentity = NO;
	isRigid = NO;
}

/** Template method. Subclasses will provide implementation. */
-(void) implPopulateZero {
	NSAssert1(NO, @"%@ does not implement the implPopulateZero method", self);
}

-(void) populateIdentity {
	if (!isIdentity) {
		[self implPopulateIdentity];
		isIdentity = YES;
		isRigid = YES;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implPopulateIdentity {
	NSAssert1(NO, @"%@ does not implement the implPopulateIdentity method", self);
}

-(void) populateFrom: (CC3Matrix*) aMatrix {
	if (!aMatrix || aMatrix.isIdentity) {
		[self populateIdentity];
	} else {
		[self implPopulateFrom: aMatrix];
		isIdentity = NO;
		isRigid = aMatrix.isRigid;
	}
}

/**
 * Template method. Subclasses will provide implementation.
 * Subclass implementations will double-dispatch to the other matrix.
 * Subclass implementation does not need to set isIdentity or isRigid.
 */
-(void) implPopulateFrom: (CC3Matrix*) aMatrix {
	NSAssert1(NO, @"%@ does not implement the implPopulateFrom: method", self);
}

-(void) populateFromCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	[self implPopulateFromCC3Matrix3x3: mtx];
	isIdentity = CC3Matrix3x3IsIdentity(mtx);
	isRigid = isIdentity;
}

-(void) implPopulateFromCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the implPopulateFromCC3Matrix3x3: method", self);
}

-(void) populateCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the populateCC3Matrix3x3: method", self);
}

-(void) populateFromCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	[self implPopulateFromCC3Matrix4x3: mtx];
	isIdentity = CC3Matrix4x3IsIdentity(mtx);
	isRigid = isIdentity;
}

-(void) implPopulateFromCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the implPopulateFromCC3Matrix3x3: method", self);
}

-(void) populateCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the populateCC3Matrix4x3: method", self);
}

-(void) populateFromCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	[self implPopulateFromCC3Matrix4x4: mtx];
	isIdentity = CC3Matrix4x4IsIdentity(mtx);
	isRigid = isIdentity;
}

-(void) implPopulateFromCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	NSAssert1(NO, @"%@ does not implement the implPopulateFromCC3Matrix4x4: method", self);
}

-(void) populateCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	NSAssert1(NO, @"%@ does not implement the populateCC3Matrix4x4: method", self);
}

-(void) populateFromRotation: (CC3Vector) aRotation {
	if (CC3VectorsAreEqual(aRotation, kCC3VectorZero)) {
		[self populateIdentity];
	} else {
		[self implPopulateFromRotation: aRotation];
		isIdentity = NO;
		isRigid = YES;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implPopulateFromRotation: (CC3Vector) aRotation {
	NSAssert1(NO, @"%@ does not implement the implPopulateFromRotation: method", self);
}

-(void) populateFromQuaternion: (CC3Quaternion) aQuaternion {
	if (CC3QuaternionsAreEqual(aQuaternion, kCC3QuaternionIdentity)) {
		[self populateIdentity];
	} else {
		[self implPopulateFromQuaternion: aQuaternion];
		isIdentity = NO;
		isRigid = YES;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implPopulateFromQuaternion: (CC3Quaternion) aQuaternion {
	NSAssert1(NO, @"%@ does not implement the implPopulateFromQuaternion: method", self);
}

-(void) populateFromScale: (CC3Vector) aScale {
	if (CC3VectorsAreEqual(aScale, kCC3VectorUnitCube)) {
		[self populateIdentity];
	} else {
		[self implPopulateFromScale: aScale];
		isIdentity = NO;
		isRigid = NO;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implPopulateFromScale: (CC3Vector) aScale {
	NSAssert1(NO, @"%@ does not implement the implPopulateFromScale: method", self);
}

-(void) populateFromTranslation: (CC3Vector) aTranslation {
	if (CC3VectorsAreEqual(aTranslation, kCC3VectorZero)) {
		[self populateIdentity];
	} else {
		[self implPopulateFromTranslation: aTranslation];
		isIdentity = NO;
		isRigid = YES;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implPopulateFromTranslation: (CC3Vector) aTranslation {
	NSAssert1(NO, @"%@ does not implement the implPopulateFromTranslation: method", self);
}

-(void) populateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection {
	[self implPopulateToPointTowards: fwdDirection withUp: upDirection];
	isIdentity = NO;
	isRigid = YES;
}

/** Template method. Subclasses will provide implementation. */
-(void) implPopulateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection {
	NSAssert1(NO, @"%@ does not implement the implPopulateToPointTowards:withUp: method", self);
}

-(void) populateToLookAt: (CC3Vector) targetLocation
			   withEyeAt: (CC3Vector) eyeLocation
				  withUp: (CC3Vector) upDirection {
	
	CC3Vector fwdDir = CC3VectorDifference(targetLocation, eyeLocation);
	[self populateToPointTowards: fwdDir withUp: upDirection];
	[self transpose];		
	[self translateBy: CC3VectorNegate(eyeLocation)];
	isIdentity = NO;
	isRigid = YES;
}

-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near
						 andFar: (GLfloat) far {
	[self implPopulateFromFrustumLeft: left andRight: right andTop: top
							andBottom: bottom andNear: near andFar: far];
	isIdentity = NO;
	isRigid = NO;
}

-(void) implPopulateFromFrustumLeft: (GLfloat) left
						   andRight: (GLfloat) right
							 andTop: (GLfloat) top  
						  andBottom: (GLfloat) bottom
							andNear: (GLfloat) near
							 andFar: (GLfloat) far {
	NSAssert1(NO, @"%@ does not support perspective projection. Use the CC3ProjectionMatrix instead", self);
}

-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
						 andTop: (GLfloat) top  
					  andBottom: (GLfloat) bottom
						andNear: (GLfloat) near {
	[self implPopulateFromFrustumLeft: left andRight: right andTop: top andBottom: bottom andNear: near];
	isIdentity = NO;
	isRigid = NO;
}

-(void) implPopulateFromFrustumLeft: (GLfloat) left
						   andRight: (GLfloat) right
							 andTop: (GLfloat) top  
						  andBottom: (GLfloat) bottom
							andNear: (GLfloat) near {
	NSAssert1(NO, @"%@ does not support perspective projection. Use the CC3ProjectionMatrix instead", self);
}

-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
							  andTop: (GLfloat) top  
						   andBottom: (GLfloat) bottom
							 andNear: (GLfloat) near
							  andFar: (GLfloat) far {
	[self implPopulateOrthoFromFrustumLeft: left andRight: right andTop: top  
								 andBottom: bottom andNear: near andFar: far];
	isIdentity = NO;
	isRigid = NO;
}

-(void) implPopulateOrthoFromFrustumLeft: (GLfloat) left
								andRight: (GLfloat) right
								  andTop: (GLfloat) top  
							   andBottom: (GLfloat) bottom
								 andNear: (GLfloat) near
								  andFar: (GLfloat) far {
	NSAssert1(NO, @"%@ does not support orthographic projection. Use the CC3ProjectionMatrix instead", self);
}

-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
							  andTop: (GLfloat) top  
						   andBottom: (GLfloat) bottom
							 andNear: (GLfloat) near {
	[self implPopulateOrthoFromFrustumLeft: left andRight: right andTop: top andBottom: bottom andNear: near];
	isIdentity = NO;
	isRigid = NO;
}

-(void) implPopulateOrthoFromFrustumLeft: (GLfloat) left
								andRight: (GLfloat) right
								  andTop: (GLfloat) top  
							   andBottom: (GLfloat) bottom
								 andNear: (GLfloat) near {
	NSAssert1(NO, @"%@ does not support orthographic projection. Use the CC3ProjectionMatrix instead", self);
}


#pragma mark Accessing content

-(CC3Vector) extractRotation {
	NSAssert1(NO, @"%@ does not implement the extractRotation method", self);
	return kCC3VectorNull;
}

-(CC3Quaternion) extractQuaternion  {
	NSAssert1(NO, @"%@ does not implement the extractQuaternion method", self);
	return kCC3QuaternionNull;
}

-(CC3Vector) extractForwardDirection  {
	NSAssert1(NO, @"%@ does not implement the extractForwardDirection method", self);
	return kCC3VectorNull;
}

-(CC3Vector) extractUpDirection  {
	NSAssert1(NO, @"%@ does not implement the extractUpDirection method", self);
	return kCC3VectorNull;
}

-(CC3Vector) extractRightDirection  {
	NSAssert1(NO, @"%@ does not implement the extractRightDirection method", self);
	return kCC3VectorNull;
}


#pragma mark Matrix transformations

// Short-circuit the identity transform. isRigid unchanged under rotation.
-(void) rotateBy: (CC3Vector) aRotation {
	if ( !CC3VectorsAreEqual(aRotation, kCC3VectorZero) ) {
		[self implRotateBy: aRotation];
		isIdentity = NO;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implRotateBy: (CC3Vector) aRotation {
	NSAssert1(NO, @"%@ does not implement the implRotateBy: method", self);
}

// Short-circuit the identity transform. isRigid unchanged under rotation.
-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion {
	if ( !CC3QuaternionsAreEqual(aQuaternion, kCC3QuaternionIdentity) ) {
		[self implRotateByQuaternion: aQuaternion];
		isIdentity = NO;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implRotateByQuaternion: (CC3Quaternion) aQuaternion {
	NSAssert1(NO, @"%@ does not implement the implRotateByQuaternion: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) orthonormalizeRotationStartingWith: (NSUInteger) startColNum {
	NSAssert1(NO, @"%@ does not implement the orthonormalizeRotationStartingWith: method", self);
}

// Short-circuit the identity transform
-(void) scaleBy: (CC3Vector) aScale {
	if ( !CC3VectorsAreEqual(aScale, kCC3VectorUnitCube) ) {
		[self implScaleBy: aScale];
		isIdentity = NO;
		isRigid = NO;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implScaleBy: (CC3Vector) aScale {
	NSAssert1(NO, @"%@ does not implement the implScaleBy: method", self);
}

// Short-circuit the identity transform. isRigid unchanged under translation.
-(void) translateBy: (CC3Vector) aTranslation {
	if ( !CC3VectorsAreEqual(aTranslation, kCC3VectorZero) ) {
		[self implTranslateBy: aTranslation];
		isIdentity = NO;
	}
}

/** Template method. Subclasses will provide implementation. */
-(void) implTranslateBy: (CC3Vector) aTranslation {
	NSAssert1(NO, @"%@ does not implement the implTranslateBy: method", self);
}


#pragma mark Matrix multiplication

// Includes short-circuits when one of the matrix is an identity matrix
-(void) multiplyBy: (CC3Matrix*) aMatrix {

	// If other matrix is identity, this matrix doesn't change, so leave
	if (!aMatrix || aMatrix.isIdentity) return;
	
	// If this matrix is identity, it just becomes the other matrix
	if (isIdentity) {
		[self populateFrom: aMatrix];
		return;
	}

	// Otherwise, go through with the multiplication
	[self implMultiplyBy: aMatrix];
	isIdentity = NO;
	if ( !aMatrix.isRigid ) isRigid = NO;
}

/**
 * Template method for multiplying this matrix by the other, once it is known that neither
 * this matrix nor the other are identity matrices.
 *
 * Subclass implementations will double-dispatch to the other matrix.
 * Subclass implementation does not need to set isIdentity or isRigid.
 */
-(void) implMultiplyBy: (CC3Matrix*) aMatrix {
	NSAssert1(NO, @"%@ does not implement the implMultiplyBy: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) multiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the multiplyIntoCC3Matrix3x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) multiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the multiplyByCC3Matrix3x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) multiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the multiplyIntoCC3Matrix4x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) multiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the multiplyByCC3Matrix4x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) multiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	NSAssert1(NO, @"%@ does not implement the multiplyIntoCC3Matrix4x4: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) multiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	NSAssert1(NO, @"%@ does not implement the multiplyByCC3Matrix4x4: method", self);
}

// Includes short-circuits when one of the matrix is an identity matrix
-(void) leftMultiplyBy: (CC3Matrix*) aMatrix {
	
	// If other matrix is identity, this matrix doesn't change, so leave
	if (!aMatrix || aMatrix.isIdentity) return;
	
	// If this matrix is identity, it just becomes the other matrix
	if (isIdentity) {
		[self populateFrom: aMatrix];
		return;
	}
	
	// Otherwise, go through with the multiplication
	[self implLeftMultiplyBy: aMatrix];
	isIdentity = NO;
	if ( !aMatrix.isRigid ) isRigid = NO;
}

/**
 * Template method for multiplying this matrix by the other, once it is known that neither
 * this matrix nor the other are identity matrices.
 *
 * Subclass implementations will double-dispatch to the other matrix.
 * Subclass implementation does not need to set isIdentity or isRigid.
 */
-(void) implLeftMultiplyBy: (CC3Matrix*) aMatrix {
	NSAssert1(NO, @"%@ does not implement the implLeftMultiplyBy: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) leftMultiplyIntoCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the leftMultiplyIntoCC3Matrix3x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) leftMultiplyByCC3Matrix3x3: (CC3Matrix3x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the leftMultiplyByCC3Matrix3x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) leftMultiplyIntoCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the leftMultiplyIntoCC3Matrix4x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) leftMultiplyByCC3Matrix4x3: (CC3Matrix4x3*) mtx {
	NSAssert1(NO, @"%@ does not implement the leftMultiplyByCC3Matrix4x3: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) leftMultiplyIntoCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	NSAssert1(NO, @"%@ does not implement the leftMultiplyIntoCC3Matrix4x4: method", self);
}

/** Template method. Subclasses will provide implementation. */
-(void) leftMultiplyByCC3Matrix4x4: (CC3Matrix4x4*) mtx {
	NSAssert1(NO, @"%@ does not implement the leftMultiplyByCC3Matrix4x4: method", self);
}


#pragma mark Matrix operations

// Short-circuit if this is an identity matrix
-(CC3Vector) transformLocation: (CC3Vector) aLocation {
	if (isIdentity) return aLocation;
	NSAssert1(NO, @"%@ does not implement the transformLocation: method", self);
	return kCC3VectorNull;
}

// Short-circuit if this is an identity matrix
-(CC3Vector) transformDirection: (CC3Vector) aDirection {
	if (isIdentity) return aDirection;
	NSAssert1(NO, @"%@ does not implement the transformDirection: method", self);
	return kCC3VectorNull;
}

// Short-circuit if this is an identity matrix
-(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector {
	if (isIdentity) return aVector;
	NSAssert1(NO, @"%@ does not implement the transformHomogeneousVector: method", self);
	return kCC3Vector4Null;
}

// Short-circuit if this is an identity matrix
-(CC3Ray) transformRay: (CC3Ray) aRay {
	if (isIdentity) return aRay;
	CC3Ray rayOut;
	rayOut.startLocation = [self transformLocation: aRay.startLocation];
	rayOut.direction = [self transformDirection: aRay.direction];
	return rayOut;
}

// Short-circuit if this is an identity matrix
-(void) transpose {
	if (isIdentity) return;
	NSAssert1(NO, @"%@ does not implement the transpose method", self);
}

// Short-circuit if this is an identity or rigid matrix
-(BOOL) invert {
	if (isIdentity) return YES;
	if (isRigid) {
		[self invertRigid];
		return YES;
	}
	return [self invertAdjoint];
}

// Short-circuit if this is an identity or rigid matrix
-(BOOL) invertAdjoint {
	if (isIdentity) return YES;
	NSAssert1(NO, @"%@ does not implement the invertAdjoint method", self);
	return NO;
}

// Short-circuit if this is an identity matrix
-(void) invertRigid {
	if (isIdentity) return;
	NSAssert1(NO, @"%@ does not implement the invertRigid method", self);
}

@end



