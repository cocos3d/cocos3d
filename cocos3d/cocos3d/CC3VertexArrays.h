/*
 * CC3VertexArrays.h
 *
 * cocos3d 0.6.4
 * Author: Bill Hollings, Chris Myers
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 * Copyright (c) 2011 Chris Myers. All rights reserved.
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
 *
 * Vertex arrays support the NSCopying protocol, but in normal operation, the need to create
 * copies of vertex arrays is rare.
 *
 * By default, when a mesh node is copied, it does not make a separate copy of its model.
 * Both the original and the copy make use of the same mesh instance. Similarly, when
 * a mesh is copied, it does not make separate copies of its vertex arrays. Instead,
 * both the original and the copy make use of the same vertex array instances.
 *
 * However, in some cases, such as populating a mesh from a template and then manipulating
 * the contents of each resulting mesh individually, creating copies of vertex arrays can
 * be useful.
 *
 * If you do find need to create a copy of a vertex array, you can do so by invoking the
 * copy method. However, you should take care to understand several points about copying
 * vertex arrays:
 *   - Copying a vertex array creates a full copy of the vertex data. This may consume
 *     significant memory.
 *   - The vertex data is copied for each vertex array copy. If several vertex arrays
 *     share interleaved data, multiple copies of that data will be created. This is almost
 *     never what you intend to do, and results in significant redundant data in memory.
 *     Instead, consider creating a copy of one of the vertex arrays, and then manually
 *     populating the others so that the interleaved vertex data can be shared.
 *   - If the value of the shouldReleaseRedundantData property of the original vertex
 *     array is YES and releaseRedundantData has been invoked, there will be no vertex
 *     data to be copied.
 *   - The new vertex array will not have a GL vertex buffer object associated with it.
 *     To buffer the vertex data of the new vertex array, invoke the createGLBuffer method
 *     on the new vertex array.
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
	BOOL shouldAllowVertexBuffering;
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
 * generally not be re-accessed after loading. If you will be updating the data frequently,
 * you can change this to GL_DYNAMIC_DRAW.
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
 * Indicates whether this instance should allow the vertex data to be copied to a vertex
 * buffer object within the GL engine when the createGLBuffer method is invoked.
 *
 * The initial value of this property is YES. In most cases, this is appropriate, but for
 * specific meshes, it might make sense to retain data in main memory and submit it to the
 * GL engine during each frame rendering.
 *
 * As an alternative to setting this property to NO, consider leaving it as YES, and making
 * use of the updateGLBuffer and updateGLBufferStartingAt:forLength: to dynamically update
 * the data in the GL engine buffer. Doing so permits the data to be copied to the GL engine
 * only when it has changed, and permits copying only the range of data that has changed,
 * both of which offer performance improvements over submitting all of the vertex data on
 * each frame render.
 */
@property(nonatomic, assign) BOOL shouldAllowVertexBuffering;

/** 
 * If the shouldAllowVertexBuffering property is set to YES, creates a vertex buffer object
 * within the GL engine, copies the data referenced by the elements into the GL engine (which
 * may make use of VRAM), and sets the value of the bufferID property to that of the new GL buffer.
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
 * This method is invoked automatically by the createGLBuffers method of the mesh class,
 * which also coordinates the invocations across multiple CC3VertexArray instances when
 * interleaved data is shared between them, along with the subsequent copying of the bufferID's.
 * Consider using the createGLBuffers of the mesh class instead of this method.
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
 * Updates the GL engine buffer with the element data contained in this array,
 * starting at the vertex at the specified offsetIndex, and extending for
 * the specified number of vertices.
 */
-(void) updateGLBufferStartingAt: (GLuint) offsetIndex forLength: (GLsizei) vertexCount;

/** Updates the GL engine buffer with all of the element data contained in this array. */
-(void) updateGLBuffer;

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
 * This is invoked automatically from the draw method of the CC3VertexArrayMesh
 * containing this instance. Usually, the application never needs to invoke this method directly.
 */
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor;

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
 * This method is invoked automatically from the CC3VertexArrayMesh instance.
 * Usually, the application never needs to invoke this method directly.
 */
+(void) unbind;


#pragma mark Accessing elements

/**
 * Returns a pointer to the element in the underlying data at the specified index.
 * The implementation takes into consideration the elementStride and elementOffset
 * properties to locate the aspect of interest in this instance.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, or the index is beyond the elementCount,
 * this method will raise an assertion exception.
 */
-(GLvoid*) addressOfElement: (GLsizei) index;


#pragma mark Array context switching

/**
 * Resets the tracking of the vertex array switching functionality.
 *
 * This is invoked automatically by the resetAllSwitching method at the beginning of each
 * frame drawing cycle. Usually, the application never needs to invoke this method directly.
 */
+(void) resetSwitching;

/**
 * Resets the tracking of the vertex array switching functionality for all vertex array subclasses.
 *
 * This is invoked automatically by the resetSwitching method in CC3VertexArrayMesh at the
 * beginning of each frame drawing cycle. Usually, the application never needs to invoke
 * this method directly.
 */
+(void) resetAllSwitching;

@end


#pragma mark -
#pragma mark CC3DrawableVertexArray

/**
 * This abstract subclass of  CC3VertexArray adds the functionality to draw the vertex
 * data to the display through the GL engine.
 *
 * The underlying data is drawn by invoking the drawWithVisitor: method, and can be drawn
 * in a single GL call for all vertices, or the vertices can be arranged in strips, and
 * the strips drawn serially.
 *
 * You define vertex strips using the stripCount and stripLengths properties, or using
 * the allocateStripLengths: method to set both properties at once.
 * 
 * Using vertex strips performs more GL calls, and will be less efficient, but in some
 * applications, might assist in the organization of mesh vertex data.
 *
 * Alternately, a subset of the vertices may be drawn by invoking the
 * drawFrom:forCount:withVisitor: method instead of the drawWithVisitor: method.
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
 * This method is invoked automatically from the draw method of CC3VertexArrayMesh.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Draws the specified number of vertices, starting at the specified vertex index,
 * in a single GL draw call.
 *
 * This method can be used to draw a subset of thevertices. This can be used when this array
 * holds data for a number of meshes, or when data is being sectioned for palette matrices.
 *
 * This abstract implementation collects drawing performance statistics if the visitor
 * is configured to do so. Subclasses will override to perform appropriate drawing
 * activity, but should also invoke this superclass implementation to perform the
 * collection of performance data.
 */
-(void) drawFrom: (GLuint) vertexIndex
		forCount: (GLuint) vertexCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor;

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


#pragma mark Utility

/**
 * Returns the number of faces to be drawn from the specified
 * number of vertices, based on the drawing mode of this array.
 */ 
-(GLsizei) faceCountFromVertexCount: (GLsizei) vc;

/**
 * Returns the number of vertices required to draw the specified
 * number of faces, based on the drawing mode of this array.
 */ 
-(GLsizei) vertexCountFromFaceCount: (GLsizei) fc;

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
	GLfloat radius;
	BOOL boundaryIsDirty;
	BOOL radiusIsDirty;
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
 * Returns the radius of a spherical boundary, centered on the centerOfGeometry,
 * that encompasses all the vertices of this mesh.
 */
@property(nonatomic, readonly) GLfloat radius;

/** Marks the boundary, including bounding box and radius, as dirty, and need of recalculation. */
-(void) markBoundaryDirty;

/**
 * Returns the location element at the specified index in the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
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
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 * 
 * If the new vertex location changes the bounding box of this instance, and this
 * instance is being used by any mesh nodes, be sure to invoke the rebuildBoundingVolume
 * method on all mesh nodes that use this vertex array, to ensure that the boundingVolume
 * encompasses the new vertex location.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setLocation: (CC3Vector) aLocation at: (GLsizei) index;

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
 * This method changes the location component of every vertex in the mesh data. This can
 * be quite costly, and should only be performed once to adjust a mesh so that it is
 * easier to manipulate.
 * 
 * Do not use this method to move your model around. Instead, use the transform
 * properties (location, rotation and scale) of the CC3Node that contains this mesh,
 * and let the GL engine do the heavy lifting of transforming the mesh vertices.
 * 
 * If this instance is being used by any mesh nodes, be sure to invoke the
 * rebuildBoundingVolume method on all mesh nodes that use this vertex array,
 * to ensure that the boundingVolume encompasses the new vertex locations.
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
 * This method changes the location component of every vertex in the mesh data. This can
 * be quite costly, and should only be performed once to adjust a mesh so that it is
 * easier to manipulate.
 * 
 * Do not use this method to move your model around. Instead, use the transform
 * properties (location, rotation and scale) of the CC3Node that contains this mesh,
 * and let the GL engine do the heavy lifting of transforming the mesh vertices.
 * 
 * If this instance is being used by any mesh nodes, be sure to invoke the
 * rebuildBoundingVolume method on all mesh nodes that use this vertex array,
 * to ensure that the boundingVolume encompasses the new vertex locations.
 *
 * This method ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) movePivotToCenterOfGeometry;

@end


#pragma mark -
#pragma mark CC3VertexNormals

/** A CC3VertexArray that manages the normal aspect of an array of vertices. */
@interface CC3VertexNormals : CC3VertexArray {}

/**
 * Returns the normal element at the specified index in the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
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
 * The index refers to vertices, not bytes. The implementation takes into consideration
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
 * If the underlying vertex data is not of type GLfloat, the color components are
 * converted to GLfloat before the color value is returned.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
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
 * If the underlying vertex data is not of type GLfloat, the color components are
 * converted to the appropriate type (typically GLubyte) before being set in the
 * vertex data.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setColor4F: (ccColor4F) aColor at: (GLsizei) index;

/**
 * Returns the color element at the specified index in the underlying vertex data.
 *
 * If the underlying vertex data is not of type GLubyte, the color components are
 * converted to GLubyte before the color value is returned.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4B) color4BAt: (GLsizei) index;

/**
 * Sets the color element at the specified index in the underlying vertex data to
 * the specified color value.
 *
 * If the underlying vertex data is not of type GLubyte, the color components are
 * converted to the appropriate type (typically GLfloat) before being set in the
 * vertex data.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setColor4B: (ccColor4B) aColor at: (GLsizei) index;

@end


#pragma mark -
#pragma mark CC3VertexTextureCoordinates

/** A rectangle with origin zero and unit size for initial value of the textureRectangle property. */
static const CGRect kCC3UnitTextureRectangle = { {0.0, 0.0}, {1.0, 1.0} };

/**
 * A CC3VertexArray that manages the texture coordinates aspect of an array of vertices.
 *
 * This class supports multi-texturing, and a single CC3VertexTextureCoordinates instance
 * can be applied to multiple texture units.
 *
 * This class includes several convenience methods that allow the texture coordinates
 * to be adjusted to match the visible area of a particular texture.
 *
 * This class supports covering the mesh with a repeating texture through the
 * repeatTexture: method.
 *
 * This class also supports covering the mesh with only a fractional part of the texture
 * through the use of the textureRectangle property, effectlivly permitting sprite-sheet
 * textures to be used with 3D meshes.
 */
@interface CC3VertexTextureCoordinates : CC3VertexArray {
	CGSize naturalMapSize;
	CGRect textureRectangle;
}

/**
 * Defines the rectangular area of the texture that should be mapped to the mesh.
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
 * The dimensions of the rectangle in this property are independent of the size
 * specified in the  alignWithTextureMapSize: and alignWithInvertedTextureMapSize:
 * methods. A unit rectangle value for this property will automatically take into
 * consideration the adjustment made to the mesh by those methods, and will display
 * only the part of the texture defined by them. Rectangular values for this property
 * that are smaller than the unit rectangle will be relative to the displayable area
 * defined by alignWithTextureMapSize: and alignWithInvertedTextureMapSize:.
 *
 * As an example, if the alignWithTextureMapSize: method was used to limit the mesh
 * to using only 80% of the texture (perhaps when using a non-POT texture), and this
 * property was set to a rectangle with origin at (0.5, 0.0) and size (0.5, 0.5),
 * the mesh will be covered by the bottom-right quarter of the usable 80% of the
 * overall texture.
 *
 * The initial value of this property is a rectangle with origin at zero, and unit
 * size, indicating that the mesh will be covered with the complete usable area of
 * the texture.
 */
@property(nonatomic, assign) CGRect textureRectangle;

/**
 * Returns the texture coordinate element at the specified index in the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
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
 * The index refers to vertices, not bytes. The implementation takes into consideration
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
 * dimensions is not a power-of-two), you should invoke one of the alignWithTexture...
 * or alignWithInvertedTexture... methods before invoking this method.
 *
 * In the example above, you would invoke one of those methods before invoking this
 * method, to first align the mesh with that non-power-of-two side.
 *
 * The dimensions of the repeatFactor are independent of the size specified in the
 * alignWithTextureMapSize: and alignWithInvertedTextureMapSize: methods, or derived
 * from the texture by the alignWithTexture or alignWithInvertedTexture methods.
 * A value of 1.0 for an element in the specified repeatFactor will automatically
 * take into consideration the adjustment made to the mesh by those methods, and will
 * display only the part of the texture defined by them.
 *
 * You can specify a fractional value for either of the components of the repeatFactor
 * to expand the texture in that dimension so that only part of the texture appears
 * in that dimension, while potentially repeating multiple times in the other dimension.
 */
-(void) repeatTexture: (ccTex2F) repeatFactor;

/**
 * Convenience method that flips the texture coordinate mapping horizontally.
 * This has the effect of flipping the texture horizontally on the model.
 */
-(void) flipHorizontally;

/**
 * Convenience method that flips the texture coordinate mapping vertically.
 * This has the effect of flipping the texture vertically on the model.
 */
-(void) flipVertically;

/**
 * Unbinds all texture arrays from the specified texture unit in the GL engine
 * by disabling texture array handling in the GL engine for that texture unit.
 *
 * The texture unit value should be set to a number between zero and the maximum number
 * of texture units, which can be read from [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 */
+(void) unbind: (GLuint) textureUnit;

/**
 * Unbinds all texture arrays from the all texture units at or above the specified texture unit.
 *
 * The texture unit value should be set to a number between zero and the maximum number
 * of texture units, which can be read from [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 */
+(void) unbindRemainingFrom: (GLuint)textureUnit;

/**
 * Unbinds all texture arrays from all texture units in the GL engine
 * by disabling texture array handling in the GL engine for all texture units.
 */
+(void) unbind;

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
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLushort) indexAt: (GLsizei) index;

/**
 * Sets the index element at the specified index in the underlying vertex data, to
 * the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setIndex: (GLushort) vertexIndex at: (GLsizei) index;

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


#pragma mark -
#pragma mark CC3VertexPointSizes

/** A CC3VertexArray that manages the point sizes aspect of an array of point sprite vertices. */
@interface CC3VertexPointSizes : CC3VertexArray {}

/**
 * Returns the point size element at the specified index in the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat) pointSizeAt: (GLsizei) index;

/**
 * Sets the point size element at the specified index in the underlying vertex data,
 * to the specified location value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setPointSize: (GLfloat) aSize at: (GLsizei) index;

@end


#pragma mark -
#pragma mark CC3VertexWeights

/**
 * A CC3VertexArray that manages a collection of weights used by each vertex during
 * vertex skinning, which is the manipulation of a soft-body mesh under control of
 * a skeleton of bone nodes.
 * 
 * This vertex array works together with an instace of a CC3VertexMatrixIndices vertex
 * array, and the elementSize property of the two vertex arrays must be equal, and must
 * not be larger than the maximum number of available vertex units for the platform,
 * which can be retreived from [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 */
@interface CC3VertexWeights : CC3VertexArray

/**
 * Returns the weight element, for the specified vertex unit, at the specified index in
 * the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding to
 * one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the elementSize property, exclusive.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

/**
 * Sets the weight element, for the specified vertex unit, at the specified index in
 * the underlying vertex data, to the specified value.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding to
 * one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the elementSize property, exclusive.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

@end


#pragma mark -
#pragma mark CC3VertexMatrixIndices

/**
 * A CC3VertexArray that manages a collection of indices used by each vertex to point
 * to a collection of distinct matrices during vertex skinning. Vertex skinning is
 * the manipulation of a soft-body mesh under control of a skeleton of bone nodes.
 * 
 * This vertex array works together with an instace of a CC3VertexWeights vertex array,
 * and the elementSize property of the two vertex arrays must be equal, and must
 * not be larger than the maximum number of available vertex units for the platform,
 * which can be retreived from [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 */
@interface CC3VertexMatrixIndices : CC3VertexArray

/**
 * Returns the matrix index element, for the specified vertex unit, at the specified
 * index in the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * Several matrix indices are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the elementSize property, exclusive.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLushort) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

/**
 * Sets the matrix index element, for the specified vertex unit, at the specified index
 * in the underlying vertex data, to the specified value.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * Several matrix indices are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the elementSize property, exclusive.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setMatrixIndex: (GLushort) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

@end

