/*
 * CC3BoundingVolumes.m
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

@synthesize node, volumeNeedsBuilding;
@synthesize centerOfGeometry, globalCenterOfGeometry, cameraDistanceProduct;

-(void) dealloc {
	node = nil;			// not retained
	[super dealloc];
}

-(id) init {
	if ( (self = [super init]) ) {
		node = nil;
		centerOfGeometry = kCC3VectorZero;
		globalCenterOfGeometry = kCC3VectorZero;
		volumeNeedsBuilding = YES;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// Node property is not copied and must be set externally, because a node can only have one BV.
-(void) populateFrom: (CC3NodeBoundingVolume*) another {
	centerOfGeometry = another.centerOfGeometry;
	globalCenterOfGeometry = another.globalCenterOfGeometry;
	cameraDistanceProduct = another.cameraDistanceProduct;
	volumeNeedsBuilding = another.volumeNeedsBuilding;
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

/** Invokes the buildVolume method if the volume needs building, otherwise does nothing. */
-(void) buildVolumeIfNeeded {
	if (volumeNeedsBuilding) {
		[self buildVolume];
	}
}

-(void) buildVolume {
	volumeNeedsBuilding = NO;
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
	return [NSString stringWithFormat: @"%@ globally centered at: %@",
			[self class], NSStringFromCC3Vector(globalCenterOfGeometry) ];
}

@end


#pragma mark -
#pragma mark CC3NodeSphericalBoundingVolume implementation

@implementation CC3NodeSphericalBoundingVolume

@synthesize radius, globalRadius;

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
	return [NSString stringWithFormat: @"%@ with radius: %.2f, global radius: %.2f", [super description], radius, globalRadius];
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVolume implementation

@implementation CC3NodeBoundingBoxVolume

@synthesize boundingBox;

-(CC3Vector*) globalBoundingBoxVertices {
	return globalBoundingBoxVertices;
}

-(id) init {
	if ( (self = [super init]) ) {
		boundingBox.minimum = kCC3VectorZero;
		boundingBox.maximum = kCC3VectorZero;
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

	// Get the corners of the local bounding box
	CC3Vector bbMin = boundingBox.minimum;
	CC3Vector bbMax = boundingBox.maximum;
	
	// Construct all 8 corner vertices of the local bounding box and transform each to global coordinates
	globalBoundingBoxVertices[0] = [node.transformMatrix transformLocation: cc3v(bbMin.x, bbMin.y, bbMin.z)];
	globalBoundingBoxVertices[1] = [node.transformMatrix transformLocation: cc3v(bbMin.x, bbMin.y, bbMax.z)];
	globalBoundingBoxVertices[2] = [node.transformMatrix transformLocation: cc3v(bbMin.x, bbMax.y, bbMin.z)];
	globalBoundingBoxVertices[3] = [node.transformMatrix transformLocation: cc3v(bbMin.x, bbMax.y, bbMax.z)];
	globalBoundingBoxVertices[4] = [node.transformMatrix transformLocation: cc3v(bbMax.x, bbMin.y, bbMin.z)];
	globalBoundingBoxVertices[5] = [node.transformMatrix transformLocation: cc3v(bbMax.x, bbMin.y, bbMax.z)];
	globalBoundingBoxVertices[6] = [node.transformMatrix transformLocation: cc3v(bbMax.x, bbMax.y, bbMin.z)];
	globalBoundingBoxVertices[7] = [node.transformMatrix transformLocation: cc3v(bbMax.x, bbMax.y, bbMax.z)];
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
	CC3Vector gbbv, gbbvMin, gbbvMax;
	gbbv = globalBoundingBoxVertices[0];
	gbbvMin = gbbv;
	gbbvMax = gbbv;
	for (GLsizei i = 1; i < 8; i++) {
		gbbv = globalBoundingBoxVertices[i];
		gbbvMin = CC3VectorMinimize(gbbvMin, gbbv);
		gbbvMax = CC3VectorMaximize(gbbvMax, gbbv);
	}
	return [NSString stringWithFormat: @"%@ with global bounding box: (%@, %@)", [self class],
			NSStringFromCC3Vector(gbbvMin), NSStringFromCC3Vector(gbbvMax)];
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

-(void) setNode:(CC3Node*) aNode {
	[super setNode: aNode];
	for (CC3NodeBoundingVolume* bv in boundingVolumes) {
		bv.node = aNode;
	}
}

-(id) init {
	if ( (self = [super init]) ) {
		boundingVolumes = [[NSMutableArray array] retain];
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
	return NO;
}

-(BOOL) doesIntersectBounds: (CGRect) bounds {
	return YES;
}

@end
