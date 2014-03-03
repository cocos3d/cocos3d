/*
 * CC3Camera.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Node.h"

/** Defines the orientation of the camera's field of view measurement. */
typedef enum {
    CC3FieldOfViewOrientationUndefined,		/**< The FOV orientation is undefined. */
    CC3FieldOfViewOrientationHorizontal,	/**< The FOV spans the horizontal aspect of the display surface. */
    CC3FieldOfViewOrientationVertical,		/**< The FOV spans the vertical aspect of the display surface. */
    CC3FieldOfViewOrientationDiagonal		/**< The FOV spans the diagonal aspect of the display surface. */
} CC3FieldOfViewOrientation;


/** Default camera field of view. Measured in degrees. */
static const GLfloat kCC3DefaultFieldOfView = 45.0f;

/** Default distance from the camera to the near clipping plane. */
static const GLfloat kCC3DefaultNearClippingDistance = 1.0f;

/** Default distance from the camera to the far clipping plane. */
static const GLfloat kCC3DefaultFarClippingDistance = 1000.0f;

// Deprecated
static const GLfloat kCC3DefaultNearClippingPlane DEPRECATED_ATTRIBUTE = 1.0f;
static const GLfloat kCC3DefaultFarClippingPlane DEPRECATED_ATTRIBUTE = 1000.0f;

/**
 * Default padding around a node when framed by the camera using one of the
 * moveToShowAllOf:... or moveWithDuration:toShowAllOf: family of methods.
 */
static const GLfloat kCC3DefaultFrustumFitPadding = 0.02f;


#pragma mark -
#pragma mark CC3Camera interface

/**
 * CC3Camera represents the camera viewing the 3D scene.
 *
 * CC3Camera is a type of CC3Node, and can therefore participate in a structural node assembly.
 * An instance can be the child of another node, and the camera itself can have child nodes.
 * For example, a camera can be mounted on a boom object or truck, and will move along with
 * the parent node. Or the camera node itself might have a light node attached as a child,
 * so that the light will move along with the camera, and point where the camera points.
 *
 * However, when adding a camera to an assembly of nodes, be aware of whether the parent nodes
 * use scaling. To construct the viewMatrix, the camera makes heavy use of matrix inversion of the
 * cummulative transform matrix of the camera's transforms and the transforms of all its ancestors.
 * If scaling has not been added to any ancestor nodes, the cummulative transform will be a Rigid
 * transform. Inverting a Rigid transform matrix is much, much faster (orders of magnitude) than
 * inverting a matrix that contains scaling and is therefore not rigid. If possible, try to avoid
 * applying scaling to the ancestor nodes of this camera.
 *
 * Like any CC3Node, CC3Camera can be pointed in a specific direction, pointed at a specific
 * location, or at a specific node by setting the forwardDirection, targetLocation, or target
 * properties, respectively.
 *
 * The camera can be configured for either perspective or parallel projection, using the
 * isUsingParallelProjection property. By default, the camera will use perspective projection.
 *
 * You can use the projectLocation: and projectNode: methods to project global locations within
 * the 3D scene into 2D view coordinates, indicating where on the screen a 3D object appears.
 *
 * You can use the unprojectPoint: and unprojectPoint:ontoPlane: methods to project a 2D screen
 * position into either a ray (a line) in the 3D scene, or into a specific intersection location
 * on a 3D plane.
 *
 * You can use the  moveToShowAllOf:... or moveWithDuration:toShowAllOf: family of methods to
 * have the camera automatically focus on, and display all of, a particular node, or even the
 * whole scene itself.
 *
 * Scaling a camera is a null operation because it scales everything, including the size of objects,
 * but also the distance from the camera to those objects. The effects cancel out, and visually it
 * appears that nothing has changed.
 *
 * Therefore, for cameras, the scale and uniformScale properties are not applied to the transform
 * matrix. Instead, the uniformScale property acts as a zoom factor (as if the camera lens is zoomed
 * in or out), and influences the fieldOfView property accordingly. See the description of the
 * fieldOfView property for more information about zooming.
 *
 * If you find that objects in the periphery of your view appear elongated, you can adjust
 * the fieldOfView and/or uniformScale properties to reduce this "fish-eye" effect.
 * See the notes of the fieldOfView property for more on this.
 *
 * For cameras, any change in the projection parameters, such as fieldOfView, scale, near or far
 * clipping distances, is considered a transform change, and the transformListeners are sent a
 * notification via the nodeWasTransformed: method when the projection matrix is recalculated.
 */
@interface CC3Camera : CC3Node {
	CC3Frustum* _frustum;
	CC3Viewport _viewport;
	GLfloat _fieldOfView;
	CC3FieldOfViewOrientation _fieldOfViewOrientation;
	UIInterfaceOrientation _fieldOfViewAspectOrientation;
	GLfloat _nearClippingDistance;
	GLfloat _farClippingDistance;
	BOOL _isOpen : 1;
	BOOL _hasInfiniteDepthOfField : 1;
	BOOL _isProjectionDirty : 1;
	BOOL _shouldClipToViewport : 1;
}

/** Returns whether this node is a camera. Returns YES. */
@property(nonatomic, readonly) BOOL isCamera;

/**
 * The nominal field of view of this camera, in degrees. The initial value of this
 * property is set to kCC3DefaultFieldOfView.
 *
 * The effect of setting this property is affected by the fieldOfViewOrientation,
 * fieldOfViewAspectOrientation, and  uniformScale properties.
 *
 * In handheld devices, the device orientation can change at will, changing the aspect ratio
 * of the camera viewport. The fieldOfViewOrientation, and fieldOfViewAspectOrientation
 * properties work together to establish and maintain a consistent perspective, regardless
 * of the current aspect ratio.
 *
 * The fieldOfViewOrientation property indicates whether this fieldOfView value is measured
 * horizontally, vertically, or diagonally across the display surface. 
 *
 * The fieldOfViewAspectOrientation property indicates the orientation (portrait or landscape)
 * of the display surface to which this fieldOfView value is specified.
 *
 * The fieldOfViewOrientation and fieldOfViewAspectOrientation properties combine to
 * determine whether the fieldOfView value is measured horizontally or vertically, and
 * whether it was meant to be applied to the long or short side of the display surface.
 * 
 * Applying a field of view angle across the short side of the display surface will produce
 * a somewhat different view perspective than if the same field of view value is applied
 * across the long side of the display surface.
 *
 * Knowing these values, this camera can then automatically adjust the perspective, and keep
 * it consistent, regardless of the actual orientation of the device and display surface.
 *
 * For example, if the fieldOfViewOrientation property indicates that the fieldOfView applies
 * to the horizontal direction, and the fieldOfViewAspectOrientation indicates that the
 * horizontal side is longer than the vertical side (landscape), the camera knows that the
 * fieldOfView property should be applied to the long side, regardless of the orientation
 * of the device and display surface. 
 *
 * As another example, a vertical fieldOfViewOrientation, combined with a landscape
 * fieldOfViewAspectOrientation corresponds to the commonly-used Hor+ FOV technique.
 *
 * See the notes for the fieldOfViewOrientation and fieldOfViewAspectOrientation properties
 * for more information about how they affect the use of the fieldOfView.
 *
 * The effective field of view is influenced by the value of the uniformScale property,
 * which, for cameras, acts as a zoom factor (as if the camera lens is zoomed in or out).
 * The effective field of view of this camera is calculated as (fieldOfView / uniformScale).
 *
 * Once a nominal field of view has been set in this property, changing the scale or
 * uniformScale properties will change the effective field of view accordingly (although
 * the value of the fieldOfView property remains the same). Scales greater than one zoom in
 * (objects appear larger), and scales between one and zero zoom out (objects appear smaller).
 *
 * Like real-world cameras, larger values of the effective field of view can result in a
 * "fish-eye" effect, where objects at the periphery of the view can appear elongated.
 * To reduce this effect, lower the value of fieldOfView property, or increase the value
 * of the uniformScale property. In doing so, you may need to move your camera further
 * away from the scene, so that your view will continue to include the same objects.
 *
 * The effective field of view is clamped to keep it below 180 degrees, beyond which
 * the scene would vanish into the distance.
 */
@property(nonatomic, assign) GLfloat fieldOfView;

/**
 * Indicates whether the value of the fieldOfView property is measured horizontally, 
 * vertically, or diagonally across the display surface.
 *
 * This property works together with the fieldOfViewAspectOrientation property to ensure
 * that the fieldOfView is applied to the camera's perspective on the display surface in
 * a consistent manner, regardless of changes to the orientation of the display surface
 * resulting from changes to the orientation of the device. See the notes for the
 * fieldOfView property for more information about this interaction.
 *
 * The initial value of this property is CC3FieldOfViewOrientationDiagonal, indicating
 * that the fieldOfView is measured diagonally across the display surface. This is a
 * good general-purpose setting for framing a scene where it is not certain whether the
 * scene will be displayed with portrait or landscape orientation.
 *
 * Specifying a vertical fieldOfViewOrientation is good when you want to frame a scene
 * containing a character close-up, and you don't want the character's head to be clipped
 * off if the device is rotated. Combining a vertical fieldOfViewOrientation and a horizontal
 * fieldOfViewAspectOrientation corresponds to the commonly-used Hor+ FOV technique.
 */
@property(nonatomic, assign) CC3FieldOfViewOrientation fieldOfViewOrientation;

/**
 * Indicates the orientation (portrait or landscape) of the display surface to which the
 * value of the fieldOfView value is specified.
 *
 * This property works together with the fieldOfViewOrientation property to ensure
 * that the fieldOfView is applied to the camera's perspective on the display surface in
 * a consistent manner, regardless of changes to the orientation of the display surface
 * resulting from changes to the orientation of the device. See the notes for the
 * fieldOfView property for more information about this interaction.
 *
 * This property is only concerned with whether the display surface orientation is
 * portrait or landscape. It doesn't matter whether a portrait orientation is right-side-up
 * or upside-down, or whether a landscape orientation is left or right. To indicate a portrait
 * orientation, either UIInterfaceOrientationPortrait or UIInterfaceOrientationPortraitUpsideDown
 * may be used, and to indicate a landscape orientation, either UIInterfaceOrientationLandscapeLeft
 * or UIInterfaceOrientationLandscapeRight may be used.
 *
 * The initial value of this propety is UIInterfaceOrientationLandscapeLeft, indicating
 * that the value of the fieldOfView propery is meant to apply to a display surface whose
 * horizontal side is longer than its vertical side.
 */
@property(nonatomic, assign) UIInterfaceOrientation fieldOfViewAspectOrientation;

/**
 * The effective field of view of this camera, in degrees.
 *
 * Since the device orientation can change at will, the effective field of view is associated
 * with the narrower of the two viewport dimensions (width or height), regardless of orientation.
 * This allows the perspective to stay the same as the device is rotated by the user.
 *
 * The effective field of view is influenced by the value of the uniformScale property,
 * which, for cameras, acts as a zoom factor (as if the camera lens is zoomed in or out).
 * The effective field of view of this camera is calculated as (fieldOfView / uniformScale).
 *
 * Once a nominal field of view has been set in this property, changing the scale or
 * uniformScale properties will change the effective field of view accordingly (although
 * the value of the fieldOfView property remains the same). Scales greater than one zoom in
 * (objects appear larger), and scales between one and zero zoom out (objects appear smaller).
 *
 * Like real-world cameras, larger values of the effective field of view can result in a
 * "fish-eye" effect, where objects at the periphery of the view can appear elongated.
 * To reduce this effect, lower the value of fieldOfView property, or increase the value
 * of the uniformScale property. In doing so, you may need to move your camera further
 * away from the scene, so that your view will continue to include the same objects.
 *
 * The effective field of view is clamped to keep it below 180 degrees, beyond which
 * the scene would vanish into the distance.
 */
@property(nonatomic, readonly) GLfloat effectiveFieldOfView;

/**
 * The distance from the camera to the clipping plane of the camera's frustrum
 * that is nearest to the camera. Initially set to kCC3DefaultNearClippingDistance.
 */
@property(nonatomic, assign) GLfloat nearClippingDistance;

/** @deprecated Renamed to nearClippingDistance. */
@property(nonatomic, assign) GLfloat nearClippingPlane DEPRECATED_ATTRIBUTE;

/**
 * The distance from the camera to the clipping plane of the camera's frustrum
 * that is farthest from the camera. Initially set to kCC3DefaultFarClippingDistance.
 */
@property(nonatomic, assign) GLfloat farClippingDistance;

/** @deprecated Renamed to farClippingDistance. */
@property(nonatomic, assign) GLfloat farClippingPlane DEPRECATED_ATTRIBUTE;

/**
 * The viewport to which the camera will render its view.
 *
 * This property must be set prior to attempting to render the camera's view.
 */
@property(nonatomic, assign) CC3Viewport viewport;

/**
 * Indicates whether a scissor test should be used to ensure that redering remains within the viewport.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldClipToViewport;

/**
 * The frustum of the camera.
 * 
 * This is constructed automatically from the field of view and the clipping plane
 * properties. Usually the application never has need to set this property directly.
 */
@property(nonatomic, strong) CC3Frustum* frustum;

/**
 * The matrix that holds the transform from model space to view space. 
 *
 * This is a convenience method that simply returns the value of the
 * globalTransformMatrixInverted property.
 */
@property(nonatomic, strong, readonly) CC3Matrix* viewMatrix;

/** @deprecated Renamed to viewMatrix for a more accurate semantic. */
@property(nonatomic, strong, readonly) CC3Matrix* modelviewMatrix DEPRECATED_ATTRIBUTE;

/**
 * The projection matrix that takes the camera's modelview and projects it to the viewport.
 *
 * This projection matrix takes into account the value of the farClippingDistance property,
 * and will be finite in depth. This is contrasted by the projection matrix found in the
 * infiniteProjectionMatrix property.
 */
@property(nonatomic, strong, readonly) CC3Matrix* projectionMatrix;

/**
 * Indicates whether, during rendering, this camera uses an infinite depth of field, with a far
 * clipping plane set at infinity. The setting of this property affects the value of the
 * projectionMatrix property.
 *
 * The frustum of this camera calculates two projection matrices. One has a finite depth of field,
 * and is held in the frustum finiteProjectionMatrix property. The other has an infinite depth of
 * field and is held in the frustum infiniteProjectionMatrix property.
 *
 * If the value of this property is set to NO, the projectionMatix property of this camera
 * returns the value of the finiateProjectionMatrix of the frustum. If the value of this
 * property is set to YES, the projectionMatix property of this camera returns the value of the
 * infiniateProjectionMatrix of the frustum, effectively creating an infinite depth of field.
 *
 * The value of this property does not affect the culling of nodes outside the camera's frustum.
 * During drawing, regardless of the value of this property, the value of the farClippingDistance
 * property is used to cull objects outside the camera's frustum. This is done to avoid wasting
 * time rendering objects that are too far away to be seen (as defined by the value of the
 * farClippingDistance property).
 *
 * The initial value of this property is NO, indicating that the camera will have
 * a finite depth of field, based on the value of the farClippingDistance.
 *
 * For the most part, a finite depth of field provides slightly more accurate rendering, and this
 * property should generally be left set to NO. However, there are a few circumstances, such as
 * the rendering of infinite shadow volumes, where clipping at the far clipping plane within the
 * GL engine needs to be avoided. In such circumstances, setting this property to YES can be useful.
 *
 * Because of its use for rendering shadows, whenever a camera is set into the activeCamera property
 * of the CC3Scene, the value of this property is copied from the old active camera.
 */
@property(nonatomic, assign) BOOL hasInfiniteDepthOfField;

/**
 * Indicates whether this camera uses parallel projection.
 *
 * If this value is set to NO, the projection matrix will be configured for perspective
 * projection, which is typical for 3D scenes. If this value is set to YES, the projection
 * matrix will be configured for parallel/isometric/orthographic projection.
 *
 * The initial value of this property is NO, indicating that perspective projection will be used.
 */
@property(nonatomic, assign) BOOL isUsingParallelProjection;

/**
 * The direction in which this camera is pointing, relative to the coordinate
 * system of this camera, which is relative to the parent's rotation.
 *
 * The initial value of this property is kCC3VectorUnitZNegative, pointing
 * down the negative Z-axis in the local coordinate system of this camera.
 * When this camera is rotated, the original negative-Z axis of the camera's
 * local coordinate system will point in this direction.
 *
 * This orientation is opposite that for most other nodes, whose forwardDirection
 * property orients the positve Z-axis of the node's coordinate system in
 * the stated direction. This arrangement allows unrotated nodes to face the
 * camera in a natural stance, and allows the unrotated camera to face the nodes.
 *
 * See further notes in the notes for this property in the CC3Node class.
 */
@property(nonatomic, assign) CC3Vector forwardDirection;


#pragma mark Transformations

/**
 * Indicates that the projection matrix is dirty and needs to be recalculated.
 *
 * For cameras, a change in projection is considered a transform change, so the
 * transformListeners are sent a notification via the nodeWasTransformed: method
 * when the projection matrix is rebuilt.
 *
 * This method is invoked automatically as needed. Usually the application never needs
 * to invoke this method directly.
 */
-(void) markProjectionDirty;


#pragma mark Drawing

/**
 * Opens the camera for drawing operations.
 *
 * This method is called automatically by the CC3Scene at the beginning of each frame
 * drawing cycle. Usually, the application never needs to invoke this method directly.
 */
-(void) openWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Closes the camera for drawing operations.
 *
 * This method is called automatically by the CC3Scene at the end of each frame drawing cycle.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) closeWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Indicates whether this camera is open.
 *
 * The initial value of this property is NO. It will return YES after the open method
 * has been invoked, and will revert back to NO when the close method is invoked.
 */
@property(nonatomic, readonly) BOOL isOpen;


#pragma mark Viewing nodes

/**
 * Calculates and returns where to position this camera along a line extending in the
 * specified direction from the center of the specified node, so that the camera will
 * show the entire content of the node, including any descendant nodes.
 *
 * The entire node can then be shown by positioning the camera at the returned location
 * and setting the forwardDirection of the camera to the negated specified direction.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * By setting CC3Scene as the specified node, you can use this method to determine
 * where to position the camera in order to show the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to determine where to locate your camera to capture the entire scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding;


/**
 * Calculates and returns where to position this camera along a line extending in the
 * specified direction from the specified target location, so that the camera will
 * show the entire content of the node, including any descendant nodes.
 *
 * The entire node can then be shown by positioning the camera at the returned location
 * and setting the forwardDirection of the camera to the negated specified direction.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * By setting CC3Scene as the specified node, you can use this method to determine
 * where to position the camera in order to show the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to determine where to locate your camera to capture the entire scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
						   whileLookingAt: (CC3Vector) targetLoc
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line between the center of the specified
 * node and this camera, so that the camera will show the entire content of the node,
 * including any descendant nodes, with minimal padding. The camera will point back
 * towards the node along the line between itself and the center of the node.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode;

/**
 * Moves this camera to a location along a line between the center of the specified
 * node and this camera, so that the camera will show the entire content of the node,
 * including any descendant nodes. The camera will point back towards the node along
 * the line between itself and the center of the node.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the center of the specified node, so that the camera will show the entire
 * content of the node, including any descendant nodes, with minimal padding. The
 * camera will point back towards the center of the node along the specified direction.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode fromDirection: (CC3Vector) aDirection;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the center of the specified node, so that the camera will show the entire
 * content of the node, including any descendant nodes. The camera will point back
 * towards the center of the node along the specified direction.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes, with minimal padding. The camera will
 * point back towards the specified target location along the line between itself and
 * the target location.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * Although the camera will point at the specified target location, the targetLocation
 * property of the camera is not set to that location, and the camera will not track
 * that location automatically. If you want the target location to be tracked by the
 * camera, you should set the targetLocation and shouldTrackTarget properties of this
 * camera once this method has finished.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode whileLookingAt: (CC3Vector) targetLoc;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes. The camera will point back towards the
 * specified target location along the line between itself and the target location.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * Although the camera will point at the specified target location, the targetLocation
 * property of the camera is not set to that location, and the camera will not track
 * that location automatically. If you want the target location to be tracked by the
 * camera, you should set the targetLocation and shouldTrackTarget properties of this
 * camera once this method has finished.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
			withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes, with minimal padding. The camera will
 * point back towards the specified target location along the specified direction.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * Although the camera will point at the specified target location, the targetLocation
 * property of the camera is not set to that location, and the camera will not track
 * that location automatically. If you want the target location to be tracked by the
 * camera, you should set the targetLocation and shouldTrackTarget properties of this
 * camera once this method has finished.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
		  fromDirection: (CC3Vector) aDirection;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes. The camera will point back towards the
 * specified target location along the specified direction.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * Although the camera will point at the specified target location, the targetLocation
 * property of the camera is not set to that location, and the camera will not track
 * that location automatically. If you want the target location to be tracked by the
 * camera, you should set the targetLocation and shouldTrackTarget properties of this
 * camera once this method has finished.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line between the center of the specified
 * node and this camera, so that the camera will show the entire content of the node,
 * including any descendant nodes, with minimal padding. The camera will point back
 * towards the node along the line between itself and the center of the node.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveWithDuration: (CCTime) t toShowAllOf: (CC3Node*) aNode;

/**
 * Moves this camera to a location along a line between the center of the specified
 * node and this camera, so that the camera will show the entire content of the node,
 * including any descendant nodes. The camera will point back towards the node along
 * the line between itself and the center of the node.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
			 withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the center of the specified node, so that the camera will show the entire
 * content of the node, including any descendant nodes, with minimal padding. The
 * camera will point back towards the center of the node along the specified direction.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize. This is necessary so that the frustum of the camera has been set from
 * the contentSize of the CC3Layer.
 */
-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the center of the specified node, so that the camera will show the entire
 * content of the node, including any descendant nodes. The camera will point back
 * towards the center of the node along the specified direction.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * This method can be useful during development to troubleshoot scene display issues.
 * For example, you can invoke this method in the onOpen method of your custom CC3Scene
 * to ensure that the camera is pointed towards the whole scene, or a particular
 * node within the scene, when the scene is first drawn.
 *
 * Since the camera points to the center of the node, when displayed, the node may
 * not extend to both sides (or top & bottom) of the scene equally, due to perspective.
 * In addition, in some cases, if the bounds of the node are fluid because of movement,
 * or billboards that rotate as the camera moves into position, one or more corners of
 * the node may extend slightly out of the camera's view.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize. This is necessary so that the frustum of the camera has been set from
 * the contentSize of the CC3Layer.
 */
-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes, with minimal padding. The camera will
 * point back towards the specified target location along the line between itself and
 * the target location.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * Although the camera will point at the specified target location, the targetLocation
 * property of the camera is not set to that location, and the camera will not track
 * that location automatically.
 *
 * If you want the target location to be tracked by the camera, once this movement
 * is finished, you should consider not using this method, and instead, use the
 * calculateLocationToShowAllOf:whileLookingAt:fromDirection:withPadding: method to
 * determine the location to move the camera to, and create a combination of actions
 * that include using the CC3MoveTo and CC3RotateToLookTowards actions in parallel,
 * plus a callback action once those actions are complete, to a method that will set
 * the appropriate target or targetLocation, and shouldTrackTarget properties.
 * See the implementation of this method for ideas.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveWithDuration: (CCTime) t
		  whileLookingAt: (CC3Vector) targetLoc
			 toShowAllOf: (CC3Node*) aNode;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes. The camera will point back towards the
 * specified target location along the line between itself and the target location.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * If you want the target location to be tracked by the camera, once this movement
 * is finished, you should consider not using this method, and instead, use the
 * calculateLocationToShowAllOf:whileLookingAt:fromDirection:withPadding: method to
 * determine the location to move the camera to, and create a combination of actions
 * that include using the CC3MoveTo and CC3RotateToLookTowards actions in parallel,
 * plus a callback action once those actions are complete, to a method that will set
 * the appropriate target or targetLocation, and shouldTrackTarget properties.
 * See the implementation of this method for ideas.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize (typically after the layer has been opened in its view). This is
 * necessary because the frustum of this camera requires the contentSize of the
 * CC3Layer to determine the projection matrix. Because of this, you cannot invoke
 * this method when creating this camera, or from the initializeScene method of the
 * CC3Scene. If you want to open your scene with the camera automatically framing
 * the entire scene, or a particular node, a good place to invoke this method is in
 * the onOpen callback method of your customized CC3Scene.
 */
-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
			 withPadding: (GLfloat) padding;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes, with minimal padding. The camera will
 * point back towards the specified target location along the specified direction.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * If you want the target location to be tracked by the camera, once this movement
 * is finished, you should consider not using this method, and instead, use the
 * calculateLocationToShowAllOf:whileLookingAt:fromDirection:withPadding: method to
 * determine the location to move the camera to, and create a combination of actions
 * that include using the CC3MoveTo and CC3RotateToLookTowards actions in parallel,
 * plus a callback action once those actions are complete, to a method that will set
 * the appropriate target or targetLocation, and shouldTrackTarget properties.
 * See the implementation of this method for ideas.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize. This is necessary so that the frustum of the camera has been set from
 * the contentSize of the CC3Layer.
 */
-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
		   fromDirection: (CC3Vector) aDirection;

/**
 * Moves this camera to a location along a line extending in the specified direction
 * from the specified target location, so that the camera will show the entire content
 * of the node, including any descendant nodes. The camera will point back towards the
 * specified target location along the specified direction.
 *
 * The camera's movement will take the specified amount of time, starting at its
 * current location and orientation, and ending at the calculated location and
 * oriented to point back towards the center of the node.
 *
 * The padding argument indicates the empty-space padding to add around the bounding box
 * of the node when it is framed in the camera. This value is expressed as a fraction of
 * the size of the bounding box of the node. For example, if the padding value is set to
 * 0.1, then this method will locate the camera so that there will be 10% empty space
 * around the node when it is framed by the camera. A negative padding value will cause
 * the node to expand to more fully fill the camera frame, or even expand beyond it.
 *
 * The specified node may be the CC3Scene, in which case, the camera will be located
 * to display the entire scene.
 *
 * If you want the target location to be tracked by the camera, once this movement
 * is finished, you should consider not using this method, and instead, use the
 * calculateLocationToShowAllOf:whileLookingAt:fromDirection:withPadding: method to
 * determine the location to move the camera to, and create a combination of actions
 * that include using the CC3MoveTo and CC3RotateToLookTowards actions in parallel,
 * plus a callback action once those actions are complete, to a method that will set
 * the appropriate target or targetLocation, and shouldTrackTarget properties.
 * See the implementation of this method for ideas.
 *
 * This method requires that the CC3Scene is attached to a CC3Layer that has a valid
 * contentSize. This is necessary so that the frustum of the camera has been set from
 * the contentSize of the CC3Layer.
 */
-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding;

	
#pragma mark 3D <-> 2D mapping functionality

/**
 * Projects the specified global 3D scene location onto a 2D position in the viewport
 * coordinate space, indicating where on the screen this 3D location will be seen.
 * The 2D position can be read from the X and Y components of the returned 3D location.
 *
 * The specified location should be in global coordinates. If you are invoking this method to
 * project the location of a CC3Node, you should use the globalLocation property of the node.
 * For objects that are moving, the updated globalLocation is available in the updateAfterTransform:
 * method of your customized CC3Scene.
 *
 * The Z-component of the returned location indicates the distance from the camera to the specified
 * location, with a positive value indicating that the specified location is in front of the camera,
 * and a negative value indicating that the specified location is behind the camera.
 *
 * Any 3D scene location can be either in front of or behind the camera, and both cases will be 
 * projected onto the 2D space of the viewport plane. If you are only interested in the case when
 * the specified location is in front of the camera (potentially visible to the camera), check
 * that the Z-component of the returned location is positive.
 *
 * This method takes into account the orientation of the device (portrait, landscape). 
 */
-(CC3Vector) projectLocation: (CC3Vector) aGlobal3DLocation;

/**
 * Projects the specified 3D location, in the local coordinate system of the specified node, onto a 2D
 * position in the viewport coordinate space. This indicates where on the screen this point on the node
 * will be seen. The 2D position can be read from the X and Y components of the returned 3D location.
 *
 * The specified location should be in the local coordinates of the specified node.
 *
 * The Z-component of the returned location indicates the distance from the camera to the specified
 * location, in global coordinates, with a positive value indicating that the specified location is in
 * front of the camera, and a negative value indicating that the specified location is behind the camera.
 *
 * Any 3D scene location can be either in front of or behind the camera, and both cases will be 
 * projected onto the 2D space of the viewport plane. If you are only interested in the case when
 * the specified location is in front of the camera (potentially visible to the camera), check
 * that the Z-component of the returned location is positive.
 *
 * This method takes into account the orientation of the device (portrait, landscape). 
 */
-(CC3Vector) projectLocation: (CC3Vector) aLocal3DLocation onNode: (CC3Node*) aNode;

/**
 * Projects the globalLocation of the specified node onto a 2D position in the viewport coordinate
 * space, by invoking the projectLocation: method of this camera, passing the node's globalLocation.
 * See the notes of the projectLocation: method for more info about the content of the returned vector.
 *
 * During any frame update, for objects that are moving, the updated globalLocation is
 * available in the updateAfterTransform: method of your customized CC3Scene.
 *
 * In addition to returning the projected 2D location, this method also sets that value
 * into the projectedLocation property of the node, for future access.
 */
-(CC3Vector) projectNode: (CC3Node*) aNode;

/**
 * Projects a 2D point, which is specified in the local coordinates of the CC3Layer,
 * into a ray extending from the camera into the 3D scene. The returned ray contains
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
 * method to map touch events to the 3D scene space for activities such as dropping
 * objects into the 3D scene at a location under user finger touch control.
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
 * You can use this method to map touch events to the plane in the 3D scene space for
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
 * If the plane has bounds in your scene, you should also check whether the returned
 * intersection is within those bounds.
 */
-(CC3Vector4) unprojectPoint:(CGPoint)cc2Point ontoPlane: (CC3Plane) plane;

/**
 * Converts the specified point, which is in the coordinate system of the cocos2d layer,
 * into the coordinate system used by the 3D GL environment, taking into consideration
 * the size and position of the layer/viewport.
 *
 * The cocos2d layer coordinates are relative, and measured from the bottom-left corner
 * of the layer, which might not be in the corner of the UIView or screen.
 *
 * The GL cocordinates are absolute, relative to the bottom-left corner of the underlying
 * UIView, which does not rotate with device orientation, is always in portait orientation,
 * and is always in the corner of the screen.
 *
 * One can think of the GL coordinates as absolute and fixed relative to the portrait screen,
 * and the layer coordinates as relative to layer position and size.
 */
-(CGPoint) glPointFromCC2Point: (CGPoint) cc2Point;

/**
 * Converts the specified point, which is in the coordinate system of the 3D GL environment,
 * into the coordinate system used by the cocos2d layer, taking into consideration the size
 * and position of the layer/viewport.
 *
 * The cocos2d layer coordinates are relative, and measured from the bottom-left corner
 * of the layer, which might not be in the corner of the UIView or screen.
 *
 * The GL cocordinates are absolute, relative to the bottom-left corner of the underlying
 * UIView, which is always in the corner of the screen.
 *
 * One can think of the GL coordinates as absolute and fixed relative to the portrait screen,
 * and the layer coordinates as relative to layer position and size.
 */
-(CGPoint) cc2PointFromGLPoint: (CGPoint) glPoint;

@end


#pragma mark -
#pragma mark CC3Frustum

/**
 * Represents a camera's frustum. Each CC3Camera instance contains an instance of this class.
 *
 * Each frustum has four sides: top, bottom, left and right, and has two caps: near and far.
 * These sides and caps are represented as six planes.
 *
 * The frustum is a truncated pyramid that has the location of the camera as the pyrimid apex.
 * This frustum manages and populates the projection matrix used by the camera, and builds its
 * planes from a combination of that projection matrix and the camera's modelview matrix.
 *
 * The frustum is a type of bounding volume and therefore supports methods for testing whether
 * locations, rays, shapes, and other bounding volumes intersect the volume of the frustum.
 */
@interface CC3Frustum : CC3BoundingVolume {
	CC3Camera* _camera;
	CC3Matrix* _finiteProjectionMatrix;
	CC3Matrix* _infiniteProjectionMatrix;
	CC3Plane _planes[6];
	CC3Vector _vertices[8];
	GLfloat _top;
	GLfloat _bottom;
	GLfloat _left;
	GLfloat _right;
	GLfloat _near;
	GLfloat _far;
	BOOL _isUsingParallelProjection : 1;
}

/**
 * The camera whose frustum this is.
 *
 * This link-back property is set automatically when this frustum is set into the frustum
 * property of the camera. Usually the application should never set this property directly.
 *
 * This is a weak reference to avoid a retain cycle between the camera and the frustum.
 */
@property(nonatomic, assign) CC3Camera* camera;

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

/** Returns the location of the near top left corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector nearTopLeft;

/** Returns the location of the near top right corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector nearTopRight;

/** Returns the location of the near bottom left corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector nearBottomLeft;

/** Returns the location of the near bottom right corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector nearBottomRight;

/** Returns the location of the far top left corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector farTopLeft;

/** Returns the location of the far top right corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector farTopRight;

/** Returns the location of the far bottom left corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector farBottomLeft;

/** Returns the location of the far bottom right corner of this frustum, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector farBottomRight;

/** A finite projection matrix with the far end at the distance given by the far property. */
@property(nonatomic, strong, readonly) CC3Matrix* finiteProjectionMatrix;

/** An infinite projection matrix with the far end at infinity. */
@property(nonatomic, strong, readonly) CC3Matrix* infiniteProjectionMatrix;

/**
 * Indicates whether this frustum uses parallel projection.
 *
 * If this value is set to NO, the projection matrix will be configured for
 * perspective projection, which is typical for 3D scenes. If this value is set
 * to YES, the projection matrix will be configured for orthographic projection.
 *
 * The initial value of this property is NO, indicating that perspective
 * projection will be used.
 */
@property(nonatomic, assign) BOOL isUsingParallelProjection;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) frustum;

/**
 * Sets the six frustum clipping planes and the projectionMatrix from the specified measurements.
 * The left and bottom measurements are set to the negated right and top measurements, respectively.
 */
-(void) populateRight: (GLfloat) right
			   andTop: (GLfloat) top
			  andNear: (GLfloat) near
			   andFar: (GLfloat) far;

/**
 * @deprecated Use populateRight:andTop:andNear:andFar: instead.
 *
 * Sets the six frustum clipping planes and the projectionMatrix from the specified view parameters.
 *
 * The aspect parameter indicates the width/height ratio of the viewport. The field of view angle
 * is applied to the narrower dimension, to ensure that overall perspective are consistent across
 * a simple transposition of the viewport dimensions (ie- a rotation of the viewport by 90 degrees).
 */
-(void) populateFrom: (GLfloat) fieldOfView
		   andAspect: (GLfloat) aspect
		 andNearClip: (GLfloat) nearClip
		  andFarClip: (GLfloat) farClip DEPRECATED_ATTRIBUTE;;

/** @deprecated Renamed to markDirty. */
-(void) markPlanesDirty DEPRECATED_ATTRIBUTE;

/** @deprecated Use the same property on the camera instead. */
@property(nonatomic, strong, readonly) CC3Matrix* viewMatrix DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to viewMatrix for a more accurate semantic. */
@property(nonatomic, strong, readonly) CC3Matrix* modelviewMatrix DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to doesIntersectLocation:. */
-(BOOL) doesIntersectPointAt: (CC3Vector) aLocation DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to doesIntersectLocation:. */
-(BOOL) doesIntersectSphereAt: (CC3Vector) aLocation withRadius: (GLfloat) radius DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3Node extension for lights

@interface CC3Node (Camera)

/**
 * Returns whether this node is a camera.
 *
 * This implementation returns NO. Subclasses that are cameras will override to return YES.
 */
@property(nonatomic, readonly) BOOL isCamera;

@end
