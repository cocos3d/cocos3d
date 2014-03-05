/*
 * CC3UtilityMeshNodes.m
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
 * See header file CC3UtilityMeshNodes.h for full API documentation.
 */

#import "CC3UtilityMeshNodes.h"
#import "CC3Scene.h"


// Expose CC3Node parent property as writeable, so subclasses can propagate to superclass.
@interface CC3Node (TemplateMethods)
@property(nonatomic, unsafe_unretained, readwrite) CC3Node* parent;
@end


#pragma mark -
#pragma mark CC3PlaneNode

@implementation CC3PlaneNode

-(CC3Plane) plane {
	CC3Box bb = self.mesh.boundingBox;
	
	// Get three points on the plane by using three corners of the mesh bounding box.
	CC3Vector p1 = bb.minimum;
	CC3Vector p2 = bb.maximum;
	CC3Vector p3 = bb.minimum;
	p3.x = bb.maximum.x;
	
	// Transform these points.
	p1 = [self.globalTransformMatrix transformLocation: p1];
	p2 = [self.globalTransformMatrix transformLocation: p2];
	p3 = [self.globalTransformMatrix transformLocation: p3];
	
	// Create and return a plane from these points.
	return CC3PlaneFromLocations(p1, p2, p3);
}

@end


#pragma mark -
#pragma mark CC3LineNode

@implementation CC3LineNode

// Deprecated property
-(GLenum) performanceHint { return self.lineSmoothingHint; }
-(void) setPerformanceHint: (GLenum) aHint { self.lineSmoothingHint = aHint; }

@end


#pragma mark -
#pragma mark CC3SimpleLineNode

@implementation CC3SimpleLineNode


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_lineVertices[0] = kCC3VectorZero;
		_lineVertices[1] = kCC3VectorZero;
		[self populateAsLineStripWith: 2 vertices: _lineVertices andRetain: NO];
		[self retainVertexLocations];
	}
	return self;
}

-(CC3Vector) lineStart { return [self vertexLocationAt: 0]; }

-(void) setLineStart: (CC3Vector) aLocation {
	[self setVertexLocation: aLocation at: 0];
	[self updateVertexLocationsGLBuffer];
}

-(CC3Vector) lineEnd { return [self vertexLocationAt: 1]; }

-(void) setLineEnd: (CC3Vector) aLocation {
	[self setVertexLocation: aLocation at: 1];
	[self updateVertexLocationsGLBuffer];
}

@end


#pragma mark -
#pragma mark CC3BoxNode

@implementation CC3BoxNode
@end


#pragma mark -
#pragma mark CC3TouchBox

@implementation CC3TouchBox

@synthesize shouldAlwaysMeasureParentBoundingBox=_shouldAlwaysMeasureParentBoundingBox;

-(CC3Box) box { return self.localContentBoundingBox; }

-(void) setBox: (CC3Box) aBox {
	if (CC3BoxIsNull(aBox)) {
		self.mesh = nil;
	} else {
		[self populateBox: aBox];
	}
}

-(void) setParent: (CC3Node*) aNode {
	[super setParent: aNode];
	[self deriveNameFrom: aNode];
	if ( !_mesh ) self.box = self.parentBoundingBox;
}

-(NSString*) nameSuffix { return @"TouchBox"; }

-(CC3Box) parentBoundingBox { return _parent ? _parent.boundingBox : kCC3BoxNull; }

-(BOOL) shouldContributeToParentBoundingBox { return NO; }


#pragma mark Population as a box

-(void) populateBox: (CC3Box) aBox {
	
	CC3Mesh* mesh = [self prepareParametricMesh];
	
	// Now update the vertex locations with the box data
	GLuint vIdx = 0;
	CC3Vector bbMin = aBox.minimum;
	CC3Vector bbMax = aBox.maximum;
	[mesh setVertexLocation: cc3v(bbMin.x, bbMin.y, bbMin.z) at: vIdx++];
	[mesh setVertexLocation: cc3v(bbMin.x, bbMin.y, bbMax.z) at: vIdx++];
	[mesh setVertexLocation: cc3v(bbMin.x, bbMax.y, bbMin.z) at: vIdx++];
	[mesh setVertexLocation: cc3v(bbMin.x, bbMax.y, bbMax.z) at: vIdx++];
	[mesh setVertexLocation: cc3v(bbMax.x, bbMin.y, bbMin.z) at: vIdx++];
	[mesh setVertexLocation: cc3v(bbMax.x, bbMin.y, bbMax.z) at: vIdx++];
	[mesh setVertexLocation: cc3v(bbMax.x, bbMax.y, bbMin.z) at: vIdx++];
	[mesh setVertexLocation: cc3v(bbMax.x, bbMax.y, bbMax.z) at: vIdx++];
	
	[mesh updateVertexLocationsGLBuffer];
	[self markBoundingVolumeDirty];
}

/** Overridden because we only need vertex locations, and to allocate and populate indices. */
-(CC3Mesh*) prepareParametricMesh {
	if (_mesh) return _mesh;
	
	if (self.vertexContentTypes == kCC3VertexContentNone)
		self.vertexContentTypes = kCC3VertexContentLocation;
	
	// Prepare the vertex content and allocate space for vertices and indices.
	_mesh.allocatedVertexCapacity = 8;
	_mesh.allocatedVertexIndexCapacity = 36;
	
	GLuint vIdx = 0;
	
	// Front
	[_mesh setVertexIndex: 1 at: vIdx++];
	[_mesh setVertexIndex: 5 at: vIdx++];
	[_mesh setVertexIndex: 7 at: vIdx++];
	[_mesh setVertexIndex: 7 at: vIdx++];
	[_mesh setVertexIndex: 3 at: vIdx++];
	[_mesh setVertexIndex: 1 at: vIdx++];
	
	// Back
	[_mesh setVertexIndex: 0 at: vIdx++];
	[_mesh setVertexIndex: 2 at: vIdx++];
	[_mesh setVertexIndex: 6 at: vIdx++];
	[_mesh setVertexIndex: 6 at: vIdx++];
	[_mesh setVertexIndex: 4 at: vIdx++];
	[_mesh setVertexIndex: 0 at: vIdx++];
	
	// Left
	[_mesh setVertexIndex: 0 at: vIdx++];
	[_mesh setVertexIndex: 1 at: vIdx++];
	[_mesh setVertexIndex: 3 at: vIdx++];
	[_mesh setVertexIndex: 3 at: vIdx++];
	[_mesh setVertexIndex: 2 at: vIdx++];
	[_mesh setVertexIndex: 0 at: vIdx++];
	
	// Right
	[_mesh setVertexIndex: 4 at: vIdx++];
	[_mesh setVertexIndex: 6 at: vIdx++];
	[_mesh setVertexIndex: 7 at: vIdx++];
	[_mesh setVertexIndex: 7 at: vIdx++];
	[_mesh setVertexIndex: 5 at: vIdx++];
	[_mesh setVertexIndex: 4 at: vIdx++];
	
	// Top
	[_mesh setVertexIndex: 2 at: vIdx++];
	[_mesh setVertexIndex: 3 at: vIdx++];
	[_mesh setVertexIndex: 7 at: vIdx++];
	[_mesh setVertexIndex: 7 at: vIdx++];
	[_mesh setVertexIndex: 6 at: vIdx++];
	[_mesh setVertexIndex: 2 at: vIdx++];
	
	// Bottom
	[_mesh setVertexIndex: 0 at: vIdx++];
	[_mesh setVertexIndex: 4 at: vIdx++];
	[_mesh setVertexIndex: 5 at: vIdx++];
	[_mesh setVertexIndex: 5 at: vIdx++];
	[_mesh setVertexIndex: 1 at: vIdx++];
	[_mesh setVertexIndex: 0 at: vIdx++];
	
	return _mesh;
}


#pragma mark Updating

/** If we should remeasure and update the bounding box dimensions, do so. */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	if (_shouldAlwaysMeasureParentBoundingBox) self.box = self.parentBoundingBox;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_shouldAlwaysMeasureParentBoundingBox = NO;
		self.visible = NO;
		self.shouldAllowTouchableWhenInvisible = YES;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3SphereNode

@implementation CC3SphereNode

-(CC3NodeBoundingVolume*) defaultBoundingVolume {
	return [CC3NodeSphericalBoundingVolume boundingVolume];
}

@end


#pragma mark -
#pragma mark CC3ClipSpaceNode

@implementation CC3ClipSpaceNode

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.shouldDrawInClipSpace = YES;
	}
	return self;
}

+(id) nodeWithTexture: (CC3Texture*) texture {
	CC3MeshNode* csn = [self node];
	csn.texture = texture;
	return csn;
}

// Use diffuseColor to force material and use clip-space shaders
+(id) nodeWithColor: (ccColor4F) color {
	CC3MeshNode* csn = [self node];
	csn.diffuseColor = color;
	return csn;
}

/** The camera frustum has no meaning in clip-space. */
-(CC3NodeBoundingVolume*) defaultBoundingVolume { return nil; }

@end


#pragma mark -
#pragma mark CC3Backdrop

@implementation CC3Backdrop
@end


#pragma mark -
#pragma mark CC3WireframeBoundingBoxNode

@implementation CC3WireframeBoundingBoxNode

@synthesize shouldAlwaysMeasureParentBoundingBox=_shouldAlwaysMeasureParentBoundingBox;

-(BOOL) shouldIncludeInDeepCopy { return NO; }

-(BOOL) shouldDrawDescriptor { return YES; }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {}

-(BOOL) shouldDrawWireframeBox { return YES; }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldDrawLocalContentWireframeBox { return YES; }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

-(BOOL) shouldDrawBoundingVolume { return NO; }

-(void) setShouldDrawBoundingVolume: (BOOL) shouldDraw {}

/** Overridden so that not touchable unless specifically set as such. */
-(BOOL) isTouchable {
	return (self.visible || _shouldAllowTouchableWhenInvisible) && self.isTouchEnabled;
}

/** Overridden so that can still be visible if parent is invisible, unless explicitly turned off. */
-(BOOL) visible { return _visible; }

/** For wireframe lines, if material is created dynamically, make sure it ignores lighting. */
-(CC3Material*) makeMaterial {
	CC3Material* mat = [super makeMaterial];
	mat.shouldUseLighting = NO;
	return mat;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) )
		_shouldAlwaysMeasureParentBoundingBox = NO;
	return self;
}

-(void) populateFrom: (CC3WireframeBoundingBoxNode*) another {
	[super populateFrom: another];
	
	_shouldAlwaysMeasureParentBoundingBox = another.shouldAlwaysMeasureParentBoundingBox;
}

-(void) releaseRedundantContent {
	[self retainVertexLocations];
	[super releaseRedundantContent];
}


#pragma mark Updating

-(void) updateFromParentBoundingBox { [self updateFromParentBoundingBoxWithVisitor: nil]; }

/** If we should remeasure and update the bounding box dimensions, do so. */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	if (_shouldAlwaysMeasureParentBoundingBox)
		[self updateFromParentBoundingBoxWithVisitor: visitor];
}

/** Measures the bounding box of the parent node and updates the vertex locations. */
-(void) updateFromParentBoundingBoxWithVisitor: (CC3NodeUpdatingVisitor*) visitor {
	CC3Box pbb = self.parentBoundingBox;
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.minimum.y, pbb.minimum.z) at: 0];
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.minimum.y, pbb.maximum.z) at: 1];
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.maximum.y, pbb.minimum.z) at: 2];
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.maximum.y, pbb.maximum.z) at: 3];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.minimum.y, pbb.minimum.z) at: 4];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.minimum.y, pbb.maximum.z) at: 5];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.maximum.y, pbb.minimum.z) at: 6];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.maximum.y, pbb.maximum.z) at: 7];
	[self updateVertexLocationsGLBuffer];
}

/**
 * Returns the parent's bounding box, or kCC3BoxZero if no parent,
 * or if parent doesn't have a bounding box.
 */
-(CC3Box) parentBoundingBox {
	if (_parent) {
		CC3Box pbb = _parent.boundingBox;
		if (!CC3BoxIsNull(pbb)) return pbb;
	}
	return kCC3BoxZero;
}

@end


#pragma mark -
#pragma mark CC3WireframeLocalContentBoundingBoxNode

@implementation CC3WireframeLocalContentBoundingBoxNode

/**
 * Overridden to return the parent's local content bounding box,
 * or kCC3BoxZero if no parent, or if parent doesn't have a bounding box.
 */
-(CC3Box) parentBoundingBox {
	if (_parent && _parent.hasLocalContent) {
		CC3Box pbb = ((CC3LocalContentNode*)_parent).localContentBoundingBox;
		if (!CC3BoxIsNull(pbb)) return pbb;
	}
	return kCC3BoxZero;
}

@end


#pragma mark -
#pragma mark CC3DirectionMarkerNode

@implementation CC3DirectionMarkerNode

-(CC3Vector) markerDirection { return _markerDirection; }

-(void) setMarkerDirection: (CC3Vector) aDirection { _markerDirection = CC3VectorNormalize(aDirection); }

-(void) setParent: (CC3Node*) aNode {
	[super setParent: aNode];
	[self updateFromParentBoundingBox];
}

/** 
 * Overridden to establish a default parent bounding box for parents that have no bounding
 * box, such as cameras and lights. The default parent box is calculated as 10% of the size
 * of the entire scene.
 */
-(CC3Box) parentBoundingBox {
	CC3Box pbb = super.parentBoundingBox;
	if ( !CC3BoxIsZero(pbb) ) return pbb;

	CC3Vector bbDim = CC3VectorScaleUniform(CC3BoxSize(self.scene.boundingBox), 0.05f);
	return CC3BoxFromMinMax(CC3VectorNegate(bbDim), bbDim);
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_markerDirection = kCC3VectorUnitZNegative;
	}
	return self;
}

-(void) populateFrom: (CC3DirectionMarkerNode*) another {
	[super populateFrom: another];
	
	_markerDirection = another.markerDirection;
}


#pragma mark Updating

/** Measures the bounding box of the parent node and updates the vertex locations. */
-(void) updateFromParentBoundingBoxWithVisitor: (CC3NodeUpdatingVisitor*) visitor {
	[self setVertexLocation: [self calculateLineEnd] at: 1];
	[self updateVertexLocationsGLBuffer];
}

#define kCC3DirMarkerLineScale 1.5
#define kCC3DirMarkerMinAbsoluteScale (0.25 / kCC3DirMarkerLineScale)

/**
 * Calculates the scale to use, along a single axis, for the length of the directional marker.
 * Divide the distance from the origin, along this axis, to each of two opposite sides of the
 * bounding box, by the length of the directional marker in this axis.
 *
 * Taking into consideration the sign of the direction, the real distance along this axis to
 * the side it will intersect will be the maximum of these two values.
 *
 * Finally, in case the origin is on, or very close to, one side, make sure the length of the
 * directional marker is at least 1/4 of the length of the distance between the two sides.
 */
-(GLfloat) calcScale: (GLfloat) markerAxis bbMin: (GLfloat) minBBAxis bbMax: (GLfloat) maxBBAxis {
	if (markerAxis == 0.0f) return kCC3MaxGLfloat;
	
	GLfloat scaleToMaxSide = maxBBAxis / markerAxis;
	GLfloat scaleToMinSide = minBBAxis / markerAxis;
	GLfloat minAbsoluteScale = fabsf((maxBBAxis - minBBAxis) / markerAxis) * kCC3DirMarkerMinAbsoluteScale;
	CC3_PUSH_NOSHADOW
	return MAX(MAX(scaleToMaxSide, scaleToMinSide), minAbsoluteScale);
	CC3_POP_NOSHADOW
}

// The proportional distance that the direction should protrude from the parent node
static GLfloat directionMarkerScale = 1.5;

+(GLfloat) directionMarkerScale { return directionMarkerScale; }

+(void) setDirectionMarkerScale: (GLfloat) aScale { directionMarkerScale = aScale; }

// The minimum length of a direction marker, in the global coordinate system.
static GLfloat directionMarkerMinimumLength = 0;

+(GLfloat) directionMarkerMinimumLength { return directionMarkerMinimumLength; }

+(void) setDirectionMarkerMinimumLength: (GLfloat) len { directionMarkerMinimumLength = len; }

/**
 * Calculate the end of the directonal marker line.
 *
 * This is done by calculating the scale we need to multiply the directional marker by to
 * reach each of the three sides of the bounding box, then take the smallest of these,
 * because that is the side it will intersect. Finally, multiply by an overall scale factor.
 */
-(CC3Vector) calculateLineEnd {
	CC3Box pbb = self.parentBoundingBox;
	CC3Vector md = self.markerDirection;
	
	CC3Vector pbbDirScale = cc3v([self calcScale: md.x bbMin: pbb.minimum.x bbMax: pbb.maximum.x],
								 [self calcScale: md.y bbMin: pbb.minimum.y bbMax: pbb.maximum.y],
								 [self calcScale: md.z bbMin: pbb.minimum.z bbMax: pbb.maximum.z]);
	CC3_PUSH_NOSHADOW
	GLfloat dirScale = MIN(pbbDirScale.x, MIN(pbbDirScale.y, pbbDirScale.z));
	dirScale = dirScale * [[self class] directionMarkerScale];
	CC3_POP_NOSHADOW

	// Ensure that the direction marker has the minimum length specified by directionMarkerMinimumLength
	if (directionMarkerMinimumLength) {
		GLfloat gblUniScale = CC3VectorLength(self.globalScale) / kCC3VectorUnitCubeLength;
		GLfloat minScale = directionMarkerMinimumLength / gblUniScale;
		dirScale = MAX(dirScale, minScale);
	}

	CC3Vector lineEnd = CC3VectorScaleUniform(md, dirScale);
	LogTrace(@"%@ calculated line end %@ from pbb scale %@ and dir scale %.3f and min global length: %.3f", self,
			 NSStringFromCC3Vector(lineEnd), NSStringFromCC3Vector(pbbDirScale), dirScale, directionMarkerMinimumLength);
	return lineEnd;
}

@end


#pragma mark -
#pragma mark CC3BoundingVolumeDisplayNode

@implementation CC3BoundingVolumeDisplayNode

/** Forces the color to always remain the same, even when the primary node is tinted to some other color. */
-(void) setColor: (ccColor3B) color {
	CC3NodeBoundingVolume* bv = self.parent.boundingVolume;
	if (bv) color = bv.displayNodeColor;
	[super setColor:color];
}

/** 
 * Limit the opacity of the bounding volume display, so it doesn't obscure the primary node,
 * even when opacity of the parent is changed, as in a fade-in.
 */
-(void) setOpacity:(GLubyte)opacity {
	CC3NodeBoundingVolume* bv = self.parent.boundingVolume;
	if (bv) opacity = MIN(opacity, bv.displayNodeOpacity);
	[super setOpacity: opacity];
}

-(BOOL) shouldIncludeInDeepCopy { return NO; }

-(BOOL) shouldDrawDescriptor { return YES; }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {}

-(BOOL) shouldDrawWireframeBox { return YES; }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldDrawLocalContentWireframeBox { return YES; }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

-(BOOL) shouldDrawBoundingVolume { return NO; }

-(void) setShouldDrawBoundingVolume: (BOOL) shouldDraw {}

// Overridden so that not touchable unless specifically set as such
-(BOOL) isTouchable {
	return (self.visible || _shouldAllowTouchableWhenInvisible) && self.isTouchEnabled;
}

// Overridden so that can still be visible if parent is invisible, unless explicitly turned off.
-(BOOL) visible { return _visible; }
@end


#pragma mark -
#pragma mark CC3Fog

@implementation CC3Fog

@synthesize attenuationMode=_attenuationMode, performanceHint=_performanceHint;
@synthesize density=_density, startDistance=_startDistance, endDistance=_endDistance;


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_attenuationMode = GL_EXP2;
		_performanceHint = GL_DONT_CARE;
		_density = 1.0;
		_startDistance = 0.0;
		_endDistance = 1.0;
		self.diffuseColor = kCCC4FLightGray;
		self.shouldDrawInClipSpace = YES;
	}
	return self;
}

+(id) fog { return [[[self alloc] init] autorelease]; }

-(void) populateFrom: (CC3Fog*) another {
	[super populateFrom: another];
	
	_attenuationMode = another.attenuationMode;
	_performanceHint = another.performanceHint;
	_density = another.density;
	_startDistance = another.startDistance;
	_endDistance = another.endDistance;
}


#pragma mark Deprecated functionality

// Deprecated
-(ccColor4F) floatColor { return self.diffuseColor; }
-(void) setFloatColor: (ccColor4F) floatColor { self.diffuseColor = floatColor; }
-(void) update: (CCTime)dt {}

@end



