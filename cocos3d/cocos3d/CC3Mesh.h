/*
 * CC3Mesh.h
 *
 * cocos3d 0.6.4
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

#import "CC3Node.h"
#import "CC3Material.h"

/**
 * A CC3Mesh holds the 3D mesh for a CC3MeshNode. The CC3MeshNode enapsulates a reference
 * to the CC3Mesh.
 *
 * In 3D models, the mesh generally remains fixed, and transformations such as translation,
 * rotation, and scaling are applied at the node level. A single CC3Mesh instance, which
 * typically contains a large set of data points, can be used by many nodes simultaneously,
 * and each node instance can be transformed, colored, and textured independently.
 *
 * With this in mind, and following best practices to consevere memory and processing time,
 * you should strive to create only one CC3Mesh instance for each distinct mesh in your
 * application, and assign that single CC3Mesh instance to any number of separate
 * CC3MeshNode instances that make use of it.
 *
 * When drawing the mesh to the GL engine, this class remembers which mesh was last drawn
 * and only binds the mesh data to the GL engine when a different mesh is drawn. This allows
 * the application to organize the CC3MeshNodes within the CC3World so that nodes using the
 * same mesh are drawn together, before moving on to other mesh models. This strategy
 * can minimize the number of mesh switches in the GL engine, which improves performance. 
 *
 * CC3Mesh is an abstract class. Subclasses can be created for loading and managing
 * meshes from different sources and third-party libraries.
 */
@interface CC3Mesh : CC3Identifiable

/**
 * Indicates whether this mesh contains data for vertex normals.
 * 
 * This abstract implementation always returns NO.
 * Subclasses will override to return an appropriate value.
 */
@property(nonatomic, readonly) BOOL hasNormals;

/**
 * Indicates whether this mesh contains data for vertex colors.
 * 
 * This abstract implementation always returns NO.
 * Subclasses will override to return an appropriate value.
 */
@property(nonatomic, readonly) BOOL hasColors;

/**
 * The axially-aligned-bounding-box (AABB) in the mesh local (untransformed) coordinate system.
 * 
 * This abstract implementation always returns the null bounding box.
 * Subclasses will override to return an appropriate value.
 */
@property(nonatomic, readonly) CC3BoundingBox boundingBox;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) mesh;

/** Allocates and initializes an unnamed autoreleased instance with the specified tag. */
+(id) meshWithTag: (GLuint) aTag;

/**
 * Allocates and initializes an autoreleased instance with the specified name and an
 * automatically generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) meshWithName: (NSString*) aName;

/** Allocates and initializes an autoreleased instance with the specified tag and name. */
+(id) meshWithTag: (GLuint) aTag withName: (NSString*) aName;

/**
 * Convenience method to create GL buffers for all vertex arrays used by this mesh.
 *
 * This method may safely be called more than once, or on more than one mesh that shares
 * vertex arrays, since vertex array GL buffers are only created if they don't already exist.
 */
-(void) createGLBuffers;

/**
 * Convenience method to delete any GL buffers for all vertex arrays used by this mesh.
 * The arrays may continue to be used, and the arrays will be passed from the client during
 * each draw instead of bound to the GL server as a vertex buffer.
 *
 * This is a convenience method. Because vertex arrays may be shared between arrays, this
 * method should likely be used when it is known that this mesh is the only user of the array,
 * or to clear GL memory for any rarely used meshes. A more general design is to simply release
 * the vertex array. The GL buffer will be deleted when the vertex array is deallocated.
 *
 * This method may safely be called more than once, or on more than one mesh that shares
 * vertex arrays, since vertex array GL buffers are only deleted if they exist.
 */
-(void) deleteGLBuffers;

/**
 * Once the elements data has been buffered into a GL vertex buffer object (VBO)
 * within the GL engine, via the createGLBuffer method, this method can be used
 * to release the data in main memory that is now redundant.
 *
 * Typically, this method is not invoked directly by the application. Instead, 
 * consider using the same method on a node assembly in order to release as much
 * memory as possible in one simply method invocation.
 */
-(void) releaseRedundantData;

/**
 * Convenience method to cause the vertex location data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex locations will be retained. Any other vertex data, such as normals,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexLocations;

/**
 * Convenience method to cause the vertex normal data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex normals will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexNormals;

/**
 * Convenience method to cause the vertex color data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex colors will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexColors;

/**
 * Convenience method to cause the vertex texture coordinate data for all texture units
 * used by this mesh to be retained in application memory when releaseRedundantData is
 * invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex texture coordinates will be retained. Any other vertex data, such as
 * locations, or normals, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexTextureCoordinates;

/**
 * Convenience method to cause the vertex index data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex indices will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexIndices;

/**
 * Convenience method to cause the vertex location data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a a GL VBO,
 * is retained in application memory, and is submitted to the GL engine on
 * each frame render.
 *
 * Only the vertex locations will not be buffered to a GL VBO. Any other vertex
 * data, such as normals, or texture coordinates, will be buffered to a GL VBO
 * when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexLocations method.
 */
-(void) doNotBufferVertexLocations;

/**
 * Convenience method to cause the vertex normal data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a a GL VBO,
 * is retained in application memory, and is submitted to the GL engine on
 * each frame render.
 *
 * Only the vertex normals will not be buffered to a GL VBO. Any other vertex
 * data, such as locations, or texture coordinates, will be buffered to a GL
 * VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexNormals method.
 */
-(void) doNotBufferVertexNormals;

/**
 * Convenience method to cause the vertex color data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a a GL VBO,
 * is retained in application memory, and is submitted to the GL engine on
 * each frame render.
 *
 * Only the vertex colors will not be buffered to a GL VBO. Any other vertex
 * data, such as locations, or texture coordinates, will be buffered to a GL
 * VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexColors method.
 */
-(void) doNotBufferVertexColors;

/**
 * Convenience method to cause the vertex texture coordinate data for all
 * texture units used by this mesh to be skipped when createGLBuffers is
 * invoked. The vertex data is not buffered to a a GL VBO, is retained in
 * application memory, and is submitted to the GL engine on each frame render.
 *
 * Only the vertex texture coordinates will not be buffered to a GL VBO.
 * Any other vertex data, such as locations, or texture coordinates, will
 * be buffered to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexTextureCoordinates method.
 */
-(void) doNotBufferVertexTextureCoordinates;

/**
 * Convenience method to cause the vertex index data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a a GL VBO,
 * is retained in application memory, and is submitted to the GL engine on
 * each frame render.
 *
 * Only the vertex indices will not be buffered to a GL VBO. Any other vertex
 * data, such as locations, or texture coordinates, will be buffered to a GL
 * VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexColors method.
 */
-(void) doNotBufferVertexIndices;

/**
 * Aligns the texture coordinates of the mesh with the textures held in the specified material.
 *
 * This method can be useful when the mesh is covered by textures whose width and height
 * are not a power-of-two. Under iOS, when loading a texture that is not a power-of-two,
 * the texture will be converted to a size whose width and height are a power-of-two.
 * The result is a texture that can have empty space on the top and right sides. If the
 * texture coordinates of the mesh do not take this into consideration, the result will
 * be that only the lower left of the mesh will be covered by the texture.
 *
 * When this occurs, invoking this method will adjust the texture coordinates of the mesh
 * to map to the original width and height of the texture.
 *
 * If the mesh is using multi-texturing, this method will adjust the texture coordinates
 * array for each texture unit, using the corresponding texture for that texture unit
 * in the specified material.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This method should only be invoked once on any mesh, and it may cause mapping conflicts
 * if the same mesh is shared by other CC3MeshNodes that use different textures.
 *
 * To adjust the texture coordinates of only a single texture coordinates array within
 * this mesh, invoke the alignWithTexture: method on the appropriate instance of
 * CC3VertexTextureCoordinates.
 */
-(void) alignWithTexturesIn: (CC3Material*) aMaterial;

/**
 * Aligns the texture coordinates of the mesh with the textures held in the specified material.
 *
 * The texture coordinates are aligned assuming that the texture is inverted in the
 * Y-direction. Certain texture formats are inverted during loading, and this method
 * can be used to compensate.
 *
 * This method can be useful when the mesh is covered by textures whose width and height
 * are not a power-of-two. Under iOS, when loading a texture that is not a power-of-two,
 * the texture will be converted to a size whose width and height are a power-of-two.
 * The result is a texture that can have empty space on the top and right sides. If the
 * texture coordinates of the mesh do not take this into consideration, the result will
 * be that only the lower left of the mesh will be covered by the texture.
 *
 * When this occurs, invoking this method will adjust the texture coordinates of the mesh
 * to map to the original width and height of the texture.
 *
 * If the mesh is using multi-texturing, this method will adjust the texture coordinates
 * array for each texture unit, using the corresponding texture for that texture unit
 * in the specified material.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This method should only be invoked once on any mesh, and it may cause mapping conflicts
 * if the same mesh is shared by other CC3MeshNodes that use different textures.
 *
 * To adjust the texture coordinates of only a single texture coordinates array within
 * this mesh, invoke the alignWithInvertedTexture: method on the appropriate instance
 * of CC3VertexTextureCoordinates.
 */
-(void) alignWithInvertedTexturesIn: (CC3Material*) aMaterial;

/**
 * Configures the mesh so that a texture applied to this mesh will be repeated the
 * specified number of times across the mesh, in each dimension. The repeatFactor
 * argument contains two numbers, corresponding to how many times in each dimension
 * the texture should be repeated.
 * 
 * As an example, a value of (1, 2) for the repeatValue indicates that the texture
 * should repeat twice vertically, but not repeat horizontally.
 * 
 * When a texture is repeated, the corresponding side of the texture covering this
 * mesh must have a length that is a power-of-two, otherwise the padding added by
 * iOS to convert it to a power-of-two length internally will be visible in the
 * repeating pattern across the mesh.
 *
 * For a side that is not repeating, the corresponding side of the texture covering
 * this mesh does not require a length that is a power-of-two.
 *
 * The textureParameters property of any texture covering this mesh should include
 * the GL_REPEAT setting in each of its texture wrap components that correspond to
 * a repeatFactor greater than one. The GL_REPEAT setting is the default setting
 * for CC3Texture.
 *
 * For example, if you want to repeat your texture twice in one dimension, but only
 * once in the other, then you would use a repeatFactor of (1, 2) or (2, 1). For the
 * side that is repeating twice, the length of that side of the texture must be a
 * power-of-two. But the other side may have any dimension. The textureParameters
 * property of the CC3Texture should include the GL_REPEAT setting for the
 * corresponding texture dimension.
 *
 * If your texture requires aligning with the mesh (typically if one of the texture
 * dimensions is not a power-of-two), you should invoke either the alignWithTexturesIn:
 * or alignWithInvertedTexturesIn: method before invoking this method.
 *
 * In the example above, you would invoke one of those methods before invoking this
 * method, to first align the mesh with that non-power-of-two side.
 *
 * The dimensions of the repeatFactor are independent of the size derived from the
 * texture by the alignWithTexturesIn: or alignWithInvertedTexturesIn: methods.
 * A value of 1.0 for an element in the specified repeatFactor will automatically take
 * into consideration the adjustment made to the mesh by those methods, and will display
 * only the part of the texture defined by them.
 *
 * You can specify a fractional value for either of the components of the repeatFactor
 * to expand the texture in that dimension so that only part of the texture appears
 * in that dimension, while potentially repeating multiple times in the other dimension.
 */
-(void) repeatTexture: (ccTex2F) repeatFactor;

/**
 * Defines the rectangular area of the textures, for all texture units, that should
 * be mapped to this mesh.
 *
 * This property facilitates the use of sprite-sheets, where the mesh is covered
 * by a small fraction of a larger texture. This technique has many uses, including
 * animating a texture onto a mesh, where each section of the full texture is really
 * a different frame of a texture animation, or simply loading one larger texture
 * and using parts of it to texture many different meshes.
 *
 * The dimensions of this rectangle are taken as fractional portions of the full
 * area of the texture. Therefore, a rectangle with zero origin, and unit size
 * ((0.0, 0.0), (1.0, 1.0)) indicates that the mesh should be covered with the
 * complete texture.
 * 
 * A rectangle of smaller size, and/or a non-zero origin, indicates that the mesh
 * should be covered by a fractional area of the texture. For example, a rectangular
 * value for this property with origin at (0.5, 0.5), and size of (0.5, 0.5) indicates
 * that only the top-right quarter of the texture will be used to cover this mesh.
 *
 * The bounds of the texture rectangle must fit within a unit rectangle. Both the
 * bottom-left and top-right corners must lie between zero and one in both the
 * X and Y directions.
 *
 * The dimensions of the rectangle in this property are independent of adjustments
 * made by the  alignWithTexturesIn: and alignWithInvertedTexturesIn: methods.
 * A unit rectangle value for this property will automatically take into
 * consideration the adjustment made to the mesh by those methods, and will display
 * only the part of the texture defined by them. Rectangular values for this property
 * that are smaller than the unit rectangle will be relative to the displayable area
 * defined by alignWithTexturesIn: and alignWithInvertedTexturesIn:.
 *
 * As an example, if the alignWithTexturesIn: method was used to limit the mesh
 * to using only 80% of the texture (perhaps when using a non-POT texture), and this
 * property was set to a rectangle with origin at (0.5, 0.0) and size (0.5, 0.5),
 * the mesh will be covered by the bottom-right quarter of the usable 80% of the
 * overall texture.
 *
 * This property affects all texture units used by this mesh, to query or change
 * this property for a single texture unit only, use the textureRectangleForTextureUnit:
 * and setTextureRectangle:forTextureUnit: methods.
 *
 * The initial value of this property is a rectangle with origin at zero, and unit
 * size, indicating that the mesh will be covered with the complete usable area of
 * the texture.
 */
@property(nonatomic, assign) CGRect textureRectangle;

/**
 * Returns the textureRectangle property from the texture coordinates that are
 * mapping the specified texture unit index.
 *
 * See the notes for the textureRectangle property of this class for an explanation
 * of the use of this property.
 */
-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit;

/**
 * Sets the textureRectangle property from the texture coordinates that are
 * mapping the specified texture unit index.
 *
 * See the notes for the textureRectangle property of this class for an explanation
 * of the use of this property.
 */
-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit;


#pragma mark Drawing

/**
 * Draws the mesh data to the GL engine. The specified visitor encapsulates
 * the currently active camera, and certain drawing options.
 *
 * If this mesh is different than the last mesh drawn, this method binds this
 * mesh data to the GL engine. Otherwise, if this mesh is the same as the mesh
 * already bound, it is not bound again, Once binding is complete, this method
 * then performs the GL draw operations.
 * 
 * This is invoked automatically from the draw method of the CC3MeshNode instance that is
 * using this mesh. Usually, the application never needs to invoke this method directly.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Draws a portion of the mesh data to the GL engine, starting at the vertex at the
 * specified index, and drawing the specified number of vertices. The specified visitor
 * encapsulates the currently active camera, and certain drawing options.
 *
 * If this mesh is different than the last mesh drawn, this method binds this
 * mesh data to the GL engine. Otherwise, if this mesh is the same as the mesh
 * already bound, it is not bound again, Once binding is complete, this method
 * then performs the GL draw operations.
 * 
 * This is invoked automatically from the draw method of the CC3MeshNode instance that is
 * using this mesh. Usually, the application never needs to invoke this method directly.
 */
-(void) drawFrom: (GLuint) vertexIndex
		forCount: (GLuint) vertexCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Returns an allocated, initialized, autorelease instance of the bounding volume to
 * be used by the CC3MeshNode that wraps this mesh. This method is called automatically
 * by the CC3MeshNode instance when this mesh is attached to the CC3MeshNode.
 *
 * This abstract implementation always returns nil. Subclasses will override to provide
 * an appropriate and useful bounding volume instance.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume;

/**
 * Returns the number of faces to be drawn from the specified number of
 * vertices, based on the type of primitives that this mesh is drawing.
 */ 
-(GLsizei) faceCountFromVertexCount: (GLsizei) vc;

/**
 * Returns the number of vertices required to draw the specified number
 * of faces, based on the type of primitives that this mesh is drawing.
 */ 
-(GLsizei) vertexCountFromFaceCount: (GLsizei) fc;


#pragma mark Accessing vertex data

/**
 * Changes the mesh data so that the pivot point of the mesh will be at the specified
 * location. The pivot point of the mesh is the location in the local coordinate system
 * around which all transforms are performed. A vertex at the pivot point would have
 * local coordinates (0,0,0).
 *
 * This method can be used to adjust the mesh structure to make it easier to apply
 * transformations, by moving the origin of the transformations to a more convenient
 * location in the mesh.
 *
 * This method changes the location component of every vertex in the mesh data.
 * This can be quite costly, and should only be performed once to adjust a mesh
 * so that it is easier to manipulate.
 * 
 * Do not use this method to move your model around. Instead, use the transform
 * properties (location, rotation and scale) of the CC3Node that contains this mesh,
 * and let the GL engine do the heavy lifting of transforming the mesh vertices.
 * 
 * If this mesh is being used by any mesh nodes, be sure to invoke the
 * rebuildBoundingVolume method on all nodes that use this mesh, to ensure
 * that the boundingVolume is recalculated using the new location values.
 *
 * This method ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) movePivotTo: (CC3Vector) aLocation;

/**
 * Changes the mesh data so that the pivot point of the mesh will be at the center of
 * geometry of the mesh vertices. The pivot point of the mesh is the location in the
 * local coordinate system around which all transforms are performed. A vertex at the
 * pivot point would have local coordinates (0,0,0).
 *
 * This method can be used to adjust the mesh structure to make it easier to apply
 * transformations, by moving the origin of the transformations to the center of the mesh.
 *
 * This method changes the location component of every vertex in the mesh data.
 * This can be quite costly, and should only be performed once to adjust a mesh
 * so that it is easier to manipulate.
 * 
 * Do not use this method to move your model around. Instead, use the transform
 * properties (location, rotation and scale) of the CC3Node that contains this mesh,
 * and let the GL engine do the heavy lifting of transforming the mesh vertices.
 * 
 * If this mesh is being used by any mesh nodes, be sure to invoke the
 * rebuildBoundingVolume method on all nodes that use this mesh, to ensure
 * that the boundingVolume is recalculated using the new location values.
 *
 * This method ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) movePivotToCenterOfGeometry;

/** Returns the number of vertices in this mesh. */
@property(nonatomic, readonly) GLsizei vertexCount;

/**
 * Returns the location element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexLocationAt: (GLsizei) index;

/**
 * Sets the location element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 * 
 * If this mesh is being used by any mesh nodes, be sure to invoke the
 * rebuildBoundingVolume method on all nodes that use this mesh, to ensure
 * that the boundingVolume is recalculated using the new location values.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexLocationsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexLocation: (CC3Vector) aLocation at: (GLsizei) index;

/**
 * Returns the normal element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexNormalAt: (GLsizei) index;

/**
 * Sets the normal element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexNormalsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexNormal: (CC3Vector) aNormal at: (GLsizei) index;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4F) vertexColor4FAt: (GLsizei) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexColorsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4F: (ccColor4F) aColor at: (GLsizei) index;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4B) vertexColor4BAt: (GLsizei) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexColorsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4B: (ccColor4B) aColor at: (GLsizei) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the specified texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLsizei) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the specified texture unit index, to the specified texture coordinate value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBufferForTextureUnit: method
 * to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLsizei) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the commonly used texture unit zero.
 *
 * This is a convenience method that is equivalent to invoking the
 * vertexTexCoord2FForTextureUnit:at: method, with zero as the texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the commonly used texture unit zero, to the specified texture coordinate value.
 *
 * This is a convenience method that delegates to the setVertexTexCoord2F:forTextureUnit:at:
 * method, passing in zero for the texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBuffer method to ensure that
 * the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index;

/** @deprecated Use the vertexTexCoord2FForTextureUnit:at: method instead, */
-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/** @deprecated Use the setVertexTexCoord2F:forTextureUnit:at: method instead, */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/**
 * Returns the index element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLushort) vertexIndexAt: (GLsizei) index;

/**
 * Sets the index element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexIndicesGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexIndex: (GLushort) vertexIndex at: (GLsizei) index;

/** Updates the GL engine buffer with the vertex location data in this mesh. */
-(void) updateVertexLocationsGLBuffer;

/** Updates the GL engine buffer with the vertex normal data in this mesh. */
-(void) updateVertexNormalsGLBuffer;

/** Updates the GL engine buffer with the vertex color data in this mesh. */
-(void) updateVertexColorsGLBuffer;

/**
 * Updates the GL engine buffer with the vertex texture coord data from the
 * specified texture unit in this mesh.
 */
-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit;

/**
 * Updates the GL engine buffer with the vertex texture coord data from
 * texture unit zero in this mesh.
 */
-(void) updateVertexTextureCoordinatesGLBuffer;

/** Updates the GL engine buffer with the vertex index data in this mesh. */
-(void) updateVertexIndicesGLBuffer;


#pragma mark Mesh context switching

/**
 * Resets the tracking of the mesh switching functionality.
 *
 * This is invoked automatically by the CC3World at the beginning of each frame drawing cycle.
 * Usually, the application never needs to invoke this method directly.
 */
+(void) resetSwitching;

@end


#pragma mark -
#pragma mark Deprecated CC3MeshModel

/** Deprecated CC3MeshModel renamed to CC3Mesh. @deprecated */
@interface CC3MeshModel : CC3Mesh
@end
