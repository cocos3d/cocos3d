/*
 * CC3Rotator.m
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
 * See header file CC3Rotator.h for full API documentation.
 */

#import "CC3Rotator.h"
#import "CC3Node.h"
#import "CC3LinearMatrix.h"


#pragma mark -
#pragma mark CC3Rotator

@implementation CC3Rotator

-(BOOL) isMutable { return NO; }

-(BOOL) isDirectional { return NO; }

-(BOOL) isTargettable { return NO; }

-(CC3Vector) rotation { return kCC3VectorZero; }

-(CC3Quaternion) quaternion { return kCC3QuaternionIdentity; }

-(CC3Vector) rotationAxis { return kCC3VectorNull; }

-(GLfloat) rotationAngle { return 0.0f; }

-(CC3Matrix*) rotationMatrix { return nil; }

-(CC3Vector) targetLocation { return kCC3VectorNull; }

-(CC3TargettingConstraint) targettingConstraint { return kCC3TargettingConstraintGlobalUnconstrained; }

-(CC3Node*) target { return nil; }

-(BOOL) shouldTrackTarget { return NO; }

-(BOOL) shouldUpdateToTarget { return NO; }

-(BOOL) shouldAutotargetCamera { return NO; }

-(BOOL) shouldRotateToTargetLocation { return NO; }

-(BOOL) isTrackingForBumpMapping { return NO; }

-(BOOL) isTrackingTargetDirection { return NO; }

-(BOOL) clearIfTarget: (CC3Node*) aNode { return NO; }


#pragma mark Allocation and initialization

+(id) rotator { return [[[self alloc] init] autorelease]; }

-(id) copyWithZone: (NSZone*) zone {
	CC3Rotator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(void) populateFrom: (CC3Rotator*) another {}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

-(NSString*) fullDescription { return self.description; }


#pragma mark Transformations

-(void) applyRotationTo: (CC3Matrix*) aMatrix {}

-(CC3Vector) transformDirection: (CC3Vector) aDirection { return aDirection; }

@end


#pragma mark -
#pragma mark CC3MutableRotator

@implementation CC3MutableRotator

-(void) dealloc {
	[_rotationMatrix release];
	[super dealloc];
}

-(BOOL) isMutable { return YES; }

-(BOOL) isDirectional { return NO; }

-(BOOL) isRotationDirty { return _rotationMatrix.isDirty; }

-(void) markRotationDirty { _rotationMatrix.isDirty = YES; }

-(void) markRotationClean { _rotationMatrix.isDirty = NO; }

-(CC3Vector) rotation {
	return (_rotationType == kCC3RotationTypeEuler)
				? _rotationVector.v
				: [self.rotationMatrix extractRotation];
}

-(void) setRotation:(CC3Vector) aRotation {
	_rotationVector = CC3Vector4FromCC3Vector(CC3VectorRotationModulo(aRotation), 0.0f);
	_rotationType = kCC3RotationTypeEuler;
	[self markRotationDirty];
}

-(void) rotateBy: (CC3Vector) aRotation {
	[self.rotationMatrix rotateBy: CC3VectorRotationModulo(aRotation)];
	[self autoOrthonormalize];
	_rotationType = kCC3RotationTypeUnknown;
	[self markRotationClean];
}

-(CC3Quaternion) quaternion {
	switch (_rotationType) {
		case kCC3RotationTypeQuaternion:
			return _rotationVector;
		case kCC3RotationTypeAxisAngle:
			return CC3QuaternionFromAxisAngle(self.rotationAxisAngle);
		default:
			return [self.rotationMatrix extractQuaternion];
	}
}

-(void) setQuaternion:(CC3Quaternion) aQuaternion {
	_rotationVector = aQuaternion;
	_rotationType = kCC3RotationTypeQuaternion;
	[self markRotationDirty];
}

-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion {
	[self.rotationMatrix rotateByQuaternion: aQuaternion];
	[self autoOrthonormalize];
	_rotationType = kCC3RotationTypeUnknown;
	[self markRotationClean];
}

-(CC3Vector4) rotationAxisAngle {
	return (_rotationType == kCC3RotationTypeAxisAngle)
				? _rotationVector
				: CC3AxisAngleFromQuaternion(self.quaternion);
}

-(CC3Vector) rotationAxis { return self.rotationAxisAngle.v; }

-(void) setRotationAxis: (CC3Vector) aDirection {
	_rotationVector = CC3Vector4FromCC3Vector(aDirection, self.rotationAngle);
	_rotationType = kCC3RotationTypeAxisAngle;
	[self markRotationDirty];
}

-(GLfloat) rotationAngle { return self.rotationAxisAngle.w; }

-(void) setRotationAngle: (GLfloat) anAngle {
	_rotationVector = CC3Vector4FromCC3Vector(self.rotationAxis, CC3CyclicAngle(anAngle));
	_rotationType = kCC3RotationTypeAxisAngle;
	[self markRotationDirty];
}

-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	[self rotateByQuaternion: CC3QuaternionFromAxisAngle(CC3Vector4FromCC3Vector(anAxis, anAngle))];
}

-(CC3Matrix*) rotationMatrix {
	[self applyRotation];
	return _rotationMatrix;
}

-(void) setRotationMatrix:(CC3Matrix*) aMatrix {
	if (aMatrix == _rotationMatrix) return;
	
	[_rotationMatrix release];
	_rotationMatrix = [aMatrix retain];
	
	_rotationType = kCC3RotationTypeUnknown;
	[self markRotationClean];
}

// Orthonormalize the matrix using the current starting basis vector.
// Then cycle the starting vector, so that the next invocation starts with a different column.
-(void) orthonormalize {
	LogTrace(@"Orthonormalizing (starting with column %i): %@", _orthonormalizationStartColumnNumber, self.rotationMatrix);
	
	[self.rotationMatrix orthonormalizeRotationStartingWith: _orthonormalizationStartColumnNumber];

	_orthonormalizationStartColumnNumber = (_orthonormalizationStartColumnNumber < 3)
												? (_orthonormalizationStartColumnNumber + 1) : 1;
	LogTrace(@"Orthonormalization completed: %@", self.rotationMatrix);
}

static GLubyte _autoOrthonormalizeCount = 0;

+(GLubyte) autoOrthonormalizeCount { return _autoOrthonormalizeCount; }

+(void) setAutoOrthonormalizeCount: (GLubyte) aCount { _autoOrthonormalizeCount = aCount; }

-(void) autoOrthonormalize {
	if (_autoOrthonormalizeCount) {
		_incrementalRotationCount++;
		if (_incrementalRotationCount >= _autoOrthonormalizeCount) {
			[self orthonormalize];
			_incrementalRotationCount = 0;
		}
	}
}


#pragma mark Allocation and initialization

-(id) init { return [self initOnRotationMatrix: [CC3LinearMatrix matrix]]; }

-(id) initOnRotationMatrix: (CC3Matrix*) aMatrix {
	if ( (self = [super init]) ) {
		_orthonormalizationStartColumnNumber = 1;
		_incrementalRotationCount = 0;
		_rotationVector = kCC3Vector4Zero;
		self.rotationMatrix = aMatrix;		// also sets rotation type
	}
	return self;
}
	
+(id) rotatorOnRotationMatrix: (CC3Matrix*) aMatrix {
	return [[[self alloc] initOnRotationMatrix: aMatrix] autorelease];
}

// Protected properties for copying
-(CC3Vector4) rotationVector { return _rotationVector; }
-(GLubyte) rotationType { return _rotationType; }
-(GLubyte) orthonormalizationStartColumnNumber { return _orthonormalizationStartColumnNumber; }
-(GLubyte) incrementalRotationCount { return _incrementalRotationCount; }

-(void) populateFrom: (CC3MutableRotator*) another {
	[super populateFrom: another];
	
	// Only populate the following if the other instance is also a mutable rotator.
	if( [another isKindOfClass:[CC3MutableRotator class]] ) {
		_rotationVector = another.rotationVector;
		_rotationType = another.rotationType;
		_orthonormalizationStartColumnNumber = another.orthonormalizationStartColumnNumber;
		_incrementalRotationCount = another.incrementalRotationCount;
	}

	[self markRotationDirty];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ with rotation: %@, quaternion: %@, rotation axis: %@, rotation angle %.3f",
			super.fullDescription,
			NSStringFromCC3Vector(self.rotation),
			NSStringFromCC3Vector4(self.quaternion),
			NSStringFromCC3Vector(self.rotationAxis),
			self.rotationAngle];
}


#pragma mark Transformations

/** Recalculates the rotation matrix from the most recently set rotation property. */
-(void) applyRotation {
	if ( !self.isRotationDirty ) return;

	switch (_rotationType) {
		case kCC3RotationTypeEuler:
			[_rotationMatrix populateFromRotation: self.rotation];
			break;
		case kCC3RotationTypeQuaternion:
		case kCC3RotationTypeAxisAngle:
			[_rotationMatrix populateFromQuaternion: self.quaternion];
			break;
		default:
			break;
	}
	[self markRotationClean];
}

// Rotation matrix is built lazily if needed
-(void) applyRotationTo: (CC3Matrix*) aMatrix { [aMatrix multiplyBy: self.rotationMatrix]; }

-(CC3Vector) transformDirection: (CC3Vector) aDirection {
	return [self.rotationMatrix transformDirection: aDirection];
}

@end


#pragma mark -
#pragma mark CC3DirectionalRotator

@implementation CC3DirectionalRotator

-(BOOL) isDirectional { return YES; }

-(BOOL) shouldReverseForwardDirection { return _shouldReverseForwardDirection; }

-(void) setShouldReverseForwardDirection: (BOOL) shouldReverse {
	_shouldReverseForwardDirection = shouldReverse;
}

-(CC3Vector) forwardDirection {
	if (_rotationType == kCC3RotationTypeDirection) {
		return _rotationVector.v;
	} else {
		CC3Vector mtxFwdDir = [self.rotationMatrix extractForwardDirection];
		return _shouldReverseForwardDirection ? CC3VectorNegate(mtxFwdDir) : mtxFwdDir;
	}
}

-(void) setForwardDirection: (CC3Vector) aDirection {
	CC3Assert(!CC3VectorsAreEqual(aDirection, kCC3VectorZero),
			 @"The forwardDirection may not be set to the zero vector.");
	_rotationVector = CC3Vector4FromDirection(CC3VectorNormalize(aDirection));
	_rotationType = kCC3RotationTypeDirection;
	[self markRotationDirty];
}

-(CC3Vector) referenceUpDirection { return _referenceUpDirection; }

/** Does not set the rotation type until the forwardDirection is set. */
-(void) setReferenceUpDirection: (CC3Vector) aDirection {
	CC3Assert(!CC3VectorsAreEqual(aDirection, kCC3VectorZero),
			 @"The referenceUpDirection may not be set to the zero vector.");
	_referenceUpDirection = CC3VectorNormalize(aDirection);
}

// Deprecated
-(CC3Vector) sceneUpDirection { return self.referenceUpDirection; }
-(void) setSceneUpDirection: (CC3Vector) aDirection { self.referenceUpDirection = aDirection; }
-(CC3Vector) worldUpDirection { return self.referenceUpDirection; }
-(void) setWorldUpDirection: (CC3Vector) aDirection { self.referenceUpDirection = aDirection; }

-(CC3Vector) upDirection { return [self.rotationMatrix extractUpDirection]; }

-(CC3Vector) rightDirection { return [self.rotationMatrix extractRightDirection]; }


#pragma mark Allocation & Initialization

-(id) initOnRotationMatrix: (CC3Matrix*) aMatrix {
	if ( (self = [super initOnRotationMatrix: aMatrix]) ) {
		_referenceUpDirection = kCC3VectorUnitYPositive;
		_shouldReverseForwardDirection = NO;
	}
	return self;
}
-(void) populateFrom: (CC3DirectionalRotator*) another {
	[super populateFrom: another];

	// Only populate the following if the other instance is also a directional rotator.
	if( [another isKindOfClass:[CC3DirectionalRotator class]] ) {
		_referenceUpDirection = another.referenceUpDirection;
		_shouldReverseForwardDirection = another.shouldReverseForwardDirection;
	}
}

// If rotation is defined by the forward direction, apply it to the matrix, taking into
// consideration whether the foward direction should be inverted. Otherwise, invoke superclass
// implementation to handle other types of rotation.
-(void) applyRotation {
	if ( !self.isRotationDirty ) return;
	
	if (_rotationType == kCC3RotationTypeDirection) {
		CC3Assert( !CC3VectorsAreParallel(self.forwardDirection, self.referenceUpDirection),
				  @"The forwardDirection %@ cannot be parallel to the referenceUpDirection %@."
				  @" To use this forwardDirection, you must choose a different referenceUpDirection.",
				  NSStringFromCC3Vector(self.forwardDirection), NSStringFromCC3Vector(self.referenceUpDirection));

		CC3Vector mtxFwdDir = _shouldReverseForwardDirection
									? CC3VectorNegate(self.forwardDirection)
									: self.forwardDirection;
		[_rotationMatrix populateToPointTowards: mtxFwdDir withUp: self.referenceUpDirection];
		[self markRotationClean];
	} else {
		[super applyRotation];
	}
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, direction: %@, up: %@, scene up: %@",
			super.fullDescription,
			NSStringFromCC3Vector(self.forwardDirection),
			NSStringFromCC3Vector(self.upDirection),
			NSStringFromCC3Vector(self.referenceUpDirection)];
}

@end


#pragma mark -
#pragma mark CC3TargettingRotator

@implementation CC3TargettingRotator
	
-(void) dealloc {
	_target = nil;		// weak reference
	[super dealloc];
}

-(BOOL) isTrackingForBumpMapping { return _isTrackingForBumpMapping; }

-(void) setIsTrackingForBumpMapping: (BOOL)  isBM { _isTrackingForBumpMapping = isBM; }

-(BOOL) shouldTrackTarget { return _shouldTrackTarget; }

-(void) setShouldTrackTarget: (BOOL) shouldTrack { _shouldTrackTarget = shouldTrack; }

-(BOOL) shouldAutotargetCamera { return _shouldAutotargetCamera; }

-(void) setShouldAutotargetCamera: (BOOL) shouldAutotarget { _shouldAutotargetCamera = shouldAutotarget; }

-(CC3TargettingConstraint) targettingConstraint { return _targettingConstraint; }

-(void) setTargettingConstraint: (CC3TargettingConstraint) targContraint { _targettingConstraint = targContraint; }

// Deprecated
-(CC3TargettingConstraint) axisRestriction { return self.targettingConstraint; }
-(void) setAxisRestriction: (CC3TargettingConstraint) axisRest { self.targettingConstraint = axisRest; }

-(BOOL) isTargettable { return YES; }

-(CC3Vector) targetLocation {
	return (_rotationType == kCC3RotationTypeLocation) ? _rotationVector.v : kCC3VectorNull;
}

-(void) setTargetLocation: (CC3Vector) aLocation {
	_rotationVector = CC3Vector4FromCC3Vector(aLocation, 0.0f);
	_rotationType = kCC3RotationTypeLocation;
	_isNewTarget = NO;		// Target is no longer new once the location of it has been set.
	[self markRotationDirty];
}

-(BOOL) isDirtyByTargetLocation { return self.isRotationDirty && (_rotationType == kCC3RotationTypeLocation); }

-(void) rotateToTargetLocation: (CC3Vector) targLoc from: (CC3Vector) eyeLoc withUp: (CC3Vector) upDir {
	if ( !CC3VectorsAreEqual(targLoc, eyeLoc) ) {
		CC3Vector mtxDir = _shouldReverseForwardDirection
								? CC3VectorDifference(eyeLoc, targLoc)
								: CC3VectorDifference(targLoc, eyeLoc);
		[_rotationMatrix populateToPointTowards: mtxDir withUp: upDir];
		[self markRotationClean];
	}
}

// Deprecated
-(void) rotateToTargetLocationFrom: (CC3Vector) aLocation {
	[self rotateToTargetLocation: self.targetLocation from: aLocation withUp: self.referenceUpDirection];
}

-(CC3Node*) target { return _target; }

/**
 * Set the new target as weak reference and mark whether it has changed.
 * Don't mark if not changed, so that a change persists even if the same target is set again.
 */
-(void) setTarget: (CC3Node*) aNode {
	if (aNode != _target) _isNewTarget = YES;
	_target = aNode;		// weak reference
}

-(BOOL) shouldUpdateToTarget { return _target && (_isNewTarget || _shouldTrackTarget); }

-(BOOL) shouldRotateToTargetLocation {
	return (self.isDirtyByTargetLocation || _shouldTrackTarget) && !_isTrackingForBumpMapping;
}

-(BOOL) isTrackingTargetDirection {
	return _shouldTrackTarget && !_isTrackingForBumpMapping && (_target != nil);
}

-(BOOL) clearIfTarget: (CC3Node*) aNode {
	if (aNode != _target) return NO;
	_target = nil;		// weak reference
	return YES;
}


#pragma mark Allocation & Initialization

-(id) initOnRotationMatrix: (CC3Matrix*) aMatrix {
	if ( (self = [super initOnRotationMatrix: aMatrix]) ) {
		_target = nil;
		_targettingConstraint = kCC3TargettingConstraintGlobalUnconstrained;
		_isNewTarget = NO;
		_shouldTrackTarget = NO;
		_shouldAutotargetCamera = NO;
		_isTrackingForBumpMapping = NO;
	}
	return self;
}

// Protected properties used for copying
-(BOOL) isNewTarget { return _isNewTarget; }

-(void) populateFrom: (CC3Rotator*) another {
	[super populateFrom: another];

	self.target = another.target;		// weak reference...not copied
	_targettingConstraint = another.targettingConstraint;
	_shouldTrackTarget = another.shouldTrackTarget;
	_shouldAutotargetCamera = another.shouldAutotargetCamera;
	_isTrackingForBumpMapping = another.isTrackingForBumpMapping;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, targetted at: %@, from target: %@",
			super.fullDescription, NSStringFromCC3Vector(self.targetLocation), _target];
}

@end


#pragma mark -
#pragma mark Deprecated CC3ReverseDirectionalRotator

@implementation CC3ReverseDirectionalRotator

-(id) initOnRotationMatrix: (CC3Matrix*) aMatrix {
	if ( (self = [super initOnRotationMatrix: aMatrix]) ) {
		_shouldReverseForwardDirection = YES;
	}
	return self;
}

@end

