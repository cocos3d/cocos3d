/*
 * CC3GLMatrix.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Matrix4x4.h"
#import "CC3MatrixMath.h"

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
typedef enum {
	kCC3GLMatrixOrthonormalizationStartX,	/**< Start with the X-axis basis vector. */
	kCC3GLMatrixOrthonormalizationStartY,	/**< Start with the Y-axis basis vector. */
	kCC3GLMatrixOrthonormalizationStartZ	/**< Start with the Z-axis basis vector. */
} CC3GLMatrixOrthonormalizationStart;

/**
 * Deprecated and replaced by the CC3Matrix family of classes.
 * @deprecated
 * This class has been created to stand in for the deprecated CC3GLMatrix class
 * in framework code. Do not use this class.
 */
@interface CC3GLMatrixDeprecated : NSObject <NSCopying> {
	BOOL isIdentity;
}

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
@property(nonatomic, assign) GLfloat* glMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
@property(nonatomic, readonly) BOOL isIdentity;


#pragma mark Allocation and initialization

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(id) init;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(id) matrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(id) initIdentity;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(id) identity;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(id) initFromGLMatrix: (GLfloat*) aGLMtx;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(id) matrixFromGLMatrix: (GLfloat*) aGLMtx;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(id) matrixByMultiplying: (CC3GLMatrixDeprecated*) m1 by: (CC3GLMatrixDeprecated*) m2;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(id) initOnGLMatrix: (GLfloat*) aGLMtx;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(id) matrixOnGLMatrix: (GLfloat*) aGLMtx;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(id) initWithElements: (GLfloat) e00, ...;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(id) matrixWithElements: (GLfloat) e00, ...;


#pragma mark -
#pragma mark Instance population

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFrom: (CC3GLMatrixDeprecated*) aMtx;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFromGLMatrix: (GLfloat*) aGLMtx;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateZero;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateIdentity;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFromTranslation: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFromRotation: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFromQuaternion: (CC3Quaternion) aQuaternion;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFromScale: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateToLookAt: (CC3Vector) targetLocation
			   withEyeAt: (CC3Vector) eyeLocation
				  withUp: (CC3Vector) upDirection;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
					  andBottom: (GLfloat) bottom
						 andTop: (GLfloat) top  
						andNear: (GLfloat) near
						 andFar: (GLfloat) far;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
					  andBottom: (GLfloat) bottom
						 andTop: (GLfloat) top  
						andNear: (GLfloat) near;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
						   andBottom: (GLfloat) bottom
							  andTop: (GLfloat) top  
							 andNear: (GLfloat) near
							  andFar: (GLfloat) far;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
						   andBottom: (GLfloat) bottom
							  andTop: (GLfloat) top  
							 andNear: (GLfloat) near;


#pragma mark Matrix population

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) copyMatrix: (const GLfloat*) srcGLMatrix into: (GLfloat*) destGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populateZero: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populateIdentity: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix fromTranslation: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix fromRotation: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix fromQuaternion: (CC3Quaternion) aQuaternion;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix fromScale: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix toPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix
		toLookAt: (CC3Vector) targetLocation
	   withEyeAt: (CC3Vector) eyeLocation
		  withUp: (CC3Vector) upDirection;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix 
 fromFrustumLeft: (GLfloat) left
		andRight: (GLfloat) right
	   andBottom: (GLfloat) bottom
		  andTop: (GLfloat) top  
		 andNear: (GLfloat) near
		  andFar: (GLfloat) far;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populate: (GLfloat*) aGLMatrix 
 fromFrustumLeft: (GLfloat) left
		andRight: (GLfloat) right
	   andBottom: (GLfloat) bottom
		  andTop: (GLfloat) top  
		 andNear: (GLfloat) near;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populateOrtho: (GLfloat*) aGLMatrix 
	  fromFrustumLeft: (GLfloat) left
			 andRight: (GLfloat) right
			andBottom: (GLfloat) bottom
			   andTop: (GLfloat) top  
			  andNear: (GLfloat) near
			   andFar: (GLfloat) far;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) populateOrtho: (GLfloat*) aGLMatrix 
	  fromFrustumLeft: (GLfloat) left
			 andRight: (GLfloat) right
			andBottom: (GLfloat) bottom
			   andTop: (GLfloat) top  
			  andNear: (GLfloat) near;


#pragma mark -
#pragma mark Instance accessing

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Vector) extractRotation;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Quaternion) extractQuaternion;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Vector) extractForwardDirection;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Vector) extractUpDirection;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Vector) extractRightDirection;


#pragma mark Matrix accessing

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) extractRotationFromMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) extractRotationYXZFromMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) extractRotationZYXFromMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Quaternion) extractQuaternionFromMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) extractForwardDirectionFrom: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) extractUpDirectionFrom: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) extractRightDirectionFrom: (GLfloat*) aGLMatrix;


#pragma mark -
#pragma mark Instance transformations

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) translateBy: (CC3Vector) translationVector
		   rotateBy: (CC3Vector) rotationVector
			scaleBy: (CC3Vector) scaleVector;
	
/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) rotateBy: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) rotateByX: (GLfloat) degrees;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) rotateByY: (GLfloat) degrees;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) rotateByZ: (GLfloat) degrees;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) orthonormalizeRotationStartingWith: (CC3GLMatrixOrthonormalizationStart) startVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) translateBy: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) translateByX: (GLfloat) distance;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) translateByY: (GLfloat) distance;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) translateByZ: (GLfloat) distance;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) scaleBy: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) scaleByX: (GLfloat) scaleFactor;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) scaleByY: (GLfloat) scaleFactor;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) scaleByZ: (GLfloat) scaleFactor;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) scaleUniformlyBy: (GLfloat) scaleFactor;


#pragma mark Matrix transformations

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) transform: (GLfloat*) aGLMatrix
	  translateBy: (CC3Vector) aTranslation
		 rotateBy: (CC3Vector) aRotation
		  scaleBy: (CC3Vector) aScale;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) rotateYXZ: (GLfloat*) aGLMatrix by: (CC3Vector) aRotation;
	
/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) rotateZYX: (GLfloat*) aGLMatrix by: (CC3Vector) aRotation;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) rotate: (GLfloat*) aGLMatrix byX: (GLfloat) degrees;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) rotate: (GLfloat*) aGLMatrix byY: (GLfloat) degrees;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) rotate: (GLfloat*) aGLMatrix byZ: (GLfloat) degrees;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) rotate: (GLfloat*) aGLMatrix byQuaternion: (CC3Quaternion) aQuaternion;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) orthonormalizeRotationOf: (GLfloat*) aGLMatrix
					startingWith: (CC3GLMatrixOrthonormalizationStart) startVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) translate: (GLfloat*) aGLMatrix by: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) translate: (GLfloat*) aGLMatrix byX: (GLfloat) distance;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) translate: (GLfloat*) aGLMatrix byY: (GLfloat) distance;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) translate: (GLfloat*) aGLMatrix byZ: (GLfloat) distance;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) scale: (GLfloat*) aGLMatrix by: (CC3Vector) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) scale: (GLfloat*) aGLMatrix byX: (GLfloat) scaleFactor;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) scale: (GLfloat*) aGLMatrix byY: (GLfloat) scaleFactor;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) scale: (GLfloat*) aGLMatrix byZ: (GLfloat) scaleFactor;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) scale: (GLfloat*) aGLMatrix uniformlyBy: (GLfloat) scaleFactor;


#pragma mark -
#pragma mark Instance math operations

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) multiplyByMatrix: (CC3GLMatrixDeprecated*) aMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) leftMultiplyByMatrix: (CC3GLMatrixDeprecated*) aMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Vector) transformLocation: (CC3Vector) aLocation;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Vector) transformDirection: (CC3Vector) aDirection;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(CC3Ray) transformRay: (CC3Ray) aRay;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) transpose;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(BOOL) invert;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(BOOL) invertAffine;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
-(void) invertRigid;
	

#pragma mark Matrix math operations

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) multiply: (GLfloat*) aGLMatrix byMatrix: (GLfloat*) anotherGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) leftMultiply: (GLfloat*) aGLMatrix byMatrix: (GLfloat*) anotherGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) transformLocation: (CC3Vector) aLocation withMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector) transformDirection: (CC3Vector) aDirection withMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector withMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(CC3Ray) transformRay: (CC3Ray) aRay withMatrix: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) transpose: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(BOOL) invert: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(BOOL) invertAffine: (GLfloat*) aGLMatrix;

/** @deprecated CC3GLMatrix has been replaced by the CC3Matrix family of classes. */
+(void) invertRigid: (GLfloat*) aGLMatrix;

@end


#pragma mark Deprecated CC3GLMatrix

DEPRECATED_ATTRIBUTE
/**
 * Deprecated and replaced by the CC3Matrix family of classes.
 * @deprecated Replaced by the CC3Matrix family of classes. Full functionality provided by CC3ProjectionMatrix.
 */
@interface CC3GLMatrix : CC3GLMatrixDeprecated
@end

