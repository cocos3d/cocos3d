/*
 * CC3ParametricMeshNodes.m
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
 * See header file CC3ParametricMeshNodes.h for full API documentation.
 */

#import "CC3ParametricMeshNodes.h"
#import "CGPointExtension.h"
#import "CC3VertexArrayMesh.h"



#pragma mark -
#pragma mark CC3MeshNode parametric shapes extension

@implementation CC3MeshNode (ParametricShapes)


#pragma mark Populating parametric planes

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0f, rectSize.height / 2.0f)];
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) facesPerSide {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0f, rectSize.height / 2.0f)
					  andTessellation: facesPerSide];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	[self populateAsRectangleWithSize: rectSize andPivot: pivot andTessellation: ccg(1, 1)];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide {
	NSString* itemName;
	CC3TexturedVertex* vertices;		// Array of custom structures to hold the interleaved vertex data
	
	// Must be at least one tessellation face per side of the rectangle.
	facesPerSide.x = MAX(facesPerSide.x, 1);
	facesPerSide.y = MAX(facesPerSide.y, 1);

	// Move the origin of the rectangle to the pivot point
	CGPoint botLeft = ccpSub(CGPointZero, pivot);
	CGPoint topRight = ccpSub(ccpFromSize(rectSize), pivot);

	// The size of each face in the tessellated grid
	CGSize faceSize = CGSizeMake((topRight.x - botLeft.x) / facesPerSide.x,
								 (topRight.y - botLeft.y) / facesPerSide.y);

	// Get vertices per side.
	ccGridSize verticesPerSide;
	verticesPerSide.x = facesPerSide.x + 1;
	verticesPerSide.y = facesPerSide.y + 1;
	int vertexCount = verticesPerSide.x * verticesPerSide.y;
	
	// Interleave the vertex locations, normals and tex coords
	// Create vertex location array, allocating enough space for the stride of the full structure
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	locArray.elementStride = sizeof(CC3TexturedVertex);	// Set stride before allocating elements.
	locArray.elementOffset = 0;							// Offset to location element in vertex structure
	vertices = [locArray allocateElements: vertexCount];
	
	// Create the normal array interleaved on the same element array
	itemName = [NSString stringWithFormat: @"%@-Normals", self.name];
	CC3VertexNormals* normArray = [CC3VertexNormals vertexArrayWithName: itemName];
	normArray.elements = vertices;
	normArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
	normArray.elementCount = vertexCount;
	normArray.elementOffset = sizeof(CC3Vector);		// Offset to normal element in vertex structure

	// Populate vertex locations and normals in the X-Y plane
	// Iterate through the rows and columns of the vertex grid, from the bottom left corner,
	// and set the location of each vertex to be proportional to its position in the grid,
	// and set the normal of each vertex to point up the Z-axis.
	for (int iy = 0; iy < verticesPerSide.y; iy++) {
		for (int ix = 0; ix < verticesPerSide.x; ix++) {
			int vIndx = iy * verticesPerSide.x + ix;
			GLfloat vx = botLeft.x + (faceSize.width * ix);
			GLfloat vy = botLeft.y + (faceSize.height * iy);
			vertices[vIndx].location = cc3v(vx, vy, 0.0);
			vertices[vIndx].normal = kCC3VectorUnitZPositive;
		}
	}
	
	// Construct the vertex indices that will draw the triangles that make up each
	// face of the box. Indices are ordered for each of the six faces starting in
	// the lower left corner and proceeding counter-clockwise.
	GLuint triangleCount = facesPerSide.x * facesPerSide.y * 2;
	GLuint indexCount = triangleCount * 3;
	itemName = [NSString stringWithFormat: @"%@-Indices", self.name];
	CC3VertexIndices* indexArray = [CC3VertexIndices vertexArrayWithName: itemName];
	indexArray.drawingMode = GL_TRIANGLES;
	indexArray.elementType = GL_UNSIGNED_SHORT;
	indexArray.elementCount = indexCount;
	GLushort* indices = [indexArray allocateElements: indexCount];
	
	// Iterate through the rows and columns of the faces in the grid, from the bottom left corner,
	// and specify the indexes of the three vertices in each of the two triangles of each face.
	int iIndx = 0;
	for (int iy = 0; iy < facesPerSide.y; iy++) {
		for (int ix = 0; ix < facesPerSide.x; ix++) {
			GLushort botLeftOfFace;
			
			// First triangle of face wound counter-clockwise
			botLeftOfFace = iy * verticesPerSide.x + ix;
			indices[iIndx++] = botLeftOfFace;							// Bottom left
			indices[iIndx++] = botLeftOfFace + 1;						// Bot right
			indices[iIndx++] = botLeftOfFace + verticesPerSide.x + 1;	// Top right

			// Second triangle of face wound counter-clockwise
			indices[iIndx++] = botLeftOfFace + verticesPerSide.x + 1;	// Top right
			indices[iIndx++] = botLeftOfFace + verticesPerSide.x;		// Top left
			indices[iIndx++] = botLeftOfFace;							// Bottom left
		}
	}
	
	// Create mesh with interleaved vertex arrays
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* aMesh = [CC3VertexArrayMesh meshWithName: itemName];
	aMesh.interleaveVertices = YES;
	aMesh.vertexLocations = locArray;
	aMesh.vertexNormals = normArray;
	aMesh.vertexIndices = indexArray;
	self.mesh = aMesh;
}

-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize {
	[self populateAsTexturedRectangleWithSize: rectSize
									 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)];
}

-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize
									andTessellation: (ccGridSize) facesPerSide {
	[self populateAsTexturedRectangleWithSize: rectSize
									 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
							  andTessellation: facesPerSide];
}

-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	[self populateAsTexturedRectangleWithSize: rectSize andPivot: pivot andTessellation: ccg(1, 1)];
}

-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize
								   andPivot: (CGPoint) pivot
							andTessellation: (ccGridSize) facesPerSide {
	NSString* itemName;
	
	// Must be at least one tessellation face per side of the rectangle.
	facesPerSide.x = MAX(facesPerSide.x, 1);
	facesPerSide.y = MAX(facesPerSide.y, 1);
	
	// The size of each face in the tessellated grid
	CGSize faceSize = CGSizeMake((1.0 / facesPerSide.x), (1.0 / facesPerSide.y));
	
	// Get vertices per side.
	ccGridSize verticesPerSide;
	verticesPerSide.x = facesPerSide.x + 1;
	verticesPerSide.y = facesPerSide.y + 1;
	
	// Start as a basic white rectangle of the right size and location.
	[self populateAsRectangleWithSize: rectSize andPivot: pivot andTessellation: facesPerSide];
	
	// Get my aMesh model and vertices.
	CC3VertexArrayMesh* vam = (CC3VertexArrayMesh*)self.mesh; 
	CC3VertexLocations* locArray = vam.vertexLocations;
	
	// Create the tex coord array interleaved on the same element array as the vertex locations
	CC3VertexTextureCoordinates* tcArray = nil;
	itemName = [NSString stringWithFormat: @"%@-Texture", self.name];
	tcArray = [CC3VertexTextureCoordinates vertexArrayWithName: itemName];
	tcArray.elements = locArray.elements;
	tcArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
	tcArray.elementCount = locArray.elementCount;
	tcArray.elementOffset = 2 * sizeof(CC3Vector);	// Offset to texcoord element in vertex structure
	
	// Add the texture coordinates array to the mesh
	vam.vertexTextureCoordinates = tcArray;
	
	// Populate the texture coordinate array mapping
	CC3TexturedVertex* vertices = locArray.elements;
	
	// Iterate through the rows and columns of the vertex grid, from the bottom left corner,
	// and set the X & Y texture coordinate of each vertex to be proportional to its position
	// in the grid.
	for (int iy = 0; iy < verticesPerSide.y; iy++) {
		for (int ix = 0; ix < verticesPerSide.x; ix++) {
			int vIndx = iy * verticesPerSide.x + ix;
			GLfloat vx = faceSize.width * ix;
			GLfloat vy = faceSize.height * iy;
			vertices[vIndx].texCoord = (ccTex2F){vx, vy};
		}
	}
}


#pragma mark Deprecated parametric plane methods

-(void) deprecatedPopulateAsRectangleWithSize: (CGSize) rectSize
									 andPivot: (CGPoint) pivot
							  andTessellation: (ccGridSize) facesPerSide
								  withTexture: (CC3Texture*) texture
								invertTexture: (BOOL) shouldInvert {
	
	// Populate the mesh, attach the texture
	[self populateAsTexturedRectangleWithSize: rectSize
									 andPivot: pivot
							  andTessellation: facesPerSide];
	self.texture = texture;
	
	// Align the texture coordinates to the texture
	if (shouldInvert) {
		[self alignInvertedTextures];
	} else {
		[self alignTextures];
	}
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert {
	[self deprecatedPopulateAsRectangleWithSize: rectSize
									   andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
								andTessellation: ccg(1, 1)
									withTexture: texture
								  invertTexture: shouldInvert];
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) facesPerSide
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert {
	[self deprecatedPopulateAsRectangleWithSize: rectSize
									   andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
								andTessellation: facesPerSide
									withTexture: texture
								  invertTexture: shouldInvert];
}

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

-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert {
	[self deprecatedPopulateAsRectangleWithSize: rectSize
									   andPivot: pivot
								andTessellation: facesPerSide
									withTexture: texture
								  invertTexture: shouldInvert];
}


#pragma mark Populating parametric boxes

// Index data for the triangles covering the six faces of a solid box.
static const GLubyte solidBoxIndexData[] = {
	1, 5, 7, 7, 3, 1,
	0, 1, 3, 3, 2, 0,
	4, 0, 2, 2, 6, 4,
	5, 4, 6, 6, 7, 5,
	3, 7, 6, 6, 2, 3,
	0, 4, 5, 5, 1, 0,
};

-(void) populateAsSolidBox: (CC3BoundingBox) box {
	NSString* itemName;
	CC3TexturedVertex* vertices;		// Array of custom structures to hold the interleaved vertex data
	CC3Vector boxMin = box.minimum;
	CC3Vector boxMax = box.maximum;
	GLuint vertexCount = 8;
	
	// Create vertexLocation array.
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	locArray.elementStride = sizeof(CC3TexturedVertex);	// Set stride before allocating elements.
	locArray.elementOffset = 0;							// Offset to location element in vertex structure
	vertices = [locArray allocateElements: vertexCount];
	
	// Extract all 8 corner vertices from the box.
	vertices[0].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[1].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[2].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[3].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[4].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[5].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[6].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[7].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
	
	// Create the normal array interleaved on the same element array
	itemName = [NSString stringWithFormat: @"%@-Normals", self.name];
	CC3VertexNormals* normArray = [CC3VertexNormals vertexArrayWithName: itemName];
	normArray.elements = vertices;
	normArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
	normArray.elementCount = vertexCount;
	normArray.elementOffset = sizeof(CC3Vector);		// Offset to normal element in vertex structure

	// Since this is a box, and all sides meet at right angles, all components
	// of all normals will have a value of either positive or negative (1 / sqrt(3)).
	GLfloat oort = 1.0f / M_SQRT3;		// One-over-root-three
	
	// Populate normals diagonally from each corner of the box
	vertices[0].normal = cc3v(-oort, -oort, -oort);
	vertices[1].normal = cc3v(-oort, -oort,  oort);
	vertices[2].normal = cc3v(-oort,  oort, -oort);
	vertices[3].normal = cc3v(-oort,  oort,  oort);
	vertices[4].normal = cc3v( oort, -oort, -oort);
	vertices[5].normal = cc3v( oort, -oort,  oort);
	vertices[6].normal = cc3v( oort,  oort, -oort);
	vertices[7].normal = cc3v( oort,  oort,  oort);
	
	// Construct the vertex indices that will draw the triangles that make up each
	// face of the box. Indices are ordered for each of the six faces starting in
	// the lower left corner and proceeding counter-clockwise.
	GLuint triangleCount = 12;
	GLuint indexCount = triangleCount * 3;
	itemName = [NSString stringWithFormat: @"%@-Indices", self.name];
	CC3VertexIndices* indexArray = [CC3VertexIndices vertexArrayWithName: itemName];
	indexArray.drawingMode = GL_TRIANGLES;
	indexArray.elementType = GL_UNSIGNED_BYTE;
	indexArray.elementCount = indexCount;
	indexArray.elements = (GLvoid*)solidBoxIndexData;
	
	// Create mesh with interleaved vertex arrays
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* aMesh = [CC3VertexArrayMesh meshWithName: itemName];
	aMesh.interleaveVertices = YES;
	aMesh.vertexLocations = locArray;
	aMesh.vertexNormals = normArray;
	aMesh.vertexIndices = indexArray;
	self.mesh = aMesh;
}

-(void) populateAsTexturedBox: (CC3BoundingBox) box {
	[self populateAsTexturedBox: box withCorner: ccp((1.0 / 4.0), (1.0 / 3.0))];
}

// Thanks to cocos3d user andyman for contributing the prototype code and texture
// template file for this method.
-(void) populateAsTexturedBox: (CC3BoundingBox) box withCorner: (CGPoint) corner {
	NSString* itemName;
	CC3TexturedVertex* vertices;		// Array of custom structures to hold the interleaved vertex data
	CC3Vector boxMin = box.minimum;
	CC3Vector boxMax = box.maximum;
	GLuint vertexCount = 24;
	
	// Create vertexLocation array.
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	locArray.elementStride = sizeof(CC3TexturedVertex);	// Set stride before allocating elements.
	locArray.elementOffset = 0;							// Offset to location element in vertex structure
	vertices = [locArray allocateElements: vertexCount];
	
	// Create the normal array interleaved on the same element array
	itemName = [NSString stringWithFormat: @"%@-Normals", self.name];
	CC3VertexNormals* normArray = [CC3VertexNormals vertexArrayWithName: itemName];
	normArray.elements = vertices;
	normArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
	normArray.elementCount = vertexCount;
	normArray.elementOffset = sizeof(CC3Vector);		// Offset to normal element in vertex structure
	
	// Create the tex coord array interleaved on the same element array as the vertex locations
	CC3VertexTextureCoordinates* tcArray = nil;
	itemName = [NSString stringWithFormat: @"%@-Texture", self.name];
	tcArray = [CC3VertexTextureCoordinates vertexArrayWithName: itemName];
	tcArray.elements = vertices;
	tcArray.elementStride = locArray.elementStride;		// Interleaved...so same stride
	tcArray.elementCount = vertexCount;
	tcArray.elementOffset = 2 * sizeof(CC3Vector);		// Offset to texCoord element in vertex structure
	
	// Front face, CCW winding:
	vertices[0].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[0].normal = kCC3VectorUnitZPositive;
	vertices[0].texCoord = (ccTex2F){corner.x, corner.y};
	
	vertices[1].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[1].normal = kCC3VectorUnitZPositive;
	vertices[1].texCoord = (ccTex2F){0.5f, corner.y};
	
	vertices[2].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
	vertices[2].normal = kCC3VectorUnitZPositive;
	vertices[2].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
	
	vertices[3].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[3].normal = kCC3VectorUnitZPositive;
	vertices[3].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
	
	// Right face, CCW winding:
	vertices[4].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[4].normal = kCC3VectorUnitXPositive;
	vertices[4].texCoord = (ccTex2F){0.5f, corner.y};
	
	vertices[5].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[5].normal = kCC3VectorUnitXPositive;
	vertices[5].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
	
	vertices[6].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[6].normal = kCC3VectorUnitXPositive;
	vertices[6].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
	
	vertices[7].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
	vertices[7].normal = kCC3VectorUnitXPositive;
	vertices[7].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
	
	// Back face, CCW winding:
	vertices[8].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[8].normal = kCC3VectorUnitZNegative;
	vertices[8].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
	
	vertices[9].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[9].normal = kCC3VectorUnitZNegative;
	vertices[9].texCoord = (ccTex2F){1.0f, corner.y};
	
	vertices[10].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[10].normal = kCC3VectorUnitZNegative;
	vertices[10].texCoord = (ccTex2F){1.0f, (1.0f - corner.y)};
	
	vertices[11].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[11].normal = kCC3VectorUnitZNegative;
	vertices[11].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
	
	// Left face, CCW winding:
	vertices[12].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[12].normal = kCC3VectorUnitXNegative;
	vertices[12].texCoord = (ccTex2F){0.0f, corner.y};
	
	vertices[13].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[13].normal = kCC3VectorUnitXNegative;
	vertices[13].texCoord = (ccTex2F){corner.x, corner.y};
	
	vertices[14].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[14].normal = kCC3VectorUnitXNegative;
	vertices[14].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
	
	vertices[15].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[15].normal = kCC3VectorUnitXNegative;
	vertices[15].texCoord = (ccTex2F){0.0f, (1.0f - corner.y)};
	
	// Top face, CCW winding:
	vertices[16].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[16].normal = kCC3VectorUnitYPositive;
	vertices[16].texCoord = (ccTex2F){corner.x, 1.0f};
	
	vertices[17].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[17].normal = kCC3VectorUnitYPositive;
	vertices[17].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
	
	vertices[18].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
	vertices[18].normal = kCC3VectorUnitYPositive;
	vertices[18].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
	
	vertices[19].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[19].normal = kCC3VectorUnitYPositive;
	vertices[19].texCoord = (ccTex2F){0.5f, 1.0f};
	
	// Bottom face, CCW winding:
	vertices[20].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[20].normal = kCC3VectorUnitYNegative;
	vertices[20].texCoord = (ccTex2F){corner.x, corner.y};
	
	vertices[21].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[21].normal = kCC3VectorUnitYNegative;
	vertices[21].texCoord = (ccTex2F){corner.x, 0.0f};
	
	vertices[22].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[22].normal = kCC3VectorUnitYNegative;
	vertices[22].texCoord = (ccTex2F){0.5f, 0.0f};
	
	vertices[23].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[23].normal = kCC3VectorUnitYNegative;
	vertices[23].texCoord = (ccTex2F){0.5f, corner.y};
	
	// Construct the vertex indices that will draw the triangles that make up each
	// face of the box. Indices are ordered for each of the six faces starting in
	// the lower left corner and proceeding counter-clockwise.
	GLuint triangleCount = 12;
	GLuint indexCount = triangleCount * 3;
	itemName = [NSString stringWithFormat: @"%@-Indices", self.name];
	CC3VertexIndices* indexArray = [CC3VertexIndices vertexArrayWithName: itemName];
	indexArray.drawingMode = GL_TRIANGLES;
	indexArray.elementType = GL_UNSIGNED_BYTE;
	GLubyte* indices = [indexArray allocateElements: indexCount];
	
	GLubyte indxIndx = 0;
	GLubyte vtxIndx = 0;
	for (int side = 0; side < 6; side++) {
		// First trangle of side - CCW from bottom left
		indices[indxIndx++] = vtxIndx++;		// vertex 0
		indices[indxIndx++] = vtxIndx++;		// vertex 1
		indices[indxIndx++] = vtxIndx;			// vertex 2
		
		// Second triangle of side - CCW from bottom left
		indices[indxIndx++] = vtxIndx++;		// vertex 2
		indices[indxIndx++] = vtxIndx++;		// vertex 3
		indices[indxIndx++] = (vtxIndx - 4);	// vertex 0
	}
	
	// Create mesh with interleaved vertex arrays
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* aMesh = [CC3VertexArrayMesh meshWithName: itemName];
	aMesh.interleaveVertices = YES;
	aMesh.vertexLocations = locArray;
	aMesh.vertexNormals = normArray;
	aMesh.vertexTextureCoordinates = tcArray;
	aMesh.vertexIndices = indexArray;
	self.mesh = aMesh;
}

// Vertex index data for the 12 lines of a wire box.
static const GLubyte wireBoxIndexData[] = {
	0, 1, 1, 3, 3, 2, 2, 0,
	4, 5, 5, 7, 7, 6, 6, 4,
	0, 4, 1, 5, 2, 6, 3, 7,
};

-(void) populateAsWireBox: (CC3BoundingBox) box {
	NSString* itemName;
	CC3Vector boxMin = box.minimum;
	CC3Vector boxMax = box.maximum;
	GLuint vertexCount = 8;
	
	// Create vertexLocation array.
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	CC3Vector* vertices = [locArray allocateElements: vertexCount];
	
	// Extract all 8 corner vertices from the box.
	vertices[0] = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[1] = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[2] = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[3] = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[4] = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[5] = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[6] = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[7] = cc3v(boxMax.x, boxMax.y, boxMax.z);
	
	GLuint lineCount = 12;
	GLuint indexCount = lineCount * 2;
	itemName = [NSString stringWithFormat: @"%@-Indices", self.name];
	CC3VertexIndices* indexArray = [CC3VertexIndices vertexArrayWithName: itemName];
	indexArray.drawingMode = GL_LINES;
	indexArray.elementType = GL_UNSIGNED_BYTE;
	indexArray.elementCount = indexCount;
	indexArray.elements = (GLvoid*)wireBoxIndexData;
	
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* aMesh = [CC3VertexArrayMesh meshWithName: itemName];
	aMesh.vertexLocations = locArray;
	aMesh.vertexIndices = indexArray;
	self.mesh = aMesh;
}


#pragma mark Populating parametric lines

-(void) populateAsLineStripWith: (GLshort) vertexCount
					   vertices: (CC3Vector*) vertices
					  andRetain: (BOOL) shouldRetainVertices {
	NSString* itemName;
	
	// Create vertexLocation array.
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	locArray.drawingMode = GL_LINE_STRIP;
	if (shouldRetainVertices) {
		[locArray allocateElements: vertexCount];
		memcpy(locArray.elements, vertices, vertexCount * sizeof(CC3Vector));
	} else {
		locArray.elementCount = vertexCount;
		locArray.elements = vertices;
	}
	
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* aMesh = [CC3VertexArrayMesh meshWithName: itemName];
	aMesh.vertexLocations = locArray;
	self.mesh = aMesh;
}

@end

