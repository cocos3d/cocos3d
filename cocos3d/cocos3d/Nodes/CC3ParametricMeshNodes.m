/*
 * CC3ParametricMeshNodes.m
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
 * See header file CC3ParametricMeshNodes.h for full API documentation.
 */

#import "CC3ParametricMeshNodes.h"
#import "CGPointExtension.h"


#pragma mark -
#pragma mark CC3MeshNode parametric shapes extension

@implementation CC3MeshNode (ParametricShapes)


#pragma mark Utility methods

-(CC3VertexArrayMesh*) prepareParametricMesh {
	if (self.vertexContentTypes == kCC3VertexContentNone) {
		self.vertexContentTypes = (kCC3VertexContentLocation |
								   kCC3VertexContentNormal |
								   kCC3VertexContentTextureCoordinates);
	}
	NSAssert1([mesh isKindOfClass: [CC3VertexArrayMesh class]], @"For parametric construction, the mesh property of %@ must be an instance of CC3VertexArrayMesh.", self);
	return (CC3VertexArrayMesh*) mesh;
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
							andTessellation: (ccGridSize) divsPerAxis {
	[[self prepareParametricMesh] populateAsCenteredRectangleWithSize: rectSize
													  andTessellation: divsPerAxis];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize andRelativeOrigin: (CGPoint) origin {
	[[self prepareParametricMesh] populateAsRectangleWithSize: rectSize andRelativeOrigin: origin];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
				  andRelativeOrigin: (CGPoint) origin
					andTessellation: (ccGridSize) divsPerAxis {
	[[self prepareParametricMesh] populateAsRectangleWithSize: rectSize
											andRelativeOrigin: origin
											  andTessellation: divsPerAxis];
}


#pragma mark Populating parametric circular disk

-(void) populateAsDiskWithRadius: (GLfloat) radius andTessellation: (ccGridSize) radialAndAngleDivs {
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
	CC3VertexArrayMesh* vaMesh = [CC3VertexArrayMesh mesh];
	[vaMesh populateAsWireBox: box];
	self.mesh = vaMesh;		// Set mesh to update bounding volume
}


#pragma mark Populating parametric sphere

// After populating, set spherical bounding volume
-(void) populateAsSphereWithRadius: (GLfloat) radius andTessellation: (ccGridSize) divsPerAxis {
	[[self prepareParametricMesh] populateAsSphereWithRadius: radius andTessellation: divsPerAxis];
	self.boundingVolume = [CC3VertexLocationsSphericalBoundingVolume boundingVolume];
}


#pragma mark Populating parametric cone

-(void) populateAsHollowConeWithRadius: (GLfloat) radius
								height: (GLfloat) height
					   andTessellation: (ccGridSize) angleAndHeightDivs {
	[[self prepareParametricMesh] populateAsHollowConeWithRadius: radius
														  height: height
												 andTessellation: angleAndHeightDivs];
}


#pragma mark Populating parametric lines

-(void) populateAsLineStripWith: (GLuint) vertexCount
					   vertices: (CC3Vector*) vertices
					  andRetain: (BOOL) shouldRetainVertices {
	CC3VertexArrayMesh* vaMesh = [CC3VertexArrayMesh mesh];
	[vaMesh populateAsLineStripWith: vertexCount
						   vertices: vertices
						  andRetain: shouldRetainVertices];
	self.mesh = vaMesh;		// Set mesh to update bounding volume
}


#pragma mark Populating for bitmapped font textures

-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
							   fromFontFile: (NSString*) fontFileName
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (UITextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (ccGridSize) divsPerChar {
	
	CC3BMFontConfiguration* fontConfig = [CC3BMFontConfiguration configurationFromFontFile: fontFileName];
	
	[[self prepareParametricMesh] populateAsBitmapFontLabelFromString: lblString
															  andFont: fontConfig
														andLineHeight: lineHeight
													 andTextAlignment: textAlignment
													andRelativeOrigin: origin
													  andTessellation: divsPerChar];

	// Set texture after mesh to avoid mesh setter from clearing texture
	self.texture = [CC3Texture textureFromFile: fontConfig->atlasName_];

	// By definition, characters have significant transparency, so turn alpha blending on.
	// Since characters can overlap with kerning, don't draw the transparent parts to avoid Z-fighting
	// between the characters. Set the alpha tolerance higher than zero so that non-zero alpha at
	// character edges due to anti-aliasing won't be drawn.
	self.isOpaque = NO;
	self.shouldDrawLowAlpha = NO;
	self.material.alphaTestReference = 0.05;
}

@end


#pragma mark -
#pragma mark CC3SimpleLineNode

@implementation CC3SimpleLineNode {
	CC3Vector lineVertices[2];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		lineVertices[0] = kCC3VectorZero;
		lineVertices[1] = kCC3VectorZero;
		[self populateAsLineStripWith: 2 vertices: lineVertices andRetain: NO];
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

@interface CC3TouchBox (TemplateMethods)
@property(nonatomic, readonly) CC3BoundingBox parentBoundingBox;
-(void) populateBox: (CC3BoundingBox) aBox;

@end

@implementation CC3TouchBox

@synthesize shouldAlwaysMeasureParentBoundingBox;

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
	if ( !mesh ) self.box = self.parentBoundingBox;
}

-(NSString*) nameSuffix { return @"TouchBox"; }

-(CC3BoundingBox) parentBoundingBox { return parent ? parent.boundingBox : kCC3BoundingBoxNull; }

-(BOOL) shouldContributeToParentBoundingBox { return NO; }


#pragma mark Population as a box

-(void) populateBox: (CC3BoundingBox) aBox {
	
	CC3VertexArrayMesh* vaMesh = [self prepareParametricMesh];
	
	// Now update the vertex locations with the box data
	GLuint vIdx = 0;
	CC3Vector bbMin = aBox.minimum;
	CC3Vector bbMax = aBox.maximum;
	[vaMesh setVertexLocation: cc3v(bbMin.x, bbMin.y, bbMin.z) at: vIdx++];
	[vaMesh setVertexLocation: cc3v(bbMin.x, bbMin.y, bbMax.z) at: vIdx++];
	[vaMesh setVertexLocation: cc3v(bbMin.x, bbMax.y, bbMin.z) at: vIdx++];
	[vaMesh setVertexLocation: cc3v(bbMin.x, bbMax.y, bbMax.z) at: vIdx++];
	[vaMesh setVertexLocation: cc3v(bbMax.x, bbMin.y, bbMin.z) at: vIdx++];
	[vaMesh setVertexLocation: cc3v(bbMax.x, bbMin.y, bbMax.z) at: vIdx++];
	[vaMesh setVertexLocation: cc3v(bbMax.x, bbMax.y, bbMin.z) at: vIdx++];
	[vaMesh setVertexLocation: cc3v(bbMax.x, bbMax.y, bbMax.z) at: vIdx++];

	[vaMesh updateVertexLocationsGLBuffer];
	[self markBoundingVolumeDirty];
}

/** Overridden because we only need vertex locations, and to allocate and populate indices. */
-(CC3VertexArrayMesh*) prepareParametricMesh {
	if (mesh) return (CC3VertexArrayMesh*)mesh;
	
	if (self.vertexContentTypes == kCC3VertexContentNone) {
		self.vertexContentTypes = kCC3VertexContentLocation;
	}
	CC3VertexArrayMesh* vaMesh = (CC3VertexArrayMesh*)mesh;
	
	// Prepare the vertex content and allocate space for vertices and indices.
	vaMesh.allocatedVertexCapacity = 8;
	vaMesh.allocatedVertexIndexCapacity = 36;
	
	GLuint vIdx = 0;
	
	// Front
	[vaMesh setVertexIndex: 1 at: vIdx++];
	[vaMesh setVertexIndex: 5 at: vIdx++];
	[vaMesh setVertexIndex: 7 at: vIdx++];
	[vaMesh setVertexIndex: 7 at: vIdx++];
	[vaMesh setVertexIndex: 3 at: vIdx++];
	[vaMesh setVertexIndex: 1 at: vIdx++];
	
	// Back
	[vaMesh setVertexIndex: 0 at: vIdx++];
	[vaMesh setVertexIndex: 2 at: vIdx++];
	[vaMesh setVertexIndex: 6 at: vIdx++];
	[vaMesh setVertexIndex: 6 at: vIdx++];
	[vaMesh setVertexIndex: 4 at: vIdx++];
	[vaMesh setVertexIndex: 0 at: vIdx++];
	
	// Left
	[vaMesh setVertexIndex: 0 at: vIdx++];
	[vaMesh setVertexIndex: 1 at: vIdx++];
	[vaMesh setVertexIndex: 3 at: vIdx++];
	[vaMesh setVertexIndex: 3 at: vIdx++];
	[vaMesh setVertexIndex: 2 at: vIdx++];
	[vaMesh setVertexIndex: 0 at: vIdx++];
	
	// Right
	[vaMesh setVertexIndex: 4 at: vIdx++];
	[vaMesh setVertexIndex: 6 at: vIdx++];
	[vaMesh setVertexIndex: 7 at: vIdx++];
	[vaMesh setVertexIndex: 7 at: vIdx++];
	[vaMesh setVertexIndex: 5 at: vIdx++];
	[vaMesh setVertexIndex: 4 at: vIdx++];
	
	// Top
	[vaMesh setVertexIndex: 2 at: vIdx++];
	[vaMesh setVertexIndex: 3 at: vIdx++];
	[vaMesh setVertexIndex: 7 at: vIdx++];
	[vaMesh setVertexIndex: 7 at: vIdx++];
	[vaMesh setVertexIndex: 6 at: vIdx++];
	[vaMesh setVertexIndex: 2 at: vIdx++];
	
	// Bottom
	[vaMesh setVertexIndex: 0 at: vIdx++];
	[vaMesh setVertexIndex: 4 at: vIdx++];
	[vaMesh setVertexIndex: 5 at: vIdx++];
	[vaMesh setVertexIndex: 5 at: vIdx++];
	[vaMesh setVertexIndex: 1 at: vIdx++];
	[vaMesh setVertexIndex: 0 at: vIdx++];		

	return vaMesh;
}


#pragma mark Updating

/** If we should remeasure and update the bounding box dimensions, do so. */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	if (shouldAlwaysMeasureParentBoundingBox) self.box = self.parentBoundingBox;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		shouldAlwaysMeasureParentBoundingBox = NO;
		self.visible = NO;
		self.shouldAllowTouchableWhenInvisible = YES;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3BitmapLabelNode

@interface CC3BitmapLabelNode (TemplateMethods)
-(void) populateLabelMesh;
@end

@implementation CC3BitmapLabelNode

-(void) dealloc {
	[labelString release];
	[fontFileName release];
	[fontConfig release];
	[super dealloc];
}

-(GLfloat) lineHeight { return lineHeight ? lineHeight : fontConfig->commonHeight_; }

-(void) setLineHeight: (GLfloat) lineHt {
	if (lineHt != lineHeight) {
		lineHeight = lineHt;
		[self populateLabelMesh];
	}
}

-(NSString*) labelString { return labelString; }

-(void) setLabelString: (NSString*) aString {
	if ( ![aString isEqualToString: labelString] ) {
		[labelString release];
		labelString = [aString retain];
		[self populateLabelMesh];
	}
}

-(NSString*) fontFileName { return fontFileName; }

-(void) setFontFileName: (NSString*) aFileName {
	if ( ![aFileName isEqualToString: fontFileName] ) {
		[fontFileName release];
		fontFileName = [aFileName retain];

		[fontConfig release];
		fontConfig = [[CC3BMFontConfiguration configurationFromFontFile: fontFileName] retain];

		[self populateLabelMesh];
	}
}

-(UITextAlignment) textAlignment { return textAlignment; }

-(void) setTextAlignment: (UITextAlignment) alignment {
	if (alignment != textAlignment) {
		textAlignment = alignment;
		[self populateLabelMesh];
	}
}

-(CGPoint) relativeOrigin { return relativeOrigin; }

-(void) setRelativeOrigin: (CGPoint) relOrigin {
	if ( !CGPointEqualToPoint(relOrigin, relativeOrigin) ) {
		relativeOrigin = relOrigin;
		[self populateLabelMesh];
	}
}

-(ccGridSize) tessellation { return tessellation; }

-(void) setTessellation: (ccGridSize) aGrid {
	if ( !((aGrid.x == tessellation.x) && (aGrid.y == tessellation.y)) ) {
		tessellation = aGrid;
		[self populateLabelMesh];
	}
}

-(GLfloat) fontSize { return fontConfig ? fontConfig->fontSize : 0; }

-(GLfloat) baseline {
	if ( !fontConfig ) return 0.0f;
	return 1.0f - (GLfloat)fontConfig->baseline / (GLfloat)fontConfig->commonHeight_;
}

#pragma mark Mesh population

-(void) populateLabelMesh {
	if (fontFileName && labelString) {
		[self populateAsBitmapFontLabelFromString: self.labelString
									 fromFontFile: self.fontFileName
									andLineHeight: self.lineHeight
								 andTextAlignment: self.textAlignment
								andRelativeOrigin: self.relativeOrigin
								  andTessellation: self.tessellation];
		[self markBoundingVolumeDirty];
		if (mesh.isUsingGLBuffers) {
			[mesh deleteGLBuffers];
			[mesh createGLBuffers];
		}
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		labelString = @"hello, world";		// Fail-safe to display if nothing set
		fontFileName = nil;
		fontConfig = nil;
		lineHeight = 0;
		textAlignment = UITextAlignmentLeft;
		relativeOrigin = ccp(0,0);
		tessellation = ccg(1,1);
	}
	return self;
}

-(void) populateFrom: (CC3BitmapLabelNode*) another {
	[super populateFrom: another];

	relativeOrigin = another.relativeOrigin;
	textAlignment = another.textAlignment;
	tessellation = another.tessellation;
	lineHeight = another.lineHeight;
	self.fontFileName = another.fontFileName;
	self.labelString = another.labelString;		// Will trigger repopulation
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ '%@'", super.description, self.labelString];
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
					andTessellation: (ccGridSize) divsPerAxis {
	[self populateAsRectangleWithSize: rectSize
					andRelativeOrigin: CC3RelOrigin(pivot, rectSize)
					  andTessellation: divsPerAxis];
}

// Deprecated
-(void) deprecatedPopulateAsRectangleWithSize: (CGSize) rectSize
									 andPivot: (CGPoint) pivot
							  andTessellation: (ccGridSize) divsPerAxis
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
								andTessellation: ccg(1, 1)
									withTexture: texture
								  invertTexture: shouldInvert];
}

// Deprecated
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) divsPerAxis
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
								andTessellation: ccg(1, 1)
									withTexture: texture
								  invertTexture: shouldInvert];
}

// Deprecated
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) divsPerAxis
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
									andTessellation: (ccGridSize) divsPerAxis {
	[self populateAsCenteredRectangleWithSize: rectSize andTessellation: divsPerAxis];
}

// Deprecated
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	[self populateAsRectangleWithSize: rectSize andRelativeOrigin: CC3RelOrigin(pivot, rectSize)];
}

// Deprecated
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize
								   andPivot: (CGPoint) pivot
							andTessellation: (ccGridSize) divsPerAxis {
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

