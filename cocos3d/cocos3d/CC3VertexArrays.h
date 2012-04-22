/*
 * CC3VertexArrays.h
 *
 * cocos3d 0.7.1
 * Author: Bill Hollings, Chris Myers
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * within the CC3Scene so that nodes using the same mesh vertices are drawn together, before
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
	GLsizei allocatedElementCount;
	GLint elementSize;
	GLenum elementType;
	GLsizei elementStride;
	GLuint bufferID;
	GLenum bufferUsage;
	GLfloat capacityExpansionFactor;
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
 * Returns the length, or size, of each individual element, measured in bytes.
 *
 * The returned value is the result of multiplying the size of the data type identified
 * by the elementType property, with the value of the elementSize property.
 *
 * For example, if the elementType property is GL_FLOAT and the elementSize property
 * is 3, this property will return (sizeof(GLfloat) * 3) = (4 * 3) = 12.
 *
 * For non-interleaved data, the value of this property will be the same as the
 * value of the elementStride property. For interleaved data, the value of this
 * property will be smaller than the value of the elementStride property.
 */
@property(nonatomic, readonly) GLsizei elementLength;

/**
 * The number of bytes between consecutive vertices for the vertex aspect being
 * managed by this instance.
 *
 * If the underlying data is not interleaved, and contains only the data managed
 * by this instance, the value of this property will be the same as that of the
 * elementLength property.
 * 
 * If the underlying data is interleaved and contains data for several vertex aspects
 * (location, normals, colors...) interleaved in one memory space, this value should
 * be set by the application to indicate the distance, in bytes, from one element of
 * this aspect to the next.
 *
 * The initial value of this property is the same as the value of the elementLength property.
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

/**
 * Configure this vertex array to use the same underlying vertex data as the specified
 * other vertex array, with the data used by this array interleaved with the data from
 * the other vertex array. This can be repeated with other arrays to interleave the data
 * from several vertex arrays into one underlying memory buffer.
 *
 * This is a convenience method that sets the elements, elementStride, and elementCount
 * properties of this vertex array to be the same as those of the other vertex array,
 * and then sets the elementOffset property of this vertex array to the specified
 * elemOffset value.
 *
 * Returns a pointer to the elements array, offset by the elemOffset. This is effectively
 * a pointer to the first element in this vertex array, and can be used as a starting
 * point to iterate the array to populate it.
 */
-(GLvoid*) interleaveWith: (CC3VertexArray*) otherVtxArray usingOffset: (GLuint) elemOffset;


#pragma mark Binding GL artifacts

/**
 * Allocates underlying memory for the specified number of elements, taking into
 * consideration the elementStride, assigns the elements property to point to the
 * allocated memory, and returns a pointer to the allocated memory. Specifically,
 * the amount of memory allocated will be (elemCount * self.elementStride) bytes.
 *
 * Once completed, the elementCount property is set to the specified value.
 *
 * If the underlying data is to be interleaved, set the value of the elementStride
 * property to the appropriate value before invoking this method. If the underlying
 * data will not be interleaved, the elementStride property is determined by the
 * elementType and elementSize properties. Therefore, set the correct values of these
 * two properties before invoking this method.
 *
 * When interleaving data, this method should be invoked on only one of the CC3VertexArray
 * instances that are sharing the underlying data. After allocating on one CC3VertexArray
 * instances, set the elements property of the other instances to be equal to the elements
 * property of the CC3VertexArray instance on which this method was invoked (or just
 * simply to the pointer returned by this method).
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(GLvoid*) allocateElements: (GLsizei) elemCount;

/**
 * Allocates underlying memory for the specified number of elements, taking into
 * consideration the elementStride, assigns the elements property to point to the
 * allocated memory, and returns a pointer to the allocated memory. Specifically, the
 * total amount of memory allocated will be (elemCount * self.elementStride) bytes.
 *
 * Once completed, the elementCount property is set to the specified value.
 *
 * This method can be used to manage the underlying mesh vertex data as a
 * dynamically-sized array, growing and shrinking the allocated memory as needed.
 *
 * If element memory has been previously allocated with either this method or the
 * alocateElements: method, the elements already saved to the array, up to the number
 * specified by elemCount will remain unchanged. In this case, this method essentially
 * expands the allocated size of the underlying data array, while retaining the existing
 * contents.
 *
 * If the specified elemCount is less that was previously allocated, the elements already
 * saved to the array, up to the number specified by elemCount will remain unchanged, and
 * memory beyond that point will be freed. This method essentially shrinks the allocated
 * size of the underlying data array, while retaining the exisitng contents up to the
 * reduced size.
 *
 * If element memory has not been previously allocated, this method behaves like the
 * allocateElements: method.
 *
 * If the underlying data is to be interleaved, set the value of the elementStride
 * property to the appropriate value before invoking this method. If the underlying
 * data will not be interleaved, the elementStride property is determined by the
 * elementType and elementSize properties. Therefore, set the correct values of these
 * two properties before invoking this method.
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
-(GLvoid*) reallocateElements: (GLsizei) elemCount;

/**
 * Checks to see if the underlying elements data array, that was previously allocated
 * with either the allocateElements: method or reallocateElements: method has enough
 * capacity to hold the specified number of elements.
 *
 * If sufficient capacity exists, this implementation does nothing.
 *
 * If there is not sufficient capacity, the reallocateElements: method is invoked to
 * expand the array to accomodate the specified number of elements, plus some buffer
 * capacity as specified by the capacityExpansionFactor property. The capacity is
 * expanded to a total of (elemCount * capacityExpansionFactor).
 *
 * If the elements property was set directly, and was not previously allocated
 * using either the allocateElements: method or reallocateElements: method, the
 * memory is being managed by the application. This implementation assumes
 * sufficient memory, and does nothing.
 *
 * Returns whether the underlying element data had to be expanded. The application
 * can use this response value to determine whether or not to reset GL buffers, etc.
 */
-(BOOL) ensureCapacity: (GLsizei) elemCount;

/**
 * A factor that is used to provide buffer capacity when increasing the allocated
 * capacity via the ensureCapacity: method.
 *
 * If the ensureCapacity: method determines that there is not sufficient capacity,
 * the reallocateElements: method is invoked to increase the capacity to a total
 * of (require-capacity * capacityExpansionFactor).
 *
 * The initial value of this property is 1.25, providing a buffer of 25% whenever
 * the capacity is expanded.
 */
@property(nonatomic, assign) GLfloat capacityExpansionFactor;

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
 * If the shouldAllowVertexBuffering property is set to YES, creates a vertex buffer
 * object (VBO) within the GL engine, copies the data referenced by the elements into
 * the GL engine  (which may make use of VRAM), and sets the value of the bufferID
 * property to that of the new GL buffer.
 *
 * If memory for the elements was allocated via the allocateElements: method, the GL
 * VBO size is set to the same as the amount allocated by this instance. If memory was
 * allocated externally, the GL VBO size is set to the value of elementCount.
 * 
 * Calling this method is optional. Using GL engine buffers is more efficient than passing
 * arrays on each GL draw call, but is optional. If you choose not to call this method,
 * this instance will pass the mesh data properties to the GL engine on each draw call.
 *
 * If the GL engine cannot allocate space for any of the buffers, this instance will
 * revert to passing the array data for any unallocated buffer on each draw call.
 *
 * When using interleaved data, this method should be invoked on only one of the 
 * CC3VertexArrays that share the data. The bufferID property of that instance should
 * then be copied to the other vertex arrays.
 *
 * Consider using the createGLBuffers of the mesh class instead of this method, which
 * automatically handles the buffering all vertex arrays used by the mesh, and correctly
 * coordinates buffering interleaved data.
 *
 * It is safe to invoke this method more than once, but subsequent invocations will do nothing.
 *
 * This method is invoked automatically by the createGLBuffers method of the mesh class,
 * which also coordinates the invocations across multiple CC3VertexArray instances when
 * interleaved data is shared between them, along with the subsequent copying of the
 * bufferID's.
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
 * Returns whether the underlying vertex data has been loaded into a GL engine vertex
 * buffer object. Vertex buffer objects are engaged via the createGLBuffer method.
 */
@property(nonatomic, readonly) BOOL isUsingGLBuffer;

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

/**
 * Returns a string containing a description of the elements of this vertex array, with
 * the contents of each element output on a different line. The number of values output
 * on each line is dictated by the elementSize property.
 *
 * The output contains the all of the elements in this vertex array. The total number
 * of values output will therefore be (elementSize * elementCount).
 */
-(NSString*) describeElements;

/**
 * Returns a string containing a description of the specified elements, with the contents
 * of each element output on a different line. The number of values output on each line
 * is dictated by the elementSize property.
 *
 * The output contains the number of elements specified, starting at the first element in
 * this vertex array, and is limited to the number of elements in this array. The total
 * number of values output will therefore be (elementSize * MIN(elemCount, elementCount)).
 */
-(NSString*) describeElements: (GLsizei) elemCount;

/**
 * Returns a string containing a description of the specified elements, with the contents
 * of each element output on a different line. The number of values output on each line
 * is dictated by the elementSize property. 
 *
 * The output contains the number of elements specified, starting at the element at the
 * specified index, and is limited to the number of elements in this array. The total number
 * of values output will therefore be (elementSize * MIN(elemCount, elementCount - startElem)).
 */
-(NSString*) describeElements: (GLsizei) elemCount startingAt: (GLsizei) startElem;


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


#pragma mark Faces

/**
 * Returns the number of faces in this array.
 *
 * This is calculated from the number of vertices, taking into
 * consideration the drawing mode of this array.
 */
@property(nonatomic, readonly) GLsizei faceCount;

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

/**
 * Returns the vertex indices of the face from the mesh at the specified index.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 *
 * The returned structure reference contains the indices of the three vertices that
 * make up the triangular face. These indices index into the actual vertex locations
 * in the CC3VertexLocations array.
 *
 * This method takes into consideration the drawingMode of this vertex array,
 * and any padding (stride) between the vertex indices.
 */
-(CC3FaceIndices) faceIndicesAt: (GLsizei) faceIndex;

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
 * This implementation takes into consideration the elementSize property. If the value
 * of the elementSize property is 2, the returned vector will contain zero in the Z component.
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
 * This implementation takes into consideration the elementSize property. If the value
 * of the elementSize property is 2, the Z component of the specified vector will be
 * ignored. If the value of the elementSize property is 4, the specified vector will
 * be converted to a 4D vector, with the W component set to one, before storing.
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
 * Returns the location element at the specified index in the underlying vertex data,
 * as a four-dimensional location in the 4D homogeneous coordinate space.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * This implementation takes into consideration the elementSize property. If the
 * value of the elementSize property is 3, the returned vector will contain one
 * in the W component. If the value of the elementSize property is 2, the returned
 * vector will contain zero in the Z component and one in the W component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector4) homogeneousLocationAt: (GLsizei) index;

/**
 * Sets the location element at the specified index in the underlying vertex data to
 * the specified four-dimensional location in the 4D homogeneous coordinate space.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * This implementation takes into consideration the elementSize property. If the value
 * of the elementSize property is 3, the W component of the specified vector will be
 * ignored. If the value of the elementSize property is 2, both the W and Z components
 * of the specified vector will be ignored.
 * 
 * If the new vertex location changes the bounding box of this instance, and this
 * instance is being used by any mesh nodes, be sure to invoke the rebuildBoundingVolume
 * method on all mesh nodes that use this vertex array, to ensure that the boundingVolume
 * encompasses the new vertex location.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setHomogeneousLocation: (CC3Vector4) aLocation at: (GLsizei) index;

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

/**
 * Returns the face from the mesh at the specified index.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 *
 * The returned face structure contains only the locations of the vertices. If the vertex
 * locations are interleaved with other vertex data, such as color or texture coordinates,
 * or other padding, that data will not appear in the returned face structure.
 *
 * This method takes into consideration the drawingMode of this vertex array,
 * and any padding (stride) between the vertex indices.
 *
 * This method is only meaningful if the vertices are drawn directly from this vertex
 * array, without using vertex indexing. If vertex indexing is in use (the mesh contains
 * an instance of CC3VertexIndices) the order of the vertices in this array will likely
 * not be accurate.
 */
-(CC3Face) faceAt: (GLsizei) faceIndex;

/**
 * Returns the mesh face that is made up of the three vertices at the three indices
 * within the specified face indices structure. Because indexing is used, the three
 * vertices that make up the face may not be contiguous within this array.
 *
 * The returned face structure contains only the locations of the vertices. If the vertex
 * locations are interleaved with other vertex data, such as color or texture coordinates,
 * or other padding, that data will not appear in the returned face structure.
 */
-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices;

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
 * The vertical axis of the coordinate system of OpenGL is inverted relative to
 * the iOS view coordinate system. This results in textures from most file formats
 * being oriented upside-down, relative to the OpenGL coordinate system. All file
 * formats except PVR format will be oriented upside-down after loading.
 *
 * This class supports the expectsVerticallyFlippedTextures property and several
 * utility methods to help align these texture coordinates with textures.
 * The alignWithTexture: method is invoked automatically whenever a texture is added
 * to the mesh holding these texture coordinates to align these texture coordinates
 * with the new texture. In addition, there are several utility methods that can be
 * invoked to flip the mesh data for a texture, either horizontally or vertically.
 *
 * This class includes several convenience methods that allow the texture coordinates
 * to be adjusted to match the visible area of a particular texture.
 *
 * This class supports covering the mesh with a repeating texture through the
 * repeatTexture: method.
 *
 * This class also supports covering the mesh with only a fractional part of the texture
 * through the use of the textureRectangle property, effectivly permitting sprite-sheet
 * textures to be used with 3D meshes.
 */
@interface CC3VertexTextureCoordinates : CC3VertexArray {
	CGSize mapSize;
	CGSize naturalMapSize;
	CGRect textureRectangle;
	BOOL expectsVerticallyFlippedTextures;
}

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
 * Indicates whether the texture coordinates of this mesh expects that the texture
 * was flipped upside-down during texture loading.
 * 
 * The vertical axis of the coordinate system of OpenGL is inverted relative to
 * the iOS view coordinate system. This results in textures from most file formats
 * being oriented upside-down, relative to the OpenGL coordinate system. All file
 * formats except PVR format will be oriented upside-down after loading.
 *
 * The value of this property is used in combination with the value of the 
 * isFlippedVertically property of a texture to determine whether the texture
 * will be oriented correctly when displayed using these texture coordinates.
 *
 * The alignWithTexture: method compares the value of this property with the
 * isFlippedVertically property of the texture to automatically determine
 * whether these texture coordinates need to be flipped vertically in order
 * to display the texure correctly, and will do so if needed. As part
 * of that inversion, the value of this property will also be flipped, to
 * indicate that the texture coordinates are now aligned differently.
 *
 * The value of this property does not affect the behaviour of, nor
 * is affected by, the flipVertically , alignWithInvertedTexture:,
 * alignWithTextureMapSize:, or alignWithInvertedTextureMapSize: methods.
 * 
 * The initial value of this property is determined by the value of the class-side
 * defaultExpectsVerticallyFlippedTextures property at the time an instance of
 * this class is created and initialized. If you want all meshes to behave the same
 * way, with respect to this property, set the value of that class-side property.
 * 
 * The value of this property is set when the underlying mesh texture
 * coordinates are built or loaded. See the same property on the CC3Resource
 * class to understand how this property is set during mesh resource loading.
 * 
 * When building meshes programmatically, you should endeavour to design the
 * mesh so that this property will be YES if you will be using vertically-flipped
 * textures (all texture file formats except PVR).
 */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures;

/**
 * This class-side property determines the initial value of the
 * expectsVerticallyFlippedTextures property when an instance
 * of this class is created and initialized.
 *
 * See the notes for that property for more information.
 *
 * The initial value of this class-side property is YES.
 */
+(BOOL) defaultExpectsVerticallyFlippedTextures;

/**
 * This class-side property determines the initial value of the
 * expectsVerticallyFlippedTextures property when an instance
 * of this class are created and initialized.
 *
 * See the notes for that property for more information.
 *
 * The initial value of this class-side property is YES.
 */
+(void) setDefaultExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped;

/**
 * Aligns the texture coordinate array with the specfied texture map size,
 * which is typically extracted from a specific texture.
 * 
 * Under iOS, textures that do not have dimensions that are a power-of-two, will
 * be padded to dimensions of a power-of-two on loading. The result is that the
 * texture will be physically larger than is expected by these texture coordinates.
 * The texture map size indicates the usable size of the texture, and invoking
 * this method will align these texture coordinates with that usable size.
 *
 * For the sake of efficiency, if the specified texMapSize is the same as the
 * value submitted in the previous invocation (or is equal to (1, 1) on the
 * first invocation), this method does nothing, to avoid updating the texture
 * coordinates when no change has occurred.
 *
 * For subsequent invocations, if the specified texMapSize is the same as the
 * value submitted in the previous invocation, this method does nothing, to
 * avoid updating all the texture coordinates to the value they currently have.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithTextureMapSize: (CGSize) texMapSize;

/**
 * Aligns the texture coordinate array with the specfied texture map size,
 * which is typically extracted from a specific texture, and vertically
 * flips the texture coordinates.
 * 
 * Under iOS, textures that do not have dimensions that are a power-of-two, will
 * be padded to dimensions of a power-of-two on loading. The result is that the
 * texture will be physically larger than is expected by these texture coordinates.
 * The texture map size indicates the usable size of the texture, and invoking
 * this method will align these texture coordinates with that usable size.
 *
 * The texture coordinates are flipped vertically to align with textures that have
 * been loaded upside down. Under iOS, most texture formats are loaded upside-down,
 * and this method can be used to compensate.
 *
 * This method vertically flips the texture coordinates on each invocation. As a
 * result, unlike the alignWithTextureMapSize: method, this method updates all the
 * texture coordinates on each invocation, regardless of whether the specified
 * texMapSize is the same as on the previous invocation.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithInvertedTextureMapSize: (CGSize) texMapSize;

/**
 * Aligns the texture coordinate array with the specfied texture.
 * 
 * Under iOS, textures that do not have dimensions that are a power-of-two, will
 * be padded to dimensions of a power-of-two on loading. The result is that the
 * texture will be physically larger than is expected by these texture coordinates.
 *
 * The usable area of the texture is indicated by its mapSize property, and invoking
 * this method will align these texture coordinates with the usable size of the
 * specified texture.
 *
 * If the value of the expectsVerticallyFlippedTextures property is different
 * than the value of the isFlippedVertically property of the specified texture, the
 * texture coordinates are not oriented vertically for the texture. To align them,
 * this method delegates to the alignWithInvertedTextureMapSize:, passing the mapSize
 * of the specified texture, to both align the texture coordinates to the usable size
 * of the texture, and to flip the texture coordinates to align with the texture.
 *
 * If the value of the expectsVerticallyFlippedTextures property is the same
 * as the value of the isFlippedVertically property of the specified texture, the
 * texture coordinates are correctly oriented vertically for the texture. This
 * method delegates to the alignWithTextureMapSize:, passing the mapSize of the
 * specified texture, to align the texture coordinates to the usable size of
 * the texture, but does not flip the texture coordinates.
 *
 * To avoid updating the texture coordinates when no change has occurred, if the
 * coordinates do not need to be flipped vertically, and the specified texture has
 * the same usable area as the texture used on the previous invocation (or has a
 * full usable area on the first invocation), this method does nothing.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithTexture: (CC3Texture*) texture;

/**
 * Aligns the texture coordinate array with the specfied texture and vertically
 * flips the texture coordinates.
 * 
 * Under iOS, textures that do not have dimensions that are a power-of-two, will
 * be padded to dimensions of a power-of-two on loading. The result is that the
 * texture will be physically larger than is expected by these texture coordinates.
 *
 * The usable area of the texture is indicated by its mapSize property, and invoking
 * this method will align these texture coordinates with the usable size of the
 * specified texture.
 *
 * The texture coordinates are flipped vertically to align with textures that have
 * been loaded upside down. Under iOS, most texture formats are loaded upside-down,
 * and the texture coordinates are automatically aligned to compensate (see the
 * notes for the alignWithTexture: method).
 *
 * As a result, the application usually has no need for this method. However, this
 * method can be used occasionally when the automatic alignment is not effective.
 *
 * This method vertically flips the texture coordinates on each invocation. As a
 * result, unlike the alignWithTexture: method, this method updates all texture
 * coordinates on each invocation, regardless of whether the specified texMapSize
 * is the same as on the previous invocation.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This may cause mapping conflicts if the same vertex data is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithInvertedTexture: (CC3Texture*) texture;

/**
 * Convenience method that flips the texture coordinate mapping horizontally.
 * This has the effect of flipping the texture horizontally on the model,
 * and can be useful for creating interesting effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 */
-(void) flipHorizontally;

/**
 * Convenience method that flips the texture coordinate mapping vertically.
 * This has the effect of flipping the texture vertically on the model,
 * and can be useful for creating interesting effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 */
-(void) flipVertically;

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
 * Configures this instance to draw triangular faces, and allocates memory for the
 * specified number of triangles. Each triangular face contains three vertex indices.
 *
 * After the allocation, the elementCount property of this instance will be equal to
 * three times the specified number of triangles.
 *
 * Returns a pointer to the first allocated index. 
 */
-(GLushort*) allocateTriangles: (GLsizei) triangleCount;

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

/**
 * Returns the vertex indices of the face from the mesh at the specified index.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 *
 * The returned structure reference contains the indices of the three vertices that
 * make up the triangular face. These indices index into the actual vertex locations
 * in the CC3VertexLocations array.
 *
 * This method takes into consideration the drawingMode of this vertex array,
 * and any padding (stride) between the vertex indices.
 *
 * The indices in the returned face are of type GLushort, regardless of whether the
 * elementType property is GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE.
 */
-(CC3FaceIndices) faceIndicesAt: (GLsizei) faceIndex;

/**
 * Convenience method to populate this index array from the specified run-length
 * encoded array.
 *
 * Run-length encoded arrays are used to compactly store a set of variable-length
 * sub-arrays of indexes, where the first element of each sub-array indicates the
 * number of data elements contained in that sub-array.
 *
 * For example, if the first element of the array (element zero) contains the value 5,
 * then the next 5 elements of the array contain the first 5 data elements of the first
 * sub-array. Then the next element of the array (element 6) contains the length of the
 * second sub-array, and so on.
 *
 * The total number of elements in the run-length array, including the run-length entries
 * is specified by the rlaLen parameter.
 *
 * Run-length encoded arrays are of limited use as GL index arrays, because they cannot
 * easily be copied into, and managed as a VBO in the GL engine, which is a performance
 * hinderance. And becuase run-length encoded arrays intermix vertex indices and run
 * lengths, it makes accessing individual vertex indices and faces unwieldy.
 */
-(void) populateFromRunLengthArray: (GLushort*) runLenArray ofLength: (GLsizei) rlaLen;

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

/**
 * Returns a pointer to an array of the weight elements at the specified vertex
 * index in the underlying vertex data.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The number of
 * elements in the returned array is the same for all vertices in this array, and
 * can be retrieved from the elementSize property.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct elements.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat*) weightsAt: (GLsizei) index;

/**
 * Sets the weight elements at the specified vertex index in the underlying vertex data,
 * to the values in the specified array.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The number of
 * weight elements is the same for all vertices in this array, and can be retrieved
 * from the elementSize property. The number of elements in the specified input
 * array must therefore be at least as large as the value of the elementSize property.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setWeights: (GLfloat*) weights at: (GLsizei) index;

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
 * Several matrix indices are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the elementSize property, exclusive.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setMatrixIndex: (GLushort) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

/**
 * Returns a pointer to an array of the matrix indices at the specified vertex
 * index in the underlying vertex data.
 *
 * Several matrix index values are stored for each vertex, one per vertex unit,
 * corresponding to one for each bone that influences the location of the vertex.
 * The number of elements in the returned array is the same for all vertices in
 * this array, and can be retrieved from the elementSize property.
 * 
 * The matrix indices can be stored in this array as either type GLushort or type
 * GLubyte. The returned array will be of the type of index stored by this vertex
 * array, and it is up to the application to know which type will be returned,
 * and cast the returned array accordingly. The type can be determined by the
 * elementType property of this array, which will return one of GL_UNSIGNED_SHORT
 * or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the elementType altogether, you can use the matrixIndexForVertexUnit:at:
 * method, which retrieves the matrix index values one at a time, and automatically converts
 * the stored type to GLushort.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct elements.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLvoid*) matrixIndicesAt: (GLsizei) index;

/**
 * Sets the matrix index elements at the specified vertex index in the underlying
 * vertex data, to the values in the specified array.
 *
 * Several matrix index values are stored for each vertex, one per vertex unit,
 * corresponding to one for each bone that influences the location of the vertex.
 * The number of elements is the same for all vertices in this array, and can be
 * retrieved from the elementSize property. The number of elements in the specified input
 * array must therefore be at least as large as the value of the elementSize property.
 * 
 * The matrix indices can be stored in this array as either type GLushort or type GLubyte.
 * The specified array must be of the type of index stored by this vertex array, and it
 * is up to the application to know which type is required, and provide that type of
 * array accordingly. The type can be determined by the elementType property of this
 * array, which will return one of GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the elementType altogether, you can use the setMatrixIndex:forVertexUnit:at:
 * method, which sets the matrix index values one at a time, and automatically converts the
 * input type to the correct stored type.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setMatrixIndices: (GLvoid*) mtxIndices at: (GLsizei) index;

@end

