/*
 * CC3Rotator.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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

-(CC3Node*) target { return nil; }

-(BOOL) shouldTrackTarget { return NO; }

-(BOOL) shouldAutotargetCamera { return NO; }

-(BOOL) shouldRotateToTargetLocation { return NO; }


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

@interface CC3MutableRotator (TemplateMethods)
-(CC3Vector4) rotationAxisAngle;
-(void) autoOrthonormalize;
-(void) applyRotation;
@end

@implementation CC3MutableRotator

-(void) dealloc {
	[_rotationMatrix release];
	[super dealloc];
}

-(BOOL) isMutable { return YES; }

-(BOOL) isDirectional { return NO; }

-(BOOL) isRotationDirty { return _isRotationDirty; }

-(void) markRotationDirty { _isRotationDirty = YES; }

-(CC3Vector) rotation {
	return (_rotationType == kCC3RotationTypeEuler)
				? CC3VectorFromTruncatedCC3Vector4(_rotationVector)
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
	_isRotationDirty = NO;
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
	_isRotationDirty = NO;
}

-(CC3Vector4) rotationAxisAngle {
	return (_rotationType == kCC3RotationTypeAxisAngle)
				? _rotationVector
				: CC3AxisAngleFromQuaternion(self.quaternion);
}

-(CC3Vector) rotationAxis { return CC3VectorFromTruncatedCC3Vector4(self.rotationAxisAngle); }

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
	_isRotationDirty = NO;
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
		self.rotationMatrix = aMatrix;
		_rotationVector = kCC3Vector4Zero;
		_rotationType = kCC3RotationTypeUnknown;
		_orthonormalizationStartColumnNumber = 1;
		_incrementalRotationCount = 0;
	}
	return self;
}

+(id) rotatorOnRotationMatrix: (CC3Matrix*) aMatrix {
	return [[[self alloc] initOnRotationMatrix: aMatrix] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	CC3Rotator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

// Protected properties for copying
-(CC3Vector4) rotationVector { return _rotationVector; }
-(GLubyte) orthonormalizationStartColumnNumber { return _orthonormalizationStartColumnNumber; }
-(GLubyte) incrementalRotationCount { return _incrementalRotationCount; }

-(void) populateFrom: (CC3Rotator*) another {
	
	// Copy matrix contents, then set matrix again to reset all dirty flags
	[_rotationMatrix populateFrom: another.rotationMatrix];
	self.rotationMatrix = self.rotationMatrix;
	
	// Only proceed with populating the following properties if the
	// other instance is also a mutable rotator.
	if( [another isKindOfClass:[CC3MutableRotator class]] ) {
		CC3MutableRotator* anotherMR = (CC3MutableRotator*)another;
		_rotationVector = anotherMR.rotationVector;
		_isRotationDirty = anotherMR.isRotationDirty;
		_orthonormalizationStartColumnNumber = anotherMR.orthonormalizationStartColumnNumber;
		_incrementalRotationCount = anotherMR.incrementalRotationCount;
	}
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
	if ( !_isRotationDirty ) return;

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
	_isRotationDirty = NO;
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
		return CC3VectorFromTruncatedCC3Vector4(_rotationVector);
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
-(void) populateFrom: (CC3Rotator*) another {
	[super populateFrom: another];

	// Only proceed with populating the directional properties if the
	// other instance is also a directional rotator.
	if( [another isKindOfClass:[CC3DirectionalRotator class]] ) {
		CC3DirectionalRotator* anotherDR = (CC3DirectionalRotator*)another;
		_referenceUpDirection = anotherDR.referenceUpDirection;
		_shouldReverseForwardDirection = anotherDR.shouldReverseForwardDirection;
	}
}

// If rotation is defined by the forward direction, apply it to the matrix, taking into
// consideration whether the foward direction should be inverted. Otherwise, invoke superclass
// implementation to handle other types of rotation.
-(void) applyRotation {
	if ( !_isRotationDirty ) return;
	
	if (_rotationType == kCC3RotationTypeDirection) {
		CC3Vector mtxFwdDir = _shouldReverseForwardDirection
									? CC3VectorNegate(self.forwardDirection)
									: self.forwardDirection;
		[_rotationMatrix populateToPointTowards: mtxFwdDir withUp: self.referenceUpDirection];
		_isRotationDirty = NO;
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

@interface CC3TargettingRotator (TemplateMethods)
@property(nonatomic, readonly) BOOL isDirtyByTargetLocation;
@end

@implementation CC3TargettingRotator

-(void) dealloc {
	_target = nil;			// not retained
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
	return (_rotationType == kCC3RotationTypeLocation)
				? CC3VectorFromTruncatedCC3Vector4(_rotationVector)
				: kCC3VectorNull;
}

-(void) setTargetLocation: (CC3Vector) aLocation {
	_rotationVector = CC3Vector4FromCC3Vector(aLocation, 0.0f);
	_rotationType = kCC3RotationTypeLocation;
	_isNewTarget = NO;		// Target is no longer new once the location of it has been set.
	[self markRotationDirty];
}

-(BOOL) isDirtyByTargetLocation { return _isRotationDirty && (_rotationType == kCC3RotationTypeLocation); }

-(void) rotateToTargetLocation: (CC3Vector) targLoc from: (CC3Vector) eyeLoc withUp: (CC3Vector) upDir {
	if ( !CC3VectorsAreEqual(targLoc, eyeLoc) ) {
		CC3Vector mtxDir = _shouldReverseForwardDirection
								? CC3VectorDifference(eyeLoc, targLoc)
								: CC3VectorDifference(targLoc, eyeLoc);
		[_rotationMatrix populateToPointTowards: mtxDir withUp: upDir];
		_isRotationDirty = NO;
	}
}

// Deprecated
-(void) rotateToTargetLocationFrom: (CC3Vector) aLocation {
	[self rotateToTargetLocation: self.targetLocation from: aLocation withUp: self.referenceUpDirection];
}

-(CC3Node*) target { return _target; }

/**
 * Set the new target as weak line and mark if it has changed.
 * Don't mark if not changed, so that a change persists even if the same target is set again.
 */
-(void) setTarget: (CC3Node*) aNode {
	if (aNode != _target) _isNewTarget = YES;
	_target = aNode;
}

-(BOOL) shouldUpdateToTarget { return _target && (_isNewTarget || _shouldTrackTarget); }

-(BOOL) shouldRotateToTargetLocation {
	return (self.isDirtyByTargetLocation || _shouldTrackTarget) && !_isTrackingForBumpMapping;
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
	
	// Only proceed with populating the directional properties if the
	// other instance is also a targetting rotator.
	if( [another isKindOfClass:[CC3TargettingRotator class]] ) {
		self.target = another.target;		// weak link...not copied
		CC3TargettingRotator* anotherTR = (CC3TargettingRotator*)another;
		_targettingConstraint = anotherTR.targettingConstraint;
		_isNewTarget = anotherTR.isNewTarget;
		_shouldTrackTarget = anotherTR.shouldTrackTarget;
		_shouldAutotargetCamera = anotherTR.shouldAutotargetCamera;
		_isTrackingForBumpMapping = anotherTR.isTrackingForBumpMapping;
	}
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

