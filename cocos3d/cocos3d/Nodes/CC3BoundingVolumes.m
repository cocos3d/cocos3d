/*
 * CC3BoundingVolumes.m
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
 * 
 * See header file CC3BoundingVolumes.h for full API documentation.
 */

#import "CC3BoundingVolumes.h"
#import "CC3Camera.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3Light.h"
#import "CC3IOSExtensions.h"


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

@interface CC3BoundingVolume (TemplateMethods)
-(void) updateIfNeeded;
-(void) buildVolume;
-(void) buildPlanes;
-(BOOL) areAllVerticesInFrontOfOneOf: (GLuint) numPlanes planes: (CC3Plane*) planes;
-(BOOL) areAllVerticesInFrontOf: (CC3Plane) plane;
-(BOOL) isRay: (CC3Ray) aRay behindAllOtherPlanesAtPunctureOfPlaneAt: (GLuint) planeIndex;
-(CC3Plane) buildPlaneFromNormal: (CC3Vector) normal
						 andFace: (CC3Face) face
			  andOrientationAxis: (CC3Vector) orientationAxis;
-(void) appendPlanesTo: (NSMutableString*) desc;
-(void) appendVerticesTo: (NSMutableString*) desc;
-(void) logIntersection: (BOOL) intersects with: (CC3BoundingVolume*) aBoundingVolume;
@end

@implementation CC3BoundingVolume

@synthesize shouldIgnoreRayIntersection;

-(CC3Plane*) planes { return NULL; }

-(GLuint) planeCount { return 0; }

-(CC3Vector*) vertices { return NULL; }

-(GLuint) vertexCount { return 0; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {

		GLuint pCnt = self.planeCount;
		CC3Plane* pArray = self.planes;
		for (int i = 0; i < pCnt; i++) {
			pArray[i] = kCC3PlaneZero;
		}

		GLuint vCnt = self.vertexCount;
		CC3Vector* vArray = self.vertices;
		for (int i = 0; i < vCnt; i++) {
			vArray[i] = kCC3VectorZero;
		}

		isDirty = YES;
		shouldIgnoreRayIntersection = NO;
		self.shouldLogIntersections = NO;			// Use setter
		self.shouldLogIntersectionMisses = NO;		// Use setter
	}
	return self;
}

+(id) boundingVolume { return [[[self alloc] init] autorelease]; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3BoundingVolume*) another {
	isDirty = another.isDirty;
	shouldIgnoreRayIntersection = another.shouldIgnoreRayIntersection;
	self.shouldLogIntersections = another.shouldLogIntersections;			// Use setter
	self.shouldLogIntersectionMisses = another.shouldLogIntersectionMisses;	// Use setter

	GLuint pCnt = self.planeCount;
	CC3Plane* pArray = self.planes;
	CC3Plane* otherPlanes = another.planes;
	for (int i = 0; i < pCnt; i++) {
		pArray[i] = otherPlanes[i];
	}
	
	GLuint vCnt = self.vertexCount;
	CC3Vector* vArray = self.vertices;
	CC3Vector* otherVertices = another.vertices;
	for (int i = 0; i < vCnt; i++) {
		vArray[i] = otherVertices[i];
	}
}

-(id) copyWithZone: (NSZone*) zone {
	CC3BoundingVolume* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@", self.class];
}

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
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		[desc appendFormat: @"\n\tplane: %@", NSStringFromCC3Plane(pArray[pIdx])];
	}
}

-(void) appendVerticesTo: (NSMutableString*) desc {
	GLuint vCnt = self.vertexCount;
	CC3Vector* vArray = self.vertices;
	for (GLuint vIdx = 0; vIdx < vCnt; vIdx++) {
		[desc appendFormat: @"\n\tvertex: %@", NSStringFromCC3Vector(vArray[vIdx])];
	}
}


#pragma mark Updating

-(BOOL) isDirty { return isDirty; }

-(void) markDirty { isDirty = YES; }

-(void) updateIfNeeded {
	if (isDirty) {
		[self buildVolume];
		[self buildPlanes];
		isDirty = NO;
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
	NSAssert1(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersect:", self);
	BOOL intersects = [aBoundingVolume doesIntersectConvexHullOf: self.planeCount
														  planes: self.planes
															from: self];
	CC3LogBVIntersection(aBoundingVolume, intersects);
	return intersects;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation {
	NSAssert1(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersectLocation:", self);
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
	CC3Vector punctureLoc = CC3VectorFromTruncatedCC3Vector4(pLoc4);
	
	// Ray is parallel to plane and won't puncture it.
	if (CC3VectorIsNull(punctureLoc)) return NO;

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
	NSAssert1(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersectRay:", self);
	if (shouldIgnoreRayIntersection) return NO;
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
	NSAssert1(self.planes, @"%@ does not use planes. You must add planes or override method doesIntersectSphere:from:", self);
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
	NSAssert1(NO, @"%@ does not yet implement globalLocationOfGlobalRayIntesection:. An implementation needs to be added.", [self class]);
	return kCC3VectorNull;
}


#pragma mark Intersection logging

#if LOGGING_ENABLED

-(BOOL) shouldLogIntersections { return shouldLogIntersections; }

-(void) setShouldLogIntersections: (BOOL) shouldLog { shouldLogIntersections = shouldLog; }

-(BOOL) shouldLogIntersectionMisses { return shouldLogIntersectionMisses; }

-(void) setShouldLogIntersectionMisses: (BOOL) shouldLog { shouldLogIntersectionMisses = shouldLog; }

#else

-(BOOL) shouldLogIntersections { return NO; }

-(void) setShouldLogIntersections: (BOOL) shouldLog {}

-(BOOL) shouldLogIntersectionMisses { return NO; }

-(void) setShouldLogIntersectionMisses: (BOOL) shouldLog {}

#endif

/**
 * If the shouldLogIntersections or shouldLogIntersectionMisses property is set to YES
 * in both this bounding volume and the specified bounding volume, a message is logged.
 *
 * Since this method is conditionally compiled, you should not invoke this method
 * directly from code that is not likewise conditionally compiled. Instead, you
 * can use the CC3LogBVIntersection macro function to invoke this method from
 * unconditionally compiled code.
 */
-(void) logIntersection: (BOOL) intersects with: (CC3BoundingVolume*) aBoundingVolume {
	if (intersects && self.shouldLogIntersections && aBoundingVolume.shouldLogIntersections) {
		LogInfo(@"%@ intersects %@", self.fullDescription, aBoundingVolume.fullDescription);
	}
	if (!intersects && self.shouldLogIntersectionMisses && aBoundingVolume.shouldLogIntersectionMisses) {
		LogInfo(@"%@ does not intersect %@", self.fullDescription, aBoundingVolume.fullDescription);
	}
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingVolume implementation

@interface CC3NodeBoundingVolume (TemplateMethods)
-(void) transformVolume;
-(CC3BoundingVolumeDisplayNode*) displayNode;
-(void) updateDisplayNode;
@end


@implementation CC3NodeBoundingVolume

@synthesize node, shouldMaximize, cameraDistanceProduct;

-(void) dealloc {
	node = nil;			// not retained
	[super dealloc];
}

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return &globalCenterOfGeometry;
}

-(GLuint) vertexCount { return 1; }

-(CC3Vector) centerOfGeometry {
	[self updateIfNeeded];
	return centerOfGeometry;
}

-(CC3Vector) globalCenterOfGeometry {
	[self updateIfNeeded];
	return globalCenterOfGeometry;
}

-(void) setCenterOfGeometry: (CC3Vector) aLocation {
	centerOfGeometry = aLocation;
	isDirty = NO;
	[self markTransformDirty];
}

-(id) init {
	if ( (self = [super init]) ) {
		node = nil;
		centerOfGeometry = kCC3VectorZero;
		globalCenterOfGeometry = kCC3VectorZero;
		cameraDistanceProduct = 0.0f;
		shouldMaximize = NO;
		isTransformDirty = YES;
		shouldDraw = NO;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3NodeBoundingVolume*) another {
	[super populateFrom: another];

	// Node property is not copied and must be set externally,
	// because a node can only have one bounding volume.

	centerOfGeometry = another.centerOfGeometry;
	globalCenterOfGeometry = another.globalCenterOfGeometry;
	cameraDistanceProduct = another.cameraDistanceProduct;
	shouldMaximize = another.shouldMaximize;
	isTransformDirty = another.isTransformDirty;
	shouldDraw = another.shouldDraw;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for %@", [super description], node];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ for %@ centered at: %@ (globally: %@)",
			[super fullDescription], node, NSStringFromCC3Vector(self.centerOfGeometry),
			NSStringFromCC3Vector(self.globalCenterOfGeometry) ];
}


#pragma mark Updating

-(BOOL) isTransformDirty { return isTransformDirty; }

-(void) markTransformDirty { isTransformDirty = YES; }

/**
 * Builds the volume if needed, then transforms it with the node's transformMatrix.
 * The transformation will occur if either the transform is marked as dirty, or the
 * bounding volume is being rebuilt.
 */
-(void) updateIfNeeded {
	if (isDirty) {
		[self buildVolume];
		isDirty = NO;
		[self updateDisplayNode];
		[self markTransformDirty];
	}

	if ( node && isTransformDirty ) {
		[self transformVolume];
		[self buildPlanes];
		isTransformDirty = NO;
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
	globalCenterOfGeometry = CC3VectorsAreEqual(centerOfGeometry, kCC3VectorZero)
								? node.globalLocation
								: [node.transformMatrix transformLocation: centerOfGeometry];
}


#pragma mark Intersection testing

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	NSAssert1(NO, @"%@ does not yet implement locationOfRayIntesection:. An implementation needs to be added.", [self class]);
	return kCC3VectorNull;
}

-(CC3Vector) globalLocationOfGlobalRayIntesection: (CC3Ray) aRay {
	if ( !node || shouldIgnoreRayIntersection ) return kCC3VectorNull;

	CC3Ray localRay = [node.transformMatrixInverted transformRay: aRay];
	CC3Vector puncture = [self locationOfRayIntesection: localRay];
	return CC3VectorIsNull(puncture)
				? puncture
				: [node.transformMatrix transformLocation: puncture];
}

// Deprecated and replaced by doesIntersect:
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	return [self doesIntersect: aFrustum];
}


#pragma mark Drawing bounding volume

/**
 * Template method that returns the suffix used to name the node used to display
 * this bounding volume. Different bounding volume types will use different suffixes.
 */
-(NSString*) displayNodeNameSuffix {
	NSAssert1(NO, @"%@ has no unique display node suffix. You must override method displayNodeNameSuffix:", self);
	return @"BV";
}

/** The name to use when creating or retrieving the wireframe child node of this node. */
-(NSString*) displayNodeName {
	return [NSString stringWithFormat: @"%@-%@", self.node.name, self.displayNodeNameSuffix];
}

/**
 * Retrieves the display node that is displaying this bounding volume from this
 * bounding volume's node, and returns it, or returns nil if this bounding volume
 * is not currently being displayed.
 */
-(CC3BoundingVolumeDisplayNode*) displayNode {
	return (CC3BoundingVolumeDisplayNode*)[self.node getNodeNamed: [self displayNodeName]];
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
-(void) updateDisplayNode {
	if (shouldDraw) [self populateDisplayNode];
}

-(BOOL) shouldDraw { return shouldDraw; }

-(void) setShouldDraw: (BOOL) shdDraw {
	shouldDraw = shdDraw;
	
	// Fetch the display node.
	CC3BoundingVolumeDisplayNode* dn = self.displayNode;
	
	// If the display node exists, but should not, remove it
	if (dn && !shouldDraw) {
		[dn remove];
	}
	
	// If there is no display node, but there should be, add it by creating a
	// CC3BoundingVolumeDisplayNode of the correct shape from the properties of
	// this bounding volume, and add it as a child of this bounding volume's node.
	if(!dn && shouldDraw) {
		dn = [CC3BoundingVolumeDisplayNode nodeWithName: [self displayNodeName]];
		dn.material = [CC3Material shiny];
		dn.color = self.displayNodeColor;
		dn.opacity = self.displayNodeOpacity;

		dn.decalOffsetFactor = -2.0f;		// Move towards the camera to avoid...
		dn.decalOffsetUnits = 0.0f;			// ...Z-fighting with object node itself

		dn.shouldDisableDepthMask = YES;	// Don't update depth mask, to allow later...
											// ..overlapping transparencies to all be drawn
		[self.node addChild: dn];
		[self populateDisplayNode];			// Populate with the right shape
	}
}

@end


#pragma mark -
#pragma mark CC3NodeCenterOfGeometryBoundingVolume implementation

@implementation CC3NodeCenterOfGeometryBoundingVolume


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
	if (shouldIgnoreRayIntersection) return NO;
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
	if (shouldIgnoreRayIntersection) return kCC3VectorNull;
	CC3Vector cog = self.centerOfGeometry;
	return ( CC3IsLocationOnRay(cog, localRay) ) ? cog : kCC3VectorNull;
}


#pragma mark Drawing bounding volume

-(NSString*) displayNodeNameSuffix { return @"BV-CoG"; }

@end


#pragma mark -
#pragma mark CC3NodeSphericalBoundingVolume implementation

@implementation CC3NodeSphericalBoundingVolume

-(GLfloat) radius {
	[self updateIfNeeded];
	return radius;
}

-(void) setRadius: (GLfloat) aRadius {
	radius = aRadius;
	isDirty = NO;
	[self markTransformDirty];
}

-(GLfloat) globalRadius {
	[self updateIfNeeded];
	return globalRadius;
}

-(CC3Sphere) sphere { return CC3SphereMake(self.centerOfGeometry, self.radius); }

-(CC3Sphere) globalSphere { return CC3SphereMake(self.globalCenterOfGeometry, self.globalRadius); }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3NodeSphericalBoundingVolume*) another {
	[super populateFrom: another];

	radius = another.radius;
	globalRadius = another.globalRadius;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ centered at: %@ (globally: %@) with radius: %.3f (globally: %.3f)",
			self.description, NSStringFromCC3Vector(self.centerOfGeometry),
			NSStringFromCC3Vector(self.globalCenterOfGeometry), self.radius, self.globalRadius];
}


#pragma mark Updating

-(void) transformVolume {
	[super transformVolume];

	// Expand the radius by the global scale of the node.
	// In case the node's global scale is not uniform, use the largest of the
	// three scale axes to ensure the scaled object is contained within the sphere.
	CC3Vector nodeScale = node.globalScale;
	GLfloat maxScale = MAX(MAX(nodeScale.x, nodeScale.y), nodeScale.z);
	globalRadius = radius * maxScale;
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
	if (shouldIgnoreRayIntersection) return NO;
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
	if (shouldIgnoreRayIntersection) return kCC3VectorNull;
	return CC3RayIntersectionOfSphere(localRay, self.sphere);
}


#pragma mark Drawing bounding volume

-(NSString*) displayNodeNameSuffix { return @"BV-Sphere"; }

-(ccColor3B) displayNodeColor { return ccMAGENTA; }		// Magenta

-(GLubyte) displayNodeOpacity { return 85; }			// Magenta is faint...increase to 33% opacity

-(void) populateDisplayNode {
	CC3BoundingVolumeDisplayNode* dn = self.displayNode;
	[dn populateAsSphereWithRadius: self.radius andTessellation: ccg(24, 24)];
	[dn doNotBufferVertexContent];
	dn.location = self.centerOfGeometry;
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVolume implementation

@implementation CC3NodeBoundingBoxVolume

-(CC3BoundingBox) boundingBox {
	[self updateIfNeeded];
	return boundingBox;
}

-(void) setBoundingBox: (CC3BoundingBox) aBoundingBox {
	boundingBox = aBoundingBox;
	isDirty = NO;
	[self markTransformDirty];
}

-(CC3Plane*) planes {
	[self updateIfNeeded];
	return planes;
}

-(GLuint) planeCount { return 6; }

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return vertices;
}

-(GLuint) vertexCount { return 8; }

// Deprecated
-(CC3Vector*) globalBoundingBoxVertices { return self.vertices; }

-(id) init {
	if ( (self = [super init]) ) {
		boundingBox = kCC3BoundingBoxZero;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3NodeBoundingBoxVolume*) another {
	[super populateFrom: another];

	boundingBox = another.boundingBox;
}

-(void) transformVolume {
	[super transformVolume];

	CC3Matrix* tMtx = node.transformMatrix;

	// Get the corners of the local bounding box
	CC3Vector bbMin = boundingBox.minimum;
	CC3Vector bbMax = boundingBox.maximum;
	
	// Construct all 8 corner vertices of the local bounding box and transform each to global coordinates
	vertices[0] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMin.z)];
	vertices[1] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMax.z)];
	vertices[2] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMin.z)];
	vertices[3] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMax.z)];
	vertices[4] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMin.z)];
	vertices[5] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMax.z)];
	vertices[6] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMin.z)];
	vertices[7] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMax.z)];
}

/**
 * Constructs the six box face planes from normals and vertices.
 * The plane normals are the transformed face normals of the original box.
 * The vertices are the transformed min-max corners of the box.
 */
-(void) buildPlanes {
	CC3Vector normal;
	CC3Matrix* tMtx = node.transformMatrix;
	CC3Vector bbMin = vertices[0];
	CC3Vector bbMax = vertices[7];
	
	// Front plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitZPositive]);
	planes[0] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Back plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitZNegative]);
	planes[1] = CC3PlaneFromNormalAndLocation(normal, bbMin);
	
	// Right plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitXPositive]);
	planes[2] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Left plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitXNegative]);
	planes[3] = CC3PlaneFromNormalAndLocation(normal, bbMin);
	
	// Top plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitYPositive]);
	planes[4] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Bottom plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitYNegative]);
	planes[5] = CC3PlaneFromNormalAndLocation(normal, bbMin);
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" with bounding box: %@", NSStringFromCC3BoundingBox(self.boundingBox)];
	[self appendPlanesTo: desc];
	[self appendVerticesTo: desc];
	return desc;
}


#pragma mark Intersection testing

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (shouldIgnoreRayIntersection) return kCC3VectorNull;
	return CC3RayIntersectionOfBoundingBox(localRay, self.boundingBox);
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

@end


#pragma mark -
#pragma mark CC3NodeTighteningBoundingVolumeSequence implementation

@implementation CC3NodeTighteningBoundingVolumeSequence

@synthesize boundingVolumes;

-(void) dealloc {
	[boundingVolumes release];
	[super dealloc];
}

-(void) setShouldMaximize: (BOOL) shouldMax {
	shouldMaximize = shouldMax;
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		bv.shouldMaximize = shouldMax;
	}
}

-(void) setNode:(CC3Node*) aNode {
	[super setNode: aNode];
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		bv.node = aNode;
	}
}

/** Overridden to keep the COG consistent for all BV's.  */
-(void) setCenterOfGeometry: (CC3Vector) aLocation {
	[super setCenterOfGeometry: aLocation];
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		bv.centerOfGeometry = aLocation;
	}
}

-(id) init {
	if ( (self = [super init]) ) {
		boundingVolumes = [[CCArray array] retain];
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3NodeTighteningBoundingVolumeSequence*) another {
	[super populateFrom: another];
	
	for(CC3NodeBoundingVolume* bv in another.boundingVolumes) {
		[boundingVolumes addObject: [bv autoreleasedCopy]];		// retained through collection
	}
}

-(void) addBoundingVolume: (CC3NodeBoundingVolume*) aBoundingVolume {
	[boundingVolumes addObject: aBoundingVolume];
	aBoundingVolume.node = self.node;
}

-(void) markDirty {
	[super markDirty];
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[bv markDirty];
	}
}

-(void) markTransformDirty {
	[super markTransformDirty];
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[bv markTransformDirty];
	}
}

/** Builds each contained bounding volume, if needed, and sets the local centerOfGeometry from the last one. */
-(void) buildVolume {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[bv updateIfNeeded];
		centerOfGeometry = bv.centerOfGeometry;
	}
}

-(void) transformVolume {
	[super transformVolume];

	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[bv transformVolume];
	}
}

-(NSString*) description {
	if (boundingVolumes.count == 0) {
		return [NSString stringWithFormat: @"%@ containing nothing", [self class]];
	}
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ containing:", [self class]];
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[desc appendFormat: @"\n\t%@", bv];
	}
	return desc;
}

-(NSString*) fullDescription {
	if (boundingVolumes.count == 0) return self.description;
	
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ containing:", [self class]];
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[desc appendFormat: @"\n\t%@", bv.fullDescription];
	}
	return desc;
}


#pragma mark Intersection testing

-(BOOL) doesIntersect: (CC3BoundingVolume*) aBoundingVolume {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( ![bv doesIntersect: aBoundingVolume] ) {
			return NO;
		}
	}
	return YES;
}

-(BOOL) doesIntersectLocation: (CC3Vector) aLocation {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( ![bv doesIntersectLocation: aLocation] ) {
			return NO;
		}
	}
	return YES;
}

-(BOOL) doesIntersectRay: (CC3Ray) aRay {
	if (shouldIgnoreRayIntersection) return NO;
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( ![bv doesIntersectRay: aRay] ) {
			return NO;
		}
	}
	return YES;
}

-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( [bv isInFrontOfPlane: aPlane] ) {
			return YES;
		}
	}
	return NO;
}

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( ![bv doesIntersectSphere: aSphere from: otherBoundingVolume] ) {
			return NO;
		}
	}
	return YES;
}

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( ![bv doesIntersectConvexHullOf: numOtherPlanes
									planes: otherPlanes
									  from: otherBoundingVolume] ) {
			return NO;
		}
	}
	return YES;
}

/** Returns the location of the intersection on the tightest child BV. */
-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (shouldIgnoreRayIntersection) return kCC3VectorNull;
	CC3NodeBoundingVolume* bv = boundingVolumes.lastObject;
	return bv ? [bv locationOfRayIntesection: localRay] : kCC3VectorNull;
}


#pragma mark Intersection logging

#if LOGGING_ENABLED

-(BOOL) shouldLogIntersections {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( bv.shouldLogIntersections ) return YES;
	}
	return NO;
}

-(void) setShouldLogIntersections: (BOOL) shouldLog {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		bv.shouldLogIntersections = shouldLog;
	}
}

-(BOOL) shouldLogIntersectionMisses {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( bv.shouldLogIntersectionMisses ) return YES;
	}
	return NO;
}

-(void) setShouldLogIntersectionMisses: (BOOL) shouldLog {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		bv.shouldLogIntersectionMisses = shouldLog;
	}
}

#endif


#pragma mark Drawing bounding volume

-(BOOL) shouldDraw {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( bv.shouldDraw ) return YES;
	}
	return NO;
}

-(void) setShouldDraw: (BOOL) shdDraw {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		bv.shouldDraw = shdDraw;
	}
}

@end


#pragma mark -
#pragma mark CC3NodeSphereThenBoxBoundingVolume interface

@implementation CC3NodeSphereThenBoxBoundingVolume

-(CC3NodeSphericalBoundingVolume*) sphericalBoundingVolume { return [boundingVolumes objectAtIndex: 0]; }

-(CC3NodeBoundingBoxVolume*) boxBoundingVolume { return [boundingVolumes objectAtIndex: 1]; }

+(id) boundingVolumeWithSphere: (CC3NodeSphericalBoundingVolume*) sphereBV
						andBox: (CC3NodeBoundingBoxVolume*) boxBV {
	CC3NodeSphereThenBoxBoundingVolume* sbbv = [self boundingVolume];
	[sbbv addBoundingVolume: sphereBV];
	[sbbv addBoundingVolume: boxBV];
	return sbbv;
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
	if (shouldIgnoreRayIntersection) return NO;
	return YES;
}

-(BOOL) isInFrontOfPlane: (CC3Plane) aPlane { return NO; }

-(BOOL) doesIntersectSphere: (CC3Sphere) aSphere
					   from: (CC3BoundingVolume*) otherBoundingVolume { return YES; }

-(BOOL) doesIntersectConvexHullOf: (GLuint) numOtherPlanes
						   planes: (CC3Plane*) otherPlanes
							 from: (CC3BoundingVolume*) otherBoundingVolume { return YES; }

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (shouldIgnoreRayIntersection) return kCC3VectorNull;
	return localRay.startLocation;
}


#pragma mark Drawing bounding volume

-(BOOL) shouldDraw { return shouldDraw; }

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

-(BOOL) shouldDraw { return shouldDraw; }

-(void) setShouldDraw: (BOOL) shdDraw {}

@end

