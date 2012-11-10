/*
 * CC3VertexArrayMesh.h
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
	GLfloat capacityExpansionFactor;
	BOOL shouldInterleaveVertices : 1;
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
 * with the specified index.
 *
 * If the specified texture unit index is equal to or larger than the number of
 * texture coordinates arrays, as indicated by the value of the
 * textureCoordinatesArrayCount property, the texture coordinate array with the
 * highest index is returned.
 *
 * This design reuses the texture coordinate array with the highest index
 * for all texture units higher than that index.
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


#pragma mark Vertex management

/**
 * Indicates whether the vertex content should be interleaved, or separated by type.
 *
 * If the vertex data is interleaved, each of the contained CC3VertexArray instances will
 * reference the same underlying memory buffer through their individual vertices property.
 *
 * Interleaving vertex content is recommended, as it improves the GPU's ability to optimize
 * throughput.
 *
 * The value of this property should be set before the values of the vertexContentTypes and
 * allocatedVertexCapacity are set.
 * 
 * The initial value is YES, indicating that the vertex data will be interleaved.
 */
@property(nonatomic, assign) BOOL shouldInterleaveVertices;

/**
 * Indicates the types of content contained in each vertex of this mesh.
 *
 * Each vertex can contain several types of content, optionally including location, normal,
 * color, texture coordinates, along with other specialized content for certain specialized
 * meshes. To identify this various content, this property is a bitwise-OR of flags that
 * enumerate the types of content contained in each vertex of this mesh.
 *
 * Valid component flags of this property include:
 *   - kCC3VertexContentLocation
 *   - kCC3VertexContentNormal
 *   - kCC3VertexContentColor
 *   - kCC3VertexContentTextureCoordinates
 *
 * To indicate that this mesh should contain particular vertex content, construct a
 * bitwise-OR combination of one or more of the component types listed above, and set
 * this property to that combined value.
 *
 * Setting each bitwise-OR component in this property instructs this instance to
 * automatically construct the appropriate type of contained vertex array:
 *   - kCC3VertexContentLocation - automatically constructs a CC3VertexLocations instance in the
 *     vertexLocations property, that holds 3D vertex locations, in one CC3Vector structure per vertex.
 *     This component is optional, as the vertexLocations property will be constructed regardless.
 *   - kCC3VertexContentNormal - automatically constructs a CC3VertexNormals instance in the
 *     vertexNormals property, that holds 3D vertex normals, in one CC3Vector structure per vertex.
 *   - kCC3VertexContentColor - automatically constructs a CC3VertexColors instance in the vertexColors
 *     property, that holds RGBA colors with GLubyte components, in one ccColor4B structure per vertex.
 *   - kCC3VertexContentTextureCoordinates - automatically constructs a CC3VertexTextureCoordinates
 *     instance in the vertexTextureCoordinates property, that holds 2D texture coordinates, in one
 *     ccTex2F structure per vertex.
 * 
 * This property is a convenience property. Instead of using this property, you can create the
 * appropriate vertex arrays in those properties directly.
 * 
 * The vertex arrays constructed by this property will be configured to use interleaved data
 * if the shouldInterleaveVertices property is set to YES. You should ensure the value of the
 * shouldInterleaveVertices property to the desired value before setting the value of this property.
 * The initial value of the shouldInterleaveVertices property is YES.
 *
 * If the content is interleaved, for each vertex, the content is held in the structures identified in
 * the list above, in the order that they appear in the list. You can use this consistent organization
 * to create an enclosing structure to access all data for a single vertex, if it makes it easier to
 * access vertex data that way. If vertex content is not specified, it is simply absent, and the content
 * from the following type will be concatenated directly to the content from the previous type.
 *
 * For instance, if color content is not required, you would omit the kCC3VertexContentColor value when
 * setting this property, and the resulting structure for each vertex would be a location CC3Vector,
 * followed by a normal CC3Vector, followed immediately by a texture coordinate ccTex2F. You can then
 * define an enclosing structure to hold and manage all content for a single vertex. In this particular
 * example, this is already done for you with the CC3TexturedVertex structure.
 *
 * You can declare and use such a custom vertex structure even if you have constructed the vertex
 * arrays directly, without using this property. The structure of the content of a single vertex
 * is the same in either case.
 *
 * The vertex arrays created by this property cover the most common use cases and data formats.
 * If you require more customized vertex arrays, you can use this property to create the typical
 * vertex arrays, and then customize them, by accessing the vertex arrays individually through
 * their respective properties. After doing so, if the vertex data is interleaved, you should
 * invoke the updateVertexStride method on this instance to automatically align the elementOffset
 * and vertexStride properties of all of the contained vertex arrays. After setting this property,
 * you do not need to invoke the updateVertexStride method unless you subsequently make changes
 * to the constructed vertex arrays.
 *
 * It is safe to set this property more than once. Doing so will remove any existing vertex arrays
 * and replace them with those indicated by this property.
 * 
 * When reading this property, the appropriate bitwise-OR values are returned, corresponding
 * to the contained vertex arrays, even if those arrays were constructed directly, instead
 * of by setting this property. If this mesh contains no vertex arrays, this property will
 * return kCC3VertexContentNone.
 */
@property(nonatomic, assign) CC3VertexContent vertexContentTypes;

/**
 * If the shouldInterleaveVertices property is set to YES, updates the elementOffset and vertexStride
 * properties of each enclosed vertex array to correctly align them for interleaved data.
 *
 * After constructing the vertex arrays in this mesh, and setting the shouldInterleaveVertices property
 * is set to YES, you can invoke this method to align the vertex arrays for interleaved vertex data.
 *
 * If the shouldInterleaveVertices property is set to NO, this method has no effect.
 *
 * If you used the vertexContentTypes property to construct the vertex arrays, you do not need to
 * invoke this method. However, if you subsequently adjusted the elementType or elementSize of any
 * of the vertex arrays, or if you added additional texture coordinate overlay vertex arrays, you
 * can invoke this method to align the vertex arrays correctly again.
 *
 * The element offsets of the vertex arrays are aligned in the order documented in the notes of the
 * vertexContentTypes property, even if the vertex arrays were created directly, instead of by setting
 * the vertexContentTypes property.
 *
 * Returns the number of bytes used by the all of the content of one vertex. This value is
 * calculated and returned regardless of the value of the shouldInterleaveVertices property
 */
-(GLuint) updateVertexStride;

/**
 * Allocates, reallocates, or deallocates underlying memory for the specified number of
 * vertices, taking into consideration the amount of memory required by each vertex.
 *
 * Setting this property affects the value of the vertexCount property. After setting this
 * property, the vertexCount property will be set to the same value as this property. After
 * setting this property, if you will not be using all of the allocated vertices immediately,
 * you should set the value of the vertexCount property to the actual number of vertices in use.
 *
 * Use of this property is not required if the vertex data has already been loaded into
 * memory by a file loader, or defined by a static array. In that situation, you should
 * set the vertexCount property directly, and avoid using this property.
 *
 * If the vertex content consists only of vertex locations, you can set this property without
 * having to define any content, and the CC3VertexLocations instance in the vertexLocations
 * property will automatically be created.
 *
 * However, if the vertex content contains more than just location data, since memory allocation
 * is dependent on the content required by each vertex, you should set this property only after
 * the contained vertex arrays have been constructed and configured, either directly, or via the
 * the vertexContentTypes property, the shouldInterleaveVertices property has been set, and the
 * udpateVertexStride method has been invoked, if needed.
 *
 * If adding vertex arrays directly, in general, the order of operations is:
 *   -# set the shouldInterleaveVertices property appropriately
 *   -# add vertex arrays directly
 *   -# invoke the updateVertexStride method (if shouldInterleaveVertices set to YES)
 *   -# set the allocatedVertexCapacity property to allocate memory
 *   -# populate the vertex content with your data
 *
 * If using the vertexContentTypes property to automatically construct the vertex arrays,
 * the order of operations is:
 *   -# set the shouldInterleaveVertices property appropriately
 *   -# set the vertexContentTypes property
 *   -# set the allocatedVertexCapacity property to allocate memory
 *   -# populate the vertex content with your data
 *
 * This property may be set repeatedly to manage the underlying mesh vertex data as a
 * dynamically-sized array, growing and shrinking the allocated memory as needed.
 *
 * In addition, you can set this property to zero to safely deallocate all memory used
 * by the vertex content of this mesh. After setting this property to zero, the value of
 * the vertexCount property will be zero.
 *
 * When setting the value of this property to a new non-zero value, all current vertex
 * content, up to the lesser of the new and old values of this property, will be preserved.
 *
 * If the value of this property is increased (including from zero on the first assignement),
 * vertex content for those vertices beyond the old value of this property will be undefined,
 * and must be populated by the application before attempting to draw that vertex data.
 *
 * If you are not ready to populate the newly allocated vertex content yet, after setting the value
 * of this property, you can set the value of the vertexCount property to a value less than the
 * value of this property (including to zero) to stop such undefined vertex content from being drawn.
 */
@property(nonatomic, assign) GLuint allocatedVertexCapacity;

/**
 * Checks to see if the previously-allocated, underlying vertex capacity is large enough to hold
 * the specified number of vertices, and if not, expands the memory allocations accordingly.
 *
 * If exansion is required, vertex capacity is expanded to hold the specified number of vertices,
 * multiplied by the capacityExpansionFactor property, to provide a buffer for future requirements.
 *
 * Returns whether the underlying vertex memory had to be expanded. The application
 * can use this response value to determine whether or not to reset GL buffers, etc.
 */
-(BOOL) ensureVertexCapacity: (GLuint) vtxCount;

/**
 * A factor that is used to provide additional vertex capacity when increasing the
 * allocated vertex capacity via the ensureVertexCapacity: method.
 *
 * The initial value of this property is 1.25, providing a buffer of 25% whenever
 * vertex capacity is expanded.
 */
@property(nonatomic, assign) GLfloat capacityExpansionFactor;

/**
 * The number of bytes used by the content of each vertex.
 *
 * The value of this property is calculated each time it is read, by accumulating the
 * values of the elementLength property of each enclosed vertex array. If this instance
 * contains no vertex arrays, this property will return zero.
 *
 * If the shouldInterleaveVertices property is set to YES, setting this property will set
 * the same value in all enclosed vertex arrays. If the shouldInterleaveVertices property
 * is set to NO, setting this property has no effect.
 *
 * The initial value of this property is the same as the value of the elementLength property.
 */
@property(nonatomic, assign) GLuint vertexStride;

/**
 * If the shouldInterleaveVertices is set to YES, returns a pointer to the interleaved vertex
 * content of this mesh. If the shouldInterleaveVertices is set to NO, returns a NULL pointer.
 *
 * You must set the allocatedVertexCapacity property, or directly attach vertex storage
 * to the vertex arrays, prior to accessing this property.
 *
 * When populating the interleaved vertex content for this mesh, you can use this pointer
 * as a starting point to iterate through the vertex content. You can cast the returned
 * pointer to a custom structure that you declare that matches the content structure of a
 * single interleaved vertex. The form of that structure depends on the content components
 * defined for the vertices, is described in the documentation for the vertexContentTypes
 * property. An enumeration of the vertex content components is available through the
 * vertexContentTypes property.
 */
@property(nonatomic, readonly) GLvoid* interleavedVertices;

/**
 * Allocates, reallocates, or deallocates underlying memory for the specified number of
 * vertex indices, taking into consideration the amount of memory required by each index.
 *
 * Setting this property affects the value of the vertexIndexCount property. After setting this
 * property, the vertexIndexCount property will be set to the same value as this property. After
 * setting this property, if you will not be using all of the allocated vertex indices immediately,
 * you should set the value of the vertexIndexCount property to the actual number of vertices in use.
 *
 * Use of this property is not required if the vertex data has already been loaded into
 * memory by a file loader, or defined by a static array. In that situation, you should
 * set the vertexIndexCount property directly, and avoid using this property.
 *
 * This property may be set repeatedly to manage the underlying mesh vertex index data as
 * a dynamically-sized array, growing and shrinking the allocated memory as needed.
 *
 * In addition, you can set this property to zero to safely deallocate all memory used
 * by the vertex indices of this mesh. After setting this property to zero, the value of
 * the vertexIndexCount property will be zero.
 *
 * When setting the value of this property to a new non-zero value, all current vertex
 * indices, up to the lesser of the new and old values of this property, will be preserved.
 *
 * If the value of this property is increased (including from zero on the first assignement),
 * those vertex indices beyond the old value of this property will be undefined, and must be
 * populated by the application before attempting to draw that vertex data.
 *
 * If you are not ready to populate the newly allocated vertex indices yet, after setting the value
 * of this property, you can set the value of the vertexIndexCount property to a value less than the
 * value of this property (including to zero) to stop such undefined vertices from being drawn.
 */
@property(nonatomic, assign) GLuint allocatedVertexIndexCapacity;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the
 * specified source vertex index to memory starting at the specified destination vertex index.
 *
 * You can use this method to copy data from one area in the mesh to another.
 */
-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the
 * specified source vertex index, in the specified source mesh, to memory starting at the
 * specified destination vertex index in this mesh.
 *
 * You can use this method to copy data from another mesh to this mesh.
 */
-(void) copyVertices: (GLuint) vtxCount
				from: (GLuint) srcIdx
			  inMesh: (CC3VertexArrayMesh*) srcMesh
				  to: (GLuint) dstIdx;

/**
 * Copies the vertex content at the specified vertex index in the specified mesh to
 * this mesh at the specified vertex index.
 *
 * It is permissible for the two meshes to have different vertex content types. Only the vertex
 * content applicable to this mesh will be copied over. If this mesh has vertex content that is
 * not available in the source mesh, default content is applied to the vertex in this mesh.
 */
-(void) copyVertexAt: (GLuint) srcIdx from: (CC3VertexArrayMesh*) srcMesh to: (GLuint) dstIdx;

/**
 * Copies vertex indices for the specified number of vertices from memory starting at the specified
 * source vertex index to memory starting at the specified destination vertex index, and offsets
 * each value by the specified offset amount. The value at the destination vertex will be that of
 * the source vertex, plus the specified offset.
 *
 * You can use this method to copy content from one area in the vertex indices array to another area,
 * while adjusting for movement of the underlying vertex content pointed to by these vertex indices.
 *
 * If this mesh has no vertex indices, this method does nothing.
 */
-(void) copyVertexIndices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx offsettingBy: (GLint) offset;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the specified
 * source vertex index, in the specified source mesh, to memory starting at the specified destination
 * vertex index in this mesh.
 *
 * You can use this method to copy vertex indices from another mesh to this mesh, while adjusting
 * for differences in where the vertex content lies in each mesh. This method compensates correctly
 * if the vertex indices in the source mesh are of a different type (GL_UNSIGNED_BYTE or
 * GL_UNSIGNED_SHORT) than the vertex indices of this mesh.
 *
 * If this mesh has no vertex indices, this method does nothing. If the source mesh has no vertex
 * indices, the specified offset is taken as the starting index of the vertex content in this mesh,
 * and vertex indices are manufactured automatically to simply point directly to the corresponding
 * vertex content, in a 1:1 relationship.
 */
-(void) copyVertexIndices: (GLuint) vtxCount
					 from: (GLuint) srcIdx
				   inMesh: (CC3VertexArrayMesh*) srcMesh
					   to: (GLuint) dstIdx
			 offsettingBy: (GLint) offset;


#pragma mark Updating

/**
 * Convenience method to update GL buffers for all vertex arrays used by this mesh, except
 * vertexIndices, starting at the vertex at the specified offsetIndex, and extending for
 * the specified number of vertices.
 */
-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLuint) vertexCount;

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
#pragma mark CC3NodeSphereThenBoxBoundingVolume extension

/** Extension to add support for vertex location based bounding volumes. */
@interface CC3NodeSphereThenBoxBoundingVolume (VertexLocationsBoundingVolume)

/**
 * Allocates and initializes an autoreleased instance that contains a spherical bounding volume
 * and a bounding box volume, each of which determines its boundaries from the vertexLocations
 * of a mesh of type CC3VertexArrayMesh.
 */
+(id) vertexLocationsSphereandBoxBoundingVolume;

@end



