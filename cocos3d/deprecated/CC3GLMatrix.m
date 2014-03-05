/*
 * CC3GLMatrix.m
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
 * See header file CC3GLMatrix.h for full API documentation.
 */

#import "CC3GLMatrix.h"


#pragma mark CC3Matrix private template method declaration

@interface CC3GLMatrixDeprecated (TemplateMethods)
-(id) initParent;
-(id) initWithFirstElement: (GLfloat) e00 remainingElements: (va_list) args;
@end


#pragma mark -
#pragma mark CC3ArrayMatrix class cluster implementation class

@interface CC3GLArrayMatrix : CC3GLMatrixDeprecated {
	GLfloat glArray[16];
}

@end

@implementation CC3GLArrayMatrix

-(GLfloat*) glMatrix { return glArray; }

-(id) init {
	if( (self = [self initParent]) ) {
		[self populateZero];
	}
	return self;
}

+(id) matrix { return [[[self alloc] init] autorelease]; }

-(id) initIdentity {
	if( (self = [self initParent]) ) {
		[self populateIdentity];
	}
	return self;
}

+(id) identity { return [[[self alloc] initIdentity] autorelease]; }

-(id) initFromGLMatrix: (GLfloat*) aGLMtx {
	if( (self = [self initParent]) ) {
		[self populateFromGLMatrix: aGLMtx];
	}
	return self;
}

+(id) matrixFromGLMatrix: (GLfloat*) aGLMtx {
	return [[[self alloc] initFromGLMatrix: aGLMtx] autorelease];
}

-(id) initWithFirstElement: (GLfloat) e00 remainingElements: (va_list) args {
	if( (self = [self initParent]) ) {
		GLfloat* p = self.glMatrix;
		*p++ = e00;
		for (int i = 1; i < 16; i++) {
			*p++ = (GLfloat)va_arg(args, double);
		}
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3GLPointerMatrix class cluster implementation class

@interface CC3GLPointerMatrix : CC3GLMatrixDeprecated {
	GLfloat* glMatrix;
}

@end

@implementation CC3GLPointerMatrix

-(GLfloat*) glMatrix {
	return glMatrix;
}

-(void) setGlMatrix: (GLfloat*) aGLMtx {
	glMatrix = aGLMtx;
}

-(id) initOnGLMatrix: (GLfloat*) aGLMtx {
	if ( (self = [self initParent]) ) {
		glMatrix = aGLMtx;
	}
	return self;
}

+(id) matrixOnGLMatrix: (GLfloat*) aGLMtx {
	return [[[self alloc] initOnGLMatrix: aGLMtx] autorelease];
}

@end


#pragma mark -
#pragma mark CC3Matrix implementation

@implementation CC3GLMatrixDeprecated

@synthesize isIdentity;

/**
 * Abstract class simply returns NULL.
 * Subclasses will provide concrete access to the appropriate structure.
 */
-(GLfloat*) glMatrix { return NULL; }

// Setting this property is ignored. Subclasses that permit this may override.
-(void) setGlMatrix: (GLfloat*) aGLMtx {}


#pragma mark Allocation and initialization

-(id) initParent {
	return [super init];
}

// Instantiate the appropriate concrete cluster class.
-(id) init {
	[self release];
	return [[CC3GLArrayMatrix alloc] init];
}

// Instantiate the appropriate concrete cluster class.
+(id) matrix { return [CC3GLArrayMatrix matrix]; }

// Instantiate the appropriate concrete cluster class.
-(id) initIdentity {
	[self release];
	return [[CC3GLArrayMatrix alloc] initIdentity];
}

// Instantiate the appropriate concrete cluster class.
+(id) identity { return [CC3GLArrayMatrix identity]; }

// Instantiate the appropriate concrete cluster class.
-(id) initFromGLMatrix: (GLfloat*) aGLMtx {
	[self release];
	return [[CC3GLArrayMatrix alloc] initFromGLMatrix: aGLMtx];
}

// Instantiate the appropriate concrete cluster class.
+(id) matrixFromGLMatrix: (GLfloat*) aGLMtx {
	return [CC3GLArrayMatrix matrixFromGLMatrix: aGLMtx];
}

+(id) matrixByMultiplying: (CC3GLMatrixDeprecated*) m1 by: (CC3GLMatrixDeprecated*) m2 {
	CC3GLMatrixDeprecated* m = [self matrixFromGLMatrix: m1.glMatrix];
	[m multiplyByMatrix: m2];
	return m;
}

// Instantiate the appropriate concrete cluster class.
-(id) initWithFirstElement: (GLfloat) e00 remainingElements: (va_list) args {
	[self release];
	return [[CC3GLArrayMatrix alloc] initWithFirstElement: e00 remainingElements: args];
}

// Instantiate the appropriate concrete cluster class.
-(id) initWithElements: (GLfloat) e00, ... {
	va_list args;
	va_start(args, e00);
	self = [self initWithFirstElement: e00 remainingElements: args];
	va_end(args);
	return self;
}

// Instantiate the appropriate concrete cluster class.
+(id) matrixWithElements: (GLfloat) e00, ... {
	va_list args;
	va_start(args, e00);
	CC3GLMatrixDeprecated* mtx = [[CC3GLArrayMatrix alloc] initWithFirstElement: e00 remainingElements: args];
	va_end(args);
	return [mtx autorelease];
}

// Instantiate the appropriate concrete cluster class.
-(id) initOnGLMatrix: (GLfloat*) aGLMtx {
	[self release];
	return [[CC3GLPointerMatrix alloc] initOnGLMatrix: aGLMtx];
}

// Instantiate the appropriate concrete cluster class.
+(id) matrixOnGLMatrix: (GLfloat*) aGLMtx {
	return [CC3GLPointerMatrix matrixOnGLMatrix: aGLMtx];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[CC3GLArrayMatrix alloc] initFromGLMatrix: self.glMatrix];
}

-(NSString*) description {
	GLfloat* m = self.glMatrix;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"\n\t[%.12f, ", m[0]];
	[desc appendFormat: @"%.12f, ", m[4]];
	[desc appendFormat: @"%.12f, ", m[8]];
	[desc appendFormat: @"%.12f,\n\t ", m[12]];
	[desc appendFormat: @"%.12f, ", m[1]];
	[desc appendFormat: @"%.12f, ", m[5]];
	[desc appendFormat: @"%.12f, ", m[9]];
	[desc appendFormat: @"%.12f,\n\t ", m[13]];
	[desc appendFormat: @"%.12f, ", m[2]];
	[desc appendFormat: @"%.12f, ", m[6]];
	[desc appendFormat: @"%.12f, ", m[10]];
	[desc appendFormat: @"%.12f,\n\t ", m[14]];
	[desc appendFormat: @"%.12f, ", m[3]];
	[desc appendFormat: @"%.12f, ", m[7]];
	[desc appendFormat: @"%.12f, ", m[11]];
	[desc appendFormat: @"%.12f]", m[15]];
	return desc;
}


#pragma mark -
#pragma mark Instance population

-(void) populateFrom: (CC3GLMatrixDeprecated*) aMtx { 
	if (!aMtx || aMtx.isIdentity) {
		[self populateIdentity];
	} else {
		[self populateFromGLMatrix: aMtx.glMatrix];
	}
}

-(void) populateFromGLMatrix: (GLfloat*) aGLMtx {
	[[self class] copyMatrix: aGLMtx into: self.glMatrix];
	isIdentity = NO;
}

-(void) populateZero {
	[[self class] populateZero: self.glMatrix];
	isIdentity = NO;
}

-(void) populateIdentity {
	if (!isIdentity) {
		[[self class] populateIdentity: self.glMatrix];
		isIdentity = YES;
	}
}

-(void) populateFromTranslation: (CC3Vector) aVector {
/*
     | 1  0  0  x |
 M = | 0  1  0  y |
     | 0  0  1  z |
     | 0  0  0  1 |
*/
	if ( !CC3VectorsAreEqual(aVector, kCC3VectorZero) ) {
		[[self class] populate: self.glMatrix fromTranslation: aVector];
		isIdentity = NO;
	} else {
		[self populateIdentity];
	}
}

-(void) populateFromRotation: (CC3Vector) aRotation {
	if ( !CC3VectorsAreEqual(aRotation, kCC3VectorZero) ) {
		CC3KMMat4RotationYXZ(self.glMatrix, aRotation);
		isIdentity = NO;
	} else {
		[self populateIdentity];
	}
}

-(void) populateFromQuaternion: (CC3Quaternion) aQuaternion {
	if ( !CC3QuaternionsAreEqual(aQuaternion, kCC3QuaternionIdentity) ) {
		CC3KMMat4RotationQuaternion(self.glMatrix, aQuaternion);
		isIdentity = NO;
	} else {
		[self populateIdentity];
	}
}

-(void) populateFromScale: (CC3Vector) aVector {
	if ( !CC3VectorsAreEqual(aVector, kCC3VectorUnitCube) ) {
		[[self class] populate: self.glMatrix fromScale: aVector];
		isIdentity = NO;
	} else {
		[self populateIdentity];
	}
}

-(void) populateToPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection {
	[[self class] populate: self.glMatrix toPointTowards: fwdDirection withUp: upDirection];
	isIdentity = NO;
}

-(void) populateToLookAt: (CC3Vector) targetLocation
			   withEyeAt: (CC3Vector) eyeLocation
				  withUp: (CC3Vector) upDirection {

	[[self class] populate: self.glMatrix
				  toLookAt: targetLocation
				 withEyeAt: eyeLocation
					withUp: upDirection];
	isIdentity = NO;
}

-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
					  andBottom: (GLfloat) bottom
						 andTop: (GLfloat) top  
						andNear: (GLfloat) near
						 andFar: (GLfloat) far {
	[[self class] populate: self.glMatrix
		   fromFrustumLeft: left andRight: right
				 andBottom: bottom andTop: top  
				   andNear: near andFar: far];
	isIdentity = NO;
}

-(void) populateFromFrustumLeft: (GLfloat) left
					   andRight: (GLfloat) right
					  andBottom: (GLfloat) bottom
						 andTop: (GLfloat) top  
						andNear: (GLfloat) near {
	[[self class] populate: self.glMatrix
		   fromFrustumLeft: left andRight: right
				 andBottom: bottom andTop: top  
				   andNear: near];
	isIdentity = NO;
}

-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
						   andBottom: (GLfloat) bottom
							  andTop: (GLfloat) top  
							 andNear: (GLfloat) near
							  andFar: (GLfloat) far {
	[[self class] populateOrtho: self.glMatrix
				fromFrustumLeft: left andRight: right
					  andBottom: bottom andTop: top  
						andNear: near andFar: far];
	isIdentity = NO;
}

-(void) populateOrthoFromFrustumLeft: (GLfloat) left
							andRight: (GLfloat) right
						   andBottom: (GLfloat) bottom
							  andTop: (GLfloat) top  
							 andNear: (GLfloat) near {
	[[self class] populateOrtho: self.glMatrix
				fromFrustumLeft: left andRight: right
					  andBottom: bottom andTop: top  
						andNear: near];
	isIdentity = NO;
}


#pragma mark Matrix population

static const GLfloat identityContents[] = { 1.0f, 0.0f, 0.0f, 0.0f,
	0.0f, 1.0f, 0.0f, 0.0f,
	0.0f, 0.0f, 1.0f, 0.0f,
	0.0f, 0.0f, 0.0f, 1.0f };

+(void) copyMatrix: (const GLfloat*) srcGLMatrix into: (GLfloat*) destGLMatrix {
	memcpy(destGLMatrix, srcGLMatrix, 16 * sizeof(GLfloat));
}

+(void) populateZero: (GLfloat*) aGLMatrix { memset(aGLMatrix, 0, 16 * sizeof(GLfloat)); }

+(void) populateIdentity: (GLfloat*) aGLMatrix { [self copyMatrix: identityContents into: aGLMatrix]; }

+(void) populate: (GLfloat*) aGLMatrix fromTranslation: (CC3Vector) aVector {
/*
     | 1  0  0  x |
 M = | 0  1  0  y |
     | 0  0  1  z |
     | 0  0  0  1 |
*/
	// Start with identity, then insert the translation components.
	GLfloat* m = aGLMatrix;
	[self populateIdentity: m];
	m[12] = aVector.x;
	m[13] = aVector.y;
	m[14] = aVector.z;
}

+(void) populate: (GLfloat*) aGLMatrix fromRotation: (CC3Vector) aRotation {
	if ( !CC3VectorsAreEqual(aRotation, kCC3VectorZero) ) {
		CC3KMMat4RotationYXZ(aGLMatrix, aRotation);
	} else {
		[self populateIdentity: aGLMatrix];
	}
}

+(void) populate: (GLfloat*) aGLMatrix fromQuaternion: (CC3Quaternion) aQuaternion {
	if ( !CC3QuaternionsAreEqual(aQuaternion, kCC3QuaternionIdentity) ) {
		CC3KMMat4RotationQuaternion(aGLMatrix, aQuaternion);
	} else {
		[self populateIdentity: aGLMatrix];
	}
}

+(void) populate: (GLfloat*) aGLMatrix fromScale: (CC3Vector) aVector {
/*
     |  x  0  0  0 |
 M = |  0  y  0  0 |
     |  0  0  z  0 |
     |  0  0  0  1 |
*/
	// Start with identity, then insert the scale components.
	GLfloat* m = aGLMatrix;
	[self populateIdentity: m];
	m[0] = aVector.x;
	m[5] = aVector.y;
	m[10] = aVector.z;
}

+(void) populate: (GLfloat*) aGLMatrix toPointTowards: (CC3Vector) fwdDirection withUp: (CC3Vector) upDirection {
/*
     |  rx  ux  -fx  0 |
 M = |  ry  uy  -fy  0 |
     |  rz  uz  -fz  0 |
     |  0   0    0   1 |
	 
	 where f is the normalized Forward vector (the direction being pointed to)
	 and u is the normalized Up vector in the rotated frame
	 and r is the normalized Right vector in the rotated frame
 */
	CC3Vector f, u, r;
	
	f = CC3VectorNormalize(fwdDirection);
	r = CC3VectorNormalize(CC3VectorCross(f, upDirection));
	u = CC3VectorCross(r, f);			// already normalized since f & r are orthonormal
	
	aGLMatrix[0]  = r.x;
	aGLMatrix[1]  = r.y;
	aGLMatrix[2]  = r.z;
	aGLMatrix[3] = 0.0;
	
	aGLMatrix[4]  = u.x;
	aGLMatrix[5]  = u.y;
	aGLMatrix[6]  = u.z;
	aGLMatrix[7] = 0.0;
	
	aGLMatrix[8]  = -f.x;
	aGLMatrix[9]  = -f.y;
	aGLMatrix[10] = -f.z;
	aGLMatrix[11] = 0.0;
	
	aGLMatrix[12]  = 0.0;
	aGLMatrix[13]  = 0.0;
	aGLMatrix[14] = 0.0;
	aGLMatrix[15] = 1.0;
}

+(void) populate: (GLfloat*) aGLMatrix
		toLookAt: (CC3Vector) targetLocation
	   withEyeAt: (CC3Vector) eyeLocation
		  withUp: (CC3Vector) upDirection {
	
	CC3Vector fwdDir = CC3VectorDifference(targetLocation, eyeLocation);
	[self populate: aGLMatrix toPointTowards: fwdDir withUp: upDirection];
	[self transpose: aGLMatrix];		
	[self translate: aGLMatrix by: CC3VectorNegate(eyeLocation)];
}

+(void) populate: (GLfloat*) aGLMatrix
 fromFrustumLeft: (GLfloat) left
		andRight: (GLfloat) right
	   andBottom: (GLfloat) bottom
		  andTop: (GLfloat) top  
		 andNear: (GLfloat) near
		  andFar: (GLfloat) far {
	
	GLfloat twoNear = 2.0f * near;
	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	GLfloat ooDepth = 1.0f / (far - near);
	
	aGLMatrix[0]  = twoNear * ooWidth;
	aGLMatrix[1]  = 0.0f;
	aGLMatrix[2]  = 0.0f;
	aGLMatrix[3] = 0.0f;
	
	aGLMatrix[4]  = 0.0f;
	aGLMatrix[5]  = twoNear * ooHeight;
	aGLMatrix[6]  = 0.0f;
	aGLMatrix[7] = 0.0f;
	
	aGLMatrix[8]  = (right + left) * ooWidth;
	aGLMatrix[9]  = (top + bottom) * ooHeight;
	aGLMatrix[10] = -(far + near) * ooDepth;
	aGLMatrix[11] = -1.0f;
	
	aGLMatrix[12]  = 0.0f;
	aGLMatrix[13]  = 0.0f;
	aGLMatrix[14] = -(twoNear * far) * ooDepth;
	aGLMatrix[15] = 0.0f;
}

+(void) populate: (GLfloat*) aGLMatrix
 fromFrustumLeft: (GLfloat) left
		andRight: (GLfloat) right
	   andBottom: (GLfloat) bottom
		  andTop: (GLfloat) top  
		 andNear: (GLfloat) near {
	
	GLfloat twoNear = 2.0f * near;
	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	
	GLfloat epsilon = 0.0f;
		
	aGLMatrix[0]  = twoNear * ooWidth;
	aGLMatrix[1]  = 0.0f;
	aGLMatrix[2]  = 0.0f;
	aGLMatrix[3] = 0.0f;
	
	aGLMatrix[4]  = 0.0f;
	aGLMatrix[5]  = twoNear * ooHeight;
	aGLMatrix[6]  = 0.0f;
	aGLMatrix[7] = 0.0f;
	
	aGLMatrix[8]  = (right + left) * ooWidth;
	aGLMatrix[9]  = (top + bottom) * ooHeight;
	aGLMatrix[10] = epsilon - 1.0f;
	aGLMatrix[11] = -1.0f;
	
	aGLMatrix[12]  = 0.0f;
	aGLMatrix[13]  = 0.0f;
	aGLMatrix[14] = near * (epsilon - 2);
	aGLMatrix[15] = 0.0f;
}

+(void) populateOrtho: (GLfloat*) aGLMatrix
	  fromFrustumLeft: (GLfloat) left
			 andRight: (GLfloat) right
			andBottom: (GLfloat) bottom
			   andTop: (GLfloat) top  
			  andNear: (GLfloat) near
			   andFar: (GLfloat) far {

	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	GLfloat ooDepth = 1.0f / (far - near);
	
	aGLMatrix[0]  = 2.0f * ooWidth;
	aGLMatrix[1]  = 0.0f;
	aGLMatrix[2]  = 0.0f;
	aGLMatrix[3] = 0.0f;
	
	aGLMatrix[4]  = 0.0f;
	aGLMatrix[5]  = 2.0f * ooHeight;
	aGLMatrix[6]  = 0.0f;
	aGLMatrix[7] = 0.0f;

	aGLMatrix[8]  = 0.0f;
	aGLMatrix[9]  = 0.0f;
	aGLMatrix[10]  = -2.0f * ooDepth;
	aGLMatrix[11] = 0.0f;

	aGLMatrix[12]  = -(right + left) * ooWidth;
	aGLMatrix[13]  = -(top + bottom) * ooHeight;
	aGLMatrix[14] = -(far + near) * ooDepth;
	aGLMatrix[15] = 1.0f;
}

+(void) populateOrtho: (GLfloat*) aGLMatrix
	  fromFrustumLeft: (GLfloat) left
			 andRight: (GLfloat) right
			andBottom: (GLfloat) bottom
			   andTop: (GLfloat) top  
			  andNear: (GLfloat) near {
	
	GLfloat ooWidth = 1.0f / (right - left);
	GLfloat ooHeight = 1.0f / (top - bottom);
	
	aGLMatrix[0]  = 2.0f * ooWidth;
	aGLMatrix[1]  = 0.0f;
	aGLMatrix[2]  = 0.0f;
	aGLMatrix[3] = 0.0f;
	
	aGLMatrix[4]  = 0.0f;
	aGLMatrix[5]  = 2.0f * ooHeight;
	aGLMatrix[6]  = 0.0f;
	aGLMatrix[7] = 0.0f;
	
	aGLMatrix[8]  = 0.0f;
	aGLMatrix[9]  = 0.0f;
	aGLMatrix[10]  = 0.0f;
	aGLMatrix[11] = 0.0f;
	
	aGLMatrix[12]  = -(right + left) * ooWidth;
	aGLMatrix[13]  = -(top + bottom) * ooHeight;
	aGLMatrix[14] = -1.0f;
	aGLMatrix[15] = 1.0f;
}


#pragma mark -
#pragma mark Instance accessing

-(CC3Vector) extractRotation {
	return [[self class] extractRotationYXZFromMatrix: self.glMatrix];
}

-(CC3Quaternion) extractQuaternion {
	return [[self class] extractQuaternionFromMatrix: self.glMatrix];
}

-(CC3Vector) extractForwardDirection {
	return [[self class] extractForwardDirectionFrom: self.glMatrix];
}

-(CC3Vector) extractUpDirection {
	return [[self class] extractUpDirectionFrom: self.glMatrix];
}

-(CC3Vector) extractRightDirection {
	return [[self class] extractRightDirectionFrom: self.glMatrix];
}


#pragma mark Matrix accessing

+(CC3Vector) extractRotationFromMatrix: (GLfloat*) aGLMatrix {
	return [self extractRotationYXZFromMatrix: aGLMatrix];
}

// Assumes YXZ euler order, which is the OpenGL ES default
+(CC3Vector) extractRotationYXZFromMatrix: (GLfloat*) aGLMatrix {
/*
     |  cycz + sxsysz   czsxsy - cysz   cxsy  0 |
 M = |  cxsz            cxcz           -sx    0 |
     |  cysxsz - czsy   cyczsx + sysz   cxcy  0 |
     |  0               0               0     1 |
 
     where cA = cos(A), sA = sin(A) for A = x,y,z
 */
	GLfloat radX, radY, radZ;
	GLfloat cxsz = aGLMatrix[1];
	GLfloat cxcz = aGLMatrix[5];
	GLfloat cxsy = aGLMatrix[8];
	GLfloat sx = -aGLMatrix[9];
	GLfloat cxcy = aGLMatrix[10];
	if (sx < +1.0) {
		if (sx > -1.0) {
			radX = asinf(sx);
			radY = atan2f(cxsy, cxcy);
			radZ = atan2f(cxsz, cxcz);
		}
		else {		// sx = -1 (cx = 0). Not a unique solution: radZ + radY = atan2(-m01,m00).
			radX = -M_PI_2;
			radY = atan2f(-aGLMatrix[4], aGLMatrix[0]);
			radZ = 0.0;
		}
	}
	else {			// sx = +1 (cx = 0). Not a unique solution: radZ - radY = atan2(-m01,m00).
		radX = +M_PI_2;
		radY = -atan2f(-aGLMatrix[4], aGLMatrix[0]);
		radZ = 0.0;
	}	
	return cc3v(CC3RadToDeg(radX), CC3RadToDeg(radY), CC3RadToDeg(radZ));
}

// Assumes ZYX euler order
+(CC3Vector) extractRotationZYXFromMatrix: (GLfloat*) aGLMatrix {
/*
     |  cycz  -cxsz + sxsycz   sxsz + cxsycz  0 |
 M = |  cysz   cxcz + sxsysz  -sxcz + cxsysz  0 |
     | -sy     sxcy            cxcy           0 |
     |  0      0               0              1 |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
 */
	GLfloat radX, radY, radZ;
	GLfloat cycz = aGLMatrix[0];
	GLfloat cysz = aGLMatrix[1];
	GLfloat sy = -aGLMatrix[2];
	GLfloat sxcy = aGLMatrix[6];
	GLfloat cxcy = aGLMatrix[10];
	if (sy < +1.0) {
		if (sy > -1.0) {
			radY = asinf(sy);
			radZ = atan2f(cysz, cycz);
			radX = atan2f(sxcy, cxcy);
		}
		else {		// sy = -1. Not a unique solution: radX + radZ = atan2(-m12,m11).
			radY = -M_PI_2;
			radZ = atan2f(-aGLMatrix[9], aGLMatrix[5]);
			radX = 0.0;
		}
	}
	else {			// sy = +1. Not a unique solution: radX - radZ = atan2(-m12,m11).
		radY = +M_PI_2;
		radZ = -atan2f(-aGLMatrix[9], aGLMatrix[5]);
		radX = 0.0;
	}	
	return cc3v(CC3RadToDeg(radX), CC3RadToDeg(radY), CC3RadToDeg(radZ));
}

/**
 * Extracts a quaternion from a rotation matrix, stores the result in quat and returns the result.
 *
 * This algorithm uses the technique of finding the largest combination of the diagonal elements
 * to select which quaternion element (w,x,y,z) to solve for from the diagonal, and then using
 * that value along with pairs of diagonally-opposite matrix elements to derive the other three
 * quaternion elements. For example, if we want to solve for the quaternion w value first:
 *   - sum of diagonal elements = m[0] + m[5] + m[10] = (4w^2 - 1).
 *   - Therefore w = sqrt(m[0] + m[5] + m[10] + 1) / 2.
 *   - And m[9] - m[6] = 4wx, therefore x = (m[9] - m[6]) / 4w
 *   - And m[2] - m[8] = 4wy, therefore y = (m[2] - m[8]) / 4w
 *   - And m[4] - m[1] = 4wz, therefore z = (m[4] - m[1]) / 4w
 *
 * Similar equations exist for the other combinations of the diagonal elements.
 * Selecting the largest combination helps numerical stability and avoids
 * divide-by-zeros and square roots of negative numbers.
 */
+(CC3Quaternion) extractQuaternionFromMatrix: (GLfloat*) aGLMatrix {
	enum {W,X,Y,Z} bigType;
	CC3Quaternion quat;
	GLfloat* m = aGLMatrix;		// Make a simple alias

	// From the matrix diagonal element, calc (4q^2 - 1),
	// where q is each of the quaternion components: w, x, y & z.
	GLfloat fourWSqM1 =  m[0] + m[5] + m[10];
	GLfloat fourXSqM1 =  m[0] - m[5] - m[10];
	GLfloat fourYSqM1 = -m[0] + m[5] - m[10];
	GLfloat fourZSqM1 = -m[0] - m[5] + m[10];
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
			quat.x = (m[9] - m[6]) * oo4BigVal;
			quat.y = (m[2] - m[8]) * oo4BigVal;
			quat.z = (m[4] - m[1]) * oo4BigVal;
			break;
		case X:
			quat.w = (m[9] - m[6]) * oo4BigVal;
			quat.x = bigVal;
			quat.y = (m[4] + m[1]) * oo4BigVal;
			quat.z = (m[2] + m[8]) * oo4BigVal;
			break;
		case Y:
			quat.w = (m[2] - m[8]) * oo4BigVal;
			quat.x = (m[4] + m[1]) * oo4BigVal;
			quat.y = bigVal;
			quat.z = (m[9] + m[6]) * oo4BigVal;
			break;
		case Z:
			quat.w = (m[4] - m[1]) * oo4BigVal;
			quat.x = (m[2] + m[8]) * oo4BigVal;
			quat.y = (m[9] + m[6]) * oo4BigVal;
			quat.z = bigVal;
			break;
	}
	return quat;
}

+(CC3Vector) extractForwardDirectionFrom: (GLfloat*) aGLMatrix {
	return CC3VectorNegate(*(CC3Vector*)&aGLMatrix[8]);
}

+(CC3Vector) extractUpDirectionFrom: (GLfloat*) aGLMatrix {
	return *(CC3Vector*)&aGLMatrix[4];
}

+(CC3Vector) extractRightDirectionFrom: (GLfloat*) aGLMatrix {
	return *(CC3Vector*)&aGLMatrix[0];
}


#pragma mark -
#pragma mark Instance transformations

-(void) translateBy: (CC3Vector) translationVector
		   rotateBy: (CC3Vector) rotationVector
			scaleBy: (CC3Vector) scaleVector {
	// if not ALL identity transforms, transform this matrix
	if ( !(CC3VectorsAreEqual(translationVector, kCC3VectorZero) &&
		   CC3VectorsAreEqual(rotationVector, kCC3VectorZero) &&
		   CC3VectorsAreEqual(scaleVector, kCC3VectorUnitCube)) ) {
		[[self class] transform: self.glMatrix
					translateBy: translationVector
					   rotateBy: rotationVector
						scaleBy: scaleVector];
		isIdentity = NO;
	}
}

-(void) translateBy: (CC3Vector) aVector {
	// Short-circuit an identity transform
	if ( !CC3VectorsAreEqual(aVector, kCC3VectorZero) ) {
		[[self class] translate: self.glMatrix by: aVector];
		isIdentity = NO;
	}
}

-(void) translateByX: (GLfloat) distance {
	// Short-circuit an identity transform
	if ( distance != 0.0f ) {
		[[self class] translate: self.glMatrix byX: distance];
		isIdentity = NO;
	}
}

-(void) translateByY: (GLfloat) distance {
	// Short-circuit an identity transform
	if ( distance != 0.0f ) {
		[[self class] translate: self.glMatrix byY: distance];
		isIdentity = NO;
	}
}

-(void) translateByZ: (GLfloat) distance {
	// Short-circuit an identity transform
	if ( distance != 0.0f ) {
		[[self class] translate: self.glMatrix byZ: distance];
		isIdentity = NO;
	}
}

-(void) rotateBy: (CC3Vector) aVector {
	// Short-circuit an identity transform
	if ( !CC3VectorsAreEqual(aVector, kCC3VectorZero) ) {
		[[self class] rotateYXZ: self.glMatrix by: aVector];
		isIdentity = NO;
	}
}

-(void) rotateByX: (GLfloat) degrees {
	// Short-circuit an identity transform
	if ( degrees != 0.0f ) {
		[[self class] rotate: self.glMatrix byX: degrees];
		isIdentity = NO;
	}
}

-(void) rotateByY: (GLfloat) degrees {
	// Short-circuit an identity transform
	if ( degrees != 0.0f ) {
		[[self class] rotate: self.glMatrix byY: degrees];
		isIdentity = NO;
	}
}

-(void) rotateByZ: (GLfloat) degrees {
	// Short-circuit an identity transform
	if ( degrees != 0.0f ) {
		[[self class] rotate: self.glMatrix byZ: degrees];
		isIdentity = NO;
	}
}

-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion {
	// Short-circuit an identity transform
	if ( !CC3QuaternionsAreEqual(aQuaternion, kCC3QuaternionIdentity) ) {
		[[self class] rotate: self.glMatrix byQuaternion: aQuaternion];
		isIdentity = NO;
	}
}

-(void) orthonormalizeRotationStartingWith: (CC3GLMatrixOrthonormalizationStart) startVector {
	if (isIdentity) return;		// Already orthonormal.
	[[self class] orthonormalizeRotationOf: self.glMatrix startingWith: startVector];
}

-(void) scaleBy: (CC3Vector) aVector {
	// Short-circuit an identity transform
	if ( !CC3VectorsAreEqual(aVector, kCC3VectorUnitCube) ) {
		[[self class] scale: self.glMatrix by: aVector];
		isIdentity = NO;
	}
}

-(void) scaleByX: (GLfloat) scaleFactor {
	// Short-circuit an identity transform
	if ( scaleFactor != 1.0f ) {
		[[self class] scale: self.glMatrix byX: scaleFactor];
		isIdentity = NO;
	}
}

-(void) scaleByY: (GLfloat) scaleFactor {
	// Short-circuit an identity transform
	if ( scaleFactor != 1.0f ) {
		[[self class] scale: self.glMatrix byY: scaleFactor];
		isIdentity = NO;
	}
}

-(void) scaleByZ: (GLfloat) scaleFactor {
	// Short-circuit an identity transform
	if ( scaleFactor != 1.0f ) {
		[[self class] scale: self.glMatrix byZ: scaleFactor];
		isIdentity = NO;
	}
}

-(void) scaleUniformlyBy: (GLfloat) scaleFactor {
	// Short-circuit an identity transform
	if ( scaleFactor != 1.0f ) {
		[[self class] scale: self.glMatrix uniformlyBy: scaleFactor];
		isIdentity = NO;
	}
}

#pragma mark Matrix transformations

+(void) transform: (GLfloat*) aGLMatrix
	  translateBy: (CC3Vector) aTranslation
		 rotateBy: (CC3Vector) aRotation
		  scaleBy: (CC3Vector) aScale {

	GLfloat tmpMtx[16];
	CC3KMMat4Transformation(tmpMtx, aTranslation, aRotation, aScale);
	[self multiply: aGLMatrix byMatrix: tmpMtx];
}

+(void) rotateYXZ: (GLfloat*) aGLMatrix by: (CC3Vector) aRotation {
	GLfloat tmpMtx[16];
	CC3KMMat4RotationYXZ(tmpMtx, aRotation);
	[self leftMultiply: aGLMatrix byMatrix: tmpMtx];
}

+(void) rotateZYX: (GLfloat*) aGLMatrix by: (CC3Vector) aRotation {
	GLfloat tmpMtx[16];
	CC3KMMat4RotationZYX(tmpMtx, aRotation);
	[self leftMultiply: aGLMatrix byMatrix: tmpMtx];
}

+(void) rotate: (GLfloat*) aGLMatrix byX: (GLfloat) degrees {
	GLfloat tmpMtx[16];
	CC3KMMat4RotationX(tmpMtx, degrees);
	[self leftMultiply: aGLMatrix byMatrix: tmpMtx];
}

+(void) rotate: (GLfloat*) aGLMatrix byY: (GLfloat) degrees {
	GLfloat tmpMtx[16];
	CC3KMMat4RotationY(tmpMtx, degrees);
	[self leftMultiply: aGLMatrix byMatrix: tmpMtx];
}

+(void) rotate: (GLfloat*) aGLMatrix byZ: (GLfloat) degrees {
	GLfloat tmpMtx[16];
	CC3KMMat4RotationZ(tmpMtx, degrees);
	[self leftMultiply: aGLMatrix byMatrix: tmpMtx];
}

+(void) rotate: (GLfloat*) aGLMatrix byQuaternion: (CC3Quaternion) aQuaternion {
	GLfloat tmpMtx[16];
	CC3KMMat4RotationQuaternion(tmpMtx, aQuaternion);
	[self leftMultiply: aGLMatrix byMatrix: tmpMtx];
}

+(void) orthonormalizeRotationOf: (GLfloat*) aGLMatrix
					startingWith: (CC3GLMatrixOrthonormalizationStart) startVector {
	#define CC3BasisVectorX		(*(CC3Vector*)&aGLMatrix[0])
	#define CC3BasisVectorY		(*(CC3Vector*)&aGLMatrix[4])
	#define CC3BasisVectorZ		(*(CC3Vector*)&aGLMatrix[8])
	CC3Vector basisVectors[3];
	switch (startVector) {
			
		// Start Gram-Schmidt orthonormalization with the X-axis basis vector.
		case kCC3GLMatrixOrthonormalizationStartX:
			basisVectors[0] = CC3BasisVectorX;
			basisVectors[1] = CC3BasisVectorY;
			basisVectors[2] = CC3BasisVectorZ;
			CC3VectorOrthonormalizeTriple(basisVectors);
			CC3BasisVectorX = basisVectors[0];
			CC3BasisVectorY = basisVectors[1];
			CC3BasisVectorZ = basisVectors[2];
			break;
			
		// Start Gram-Schmidt orthonormalization with the Y-axis basis vector.
		case kCC3GLMatrixOrthonormalizationStartY:
			basisVectors[0] = CC3BasisVectorY;
			basisVectors[1] = CC3BasisVectorZ;
			basisVectors[2] = CC3BasisVectorX;
			CC3VectorOrthonormalizeTriple(basisVectors);
			CC3BasisVectorY = basisVectors[0];
			CC3BasisVectorZ = basisVectors[1];
			CC3BasisVectorX = basisVectors[2];
			break;
			
		// Start Gram-Schmidt orthonormalization with the Z-axis basis vector.
		case kCC3GLMatrixOrthonormalizationStartZ:
			basisVectors[0] = CC3BasisVectorZ;
			basisVectors[1] = CC3BasisVectorX;
			basisVectors[2] = CC3BasisVectorY;
			CC3VectorOrthonormalizeTriple(basisVectors);
			CC3BasisVectorZ = basisVectors[0];
			CC3BasisVectorX = basisVectors[1];
			CC3BasisVectorY = basisVectors[2];
			break;
			
		default:	// Don't do any orthonormalization
			break;
	}
}

+(void) translate: (GLfloat*) aGLMatrix by: (CC3Vector) aVector {
	GLfloat* m = aGLMatrix;					// Make a simple alias
	
	m[12] += aVector.x * m[0] + aVector.y * m[4] + aVector.z * m[8];
	m[13] += aVector.x * m[1] + aVector.y * m[5] + aVector.z * m[9];
	m[14] += aVector.x * m[2] + aVector.y * m[6] + aVector.z * m[10];
    m[15] += aVector.x * m[3] + aVector.y * m[7] + aVector.z * m[11];
}

+(void) translate: (GLfloat*) aGLMatrix byX: (GLfloat) distance {
	[self translate: aGLMatrix by: cc3v(distance, 0.0, 0.0)];
}

+(void) translate: (GLfloat*) aGLMatrix byY: (GLfloat) distance {
	[self translate: aGLMatrix by: cc3v(0.0, distance, 0.0)];
}

+(void) translate: (GLfloat*) aGLMatrix byZ: (GLfloat) distance {
	[self translate: aGLMatrix by: cc3v(0.0, 0.0, distance)];
}

+(void) scale: (GLfloat*) aGLMatrix by: (CC3Vector) aVector {
	GLfloat* m = aGLMatrix;					// Make a simple alias

	m[0] *= aVector.x;
	m[1] *= aVector.x;
	m[2] *= aVector.x;
	m[3] *= aVector.x;
	
	m[4] *= aVector.y;
	m[5] *= aVector.y;
	m[6] *= aVector.y;
	m[7] *= aVector.y;
	
	m[8] *= aVector.z;
	m[9] *= aVector.z;
	m[10] *= aVector.z;
	m[11] *= aVector.z;
}

+(void) scale: (GLfloat*) aGLMatrix byX: (GLfloat) scaleFactor {
	[self scale: aGLMatrix by: cc3v(scaleFactor, 1.0, 1.0)];
}

+(void) scale: (GLfloat*) aGLMatrix byY: (GLfloat) scaleFactor {
	[self scale: aGLMatrix by: cc3v(1.0, scaleFactor, 1.0)];
}

+(void) scale: (GLfloat*) aGLMatrix byZ: (GLfloat) scaleFactor {
	[self scale: aGLMatrix by: cc3v(1.0, 1.0, scaleFactor)];
}
	
+(void) scale: (GLfloat*) aGLMatrix uniformlyBy: (GLfloat) scaleFactor {
	[self scale: aGLMatrix by: cc3v(scaleFactor, scaleFactor, scaleFactor)];
}
		 

#pragma mark -
#pragma mark Instance math operations

// Includes short-circuits when one of the matrix is an identity matrix
-(void) multiplyByMatrix: (CC3GLMatrixDeprecated*) aGLMatrix {

	// If other matrix is identity, this matrix doesn't change, so leave
	if (!aGLMatrix || aGLMatrix.isIdentity) return;
	
	// If this matrix is identity, it just becomes the other matrix
	if (self.isIdentity) {
		[self populateFrom: aGLMatrix];
		return;
	}

	// Otherwise, go through with the multiplication
	[[self class] multiply: self.glMatrix byMatrix: aGLMatrix.glMatrix];
	isIdentity = NO;
}

// Includes short-circuits when one of the matrix is an identity matrix
-(void) leftMultiplyByMatrix: (CC3GLMatrixDeprecated*) aGLMatrix {
	
	// If other matrix is identity, this matrix doesn't change, so leave
	if (!aGLMatrix || aGLMatrix.isIdentity) {
		return;
	}
	
	// If this matrix is identity, it just becomes the other matrix
	if (self.isIdentity) {
		[self populateFrom: aGLMatrix];
		return;
	}
	
	// Otherwise, go through with the multiplication
	[[self class] leftMultiply: self.glMatrix byMatrix: aGLMatrix.glMatrix];
	isIdentity = NO;
}

-(CC3Vector) transformLocation: (CC3Vector) aLocation {
	// Short-circuit if this is an identity matrix
	if (isIdentity) {
		return aLocation;
	} else {
		return [[self class] transformLocation: aLocation withMatrix: self.glMatrix];
	}
}

-(CC3Vector) transformDirection: (CC3Vector) aDirection {
	// Short-circuit if this is an identity matrix
	if (isIdentity) {
		return aDirection;
	} else {
		return [[self class] transformDirection: aDirection withMatrix: self.glMatrix];
	}
}

-(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector {
	// Short-circuit if this is an identity matrix
	if (isIdentity) {
		return aVector;
	} else {
		return [[self class] transformHomogeneousVector: aVector withMatrix: self.glMatrix];
	}
}

-(CC3Ray) transformRay: (CC3Ray) aRay {
	return [[self class] transformRay: aRay withMatrix: self.glMatrix];
}

-(void) transpose {
	// Short-circuit if this is an identity matrix
	if (!isIdentity) {
		[[self class] transpose: self.glMatrix];
	}
}

-(BOOL) invert {
	// Short-circuit if this is an identity matrix
	if (isIdentity) return YES;

	BOOL wasInverted = [[self class] invert: self.glMatrix];
	if ( !wasInverted ) {
		LogError(@"Matrix is singular and cannot be inverted: %@", self);
	}
	return wasInverted;
}

-(BOOL) invertAffine {
	// Short-circuit if this is an identity matrix
	if (isIdentity) return YES;
	
	BOOL wasInverted = [[self class] invertAffine: self.glMatrix];
	if ( !wasInverted ) {
		LogError(@"Matrix is singular and cannot be inverted: %@", self);
	}
	return wasInverted;
}

-(void) invertRigid {
	// Short-circuit if this is an identity matrix
	if (!isIdentity) {
		[[self class] invertRigid: self.glMatrix];
	}
}


#pragma mark Matrix math operations

+(void) multiply: (GLfloat*) aGLMatrix byMatrix: (GLfloat*) anotherGLMatrix {
	GLfloat mOut[16];
	CC3Mat4Multiply(mOut, aGLMatrix, anotherGLMatrix);
	[self copyMatrix: mOut into: aGLMatrix];
}

+(void) leftMultiply: (GLfloat*) aGLMatrix byMatrix: (GLfloat*) anotherGLMatrix {
	GLfloat mOut[16];
	CC3Mat4Multiply(mOut, anotherGLMatrix, aGLMatrix);
	[self copyMatrix: mOut into: aGLMatrix];
}

+(CC3Vector) transformLocation: (CC3Vector) aLocation withMatrix: (GLfloat*) aGLMatrix {
	return [self transformHomogeneousVector: CC3Vector4FromLocation(aLocation) withMatrix: aGLMatrix].v;
}

+(CC3Vector) transformDirection: (CC3Vector) aDirection withMatrix: (GLfloat*) aGLMatrix {
	return [self transformHomogeneousVector: CC3Vector4FromDirection(aDirection) withMatrix: aGLMatrix].v;
}

+(CC3Vector4) transformHomogeneousVector: (CC3Vector4) aVector withMatrix: (GLfloat*) aGLMatrix {
	CC3Vector4 vOut;
	GLfloat* m = aGLMatrix;					// Make a simple alias

	vOut.x = aVector.x * m[0] + aVector.y * m[4] + aVector.z * m[8] + aVector.w * m[12];
	vOut.y = aVector.x * m[1] + aVector.y * m[5] + aVector.z * m[9] + aVector.w * m[13];
	vOut.z = aVector.x * m[2] + aVector.y * m[6] + aVector.z * m[10] + aVector.w * m[14];
    vOut.w = aVector.x * m[3] + aVector.y * m[7] + aVector.z * m[11] + aVector.w * m[15];

	return vOut;
}

+(CC3Ray) transformRay: (CC3Ray) aRay withMatrix: (GLfloat*) aGLMatrix {
	CC3Ray rayOut;
	rayOut.startLocation = [self transformLocation: aRay.startLocation withMatrix: aGLMatrix];
	rayOut.direction = [self transformDirection: aRay.direction withMatrix: aGLMatrix];
	return rayOut;
}

+(void) transpose: (GLfloat*) aGLMatrix {
	GLfloat tmp;
	GLfloat* m = aGLMatrix;							// Make a simple alias

	tmp = m[1];    m[1] = m[4];    m[4] = tmp;		// Swap 1 and 4
	tmp = m[2];    m[2] = m[8];    m[8] = tmp;		// Swap 2 and 8
	tmp = m[3];    m[3] = m[12];   m[12] = tmp;		// Swap 3 and 12
	tmp = m[6];    m[6] = m[9];    m[9] = tmp;		// Swap 6 and 9
	tmp = m[7];    m[7] = m[13];   m[13] = tmp;		// Swap 7 and 13
	tmp = m[11];   m[11] = m[14];  m[14] = tmp;		// Swap 11 and 14
}

/**
 * Inverts the specified matrix by calculating the classical adjoint of
 * the matrix and then divides by the determinant of the matrix.
 * 
 * Returns NO if the determinant is zero, as this indicates that the
 * matrix is singular and cannot be inverted. Returns YES otherwise.
 */
+(BOOL) invert: (GLfloat*) aGLMatrix {
	GLfloat* m = aGLMatrix;				// Make a simple alias
	GLfloat adj[16];					// The inverse matrix
	GLfloat det;						// The determinant.
	
	// Create the transpose of the cofactors, as the classical adjoint of the matrix.
    adj[0] =  CC3Det3x3(m[5], m[6], m[7], m[9], m[10], m[11], m[13], m[14], m[15]);
    adj[1] = -CC3Det3x3(m[1], m[2], m[3], m[9], m[10], m[11], m[13], m[14], m[15]);
    adj[2] =  CC3Det3x3(m[1], m[2], m[3], m[5], m[6], m[7], m[13], m[14], m[15]);
    adj[3] = -CC3Det3x3(m[1], m[2], m[3], m[5], m[6], m[7], m[9], m[10], m[11]);
	
    adj[4] = -CC3Det3x3(m[4], m[6], m[7], m[8], m[10], m[11], m[12], m[14], m[15]);
    adj[5] =  CC3Det3x3(m[0], m[2], m[3], m[8], m[10], m[11], m[12], m[14], m[15]);
    adj[6] = -CC3Det3x3(m[0], m[2], m[3], m[4], m[6], m[7], m[12], m[14], m[15]);
    adj[7] =  CC3Det3x3(m[0], m[2], m[3], m[4], m[6], m[7], m[8], m[10], m[11]);
	
    adj[8] =  CC3Det3x3(m[4], m[5], m[7], m[8], m[9], m[11], m[12], m[13], m[15]);
    adj[9] = -CC3Det3x3(m[0], m[1], m[3], m[8], m[9], m[11], m[12], m[13], m[15]);
    adj[10] =  CC3Det3x3(m[0], m[1], m[3], m[4], m[5], m[7], m[12], m[13], m[15]);
    adj[11] = -CC3Det3x3(m[0], m[1], m[3], m[4], m[5], m[7], m[8], m[9], m[11]);
	
    adj[12] = -CC3Det3x3(m[4], m[5], m[6], m[8], m[9], m[10], m[12], m[13], m[14]);
    adj[13] =  CC3Det3x3(m[0], m[1], m[2], m[8], m[9], m[10], m[12], m[13], m[14]);
    adj[14] = -CC3Det3x3(m[0], m[1], m[2], m[4], m[5], m[6], m[12], m[13], m[14]);
    adj[15] =  CC3Det3x3(m[0], m[1], m[2], m[4], m[5], m[6], m[8], m[9], m[10]);
	
	// Calculate the determinant as a combination of the cofactors of the first row.
	det = (m[0] * adj[0]) + (m[4] * adj[1]) + (m[8] * adj[2]) + (m[12] * adj[3]);
	
	// If determinant is not zero, matrix is invertable.
	// Divide the classical adjoint matrix by the determinant and set back into original matrix.
	BOOL isInvertable = (det != 0.0f);
	if (isInvertable) {
		GLfloat ooDet = 1.0 / det;		// Turn div into mult for speed
		
		m[0]  = adj[0]  * ooDet;
		m[1]  = adj[1]  * ooDet;
		m[2]  = adj[2]  * ooDet;
		m[3]  = adj[3]  * ooDet;
		m[4]  = adj[4]  * ooDet;
		m[5]  = adj[5]  * ooDet;
		m[6]  = adj[6]  * ooDet;
		m[7]  = adj[7]  * ooDet;
		m[8]  = adj[8]  * ooDet;
		m[9]  = adj[9]  * ooDet;
		m[10] = adj[10] * ooDet;
		m[11] = adj[11] * ooDet;
		m[12] = adj[12] * ooDet;
		m[13] = adj[13] * ooDet;
		m[14] = adj[14] * ooDet;
		m[15] = adj[15] * ooDet;
	}
	
	return isInvertable;
}

+(BOOL) invertAffine: (GLfloat*) aGLMatrix {
/*
 M = |  L  t |
     |  0  1 |
	 
	 where L is a 3x3 linear tranformation matrix, t is a translation vector,
	 and 0 is a row of 3 zeros
*/

	GLfloat* m = aGLMatrix;					// Make a simple alias
	BOOL wasInverted = [self invert: m];	// Invert the matrix
	m[3] = m[7] = m[11] = 0.0f;				// Ensure bottom row are exactly {0, 0, 0, 1}
	m[15] = 1.0f;
    return wasInverted;
}

+(void) invertRigid: (GLfloat*) aGLMatrix {
/*
 M = |  RT  -RT(t) |
     |  0     1    |
	 
	 where RT is the transposed 3x3 rotation matrix extracted from the 4x4 matrix
	 and t is a translation vector extracted from the 4x4 matrix
*/
	
	GLfloat* m = aGLMatrix;		// Make a simple alias
	
	// Extract translation component of matrix and remove it to leave a rotation-only matrix
	CC3Vector t = cc3v(m[12], m[13], m[14]);
	m[12] = m[13] = m[14] = 0.0f;
	m[3] = m[7] = m[11] = 0.0f;				// Ensure bottom row are exactly {0, 0, 0, 1}
	m[15] = 1.0f;

	// Transpose (invert) rotation matrix
	[self transpose: m];
	
	// Transform negated translation with transposed rotation matrix
	// and reinsert into transposed matrix
	t = [self transformDirection: CC3VectorNegate(t) withMatrix: m];	
	m[12] = t.x;
	m[13] = t.y;
	m[14] = t.z;
}

@end


#pragma mark Deprecated CC3GLMatrix

@implementation CC3GLMatrix
@end


