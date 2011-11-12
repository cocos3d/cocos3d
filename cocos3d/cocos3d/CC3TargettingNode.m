/*
 * CC3TargettingNode.m
 *
 * cocos3d 0.6.3
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3TargettingNode.h for full API documentation.
 */

#import "CC3TargettingNode.h"

@interface CC3Node (TemplateMethods)
-(void) applyRotation;
-(void) updateGlobalLocation;
-(void) populateFrom: (CC3Node*) another;
@property(nonatomic, readonly) CC3GLMatrix* globalRotationMatrix;
@end

@interface CC3TargettingNode (TemplateMethods)
-(void) applyTargetLocation;
-(void) applyTargetDirectionRotation;
-(CC3Vector) rotationallyRestrictTargetLocation: (CC3Vector) aLocation;
-(void) resetTargetTrackingState;
@property(nonatomic, readonly) BOOL isNewTarget;
@property(nonatomic, readonly) BOOL isTargetLocationDirty;
@property(nonatomic, readonly) BOOL isRotatorDirtyByTargetLocation;
@property(nonatomic, readonly) BOOL shouldRotateToTarget;
@property(nonatomic, readonly) BOOL shouldRotateToTargetLocation;
@end

@implementation CC3TargettingNode

@synthesize target, targetLocation, shouldTrackTarget, axisRestriction;

-(void) dealloc {
	[target release];
	[super dealloc];
}

-(void) setTarget:(CC3Node *) aNode {
	CC3Node* oldTarget = target;
	target = [aNode retain];
	isNewTarget = (target != oldTarget);
	[oldTarget release];
}

// Set the location anyway...and mark target location dirty if not set to track
-(void) setLocation: (CC3Vector) aLocation {
	[super setLocation: aLocation];
	if (!shouldTrackTarget) {
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(void) setRotation: (CC3Vector) aRotation {
	if (!shouldTrackTarget) {
		[super setRotation: aRotation];
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(void) rotateBy: (CC3Vector) aRotation {
	if (!shouldTrackTarget) {
		[super rotateBy: aRotation];
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(void) setQuaternion: (CC3Vector4) aQuaternion {
	if (!shouldTrackTarget) {
		[super setQuaternion: aQuaternion];
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(void) rotateByQuaternion: (CC3Vector4) aQuaternion {
	if (!shouldTrackTarget) {
		[super rotateByQuaternion: aQuaternion];
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(void) setRotationAxis: (CC3Vector) aDirection {
	if (!shouldTrackTarget) {
		[super setRotationAxis: aDirection];
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(GLfloat) rotationAngle {
	return rotator.rotationAngle;
}

-(void) setRotationAngle: (GLfloat) anAngle {
	if (!shouldTrackTarget) {
		[super setRotationAngle: anAngle];
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	if (!shouldTrackTarget) {
		[super rotateByAngle: anAngle aroundAxis: anAxis];
		isTargetLocationDirty = YES;
		isRotatorDirtyByTargetLocation = NO;
	}
}

-(CC3Vector) targetLocation {
	if (isTargetLocationDirty) {
		CC3Vector gLoc = self.globalLocation;
		// To avoid rounding errors when adding wildly different values, scale the forward 
		// direction (which is normalized so all components are < 1) to values that are roughly
		// compatible with the size of the global location of this node. This is done by using
		// simply totaling positive X + Y + Z of global location, and ensuring it is not zero.
		GLfloat dirScale = MAX(ABS(gLoc.x) + ABS(gLoc.y) + ABS(gLoc.z), 1.0f);
		CC3Vector fwdDir = self.forwardDirection;
		CC3Vector scaledDir = CC3VectorScaleUniform(fwdDir, dirScale);
		targetLocation = CC3VectorAdd(gLoc, scaledDir);
		isTargetLocationDirty = NO;
		LogTrace(@"%@ calculating target location from global location: %@, forward dir: %@, dir scale: %.2f, scaled dir: %@, target location: %@",
				 self, NSStringFromCC3Vector(gLoc), NSStringFromCC3Vector(fwdDir), dirScale,
				 NSStringFromCC3Vector(scaledDir), NSStringFromCC3Vector(targetLocation));
	}
	return targetLocation;
}

/**
 * The new target location cannot be applied immediately, because the direction to
 * the target depends on the transformed global location of both this node
 * and the target location. Remember that it was set.
 */
-(void) setTargetLocation: (CC3Vector) aLocation {
	targetLocation = [self rotationallyRestrictTargetLocation: aLocation];
	isTargetLocationDirty = NO;
	[self markTransformDirty];
	isRotatorDirtyByTargetLocation = YES;
}

/**
 * If the value of the axisRestriction property is set to one of kCC3TargettingAxisRestrictionXAxis, 
 * kCC3TargettingAxisRestrictionYAxis or kCC3TargettingAxisRestrictionZAxis, the value of the
 * corresponding component of the specified location will be set to the value of that component
 * from the globalLocation of this node. The result is that rotation will be restricted to only
 * that axis. For example, by setting the axisRestriction property to kCC3TargettingAxisRestrictionYAxis,
 * the Y-component of the specified location will be set to the Y-component of the globalLocation
 * of this targetting node.
 */
-(CC3Vector) rotationallyRestrictTargetLocation: (CC3Vector) aLocation {
	switch (axisRestriction) {
		case kCC3TargettingAxisRestrictionXAxis:
			aLocation.x = self.globalLocation.x;
			break;
		case kCC3TargettingAxisRestrictionYAxis:
			aLocation.y = self.globalLocation.y;
			break;
		case kCC3TargettingAxisRestrictionZAxis:
			aLocation.z = self.globalLocation.z;
			break;
		default:
			break;
	}
	return aLocation;
}

-(CC3Vector) forwardDirection {
	return ((CC3DirectionalRotator*)rotator).forwardDirection;
}

-(CC3Vector) globalForwardDirection {
	return [self.globalRotationMatrix extractForwardDirection];
}

-(void) setForwardDirection: (CC3Vector) aDirection {
	if (!shouldTrackTarget) {
		((CC3DirectionalRotator*)rotator).forwardDirection = aDirection;
		isRotatorDirtyByTargetLocation = NO;
		[self markTransformDirty];
	}
}

-(CC3Vector) upDirection {
	return ((CC3DirectionalRotator*)rotator).upDirection;
}

-(CC3Vector) globalUpDirection {
	return [self.globalRotationMatrix extractUpDirection];
}

-(CC3Vector) worldUpDirection {
	return ((CC3DirectionalRotator*)rotator).worldUpDirection;
}

-(void) setWorldUpDirection: (CC3Vector) aDirection {
	((CC3DirectionalRotator*)rotator).worldUpDirection = aDirection;
	[self markTransformDirty];
}

-(CC3Vector) rightDirection {
	return ((CC3DirectionalRotator*)rotator).rightDirection;
}

-(CC3Vector) globalRightDirection {
	return [self.globalRotationMatrix extractRightDirection];
}

-(BOOL) shouldAutotargetCamera {
	return shouldAutotargetCamera;
}

-(void) setShouldAutotargetCamera: (BOOL) shouldAutotarg {
	shouldAutotargetCamera = shouldAutotarg;
	self.shouldTrackTarget = shouldAutotarg;
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		target = nil;
		targetLocation = kCC3VectorZero;
		axisRestriction = kCC3TargettingAxisRestrictionNone;
		isNewTarget = NO;
		shouldTrackTarget = NO;
		shouldAutotargetCamera = NO;
		isTargetLocationDirty = NO;
		isRotatorDirtyByTargetLocation = NO;
		wasGlobalLocationChanged = NO;
	}
	return self;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, targetted at: %@, from target: %@",
			[super fullDescription], NSStringFromCC3Vector(targetLocation), target];
}

-(id) rotatorClass {
	return [CC3DirectionalRotator class];
}

// Protected properties for copying
-(BOOL) isNewTarget { return isNewTarget; }
-(BOOL) isTargetLocationDirty { return isTargetLocationDirty; }
-(BOOL) isRotatorDirtyByTargetLocation { return isRotatorDirtyByTargetLocation; }
-(BOOL) wasGlobalLocationChanged { return wasGlobalLocationChanged; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3TargettingNode*) another {
	[super populateFrom: another];
	
	[target release];
	target = [another.target retain];			// retained...not copied

	targetLocation = another.targetLocation;
	axisRestriction = another.axisRestriction;
	isNewTarget = another.isNewTarget;
	shouldTrackTarget = another.shouldTrackTarget;
	shouldAutotargetCamera = another.shouldAutotargetCamera;
	isTargetLocationDirty = another.isTargetLocationDirty;
	isRotatorDirtyByTargetLocation = another.isRotatorDirtyByTargetLocation;
	wasGlobalLocationChanged = another.wasGlobalLocationChanged;
}


#pragma mark Updating

-(void) trackTargetWithVisitor: (CC3NodeTransformingVisitor*) visitor {
	if (self.shouldRotateToTarget) {
		self.targetLocation = target.globalLocation;
		[visitor visit: self];		// Recalculate transforms
		LogTrace(@"%@ tracking adjusted to target", [self fullDescription]);
	}
	[self resetTargetTrackingState];
}

/**
 * Returns whether this node should rotate to face the target. It will do so if:
 *   - target exists, AND
 *   - the target has just been set OR shouldTrackTarget is YES, AND
 *   - either the global location of this node or the target node has changed
 */
-(BOOL) shouldRotateToTarget {
	return target && (isNewTarget || shouldTrackTarget)
				&& (wasGlobalLocationChanged || !CC3VectorsAreEqual(self.targetLocation, target.globalLocation));
}


#pragma mark Transformations

/** Keeps track of whether the globalLocation is changed by this method. */
-(void) updateGlobalLocation {
	CC3Vector oldGlobLoc = globalLocation;
	[super updateGlobalLocation];
	wasGlobalLocationChanged = !CC3VectorsAreEqual(globalLocation, oldGlobLoc);
}

/**
 * Target location can only be applied once translation is complete, because the
 * direction to the target depends on the transformed global location of both this
 * node and the target location.
 */
-(void) applyRotation {
	if (self.shouldRotateToTargetLocation) {
		[self applyTargetLocation];
		[self applyTargetDirectionRotation];
		isRotatorDirtyByTargetLocation = NO;
	} else {
		[super applyRotation];
	}
}

/**
 * Template method to update the rotator transform from the targetLocation
 * and the globalLocation.
 *
 * Only update the rotation transform if the targetLocation was changed, or this
 * node has moved. But don't update if the target location is the same as the
 * globalLocation of this node (which makes the direction to point undefined).
 */
-(void) applyTargetLocation {
	CC3Vector targLoc = self.targetLocation;
	CC3Vector globLoc = self.globalLocation;
	if ((isRotatorDirtyByTargetLocation || wasGlobalLocationChanged) 
			&& !CC3VectorsAreEqual(targLoc, globLoc)) {
		((CC3DirectionalRotator*)rotator).forwardDirection = CC3VectorDifference(targLoc, globLoc);
	}
}

/**
 * Applies the target location rotation using the forward direction.
 *
 * Since we want to target a global direction, we must ignore the rotation
 * of all ancestor nodes. The transformMatrix is rebuilt using the globalLocation
 * (which was calculated during the location transform), and then the global
 * rotation is applied by the rotator. Finally, the ancestor scale is applied.
 */
-(void) applyTargetDirectionRotation {
	[transformMatrix populateIdentity];
	[transformMatrix translateBy: self.globalLocation];
	[super applyRotation];
	if (parent) {
		[transformMatrix scaleBy: parent.globalScale];
	}
}

/**
 * Returns whether this node should rotate to face the targetLocation.
 * It will do so if targetDirection was just set, or shouldTrackTarget is YES.
 */
-(BOOL) shouldRotateToTargetLocation {
	return isRotatorDirtyByTargetLocation || shouldTrackTarget;
}

/**
 * Resets the internal indicators of whether the target or this instance has moved
 * and therefore the targetLocation needs updating.
 */
-(void) resetTargetTrackingState {
	isNewTarget = NO;
	wasGlobalLocationChanged = NO;
}

@end


#pragma mark -
#pragma mark CC3DirectionalRotator

@interface CC3Rotator (TemplateMethods)
-(void) applyRotation;
-(void) populateFrom: (CC3Rotator*) another;
@end

@interface CC3DirectionalRotator (TemplateMethods)
-(void) ensureForwardDirectionFromMatrix;
-(void) ensureUpDirectionFromMatrix;
-(void) ensureRightDirectionFromMatrix;
@property(nonatomic, readonly) BOOL isForwardDirectionDirty;
@property(nonatomic, readonly) BOOL isUpDirectionDirty;
@property(nonatomic, readonly) BOOL isRightDirectionDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByDirection;
@end


@implementation CC3DirectionalRotator

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
	
	matrixIsDirtyBy = kCC3MatrixIsDirtyByDirection;
}

-(CC3Vector) upDirection {
	[self ensureUpDirectionFromMatrix];
	return upDirection;
}

-(CC3Vector) worldUpDirection {
	return worldUpDirection;
}

-(void) setWorldUpDirection: (CC3Vector) aDirection {
	NSAssert(!CC3VectorsAreEqual(aDirection, kCC3VectorZero),
			 @"The worldUpDirection may not be set to the zero vector.");
	
	worldUpDirection = CC3VectorNormalize(aDirection);
	
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	isForwardDirectionDirty = NO;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	
	matrixIsDirtyBy = kCC3MatrixIsDirtyByDirection;
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
}

-(void) rotateBy: (CC3Vector) aRotation {
	[super rotateBy: aRotation];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
}

-(void) setQuaternion:(CC3Vector4) aQuaternion {
	[super setQuaternion: aQuaternion];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
}

-(void) rotateByQuaternion: (CC3Vector4) aQuaternion {
	[super rotateByQuaternion: aQuaternion];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
}

-(void) setRotationMatrix:(CC3GLMatrix*) aGLMatrix {
	[super setRotationMatrix: aGLMatrix];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
}

-(id) initOnRotationMatrix: (CC3GLMatrix*) aGLMatrix {
	if ( (self = [super initOnRotationMatrix: aGLMatrix]) ) {
		forwardDirection = kCC3VectorInitialForwardDirection;
		upDirection = kCC3VectorInitialUpDirection;
		worldUpDirection = kCC3VectorInitialUpDirection;
		rightDirection = kCC3VectorInitialRightDirection;
		isForwardDirectionDirty = NO;
		isUpDirectionDirty = NO;
		isRightDirectionDirty = NO;
	}
	return self;
}

// Protected properties for copying
-(BOOL) isForwardDirectionDirty { return isForwardDirectionDirty; }
-(BOOL) isUpDirectionDirty { return isUpDirectionDirty; }
-(BOOL) isRightDirectionDirty { return isRightDirectionDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3DirectionalRotator*) another {
	[super populateFrom: another];

	forwardDirection = another.forwardDirection;
	worldUpDirection = another.worldUpDirection;
	upDirection = another.upDirection;
	rightDirection = another.rightDirection;
	isForwardDirectionDirty = another.isForwardDirectionDirty;
	isUpDirectionDirty = another.isUpDirectionDirty;
	isRightDirectionDirty = another.isRightDirectionDirty;
}

/**
 * If needed, extracts and sets the forwardDirection from the encapsulated rotation
 * matrix. This method is invoked automatically when accessing the forwardDirection
 * property, if that property is not current (ie- if the rotation was most recently
 * set with Euler angles or a quaternion).
 */
-(void) ensureForwardDirectionFromMatrix {
	if (isForwardDirectionDirty) {
		forwardDirection = [self.rotationMatrix extractForwardDirection];
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
 * If needed, extracts and sets the rightDirection from the encapsulated rotation matrix.
 * This method is invoked automatically when accessing the rightDirection property,
 * if that property is not current (ie- if the rotation was most recently set with
 * Euler angles or a quaternion).
 */
-(void) ensureRightDirectionFromMatrix {
	if (isRightDirectionDirty) {
		rightDirection = [self.rotationMatrix extractRightDirection];
		isRightDirectionDirty = NO;
	}
}

-(void) applyRotation {
	[super applyRotation];
	if (matrixIsDirtyBy == kCC3MatrixIsDirtyByDirection) {
		[rotationMatrix populateToPointTowards: forwardDirection withUp: worldUpDirection];
		matrixIsDirtyBy = kCC3MatrixIsNotDirty;
	}
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@, direction: %@, up: %@, world up: %@",
			[super description],
			NSStringFromCC3Vector(self.forwardDirection),
			NSStringFromCC3Vector(self.upDirection),
			NSStringFromCC3Vector(self.worldUpDirection)];
}

@end


#pragma mark -
#pragma mark CC3LightTracker

@implementation CC3LightTracker

-(void) trackTargetWithVisitor: (CC3NodeTransformingVisitor*) visitor {
	if (target && (isNewTarget || shouldTrackTarget)) {
		self.globalLightLocation = target.globalLocation;
		LogTrace(@"%@ tracking adjusted to target", [self fullDescription]);
	}
	[self resetTargetTrackingState];
}

@end


#pragma mark -
#pragma mark CC3Node extension

@implementation CC3Node (CC3TargettingNode)

-(CC3TargettingNode*) asTargettingNode {
	CC3TargettingNode* tn = [CC3TargettingNode nodeWithName: [NSString stringWithFormat: @"%@-TargettingWrapper", self.name]];
	tn.shouldAutoremoveWhenEmpty = YES;
	[tn addChild: self];
	return tn;
}

-(CC3TargettingNode*) asTracker {
	CC3TargettingNode* tn = [self asTargettingNode];
	tn.shouldTrackTarget = YES;
	return tn;
}

-(CC3TargettingNode*) asCameraTracker {
	CC3TargettingNode* tn = [self asTracker];
	tn.shouldAutotargetCamera = YES;
	return tn;
}

-(CC3TargettingNode*) asLightTracker {
	CC3TargettingNode* tn = [CC3LightTracker nodeWithName: [NSString stringWithFormat: @"%@-LightTrackerWrapper", self.name]];
	tn.shouldAutoremoveWhenEmpty = YES;
	tn.shouldTrackTarget = YES;
	[tn addChild: self];
	return tn;
}

@end
