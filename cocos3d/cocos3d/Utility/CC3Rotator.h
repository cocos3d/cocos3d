/*
 * CC3Rotator.h
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
 */

/** @file */	// Doxygen marker

#import "CC3GLMatrix.h"

@class CC3Node;


#pragma mark -
#pragma mark CC3Rotator

/** Enumeration of causes for why the transform matrix is dirty and needs to be recalculated. */
typedef enum {
	kCC3RotationMatrixIsNotDirty,				/**< No rotation properties have changed. */
	kCC3RotationMatrixIsDirtyByRotation,		/**< The rotation property was set. */
	kCC3RotationMatrixIsDirtyByQuaternion,		/**< The quaternion property was set. */
	kCC3RotationMatrixIsDirtyByAxisAngle,		/**< The rotationAxis or rotationAngle property was set. */
	kCC3RotationMatrixIsDirtyByDirection,		/**< The forwardDirection property was set. */
	kCC3RotationMatrixIsDirtyByTargetLocation,	/**< The targetLocation property was set (only applies to CC3DirectionalRotator). */
} CC3RotationMatrixDirtyCause;

/**
 * CC3otator encapsulates the various mechanisms of rotating a node, and converts
 * between them. Nodes delegate responsibility for managing their rotation to an
 * encapsulated instance of CC3Rotator.
 * 
 * Rotations can be read in any of the following forms:
 *   - three Euler angles
 *   - rotation angle around an arbitrary rotation axis
 *   - quaternion
 *
 * This base class represents a read-only rotator and performs only identity rotations.
 * It's primary purpose is to save memory in nodes that do not require any rotation.
 *
 * The CC3MutableRotator class adds the ability to set rotations, and is more commonly
 * used. The CC3DirectionalRotator class further adds directional rotational mechanisms
 * (such as pointing).
 *
 * The rotator maintains an internal rotationMatrix, separate from the node's
 * transformMatrix, and the rotator can use this rotationMatrix to convert between
 * different rotational specifications.
 */
@interface CC3Rotator : NSObject <NSCopying> {}

/**
 * Indicates whether this rotator supports changing rotation properties, including
 * rotation, quaternion, rotationAxis, and rotationAngle, and supports incremental
 * rotation through the rotateBy...family of methods.
 *
 * This implementation always returns NO. Subclasses that support changing rotation
 * properties will override.
 */
@property(nonatomic, readonly) BOOL isMutable;

/**
 * Indicates whether this rotator supports rotating to point towards a specific
 * direction (ie- "look-at").
 *
 * This implementation always returns NO. Subclasses that support pointing towards
 * a specific direction will override.
 */
@property(nonatomic, readonly) BOOL isDirectional;

/**
 * The rotation matrix derived from the rotation or quaternion properties. Rotation can be
 * specified in terms of either of these properties, and read by either property, even if set
 * by the other property. The matrix will reflect the rotational property most recently set.
 *
 * The rotation matrix for each instance is local to the node and does not include rotational
 * information about the node's ancestors.
 *
 * This base class always returns nil. Subclasses that support changing rotation will override.
 */
@property(nonatomic, retain, readonly) CC3GLMatrix* rotationMatrix;

/**
 * The rotational orientation of the node in 3D space, relative to the parent of the
 * node. This value contains three Euler angles, defining a rotation of this node
 * around the X, Y and Z axes. Each angle is specified in degrees.
 *
 * Rotation is performed in Y-X-Z order, which is the OpenGL default. Depending on
 * the nature of the object you are trying to control, you can think of this order
 * as yaw, then pitch, then roll, or heading, then inclination, then tilt,
 *
 * This base class always returns kCC3VectorZero.
 */
@property(nonatomic, assign, readonly) CC3Vector rotation;

/**
 * The rotation of the node in 3D space, relative to the parent of this node,
 * expressed as a quaternion.
 *
 * This base class always returns kCC3Vector4QuaternionIdentity.
 */
@property(nonatomic, assign, readonly) CC3Vector4 quaternion;

/**
 * The axis of rotation of the node in 3D space, relative to the parent of this
 * node, expressed as a directional vector. This axis can be used in conjunction
 * with the rotationAngle property to describe the rotation as a single angular
 * rotation around an arbitrary axis.
 *
 * This base class always returns kCC3VectorZero.
 */
@property(nonatomic, assign, readonly) CC3Vector rotationAxis;

/**
 * The angular rotation around the axis specified in the rotationAxis property.
 *
 * This base class always returns zero.
 */
@property(nonatomic, assign, readonly) GLfloat rotationAngle;

/**
 * The target node at which this rotator is pointed.
 *
 * Always returns nil. Subclasses that support target tracking will override.
 */
@property(nonatomic, assign, readonly) CC3Node* target;

/**
 * Indicates whether the node should track the node set in the target
 * property as the target and the node carrying this rotator move around.
 *
 * Always returns NO. Subclasses that support target tracking will override.
 */
@property(nonatomic, assign, readonly) BOOL shouldTrackTarget;

/**
 * Indicates whether the node should automatically find and track the camera
 * as its target. If this property is set to YES, the node will automatically
 * find and track the camera without having to set the target and shouldTrackTarget
 * properties explicitly.
 *
 * Always returns NO. Subclasses that support target tracking will override.
 */
@property(nonatomic, assign, readonly) BOOL shouldAutotargetCamera;

/**
 * Returns whether the node should rotate to face a target location.
 *
 * This implementation always returns NO.
 * Subclasses that support target locations will override.
 */
@property(nonatomic, readonly) BOOL shouldRotateToTargetLocation;

/** Marks that the global location of the node has changed. */
//-(void) markGlobalLocationChanged;

/**
 * Indicates how often the basis vectors of the underlying rotation matrix
 * should be orthonormalized.
 *
 * If this property is set to a value greater than zero, this rotator keeps track
 * of how many times one of the rotateBy... family of methods of a CC3MutableRotator
 * has been invoked. When that count reaches the value of this property, the
 * orthonormalize method is invoked to orthonormalize the underlying matrix, and
 * the count is set back to zero to start the cycle again. See the notes for the
 * CC3MutableRotator orthonormalize method for a further discussion of orthonormalization.
 *
 * If this property is set to zero, orthonormalization will not occur automatically.
 * The application can invoke the orthonormalize method to cause the rotation matrix
 * to be orthonormalized manually.
 *
 * The initial value of this property is zero, indicating that orthonormalization
 * will not occur automatically.
 */
+(GLubyte) autoOrthonormalizeCount;

/**
 * Sets how often the basis vectors of the underlying rotation matrix
 * should be orthonormalized.
 *
 * If this property is set to a value greater than zero, this rotator keeps track
 * of how many times one of the rotateBy... family of methods of a CC3MutableRotator
 * has been invoked. When that count reaches the value of this property, the
 * orthonormalize method is invoked to orthonormalize the underlying matrix, and
 * the count is set back to zero to start the cycle again. See the notes for the
 * CC3MutableRotator orthonormalize method for a further discussion of orthonormalization.
 *
 * If this property is set to zero, orthonormalization will not occur automatically.
 * The application can invoke the orthonormalize method to cause the rotation matrix
 * to be orthonormalized manually.
 *
 * The initial value of this property is zero, indicating that orthonormalization
 * will not occur automatically.
 */
+(void) setAutoOrthonormalizeCount: (GLubyte) aCount;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance with an identity rotationMatrix. */
+(id) rotator;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or
 * copyWithZone: method. In most situations, the application should use the
 * copy method, and should never need to invoke this method directly.
 * 
 * Subclasses that add additional instance state (instance variables) should extend
 * copying by overriding this method to copy that additional state. Superclass that
 * override this method should be sure to invoke the superclass implementation to
 * ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3Rotator*) another;

/**
 * Returns a string containing a more complete description of this rotator,
 * including rotation properties.
 */
-(NSString*) fullDescription;


#pragma mark Transformations

/**
 * Applies the rotationMatrix to the specified transform matrix.
 * This is accomplished by multiplying the transform matrix by the rotationMatrix.
 * This method is invoked automatically from the applyRotation method of the node.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) applyRotationTo: (CC3GLMatrix*) aMatrix;

@end

/**
 * CC3otator encapsulates the various mechanisms of rotating a node, and converts
 * between them. Nodes delegate responsibility for managing their rotation to an
 * encapsulated instance of CC3Rotator.
 * 
 * Rotations can be specified in any of the following methods:
 *   - three Euler angles
 *   - rotation angle around an arbitrary rotation axis
 *   - quaternion
 * Subclasses may also specify other rotational mechanisms (such as pointing).
 *
 * The rotator maintains an internal rotationMatrix, separate from the node's transformMatrix,
 * and the rotator can use this rotationMatrix to convert between different rotational
 * specifications. As such, the rotation of a node can be set using any one of the above
 * specifications, and read back as any of the other specifications.
 */
@interface CC3MutableRotator : CC3Rotator {
	CC3GLMatrix* rotationMatrix;
	CC3Vector rotation;
	CC3Vector4 quaternion;
	CC3Vector rotationAxis;
	GLfloat rotationAngle;
	GLubyte matrixIsDirtyBy;
	GLubyte orthonormalizationStartVector;
	GLubyte incrementalRotationCount;
	BOOL isRotationDirty;
	BOOL isQuaternionDirty;
	BOOL isAxisAngleDirty;
	BOOL isQuaternionDirtyByAxisAngle;
}

/**
 * The rotation matrix derived from the rotation or quaternion properties. Rotation can be
 * specified in terms of either of these properties, and read by either property, even if set
 * by the other property. The matrix will reflect the rotational property most recently set.
 *
 * The rotation matrix for each instance is local to the node and does not include rotational
 * information about the node's ancestors.
 */
@property(nonatomic, retain, readwrite) CC3GLMatrix* rotationMatrix;

/**
 * The rotational orientation of the node in 3D space, relative to the parent of the
 * node. This value contains three Euler angles, defining a rotation of this node
 * around the X, Y and Z axes. Each angle is specified in degrees.
 *
 * Rotation is performed in Y-X-Z order, which is the OpenGL default. Depending on
 * the nature of the object you are trying to control, you can think of this order
 * as yaw, then pitch, then roll, or heading, then inclination, then tilt,
 *
 * When setting this value, each component is converted to modulo +/-360 degrees.
 */
@property(nonatomic, assign, readwrite) CC3Vector rotation;

/**
 * The rotation of the node in 3D space, relative to the parent of this node,
 * expressed as a quaternion.
 */
@property(nonatomic, assign, readwrite) CC3Vector4 quaternion;

/**
 * The axis of rotation of the node in 3D space, relative to the parent of this
 * node, expressed as a directional vector. This axis can be used in conjunction
 * with the rotationAngle property to describe the rotation as a single angular
 * rotation around an arbitrary axis.
 */
@property(nonatomic, assign, readwrite) CC3Vector rotationAxis;

/**
 * The angular rotation around the axis specified in the rotationAxis property.
 *
 * When setting this value, it is converted to modulo +/-360 degrees.
 */
@property(nonatomic, assign, readwrite) GLfloat rotationAngle;

/** Rotates this rotator from its current state by the specified Euler angles in degrees. */
-(void) rotateBy: (CC3Vector) aRotation;

/** Rotates this rotator from its current state by the specified quaternion. */
-(void) rotateByQuaternion: (CC3Vector4) aQuaternion;

/**
 * Rotates this rotator from its current state by rotating around
 * the specified axis by the specified angle in degrees.
 */
-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis;

/**
 * When a large number of incremental rotations are applied to a rotator using
 * the rotateBy... family of methods, accumulated rounding errors can cause the
 * basis vectors of the underlying rotation matrix to lose mutual orthogonality
 * (no longer be orthogonal to each other), and to become individually unnormalized
 * (no longer be unit vectors).
 * 
 * Although uncommon, it is possible for visible errors to creep into the
 * rotation of this rotator, after many, many incremental rotations.
 *
 * If this happens, you can invoke this method to orthonormalize the basis vectors of
 * the underlying rotation matrix. You can also set the class-side autoOrthonormalizeCount
 * property to have this method automatically invoked periodically.
 *
 * Upon completion of this method, each basis vector in the underlying matrix will
 * be a unit vector that is orthagonal to the other two basis vectors in this matrix.
 *
 * Error creep only appears through repeated use of the the rotateBy... family
 * of methods. Error creep does not occur when the rotation is set explicitly
 * through any of the rotation properties (rotation, quaternion,
 * rotationAxis/rotationAngle, etc), as these properties populate the rotation
 * matrix directly in orthonormal form each time then are set. Use of this
 * method is not needed if rotations have been set directly using these
 * properties, even when set many times.
 *
 * This method uses using a Gram-Schmidt process to orthonormalize the basis
 * vectors of the underlying rotation matrix. The Gram-Schmidt process is biased
 * towards the basis vector chosen to start the calculation process. To minimize
 * the effect of this, this implementation chooses a different basis vector to
 * start the orthonormalization process each time this method is invoked, to
 * average the bias across all basis vectors over time.
 */
-(void) orthonormalize;


#pragma mark Allocation and initialization

/** Initializes this instance to use the specified matrix as the rotationMatrix. */
-(id) initOnRotationMatrix: (CC3GLMatrix*) aGLMatrix;

/** Allocates and initializes an autoreleased instance to use the specified matrix as the rotationMatrix. */
+(id) rotatorOnRotationMatrix: (CC3GLMatrix*) aGLMatrix;

@end


#pragma mark -
#pragma mark CC3DirectionalRotator

/**
 * Enumeration of options for restricting rotation of a CC3Node to rotate only
 * around a single axis when attempting to point at a target node or targetLocation.
 */
typedef enum {
	kCC3TargettingAxisRestrictionNone,		/**< Don't restrict targetting rotations. */
	kCC3TargettingAxisRestrictionXAxis,		/**< Only rotate around the X-axis. */
	kCC3TargettingAxisRestrictionYAxis,		/**< Only rotate around the Y-axis. */
	kCC3TargettingAxisRestrictionZAxis,		/**< Only rotate around the Z-axis. */
} CC3TargettingAxisRestriction;

/**
 * This CC3MutableRotator subclass adds the ability to set rotation based on directional information.
 * 
 * In addition to specifying rotations in terms of three Euler angles, a rotation axis and
 * a rotation angle, or a quaternion, rotations of this class can be specified in terms of
 * pointing in a particular forwardDirection, and orienting so that 'up' is in a particular
 * sceneUpDirection.
 *
 * The directional rotator keeps track of a number of properties related to tracking another
 * node, on behalf of the node containing this rotator, particularly when it comes to tracking
 * the location of another node.
 *
 * The rotationMatrix of this rotator can be used to convert between directional rotation,
 * Euler angles, and quaternions. As such, the rotation of a node can be specified as a
 * quaternion or a set of Euler angles, and then read back as a fowardDirection, upDirection,
 * and rightDirection. Or, conversely, rotation may be specified by pointing to a particular
 * forwardDirection and sceneUpDirection, and then read as a quaternion or a set of Euler angles.
 */
@interface CC3DirectionalRotator : CC3MutableRotator {
	CC3Node* target;
	CC3Vector targetLocation;
	CC3Vector forwardDirection;
	CC3Vector sceneUpDirection;
	CC3Vector upDirection;
	CC3Vector rightDirection;
	GLubyte axisRestriction;
	BOOL isForwardDirectionDirty;
	BOOL isUpDirectionDirty;
	BOOL isRightDirectionDirty;
	BOOL isNewTarget;
	BOOL shouldTrackTarget;
	BOOL shouldAutotargetCamera;
	BOOL isTrackingForBumpMapping;
	BOOL isTargetLocationDirty;
}

/**
 * Indicates whether this rotator supports rotating to point towards a specific
 * direction (ie- "look-at").
 *
 * This implementation always returns YES.
 */
@property(nonatomic, readonly) BOOL isDirectional;

/**
 * The direction towards which this node is pointing, relative to the parent of the node.
 *
 * A valid direction vector is required. Attempting to set this property
 * to the zero vector (kCC3VectorZero) will raise an assertion error.
 *
 * See the discussion in the notes of the same property in CC3Node for more info.
 *
 * The initial value of this property is kCC3VectorUnitZPositive.
 */
@property(nonatomic, assign) CC3Vector forwardDirection;

/**
 * The direction, in the global coordinate system, that is considered to be 'up'.
 *
 * A valid direction vector is required. Attempting to set this property
 * to the zero vector (kCC3VectorZero) will raise an assertion error.
 *
 * See the discussion in the notes of the same property in CC3Node for more info.
 *
 * The initial value of this property is kCC3VectorUnitYPositive.
 */
@property(nonatomic, assign) CC3Vector sceneUpDirection;

/** @deprecated Renamed to sceneUpDirection. */
@property(nonatomic, assign) CC3Vector worldUpDirection DEPRECATED_ATTRIBUTE;

/**
 * The direction, in the node's coordinate system, that is considered to be 'up'.
 * This corresponds to the sceneUpDirection, after it has been transformed by
 * the rotationMatrix of this instance.
 *
 * See the discussion in the notes of the same property in CC3Node for more info.
 *
 * The initial value of this property is kCC3VectorUnitYPositive.
 */
@property(nonatomic, assign, readonly) CC3Vector upDirection;

/**
 * The direction in the node's coordinate system that would be considered to be
 * "off to the right" relative to the forwardDirection and upDirection.
 * 
 * See the discussion in the notes of the same property in CC3Node for more info.
 *
 * The initial value of this property is kCC3VectorUnitXPositive.
 */
@property(nonatomic, assign, readonly) CC3Vector rightDirection;

/** 
 * The global location towards which this node is facing.
 *
 * The target location is determined by the node and is cached by the directional rotator.
 */
@property(nonatomic, assign) CC3Vector targetLocation;

/** 
 * Sets the targetLocation property without marking this rotator
 * as being dirty and in need of recalculation.
 */
-(void) setRawTargetLocation: (CC3Vector) targLoc;

/**
 * Indicates whether rotation should be restricted to a single axis when attempting
 * to rotate the node to point at the target or targetLocation.
 *
 * The initial value of this property is kCC3TargettingAxisRestrictionNone.
 */
@property(nonatomic, assign) CC3TargettingAxisRestriction axisRestriction;

/** Returns whether the target location is dirty and needs to be recalculated and reset. */
@property(nonatomic, readonly) BOOL isTargetLocationDirty;

/**
 * If the targetLocation was recently set, set the forwardDirection to
 * point to it from the specified location, which is the location of
 * the node holding this rotator, in the global coordinate system.
 *
 * If the specified location is the same as the targetLocation, it is
 * not possible to set the foward direcion, and so the request is ignored.
 */
-(void) rotateToTargetLocationFrom: (CC3Vector) aLocation;

/**
 * The target node at which this rotator is pointed. If the shouldTrackTarget property
 * is set to YES, the node will track the target so that it always points to the
 * target, regardless of how the target and this node move through the 3D scene.
 *
 * The target is not retained. If you destroy the target node, you must remove
 * it as the target of this rotator.
 */
@property(nonatomic, assign, readwrite) CC3Node* target;

/**
 * Indicates whether the node should track the node set in the target property
 * as the target and the node carrying this rotator move around.
 *
 * This initial value of this property is NO.
 */
@property(nonatomic, assign, readwrite) BOOL shouldTrackTarget;

/**
 * Indicates whether the node should automatically find and track the camera
 * as its target. If this property is set to YES, the node will automatically
 * find and track the camera without having to set the target and shouldTrackTarget
 * properties explicitly.
 *
 * This initial value of this property is NO.
 */
@property(nonatomic, assign, readwrite) BOOL shouldAutotargetCamera;

/**
 * Returns whether the node should update itself towards the target.
 *
 * Returns YES if the target property is set and the shouldTrackTarget returns YES.
 */
@property(nonatomic, readonly) BOOL shouldUpdateToTarget;

/**
 * Returns whether this node should rotate to face the targetLocation.
 * It will do so if it is not tracking for bump-mapping purposes, and the 
 * targetDirection was just set, or shouldTrackTarget is YES.
 */
@property(nonatomic, readonly) BOOL shouldRotateToTargetLocation;

/**
 * If the taget node of the node carrying this rotator is a CC3Light, the target
 * can be tracked by the node for the purpose of updating the lighting of a contained
 * bump-map texture, instead of rotating to face the light, as normally occurs with tracking.
 * 
 * This property indicates whether the node should update its globalLightLocation
 * from the tracked location of the light, instead of rotating to face the light.
 *
 * The initial property is set to NO.
 */
@property(nonatomic, assign) BOOL isTrackingForBumpMapping;

@end


#pragma mark -
#pragma mark CC3ReverseDirectionalRotator

/**
 * A directional rotator that orients the node such that the positive-Z axis
 * of the node's local coordinates points in the fowardDirection.
 *
 * This is opposite to the parent class behaviour, which orients the node such that
 * the negative-Z axis of the node's local coordinates points in the fowardDirection
 */
@interface CC3ReverseDirectionalRotator : CC3DirectionalRotator
@end
