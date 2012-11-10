/*
 * CC3Node.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Identifiable.h"
#import "CC3Matrix.h"
#import "CC3Rotator.h"
#import "CC3NodeVisitor.h"
#import "CC3BoundingVolumes.h"
#import "CCAction.h"
#import "CCProtocols.h"

@class CC3NodeDrawingVisitor, CC3Scene, CC3Camera, CC3Frustum;
@class CC3NodeAnimation, CC3NodeDescriptor, CC3WireframeBoundingBoxNode;

/**
 * Enumeration of options for scaling normals after they have been transformed during
 * vertex drawing.
 */
typedef enum {
	kCC3NormalScalingNone,			/**< Don't resize normals. */
	kCC3NormalScalingRescale,		/**< Uniformly rescale normals using model-view matrix. */
	kCC3NormalScalingNormalize,		/**< Normalize each normal after tranformation. */
	kCC3NormalScalingAutomatic,		/**< Automatically determine optimal normal scaling method. */
} CC3NormalScaling;


#pragma mark -
#pragma mark CC3NodeListenerProtocol

/**
 * This protocol defines the behaviour requirements for objects that wish to be
 * notified about the basic existence of a node.
 */
@protocol CC3NodeListenerProtocol

/**
 * Callback method that will be invoked when the node has been deallocated.
 *
 * Although the sending node is still alive when sending this message, its state is
 * unpredictable, because all subclass state will have been released or detroyed when
 * this message is sent. The receiver of this message should not attempt to send any
 * messages to the sender. Instead, it should simply clear any references to the node.
 */
-(void) nodeWasDestroyed: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3NodeTransformListenerProtocol

/**
 * This protocol defines the behaviour requirements for objects that wish to be
 * notified whenever the transform of a node has changed.
 *
 * This occurs when one of the transform properties (location, rotation & scale)
 * of the node, or any of its structural ancestor nodes, has changed.
 *
 * A transform listener can be registered with a node via the addTransformListener: method.
 *
 * Each listener registered with a node will be sent the nodeWasTransformed: notification
 * message when the transformMatrix of this node is recalculated, or is set directly.
 */
@protocol CC3NodeTransformListenerProtocol <CC3NodeListenerProtocol>

/** Callback method that will be invoked when the transformMatrix of the specified node has changed. */
-(void) nodeWasTransformed: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3Node

/**
 * CC3Node and its subclasses form the basis of all 3D artifacts in the 3D scene, including
 * visible meshes, structures, cameras, lights, resources, and the 3D scene itself.
 *
 * Nodes can be moved, rotated and scaled. Rotation can be specified via Euler angles,
 * quaternions, rotation axis and angle, or changes to any of these properties.
 *
 * In addition to programmatically rotating a node using the rotation quaternion, rotationAxis,
 * and rotationAngle properties, or one of the rotateBy...: methods, you can set a node to point
 * towards a particular direction, location. You can even point a node towards another target
 * node, and have it track that node, so that it always points towards the target node, as
 * either the node, or the target node move around.
 *
 * For more on targetting the node in a direction, or to track a target node, see the notes
 * of the following properties and methods:
 *   - target
 *   - targetLocation
 *   - shouldTrackTarget
 *   - targettingConstraint
 *   - shouldAutotargetCamera
 *   - isTrackingForBumpMapping
 *
 * Nodes can be assembled in a structural hierarchy of parents and children, using the addChild:
 * method. Transformations that are applied to a node are also applied to its descendant nodes.
 * Typically, the root of a structural node hierarchy is an instance of CC3Scene.
 *
 * When creating a structural hierarchy of nodes, it is often useful to wrap one node in another
 * node in order to orient the node of interest in a particular direction, or provide an offset
 * location in order to allow the node of interest to visually anchored at a location other than
 * its origin. To easily wrap a node in another node, use the following methods:
 *   - asOrientingWrapper
 *   - asTrackingWrapper
 *   - asCameraTrackingWrapper
 *   - asBumpMapLightTrackingWrapper
 *
 * Each node is automatically touched at two distinct times during animation frame handling.
 * First, the updateBeforeTransform: and updateAfterTransform: methods are each invoked during
 * scheduled model state updating, before and after the transformation matrix of the node is
 * rebuilt, respectively. You should override udpateBeforeTransform: method to make any changes
 * to the node, or its child nodes.
 * 
 * You should override updateAfterTransform: only if you need to make use of the global
 * properties of the node or its child nodes, such as globalLocation, globalRotation, or
 * globalScale. These properties are valid only after the transformMatrix has been
 * calculated, and are therefore not valid within the updateBeforeTransform: method.
 * However, if you make any changes to the transform properties (location, rotation, scale)
 * of a node within the updateAfterTransform: method, you must invoke the updateTransformMatrices
 * method on that node in order to have the changes applied to the node's transformMatrix.
 * 
 * Note that you do NOT need to invoke the updateTransformMatrices method for any changes
 * made in the updateBeforeTransform: method, since those changes will automatically be
 * applied to the transformMatrix.
 *
 * The second place a node is touched is the transformAndDrawWithVisitor: method,
 * which is automaticaly invoked during each frame rendering cycle. You should have
 * no need to override this method.
 * 
 * To maximize throughput, the operations of updating model state should be kept
 * separate from the operations of frame rendering, and the two should not be mixed.
 * Subclasses should respect this design pattern when overriding behaviour. Drawing
 * operations should not be included in state updating, and vice versa. Since OpenGL is
 * a hardware-accelerated state-machine pipeline, this separation allows frame-drawing
 * operations to be performed by the GPU at the same time that state update operations for
 * the next frame are being handled by the CPU, and on some systems, permits frame drawing
 * and model updating to be perfomed on separate threads.
 *
 * CC3Nodes support the cocos2d CCAction class hierarchy. Nodes can be translated, rotated,
 * and scaled in three dimensions, or made to point towards a direction (for cameras and
 * lights), all under control of cocos2d CCActions. As with other CCActions, these actions
 * can be combined into action sequences or repeating actions, or modified with cocos2d
 * ease actions. See the class CC3TransformTo and its subclasses for actions that operate
 * on CC3Nodes.
 *
 * When populating your scene, you can easily create hordes of similar nodes using the copy
 * and copyWithName: methods. Those methods effect deep copies to allow each copy to be
 * manipulated independently, but will share underlying mesh data for efficient memory use.
 * See the notes at the copy method for more details about copying nodes.
 *
 * You can animate this class with animation data held in a subclass of CC3NodeAnimation.
 * To animate this node using animation data, set the animation property to an instance of
 * a subclass of the abstract CC3NodeAnimation class, populated with animation data, and
 * then create an instance of a CC3Animate action, and run it on this node.
 *
 * Nodes can respond to iOS touch events. The property isTouchEnabled can be set to YES
 * to allow a node to be selected by a touch event. If the shouldInheritTouchability
 * property is also set to YES, then this touchable capability can also be inherited from
 * a parent node. Selection of nodes based on touch events is handled by CC3Scene. The
 * nodeSelected:byTouchEvent:at: callback method of your customized CC3Scene will be
 * invoked to indicate which node has been touched.
 *
 * You can cause a wireframe box to be drawn around the node and all its descendants by
 * setting the shouldDrawWireframeBox property to YES. This can be particularly useful
 * during development to locate the boundaries of a node, or to locate a node that is not
 * drawing properly. You can set the default color of this wireframe using the class-side
 * defaultWireframeBoxColor property.
 *
 * You can also cause the name of the node to be displayed where the node is by setting 
 * the shouldDrawDescriptor property to YES. This is also useful for locating a node when
 * debugging rendering problems.
 *
 * To maximize GL throughput, all OpenGL ES 1.1 state is tracked by the singleton instance
 * [CC3OpenGLES11Engine engine]. CC3OpenGLES11Engine only sends state change calls to the
 * GL engine if GL state really is changing. It is critical that all changes to GL state
 * are made through the CC3OpenGLES11Engine singleton. When adding or overriding functionality
 * in this framework, do NOT make gl* function calls directly if there is a corresponding
 * state change tracker in the CC3OpenGLES11Engine singleton. Route the state change request
 * through the CC3OpenGLES11Engine singleton instead.
 */
@interface CC3Node : CC3Identifiable <CCRGBAProtocol, CCBlendProtocol, CC3NodeTransformListenerProtocol> {
	CCArray* children;
	CC3Node* parent;
	CC3Matrix* transformMatrix;
	CC3Matrix* transformMatrixInverted;
	CCArray* transformListeners;
	CC3Matrix* globalRotationMatrix;
	CC3Rotator* rotator;
	CC3NodeBoundingVolume* boundingVolume;
	CC3NodeAnimation* animation;
	CC3Vector location;
	CC3Vector globalLocation;
	CC3Vector projectedLocation;
	CC3Vector scale;
	CC3Vector globalScale;
	GLfloat boundingVolumePadding;
	BOOL isTransformDirty : 1;
	BOOL isTransformInvertedDirty : 1;
	BOOL isGlobalRotationDirty : 1;
	BOOL isTouchEnabled : 1;
	BOOL shouldInheritTouchability : 1;
	BOOL shouldAllowTouchableWhenInvisible : 1;
	BOOL isAnimationEnabled : 1;
	BOOL visible : 1;
	BOOL isRunning : 1;
	BOOL shouldAutoremoveWhenEmpty : 1;
	BOOL shouldUseFixedBoundingVolume : 1;
	BOOL shouldStopActionsWhenRemoved : 1;
}

/**
 * The location of the node in 3D space, relative to the parent of this node. The global
 * location of the node is therefore a combination of the global location of the parent
 * of this node and the value of this location property.
 */
@property(nonatomic, assign) CC3Vector location;

/**
 * The location of the node in 3D space, relative to the global origin.
 * 
 * This is calculated by using the transformMatrix to tranform the local origin (0,0,0).
 */
@property(nonatomic, readonly) CC3Vector globalLocation;

/**
 * Translates the location of this node by the specified vector.
 *
 * The incoming vector specify the amount of change in location,
 * not the final location.
 */
-(void) translateBy: (CC3Vector) aVector;

/**
 * Returns the rotator that manages the local rotation of this node.
 *
 * CC3Rotator is the base class of a class cluster, of which different subclasses perform
 * different types of rotation. The type of object returned by this property may change,
 * depending on what rotational changes have been made to this node.
 *
 * For example, if no rotation is applied to this node, this property will return a base
 * CC3Rotator. After the rotation of this node has been changed, this property will return
 * a CC3MutableRotator, and if directional properties, such as forwardDirection have been
 * accessed or changed, this property will return a CC3DirectionalRotator. The creation
 * of the type of rotator required to support the various rotations is automatic.
 */
@property(nonatomic, retain) CC3Rotator* rotator;

/**
 * The rotational orientation of the node in 3D space, relative to the parent of this node.
 * The global rotation of the node is therefore a combination of the global rotation of the
 * parent of this node and the value of this rotation property. This value contains three
 * Euler angles, defining a rotation of this nodearound the X, Y and Z axes. Each angle is
 * specified in degrees.
 *
 * Rotation is performed in Y-X-Z order, which is the OpenGL default. Depending on the
 * nature of the object you are trying to control, you can think of this order as yaw,
 * then pitch, then roll, or heading, then inclination, then tilt,
 *
 * When setting this value, each component is converted to modulo +/-360 degrees.
 *
 * Rotational transformation can also be specified using the rotationAxis and rotationAngle
 * properties, or the quaternion property. Subsequently, this property can be read to return
 * the corresponding Euler angles.
 */
@property(nonatomic, assign) CC3Vector rotation;

/**
 * Returns the overall rotation of the node in 3D space, relative to the global X, Y & Z axes.
 * The returned value contains three Euler angles, specified in degrees, defining a global
 * rotation of this node around the X, Y and Z axes.
 */
@property(nonatomic, readonly) CC3Vector globalRotation;

/**
 * Rotates this node from its current rotational state by the specified Euler angles in degrees.
 *
 * The incoming Euler angles specify the amount of change in rotation, not the final rotational state.
 */
-(void) rotateBy: (CC3Vector) aRotation;

/**
 * The rotation of the node in 3D space, relative to the parent of this node, expressed
 * as a quaternion.
 *
 * Rotational transformation can also be specified using the rotation property (Euler angles),
 * or the rotationAxis and rotationAngle properties. Subsequently, this property can be read
 * to return the corresponding quaternion.
 */
@property(nonatomic, assign) CC3Quaternion quaternion;

/**
 * Rotates this node from its current rotational state by the specified quaternion.
 *
 * The incoming quaternion specifies the amount of change in rotation,
 * not the final rotational state.
 */
-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion;

/**
 * The axis of rotation of the node in 3D space, relative to the parent of this node,
 * expressed as a directional vector. This axis can be used in conjunction with the
 * rotationAngle property to describe the rotation as a single angular rotation around
 * an arbitrary axis.
 *
 * Under the identity rotation (no rotation), the rotationAngle is zero and the rotationAxis
 * is undefined. Under that condition, this property will return the zero vector kCC3VectorZero.
 *
 * Rotational transformation can also be specified using the rotation property (Euler
 * angles), or the quaternion property. Subsequently, this property can be read to return
 * the corresponding axis of rotation.
 */
@property(nonatomic, assign) CC3Vector rotationAxis;

/**
 * The angular rotation around the axis specified in the rotationAxis property.
 *
 * Rotational transformation can also be specified using the rotation property (Euler
 * angles), or the quaternion property. Subsequently, this property can be read to
 * return the corresponding angle of rotation.
 *
 * When setting this value, it is converted to modulo +/-360 degrees. When reading this
 * value after making changes using rotateByAngle:aroundAxis:, or using another rotation
 * property, the value of this property will be clamped to +/-180 degrees.
 *
 * For example, if current rotation is 170 degrees around the rotationAxis, invoking
 * the rotateByAngle:aroundAxis: method using the same rotation axis and 20 degrees,
 * reading this property will return -170 degrees, not 190 degrees.
 */
@property(nonatomic, assign) GLfloat rotationAngle;

/**
 * Rotates this node from its current rotational state by rotating around
 * the specified axis by the specified angle in degrees.
 *
 * The incoming axis and angle specify the amount of change in rotation,
 * not the final rotational state.
 *
 * Thanks to cocos3d user nt901 for contributing to the development of this feature
 */
-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis;

/**
 * The direction in which this node is pointing.
 *
 * The value of this property is specified in the local coordinate system of this node.
 *
 * The initial value of this property is kCC3VectorUnitZPositive, pointing down the positive
 * Z-axis in the local coordinate system of this node. When this node is rotated, the original
 * positive-Z axis of the node's local coordinate system will point in this direction.
 *
 * Pointing the node in a particular direction does not fully define its rotation in 3D space,
 * because the node can be oriented in any rotation around the axis along the forwardDirection
 * vector (think of pointing a camera at a scene, and then rotating the camera along the axis
 * of its lens, landscape towards portrait).
 *
 * The orientation around this axis is defined by specifying an additional 'up' direction, which
 * fixes the rotation around the forwardDirection by specifying which direction is considered to
 * be 'up'. The 'up' direction is specified by setting the referenceUpDirection property, which
 * is independent of the tilt of the local axes, and does not need to be perpendicular to the
 * forwardDirection.
 *
 * The value returned for this property is of unit length. When setting this
 * property, the value will be normalized to be a unit vector.
 *
 * A valid direction vector is required. Attempting to set this property
 * to the zero vector (kCC3VectorZero) will raise an assertion error.
 */
@property(nonatomic, assign) CC3Vector forwardDirection;

/**
 * The direction in which this node is pointing, relative to the global
 * coordinate system. This is calculated by using the transformMatrix
 * to translate the forwardDirection.
 *
 * The value returned is of unit length. 
 */
@property(nonatomic, readonly) CC3Vector globalForwardDirection;

/**
 * The direction that is considered to be 'up' when rotating to face in a particular direction,
 * by using one of the directional properties forwardDirection, target, or targetLocation.
 *
 * As explained in the note for the forwardDirection, specifying a forwardDirection alone is not
 * sufficient to determine the rotation of a node in 3D space. This property indicates which
 * direction should be considered 'up' when orienting the rotation of the node to face a direction,
 * target, or target location.
 * 
 * The interpretation of whether the value of this property is specified in local or global
 * coordinates depends on how the direction of pointing is being specified. 
 *
 * When using the forwardDirection property, the value of this property is taken to be specified
 * in the local coordinate system. When using either the target or targetLocation properties,
 * the interpretation of whether the value of this property is specified in the local or global
 * coordinate system is determined by the value of the targettingConstraint property.
 *
 * The initial value of this property is kCC3VectorUnitYPositive, pointing parallel
 * to the positive Y-axis, and in most cases, this property can be left with that value.
 *
 * The value returned is of unit length. When setting this property, the value will be normalized
 * to be a unit vector.
 *
 * When setting this property, a valid direction vector is required. Attempting to set this
 * property to the zero vector (kCC3VectorZero) will raise an assertion error.
 */
@property(nonatomic, assign) CC3Vector referenceUpDirection;

/** @deprecated Renamed to referenceUpDirection. */
@property(nonatomic, assign) CC3Vector sceneUpDirection DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to referenceUpDirection. */
@property(nonatomic, assign) CC3Vector worldUpDirection DEPRECATED_ATTRIBUTE;

/**
 * The direction, in the node's coordinate system, that is considered to be 'up'.
 * This corresponds to the referenceUpDirection, after it has been transformed by the
 * rotations of this node. For example, rotating the node upwards to point towards
 * an elevated target will move the upDirection of this node away from the
 * referenceUpDirection.
 *
 * The value returned by this property is in the local coordinate system of this node,
 * except when this node is actively tracking a target node (the shouldTrackTarget
 * property is YES), in which case, the value returned will be a global direction in
 * the global coordinate system.
 *
 * The value returned is of unit length. 
 */
@property(nonatomic, readonly) CC3Vector upDirection;

/**
 * The direction that is considered to be 'up' for this node, relative to the
 * global coordinate system. This is calculated by using the transformMatrix to
 * translate the upDirection. As the node is rotated from its default orientation,
 * this value will be different than the referenceUpDirection, which is fixed and
 * independent of the orientation of the node.
 *
 * The value returned is of unit length. 
 */
@property(nonatomic, readonly) CC3Vector globalUpDirection;

/**
 * The direction in the node's coordinate system that would be considered to be
 * "off to the right" when looking out from the node, along the forwardDirection
 * and with the upDirection defined.
 *
 * The value returned by this property is in the local coordinate system of this node,
 * except when this node is actively tracking a target node (the shouldTrackTarget
 * property is YES), in which case, the value returned will be a global direction in
 * the global coordinate system.
 *
 * The value returned is of unit length. 
 */
@property(nonatomic, readonly) CC3Vector rightDirection;

/**
 * The direction that is considered to be "off to the right" for this node,
 * relative to the global coordinate system. This is calculated by using the
 * transformMatrix to translate the rightDirection.
 *
 * The value returned is of unit length. 
 */
@property(nonatomic, readonly) CC3Vector globalRightDirection;

/**
 * The scale of the node in each dimension, relative to the parent of this node.
 *
 * Unless non-uniform scaling is needed, it is recommended that you use the uniformScale
 * property instead.
 */
@property(nonatomic, assign) CC3Vector scale;

/**
 * The scale of the node in 3D space, relative to the global coordinate system,
 * and accumulating the scaling of all ancestor nodes.
 */
@property(nonatomic, readonly) CC3Vector globalScale;

/**
 * The scale of the node, uniform in each dimension, relative to the parent of this node.
 *
 * Unless non-uniform scaling is needed, it is recommended that you use this property instead
 * of the scale property.
 *
 * If non-uniform scaling is applied via the scale property, this uniformScale property will
 * return the length of the scale property vector divided by the length of a unit cube (sqrt(3.0)),
 * as an approximation of the overall scaling condensed to a single scalar value.
 */
@property(nonatomic, assign) GLfloat uniformScale;

/**
 * Indicates whether current local scaling (via the scale property) is uniform along all axes.
 *
 * This property does not take into consideration the scaling of any ancestors.
 */
@property(nonatomic, readonly) BOOL isUniformlyScaledLocally;

/**
 * Indicates whether current global scaling is uniform along all axes.
 *
 * This property takes into consideration the scaling of all ancestors.
 */
@property(nonatomic, readonly) BOOL isUniformlyScaledGlobally;

/**
 * Returns whether the current transform applied to this node is rigid.
 *
 * A rigid transform contains only rotation and translation transformations, and does not include scaling.
 *
 * This implementation returns the value of the isRigid property of the transformMatrix.
 */
@property(nonatomic, readonly) BOOL isTransformRigid;

/**
 * @deprecated This property is no longer needed, since the rigidity of a node transform is
 * now tracked by the transformMatrix itself. This property will always return zero. Setting
 * this property will have no effect.
 */
@property(nonatomic, assign) GLfloat scaleTolerance DEPRECATED_ATTRIBUTE;

/**
 * @deprecated This property is no longer needed, since the rigidity of a node transform is
 * now tracked by the transformMatrix itself. This property will always return zero.
 */
+(GLfloat) defaultScaleTolerance DEPRECATED_ATTRIBUTE;

/**
 * @deprecated This property is no longer needed, since the rigidity of a node transform is
 * now tracked by the transformMatrix itself. Setting this property will have no effect.
 */
+(void) setDefaultScaleTolerance: (GLfloat) aTolerance DEPRECATED_ATTRIBUTE;

/**
 * The bounding volume of this node. This is used by culling during drawing operations,
 * it can be used by the application to detect when two nodes intersect in space
 * (collision detection), and it can be used to determine whether a node intersects
 * a specific location, ray, or plane.
 *
 * Different shapes of boundaries are available, permitting tradeoffs between
 * accuracy and computational processing time.
 *
 * By default, nodes do not have a bounding volume. Subclasses may set a suitable
 * bounding volume.
 *
 * You can make the bounding volume of any node visible by setting the
 * shouldDrawBoundingVolume property to YES. You can use the shouldDrawAllBoundingVolumes
 * property to make the bounding volumes of this node and all its descendants visible
 * by setting the shouldDrawAllBoundingVolumes property to YES.
 */
@property(nonatomic, retain) CC3NodeBoundingVolume* boundingVolume;

/**
 * Padding that is added to all edges of the bounding volume, when the bounding volume or the
 * boundingBox property is determined.
 *
 * You can use this to establish a "buffer zone" around the node when creating bounding volumes
 * or when working with the boundingBox of this node.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) GLfloat boundingVolumePadding;

/**
 * Returns the smallest axis-aligned bounding box that surrounds any local content
 * of this node, plus all descendants of this node.
 *
 * The returned bounding box is specfied in the local coordinate system of this node.
 *
 * Returns kCC3BoundingBoxNull if this node has no local content or descendants.
 *
 * The computational cost of reading this property depends on whether the node has children.
 * For a node without children, this property can be read quickly from the cached bounding
 * box of any local content of the node (for example, the mesh in a CC3MeshNode).
 *
 * However, for nodes that contain children (and possibly other descendants), since
 * the bounding box of a node can change based on the locations, rotations, or scales
 * of any descendant node, this property must measured dynamically on each access,
 * by traversing all descendant nodes. This is a computationally expensive method.
 */
@property(nonatomic, readonly) CC3BoundingBox boundingBox;

/**
 * Returns the smallest axis-aligned bounding box that surrounds any local content
 * of this node, plus all descendants of this node.
 *
 * The returned bounding box is specfied in the global coordinate system of the 3D scene.
 *
 * Returns kCC3BoundingBoxNull if this node has no local content or descendants.
 *
 * Since the bounding box of a node can change based on the locations, rotations, or
 * scales of any descendant node, this property is measured dynamically on each access,
 * by traversing all descendant nodes. This is a computationally expensive method.
 */
@property(nonatomic, readonly) CC3BoundingBox globalBoundingBox;

/**
 * Returns the center of geometry of this node, including any local content of
 * this node, plus all descendants of this node.
 *
 * The returned location is specfied in the local coordinate system of this node.
 *
 * If this node has no local content or descendants, returns a zero vector.
 *
 * This property is calculated from the value of the boundingBox property.
 * The computational cost of reading that property depends on whether this
 * node has children. See the notes for that property for more info.
 */
@property(nonatomic, readonly) CC3Vector centerOfGeometry;

/**
 * Returns the center of geometry of this node, including any local content of
 * this node, plus all descendants of this node.
 *
 * The returned location is specfied in the global coordinate system of the 3D scene.
 *
 * If this node has no local content or descendants, returns the value of the
 * globalLocation property.
 *
 * This property is calculated from the value of the boundingBox property.
 * The computational cost of reading that property depends on whether this
 * node has children. See the notes for that property for more info.
 */
@property(nonatomic, readonly) CC3Vector globalCenterOfGeometry;

/**
 * The current location of this node, as projected onto the 2D viewport coordinate space.
 * For most purposes, this is where this node will appear on the screen or window.
 * The 2D position can be read from the X and Y components of the returned 3D location.
 *
 * The initial value of this property is kCC3VectorZero. To set this property, pass this
 * node as the argument to the projectNode: method of the active camera, which can be
 * retrieved from the activeCamera property of the CC3Scene. The application should usually
 * not set this property directly. For more information, see the notes for the projectNode:
 * method of CC3Camera.
 *
 * The Z-component of the returned location indicates the distance from the camera to this
 * node, with a positive value indicating that this node is in front of the camera, and a
 * negative value indicating that it is behind the camera. If you are only interested in
 * the case when this node is in front of the camera (potentially visible to the camera),
 * check that the Z-component of the returned location is positive.
 *
 * When several nodes overlap a 2D position on the screen, you can also use the Z-component
 * of the projectedLocation property of each of the nodes to determine which node is closest
 * the camera, and is therefore "on-top" visually. This can be useful when trying to select
 * a 3D node from an iOS touch event position.
 *
 * The returned value takes into account the orientation of the device (portrait, landscape). 
 */
@property(nonatomic, assign) CC3Vector projectedLocation;

/**
 * The current position of this node, as projected onto the 2D viewport coordinate space,
 * returned as a 2D point. For most purposes, this is where this node will appear on the
 * screen or window.
 *
 * This value is derived from the X and Y coordinates of the projectedLocation property.
 * If this node is behind the camera, both the X and Y coordinates of the returned point
 * will have the value -kCC3MaxGLfloat.
 *
 * The initial value of this property is CGPointZero. To set this property, pass this
 * node as the argument to the projectNode: method of the active camera, which can be
 * retrieved from the activeCamera property of the CC3Scene. For more information, see
 * the notes for the projectNode: method of CC3Camera.
 *
 * The returned value takes into account the orientation of the device (portrait, landscape). 
 */
@property(nonatomic, readonly) CGPoint projectedPosition;

/**
 * Controls whether this node should be displayed. Initial value is YES.
 *
 * You can set this to NO to make this node and all its descendants invisible to stop
 * them from being displayed and to stop rendering processing on them.
 *
 * When reading this property, the return value takes into consideration whether the parent
 * is visible. As a result, setting this property to YES and then reading it may return NO
 * if an ancestor has visibility set to NO.
 */
@property(nonatomic, assign) BOOL visible;

/** Convenience method that sets the visible property to YES. */
-(void) show;

/** Convenience method that sets the visible property to NO. */
-(void) hide;

/**
 * Indicates the order in which this node should be drawn when compared to other nodes,
 * when drawing order should be determined by distance from the camera (Z-order).
 *
 * Sequencing nodes for drawing based on distance from the camera is necessary for translucent nodes.
 *
 * In a drawing sequencer that sorts nodes by drawing order based on distance from the
 * camera, the value of this property overrides the distances of the nodes from the camera.
 * Sorting occurs on the value of this property first, and then on distance from the camera.
 *
 * Sorting based on distance to the camera alone is quite effective. In almost all cases,
 * it is not necessary to set the value of this property, and if nodes are moving around,
 * setting a value to this property can actually interfere with the dynamic determination
 * of the correct drawing order. Only use this property if you have reason to force a node
 * to be drawn before or after another node for visual effect.
 *
 * The smaller the value of this property, the closer to the camera the node is deemed
 * to be. This property may be assigned a negative value.
 *
 * The initial value of this property is zero.
 *
 * The CC3Scene must be configured with a drawing sequencer that sorts by Z-order
 * for this property to be effective.
 *
 * This property only has effect for nodes with local content to draw (instances of CC3LocalContentNode).
 * Setting this property passes the value to all descendant nodes. Reading this value returns the average
 * value of all child nodes, or returns zero if there are no child nodes.
 */
@property(nonatomic, assign) GLint zOrder;

/**
 * Indicates whether this node has local content that will be drawn.
 * Default value is NO. Subclasses that do draw content will override to return YES.
 */
@property(nonatomic, readonly) BOOL hasLocalContent;


#pragma mark Targetting

/**
 * The target node at which this node is pointed. If the shouldTrackTarget property
 * is set to YES, this node will track the target so that it always points to the
 * target, regardless of how the target and this node move through the 3D scene.
 *
 * The target is not retained. If you destroy the target node, you must remove
 * it as the target of this node.
 */
@property(nonatomic, assign) CC3Node* target;

/**
 * Indicates whether this node is tracking the location of a target node.
 *
 * This is a convenience property that returns YES if the target property is not nil.
 */
@property(nonatomic, readonly) BOOL hasTarget;

/** 
 * The global location towards which this node is facing.
 *
 * This property is always taken to be a global location, even if the targettingConstraint
 * property is set to one of the local coordinate system constraints. The node will always
 * orient to the target or targetLocation as a global coordinate.
 *
 * Instead of specifying a target node with the target property, this property can be
 * used to set a specific global location to point towards. If the shouldTrackTarget
 * property is set to YES, this node will track the targetLocation so that it always
 * points to the targetLocation, regardless of how this node moves through the 3D scene.
 *
 * If both target and targetLocation properties are set, this node will orient to the target.
 *
 * When retrieving this property value, if the property was earlier explictly set, it will be
 * retrieved cleanly. However, if rotation was set by Euler angles, quaternions, or
 * forwardDirection, retrieving the targetLocation comes with two caveats.
 *
 * The first caveat is that calculating a targetLocation requires the global location of
 * this node, which is only calculated when the node's transformMatrix is calculated after
 * all model updates have been processed. This means that, depending on when you access
 * this property, the calculated targetLocation may be one frame behind the real value.
 * 
 * The second caveat is that the derived targetLocation will be an invented location
 * one unit length away from the globalLocation of this node, in the direction of the
 * fowardDirection of this node. Although this is a real location, it is unlikely that
 * this location is meaningful to the application.
 * 
 * In general, it is best to use this property directly, both reading and writing it,
 * rather than reading this property after setting one of the other rotational properties.
 */
@property(nonatomic, assign) CC3Vector targetLocation;

/**
 * Indicates whether this instance should track the targetLocation or target properties
 * as this node, or the target node, moves around.
 *
 * If this property is set to YES, as this node move around, or the node in the target
 * property moves around, this node will automatically rotate itself to face the target
 * or targetLocation. If this property is set to NO, this node will initially rotate to
 * face the target or targetLocation, but will not track the target or targetLocation
 * when this node, or the target node, subsequently moves.
 *
 * The initial value of this property is NO, indicating that if the either the target or
 * targetLocation properties is set, this node will initially point to it, but will not
 * track it as this node, or the target node, moves.
 *
 * If this property is set to YES, subsequently changing the value of the rotation,
 * quaternion, or forwardDirection properties will have no effect, since they would
 * interfere with the ability to track the target. To set specific rotations or
 * pointing direction, first set this property back to NO.
 */
@property(nonatomic, assign) BOOL shouldTrackTarget;

/**
 * Indicates whether this instance should automatically find and track the camera as its target.
 * If this property is set to YES, this instance will automatically find and track the camera
 * without having to set the target and shouldTrackTarget properties explicitly.
 * 
 * Setting this property to YES has the same effect as setting the shouldTrackTarget to YES
 * and setting the target to the active camera. Beyond simplifying the two steps into one,
 * this property can be set before the active camera is established, or without being aware
 * of the active camera. When using this property, you do not need to set the target property,
 * as it will automatically be set to the active camera.
 *
 * This property will be set to NO once the camera has been attached as the target.
 *
 * If the active camera is changed to a different camera (via the activeCamera property of
 * the CC3Scene), this property will ensure that this node will target the new active camera.
 *
 * Setting this property to NO also sets the shouldTrackTarget to NO.
 *
 * This initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldAutotargetCamera;

/**
 * If the node held in the target property is a CC3Light, the target can be tracked
 * by this node for the purpose of updating the lighting of a contained bump-map
 * texture, instead of rotating to face the light, as normally occurs with tracking.
 * 
 * This property indicates whether this node should update its globalLightLocation
 * from the tracked location of the light, instead of rotating to face the light.
 *
 * The initial property is set to NO, indicating that this node will rotate to face
 * the target as it or this node moves. If you have set the target property to a
 * CC3Light instance, and want the bump-map lighting property globalLightLocation
 * to be updated as the light is tracked instead, set this property to YES.
 */
@property(nonatomic, assign) BOOL isTrackingForBumpMapping;

/**
 * Indicates whether rotation should be constrained when attempting to rotate the node to
 * point at the target or targetLocation.
 *
 * For example, a cheap way of simulating a full 3D tree is to have a simple flat picture of a
 * tree that you rotate around the vertical axis so that it always faces the camera. Or you might
 * have a signpost that you want to rotate towards the camera, or towards another object as that
 * object moves around the scene, and you want the signpost to remain vertically oriented, and 
 * rotate side to side, but not up and down, should the object being tracked move up and down.
 *
 * The initial value of this property is kCC3TargettingConstraintGlobalUnconstrained, indicating
 * that the forward direction of this node will point directly at the target or targetLocation,
 * rotating in the global coordinate system in all three axial directions to do so, and treating
 * the referenceUpDirection as a direction in the global coordinate system. The result is that the
 * node will retain the same global orientation, regardless of how it is moved, or how its
 * ancestors (parent, etc) are moved and rotated.
 */
@property(nonatomic, assign) CC3TargettingConstraint targettingConstraint;

/** @deprecated Renamed to targettingConstraint. */
@property(nonatomic, assign) CC3TargettingConstraint axisRestriction DEPRECATED_ATTRIBUTE;


#pragma mark Mesh configuration

/**
 * Indicates whether the back faces should be culled on the meshes contained in
 * descendants of this node.
 *
 * The initial value is YES, indicating that back faces will not be displayed. You can set
 * this property to NO if you have reason to display the back faces of the mesh (for instance,
 * if you have a rectangular plane and you want to show both sides of it).
 *
 * Since the normal of the face points out the front face, back faces interact with light
 * the same way the front faces do, and will appear luminated by light that falls on the
 * front face, much like a stained-glass window. This may not be the affect that you are after,
 * and for some lighting conditions, instead of disabling back face culling, you might consider
 * creating a second textured front face, placed back-to-back with the original front face.
 *
 * Be aware that culling improves performance, so this property should be set to NO
 * only when specifically needed for visual effect, and only on the meshes that need it.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns NO if any of the descendant mesh nodes have this property
 * set to NO. Initially, and in most cases, all mesh nodes have this property set to YES.
 *
 * For more information about this use of this property, see the class notes for the
 * CC3MeshNode class.
 */
@property(nonatomic, assign) BOOL shouldCullBackFaces;

/**
 * Indicates whether the front faces should be culled on the meshes contained in
 * descendants of this node.
 *
 * The initial value is NO. Normally, you should leave this property with the initial value,
 * unless you have a specific need not to display the front faces.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns YES if any of the descendant mesh nodes have this property
 * set to YES. Initially, and in most cases, all mesh nodes have this property set to NO.
 *
 * For more information about this use of this property, see the class notes for the
 * CC3MeshNode class.
 */
@property(nonatomic, assign) BOOL shouldCullFrontFaces;

/**
 * Indicates whether the edge-widing algorithm used by the GL engine to determine
 * which face of a triangle is the front face should use clockwise winding.
 *
 * If this property is set to YES, the front face of all triangles in the mesh
 * of this node will be determined using clockwise winding of the edges. If this
 * property is set to NO, the front face of all triangles in the mesh of this
 * node will be determined using counter-clockwise winding of the edges.
 *
 * The initial value of this property is NO, indicating that the OpenGL-standard
 * counter-clockwise winding will be used by the GL engine to determine the front
 * face of all triangles in the mesh of this node. Unless you have a reason to
 * change this value, you should leave it at the initial value.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns YES if any of the descendant mesh nodes have
 * this property set to YES, otherwise returns NO.
 */
@property(nonatomic, assign) BOOL shouldUseClockwiseFrontFaceWinding;

/**
 * Indicates whether the shading of the faces of the mesh of this node should be
 * smoothly shaded, using color interpolation between vertices.
 *
 * If this property is set to YES, the color of each pixel in any face in the mesh
 * of this node will be interpolated from the colors of all three vertices of the
 * face, using the distance of the pixel to each vertex as the means to interpolate.
 * The result is a smooth gradient of color across the face.
 *
 * If this property is set to NO, the color of all pixels in any face in the mesh
 * of this node will be determined by the color at the third vertex of the face.
 * All pixels in the face will be painted in the same color.
 *
 * The initial value is YES. For realistic rendering, you should leave this
 * property with the initial value, unless you have a specific need to render
 * flat color across each face in the mesh, such as to deliberately create a
 * cartoon-like effect on the model.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns NO if any of the descendant mesh nodes have this property
 * set to NO. Initially, and in most cases, all mesh nodes have this property set to YES.
 */
@property(nonatomic, assign) BOOL shouldUseSmoothShading;

/**
 * Specifies the method to be used to scale vertex normals after they have been transformed
 * during vertex drawing.
 *
 * Normal vectors should have a unit length. Since normals are vectors in the local coordinate
 * system of the node, they are transformed into scene and eye coordinates during drawing.
 *
 * During transformation, there are several factors that might distort the normal vector:
 *   - If the normals started out not being of unit length, they will generally be transformed
 *     into vectors that are not of unit length.
 *   - If the transforms are not rigid, and include scaling, even normals that have unit
 *     length in object space will end up shorter or longer than unit length in eye space.
 *   - If the transform scaling is not uniform, the normals will shear, and end up shorter
 *     or longer than unit length.
 *
 * Normals that are not of unit length, or are sheared, will cause portions of the objects
 * to appear lighter or darker after transformation, or will cause specular highlights to
 * actually be dark, distorting the overall look of the material covering the mesh.
 *
 * The GL engine can be instructed to compensate for these transforms by setting this
 * property as follows:
 *
 *   - kCC3NormalScalingNone:
 *     No compensating scaling is performed on the normals after they have been transformed.
 *     This has the highest performance, but will not adjust the normals if they have been
 *     scaled. Use this option if you know that the normals will not be significantly scaled
 *     during transformation.
 *
 *   - kCC3NormalScalingRescale:
 *     Uses the modelview matrix to scale all normals by the inverse of the node's overall
 *     scaling. This does have a processing cost, but is much faster than using 
 *     kCC3NormalScalingNormalize. However, it is not as accurate if significantly non-uniform
 *     scaling has been applied to the node.
 *
 *   - kCC3NormalScalingNormalize:
 *     Normalizes each norml vector independently. This is the most accurate method, but is
 *     also, by far, the most computationally expensive. Use this method only if selecting
 *     one of the other options does not give you the results that you expect.
 *
 *   - kCC3NormalScalingAutomatic:
 *     Chooses the most appropriate method based on the scaling that has been applied to the
 *     node. If no scaling has been applied to the node, kCC3NormalScalingNone will be used.
 *     If only uniform scaling has been applied to the node, kCC3NormalScalingRescale will
 *     be used. If non-uniform scaling has been applied to the node, then
 *     kCC3NormalScalingNormalize will be used.
 *
 * The initial value of this property is kCC3NormalScalingAutomatic. You can generally leave
 * this property at this default value unless you are not getting the results that you expect. 
 *
 * Setting this property sets the corresponding property in all descendant nodes, and affects
 * the processing of normals in all vertex meshes contained in all descendant nodes.
 *
 * Querying this property returns the value of this property from the first descendant mesh
 * node, or will return kCC3NormalScalingNone if no mesh node are found in the descendants
 * of this node.
 */
@property(nonatomic, assign) CC3NormalScaling normalScalingMethod;

/**
 * Indicates whether information about the faces of mesh should be cached.
 *
 * If this property is set to NO, accessing information about the faces through the
 * methods faceAt:, faceIndicesAt:, faceCenterAt:, faceNormalAt:, or facePlaneAt:,
 * will be calculated dynamically from the mesh data.
 *
 * If such data will be accessed frequently, this repeated dynamic calculation may
 * cause a noticable impact to performance. In such a case, this property can be
 * set to YES to cause the data to be calculated once and cached, improving the
 * performance of subsequent accesses to information about the faces.
 *
 * However, caching information about the faces will increase the amount of memory
 * required by the mesh, sometimes significantly. To avoid this additional memory
 * overhead, in general, you should leave this property set to NO, unless intensive
 * access to face information is causing a performance impact.
 *
 * An example of a situation where the use of this property may be noticable,
 * is when adding shadow volumes to nodes. Shadow volumes make intense use of
 * accessing face information about the mesh that is casting the shadow.
 *
 * When the value of this property is set to NO, any data cached during previous
 * access through the indicesAt:, centerAt:, normalAt:, or planeAt:, methods will
 * be cleared.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns YES if any of the descendant mesh nodes have this property
 * set to YES. Initially, and in most cases, all mesh nodes have this property set to NO.
 */
@property(nonatomic, assign) BOOL shouldCacheFaces;

/**
 * Indicates whether this instance will disable the GL depth mask while drawing the
 * content of this node. When the depth mask is disabled, drawing activity will not
 * write to the depth buffer.
 *
 * If this property is set to NO, the Z-distance of this node will be compared against
 * previously drawn content, and the drawing of this node will update the depth buffer,
 * so that subsequent drawing will take into consideration the Z-distance of this node.
 *
 * If this property is set to YES, the Z-distance of this node will still be compared
 * against previously drawn content, but the drawing of this node will NOT update the
 * depth buffer, and subsequent drawing will NOT take into consideration the Z-distance
 * of this node.
 *
 * This property only has effect if the shouldDisableDepthTest property is set to NO.
 *
 * In most cases, to draw an accurate scene, we want depth testing to be performed
 * at all times, and this property is usually set to NO. However, there are some
 * occasions where it is useful to disable writing to the depth buffer during the
 * drawing of a node. One notable situation is with particle systems, where temporarily
 * disabling the depth mask will avoid Z-fighting between individual particles.
 *
 * The initial value of this property is NO, indicating that the GL depth mask will
 * not be disabled during the drawing of this node, and the depth buffer will be
 * updated during the drawing of this node.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns YES if any of the descendant mesh nodes have
 * this property set to YES, otherwise returns NO.
 */
@property(nonatomic, assign) BOOL shouldDisableDepthMask;

/**
 * Indicates whether this instance will disable the GL depth test while drawing
 * the content of this node. When the depth test is disabled, the Z-distance of
 * this node will not be compared against previously drawn content, and drawing
 * activity will not write to the depth buffer.
 *
 * If this property is set to NO, the Z-distance of this node will be compared against
 * previously drawn content, and the drawing of this node will update the depth buffer,
 * so that subsequent drawing will take into consideration the Z-distance of this node.
 *
 * If this property is set to YES, the Z-distance of this node will not be compared
 * against previously drawn content and this node will be drawn over all previously
 * drawn content. In addition, the drawing of this node will not update the depth
 * buffer, with the result that subsequent object drawing will not take into
 * consideration the Z-distance of this node.
 *
 * In most cases, to draw an accurate scene, we want depth testing to be performed
 * at all times, and this property is usually set to NO. However, there are some
 * occasions where it is useful to disable depth testing during the drawing of a node.
 * One notable situation is with particle systems, where temporarily disabling depth
 * testing may help avoid Z-fighting between individual particles.
 *
 * The initial value of this property is NO, indicating that the GL depth tesing will
 * not be disabled during the drawing of this node, and the depth buffer will be
 * updated during the drawing of this node.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns YES if any of the descendant mesh nodes have
 * this property set to YES, otherwise returns NO.
 */
@property(nonatomic, assign) BOOL shouldDisableDepthTest;

/**
 * The depth function used by the GL engine when comparing the Z-distance of the
 * content of this node against previously drawn content.
 *
 * This property only has effect if the shouldDisableDepthTest property is set to NO.
 *
 * This property must be set to one of the following values:
 *   - GL_LESS - the content of this node will be drawn if it is closer to the camera
 *     than previously drawn content.
 *   - GL_LEQUAL - the content of this node will be drawn if it is at least as close
 *     to the camera as previously drawn content.
 *   - GL_EQUAL - the content of this node will be drawn if it is exactly as close
 *     to the camera as previously drawn content.
 *   - GL_GEQUAL - the content of this node will be drawn if it is at least as far
 *     away from the camera as previously drawn content.
 *   - GL_GREATER - the content of this node will be drawn if it is farther away from
 *     the camera than previously drawn content.
 *   - GL_NOTEQUAL - the content of this node will be drawn if it is not exactly as
 *     close to the camera as previously drawn content.
 *   - GL_ALWAYS - the content of this node will always be drawn
 *   - GL_NEVER - the content of this node will not be drawn
 *
 * The initial value of this property is GL_LEQUAL. In most cases, to draw an accurate
 * scene, this value is the most suitable. However, some special cases, including some
 * particle emitters, may benefit from the use of one of the other depth functions.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns the value of this property from the first descendant mesh
 * node, or will return GL_NEVER if no mesh node are found in the descendants of this node.
 */
@property(nonatomic, assign) GLenum depthFunction;

/**
 * An offset factor used by the GL engine when comparing the Z-distance of the content
 * of this node against previously drawn content. This can be used to correct for
 * Z-fighting between overlapping, and nearly co-planar, faces of two objects that overlap.
 *
 * The definitive example is when you wish to apply a decal object on top of another,
 * such as bullet-holes on a wall, or a real label on a box. Since the decal is
 * co-planar with the surface it is attached to, it is easy for rounding errors to
 * cause some of the pixels of the decal to be considered on top of the background,
 * and others to be considered behind the background, resulting in only a partial
 * display of the decal content. This is known as Z-fighting.
 *
 * A face whose orientation is at an angle to the camera, particularly those who are
 * oriented almost edge-on to the camera, might have a significant change in depth
 * across its visible span. Depending on which parts of the face are used to determine
 * each pixel depth, the difference in the depth value might be significant.
 *
 * By assigning a value to this property, the depth of each pixel will be offset by the
 * overall change in depth across the face being drawn, multiplied by the value of this
 * property. When comparing the depth  of content to be drawn against content that has
 * already been drawn, a positive value for this property will effectively move that
 * content away from the camera, and a negative value will effectively move that content
 * towards the camera, relative to the content that has already been drawn.
 *
 * A value of -1.0 will cause the depth of content to be drawn to be offset by the
 * overall change in depth across the face, effectively pulling the face toward the
 * camera by an amount equal to the span of its depth.
 *
 * The depth offset determined by this property is added to the depth offset determined
 * by the decalOffsetUnits property to determine the overall depth offset to be applied
 * to each pixel.
 *
 * This property only has effect if the shouldDisableDepthTest property is set to NO.
 *
 * The initial value of this property is zero, indicating that no depth offset based on
 * the change in depth across the face will be applied.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns the first non-zero value of this property from
 * any descendant mesh node, or will return zero if no mesh nodes are found in the
 * descendants of this node.
 */
@property(nonatomic, assign) GLfloat decalOffsetFactor;

/**
 * An offset value used by the GL engine when comparing the Z-distance of the content
 * of this node against previously drawn content. This can be used to correct for
 * Z-fighting between overlapping, and nearly co-planar, faces of two objects that overlap.
 *
 * The definitive example is when you wish to apply a decal object on top of another,
 * such as bullet-holes on a wall, or a real label on a box. Since the decal is
 * co-planar with the surface it is attached to, it is easy for rounding errors to
 * cause some of the pixels of the decal to be considered on top of the background,
 * and others to be considered behind the background, resulting in only a partial
 * display of the decal content. This is known as Z-fighting.
 *
 * By assigning a value to this property, the depth of each pixel will be offset by the
 * minimum resolvable depth buffer value, multiplied by the value of this property.
 * When comparing the depth  of content to be drawn against content that has already
 * been drawn, a positive value for this property will effectively move that content
 * away from the camera, and a negative value will effectively move that content towards
 * the camera, relative to the content that has already been drawn.
 *
 * A value of -1.0 will cause the depth of content to be drawn to be offset by the
 * minimum resolvable depth buffer value, effectively pulling the face toward the
 * camera by an amount equal to the minimum Z-distance that is resolvable by the
 * depth buffer (which depends on the configuration of the depth buffer).
 *
 * The depth offset determined by this property is added to the depth offset determined
 * by the decalOffsetFactor property to determine the overall depth offset to be applied
 * to each pixel.
 *
 * This property only has effect if the shouldDisableDepthTest property is set to NO.
 *
 * The initial value of this property is zero, indicating that no absolute depth offset
 * will be applied.
 *
 * Setting this value sets the same property on all descendant nodes.
 *
 * Querying this property returns the first non-zero value of this property from
 * any descendant mesh node, or will return zero if no mesh nodes are found in the
 * descendants of this node.
 */
@property(nonatomic, assign) GLfloat decalOffsetUnits;

/**
 * Indicates whether the bounding volume of this node should be considered fixed,
 * even if the mesh vertices that determine the boundary are changed, or should be
 * recalculated whenever the underlying mesh vertices change.
 *
 * If the value of this property is set to YES, the bounding volume will NOT be
 * recalculated each time the vertices of the mesh are modified (typically via the
 * setVertexLocation:at: method). If the value of this property is set to NO, the
 * bounding volume will be recalculated each time the vertices of the mesh are modified.
 *
 * The initial value of this property is NO, indicating that the bounding volume will
 * be recalculated whenever the underlying mesh vertices change.
 *
 * For most scenarios, the most accurate bounding volume is achieved by leaving setting
 * this property to NO, and letting the bounding volume automatically adapt to changes
 * in the underlying mesh vertices.
 * 
 * However, for some specialized meshes, such as particle generators, where the vertex
 * data is continuously being modified in a predictable manner, the processing cost of
 * constantly re-measuring the bounding volume may be significant, and it may be more
 * effective to set a fixed bounding volume that encompasses the entire possible range
 * of vertex location data, and set the value of this property to YES to stop the
 * bounding volume from being recalculated every time the vertex data is changed.
 *
 * See the note for the various subclasses of CC3NodeBoundingVolume
 * (eg- CC3NodeBoundingBoxVolume and CC3NodeSphericalBoundingVolume) to learn how
 * to set the properties of the bounding volumes, to fix them to a particular range.
 */
@property(nonatomic, assign) BOOL shouldUseFixedBoundingVolume;

/**
 * Indicates whether descendant mesh nodes should cast shadows even when invisible.
 *
 * Normally, when a mesh is made invisible, its shadows should disappear as well.
 * However, there are certain situations where you might want a mesh to cast shadows,
 * even when it is not being rendered visibly. One situation might be to use an
 * invisible low-poly mesh to generate the shadows of a more detailed high-poly
 * mesh, in order to reduce the processing effort required to generate the shadows.
 * This technique can be particularly useful when using shadow volumes.
 *
 * The initial value of this propety is NO.
 *
 * Setting this value sets the same property on all descendant mesh and light nodes.
 *
 * Querying this property returns the first YES value of this property from any
 * descendant mesh or light node, or will return NO if no descendant nodes have this
 * property set to YES.
 */
@property(nonatomic, assign) BOOL shouldCastShadowsWhenInvisible;

/**
 * Indicates whether the dynamic behaviour of this node is enabled.
 *
 * Setting this property affects both internal activities driven by the update
 * process, and any CCActions controling this node. Setting this property to NO will
 * effectively pause all update and CCAction behaviour on the node. Setting this
 * property to YES will effectively resume the update and CCAction behaviour.
 * 
 * Setting this property sets the same property in all descendant nodes.
 *
 * Be aware that when this property is set to NO, any CCActions are just paused,
 * but not stopped or removed. If you want to fully stop all CCActions on this node,
 * use the stopAllActions method, or if you want to fully stop all CCActions on this
 * node AND all descendant nodes, use the cleanupActions method.
 */
@property(nonatomic, assign) BOOL isRunning;

/**
 * Some node types (notably CC3Scene) collect runtime performance statistics using
 * an instance of CC3PerformanceStatistics accessed by this property.
 *
 * By default, nodes do not collect statistics. This property always returns nil,
 * and setting this property has no effect. Subclasses that performance support
 * statistics collection will override to allow the property to be get and set.
 */
@property(nonatomic, retain) CC3PerformanceStatistics* performanceStatistics;

/**
 * Returns a description of the structure of this node and its descendants,
 * by recursing through this node and its descendants and appending the
 * result of the description property of each node.
 *
 * The description of each node appears on a separate line and is indented
 * according to its depth in the structural hierarchy, starting at this node.
 */
@property(nonatomic, readonly) NSString* structureDescription;

/**
 * Appends the description of this node to the specified mutable string, on a new line
 * and indented the specified number of levels.
 *
 * Returns the specified mutable string, as a convenience.
 */
-(NSString*) appendStructureDescriptionTo: (NSMutableString*) desc withIndent: (NSUInteger) indentLevel;


#pragma mark Matierial coloring

/**
 * If this value is set to YES, current lighting conditions will be taken into consideration
 * when drawing colors and textures, and the ambientColor, diffuseColor, specularColor,
 * emissionColor, and shininess properties will interact with lighting settings.
 *
 * If this value is set to NO, lighting conditions will be ignored when drawing colors and
 * textures, and the material emissionColor will be applied to the mesh surface without regard
 * to lighting. Blending will still occur, but the other material aspects, including ambientColor,
 * diffuseColor, specularColor, and shininess will be ignored. This is useful for a cartoon
 * effect, where you want a pure color, or the natural colors of the texture, to be included
 * in blending calculations, without having to arrange lighting, or if you want those colors
 * to be displayed in their natural values despite current lighting conditions.
 *
 * Setting the value of this property sets the same property in the materials contained in all
 * descendant nodes. Reading the value of this property returns YES if any descendant node
 * returns YES, and returns NO otherwise.
 */
@property(nonatomic, assign) BOOL shouldUseLighting;

/**
 * The ambient color of the materials of this node.
 *
 * Setting this property sets the same property on all child nodes.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 *
 * Querying this property returns the average value of querying this property on all child nodes.
 * When querying this value on a large node assembly, be aware that this may be time-consuming.
 */
@property(nonatomic, assign) ccColor4F ambientColor;

/**
 * The diffuse color of the materials of this node.
 *
 * Setting this property sets the same property on all child nodes.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 *
 * Querying this property returns the average value of querying this property on all child nodes.
 * When querying this value on a large node assembly, be aware that this may be time-consuming.
 */
@property(nonatomic, assign) ccColor4F diffuseColor;

/**
 * The specular color of the materials of this node.
 *
 * Setting this property sets the same property on all child nodes.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 *
 * Querying this property returns the average value of querying this property on all child nodes.
 * When querying this value on a large node assembly, be aware that this may be time-consuming.
 */
@property(nonatomic, assign) ccColor4F specularColor;

/**
 * The emission color of the materials of this node.
 *
 * Setting this property sets the same property on all child nodes.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 *
 * Querying this property returns the average value of querying this property on all child nodes.
 * When querying this value on a large node assembly, be aware that this may be time-consuming.
 */
@property(nonatomic, assign) ccColor4F emissionColor;

/**
 * When a mesh node is textured with a DOT3 bump-map (normal map), this property indicates
 * the location, in the global coordinate system, of the light that is illuminating the node.
 * 
 * When setting this property, this implementation sets the same property in all child nodes.
 * Set the value of this property to the globalLocation of the light source. Bump-map textures
 * may interact with only one light source.
 *
 * This property only needs to be set, and will only have effect when set, on individual
 * CC3MeshNodes whose material is configured for bump-mapping. This property is provided in
 * CC3Node as a convenience to automatically traverse the node structural hierarchy to set
 * this property in all descendant nodes.
 *
 * When reading this property, this implementation returns the value of the same property
 * from the first descendant node that is a CC3MeshNode and that contains a texture configured
 * for bump-mapping. Otherwise, this implementation returns kCC3VectorZero.
 */
@property(nonatomic, assign) CC3Vector globalLightLocation;


#pragma mark CCRGBAProtocol and CCBlendProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * Setting this property sets the same property on all child nodes.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 *
 * Querying this property returns the average value of querying this property on all child nodes.
 * When querying this value on a large node assembly, be aware that this may be time-consuming.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * Querying this property returns the average value of querying this property on all child nodes.
 * When querying this value on a large node assembly, be aware that this may be time-consuming.
 *
 * Setting this property sets the same property in all descendants. See the notes for
 * this property on CC3Material for more information on how this property interacts
 * with the other material properties.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 *
 * Setting this property should be thought of as a convenient way to switch between the
 * two most common types of blending combinations. For finer control of blending, set
 * specific blending properties on the CC3Material instance directly, and avoid making
 * changes to this property.
 */
@property(nonatomic, assign) GLubyte opacity;

/**
 * Indicates whether the content of this node and its descendants is opaque.
 *
 * Returns NO if at least one descendant is not opaque, as determined by its isOpaque
 * property. Returns YES if all descendants return YES from their isOpaque property.
 *
 * Setting this property sets the same property in all descendants. See the notes for
 * this property on CC3Material for more information on how this property interacts with
 * the other material properties.
 *
 * Setting this property should be thought of as a convenient way to switch between the
 * two most common types of blending combinations. For finer control of blending, set
 * specific blending properties on the CC3Material instance directly, and avoid making
 * changes to this property.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 */
@property(nonatomic, assign) BOOL isOpaque;

/**
 * Implementation of the CCBlendProtocol blendFunc property.
 *
 * This is a convenience property that gets and sets the same property of the material
 * of all descendant nodes
 *
 * Querying this property returns the value of the same property from the first
 * descendant node that supports materials, or {GL_ONE, GL_ZERO} if no descendant
 * nodes support materials. Setting this property sets the same property on the
 * materials in all descendant nodes.
 *
 * Before setting this property, for this property to have affect on descendant
 * mesh nodes, you must assign a material to each of those nodes using its material
 * property, or assign a texture to those mesh nodes using the texture property,
 * which will automatically create a material to hold the texture.
 */
@property(nonatomic, assign) ccBlendFunc blendFunc;

/**
 * For descendant mesh nodes whose mesh contains per-vertex color content, this property indicates
 * whether setting the opacity and color properties should change the color content of all vertices
 * in the mesh.
 *
 * Normally, opacity and color information is held in the material of a mesh node, and changing
 * the opacity and color properties of a mesh node will change the material properties only.
 * However, when a mesh contains per-vertex coloring, the material opacity and coloring will be
 * ignored in favour of the opacity and coloring of each vertex, and changing these properties
 * will not affect a mesh node with per-vertex coloring. In the case of opacity, this effectivly
 * means that the mesh node cannot be faded in and out by using the opacity property.
 *
 * Setting this property to YES will ensure that changes to the opacity and color properties are also
 * propagated to the vertex content of any mesh node descendants that have per-vertex color content.
 * In the case of opacity, this allows such mesh nodes to be effectively faded in and out.
 *
 * This property has no effect on mesh nodes that do not contain per-vertex color content.
 *
 * The initial value of this property is NO, indicating that changes to the opacity and color
 * of each descendant mesh node will only be applied to the material of the mesh node and not
 * to any per-vertex color content.
 *
 * Querying this property returns the value of this property on the first descendant mesh node.
 *
 * Setting this property sets the value in the same property in all descendant mesh nodes.
 */
@property(nonatomic, assign) BOOL shouldApplyOpacityAndColorToMeshContent;


#pragma mark Line drawing configuration

/** The width of the lines that will be drawn. The initial value is 1.0. */
@property(nonatomic, assign) GLfloat lineWidth;

/** Indicates whether lines should be smoothed (antialiased). The initial value is NO. */
@property(nonatomic, assign) BOOL shouldSmoothLines;

/**
 * Indicates how the GL engine should trade off between rendering quality and speed.
 * The value of this property should be one of GL_FASTEST, GL_NICEST, or GL_DONT_CARE.
 *
 * The initial value of this property is GL_DONT_CARE.
 */
@property(nonatomic, assign) GLenum lineSmoothingHint;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) node;

/** Allocates and initializes an unnamed autoreleased instance with the specified tag. */
+(id) nodeWithTag: (GLuint) aTag;

/**
 * Allocates and initializes an autoreleased instance with the specified name and an
 * automatically generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) nodeWithName: (NSString*) aName;

/** Allocates and initializes an autoreleased instance with the specified tag and name. */
+(id) nodeWithTag: (GLuint) aTag withName: (NSString*) aName;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will have the
 * same name as this node, but will have a unique tag.
 *
 * The copying operation effects a deep copy. For any content that is held by reference
 * (eg- objects), and subject to future modification, a copy is created, so that both this
 * instance and the other instance can be treated independently. This includes child nodes,
 * of which copies are created.
 * 
 * The following rules are applied when copying a node:
 *   - The tag property is not copied. The tag is property is assigned and automatically
 *     generated unique tag value.
 *   - The copy will initially have no parent. It will automatically be set when this
 *     node is added as a child to a parent node.
 *   - Copies are created of all child nodes, using the copy method of each child. The
 *     child nodes of the new node will therefore have the same names as the child nodes
 *     of the original node.
 *   - Mesh data is copied by reference, not by value. Child nodes that support mesh data
 *     will assign it by reference when that child is copied. Mesh data is shared between
 *     both the original mesh node and copy node.
 * 
 * Subclasses that extend content should honour the deep copy design pattern, making
 * exceptions only for content that is both large and not subject to modifications,
 * such as mesh data.
 *
 * This method may often be used to duplicate a node many times, to create large number of
 * similar instances to populate a game. To help you verify that you are correctly releasing
 * and deallocating all these copies, you can use the instanceCount class method to get a
 * current count of the total number of instances of all subclasses of CC3Identifiable,
 * When reviewing that number, remember that nodes are only one type of CC3Identifiable,
 * and other subclasses, such as materials, will contribute to this count.
 */
-(id) copy;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will have its
 * name set to the specified name, and will have a unique tag.
 *
 * The copying operation effects a deep copy. See the notes at the copy method for more
 * details about copying nodes.
 */
-(id) copyWithName: (NSString*) aName;

/**
 * Creates OpenGL ES buffers to be used by the GL engine hardware. Default behaviour is to
 * invoke the same method on all child nodes. Subclasses that can make use of hardware
 * buffering, notably mesh subclasses, will override and bind their data to GL hardware buffers.
 *
 * Invoking this method is optional and is not performed automatically. If an application does
 * not wish to use hardware buffering for some nodes, it can do so by avoiding the invocation of
 * this method on those nodes. Typically, however, an applicaiton will simply invoke this method
 * once during initialization of highest-level ancestor node (ususally a subclass of CC3Scene).
 */
-(void) createGLBuffers;

/**
 * Deletes any OpenGL buffers that were created by any descendant nodes via a prior invocation
 * of createGLBuffers. If the descendant nodes also retained the vertex content locally, drawing
 * will then revert to distinct GL draw calls, passing data through the GL API on each call,
 * rather than via the bound buffers.
 *
 * If a descendant node did not retain the vertex content locally, then after this method is invoked,
 * no vertex content will be available for the node, and the node will no longer be drawn. For this
 * reason, great care should be taken when using this method in combination with releasing the local
 * copy of the vertex data.
 *
 * To delete the GL buffers of a particular node without deleting those of any descendant nodes,
 * use this method on the mesh node's mesh, instead of on the mesh node itself.
 *
 * The local copy of the vertex content in main memory can be released via the releaseRedundantData
 * method. To retain the local copy of the vertex content for any particular node, invoke one or
 * more of the retainVertex... family of methods. See the notes of the releaseRedundantData for more
 * info regarding retaining and releasing the local copy of the vertex content in app memory. 
 */
-(void) deleteGLBuffers;

/**
 * Once the vertex data has been buffered into a GL vertex buffer object (VBO)
 * within the GL engine, via the createGLBuffer method, this method can be used
 * to release the data in main memory that is now redundant from all meshes that
 * have been buffered to the GL engine.
 *
 * Invoking this method on a node will release from main memory any data within
 * all descendant mesh nodes, that has successfully been copied to buffers in
 * the GL engine. It is safe to invokde this method even if createGLBuffer has not
 * been invoked, and even if VBO buffering was unsuccessful.
 *
 * To exempt vertex data from release, invoke one or more of the following methods
 * once on nodes for which data should be retained, before invoking this method:
 *   - retainVertexContent
 *   - retainVertexLocations
 *   - retainVertexNormals
 *   - retainVertexColors
 *   - retainVertexTextureCoordinates
 *   - retainVertexIndices
 *
 * For example, sophisticated physics engines and collision detection algorithms may make
 * use of vertex location data in main memory. Or a rippling texture animation might retain
 * texture coordinate data in order to dyamically adjust the texture coordinate data.
 *
 * Normally, you would invoke the retainVertex... methods on specific individual
 * nodes, and then invoke this method on the parent node of a node assembly,
 * or on the CC3Scene.
 */
-(void) releaseRedundantData;

/**
 * Convenience method to cause all vertex content data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * All vertex content, such as location, normal, color, texture coordinates, point size,
 * weights and matrix indices will be retained.
 * 
 * This method does NOT cause vertex index data to be retained. To retain vertex index data,
 * use the retainVertexIndices method as well.
 */
-(void) retainVertexContent;

/**
 * Convenience method to cause the vertex location data of this node and all descendant
 * nodes to be retained in application memory when releaseRedundantData is invoked, even
 * if it has been buffered to a GL VBO.
 *
 * Use this method if you require access to vertex data after the data has been
 * buffered to a GL VBO.
 *
 * Only the vertex locations will be retained. Any other vertex data, such as normals,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexLocations;

/**
 * Convenience method to cause the vertex normal data of this node and all descendant
 * nodes to be retained in application memory when releaseRedundantData is invoked,
 * even if it has been buffered to a GL VBO.
 *
 * Use this method if you require access to vertex data after the data has been
 * buffered to a GL VBO.
 *
 * Only the vertex normals will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexNormals;

/**
 * Convenience method to cause the vertex color data of this node and all descendant
 * nodes to be retained in application memory when releaseRedundantData is invoked,
 * even if it has been buffered to a GL VBO.
 *
 * Use this method if you require access to vertex data after the data has been
 * buffered to a GL VBO.
 *
 * Only the vertex colors will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexColors;

/**
 * Convenience method to cause the vertex texture coordinate data of this node and
 * all descendant nodes, for all texture units, used by this mesh to be retained in
 * application memory when releaseRedundantData is invoked, even if it has been
 * buffered to a GL VBO.
 *
 * Use this method if you require access to vertex data after the data has been
 * buffered to a GL VBO.
 *
 * Only the vertex texture coordinates will be retained. Any other vertex data, such as
 * locations, or normals, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexTextureCoordinates;

/**
 * Convenience method to cause the vertex index data of this node and all descendant
 * nodes to be retained in application memory when releaseRedundantData is invoked,
 * even if it has been buffered to a GL VBO.
 *
 * Use this method if you require access to vertex data after the data has been
 * buffered to a GL VBO.
 *
 * Only the vertex indices will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexIndices;

/**
 * Convenience method to cause all vertex content to be skipped when createGLBuffers is invoked.
 * The vertex content is not buffered to a a GL VBO, is retained in application memory, and is
 * submitted to the GL engine on each frame render.
 *
 * This method does NOT stop vertex index data from being buffered. If you meshes use vertex
 * indices, and you don't want them buffered, use the doNotBufferVertexIndices method as well.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexContent method.
 */
-(void) doNotBufferVertexContent;

/**
 * Convenience method to cause the vertex location data of this node and all
 * descendant nodes to be skipped when createGLBuffers is invoked. The vertex
 * data is not buffered to a a GL VBO, is retained in application memory, and
 * is submitted to the GL engine on each frame render.
 *
 * Only the vertex locations will not be buffered to a GL VBO. Any other vertex
 * data, such as normals, or texture coordinates, will be buffered to a GL VBO
 * when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexLocations method.
 */
-(void) doNotBufferVertexLocations;

/**
 * Convenience method to cause the vertex normal data of this node and all
 * descendant nodes to be skipped when createGLBuffers is invoked. The vertex
 * data is not buffered to a a GL VBO, is retained in application memory, and
 * is submitted to the GL engine on each frame render.
 *
 * Only the vertex normals will not be buffered to a GL VBO. Any other vertex
 * data, such as locations, or texture coordinates, will be buffered to a GL
 * VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexNormals method.
 */
-(void) doNotBufferVertexNormals;

/**
 * Convenience method to cause the vertex color data of this node and all
 * descendant nodes to be skipped when createGLBuffers is invoked. The vertex
 * data is not buffered to a a GL VBO, is retained in application memory, and
 * is submitted to the GL engine on each frame render.
 *
 * Only the vertex colors will not be buffered to a GL VBO. Any other vertex
 * data, such as locations, or texture coordinates, will be buffered to a GL
 * VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexColors method.
 */
-(void) doNotBufferVertexColors;

/**
 * Convenience method to cause the vertex texture coordinate data of this
 * node and all descendant nodes, for all texture units used by those nodes,
 * to be skipped when createGLBuffers is invoked. The vertex data is not
 * buffered to a a GL VBO, is retained in application memory, and is submitted
 * to the GL engine on each frame render.
 *
 * Only the vertex texture coordinates will not be buffered to a GL VBO.
 * Any other vertex data, such as locations, or texture coordinates, will
 * be buffered to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexTextureCoordinates method.
 */
-(void) doNotBufferVertexTextureCoordinates;

/**
 * Convenience method to cause the vertex index data of this node and all
 * descendant nodes to be skipped when createGLBuffers is invoked. The vertex
 * data is not buffered to a a GL VBO, is retained in application memory, and
 * is submitted to the GL engine on each frame render.
 *
 * Only the vertex indices will not be buffered to a GL VBO. Any other vertex
 * data, such as locations, or texture coordinates, will be buffered to a GL
 * VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexColors method.
 */
-(void) doNotBufferVertexIndices;


#pragma mark Texture alignment

/**
 * Indicates whether the texture coordinates of the meshes of the descendants
 * expect that the texture was flipped upside-down during texture loading.
 * 
 * The vertical axis of the coordinate system of OpenGL is inverted relative to
 * the iOS view coordinate system. This results in textures from most file formats
 * being oriented upside-down, relative to the OpenGL coordinate system. All file
 * formats except PVR format will be oriented upside-down after loading.
 *
 * For each descendant mesh node, the value of this property is used in
 * combination with the value of the  isFlippedVertically property of a texture
 * to determine whether the texture will be oriented correctly when displayed
 * using these texture coordinates.
 *
 * When a texture or material is assigned to a mesh node, the value of this
 * property is compared with the isFlippedVertically property of the texture to
 * automatically determine whether the texture coordinates of the mesh need to
 * be flipped vertically in order to display the texture correctly. If needed,
 * the texture coordinates will be flipped automatically. As part of that inversion,
 * the value of this property will also be flipped, to indicate that the texture
 * coordinates are now aligned differently.
 *
 * Reading the value of this property will return YES if the same property of
 * any descendant mesh node returns YES, otherwise this property will return NO.
 *
 * The initial value of this property is set when the underlying mesh texture
 * coordinates are built or loaded. See the same property on the CC3Resource
 * class to understand how this property is set during mesh resource loading.
 *
 * Generally, the application never has need to change the value of this property.
 * If you do need to adjust the value of this property, you sould do so before
 * setting a texture or material into any descendant mesh nodes.
 *
 * Setting the value of this property will set the same property on all descendant nodes.
 * 
 * When building meshes programmatically, you should endeavour to design the
 * mesh so that this property will be YES if you will be using vertically-flipped
 * textures (all texture file formats except PVR). This avoids the texture
 * coordinate having to be flipped automatically when a texture or material
 * is assigned to this mesh node.
 */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures;

/**
 * Convenience method that flips the texture coordinate mapping vertically
 * for all texture units on all descendant mesh nodes. This has the effect
 * of flipping the textures vertically on the model. and can be useful for
 * creating interesting effects, or mirror images.
 */
-(void) flipTexturesVertically;

/**
 * Convenience method that flips the texture coordinate mapping horizontally
 * for all texture units on all descendant mesh nodes. This has the effect
 * of flipping the textures vertically on the model. and can be useful for
 * creating interesting effects, or mirror images.
 */
-(void) flipTexturesHorizontally;

/**
 * @deprecated The alignment performed by this method is now performed automatically
 * whenever a texture or material is attached to a mesh node. If you do need to manually
 * align a mesh to a texture, use the expectsVerticallyFlippedTextures property
 * to indicate whether the texture mesh is aligned with vertically-flipped texture
 * prior to setting the texture or material into your mesh nodes.
 */
-(void) alignTextures;

/**
 * @deprecated The alignment performed by this method is now performed automatically
 * whenever a texture or material is attached to a mesh node. If you do need to manually
 * align a mesh to a texture, use the expectsVerticallyFlippedTextures property
 * to indicate whether the texture mesh is aligned with vertically-flipped texture
 * prior to setting the texture or material into your mesh nodes.
 */
-(void) alignInvertedTextures;


#pragma mark Updating

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides this node with an opportunity to perform update activities before any
 * changes are applied to the transformMatrix of the node. The similar and complimentary method
 * updateAfterTransform: is automatically invoked after the transformMatrix has been recalculated.
 * If you need to make changes to the transform properties (location, rotation, scale) of the node,
 * or any child nodes, you should override this method to perform those changes.
 *
 * The global transform properties of a node (globalLocation, globalRotation, globalScale)
 * will not have accurate values when this method is run, since they are only valid after
 * the transformMatrix has been updated. If you need to make use of the global properties
 * of a node (such as for collision detection), override the udpateAfterTransform: method
 * instead, and access those properties there.
 *
 * This abstract template implementation does nothing. Subclasses that act predictively,
 * such as those undergoing trajectories or IPO curves can update their properties accordingly.
 * Subclasses that override do not need to invoke this superclass implementation. Nor do
 * subclasses need to invoke this method on their child nodes. That is performed automatically.
 *
 * The specified visitor encapsulates the CC3Scene instance, to allow this node to interact
 * with other nodes in the scene.
 *
 * The visitor also encapsulates the deltaTime, which is the interval, in seconds, since
 * the previous update. This value can be used to create realistic real-time motion that
 * is independent of specific frame or update rates. Depending on the setting of the
 * maxUpdateInterval property of the CC3Scene instance, the value of dt may be clamped to
 * an upper limit before being passed to this method. See the description of the CC3Scene
 * maxUpdateInterval property for more information about clamping the update interval.
 * 
 * If you wish to remove this node during an update visitation, avoid invoking the remove
 * method on the node from this method. The visitation process involves iterating through
 * collections of child nodes, and removing a node during the iteration of a collection
 * raises an error. Instead, you can use the requestRemovalOf: method on the visitor,
 * which safely processes all removal requests once the full visitation run is complete.
 *
 * As described in the class documentation, in keeping with best practices, updating the
 * model state should be kept separate from frame rendering. Therefore, when overriding
 * this method in a subclass, do not perform any drawing or rending operations. This
 * method should perform model updates only.
 *
 * This method is invoked automatically at each scheduled update. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides this node with an opportunity to perform update activities after
 * the transformMatrix of the node has been recalculated. The similar and complimentary
 * method updateBeforeTransform: is automatically invoked before the transformMatrix
 * has been recalculated.
 *
 * The global transform properties of a node (globalLocation, globalRotation, globalScale)
 * will have accurate values when this method is run, since they are only valid after the
 * transformMatrix has been updated. If you need to make use of the global properties
 * of a node (such as for collision detection), override this method.
 *
 * Since the transformMatrix has already been updated when this method is invoked, if
 * you override this method and make any changes to the transform properties (location,
 * rotation, scale) of any node, you should invoke the updateTransformMatrices method of
 * that node, to have its transformMatrix, and those of its child nodes, recalculated.
 *
 * This abstract template implementation does nothing. Subclasses that need access to
 * their global transform properties will override accordingly. Subclasses that override
 * do not need to invoke this superclass implementation. Nor do subclasses need to invoke
 * this method on their child nodes. That is performed automatically.
 *
 * The specified visitor encapsulates the CC3Scene instance, to allow this node to interact
 * with other nodes in the scene.
 *
 * The visitor also encapsulates the deltaTime, which is the interval, in seconds, since
 * the previous update. This value can be used to create realistic real-time motion that
 * is independent of specific frame or update rates. Depending on the setting of the
 * maxUpdateInterval property of the CC3Scene instance, the value of dt may be clamped to
 * an upper limit before being passed to this method. See the description of the CC3Scene
 * maxUpdateInterval property for more information about clamping the update interval.
 * 
 * If you wish to remove this node during an update visitation, avoid invoking the remove
 * method on the node from this method. The visitation process involves iterating through
 * collections of child nodes, and removing a node during the iteration of a collection
 * raises an error. Instead, you can use the requestRemovalOf: method on the visitor,
 * which safely processes all removal requests once the full visitation run is complete.
 *
 * As described in the class documentation, in keeping with best practices, updating the
 * model state should be kept separate from frame rendering. Therefore, when overriding
 * this method in a subclass, do not perform any drawing or rending operations. This
 * method should perform model updates only.
 *
 * This method is invoked automatically at each scheduled update. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor;

/**
 * If the shouldTrackTarget property is set to YES, orients this node to point towards
 * its target, otherwise does nothing. The transform visitor is used to transform
 * this node and all its children if this node re-orients.
 *
 * This method is invoked automatically if either the target node or this node moves.
 * Usually, the application should never need to invoke this method directly.
 */
-(void) trackTargetWithVisitor: (CC3NodeTransformingVisitor*) visitor;

/**
 * If the shouldUseFixedBoundingVolume property is set to NO, this method marks the bounding
 * volume of this node as dirty and in need of rebuilding. If the shouldUseFixedBoundingVolume
 * property is set to YES, this method does nothing.
 *
 * If this node has an underlying mesh, and you have changed the vertex locations in the mesh
 * directly, you can invoke this method to ensure that the bounding volume is rebuilt to
 * encompass the new vertex locations.
 *
 * The bounding volume is automatically transformed as the node is transformed, so this
 * method does NOT need to be invoked when the node is transformed (moved, rotated, or scaled).
 */
-(void) markBoundingVolumeDirty;

/** @deprecated Renamed to markBoundingVolumeDirty. */
-(void) rebuildBoundingVolume DEPRECATED_ATTRIBUTE;


#pragma mark Transformations

/**
 * A list of objects that have requested that they be notified whenever the
 * transform of this node has changed.
 *
 * This occurs when one of the transform properties (location, rotation & scale)
 * of this node, or any of its structural ancestor nodes has changed.
 *
 * Each listener in this list will be sent the nodeWasTransformed: notification
 * message when the transformMatrix of this node is recalculated, or is set directly.
 *
 * Objects can be added to this list by using the addTransformListener: method.
 *
 * This property will be nil if no objects have been added via addTransformListener:
 * method, or if they have all been subsequently removed.
 *
 * Transform listeners are not retained. Each listener should know who it has subscribed
 * to, and must remove itself as a listener (using the removeTransformListener: method)
 * when appropriate, such as when being deallocated.
 *
 * For the same reason, transform listeners are not automatically copied when a node is
 * copied. If you copy a node and want its listeners to also listen to the copied node,
 * you must deliberately add them to the new node.
 */
@property(nonatomic, readonly) CCArray* transformListeners;

/**
 * Indicates that the specified listener object wishes to be notified whenever
 * the transform of this node has changed.
 *
 * This occurs when one of the transform properties (location, rotation & scale)
 * of this node, or any of its structural ancestor nodes has changed.
 *
 * The listener will be sent the nodeWasTransformed: notification message whenever
 * the transformMatrix of this node is recalculated, or is set directly.
 *
 * Once added by this method, the newly added listener is immediately sent the
 * nodeWasTransformed: notification message, so that the listener is aware of
 * this node's current transform state. This is necessary in case this node
 * will not be transformed in the near future,
 *
 * It is safe to invoke this method more than once for the same listener, or
 * with a nil listener. In either case, this method simply ignores the request.
 *
 * Transform listeners are not retained. Each listener should know who it has subscribed
 * to, and must remove itself as a listener (using the removeTransformListener: method)
 * when appropriate, such as when being deallocated.
 *
 * For the same reason, transform listeners are not automatically copied when a node is
 * copied. If you copy a node and want its listeners to also listen to the copied node,
 * you must deliberately add them to the new node.
 */
-(void) addTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener;

/**
 * Removes the specified transform listener from the list of objects that have
 * requested that they be notified whenever the transform of this node has changed.
 *
 * It is safe to invoke this method with a listener that was not previously added,
 * or with a nil listener. In either case, this method simply ignores the request.
 */
-(void) removeTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener;

/**
 * Removes all transform listeners, that were previously added via the
 * addTransformListener: method, from this node.
 */
-(void) removeAllTransformListeners;

/**
 * Nodes can be listeners of the transforms of other nodes.
 *
 * If the specified node is the node in the target property of this node, and
 * the shouldTrackTarget property of this node is YES, the targetLocation property
 * of this node is set from the globalLocation property of the specified node.
 *
 * Subclasses may add additional behaviour, but should invoke this superclass
 * implementation to ensure basic targetting behaviour is maintained.
 */
-(void) nodeWasTransformed: (CC3Node*) aNode;

/**
 * If the specified node is the node in the target property of this node, the
 * target property of this node is set to nil.
 *
 * Subclasses may add additional behaviour, but should invoke this superclass
 * implementation to ensure basic targetting behaviour is maintained.
 */
-(void) nodeWasDestroyed: (CC3Node*) aNode;


/**
 * The transformation matrix derived from the location, rotation and scale transform properties
 * of this node and any ancestor nodes.
 *
 * This matrix is recalculated automatically when the node is updated.
 *
 * The transformation matrix for each node is global, in that it includes the transforms of
 * all ancestors to the node. This streamlines rendering in that it allows the transform of
 * each drawable node to be applied directly, and allows the order in which drawable nodes
 * are drawn to be independent of the node structural hierarchy.
 *
 * Setting this property udpates the globalLocation and globalScale properties.
 */
@property(nonatomic, retain) CC3Matrix* transformMatrix;

/**
 * Returns the transform matrix of the parent node. Returns nil if there is no parent.
 * 
 * This template property is used by this class to base the transform of this node on
 * the transform of its parent. A subclass may override to return nil if it determines
 * that it wants to ignore the parent transform when calculating its own transform.
 */
@property(nonatomic, readonly) CC3Matrix* parentTransformMatrix;

/**
 * Indicates whether any of the transform properties, location, rotation, or scale
 * have been changed, and so the transformMatrix of this node needs to be recalculated.
 *
 * This property is automatically set to YES when one of those properties have been
 * changed, and is reset to NO once the transformMatrix has been recalculated.
 *
 * Recalculation of the transformMatrix occurs automatically when the node is updated.
 */
@property(nonatomic, readonly) BOOL isTransformDirty;

/**
 * Indicates that the transformation matrix is dirty and needs to be recalculated.
 *
 * This method is invoked automatically as needed. Usually the application never needs
 * to invoke this method directly.
 */
-(void) markTransformDirty;

/**
 * Returns the matrix inversion of the transformMatrix.
 * 
 * This can be useful for converting global transform properties, such as global
 * location, rotation and scale to the local coordinate system of the node.
 */
@property(nonatomic, readonly) CC3Matrix* transformMatrixInverted;

/**
 * Applies the transform properties (location, rotation, scale) to the transformMatrix
 * of this node, and all descendant nodes.
 *
 * To ensure that the transforms are accurately applied, this method also automatically
 * ensures that the transform matrices of any ancestor nodes are also updated, if needed,
 * before updating this node and its descendants.
 *
 * Equivalent behaviour is invoked automatically during scheduled update processing
 * between the invocations of the updateBeforeTransform: and updateAfterTransform: methods.
 *
 * Changes that you make to the transform properties within the updateBeforeTransform:
 * method will automatically be applied to the transformMatrix of the node. Because of this,
 * it's best to make any changes to the transform properties in that method.
 *
 * However, if you need to make changes to the transform properties in the
 * updateAfterTransform: method of a node, after you have made all your changes to the
 * node properties, you should then invoke this method on the node, in order to have
 * those changes applied to the transformMatrix.
 *
 * Similarly, if you have updated the transform properties of this node asynchronously
 * through an event callback, and want those changes to be immediately reflected in
 * the transform matrices, you can use this method to do so.
 */
-(void) updateTransformMatrices;

/**
 * Applies the transform properties (location, rotation, scale) to the transformMatrix
 * of this node, but NOT to any descendant nodes.
 *
 * To ensure that the transforms are accurately applied, this method also automatically
 * ensures that the transform matrices of any ancestor nodes are also updated, if needed,
 * before updating this node and its descendants.
 *
 * Use this method only when you know that you only need the transformMatrix of the
 * specific node updated, and not the matrices of the decendants of that node, or if
 * you will manually update the transformMatrices of the descendant nodes. If in doubt,
 * use the updateTransformMatrices method instead.
 */
-(void) updateTransformMatrix;

/**
 * Returns the heighest node in my ancestor hierarchy, including myself, that
 * is dirty. Returns nil if neither myself nor any of my ancestors are dirty.
 *
 * This method can be useful when deciding at what level to update a hierarchy.
 *
 * This method is invoked automatically by the updateTransformMatrices and
 * updateTransformMatrix, so in most cases, you do not need to use this method
 * directly. However, there may be special cases where you want to determine
 * beforehand whether this node or its ancestors are dirty or not before running
 * either of those methods.
 */
@property(nonatomic, readonly) CC3Node* dirtiestAncestor;

/**
 * Template method that recalculates the transform matrix of this node from the
 * location, rotation and scale transformation properties, using the specified visitor.
 *
 * This method is invoked automatically by the visitor. Usually the application
 * never needs to invoke this method.
 */
-(void) buildTransformMatrixWithVisitor: (CC3NodeTransformingVisitor*) visitor;

/**
 * Returns the class of visitor that will automatically be instantiated when visiting
 * this node to transform, without updating.
 *
 * The returned class must be a subclass of CC3NodeTransformingVisitor. This implementation
 * returns CC3NodeTransformingVisitor. Subclasses may override to customize the behaviour
 * of the updating visits.
 */
-(id) transformVisitorClass;


#pragma mark Drawing

/**
 * Template method that applies this node's transform matrix to the GL matrix stack
 * and draws this node using the specified visitor.
 *
 * This method is invoked by the drawing visitor when it visits the node, if all of
 * the following conditions are met by this node:
 *   - ths node is visible (as indicated by the visible property)
 *   - has content to draw (as indicated by the hasLocalContent property)
 *   - intersects the camera's frustum (which is checked by invoking the method
 *     doesIntersectFrustum: of this node with the frustum from the visitor).
 *
 * If all of these tests pass, drawing is required, and this method transforms and draws
 * the local content of this node.
 *
 * This method is automatically invoked from the visitor. The application should
 * never have need to used this method.
 */
-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Returns whether the bounding volume of this node intersects the specified camera frustum.
 * This check does not include checking children, only the local content.
 *
 * This method is invoked automatically during the drawing operations of each frame to determine
 * whether this node does not intersect the camera frustum, should be culled from the visible
 * nodes and not drawn. A return value of YES will cause the node to be drawn, a return value
 * of NO will cause the node to be culled and not drawn.
 *
 * Culling nodes that are not visible to the camera is an important performance enhancement. The
 * node should strive to be as accurate as possible in returning whether it intersects the camera's
 * frustum. Incorrectly returning YES will cause wasted processing within the GL engine. Incorrectly
 * returning NO will cause a node that should at least be partially visible to not be drawn.
 *
 * This implementation simply delegates to the more general doesIntersectBoundingVolume: method.
 * However, subclasses may override to take special action when testing for the specific case
 * of intersection with the camera frustum.
 */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum;

/**
 * Draws the content of this node to the GL engine. The specified visitor encapsulates
 * the frustum of the currently active camera, and certain drawing options.
 *
 * As described in the class documentation, in keeping with best practices, drawing and frame
 * rendering should be kept separate from updating the model state. Therefore, when overriding
 * this method in a subclass (or any of the template methods invoked by this method), do not
 * update any model state. This method should perform only frame rendering operations.
 * 
 * This method is invoked automatically as part of the drawing operations initiated by
 * the transformAndDrawWithVisitor: method.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Checks that the child nodes of this node are in the correct drawing order relative
 * to other nodes. This implementation forwards this request to all descendants.
 * Those descendants with local content to draw will check their positions in the
 * drawing sequence by passing this notification up the ancestor chain to the CC3Scene.
 *
 * By default, nodes are automatically repositioned on each drawing frame to optimize
 * the drawing order, so you should usually have no need to use this method.
 * 
 * However, in order to eliminate the overhead of checking each node during each drawing
 * frame, you can disable this automatic behaviour by setting the allowSequenceUpdates
 * property of specific drawing sequencers to NO.
 *
 * In that case, if you modify the properties of a node or its content, such as mesh or material
 * opacity, and your CC3Scene drawing sequencer uses that criteria to sort nodes, you can invoke
 * this method to force the node to be repositioned in the correct drawing order.
 *
 * You don't need to invoke this method when initially setting the properties.
 * You only need to invoke this method if you modify the properties after the node has
 * been added to the CC3Scene, either by itself, or as part of a node assembly.
 */
-(void) checkDrawingOrder;


#pragma mark Node structural hierarchy

/**
 * The child nodes of this node, in a node structural hierarchy.
 *
 * This property will be nil if this node has no child nodes.
 *
 * To change the contents of this array, use the addChild: and removeChild:
 * methods of this class. Do not manipulate the contents of this array directly.
 */
@property(nonatomic, readonly) CCArray* children;

/**
 * The parent node of this node, in a node structural hierarchy.
 *
 * This property will be nil if this node has not been added as a child to a parent node.
 */
@property(nonatomic, readonly) CC3Node* parent;

/**
 * Returns the root ancestor of this node, in the node structural hierarchy,
 * or returns this node, if this node has no parent.
 *
 * In almost all cases, this node returned will be the CC3Scene. However, if
 * this node and all of its ancestors have not been added to the CC3Scene,
 * then the returned node may be some other node.
 *
 * Reading this property traverses up the node hierarchy. If this property
 * is accessed frequently, it is recommended that it be cached.
 */
@property(nonatomic, readonly) CC3Node* rootAncestor;

/**
 * If this node has been added to the 3D scene, either directly, or as part
 * of a node assembly, returns the CC3Scene instance that forms the 3D scene,
 * otherwise returns nil.
 *
 * Reading this property traverses up the node hierarchy. If this property
 * is accessed frequently, it is recommended that it be cached.
 */
@property(nonatomic, readonly) CC3Scene* scene;

/** @deprecated Renamed to scene. */
@property(nonatomic, readonly) CC3Scene* world DEPRECATED_ATTRIBUTE;

/**
 * If this node has been added to the 3D scene, either directly, or as part
 * of a node assembly, returns the activeCamera property of the CC3Scene instance,
 * as accessed via the scene property, otherwise returns nil.
 *
 * Reading this property traverses up the node hierarchy. If this property
 * is accessed frequently, it is recommended that it be cached.
 */
@property(nonatomic, retain, readonly) CC3Camera* activeCamera;

/**
 * Indicates whether this instance should automatically remove itself from its parent
 * once its last child is removed.
 *
 * Setting this property to YES can be useful for certain types of wrapper subclasses,
 * where a instance wraps a single child node. Removing that child node from the node
 * hierarchy (typically by invoking the remove method on that child node, and which
 * may be performed automatically for some types of child nodes), will also cause the
 * wrapper node to be removed as well. This cleanup is important to avoid littering
 * your scene with empty wrapper nodes.
 *
 * The initial value of this property is NO, indicating that this instance will NOT
 * automatically remove itself from the node hierarchy once all its child nodes have
 * been removed.
 */
@property(nonatomic, assign) BOOL shouldAutoremoveWhenEmpty;

/**
 * Adds the specified node as a direct child node to this node.
 *
 * The child node is automatically removed from its existing parent.
 *
 * It is safe to invoke this method more than once for the same child node.
 * This method does nothing if the child already has this node as its parent.
 *
 * If you are invoking this method from the updateBeforeTransform: of the node
 * being added, this node, or any ancestor node (including your CC3Scene), the
 * transformMatrix of the node being added (and its descendant nodes) will
 * automatically be updated. However, if you are invoking this method from the
 * updateAfterTransform: method, you should invoke the updateTransformMatrices
 * method on the node being added after this method is finished, to ensure that
 * the transform matrices are udpated.
 */
-(void) addChild: (CC3Node*) aNode;

/**
 * Adds the specified node as a direct child node to this node, and localizes
 * the child node's location, rotation, and scale properties to this node.
 *
 * This has the effect of leaving the global location, rotation and scale
 * of the child node as they were, but re-homing the node to this parent.
 * Visually, the node appears to stay in place, but will now move with the
 * new parent, not with the old parent.
 *
 * For instance, you might have an apple object whose overall intended global
 * size and orientation you know, but you want that object to be added to a bowl,
 * so that when you move the bowl, the apple moves with it. The bowl has likely
 * been rotated and scaled, and raised onto a table, and you don't want your
 * known apple to be transformed by the table and bowl when you add the apple
 * to the bowl, You can use this method on the bowl object to add the apple,
 * and reverse the table and bowl transforms for the apple, so that the apple
 * will appear with its current size and orientation.
 *
 * To do this, this method finds the appropriate location, rotation, and scale
 * properties for the child node that will result in the globalLocation,
 * globalRotation and globalScale properties remaining the same after it has
 * been added to this parent node.
 *
 * The child node is removed from its existing parent.
 *
 * This method makes use of the transformMatrices of this node and the node
 * being added. To ensure that both matrices are each up to date, this method
 * invokes updateTransformMatrix method on both this node and the node being
 * added. You can therefore invoke this method without having to consider
 * whether the transformMatrix has been calculated already.
 *
 * This method changes the transform properties of the node being added.
 * If you are invoking this method from the updateBeforeTransform: of the node
 * being added, this node, or any ancestor node (including your CC3Scene), the
 * transformMatrix of the node being added (and its descendant nodes) will
 * automatically be updated. However, if you are invoking this method from the
 * updateAfterTransform: method, you should invoke the updateTransformMatrices
 * method on the node being added after this method is finished, to ensure that
 * the transform matrices are udpated.
 */
-(void) addAndLocalizeChild: (CC3Node*) aNode;

/**
 * Template method that is invoked automatically when this node is added to its parent node.
 *
 * This method is invoked automatically after the node has been added to its parent (and to
 * the scene if the parent is already in the scene). You can override this method to implement
 * any node initialization that might depend on knowing the parent of this node.
 *
 * You can also override the setParent: method to perform simple initialization to this node
 * that depends on the parent (eg- setting the name of this node based on the parent's name).
 *
 * However, if you need to make any structural changes, such as adding children to this node
 * once it is added to its parent, you must do so in this wasAdded method instead.
 *
 * The wasAdded method is inherently safer than the setParent: method because the wasAdded method
 * is invoked after this node has been fully established in the parent ancestor hierarchy, whereas
 * the setParent: method is invoked part-way through establishing that structural relationship.
 *
 * This implementation does nothing. Subclasses can override.
 */
-(void) wasAdded;

/**
 * Removes the specified node as a direct child node to this node.
 *
 * Does nothing if the specified node is not actually a child of this node.
 *
 * If the shouldStopActionsWhenRemoved property of the node being removed is set to YES, any
 * CCActions running on that node will be stopped and removed. If the shouldStopActionsWhenRemoved
 * property of the node being removed is set to NO, any CCActions running on that node will be paused,
 * but not removed.
 *
 * Stopping and removing CCActions is important because the actions running on a node retain links
 * to the node. If the actions are simply paused, those links will be retained forever, potentially
 * creating memory leaks of nodes that are invisibly retained by their actions.
 *
 * By default, the shouldStopActionsWhenRemoved property is set to YES, and all CCActions running
 * on the node being removed will be stopped and removed. If the shouldStopActionsWhenRemoved is
 * set to NO, it is up to you to clean up any running CCActions when you are done with the node.
 * You can do this using either the stopAllActions or cleanupActions method.
 *
 * If the shouldAutoremoveWhenEmpty property is YES, and the last child node is
 * being removed, this node will invoke its own remove method to remove itself from
 * the node hierarchy as well. See the notes for the shouldAutoremoveWhenEmpty
 * property for more info on autoremoving when all child nodes have been removed.
 */
-(void) removeChild: (CC3Node*) aNode;

/** Removes all child nodes of this node. */
-(void) removeAllChildren;

/**
 * Convenience method that removes this node from its structural hierarchy
 * by simply invoking removeChild: on the parent of this node.
 *
 * If the shouldStopActionsWhenRemoved property of this node is set to YES, any CCActions running
 * on this node will be stopped and removed. If the shouldStopActionsWhenRemoved property of this
 * node is set to NO, any CCActions running on that node will be paused, but not removed.
 *
 * Stopping and removing CCActions is important because the actions running on a node retain links
 * to the node. If the actions are simply paused, those links will be retained forever, potentially
 * creating memory leaks of nodes that are invisibly retained by their actions.
 *
 * By default, the shouldStopActionsWhenRemoved property is set to YES, and all CCActions running
 * on this node will be stopped and removed. If the shouldStopActionsWhenRemoved is set to NO, it
 * is up to you to clean up any running CCActions when you are done with this node. You can do this
 * using either the stopAllActions or cleanupActions method.
 * 
 * During a node visitation run with a CCNodeVisitor, you should avoid using this
 * method directly. The visitation process involves iterating through collections of
 * child nodes, and removing a node during the iteration of a collection raises an error.
 *
 * Instead, during a visitation run, you can use the requestRemovalOf: method on the visitor,
 * which safely processes all removal requests once the full visitation run is complete.
 */
-(void) remove;

/**
 * Template method that is invoked automatically when this node is removed from its parent node.
 *
 * This implementation sets the isRunning property to NO. It also checks the value of the
 * shouldStopActionsWhenRemoved property and, if it is set to YES, stops and removes any
 * CCActions running on this node and its descendants.
 */
-(void) wasRemoved;

/**
 * Retrieves the first node found with the specified name, anywhere in the structural hierarchy
 * of descendants of this node (not just direct children). The hierarchy search is depth-first.
 */
-(CC3Node*) getNodeNamed: (NSString*) aName;

/**
 * Retrieves the first node found with the specified tag, anywhere in the structural hierarchy
 * of descendants of this node (not just direct children). The hierarchy search is depth-first.
 */
-(CC3Node*) getNodeTagged: (GLuint) aTag;

/**
 * Returns whether this node is the same object as the specified node, or is a structural
 * descendant (child, grandchild, etc) of the specified node.
 */
-(BOOL) isDescendantOf: (CC3Node*) aNode;

/**
 * Returns an autoreleased array containing this node and all its descendants.
 * This is done by invoking flattenInto: with a newly-created array, and returning the array. 
 */
-(CCArray*) flatten;

/**
 * Adds this node to the specified array, and then invokes this method on each child node.
 * The effect is to populate the array with this node and all its descendants.
 */
-(void) flattenInto: (CCArray*) anArray;

/**
 * Wraps this node in a new autoreleased instance of CC3Node, and returns the new
 * wrapper node. This node appears as the lone child node of the returned node.
 *
 * This is a convenience method that is useful when a rotational or locational
 * offset needs to be assigned to a node.
 *
 * For instance, for nodes that point towards a specific target or location, to change the side
 * of the node that is facing that target node, you can use this method to create a wrapper node,
 * and then assign an offset rotation to the this node, so that it is rotated by a fixed amount
 * relative to the wrapper node. You can then assign the target or target location to the wrapper,
 * which will rotate to point its forwardDirection towards the target, carrying this node along
 * with it. The result will be that the desired side of this node will point towards the target.
 *
 * As another example, to offset the origin of a node (the point associated with its location, and
 * around which the node pivots when rotated you can use this method to create a wrapper node, and
 * then assign an offset location to this node, so that it is offset by a fixed amount relative to
 * the wrapper node. You can then rotate or locate the wrapper node, which will carry this node
 * along with it. The result will be that the desired point in this node will be located at the
 * origin of rotation and location operations.
 *
 * The shouldAutoremoveWhenEmpty property of the returned wrapper node is set to YES, so the wrapper
 * node will automatically disappear when this node is removed from the node structural hierarchy.
 *
 * The returned wrapper node will have the name "<this node name>-OW".
 */
-(CC3Node*) asOrientingWrapper;

/**
 * Wraps this node in a new  autoreleased instance of CC3Node, and returns the new
 * wrapper node. This node appears as the lone child node of the returned node.
 *
 * This method uses the asOrientingWrapper method to create the wrapper. The
 * shouldTrackTarget property of the returned wrapper node is set to YES so that
 * the wrapper will automatically track the target after it has been assigned.
 */
-(CC3Node*) asTrackingWrapper;

/**
 * Wraps this node in a new  autoreleased instance of CC3Node, and returns the new
 * wrapper node. This node appears as the lone child node of the returned node.
 *
 * This method uses the asOrientingWrapper method to create the wrapper. The
 * shouldAutotargetCamera property of the returned wrapper node is set to YES
 * so that the wrapper will automatically locate and track the active camera.
 * When using this method, you do not need to set the camera as the target of
 * the wrapper, as it is located and assigned automatically. See the notes of
 * the shouldAutotargetCamera property for more info.
 */
-(CC3Node*) asCameraTrackingWrapper;

/**
 * Wraps this node in a new  autoreleased instance of CC3Node, and returns the new
 * wrapper node. This node appears as the lone child node of the returned node.
 *
 * This method uses the asTrackingWrapper method to create a wrapper that
 * automatically tracks the target once it has been assigned.
 *
 * The isTrackingForBumpMapping of the returned wrapper is set to YES, so that
 * if the target that is assigned is a CC3Light, the wrapper will update the
 * globalLightLocation of the wrapped node from the tracked location of the light,
 * instead of rotating to face the light. This allows the normals embedded in any
 * bump-mapped texture on the wrapped node to interact with the direction of the
 * light source to create per-pixel luminosity that appears realistic
 */
-(CC3Node*) asBumpMapLightTrackingWrapper;


#pragma mark CC3Node actions

/**
 * Indicates whether all the CCActions currently running on this node and all
 * descendants should be stopped and removed when this node is removed from its parent.
 *
 * If the value of this property is YES, when this node is removed from its parent, the cleanupActions
 * method will automatically be invoked. If the value of this method is NO, when this node is removed
 * from its parent, the isRunning property will be set to NO, which causes all actions to be paused,
 * but not removed.
 *
 * Stopping and removing CCActions is important because the actions running on a node retain links
 * to the node. If the actions are simply paused, those links will be retained forever, potentially
 * creating memory leaks of nodes that are invisibly retained by their actions.
 *
 * The initial value of this property is YES, indicating that all actions will be stopped and removed
 * when this node is removed from its parent. If you have reason to want the actions to be paused but
 * not removed when removing this node from its parent, set this property to NO.
 *
 * One example of such a situation is when you use the addChild: method to move a node from one
 * parent to another. As part of the processing of the addChild: method, if the node already has
 * a parent, it is automatically removed from its current parent. The addChild: method temporarily
 * sets this property to NO so that the actions are not destroyed during the move.
 *
 * If you have some other reason for setting this property to NO, be sure to set it back to YES before
 * this node, or the ancestor node assembly that this node belongs to is removed for good, otherwise
 * this node will continue to be retained by any actions running on this node, and this node will not
 * be deallocated.
 *
 * Alternately, if you have this property set to NO, you can manually stop and remove all actions
 * using the cleanupActions method.
 */
@property(nonatomic, assign) BOOL shouldStopActionsWhenRemoved;

/** @deprecated Renamed to shouldStopActionsWhenRemoved. */
@property(nonatomic, assign) BOOL shouldCleanupActionsWhenRemoved DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to shouldStopActionsWhenRemoved. */
@property(nonatomic, assign) BOOL shouldCleanupWhenRemoved DEPRECATED_ATTRIBUTE;

/** Starts the specified action, and returns that action. This node becomes the action's target. */
-(CCAction*) runAction: (CCAction*) action;

/**
 * Stops any existing action on this node that had previously been assigned the specified tag,
 * assigns the tag to the specified new action, starts that new action, returns it. This node
 * becomes the action's target.
 *
 * This method is useful for replacing one action of a particular type with another, without
 * affecting any other actions that might be executing on the same node. For instance, a node might
 * be both moving and fading-in concurrently. If the movement is altered by a user interaction, it
 * might be desirable to stop the movement action and replace it, without affecting the fade action.
 *
 * Using this method to assign a tag to the movement action when running it allows that movement
 * action to be stopped and replaced with a new movement action, through a second invocation of
 * this method with the same tag, without affecting the fade action.
 *
 * When using this method, you can use the CC3ActionTag enumeration as a convenience for consistently
 * assigning tags by action type.
 */
-(CCAction*) runAction: (CCAction*) action withTag: (NSInteger) tag;

/** Pauses all actions running on this node. */
-(void) pauseAllActions;

/** Resumes all actions running on this node. */
-(void) resumeAllActions;

/** Stops and removes all actions on this node. */
-(void) stopAllActions;

/** Stops and removes the specified action on this node. */
-(void) stopAction: (CCAction*) action;

/** Stops and removes the action with the specified tag from this node. */
-(void) stopActionByTag: (NSInteger) tag;

/** Returns the action with the specified tag running on this node. */
-(CCAction*) getActionByTag: (NSInteger) tag;

/**
 * Returns the numbers of actions that are running plus the ones that are scheduled to run
 * (actions in actionsToAdd and actions arrays).
 *
 * Composable actions are counted as 1 action. Example:
 *    If you are running 1 Sequence of 7 actions, it will return 1.
 *    If you are running 7 Sequences of 2 actions, it will return 7.
 */
-(NSInteger) numberOfRunningActions;

/**
 * Stops all running CCActions for this node and all descendant nodes.
 * Effectively invokes stopAllActions on this node and all descendant nodes.
 */
-(void) cleanupActions;

/** @deprecated Renamed to cleanupActions. */
-(void) cleanup DEPRECATED_ATTRIBUTE;


#pragma mark Touch handling

/**
 * Indicates if this node, or any of its descendants, will respond to UI touch events.
 *
 * This property also affects which node will be returned by the touchableNode property.
 * If the isTouchEnabled property is explicitly set for a parent node, but not for a
 * child node, both the parent and the child can be touchable, but it will be the
 * parent that is returned by the touchableNode property of either the parent or child.
 *
 * This design simplifies identifying the node that is of interest when a touch event
 * occurs. Thus, a car may be drawn as a node assembly of many descendant nodes (doors,
 * wheels, body, etc). If isTouchEnabled is set for the car structural node, but not
 * each wheel, it will be the parent car node that will be returned by the touchableNode
 * property of the car structural node, or each wheel node. This allows the user to
 * touch a wheel, but still have the car identified as the object of interest.
 * 
 * Normally, only visible nodes can be touched. But this can be changed by setting the
 * shouldAllowTouchableWhenInvisible property to YES.
 * 
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL isTouchEnabled;

/**
 * Indicates whether this node will respond to UI touch events.
 *
 * A node may often be touchable even if the isTouchEnabled flag is set to NO.
 *
 * When the node is visible, this property returns YES under either of the
 * following conditions:
 *   - The isTouchEnabled property of this node is set to YES.
 *   - The shouldInheritTouchability property of this node is set to YES,
 *     AND the isTouchable property of the parent of this node returns YES.
 *
 * When the node is NOT visible, this property returns YES under either of the
 * following conditions:
 *   - The isTouchEnabled property of this node is set to YES
 *     AND the shouldAllowTouchableWhenInvisible is set to YES.
 *   - The shouldInheritTouchability property of this node is set to YES,
 *     AND the isTouchable property of the parent of this node returns YES.
 *     AND the shouldAllowTouchableWhenInvisible of this node is set to YES.
 *
 * This design simplifies identifying the node that is of interest when a touch event
 * occurs. Thus, a car may be drawn as a node assembly of many descendant nodes (doors,
 * wheels, body, etc). If isTouchEnabled is set for the car structural node, but not
 * each wheel, it will be the parent car node that will be returned by the touchableNode
 * property of the car structural node, or each wheel node. This allows the user to
 * touch a wheel, but still have the car identified as the object of interest.
 */
@property(nonatomic, readonly) BOOL isTouchable;

/**
 * Indicates the node that is of interest if this node is selected by a touch event.
 * The value of this property is not always this node, but may be an ancestor node instead.
 *
 * The value returned by this property is this node if the isTouchEnabled property of this
 * node is set to YES, or the nearest ancestor whose isTouchEnabled property is set to YES,
 * or nil if neither this node, nor any ancestor has the isTouchEnabled property set to YES.
 *
 * This design simplifies identifying the node that is of interest when a touch event
 * occurs. Thus, a car may be drawn as a node assembly of many descendant nodes (doors,
 * wheels, body, etc). If isTouchEnabled is set for the car structural node, but not
 * each wheel, it will be the parent car node that will be returned by the touchableNode
 * property of the car structural node, or each wheel node. This allows the user to
 * touch a wheel, but still have the car identified as the object of interest.
 */
@property(nonatomic, readonly) CC3Node* touchableNode;

/**
 * Indicates whether this node should automatically be considered touchable if this
 * node's parent is touchable.
 * 
 * By using this property, you can turn off touchability on a child node, even when
 * the parent node is touchable.
 *
 * Normally, a node will be touchable if its isTouchEnabled property is set to YES
 * on the node itself, or on one of its ancestors. You can change this behaviour by
 * setting this property to NO on the child node. With the isTouchEnabled property
 * and this property both set to NO, the isTouchable property will return NO, even
 * if the isTouchable property of the parent returns YES, and the node will not
 * respond to touch events even if the parent node does.
 *
 * The initial value of this property is YES, indicating that this node will return
 * YES in the isTouchable property if the parent node returns YES in its isTouchable
 * property, even if the isTouchEnabled property of this node is set to NO.
 */
@property(nonatomic, assign) BOOL shouldInheritTouchability;

/**
 * Indicates whether this node should be touchable even when invisible.
 *
 * When this property and the visible property are set to NO, the isTouchable
 * property will always return NO. When this property is YES, the isTouchable
 * property can return YES for an invisible node, if the other conditions for
 * touchability are met. See the isTouchable property for more info.
 *
 * The initial value of this propety is NO.
 */
@property(nonatomic, assign) BOOL shouldAllowTouchableWhenInvisible;

/**
 * Sets the isTouchEnabled property to YES on this node and all descendant nodes.
 *
 * This is a convenience method that will make all descendants individually touchable
 * and selectable, which is not usually what is wanted. Usually, you would set
 * isTouchEnabled on specific parent nodes that are of interest to select a sub-assembly
 * as a whole. However, making all components individually selectable can sometimes be
 * desired, and is useful for testing.
 *
 * For more info see the notes for the isTouchEnabled and touchableNode properties.
 *
 * This is a convenience method that can find use in testing, where it might be of
 * interest to be able to individually select small components of a larger assembly. 
 */
-(void) touchEnableAll;

/**
 * Sets the isTouchEnabled property to NO on this node and all descendant nodes.
 *
 * This is a convenience method that will make this node and all its decendants
 * unresponsive to touches. For more info see the notes for the isTouchEnabled
 * and touchableNode properties.
 */
-(void) touchDisableAll;


#pragma mark Intersections and collision detection

/**
 * Returns whether the bounding volume of this node intersects the given bounding volume.
 * This check does not include checking children, only the local content.
 *
 * This capability can be used for detecting collisions between nodes, or to indicate
 * whether an object is located in a particular volume of space, for example, the
 * frustum of the camera.
 *
 * This implementation delegates to this node's boundingVolume. Nodes without a bounding
 * volume will not intersect any other bounding volume. With that design in mind, if
 * either the bounding volume of this node, or the otherBoundingVolume is nil, this
 * method returns NO
 */
-(BOOL) doesIntersectBoundingVolume: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns whether the bounding volume of this node intersects the bounding volume of
 * the specified node. This check does not include checking descendants of either node,
 * only the direct bounding volumes.
 *
 * This capability can be used for detecting collisions between nodes.
 *
 * This implementation invokes the doesIntersectBoundingVolume: method of this node,
 * passing the bounding volume of the other node. For an intersection to occur, both
 * nodes must each have a bounding volume. Nodes without a bounding volume will not
 * intersect any other bounding volume. Correspondingly, if either of the nodes do
 * not have a bounding volume, this method returns NO
 */
-(BOOL) doesIntersectNode: (CC3Node*) otherNode;

/**
 * Indicates whether this bounding volume should ignore intersections from rays.
 * If this property is set to YES, intersections with rays will be ignored, and
 * the doesIntersectGlobalRay: method will always return NO, and the
 * locationOfGlobalRayIntesection: and globalLocationOfGlobalRayIntesection:
 * properties will always return kCC3VectorNull.
 *
 * The initial value of this property is NO, and most of the time this is sufficient.
 *
 * For some uses, such as the bounding volumes of nodes that should be excluded from
 * puncturing from touch selection rays, such as particle emitters, it might make
 * sense to set this property to YES, so that the bounding volume is not affected
 * by rays from touch events.
 *
 * This property delegates to the bounding volume. Setting this property will
 * have no effect if this node does not have a bounding volume assigned.
 */
@property(nonatomic, assign) BOOL shouldIgnoreRayIntersection;

/**
 * Returns whether this node is intersected (punctured) by the specified ray,
 * which is specified in the global coordinate system.
 *
 * This implementation delegates to this node's boundingVolume. If this node has
 * no bounding volume, this method returns NO.
 */
-(BOOL) doesIntersectGlobalRay: (CC3Ray) aRay;

/**
 * Returns the location at which the specified ray intersects the bounding volume
 * of this node, or returns kCC3VectorNull if this node does not have a bounding
 * volume, the shouldIgnoreRayIntersection property is set to YES, or the ray does
 * not intersect the bounding volume.
 *
 * The result honours the startLocation of the ray, and will return kCC3VectorNull
 * if the bounding volume is "behind" the startLocation, even if the line projecting
 * back through the startLocation in the negative direction of the ray intersects
 * the bounding volume.
 *
 * The ray may start inside the bounding volume of this node, in which case, the
 * returned location represents the exit location of the ray.
 *
 * The ray must be specified in global coordinates. The returned location is in
 * the local coordinate system of this node. A valid non-null result can therefore
 * be used to place another node at the intersection location, by simply adding
 * it to this node at the returned location (eg- drag & drop, bullet holes, etc).
 *
 * The returned result can be tested for null using the CC3VectorIsNull function.
 *
 * When using this method, keep in mind that the returned intersection location is
 * located on the surface of the bounding volume, not on the surface of the node.
 * Depending on the shape of the surface of the node, the returned location may
 * visually appear to be at a different location than where you expect to see it
 * on the surface of on the node.
 */
-(CC3Vector) locationOfGlobalRayIntesection: (CC3Ray) aRay;

/**
 * Returns the location at which the specified ray intersects the bounding volume
 * of this node, or returns kCC3VectorNull if this node does not have a bounding
 * volume, the shouldIgnoreRayIntersection property is set to YES, or the ray does
 * not intersect the bounding volume.
 *
 * The result honours the startLocation of the ray, and will return kCC3VectorNull
 * if the bounding volume is "behind" the startLocation, even if the line projecting
 * back through the startLocation in the negative direction of the ray intersects
 * the bounding volume.
 *
 * The ray may start inside the bounding volume of this node, in which case, the
 * returned location represents the exit location of the ray.
 *
 * Both the input ray and the returned location are specified in global coordinates.
 *
 * The returned result can be tested for null using the CC3VectorIsNull function.
 *
 * When using this method, keep in mind that the returned intersection location is
 * located on the surface of the bounding volume, not on the surface of the node.
 * Depending on the shape of the surface of the node, the returned location may
 * visually appear to be at a different location than where you expect to see it
 * on the surface of on the node.
 */
-(CC3Vector) globalLocationOfGlobalRayIntesection: (CC3Ray) aRay;

/**
 * Returns the descendant nodes that are intersected (punctured) by the specified 
 * ray. This node is included in the test, and will be included in the returned
 * nodes if it has a bounding volume that is punctured by the ray.
 *
 * The results are returned as a CC3NodePuncturingVisitor instance, which can be
 * queried for the nodes that were punctured by the ray, and the locations of the
 * punctures on the nodes. The returned visitor orders the nodes by distance between
 * the startLocation of the ray and the global puncture location on each node.
 *
 * The ray must be specified in global coordinates.
 *
 * This implementation creates an instance of CC3NodePuncturingVisitor on the
 * specified ray, and invokes the visit: method on that visitor, passing this
 * node as that starting point of the visitation.
 *
 * The results will not include nodes that do not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 *
 * This method also excludes invisible nodes and nodes where the ray starts inside
 * the bounding volume of the node. To gain finer control over this behaviour,
 * instead of using this method, create an instance of CC3NodePuncturingVisitor,
 * adjust its settings, and invoke the visit: method on the visitor, with this
 * node as the arguement.
 *
 * Also, to avoid creating a new visitor for each visit, you can create a single
 * instance of CC3NodePuncturingVisitor, cache it, and invoke the visit: method
 * repeatedly, with or without changing the ray between invocations.
 */
-(CC3NodePuncturingVisitor*) nodesIntersectedByGlobalRay: (CC3Ray) aRay;

/**
 * Collects the descendant nodes that are intersected (punctured) by the
 * specified ray, and returns the node whose global puncture location is
 * closest to the startLocation of the ray, or returns nil if the ray
 * punctures no nodes. This node is included in the test.
 *
 * The ray must be specified in global coordinates.
 *
 * The result will not include any node that does not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 *
 * This method also excludes invisible nodes and nodes where the ray starts inside
 * the bounding volume of the node. To gain finer control over this behaviour,
 * instead of using this method, create an instance of CC3NodePuncturingVisitor,
 * adjust its settings, and invoke the visit: method on the visitor, with this
 * node as the arguement.
 *
 * Also, to avoid creating a new visitor for each visit, you can create a single
 * instance of CC3NodePuncturingVisitor, cache it, and invoke the visit: method
 * repeatedly, with or without changing the ray between invocations.
 *
 * This implementation simply invokes the nodesIntersectedByGlobalRay:
 * method, and reads the value of the closestPuncturedNode from the
 * CC3NodePuncturingVisitor returned by that method. See the notes
 * of the nodesIntersectedByGlobalRay: method for more info.
 */
-(CC3Node*) closestNodeIntersectedByGlobalRay: (CC3Ray) aRay;


#pragma mark Animation

/**
 * The animation content of this node, which manages animating the node under
 * the direction of a CC3Animate action.
 *
 * To animate this node, set this property to an instance of a subclass of the
 * abstract CC3NodeAnimation class, populated with animation data, and then
 * create an instance of a CC3Animate action, and run it on this node. 
 */
@property(nonatomic, retain) CC3NodeAnimation* animation;

/** Indicates whether this node, or any of its descendants, contains an instance of an animation. */
@property(nonatomic, readonly) BOOL containsAnimation;

/**
 * Indicates whether animation is enabled for this node.
 * This property only has effect if there the animation property is not nil.
 *
 * The value of this property only applies to this node, not its child nodes.
 * Child nodes that have this property set to YES will be animated even if
 * this node has this property set to NO, and vice-versa.
 
 * Use the methods enableAllAnimation and disableAllAnimation to turn animation
 * on or off for all the nodes in a node assembly.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL isAnimationEnabled;

/**
 * Enables animation of this node from animation data held in the animation property.
 *
 * This will not enable animation of child nodes.
 */
-(void) enableAnimation;

/**
 * Disables animation of this node from animation data held in the animation property.
 *
 * This will not disable animation of child nodes.
 */
-(void) disableAnimation;

/**
 * Enables animation of this node, and all descendant nodes, from animation
 * data held in the animation property of this node and each descendant node.
 */
-(void) enableAllAnimation;

/**
 * Disables animation of this node, and all descendant nodes, from animation
 * data held in the animation property of this node and each descendant node.
 */
-(void) disableAllAnimation;

/**
 * The number of frames of animation supported by this node, or its descendants.
 *
 * If this node is animated, returns the frame count from this node's animation.
 * Otherwise, a depth-first traversal of the descendants is performed, and the
 * first non-zero animation frame count value is returned.
 *
 * Returns zero if none of this node and its descendants contains any animation.
 */
@property(nonatomic, readonly) GLuint animationFrameCount;

/** 
 * Updates the location, rotation and scale of this node based on the animation frame
 * located at the specified time, which should be a value between zero and one, with
 * zero indicating the first animation frame, and one indicating the last animation frame.
 * Only those properties of this node for which there is animation data will be changed.
 *
 * This implementation delegates to the CC3NodeAnimation instance held in the animation
 * property, then passes this notification along to child nodes to align them with the
 * same animation frame. Linear interpolation of the frame data may be performed, based
 * on the number of frames and the specified time.
 *
 * If disableAnimation or disableAllAnimation has been invoked on this node,
 * it will be excluded from animation, and this method will not have any affect
 * on this node. However, this method will be propagated to child nodes.
 *
 * This method is invoked automatically from an instance of CC3Animate that is animating
 * this node. Usually, the application never needs to invoke this method directly.
 */
-(void) establishAnimationFrameAt: (ccTime) t;


#pragma mark Developer support

/**
 * Indicates whether this node should display a descriptive label on this node.
 *
 * When set to YES, a descriptive text label will appear on this node. The descriptive label is
 * positioned at the origin of this node, in this node's local coordinate system. The origin is
 * the location around which transforms such as rotation, movement and scale will occur when
 * applied to this node. The origin is not always the same as the center of geometry of the node.
 *
 * The descriptive text will appear in the font size specified in the class-side descriptorFontSize
 * property. The color of the descriptive text is determined by the subclass. Typically, for
 * structural nodes, it is the same color as the wireframe box that is drawn around the node when
 * the shouldDrawWireframeBox property is set to YES. For nodes with local content to draw, the
 * color of the text is the same as the wireframe box that is drawn around the local content of the
 * node when the shouldDrawLocalContentWireframeBox property is set to YES.
 *
 * Setting this property to YES can be useful during development in determining the identification
 * of visible nodes, or the location of nodes that are unable to be drawn correctly.
 *
 * The descriptive label is drawn by creating and adding a CC3NodeDescriptor node as a child node
 * to this node. CC3NodeDescriptor is a type of CC3Billboard, and is configured to contain a 2D
 * CCLabel, whose text is set to the description of this node. Setting this property to YES adds
 * the descriptor child node, and setting this property to NO removes the descriptor child node.
 *
 * By default, the child descriptor node is not touchable, even if this node is touchable. If, for
 * some reason you want the descriptor text to be touchable, you can retrieve the descriptor node
 * from the descriptorNode property, and set the isTouchEnabled property to YES.
 */
@property(nonatomic, assign) BOOL shouldDrawDescriptor;

/**
 * If the shouldDrawDescriptor is set to YES, returns the child node
 * that draws the descriptor text on this node. Otherwise, returns nil.
 */
@property(nonatomic, readonly) CC3NodeDescriptor* descriptorNode;

/**
 * Indicates the state of the shouldDrawDescriptor property of this node and all
 * descendant nodes.
 *
 * Setting this property sets that value into the shouldDrawDescriptor property
 * on this and all descendant nodes.
 *
 * Setting this property to YES draws a descriptor label on this node and each
 * descendant node. Setting this property to NO removes all of those labels.
 *
 * Reading this property traverses this node and its descendants and returns NO
 * if any descendant returns NO. Otherwise returns YES.
 */
@property(nonatomic, assign) BOOL shouldDrawAllDescriptors;

/**
 * Returns the font size that will be used when drawing the descriptor
 * text when the shouldDrawDescriptor property is set to YES on any node.
 * 
 * The initial value of this class-side property is 14.0.
 */
+(CGFloat) descriptorFontSize;

/**
 * Sets the font size that will be used when drawing the descriptor
 * text when the shouldDrawDescriptor property is set to YES on any node.
 * 
 * The initial value of this class-side property is 14.0.
 */
+(void) setDescriptorFontSize: (CGFloat) fontSize;

/**
 * Indicates whether the node should display a wireframe bounding box around this node
 * and all its descendants.
 *
 * The wireframe box is drawn by creating and adding a CC3WireframeBoundingBoxNode as
 * a child node to this node. The dimensions of the child node are set from the
 * boundingBox property of this node. Setting this property to YES adds the wireframe
 * child node, and setting this property to NO removes the wireframe child node.
 *
 * Setting this property to YES can be useful during development in determining the
 * boundaries of a 3D structural node.
 *
 * The color of the wireframe box will be the value of the class-side
 * defaultWireframeBoxColor property, or the value of the color property of
 * this node if defaultWireframeBoxColor is equal to kCCC4FBlackTransparent.
 *
 * If this node has no local content, or no descendant nodes with local content,
 * setting this property will have no effect. In this condition, it is possible
 * to set this property to YES and subsequently read the property back as NO.
 *
 * By default, the child wireframe node is not touchable, even if this node is
 * touchable. If, for some reason you want the wireframe to be touchable, you can
 * retrieve the wireframe node from the wireframeBoxNode property, and set the
 * isTouchEnabled property to YES.
 */
@property(nonatomic, assign) BOOL shouldDrawWireframeBox;

/**
 * If the shouldDrawWireframeBox is set to YES, returns the child node
 * that draws the wireframe box around this node. Otherwise, returns nil.
 */
@property(nonatomic, readonly) CC3WireframeBoundingBoxNode* wireframeBoxNode;

/**
 * Returns the color that wireframe bounding boxes will be drawn in when created
 * using the shouldDrawWireframeBox property.
 *
 * Setting this property to kCCC4FBlackTransparent will cause the color
 * of any new wireframe bounding boxes to be set to the value of the color
 * property of the node instead.
 * 
 * The initial value of this class property is kCCC4FYellow.
 */
+(ccColor4F) wireframeBoxColor;

/**
 * Sets the color that wireframes will be drawn in when created using
 * the shouldDrawWireframeBox property.
 *
 * Changing this property will affect the color of any new wireframe bounding
 * boxes created. It does not affect any instances that already have a wireframe
 * bounding box established.
 *
 * Setting this property to kCCC4FBlackTransparent will cause the color
 * of any new wireframe bounding boxes to be set to the value of the color
 * property of the node instead.
 * 
 * The initial value of this class property is kCCC4FYellow.
 */
+(void) setWireframeBoxColor: (ccColor4F) aColor;

/**
 * Indicates the state of the shouldDrawWireframeBox property of this node and
 * all descendant nodes.
 *
 * Setting this property sets that value into the shouldDrawWireframeBox property
 * on this and all descendant nodes.
 *
 * Setting this property to YES draws individual wireframe boxes around this node
 * and each descendant node. Setting this property to NO removes all of those boxes.
 *
 * Reading this property traverses this node and its descendants and returns NO
 * if any descendant returns NO. Otherwise returns YES.
 *
 * If this node has no local content, or has descendant nodes without local content,
 * or descendants themselves (for example cameras, lights, or simply empty structural
 * nodes), setting this property will have no effect for those descendants. Under
 * those conditions, it is possible to set this property to YES and subsequently
 * read the property back as NO.
 */
@property(nonatomic, assign) BOOL shouldDrawAllWireframeBoxes;

/**
 * Indicates the state of the shouldDrawLocalContentWireframeBox property of this
 * node, if it has local content, and all descendant nodes that have local content.
 *
 * Setting this property sets that value into the shouldDrawLocalContentWireframeBox
 * property on this node, if it has local content, and all descendant nodes that
 * have local content.
 *
 * Setting this property to YES draws individual wireframe boxes around any local
 * content of this node and any descendant nodes that have local content.
 * Setting this property to NO removes all of those boxes.
 *
 * Reading this property traverses this node and its descendants and returns NO
 * if any descendant returns NO. Otherwise returns YES.
 */
@property(nonatomic, assign) BOOL shouldDrawAllLocalContentWireframeBoxes;

/**
 * Adds a visble line, drawn in the specified color, from the origin of this node to a location
 * somewhat outside the node in the specified direction.
 *
 * The extent that the line will protrude from this node is proportional to the size of this
 * node, as determined by the CC3DirectionMarkerNode class-side directionMarkerScale property.
 * 
 * The line is drawn by creating and adding a CC3DirectionMarkerNode as a child node to this node.
 * The length of the child node is set from the boundingBox property of this node, so that the
 * line protrudes somewhat from this node.
 *
 * You can add more than one direction marker, and assign different colors to each.
 *
 * This feature can be useful during development in helping to determine the rotational orientation
 * of a 3D structural node.
 *
 * By default, the child line node is not touchable, even if this node is touchable. If, for some
 * reason you want the wireframe to be touchable, you can retrieve the direction marker nodes via
 * the directionMarkers property, and set the isTouchEnabled property to YES.
 */
-(void) addDirectionMarkerColored: (ccColor4F) aColor inDirection: (CC3Vector) aDirection;

/**
 * Adds a visble line, drawn in the color indicated by the directionMarkerColor class-side property,
 * from the origin of this node to a location somewhat outside the node in the direction of the
 * forwardDirection property, in the node's local coordinate system, and in the direction of the
 * globalForwardDirection property, in the global coordinate system of the scene.
 * 
 * See the addDirectionMarkerColored:inDirection: method for more info.
 */
-(void) addDirectionMarker;

/**
 * Adds three visble direction marker lines, indicating the direction of the X, Y & Z axes,
 * in the local coordinate system of this node.
 *
 * The lines extend from the origin of this node to a location somewhat outside the node in
 * the direction of each of the X, Y & Z axes.
 *
 * The lines are color-coded red, green and blue for the X, Y & Z axes, respectively, as an
 * easy (RGB <=> XYZ) mnemonic.
 * 
 * See the addDirectionMarkerColored:inDirection: method for more info.
 */
-(void) addAxesDirectionMarkers;

/**
 * Removes all the direction marker child nodes that were previously added using
 * the addDirectionMarkerColored:inDirection: and addDirectionMarker methods,
 * from this node and all descendant nodes.
 */
-(void) removeAllDirectionMarkers;

/**
 * Returns an array of all the direction marker child nodes that were previously added
 * using the addDirectionMarkerColored:inDirection: and addDirectionMarker methods.
 */
@property(nonatomic, readonly) CCArray* directionMarkers;

/**
 * Returns the color that direction marker lines will be drawn in when created
 * using the addDirectionMarker method.
 *
 * Setting this property to kCCC4FBlackTransparent will cause the color
 * of any new direction marker lines to be set to the value of the color
 * property of the node instead.
 * 
 * The initial value of this class property is kCCC4FRed.
 */
+(ccColor4F) directionMarkerColor;

/**
 * Sets the color that direction marker lines will be drawn in when created
 * using the addDirectionMarker method.
 *
 * Changing this property will affect the color of any new direction marker lines
 * created. It does not affect any existing direction marker lines.
 *
 * Setting this property to kCCC4FBlackTransparent will cause the color
 * of any new direction marker lines to be set to the value of the color
 * property of the node instead.
 * 
 * The initial value of this class property is kCCC4FRed.
 */
+(void) setDirectionMarkerColor: (ccColor4F) aColor;

/**
 * Indicates whether the node should display the extent of its bounding volume.
 *
 * The bounding volume is drawn by creating and adding a CC3BoundingVolumeDisplayNode
 * as a child node to this node. The shape, dimensions, and color of the child node
 * are determined by the type of bounding volume.
 *
 * If the bounding volume of this node is a composite bounding node, such as the standard
 * CC3NodeTighteningBoundingVolumeSequence, all bounding volumes will be displayed, each
 * in its own color.
 *
 * If this node has no bounding volume, setting this property will have no visible effect.
 *
 * Setting this property to YES can be useful during development in determining
 * the boundaries of a 3D structural node, and how it is interacting with the
 * camera frustum and other nodes during collision detection.
 *
 * By default, the displayed bounding volume node is not touchable, even if this
 * node is touchable. If, for some reason you want the displayed bounding volume
 * to be touchable, you can retrieve the bounding volume node from the displayNode
 * property of the bounding volume, and set its isTouchEnabled property to YES.
 */
@property(nonatomic, assign) BOOL shouldDrawBoundingVolume;

/**
 * Indicates that this node, and each of its descendant nodes, should display the
 * extent of its bounding volumes.
 *
 * Setting the value of this property has the effect of setting the value of the
 * shouldDrawBoundingVolume property on this node and all its descendant nodes.
 *
 * Reading this property will return YES if this property is set to YES on any
 * descendant, otherwise NO will be return.
 */
@property(nonatomic, assign) BOOL shouldDrawAllBoundingVolumes;

/**
 * When this property is set to YES, a log message will be output whenever the
 * doesIntersectBoundingVolume: method returns YES (indicating that another bounding volume
 * intersects the bounding volume of this node), if the shouldLogIntersections property of
 * the other bounding volume is also set to YES.
 *
 * The shouldLogIntersections property of this node and the other bounding
 * volumes must both be set to YES for the log message to be output.
 *
 * The initial value of this property is NO.
 *
 * This property is useful during development to help trace intersections between nodes and
 * bounding volumes, such as collision detection between nodes, or whether a node is within
 * the camera's frustum.
 * 
 * This property is only available when the LOGGING_ENABLED compiler build setting is
 * defined and set to 1.
 */
@property(nonatomic, assign) BOOL shouldLogIntersections;

/**
 * When this property is set to YES, a log message will be output whenever
 * the doesIntersectBoundingVolume: method returns NO (indicating that
 * another bounding volume does not intersect the bounding volume of this
 * node), if the shouldLogIntersectionMisses property of the other bounding
 * volume is also set to YES.
 *
 * The shouldLogIntersectionMisses property of this node and the other
 * bounding volumes must both be set to YES for the log message to be output.
 *
 * The initial value of this property is NO.
 *
 * This property is useful during development to help trace intersections
 * between nodes and bounding volumes, such as collision detection between
 * nodes, or whether a node is within the camera's frustum.
 * 
 * This property is only available when the LOGGING_ENABLED
 * compiler build setting is defined and set to 1.
 */
@property(nonatomic, assign) BOOL shouldLogIntersectionMisses;

@end


#pragma mark -
#pragma mark CC3LocalContentNode

/**
 * CC3LocalContentNode is an abstract class that forms the basis for nodes
 * that have local content to draw.
 *
 * You can cause a wireframe box to be drawn around the local content of
 * the node by setting the shouldDrawLocalContentWireframeBox property to YES.
 * This can be particularly useful during development to locate the boundaries
 * of a node, or to locate a node that is not drawing properly.
 * You can set the default color of this wireframe using the class-side
 * defaultLocalContentWireframeBoxColor property.
 */
@interface CC3LocalContentNode : CC3Node {
	CC3BoundingBox globalLocalContentBoundingBox;
	GLint zOrder;
}

/**
 * Returns the center of geometry of the local content of this node,
 * in the local coordinate system of this node.
 *
 * If this node has no local content, returns the zero vector.
 */
@property(nonatomic, readonly) CC3Vector localContentCenterOfGeometry;

/**
 * Returns the smallest axis-aligned bounding box that surrounds the local
 * content of this node, in the local coordinate system of this node.
 *
 * If this node has no local content, returns kCC3BoundingBoxNull.
 */
@property(nonatomic, readonly) CC3BoundingBox localContentBoundingBox;

/**
 * Returns the center of geometry of the local content of this node,
 * in the global coordinate system of the 3D scene.
 *
 * If this node has no local content, returns the value of the globalLocation property.
 *
 * The value of this property is calculated by transforming the value of the
 * localContentCenterOfGeometry property, using the transformMatrix of this node.
 */
@property(nonatomic, readonly) CC3Vector globalLocalContentCenterOfGeometry;

/**
 * Returns the smallest axis-aligned bounding box that surrounds the local
 * content of this node, in the global coordinate system of the 3D scene.
 *
 * If this node has no local content, returns kCC3BoundingBoxNull.
 *
 * The value of this property is calculated by transforming the eight vertices derived
 * from the localContentBoundingBox property, using the transformMatrix of this node,
 * and constructing another bounding box that surrounds all eight transformed vertices.
 *
 * Since all bounding boxes are axis-aligned (AABB), if this node is rotated, the
 * globalLocalContentBoundingBox will generally be significantly larger than the
 * localContentBoundingBox. 
 */
@property(nonatomic, readonly) CC3BoundingBox globalLocalContentBoundingBox;

/**
 * Checks that this node is in the correct drawing order relative to other nodes.
 * This implementation forwards this notification up the ancestor chain to the CC3Scene,
 * which checks if the node is correctly positioned in the drawing sequence, and
 * repositions the node if needed.
 *
 * By default, nodes are automatically repositioned on each drawing frame to optimize
 * the drawing order, so you should usually have no need to use this method.
 * 
 * However, in order to eliminate the overhead of checking each node during each drawing
 * frame, you can disable this automatic behaviour by setting the allowSequenceUpdates
 * property of specific drawing sequencers to NO.
 *
 * In that case, if you modify the properties of a node or its content, such as mesh or material
 * opacity, and your CC3Scene drawing sequencer uses that criteria to sort nodes, you can invoke
 * this method to force the node to be repositioned in the correct drawing order.
 *
 * You don't need to invoke this method when initially setting the properties.
 * You only need to invoke this method if you modify the properties after the node has
 * been added to the CC3Scene, either by itself, or as part of a node assembly.
 */
-(void) checkDrawingOrder;


#pragma mark Developer support

/**
 * Indicates whether the node should display a wireframe box around the local content
 * of this node.
 *
 * This property is distinct from the inherited shouldDrawWireframeBox property.
 * The shouldDrawWireframeBox property draws a wireframe that encompasses this node
 * and any child nodes, where this property draws a wireframe that encompasses just
 * the local content for this node alone. If this node has no children, then the two
 * wireframes will surround the same volume.
 *
 * The wireframe box is drawn by creating and adding a CC3WireframeBoundingBoxNode as a child node
 * to this node. The dimensions of the child node are set from the localContentBoundingBox
 * property of this node. Setting this property to YES adds the wireframe child node, and
 * setting this property to NO removes the wireframe child node.
 *
 * Setting this property to YES can be useful during development in determining the
 * boundaries of the local drawn content of a node.
 *
 * The color of the wireframe box will be the value of the class-side
 * defaultLocalContentWireframeBoxColor property, or the value of the color
 * property of this node if defaultLocalContentWireframeBoxColor is equal
 * to kCCC4FBlackTransparent.
 */
@property(nonatomic, assign) BOOL shouldDrawLocalContentWireframeBox;

/**
 * If the shouldDrawLocalContentWireframeBox is set to YES, returns the child node that
 * draws the wireframe around the local content of this node. Otherwise, returns nil.
 */
@property(nonatomic, readonly) CC3WireframeBoundingBoxNode* localContentWireframeBoxNode;

/**
 * Returns the color that local content wireframe bounding boxes will be drawn
 * in when created using the shouldDrawLocalContentWireframeBox property.
 *
 * Setting this property to kCCC4FBlackTransparent will cause the color
 * of any new local content wireframe bounding boxes to be set to the value
 * of the color property of the node instead.
 * 
 * The initial value of this class property is kCCC4FMagenta.
 */
+(ccColor4F) localContentWireframeBoxColor;

/**
 * Sets the color that local content wireframes will be drawn in when created
 * using the shouldDrawWireframeBox property.
 *
 * Changing this property will affect the color of any new local content wireframe
 * bounding boxes created. It does not affect any instances that already have a
 * wireframe bounding box established.
 *
 * Setting this property to kCCC4FBlackTransparent will cause the color
 * of any new local content wireframe bounding boxes to be set to the value
 * of the color property of the node instead.
 * 
 * The initial value of this class property is kCCC4FMagenta.
 */
+(void) setLocalContentWireframeBoxColor: (ccColor4F) aColor;

@end
