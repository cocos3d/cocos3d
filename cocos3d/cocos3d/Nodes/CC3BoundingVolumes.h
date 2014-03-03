/*
 * CC3BoundingVolumes.h
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


#import "CC3Foundation.h"

@class CC3Node, CC3Frustum;


#pragma mark -
#pragma mark CC3BoundingVolume

/**
 * Bounding volumes define a volume of space.
 *
 * Through the doesIntersect: method, a bounding volume can indicate whether it
 * intersects another bounding volume. This capability can be used for detecting
 * collisions between objects, or to indicate whether an object is located in a
 * particular volume of space, for example, the frustum of the camera.
 *
 * Many different shapes of boundaries are available, including points, spheres,
 * bounding boxes, cylinders, frustums, convex hulls, etc, permitting flexible
 * volume definition, and tradeoffs between accuracy and computational processing
 * time when testing intersections.
 */
@interface CC3BoundingVolume : NSObject <NSCopying> {
	BOOL _isDirty : 1;
	BOOL _shouldIgnoreRayIntersection : 1;
	BOOL _shouldLogIntersections : 1;
	BOOL _shouldLogIntersectionMisses : 1;
}

/**
 * For bounding volumes that are described in terms of a hull of vertices and
 * planes, this property returns the array of planes that define the boundary
 * surface of this bounding volume.
 *
 * The planes are defined in the global coordinate system. The number of planes
 * in the array is specified by the planeCount property.
 *
 * Not all bounding volumes are based on vertices and planes, and this abstract
 * implementation returns the NULL pointer. Subclasses that make use of vertices
 * and planes will allocate the underlying array and override this implementation.
 */
@property(nonatomic, assign, readonly) CC3Plane* planes;

/**
 * For bounding volumes that are described in terms of a hull of vertices and
 * planes, this property returns the number of planes in the array returned
 * by the planes property.
 *
 * Not all bounding volumes are based on vertices and planes, and this abstract
 * implementation returns zero. Subclasses that make use of vertices and planes
 * will allocate the underlying array and override this implementation.
 */
@property(nonatomic, assign, readonly) GLuint planeCount;

/**
 * For bounding volumes that are described in terms of a hull of vertices and
 * planes, this property returns the array of vertices at the points where the
 * planes intersect.
 *
 * The vertices are defined in the global coordinate system. The number of
 * vertices in the array is defined by the vertexCount property.
 *
 * The returned vertices are not in any defined order.
 *
 * Not all bounding volumes are based on vertices and planes, and this abstract
 * implementation returns the NULL pointer. Subclasses that make use of vertices
 * and planes will allocate the underlying array and override this implementation.
 */
@property(nonatomic, readonly) CC3Vector* vertices;

/**
 * For bounding volumes that are described in terms of a hull of vertices and
 * planes, this property returns the number of planes in the array returned
 * by the vertices property.
 *
 * Not all bounding volumes are based on vertices and planes, and this abstract
 * implementation returns zero. Subclasses that make use of vertices and planes
 * will allocate the underlying array and override this implementation.
 */
@property(nonatomic, readonly) GLuint vertexCount;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) boundingVolume;

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
-(void) populateFrom: (CC3BoundingVolume*) another;

/**
 * Returns a string containing a more complete description of this bounding
 * volume, including the vertices and planes.
 *
 * Subclasses whose bounding volumes are not described in terms of a hull
 * of vertices and planes should override this method to return a more
 * appropriate description.
 */
-(NSString*) fullDescription;


#pragma mark Updating

/** Indicates whether this volume is dirty and in need of rebuilding. */
@property(nonatomic, readonly) BOOL isDirty;

/**
 * Marks this volume as dirty and in need of rebuilding.
 *
 * The bounding volume will automatically be marked as dirty by changing any
 * of the properties of the bounding volume. However, for subclasses that
 * depend on content managed elsewhere, this method may be used to indicate
 * to this bounding volume that it needs to be rebuilt.
 * 
 * If needed, rebuilding is lazily performed automatically when the bounding
 * volume is tested against another bounding volume, or when a property that
 * depends on the rebuilding is accessed.
 */
-(void) markDirty;


#pragma mark Intersection testing

/**
 * Returns whether this bounding volume intersects the specfied other bounding volume.
 *
 * This implementation tests whether the other bounding volume intersects the
 * convex hull of this bounding volume, by double-dispatching to the
 * doesIntersectConvexHullOf:planes:from: method of the other bounding volume,
 * passing this bounding volume's planes property as the planes to test, and
 * passing this bounding volume as the otherBoundingVolume argument to that method.
 *
 * Subclasses whose bounding volumes are not described in terms of a hull of
 * vertices and planes must override this method to perform some other test.
 * Typically, subclasses that do override will implement this method as the
 * double-dispatch pattern, invoking one of the doesIntersect...:from: methods
 * on the specified other bounding volume, and even potentially adding other
 * such methods in an extension category.
 */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume;

/**
 * Returns whether the specified global location intersects (is inside) this bounding volume.
 * 
 * Returns whether the specified location is contained within the convex hull of this
 * bounding volume, by testing if the specified location is behind all of the planes
 * in the planes property of this bounding volume.
 *
 * Subclasses whose bounding volumes are not described in terms of a hull of
 * vertices and planes must override this method to perform some other test.
 */
-(BOOL) doesIntersectLocation: (CC3Vector) aLocation;

/**
 * Returns whether the specified global-coordinate ray intersects this bounding volume.
 *
 * Returns whether the specified ray intersects the convex hull of this bounding volume,
 * by testing if the intesection point of the ray and one of the planes in the planes
 * property of this bounding volume is behind all of the remaining planes of this
 * bounding volume.
 *
 * The operation of this method is affected by the shouldIgnoreRayIntersection property.
 * If that property is set to YES, this method will always return NO. See the notes of
 * the shouldIgnoreRayIntersection property for more info.
 *
 * Subclasses whose bounding volumes are not described in terms of a hull of
 * vertices and planes must override this method to perform some other test.
 */
-(BOOL) doesIntersectRay: (CC3Ray) aRay;

/**
 * Indicates whether this bounding volume should ignore intersections from rays.
 * If this property is set to YES, intersections with rays will be ignored, and
 * the doesIntersectRay: method will always return NO.
 *
 * The initial value of this property is NO, and most of the time this is sufficient.
 *
 * For some uses, such as the bounding volumes of nodes that should be excluded from
 * puncturing from touch selection rays, such as particle emitters, it might make
 * sense to set this property to YES, so that the bounding volume is not affected
 * by rays from touch events.
 */
@property(nonatomic, assign) BOOL shouldIgnoreRayIntersection;

/**
 * Returns whether this bounding volume lies completely in front of the specified
 * normalized global coordinate plane.
 *
 * This method returns YES if the bounding volume lies completely on the side of
 * the plane from which the plane normal points. It returns NO if this bounding
 * volume intersects the plane or lies completely on the opposite side of the plane.
 *
 * Returns whether all of the vertices of this bounding volume are on the side of
 * the plane from which the normal points.
 *
 * Subclasses whose bounding volumes are not described in terms of a hull of
 * vertices and planes must override this method to perform some other test.
 */
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane;

/**
 * Returns whether the specified sphere intersects this bounding volume.
 *
 * This implementation delegates to the doesIntersectSphere:from: method,
 * passing nil as the other bounding volume.
 */
-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere;

/**
 * Returns whether the specified sphere intersects this bounding volume.
 *
 * Returns whether the specified sphere intersects the convex hull of
 * this bounding volume.
 *
 * For the specified sphere to intesect this bounding volume, the center
 * of the sphere must be closer to the convex hull formed by the planes
 * of this bounding volume than the radius of the sphere.
 *
 * In other words, the sphere will be outside this bounding volume if the
 * center of the sphere lies in front of any one of the planes in the planes
 * property of this bounding volume by more than the radius of the sphere.
 *
 * This implementation ignores the otherBoundingVolume argument.
 *
 * Subclasses whose bounding volumes are not described in terms of a hull of
 * vertices and planes must override this method to perform some other test.
 */
-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns whether a convex hull composed of the specified global planes intersects
 * this bounding volume. The planes may be the face planes of a mesh, or they may
 * be the sides of an oriented bounding box (OBB), or frustum, etc.
 * 
 * This implementation delegates to the doesIntersectConvexHullOf:planes:from:
 * method, passing nil as the other bounding volume.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes planes: (CC3Plane*) otherPlanes;

/**
 * Returns whether a convex hull composed of the specified global planes from the
 * specified other bounding volume intersects this bounding volume. The planes may
 * be the face planes of a mesh, or they may be the sides of an oriented bounding
 * box (OBB), or frustum, etc.
 *
 * If all of the vertices of this bounding volume lie outside at least one of the
 * specified planes, then this bounding volume cannot intersect the convex hull
 * defined by those planes, and this method returns NO.
 *
 * Such a test will not return any false-negative results. When an intersection
 * really does occur, it will always return YES, and will never return NO.
 *
 * However, a false-positive result is possible with this test and, depending on
 * the relative orientations of the bounding volumes, can occasionally return YES
 * when an intersection has not actually happened.
 *
 * To compensate, this method also performs the same test from the opposite
 * direction by invoking the doesIntersectConvexHullOf:planes: method of the
 * specified otherBoundingVolume, passing the planes of this bounding volume.
 *
 * Therefore, with the goal of reducing the occurences of false-positive results,
 * this test is implmented by eliminating intersection failures. Each bounding
 * volume is tested against the planes of the other, and this method returns
 * NO as soon as one of those tests indicates intersection failure. If neither
 * test rejects the intersection, then this method assumes that the intersection
 * has occurred, and return YES.
 *
 * False-positives are still possible, and this method can still indicate an
 * intersection has occurred when it really hasn't. But, by combining the tests
 * from both directions, the accuracy is improved.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns the location at which the specified ray intersects this bounding volume,
 * or returns kCC3VectorNull if the ray does not intersect this bounding volume.
 *
 * The result honours the startLocation of the ray, and will return kCC3VectorNull
 * if this bounding volume is "behind" the startLocation, even if the line projecting
 * back through the startLocation in the negative direction of the ray intersects
 * this bounding volume.
 *
 * The ray may start inside this bounding volume, in which case, the returned
 * location represents the exit location of the ray.
 *
 * The operation of this method is affected by the shouldIgnoreRayIntersection property.
 * If that property is set to YES, this method will always return kCC3VectorNull. See
 * the notes of the shouldIgnoreRayIntersection property for more info.
 *
 * Both the input ray and the returned location are specified in global coordinates.
 *
 * The returned result can be tested for null using the CC3VectorIsNull function.
 */
-(CC3Vector) globalLocationOfGlobalRayIntesection: (CC3Ray) aRay;


#pragma mark Intersection logging

/**
 * When this property is set to YES, a log message will be output whenever the
 * doesIntersect: method returns YES (indicating that another bounding volume
 * intersects this bounding volume), if the shouldLogIntersections property of
 * the other bounding volume is also set to YES.
 *
 * The shouldLogIntersections property of both bounding volumes must be set
 * to YES for the log message to be output.
 *
 * The initial value of this property is NO.
 *
 * This property is useful during development to help trace intersections
 * between bounding volumes, such as collision detection between nodes, or
 * whether a node is within the camera's frustum.
 * 
 * This property is only effective when the LOGGING_ENABLED
 * compiler build setting is defined and set to 1.
 */
@property(nonatomic, assign) BOOL shouldLogIntersections;

/**
 * When this property is set to YES, a log message will be output whenever the
 * doesIntersect: method returns NO (indicating that another bounding volume
 * does not intersect this bounding volume), if the shouldLogIntersectionMisses
 * property of the other bounding volume is also set to YES.
 *
 * The shouldLogIntersectionMisses property of both bounding volumes must be
 * set to YES for the log message to be output.
 *
 * The initial value of this property is NO.
 *
 * This property is useful during development to help trace intersections
 * between bounding volumes, such as collision detection between nodes, or
 * whether a node is within the camera's frustum.
 * 
 * This property is only effective when the LOGGING_ENABLED
 * compiler build setting is defined and set to 1.
 */
@property(nonatomic, assign) BOOL shouldLogIntersectionMisses;

@end


#pragma mark -
#pragma mark CC3NodeBoundingVolume

/**
 * CC3NodeBoundingVolumes are used by CC3Nodes to determine whether a node intersets another
 * bounding volume, including the camera's frustum, or to determine boundaries for collision
 * detection during physics simulation.
 *
 * Many different shapes of boundaries are available, including points, spheres, bounding
 * boxes, etc, permitting tradeoffs between accuracy and computational processing time.
 *
 * This is an abstract class that tracks the center of geometry of the node. Subclasses are
 * provided to reflect specific shapes around the node and to perform suitable intersection tests.
 *
 * For meshes, the center of geometry is calculated from the vertex locations, via specialized
 * subclasses of CC3NodeBoundingVolume. For other nodes, it can be set directly within the
 * bounding volume via the centerOfGeometry property.
 *
 * In most cases, each node has its own bounding volume. However, when using bounding volumes
 * with skin mesh nodes whose vertices are influenced by separate bone nodes, it often makes
 * sense to share the bounding volume between one of the primary skeleton bones and the skin
 * mesh nodes, so that the bone can control the movement and shape of the bounding volume,
 * and the skin node can use that same bounding volume to determine whether its vertices are
 * intersecting another bounding volume, including the camera frustum.
 *
 * You employ this technique by assigning the bounding volume to the bone first, using the
 * boundingVolume property of the skeleton bone node, and then assigning the same bounding
 * volume to all skin nodes affected by that skeleton, using the setSkeletalBoundingVolume:
 * method on a common ancestor node of all the affected skin mesh nodes.
 */
@interface CC3NodeBoundingVolume : CC3BoundingVolume {
	CC3Node* _node;
	CC3Vector _centerOfGeometry;
	CC3Vector _globalCenterOfGeometry;
	BOOL _shouldBuildFromMesh : 1;
	BOOL _shouldMaximize : 1;
	BOOL _isTransformDirty : 1;
	BOOL _shouldDraw : 1;
}

/** The node whose boundary this instance is keeping track of. */
@property(nonatomic, assign) CC3Node* node;

/** 
 * Indicates whether this instance should build its bounds from the vertex locations within
 * the mesh held by this bounding volume's node.
 *
 * The node must be a CC3MeshNode for this property to be set to YES.
 *
 * The initial value of this property will be NO if this bounding volume was created with
 * specific dimensions, or if the node is not a type of CC3MeshNode. Otherwise, the initial
 * value of this property will be YES.
 */
@property(nonatomic, assign) BOOL shouldBuildFromMesh;

/**
 * The center of geometry for the node in the node's local coordinate system.
 *
 * For mesh nodes, the value of this property is automatically calculated from the vertex locations,
 * via specialized subclasses of CC3NodeBoundingVolume used for meshes. For other nodes, this property
 * can be set directly, if needed.
 *
 * You can also set this property directly for mesh nodes as well. Doing so will override the value
 * that was calculated automatically. This can be useful when the vertices will be changing frequently,
 * and therefore the bounding volume will need to be recalculated frequently. By setting this property
 * to a value that suits all possible vertex configurations, you can avoid expensive recalculations
 * of the bounding volume as the vertices change.
 *
 * Setting the value of this property sets the shouldBuildFromMesh property to NO, so that
 * the center of geometry will not be overridden if the vertices of the mesh change.
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
 * If the value of this property is set to YES, the boundary of this volume will only
 * ever expand when this bounding volume is repeatedly rebuilt from the underlying mesh
 * vertex data.
 * 
 * The shape of the boundary depends on the subclass. Whenever this bounding volume is
 * rebuilt, the resulting boundary is compared to the previous boundary, and replaces
 * the previous boundary only if it is larger.
 *
 * Rebuilding occurs whenever the node marks the bounding volume as dirty using the
 * markDirty method. The bounding volume is rebuilt lazily and automatically when the
 * bounding volume is tested against another bounding volume, or when a property that
 * depends on the rebuilding is accessed.
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


#pragma mark Updating

/** 
 * Scales the size of this bounding volume by the specified amount, relative to its current size.
 *
 * This method also sets the shouldBuildFromMesh property to NO so that the size of this
 * bounding volume will not change if the underlying mesh vertices change.
 *
 * This implementation sets the shouldBuildFromMesh property to NO. Subclasses with actual 
 * size should override to adjust their size, and then invoke this superclass method.
 */
-(void) scaleBy: (GLfloat) scale;

/**
 * Indicates whether this volume needs to be transformed. This is different than
 * the isDirty property, and is an indication that the node has been transformed
 * and therefore the bounding volume of the node needs to be transformed as well.
 */
@property(nonatomic, readonly) BOOL isTransformDirty;

/**
 * Marks that this volume requires being transformed.
 *
 * This is different than the markDirty method. That method indicates that the
 * underlying structure of the bounding volume needs to be rebuilt. This method
 * indicates that the underlying structure may not have changed, but it requires
 * being transformed to match a change in the node's transform properties.
 *
 * The node containing this bounding volume should invoke this method whenever the
 * transform matrix of that node has changed.
 *
 * After this method has been invoked, the transformation is automatically carried
 * out lazily when the bounding volume is tested against another bounding volume,
 * or when a property that depends on the transformation is accessed.
 *
 * Usually, the application never needs to invoke this method directly.
 */
-(void) markTransformDirty;


#pragma mark Intersection testing

/**
 * Returns the location at which the specified ray intersects this bounding volume
 * or returns kCC3VectorNull if the ray does not intersect this bounding volume.
 *
 * The result honours the startLocation of the ray, and will return kCC3VectorNull
 * if this bounding volume is "behind" the startLocation, even if the line projecting
 * back through the startLocation in the negative direction of the ray intersects
 * this bounding volume.
 *
 * The ray may start inside this bounding volume, in which case, the returned
 * location represents the exit location of the ray.
 *
 * Both the input ray and the returned location are specified in the local
 * coordinate system of the node holding this bounding volume. A valid non-null
 * result can therefore be used to place other nodes at the intersection location,
 * by simply adding them to the node at the returned location.
 *
 * The returned result can be tested for null using the CC3VectorIsNull function.
 *
 * The operation of this method is affected by the shouldIgnoreRayIntersection property.
 * If that property is set to YES, this method will always return kCC3VectorNull. See
 * the notes of the shouldIgnoreRayIntersection property for more info.
 *
 * When using this method, keep in mind that the returned intersection location is
 * located on the surface of the bounding volume, not on the surface of the node.
 * Depending on the shape of the surface of the node, the returned location may
 * visually appear to be at a different location than where you expect to see it
 * on the surface of on the node.
 */
-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay;

/** @deprecated Replaced by the more general doesIntersect: method. */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum DEPRECATED_ATTRIBUTE;


#pragma mark Drawing bounding volume

/**
 * Indicates that this bounding volume should draw itself over the node.
 *
 * This property can be useful during development to verify the extent
 * of the bounding volume.
 *
 * Setting this property to YES will add a translucent child mesh node,
 * of an appropriate shape, to the node whose bounding volume this is.
 */
@property(nonatomic, assign) BOOL shouldDraw;

/** The color used when this bounding volume is displayed. */
-(ccColor3B) displayNodeColor;

/** The opacity used when this bounding volume is displayed. */
-(GLubyte) displayNodeOpacity;

@end


#pragma mark -
#pragma mark CC3NodeCenterOfGeometryBoundingVolume

/**
 * CC3NodeCenterOfGeometryBoundingVolume is simply a single point at the node's center
 * of geometry. When applied to a node, it indicates that the node intersects another
 * bounding volume if the node's center of geometry is within that bounding volume.
 *
 * For meshes, the center of geometry is calculated from the vertex locations, via
 * specialized subclasses of CC3NodeBoundingVolume. For other nodes, it can be set
 * directly within the bounding volume via the centerOfGeometry property.
 */
@interface CC3NodeCenterOfGeometryBoundingVolume : CC3NodeBoundingVolume


#pragma mark Intersection testing

/**
 * Returns whether this bounding volume intersects the specfied other bounding volume.
 *
 * This implementation tests whether the globalCenterOfGeometry of this bounding
 * volume is inside the other bounding volume, by double-dispatching to the
 * doesIntersectLocation: method of the other bounding volume, passing this bounding
 * volume's globalCenterOfGeometry as the location to test.
 */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume;

/**
 * Returns whether the specified global location intersects (is inside) this bounding volume.
 * 
 * Returns whether the specified location is the same as the globalCenterOfGeometry
 * of this bounding volume.
 */
-(BOOL) doesIntersectLocation: (CC3Vector) aLocation;

/**
 * Returns whether the specified global-coordinate ray intersects this bounding volume.
 *
 * Returns whether the globalCenterOfGeometry of this bounding volume lies on the specified ray.
 *
 * The operation of this method is affected by the shouldIgnoreRayIntersection property.
 * If that property is set to YES, this method will always return NO. See the notes of
 * the shouldIgnoreRayIntersection property for more info.
 */
-(BOOL) doesIntersectRay: (CC3Ray) aRay;

/**
 * Returns whether this bounding volume lies completely outside the specified
 * normalized global coordinate plane.
 *
 * This method returns YES if the bounding volume lies completely on the side of
 * the plane from which the plane normal points. It returns NO if this bounding
 * volume intersects the plane or lies completely on the opposite side of the plane.
 *
 * Returns whether the globalCenterOfGeometry of this bounding volume is on the
 * side of the plane from which the normal points.
 */
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane;

/**
 * Returns whether the specified global-coordinate sphere intersects this bounding volume.
 *
 * Returns whether the globalCenterOfGeometry of this bounding volume
 * lies within specified sphere.
 *
 * This implementation ignores the otherBoundingVolume argument.
 */
-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns whether a convex hull composed of the specified global planes intersects
 * this bounding volume. The planes may be the face planes of a mesh, or they may
 * be the sides of an oriented bounding box (OBB), or frustum, etc.
 * 
 * Returns whether the globalCenterOfGeometry of this bounding volume is inside the
 * convex hull defined by the specified planes. To be so, the globalCenterOfGeometry
 * must be behind every one of the specified planes.
 *
 * This implementation ignores the otherBoundingVolume argument.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume;

@end


#pragma mark -
#pragma mark CC3NodeSphericalBoundingVolume interface

/**
 * A bounding volume that forms a sphere around a single point. When applied to a node, the
 * center of the sphere is the node's center of geometry, and this class indicates that the node
 * intersects another bounding volume if any part of the sphere intersects that bounding volume.
 *
 * The radius of the sphere must cover the node, and is scaled automatically to match
 * the globalScale of the node. For meshes, the center of geometry and local radius are
 * calculated from the vertex locations. For other nodes, the center of gravity and radius
 * can be set directly within the bounding volume via their respective properties.
 */
@interface CC3NodeSphericalBoundingVolume : CC3NodeBoundingVolume {
	GLfloat _radius;
	GLfloat _globalRadius;
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
 * Setting the value of this property sets the shouldBuildFromMesh property to NO, so that
 * the radius will not be overridden if the vertices of the mesh change.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) GLfloat radius;

/**
 * The radius that encompasses the extent of the node in the global coordinate system,
 * as measured from the global center of geometry of this instance.
 */
@property(nonatomic, readonly) GLfloat globalRadius;

/** Returns a sphere constructed from the centerOfGeometry and the radius properties. */
@property(nonatomic, readonly) CC3Sphere sphere;

/** Returns a sphere constructed from the globalCenterOfGeometry and the globalRadius properties. */
@property(nonatomic, readonly) CC3Sphere globalSphere;


#pragma mark Intersection testing

/**
 * Returns whether this bounding volume intersects the specfied other bounding volume.
 *
 * This implementation tests whether the globalSphere of this bounding volume intersects
 * the other bounding volume, by double-dispatching to the doesIntersectSphere:from:
 * method of the other bounding volume, passing this bounding volume's globalSphere as
 * the sphere to test, and passing this bounding volume as the otherBoundingVolume
 * argument to that method.
 */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume;

/**
 * Returns whether the specified global location intersects (is inside) this bounding volume.
 * 
 * Returns whether the specified location is contained within the globalSphere of this
 * bounding volume.
 */
-(BOOL) doesIntersectLocation: (CC3Vector) aLocation;

/**
 * Returns whether the specified global-coordinate ray intersects this bounding volume.
 *
 * Returns whether the specified ray intersects the globalSphere of this bounding volume.
 *
 * The operation of this method is affected by the shouldIgnoreRayIntersection property.
 * If that property is set to YES, this method will always return NO. See the notes of
 * the shouldIgnoreRayIntersection property for more info.
 */
-(BOOL) doesIntersectRay: (CC3Ray) aRay;

/**
 * Returns whether this bounding volume lies completely outside the specified
 * normalized global coordinate plane.
 *
 * This method returns YES if the bounding volume lies completely on the side of
 * the plane from which the plane normal points. It returns NO if this bounding
 * volume intersects the plane or lies completely on the opposite side of the plane.
 *
 * Returns whether the globalCenterOfGeometry of this bounding volume is farther
 * away than the globalRadius from the side of the plane from which the normal points.
 */
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane;

/**
 * Returns whether the specified global-coordinate sphere intersects this bounding volume.
 *
 * Returns whether the specified sphere intersects the globalSphere of this bounding volume.
 *
 * This implementation ignores the otherBoundingVolume argument.
 */
-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns whether a convex hull composed of the specified global planes intersects
 * this bounding volume. The planes may be the face planes of a mesh, or they may
 * be the sides of an oriented bounding box (OBB), or frustum, etc.
 * 
 * Returns whether the globalSphere of this bounding volume intersects the convex
 * hull defined by the specified planes. To be so, the globalCenterOfGeometry of
 * this bounding volume must be no farther away than the globalRadius from the
 * front face of every one of the specified planes.
 *
 * This implementation ignores the otherBoundingVolume argument.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume;


#pragma mark Allocation and initialization

/** 
 * Initializes this instance from the specified sphere,
 * and sets the shouldBuildFromMesh property to NO.
 *
 * The sphere dimensions are specified in the coordinate system of the node. The resulting bounding
 * volume is fixed to the sizes provided, and will not take into consideration the vertices of the
 * mesh. It will, however, transform along with the node, as the node is transformed.
 */
-(id) initFromSphere: (CC3Sphere) sphere;

/** 
 * Allocates and initializes an autoreleased instance from the specified sphere,
 * and sets the shouldBuildFromMesh property to NO.
 *
 * The sphere dimensions are specified in the coordinate system of the node. The resulting bounding
 * volume is fixed to the sizes provided, and will not take into consideration the vertices of the
 * mesh. It will, however, transform along with the node, as the node is transformed.
 */
+(id) boundingVolumeFromSphere: (CC3Sphere) sphere;

@end


#pragma mark -
#pragma mark CC3NodeBoxBoundingVolume interface

/**
 * A bounding volume that forms an axially aligned bounding box (AABB) around the node,
 * in the node's local coordinate system. When transformed, this becomes an oriented
 * bounding box (OBB) in the global coordinate system.
 *
 * This class indicates that the node is inside another bounding volume unless all
 * eight vertices of the transformed bounding box lie outside each of the planes of
 * the other bounding volume.
 *
 * These tests are much more computationally intenstive than a spherical bounding
 * volume, but for many shapes, particularly those that are rectangular, provides
 * a tighter bounding volume and therefore results in lower false-positives, which
 * occurs when the bounding volume intersects the other bounding volume, but the
 * object shapes actually do not intersect.
 *
 * The local bounding box must cover the node, and is translated, rotated, and scaled
 * automatically to match the transformation of the node. For meshes, the local bounding
 * box is calculated from the vertex locations. For other nodes, the local bounding box
 * can be set directly within the bounding volume via the boundingBox property.
 */
@interface CC3NodeBoxBoundingVolume : CC3NodeBoundingVolume {
	CC3Box _boundingBox;
	CC3Vector _vertices[8];
	CC3Plane _planes[6];
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
 * Setting the value of this property sets the shouldBuildFromMesh property to NO, so that
 * the bounding box will not be overridden if the vertices of the mesh change.
 *
 * The initial value of this property is kCC3BoxZero.
 */
@property(nonatomic, assign) CC3Box boundingBox;

/** @deprecated Use the superclass vertices property instead. */
@property(nonatomic, readonly) CC3Vector* globalBoundingBoxVertices DEPRECATED_ATTRIBUTE;


#pragma mark Allocation and initialization

/** 
 * Initializes this instance from the specified bounding box,
 * and sets the shouldBuildFromMesh property to NO.
 *
 * The box dimensions are specified in the coordinate system of the node. The resulting bounding
 * volume is fixed to the sizes provided, and will not take into consideration the vertices of
 * the mesh. It will, however, transform along with the node, as the node is transformed.
 */
-(id) initFromBox: (CC3Box) box;

/** 
 * Allocates and initializes an autoreleased instance from the specified bounding box,
 * and sets the shouldBuildFromMesh property to NO.
 *
 * The box dimensions are specified in the coordinate system of the node. The resulting bounding
 * volume is fixed to the sizes provided, and will not take into consideration the vertices of
 * the mesh. It will, however, transform along with the node, as the node is transformed.
 */
+(id) boundingVolumeFromBox: (CC3Box) box;

@end

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated Renamed to CC3NodeBoxBoundingVolume.
 */
@interface CC3NodeBoundingBoxVolume : CC3NodeBoxBoundingVolume
@end


#pragma mark -
#pragma mark CC3NodeTighteningBoundingVolumeSequence interface

/**
 * A composite bounding volume that contains other bounding volumes.
 *
 * This class tests whether this bounding volume intesects another bounding volume
 * by testing that bounding volume against each of the contained bounding volumes
 * in turn, in the order that the contained bounding volumes were added to this
 * bounding volume.
 *
 * This class indicates that the other bounding volume being tested is outside this
 * bounding volume as soon as one of the contained bounding volumes indicates as much.
 * Otherwise, if a contained bounding volume indicates an intersection has occurred,
 * the other bounding volume being tested is tested against the next contained
 * bounding volume, and so on.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid rejection during
 * testing against other bounding volumes, of those that are easily determined to be
 * well outside this bounding volume, and only proceeding to the more intensive (but
 * presumably more accurate) tests, if an early rejection cannot be determined.
 *
 * For example, a typical bounding volume sequence might be to first test against
 * a simple, but crude, spherical bounding volume, followed by a rectangular
 * bounding-box bounding volume, or even a full mesh-based bounding volume.
 */
@interface CC3NodeTighteningBoundingVolumeSequence : CC3NodeBoundingVolume {
	NSMutableArray* _boundingVolumes;
}

/**
 * The array of contained bounding volumes.
 *
 * When testing for instersection, the contained bounding volumes will be traversed
 * in the order they appear in this array.
 */
@property(nonatomic, retain, readonly) NSArray* boundingVolumes;

/** Adds the specified bounding volume to the end of the array of contained bounding volumes. */
-(void) addBoundingVolume: (CC3NodeBoundingVolume*) aBoundingVolume;


#pragma mark Intersection testing

/**
 * Returns whether this bounding volume intersects the specfied other bounding volume.
 *
 * This implementation delegates to the contained bounding volumes in the order
 * in which they were added to this sequence, and returns NO as soon as one of
 * the contained bounding volumes returns NO.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid rejection during
 * testing against other bounding volumes, of those that are easily determined to be
 * well outside this bounding volume, and only proceeding to the more intensive (but
 * presumably more accurate) tests, if an early rejection cannot be determined.
 */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume;

/**
 * Returns whether the specified global location intersects (is inside) this bounding volume.
 * 
 * This implementation delegates to the contained bounding volumes in the order
 * in which they were added to this sequence, and returns NO as soon as one of
 * the contained bounding volumes returns NO.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid rejection during
 * testing, of locations that are easily determined to be well outside this bounding
 * volume, and only proceeding to the more intensive (but presumably more accurate)
 * tests, if an early rejection cannot be determined.
 */
-(BOOL) doesIntersectLocation: (CC3Vector) aLocation;

/**
 * Returns whether the specified global-coordinate ray intersects this bounding volume.
 *
 * This implementation delegates to the contained bounding volumes in the order
 * in which they were added to this sequence, and returns NO as soon as one of
 * the contained bounding volumes returns NO.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid rejection during
 * testing, of rays that are easily determined to be well outside this bounding
 * volume, and only proceeding to the more intensive (but presumably more accurate)
 * tests, if an early rejection cannot be determined.
 *
 * The operation of this method is affected by the shouldIgnoreRayIntersection property.
 * If that property is set to YES, this method will always return NO. See the notes of
 * the shouldIgnoreRayIntersection property for more info.
 */
-(BOOL) doesIntersectRay: (CC3Ray) aRay;

/**
 * Returns whether this bounding volume lies completely outside the specified
 * normalized global coordinate plane.
 *
 * This method returns YES if the bounding volume lies completely on the side of
 * the plane from which the plane normal points. It returns NO if this bounding
 * volume intersects the plane or lies completely on the opposite side of the plane.
 *
 * This implementation delegates to the contained bounding volumes in the order
 * in which they were added to this sequence, and returns YES as soon as one of
 * the contained bounding volumes returns YES.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid rejection during
 * testing, of rays that are easily determined to be well outside this bounding
 * volume, and only proceeding to the more intensive (but presumably more accurate)
 * tests, if an early rejection cannot be determined.
 */
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane;

/**
 * Returns whether the specified sphere intersects this bounding volume.
 *
 * This implementation delegates to the contained bounding volumes in the order
 * in which they were added to this sequence, and returns NO as soon as one of
 * the contained bounding volumes returns NO.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid rejection during
 * testing, of spheres that are easily determined to be well outside this bounding
 * volume, and only proceeding to the more intensive (but presumably more accurate)
 * tests, if an early rejection cannot be determined.
 */
-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns whether a convex hull composed of the specified global planes intersects
 * this bounding volume. The planes may be the face planes of a mesh, or they may
 * be the sides of an oriented bounding box (OBB), or frustum, etc.
 * 
 * This implementation delegates to the contained bounding volumes in the order
 * in which they were added to this sequence, and returns NO as soon as one of
 * the contained bounding volumes returns NO.
 *
 * The contained bounding volumes should be added in increasing order of computational
 * complexity (but presumably lower accuracy), allowing a rapid rejection during
 * testing, of convex hulls that are easily determined to be well outside this
 * bounding volume, and only proceeding to the more intensive (but presumably more
 * accurate) tests, if an early rejection cannot be determined.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume;

@end


#pragma mark -
#pragma mark CC3NodeSphereThenBoxBoundingVolume interface

/**
 * CC3NodeSphereThenBoxBoundingVolume is a CC3NodeBoundingVolume that contains a 
 * CC3NodeSphericalBoundingVolume and a CC3NodeBoxBoundingVolume. The effective spacial
 * volume defined by this bounding volume is the intersection space of the spherical and
 * box volumes. Therefore, a point must lie within BOTH the sphere and the box to be 
 * considered contained within this bounding volume.
 *
 * The spherical bounding volume is tested first, and if it passes, the bounding box volume is
 * tested next. This combination benefits from the fast testing capabilities of the spherical
 * bounding volume to reject obvious intersection failures, and from the bounding box's more
 * accurate volume coverage on most meshes.
 */
@interface CC3NodeSphereThenBoxBoundingVolume : CC3NodeBoundingVolume {
	CC3NodeSphericalBoundingVolume* _sphericalBoundingVolume;
	CC3NodeBoxBoundingVolume* _boxBoundingVolume;
}

/** The spherical bounding volume that is tested first. */
@property(nonatomic, retain, readonly) CC3NodeSphericalBoundingVolume* sphericalBoundingVolume;

/** The box bounding volume that is tested only if the test against the spherical bounding volume passes. */
@property(nonatomic, retain, readonly) CC3NodeBoxBoundingVolume* boxBoundingVolume;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance containing a standard
 * CC3NodeSphericalBoundingVolume and a standard CC3NodeBoxBoundingVolume.
 */
+(id) boundingVolume;

/** Initializes this instance containing the specified bounding volumes. */
-(id) initWithSphereVolume: (CC3NodeSphericalBoundingVolume*) sphereBV
			  andBoxVolume: (CC3NodeBoxBoundingVolume*) boxBV;

/** Allocates and returns an autoreleased instance containing the specified bounding volumes. */
+(id) boundingVolumeWithSphereVolume: (CC3NodeSphericalBoundingVolume*) sphereBV
						andBoxVolume: (CC3NodeBoxBoundingVolume*) boxBV;

/**
 * Allocates and returns an autoreleased instance containing spherical and box bounding
 * volumes created from the specified sphere and box, respectively.
 *
 * The sphere and box dimensions are specified in the coordinate system of the node.
 * The resulting bounding volume is fixed to the sizes provided, and will not take into
 * consideration the vertices of the mesh. It will, however, transform along with the
 * node, as the node is transformed.
 */
-(id) initFromSphere: (CC3Sphere) sphere andBox: (CC3Box) box;

/** 
 * Initializes this instance containing spherical and box bounding
 * volumes created from the specified sphere and box, respectively. 
 *
 * The sphere and box dimensions are specified in the coordinate system of the node.
 * The resulting bounding volume is fixed to the sizes provided, and will not take into
 * consideration the vertices of the mesh. It will, however, transform along with the
 * node, as the node is transformed.
 */
+(id) boundingVolumeFromSphere: (CC3Sphere) sphere andBox: (CC3Box) box;

/**
 * Initializes this instance containing spherical and box bounding volumes created from
 * the specified box. The spherical bounding volume is created by circumscribing the box.
 */
-(id) initByCircumscribingBox: (CC3Box) box;

/**
 * Allocates and returns an autoreleased instance containing spherical and box bounding
 * volumes created from the specified box. The spherical bounding volume is created by
 * circumscribing the box.
 */
+(id) boundingVolumeCircumscribingBox: (CC3Box) box;

/**@deprecated Use boundingVolume instead. */
+(id) vertexLocationsSphereandBoxBoundingVolume DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3NodeBoundingArea interface

/**
 * A bounding volume that defines a 2D bounding area for a node, and checks that
 * bounding area against a given 2D bounding box, which is typically the bounding
 * box of the CC3Layer. This is useful for, and only applicable to, nodes that draw
 * 2D content as overlays, such as CC3Billboards, when they are drawn as overlays.
 */
@interface CC3NodeBoundingArea : CC3NodeBoundingVolume

/**
 * Returns whether this bounding volume intersects the specfied bounding rectangle.
 *
 * This default implementation always returns YES. Subclasses will override appropriately.
 *
 * This method is invoked automatically by nodes with 2D content, when the node is being
 * drawn as a 2D overlay, to determine whether or not it should be drawn.
 */
-(BOOL) doesIntersectBounds: (CGRect) bounds;

@end


#pragma mark -
#pragma mark CC3NodeInfiniteBoundingVolume

/**
 * A bounding volume that forms a volume of infinite size. When applied to a node,  this volume will
 * always intersect all other bounding volumes, and will always be considered inside the camera's frustum.
 *
 * Although not useful for collision detection, or testing points and rays, this bounding volume
 * ensures that its node will never be clipped by the camera frustum, and will always be drawn.
 *
 * This bounding volume can be used for nodes that do not have an easily encapsulated
 * bounding volume, such as certain particle generators. And it can also be useful during
 * the development of new node types that do not use one of the standard bounding volumes.
 */
@interface CC3NodeInfiniteBoundingVolume : CC3NodeBoundingVolume


#pragma mark Intersection testing

/**
 * Returns whether this bounding volume intersects the specfied other bounding volume.
 *
 * This implementation always returns YES.
 */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume;

/**
 * Returns whether the specified global location intersects (is inside) this bounding volume.
 * 
 * This implementation always returns YES.
 */
-(BOOL) doesIntersectLocation: (CC3Vector) aLocation;

/**
 * Returns whether the specified global-coordinate ray intersects this bounding volume.
 *
 * This implementation always returns YES, unless the shouldIgnoreRayIntersection property
 * is set to YES, in which case this method will always return NO. See the notes of
 * the shouldIgnoreRayIntersection property for more info.
 */
-(BOOL) doesIntersectRay: (CC3Ray) aRay;

/**
 * Returns whether this bounding volume lies completely outside the specified
 * normalized global coordinate plane.
 *
 * This implementation always returns NO.
 */
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane;

/**
 * Returns whether the specified global-coordinate sphere intersects this bounding volume.
 *
 * This implementation always returns YES.
 */
-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns whether a convex hull composed of the specified global planes intersects
 * this bounding volume. The planes may be the face planes of a mesh, or they may
 * be the sides of an oriented bounding box (OBB), or frustum, etc.
 * 
 * This implementation always returns YES.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume;


#pragma mark Drawing bounding volume

/**
 * Indicates that this bounding volume should draw itself over the node.
 *
 * The infinite bounding volume will never be drawn. This property will
 * always return NO, and setting this property will have no effect.
 */
@property(nonatomic, assign) BOOL shouldDraw;

@end


#pragma mark -
#pragma mark CC3NodeNullBoundingVolume

/**
 * A bounding volume that forms a volume of zero size and location. When applied
 * to a node,  this volume will never intersect any other bounding volumes, and
 * will never be considered inside the camera's frustum.
 */
@interface CC3NodeNullBoundingVolume : CC3NodeBoundingVolume


#pragma mark Intersection testing

/**
 * Returns whether this bounding volume intersects the specfied other bounding volume.
 *
 * This implementation always returns NO.
 */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume;

/**
 * Returns whether the specified global location intersects (is inside) this bounding volume.
 * 
 * This implementation always returns NO.
 */
-(BOOL) doesIntersectLocation: (CC3Vector) aLocation;

/**
 * Returns whether the specified global-coordinate ray intersects this bounding volume.
 *
 * This implementation always returns NO.
 *
 * The shouldIgnoreRayIntersection property has no effect on this implementation.
 */
-(BOOL) doesIntersectRay: (CC3Ray) aRay;

/**
 * Returns whether this bounding volume lies completely outside the specified
 * normalized global coordinate plane.
 *
 * This implementation always returns YES.
 */
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane;

/**
 * Returns whether the specified global-coordinate sphere intersects this bounding volume.
 *
 * This implementation always returns NO.
 */
-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume;

/**
 * Returns whether a convex hull composed of the specified global planes intersects
 * this bounding volume. The planes may be the face planes of a mesh, or they may
 * be the sides of an oriented bounding box (OBB), or frustum, etc.
 * 
 * This implementation always returns NO.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume;


#pragma mark Drawing bounding volume

/**
 * Indicates that this bounding volume should draw itself over the node.
 *
 * The null bounding volume will never be drawn. This property will
 * always return NO, and setting this property will have no effect.
 */
@property(nonatomic, assign) BOOL shouldDraw;

@end

