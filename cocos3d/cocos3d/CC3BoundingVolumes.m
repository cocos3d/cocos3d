/*
 * CC3BoundingVolumes.m
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
 * 
 * See header file CC3BoundingVolumes.h for full API documentation.
 */

#import "CC3BoundingVolumes.h"
#import "CC3Camera.h"


#pragma mark CC3NodeBoundingVolume implementation

@interface CC3NodeBoundingVolume (TemplateMethods)
-(void) buildVolumeIfNeeded;
-(void) buildVolume;
-(void) transformVolume;
@end


@implementation CC3NodeBoundingVolume

@synthesize node, shouldMaximize;
@synthesize centerOfGeometry, globalCenterOfGeometry, cameraDistanceProduct;

-(void) dealloc {
	node = nil;			// not retained
	[super dealloc];
}

-(void) setCenterOfGeometry: (CC3Vector) aLocation {
	centerOfGeometry = aLocation;
	volumeIsDirty = NO;
}

-(id) init {
	if ( (self = [super init]) ) {
		node = nil;
		centerOfGeometry = kCC3VectorZero;
		globalCenterOfGeometry = kCC3VectorZero;
		shouldMaximize = NO;
		volumeIsDirty = YES;
	}
	return self;
}

// Protected properties used for copying
-(BOOL) volumeIsDirty { return volumeIsDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// Node property is not copied and must be set externally, because a node can only have one BV.
-(void) populateFrom: (CC3NodeBoundingVolume*) another {
	centerOfGeometry = another.centerOfGeometry;
	globalCenterOfGeometry = another.globalCenterOfGeometry;
	cameraDistanceProduct = another.cameraDistanceProduct;
	shouldMaximize = another.shouldMaximize;
	volumeIsDirty = another.volumeIsDirty;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3NodeBoundingVolume* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

+(id) boundingVolume {
	return [[[self alloc] init] autorelease];
}

-(void) update {
	[self buildVolumeIfNeeded];
	if (node) {
		[self transformVolume];
	}
}

-(void) markDirty {
	volumeIsDirty = YES;
}

-(void) markDirtyAndUpdate {
	[self markDirty];
	[self update];
}

/** Invokes the buildVolume method if the volume needs building, otherwise does nothing. */
-(void) buildVolumeIfNeeded {
	if (volumeIsDirty) {
		[self buildVolume];
	}
}

/**
 * Builds the bounding volume in the node's local coordinate system.
 *
 * This is a template method. Default does nothing except mark the volume as no longer
 * dirty. Subclasses will override to calculate a real bounding volume, but should
 * invoke this superclass method to mark the volume as no longer dirty.
 */
-(void) buildVolume {
	LogTrace(@"Rebuilt %@", self);
	volumeIsDirty = NO;
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

-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	return [aFrustum doesIntersectPointAt: globalCenterOfGeometry];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for %@ centered at: %@ (globally: %@)", [self class], node,
			NSStringFromCC3Vector(centerOfGeometry), NSStringFromCC3Vector(globalCenterOfGeometry) ];
}

@end


#pragma mark -
#pragma mark CC3NodeSphericalBoundingVolume implementation

@implementation CC3NodeSphericalBoundingVolume

@synthesize radius, globalRadius;

-(void) setRadius: (GLfloat) aRadius {
	radius = aRadius;
	volumeIsDirty = NO;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3NodeSphericalBoundingVolume*) another {
	[super populateFrom: another];

	radius = another.radius;
	globalRadius = another.globalRadius;
}

-(void) transformVolume {
	[super transformVolume];

	// Expand the radius by the global scale of the node.
	// In case the node's global scale is not uniform, use the largest of the
	// three scale axes to ensure the scaled object is contained within the sphere.
	CC3Vector nodeScale = node.globalScale;
	GLfloat maxScale = MAX(MAX(nodeScale.x, nodeScale.y), nodeScale.z);
	globalRadius = radius * maxScale;
}

-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	return [aFrustum doesIntersectSphereAt: globalCenterOfGeometry withRadius: globalRadius];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with radius: %.3f (globally: %.3f)",
			[super description], radius, globalRadius];
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVolume implementation

@implementation CC3NodeBoundingBoxVolume

@synthesize boundingBox;

-(void) setBoundingBox: (CC3BoundingBox) aBoundingBox {
	boundingBox = aBoundingBox;
	volumeIsDirty = NO;
}

-(CC3Vector*) globalBoundingBoxVertices {
	return globalBoundingBoxVertices;
}

-(id) init {
	if ( (self = [super init]) ) {
		boundingBox = kCC3BoundingBoxZero;
		for (int i=0; i < 8; i++) {
			globalBoundingBoxVertices[i] = kCC3VectorZero;
		}
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3NodeBoundingBoxVolume*) another {
	[super populateFrom: another];

	boundingBox = another.boundingBox;
	for (int i = 0; i < 8; i++) {
		globalBoundingBoxVertices[i] = another.globalBoundingBoxVertices[i];
	}
}

-(void) transformVolume {
	[super transformVolume];

	CC3GLMatrix* tMtx = node.transformMatrix;

	// Get the corners of the local bounding box
	CC3Vector bbMin = boundingBox.minimum;
	CC3Vector bbMax = boundingBox.maximum;
	
	// Construct all 8 corner vertices of the local bounding box and transform each to global coordinates
	globalBoundingBoxVertices[0] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMin.z)];
	globalBoundingBoxVertices[1] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMax.z)];
	globalBoundingBoxVertices[2] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMin.z)];
	globalBoundingBoxVertices[3] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMax.z)];
	globalBoundingBoxVertices[4] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMin.z)];
	globalBoundingBoxVertices[5] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMax.z)];
	globalBoundingBoxVertices[6] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMin.z)];
	globalBoundingBoxVertices[7] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMax.z)];
}

/** Returns whether the specified location lies inside the specified plane. */
-(BOOL) isLocation: (CC3Vector) location insidePlane: (CC3Plane) plane {
	return (CC3DistanceFromNormalizedPlane(plane, location) > 0);
}

/**
 * Returns whether this bounding box lies completely outside the specified plane
 * by testing each of the eight verticies of the global bounding box, and returning
 * as soon as one vertex is found to lie inside the plane.
 */
-(BOOL) isOutsidePlane: (CC3Plane) plane {
	for (int i=0; i < 8; i++) {
		if ([self isLocation: globalBoundingBoxVertices[i] insidePlane: plane]) {
			return NO;
		}
	}
	return YES;
}

/**
 * Rejects quickly, so check in a sensible order of realism.
 * In most scenes, most objects that are outside the frustum will be behind
 * the camera or off to the left or right. Least likely is something that is
 * so far away as to be outside the far clip plane.
 */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	BOOL isOutside = [self isOutsidePlane: aFrustum.nearPlane] ||
					 [self isOutsidePlane: aFrustum.leftPlane] ||
					 [self isOutsidePlane: aFrustum.rightPlane] ||
					 [self isOutsidePlane: aFrustum.topPlane] ||
					 [self isOutsidePlane: aFrustum.bottomPlane] ||
					 [self isOutsidePlane: aFrustum.farPlane];
	return !isOutside;
}

-(NSString*) description {
	CC3BoundingBox gbb;
	CC3Vector gbbv;
	gbbv = globalBoundingBoxVertices[0];
	gbb.minimum = gbbv;
	gbb.maximum = gbbv;
	for (GLsizei i = 1; i < 8; i++) {
		gbbv = globalBoundingBoxVertices[i];
		gbb.minimum = CC3VectorMinimize(gbbv, gbb.minimum);
		gbb.maximum = CC3VectorMaximize(gbbv, gbb.maximum);
	}
	return [NSString stringWithFormat: @"%@ with bounding box: %@ (globally: %@))",
			[super description], NSStringFromCC3BoundingBox(boundingBox),
			NSStringFromCC3BoundingBox(gbb)];
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
		[boundingVolumes addObject: [bv copyAutoreleased]];		// retained through collection
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

/** Builds each contained bounding volume, and sets the local centerOfGeometry from the last one. */
-(void) buildVolume {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[bv buildVolume];
		centerOfGeometry = bv.centerOfGeometry;
	}
	[super buildVolume];
}

-(void) transformVolume {
	[super transformVolume];

	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		[bv transformVolume];
	}
}

-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		if( ![bv doesIntersectFrustum: aFrustum] ) {
			return NO;
		}
	}
	return YES;
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

@end


#pragma mark -
#pragma mark CC3NodeBoundingArea interface

@implementation CC3NodeBoundingArea


#pragma mark Drawing

-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	return YES;
}

-(BOOL) doesIntersectBounds: (CGRect) bounds {
	return YES;
}

@end
