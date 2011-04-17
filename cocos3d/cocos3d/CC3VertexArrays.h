/*
 * CC3VertexArrays.h
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

#import "CC3Identifiable.h"
#import "CC3Material.h"
#import "CC3NodeVisitor.h"


#pragma mark CC3VertexArray

/**
 * CC3VertexArray manages the data associated with an aspect of a vertex. CC3VertexArray
 * is an abstract implementation, and there are several sublcasses, each specialized to
 * manage the vertex data for a different vertex aspect (locations, normals, colors,
 * texture mapping, indices...).
 *
 * Each instance of a subclass of CC3VertexArray maintains a reference to the underlying
 * vertex data in memory, along with various parameters describing the underlying data,
 * such as its type, element size, stride, etc.
 *
 * The underlying data can be interleaved and shared by several CC3VertexArray subclasses,
 * each looking at a different aspect of the data for each vertex. In this case, the
 * elements property of each of those vertex array instances will reference the same
 * underlying data memory, and the elementOffset property of each CC3VertexArray instance
 * will indicate at which offset in each vertex data the datum of interest to that instance
 * is located.
 *
 * The CC3VertexArray instance also manages buffering the data to the GL engine, including
 * loading it into a server-side GL vertex buffer object (VBO) if desired. Once loaded into
 * the GL engine buffers, the underlying data can be released from the CC3VertexArray instance,
 * thereby freeing memory, by using the releaseRedundantData method.
 *
 * The CC3DrawableVertexArray abstract subclass adds the functionality to draw the vertex
 * data to the display through the GL engine.
 *
 * When drawing the vertices to the GL engine, each subclass remembers which vertices were
 * last drawn, and only binds the vertices to the GL engine when a different set of vertices
 * of the same type are drawn. This allows the application to organize the CC3MeshNodes
 * within the CC3World so that nodes using the same mesh vertices are drawn together, before
 * moving on to other meshes. This strategy can minimize the number of vertex pointer
 * switches in the GL engine, which improves performance. 
 */
@interface CC3VertexArray : CC3Identifiable {
	GLvoid* elements;
	GLuint elementOffset;
	GLsizei elementCount;
	GLint elementSize;
	GLenum elementType;
	GLsizei elementStride;
	GLuint bufferID;
	GLenum bufferUsage;
	BOOL elementsAreRetained;
	BOOL shouldReleaseRedundantData;
}

/**
 * A pointer to the underlying vertex data. If the underlying data memory is assigned
 * to this instance using this property directly, the underlying data memory is neither
 * retained nor deallocated by this instance. It is up to the application to manage the
 * allocation and deallocation of the underlying data memory.
 *
 * Alternately, the method allocateElements: can be used to have this instance allocate
 * and manage the underlying data. When this is done, the underlying data memory will be
 * retained and deallocated by this instance.
 *
 * The underlying data can be interleaved and shared by several CC3VertexArray subclasses,
 * each looking at a different aspect of the data for each vertex. In this case, the
 * elements property of each of those vertex array instances will reference the same
 * underlying data memory, and the elementOffset property will indicate at which offset
 * in each vertex data the datum of interest to that instance is located.
 */
@property(nonatomic, assign) GLvoid* elements;

/**
 * The number of elements in the underlying data referenced by the elements property.
 * The elements property must point to an underlying memory space that is large enough
 * to hold the amount of data specified by this elementCount property.
 *
 * The initial value is zero.
 */
@property(nonatomic, assign) GLsizei elementCount;

/**
 * When using interleaved data, this property indicates the offset, within the data
 * for a single vertex, at which the datum managed by this instance is located.
 * When data is not interleaved, and the elements data is dedicated to this instance,
 * this property will be zero.
 *
 * The initial value is zero.
 */
@property(nonatomic, assign) GLuint elementOffset;

/**
 * The number of components associated with each vertex in the underlying data.
 *
 * As an example, the location of each vertex in 3D space is specified by three
 * components (X,Y & Z), so the value of this property in an instance tracking
 * vertex locations would be three.
 *
 * The initial value is three. Subclass may override this default.
 */
@property(nonatomic, assign) GLint elementSize;

/**
 * The type of data associated with each component of a vertex.
 * This must be a valid enumerated GL data type suitable for the type of element.
 *
 * The initial value is GL_FLOAT.
 */
@property(nonatomic, assign) GLenum elementType;

/**
 * The number of bytes between consecutive vertices for the vertex aspect being managed
 * by this instance.
 *
 * If the underlying data is not interleaved, and contains only the data managed by this
 * instance, the value of this property will be the size of a single element of the type
 * of data indicated by the elementType property multiplied by the value of the elementSize
 * property. For example, with the default elementType of GL_FLOAT and elementSize of three,
 * the value of the elementStride property will be (4 * 3) = 12.
 
 * If the underlying data is interleaved and contains data for several vertex aspects
 * (location, normals, colors...) interleaved in one memory space, this value should be set
 * by the application to indicate the distance, in bytes, from one element of this aspect
 * to the next.
 *
 * The initial value of this property is the size of a single element of the type of data
 * indicated by the elementType property multiplied by the value of the elementSize property.
 */
@property(nonatomic, assign) GLsizei elementStride;

/**
 * If the underlying data has been loaded into a GL engine vertex buffer object, this
 * property holds the ID of that GL buffer as provided by the GL engine when the
 * createGLBuffer method was invoked. If the createGLBuffer method was not invoked,
 * and the underlying vertex was not loaded into a GL VBO, this property will be zero.
 */
@property(nonatomic, assign) GLuint bufferID;

/**
 * The GL engine buffer target. Must be one of GL_ARRAY_BUFFER or GL_ELEMENT_ARRAY_BUFFER.
 *
 * The default value is GL_ARRAY_BUFFER. Subclasses that manage index data will override.
 */
@property(nonatomic, readonly) GLenum bufferTarget;

/**
 * The GL engine buffer usage hint, used by the GL engine to arrange data for access when
 * loading data into a server-side vertex buffer object.
 *
 * The default value is GL_STATIC_DRAW, indicating to the GL engine that the data will
 * generally not be re-accessed after loading.
 */
@property(nonatomic, assign) GLenum bufferUsage;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) vertexArray;

/** Allocates and initializes an unnamed autoreleased instance with the specified tag. */
+(id) vertexArrayWithTag: (GLuint) aTag;

/**
 * Allocates and initializes an autoreleased instance with the specified name and an
 * automatically generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) vertexArrayWithName: (NSString*) aName;

/** Allocates and initializes an autoreleased instance with the specified tag and name. */
+(id) vertexArrayWithTag: (GLuint) aTag withName: (NSString*) aName;


#pragma mark Binding GL artifacts

/**
 * Allocates underlying memory for the specified number of elements, taking into consideration
 * the elementStride, assigns the elements property to point to the allocated memory, and
 * returns a pointer to the allocated memory. Specifically, the amount of memory allocated
 * will be (elemCount * self.elementStride) bytes.
 *
 * If the underlying data is to be interleaved, set the value of the elementStride property
 * to the appropriate value before invoking this method. If the underlying data will not be
 * interleaved, the elementStride property is determined by the elementType and elementSize
 * properties. Therefore, set the correct values of these two properties before invoking
 * this method.
 *
 * When interleaving data, this method should be invoked on only one of the CC3VertexArray
 * instances that are sharing the underlying data. After allocating on one CC3VertexArray
 * instances, set the elements property of the other instances to be equal to the elements
 * property of the CC3VertexArray instance on which this method was invoked (or just simply
 * to the pointer returned by this method).
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(GLvoid*) allocateElements: (GLsizei) elemCount;

/**
 * Deallocates the underlying vertex data memory that was previously allocated with the
 * allocateElements: method. It is safe to invoke this method more than once, or even
 * if allocateElements: was not previously invoked.
 * 
 * When using interleaved memory, deallocateElements must be invoked on the same
 * CC3VertexArray instance on which the original allocateElements: was invoked.
 *
 * Deallocating the elements array does not change the elementCount property,
 * because that property is still used for other operations, including drawing.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateElements;

/** 
 * Creates a vertex buffer object within the GL engine, copies the data referenced by
 * the elements into the GL engine (which may make use of VRAM), and sets the value of
 * the bufferID property to that of the new GL buffer.
 * 
 * Calling this method is optional. Using GL engine buffers is more efficient than passing
 * arrays on each GL draw call, but is optional. If you choose not to call this method,
 * this instance will pass the mesh data properties to the GL engine on each draw call.
 *
 * If the GL engine cannot allocate space for any of the buffers, this instance will revert
 * to passing the array data for any unallocated buffer on each draw call.
 *
 * When using interleaved data, this method should be invoked on only one of the CC3VertexArray
 * that share the data. The bufferID property of that instance should then be copied to the
 * other instances.
 *
 * It is safe to invoke this method more than once, but subsequent invocations will do nothing.
 *
 * This method is invoked automatically by the createGLBuffers method of the mesh model class,
 * which also coordinates the invocations across multiple CC3VertexArray instances when
 * interleaved data is shared between them, along with the subsequent copying of the bufferID's.
 * Consider using the createGLBuffers of the mesh model class instead of this method.
 */
-(void) createGLBuffer;

/**
 * Deletes the GL engine buffers created with createGLBuffer.
 *
 * After calling this method, if they have not been released by createGLBuffer,
 * the vertex data will be passed to the GL engine on each subsequent draw operation.
 * It is safe to call this method even if GL buffers have not been created.
 * 
 * This method may be invoked at any time to free up GL memory, but only if this vertex
 * array will not be used again, or if the data was not released by releaseRedundantData.
 * This would be the case if allocateElements: was not invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deleteGLBuffer;

/**
 * Indicates whether this instance should release the data held in the elments array
 * when the releaseRedundantData method is invoked.
 *
 * The initial value of this property is YES. In most cases, this is appropriate,
 * but in some circumstances it might make sense to retain some data (usually the
 * vertex locations) in main memory for potantial use in collision detection, etc.
 */
@property(nonatomic, assign) BOOL shouldReleaseRedundantData;

/**
 * Once the elements data has been buffered into a GL vertex buffer object (VBO)
 * within the GL engine, via the createGLBuffer method, this method can be used
 * to release the data in main memory that is now redundant.
 *
 * If the shouldReleaseRedundantData property is set to NO, or if the elements
 * data has not been successfully buffered to a VBO in the GL engine. this method
 * does nothing. It is safe to invokde this method even if createGLBuffer has not
 * been invoked, and even if VBO buffering was unsuccessful.
 *
 * Typically, this method is not invoked directly by the application. Instead, 
 * consider using the same method on a node assembly in order to release as much
 * memory as possible in one simply method invocation.
 *
 * Subclasses may extend this behaviour to remove data loaded, for example, from files,
 * but should ensure that data is only released if bufferId is valid (not zero),
 * and the shouldReleaseRedundantData property is set to YES.
 */
-(void) releaseRedundantData;

/**
 * Binds the GL engine to the underlying vertex data, if needed, in preparation for drawing.
 *
 * This implementation first invokes the switchingArray method on this instance to determine
 * if this vertex array is different than the vertex array that was last bound to the GL
 * engine. If this vertex array is indeed different, this method invokes the bindGL method,
 * otherwise it does nothing.
 * 
 * This is invoked automatically from the draw method of the CC3VertexArrayMeshModel
 * containing this instance. Usually, the application never needs to invoke this method directly.
 */
-(void) bind;

/**
 * Unbinds the GL engine from the vertex aspect managed by this instance.
 * 
 * This implementation simply delegates to the unbind class method.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) unbind;

/**
 * Unbinds the GL engine from the vertex aspect managed by this class.
 * 
 * This abstract implementation does nothing. Subclasses will override to handle
 * their particular type of vetex aspect.
 *
 * This method is invoked automatically from the CC3VertexArrayMeshModel instance.
 * Usually, the application never needs to invoke this method directly.
 */
+(void) unbind;


#pragma mark Mesh context switching

/**
 * Resets the tracking of the vertex array switching functionality.
 *
 * This is invoked automatically by the similar method in CC3VertexArrayMeshModel at the
 * beginning of each frame drawing cycle. Usually, the application never needs to invoke
 * this method directly.
 */
+(void) resetSwitching;

@end


#pragma mark -
#pragma mark CC3DrawableVertexArray

/**
 * This abstract subclass of  CC3VertexArray adds the functionality to draw the vertex
 * data to the display through the GL engine.
 *
 * The underlying data can be drawn in a single GL call for all vertices, or the vertices
 * can be arranged in strips, and the strips drawn serially. This second method obviously
 * consumes more GL calls, and will be less efficient, but in some applications, might
 * assist in the organization of mesh vertex data.
 */
@interface CC3DrawableVertexArray : CC3VertexArray {
	GLenum drawingMode;
	GLuint stripCount;
	GLuint* stripLengths;
	BOOL stripLengthsAreRetained;
}

/**
 * The drawing mode indicating how the vertices are connected (points, lines, triangles...).
 * This must be set with a valid GL drawing mode enumeration.
 *
 * The default value is GL_TRIANGLE_STRIP.
 */
@property(nonatomic, assign) GLenum drawingMode;

/**
 * The underlying data can be drawn in strips, using multiple GL calls, rather than
 * a single call. This property indicates the number of strips to draw. A value of
 * zero indicates that vertex drawing should be done in a single GL call.
 */
@property(nonatomic, assign) GLuint stripCount;

/**
 * An array of values, each indicating the number of elements to draw in the corresponding
 * strip. The stripCount property indicates the number of items in this array. 
 * If drawing is not performed in strips (stripCount is zero), this property will be NULL.
 *
 * An easy way to create a suitable array for this property, and set the associated
 * stripCount property at the same time, is to invoke the allocateStripLengths: method.
 */
@property(nonatomic, assign) GLuint* stripLengths;

/**
 * An index reference to the first element that will be drawn.
 *
 * This abstract implementation always returns zero. Subclasses will override.
 */
@property(nonatomic, readonly) GLuint firstElement;

/**
 * Draws the elements, either in strips, or in a single call, depending on the value
 * of the stripCount property.
 *
 * This method is invoked automatically from the draw method of CC3VertexArrayMeshModel.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Sets the specified number of strips into the stripCount property, then allocates an
 * array of Gluints of that length, and sets that array in the stripLengths property.
 *
 * It is safe to invoke this method more than once. The previously allocated
 * array of strip-lengths will be deallocated before the new array is created.
 *
 * The array can be deallocated by invoking the deallocateStripLengths method.
 */
-(void) allocateStripLengths: (GLsizei) sCount;

/**
 * Deallocates the array of strip-lengths that was created by a previous invocation
 * of the allocateStripLengths: method.
 *
 * It is safe to invoke this method more than once, or even if allocateStripLengths:
 * was not previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateStripLengths;

@end


#pragma mark -
#pragma mark CC3VertexLocations

/**
 * A CC3VertexArray that manages the location aspect of an array of vertices.
 *
 * This class is also a type of CC3DrawableVertexArray, and as such, is capable of drawing
 * the vertices to the GL engine.
 *
 * Since the vertex locations determine the size and shape of the mesh, this class is
 * also responsible for determining the boundingBox of the mesh.
 */
@interface CC3VertexLocations : CC3DrawableVertexArray {
	GLuint firstElement;
	CC3BoundingBox boundingBox;
	CC3Vector centerOfGeometry;
	BOOL boundingBoxNeedsBuilding;
}

/**
 * An index reference to the first element that will be drawn.
 *
 * Typically, all elements are to be drawn, and this property will be zero.
 * In some applications, large sets of underlying data may be used for the vertex arrays
 * of more than one mesh. In such a case, it may be desirable to start drawing from
 * an element that is not the first element of the array. This property can be set to
 * indicate at which element index to start drawing. If drawing is being performed in
 * strips, this will be the index of the start of the first strip to be drawn.
 *
 * The initial value is zero.
 */
@property(nonatomic, assign) GLuint firstElement;

/** Returns the axially-aligned bounding box of this mesh. */
@property(nonatomic, readonly) CC3BoundingBox boundingBox;

/** Returns the center of geometry of this mesh. */
@property(nonatomic, readonly) CC3Vector centerOfGeometry;

/**
 * Returns the location element at the specified index in the underlying vertex data.
 *
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) locationAt: (GLsizei) index;

/**
 * Sets the location element at the specified index in the underlying vertex data to
 * the specified location value.
 * 
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setLocation: (CC3Vector) aLocation at: (GLsizei) index;

@end


#pragma mark -
#pragma mark CC3VertexNormals

/** A CC3VertexArray that manages the normal aspect of an array of vertices. */
@interface CC3VertexNormals : CC3VertexArray {}

/**
 * Returns the normal element at the specified index in the underlying vertex data.
 *
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) normalAt: (GLsizei) index;

/**
 * Sets the normal element at the specified index in the underlying vertex data to
 * the specified normal value.
 * 
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setNormal: (CC3Vector) aNormal at: (GLsizei) index;

@end


#pragma mark -
#pragma mark CC3VertexColors

/** A CC3VertexArray that manages the per-vertex color aspect of an array of vertices. */
@interface CC3VertexColors : CC3VertexArray {}

/**
 * Returns the color element at the specified index in the underlying vertex data.
 *
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4F) color4FAt: (GLsizei) index;

/**
 * Sets the color element at the specified index in the underlying vertex data to
 * the specified color value.
 * 
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setColor4F: (ccColor4F) aColor at: (GLsizei) index;

@end


#pragma mark -
#pragma mark CC3VertexTextureCoordinates

/**
 * A CC3VertexArray that manages the texture coordinates aspect of an array of vertices.
 *
 * This class includes several convenience methods that allow the texture coordinates
 * to be adjusted to match the visible area of a particular texture.
 */
@interface CC3VertexTextureCoordinates : CC3VertexArray {}

/**
 * Returns the texture coordinate element at the specified index in the underlying vertex data.
 *
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) texCoord2FAt: (GLsizei) index;

/**
 * Sets the texture coordinate element at the specified index in the underlying vertex
 * data to the specified texture coordinate value.
 * 
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index;

/**
 * Aligns the texture coordinate array with the specfied texture map size,
 * which is typically extracted from a specific texture.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithTextureMapSize: (ccTex2F) texMapSize;

/**
 * Aligns the texture coordinate array with the specfied texture map size, which is
 * typically extracted from a specific texture.
 *
 * The texture coordinates are aligned assuming that the texture is inverted in the
 * Y-direction. Certain texture formats are inverted during loading, and this method
 * can be used to compensate.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithInvertedTextureMapSize: (ccTex2F) texMapSize;

/**
 * Aligns the texture coordinate array with the specfied texture.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithTexture: (CC3Texture*) texture;

/**
 * Aligns the texture coordinate array with the specfied texture.
 *
 * The texture coordinates are aligned assuming that the texture is inverted in the
 * Y-direction. Certain texture formats are inverted during loading, and this method
 * can be used to compensate.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithInvertedTexture: (CC3Texture*) texture;

@end


#pragma mark -
#pragma mark CC3VertexPointSizes

/** A CC3VertexArray that manages the point sizes aspect of an array of point sprite vertices. */
@interface CC3VertexPointSizes : CC3VertexArray {}
@end


#pragma mark -
#pragma mark CC3VertexIndices

/**
 * A CC3VertexArray that manages the drawing indices of an array of vertices.
 *
 * This class is also a type of CC3DrawableVertexArray, and as such,
 * is capable of drawing the vertices to the GL engine.
 *
 * A vertex index array is different than other vertex arrays in that instead of managing
 * actual vertex data, it manages indexes that reference the elements of the other vertex
 * arrays. The bufferTarget property is GL_ELEMENT_ARRAY_BUFFER, the elementSize
 * property is 1, and the elementType is either GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE
 *
 * Because an index datum does not describe an aspect of a particular vertex, but rather
 * points to a vertex, index data cannot be interleaved with the vertex data. As such,
 * the data underlying a CC3VertexIndices is never interleaved and shared with the data
 * underlying the other vertex arrays in a mesh.
 */
@interface CC3VertexIndices : CC3DrawableVertexArray {}

/**
 * Returns the index element at the specified index in the underlying vertex data.
 *
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLushort) indexAt: (GLsizei) index;

/**
 * Sets the index element at the specified index in the underlying vertex data to
 * the specified location value.
 * 
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setIndex: (GLushort) anIndex at: (GLsizei) index;

@end


#pragma mark -
#pragma mark CC3VertexRunLengthIndices

/**
 * An index array that manages the drawing indices of an array of vertices,
 * treating the index array as a run-length encoded array of indexes.
 *
 * This class is also a type of CC3DrawableVertexArray, and as such,
 * is capable of drawing the vertex elements to the GL engine, in this case
 * as a run-length encoded series of drawing calls.
 */
@interface CC3VertexRunLengthIndices : CC3VertexIndices {}
@end

