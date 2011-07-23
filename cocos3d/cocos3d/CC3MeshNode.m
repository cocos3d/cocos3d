/*
 * CC3MeshNode.m
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
 * See header file CC3MeshNode.h for full API documentation.
 */

#import "CC3MeshNode.h"
#import "CC3BoundingVolumes.h"
#import "CC3OpenGLES11Engine.h"
#import "CGPointExtension.h"
#import "CC3VertexArrayMesh.h"


@interface CC3Node (TemplateMethods)
-(void) populateFrom: (CC3Node*) another;
-(void) updateBoundingVolume;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) configureDrawingParameters;
-(void) configureFaceCulling;
-(void) configureNormalization;
-(void) configureColoring;
-(void) populateAsVertexBox: (CC3BoundingBox) box;
@end

@implementation CC3MeshNode

@synthesize mesh, material, pureColor, shouldCullBackFaces, shouldCullFrontFaces;

-(void) dealloc {
	[mesh release];
	[material release];
	[super dealloc];
}

// Sets the mesh then, if a bounding volume exists, forces it to rebuild
// using the new mesh data, or creates a default bounding volume from the mesh.
-(void) setMesh:(CC3Mesh *) aMesh {
	id oldMesh = mesh;
	mesh = [aMesh retain];
	[oldMesh release];
	if (boundingVolume) {
		[self.boundingVolume buildVolume];
	} else {
		self.boundingVolume = [mesh defaultBoundingVolume];
	}

}

// Support for legacy CC3MeshModel class
-(CC3MeshModel*) meshModel {
	return (CC3MeshModel*)self.mesh;
}

// Support for legacy CC3MeshModel class
-(void) setMeshModel: (CC3MeshModel *) aMesh {
	self.mesh = aMesh;
}

// After setting the bounding volume, forces it to build its volume from the mesh
-(void) setBoundingVolume:(CC3NodeBoundingVolume *) aBoundingVolume {
	[super setBoundingVolume: aBoundingVolume];
	[self.boundingVolume buildVolume];
}


#pragma mark Material coloring

-(BOOL) shouldUseLighting {
	return material ? material.shouldUseLighting : NO;
}

-(void) setShouldUseLighting: (BOOL) useLighting {
	material.shouldUseLighting = useLighting;
	[super setShouldUseLighting: useLighting];	// pass along to any children
}

-(ccColor4F) ambientColor {
	return material ? material.ambientColor : kCCC4FBlackTransparent;
}

-(void) setAmbientColor:(ccColor4F) aColor {
	material.ambientColor = aColor;
	[super setAmbientColor: aColor];	// pass along to any children
}

-(ccColor4F) diffuseColor {
	return material ? material.diffuseColor : kCCC4FBlackTransparent;
}

-(void) setDiffuseColor:(ccColor4F) aColor {
	material.diffuseColor = aColor;
	[super setDiffuseColor: aColor];	// pass along to any children
}

-(ccColor4F) specularColor {
	return material ? material.specularColor : kCCC4FBlackTransparent;
}

-(void) setSpecularColor:(ccColor4F) aColor {
	material.specularColor = aColor;
	[super setSpecularColor: aColor];	// pass along to any children
}

-(ccColor4F) emissionColor {
	return material ? material.emissionColor : kCCC4FBlackTransparent;
}

-(void) setEmissionColor:(ccColor4F) aColor {
	material.emissionColor = aColor;
	[super setEmissionColor: aColor];	// pass along to any children
}

/** If the material has a bump-mapped texture, returns the global direction  */
-(CC3Vector) globalLightLocation {
	return (material && material.hasBumpMap)
			? [self.transformMatrix transformDirection: material.lightDirection]
			: [super globalLightLocation];
}

-(void) setGlobalLightLocation: (CC3Vector) aLocation {
	if (material && material.hasBumpMap) {
		material.lightDirection = [self.transformMatrixInverted transformDirection: aLocation];
	}
	[super setGlobalLightLocation: aLocation];
}


#pragma mark CCRGBAProtocol support

-(ccColor3B) color {
	return material ? material.color : ccc3(CCColorByteFromFloat(pureColor.r),
											CCColorByteFromFloat(pureColor.g),
											CCColorByteFromFloat(pureColor.b));
}

-(void) setColor: (ccColor3B) color {
	material.color = color;

	pureColor.r = CCColorFloatFromByte(color.r);
	pureColor.g = CCColorFloatFromByte(color.g);
	pureColor.b = CCColorFloatFromByte(color.b);

	[super setColor: color];	// pass along to any children
}

-(GLubyte) opacity {
	return material ? material.opacity : CCColorByteFromFloat(pureColor.a);
}

-(void) setOpacity: (GLubyte) opacity {
	material.opacity = opacity;
	pureColor.a = CCColorFloatFromByte(opacity);

	[super setOpacity: opacity];	// pass along to any children
}

-(BOOL) isOpaque {
	return material ? material.isOpaque : (pureColor.a == 1.0f);
}

-(void) setIsOpaque: (BOOL) opaque {
	material.isOpaque = opaque;
	pureColor.a = 1.0f;
	
	[super setIsOpaque: opaque];	// pass along to any children
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		pureColor = kCCC4FWhite;
		shouldCullBackFaces = YES;
		shouldCullFrontFaces = NO;
	}
	return self;
}

-(void) createGLBuffers {
	LogTrace(@"%@ creating GL server buffers", self);
	[mesh createGLBuffers];
	[super createGLBuffers];
}

-(void) deleteGLBuffers {
	[mesh deleteGLBuffers];
	[super deleteGLBuffers];
}

-(void) releaseRedundantData {
	[mesh releaseRedundantData];
	[super releaseRedundantData];
}

-(void) retainVertexLocations {
	[mesh retainVertexLocations];
	[super retainVertexLocations];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// A copy is made of the material.
// The mesh is simply retained, without creating a copy.
// Both this node and the other node will share the mesh.
-(void) populateFrom: (CC3MeshNode*) another {
	[super populateFrom: another];
	
	self.mesh = another.mesh;						// retained
	self.material = [another.material copyAutoreleased];	// retained

	pureColor = another.pureColor;
	shouldCullBackFaces = another.shouldCullBackFaces;
	shouldCullFrontFaces = another.shouldCullFrontFaces;
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)];
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) facesPerSide {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
					  andTessellation: facesPerSide];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	[self populateAsRectangleWithSize: rectSize andPivot: pivot andTessellation: ccg(1, 1)];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide {
	NSString* itemName;
	CCTexturedVertex* vertices;		// Array of custom structures to hold the interleaved vertex data
	
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
	locArray.elementStride = sizeof(CCTexturedVertex);	// Set stride before allocating elements.
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

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
						  withTexture: texture
						invertTexture: shouldInvert];
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) facesPerSide
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
					  andTessellation: facesPerSide
						  withTexture: texture
						invertTexture: shouldInvert];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
					  andTessellation:  ccg(1, 1)
						  withTexture: texture
						invertTexture: shouldInvert];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert {
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
	CCTexturedVertex* vertices = locArray.elements;
	
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
	
	// Align the texture coordinates to the texture
	if (shouldInvert) {
		[tcArray alignWithInvertedTexture: texture];
	} else {
		[tcArray alignWithTexture: texture];
	}
	
	// Add a material and attach the texture
	itemName = [NSString stringWithFormat: @"%@-Material", self.name];
	self.material = [CC3Material materialWithName: itemName];
	self.material.texture = texture;
}

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
	CCTexturedVertex* vertices;		// Array of custom structures to hold the interleaved vertex data
	CC3Vector boxMin = box.minimum;
	CC3Vector boxMax = box.maximum;
	GLuint vertexCount = 8;
	
	// Create vertexLocation array.
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	locArray.elementStride = sizeof(CCTexturedVertex);	// Set stride before allocating elements.
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
	
	// Populate normals up the positive Z-axis
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


#pragma mark Type testing

-(BOOL) isMeshNode {
	return YES;
}


#pragma mark Drawing

/**
 * If we have a material, delegates to the material to set material and texture state,
 * otherwise, establishes the pure color by turning lighting off and setting the color.
 * One material or color is set, delegates to the mesh to draw mesh.
 */
-(void) drawLocalContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11StateTrackerCapability* gles11Lighting = gles11Engine.serverCapabilities.lighting;

	// Remember current lighting state in case we disable it to apply pure color.
	BOOL lightingWasEnabled = gles11Lighting.value;

	[self configureDrawingParameters];		// Before material draws.

	if (visitor.shouldDecorateNode) {
		if (material) {
			[material drawWithVisitor: visitor];
		} else {
			[CC3Material unbind];
			[gles11Lighting disable];
			gles11Engine.state.color.value = pureColor;
		}
	} else {
		[CC3Material unbind];
	}
	[mesh drawWithVisitor: visitor];

	// Re-establish previous lighting state.
	gles11Lighting.value = lightingWasEnabled;
}

/**
 * Configures the drawing parameters.
 *
 * The default implementation configures normalization and vertex coloring.
 * Subclasses may override to add additional drawing parameters.
 */
-(void) configureDrawingParameters {
	[self configureFaceCulling];
	[self configureNormalization];
	[self configureColoring];
}

/** Configures GL face culling based on the shouldCullBackFaces and shouldCullBackFaces properties. */
-(void) configureFaceCulling {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = gles11Engine.serverCapabilities;
	CC3OpenGLES11State* gles11State = gles11Engine.state;

	// Enable culling if either back or front should be culled.
	gles11ServCaps.cullFace.value = shouldCullBackFaces || shouldCullFrontFaces;

	// Set whether back, front or both should be culled.
	// If neither should be culled, handled by capability so leave it as back culling.
	gles11State.cullFace.value = shouldCullBackFaces
									? (shouldCullFrontFaces ? GL_FRONT_AND_BACK : GL_BACK)
									: (shouldCullFrontFaces ? GL_FRONT : GL_BACK);

}

/** Configures GL scaling of normals, based on whether the scaling of this node is uniform or not. */
-(void) configureNormalization {
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = [CC3OpenGLES11Engine engine].serverCapabilities;
	if (mesh && mesh.hasNormals) {
		if (self.isUniformlyScaledGlobally) {
			[gles11ServCaps.rescaleNormal enable];
			[gles11ServCaps.normalize disable];
		} else {
			[gles11ServCaps.rescaleNormal disable];
			[gles11ServCaps.normalize enable];
		}
	} else {
		[gles11ServCaps.rescaleNormal disable];
		[gles11ServCaps.normalize disable];
	}
}

/**
 * Configures the GL state to support vertex coloring. This must be invoked every time, because
 * both the material and mesh influence this property, and the mesh will not be re-bound if it
 * does not need to be switched. And this method must be invoked before material colors are set,
 * otherwise material colors will not stick.
 */
-(void) configureColoring {
	[CC3OpenGLES11Engine engine].serverCapabilities.colorMaterial.value = (mesh ? mesh.hasColors : NO);
}

@end


#pragma mark -
#pragma mark CC3LineNode

@interface CC3LineNode (TemplateMethods)
-(void) configureLineProperties;
@end


@implementation CC3LineNode

@synthesize lineWidth, shouldSmoothLines, performanceHint;


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		lineWidth = 1.0f;
		shouldSmoothLines = NO;
		performanceHint = GL_DONT_CARE;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3LineNode*) another {
	[super populateFrom: another];
	
	lineWidth = another.lineWidth;
	shouldSmoothLines = another.shouldSmoothLines;
	performanceHint = another.performanceHint;
}


#pragma mark Drawing

/** Overridden to set the line properties in addition to other configuration. */
-(void) configureDrawingParameters {
	[super configureDrawingParameters];
	[self configureLineProperties];
}

-(void) configureLineProperties {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	gles11Engine.state.lineWidth.value = lineWidth;
	gles11Engine.serverCapabilities.lineSmooth.value = shouldSmoothLines;
	gles11Engine.hints.lineSmooth.value = performanceHint;
}

@end


#pragma mark -
#pragma mark CC3PlaneNode

@implementation CC3PlaneNode

-(CC3Plane) plane {
	CC3VertexArrayMesh* vam = (CC3VertexArrayMesh*)self.mesh;
	CC3BoundingBox bb = vam.vertexLocations.boundingBox;
	
	// Get three points on the plane by using three corners of the mesh bounding box.
	CC3Vector p1 = bb.minimum;
	CC3Vector p2 = bb.maximum;
	CC3Vector p3 = bb.minimum;
	p3.x = bb.maximum.x;

	// Transform these points.
	p1 = [self.transformMatrix transformLocation: p1];
	p2 = [self.transformMatrix transformLocation: p2];
	p3 = [self.transformMatrix transformLocation: p3];

	// Create and return a plane from these points.
	return CC3PlaneFromPoints(p1, p2, p3);
}

@end


#pragma mark -
#pragma mark CC3BoxNode

@implementation CC3BoxNode
@end

