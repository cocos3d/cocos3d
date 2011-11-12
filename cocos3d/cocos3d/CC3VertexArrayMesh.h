/*
 * CC3VertexArrayMesh.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Mesh.h"
#import "CC3VertexArrays.h"
#import "CC3BoundingVolumes.h"


/**
 * A CC3VertexArrayMesh is a mesh whose mesh data is kept in a set of
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
 * This class supports multi-texturing. In most situations, the mesh will use the
 * same texture mapping for all texture units. In this case, the single texture coordinates
 * array in the vertexTexureCoordinates property will be applied to all texture units.
 *
 * If multi-texturing is used, and separate texture coordinate mapping is required
 * for each texture unit, additional texture coordinate arrays can be added using the
 * addTextureCoordinates: method.
 *
 * For consistency, the addTextureCoordinates:, removeTextureCoordinates:, and
 * getTextureCoordinatesNamed: methods all interact with the vertexTextureCoordinates
 * property. If that property has not been set, the first texture coordinate array that
 * is added via addTextureCoordinates: will be set into the vertexTextureCoordinates
 * array. And the removeTextureCoordinates:, and getTextureCoordinatesNamed: methods
 * each check the vertexTextureCoordinates property as well as the overlayTextureCoordinates
 * collection. This design can simplify configurations in that all texture coordinate arrays
 * can be treated the same.
 *
 * If there are more textures applied to a node than there are texture coordinate arrays
 * in the mesh (including the vertexTextureCoordinates and the those in the
 * overlayTextureCoordinates collection), the last texture coordinate array is reused.
 *
 * This class supports covering the mesh with a repeating texture through the
 * repeatTexture: method.
 *
 * This class also supports covering the mesh with only a fractional part of the texture
 * through the use of the textureRectangle property, effectlivly permitting sprite-sheet
 * textures to be used with 3D meshes.
 *
 * When a copy is made of a CC3VertexArrayMesh instance, copies are not made of the
 * vertex arrays. Instead, they are retained by reference and shared between both the
 * original mesh, and the new copy.
 *
 * CC3VertexArrayMesh manages data for one contiguous set of vertices that can be
 * drawn with a single call to the GL engine, or a single set of draw-strip calls to the
 * GL engine, using the same materail properties. To assemble a large, complex mesh
 * containing several distinct vertex groups, assign each vertex group to its own
 * CC3VertexArrayMesh instance, wrap each mesh instance in a CC3MeshNode
 * instance, and create an structural assembly of the nodes. See the class notes for
 * CC3MeshNode for more information on assembling mesh nodes.
 */
@interface CC3VertexArrayMesh : CC3Mesh {
	CC3VertexLocations* vertexLocations;
	CC3VertexNormals* vertexNormals;
	CC3VertexColors* vertexColors;
	CC3VertexTextureCoordinates* vertexTextureCoordinates;
	CCArray* overlayTextureCoordinates;
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


#pragma mark Texture overlays

/**
 * The vertex array instance managing the texture mapping data for the vertices.
 *
 * Setting this property is optional. Not all meshes use textures.
 *
 * If multi-texturing is used, and separate texture coordinate mapping is required
 * for each texture unit, additional texture coordinate arrays can be added using
 * the addTextureCoordinates: method. If this property has not been set already,
 * the first texture coordinate array that is added via addTextureCoordinates:
 * will be placed in this property. This can simplify configurations in that all
 * texture coordinate arrays can be treated the same.
 */
@property(nonatomic, retain) CC3VertexTextureCoordinates* vertexTextureCoordinates;

/**
 * Returns the number of texture coordinate arrays used by this mesh, regardless of whether
 * the texture coordinates were attached using the vertexTextureCoordinates property or the
 * addTextureCoordinates: method.
 */
@property(nonatomic, readonly) GLuint textureCoordinatesArrayCount;

/**
 * This class supports multi-texturing. In most situations, the mesh will use the same
 * texture mapping for all texture units. In such a case, the single texture coordinates
 * array in the vertexTexureCoordinates property will be applied to all texture units.
 *
 * However, if multi-texturing is used, and separate texture coordinate mapping is required
 * for each texture unit, additional texture coordinate arrays can be added using this method.
 *
 * If the vertexTextureCoordinates property has not been set already, the first
 * texture coordinate array that is added via this method will be placed in the
 * vertexTextureCoordinates property. This can simplify configurations in that all
 * texture coordinate arrays can be treated the same.
 *
 * If there are more textures applied to a node than there are texture coordinate arrays
 * in the mesh (including the vertexTextureCoordinates and the those in the
 * overlayTextureCoordinates collection), the last texture coordinate array is reused.
 */
-(void) addTextureCoordinates: (CC3VertexTextureCoordinates*) aTexCoord;

/**
 * Removes the specified texture coordinate array from either the vertexTextureCoordinates
 * property or from the overlayTextureCoordinates collection.
 */
-(void) removeTextureCoordinates: (CC3VertexTextureCoordinates*) aTexCoord;

/**
 * Removes all texture coordinates arrays from the the vertexTextureCoordinates
 * property and from the overlayTextureCoordinates collection.
 */
-(void) removeAllTextureCoordinates;

/**
 * Returns the overlay texture coordinate array with the specified name,
 * or nil if it cannot be found. This checks both the vertexTextureCoordinates
 * property and the overlayTextureCoordinates collection.
 */
-(CC3VertexTextureCoordinates*) getTextureCoordinatesNamed: (NSString*) aName;

/**
 * Returns the texture coordinate array that will be processed by the texture unit
 * with the specified index, which should be a number between zero, and one less
 * than the value of the textureCoordinatesArrayCount property.
 *
 * The value returned will be nil if there are no texture coordinates.
 */
-(CC3VertexTextureCoordinates*) textureCoordinatesForTextureUnit: (GLuint) texUnit;

/**
 * Sets the texture coordinates array that will be processed by the texture unit with
 * the specified index, which should be a number between zero, and the value of the
 * textureCoordinatesArrayCount property.
 * 
 * If the specified index is less than the number of texture units added already, the
 * specified texture coordinates array will replace the one assigned to that texture unit.
 * Otherwise, this implementation will invoke the addTextureCoordinates: method to add
 * the texture to this material.
 *
 * If the specified texture unit index is zero, the value of the vertexTextureCoordinates
 * property will be changed to the specified texture.
 */
-(void) setTextureCoordinates: (CC3VertexTextureCoordinates*) aTexture
			   forTextureUnit: (GLuint) texUnit;


#pragma mark Updating

/**
 * Convenience method to update GL buffers for all vertex arrays used by this mesh,
 * starting at the vertex at the specified offsetIndex, and extending for
 * the specified number of vertices.
 */
-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLsizei) vertexCount;

/** Convenience method to update all data in the GL buffers for all vertex arrays used by this mesh. */
-(void) updateGLBuffers;

@end


#pragma mark -
#pragma mark CC3VertexLocationsBoundingVolume interface

/**
 * CC3VertexLocationsBoundingVolume is a type of CC3NodeBoundingVolume
 * specialized for use with CC3VertexArrayMesh and CC3VertexLocations.
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
 * specialized for use with CC3VertexArrayMesh and CC3VertexLocations.
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
 * specialized for use with CC3VertexArrayMesh and CC3VertexLocations.
 *
 * The value of the boundingBox property is automatically calculated from
 * the vertex location data by the buildVolume method of this instance.
 */
@interface CC3VertexLocationsBoundingBoxVolume : CC3NodeBoundingBoxVolume
@end


#pragma mark -
#pragma mark Deprecated CC3VertexArrayMeshModel

/** Deprecated CC3VertexArrayMeshModel renamed to CC3VertexArrayMesh. @deprecated */
@interface CC3VertexArrayMeshModel : CC3VertexArrayMesh
@end
