/*
 * CC3ParametricMeshNodes.m
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

-(void) populateAsSolidBox: (CC3Box) box {
	[[self prepareParametricMesh] populateAsSolidBox: box];
}

-(void) populateAsCubeMappedSolidBox: (CC3Box) box {
	[[self prepareParametricMesh] populateAsCubeMappedSolidBox: box];
}

-(void) populateAsSolidBox: (CC3Box) box withCorner: (CGPoint) corner {
	[[self prepareParametricMesh] populateAsSolidBox: box withCorner: corner];
}

-(void) populateAsWireBox: (CC3Box) box {
	CC3Mesh* mesh = [CC3Mesh mesh];
	[mesh populateAsWireBox: box];
	self.mesh = mesh;		// Set mesh to update bounding volume
}


#pragma mark Populating parametric sphere

// After populating, set spherical bounding volume
-(void) populateAsSphereWithRadius: (GLfloat) radius andTessellation: (CC3Tessellation) divsPerAxis {
	[[self prepareParametricMesh] populateAsSphereWithRadius: radius andTessellation: divsPerAxis];
//	self.boundingVolume = [CC3NodeSphericalBoundingVolume boundingVolume];
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
-(void) populateAsTexturedBox: (CC3Box) box {
	[self populateAsSolidBox: box withCorner: ccp((1.0 / 4.0), (1.0 / 3.0))];
}

// Deprecated
-(void) populateAsTexturedBox: (CC3Box) box withCorner: (CGPoint) corner {
	[self populateAsSolidBox: box withCorner: corner];
}

@end

