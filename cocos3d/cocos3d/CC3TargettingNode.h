/*
 * CC3TargettingNode.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Node.h"

/** The OpenGL ES standard initial "forward" direction for unrotated objects. */
#define kCC3VectorInitialForwardDirection kCC3VectorUnitZNegative

/** The OpenGL ES standard initial "up" direction for unrotated objects. */
#define kCC3VectorInitialUpDirection kCC3VectorUnitYPositive

/** The OpenGL ES standard initial "right" direction for unrotated objects. */
#define kCC3VectorInitialRightDirection kCC3VectorUnitXPositive

/**
 * Enumeration of options for restricting rotation of a CC3TargettingNode to rotate
 * only around a single axis when attempting to point at a target node or targetLocation.
 */
typedef enum {
	kCC3TargettingAxisRestrictionNone,		/**< Don't restrict targetting rotations. */
	kCC3TargettingAxisRestrictionXAxis,		/**< Only rotate around the X-axis. */
	kCC3TargettingAxisRestrictionYAxis,		/**< Only rotate around the Y-axis. */
	kCC3TargettingAxisRestrictionZAxis,		/**< Only rotate around the Z-axis. */
} CC3TargettingAxisRestriction;


#pragma mark -
#pragma mark CC3TargettingNode

/**
 * This is a node class representing a 3D model node that can be pointed in a particular
 * direction, or at another node. The node can be pointed in a direction as an alternative
 * to rotating the node. Lights and cameras are examples of nodes that frequently need to
 * be pointed in this way.
 *
 * Instances can be targetted at another node, and can track that node as both the target
 * and this node move through the 3D world. For instance, if this targetting node was a
 * camera, it could be pointed at another node representing a car, and could track that
 * car as both the car or the camera were moved through the 3D world, always keeping the
 * car in the center of the camera's vision.
 *
 * To have an instance of CC3TargettingNode track the location of another node,
 * set that other node as the target property of the targetting node, and set the
 * shouldTrackTarget property of the targetting node to YES. If you leave the
 * shouldTrackTarget with a value of NO, the targetting node will rotate to point
 * at the target node initially, but will not then track that node. This can be useful
 * as a mechanism for orienting objects initially, but not forcing them to actively
 * track the other object dynamically.
 *
 * You can also use an instance of CC3TargettingNode to make any node point at a target.
 * You do this by adding that node as a child to an instance of CC3TargettingNode, and
 * then instructing the targetting node to point in a particular direction, or to track
 * a particular target. As the targetting node orients itself to do so, it will rotate
 * the child node to face the same direction. To orient the child node so that a particular
 * side of the child node is facing that direction, when you add the child node to the
 * parent targetting node, rotate it within the targetting node so that the side you want
 * to face in the targetted direction is facing in the default forwardDirection of the
 * targetting node (the negative Z-axis).
 * 
 * For example, if you have a cube, and you want the face of the cube that is pointing
 * down the positive X-axis to face the target, rotate the cube +90 degrees around the
 * Y-axis so that face of the cube is now facing down the negative Z-axis. When you add
 * the cube to an instance of CC3TargettingNode, that face of the cube will always point
 * in the direction of the parent targetting node's target.
 *
 * You can restrict the tracking of a target or targetLocation to rotation around a
 * single axis, if you want to have, say a signpost turn towards someone, but only
 * by rotating side-to-side, and not up and down. See the notes for the axisRestriction
 * property for more on this idea.
 *
 * There are three directions associated with a targetting node, and these appear as
 * properties in this class. The forwardDirection is the direction that the node is
 * pointing. This property can either be set directly, or indirectly by specifying a
 * targetLocation, or better yet, an actual target node, each of which are settable
 * properties on this node. It should be recognized that both target and targetLocation
 * are simply means to an end in setting the forwardDirection.
 *
 * But pointing the node in a particular direction does not completely define its
 * rotation in 3D space, because the node can be oriented in any rotation around the
 * axis along the forwardDirection vector (think of pointing a camera at a scene, and
 * then rotating the camera along the axis of its lens, landscape towards portrait).
 *
 * This is solved by specifying an additional upDirection, which fixes the rotation
 * around the forwardDirection by specifying which direction is considered to be 'up'.
 * This is further simplified by fixing a worldUpDirection, which does not need to
 * change. The local upDirection then becomes a read-only property calculated from
 * the combination of the forwardDirection, and the worldUpDirection.
 *
 * The third direction, the rightDirection, represents the direction that is 
 * "off to the right" if you were looking down the forwardDirection and 'up' was
 * the upDirection. The rightDirection is calculated from this. Although not really
 * needed, the rightDirection can be useful for some applications, and is provided
 * as a read-only property for completeness.
 *
 * The forwardDirection, upDirection and rightDirection form the orthagonal axes
 * of the local rotated coordinate system of the node.
 */
@interface CC3TargettingNode : CC3Node {
	CC3Node* target;
	CC3Vector targetLocation;
	CC3TargettingAxisRestriction axisRestriction;
	BOOL isNewTarget;
	BOOL shouldTrackTarget;
	BOOL isTargetLocationDirty;
	BOOL isRotatorDirtyByTargetLocation;
}

/**
 * The target node at which this node is pointed. If the shouldTrackTarget property
 * is set to YES, this node will track the target so that it always points to the
 * target, regardless of how the target and this node move through the 3D world.
 */
@property(nonatomic, retain) CC3Node* target;

/** 
 * The location of the target. Instead of specifying a target node with the target
 * property, this property can be used to set a specific location to point towards.
 * This targetLocation is not tracked, and moving the targetting node will cause
 * it to point away from the targetLocation.
 *
 * When retrieving this property value, if the property was earlier explictly set,
 * it will be retrieved cleanly. However, if rotation was set by Euler angles,
 * quaternions, or forwardDirection, retriving the targetLocation comes with two
 * caveats. The first is that calculating a targetLocation requires the global
 * location of this node, which is only calculated when the node's transformMatrix
 * is calculated after all model updates have been processed. This means that the
 * calculated targetLocation will generally be one frame behind the real value.
 * The second caveat is that the targetLocation requires extrapolating the
 * forwardDirection out to an arbitrary invented point. This can sometimes
 * introduce higher calculation inaccuracies. In general, it is best to use this
 * property directly, both reading and writing it, rather than reading this 
 * property after setting one of the other rotational properties.
 */
@property(nonatomic, assign) CC3Vector targetLocation;

/**
 * Indicates whether rotation should be restricted to a single axis when attempting
 * to rotate the node to point at the target or targetLocation.
 *
 * For example, a cheap way of simulating a full 3D tree is to have a simple flat picture
 * of a tree that you rotate around the vertical axis so that it always faces the camera.
 * Or you might hae a signpost that you want to rotate towards the camera, or towards
 * another object as that object moves around the world, and you want the signpost to
 * remain vertically oriented, and rotate side to side, but not up and down, should the
 * object being tracked move up and down.
 *
 * The initial value of this property is kCC3TargettingAxisRestrictionNone, indicating
 * that the forward direction of this node will point directly at the target or
 * targetLocation, and is free to move in all three axial directions.
 */
@property(nonatomic, assign) CC3TargettingAxisRestriction axisRestriction;

/**
 * Indicates whether this instance should track the node set in the target property
 * as the target and this node move around, or should initially point to that target,
 * but should then maintain the same pointing direction, regardless of how the target
 * or this node moves around. Initially, this property is set to NO, indicating that
 * if the target property is set, this node will initially point to it, but will not
 * track it as it moves.
 *
 * If this property is set to YES, subsequently changing the value of the rotation,
 * quaternion, or forwardDirection properties will have no effect, since they would
 * interfere with the ability to track the target. To set specific rotations or
 * pointing direction, first set this property back to NO.
 */
@property(nonatomic, assign) BOOL shouldTrackTarget;

/**
 * The direction in which this node is pointing, relative to the node's coordinate
 * system, which is relative to the parent's rotation.
 */
@property(nonatomic, assign) CC3Vector forwardDirection;

/**
 * The direction in which this node is pointing, relative to the global coordinate system.
 * This is calculated by using the transformMatrix to translate the initial forwardDirection (0,0,-1).
 */
@property(nonatomic, readonly) CC3Vector globalForwardDirection;

/**
 * The direction, in the global coordinate system, that is considered to be 'up'.
 *
 * As explained above in the description of this class, specifying a forwardDirection
 * is not sufficient to determine the rotation of a node in 3D space. This property
 * indicates which direction should be considered 'up' when orienting the rotation of
 * the node. Initially, this property is set to point parallel to the positive Y-axis,
 * and in most cases, this property can be left with that value.
 */
@property(nonatomic, assign) CC3Vector worldUpDirection;

/**
 * The direction, in the node's coordinate system, that is considered to be 'up'.
 * This corresponds to the worldUpDirection, after it has been transformed by
 * the rotations of this node. For example, rotating the node upwards
 * to point towards an elevated target will move the upDirection of this node away
 * from the worldUpDirection. See the discussion of 'up' vectors in the class notes
 * above. This property is read-only.
 */
@property(nonatomic, readonly) CC3Vector upDirection;

/**
 * The direction that is considered to be 'up' for this node, relative to the global coordinate system.
 * This is calculated by using the transformMatrix to translate the initial upDirection (0,1,0).
 */
@property(nonatomic, readonly) CC3Vector globalUpDirection;

/**
 * The direction in the node's coordinate system that would be considered to be
 * "off to the right" relative to where this node is pointing, and what is considered
 * to be 'up'. This property is read-only, is extracted from the transform matrix,
 * is generally of little use, but is included for completeness in describing the
 * rotation of the node.
 */
@property(nonatomic, readonly) CC3Vector rightDirection;

/**
 * The direction that is considered to be "off to the right" for this node,
 * relative to the global coordinate system. This is calculated by using the
 * transformMatrix to translate the initial rightDirection (1,0,0).
 */
@property(nonatomic, readonly) CC3Vector globalRightDirection;


#pragma mark Updating

/**
 * If the shouldTrackTarget property is set to YES, orients this node to point towards
 * its target, otherwise does nothing. This method is invoked automatically if either
 * the target node or this node moves. Usually, the application should never need to
 * invoke this method directly.
 */
-(void) trackTarget;
	
@end


#pragma mark -
#pragma mark CC3DirectionalRotator

/**
 * This CC3Rotator subclass adds the ability to set rotation based on directional information.
 * 
 * In addition to specifying rotations in terms of three Euler angles or quaternions, rotations
 * of this class can be specified in terms of pointing in a particular forwardDirection, and
 * orienting so that 'up' is in a particular worldUpDirection.
 *
 * The rotationMatrix of this rotator can be used to convert between directional rotation,
 * Euler angles, and quaternions. As such, the rotation of a node can be specified as a
 * quaternion or a set of Euler angles, and then read back as a fowardDirection, upDirection,
 * and rightDirection. Or, conversely, rotation may be specified by pointing to a particular
 * forwardDirection and worldUpDirection, and then read as a quaternion or a set of Euler angles.
 */
@interface CC3DirectionalRotator : CC3Rotator {
	CC3Vector forwardDirection;
	CC3Vector worldUpDirection;
	CC3Vector upDirection;
	CC3Vector rightDirection;
	BOOL isForwardDirectionDirty;
	BOOL isUpDirectionDirty;
	BOOL isRightDirectionDirty;
	BOOL isMatrixDirtyByDirection;
}

/** The direction towards which this node is pointing, relative to the parent of the node. */
@property(nonatomic, assign) CC3Vector forwardDirection;

/**
 * The direction, in the global coordinate system, that is considered to be 'up'.
 * See the discussion of 'up' vectors in the CC3TargettingNode class notes.
 */
@property(nonatomic, assign) CC3Vector worldUpDirection;

/**
 * The direction, in the node's coordinate system, that is considered to be 'up'.
 * This corresponds to the worldUpDirection, after it has been transformed by
 * the rotationMatrix of this instance.
 * See the discussion of 'up' vectors in the CC3TargettingNode class notes.
 */
@property(nonatomic, readonly) CC3Vector upDirection;

/**
 * The direction in the node's coordinate system that would be considered to be
 * "off to the right" relative to the forwardDirection and upDirection.
 * This property is read-only, See the discussion of the rotational directions
 * in the CC3TargettingNode class notes.
 */
@property(nonatomic, readonly) CC3Vector rightDirection;

@end


#pragma mark -
#pragma mark CC3LightTracker

/**
 * CC3LightTracker is a specialized CC3TargettingNode that tracks a target and
 * automatically updates its own globalLightLocation property from the globalLocation
 * property of the target. This globalLightLocaiton property is propagated to all child
 * nodes. Unlike CC3TargettingNode, CC3LightTracker does not rotate itself or its child
 * nodes to face the target.
 *
 * The primary use of CC3LightTracker is to automatically update the globalLightLocation
 * property of mesh nodes that contain bump-map textures, by tracking a light source as
 * its target. Bump-mapping combines a light direction with the per-pixel normal vectors
 * found in the texture to derive per-pixel luminosity.
 *
 * Although the globalLightLocation property is used only by CC3MeshNodes that contain
 * bump-map normal textures, the property is supported by all CC3Nodes. The automatic
 * updating of the property by this node will be propagated automatically to all child
 * nodes. Because of this, if you have a number of bump-mapped mesh nodes, you can add
 * them all as descendants of a single CC3LightTracker node, and confgure the 
 * CC3LightTracker to track a light source. The CC3LightTracker will take care of
 * updating the globalLightLocation of all the mesh nodes.
 *
 * Although typically the target of each CC3LightTracker will be a light source, it is
 * not required that the target be a CC3Light instance. Any CC3Node can be used as the
 * target. This is because bump-mapping does not actually use real light sources to
 * create its effect. Bump-mapping combines only the light direction vector and the
 * texture normals to create luminosity. However, in most 3D worlds, you will want the
 * same lighting effects to be visible on meshes that are covered with regular materials
 * and textures, and meshes that are covered with bump-map textures. To accomplish this,
 * you would set the target of the CC3LightTracker to be the CC3Light instance that is
 * illuminating the regular mesh nodes.
 */
@interface  CC3LightTracker  :  CC3TargettingNode
@end
