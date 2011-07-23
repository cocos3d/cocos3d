/*
 * CC3ModelSampleFactory.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3ModelSampleFactory.h for full API documentation.
 */

#import "CC3ModelSampleFactory.h"
#import "teapot.h"

@interface CC3ModelSampleFactory (TemplateMethods)
-(CC3VertexArrayMesh*) makeTeapotMeshNamed: (NSString*) aName;
@end


@implementation CC3ModelSampleFactory

@synthesize unicoloredTeapotMesh, multicoloredTeapotMesh, texturedTeapotMesh;

-(void) dealloc {
	[logoTexture release];
	[teapotVertexLocations release];
	[teapotVertexNormals release];
	[teapotVertexIndices release];
	[teapotVertexTextureCoordinates release];
	[teapotVertexColors release];
	[texturedTeapotMesh release];
	[multicoloredTeapotMesh release];
	[unicoloredTeapotMesh release];
	[super dealloc];
}


#pragma mark Allocation and initialization

// Initialize static teapot vertex arrays that can be reused in many teapots.
-(void) initTeapotVertexArrays {
	
	// Vertex locations come from teapot.h header file
	teapotVertexLocations = [CC3VertexLocations vertexArrayWithName: @"TeapotVertices"];
	teapotVertexLocations.elementCount = num_teapot_vertices;
	teapotVertexLocations.elements = teapot_vertices;
	
	// Vertex normals come from teapot.h header file
	teapotVertexNormals = [CC3VertexNormals vertexArrayWithName: @"TeapotNormals"];
	teapotVertexNormals.elementCount = num_teapot_normals;
	teapotVertexNormals.elements = teapot_normals;
	
	// Vertex indices come from teapot.h header file
	teapotVertexIndices = [CC3VertexRunLengthIndices vertexArrayWithName: @"TeapotIndicies"];
	teapotVertexIndices.elementCount = num_teapot_indices;
	teapotVertexIndices.elements = (GLushort*)new_teapot_indicies;
	
	// Scan vertex location array to find the min & max of each vertex dimension.
	// This can be used below to create both simple color gradient and texture wraps for the mesh.
	CC3Vector vl, vlMin, vlMax, vlRange;
	CC3Vector* vLocs = (CC3Vector*)teapotVertexLocations.elements;
	GLsizei vCount = teapotVertexLocations.elementCount;
	vl = vLocs[0];
	vlMin = vl;
	vlMax = vl;
	for (GLsizei i = 1; i < vCount; i++) {
		vl = vLocs[i];
		vlMin = CC3VectorMinimize(vlMin, vl);
		vlMax = CC3VectorMaximize(vlMax, vl);
	}
	
	vlRange.x = vlMax.x - vlMin.x;
	vlRange.y = vlMax.y - vlMin.y;
	vlRange.z = vlMax.z - vlMin.z;
	
	// Create a color array to assign colors to each vertex in a simple gradient pattern.
	// This would never happen in practice. Normally, the color array would be applied
	// and extracted as part of the creation of a mesh in a visual editor.
	teapotVertexColors = [CC3VertexColors vertexArrayWithName: @"TeapotColors"];
	ccColor4F* vCols = (ccColor4F*)[teapotVertexColors allocateElements: vCount];
	for (GLsizei i=0; i < vCount; i++) {
		vCols[i].r = (vLocs[i].x - vlMin.x) / vlRange.x;
		vCols[i].g = (vLocs[i].y - vlMin.y) / vlRange.y;
		vCols[i].b = (vLocs[i].z - vlMin.z) / vlRange.z;
		vCols[i].a = 1.0;
	}
	
	// Progamatically create a texture array to map an arbitrary texture to the mesh vertices
	// in the X-Y plane. This would never happen in practice. Normally, the texture array would
	// be painted and extracted as part of the creation of a mesh in a 3D visual editor.
	teapotVertexTextureCoordinates = [CC3VertexTextureCoordinates vertexArrayWithName: @"TeapotTexture"];
	ccTex2F* vTexCoord = (ccTex2F*)[teapotVertexTextureCoordinates allocateElements: vCount];
	for (GLsizei i=0; i < vCount; i++) {
		vTexCoord[i].u = (vLocs[i].x - vlMin.x) / vlRange.x;
		vTexCoord[i].v = (vLocs[i].y - vlMin.y) / vlRange.y;
	}
	
	// Load the texture that will be used for the textured teapot and
	// align the teapot texture coordinates to cover the texture's visible area.
	// This actually changes the values of the texture coordinates.
	logoTexture = [CC3Texture textureFromFile: @"Default.png"];
	[teapotVertexTextureCoordinates alignWithInvertedTexture: logoTexture];
}

// Initialize several static teapot meshes that can be reused in many teapots.
-(void) initTeapotMeshes {
	
	// Set up the vertex arrays that will be shared by all teapots
	[self initTeapotVertexArrays];
	
	// Mesh to support a teapot with single-colored material
	unicoloredTeapotMesh = [self makeTeapotMeshNamed: @"UnicoloredTeapot"];
	
	// Mesh to support a teapot with separately colored vertices
	multicoloredTeapotMesh = [self makeTeapotMeshNamed: @"MulticolorTeapot"];
	multicoloredTeapotMesh.vertexColors = teapotVertexColors;
	
	// Mesh to support a teapot with a textured surface
	texturedTeapotMesh = [self makeTeapotMeshNamed: @"TexturedTeapot"];
	texturedTeapotMesh.vertexTextureCoordinates = teapotVertexTextureCoordinates;
}

-(id) init {
	if ( (self = [super init]) ) {
		[self initTeapotMeshes];
	}
	return self;
}

static CC3ModelSampleFactory* factory;

+(CC3ModelSampleFactory*) factory {
	if (!factory) {
		factory = [self new];	// statically retained
	}
	return factory;
}


#pragma mark Factory methods

// Returns an autoreleased mesh of a teapot named with the specified name
-(CC3VertexArrayMesh*) makeTeapotMeshNamed: (NSString*) aName {
	CC3VertexArrayMesh* mesh = [CC3VertexArrayMesh meshWithName: aName];
	mesh.vertexLocations = teapotVertexLocations;
	mesh.vertexNormals = teapotVertexNormals;
	mesh.vertexIndices = teapotVertexIndices;
	return mesh;
}

// Returns an autoreleased mesh node displaying a teapot in a particular color
-(CC3MeshNode*) makeUniColoredTeapotNamed: (NSString*) aName withColor: (ccColor4F) color {
	CC3MeshNode* teapot = [CC3MeshNode nodeWithName: aName];
	teapot.mesh = unicoloredTeapotMesh;
	teapot.material = [CC3Material shiny];
	teapot.material.name = [NSString stringWithFormat: @"%@-Mat", aName];
	teapot.material.diffuseColor = color;	
	return teapot;
}

// Returns an autoreleased mesh node displaying a teapot painted with a color gradient...very funky
-(CC3MeshNode*) makeMultiColoredTeapotNamed: (NSString*) aName {
	CC3MeshNode* teapot = [CC3MeshNode nodeWithName: aName];
	teapot.mesh = multicoloredTeapotMesh;
	teapot.material = [CC3Material shiny];
	teapot.material.name = [NSString stringWithFormat: @"%@-Mat", aName];
	return teapot;
}

// Returns an autoreleased mesh node displaying a teapot covered by a cocos2d logo texture
-(CC3MeshNode*) makeLogoTexturedTeapotNamed: (NSString*) aName {
	CC3MeshNode* teapot = [CC3MeshNode nodeWithName: aName];
	teapot.mesh = texturedTeapotMesh;
	teapot.material = [CC3Material shiny];
	teapot.material.name = [NSString stringWithFormat: @"%@-Mat", aName];
	teapot.material.texture = logoTexture;
	return teapot;
}


@end
