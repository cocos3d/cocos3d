/*
 * CC3MeshNode.m
 *
 * cocos3d 0.5.4
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
#import "CC3VertexArrayMeshModel.h"


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

@synthesize meshModel, material, pureColor, shouldCullBackFaces, shouldCullFrontFaces;

-(void) dealloc {
	[meshModel release];
	[material release];
	[super dealloc];
}

// Sets the mesh model then, if a bounding volume exists, forces it to rebuild
// using the new mesh data, or creates a default bounding volume from the mesh model.
-(void) setMeshModel:(CC3MeshModel *) aMeshModel {
	id oldMesh = meshModel;
	meshModel = [aMeshModel retain];
	[oldMesh release];
	if (boundingVolume) {
		[self.boundingVolume buildVolume];
	} else {
		self.boundingVolume = [meshModel defaultBoundingVolume];
	}

}

// After setting the bounding volume, forces it to build its volume from the mesh
-(void) setBoundingVolume:(CC3NodeBoundingVolume *) aBoundingVolume {
	[super setBoundingVolume: aBoundingVolume];
	[self.boundingVolume buildVolume];
}


#pragma mark Material coloring

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
	[meshModel createGLBuffers];
	[super createGLBuffers];
}

-(void) deleteGLBuffers {
	[meshModel deleteGLBuffers];
	[super deleteGLBuffers];
}

-(void) releaseRedundantData {
	[meshModel releaseRedundantData];
	[super releaseRedundantData];
}

-(void) retainVertexLocations {
	[meshModel retainVertexLocations];
	[super retainVertexLocations];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// A copy is made of the material.
// The mesh model is simply assigned, without creating a copy.
// Both this node and the other node will share the mesh model.
-(void) populateFrom: (CC3MeshNode*) another {
	[super populateFrom: another];
	
	[meshModel release];
	meshModel = [another.meshModel retain];		// retained

	[material release];
	material = [another.material copy];			// retained

	pureColor = another.pureColor;
	shouldCullBackFaces = another.shouldCullBackFaces;
	shouldCullFrontFaces = another.shouldCullFrontFaces;
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot {
	NSString* itemName;
	CCTexturedVertex* vertices;		// Array of custom structures to hold the interleaved vertex data
	GLfloat xMin = 0.0f - pivot.x;
	GLfloat xMax = rectSize.width - pivot.x;
	GLfloat yMin = 0.0f - pivot.y;
	GLfloat yMax = rectSize.height - pivot.y;
	int vCount = 4;
	
	// Interleave the vertex locations, normals and tex coords
	// Create vertex location array, allocating enough space for the stride of the full structure
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	locArray.drawingMode = GL_TRIANGLE_STRIP;			// Location array will do the drawing as a strip
	locArray.elementStride = sizeof(CCTexturedVertex);	// Set stride before allocating elements.
	locArray.elementOffset = 0;							// Offset to location element in vertex structure
	vertices = [locArray allocateElements: vCount];

	// Populate vertex locations in the X-Y plane
	vertices[0].location = (CC3Vector){xMax, yMax, 0.0};
	vertices[1].location = (CC3Vector){xMin, yMax, 0.0};
	vertices[2].location = (CC3Vector){xMax, yMin, 0.0};
	vertices[3].location = (CC3Vector){xMin, yMin, 0.0};
	
	// Create the normal array interleaved on the same element array
	itemName = [NSString stringWithFormat: @"%@-Normals", self.name];
	CC3VertexNormals* normArray = [CC3VertexNormals vertexArrayWithName: itemName];
	normArray.elements = vertices;
	normArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
	normArray.elementCount = vCount;
	normArray.elementOffset = sizeof(CC3Vector);		// Offset to normal element in vertex structure
	
	// Populate normals up the positive Z-axis
	vertices[0].normal = kCC3VectorUnitZPositive;
	vertices[1].normal = kCC3VectorUnitZPositive;
	vertices[2].normal = kCC3VectorUnitZPositive;
	vertices[3].normal = kCC3VectorUnitZPositive;
	
	// Create mesh model with interleaved vertex arrays
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMeshModel* mesh = [CC3VertexArrayMeshModel meshWithName: itemName];
	mesh.interleaveVertices = YES;
	mesh.vertexLocations = locArray;
	mesh.vertexNormals = normArray;
	self.meshModel = mesh;
}

-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert {
	[self populateAsRectangleWithSize: rectSize
							 andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
						  withTexture: texture
						invertTexture: shouldInvert];
}

-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert {
	NSString* itemName;

	// Start as a basic white rectangle of the right size and location.
	[self populateAsRectangleWithSize: rectSize andPivot: pivot];
	
	// Get my mesh model and vertices.
	CC3VertexArrayMeshModel* vamm = (CC3VertexArrayMeshModel*)self.meshModel; 
	CC3VertexLocations* locArray = vamm.vertexLocations;
	
	// Create the tex coord array interleaved on the same element array as the vertex locations
	CC3VertexTextureCoordinates* tcArray = nil;
	itemName = [NSString stringWithFormat: @"%@-Texture", self.name];
	tcArray = [CC3VertexTextureCoordinates vertexArrayWithName: itemName];
	tcArray.elements = locArray.elements;
	tcArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
	tcArray.elementCount = locArray.elementCount;
	tcArray.elementOffset = 2 * sizeof(CC3Vector);	// Offset to texcoord element in vertex structure

	// Add the texture coordinates array to the mesh model
	vamm.vertexTextureCoordinates = tcArray;
	
	// Populate the texture coordinate array mapping
	CCTexturedVertex* vertices = locArray.elements;
	
	vertices[0].texCoord = (ccTex2F){1.0, 1.0};
	vertices[1].texCoord = (ccTex2F){0.0, 1.0};
	vertices[2].texCoord = (ccTex2F){1.0, 0.0};
	vertices[3].texCoord = (ccTex2F){0.0, 0.0};
	
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
	
	// Create mesh model with interleaved vertex arrays
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMeshModel* mesh = [CC3VertexArrayMeshModel meshWithName: itemName];
	mesh.interleaveVertices = YES;
	mesh.vertexLocations = locArray;
	mesh.vertexNormals = normArray;
	mesh.vertexIndices = indexArray;
	self.meshModel = mesh;
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
	CC3VertexArrayMeshModel* mesh = [CC3VertexArrayMeshModel meshWithName: itemName];
	mesh.vertexLocations = locArray;
	mesh.vertexIndices = indexArray;
	self.meshModel = mesh;
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
	CC3VertexArrayMeshModel* mesh = [CC3VertexArrayMeshModel meshWithName: itemName];
	mesh.vertexLocations = locArray;
	self.meshModel = mesh;
}


#pragma mark Type testing

-(BOOL) isMeshNode {
	return YES;
}


#pragma mark Drawing

/**
 * If we have a material, delegates to the material to set material and texture state,
 * otherwise, establishes the pure color by turning lighting off and setting the color.
 * One material or color is set, delegates to the mesh model to draw mesh.
 */
-(void) drawLocalContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11StateTrackerCapability* gles11Lighting = gles11Engine.serverCapabilities.lighting;

	// Remember current lighting state in case we disable it to apply pure color.
	BOOL lightingWasEnabled = gles11Lighting.value;

	[self configureDrawingParameters];		// Before material draws.

	if (visitor.shouldDecorateNode) {
		if (material) {
			[material draw];
		} else {
			[CC3Material unbind];
			[gles11Lighting disable];
			gles11Engine.state.color.value = pureColor;
		}
	} else {
		[CC3Material unbind];
	}
	[meshModel drawWithVisitor: visitor];

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
	if (meshModel && meshModel.hasNormals) {
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
	[CC3OpenGLES11Engine engine].serverCapabilities.colorMaterial.value = (meshModel ? meshModel.hasColors : NO);
}

@end


#pragma mark -
#pragma mark CC3LineNode

@interface CC3LineNode (TemplateMethods)
-(void) configureLineProperties;
@end


@implementation CC3LineNode

@synthesize lineWidth, shouldSmoothLines;


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		lineWidth = 1.0f;
		shouldSmoothLines = NO;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3LineNode*) another {
	[super populateFrom: another];
	
	lineWidth = another.lineWidth;
	shouldSmoothLines = another.shouldSmoothLines;
}


#pragma mark Drawing

/** Overridden to set the line properties in addition to other configuration. */
-(void) configureDrawingParameters {
	[super configureDrawingParameters];
	[self configureLineProperties];
}

-(void) configureLineProperties {
	[CC3OpenGLES11Engine engine].serverCapabilities.lineSmooth.value = shouldSmoothLines;
	[CC3OpenGLES11Engine engine].state.lineWidth.value = lineWidth;
}

@end


#pragma mark -
#pragma mark CC3PlaneNode

@implementation CC3PlaneNode

-(CC3Plane) plane {
	CC3VertexArrayMeshModel* vamm = (CC3VertexArrayMeshModel*)self.meshModel;
	CC3VertexLocations* vLocs = vamm.vertexLocations;
	CC3VertexIndices* vIndices = vamm.vertexIndices;

	GLushort i0 = 0, i1 = 1, i2 = 2;

	// If the mesh model uses indices, access the first three vertices through the indices.
	if (vIndices) {
		i0 = [vIndices indexAt: i0];
		i1 = [vIndices indexAt: i1];
		i2 = [vIndices indexAt: i2];
	}
	// Retrieve the first three indices in drawing order.
	CC3Vector p1 = [self.transformMatrix transformLocation: [vLocs locationAt: i0]];
	CC3Vector p2 = [self.transformMatrix transformLocation: [vLocs locationAt: i1]];
	CC3Vector p3 = [self.transformMatrix transformLocation: [vLocs locationAt: i2]];
	
	// Create and return a plane from these points
	return CC3PlaneFromPoints(p1, p2, p3);
}

@end


#pragma mark -
#pragma mark CC3BoxNode

@implementation CC3BoxNode
@end

