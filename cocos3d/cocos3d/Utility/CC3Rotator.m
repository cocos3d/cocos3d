/*
 * CC3Rotator.m
 *
 * cocos3d 0.7.1
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
 * See header file CC3Rotator.h for full API documentation.
 */

#import "CC3Rotator.h"
#import "CC3Node.h"


#pragma mark -
#pragma mark CC3Rotator

@implementation CC3Rotator

-(BOOL) isMutable { return NO; }

-(BOOL) isDirectional { return NO; }

-(CC3Vector) rotation { return kCC3VectorZero; }

-(CC3Vector4) quaternion { return kCC3Vector4QuaternionIdentity; }

-(CC3Vector) rotationAxis { return kCC3VectorZero; }

-(GLfloat) rotationAngle { return 0.0f; }

-(CC3GLMatrix*) rotationMatrix { return nil; }

-(CC3Node*) target { return nil; }

-(BOOL) shouldTrackTarget { return NO; }

-(BOOL) shouldAutotargetCamera { return NO; }

-(BOOL) shouldRotateToTargetLocation { return NO; }

//-(void) markGlobalLocationChanged {}

static GLubyte autoOrthonormalizeCount = 0;

+(GLubyte) autoOrthonormalizeCount { return autoOrthonormalizeCount; }

+(void) setAutoOrthonormalizeCount: (GLubyte) aCount { autoOrthonormalizeCount = aCount; }


#pragma mark Allocation and initialization

+(id) rotator { return [[[self alloc] init] autorelease]; }

-(id) copyWithZone: (NSZone*) zone {
	CC3Rotator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Rotator*) another {}

-(void) applyRotationTo: (CC3GLMatrix*) aMatrix {}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

-(NSString*) fullDescription { return self.description; }

@end


#pragma mark -
#pragma mark CC3MutableRotator

@interface CC3MutableRotator (TemplateMethods)
-(void) ensureRotationFromMatrix;
-(void) ensureQuaternionFromMatrix;
-(void) ensureQuaternionFromAxisAngle;
-(void) ensureAxisAngleFromQuaternion;
-(void) applyRotation;
-(void) autoOrthonormalize;
@property(nonatomic, readonly) BOOL isRotationDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByRotation;
@property(nonatomic, readonly) BOOL isQuaternionDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByQuaternion;
@property(nonatomic, readonly) BOOL isAxisAngleDirty;
@property(nonatomic, readonly) BOOL isQuaternionDirtyByAxisAngle;
@end

@implementation CC3MutableRotator

-(void) dealloc {
	[rotationMatrix release];
	[super dealloc];
}

-(BOOL) isMutable { return YES; }

-(BOOL) isDirectional { return NO; }

-(CC3Vector) rotation {
	[self ensureRotationFromMatrix];
	return rotation;
}

-(void) setRotation:(CC3Vector) aRotation {
	rotation = CC3VectorRotationModulo(aRotation);
	
	isRotationDirty = NO;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsDirtyByRotation;
}

-(void) rotateBy: (CC3Vector) aRotation {
	[rotationMatrix rotateBy: CC3VectorRotationModulo(aRotation)];
	[self autoOrthonormalize];
	
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsNotDirty;
}

-(CC3Vector4) quaternion {
	[self ensureQuaternionFromAxisAngle];
	[self ensureQuaternionFromMatrix];
	return quaternion;
}

-(void) setQuaternion:(CC3Vector4) aQuaternion {
	quaternion = aQuaternion;
	
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = NO;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsDirtyByQuaternion;
}

-(void) rotateByQuaternion: (CC3Vector4) aQuaternion {
	[rotationMatrix rotateByQuaternion: aQuaternion];
	[self autoOrthonormalize];
	
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsNotDirty;
}

-(CC3Vector) rotationAxis {
	[self ensureAxisAngleFromQuaternion];
	return rotationAxis;
}

-(void) setRotationAxis: (CC3Vector) aDirection {
	rotationAxis = aDirection;
	
	isRotationDirty = YES;
	isAxisAngleDirty = NO;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = YES;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsDirtyByAxisAngle;
}

-(GLfloat) rotationAngle {
	[self ensureAxisAngleFromQuaternion];
	return rotationAngle;
}

-(void) setRotationAngle: (GLfloat) anAngle {
	rotationAngle = CC3CyclicAngle(anAngle);
	
	isRotationDirty = YES;
	isAxisAngleDirty = NO;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = YES;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsDirtyByAxisAngle;
}

-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	CC3Vector4 q = CC3QuaternionFromAxisAngle(CC3Vector4FromCC3Vector(anAxis, anAngle));
	[self rotateByQuaternion: q];
}

-(CC3GLMatrix*) rotationMatrix {
	[self applyRotation];
	return rotationMatrix;
}

-(void) setRotationMatrix:(CC3GLMatrix*) aGLMatrix {
	id oldMtx = rotationMatrix;
	rotationMatrix = [aGLMatrix retain];
	[oldMtx release];
	
	isRotationDirty = YES;
	isQuaternionDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsNotDirty;
}

-(void) orthonormalize {
	LogCleanTrace(@"Orthonormalizing (starting with %i): %@",
				  orthonormalizationStartVector, self.rotationMatrix);
	
	// Orthonormalize the matrix using the current starting basis vector
	[self.rotationMatrix orthonormalizeRotationStartingWith: orthonormalizationStartVector];

	// Cycle the starting vector, so that the next invocation starts with a different basis vector
	switch (orthonormalizationStartVector) {
		case kCC3GLMatrixOrthonormalizationStartX:
			orthonormalizationStartVector = kCC3GLMatrixOrthonormalizationStartY;
			break;
		case kCC3GLMatrixOrthonormalizationStartY:
			orthonormalizationStartVector = kCC3GLMatrixOrthonormalizationStartZ;
			break;
		case kCC3GLMatrixOrthonormalizationStartZ:
		default:
			orthonormalizationStartVector = kCC3GLMatrixOrthonormalizationStartX;
			break;
	}
	LogCleanTrace(@"Orthonormalization completed: %@", self.rotationMatrix);
}

-(void) autoOrthonormalize {
	if (autoOrthonormalizeCount) {
		incrementalRotationCount++;
		if (incrementalRotationCount >= autoOrthonormalizeCount) {
			[self orthonormalize];
			incrementalRotationCount = 0;
		}
	}
}


#pragma mark Allocation and initialization

-(id) init { return [self initOnRotationMatrix: [CC3GLMatrix identity]]; }

-(id) initOnRotationMatrix: (CC3GLMatrix*) aGLMatrix {
	if ( (self = [super init]) ) {
		// All dirty flags set by matrix setter
		self.rotationMatrix = aGLMatrix;
		rotation = kCC3VectorZero;
		quaternion = kCC3Vector4QuaternionIdentity;
		rotationAxis = kCC3VectorZero;
		rotationAngle = 0.0;
		orthonormalizationStartVector = kCC3GLMatrixOrthonormalizationStartX;
		incrementalRotationCount = 0;
	}
	return self;
}

+(id) rotatorOnRotationMatrix: (CC3GLMatrix*) aGLMatrix {
	return [[[self alloc] initOnRotationMatrix: aGLMatrix] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	CC3Rotator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

// Protected properties for copying
-(CC3GLMatrixOrthonormalizationStart) orthonormalizationStartVector { return orthonormalizationStartVector; }
-(GLubyte) incrementalRotationCount { return incrementalRotationCount; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Rotator*) another {
	
	// Copy matrix contents, then set matrix again to reset all dirty flags
	[rotationMatrix populateFrom: another.rotationMatrix];
	self.rotationMatrix = self.rotationMatrix;
	
	rotation = another.rotation;
	quaternion = another.quaternion;
	rotationAxis = another.rotationAxis;
	rotationAngle = another.rotationAngle;
	
	// Only proceed with populating the following properties if the
	// other instance is also a mutable rotator.
	if( [another isKindOfClass:[CC3MutableRotator class]] ) {
		CC3MutableRotator* anotherMR = (CC3MutableRotator*)another;
		orthonormalizationStartVector = anotherMR.orthonormalizationStartVector;
		incrementalRotationCount = anotherMR.incrementalRotationCount;
	}
}

/** If needed, extracts and sets the rotation Euler angles from the encapsulated rotation matrix. */
-(void) ensureRotationFromMatrix {
	if (isRotationDirty) {
		rotation = [self.rotationMatrix extractRotation];
		isRotationDirty = NO;
	}
}

/** If needed, extracts and sets the quaternion from the encapsulated rotation matrix. */
-(void) ensureQuaternionFromMatrix {
	if (isQuaternionDirty) {
		quaternion = [self.rotationMatrix extractQuaternion];
		isQuaternionDirty = NO;
	}
}

/** If needed, extracts and sets the quaternion from the encapsulated rotation axis and angle. */
-(void) ensureQuaternionFromAxisAngle {
	if (isQuaternionDirtyByAxisAngle) {
		quaternion = CC3QuaternionFromAxisAngle(CC3Vector4FromCC3Vector(rotationAxis, rotationAngle));
		isQuaternionDirtyByAxisAngle = NO;
	}
}

/**
 * If needed, extracts and returns a rotation axis and angle from the encapsulated quaternion.
 * If the rotation angle is zero, the axis is undefined, and will be set to the zero vector.
 *
 * The rotationAxis can point in one of two equally valid directions. THe choice is made to
 * return the direction that is closest to the previous rotation angle. This step is taken
 * for consistency, so that small changes in rotation wont suddenly flip the rotation axis
 * and angle.
 *
 * The rotation angle will be clamped to +/-180 degrees. The rotationAxis can point in one
 */
-(void) ensureAxisAngleFromQuaternion {
	if (isAxisAngleDirty) {
		CC3Vector4 axisAngle = CC3AxisAngleFromQuaternion(self.quaternion);
		CC3Vector qAxis = CC3VectorFromTruncatedCC3Vector4(axisAngle);
		GLfloat qAngle = CC3SemiCyclicAngle(axisAngle.w);
		if ( CC3VectorDot(qAxis, rotationAxis) < 0 ) {
			rotationAxis = CC3VectorNegate(qAxis);
			rotationAngle = -qAngle;
		} else {
			rotationAxis = qAxis;
			rotationAngle = qAngle;
		}
		isAxisAngleDirty = NO;
	}
}

/** Recalculates the rotation matrix from the most recently set rotation or quaternion property. */
-(void) applyRotation {
	switch (matrixIsDirtyBy) {
		case kCC3RotationMatrixIsDirtyByRotation:
			[rotationMatrix populateFromRotation: self.rotation];
			matrixIsDirtyBy = kCC3RotationMatrixIsNotDirty;
			break;
		case kCC3RotationMatrixIsDirtyByQuaternion:
		case kCC3RotationMatrixIsDirtyByAxisAngle:
			[rotationMatrix populateFromQuaternion: self.quaternion];
			matrixIsDirtyBy = kCC3RotationMatrixIsNotDirty;
			break;
		default:
			break;
	}
}

-(void) applyRotationTo: (CC3GLMatrix*) aMatrix {
	[aMatrix multiplyByMatrix: self.rotationMatrix];	// Rotation matrix is built lazily if needed
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ with rotation: %@, quaternion: %@, rotation axis: %@, rotation angle %.3f",
			super.fullDescription,
			NSStringFromCC3Vector(self.rotation),
			NSStringFromCC3Vector4(self.quaternion),
			NSStringFromCC3Vector(self.rotationAxis),
			self.rotationAngle];
}

@end


#pragma mark -
#pragma mark CC3DirectionalRotator

@interface CC3DirectionalRotator (TemplateMethods)
-(void) ensureForwardDirectionFromMatrix;
-(void) ensureUpDirectionFromMatrix;
-(void) ensureRightDirectionFromMatrix;
@property(nonatomic, readonly) BOOL isDirtyByTargetLocation;
@property(nonatomic, assign) CC3Vector matrixForwardDirection;
-(void) setMatrixRightDirection:(CC3Vector) aDirection;
@end


@implementation CC3DirectionalRotator

@synthesize isTrackingForBumpMapping, shouldTrackTarget;
@synthesize shouldAutotargetCamera, targetLocation, isTargetLocationDirty;

-(void) dealloc {
	target = nil;			// not retained
	[super dealloc];
}

-(CC3TargettingAxisRestriction) axisRestriction { return axisRestriction; }

-(void) setAxisRestriction: (CC3TargettingAxisRestriction) axisRest {
	axisRestriction = axisRest;
}

-(BOOL) isDirectional { return YES; }

-(CC3Vector) forwardDirection {
	[self ensureForwardDirectionFromMatrix];
	return forwardDirection;
}

-(void) setForwardDirection: (CC3Vector) aDirection {
	NSAssert(!CC3VectorsAreEqual(aDirection, kCC3VectorZero),
			 @"The forwardDirection may not be set to the zero vector.");

	forwardDirection = CC3VectorNormalize(aDirection);

	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	isForwardDirectionDirty = NO;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isTargetLocationDirty = YES;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsDirtyByDirection;
}

-(CC3Vector) sceneUpDirection { return sceneUpDirection; }

-(void) setSceneUpDirection: (CC3Vector) aDirection {
	NSAssert(!CC3VectorsAreEqual(aDirection, kCC3VectorZero),
			 @"The sceneUpDirection may not be set to the zero vector.");
	
	sceneUpDirection = CC3VectorNormalize(aDirection);
	
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	isForwardDirectionDirty = NO;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isTargetLocationDirty = YES;
	
	matrixIsDirtyBy = kCC3RotationMatrixIsDirtyByDirection;
}

// Deprecated
-(CC3Vector) worldUpDirection { return self.sceneUpDirection; }
-(void) setWorldUpDirection: (CC3Vector) aDirection { self.sceneUpDirection = aDirection; }

-(CC3Vector) upDirection {
	[self ensureUpDirectionFromMatrix];
	return upDirection;
}

-(CC3Vector) rightDirection {
	[self ensureRightDirectionFromMatrix];
	return rightDirection;
}

-(void) setRotation:(CC3Vector) aRotation {
	[super setRotation: aRotation];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isTargetLocationDirty = YES;
}

-(void) rotateBy: (CC3Vector) aRotation {
	[super rotateBy: aRotation];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isTargetLocationDirty = YES;
}

-(void) setQuaternion:(CC3Vector4) aQuaternion {
	[super setQuaternion: aQuaternion];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isTargetLocationDirty = YES;
}

-(void) rotateByQuaternion: (CC3Vector4) aQuaternion {
	[super rotateByQuaternion: aQuaternion];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isTargetLocationDirty = YES;
}

-(void) setRotationMatrix:(CC3GLMatrix*) aGLMatrix {
	[super setRotationMatrix: aGLMatrix];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isTargetLocationDirty = YES;
}

/**
 * The new target location cannot be applied immediately, because the direction to
 * the target depends on the transformed global location of both the target location
 * and the node containing this rotator. Remember that it was set.
 */
-(void) setTargetLocation: (CC3Vector) aLocation {
	[self setRawTargetLocation: aLocation];
	matrixIsDirtyBy = kCC3RotationMatrixIsDirtyByTargetLocation;
}

-(void) setRawTargetLocation: (CC3Vector) aLocation {
	targetLocation = aLocation;
	isTargetLocationDirty = NO;
	isNewTarget = NO;		// Target is no longer new once the location of it has been set.
}

-(BOOL) isDirtyByTargetLocation {
	return matrixIsDirtyBy == kCC3RotationMatrixIsDirtyByTargetLocation;
}

-(void) rotateToTargetLocationFrom: (CC3Vector) aLocation {
	if ( !CC3VectorsAreEqual(targetLocation, aLocation) ) {
		self.forwardDirection = CC3VectorDifference(targetLocation, aLocation);
		isTargetLocationDirty = NO;		// Reset after setForwardDirection: sets it
	}
}

-(CC3Node*) target { return target; }

/**
 * Set the new target as weak line and mark if it has changed.
 * Don't mark if not changed, so that a change persists even if the same target is set again.
 */
-(void) setTarget: (CC3Node*) aNode {
	if (aNode != target) isNewTarget = YES;
	target = aNode;
}

-(BOOL) shouldUpdateToTarget { return target && (isNewTarget || shouldTrackTarget); }

-(BOOL) shouldRotateToTargetLocation {
	return (self.isDirtyByTargetLocation || shouldTrackTarget) && !isTrackingForBumpMapping;
}


#pragma mark Allocation & Initialization

-(id) initOnRotationMatrix: (CC3GLMatrix*) aGLMatrix {
	if ( (self = [super initOnRotationMatrix: aGLMatrix]) ) {
		// All dirty flags set by matrix setter in super init
		target = nil;
		sceneUpDirection = kCC3VectorUnitYPositive;
		forwardDirection = kCC3VectorNull;		// Calculated
		upDirection = kCC3VectorNull;			// Calculated
		rightDirection = kCC3VectorNull;		// Calculated
		targetLocation = kCC3VectorZero;
		axisRestriction = kCC3TargettingAxisRestrictionNone;
		isNewTarget = NO;
		shouldTrackTarget = NO;
		shouldAutotargetCamera = NO;
		isTrackingForBumpMapping = NO;
	}
	return self;
}

// Protected properties used for copying
-(BOOL) isNewTarget { return isNewTarget; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// This method supports populating from a parent class as well.
-(void) populateFrom: (CC3Rotator*) another {
	[super populateFrom: another];

	// Only proceed with populating the directional properties if the
	// other instance is also a directional rotator.
	// All dirty flags are set when matrix set in superclass
	if( [another isKindOfClass:[CC3DirectionalRotator class]] ) {
		self.target = another.target;		// weak link...not copied
		CC3DirectionalRotator* anotherDR = (CC3DirectionalRotator*)another;
		forwardDirection = anotherDR.forwardDirection;
		sceneUpDirection = anotherDR.sceneUpDirection;
		upDirection = anotherDR.upDirection;
		rightDirection = anotherDR.rightDirection;
		targetLocation = anotherDR.targetLocation;
		axisRestriction = anotherDR.axisRestriction;
		isNewTarget = anotherDR.isNewTarget;
		shouldTrackTarget = anotherDR.shouldTrackTarget;
		shouldAutotargetCamera = anotherDR.shouldAutotargetCamera;
		isTrackingForBumpMapping = anotherDR.isTrackingForBumpMapping;
	}
}

/**
 * The forward direction, modified for use in the matrix, when setting the direction.
 *
 * By default, this is simply the same as the forwardDirection. Subclasses that need
 * to point the node in another direction can override.
 */
-(CC3Vector) matrixForwardDirection { return self.forwardDirection; }

/**
 * The forward direction, modified for use in the matrix, when setting the direction
 * by extracting it from the matrix.
 *
 * By default, this is simply the same as the forwardDirection. Subclasses that need
 * to point the node in another direction can override.
 */
-(void) setMatrixForwardDirection:(CC3Vector) aDirection { forwardDirection = aDirection; }

/**
 * If needed, extracts and sets the forwardDirection from the encapsulated rotation
 * matrix. This method is invoked automatically when accessing the forwardDirection
 * property, if that property is not current (ie- if the rotation was most recently
 * set with Euler angles or a quaternion).
 */
-(void) ensureForwardDirectionFromMatrix {
	if (isForwardDirectionDirty) {
		self.matrixForwardDirection = [self.rotationMatrix extractForwardDirection];
		isForwardDirectionDirty = NO;
	}
}

/**
 * If needed, extracts and sets the upDirection from the encapsulated rotation matrix.
 * This method is invoked automatically when accessing the upDirection property,
 * if that property is not current (ie- if the rotation was most recently set with
 * Euler angles or a quaternion).
 */
-(void) ensureUpDirectionFromMatrix {
	if (isUpDirectionDirty) {
		upDirection = [self.rotationMatrix extractUpDirection];
		isUpDirectionDirty = NO;
	}
}

/**
 * The right direction, modified for use in the matrix, when setting the direction
 * by extracting it from the matrix.
 *
 * By default, this is simply the same as the rightDirection. Subclasses that need
 * to point the node in another direction can override.
 */
-(void) setMatrixRightDirection:(CC3Vector) aDirection { rightDirection = aDirection; }

/**
 * If needed, extracts and sets the rightDirection from the encapsulated rotation matrix.
 * This method is invoked automatically when accessing the rightDirection property,
 * if that property is not current (ie- if the rotation was most recently set with
 * Euler angles or a quaternion).
 */
-(void) ensureRightDirectionFromMatrix {
	if (isRightDirectionDirty) {
		[self setMatrixRightDirection: [self.rotationMatrix extractRightDirection]];
		isRightDirectionDirty = NO;
	}
}

-(void) applyRotation {
	[super applyRotation];
	if (matrixIsDirtyBy == kCC3RotationMatrixIsDirtyByDirection) {
		[rotationMatrix populateToPointTowards: self.matrixForwardDirection withUp: sceneUpDirection];
		matrixIsDirtyBy = kCC3RotationMatrixIsNotDirty;
	}
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, direction: %@, up: %@, scene up: %@, targetted at: %@, from target: %@",
			super.fullDescription,
			NSStringFromCC3Vector(self.forwardDirection),
			NSStringFromCC3Vector(self.upDirection),
			NSStringFromCC3Vector(self.sceneUpDirection),
			NSStringFromCC3Vector(self.targetLocation), target];
}

@end


#pragma mark -
#pragma mark CC3ReverseDirectionalRotator

@implementation CC3ReverseDirectionalRotator

/**
 * The forward direction, modified for use in the matrix, when setting the direction.
 *
 * This implementation reverses the forward direction, so that the positive-Z axis of
 * the node's local coordinates will point in the fowardDirection.
 */
-(CC3Vector) matrixForwardDirection { return CC3VectorNegate(self.forwardDirection); }

/**
 * The forward direction, modified for use in the matrix, when setting the direction.
 *
 * This implementation reverses the forward direction, so that the positive-Z axis of
 * the node's local coordinates will point in the fowardDirection.
 */
-(void) setMatrixForwardDirection:(CC3Vector) aDirection { forwardDirection = CC3VectorNegate(aDirection); }

/**
 * The right direction, modified for use in the matrix, when setting the direction
 * by extracting it from the matrix.
 *
 * This implementation reverses the right direction, so that the negative-X axis of
 * the node's local coordinates will point in the rightDirection. This keeps the
 * right direction pointing off to the right, as a result of the inversion of the
 * forwardDirection, pointing down the positive-Z axis.
 */
-(void) setMatrixRightDirection:(CC3Vector) aDirection { rightDirection = CC3VectorNegate(aDirection); }

@end
