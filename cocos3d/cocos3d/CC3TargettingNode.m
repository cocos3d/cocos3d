/*
 * CC3TargettingNode.m
 *
 * cocos3d 0.6.0-sp
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
-(void) updateTransformMatrices;
-(void) populateFrom: (CC3Node*) another;
@property(nonatomic, readonly) CC3GLMatrix* globalRotationMatrix;
@end

@interface CC3TargettingNode (TemplateMethods)
-(CC3Vector) rotationallyRestrictTargetLocation: (CC3Vector) aLocation;
@property(nonatomic, readonly) BOOL isNewTarget;
@property(nonatomic, readonly) BOOL isTargetLocationDirty;
@property(nonatomic, readonly) BOOL isRotatorDirtyByTargetLocation;
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

-(void) setLocation: (CC3Vector) aLocation {
	[super setLocation: aLocation];
	isTargetLocationDirty = YES;
}

-(void) setRotation: (CC3Vector) aRotation {
	if (!shouldTrackTarget) {
		[super setRotation: aRotation];
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

-(void) setTargetLocation: (CC3Vector) aLocation {
	targetLocation = [self rotationallyRestrictTargetLocation: aLocation];
	isTargetLocationDirty = NO;
	[self markTransformDirty];
	// Target location cannot be applied immediately, because the direction to the target depends on
	// the transformed global location of both this node and the target node. Remember that it was set.
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


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		target = nil;
		targetLocation = kCC3VectorZero;
		axisRestriction = kCC3TargettingAxisRestrictionNone;
		isNewTarget = NO;
		shouldTrackTarget = NO;
		isTargetLocationDirty = NO;
		isRotatorDirtyByTargetLocation = NO;
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
	isTargetLocationDirty = another.isTargetLocationDirty;
	isRotatorDirtyByTargetLocation = another.isRotatorDirtyByTargetLocation;
}


#pragma mark Updating

-(void) trackTarget {
	if (target && (isNewTarget || shouldTrackTarget) && !CC3VectorsAreEqual(self.targetLocation, target.globalLocation)) {
		self.targetLocation = target.globalLocation;
		// Recalculate the transforms of this node and all descendants.
		[self updateTransformMatrices];
		LogTrace(@"%@ tracking adjusted to target", [self fullDescription]);
	}
	isNewTarget = NO;
}


#pragma mark Transformations

-(void) applyRotation {
	// Target location can only be applied once translation is complete, because the direction to the
	// target depends on the transformed global location of both this node and the target node.
	if (isRotatorDirtyByTargetLocation) {
		((CC3DirectionalRotator*)rotator).forwardDirection = CC3VectorDifference(self.targetLocation, self.globalLocation);
		isRotatorDirtyByTargetLocation = NO;
	}
	[super applyRotation];
}

@end


#pragma mark -
#pragma mark CC3DirectionalRotator

@interface CC3Rotator (TemplateMethods)
-(void) applyRotation;
-(void) populateFrom: (CC3Rotator*) another;
@end

@interface CC3DirectionalRotator (TemplateMethods)
-(CC3Vector) extractForwardDirectionFromMatrix;
-(CC3Vector) extractUpDirectionFromMatrix;
-(CC3Vector) extractRightDirectionFromMatrix;
@property(nonatomic, readonly) BOOL isForwardDirectionDirty;
@property(nonatomic, readonly) BOOL isUpDirectionDirty;
@property(nonatomic, readonly) BOOL isRightDirectionDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByDirection;
@end


@implementation CC3DirectionalRotator

-(CC3Vector) forwardDirection {
	if (isForwardDirectionDirty) {
		forwardDirection = [self extractForwardDirectionFromMatrix];
		isForwardDirectionDirty = NO;
	}
	return forwardDirection;
}

-(void) setForwardDirection: (CC3Vector) aDirection {
	forwardDirection = CC3VectorNormalize(aDirection);

	isRotationDirty = YES;
	isQuaternionDirty = YES;
	isForwardDirectionDirty = NO;
	isUpDirectionDirty = NO;
	isRightDirectionDirty = NO;

	isMatrixDirtyByRotation = NO;
	isMatrixDirtyByQuaternion = NO;
	isMatrixDirtyByDirection = YES;
}

-(CC3Vector) upDirection {
	if (isUpDirectionDirty) {
		upDirection = [self extractUpDirectionFromMatrix];
		isUpDirectionDirty = NO;
	}
	return upDirection;
}

-(CC3Vector) worldUpDirection {
	return worldUpDirection;
}

-(void) setWorldUpDirection: (CC3Vector) aDirection {
	worldUpDirection = CC3VectorNormalize(aDirection);
	
	isRotationDirty = YES;
	isQuaternionDirty = YES;
	isForwardDirectionDirty = NO;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	
	isMatrixDirtyByRotation = NO;
	isMatrixDirtyByQuaternion = NO;
	isMatrixDirtyByDirection = YES;
}

-(CC3Vector) rightDirection {
	if (isRightDirectionDirty) {
		rightDirection = [self extractRightDirectionFromMatrix];
		isRightDirectionDirty = NO;
	}
	return rightDirection;
}

-(void) setRotation:(CC3Vector) aRotation {
	[super setRotation: aRotation];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isMatrixDirtyByDirection = NO;
}

-(void) setQuaternion:(CC3Vector4) aQuaternion {
	[super setQuaternion: aQuaternion];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isMatrixDirtyByDirection = NO;
}

-(void) setRotationMatrix:(CC3GLMatrix*) aGLMatrix {
	[super setRotationMatrix: aGLMatrix];
	isForwardDirectionDirty = YES;
	isUpDirectionDirty = YES;
	isRightDirectionDirty = YES;
	isMatrixDirtyByDirection = NO;
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
		isMatrixDirtyByDirection = NO;
	}
	return self;
}

// Protected properties for copying
-(BOOL) isForwardDirectionDirty { return isForwardDirectionDirty; }
-(BOOL) isUpDirectionDirty { return isUpDirectionDirty; }
-(BOOL) isRightDirectionDirty { return isRightDirectionDirty; }
-(BOOL) isMatrixDirtyByDirection { return isMatrixDirtyByDirection; }

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
	isMatrixDirtyByDirection = another.isMatrixDirtyByDirection;
}

/**
 * Extracts and returns a forwardDirection from the encapsulated rotation
 * matrix. This method is invoked automatically when accessing the forwardDirection
 * property, if that property is not current (ie- if the rotation was most recently
 * set with Euler angles or a quaternion).
 */
-(CC3Vector) extractForwardDirectionFromMatrix {
	return [self.rotationMatrix extractForwardDirection];
}

/**
 * Extracts and returns an upDirection from the encapsulated rotation matrix.
 * This method is invoked automatically when accessing the upDirection property,
 * if that property is not current (ie- if the rotation was most recently set with
 * Euler angles or a quaternion).
 */
-(CC3Vector) extractUpDirectionFromMatrix {
	return [self.rotationMatrix extractUpDirection];
}

/**
 * Extracts and returns an rightDirection from the encapsulated rotation matrix.
 * This method is invoked automatically when accessing the rightDirection property,
 * if that property is not current (ie- if the rotation was most recently set with
 * Euler angles or a quaternion).
 */
-(CC3Vector) extractRightDirectionFromMatrix {
	return [self.rotationMatrix extractRightDirection];
}

-(void) applyRotation {
	[super applyRotation];
	if (isMatrixDirtyByDirection) {
		// TODO: This may not work if the camera is attached to an object that is itself rotating.
		//       Directing works in the global frame, not the local, and will ignore parent
		//       rotation. Subsequent extractions of the rotation and quaternion from the
		//       rotation matrix will thus be relative to the global frame, not the parent.
		//       The worldUpDirection should also probably rotate with the parent.
		[rotationMatrix populateToPointTowards: forwardDirection withUp: worldUpDirection];
		isUpDirectionDirty = YES;
		isRightDirectionDirty = YES;
		isMatrixDirtyByDirection = NO;
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

-(void) trackTarget {
	if (target && (isNewTarget || shouldTrackTarget)) {
		self.globalLightLocation = target.globalLocation;
		LogTrace(@"%@ tracking adjusted to target", [self fullDescription]);
	}
	isNewTarget = NO;
}

@end