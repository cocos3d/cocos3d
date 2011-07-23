/*
 * CC3Camera.h
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

#import "CC3TargettingNode.h"

@class CC3Frustum, CC3World;

/** Default camera field of view. Measured in degrees. */
static const GLfloat kCC3DefaultFieldOfView = 45.0;

/** Default distance from the camera to the near clipping plane. */
static const GLfloat kCC3DefaultNearClippingPlane = 1.0;

/** Default distance from the camera to the far clipping plane. */
static const GLfloat kCC3DefaultFarClippingPlane = 1000.0;


#pragma mark -
#pragma mark CC3Camera interface

/**
 * CC3Camera represents the camera viewing the 3D world.
 *
 * CC3Camera is a type of CC3Node, and can therefore participate in a structural node assembly.
 * An instance can be the child of another node, and the camera itself can have child nodes.
 * For example, a camera can be mounted on a boom object or truck, and will move along with
 * the parent node. Or the camera node itself might have a light node attached as a child,
 * so that the light will move along with the camera, and point where the camera points.
 *
 * CC3Camera is also a type of CC3TargettingNode, and can be pointed in a particular
 * direction, or can be made to track a target node as that node moves, or the camera moves.
 *
 * The camera can be configured for either perspective or parallel projection, using
 * the isUsingParallelProjection property. By default, the camera will use perspective
 * projection.
 *
 * You can use the projectLocation: and projectNode: methods to project global locations
 * within the 3D world into 2D view coordinates, indicating where on the screen a 3D
 * object appears.
 *
 * You can use the unprojectPoint: and unprojectPoint:ontoPlane: methods to project a
 * 2D screen position into either a ray (a line) in the 3D world, or into a specific 
 * intersection location on a 3D plane.
 *
 * Scaling a camera is a null operation because it scales everything, including the size
 * of objects, but also the distance from the camera to those objects. The effects cancel
 * out, and visually it appears that nothing has changed.
 *
 * Therefore, for cameras, the scale and uniformScale properties are not applied to the
 * transform matrix. Instead, the uniformScale property acts as a zoom factor (as if the
 * camera lens is zoomed in or out), and influences the fieldOfView property accordingly.
 * See the description of the fieldOfView property for more information about zooming.
 *
 * If you find that objects in the periphery of your view appear elongated, you can adjust
 * the fieldOfView and/or uniformScale properties to reduce this "fish-eye" effect.
 * See the notes of the fieldOfView property for more on this.
 */
@interface CC3Camera : CC3TargettingNode {
	CC3World* world;
	CC3GLMatrix* modelviewMatrix;
	CC3Frustum* frustum;
	GLfloat fieldOfView;
	GLfloat nearClippingPlane;
	GLfloat farClippingPlane;
	BOOL isProjectionDirty;
}

/**
 * The CC3World in which the camera exists.
 *
 * This property is automatically set when this camera is added to the CC3World,
 * even if it is part of a larger assembly of nodes. Usually, the application
 * never needs to set this property.
 */
@property(nonatomic, assign) CC3World* world;

/**
 * The nominal field of view of this camera, in degrees. The initial value of this
 * property is set to kCC3DefaultFieldOfView.
 *
 * The effective field of view is influenced by the value of the uniformScale property,
 * which, for cameras, acts as a zoom factor (as if the camera lens is zoomed in or out).
 *
 * Once a nominal field of view has been set in this property, changing the scale or
 * uniformScale properties will change the effective field of view accordingly (although
 * the value of the fieldOfView property remains the same). Scales greater than one zoom in
 * (objects appear larger), and scales between one and zero zoom out (objects appear smaller).
 *
 * Like real-world cameras, larger values for fieldOfView can sometimes result in a
 * "fish-eye" effect, where objects at the periphery of the view can appear elongated.
 * To reduce this effect, lower the value of fieldOfView property, or increase the value
 * of the uniformScale property. In doing so, you may need to move your camera further
 * away from the scene, so that your view will continue to include the same objects.
 */
@property(nonatomic, assign) GLfloat fieldOfView;

/**
 * The distance from the camera to the clipping plane of the camera's frustrum
 * that is nearest to the camera. Initially set to kCC3DefaultNearClippingPlane.
 */
@property(nonatomic, assign) GLfloat nearClippingPlane;

/**
 * The distance from the camera to the clipping plane of the camera's frustrum
 * that is farthest from the camera. Initially set to kCC3DefaultFarClippingPlane.
 */
@property(nonatomic, assign) GLfloat farClippingPlane;

/** The frustum of the camera. */
@property(nonatomic, retain) CC3Frustum* frustum;

/**
 * The matrix that holds the transform from model space to view space. This matrix is distinct
 * from the camera's transformMatrix, which, like that of all nodes, reflects the location,
 * rotation and scale of the camera node in the 3D world space.
 *
 * In contrast, the modelviewMatrix combines the inverse of the camera's transformMatrix
 * (because any movement of the camera in world space has the opposite effect on the view),
 * with the deviceRotationMatrix from the viewportManager of the CC3World, to account for
 * the impact of device orientation on the view.
 */
@property(nonatomic, readonly) CC3GLMatrix* modelviewMatrix;

/** The projection matrix that takes the camera's modelview and projects it to the viewport. */
@property(nonatomic, readonly) CC3GLMatrix* projectionMatrix;

/**
 * Indicates whether this camera uses parallel projection.
 *
 * If this value is set to NO, the projection matrix will be configured for perspective
 * projection, which is typical for 3D worlds. If this value is set to YES, the projection
 * matrix will be configured for parallel/isometric/orthographic projection.
 *
 * The initial value of this property is NO, indicating that perspective projection will be used.
 */
@property(nonatomic, assign) BOOL isUsingParallelProjection;


#pragma mark Transformations

/**
 * Indicates that the projection matrix is dirty and needs to be recalculated.
 *
 * This method is invoked automatically as needed. Usually the application never needs
 * to invoke this method directly.
 */
-(void) markProjectionDirty;

/**
 * Updates the transformMatrix and modelviewMatrix if the target has moved, builds the
 * projectionMatrix if needed, and updates the frustum if needed.
 *
 * This method is invoked automatically from the CC3World after all updates have been
 * made to the models in the 3D world. Usually, the application never needs to invoke
 * this method directly.
 */
-(void) buildPerspective;


#pragma mark Drawing

/**
 * Opens the camera for drawing operations.
 *
 * This method is called automatically by the CC3World at the beginning of each frame
 * drawing cycle. Usually, the application never needs to invoke this method directly.
 */
-(void) open;

/**
 * Closes the camera for drawing operations.
 *
 * This method is called automatically by the CC3World at the end of each frame drawing cycle.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) close;

	
#pragma mark 3D <-> 2D mapping functionality

/**
 * Projects the globalLocation of the specified node onto a 2D position in the viewport
 * coordinate space, by invoking the projectLocation: method of this camera, passing
 * the node's globalLocation. See the notes of the projectLocation: method for more info
 * about the content of the returned vector.
 *
 * During any frame update, for objects that are moving, the updated globalLocation is
 * available in the updateAfterTransform: method of your customized CC3World.
 *
 * In addition to returning the projected 2D location, this method also sets that value
 * into the projectedLocation property of the node, for future access.
 */
-(CC3Vector) projectNode: (CC3Node*) aNode;

/**
 * Projects the specified global 3D world location onto a 2D position in the viewport
 * coordinate space, indicating where on the screen this 3D location will be seen.
 * The 2D position can be read from the X and Y components of the returned 3D location.
 *
 * The specified location should be in global coordinates. If you are invoking this
 * method to project the location of a CC3Node, you should use the globalLocation property
 * of the node. For objects that are moving, the updated globalLocation is available in the
 * updateAfterTransform: method of your customized CC3World.
 *
 * The Z-component of the returned location indicates the distance from the camera to the
 * specified location, with a positive value indicating that the specified location is in
 * front of the camera, and a negative value indicating that the specified location is
 * behind the camera.
 *
 * Any 3D world location can be either in front of or behind the camera, and both cases will
 * be projected onto the 2D space of the viewport plane. If you are only interested in
 * the case when the specified location is in front of the camera (potentially visible to
 * the camera), check that the Z-component of the returned location is positive.
 *
 * This method takes into account the orientation of the device (portrait, landscape). 
 */
-(CC3Vector) projectLocation: (CC3Vector) a3DLocation;

/**
 * Projects a 2D point, which is specified in the local coordinates of the CC3Layer,
 * into a ray extending from the camera into the 3D world. The returned ray contains
 * a starting location and a direction. 
 *
 * If this camera is using perspective projection, the ray will start at the
 * globalLocation of this camera and extend in a direction that passes through the
 * specified point as it is mampped to a global location on the near clipping plane.
 *
 * If this camera is using parallel projection, the ray will start at the specified
 * point as it is mampped to a global location on the near clipping plane, and will
 * be directed straight out from the camera, in the same direction as the camera's
 * forwardDirection.
 * 
 * This method is the compliment to the projectLocation: method. You can use this
 * method to map touch events to the 3D world space for activities such as dropping
 * objects into the 3D world at a location under user finger touch control.
 *
 * Any object that lies anywhere along the ray in 3D space will appear at the
 * specified 2D point on the view. If you are trying to place an object at a 3D
 * location corresponding to the 2D view point (eg- a finger touch point), you
 * need to choose a specific location on the returned ray.
 *
 * For example, you might determine where that ray intersects a particular plane,
 * and place the object there. Or you might choose a location a certain distance
 * from the camera, and place the object there.
 */
-(CC3Ray) unprojectPoint: (CGPoint) cc2Point;

/**
 * Projects a 2D point, which is specified in the local coordinates of the CC3Layer,
 * to a 3D location on the specified plane.
 *
 * You can use this method to map touch events to the plane in the 3D world space for
 * activities such as dropping objects onto the plane at a location under user finger
 * touch control.
 *
 * The returned result is a 4D vector, where the x, y & z components give the intersection
 * location in 3D space, and the w component gives the distance from the camera to the
 * intersection location. If the w component is negative, the intersection point is behind
 * the camera, which is an indication that the camera is looking away from the plane.
 *
 * If the ray from the camera through the specified point is parallel to the plane, no
 * intersection occurs, and the returned 4D vector will be zeroed (equal to kCC3Vector4Zero).
 *
 * You should therefore test the w component value to make sure it is positive and
 * non-zero before proceeding with an activity such as dropping an object on the plane.
 * If the plane has bounds in your world, you should also check whether the returned
 * intersection is within those bounds.
 */
-(CC3Vector4) unprojectPoint:(CGPoint)cc2Point ontoPlane: (CC3Plane) plane;

@end
	

#pragma mark -
#pragma mark CC3Frustum interface

/** Represents a camera's frustum. Each CC3Camera instance contains an instance of this class. */
@interface CC3Frustum : NSObject <NSCopying> {
	CC3GLMatrix* projectionMatrix;
	GLfloat bottom;
	GLfloat left;
	GLfloat right;
	GLfloat near;
	GLfloat far;
	CC3Plane topPlane;
	CC3Plane bottomPlane;
	CC3Plane leftPlane;
	CC3Plane rightPlane;
	CC3Plane nearPlane;
	CC3Plane farPlane;
	BOOL isUsingParallelProjection;
	BOOL arePlanesDirty;
}

/** The projection matrix that takes the camera's modelview and projects it to the viewport. */
@property(nonatomic, readonly) CC3GLMatrix* projectionMatrix;

/** The distance from view center to the top of this frustum at the near clipping plane. */
@property(nonatomic, readonly) GLfloat top;

/** The distance from view center to the bottom of this frustum at the near clipping plane. */
@property(nonatomic, readonly) GLfloat bottom;

/** The distance from view center to the left edge of this frustum at the near clipping plane. */
@property(nonatomic, readonly) GLfloat left;

/** The distance from view center to the right edge of this frustum at the near clipping plane. */
@property(nonatomic, readonly) GLfloat right;

/** The distance to the near end of this frustum. */
@property(nonatomic, readonly) GLfloat near;

/** The distance to the far end of this frustum. */
@property(nonatomic, readonly) GLfloat far;

/** The clip plane at the top of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane topPlane;

/** The clip plane at the bottom of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane bottomPlane;

/** The clip plane at the left side of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane leftPlane;

/** The clip plane at the right side of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane rightPlane;

/** The clip plane at the near end of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane nearPlane;

/** The clip plane at the far end of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane farPlane;

/**
 * Indicates whether this frustum uses parallel projection.
 *
 * If this value is set to NO, the projection matrix will be configured for
 * perspective projection, which is typical for 3D worlds. If this value is set
 * to YES, the projection matrix will be configured for orthographic projection.
 *
 * The initial value of this property is NO, indicating that perspective
 * projection will be used.
 */
@property(nonatomic, assign) BOOL isUsingParallelProjection;

/** Allocates and initializes an autorelease instance. */
+(id) frustum;

/** Marks the planes as dirty and in need of recalculation. */
-(void) markPlanesDirty;

/**
 * Calculates the six frustum dimensions and the projectionMatrix
 * from the specified projection parameters.
 */
-(void) populateFrom: (GLfloat) fieldOfView
		   andAspect: (GLfloat) aspect
		 andNearClip: (GLfloat) nearClip
		  andFarClip: (GLfloat) farClip
			 andZoom: (GLfloat) zoomFactor;

/**
 * Builds the planes in this frustum from the internal projectionMatrix and specified
 * modelviewMatrix by multiplying the two matrices together and extracting the six
 * frustum planes from the resulting model-view-projection matrix.
 */
-(void) buildPlanes: (CC3GLMatrix*) aModelViewMatrix;

/** Returns whether the specified global location intersects (is inside) this frustum. */
-(BOOL) doesIntersectPointAt: (CC3Vector) location;

/**
 * Returns whether a sphere, centered at the specified global location,
 * and with the specified radius, intersects this frustum.
 */
-(BOOL) doesIntersectSphereAt: (CC3Vector) location withRadius: (GLfloat) radius;

/**
 * Returns a string containing a more complete description of this frustum, including
 * a description of each of the six planes that make up this frustum.
 */
-(NSString*) fullDescription;

@end
