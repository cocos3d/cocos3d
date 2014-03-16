/*
 * CC3ModelSampleFactory.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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


@implementation CC3ModelSampleFactory

@synthesize unicoloredTeapotMesh=_unicoloredTeapotMesh;
@synthesize multicoloredTeapotMesh=_multicoloredTeapotMesh;
@synthesize texturedTeapotMesh=_texturedTeapotMesh;

-(void) dealloc {
	[_teapotVertexLocations release];
	[_teapotVertexNormals release];
	[_teapotVertexIndices release];
	[_teapotVertexTextureCoordinates release];
	[_teapotVertexColors release];
	[_texturedTeapotMesh release];
	[_multicoloredTeapotMesh release];
	[_unicoloredTeapotMesh release];

	[super dealloc];
}


#pragma mark Factory methods

-(CC3Mesh*) makeTeapotMeshNamed: (NSString*) aName {
	CC3Mesh* mesh = [CC3Mesh meshWithName: aName];
	mesh.shouldInterleaveVertices = NO;
	mesh.vertexLocations = _teapotVertexLocations;
	mesh.vertexNormals = _teapotVertexNormals;
	mesh.vertexIndices = _teapotVertexIndices;
	return mesh;
}

-(CC3MeshNode*) makeUniColoredTeapotNamed: (NSString*) aName withColor: (ccColor4F) color {
	CC3MeshNode* teapot = [CC3MeshNode nodeWithName: aName];
	teapot.mesh = self.unicoloredTeapotMesh;
	teapot.material = [CC3Material shiny];
	teapot.diffuseColor = color;
	return teapot;
}

-(CC3MeshNode*) makeMultiColoredTeapotNamed: (NSString*) aName {
	CC3MeshNode* teapot = [CC3MeshNode nodeWithName: aName];
	teapot.mesh = self.multicoloredTeapotMesh;
	teapot.material = [CC3Material shiny];
	return teapot;
}

-(CC3MeshNode*) makeTexturableTeapotNamed: (NSString*) aName {
	CC3MeshNode* teapot = [CC3MeshNode nodeWithName: aName];
	teapot.mesh = self.texturedTeapotMesh;
	return teapot;
}


#pragma mark Allocation and initialization

// Initialize teapot vertex arrays that can be reused in many teapots.
-(void) initTeapotVertexArrays {
	
	// Vertex locations come from the teapot.h header file
	_teapotVertexLocations = [[CC3VertexLocations vertexArrayWithName: @"TeapotVertices"] retain];
	_teapotVertexLocations.vertexCount = num_teapot_vertices;
	_teapotVertexLocations.vertices = teapot_vertices;
	
	// Vertex normals come from the teapot.h header file
	_teapotVertexNormals = [[CC3VertexNormals vertexArrayWithName: @"TeapotNormals"] retain];
	_teapotVertexNormals.vertexCount = num_teapot_normals;
	_teapotVertexNormals.vertices = teapot_normals;
	
	// Vertex indices populated from the run-length array in the teapot.h header file
	_teapotVertexIndices = [[CC3VertexIndices vertexArrayWithName: @"TeapotIndicies"] retain];
	[_teapotVertexIndices populateFromRunLengthArray: (GLushort*)new_teapot_indicies
										   ofLength: num_teapot_indices];
	_teapotVertexIndices.drawingMode = GL_TRIANGLE_STRIP;
	
	// Scan vertex location array to find the min & max of each vertex dimension.
	// This can be used below to create both simple color gradient and texture wraps for the mesh.
	CC3Vector vl, vlMin, vlMax, vlRange;
	CC3Vector* vLocs = (CC3Vector*)_teapotVertexLocations.vertices;
	GLuint vCount = _teapotVertexLocations.vertexCount;
	vl = vLocs[0];
	vlMin = vl;
	vlMax = vl;
	for (GLuint i = 1; i < vCount; i++) {
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
	_teapotVertexColors = [[CC3VertexColors vertexArrayWithName: @"TeapotColors"] retain];
	_teapotVertexColors.allocatedVertexCapacity = vCount;
	ccColor4B* vCols = (ccColor4B*)_teapotVertexColors.vertices;
	for (GLuint i=0; i < vCount; i++) {
		vCols[i].r = 255 * (vLocs[i].x - vlMin.x) / vlRange.x;
		vCols[i].g = 255 * (vLocs[i].y - vlMin.y) / vlRange.y;
		vCols[i].b = 255 * (vLocs[i].z - vlMin.z) / vlRange.z;
		vCols[i].a = 255;
	}
	
	// Progamatically create a texture array to map an arbitrary texture to the mesh vertices
	// in the X-Y plane. This would never happen in practice. Normally, the texture array would
	// be painted and extracted as part of the creation of a mesh in a 3D visual editor.
	_teapotVertexTextureCoordinates = [[CC3VertexTextureCoordinates vertexArrayWithName: @"TeapotTexture"] retain];
	_teapotVertexTextureCoordinates.allocatedVertexCapacity = vCount;
	ccTex2F* vTexCoord = (ccTex2F*)_teapotVertexTextureCoordinates.vertices;
	for (GLuint i=0; i < vCount; i++) {
		vTexCoord[i].u = (vLocs[i].x - vlMin.x) / vlRange.x;
		vTexCoord[i].v = (vLocs[i].y - vlMin.y) / vlRange.y;
	}
}

// Initialize several teapot meshes that can be reused in many teapots.
-(void) initTeapotMeshes {
	
	// Set up the vertex arrays that will be shared by all teapots
	[self initTeapotVertexArrays];
	
	// Mesh to support a teapot with single-colored material
	_unicoloredTeapotMesh = [[self makeTeapotMeshNamed: @"UnicoloredTeapot"] retain];
	
	// Mesh to support a teapot with separately colored vertices
	_multicoloredTeapotMesh = [[self makeTeapotMeshNamed: @"MulticolorTeapot"] retain];
	_multicoloredTeapotMesh.vertexColors = _teapotVertexColors;
	
	// Mesh to support a teapot with a textured surface
	_texturedTeapotMesh = [[self makeTeapotMeshNamed: @"TexturedTeapot"] retain];
	_texturedTeapotMesh.vertexTextureCoordinates = _teapotVertexTextureCoordinates;
}

-(id) init {
	if ( (self = [super init]) ) {
		[self initTeapotMeshes];
	}
	return self;
}

static CC3ModelSampleFactory* _factory = nil;

+(CC3ModelSampleFactory*) factory {
	if (!_factory) _factory = [self new];		// retained
	return _factory;
}

+(void) deleteFactory {
	[_factory release];
	_factory = nil;
}

@end
