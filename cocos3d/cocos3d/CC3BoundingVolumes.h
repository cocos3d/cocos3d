/*
 * CC3BoundingVolumes.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Node.h"

#pragma mark -
#pragma mark CC3NodeBoundingVolume

/**
 * Bounding volumes are used by CC3Nodes to determine whether a node interset the camera's
 * frustum, or to determine boundaries for collision detection during physics simulation.
 * Many different shapes of boundaries are available, including points, spheres, bounding
 * boxes, etc, permitting tradeoffs between accuracy and computational processing time.
 *
 * This base bounding volume is simply a single point. When applied to a node, it indicates
 * that the node intersects the frustum if the node's center of geometry is within the frustum.
 *
 * For meshes, the center of geometry is calculated from the vertex locations, via specialized
 * subclasses of CC3NodeBoundingVolume. For other nodes, it can be set directly within the
 * bounding volume via the centerOfGeometry property.
 */
@interface CC3NodeBoundingVolume : NSObject <NSCopying> {
	CC3Node* node;
	CC3Vector centerOfGeometry;
	CC3Vector globalCenterOfGeometry;
	GLfloat cameraDistanceProduct;
	BOOL shouldMaximize;
	BOOL volumeIsDirty;
}

/** The node whose boundary this instance is keeping track of. */
@property(nonatomic, assign) CC3Node* node;

/**
 * The center of geometry for the node in the node's local coordinate system.
 *
 * For mesh nodes, the value of this property is automatically calculated from the
 * vertex locations, via specialized subclasses of CC3NodeBoundingVolume used for
 * meshes. For other nodes, this property can be set directly, if needed.
 *
 * You can also set this property directly for mesh nodes as well. Doing so will
 * override the value that was calculated automatically. This can be useful when
 * the vertices will be changing frequently, and therefore the bounding volume will
 * need to be recalculated frequently. By setting this property to a value that
 * suits all possible vertex configurations, you can avoid expensive recalculations
 * of the bounding volume as the vertices change.
 *
 * When setting the value of this property on a mesh node directly, be sure to also
 * set the shouldUseFixedBoundingVolume property of the node to YES, to stop automatic
 * recalculation of this bounding volume whenever the underlying mesh vertices change.
 *
 * The initial value of this property is kCC3VectorZero.
 */
@property(nonatomic, assign) CC3Vector centerOfGeometry;

/**
 * The center of geometry for the node in the global coordinate system.
 * This is updated automatically by the transformVolume method of this bounding volume.
 */
@property(nonatomic, readonly) CC3Vector globalCenterOfGeometry;

/**
 * A measure of the distance from the camera to the centre of geometry of the node.
 * This is used to test the Z-order of this node to determine rendering order.
 *
 * For nodes whose rendering order depends on distance to the camera (translucent nodes),
 * this property is set automatically once the global location of the node and the camera
 * are determined. The application will generally make no use of this property.
 *
 * Do not use the value of this property as the true distance from the node to the camera.
 * This measure is not the actual distance from the camera to the node, but it is related
 * to that distance.
 *
 * Different node sequencers may measure distance differently. If the node sequencer uses
 * the true distance from the camera to the node, this property will be set to the square
 * of that distance to avoid making the computationally expensive and unnecessary square-root
 * calculation. In addition, some node sequencers may compare distance in one direction only,
 * such as only in the forwardDirection of the camera, or only the Z-axis component of the distance.
 */
@property(nonatomic, assign) GLfloat cameraDistanceProduct;

/**
 * If the value of this property is set to YES, the boundary of this volume will only
 * ever expand when this bounding volume is repeatedly rebuilt from the underlying mesh
 * vertex data.
 * 
 * The shape of the boundary depends on the subclass. Whenever this bounding volume is
 * rebuilt, the resulting boundary is compared to the previous boundary, and replaces
 * the previous boundary only if it is larger.
 *
 * Rebuilding occurs whenever the update method is invoked and this bounding volume has
 * previously been marked as dirty via the markDirty method. Rebuilding also occurs
 * directly when the markDirtyAndUpdate method is invoked.
 *
 * Rebuilding occurs under control of the node, when the rebuildBoundingVolume method
 * of the node is invoked and the shouldUseFixedBoundingVolume of the node is set to NO.
 * Typically, the node invokes the rebuildBoundingVolume method whenever the vertex
 * location data in the underlying mesh has changed.
 *
 * Setting this property to YES and the shouldUseFixedBoundingVolume of the node to NO
 * can be useful when pre-computing an appropriate fixed boundary for a node whose vertex
 * location data frequently changes, such as a particle generator, and is often used at
 * development time.
 *
 * Once the resulting maximized boundary is determined, it can then be explicitly set
 * into this bounding volume at run time, and the shouldUseFixedBoundingVolume of the
 * node can be set to YES so that the processing cost of constantly rebuilding this
 * bounding volume will not be incurred.
 * 
 * If a dynamic boundary is required at runtime, set both the shouldUseFixedBoundingVolume
 * of the node and this property to NO. With a dynamic boundary, setting this property
 * to YES has no advantage. The performance cost will be the same, and the resulting
 * boundary will be less accurate.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldMaximize;

/**
 * Transforms this bounding volume to match the transformation of the node.
 * If this bounding volume has been marked dirty via the markDirty method,
 * this bounding volume will first be rebuilt from teh associated mesh vertices.
 *
 * This method is invoked automatically by the node whenever it recalculates
 * its transformMatrix. Usually, the application never needs to invoke this method directly.
 */
-(void) update;

/**
 * Marks the volume as dirty and in need of rebuilding from the associated mesh vertices
 * the next time that the update method is invoked.
 */
-(void) markDirty;

/**
 * Marks the volume as dirty and in need of rebuilding from the associated mesh vertices,
 * and forces an update and transform of the bounding volume.
 *
 * This method should be invoked whenever changes are made to the underlying mesh vertices.
 * It is invoked automatically when the rebuildBoundingVolume is invoked on a node.
 *
 * This is a convenience method that simply invokes the markDirty and update methods in order.
 */
-(void) markDirtyAndUpdate;

/** Allocates and initializes an autoreleased instance. */
+(id) boundingVolume;

/**
 * Returns whether this bounding volume intersects the specfied frustum.
 *
 * This default implementation always returns YES. Subclasses will override appropriately.
 *
 * This method is invoked automatically by the node whenever it needs to determine whether
 * or not it should be drawn.
 */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum;

@end


#pragma mark -
#pragma mark CC3NodeSphericalBoundingVolume interface

/**
 * A bounding volume that forms a sphere around a single point. When applied to a node, 
 * the center of the sphere is the node's center of geometry, and this class indicates
 * that the node intersects the frustum if any part of the sphere intersects the frustum.
 *
 * The radius of the sphere must cover the node, and is scaled automatically to match
 * the globalScale of the node. For meshes, the center of geometry and local radius are
 * calculated from the vertex locations. For other nodes, the center of gravity and radius
 * can be set directly within the bounding volume via their respective properties.
 */
@interface CC3NodeSphericalBoundingVolume : CC3NodeBoundingVolume {
	GLfloat radius;
	GLfloat globalRadius;
}

/**
 * The radius that encompasses the extent of the node in the node's local coordinate
 * system, as measured from the center of geometry of this instance.
 *
 * For mesh nodes, the value of this property is automatically calculated from the
 * vertex locations, via specialized subclasses of CC3NodeBoundingVolume used for
 * meshes. For other nodes, this property can be set directly, if needed.
 *
 * You can also set this property directly for mesh nodes as well. Doing so will
 * override the value that was calculated automatically. This can be useful when
 * the vertices will be changing frequently, and therefore the bounding volume will
 * need to be recalculated frequently. By setting this property to a value that
 * suits all possible vertex configurations, you can avoid expensive recalculations
 * of the bounding volume as the vertices change.
 *
 * When setting the value of this property on a mesh node directly, be sure to also
 * set the shouldUseFixedBoundingVolume property of the node to YES, to stop automatic
 * recalculation of this bounding volume whenever the underlying mesh vertices change.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) GLfloat radius;

/**
 * The radius that encompasses the extent of the node in the global coordinate system,
 * as measured from the global center of geometry of this instance.
 */
@property(nonatomic, readonly) GLfloat globalRadius;

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVolume interface

/**
 * A bounding volume that forms an axially aligned bounding box (AABB) around the node,
 * in the node's local coordinate system. When transformed, this becomes an oriented
 * bounding box (OBB) in the global coordinate system.
 *
 * This class indicates that the node is inside the frustum unless all eight vertices
 * of the transformed bounding box lie outside each of the frustum planes. This is 
 * much more computationally intenstive than a spherical bounding volume, but for
 * many shapes, particularly those that are rectangular, provides a tighter bounding
 * volume and therefore results in lower false-positives, which occurs when the bounding
 * volume intersects the frustum, but the object shape actually does not, resulting in
 * potentially significant unnecessary drawing activity.
 *
 * The local bounding box must cover the node, and is translated, rotated, and scaled
 * automatically to match the transformation of the node. For meshes, the local bounding
 * box is calculated from the vertex locations. For other nodes, the local bounding box
 * can be set directly within the bounding volume via the boundingBox property.
 */
@interface CC3NodeBoundingBoxVolume : CC3NodeBoundingVolume {
	CC3BoundingBox boundingBox;
	CC3Vector globalBoundingBoxVertices[8];
}

/**
 * The axially-aligned-bounding-box (AABB) in the node's local coordinate system.
 *
 * For mesh nodes, the value of this property is automatically calculated from the
 * vertex locations, via specialized subclasses of CC3NodeBoundingVolume used for
 * meshes. For other nodes, this property can be set directly, if needed.
 *
 * You can also set this property directly for mesh nodes as well. Doing so will
 * override the value that was calculated automatically. This can be useful when
 * the vertices will be changing frequently, and therefore the bounding volume will
 * need to be recalculated frequently. By setting this property to a value that
 * suits all possible vertex configurations, you can avoid expensive recalculations
 * of the bounding volume as the vertices change.
 *
 * When setting the value of this property on a mesh node directly, be sure to also
 * set the shouldUseFixedBoundingVolume property of the node to YES, to stop automatic
 * recalculation of this bounding volume whenever the underlying mesh vertices change.
 *
 * The initial value of this property is kCC3BoundingBoxZero.
 */
@property(nonatomic, assign) CC3BoundingBox boundingBox;

/**
 * An array of the eight vertices of the bounding box in the global coordinate system,
 * after the bounding box has been transformed (translated, rotated and scaled) to match
 * the transformation of the node. For a node to be definitively outside the frustum,
 * all eight vertices of the global bounding box must be outside each of the planes
 * of the frustum.
 */
@property(nonatomic, readonly) CC3Vector* globalBoundingBoxVertices;

@end


#pragma mark -
#pragma mark CC3NodeTighteningBoundingVolumeSequence interface

/**
 * A composite bounding volume that contains other bounding volumes.
 * This class tests whether the node intesects the frustum by testing each of the
 * contained bounding volumes against the frustum, in the order in which the contained
 * bounding volumes were added to an instance of this class.
 *
 * This class indicates that the node is outside the frustum as soon as one of the
 * contained bounding volumes indicates as much. Otherwise, if a contained bounding
 * volume indicates that the node is within the frustum, the node is tested against
 * the next contained bounding volume, and so on.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid indication of nodes
 * that are easily determined to be well outside the frustum, and only proceeding to
 * the more intensive, but presumably more accurate tests, if an early rejection
 * cannot be determined.
 *
 * For example, a typical bounding volume sequence might be to first test against
 * a spherical bounding volume, followed by a rectangular bounding-box bounding volume.
 */

@interface CC3NodeTighteningBoundingVolumeSequence : CC3NodeBoundingVolume {
	CCArray* boundingVolumes;
}

/**
 * The array of contained bounding volumes.
 * The contained bounding volumes will be traversed in the order they appear in the array.
 */
@property(nonatomic, readonly) CCArray* boundingVolumes;

/** Adds the specified bounding volume to the end of the array of contained bounding volumes. */
-(void) addBoundingVolume: (CC3NodeBoundingVolume*) aBoundingVolume;

@end


#pragma mark -
#pragma mark CC3NodeBoundingArea interface

/**
 * A bounding volume that defines a 2D bounding area for a node, and checks that
 * bounding area against a given 2D bounding box, which is typically the bounding
 * box of the CC3Layer, instead of the camera frustum. This is useful for, and only
 * applicable to, nodes that draw 2D content, such as CC3Billboards,
 *
 * By default, instances of CC3NodeBoundingArea return NO in the doesIntersectFrustum:
 * method, so nodes with this bounding volume will not be drawn when 3D nodes with
 * local content are drawn. Instead, CC3NodeBoundingArea adds the doesIntersectBounds:
 * method, which is invokded to test a 2D node boundary against a 2D bounding box.
 */
@interface CC3NodeBoundingArea : CC3NodeBoundingVolume

/**
 * Returns whether this bounding volume intersects the specfied bounding rectangle.
 *
 * This default implementation always returns YES. Subclasses will override appropriately.
 *
 * This method is invoked automatically by nodes with 2D content, whenever it needs to
 * determine whether or not it should be drawn.
 */
-(BOOL) doesIntersectBounds: (CGRect) bounds;

@end
