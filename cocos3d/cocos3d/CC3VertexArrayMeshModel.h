/*
 * CC3VertexArrayMeshModel.h
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
 */

/** @file */	// Doxygen marker

#import "CC3MeshModel.h"
#import "CC3VertexArrays.h"
#import "CC3BoundingVolumes.h"


/**
 * A CC3VertexArrayMeshModel is a mesh model whose mesh data is kept in a set of
 * CC3VertexArrays instances. Each of the contained CC3VertexArray instances manages the
 * data for one aspect of the vertices (locations, normals, colors, texture mapping...).
 *
 * Vertex data can be interleaved into a single underlying memory buffer that is shared
 * between the contained CC3VertexArrays, or it can be separated into distinct memory
 * buffers for each vertex aspect.
 *
 * The only vertex array that is required is the vertexLocations property. The others are
 * optional, depending on the nature of the mesh. If the vertexIndices property is provided,
 * it will be used during drawing. Otherwise, the vertices will be drawn in linear order
 * as they appear in the vertexLocations property.
 *
 * When a copy is made of a CC3VertexArrayMeshModel instance, copies are not made of the
 * vertex arrays. Instead, they are retained by reference and shared between both the
 * original mesh model, and the new copy.
 *
 * CC3VertexArrayMeshModel manages data for one contiguous set of vertices that can be
 * drawn with a single call to the GL engine, or a single set of draw-strip calls to the
 * GL engine, using the same materail properties. To assemble a large, complex mesh
 * containing several distinct vertex groups, assign each vertex group to its own
 * CC3VertexArrayMeshModel instance, wrap each mesh model instance in a CC3MeshNode
 * instance, and create an structural assembly of the nodes. See the class notes for
 * CC3MeshNode for more information on assembling mesh nodes.
 */
@interface CC3VertexArrayMeshModel : CC3MeshModel {
	CC3VertexLocations* vertexLocations;
	CC3VertexNormals* vertexNormals;
	CC3VertexColors* vertexColors;
	CC3VertexTextureCoordinates* vertexTextureCoordinates;
	CC3VertexIndices* vertexIndices;
	BOOL interleaveVertices;
}

/** The vertex array instance managing the positional data for the vertices. */
@property(nonatomic, retain) CC3VertexLocations* vertexLocations;

/**
 * The vertex array instance managing the normal data for the vertices.
 *
 * Setting this property is optional. Not all meshes require normals.
 */
@property(nonatomic, retain) CC3VertexNormals* vertexNormals;

/**
 * The vertex array instance managing the per-vertex color data for the vertices.
 *
 * Setting this property is optional. Many meshes do not require per-vertex coloring.
 */
@property(nonatomic, retain) CC3VertexColors* vertexColors;

/**
 * The vertex array instance managing the texture mapping data for the vertices.
 *
 * Setting this property is optional. Not all meshes use textures.
 */
@property(nonatomic, retain) CC3VertexTextureCoordinates* vertexTextureCoordinates;

/**
 * The vertex array instance managing the index data for the vertices.
 *
 * Setting this property is optional. If vertex index data is not provided, the vertices
 * will be drawn in linear order as they appear in the vertexLocations property.
 */
@property(nonatomic, retain) CC3VertexIndices* vertexIndices;

/**
 * Indicates whether the vertex data is interleaved, or separated by aspect.
 * The initial value is NO, indicating that the vertex data is not interleaved.
 *
 * If the vertex data is interleaved, each of the CC3VertexArray instances will
 * reference the same underlying memory buffer through their individual elements property.
 */
@property(nonatomic, assign) BOOL interleaveVertices;

@end


#pragma mark -
#pragma mark CC3VertexLocationsBoundingVolume interface

/**
 * CC3VertexLocationsBoundingVolume is a type of CC3NodeBoundingVolume
 * specialized for use with CC3VertexArrayMeshModel and CC3VertexLocations.
 *
 * The value of the centerOfGeometry property is automatically calculated from
 * the vertex location data by the buildVolume method of this instance.
 */
@interface CC3VertexLocationsBoundingVolume : CC3NodeBoundingVolume
@end


#pragma mark -
#pragma mark CC3VertexLocationsSphericalBoundingVolume interface

/**
 * CC3VertexLocationsSphericalBoundingVolume is a type of CC3NodeSphericalBoundingVolume
 * specialized for use with CC3VertexArrayMeshModel and CC3VertexLocations.
 *
 * The values of the centerOfGeometry and radius properties are automatically calculated
 * from the vertex location data by the buildVolume method of this instance.
 */
@interface CC3VertexLocationsSphericalBoundingVolume : CC3NodeSphericalBoundingVolume
@end


#pragma mark -
#pragma mark CC3VertexLocationsBoundingBoxVolume interface


/**
 * CC3VertexLocationsBoundingBoxVolume is a type of CC3NodeBoundingBoxVolume
 * specialized for use with CC3VertexArrayMeshModel and CC3VertexLocations.
 *
 * The value of the boundingBox property is automatically calculated from
 * the vertex location data by the buildVolume method of this instance.
 */
@interface CC3VertexLocationsBoundingBoxVolume : CC3NodeBoundingBoxVolume
@end
