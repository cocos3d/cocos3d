/*
 * CC3ParametricMeshNodes.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3ParametricMeshNodes.h for full API documentation.
 */

#import "CC3ParametricMeshNodes.h"
#import "CGPointExtension.h"


#pragma mark -
#pragma mark CC3MeshNode parametric shapes extension

@implementation CC3MeshNode (ParametricShapes)


#pragma mark Utility methods

-(CC3Mesh*) prepareParametricMesh {
	if (self.vertexContentTypes == kCC3VertexContentNone) {
		self.vertexContentTypes = (kCC3VertexContentLocation |
								   kCC3VertexContentNormal |
								   kCC3VertexContentTextureCoordinates);
	}
	return _mesh;
}


#pragma mark Populating parametric triangles

-(void) populateAsTriangle: (CC3Face) face
			 withTexCoords: (ccTex2F*) texCoords
		   andTessellation: (GLuint) divsPerSide {
	[[self prepareParametricMesh] populateAsTriangle: face
									   withTexCoords: texCoords
									 andTessellation: divsPerSide];
}


#pragma mark Populating parametric planes

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize {
	[[self prepareParametricMesh] populateAsCenteredRectangleWithSize: rectSize];
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (CC3Tessellation) divsPerAxis {
	[[self prepareParametricMesh] populateAsCenteredRectangleWithSize: rectSize
													  andTessellation: divsPerAxis];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize andRelativeOrigin: (CGPoint) origin {
	[[self prepareParametricMesh] populateAsRectangleWithSize: rectSize andRelativeOrigin: origin];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
				  andRelativeOrigin: (CGPoint) origin
					andTessellation: (CC3Tessellation) divsPerAxis {
	[[self prepareParametricMesh] populateAsRectangleWithSize: rectSize
											andRelativeOrigin: origin
											  andTessellation: divsPerAxis];
}


#pragma mark Populating parametric circular disk

-(void) populateAsDiskWithRadius: (GLfloat) radius andTessellation: (CC3Tessellation) radialAndAngleDivs {
	[[self prepareParametricMesh] populateAsDiskWithRadius: radius andTessellation: radialAndAngleDivs];
}


#pragma mark Populating parametric boxes

-(void) populateAsSolidBox: (CC3BoundingBox) box {
	[[self prepareParametricMesh] populateAsSolidBox: box];
}

-(void) populateAsCubeMappedSolidBox: (CC3BoundingBox) box {
	[[self prepareParametricMesh] populateAsCubeMappedSolidBox: box];
}

-(void) populateAsSolidBox: (CC3BoundingBox) box withCorner: (CGPoint) corner {
	[[self prepareParametricMesh] populateAsSolidBox: box withCorner: corner];
}

-(void) populateAsWireBox: (CC3BoundingBox) box {
	CC3Mesh* mesh = [CC3Mesh mesh];
	[mesh populateAsWireBox: box];
	self.mesh = mesh;		// Set mesh to update bounding volume
}


#pragma mark Populating parametric sphere

// After populating, set spherical bounding volume
-(void) populateAsSphereWithRadius: (GLfloat) radius andTessellation: (CC3Tessellation) divsPerAxis {
	[[self prepareParametricMesh] populateAsSphereWithRadius: radius andTessellation: divsPerAxis];
	self.boundingVolume = [CC3NodeSphericalBoundingVolume boundingVolume];
}


#pragma mark Populating parametric cone

-(void) populateAsHollowConeWithRadius: (GLfloat) radius
								height: (GLfloat) height
					   andTessellation: (CC3Tessellation) angleAndHeightDivs {
	[[self prepareParametricMesh] populateAsHollowConeWithRadius: radius
														  height: height
												 andTessellation: angleAndHeightDivs];
}


#pragma mark Populating parametric lines

-(void) populateAsLineStripWith: (GLuint) vertexCount
					   vertices: (CC3Vector*) vertices
					  andRetain: (BOOL) shouldRetainVertices {
	CC3Mesh* mesh = [CC3Mesh mesh];
	[mesh populateAsLineStripWith: vertexCount
						   vertices: vertices
						  andRetain: shouldRetainVertices];
	self.mesh = mesh;		// Set mesh to update bounding volume
}


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
#pragma mark CC3TouchBox

@implementation CC3TouchBox

@synthesize shouldAlwaysMeasureParentBoundingBox=_shouldAlwaysMeasureParentBoundingBox;

-(CC3BoundingBox) box { return self.localContentBoundingBox; }

-(void) setBox: (CC3BoundingBox) aBox {
	if (CC3BoundingBoxIsNull(aBox)) {
		self.mesh = nil;
	} else {
		[self populateBox: aBox];
	}
}

-(void) setParent: (CC3Node*) aNode {
	super.parent = aNode;
	[self deriveNameFrom: aNode];
	if ( !_mesh ) self.box = self.parentBoundingBox;
}

-(NSString*) nameSuffix { return @"TouchBox"; }

-(CC3BoundingBox) parentBoundingBox { return _parent ? _parent.boundingBox : kCC3BoundingBoxNull; }

-(BOOL) shouldContributeToParentBoundingBox { return NO; }


#pragma mark Population as a box

-(void) populateBox: (CC3BoundingBox) aBox {
	
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
#pragma mark CC3ClipSpaceNode

@implementation CC3ClipSpaceNode


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		[self populateAsCenteredRectangleWithSize: CGSizeMake(2.0f, 2.0f)];
		self.shouldDisableDepthTest = YES;
		self.shouldDisableDepthMask = YES;
	}
	return self;
}

/** Generally, we don't use lighting in clip-space, so turn it off by default. */
-(void) setMaterial: (CC3Material*) aMaterial {
	super.material = aMaterial;
	self.shouldUseLighting = NO;
}

/** The camera frustum has no meaning in clip-space. */
-(CC3NodeBoundingVolume*) defaultBoundingVolume { return [CC3NodeInfiniteBoundingVolume boundingVolume]; }


#pragma mark Allocation and initialization

+(id) nodeWithTexture: (CC3Texture*) texture {
	CC3MeshNode* csn = [self node];
	csn.texture = texture;
	return csn;
}

+(id) nodeWithColor: (ccColor4F) color {
	CC3MeshNode* csn = [self node];
	csn.pureColor = color;
	return csn;
}

@end


#pragma mark -
#pragma mark Deprecated CC3MeshNode parametric shapes

@implementation CC3MeshNode (DeprecatedParametricShapes)

#define CC3RelOrigin(pivot, rectSize) ccp((pivot).x / (rectSize).width, (pivot).y / (rectSize).height)

// Deprecated
-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	[self populateAsRectangleWithSize: rectSize andRelativeOrigin: CC3RelOrigin(pivot, rectSize)];
}

// Deprecated
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (CC3Tessellation) divsPerAxis {
	[self populateAsRectangleWithSize: rectSize
					andRelativeOrigin: CC3RelOrigin(pivot, rectSize)
					  andTessellation: divsPerAxis];
}

// Deprecated
-(void) deprecatedPopulateAsRectangleWithSize: (CGSize) rectSize
									 andPivot: (CGPoint) pivot
							  andTessellation: (CC3Tessellation) divsPerAxis
								  withTexture: (CC3Texture*) texture
								invertTexture: (BOOL) shouldInvert {
	
	// Populate the mesh, attach the texture
	[self populateAsRectangleWithSize: rectSize
					andRelativeOrigin: CC3RelOrigin(pivot, rectSize)
					  andTessellation: divsPerAxis];
	self.texture = texture;
	
	// Align the texture coordinates to the texture.
	// Texture inversion is now  automatic in population methods, so reverse the logic.
	if (!shouldInvert) {
		[self flipTexturesVertically];
	}
}

// Deprecated
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert {
	[self deprecatedPopulateAsRectangleWithSize: rectSize
									   andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
								andTessellation: CC3TessellationMake(1, 1)
									withTexture: texture
								  invertTexture: shouldInvert];
}

// Deprecated
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (CC3Tessellation) divsPerAxis
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert {
	[self deprecatedPopulateAsRectangleWithSize: rectSize
									   andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
								andTessellation: divsPerAxis
									withTexture: texture
								  invertTexture: shouldInvert];
}

// Deprecated
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert {
	[self deprecatedPopulateAsRectangleWithSize: rectSize
									   andPivot: pivot
								andTessellation: CC3TessellationMake(1, 1)
									withTexture: texture
								  invertTexture: shouldInvert];
}

// Deprecated
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (CC3Tessellation) divsPerAxis
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert {
	[self deprecatedPopulateAsRectangleWithSize: rectSize
									   andPivot: pivot
								andTessellation: divsPerAxis
									withTexture: texture
								  invertTexture: shouldInvert];
}

// Deprecated
-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize {
	[self populateAsCenteredRectangleWithSize: rectSize];
}

// Deprecated
-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize
									andTessellation: (CC3Tessellation) divsPerAxis {
	[self populateAsCenteredRectangleWithSize: rectSize andTessellation: divsPerAxis];
}

// Deprecated
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	[self populateAsRectangleWithSize: rectSize andRelativeOrigin: CC3RelOrigin(pivot, rectSize)];
}

// Deprecated
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize
								   andPivot: (CGPoint) pivot
							andTessellation: (CC3Tessellation) divsPerAxis {
	[self populateAsRectangleWithSize: rectSize
					andRelativeOrigin: CC3RelOrigin(pivot, rectSize)
					  andTessellation: divsPerAxis];
}

// Deprecated
-(void) populateAsTexturedBox: (CC3BoundingBox) box {
	[self populateAsSolidBox: box withCorner: ccp((1.0 / 4.0), (1.0 / 3.0))];
}

// Deprecated
-(void) populateAsTexturedBox: (CC3BoundingBox) box withCorner: (CGPoint) corner {
	[self populateAsSolidBox: box withCorner: corner];
}

@end

