/*
 * CC3ParametricMeshes.m
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
 * See header file CC3ParametricMeshes.h for full API documentation.
 */

#import "CC3ParametricMeshes.h"
#import "CC3CC2Extensions.h"
#import "CGPointExtension.h"


#pragma mark -
#pragma mark CC3VertexArrayMesh parametric shapes extension

@implementation CC3VertexArrayMesh (ParametricShapes)


#pragma mark Utility methods

-(void) ensureVertexContent {
	if (self.vertexContentTypes == kCC3VertexContentNone) {
		self.vertexContentTypes = (kCC3VertexContentLocation |
								   kCC3VertexContentNormal |
								   kCC3VertexContentTextureCoordinates);
	}
}


#pragma mark Populating parametric triangles

-(void) populateAsTriangle: (CC3Face) face
			 withTexCoords: (ccTex2F*) tc
		   andTessellation: (GLuint) divsPerSide {

	// Must have at least one division per side
	divsPerSide = MAX(divsPerSide, 1);

	// The fraction of each side that each division represents.
	// This is the barycentric coordinate division increment.
	GLfloat divFrac = 1.0f / divsPerSide;
	
	// Derive the normal. All vertices on the triangle will have the same normal.
	CC3Vector vtxNml = CC3FaceNormal(face);

	GLuint vertexCount = (divsPerSide + 2) * (divsPerSide + 1) / 2.0f;
	GLuint triangleCount = divsPerSide * divsPerSide;
	
	// Prepare the vertex content and allocate space for vertices and indices.
	[self ensureVertexContent];
	self.allocatedVertexCapacity = vertexCount;
	self.allocatedVertexIndexCapacity = (triangleCount * 3);

	GLuint vIdx = 0;
	GLuint iIdx = 0;
	
	// Denoting the three corners of the main triangle as c0, c1 & c2, and denoting the side
	// extending from c0 to c1 as s1, and the side extending from c0 to c2 as s2, we can work
	// in barycentric coordinates by starting at c0, iterating the divisions on the s2, and for
	// each divison on that side, iterating  the divisions on the side of the internal similar
	// triangle that is parallel to s1.
	for (GLuint i2 = 0; i2 <= divsPerSide; i2++) {

		// Calculate the barycentric weight for the current division along s2 and hold it constant
		// as we iterate through divisions along s1 of the resulting internal similar triangle.
		// The number of divisions on the side of the internal similar triangle is found by subtracting
		// the current division index of s2 from the total divisions per side.
		GLfloat bw2 = divFrac * i2;
		GLuint divsSimSide1 = divsPerSide - i2;
		for (GLuint i1 = 0; i1 <= divsSimSide1; i1++) {

			// Calculate the barycentric weight for the current division along s1 of the internal
			// similar triangle. The third barycentric weight falls out automatically.
			GLfloat bw1 = divFrac * i1;
			GLfloat bw0 = 1.0f - bw1 - bw2;
			CC3BarycentricWeights bcw = CC3BarycentricWeightsMake(bw0, bw1, bw2);

			// Vertex location from barycentric coordinates on the main face
			CC3Vector vtxLoc = CC3FaceLocationFromBarycentricWeights(face, bcw);
			[self setVertexLocation: vtxLoc at: vIdx];
			
			// Vertex normal is constant. Will do nothing if this mesh does not include normals.
			[self setVertexNormal: vtxNml at: vIdx];
			
			// Vertex texture coordinates derived from the barycentric coordinates and inverted vertically.
			// Will do nothing if this mesh does not include texture coordinates.
			GLfloat u = bw0 * tc[0].u + bw1 * tc[1].u + bw2 * tc[2].u;
			GLfloat v = bw0 * tc[0].v + bw1 * tc[1].v + bw2 * tc[2].v;
			[self setVertexTexCoord2F: cc3tc(u, (1.0f - v)) at: vIdx];

			// First tessellated triangle starting at the vertex and opening away from corner 0.
			if (i1 < divsSimSide1) {
				[self setVertexIndex: vIdx at: iIdx++];
				[self setVertexIndex: (vIdx + 1) at: iIdx++];
				[self setVertexIndex: (vIdx + divsSimSide1 + 1) at: iIdx++];
			}

			// Second tessellated triangle starting at the vertex and opening towards corner 0.
			if (i1 > 0 && i2 > 0) {
				[self setVertexIndex: vIdx at: iIdx++];
				[self setVertexIndex: (vIdx - 1) at: iIdx++];
				[self setVertexIndex: (vIdx - divsSimSide1 - 2) at: iIdx++];
			}
			
			vIdx++;		// Move on to the next vertex
		}
	}
}


#pragma mark Populating parametric planes

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize {
	[self populateAsRectangleWithSize: rectSize andRelativeOrigin: ccp(0.5f, 0.5f)];
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) divsPerAxis {
	[self populateAsRectangleWithSize: rectSize
					andRelativeOrigin: ccp(0.5f, 0.5f)
					  andTessellation: divsPerAxis];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize andRelativeOrigin: (CGPoint) origin {
	[self populateAsRectangleWithSize: rectSize andRelativeOrigin: origin andTessellation: ccg(1, 1)];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
				  andRelativeOrigin: (CGPoint) origin
					andTessellation: (ccGridSize) divsPerAxis {
	
	// Must be at least one tessellation face per side of the rectangle.
	divsPerAxis.x = MAX(divsPerAxis.x, 1);
	divsPerAxis.y = MAX(divsPerAxis.y, 1);

	// Move the origin of the rectangle to the specified origin
	CGPoint rectExtent = ccpFromSize(rectSize);
	origin = ccpCompMult(rectExtent, origin);
	CGPoint botLeft = ccpSub(CGPointZero, origin);
	CGPoint topRight = ccpSub(rectExtent, origin);

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
	
	// Prepare the vertex content and allocate space for vertices and indices.
	[self ensureVertexContent];
	self.allocatedVertexCapacity = vertexCount;
	self.allocatedVertexIndexCapacity = (triangleCount * 3);

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
			[self setVertexLocation: cc3v(vx, vy, 0.0) at: vIndx];

			// Vertex normal. Will do nothing if this mesh does not include normals.
			[self setVertexNormal: kCC3VectorUnitZPositive at: vIndx];

			// Vertex texture coordinates, inverted vertically
			// Will do nothing if this mesh does not include texture coordinates.
			GLfloat u = divTexSpan.width * ix;
			GLfloat v = divTexSpan.height * iy;
			[self setVertexTexCoord2F: cc3tc(u, (1.0f - v)) at: vIndx];
		}
	}
	
	// Since the index array is a simple array, just access the array directly.
	// Iterate through the rows and columns of the faces in the grid, from the bottom left corner,
	// and specify the indexes of the three vertices in each of the two triangles of each face.
	GLushort* indices = self.vertexIndices.vertices;
	int iIndx = 0;
	for (int iy = 0; iy < divsPerAxis.y; iy++) {
		for (int ix = 0; ix < divsPerAxis.x; ix++) {
			GLushort botLeftOfFace;
			
			// First triangle of face wound counter-clockwise
			botLeftOfFace = iy * verticesPerAxis.x + ix;
			indices[iIndx++] = botLeftOfFace;							// Bot left
			indices[iIndx++] = botLeftOfFace + 1;						// Bot right
			indices[iIndx++] = botLeftOfFace + verticesPerAxis.x + 1;	// Top right

			// Second triangle of face wound counter-clockwise
			indices[iIndx++] = botLeftOfFace + verticesPerAxis.x + 1;	// Top right
			indices[iIndx++] = botLeftOfFace + verticesPerAxis.x;		// Top left
			indices[iIndx++] = botLeftOfFace;							// Bot left
		}
	}
}


#pragma mark Populating parametric circular disk

-(void) populateAsDiskWithRadius: (GLfloat) radius andTessellation: (ccGridSize) radialAndAngleDivs {
	
	// Must be at least one radial tessellation, and three angular tessellation.
	GLuint numRadialDivs = MAX(radialAndAngleDivs.x, 1);
	GLuint numAngularDivs = MAX(radialAndAngleDivs.y, 3);

	// Calculate the spans of each radial and angular division.
	GLfloat angularDivSpan = kCC3TwoPi / numAngularDivs;		// Zero to 2Pi
	GLfloat radialDivSpan = radius / numRadialDivs;				// Zero to radius
	GLfloat radialTexDivSpan = 0.5 / numRadialDivs;				// Zero to 0.5

	// Calculate number of vertices, triangles and indices.
	GLuint vertexCount = (numRadialDivs * (numAngularDivs + 1)) + 1;
	GLuint triangleCount = ((2 * numRadialDivs) - 1) * numAngularDivs;
	
	// Prepare the vertex content and allocate space for vertices and indices.
	[self ensureVertexContent];
	self.allocatedVertexCapacity = vertexCount;
	self.allocatedVertexIndexCapacity = (triangleCount * 3);
	GLushort* indices = self.vertexIndices.vertices;		// Pointer to the indices
	
	LogTrace(@"%@ populating as disk with radius: %.3f, %i radial divs, %i angular divs, %i vertices, and %i triangles",
				  self, radius, numRadialDivs, numAngularDivs, vertexCount, triangleCount);
	
	// Populate vertex locations, normals & texture coordinates.
	GLuint vIndx = 0;			// Vertex index
	GLuint iIndx = 0;			// Index index

	// Add the center vertex Vertex location from unit radial scaled by the radial span and ring number
	// Setters for any content that is not defined by the vertexContentTypes property will do nothing.
	[self setVertexLocation: kCC3VectorZero at: vIndx];
	[self setVertexNormal: kCC3VectorUnitZPositive at: vIndx];
	[self setVertexTexCoord2F: cc3tc(0.5f, 0.5f) at: vIndx];
	
	for (GLuint ia = 0; ia <= numAngularDivs; ia++) {
		
		GLfloat angle = angularDivSpan * ia;
		CGPoint unitRadial = ccp(cosf(angle), sinf(angle));
		
		for (GLuint ir = 1; ir <= numRadialDivs; ir++) {

			vIndx++;	// Move on to the next vertex
			
			// Vertex location from unit radial scaled by the radial span and ring number
			CGPoint locPt = ccpMult(unitRadial, (radialDivSpan * ir));
			[self setVertexLocation: cc3v(locPt.x, locPt.y, 0.0f) at: vIndx];
			
			// Vertex normal always points along positive Z-axis
			// Will do nothing if this mesh does not include normals.
			[self setVertexNormal: kCC3VectorUnitZPositive at: vIndx];

			// Vertex tex coords from unit radial scaled by the radial texture span and ring
			// number, then shifted to move range from (-0.5 <-> +0.5) to (0.0 <-> +1.0).
			// Will do nothing if this mesh does not include texture coordinates.
			CGPoint texPt = ccpAdd(ccpMult(unitRadial, (radialTexDivSpan * ir)), ccp(0.5f, 0.5f));
			[self setVertexTexCoord2F: cc3tc(texPt.x, (1.0f - texPt.y)) at: vIndx];
			
			// Since the index array is a simple array, just access the array directly.
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
	
	// Prepare the vertex content and allocate space for vertices and indices.
	[self ensureVertexContent];
	self.allocatedVertexCapacity = vertexCount;
	self.allocatedVertexIndexCapacity = (triangleCount * 3);
	GLushort* indices = self.vertexIndices.vertices;
	
	// Populate all six sides.
	// Setters for any content that is not defined by the vertexContentTypes property will do nothing.
	
	// Front face, CCW winding:
	[self setVertexLocation: cc3v(boxMin.x, boxMin.y, boxMax.z) at: 0];
	[self setVertexNormal: kCC3VectorUnitZPositive at: 0];
	[self setVertexTexCoord2F: cc3tc(corner.x, (1.0f - corner.y)) at: 0];

	[self setVertexLocation: cc3v(boxMax.x, boxMin.y, boxMax.z) at: 1];
	[self setVertexNormal: kCC3VectorUnitZPositive at: 1];
	[self setVertexTexCoord2F: cc3tc(0.5f, (1.0f - corner.y)) at: 1];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMax.y, boxMax.z) at: 2];
	[self setVertexNormal: kCC3VectorUnitZPositive at: 2];
	[self setVertexTexCoord2F: cc3tc(0.5f, corner.y) at: 2];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMax.y, boxMax.z) at: 3];
	[self setVertexNormal: kCC3VectorUnitZPositive at: 3];
	[self setVertexTexCoord2F: cc3tc(corner.x, corner.y) at: 3];
	
	// Right face, CCW winding:
	[self setVertexLocation: cc3v(boxMax.x, boxMin.y, boxMax.z) at: 4];
	[self setVertexNormal: kCC3VectorUnitXPositive at: 4];
	[self setVertexTexCoord2F: cc3tc(0.5f, (1.0f - corner.y)) at: 4];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMin.y, boxMin.z) at: 5];
	[self setVertexNormal: kCC3VectorUnitXPositive at: 5];
	[self setVertexTexCoord2F: cc3tc((0.5f + corner.x), (1.0f - corner.y)) at: 5];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMax.y, boxMin.z) at: 6];
	[self setVertexNormal: kCC3VectorUnitXPositive at: 6];
	[self setVertexTexCoord2F: cc3tc((0.5f + corner.x), corner.y) at: 6];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMax.y, boxMax.z) at: 7];
	[self setVertexNormal: kCC3VectorUnitXPositive at: 7];
	[self setVertexTexCoord2F: cc3tc(0.5f, corner.y) at: 7];
	
	// Back face, CCW winding:
	[self setVertexLocation: cc3v(boxMax.x, boxMin.y, boxMin.z) at: 8];
	[self setVertexNormal: kCC3VectorUnitZNegative at: 8];
	[self setVertexTexCoord2F: cc3tc((0.5f + corner.x), (1.0f - corner.y)) at: 8];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMin.y, boxMin.z) at: 9];
	[self setVertexNormal: kCC3VectorUnitZNegative at: 9];
	[self setVertexTexCoord2F: cc3tc(1.0f, (1.0f - corner.y)) at: 9];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMax.y, boxMin.z) at: 10];
	[self setVertexNormal: kCC3VectorUnitZNegative at: 10];
	[self setVertexTexCoord2F: cc3tc(1.0f, corner.y) at: 10];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMax.y, boxMin.z) at: 11];
	[self setVertexNormal: kCC3VectorUnitZNegative at: 11];
	[self setVertexTexCoord2F: cc3tc((0.5f + corner.x), corner.y) at: 11];
	
	// Left face, CCW winding:
	[self setVertexLocation: cc3v(boxMin.x, boxMin.y, boxMin.z) at: 12];
	[self setVertexNormal: kCC3VectorUnitXNegative at: 12];
	[self setVertexTexCoord2F: cc3tc(0.0f, (1.0f - corner.y)) at: 12];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMin.y, boxMax.z) at: 13];
	[self setVertexNormal: kCC3VectorUnitXNegative at: 13];
	[self setVertexTexCoord2F: cc3tc(corner.x, (1.0f - corner.y)) at: 13];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMax.y, boxMax.z) at: 14];
	[self setVertexNormal: kCC3VectorUnitXNegative at: 14];
	[self setVertexTexCoord2F: cc3tc(corner.x, corner.y) at: 14];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMax.y, boxMin.z) at: 15];
	[self setVertexNormal: kCC3VectorUnitXNegative at: 15];
	[self setVertexTexCoord2F: cc3tc(0.0f, corner.y) at: 15];
	
	// Top face, CCW winding:
	[self setVertexLocation: cc3v(boxMin.x, boxMax.y, boxMin.z) at: 16];
	[self setVertexNormal: kCC3VectorUnitYPositive at: 16];
	[self setVertexTexCoord2F: cc3tc(corner.x, 0.0f) at: 16];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMax.y, boxMax.z) at: 17];
	[self setVertexNormal: kCC3VectorUnitYPositive at: 17];
	[self setVertexTexCoord2F: cc3tc(corner.x, corner.y) at: 17];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMax.y, boxMax.z) at: 18];
	[self setVertexNormal: kCC3VectorUnitYPositive at: 18];
	[self setVertexTexCoord2F: cc3tc(0.5f, corner.y) at: 18];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMax.y, boxMin.z) at: 19];
	[self setVertexNormal: kCC3VectorUnitYPositive at: 19];
	[self setVertexTexCoord2F: cc3tc(0.5f, 0.0f) at: 19];
	
	// Bottom face, CCW winding:
	[self setVertexLocation: cc3v(boxMin.x, boxMin.y, boxMax.z) at: 20];
	[self setVertexNormal: kCC3VectorUnitYNegative at: 20];
	[self setVertexTexCoord2F: cc3tc(corner.x, (1.0f - corner.y)) at: 20];
	
	[self setVertexLocation: cc3v(boxMin.x, boxMin.y, boxMin.z) at: 21];
	[self setVertexNormal: kCC3VectorUnitYNegative at: 21];
	[self setVertexTexCoord2F: cc3tc(corner.x, 1.0f) at: 21];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMin.y, boxMin.z) at: 22];
	[self setVertexNormal: kCC3VectorUnitYNegative at: 22];
	[self setVertexTexCoord2F: cc3tc(0.5f, 1.0f) at: 22];
	
	[self setVertexLocation: cc3v(boxMax.x, boxMin.y, boxMax.z) at: 23];
	[self setVertexNormal: kCC3VectorUnitYNegative at: 23];
	[self setVertexTexCoord2F: cc3tc(0.5f, (1.0f - corner.y)) at: 23];

	// Populate the vertex indices
	// Since the index array is a simple array, just access the array directly.
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
}

// Vertex index data for the 12 lines of a wire box.
static const GLubyte wireBoxIndexData[] = {
	0, 1, 1, 3, 3, 2, 2, 0,
	4, 5, 5, 7, 7, 6, 6, 4,
	0, 4, 1, 5, 2, 6, 3, 7,
};

-(void) populateAsWireBox: (CC3BoundingBox) box {
	CC3Vector boxMin = box.minimum;
	CC3Vector boxMax = box.maximum;
	GLuint vertexCount = 8;
	
	// Create vertexLocation array.
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArray];
	locArray.allocatedVertexCapacity = vertexCount;
	CC3Vector* vertices = locArray.vertices;
	
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
	CC3VertexIndices* indexArray = [CC3VertexIndices vertexArray];
	indexArray.drawingMode = GL_LINES;
	indexArray.elementType = GL_UNSIGNED_BYTE;
	indexArray.vertexCount = indexCount;
	indexArray.vertices = (GLvoid*)wireBoxIndexData;
	
	self.vertexLocations = locArray;
	self.vertexIndices = indexArray;
}


#pragma mark Populating parametric sphere

-(void) populateAsSphereWithRadius: (GLfloat) radius andTessellation: (ccGridSize) divsPerAxis {
	
	// Must be at least one tessellation face per side of the rectangle.
	divsPerAxis.x = MAX(divsPerAxis.x, 3);
	divsPerAxis.y = MAX(divsPerAxis.y, 2);
	
	// The division span and texture span of each face in the tessellated grid.
	CGSize divSpan = CGSizeMake( (kCC3TwoPi / divsPerAxis.x), (kCC3Pi / divsPerAxis.y) );
	CGSize divTexSpan = CGSizeMake((1.0 / divsPerAxis.x), (1.0 / divsPerAxis.y));
	GLfloat halfDivTexSpanWidth = divTexSpan.width * 0.5f;
	
	// Calculate number of vertices, triangles and indices.
	ccGridSize verticesPerAxis;
	verticesPerAxis.x = divsPerAxis.x + 1;
	verticesPerAxis.y = divsPerAxis.y + 1;
	GLuint vertexCount = verticesPerAxis.x * verticesPerAxis.y;
	GLuint triangleCount = divsPerAxis.x * (divsPerAxis.y - 1) * 2;
	
	// Prepare the vertex content and allocate space for vertices and indices.
	[self ensureVertexContent];
	self.allocatedVertexCapacity = vertexCount;
	self.allocatedVertexIndexCapacity = (triangleCount * 3);
	GLushort* indices = self.vertexIndices.vertices;
	
	LogTrace(@"%@ populating as sphere with radius %.3f, (%i, %i) divisions, %i vertices, and %i triangles",
				  self, radius, divsPerAxis.x, divsPerAxis.y, vertexCount, triangleCount);
	
	// Populate vertex locations, normals & texture coordinates.
	// The parametric X-axis represents the longtitude (0 to 2PI).
	// The parametric Y-axis represents the latitude (0 to PI), starting at the north pole.
	GLuint vIndx = 0;			// Vertex index
	GLuint iIndx = 0;			// Index index
	for (GLuint iy = 0; iy < verticesPerAxis.y; iy++) {
		
		// Latitude (Y): 0 to PI
		GLfloat y = divSpan.height * iy;
		GLfloat sy = sinf(y);
		GLfloat cy = cosf(y);
		
		for (GLuint ix = 0; ix < verticesPerAxis.x; ix++) {
			
			// Longtitude (X): 0 to 2PI
			GLfloat x = divSpan.width * ix;
			GLfloat sx = sinf(x);
			GLfloat cx = cosf(x);
			
			// Vertex location, starting at negative-Z axis,
			// and right-hand rotating towards negative-X axis.
			CC3Vector unitRadial = cc3v( -(sy * sx), cy, -(sy * cx) );
			[self setVertexLocation: CC3VectorScaleUniform(unitRadial, radius) at: vIndx];
			
			// Vertex normal - same as location on unit sphere
			// Will do nothing if this mesh does not include normals.
			[self setVertexNormal: unitRadial at: vIndx];
			
			// Calculate vertex texture coordinate. Offset the texture coordinates at
			// each vertex at the poles by half of the division span (so triangle is
			// symetrical. The tex coord at the north pole is moved right and that at
			// the south pole is moved to the left.
			// Will do nothing if this mesh does not include texture coordinates.
			GLfloat uOffset = 0.0f;
			if (iy == 0) uOffset = halfDivTexSpanWidth;							// North pole
			if (iy == (verticesPerAxis.y - 1)) uOffset = -halfDivTexSpanWidth;	// South pole
			GLfloat u = divTexSpan.width * ix + uOffset;
			GLfloat v = divTexSpan.height * iy;
			[self setVertexTexCoord2F: cc3tc(u, v) at: vIndx];
			
			// Since the index array is a simple array, just access the array directly.
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
}


#pragma mark Populating parametric cone

-(void) populateAsHollowConeWithRadius: (GLfloat) radius
								height: (GLfloat) height
					   andTessellation: (ccGridSize) angleAndHeightDivs {
	
	// Must be at least one height tessellation, and three angular tessellation.
	GLuint numAngularDivs = MAX(angleAndHeightDivs.x, 3);
	GLuint numHeightDivs = MAX(angleAndHeightDivs.y, 1);
	
	// Calculate the spans of each angular and height division.
	GLfloat radiusHeightRatio = radius / height;
	GLfloat angularDivSpan = kCC3TwoPi / numAngularDivs;		// Zero to 2Pi
	GLfloat heightDivSpan = height / numHeightDivs;				// Zero to height
	GLfloat radialDivSpan = radius / numHeightDivs;				// Zero to radius
	GLfloat texAngularDivSpan = 1.0f / numAngularDivs;			// Zero to one
	GLfloat texHeightDivSpan = 1.0f / numHeightDivs;			// Zero to one
	
	// Calculate number of vertices, triangles and indices.
	GLuint vertexCount = (numAngularDivs + 1) * (numHeightDivs + 1);
	GLuint triangleCount = 2 * numAngularDivs * numHeightDivs - numAngularDivs;
	
	// Prepare the vertex content and allocate space for vertices and indices.
	[self ensureVertexContent];
	self.allocatedVertexCapacity = vertexCount;
	self.allocatedVertexIndexCapacity = (triangleCount * 3);
	
	// Populate vertex locations, normals & texture coordinates.
	GLuint vIdx = 0;			// Vertex index
	GLuint iIdx = 0;			// Index index
	for (GLuint ia = 0; ia <= numAngularDivs; ia++) {
		
		GLfloat angle = angularDivSpan * ia;
		GLfloat ca = -cosf(angle);		// Put seam on Z-minus axis and proceed CCW
		GLfloat sa = -sinf(angle);		// Put seam on Z-minus axis and proceed CCW
		CC3Vector vtxNormal = CC3VectorNormalize(cc3v(sa, radiusHeightRatio, ca));
		
		for (GLuint ih = 0; ih <= numHeightDivs; ih++, vIdx++) {

			GLfloat vtxRadius = radius - (radialDivSpan * ih);
			GLfloat vtxHt = heightDivSpan * ih;
			CC3Vector vtxLoc = cc3v(vtxRadius * sa, vtxHt, vtxRadius * ca);
			[self setVertexLocation: vtxLoc at: vIdx];
			
			// All vertex normals for one angular division point in the same direction
			// Will do nothing if this mesh does not include normals.
			[self setVertexNormal: vtxNormal at: vIdx];
			
			// Vertex tex coords wrapped around and projected horizontally to the cone surface.
			// Will do nothing if this mesh does not include texture coordinates.
			ccTex2F texCoord = cc3tc(texAngularDivSpan * ia, (1.0f - texHeightDivSpan * ih));
			[self setVertexTexCoord2F: texCoord at: vIdx];
			
			// First triangular face
			if (ia < numAngularDivs && ih < numHeightDivs) {
				[self setVertexIndex: vIdx at: iIdx++];							// Current vertex
				[self setVertexIndex: (vIdx + numHeightDivs + 1) at: iIdx++];	// Next angular div, same height
				[self setVertexIndex: (vIdx + numHeightDivs + 2) at: iIdx++];	// Next angular div, next height

				// Only one triangular face at ring below apex
				if (ih < numHeightDivs - 1) {
					[self setVertexIndex: (vIdx + numHeightDivs + 2) at: iIdx++];	// Next angular div, next height
					[self setVertexIndex: (vIdx + 1) at: iIdx++];					// Same angular div, next height
					[self setVertexIndex: vIdx at: iIdx++];							// Current vertex
				}
			}
		}
	}
}

#pragma mark Populating parametric lines

-(void) populateAsLineStripWith: (GLuint) vertexCount
					   vertices: (CC3Vector*) vertices
					  andRetain: (BOOL) shouldRetainVertices {
	// Create vertexLocation array.
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArray];
	locArray.drawingMode = GL_LINE_STRIP;
	if (shouldRetainVertices) {
		locArray.allocatedVertexCapacity = vertexCount;
		memcpy(locArray.vertices, vertices, vertexCount * sizeof(CC3Vector));
	} else {
		locArray.vertexCount = vertexCount;
		locArray.vertices = vertices;
	}
	self.vertexLocations = locArray;
}


#pragma mark Populating for bitmapped font textures

typedef struct {
	GLfloat lineWidth;
	NSUInteger lastVertexIndex;
} CC3BMLineSpec;

-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
									andFont: (CC3BMFontConfiguration*) fontConfig
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (UITextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (ccGridSize) divsPerChar {
	
	CGPoint charPos, adjCharPos;
	CGSize layoutSize;
	NSInteger kerningAmount;
	unichar prevChar = -1;
	NSUInteger strLen = [lblString length];
	
	if (lineHeight == 0.0f) lineHeight = fontConfig->commonHeight_;
	GLfloat fontScale = lineHeight / (GLfloat)fontConfig->commonHeight_;

	// Line count needs to be calculated before parsing the lines to get Y position
	NSUInteger charCount = 0;
	NSUInteger lineCount = 1;
	for(NSUInteger i = 0; i < strLen; i++)
		([lblString characterAtIndex: i] == '\n') ? lineCount++ : charCount++;
	
	// Create a local array to hold the dimensional characteristics of each line of text
	CC3BMLineSpec* lineSpecs = calloc(lineCount, sizeof(CC3BMLineSpec));
	
	// We now know the height of the layout. Width will be determined as the lines are laid out.
	layoutSize.width =  0;
	layoutSize.height = lineHeight * lineCount;
	
	// Prepare the vertex content and allocate space for the vertices and indexes.
	[self ensureVertexContent];
	GLuint vtxCountPerChar = (divsPerChar.x + 1) * (divsPerChar.y + 1);
	GLuint triCountPerChar = divsPerChar.x * divsPerChar.y * 2;
	self.allocatedVertexCapacity = vtxCountPerChar * charCount;
	self.allocatedVertexIndexCapacity = triCountPerChar * 3 * charCount;
	
	LogTrace(@"Creating label %@ with %i (%i) vertices and %i (%i) vertex indices from %i chars on %i lines in text %@",
			 self, self.vertexCount, self.allocatedVertexCapacity,
			 self.vertexIndexCount, self.allocatedVertexIndexCapacity, charCount, lineCount, lblString);
	
	// Start at the top-left corner of the label, above the first line.
	// Place the first character at the left of the first line.
	charPos.x = 0;
	charPos.y = lineCount * lineHeight;
	
	NSUInteger lineIndx = 0;
	NSUInteger vIdx = 0;
	NSUInteger iIdx = 0;
	
	// Iterate through the characters
	for (NSUInteger i = 0; i < strLen; i++) {
		unichar c = [lblString characterAtIndex: i];
		
		// If the character is a newline, don't draw anything and move down a line
		if (c == '\n') {
			lineIndx++;
			charPos.x = 0;
			charPos.y -= lineHeight;
			continue;
		}
		
		// Get the font specification and for the character, the kerning between the previous
		// character and this character, and determine a positioning adjustment for the character.
		ccBMFontDef* charSpec = [fontConfig characterSpecFor: c];
		NSAssert(charSpec, @"%@: no font specification loaded for character %i", self, c);

		kerningAmount = [fontConfig kerningBetween: prevChar and: c] * fontScale;
		adjCharPos.x = charPos.x + (charSpec->xOffset * fontScale) + kerningAmount;
		adjCharPos.y = charPos.y - (charSpec->yOffset * fontScale);
		
		// Determine the size of each tesselation division for this character.
		// This is specified in terms of the unscaled font config. It will be scaled later.
		CGSize divSize = CGSizeMake(charSpec->rect.size.width / divsPerChar.x,
									charSpec->rect.size.height / divsPerChar.y);
		
		// Populate the tesselated vertex locations, normals & texture coordinates for a single
		// character. Iterate through the rows and columns of the tesselation grid, from the top-left
		// corner downwards. This orientation aligns with the texture coords in the font file.
		// Set the location of each vertex and tex coords to be proportional to its position in the
		// grid, and set the normal of each vertex to point up the Z-axis.
		for (NSUInteger iy = 0; iy <= divsPerChar.y; iy++) {
			for (NSUInteger ix = 0; ix <= divsPerChar.x; ix++, vIdx++) {
				
				// Cache the index of the last vertex of this line. Since the vertices are accessed
				// in consecutive, ascending order, this is done by simply setting it each time.
				lineSpecs[lineIndx].lastVertexIndex = vIdx;
				
				// Vertex location
				GLfloat vx = adjCharPos.x + (divSize.width * ix * fontScale);
				GLfloat vy = adjCharPos.y - (divSize.height * iy * fontScale);
				[self setVertexLocation: cc3v(vx, vy, 0.0) at: vIdx];
				
				// If needed, expand the line and layout width to account for the vertices
				lineSpecs[lineIndx].lineWidth = MAX(lineSpecs[lineIndx].lineWidth, vx);
				layoutSize.width = MAX(layoutSize.width, vx);
				
				// Vertex normal. Will do nothing if this mesh does not include normals.
				[self setVertexNormal: kCC3VectorUnitZPositive at: vIdx];

				// Vertex texture coordinates, inverted vertically, because we're working top-down.
				GLfloat u = (charSpec->rect.origin.x + (divSize.width * ix)) / fontConfig->textureSize.x;
				GLfloat v = (charSpec->rect.origin.y + (divSize.height * iy)) / fontConfig->textureSize.y;
				[self setVertexTexCoord2F: cc3tc(u, v) at: vIdx];

				// In the grid of division quads for each character, each vertex that is not
				// in either the top-most row or the right-most column is the bottom-left corner
				// of a division. Break the division into two triangles.
				if (iy < divsPerChar.y && ix < divsPerChar.x) {
					
					// First triangle of face wound counter-clockwise
					[self setVertexIndex: vIdx at: iIdx++];						// TL
					[self setVertexIndex: (vIdx + divsPerChar.x + 1) at: iIdx++];	// BL
					[self setVertexIndex: (vIdx + divsPerChar.x + 2) at: iIdx++];	// BR
					
					// Second triangle of face wound counter-clockwise
					[self setVertexIndex: (vIdx + divsPerChar.x + 2) at: iIdx++];	// BR
					[self setVertexIndex: (vIdx + 1) at: iIdx++];					// TR
					[self setVertexIndex: vIdx at: iIdx++];						// TL
				}
			}
		}

		// Horizontal position of the next character
		charPos.x += (charSpec->xAdvance * fontScale) + kerningAmount;

		prevChar = c;	// Remember the current character before moving on to the next
	}

	// Iterate through the lines, calculating the width adjustment to correctly align each line,
	// and applying that adjustment to the X-component of the location of each vertex that is
	// contained within that text line.
	for (NSUInteger i = 0; i < lineCount; i++) {
		GLfloat widthAdj;
		switch (textAlignment) {
			case UITextAlignmentCenter:
				// Adjust vertices so half the white space is on each side
				widthAdj = (layoutSize.width - lineSpecs[i].lineWidth) * 0.5f;
				break;
			case UITextAlignmentRight:
				// Adjust vertices so all the white space is on the left side
				widthAdj = layoutSize.width - lineSpecs[i].lineWidth;
				break;
			case UITextAlignmentLeft:
			default:
				// Leave all vertices where they are
				widthAdj = 0.0f;
				break;
		}
		if (widthAdj) {
			NSUInteger startVtxIdx = (i > 0) ? (lineSpecs[i - 1].lastVertexIndex + 1) : 0;
			NSUInteger endVtxIdx = lineSpecs[i].lastVertexIndex;
			LogTrace(@"%@ adjusting line %i by %.3f (from line width %i in layout width %i) from vertex %i to %i",
					 self, i, widthAdj, lineSpecs[i].lineWidth, layoutSize.width, startVtxIdx, endVtxIdx);
			for (vIdx = startVtxIdx; vIdx <= endVtxIdx; vIdx++) {
				CC3Vector vtxLoc = [self vertexLocationAt: vIdx];
				vtxLoc.x += widthAdj;
				[self setVertexLocation: vtxLoc at: vIdx];
			}
		}
	}

	// Move all vertices so that the origin of the vertex coordinate system is aligned
	// with a location derived from the origin factor.
	NSUInteger vtxCnt = self.vertexCount;
	CC3Vector originLoc = cc3v((layoutSize.width * origin.x), (layoutSize.height * origin.y), 0);
	for (vIdx = 0; vIdx < vtxCnt; vIdx++) {
		CC3Vector locOld = [self vertexLocationAt: vIdx];
		CC3Vector locNew = CC3VectorDifference(locOld, originLoc);
		[self setVertexLocation: locNew at: vIdx];
	}
	
	free(lineSpecs);	// Release the array of line widths
}

/*
-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
									andFont: (CC3BMFontConfiguration*) fontConfig
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (UITextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (ccGridSize) divsPerChar {
	
	CGPoint charPos, adjCharPos;
	CGSize layoutSize;
	NSInteger kerningAmount;
	unichar prevChar = -1;
	NSUInteger strLen = [lblString length];
	
	if (lineHeight == 0.0f) lineHeight = fontConfig->commonHeight_;
	GLfloat fontScale = lineHeight / (GLfloat)fontConfig->commonHeight_;
	
	// Line count needs to be calculated before parsing the lines to get Y position
	NSUInteger charCount = 0;
	NSUInteger lineCount = 1;
	for(NSUInteger i = 0; i < strLen; i++)
		([lblString characterAtIndex: i] == '\n') ? lineCount++ : charCount++;
	
	// Create a local array to hold the dimensional characteristics of each line of text
	CC3BMLineSpec* lineSpecs = calloc(lineCount, sizeof(CC3BMLineSpec));
	
	// We now know the height of the layout. Width will be determined as the lines are laid out.
	layoutSize.width =  0;
	layoutSize.height = lineHeight * lineCount;
	
	// Prepare the vertex content and allocate space for the vertices and indexes.
	[self ensureVertexContent];
	GLuint vtxCountPerChar = (divsPerChar.x + 1) * (divsPerChar.y + 1);
	GLuint triCountPerChar = divsPerChar.x * divsPerChar.y * 2;
	self.allocatedVertexCapacity = vtxCountPerChar * charCount;
	self.allocatedVertexIndexCapacity = triCountPerChar * 3 * charCount;
	
	LogTrace(@"Creating label %@ with %i (%i) vertices and %i (%i) vertex indices from %i chars on %i lines in text %@",
			 self, self.vertexCount, self.allocatedVertexCapacity,
			 self.vertexIndexCount, self.allocatedVertexIndexCapacity, charCount, lineCount, lblString);
	
	// Start at the top-left corner of the label, above the first line.
	// Place the first character at the left of the first line.
	charPos.x = 0;
	charPos.y = lineCount * lineHeight;
	
	NSUInteger lineIndx = 0;
	NSUInteger vIdx = 0;
	NSUInteger iIdx = 0;
	
	// Iterate through the characters
	for (NSUInteger i = 0; i < strLen; i++) {
		unichar c = [lblString characterAtIndex: i];
		NSAssert( c < kCCBMFontMaxChars, @"LabelBMFont: character outside bounds");
		
		// If the character is a newline, don't draw anything and move down a line
		if (c == '\n') {
			lineIndx++;
			charPos.x = 0;
			charPos.y -= lineHeight;
			continue;
		}
		
		// Get the font specification and for the character, the kerning between the previous
		// character and this character, and determine a positioning adjustment for the character.
		ccBMFontDef charSpec = fontConfig->BMFontArray_[c];
		kerningAmount = [fontConfig kerningBetween: prevChar and: c] * fontScale;
		adjCharPos.x = charPos.x + (charSpec.xOffset * fontScale) + kerningAmount;
		adjCharPos.y = charPos.y - (charSpec.yOffset * fontScale);
		
		// Determine the size of each tesselation division for this character.
		// This is specified in terms of the unscaled font config. It will be scaled later.
		CGSize divSize = CGSizeMake(charSpec.rect.size.width / divsPerChar.x,
									charSpec.rect.size.height / divsPerChar.y);
		
		// Populate the tesselated vertex locations, normals & texture coordinates for a single
		// character. Iterate through the rows and columns of the tesselation grid, from the top-left
		// corner downwards. This orientation aligns with the texture coords in the font file.
		// Set the location of each vertex and tex coords to be proportional to its position in the
		// grid, and set the normal of each vertex to point up the Z-axis.
		for (NSUInteger iy = 0; iy <= divsPerChar.y; iy++) {
			for (NSUInteger ix = 0; ix <= divsPerChar.x; ix++, vIdx++) {
				
				// Cache the index of the last vertex of this line. Since the vertices are accessed
				// in consecutive, ascending order, this is done by simply setting it each time.
				lineSpecs[lineIndx].lastVertexIndex = vIdx;
				
				// Vertex location
				GLfloat vx = adjCharPos.x + (divSize.width * ix * fontScale);
				GLfloat vy = adjCharPos.y - (divSize.height * iy * fontScale);
				[self setVertexLocation: cc3v(vx, vy, 0.0) at: vIdx];
				
				// If needed, expand the line and layout width to account for the vertices
				lineSpecs[lineIndx].lineWidth = MAX(lineSpecs[lineIndx].lineWidth, vx);
				layoutSize.width = MAX(layoutSize.width, vx);
				
				// Vertex normal. Will do nothing if this mesh does not include normals.
				[self setVertexNormal: kCC3VectorUnitZPositive at: vIdx];
				
				// Vertex texture coordinates, inverted vertically, because we're working top-down.
				GLfloat u = (charSpec.rect.origin.x + (divSize.width * ix)) / fontConfig->textureSize.x;
				GLfloat v = (charSpec.rect.origin.y + (divSize.height * iy)) / fontConfig->textureSize.y;
				[self setVertexTexCoord2F: cc3tc(u, v) at: vIdx];
				
				// In the grid of division quads for each character, each vertex that is not
				// in either the top-most row or the right-most column is the bottom-left corner
				// of a division. Break the division into two triangles.
				if (iy < divsPerChar.y && ix < divsPerChar.x) {
					
					// First triangle of face wound counter-clockwise
					[self setVertexIndex: vIdx at: iIdx++];						// TL
					[self setVertexIndex: (vIdx + divsPerChar.x + 1) at: iIdx++];	// BL
					[self setVertexIndex: (vIdx + divsPerChar.x + 2) at: iIdx++];	// BR
					
					// Second triangle of face wound counter-clockwise
					[self setVertexIndex: (vIdx + divsPerChar.x + 2) at: iIdx++];	// BR
					[self setVertexIndex: (vIdx + 1) at: iIdx++];					// TR
					[self setVertexIndex: vIdx at: iIdx++];						// TL
				}
			}
		}
		
		// Horizontal position of the next character
		charPos.x += (charSpec.xAdvance * fontScale) + kerningAmount;
		
		prevChar = c;	// Remember the current character before moving on to the next
	}
	
	// Iterate through the lines, calculating the width adjustment to correctly align each line,
	// and applying that adjustment to the X-component of the location of each vertex that is
	// contained within that text line.
	for (NSUInteger i = 0; i < lineCount; i++) {
		GLfloat widthAdj;
		switch (textAlignment) {
			case UITextAlignmentCenter:
				// Adjust vertices so half the white space is on each side
				widthAdj = (layoutSize.width - lineSpecs[i].lineWidth) * 0.5f;
				break;
			case UITextAlignmentRight:
				// Adjust vertices so all the white space is on the left side
				widthAdj = layoutSize.width - lineSpecs[i].lineWidth;
				break;
			case UITextAlignmentLeft:
			default:
				// Leave all vertices where they are
				widthAdj = 0.0f;
				break;
		}
		if (widthAdj) {
			NSUInteger startVtxIdx = (i > 0) ? (lineSpecs[i - 1].lastVertexIndex + 1) : 0;
			NSUInteger endVtxIdx = lineSpecs[i].lastVertexIndex;
			LogTrace(@"%@ adjusting line %i by %.3f (from line width %i in layout width %i) from vertex %i to %i",
					 self, i, widthAdj, lineSpecs[i].lineWidth, layoutSize.width, startVtxIdx, endVtxIdx);
			for (vIdx = startVtxIdx; vIdx <= endVtxIdx; vIdx++) {
				CC3Vector vtxLoc = [self vertexLocationAt: vIdx];
				vtxLoc.x += widthAdj;
				[self setVertexLocation: vtxLoc at: vIdx];
			}
		}
	}
	
	// Move all vertices so that the origin of the vertex coordinate system is aligned
	// with a location derived from the origin factor.
	NSUInteger vtxCnt = self.vertexCount;
	CC3Vector originLoc = cc3v((layoutSize.width * origin.x), (layoutSize.height * origin.y), 0);
	for (vIdx = 0; vIdx < vtxCnt; vIdx++) {
		CC3Vector locOld = [self vertexLocationAt: vIdx];
		CC3Vector locNew = CC3VectorDifference(locOld, originLoc);
		[self setVertexLocation: locNew at: vIdx];
	}
	
	free(lineSpecs);	// Release the array of line widths
}
*/

#pragma mark -
#pragma mark Deprecated methods

// Deprecated
-(CC3TexturedVertex*) allocateTexturedVertices: (GLuint) vertexCount {
	self.vertexContentTypes = (kCC3VertexContentLocation |
							   kCC3VertexContentNormal |
							   kCC3VertexContentTextureCoordinates);
	self.allocatedVertexCapacity = vertexCount;
	return self.interleavedVertices;
}

// Deprecated
-(GLushort*) allocateIndexedTriangles: (GLuint) triangleCount {
	self.allocatedVertexIndexCapacity = (triangleCount * 3);
	return vertexIndices.vertices;
}

@end




