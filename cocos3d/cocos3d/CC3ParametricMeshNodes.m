/*
 * CC3ParametricMeshNodes.m
 *
 * cocos3d 0.7.1
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
							andTessellation: (ccGridSize) divsPerAxis {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0f, rectSize.height / 2.0f)
					  andTessellation: divsPerAxis];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	[self populateAsRectangleWithSize: rectSize andPivot: pivot andTessellation: ccg(1, 1)];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) divsPerAxis {
	
	// Must be at least one tessellation face per side of the rectangle.
	divsPerAxis.x = MAX(divsPerAxis.x, 1);
	divsPerAxis.y = MAX(divsPerAxis.y, 1);

	// Move the origin of the rectangle to the pivot point
	CGPoint botLeft = ccpSub(CGPointZero, pivot);
	CGPoint topRight = ccpSub(ccpFromSize(rectSize), pivot);

	// The size and texture span of each face in the tessellated grid
	CGSize divSize = CGSizeMake((topRight.x - botLeft.x) / divsPerAxis.x,
								 (topRight.y - botLeft.y) / divsPerAxis.y);
	CGSize divTexSpan = CGSizeMake((1.0 / divsPerAxis.x), (1.0 / divsPerAxis.y));

	// Get vertices per side.
	ccGridSize verticesPerAxis;
	verticesPerAxis.x = divsPerAxis.x + 1;
	verticesPerAxis.y = divsPerAxis.y + 1;
	GLuint vertexCount = verticesPerAxis.x * verticesPerAxis.y;
	GLuint triangleCount = divsPerAxis.x * divsPerAxis.y * 2;
	
	// Create the mesh, configure it for texture vertices and drawing
	// indexed triangles, and allocate space for the vertices and indices.
	NSString* meshName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* vaMesh = [CC3VertexArrayMesh meshWithName: meshName];
	CC3TexturedVertex* vertices = [vaMesh allocateTexturedVertices: vertexCount];
	GLushort* indices = [vaMesh allocateIndexedTriangles: triangleCount];

	// Populate vertex locations, normals & texture coordinates in the X-Y plane
	// Iterate through the rows and columns of the vertex grid, from the bottom left corner,
	// and set the location of each vertex to be proportional to its position in the grid,
	// and set the normal of each vertex to point up the Z-axis.
	for (int iy = 0; iy < verticesPerAxis.y; iy++) {
		for (int ix = 0; ix < verticesPerAxis.x; ix++) {
			int vIndx = iy * verticesPerAxis.x + ix;

			// Vertex location
			GLfloat vx = botLeft.x + (divSize.width * ix);
			GLfloat vy = botLeft.y + (divSize.height * iy);
			vertices[vIndx].location = cc3v(vx, vy, 0.0);

			// Vertex normal
			vertices[vIndx].normal = kCC3VectorUnitZPositive;

			// Vertex texture coordinates, inverted vertically
			GLfloat u = divTexSpan.width * ix;
			GLfloat v = divTexSpan.height * iy;
			vertices[vIndx].texCoord = (ccTex2F){u, (1.0f - v)};
		}
	}
	
	// Iterate through the rows and columns of the faces in the grid, from the bottom left corner,
	// and specify the indexes of the three vertices in each of the two triangles of each face.
	int iIndx = 0;
	for (int iy = 0; iy < divsPerAxis.y; iy++) {
		for (int ix = 0; ix < divsPerAxis.x; ix++) {
			GLushort botLeftOfFace;
			
			// First triangle of face wound counter-clockwise
			botLeftOfFace = iy * verticesPerAxis.x + ix;
			indices[iIndx++] = botLeftOfFace;							// Bottom left
			indices[iIndx++] = botLeftOfFace + 1;						// Bot right
			indices[iIndx++] = botLeftOfFace + verticesPerAxis.x + 1;	// Top right

			// Second triangle of face wound counter-clockwise
			indices[iIndx++] = botLeftOfFace + verticesPerAxis.x + 1;	// Top right
			indices[iIndx++] = botLeftOfFace + verticesPerAxis.x;		// Top left
			indices[iIndx++] = botLeftOfFace;							// Bottom left
		}
	}
	self.mesh = vaMesh;		// Set mesh at end to update bounding volume
}


#pragma mark Populating parametric circular disk

-(void) populateAsDiskWithRadius: (GLfloat) radius andTessellation: (ccGridSize) radialAndAngleDivs {
	
	// Must be at least one radial tessellation, and three angular tessellation.
	GLushort numRadialDivs = MAX(radialAndAngleDivs.x, 1);
	GLushort numAngularDivs = MAX(radialAndAngleDivs.y, 3);

	// Calculate the spans of each radial and angular division.
	GLfloat angularDivSpan = 2.0 * M_PI / numAngularDivs;		// Zero to 2PI
	GLfloat radialDivSpan = radius / numRadialDivs;				// Zero to radius
	GLfloat radialTexDivSpan = 0.5 / numRadialDivs;				// Zero to 0.5

	// Calculate number of vertices, triangles and indices.
	GLushort vertexCount = (numRadialDivs * (numAngularDivs + 1)) + 1;
	GLushort triangleCount = ((2 * numRadialDivs) - 1) * numAngularDivs;
	
	// Create the mesh, configure it for texture vertices and drawing
	// indexed triangles, and allocate space for the vertices and indices.
	NSString* meshName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* vaMesh = [CC3VertexArrayMesh meshWithName: meshName];
	CC3TexturedVertex* vertices = [vaMesh allocateTexturedVertices: vertexCount];
	GLushort* indices = [vaMesh allocateIndexedTriangles: triangleCount];
	
	LogCleanTrace(@"%@ populating as disk with radius: %.3f, %i radial divs, %i angular divs, %i vertices, and %i triangles",
				  self, radius, numRadialDivs, numAngularDivs, vertexCount, triangleCount);
	
	// Populate vertex locations, normals & texture coordinates.
	GLushort vIndx = 0;			// Vertex index
	GLushort iIndx = 0;			// Index index

	// Add the center vertex Vertex location from unit radial scaled by the radial span and ring number
	vertices[vIndx].location = kCC3VectorZero;
	vertices[vIndx].normal = kCC3VectorUnitZPositive;
	vertices[vIndx].texCoord = (ccTex2F){0.5f, 0.5f};
	
	for (GLushort ia = 0; ia <= numAngularDivs; ia++) {
		
		GLfloat angle = angularDivSpan * ia;
		CGPoint unitRadial = ccp(cosf(angle), sinf(angle));
		
		for (GLushort ir = 1; ir <= numRadialDivs; ir++) {

			vIndx++;	// Move on to the next vertex
			
			// Vertex location from unit radial scaled by the radial span and ring number
			CGPoint locPt = ccpMult(unitRadial, (radialDivSpan * ir));
			vertices[vIndx].location = cc3v(locPt.x, locPt.y, 0.0f);
			
			// Vertex normal always points along positive Z-axis
			vertices[vIndx].normal = kCC3VectorUnitZPositive;

			// Vertex tex coords from unit radial scaled by the radial texture span and ring
			// number, then shifted to move range from (-0.5 <-> +0.5) to (0.0 <-> +1.0).
			CGPoint texPt = ccpAdd(ccpMult(unitRadial, (radialTexDivSpan * ir)), ccp(0.5f, 0.5f));
			vertices[vIndx].texCoord = (ccTex2F){texPt.x, (1.0f - texPt.y)};
			
			// For the first ring, add one triangle rooted at the origin.
			// For all but the first ring, add two triangles to cover division trapezoid.
			// We don't create triangles for the last set of radial vertices, since they
			// overlap the first.
			if (ia < numAngularDivs) {
				if (ir == 1) {
					indices[iIndx++] = 0;							// Center vertex
					indices[iIndx++] = vIndx;						// Current vertex
					indices[iIndx++] = vIndx + numRadialDivs;		// Next angular div, same ring
				} else {
					indices[iIndx++] = vIndx;						// Current vertex
					indices[iIndx++] = vIndx + numRadialDivs;		// Next angular div, same ring
					indices[iIndx++] = vIndx + numRadialDivs - 1;	// Next angular div, prev ring
					
					indices[iIndx++] = vIndx;						// Current vertex
					indices[iIndx++] = vIndx + numRadialDivs - 1;	// Next angular div, prev ring
					indices[iIndx++] = vIndx - 1;					// Same angular div, prev ring
				}				
			}
		}
	}
	
	self.mesh = vaMesh;
}


#pragma mark Populating parametric boxes

-(void) populateAsSolidBox: (CC3BoundingBox) box {
	GLfloat w = box.maximum.x - box.minimum.x;		// Width of the box
	GLfloat h = box.maximum.y - box.minimum.y;		// Height of the box
	GLfloat d = box.maximum.z - box.minimum.z;		// Depth of the box
	GLfloat ufw = d + w + d + w;					// Total width of unfolded flattened box
	GLfloat ufh = d + h + d;						// Total height of unfolded flattened box
	[self populateAsSolidBox: box withCorner: ccp((d / ufw), (d / ufh))];
}

-(void) populateAsCubeMappedSolidBox: (CC3BoundingBox) box {
	[self populateAsSolidBox: box withCorner: ccp((1.0 / 4.0), (1.0 / 3.0))];
}

// Thanks to cocos3d user andyman for contributing the prototype code and texture
// template file for this method.
-(void) populateAsSolidBox: (CC3BoundingBox) box withCorner: (CGPoint) corner {

	CC3Vector boxMin = box.minimum;
	CC3Vector boxMax = box.maximum;
	GLuint vertexCount = 24;
	GLuint triangleCount = 12;
	
	// Create the mesh, configure it for texture vertices and drawing
	// indexed triangles, and allocate space for the vertices and indices.
	// Since number of vertices is fixed and low, use bytes for indices.
	NSString* meshName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* vaMesh = [CC3VertexArrayMesh meshWithName: meshName];
	CC3TexturedVertex* vertices = [vaMesh allocateTexturedVertices: vertexCount];
	GLushort* indices = [vaMesh allocateIndexedTriangles: triangleCount];
	
	// Front face, CCW winding:
	vertices[0].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[0].normal = kCC3VectorUnitZPositive;
	vertices[0].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
	
	vertices[1].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[1].normal = kCC3VectorUnitZPositive;
	vertices[1].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
	
	vertices[2].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
	vertices[2].normal = kCC3VectorUnitZPositive;
	vertices[2].texCoord = (ccTex2F){0.5f, corner.y};
	
	vertices[3].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[3].normal = kCC3VectorUnitZPositive;
	vertices[3].texCoord = (ccTex2F){corner.x, corner.y};
	
	// Right face, CCW winding:
	vertices[4].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[4].normal = kCC3VectorUnitXPositive;
	vertices[4].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
	
	vertices[5].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[5].normal = kCC3VectorUnitXPositive;
	vertices[5].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
	
	vertices[6].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[6].normal = kCC3VectorUnitXPositive;
	vertices[6].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
	
	vertices[7].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
	vertices[7].normal = kCC3VectorUnitXPositive;
	vertices[7].texCoord = (ccTex2F){0.5f, corner.y};
	
	// Back face, CCW winding:
	vertices[8].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[8].normal = kCC3VectorUnitZNegative;
	vertices[8].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
	
	vertices[9].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[9].normal = kCC3VectorUnitZNegative;
	vertices[9].texCoord = (ccTex2F){1.0f, (1.0f - corner.y)};
	
	vertices[10].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[10].normal = kCC3VectorUnitZNegative;
	vertices[10].texCoord = (ccTex2F){1.0f, corner.y};
	
	vertices[11].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[11].normal = kCC3VectorUnitZNegative;
	vertices[11].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
	
	// Left face, CCW winding:
	vertices[12].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[12].normal = kCC3VectorUnitXNegative;
	vertices[12].texCoord = (ccTex2F){0.0f, (1.0f - corner.y)};
	
	vertices[13].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[13].normal = kCC3VectorUnitXNegative;
	vertices[13].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
	
	vertices[14].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[14].normal = kCC3VectorUnitXNegative;
	vertices[14].texCoord = (ccTex2F){corner.x, corner.y};
	
	vertices[15].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[15].normal = kCC3VectorUnitXNegative;
	vertices[15].texCoord = (ccTex2F){0.0f, corner.y};
	
	// Top face, CCW winding:
	vertices[16].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
	vertices[16].normal = kCC3VectorUnitYPositive;
	vertices[16].texCoord = (ccTex2F){corner.x, 0.0f};
	
	vertices[17].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
	vertices[17].normal = kCC3VectorUnitYPositive;
	vertices[17].texCoord = (ccTex2F){corner.x, corner.y};
	
	vertices[18].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
	vertices[18].normal = kCC3VectorUnitYPositive;
	vertices[18].texCoord = (ccTex2F){0.5f, corner.y};
	
	vertices[19].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
	vertices[19].normal = kCC3VectorUnitYPositive;
	vertices[19].texCoord = (ccTex2F){0.5f, 0.0f};
	
	// Bottom face, CCW winding:
	vertices[20].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
	vertices[20].normal = kCC3VectorUnitYNegative;
	vertices[20].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
	
	vertices[21].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
	vertices[21].normal = kCC3VectorUnitYNegative;
	vertices[21].texCoord = (ccTex2F){corner.x, 1.0f};
	
	vertices[22].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
	vertices[22].normal = kCC3VectorUnitYNegative;
	vertices[22].texCoord = (ccTex2F){0.5f, 1.0f};
	
	vertices[23].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
	vertices[23].normal = kCC3VectorUnitYNegative;
	vertices[23].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};

	// Populate the vertex indices
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
	self.mesh = vaMesh;		// Set mesh at end to update bounding volume
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
	self.mesh = aMesh;		// Set mesh at end to update bounding volume
}


#pragma mark Populating parametric sphere

-(void) populateAsSphereWithRadius: (GLfloat) radius andTessellation: (ccGridSize) divsPerAxis {
	
	// Must be at least one tessellation face per side of the rectangle.
	divsPerAxis.x = MAX(divsPerAxis.x, 3);
	divsPerAxis.y = MAX(divsPerAxis.y, 2);
	
	// The division span and texture span of each face in the tessellated grid.
	CGSize divSpan = CGSizeMake( (2.0 * M_PI / divsPerAxis.x), (M_PI / divsPerAxis.y) );
	CGSize divTexSpan = CGSizeMake((1.0 / divsPerAxis.x), (1.0 / divsPerAxis.y));
	GLfloat halfDivTexSpanWidth = divTexSpan.width * 0.5f;
	
	// Calculate number of vertices, triangles and indices.
	ccGridSize verticesPerAxis;
	verticesPerAxis.x = divsPerAxis.x + 1;
	verticesPerAxis.y = divsPerAxis.y + 1;
	GLuint vertexCount = verticesPerAxis.x * verticesPerAxis.y;
	GLuint triangleCount = divsPerAxis.x * (divsPerAxis.y - 1) * 2;

	// Create the mesh, configure it for texture vertices and drawing
	// indexed triangles, and allocate space for the vertices and indices.
	NSString* meshName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* vaMesh = [CC3VertexArrayMesh meshWithName: meshName];
	CC3TexturedVertex* vertices = [vaMesh allocateTexturedVertices: vertexCount];
	GLushort* indices = [vaMesh allocateIndexedTriangles: triangleCount];
	
	LogCleanTrace(@"%@ populating as sphere with radius %.3f, (%i, %i) divisions, %i vertices, and %i triangles",
				  self, radius, divsPerAxis.x, divsPerAxis.y, vertexCount, triangleCount);
	
	// Populate vertex locations, normals & texture coordinates.
	// The parametric X-axis represents the longtitude (0 to 2PI).
	// The parametric Y-axis represents the latitude (0 to PI), starting at the north pole.
	GLushort vIndx = 0;			// Vertex index
	GLushort iIndx = 0;			// Index index
	for (GLushort iy = 0; iy < verticesPerAxis.y; iy++) {
		
		// Latitude (Y): 0 to PI
		GLfloat y = divSpan.height * iy;
		GLfloat sy = sinf(y);
		GLfloat cy = cosf(y);

		for (GLushort ix = 0; ix < verticesPerAxis.x; ix++) {

			// Longtitude (X): 0 to 2PI
			GLfloat x = divSpan.width * ix;
			GLfloat sx = sinf(x);
			GLfloat cx = cosf(x);

			// Vertex location, starting at negative-Z axis,
			// and right-hand rotating towards negative-X axis.
			CC3Vector unitRadial = cc3v( -(sy * sx), cy, -(sy * cx) );
			vertices[vIndx].location = CC3VectorScaleUniform(unitRadial, radius);
			
			// Vertex normal - same as location on unit sphere
			vertices[vIndx].normal = unitRadial;
			
			// Calculate vertex texture coordinate. Offset the texture coordinates at
			// each vertex at the poles by half of the division span (so triangle is
			// symetrical. The tex coord at the north pole is moved right and that at
			// the south pole is moved to the left.
			GLfloat uOffset = 0.0f;
			if (iy == 0) uOffset = halfDivTexSpanWidth;							// North pole
			if (iy == (verticesPerAxis.y - 1)) uOffset = -halfDivTexSpanWidth;	// South pole
			GLfloat u = divTexSpan.width * ix + uOffset;
			GLfloat v = divTexSpan.height * iy;
			vertices[vIndx].texCoord = (ccTex2F){u, v};

			// For each vertex that is at the bottom-right corner of a division, add triangles.
			if (iy > 0 && ix > 0) {
				
				// For all but the first division row, add the triangle that has apex pointing south.
				if (iy > 1) {
					indices[iIndx++] = vIndx;							// Bottom right
					indices[iIndx++] = vIndx - verticesPerAxis.x;		// Top right
					indices[iIndx++] = vIndx - verticesPerAxis.x - 1;	// Top left
				}				

				// For all but the last division row, add the triangle that has apex pointing north.
				if (iy < (verticesPerAxis.y - 1)) {
					indices[iIndx++] = vIndx - verticesPerAxis.x - 1;	// Top left
					indices[iIndx++] = vIndx - 1;						// Bottom left
					indices[iIndx++] = vIndx;							// Bottom right
				}
			}
			vIndx++;	// Move on to the next vertex
		}
	}

	// Set spherical bounding volume before setting mesh, then set mesh at end to update it
	self.boundingVolume = [CC3VertexLocationsSphericalBoundingVolume boundingVolume];
	self.mesh = vaMesh;
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
	self.mesh = aMesh;		// Set mesh at end to update bounding volume
}

#pragma mark Deprecated parametric methods

// Deprecated
-(void) deprecatedPopulateAsRectangleWithSize: (CGSize) rectSize
									 andPivot: (CGPoint) pivot
							  andTessellation: (ccGridSize) divsPerAxis
								  withTexture: (CC3Texture*) texture
								invertTexture: (BOOL) shouldInvert {
	
	// Populate the mesh, attach the texture
	[self populateAsRectangleWithSize: rectSize andPivot: pivot andTessellation: divsPerAxis];
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
	[self populateAsRectangleWithSize: rectSize andPivot: pivot];
}

// Deprecated
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize
								   andPivot: (CGPoint) pivot
							andTessellation: (ccGridSize) divsPerAxis {
	[self populateAsRectangleWithSize: rectSize andPivot: pivot andTessellation: divsPerAxis];
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

