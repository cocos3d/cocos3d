/**
 * CC3Node.m
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
 * See header file CC3Node.h for full API documentation.
 */

#import "CC3Scene.h"
#import "CC3BoundingVolumes.h"
#import "CC3NodeAnimation.h"
#import "CC3Billboard.h"
#import "CC3OpenGLFoundation.h"
#import "CCActionManager.h"
#import "CCLabelTTF.h"
#import "CGPointExtension.h"
#import "CC3ShadowVolumes.h"
#import "CC3AffineMatrix.h"
#import "CC3LinearMatrix.h"
#import "CC3CC2Extensions.h"
#import "CC3Texture.h"


#pragma mark CC3Node

@interface CC3Node (Animation_Private)
-(void) updateFromAnimationState;
@end


@implementation CC3Node

@synthesize parent=_parent, children=_children;
@synthesize rotator=_rotator, location=_location, scale=_scale;
@synthesize projectedLocation=_projectedLocation, visible=_visible;
@synthesize boundingVolume=_boundingVolume, boundingVolumePadding=_boundingVolumePadding;
@synthesize shouldInheritTouchability=_shouldInheritTouchability;
@synthesize shouldAllowTouchableWhenInvisible=_shouldAllowTouchableWhenInvisible;
@synthesize shouldAutoremoveWhenEmpty=_shouldAutoremoveWhenEmpty;
@synthesize shouldUseFixedBoundingVolume=_shouldUseFixedBoundingVolume;
@synthesize shouldStopActionsWhenRemoved=_shouldStopActionsWhenRemoved;
@synthesize cameraDistanceProduct=_cameraDistanceProduct;
@synthesize isRunning=_isRunning;

-(void) dealloc {
	self.target = nil;							// Removes myself as listener
	[self removeAllChildren];					// Also releases & nils the _children array
	[self notifyDestructionListeners];			// Must do before releasing listeners.
	
	_parent = nil;								// weak reference
	[_globalTransformMatrix release];
	[_globalTransformMatrixInverted release];
	[_globalRotationMatrix release];
	[_rotator release];
	[_boundingVolume release];
	[_animationStates release];
	[_transformListeners release];
	
	[super dealloc];
}

// If tracking target, set the location anyway
-(void) setLocation: (CC3Vector) aLocation {
	_location = aLocation;
	[self markTransformDirty];
}

// Use parent to transform local location. Don't use this node, as globalLocation
// can be referenced while building self.globalTransformMatrix.
-(CC3Vector) globalLocation {
	return [self.parent.globalTransformMatrix transformLocation: self.location];
}

-(CC3Vector4) globalHomogeneousPosition { return CC3Vector4FromLocation(self.globalLocation); }

-(void) translateBy: (CC3Vector) aVector { self.location = CC3VectorAdd(self.location, aVector); }

-(CC3Vector) rotation { return _rotator.rotation; }

-(void) setRotation: (CC3Vector) aRotation {
	if (self.isTrackingTargetDirection || CC3VectorsAreEqual(aRotation, self.rotation) ) return;

	self.mutableRotator.rotation = aRotation;
	[self markTransformDirty];
}

-(CC3Vector) globalRotation { return [self.globalRotationMatrix extractRotation]; }

-(void) rotateBy: (CC3Vector) aRotation {
	if (self.isTrackingTargetDirection) return;

	[self.mutableRotator rotateBy: aRotation];
	[self markTransformDirty];
}

-(CC3Quaternion) quaternion { return _rotator.quaternion; }

-(void) setQuaternion: (CC3Quaternion) aQuaternion {
	if (self.isTrackingTargetDirection || CC3QuaternionsAreEqual(aQuaternion, self.quaternion) ) return;

	self.mutableRotator.quaternion = aQuaternion;
	[self markTransformDirty];
}

-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion {
	if (self.isTrackingTargetDirection) return;

	[self.mutableRotator rotateByQuaternion: aQuaternion];
	[self markTransformDirty];
}

-(CC3Vector) rotationAxis { return _rotator.rotationAxis; }

-(void) setRotationAxis: (CC3Vector) aDirection {
	if (self.isTrackingTargetDirection || CC3VectorsAreEqual(aDirection, self.rotationAxis) ) return;

	self.mutableRotator.rotationAxis = aDirection;
	[self markTransformDirty];
}

-(GLfloat) rotationAngle { return _rotator.rotationAngle; }

-(void) setRotationAngle: (GLfloat) anAngle {
	if (self.isTrackingTargetDirection || (anAngle == self.rotationAngle)) return;

	self.mutableRotator.rotationAngle = anAngle;
	[self markTransformDirty];
}

-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	if (self.isTrackingTargetDirection) return;

	[self.mutableRotator rotateByAngle: anAngle aroundAxis: anAxis];
	[self markTransformDirty];
}

-(CC3Vector) forwardDirection { return self.directionalRotator.forwardDirection; }

-(void) setForwardDirection: (CC3Vector) aDirection {
	if (self.isTrackingTargetDirection) return;

	self.directionalRotator.forwardDirection = aDirection;
	[self markTransformDirty];
}

-(CC3Vector) globalForwardDirection { return [self.globalRotationMatrix extractForwardDirection]; }

-(CC3Vector) upDirection { return self.directionalRotator.upDirection; }

-(CC3Vector) globalUpDirection { return [self.globalRotationMatrix extractUpDirection]; }

-(CC3Vector) referenceUpDirection { return self.directionalRotator.referenceUpDirection; }

-(void) setReferenceUpDirection: (CC3Vector) aDirection {
	self.directionalRotator.referenceUpDirection = aDirection;
	[self markTransformDirty];
}

// Deprecated
-(CC3Vector) sceneUpDirection { return self.referenceUpDirection; }
-(void) setSceneUpDirection: (CC3Vector) aDirection { self.referenceUpDirection = aDirection; }
-(CC3Vector) worldUpDirection { return self.referenceUpDirection; }
-(void) setWorldUpDirection: (CC3Vector) aDirection { self.referenceUpDirection = aDirection; }

-(CC3Vector) rightDirection { return self.directionalRotator.rightDirection; }

-(CC3Vector) globalRightDirection { return [self.globalRotationMatrix extractRightDirection]; }

-(void) setScale: (CC3Vector) aScale {
	_scale = aScale;
	[self markTransformDirty];
}

-(GLfloat) uniformScale {
	return (self.isUniformlyScaledLocally)
					? _scale.x 
					: CC3VectorLength(_scale) / kCC3VectorUnitCubeLength;
}

-(void) setUniformScale:(GLfloat) aValue { self.scale = cc3v(aValue, aValue, aValue); }

-(BOOL) isUniformlyScaledLocally { return (_scale.x == _scale.y) && (_scale.x == _scale.z); }

-(CC3Vector) globalScale { return _parent ? CC3VectorScale(_parent.globalScale, _scale) : _scale; }

-(BOOL) isUniformlyScaledGlobally {
	return self.isUniformlyScaledLocally && (_parent ? _parent.isUniformlyScaledGlobally : YES);
}

-(BOOL) isTransformRigid { return self.globalTransformMatrix.isRigid; }

// Deprecated property
-(GLfloat) scaleTolerance { return 0.0f; }
-(void) setScaleTolerance: (GLfloat) aTolerance {}
+(GLfloat) defaultScaleTolerance { return 0.0f; }
+(void) setDefaultScaleTolerance: (GLfloat) aTolerance {}

// Derived from projected location, but only if in front of the camera
-(CGPoint) projectedPosition {
	return (_projectedLocation.z > 0.0)
				? ccp(_projectedLocation.x, _projectedLocation.y)
				: ccp(-kCC3MaxGLfloat, -kCC3MaxGLfloat);
}

-(void) setIsRunning: (BOOL) shouldRun {
	if (!_isRunning && shouldRun) [self resumeAllActions];
	if (_isRunning && !shouldRun) [self pauseAllActions];
	_isRunning = shouldRun;
	for (CC3Node* child in _children) child.isRunning = _isRunning;
}


#pragma mark Targetting

-(CC3Vector) targetLocation {
	CC3Vector targLoc = _rotator.targetLocation;
	return CC3VectorIsNull(targLoc) ? CC3VectorAdd(self.globalLocation, self.forwardDirection) : targLoc;
}

/** Apply any rotational axis restrictions to the target location before setting it. */
-(void) setTargetLocation: (CC3Vector) aLocation {
	self.targettingRotator.targetLocation = aLocation;
	[self markTransformDirty];
}

-(CC3Node*) target { return _rotator.target; }

/** Set the new target and notify that I am now tracking a target. */
-(void) setTarget: (CC3Node*) aNode {
	if (aNode == self.target) return;

	[self.target removeTransformListener: self];
	self.targettingRotator.target = aNode;
	[self.target addTransformListener: self];
}

-(BOOL) hasTarget { return (self.target != nil); }

-(BOOL) shouldTrackTarget { return _rotator.shouldTrackTarget; }

/**
 * Check if the property was off and is now being turned on. In the case where this property was
 * temporarily turned off to perform some movement or rotation, we must force an update of the
 * target location when this property is turned back on.
 */
-(void) setShouldTrackTarget: (BOOL) shouldTrack {
	BOOL wasAlreadyTracking = self.shouldTrackTarget;
	self.targettingRotator.shouldTrackTarget = shouldTrack;
	if ( shouldTrack && !wasAlreadyTracking) [self markTransformDirty];
}

-(BOOL) shouldAutotargetCamera { return _rotator.shouldAutotargetCamera; }

-(void) setShouldAutotargetCamera: (BOOL) shouldAutotarg {
	self.targettingRotator.shouldAutotargetCamera = shouldAutotarg;
	self.shouldTrackTarget = shouldAutotarg;
}

-(CC3TargettingConstraint) targettingConstraint { return _rotator.targettingConstraint; }

-(void) setTargettingConstraint: (CC3TargettingConstraint) targContraint {
	self.targettingRotator.targettingConstraint = targContraint;
}

// Deprecated
-(CC3TargettingConstraint) axisRestriction { return self.targettingConstraint; }
-(void) setAxisRestriction: (CC3TargettingConstraint) axisRest { self.targettingConstraint = axisRest; }

-(BOOL) isTrackingForBumpMapping { return _rotator.isTrackingForBumpMapping; }

-(void) setIsTrackingForBumpMapping: (BOOL) isBumpMapping {
	self.targettingRotator.isTrackingForBumpMapping = isBumpMapping;
}

-(BOOL) isTrackingTargetDirection { return _rotator.isTrackingTargetDirection; }

/**
 * Checks if the camera should be a target, and if so,
 * ensures that the target is the currently active camera.
 */
-(void) checkCameraTarget {
	if (self.shouldAutotargetCamera) {
		CC3Camera* cam = self.activeCamera;
		if (cam && (self.target != cam)) {
			self.target = cam;
			self.targettingRotator.shouldAutotargetCamera = NO;
		}
	}
}

// Deprecated
-(void) trackTargetWithVisitor: (id) visitor {}


#pragma mark Rotator

/**
 * Returns the rotator property, cast as a CC3MutableRotator.
 *
 * If the rotator is not already a CC3MutableRotator, a new CC3MutableRotator
 * is created and its state is copied from the current rotator.
 *
 * This design allows nodes that do not require rotation to use the empty and smaller
 * CC3Rotator instance, but allows an automatic upgrade to a mutable rotator
 * when the node needs to make changes to the rotational properties.
 *
 * This property should only be accessed if the intention is to swap the existing
 * rotator with a directional rotator.
 */
-(CC3MutableRotator*) mutableRotator {
	if ( !_rotator.isMutable ) {
		CC3MutableRotator* mRotator = (CC3MutableRotator*)[[self mutableRotatorClass] rotator];
		[mRotator populateFrom: _rotator];
		LogTrace(@"%@ swapping %@ for existing %@", self, mRotator, _rotator);
		self.rotator = mRotator;
	}
	return (CC3MutableRotator*)_rotator;
}

/**
 * Rotation tracking for each node is handled by a encapsulated instance of CC3Rotator.
 *
 * When the mutableRotator property is accessed, the default rotator is upgraded
 * to a CC3MutableRotator, or one of its subclasses.
 *
 * This property returns the class to use when creating the rotator returned by the
 * mutableRotator property. Different node types may use different mutable rotators.
 *
 * This base implementation returns a basic CC3MutableRotator.
 */
-(Class) mutableRotatorClass { return [CC3MutableRotator class]; }

/**
 * Returns the rotator property, cast as a CC3DirectionalRotator.
 *
 * If the rotator is not already a CC3DirectionalRotator, a new CC3DirectionalRotator
 * is created and its state is copied from the current rotator.
 *
 * This design allows most nodes to use a simpler and smaller CC3Rotator instance,
 * but allow an automatic upgrade to a larger and more complex directional rotator
 * when the node needs to make use of pointing or tracking functionality.
 *
 * This implementation returns a reversing directional rotator class that orients
 * the positive-Z axis of the node along the forwardDirection.
 *
 * This property should only be accessed if the intention is to swap the existing
 * rotator with a directional rotator.
 */
-(CC3DirectionalRotator*) directionalRotator {
	if ( !_rotator.isDirectional ) {
		CC3DirectionalRotator* dRotator = (CC3DirectionalRotator*)[[self directionalRotatorClass] rotator];
		[dRotator populateFrom: _rotator];
		dRotator.shouldReverseForwardDirection = self.shouldReverseForwardDirection;
		LogTrace(@"%@ swapping %@ for existing %@", self, dRotator, _rotator);
		self.rotator = dRotator;
	}
	return (CC3DirectionalRotator*)_rotator;
}

/**
 * Rotation tracking for each node is handled by a encapsulated instance of CC3Rotator.
 *
 * When the directionalRotator property is accessed, the default rotator is upgraded
 * to a CC3DirectionalRotator, or one of its subclasses.
 *
 * This property returns the class to use when creating the rotator returned by the
 * directionalRotator property. Different node types may use different directional rotators.
 */
-(Class) directionalRotatorClass { return [CC3DirectionalRotator class]; }

/**
 * Returns the rotator property, cast as a CC3TargettingRotator.
 *
 * If the rotator is not already a CC3TargettingRotator, a new CC3TargettingRotator
 * is created and its state is copied from the current rotator.
 *
 * This design allows most nodes to use a simpler and smaller CC3Rotator instance,
 * but allow an automatic upgrade to a larger and more complex directional rotator
 * when the node needs to make use of pointing or tracking functionality.
 *
 * This implementation returns a reversing directional rotator class that orients
 * the positive-Z axis of the node along the forwardDirection.
 *
 * This property should only be accessed if the intention is to swap the existing
 * rotator with a targetting rotator.
 */
-(CC3TargettingRotator*) targettingRotator {
	if ( !_rotator.isTargettable ) {
		CC3TargettingRotator* tRotator = (CC3TargettingRotator*)[[self targettingRotatorClass] rotator];
		[tRotator populateFrom: _rotator];
		tRotator.shouldReverseForwardDirection = self.shouldReverseForwardDirection;
		LogTrace(@"%@ swapping %@ for existing %@", self, tRotator, _rotator);
		self.rotator = tRotator;
	}
	return (CC3TargettingRotator*)_rotator;
}

/**
 * Rotation tracking for each node is handled by a encapsulated instance of CC3Rotator.
 *
 * When the targettingRotator property is accessed, the default rotator is upgraded
 * to a CC3TargettingRotator, or one of its subclasses.
 *
 * This property returns the class to use when creating the rotator returned by the
 * targettingRotator property. Different node types may use different directional rotators.
 */
-(Class) targettingRotatorClass { return [CC3TargettingRotator class]; }

/**
 * Indicates whether the effect of setting the forwardDirection property should be reversed.
 *
 * In OpenGL, rotation is defined relative to the negative-Z-axis, and cameras and lights are
 * oriented in this manner by default. However, most other nodes are oriented so that the
 * forwardDirection aligns with the positive-Z-axis, so that the forwardDirection of the node
 * will face the camera and lights by default.
 *
 * Consequently, this property returns YES for most nodes, to align the forwardDirection with
 * the positive-Z-axis. Subclasses that want to use the default OpenGL orientation, such as
 * cameras and lights, will override to return NO.
 */
-(BOOL) shouldReverseForwardDirection { return YES; }


#pragma mark Mesh configuration

-(BOOL) shouldDrawInClipSpace {
	for (CC3Node* child in _children) if (child.shouldDrawInClipSpace == YES) return YES;
	return NO;
}

-(void) setShouldDrawInClipSpace: (BOOL) shouldClip {
	for (CC3Node* child in _children) child.shouldDrawInClipSpace = shouldClip;
}

-(BOOL) shouldCullBackFaces {
	for (CC3Node* child in _children) if (child.shouldCullBackFaces == NO) return NO;
	return YES;
}

-(void) setShouldCullBackFaces: (BOOL) shouldCull {
	for (CC3Node* child in _children) child.shouldCullBackFaces = shouldCull;
}

-(BOOL) shouldCullFrontFaces {
	for (CC3Node* child in _children) if (child.shouldCullFrontFaces) return YES;
	return NO;
}

-(void) setShouldCullFrontFaces: (BOOL) shouldCull {
	for (CC3Node* child in _children) child.shouldCullFrontFaces = shouldCull;
}

-(BOOL) shouldUseClockwiseFrontFaceWinding {
	for (CC3Node* child in _children) if (child.shouldUseClockwiseFrontFaceWinding) return YES;
	return NO;
}

-(void) setShouldUseClockwiseFrontFaceWinding: (BOOL) shouldWindCW {
	for (CC3Node* child in _children) child.shouldUseClockwiseFrontFaceWinding = shouldWindCW;
}

-(BOOL) shouldUseSmoothShading {
	for (CC3Node* child in _children) if (child.shouldUseSmoothShading == NO) return NO;
	return YES;
}

-(void) setShouldUseSmoothShading: (BOOL) shouldSmooth {
	for (CC3Node* child in _children) child.shouldUseSmoothShading = shouldSmooth;
}

-(CC3NormalScaling) normalScalingMethod {
	for (CC3Node* child in _children) {
		CC3NormalScaling csm = child.normalScalingMethod;
		if (csm != kCC3NormalScalingNone) return csm;
	}
	return kCC3NormalScalingNone;
}

-(void) setNormalScalingMethod: (CC3NormalScaling) nsMethod {
	for (CC3Node* child in _children) child.normalScalingMethod = nsMethod;
}

-(BOOL) shouldCacheFaces {
	for (CC3Node* child in _children) if (child.shouldCacheFaces) return YES;
	return NO;
}

-(void) setShouldCacheFaces: (BOOL) shouldCache {
	for (CC3Node* child in _children) child.shouldCacheFaces = shouldCache;
}

-(BOOL) shouldCastShadowsWhenInvisible {
	for (CC3Node* child in _children) {
		if (child.shouldCastShadowsWhenInvisible) return YES;
	}
	return NO;
}

-(void) setShouldCastShadowsWhenInvisible: (BOOL) shouldCast {
	for (CC3Node* child in _children) child.shouldCastShadowsWhenInvisible = shouldCast;
}

-(BOOL) shouldDisableDepthMask {
	for (CC3Node* child in _children) if (child.shouldDisableDepthMask) return YES;
	return NO;
}

-(void) setShouldDisableDepthMask: (BOOL) shouldDisable {
	for (CC3Node* child in _children) child.shouldDisableDepthMask = shouldDisable;
}

-(BOOL) shouldDisableDepthTest {
	for (CC3Node* child in _children) if (child.shouldDisableDepthTest) return YES;
	return NO;
}

-(void) setShouldDisableDepthTest: (BOOL) shouldDisable {
	for (CC3Node* child in _children) child.shouldDisableDepthTest = shouldDisable;
}

-(GLenum) depthFunction {
	for (CC3Node* child in _children) {
		GLenum df = child.depthFunction;
		if (df != GL_NEVER) return df;
	}
	return GL_NEVER;
}

-(void) setDepthFunction: (GLenum) depthFunc {
	for (CC3Node* child in _children) {
		child.depthFunction = depthFunc;
	}
}

-(GLfloat) decalOffsetFactor {
	for (CC3Node* child in _children) {
		GLenum df = child.decalOffsetFactor;
		if (df) return df;
	}
	return 0.0f;
}

-(void) setDecalOffsetFactor: (GLfloat) factor {
	for (CC3Node* child in _children) child.decalOffsetFactor = factor;
}

-(GLfloat) decalOffsetUnits {
	for (CC3Node* child in _children) {
		GLenum du = child.decalOffsetUnits;
		if (du) return du;
	}
	return 0.0f;
}

-(void) setDecalOffsetUnits: (GLfloat) units {
	for (CC3Node* child in _children) child.decalOffsetUnits = units;
}

-(CC3Box) boundingBox { return [self boundingBoxRelativeTo: self]; }

-(CC3Box) globalBoundingBox { return [self boundingBoxRelativeTo: nil]; }

-(CC3Box) boundingBoxRelativeTo: (CC3Node*) ancestor {
	CC3Box bb = kCC3BoxNull;
	for (CC3Node* child in _children) bb = CC3BoxUnion(bb, [child boundingBoxRelativeTo: ancestor]);
	return bb;
}

-(CC3Vector) centerOfGeometry {
	CC3Box bb = self.boundingBox;
	return CC3BoxIsNull(bb) ? kCC3VectorZero : CC3BoxCenter(bb);
}

-(CC3Vector) globalCenterOfGeometry {
	return [self.globalTransformMatrix transformLocation: self.centerOfGeometry];
}

// By default, individual nodes do not collect their own performance statistics
-(CC3PerformanceStatistics*) performanceStatistics { return nil; }
-(void) setPerformanceStatistics: (CC3PerformanceStatistics*) aPerfStats {}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ location: %@, global: %@, %@, scale: %@",
			[self description],
			NSStringFromCC3Vector(self.location),
			NSStringFromCC3Vector(self.globalLocation),
			_rotator.fullDescription,
			NSStringFromCC3Vector(self.scale)];
}

-(NSString*) structureDescription {
	return [self appendStructureDescriptionTo: [NSMutableString stringWithCapacity: 1000] withIndent: 0];
}

-(NSString*) appendStructureDescriptionTo: (NSMutableString*) desc withIndent: (NSUInteger) indentLevel {
	[desc appendFormat: @"\n"];
	for (int i = 0; i < indentLevel; i++) [desc appendFormat: @"  "];
	[desc appendFormat: @"%@", self];
	for (CC3Node* child in _children) [child appendStructureDescriptionTo: desc withIndent: indentLevel + 1];
	return desc;
}


#pragma mark Matierial properties

-(BOOL) shouldUseLighting {
	for (CC3Node* child in _children) if (child.shouldUseLighting) return YES;
	return NO;
}

-(void) setShouldUseLighting: (BOOL) useLighting {
	for (CC3Node* child in _children) child.shouldUseLighting = useLighting;
}

-(ccColor4F) ambientColor {
	ccColor4F col = kCCC4FBlackTransparent;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in _children) {
			ccColor4F childColor = child.ambientColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = ccc4f(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setAmbientColor: (ccColor4F) color {
	for (CC3Node* child in _children) child.ambientColor = color;
}

-(ccColor4F) diffuseColor {
	ccColor4F col = kCCC4FBlackTransparent;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in _children) {
			ccColor4F childColor = child.diffuseColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = ccc4f(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setDiffuseColor: (ccColor4F) color {
	for (CC3Node* child in _children) child.diffuseColor = color;
}

-(ccColor4F) specularColor {
	ccColor4F col = kCCC4FBlackTransparent;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in _children) {
			ccColor4F childColor = child.specularColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = ccc4f(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setSpecularColor: (ccColor4F) color {
	for (CC3Node* child in _children) child.specularColor = color;
}

-(ccColor4F) emissionColor {
	ccColor4F col = kCCC4FBlackTransparent;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in _children) {
			ccColor4F childColor = child.emissionColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = ccc4f(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setEmissionColor: (ccColor4F) color {
	for (CC3Node* child in _children) child.emissionColor = color;
}

-(GLfloat) shininess {
	GLfloat shininess = 0.0f;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLfloat sSum = 0.0f;
		for (CC3Node* child in _children) sSum += child.shininess;
		shininess = sSum / childCnt;
	}
	return shininess;
}

-(void) setShininess: (GLfloat) shininess {
	for (CC3Node* child in _children) [child setShininess: shininess];
}

-(GLfloat) reflectivity {
	GLfloat reflectivity = 0.0f;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLfloat rSum = 0.0f;
		for (CC3Node* child in _children) rSum += child.reflectivity;
		reflectivity = rSum / childCnt;
	}
	return reflectivity;
}

-(void) setReflectivity: (GLfloat) reflectivity {
	for (CC3Node* child in _children) [child setReflectivity: reflectivity];
}

-(CC3Texture*) texture {
	for (CC3Node* child in _children) {
		CC3Texture* tex = child.texture;
		if (tex) return tex;
	}
	return nil;
}

-(void) setTexture: (CC3Texture*) texture {
	for (CC3Node* child in _children) [child setTexture: texture];
}

-(void) addTexture: (CC3Texture*) texture {
	for (CC3Node* child in _children) [child addTexture: texture];
}

-(CC3Vector4) globalLightPosition {
	for (CC3Node* child in _children) {
		CC3Vector4 glp = child.globalLightPosition;
		if ( !CC3Vector4sAreEqual(glp, kCC3Vector4Zero) ) return glp;
	}
	return kCC3Vector4Zero;
}

-(void) setGlobalLightPosition: (CC3Vector4) aPosition {
	for (CC3Node* child in _children) child.globalLightPosition = aPosition;
}

-(CC3Vector) globalLightLocation { return CC3VectorFromTruncatedCC3Vector4(self.globalLightPosition); };

-(void) setGlobalLightLocation: (CC3Vector) aLocation {
	self.globalLightPosition = CC3Vector4FromLocation(aLocation);
}

-(CC3ShaderContext*) shaderContext {
	for (CC3Node* child in _children) {
		CC3ShaderContext* shaderContext = child.shaderContext;
		if (shaderContext) return shaderContext;
	}
	return nil;
}

-(void) setShaderContext: (CC3ShaderContext*) shaderContext {
	for (CC3Node* child in _children) child.shaderContext = shaderContext;
}

-(CC3ShaderProgram*) shaderProgram {
	for (CC3Node* child in _children) {
		CC3ShaderProgram* program = child.shaderProgram;
		if (program) return program;
	}
	return nil;
}

-(void) setShaderProgram: (CC3ShaderProgram*) shaderProgram {
	for (CC3Node* child in _children) child.shaderProgram = shaderProgram;
}

-(void) selectShaders { for (CC3Node* child in _children) [child selectShaders]; }

-(void) removeShaders { for (CC3Node* child in _children) [child removeShaders]; }

// Deprecated
-(void) selectShaderPrograms { [self selectShaders]; }
-(void) clearShaderPrograms { [self removeShaders]; }


#pragma mark CCRGBAProtocol and CCBlendProtocol support

-(ccColor3B) color {
	ccColor3B col = ccBLACK;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLuint rSum, bSum, gSum;
		rSum = bSum = gSum = 0;
		for (CC3Node* child in _children) {
			ccColor3B childColor = child.color;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
		}
		col = ccc3(rSum / childCnt, gSum / childCnt, bSum / childCnt);
	}
	return col;
}

-(void) setColor: (ccColor3B) color {
	if (_cascadeColorEnabled) for (CC3Node* child in _children) child.color = color;
}

-(GLubyte) opacity {
	GLubyte opc = 0;
	NSUInteger childCnt = 0;
	if (_children && (childCnt = _children.count) > 0) {
		GLuint oSum = 0;
		for (CC3Node* child in _children) oSum += child.opacity;
		opc = oSum / childCnt;
	}
	return opc;
}

-(void) setOpacity: (GLubyte) opacity {
	if (_cascadeOpacityEnabled) for (CC3Node* child in _children) child.opacity = opacity;
}

-(ccColor3B) displayedColor { return self.color; }

-(BOOL) isCascadeColorEnabled { return _cascadeColorEnabled; }

-(void) setCascadeColorEnabled: (BOOL) cascadeColorEnabled {
	_cascadeColorEnabled = cascadeColorEnabled;
}

-(void) updateDisplayedColor: (ccColor3B) color {}

-(GLubyte) displayedOpacity { return self.opacity; }

-(BOOL) isCascadeOpacityEnabled { return _cascadeOpacityEnabled; }

-(void) setCascadeOpacityEnabled: (BOOL) cascadeOpacityEnabled {
	_cascadeOpacityEnabled = cascadeOpacityEnabled;
}

-(void) updateDisplayedOpacity: (GLubyte) opacity {}

-(ccBlendFunc) blendFunc {
	for (CC3Node* child in _children) return child.blendFunc;	// From first child if exists
	return (ccBlendFunc){GL_ONE, GL_ZERO};
}

-(void) setBlendFunc: (ccBlendFunc) aBlendFunc {
	for (CC3Node* child in _children) child.blendFunc = aBlendFunc;
}

-(BOOL) isOpaque {
	for (CC3Node* child in _children) if(!child.isOpaque) return NO;
	return YES;
}

-(void) setIsOpaque: (BOOL) opaque {
	for (CC3Node* child in _children) child.isOpaque = opaque;
}

-(BOOL) shouldBlendAtFullOpacity {
	for (CC3Node* child in _children) if(child.shouldBlendAtFullOpacity) return YES;
	return NO;
}

-(void) setShouldBlendAtFullOpacity: (BOOL) shouldBlend {
	for (CC3Node* child in _children) child.shouldBlendAtFullOpacity = shouldBlend;
}

-(BOOL) shouldApplyOpacityAndColorToMeshContent {
	for (CC3Node* child in _children) return child.shouldApplyOpacityAndColorToMeshContent;
	return NO;
}

-(void) setShouldApplyOpacityAndColorToMeshContent: (BOOL) shouldApply {
	for (CC3Node* child in _children) child.shouldApplyOpacityAndColorToMeshContent = shouldApply;
}


#pragma mark Line drawing configuration

-(GLfloat) lineWidth {
	for (CC3Node* child in _children) return child.lineWidth;	// From first child if exists
	return 1.0f;
}

-(void) setLineWidth: (GLfloat) aLineWidth {
	for (CC3Node* child in _children) child.lineWidth = aLineWidth;
}

-(BOOL) shouldSmoothLines {
	for (CC3Node* child in _children) return child.shouldSmoothLines;	// From first child if exists
	return NO;
}

-(void) setShouldSmoothLines: (BOOL) shouldSmooth {
	for (CC3Node* child in _children) child.shouldSmoothLines = shouldSmooth;
}

-(GLenum) lineSmoothingHint {
	for (CC3Node* child in _children) return child.lineSmoothingHint;	// From first child if exists
	return GL_DONT_CARE;
}

-(void) setLineSmoothingHint: (GLenum) aHint {
	for (CC3Node* child in _children) child.lineSmoothingHint = aHint;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_globalTransformMatrix = [CC3AffineMatrix new];		// retained
		_globalTransformMatrixInverted = nil;
		_globalRotationMatrix = nil;
		_rotator = [CC3Rotator new];						// retained
		_transformListeners = nil;
		_animationStates = nil;
		_isAnimationDirty = NO;
		_boundingVolume = nil;
		_boundingVolumePadding = 0.0f;
		_shouldUseFixedBoundingVolume = NO;
		_location = kCC3VectorZero;
		_projectedLocation = kCC3VectorZero;
		_scale = kCC3VectorUnitCube;
		_cameraDistanceProduct = 0.0f;
		_touchEnabled = NO;
		_shouldInheritTouchability = YES;
		_shouldAllowTouchableWhenInvisible = NO;
		_visible = YES;
		_isRunning = NO;
		_shouldStopActionsWhenRemoved = YES;
		_shouldAutoremoveWhenEmpty = NO;
		_cascadeColorEnabled = YES;
		_cascadeOpacityEnabled = YES;
		_shouldCastShadows = YES;
		_isBeingAdded = NO;
	}
	return self;
}

+(id) node { return [[[self alloc] init] autorelease]; }

+(id) nodeWithTag: (GLuint) aTag { return [[[self alloc] initWithTag: aTag] autorelease]; }

+(id) nodeWithName: (NSString*) aName { return [[[self alloc] initWithName: aName] autorelease]; }

+(id) nodeWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

// Protected properties for copying
-(BOOL) rawVisible { return _visible; }
-(NSArray*) animationStates { return _animationStates; }

/**
 * Populates this instance with content copied from the specified other node.
 *
 * The population of this node from the content of the other node effects a deep copy.
 * For any content that is held by reference (eg- objects), and subject to future
 * modification, a copy is created, so that both this instance and the other instance can
 * be treated independently.
 * 
 * Child nodes are not copied in this method. Once this node has been populated with
 * configuration content by this method, invoke the addCopiesOfChildrenFrom: method to copy
 * the child nodes from the other node.
 * 
 * Subclasses that extend copying should extend this method, and honour the deep copy
 * design pattern, making exceptions only for content that is both large and not subject
 * to modifications, such as mesh data.
 */
-(void) populateFrom: (CC3Node*) another {
	[super populateFrom: another];
	
	_location = another.location;
	_projectedLocation = another.projectedLocation;
	_scale = another.scale;
	[self markTransformDirty];

	[_rotator release];
	_rotator = [another.rotator copy];					// retained
	
	[_boundingVolume release];
	_boundingVolume = [another.boundingVolume copy];	// retained
	_boundingVolume.node = self;
	_boundingVolumePadding = another.boundingVolumePadding;
	_shouldUseFixedBoundingVolume = another.shouldUseFixedBoundingVolume;

	_isAnimationDirty = NO;
	for (CC3NodeAnimationState* as in another.animationStates)
		[self addAnimation: as.animation asTrack: as.trackID];
	
	// Transform listeners are not copied. Managing listeners must be deliberate.

	_touchEnabled = another.isTouchEnabled;
	_shouldInheritTouchability = another.shouldInheritTouchability;
	_shouldAllowTouchableWhenInvisible = another.shouldAllowTouchableWhenInvisible;
	_visible = another.rawVisible;
	_isRunning = another.isRunning;
	_shouldStopActionsWhenRemoved = another.shouldStopActionsWhenRemoved;
	_shouldAutoremoveWhenEmpty = another.shouldAutoremoveWhenEmpty;
	_cascadeColorEnabled = another.isCascadeColorEnabled;
	_cascadeOpacityEnabled = another.isCascadeOpacityEnabled;
	_cameraDistanceProduct = another.cameraDistanceProduct;
	_shouldCastShadows = another.shouldCastShadows;
	
	self.shouldDrawDescriptor = another.shouldDrawDescriptor;		// May create a child node
	self.shouldDrawWireframeBox = another.shouldDrawWireframeBox;	// May create a child node
}

/**
 * Copying of children is performed here instead of in populateFrom:
 * so that subclasses will be completely configured before children are added.
 * Subclasses that extend copying should not override this method,
 * but should override the populateFrom: method instead.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName asClass: (Class) aClass {
	CC3Node* aCopy = (CC3Node*)[super copyWithZone: zone withName: aName asClass: aClass];
	[aCopy addCopiesOfChildrenFrom: self];
	return aCopy;
}

/**
 * Adds copies of the child nodes of the other node to this node.
 * Only the children that have the shouldIncludeInDeepCopy property set to YES are copied.
 * The children from the other node are added to the children that already exist in this node
 * (which were possibly added during instantiation init).
 */
-(void) addCopiesOfChildrenFrom: (CC3Node*) another {
	NSArray* otherKids = another.children;
	for (CC3Node* otherKid in otherKids) {
		if (otherKid.shouldIncludeInDeepCopy) {
			CC3Node* myKid = [otherKid copy];
			[self addChild: myKid];
			[myKid release];
		}
	}
}

// Implementations to keep compiler happy so this method can be included in interface for documentation.
-(id) copy { return [super copy]; }
-(id) copyWithName: (NSString*) aName { return [super copyWithName: aName]; }

-(void) createGLBuffers { for (CC3Node* child in _children) [child createGLBuffers]; }

-(void) deleteGLBuffers { for (CC3Node* child in _children) [child deleteGLBuffers]; }

-(void) releaseRedundantContent { for (CC3Node* child in _children) [child releaseRedundantContent]; }

// Deprecated
-(void) releaseRedundantData { [self releaseRedundantContent]; }

-(void) retainVertexContent { for (CC3Node* child in _children) [child retainVertexContent]; }

-(void) retainVertexLocations { for (CC3Node* child in _children) [child retainVertexLocations]; }

-(void) retainVertexNormals { for (CC3Node* child in _children) [child retainVertexNormals]; }

-(void) retainVertexTangents { for (CC3Node* child in _children) [child retainVertexTangents]; }

-(void) retainVertexBitangents { for (CC3Node* child in _children) [child retainVertexBitangents]; }

-(void) retainVertexColors { for (CC3Node* child in _children) [child retainVertexColors]; }

-(void) retainVertexBoneWeights { for (CC3Node* child in _children) [child retainVertexBoneWeights]; }

-(void) retainVertexBoneIndices { for (CC3Node* child in _children) [child retainVertexBoneIndices]; }

-(void) retainVertexPointSizes { for (CC3Node* child in _children) [child retainVertexPointSizes]; }

-(void) retainVertexTextureCoordinates { for (CC3Node* child in _children) [child retainVertexTextureCoordinates]; }

-(void) retainVertexIndices { for (CC3Node* child in _children) [child retainVertexIndices]; }

-(void) doNotBufferVertexContent { for (CC3Node* child in _children) [child doNotBufferVertexContent]; }

-(void) doNotBufferVertexLocations { for (CC3Node* child in _children) [child doNotBufferVertexLocations]; }

-(void) doNotBufferVertexNormals { for (CC3Node* child in _children) [child doNotBufferVertexNormals]; }

-(void) doNotBufferVertexTangents { for (CC3Node* child in _children) [child doNotBufferVertexTangents]; }

-(void) doNotBufferVertexBitangents { for (CC3Node* child in _children) [child doNotBufferVertexBitangents]; }

-(void) doNotBufferVertexColors { for (CC3Node* child in _children) [child doNotBufferVertexColors]; }

-(void) doNotBufferVertexBoneWeights { for (CC3Node* child in _children) [child doNotBufferVertexBoneWeights]; }

-(void) doNotBufferVertexBoneIndices { for (CC3Node* child in _children) [child doNotBufferVertexBoneIndices]; }

-(void) doNotBufferVertexPointSizes { for (CC3Node* child in _children) [child doNotBufferVertexPointSizes]; }

-(void) doNotBufferVertexTextureCoordinates { for (CC3Node* child in _children) [child doNotBufferVertexTextureCoordinates]; }

-(void) doNotBufferVertexIndices { for (CC3Node* child in _children) [child doNotBufferVertexIndices]; }

-(void) retainVertexWeights { [self retainVertexBoneWeights]; }

-(void) retainVertexMatrixIndices { [self retainVertexBoneIndices]; }

-(void) doNotBufferVertexWeights { [self doNotBufferVertexBoneWeights]; }

-(void) doNotBufferVertexMatrixIndices { [self doNotBufferVertexBoneIndices]; }


#pragma mark Texture and normal alignment

-(void) flipNormals { for (CC3Node* child in _children) [child flipNormals]; }

-(BOOL) expectsVerticallyFlippedTextures {
	for (CC3Node* child in _children) if (child.expectsVerticallyFlippedTextures) return YES;
	return NO;
}

-(void) setExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {
	for (CC3Node* child in _children) child.expectsVerticallyFlippedTextures = expectsFlipped;
}

-(void) flipTexturesVertically { for (CC3Node* child in _children) [child flipTexturesVertically]; }

-(void) flipTexturesHorizontally { for (CC3Node* child in _children) [child flipTexturesHorizontally]; }

// Deprecated
-(void) alignTextures { for (CC3Node* child in _children) [child alignTextures]; }

// Deprecated
-(void) alignInvertedTextures { for (CC3Node* child in _children) [child alignInvertedTextures]; }


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Nodes.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedNodeTag;

-(GLuint) nextTag { return ++lastAssignedNodeTag; }

+(void) resetTagAllocation { lastAssignedNodeTag = 0; }


#pragma mark Type testing

-(BOOL) hasLocalContent { return NO; }

-(BOOL) visible { return _visible && (!_parent || _parent.visible); }

-(void) show { self.visible = YES; }

-(void) hide { self.visible = NO; }

-(GLint) zOrder {
	NSUInteger childCount = _children ? _children.count : 0;
	if (childCount > 0) {
		GLint zoSum = 0;
		for (CC3Node* child in _children) zoSum += child.zOrder;
		return zoSum / childCount;
	}
	return 0;
}

-(void) setZOrder: (GLint) zo { for (CC3Node* child in _children) child.zOrder = zo; }


#pragma mark Updating

// Deprecated legacy method - supported for backwards compatibility
-(void) update: (CCTime)dt {}

// Deprecated legacy method - supported for backwards compatibility
-(void) updateBeforeChildren: (CC3NodeUpdatingVisitor*) visitor {}

// Deprecated legacy method - supported for backwards compatibility
-(void) updateAfterChildren: (CC3NodeUpdatingVisitor*) visitor {}

/** Protected template method invoked from the update visitor just before updating the transform. */
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self checkCameraTarget];
	[self updateFromAnimationState];
	[self updateBeforeTransform: visitor];
}

// Default invokes legacy updateBeforeChildren: and update: methods, for backwards compatibility.
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateBeforeChildren: visitor];
	[self update: visitor.deltaTime];
}

/**
 * Protected template method invoked from the update visitor just after updating
 * the transform.
 *
 * This implementation simply invokes the application callback updateAfterTransform:
 * method. Framework subclasses that want to perform other activity may override, but
 * should invoke this superclass method to ensure that the updateAfterTransform:
 * will be invoked.
 */
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateAfterTransform: visitor];
}

// Default invokes legacy updateAfterChildren: method, for backwards compatibility.
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateAfterChildren: visitor];
}


#pragma mark Transformations

-(NSSet*) transformListeners {
	return _transformListeners ? _transformListeners.transformListeners : [NSSet set];
}

-(void) addTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener {
	if (!aListener) return;
	
	// Lazily create the transform listeners cache, and add the listener
	if( !_transformListeners ) _transformListeners = [[CC3NodeTransformListeners listenersForNode: self] retain];
	[_transformListeners addTransformListener: aListener];
	
	// Notify immediately, to ensure the listener is aware of current state.
	[aListener nodeWasTransformed: self];
}

-(void) removeTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener {
	// Remove the listener, then remove the transform listeners cache if no further listeners
	[_transformListeners removeTransformListener: aListener];
	if (_transformListeners.isEmpty) {
		[_transformListeners release];
		_transformListeners = nil;
	}
}

-(void) removeAllTransformListeners { [_transformListeners removeAllTransformListeners]; }

-(void) notifyTransformListeners { [_transformListeners notifyTransformListeners]; }

-(void) notifyDestructionListeners { [_transformListeners notifyDestructionListeners]; }

-(void) nodeWasTransformed: (CC3Node*) aNode {
	if ( (aNode == self.target) && self.shouldUpdateToTarget ) [self markTransformDirty];
}

-(void) nodeWasDestroyed: (CC3Node*) aNode {
	// Can't retrieve target from rotator, because it might be deallocated already,
	// and ARC will attempt to retain and autorelease it, resulting in a zombie.
	// Maybe revisit need for this once using true weak refs under minimum iOS 5.
	[_rotator clearIfTarget: aNode];
}

-(BOOL) shouldUpdateToTarget { return _rotator.shouldUpdateToTarget; }

-(BOOL) isTransformDirty { return _globalTransformMatrix.isDirty; }

-(void) markTransformDirty {
	if (self.isTransformDirty) return;
	
	_globalTransformMatrix.isDirty = YES;
	_globalTransformMatrixInverted.isDirty = YES;
	_globalRotationMatrix.isDirty = YES;
	[_boundingVolume markTransformDirty];
	
	[self notifyTransformListeners];
	
	for (CC3Node* child in _children) [child markTransformDirty];
}

-(CC3Matrix*) globalTransformMatrix {
	if (self.isTransformDirty) {
		[_globalTransformMatrix populateFrom: self.parent.globalTransformMatrix];
		[self applyLocalTransforms];
		_globalTransformMatrix.isDirty = NO;
	}
	return _globalTransformMatrix;
}

/**
 * Template method that applies the local location, rotation and scale properties to
 * the transform matrix. Subclasses may override to enhance or modify this behaviour.
 */
-(void) applyLocalTransforms {
	[self applyTranslation];
	[self applyRotation];
	[self applyScaling];
}

/** Template method that applies the local location property to the transform matrix. */
-(void) applyTranslation { [_globalTransformMatrix translateBy: _location]; }

/**
 * Template method that applies the rotation in the rotator to the transform matrix.
 *
 * Target location can only be applied once translation is complete, because the direction to
 * the target depends on the transformed global location of both this node and the target location.
 */
-(void) applyRotation {
	[self updateTargetLocation];
	if (self.shouldRotateToTargetLocation) [self applyTargetLocation];
	[self applyRotator];
}

/** Check if target location needs to be updated from target, and do so if needed. */
-(void) updateTargetLocation {
	if (self.shouldUpdateToTarget && !self.isTrackingForBumpMapping)
		self.targetLocation = self.target.globalLocation;
}

/**
 * Template property simply delegates to rotator.
 * Subclasses can override to change target tracking behaviour.
 */
-(BOOL) shouldRotateToTargetLocation { return _rotator.shouldRotateToTargetLocation; }

/** Template method to update the rotator transform from the targetLocation. */
-(void) applyTargetLocation {
	if (self.isTargettingConstraintLocal)
		[self applyTargetLocationAsLocal];
	else
		[self applyTargetLocationAsGlobal];
}

/**
 * Rotates the node to point to the target location, by converting the target location to the
 * local coordinate system, treating the referenceUpDirection as a local direction, and rotating
 * in the local coordinate system.
 */
-(void) applyTargetLocationAsLocal {
	CC3Vector targLoc = self.targetLocation;
	if (_parent) targLoc = [_parent.globalTransformMatrixInverted transformLocation: targLoc];
	targLoc = [self rotationallyRestrictTargetLocation: targLoc];
	[self.targettingRotator rotateToTargetLocation: targLoc
											  from: self.location
											withUp: self.referenceUpDirection];
}

/**
 * Rotates the node to point to the target location, by treating the referenceUpDirection as a
 * global direction, and rotating in the global coordinate system.
 */
-(void) applyTargetLocationAsGlobal {
	CC3Vector targLoc = self.targetLocation;
	targLoc = [self rotationallyRestrictTargetLocation: targLoc];
	[self.targettingRotator rotateToTargetLocation: targLoc
											  from: self.globalLocation
											withUp: self.referenceUpDirection];
	[self convertRotatorGlobalToLocal];
}

/**
 * Returns whether the targettingConstraint is specified in the local coordinate system
 * or the global coordinate system.
 */
-(BOOL) isTargettingConstraintLocal {
	switch (self.targettingConstraint) {
		case kCC3TargettingConstraintGlobalUnconstrained:
		case kCC3TargettingConstraintGlobalXAxis:
		case kCC3TargettingConstraintGlobalYAxis:
		case kCC3TargettingConstraintGlobalZAxis:
			return NO;
		case kCC3TargettingConstraintLocalUnconstrained:
		case kCC3TargettingConstraintLocalXAxis:
		case kCC3TargettingConstraintLocalYAxis:
		case kCC3TargettingConstraintLocalZAxis:
		default:
			return YES;
	}
}

/**
 * Constrains rotation to the specified target location by changing the cooresponding coordinate
 * of the location to be the same as this node, so that the node will not rotate out of that plane.
 */
-(CC3Vector) rotationallyRestrictTargetLocation: (CC3Vector) aLocation {
	switch (self.targettingConstraint) {
		case kCC3TargettingConstraintLocalXAxis:
			aLocation.x = self.location.x;
			break;
		case kCC3TargettingConstraintLocalYAxis:
			aLocation.y = self.location.y;
			break;
		case kCC3TargettingConstraintLocalZAxis:
			aLocation.z = self.location.z;
			break;
		case kCC3TargettingConstraintGlobalXAxis:
			aLocation.x = self.globalLocation.x;
			break;
		case kCC3TargettingConstraintGlobalYAxis:
			aLocation.y = self.globalLocation.y;
			break;
		case kCC3TargettingConstraintGlobalZAxis:
			aLocation.z = self.globalLocation.z;
			break;
		default:
			break;
	}
	return aLocation;
}

/**
 * Converts the rotator's rotation matrix from global to local coordinates,
 * by applying an inverse of the parent's global rotation matrix.
 *
 * If Mc is the local rotation of the child, Mp is the global rotation of
 * the parent node, and Mg is the global rotation of this child node:
 *   Mg = Mp.Mc
 *   Mp(-1).Mg = Mp(-1).Mp.Mc
 *   Mp(-1).Mg = Mc
 *
 * Therefore, we can determine the local rotation of this node by multiplying
 * its global rotation by the inverse of the parent's global rotation.
 */
 -(void) convertRotatorGlobalToLocal {
	if ( !_parent ) return;		// No transform needed if no parent
	
	CC3Matrix3x3 parentInvRotMtx;
	[_parent.globalRotationMatrix populateCC3Matrix3x3: &parentInvRotMtx];
	CC3Matrix3x3InvertRigid(&parentInvRotMtx);
	[_rotator.rotationMatrix leftMultiplyByCC3Matrix3x3: &parentInvRotMtx];
}

/** Apply the rotational state of the rotator to the transform matrix. */
-(void) applyRotator {
	[_rotator applyRotationTo: _globalTransformMatrix];
	LogTrace(@"%@ rotated to %@ %@", self, NSStringFromCC3Vector(_rotator.rotation), _globalTransformMatrix);
}

/** Template method that applies the local scale property to the transform matrix. */
-(void) applyScaling { [_globalTransformMatrix scaleBy: CC3EnsureMinScaleVector(_scale)]; }

/**
 * Returns the inverse of the globalTransformMatrix.
 *
 * Since this inverse matrix is not commonly used, and is often expensive to compute,
 * it is only calculated when the globalTransformMatrix has changed, and then only on demand.
 */
-(CC3Matrix*) globalTransformMatrixInverted {
	if (!_globalTransformMatrixInverted) {
		_globalTransformMatrixInverted = [CC3AffineMatrix new];		// retained
		_globalTransformMatrixInverted.isDirty = YES;
	}
	if (_globalTransformMatrixInverted.isDirty) {
		[_globalTransformMatrixInverted populateFrom: self.globalTransformMatrix];
		[_globalTransformMatrixInverted invert];
		_globalTransformMatrixInverted.isDirty = NO;
		
		LogTrace(@"%@ with global scale %@ and transform: %@ %@ inverted to: %@",
				 self, NSStringFromCC3Vector(self.globalScale), _globalTransformMatrix,
				 (_globalTransformMatrixInverted.isRigid ? @"rigidly" : @"adjoint"), _globalTransformMatrixInverted);
		LogTrace(@"validating right multiply: %@ \nvalidating left multiply: %@",
				 [CC3AffineMatrix matrixByMultiplying: _globalTransformMatrix by: _globalTransformMatrixInverted],
				 [CC3AffineMatrix matrixByMultiplying: _globalTransformMatrixInverted by: _globalTransformMatrix]);
	}
	return _globalTransformMatrixInverted;
}

/**
 * Returns a matrix representing all of the rotations that make up this node,
 * including ancestor nodes.
 *
 * Since this matrix is not commonly used, and is expensive to compute, it is only
 * calculated when the globalTransformMatrix has changed, and then only on demand.
 * When the globalTransformMatrix is marked as dirty, the globalRotationMatrix is marked
 * as dirty as well. It is then recalculated the next time this property is accessed,
 * and is cached until it is marked dirty again.
 */
-(CC3Matrix*) globalRotationMatrix {
	if (!_globalRotationMatrix) {
		_globalRotationMatrix = [CC3LinearMatrix new];		// retained
		_globalRotationMatrix.isDirty = YES;
	}
	if (_globalRotationMatrix.isDirty) {

		// Ensure main global transform matrix is updated as well. It is not needed here, but it
		// tracks whether the node's transform is dirty, and it and this matrix need to be in sync.
		[self globalTransformMatrix];
		
		[_globalRotationMatrix populateFrom: _parent.globalRotationMatrix];
		[_globalRotationMatrix multiplyBy: _rotator.rotationMatrix];
		_globalRotationMatrix.isDirty = NO;
	}
	return _globalRotationMatrix;
}

// Deprecated
-(CC3Matrix*) transformMatrix { return self.globalTransformMatrix; }
-(CC3Matrix*) transformMatrixInverted { return self.globalTransformMatrixInverted; }
-(CC3Matrix*) parentTransformMatrix { return _parent.globalTransformMatrix; }
-(CC3Matrix*) parentGlobalTransformMatrix { return _parent.globalTransformMatrix; }
-(void) updateTransformMatrices {}
-(void) updateTransformMatrix {}
-(id) transformVisitorClass { return nil; }
-(CC3Node*) dirtiestAncestor {
	CC3Node* da = _parent.dirtiestAncestor;
	if (da) return da;
	return (self.isTransformDirty) ? self : nil;
}
-(void) buildTransformMatrixWithVisitor: (id) visitor {}


#pragma mark Bounding volumes

-(void) setBoundingVolume:(CC3NodeBoundingVolume *) aBoundingVolume {
	if (aBoundingVolume == _boundingVolume) return;
	
	aBoundingVolume.shouldIgnoreRayIntersection = _boundingVolume.shouldIgnoreRayIntersection;
	
	[_boundingVolume release];
	_boundingVolume = [aBoundingVolume retain];
	
	// If the bounding volume has not been assigned to a node yet, this node will be the primary
	// node of the bounding volume. Otherwise, this node is a secondary node, is tracking the
	// bounding volume, but should not influence the bounding volume characteristics.
	if ( !_boundingVolume.node ) {
		_boundingVolume.node = self;
		[self markBoundingVolumeDirty];
	} else
		_shouldUseFixedBoundingVolume = YES;
}

-(void) createBoundingVolume {
	if ( !_boundingVolume ) self.boundingVolume = [self defaultBoundingVolume];
}

-(void) createBoundingVolumes {
	[self createBoundingVolume];
	for (CC3Node* child in _children) [child createBoundingVolumes];
}

-(void) deleteBoundingVolumes {
	self.boundingVolume = nil;
	for (CC3Node* child in _children) [child deleteBoundingVolumes];
}

-(CC3NodeBoundingVolume*) defaultBoundingVolume { return nil; }

-(void) markBoundingVolumeDirty { if (!_shouldUseFixedBoundingVolume) [_boundingVolume markDirty]; }

// Deprecated method
-(void) rebuildBoundingVolume { [self markBoundingVolumeDirty]; }

-(BOOL) shouldDrawBoundingVolume { return _boundingVolume ? _boundingVolume.shouldDraw : NO; }

-(void) setShouldDrawBoundingVolume: (BOOL) shouldDraw {
	if (shouldDraw) [self createBoundingVolume];
	_boundingVolume.shouldDraw = shouldDraw;
}


#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	if ( !_boundingVolume || !aFrustum ) return YES;
	return [self doesIntersectBoundingVolume: aFrustum];
}

-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Transforming and drawing %@", self);
	CC3OpenGL* gl = visitor.gl;

	[gl pushModelviewMatrixStack];

	LogTrace(@"%@ applying transform matrix: %@", self, _globalTransformMatrix);
	[visitor populateModelMatrixFrom: self.globalTransformMatrix];

	[visitor draw: self];

	[gl popModelviewMatrixStack];
}

-(void) checkDrawingOrder { for (CC3Node* child in _children) [child checkDrawingOrder]; }

-(BOOL) shouldCastShadows { return _shouldCastShadows; }

-(void) setShouldCastShadows: (BOOL) shouldCastShadows {
	_shouldCastShadows = shouldCastShadows;
	for (CC3Node* child in _children) child.shouldCastShadows = shouldCastShadows;
}


#pragma mark Node structural hierarchy

/**
 * When assigned to a new parent, ensure that the transform will be recalculated,
 * since it changes this child's overall transform. Parent is weakly referenced.
 */
-(void) setParent: (CC3Node*) aNode {
	if (aNode == _parent) return;
	
	_parent = aNode;					// weak reference.
	self.isRunning = aNode.isRunning;
	[self markTransformDirty];
}

-(CC3Node*) rootAncestor { return _parent ? _parent.rootAncestor : self; }

-(CC3Scene*) scene { return _parent.scene; }

// Deprecated
-(CC3Scene*) world { return self.scene; }

-(CC3Camera*) activeCamera { return self.scene.activeCamera; }

/** 
 * If this action is occuring on a background thread, and this node is already part of the
 * scene being rendered, the operation is queued for execution on the rendering thread, to
 * avoid the possibility of adding a node in the middle of a render iteration.
 */
-(void) addChild: (CC3Node*) aNode {
	
	// Don't add if child is nil or is already a child of this node
	CC3Assert(aNode, @"Child node cannot be nil");
	if(aNode.parent == self) return;

	[aNode markAddBegin];	// Mark that this node is being added

	if ( !CC3OpenGL.sharedGL.isRenderingContext && self.scene )
		[self addChildFromBackgroundThread: aNode];
	else
		[self addChildNow: aNode];
}

/** Adds the specified node as a child of this node without queuing. */
-(void) addChildNow: (CC3Node*) aNode {
	
	[aNode remove];		// Remove node from its existing parent

	// Lazily create the children array, if needed, and add the node to it
	if(!_children) _children = [NSMutableArray new];	// retained
	[_children addObject: aNode];

	aNode.parent = self;
	[self didAddDescendant: aNode];
	[aNode markAddEnd];
	[aNode wasAdded];
	LogTrace(@"%@ added to parent %@", aNode, self);
}

/** 
 * Invoked when a child is being added on a background thread, and this parent node is
 * already part of the scene.
 *
 * Since the scene may be in the process of being rendered, the child is not added immediately.
 * Instead, all GL activity on this thread is allowed to finish, to ensure all GL components
 * of the node are in place, and then an operation to add the specified node as a child of
 * this node is queued to the thread that is performing rendering.
 */
-(void) addChildFromBackgroundThread: (CC3Node*) aNode {
	[CC3OpenGL.sharedGL finish];
	[CC3OpenGL.renderThread runBlockAsync: ^{ [self addChildNow: aNode]; } ];
	
	// A better design would be to use dispatch queues, but OSX typically
	// renders using a DisplayLink thread instead of the main thread.
//	dispatch_async(dispatch_get_main_queue(), ^{ [self addChildNow: aNode]; });
}

/**
 * To transform location and rotation, we invert the matrix of this node, and multiply it by the
 * matrix of the child node. The incoming child's matrix is in global form. We want a local form
 * that will provide the local location and rotation. We can then extract local location, rotation,
 * and scale from the local matrix.
 *
 * Mathematically, if Mcg is the global matrix of the child node, Mpg is the
 * matrix of this parent, and Mcl is the desired local matrix, we have:
 *     Normally: Mcg = Mpg.Mcl
 * Multiplying both sides by  Mpg(-1), the inverse of the parent's matrix:
 *     Mpg(-1).Mcg = Mpg(-1).Mpg.Mcl
 *     Mcl = Mpg(-1).Mcg
 */
-(void) addAndLocalizeChild: (CC3Node*) aNode {
	CC3Matrix4x3 g2LMtx;
	CC3Matrix3x3 g2LRotMtx;
	
	// Localize the child node's location by finding the right local matrix, and then translating
	// the child node's local origin by the resulting matrix. This is what the location property
	// does. It instructs the local matrix to move the node's origin. By transforming the origin,
	// we determine what that location property needs to be.
	[self.globalTransformMatrixInverted populateCC3Matrix4x3: &g2LMtx];
	[aNode.globalTransformMatrix multiplyIntoCC3Matrix4x3: &g2LMtx];
	CC3Vector4 nodeLoc4 = CC3Matrix4x3TransformCC3Vector4(&g2LMtx, kCC3Vector4ZeroLocation);
	aNode.location = nodeLoc4.v;
	
	// Localize the child node's rotation by finding the right rotation matrix. For rotation, we use
	// the globalRotationMatrix, which is free of scale and translation content. Otherwise it would
	// be impossible to extract he local rotation from an arbitrarily scaled and translated matrix.
	[self.globalRotationMatrix populateCC3Matrix3x3: &g2LRotMtx];
	CC3Matrix3x3InvertRigid(&g2LRotMtx);	// Contains only rotation
	[aNode.globalRotationMatrix multiplyIntoCC3Matrix3x3: &g2LRotMtx];
	aNode.rotation = CC3Matrix3x3ExtractRotationYXZ(&g2LRotMtx);
	
	// Scale cannot readily be extracted from the inverted and multiplied matrix, but we can get
	// it by scaling the node's scale down by the globalScale of this parent, so that when they
	// are recombined, the original globalScale of the child node.
	aNode.scale = CC3VectorScale(aNode.globalScale, CC3VectorInvert(self.globalScale));
	
	[self addChild:aNode];		// Finally, add the child node to this parent
}

/** 
 * Marks that this node is being added to a parent.
 *
 * Since the add operation can be transferred to another thread, its possible for this node
 * to be removed from its current parent before being added to another parent. By marking
 * the add operation as being in progress, the node can avoid standard removal activities
 * such as stopping all actions.
 */
-(void) markAddBegin { _isBeingAdded = YES; }

/**
 * Marks that the operation of adding this node to a parent has finished.
 *
 * Since the add operation can be transferred to another thread, its possible for this node
 * to be removed from its current parent before being added to another parent. By marking
 * the add operation as being in progress, the node can avoid standard removal activities
 * such as stopping all actions.
 */
-(void) markAddEnd { _isBeingAdded = NO; }

-(void) wasAdded {}

/**
 * Removes a child node and invokes didRemoveDescendant: so action can be taken by subclasses.
 * First locates the object to make sure it is in the child node collection, and only performs
 * the removal and related actions if the specified node really is a child of this node.
 * Also removes this node if the shouldAutoremoveWhenEmpty property is YES, and the last
 * child has just been removed.
 */
-(void) removeChild: (CC3Node*) aNode {
	if ( !_children || !aNode ) return;

	NSUInteger indx = [_children indexOfObjectIdenticalTo: aNode];
	if (indx == NSNotFound) return;

	// If the children collection is the only thing referencing the child node, the
	// child node will be deallocated as soon as it is removed, and will be invalid
	// when passed to the didRemoveDescendant: method, or to other activities that
	// it may be subject to in the processing loop. To avoid problems, retain it for
	// the duration of this processing loop, so that it will still be valid until
	// we're done with it.
	
	// If the children collection is the only thing referencing the child node, the child
	// node will be deallocated as soon as it is removed, and will be invalid when passed
	// to the didRemoveDescendant: method, or to other activities that it may be subject
	// to in the processing loop. To avoid problems, retain it for the duration of this
	// processing loop, so that it will still be valid until we're done with it.
	[[aNode retain] autorelease];
	
	aNode.parent = nil;
	[_children removeObjectAtIndex: indx];
	if (_children.count == 0) {
		[_children release];
		_children = nil;
	}

	[aNode wasRemoved];						// Invoke before didRemoveDesc notification
	[self didRemoveDescendant: aNode];

	LogTrace(@"After removing %@, %@ now has children: %@", aNode, self, _children);
	
	// If the last child has been removed, and this instance should autoremove when
	// that occurs, remove this node from the hierarchy as well. This must be performed
	// after everything else is done, particularly only after the didRemoveDescendant:
	// has been invoked so notification can propagate up the node hierarchy.
	if (!_children && _shouldAutoremoveWhenEmpty) [self remove];
}

-(void) removeAllChildren {
	NSArray* myKids = [_children copy];
	for (CC3Node* child in myKids) [self removeChild: child];
	[myKids release];
}

-(void) remove { [_parent removeChild: self]; }

-(void) wasRemoved {
	if (_shouldStopActionsWhenRemoved && !_isBeingAdded) [self stopAllActions];
	self.isRunning = NO;
}

// Deprecated properties
-(BOOL) shouldCleanupActionsWhenRemoved { return self.shouldStopActionsWhenRemoved; }
-(void) setShouldCleanupActionsWhenRemoved: (BOOL) shouldCleanup { self.shouldStopActionsWhenRemoved = shouldCleanup; }
-(BOOL) shouldCleanupWhenRemoved { return self.shouldStopActionsWhenRemoved; }
-(void) setShouldCleanupWhenRemoved: (BOOL) shouldCleanup { self.shouldStopActionsWhenRemoved = shouldCleanup; }

-(BOOL) isDescendantOf: (CC3Node*) aNode {
	return (aNode == self) || (_parent && [_parent isDescendantOf: aNode]);
}

/**
 * Invoked automatically when a node is added as a child somewhere in the descendant structural
 * hierarchy of this node. The method is not only invoked on the immediate parent of the newly
 * added node, but is actually invoked on all ancestors as well (parents of the parent).
 * This default implementation simply passes the notification up the parental ancestor chain.
 * Subclasses may override to take a specific interest in which nodes are being added below them.
 */
-(void) didAddDescendant: (CC3Node*) aNode { [_parent didAddDescendant: aNode]; }

/**
 * Invoked automatically when a node is removed as a child somewhere in the descendant structural
 * hierarchy of this node. The method is not only invoked on the immediate parent of the removed
 * node, but is actually invoked on all ancestors as well (parents of the parent).
 * This default implementation simply passes the notification up the parental ancestor chain.
 * Subclasses may override to take a specific interest in which nodes are being removed below them.
 */
-(void) didRemoveDescendant: (CC3Node*) aNode { [_parent didRemoveDescendant: aNode]; }

/**
 * Invoked automatically when a property was modified on a descendant node that potentially
 * affects its drawing order, relative to other nodes. This default implementation simply
 * passes the notification up the parental ancestor chain. Subclasses may override to take
 * a specific interest in which nodes need resorting below them.
 */
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode {
	[_parent descendantDidModifySequencingCriteria: aNode];
}

-(CC3Node*) getNodeNamed: (NSString*) aName {
	// First see if it's me
	if ([_name isEqual: aName] || (!_name && !aName)) return self;

	for (CC3Node* child in _children) {
		CC3Node* childResult = [child getNodeNamed: aName];
		if (childResult) return childResult;
	}
	return nil;
}

-(CC3Node*) getNodeTagged: (GLuint) aTag {
	if (_tag == aTag) return self;
	for (CC3Node* child in _children) {
		CC3Node* childResult = [child getNodeTagged: aTag];
		if (childResult) return childResult;
	}
	return nil;
}

-(NSArray*) flatten {
	NSMutableArray* allNodes = [NSMutableArray array];
	[self flattenInto: allNodes];
	return allNodes;
}

-(void) flattenInto: (NSMutableArray*) anArray {
	[anArray addObject: self];
	for (CC3Node* child in _children) [child flattenInto: anArray];
}

-(CC3Node*) asOrientingWrapper {
	CC3Node* wrap = [CC3Node nodeWithName: [NSString stringWithFormat: @"%@-OW", self.name]];
	wrap.shouldAutoremoveWhenEmpty = YES;
	[wrap addChild: self];
	return wrap;
}

-(CC3Node*) asTrackingWrapper {
	CC3Node* wrap = [self asOrientingWrapper];
	wrap.shouldTrackTarget = YES;
	return wrap;
}

-(CC3Node*) asCameraTrackingWrapper {
	CC3Node* wrap = [self asOrientingWrapper];
	wrap.shouldAutotargetCamera = YES;
	return wrap;
}

-(CC3Node*) asBumpMapLightTrackingWrapper {
	CC3Node* wrap = [self asTrackingWrapper];
	wrap.isTrackingForBumpMapping = YES;
	return wrap;
}


#pragma mark CC3Node Actions

-(CCAction*) runAction:(CCAction*) action {
	CC3Assert( action != nil, @"Argument must be non-nil");
	[CCDirector.sharedDirector.actionManager addAction: action target: self paused: !_isRunning];
	return action;
}

-(CCAction*) runAction: (CCAction*) action withTag: (NSInteger) aTag {
	[self stopActionByTag: aTag];
	action.tag = aTag;
	return [self runAction: action];
}

-(void) stopAllActions { [CCDirector.sharedDirector.actionManager removeAllActionsFromTarget: self]; }

-(void) stopAction: (CCAction*) action { [CCDirector.sharedDirector.actionManager removeAction: action]; }

-(void) stopActionByTag: (NSInteger) aTag {
	CC3Assert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[CCDirector.sharedDirector.actionManager removeActionByTag: aTag target: self];
}

-(CCAction*) getActionByTag: (NSInteger) aTag {
	CC3Assert( aTag != kCCActionTagInvalid, @"Invalid tag");
	return [CCDirector.sharedDirector.actionManager getActionByTag: aTag target: self];
}

-(NSInteger) numberOfRunningActions {
	return [CCDirector.sharedDirector.actionManager numberOfRunningActionsInTarget: self];
}

-(void) resumeAllActions { [CCDirector.sharedDirector.actionManager resumeTarget: self]; }

-(void) pauseAllActions { [CCDirector.sharedDirector.actionManager pauseTarget: self]; }

-(void) cleanupActions {
	[self stopAllActions];
	for (CC3Node* child in _children) {
		[child cleanupActions];
	}
}

// Deprecated
-(void) cleanup { [self cleanupActions]; }


#pragma mark Touch handling

-(BOOL) isTouchEnabled { return _touchEnabled; }
-(void) setTouchEnabled: (BOOL) canTouch { _touchEnabled = canTouch; }

// Deprecated
-(void) setIsTouchEnabled: (BOOL) canTouch { self.touchEnabled = canTouch; }

-(BOOL) isTouchable {
	return (self.visible || _shouldAllowTouchableWhenInvisible)
			&& (_touchEnabled || ((_parent && _shouldInheritTouchability) ? _parent.isTouchable : NO));
}

-(CC3Node*) touchableNode { return _touchEnabled ? self : (_parent ? _parent.touchableNode : nil); }

-(void) touchEnableAll {
	_touchEnabled = YES;
	for (CC3Node* child in _children) [child touchEnableAll];
}

-(void) touchDisableAll {
	_touchEnabled = NO;
	for (CC3Node* child in _children) [child touchDisableAll];
}


#pragma mark Intersections and collision detection

-(BOOL) shouldIgnoreRayIntersection {
	return _boundingVolume ? _boundingVolume.shouldIgnoreRayIntersection : YES;
}

-(void) setShouldIgnoreRayIntersection: (BOOL) shouldIgnore {
	_boundingVolume.shouldIgnoreRayIntersection = shouldIgnore;
}

-(BOOL) doesIntersectBoundingVolume: (CC3BoundingVolume*) otherBoundingVolume {
	return _boundingVolume && [_boundingVolume doesIntersect: otherBoundingVolume];
}

-(BOOL) doesIntersectNode: (CC3Node*) otherNode {
	return [self doesIntersectBoundingVolume: otherNode.boundingVolume];
}

-(BOOL) doesIntersectGlobalRay: (CC3Ray) aRay {
	return _boundingVolume && [_boundingVolume doesIntersectRay: aRay];
}

-(CC3Vector) locationOfGlobalRayIntesection: (CC3Ray) aRay {
	if (self.shouldIgnoreRayIntersection) return kCC3VectorNull;

	CC3Ray localRay = [self.globalTransformMatrixInverted transformRay: aRay];
	return [_boundingVolume locationOfRayIntesection: localRay];
}

-(CC3Vector) globalLocationOfGlobalRayIntesection: (CC3Ray) aRay {
	if ( !_boundingVolume ) return kCC3VectorNull;

	return [_boundingVolume globalLocationOfGlobalRayIntesection: aRay];
}

-(CC3NodePuncturingVisitor*) nodesIntersectedByGlobalRay: (CC3Ray) aRay {
	CC3NodePuncturingVisitor* pnv = [CC3NodePuncturingVisitor visitorWithRay: aRay];
	[pnv visit: self];
	return pnv;
}

-(CC3Node*) closestNodeIntersectedByGlobalRay: (CC3Ray) aRay {
	return [self nodesIntersectedByGlobalRay: aRay].closestPuncturedNode;
}


#pragma mark Developer support

/** Suffix used to name the descriptor child node. */
#define kDescriptorSuffix @"DESC"

/** The name to use when creating or retrieving the descriptor child node of this node. */
-(NSString*) descriptorName {
	return [NSString stringWithFormat: @"%@-%@", self.name, kDescriptorSuffix];
}

-(CC3NodeDescriptor*) descriptorNode {
	return (CC3NodeDescriptor*)[self getNodeNamed: [self descriptorName]];
}

-(ccColor3B) initialDescriptorColor { return CCC3BFromCCC4F(self.initialWireframeBoxColor); }

-(BOOL) shouldDrawDescriptor { return (self.descriptorNode != nil); }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {
	
	// Fetch the descriptor node from the child nodes.
	CC3NodeDescriptor* dn = self.descriptorNode;
	
	// If the descriptor node exists, but should not, remove it
	if (dn && !shouldDraw) {
		[dn remove];
	}
	
	// If there is no descriptor node, but there should be, add it by creating a
	// CC3NodeDescriptor from the description property and add it as a child of this node.
	if(!dn && shouldDraw) {
		CCLabelTTF* dnLabel = [CCLabelTTF labelWithString: self.description
												 fontName: @"Arial"
												 fontSize: [[self class] descriptorFontSize]];
		dn = [CC3NodeDescriptor nodeWithName: [self descriptorName] withBillboard: dnLabel];
		dn.color = self.initialDescriptorColor;
		[self addChild: dn];
	}
}

-(BOOL) shouldDrawAllDescriptors {
	if (!self.shouldDrawDescriptor) return NO;
	
	for (CC3Node* child in _children) {
		if (!child.shouldDrawAllDescriptors) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldDrawAllDescriptors: (BOOL) shouldDraw {
	self.shouldDrawDescriptor = shouldDraw;
	for (CC3Node* child in _children) {
		child.shouldDrawAllDescriptors = shouldDraw;
	}
}

// Initial font size for any new descriptors
static CGFloat descriptorFontSize = 8.0;

+(CGFloat) descriptorFontSize { return descriptorFontSize; }

+(void) setDescriptorFontSize: (CGFloat) fontSize { descriptorFontSize = fontSize; }


/** Suffix used to name the wireframe child node. */
#define kWireframeBoxSuffix @"WFB"

/** The name to use when creating or retrieving the wireframe child node of this node. */
-(NSString*) wireframeBoxName {
	return [NSString stringWithFormat: @"%@-%@", self.name, kWireframeBoxSuffix];
}

-(CC3WireframeBoundingBoxNode*) wireframeBoxNode {
	return (CC3WireframeBoundingBoxNode*)[self getNodeNamed: [self wireframeBoxName]];
}

-(BOOL) shouldDrawWireframeBox { return (self.wireframeBoxNode != nil); }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {
	
	// Fetch the wireframe node from the child nodes.
	CC3WireframeBoundingBoxNode* wf = self.wireframeBoxNode;
	
	// If the wireframe exists, but should not, remove it
	if (wf && !shouldDraw) {
		[wf remove];
	}
	
	// If there is no wireframe, but there should be, add it by creating a
	// CC3WireframeBoundingBoxNode from the boundingBox property and add it as a
	// child of this node. If the bounding box is null, don't create a wireframe.
	// The bounding box is set to update its vertices from the bounding box of
	// this node on each update pass to allow the wireframe to grow and shrink
	// along with the bounding box of this node and its descendants
	if(!wf && shouldDraw) {
		CC3Box bb = self.boundingBox;
		if ( !CC3BoxIsNull(bb) ) {
			wf = [CC3WireframeBoundingBoxNode nodeWithName: [self wireframeBoxName]];
			[wf populateAsWireBox: bb];
			wf.pureColor = self.initialWireframeBoxColor;
			wf.shouldAlwaysMeasureParentBoundingBox = YES;
			[self addChild: wf];
		}
	}
}

/** If default is transparent black, use the color of the node. */
-(ccColor4F) initialWireframeBoxColor {
	ccColor4F defaultColor = [[self class] wireframeBoxColor];
	return CCC4FAreEqual(defaultColor, kCCC4FBlackTransparent)
				? ccc4FFromccc3B(self.color) 
				: defaultColor;
}

// The default color to use when drawing the wireframes
static ccColor4F wireframeBoxColor = { 1.0, 1.0, 0.0, 1.0 };	// kCCC4FYellow

+(ccColor4F) wireframeBoxColor { return wireframeBoxColor; }

+(void) setWireframeBoxColor: (ccColor4F) aColor { wireframeBoxColor = aColor; }

-(BOOL) shouldDrawAllWireframeBoxes {
	if (!self.shouldDrawWireframeBox) {
		return NO;
	}
	for (CC3Node* child in _children) {
		if (!child.shouldDrawAllWireframeBoxes) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldDrawAllWireframeBoxes: (BOOL) shouldDraw {
	self.shouldDrawWireframeBox = shouldDraw;
	for (CC3Node* child in _children) {
		child.shouldDrawAllWireframeBoxes = shouldDraw;
	}
}

-(BOOL) shouldDrawAllLocalContentWireframeBoxes {
	for (CC3Node* child in _children) {
		if (!child.shouldDrawAllLocalContentWireframeBoxes) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldDrawAllLocalContentWireframeBoxes: (BOOL) shouldDraw {
	for (CC3Node* child in _children) {
		child.shouldDrawAllLocalContentWireframeBoxes = shouldDraw;
	}
}

-(void) addDirectionMarkerColored: (ccColor4F) aColor inDirection: (CC3Vector) aDirection {
	NSString* dmName = [NSString stringWithFormat: @"%@-DM-%@",
						self.name, NSStringFromCC3Vector(aDirection)];
	CC3DirectionMarkerNode* dm = [CC3DirectionMarkerNode nodeWithName: dmName];

	CC3Vector lineVertices[2] = { kCC3VectorZero, kCC3VectorZero };
	[dm populateAsLineStripWith: 2 vertices: lineVertices andRetain: YES];

	dm.markerDirection = aDirection;
	dm.lineWidth = 2.0;
	dm.pureColor = aColor;
	[self addChild: dm];
}

-(void) addDirectionMarker {
	[self addDirectionMarkerColored: [[self class] directionMarkerColor]
						inDirection: kCC3VectorUnitZNegative];
}

-(void) addAxesDirectionMarkers {
	[self addDirectionMarkerColored: kCCC4FRed inDirection: kCC3VectorUnitXPositive];
	[self addDirectionMarkerColored: kCCC4FGreen inDirection: kCC3VectorUnitYPositive];
	[self addDirectionMarkerColored: kCCC4FBlue inDirection: kCC3VectorUnitZPositive];
}

-(void) removeAllDirectionMarkers {
	NSArray* dirMks = self.directionMarkers;
	for (CC3Node* dm in dirMks) [dm remove];
	for (CC3Node* child in _children) [child removeAllDirectionMarkers];
}

-(NSArray*) directionMarkers {
	NSMutableArray* dirMks = [NSMutableArray array];
	for (CC3Node* child in _children)
		if ( [child isKindOfClass: [CC3DirectionMarkerNode class]] ) [dirMks addObject: child];
	return dirMks;
}

/** If default is transparent black, use the color of the node. */
-(ccColor4F) initialDirectionMarkerColor {
	ccColor4F defaultColor = [[self class] directionMarkerColor];
	return CCC4FAreEqual(defaultColor, kCCC4FBlackTransparent)
				? ccc4FFromccc3B(self.color)
				: defaultColor;
}

// The default color to use when drawing the direction markers
static ccColor4F directionMarkerColor = { 1.0, 0.0, 0.0, 1.0 };		// kCCC4FRed

+(ccColor4F) directionMarkerColor { return directionMarkerColor; }

+(void) setDirectionMarkerColor: (ccColor4F) aColor { directionMarkerColor = aColor; }

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

-(BOOL) shouldDrawAllBoundingVolumes {
	if (self.shouldDrawBoundingVolume) return YES;
	for (CC3Node* child in _children) if (child.shouldDrawAllBoundingVolumes) return YES;
	return NO;
}

-(void) setShouldDrawAllBoundingVolumes: (BOOL) shouldDraw {
	self.shouldDrawBoundingVolume = YES;
	for (CC3Node* child in _children) child.shouldDrawAllBoundingVolumes = YES;
}

-(BOOL) shouldLogIntersections {
	if (_boundingVolume && _boundingVolume.shouldLogIntersections) return YES;
	for (CC3Node* child in _children) if (child.shouldLogIntersections) return YES;
	return NO;
}

-(void) setShouldLogIntersections: (BOOL) shouldLog {
	if (shouldLog) [self createBoundingVolume];
	_boundingVolume.shouldLogIntersections = shouldLog;
	for (CC3Node* child in _children) child.shouldLogIntersections = shouldLog;
}

-(BOOL) shouldLogIntersectionMisses {
	if (_boundingVolume && _boundingVolume.shouldLogIntersectionMisses) return YES;
	for (CC3Node* child in _children) if (child.shouldLogIntersectionMisses) return YES;
	return NO;
}

-(void) setShouldLogIntersectionMisses: (BOOL) shouldLog {
	if (shouldLog) [self createBoundingVolume];
	_boundingVolume.shouldLogIntersectionMisses = shouldLog;
	for (CC3Node* child in _children) child.shouldLogIntersectionMisses = shouldLog;
}

@end
