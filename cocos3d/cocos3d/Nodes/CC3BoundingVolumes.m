/*
 * CC3BoundingVolumes.m
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
 * See header file CC3BoundingVolumes.h for full API documentation.
 */

#import "CC3BoundingVolumes.h"
#import "CC3Camera.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3Light.h"
#import "CC3OSExtensions.h"


/**
 * A macro that invokes the logIntersection:with: method if the LOGGING_ENABLED
 * compiler build setting is defined and set to 1.
 *
 * If the compiler build setting is not defined, or is set to 0, this macro is an
 * empty string, and effectively does not invoke the logIntersection:with: method.
 *
 * This macro allows code that is not conditionally compiled with the LOGGING_ENABLED
 * to include invoke the logIntersection:with: method when the conditionally compiled
 * code is available.
 */
#if LOGGING_ENABLED
#	define CC3LogBVIntersection(BV, I); [self logIntersection: (I) with: (BV)];
#else
#	define CC3LogBVIntersection(BV, I);
#endif

#pragma mark -
#pragma mark CC3BoundingVolume

@implementation CC3BoundingVolume

@synthesize shouldIgnoreRayIntersection=_shouldIgnoreRayIntersection;

-(CC3Plane*) planes { return NULL; }

-(GLuint) planeCount { return 0; }

-(CC3Vector*) vertices { return NULL; }

-(GLuint) vertexCount { return 0; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {

		GLuint pCnt = self.planeCount;
		CC3Plane* pArray = self.planes;
		for (int i = 0; i < pCnt; i++) pArray[i] = kCC3PlaneZero;

		GLuint vCnt = self.vertexCount;
		CC3Vector* vArray = self.vertices;
		for (int i = 0; i < vCnt; i++) vArray[i] = kCC3VectorZero;

		_isDirty = YES;
		_shouldIgnoreRayIntersection = NO;
		self.shouldLogIntersections = NO;			// Use setter
		self.shouldLogIntersectionMisses = NO;		// Use setter
	}
	return self;
}

+(id) boundingVolume { return [[[self alloc] init] autorelease]; }

-(void) populateFrom: (CC3BoundingVolume*) another {
	_isDirty = another.isDirty;
	_shouldIgnoreRayIntersection = another.shouldIgnoreRayIntersection;
	self.shouldLogIntersections = another.shouldLogIntersections;			// Use setter
	self.shouldLogIntersectionMisses = another.shouldLogIntersectionMisses;	// Use setter

	GLuint pCnt = self.planeCount;
	CC3Plane* pArray = self.planes;
	CC3Plane* otherPlanes = another.planes;
	for (int i = 0; i < pCnt; i++) pArray[i] = otherPlanes[i];
	
	GLuint vCnt = self.vertexCount;
	CC3Vector* vArray = self.vertices;
	CC3Vector* otherVertices = another.vertices;
	for (int i = 0; i < vCnt; i++) vArray[i] = otherVertices[i];
}

-(id) copyWithZone: (NSZone*) zone {
	CC3BoundingVolume* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description { return [NSString stringWithFormat: @"%@", self.class]; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self.description];
	[self appendPlanesTo: desc];
	[self appendVerticesTo: desc];
	return desc;
}

-(void) appendPlanesTo: (NSMutableString*) desc {
	GLuint pCnt = self.planeCount;
	CC3Plane* pArray = self.planes;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++)
		[desc appendFormat: @"\n\tplane: %@", NSStringFromCC3Plane(pArray[pIdx])];
}

-(void) appendVerticesTo: (NSMutableString*) desc {
	GLuint vCnt = self.vertexCount;
	CC3Vector* vArray = self.vertices;
	for (GLuint vIdx = 0; vIdx < vCnt; vIdx++)
		[desc appendFormat: @"\n\tvertex: %@", NSStringFromCC3Vector(vArray[vIdx])];
}


#pragma mark Updating

-(BOOL) isDirty { return _isDirty; }

-(void) markDirty { _isDirty = YES; }

-(void) updateIfNeeded {
	if (_isDirty) {
		[self buildVolume];
		[self buildPlanes];
		_isDirty = NO;
	}
}

/**
 * Builds the bounding volume.
 *
 * This default template method implementation does nothing. Subclasses will override.
 * 
 * This method is invoked automatically when this bounding volume requires rebuilding.
 */
-(void) buildVolume {}

/** 
 * If this bounding volume is described in terms of a hull of planes,
 * builds those planes.
 *
 * This default template method implementation does nothing. Subclasses will override.
 * 
 * This method is invoked automatically when this bounding volume is rebuilt.
 */
-(void) buildPlanes {}


#pragma mark Intersection testing

/**
 * Double-dispatches to the other bounding volume as a convex hull using
 * using the planes of this bounding volume.
 */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	CC3Assert(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersect:", self);
	BOOL intersects = [aBoundingVolume doesIntersectConvexHullOf: self.planeCount
														  planes: self.planes
															from: self];
	CC3LogBVIntersection(aBoundingVolume, intersects);
	return intersects;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation {
	CC3Assert(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersectLocation:", self);
	GLuint pCnt = self.planeCount;
	CC3Plane* pArray = self.planes;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		if ( CC3VectorIsInFrontOfPlane(aLocation, pArray[pIdx]) ) return NO;
	}
	return YES;
}

/**
 * Returns whether the location where the specified ray punctures the plane at the
 * specified index, is behind all the other planes. This indicates that the puncture
 * location is behind all of the planes, and hence is inside this bounding volume.
 */
-(BOOL) isRay: (CC3Ray) aRay behindAllOtherPlanesAtPunctureOfPlaneAt: (GLuint) planeIndex {
	CC3Plane* pArray = self.planes;
	CC3Vector4 pLoc4 = CC3RayIntersectionWithPlane(aRay, pArray[planeIndex]);

	// If ray is pointed away from, or is parallel to the plane, it won't puncture it.
	if (pLoc4.w < 0.0f || CC3Vector4IsNull(pLoc4)) return NO;

	CC3Vector punctureLoc = pLoc4.v;
	GLuint pCnt = self.planeCount;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		if ( (pIdx != planeIndex) &&
			CC3VectorIsInFrontOfPlane(punctureLoc, pArray[pIdx]) ) return NO;
	}
	return YES;
}

/**
 * Find puncture location of ray on each plane in turn. If any of those puncture locations
 * is behind all of the other planes, then the ray intersects this bounding volume.
 */
-(BOOL) doesIntersectRay: (CC3Ray) aRay {
	if (_shouldIgnoreRayIntersection) return NO;
	CC3Assert(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersectRay:", self);
	GLuint pCnt = self.planeCount;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		if ( [self isRay: aRay behindAllOtherPlanesAtPunctureOfPlaneAt: pIdx] ) {
			LogTrace(@"Ray %@ intersects %@", NSStringFromCC3Ray(aRay), self.fullDescription);
			return YES;
		}
	}
	return NO;
}

-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane {
	return [self areAllVerticesInFrontOf: aPlane];
}

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere {
	return [self doesIntersectSphere: aSphere from: nil];
}

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume {
	CC3Assert(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersectSphere:from:", self);
	GLuint pCnt = self.planeCount;
	CC3Plane* pArray = self.planes;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		GLfloat dist = CC3DistanceFromPlane(aSphere.center, pArray[pIdx]);
		if (dist > aSphere.radius) {
			LogTrace(@"Sphere %@ from %@ is in front of plane %@ and does not intersect %@",
						  NSStringFromCC3Spere(aSphere), otherBoundingVolume,
						  NSStringFromCC3Plane(pArray[pIdx]), self.fullDescription);
			return NO;
		}
	}
	LogTrace(@"Sphere %@ from %@ intersects %@", NSStringFromCC3Spere(aSphere), otherBoundingVolume, self);
	return YES;
}

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes planes: (CC3Plane*) otherPlanes {
	return [self doesIntersectConvexHullOf: numOtherPlanes planes: otherPlanes from: nil];
}

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume {
	
	// This test attempts to reject the intersection in stages, first by testing
	// the vertices of this BV against the specified planes of the other BV, then,
	// if the other BV has been specified, it is tested against the planes of this
	// BV. If neither test rejects the intersection, then we assume that the
	// intersection has occurred.
	
	// Reject if all vertices of this are in front of one of the other BV's planes
	if ( [self areAllVerticesInFrontOfOneOf: numOtherPlanes planes: otherPlanes] ) return NO;
	
	// If not, then if the other BV exists, reject if it is outside this BV's planes.
	if (otherBoundingVolume) {
		return [otherBoundingVolume doesIntersectConvexHullOf: self.planeCount
													   planes: self.planes];
	}
	
	return YES;		// Neither test rejected the intersection, so pass it.
}

/**
 * Utility method that returns whether all of the vertices of this bounding
 * volume are in front of any one of the specified planes. For this method
 * to return YES, all vertices must be in front of the same plane.
 *
 * The term <em>in front of</em> means the side of the plane from which
 * the plane normal points. Specifically, this method will return YES if
 * all the specified vertices are on the side of the plane from which the
 * normal points, for any one of the specified planes.
 */
-(BOOL) areAllVerticesInFrontOfOneOf: (GLuint) numPlanes planes: (CC3Plane*) planes {
	for (GLuint pIdx = 0; pIdx < numPlanes; pIdx++) {
		if( [self areAllVerticesInFrontOf: planes[pIdx]] ) return YES;
	}
	return NO;
}

/**
 * Utility method that returns whether all of the vertices of this
 * bounding volume are in front of the specified plane.
 *
 * The term <em>in front of</em> means the side of the plane from which
 * the normal points. Specifically, this method will return YES if all
 * vertices are on the side of the plane from which the normal points.
 */
-(BOOL) areAllVerticesInFrontOf: (CC3Plane) plane {
	GLuint vCnt = self.vertexCount;
	if (vCnt == 0) return NO;

	CC3Vector* vArray = self.vertices;
	for (int vIdx = 0; vIdx < vCnt; vIdx++) {
		LogTrace(@"Location %@ from %@ is %@ plane %@",
					  NSStringFromCC3Vector(vArray[vIdx]), self,
					  ((CC3VectorIsInFrontOfPlane(vArray[vIdx], plane)) ? @"in front of" : @"behind"),
					  NSStringFromCC3Plane(plane));
		if ( !CC3VectorIsInFrontOfPlane(vArray[vIdx], plane) ) return NO;
	}
	LogTrace(@"%@ all %i vertices are in front of plane %@",
				  self, vCnt, NSStringFromCC3Plane(plane));
	return YES;
}

/**
 * Utility method to build a plane from a mix of mesh data, including a normal,
 * a face, and an axis of orientation.
 *
 * The combination of data allows a plane to be derived from vertices that are
 * arranged in a box, a plane, a line, or simply a single location.
 *
 * First, if the specified normal is not zero, it is used in conjunction with
 * the one of the face vertices to create the plane. If the normal is zero,
 * it's an indication that the mesh is planar.
 *
 * Next, an attempt is made to build the plane from the face. If two of the
 * vertices of the face are co-linear, it's an indication that the mesh
 * is actually just a line.
 *
 * The orientationAxis is used to orient the plane on which the line exists.
 * Typically, this orientationAxis is one of the three cardinal axes.
 *
 * Finally, if the mesh is just a single location, use the orientationAxis
 * as the normal of the plane, and locate it so that it intersects the location.
 */
-(CC3Plane) buildPlaneFromNormal: (CC3Vector) normal
						 andFace: (CC3Face) face
			  andOrientationAxis: (CC3Vector) orientationAxis {
	CC3Plane p;
	
	// First, assume the mesh is a box. Try making plane from the normal and one location.
	// Will fail if normal is zero.
	p = CC3PlaneFromNormalAndLocation(normal, face.vertices[0]);
	if ( !CC3PlaneIsZero(p) ) return p;
	
	// The mesh is no more than a plane.
	// Next, try making plane from the three locations of the face.
	// Will fail if two are co-linear,
	p = CC3FacePlane(face);
	if ( !CC3PlaneIsZero(p) ) return p;
	
	// The mesh is no more than a line.
	// Next, try making the plane from the line, using the orientationAxis to provide a
	// third vertex by adding the orientation axis to one of the vertices on the line.
	CC3Vector v3 = CC3VectorAdd(face.vertices[0], orientationAxis);
	p = CC3PlaneFromLocations(face.vertices[1], face.vertices[0], v3);
	if ( !CC3PlaneIsZero(p) ) return p;
	
	// Try the other possible line.
	p = CC3PlaneFromLocations(face.vertices[2], face.vertices[0], v3);
	if ( !CC3PlaneIsZero(p) ) return p;
	
	// The mesh is just a single location.
	// Finally, use the orienationAxis as the plane's normal.
	return CC3PlaneFromNormalAndLocation(orientationAxis, face.vertices[0]);
}

-(CC3Vector) globalLocationOfGlobalRayIntesection: (CC3Ray) aRay {
	CC3Assert(NO, @"%@ does not yet implement globalLocationOfGlobalRayIntesection:. An implementation needs to be added.", [self class]);
	return kCC3VectorNull;
}


#pragma mark Intersection logging

-(BOOL) shouldLogIntersections { return _shouldLogIntersections; }

-(void) setShouldLogIntersections: (BOOL) shouldLog { _shouldLogIntersections = shouldLog; }

-(BOOL) shouldLogIntersectionMisses { return _shouldLogIntersectionMisses; }

-(void) setShouldLogIntersectionMisses: (BOOL) shouldLog { _shouldLogIntersectionMisses = shouldLog; }

/**
 * If the shouldLogIntersections or shouldLogIntersectionMisses property is set to YES
 * in both this bounding volume and the specified bounding volume, a message is logged.
 *
 * You can use the CC3LogBVIntersection macro function to invoke this method in a way that
 * will be removed from the code when logging is disabled.
 */
-(void) logIntersection: (BOOL) intersects with: (CC3BoundingVolume*) aBoundingVolume {
	LogInfoIf(intersects && self.shouldLogIntersections && aBoundingVolume.shouldLogIntersections
			  , @"%@ intersects %@", self.fullDescription, aBoundingVolume.fullDescription);

	LogInfoIf(!intersects && self.shouldLogIntersectionMisses && aBoundingVolume.shouldLogIntersectionMisses,
			  @"%@ does not intersect %@", self.fullDescription, aBoundingVolume.fullDescription);
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingVolume implementation

@implementation CC3NodeBoundingVolume

@synthesize shouldMaximize=_shouldMaximize;

-(void) dealloc {
	_node = nil;		// weak reference
	[super dealloc];
}

-(CC3Node*) node { return _node; }

-(void) setNode: (CC3Node*) node {
	CC3Assert( !_node || !node, @"%@ may have only one primary node. If you want to change the"
			  @" primary node, first set this property to nil, then set the new node.", self);
	_node = node;			// weak reference

	// Update whether the BV should be built from the mesh
	self.shouldBuildFromMesh = self.shouldBuildFromMesh;
}

-(BOOL) shouldBuildFromMesh { return _shouldBuildFromMesh; }

-(void) setShouldBuildFromMesh: (BOOL) shouldBuildFromMesh {
	_shouldBuildFromMesh = shouldBuildFromMesh && ( (_node == nil) || [_node isKindOfClass: [CC3MeshNode class]]);
	if (_shouldBuildFromMesh) [self markDirty];
}

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return &_globalCenterOfGeometry;
}

-(GLuint) vertexCount { return 1; }

-(CC3Vector) centerOfGeometry {
	[self updateIfNeeded];
	return _centerOfGeometry;
}

-(CC3Vector) globalCenterOfGeometry {
	[self updateIfNeeded];
	return _globalCenterOfGeometry;
}

-(void) setCenterOfGeometry: (CC3Vector) aLocation {
	_centerOfGeometry = aLocation;
	_isDirty = NO;
	_shouldBuildFromMesh = NO;
	[self markTransformDirty];
}

/**
 * Returns the vertex locations of the CC3MeshNode holding this bounding volume.
 * If the node is not a CC3MeshNode, an assertion error is raised.
 */
-(CC3VertexLocations*) vertexLocations {
	CC3Assert([_node isKindOfClass: [CC3MeshNode class]], @"%@ can only be assigned to a CC3MeshNode instance.", self.class);
	return ((CC3MeshNode*)_node).mesh.vertexLocations;
}

-(id) init {
	if ( (self = [super init]) ) {
		_node = nil;
		_shouldBuildFromMesh = YES;		// Assume YES. Will be set to no if not assigned to mesh node
		_centerOfGeometry = kCC3VectorZero;
		_globalCenterOfGeometry = kCC3VectorZero;
		_shouldMaximize = NO;
		_isTransformDirty = YES;
		_shouldDraw = NO;
	}
	return self;
}

-(void) populateFrom: (CC3NodeBoundingVolume*) another {
	[super populateFrom: another];

	// Node property is not copied and must be set externally,
	// because a node can only have one bounding volume.

	_shouldBuildFromMesh = another.shouldBuildFromMesh;
	_centerOfGeometry = another.centerOfGeometry;
	_globalCenterOfGeometry = another.globalCenterOfGeometry;
	_shouldMaximize = another.shouldMaximize;
	_isTransformDirty = another.isTransformDirty;
	_shouldDraw = another.shouldDraw;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for %@", [super description], _node];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ for %@ centered at: %@ (globally: %@)",
			[super fullDescription], _node, NSStringFromCC3Vector(self.centerOfGeometry),
			NSStringFromCC3Vector(self.globalCenterOfGeometry) ];
}


#pragma mark Updating

-(void) scaleBy: (GLfloat) scale { _shouldBuildFromMesh = NO; }

-(BOOL) isTransformDirty { return _isTransformDirty; }

-(void) markTransformDirty { _isTransformDirty = YES; }

/**
 * Builds the volume if needed, then transforms it with the node's globalTransformMatrix.
 * The transformation will occur if either the transform is marked as dirty, or the
 * bounding volume is being rebuilt.
 */
-(void) updateIfNeeded {
	if (_isDirty) {
		[self buildVolume];
		_isDirty = NO;
		[self updateDisplayNode];
		[self markTransformDirty];
	}

	if (_node && _isTransformDirty) {
		[self transformVolume];
		[self buildPlanes];
		_isTransformDirty = NO;
	}
}

/**
 * Template method to transform this bounding volume to cover the node. Typically,
 * this involves moving the bounding volume to where the node is located, scaling it
 * appropriately, and possibly rotating the bounding volume to track the node's rotation.
 *
 * This default implementation sets the globalCenterOfGeometry from the local value.
 * Subclasses will override appropriately, but should invoke this superclass implementation
 * so that the global center of geometry will always be calculated.
 */
-(void) transformVolume {
	_globalCenterOfGeometry = CC3VectorsAreEqual(_centerOfGeometry, kCC3VectorZero)
								? _node.globalLocation
								: [_node.globalTransformMatrix transformLocation: _centerOfGeometry];
}


#pragma mark Intersection testing

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	CC3Assert(NO, @"%@ does not yet implement locationOfRayIntesection:. An implementation needs to be added.", [self class]);
	return kCC3VectorNull;
}

-(CC3Vector) globalLocationOfGlobalRayIntesection: (CC3Ray) aRay {
	if ( !_node || _shouldIgnoreRayIntersection ) return kCC3VectorNull;

	CC3Ray localRay = [_node.globalTransformMatrixInverted transformRay: aRay];
	CC3Vector puncture = [self locationOfRayIntesection: localRay];
	return CC3VectorIsNull(puncture)
				? puncture
				: [_node.globalTransformMatrix transformLocation: puncture];
}

// Deprecated and replaced by doesIntersect:
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum { return [self doesIntersect: aFrustum]; }


#pragma mark Drawing bounding volume

/**
 * Template method that returns the suffix used to name the node used to display
 * this bounding volume. Different bounding volume types will use different suffixes.
 */
-(NSString*) displayNodeNameSuffix {
	CC3Assert(NO, @"%@ has no unique display node suffix. You must override method displayNodeNameSuffix:", self);
	return @"BV";
}

/** The name to use when creating or retrieving the wireframe child node of this node. */
-(NSString*) displayNodeName {
	return [NSString stringWithFormat: @"%@-%@", _node.name, self.displayNodeNameSuffix];
}

/**
 * Retrieves the display node that is displaying this bounding volume from this
 * bounding volume's node, and returns it, or returns nil if this bounding volume
 * is not currently being displayed.
 */
-(CC3BoundingVolumeDisplayNode*) displayNode {
	return (CC3BoundingVolumeDisplayNode*)[_node getNodeNamed: [self displayNodeName]];
}

/** The color used to display the bounding volume. */
-(ccColor3B) displayNodeColor { return ccWHITE; }

/** The opacity at which to display the bounding volume. */
-(GLubyte) displayNodeOpacity { return 64; }	// 25% opacity

/**
 * Populates the display node to create the appropriate shape.
 * This abstract implementation does nothing. Subclasses will customize.
 */
-(void) populateDisplayNode {}

/**
 * If this bounding volume is being displayed, update the display mesh node.
 *
 * This default implementation repopulates the mesh node from scratch, which
 * may be expensive. Subclasses may override to something more efficient.
 */
-(void) updateDisplayNode { if (_shouldDraw) [self populateDisplayNode]; }

-(BOOL) shouldDraw { return _shouldDraw; }

-(void) setShouldDraw: (BOOL) shdDraw {
	_shouldDraw = shdDraw;
	
	// Fetch the display node.
	CC3BoundingVolumeDisplayNode* dn = self.displayNode;
	
	// If the display node exists, but should not, remove it
	if (dn && !_shouldDraw) [dn remove];
	
	// If there is no display node, but there should be, add it by creating a
	// CC3BoundingVolumeDisplayNode of the correct shape from the properties of
	// this bounding volume, and add it as a child of this bounding volume's node.
	if(!dn && _shouldDraw) {
		dn = [CC3BoundingVolumeDisplayNode nodeWithName: [self displayNodeName]];
		dn.material = [CC3Material shiny];
		dn.color = self.displayNodeColor;
		dn.opacity = self.displayNodeOpacity;

		// Set drawing order and decal properties to minimize Z-fighting between the
		// bounding volume display and the node which the bounding volume surrounds.
		dn.zOrder = _node.zOrder - 1;
		dn.decalOffsetFactor = -5.0f;
		dn.decalOffsetUnits = -5.0f;

		dn.shouldDisableDepthMask = YES;	// Don't update depth mask, to allow later...
											// ..overlapping transparencies to all be drawn
		[_node addChild: dn];
		[self populateDisplayNode];			// Populate with the right shape
	}
}

@end


#pragma mark -
#pragma mark CC3NodeCenterOfGeometryBoundingVolume implementation

@implementation CC3NodeCenterOfGeometryBoundingVolume

-(void) buildVolume {
	if ( !(_node && _shouldBuildFromMesh) ) return;
	
	_centerOfGeometry = self.vertexLocations.centerOfGeometry;
}

#pragma mark Intersection testing

/** Double-dispatches to the other bounding volume as a single point location. */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	BOOL intersects = [aBoundingVolume doesIntersectLocation: self.globalCenterOfGeometry];
	CC3LogBVIntersection(aBoundingVolume, intersects);
	return intersects;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation {
	return CC3VectorsAreEqual(self.globalCenterOfGeometry, aLocation);
}

-(BOOL) doesIntersectRay: (CC3Ray) aRay {
	if (_shouldIgnoreRayIntersection) return NO;
	return CC3IsLocationOnRay(self.globalCenterOfGeometry, aRay);
}

// Included to satisfy compiler because selector appears in interface for documentation purposes
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane { return [super isInFrontOfPlane: aPlane]; }

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume {
	return CC3IsLocationWithinSphere(self.globalCenterOfGeometry, aSphere);
}

/**
 * Determines whether the globalCenterOfGeometry is outside any of the planes,
 * returns NO if that is the case.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume {
	CC3Vector gcog = self.globalCenterOfGeometry;	// Retrieve as property to force update
	for (GLuint pIdx = 0; pIdx < numOtherPlanes; pIdx++) {
		if ( CC3VectorIsInFrontOfPlane(gcog, otherPlanes[pIdx]) ) return NO;
	}
	return YES;
}

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (_shouldIgnoreRayIntersection) return kCC3VectorNull;
	CC3Vector cog = self.centerOfGeometry;
	return ( CC3IsLocationOnRay(cog, localRay) ) ? cog : kCC3VectorNull;
}


#pragma mark Drawing bounding volume

-(NSString*) displayNodeNameSuffix { return @"BV-CoG"; }

-(BOOL) shouldDraw { return NO; }			// No shape to draw

-(void) setShouldDraw: (BOOL) shdDraw {}	// No shape to draw

@end


#pragma mark -
#pragma mark CC3NodeSphericalBoundingVolume implementation

@implementation CC3NodeSphericalBoundingVolume

/**
 * If building from the mesh, finds the sphere that currently encompasses all the vertices.
 * Then, if the boundary should be maximized, finds the sphere that is the union of that sphere,
 * and the sphere that previously encompassed all the vertices, otherwise, uses the new sphere.
 */
-(void) buildVolume {
	if ( !(_node && _shouldBuildFromMesh) ) return;
	
	CC3VertexLocations* vtxLocs = self.vertexLocations;
	CC3Vector newCOG = vtxLocs.centerOfGeometry;
	GLfloat newRadius = vtxLocs.radius + self.node.boundingVolumePadding;
	
	if (_shouldMaximize) {
		CC3Sphere unionSphere = CC3SphereUnion(CC3SphereMake(newCOG, newRadius),
											   CC3SphereMake(_centerOfGeometry, _radius));
		_centerOfGeometry = unionSphere.center;
		_radius = unionSphere.radius;
	} else {
		_centerOfGeometry = newCOG;
		_radius = newRadius;
	}
}

-(GLfloat) radius {
	[self updateIfNeeded];
	return _radius;
}

-(void) setRadius: (GLfloat) aRadius {
	_radius = aRadius;
	_isDirty = NO;
	_shouldBuildFromMesh = NO;
	[self markTransformDirty];
}

-(GLfloat) globalRadius {
	[self updateIfNeeded];
	return _globalRadius;
}

-(void) scaleBy: (GLfloat) scale {
	[super scaleBy: scale];
	self.radius = self.radius * scale;
}

-(CC3Sphere) sphere { return CC3SphereMake(self.centerOfGeometry, self.radius); }

-(CC3Sphere) globalSphere { return CC3SphereMake(self.globalCenterOfGeometry, self.globalRadius); }

-(void) populateFrom: (CC3NodeSphericalBoundingVolume*) another {
	[super populateFrom: another];

	_radius = another.radius;
	_globalRadius = another.globalRadius;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ centered at: %@ (globally: %@) with radius: %.3f (globally: %.3f)",
			self.description, NSStringFromCC3Vector(self.centerOfGeometry),
			NSStringFromCC3Vector(self.globalCenterOfGeometry), self.radius, self.globalRadius];
}


#pragma mark Updating

-(void) transformVolume {
	[super transformVolume];

	CC3_PUSH_NOSHADOW
	// Expand the radius by the global scale of the node. In case the node's global scale is not
	// uniform, use the largest of the three scale axes to ensure the scaled object is contained
	// within the sphere, and ensure that the radius is positive even if scale is negative.
	CC3Vector ngs = _node.globalScale;
	_globalRadius = _radius * ABS(MAX(MAX(ngs.x, ngs.y), ngs.z));
	CC3_POP_NOSHADOW
}


#pragma mark Intersection testing

/** Double-dispatches to the other bounding volume as a sphere. */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	BOOL intersects = [aBoundingVolume doesIntersectSphere: self.globalSphere from: self];
	CC3LogBVIntersection(aBoundingVolume, intersects);
	return intersects;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation {
	return CC3IsLocationWithinSphere(aLocation, self.globalSphere);
}

-(BOOL) doesIntersectRay: (CC3Ray) aRay {
	if (_shouldIgnoreRayIntersection) return NO;
	return CC3DoesRayIntersectSphere(aRay, self.globalSphere);
}

/**
 * Determines the distance from the globalCenterOfGeometry to the plane
 * (in terms of the normal of the plane), and return YES if that distance
 * is greater than the globalRadius, indicating the sphere is in front
 * of that plane.
 */
-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane {
	GLfloat dist = CC3DistanceFromPlane(self.globalCenterOfGeometry, aPlane);
	return (dist > self.globalRadius);
}

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume {
	return CC3DoesSphereIntersectSphere(aSphere, self.globalSphere);
}

/**
 * Determines whether the globalCenterOfGeometry is in front of any of the
 * specified planes, and if so, returns NO.
 */
-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume {
	for (GLuint pIdx = 0; pIdx < numOtherPlanes; pIdx++) {
		if ( [self isInFrontOfPlane: otherPlanes[pIdx]] ) return NO;
	}
	return YES;
}

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (_shouldIgnoreRayIntersection) return kCC3VectorNull;
	return CC3RayIntersectionWithSphere(localRay, self.sphere);
}


#pragma mark Drawing bounding volume

-(NSString*) displayNodeNameSuffix { return @"BV-Sphere"; }

-(ccColor3B) displayNodeColor { return ccMAGENTA; }		// Magenta

-(GLubyte) displayNodeOpacity { return 85; }			// Magenta is faint...increase to 33% opacity

-(void) populateDisplayNode {
	CC3BoundingVolumeDisplayNode* dn = self.displayNode;
	[dn populateAsSphereWithRadius: self.radius andTessellation: CC3TessellationMake(24, 24)];
	[dn doNotBufferVertexContent];
	dn.location = self.centerOfGeometry;
}


#pragma mark Allocation and initialization

// Don't delegate to initFromSphere: because this intializer must leave _shouldBuildFromMesh alone
-(id) init {
	if ( (self = [super init]) ) {
		_radius = 0.0f;
	}
	return self;
}

-(id) initFromSphere: (CC3Sphere) sphere {
	if ( (self = [super init]) ) {
		_centerOfGeometry = sphere.center;
		_radius = sphere.radius;
		_shouldBuildFromMesh = NO;		// We want a fixed volume
	}
	return self;
}

+(id) boundingVolumeFromSphere: (CC3Sphere) sphere {
	return [[[self alloc] initFromSphere: sphere] autorelease];
}

@end


#pragma mark -
#pragma mark CC3NodeBoxBoundingVolume implementation

@implementation CC3NodeBoxBoundingVolume

/**
 * If building from the mesh, finds the bounding box that currently encompasses all the vertices.
 * Then, if the boundary should be maximized, finds the bounding box that is the union of that
 * bounding box, and the bounding box that previously encompassed all the vertices, otherwise,
 * uses the new bounding box.
 */
-(void) buildVolume {
	if ( !(_node && _shouldBuildFromMesh) ) return;

	CC3Box newBB = ((CC3MeshNode*)self.node).localContentBoundingBox;	// Includes possible padding
	_boundingBox = _shouldMaximize ? CC3BoxUnion(newBB, _boundingBox) : newBB;
	_centerOfGeometry = CC3BoxCenter(_boundingBox);
}

-(CC3Box) boundingBox {
	[self updateIfNeeded];
	return _boundingBox;
}

-(void) setBoundingBox: (CC3Box) aBoundingBox {
	_boundingBox = aBoundingBox;
	_isDirty = NO;
	_shouldBuildFromMesh = NO;
	[self markTransformDirty];
}

-(void) scaleBy: (GLfloat) scale {
	[super scaleBy: scale];
	self.boundingBox = CC3BoxScaleUniform(self.boundingBox, scale);
}

-(CC3Plane*) planes {
	[self updateIfNeeded];
	return _planes;
}

-(GLuint) planeCount { return 6; }

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return _vertices;
}

-(GLuint) vertexCount { return 8; }

// Deprecated
-(CC3Vector*) globalBoundingBoxVertices { return self.vertices; }

-(void) populateFrom: (CC3NodeBoxBoundingVolume*) another {
	[super populateFrom: another];

	_boundingBox = another.boundingBox;
}

-(void) transformVolume {
	[super transformVolume];

	CC3Matrix* tMtx = _node.globalTransformMatrix;

	// Get the corners of the local bounding box
	CC3Vector bbMin = _boundingBox.minimum;
	CC3Vector bbMax = _boundingBox.maximum;
	
	// Construct all 8 corner vertices of the local bounding box and transform each to global coordinates
	_vertices[0] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMin.z)];
	_vertices[1] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMax.z)];
	_vertices[2] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMin.z)];
	_vertices[3] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMax.z)];
	_vertices[4] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMin.z)];
	_vertices[5] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMax.z)];
	_vertices[6] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMin.z)];
	_vertices[7] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMax.z)];
}

/**
 * Constructs the six box face planes from normals and vertices.
 * The plane normals are the transformed face normals of the original box.
 * The vertices are the transformed min-max corners of the box.
 */
-(void) buildPlanes {
	CC3Vector normal;
	CC3Matrix* tMtx = _node.globalTransformMatrix;
	CC3Vector bbMin = _vertices[0];
	CC3Vector bbMax = _vertices[7];
	
	// Front plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitZPositive]);
	_planes[0] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Back plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitZNegative]);
	_planes[1] = CC3PlaneFromNormalAndLocation(normal, bbMin);
	
	// Right plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitXPositive]);
	_planes[2] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Left plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitXNegative]);
	_planes[3] = CC3PlaneFromNormalAndLocation(normal, bbMin);
	
	// Top plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitYPositive]);
	_planes[4] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Bottom plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitYNegative]);
	_planes[5] = CC3PlaneFromNormalAndLocation(normal, bbMin);
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" with bounding box: %@", NSStringFromCC3Box(self.boundingBox)];
	[self appendPlanesTo: desc];
	[self appendVerticesTo: desc];
	return desc;
}


#pragma mark Intersection testing

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (_shouldIgnoreRayIntersection) return kCC3VectorNull;
	return CC3RayIntersectionWithBox(localRay, self.boundingBox);
}


#pragma mark Drawing bounding volume

-(NSString*) displayNodeNameSuffix { return @"BV-Box"; }

-(ccColor3B) displayNodeColor { return ccc3(0,255,255); }	// Cyan

-(GLubyte) displayNodeOpacity { return 64; }				// Cyan is heavy...reduce to 25% opacity

-(void) populateDisplayNode {
	CC3BoundingVolumeDisplayNode* dn = self.displayNode;
	[dn populateAsSolidBox: self.boundingBox];
	[dn doNotBufferVertexContent];
}


#pragma mark Allocation and initialization

// Don't delegate to initFromBox: because this intializer must leave _shouldBuildFromMesh alone
-(id) init {
	if ( (self = [super init]) ) {
		_boundingBox = kCC3BoxZero;
	}
	return self;
}

-(id) initFromBox: (CC3Box) box {
	if ( (self = [super init]) ) {
		_centerOfGeometry = CC3BoxCenter(box);
		_boundingBox = box;
		_shouldBuildFromMesh = NO;		// We want a fixed volume
	}
	return self;
}

+(id) boundingVolumeFromBox: (CC3Box) box {
	return [[[self alloc] initFromBox: box] autorelease]; }

@end

// Deprecated class
@implementation CC3NodeBoundingBoxVolume
@end


#pragma mark -
#pragma mark CC3NodeTighteningBoundingVolumeSequence implementation

@implementation CC3NodeTighteningBoundingVolumeSequence

@synthesize boundingVolumes=_boundingVolumes;

-(void) dealloc {
	[_boundingVolumes release];
	[super dealloc];
}

-(void) setShouldMaximize: (BOOL) shouldMax {
	_shouldMaximize = shouldMax;
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) bv.shouldMaximize = shouldMax;
}

-(void) setNode:(CC3Node*) aNode {
	[super setNode: aNode];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) bv.node = aNode;
}

/** Overridden to keep the COG consistent for all BV's.  */
-(void) setCenterOfGeometry: (CC3Vector) aLocation {
	[super setCenterOfGeometry: aLocation];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) bv.centerOfGeometry = aLocation;
}

-(void) scaleBy: (GLfloat) scale {
	[super scaleBy: scale];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) [bv scaleBy: scale];
}

-(id) init {
	if ( (self = [super init]) ) {
		_boundingVolumes = [NSMutableArray new];	// retained
	}
	return self;
}

-(void) populateFrom: (CC3NodeTighteningBoundingVolumeSequence*) another {
	[super populateFrom: another];
	for(CC3NodeBoundingVolume* bv in another.boundingVolumes)
		[_boundingVolumes addObject: [bv autoreleasedCopy]];		// retained through collection
}

-(void) addBoundingVolume: (CC3NodeBoundingVolume*) aBoundingVolume {
	[_boundingVolumes addObject: aBoundingVolume];
	aBoundingVolume.node = _node;
}

-(void) markDirty {
	[super markDirty];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) [bv markDirty];
}

-(void) markTransformDirty {
	[super markTransformDirty];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) [bv markTransformDirty];
}

/** Builds each contained bounding volume, if needed, and sets the local centerOfGeometry from the last one. */
-(void) buildVolume {
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) {
		[bv updateIfNeeded];
		_centerOfGeometry = bv.centerOfGeometry;
	}
}

-(void) transformVolume {
	[super transformVolume];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) [bv transformVolume];
}

-(NSString*) description {
	if (_boundingVolumes.count == 0)
		return [NSString stringWithFormat: @"%@ containing nothing", [self class]];

	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ containing:", [self class]];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) [desc appendFormat: @"\n\t%@", bv];
	return desc;
}

-(NSString*) fullDescription {
	if (_boundingVolumes.count == 0) return self.description;
	
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ containing:", [self class]];
	for (CC3NodeBoundingVolume* bv in _boundingVolumes)
		[desc appendFormat: @"\n\t%@", bv.fullDescription];
	return desc;
}


#pragma mark Intersection testing

-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	BOOL intersects = YES;
	
	for (CC3NodeBoundingVolume* bv in _boundingVolumes)
		intersects = intersects && [bv doesIntersect: aBoundingVolume];

	CC3LogBVIntersection(aBoundingVolume, intersects);
	return intersects;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation {
	for (CC3NodeBoundingVolume* bv in _boundingVolumes)
		if( ![bv doesIntersectLocation: aLocation] ) return NO;
	return YES;
}

-(BOOL) doesIntersectRay: (CC3Ray) aRay {
	if (_shouldIgnoreRayIntersection) return NO;
	for (CC3NodeBoundingVolume* bv in _boundingVolumes)
		if( ![bv doesIntersectRay: aRay] ) return NO;
	return YES;
}

-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane {
	for (CC3NodeBoundingVolume* bv in _boundingVolumes)
		if( [bv isInFrontOfPlane: aPlane] ) return YES;
	return NO;
}

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere from: (CC3BoundingVolume*) otherBoundingVolume {
	for (CC3NodeBoundingVolume* bv in _boundingVolumes)
		if( ![bv doesIntersectSphere: aSphere from: otherBoundingVolume] ) return NO;
	return YES;
}

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume {
	for (CC3NodeBoundingVolume* bv in _boundingVolumes)
		if( ![bv doesIntersectConvexHullOf: numOtherPlanes
									planes: otherPlanes
									  from: otherBoundingVolume] ) return NO;
	return YES;
}

/** Returns the location of the intersection on the tightest child BV. */
-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (_shouldIgnoreRayIntersection) return kCC3VectorNull;
	CC3NodeBoundingVolume* bv = _boundingVolumes.lastObject;
	return bv ? [bv locationOfRayIntesection: localRay] : kCC3VectorNull;
}


#pragma mark Drawing bounding volume

-(void) setShouldDraw: (BOOL) shouldDraw {
	for (CC3NodeBoundingVolume* bv in _boundingVolumes) bv.shouldDraw = shouldDraw;
}

@end


#pragma mark -
#pragma mark CC3NodeSphereThenBoxBoundingVolume interface

@implementation CC3NodeSphereThenBoxBoundingVolume

@synthesize sphericalBoundingVolume=_sphericalBoundingVolume;
@synthesize boxBoundingVolume=_boxBoundingVolume;

-(void) dealloc {
	[_sphericalBoundingVolume release];
	[_boxBoundingVolume release];
	[super dealloc];
}

-(void) setShouldMaximize: (BOOL) shouldMax {
	[super setShouldMaximize: shouldMax];
	[_sphericalBoundingVolume setShouldMaximize: shouldMax];
	[_boxBoundingVolume setShouldMaximize: shouldMax];
}

-(void) setNode:(CC3Node*) aNode {
	[super setNode: aNode];
	[_sphericalBoundingVolume setNode: aNode];
	[_boxBoundingVolume setNode: aNode];
}

/** Overridden to keep the COG consistent for all BV's.  */
-(void) setCenterOfGeometry: (CC3Vector) aLocation {
	[super setCenterOfGeometry: aLocation];
	[_sphericalBoundingVolume setCenterOfGeometry: aLocation];
	[_boxBoundingVolume setCenterOfGeometry: aLocation];
}

-(void) scaleBy: (GLfloat) scale {
	[super scaleBy: scale];
	[_sphericalBoundingVolume scaleBy: scale];
	[_boxBoundingVolume scaleBy: scale];
}

-(void) populateFrom: (CC3NodeSphereThenBoxBoundingVolume*) another {
	[super populateFrom: another];
	
	[_sphericalBoundingVolume release];
	_sphericalBoundingVolume = [another.sphericalBoundingVolume copy];	// retained

	[_boxBoundingVolume release];
	_boxBoundingVolume = [another.boxBoundingVolume copy];				// retained
}

-(void) markDirty {
	[super markDirty];
	[_sphericalBoundingVolume markDirty];
	[_boxBoundingVolume markDirty];
}

-(void) markTransformDirty {
	[super markTransformDirty];
	[_sphericalBoundingVolume markTransformDirty];
	[_boxBoundingVolume markTransformDirty];
}

/** Builds each contained bounding volume, if needed, and sets the local centerOfGeometry from the box. */
-(void) buildVolume {
	[super buildVolume];
	[_sphericalBoundingVolume updateIfNeeded];
	[_boxBoundingVolume updateIfNeeded];
	_centerOfGeometry = (_boxBoundingVolume
						 ? _boxBoundingVolume.centerOfGeometry
						 : _sphericalBoundingVolume.centerOfGeometry);
}

-(void) transformVolume {
	[super transformVolume];
	[_sphericalBoundingVolume transformVolume];
	[_boxBoundingVolume transformVolume];
}


#pragma mark Intersection testing

-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	BOOL intersects = YES;

	if (_sphericalBoundingVolume)
		intersects = intersects && [_sphericalBoundingVolume doesIntersect: aBoundingVolume];

	if (_boxBoundingVolume)
		intersects = intersects && [_boxBoundingVolume doesIntersect: aBoundingVolume];
	
	CC3LogBVIntersection(aBoundingVolume, intersects);
	return intersects;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation {
	return ([_sphericalBoundingVolume doesIntersectLocation: aLocation] &&
			[_boxBoundingVolume doesIntersectLocation: aLocation]);
}

-(BOOL) doesIntersectRay: (CC3Ray) aRay {
	if (_shouldIgnoreRayIntersection) return NO;

	return ([_sphericalBoundingVolume doesIntersectRay: aRay] &&
			[_boxBoundingVolume doesIntersectRay: aRay]);
}

-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane {
	return ([_sphericalBoundingVolume isInFrontOfPlane: aPlane] ||
			[_boxBoundingVolume isInFrontOfPlane: aPlane]);
}

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere from: (CC3BoundingVolume*) otherBoundingVolume {
	return ([_sphericalBoundingVolume doesIntersectSphere: aSphere from: otherBoundingVolume] &&
			[_boxBoundingVolume doesIntersectSphere: aSphere from: otherBoundingVolume]);
}

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume {
	return ([_sphericalBoundingVolume doesIntersectConvexHullOf: numOtherPlanes
														 planes: otherPlanes
														   from: otherBoundingVolume] &&
			[_boxBoundingVolume doesIntersectConvexHullOf: numOtherPlanes
												   planes: otherPlanes
													 from: otherBoundingVolume]);
}

/** Returns the location of the intersection on the tightest BV. */
-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (_shouldIgnoreRayIntersection) return kCC3VectorNull;

	CC3NodeBoundingVolume* bv = _boxBoundingVolume ? _boxBoundingVolume : _sphericalBoundingVolume;
	return bv ? [bv locationOfRayIntesection: localRay] : kCC3VectorNull;
}


#pragma mark Drawing bounding volume

-(void) setShouldDraw: (BOOL) shouldDraw {
	[_sphericalBoundingVolume setShouldDraw: shouldDraw];
	[_boxBoundingVolume setShouldDraw: shouldDraw];
}


#pragma mark Allocation and initialization

-(id) init {
	return [self initWithSphereVolume: [CC3NodeSphericalBoundingVolume boundingVolume]
						 andBoxVolume: [CC3NodeBoxBoundingVolume boundingVolume]];
}

+(id) boundingVolume { return [[[self alloc] init] autorelease]; }

-(id) initWithSphereVolume: (CC3NodeSphericalBoundingVolume*) sphereBV
			  andBoxVolume: (CC3NodeBoxBoundingVolume*) boxBV {
	if ( (self = [super init]) ) {
		_sphericalBoundingVolume = [sphereBV retain];
		_boxBoundingVolume = [boxBV retain];
	}
	return self;
}

+(id) boundingVolumeWithSphereVolume: (CC3NodeSphericalBoundingVolume*) sphereBV
						andBoxVolume: (CC3NodeBoxBoundingVolume*) boxBV {
	return [[[self alloc] initWithSphereVolume: sphereBV andBoxVolume: boxBV] autorelease];
}

-(id) initFromSphere: (CC3Sphere) sphere andBox: (CC3Box) box {
	return [self initWithSphereVolume: [CC3NodeSphericalBoundingVolume boundingVolumeFromSphere: sphere]
						 andBoxVolume: [CC3NodeBoxBoundingVolume boundingVolumeFromBox: box]];
}

+(id) boundingVolumeFromSphere: (CC3Sphere) sphere andBox: (CC3Box) box {
	return [[[self alloc] initFromSphere: sphere andBox: box] autorelease];
}

-(id) initByCircumscribingBox: (CC3Box) box {
	return [self initFromSphere: CC3SphereFromCircumscribingBox(box) andBox: box];
}

+(id) boundingVolumeCircumscribingBox: (CC3Box) box {
	return [[[self alloc] initByCircumscribingBox: box] autorelease];
}

// Deprecated
+(id) vertexLocationsSphereandBoxBoundingVolume { return [self boundingVolume]; }

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ containing:", [self class]];
	[desc appendFormat: @"\n\t%@", _sphericalBoundingVolume];
	[desc appendFormat: @"\n\t%@", _boxBoundingVolume];
	return desc;
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ containing:", [self class]];
	[desc appendFormat: @"\n\t%@", _sphericalBoundingVolume.fullDescription];
	[desc appendFormat: @"\n\t%@", _boxBoundingVolume.fullDescription];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingArea interface

@implementation CC3NodeBoundingArea


#pragma mark Drawing

-(BOOL) doesIntersectBounds: (CGRect) bounds { return YES; }

@end


#pragma mark -
#pragma mark CC3NodeInfiniteBoundingVolume implementation

@implementation CC3NodeInfiniteBoundingVolume


#pragma mark Intersection testing

/** Intersects everything except nil. */
-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	BOOL intersects = (aBoundingVolume != nil);
	CC3LogBVIntersection(aBoundingVolume, intersects);
	return intersects;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation { return YES; }

-(BOOL) doesIntersectRay: (CC3Ray) aRay {
	if (_shouldIgnoreRayIntersection) return NO;
	return YES;
}

-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane { return NO; }

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume { return YES; }

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume { return YES; }

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (_shouldIgnoreRayIntersection) return kCC3VectorNull;
	return localRay.startLocation;
}


#pragma mark Drawing bounding volume

-(BOOL) shouldDraw { return _shouldDraw; }

-(void) setShouldDraw: (BOOL) shdDraw {}

@end


#pragma mark -
#pragma mark CC3NodeNullBoundingVolume implementation

@implementation CC3NodeNullBoundingVolume


#pragma mark Intersection testing

-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	CC3LogBVIntersection(aBoundingVolume, NO);
	return NO;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation { return NO; }

-(BOOL) doesIntersectRay: (CC3Ray) aRay { return NO; }

-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane { return YES; }

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume { return NO; }

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume { return NO; }

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay { return kCC3VectorNull; }


#pragma mark Drawing bounding volume

-(BOOL) shouldDraw { return _shouldDraw; }

-(void) setShouldDraw: (BOOL) shdDraw {}

@end
