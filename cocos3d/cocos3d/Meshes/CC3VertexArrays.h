/*
 * CC3VertexArrays.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3ShaderSemantics.h"


#pragma mark -
#pragma mark CC3VertexArrayContent

/**
 * CC3VertexArrayContent contains the vertex content data on behalf of a CC3VertexArray.
 *
 * This is a simple direct-access class with public instance variables, making this class little
 * more than a memory-allocated structure. This design is deliberate.
 *
 * When vertex content is interleaved, multiple vertex arrays share access to the same vertex content
 * memory and the same GL buffer resources. In this situation, a single CC3VertexArrayContent instance
 * will be shared between the vertex arrays whose data are interleaved within the mesh, giving all
 * interleaved vertex arrays access to the same vertex content memory and GL buffer resources.
 *
 * When vertex content is not interleaved, each vertex array will contain a separate instance of
 * CC3VertexArrayContent, giving each vertex array access to its own vertex content memory and GL
 * buffer resources.
 */
@interface CC3VertexArrayContent : NSObject {
@public
	GLvoid* _vertices;
	GLuint _vertexCount;
//	GLuint _allocatedVertexCapacity;
	GLuint _vertexStride;
	GLuint _bufferID;
	GLenum _bufferUsage;
	NSRange _dirtyVertexRange;
	BOOL _shouldAllowVertexBuffering : 1;
	BOOL _shouldReleaseRedundantContent : 1;
	BOOL _wasVertexCapacityChanged : 1;		// Future use to track dirty vertex range
}

@end


#pragma mark -
#pragma mark CC3VertexArray

/**
 * CC3VertexArray manages the content associated with an aspect of a vertex. CC3VertexArray
 * is an abstract implementation, and there are several sublcasses, each specialized to
 * manage the vertex content for a different vertex aspect (locations, normals, colors,
 * texture mapping, indices...).
 *
 * Each instance of a subclass of CC3VertexArray maintains a reference to the underlying
 * vertex content in memory, along with various parameters describing the underlying content,
 * such as its type, element size, stride, etc.
 *
 * The underlying content can be interleaved and shared by several CC3VertexArray subclasses,
 * each looking at a different aspect of the content for each vertex. In this case, the vertices
 * property of each of those vertex array instances will reference the same underlying content
 * memory, and the elementOffset property of each CC3VertexArray instance will indicate at which
 * offset in each vertex content the datum of interest to that instance is located.
 *
 * The CC3VertexArray instance also manages buffering the content to the GL engine, including
 * loading it into a server-side GL vertex buffer object (VBO) if desired. Once loaded into
 * the GL engine buffers, the underlying content can be released from the CC3VertexArray instance,
 * thereby freeing memory, by using the releaseRedundantContent method.
 *
 * The CC3DrawableVertexArray abstract subclass adds the functionality to draw the vertex
 * content to the display through the GL engine.
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
 *   - Copying a vertex array creates a full copy of the vertex content. This may consume
 *     significant memory.
 *   - The vertex content is copied for each vertex array copy. If several vertex arrays share
 *     interleaved content, multiple copies of that content will be created. This is almost
 *     never what you intend to do, and results in significant redundant content in memory.
 *     Instead, consider creating a copy of one of the vertex arrays, and then manually
 *     populating the others so that the interleaved vertex content can be shared.
 *   - If the value of the shouldReleaseRedundantContent property of the original vertex
 *     array is YES and releaseRedundantContent has been invoked, there will be no vertex
 *     content to be copied.
 *   - The new vertex array will not have a GL vertex buffer object associated with it.
 *     To buffer the vertex content of the new vertex array, invoke the createGLBuffer method
 *     on the new vertex array.
 */
@interface CC3VertexArray : CC3Identifiable {
	//	CC3VertexArrayContent* _vertexContent;
	GLuint _elementOffset;
	GLint _elementSize;
	GLenum _elementType;
	GLuint _allocatedVertexCapacity;

//	NSRange _dirtyVertexRange;
	GLvoid* _vertices;
	GLuint _vertexCount;
	GLuint _bufferID;
	GLenum _bufferUsage;
	GLenum _semantic;
	GLuint _vertexStride : 8;
	BOOL _shouldNormalizeContent : 1;
	BOOL _shouldAllowVertexBuffering : 1;
	BOOL _shouldReleaseRedundantContent : 1;
	BOOL _wasVertexCapacityChanged : 1;		// Future use to track dirty vertex range
}

/**
 * The CC3VertexArrayContent instance that contains the vertex content data on behalf of this vertex array.
 *
 * This property is set automatically when the vertex array is assigned to a mesh, or when the
 * shouldInterleaveVertices property of the mesh is changed. Usually, the application never needs
 * to access or set this property.
 */
//@property(nonatomic, retain) CC3VertexArrayContent* vertexContent;

/**
 * Indicates the vertex attribute semantic of this array.
 *
 * Under OpenGL ES 2, this values are used to match a vertex array to its semantic usage
 * within a GLSL vertex shader.
 *
 * The initial value of this property is set by from the defaultSemantic class property,
 * which subclasses override to provide an appropriate semantic value from the
 * CC3VertexContentSemantic enumeration, based on the vertex array type.
 *
 * The app may change this property to a custom value if desired. The custom value should be
 * kept within the range defined by kCC3SemanticAppBase and kCC3SemanticMax.
 */
@property(nonatomic, assign) GLenum semantic;

/**
 * The default value for the semantic property.
 *
 * Each subclass will provide an appropriate value from the CC3VertexContentSemantic enumeration.
 */
+(GLenum) defaultSemantic;

/**
 * A pointer to the underlying vertex content. If the underlying content memory is assigned
 * to this instance using this property directly, the underlying content memory is neither
 * retained nor deallocated by this instance. It is up to the application to manage the
 * allocation and deallocation of the underlying content memory.
 *
 * Alternately, the allocatedVertexCapacity property can be used to have this instance allocate
 * and manage the underlying vertex content. When this is done, the underlying content memory
 * will be retained and deallocated by this instance.
 *
 * The underlying content can be interleaved and shared by several CC3VertexArray subclasses,
 * each looking at a different aspect of the content for each vertex. In this case, the
 * vertices property of each of those vertex array instances will reference the same
 * underlying content memory, and the elementOffset property will indicate at which offset
 * in each vertex content the datum of interest to that instance is located.
 */
@property(nonatomic, assign) GLvoid* vertices;

/** @deprecated Renamed to vertices. */
@property(nonatomic, assign) GLvoid* elements DEPRECATED_ATTRIBUTE;

/**
 * The number of vertices in the underlying content referenced by the vertices property.
 * The vertices property must point to an underlying memory space that is large enough
 * to hold the amount of content specified by this property.
 *
 * The initial value is zero.
 *
 * Setting the value of the allocatedVertexCapacity property also sets the value of this
 * property to the same value. After setting the allocatedVertexCapacity property, if you
 * will not be using all of the allocated vertices immediately, you should set the value
 * of this vertexCount property to the actual number of vertices in use.
 */
@property(nonatomic, assign) GLuint vertexCount;

/** @deprecated Renamed to vertexCount. */
@property(nonatomic, assign) GLuint elementCount DEPRECATED_ATTRIBUTE;

/**
 * When using interleaved content, this property indicates the offset, within the content for a
 * single vertex, at which the datum managed by this instance is located. When content is not
 * interleaved, and the vertices content is dedicated to this instance, this property will be zero.
 *
 * The initial value is zero.
 */
@property(nonatomic, assign) GLuint elementOffset;

/**
 * The number of components associated with each vertex in the underlying content.
 *
 * As an example, the location of each vertex in 3D space is specified by three components (X,Y & Z),
 * so the value of this property in an instance tracking vertex locations would be three.
 *
 * When allocating non-interleaved vertex memory, setting this property affects the amount of
 * memory allocated by the allocatedVertexCapacity property. If this property is set after
 * the allocatedVertexCapacity property has been set, vertex memory will be reallocated again.
 * To avoid allocating twice, if you are not interleaving content, and you need to set this
 * property, do so before setting the allocatedVertexCapacity property.
 *
 * The initial value is three. Subclass may override this default.
 */
@property(nonatomic, assign) GLint elementSize;

/**
 * The type of content associated with each component of a vertex.
 * This must be a valid enumerated GL content type suitable for the type of element.
 *
 * When allocating non-interleaved vertex memory, setting this property affects the amount of
 * memory allocated by the allocatedVertexCapacity property. If this property is set after
 * the allocatedVertexCapacity property has been set, vertex memory will be reallocated again.
 * To avoid allocating twice, if you are not interleaving content, and you need to set this
 * property, do so before setting the allocatedVertexCapacity property.
 *
 * The initial value is GL_FLOAT.
 */
@property(nonatomic, assign) GLenum elementType;

/**
 * Returns the length, or size, of each individual element, measured in bytes.
 *
 * The returned value is the result of multiplying the size of the content type identified
 * by the elementType property, with the value of the elementSize property.
 *
 * For example, if the elementType property is GL_FLOAT and the elementSize property
 * is 3, this property will return (sizeof(GLfloat) * 3) = (4 * 3) = 12.
 *
 * For non-interleaved content, the value of this property will be the same as the
 * value of the vertexStride property. For interleaved content, the value of this
 * property will be smaller than the value of the vertexStride property.
 */
@property(nonatomic, readonly) GLuint elementLength;

/**
 * The number of bytes between consecutive vertices for the vertex aspect being
 * managed by this instance.
 *
 * If the underlying content is not interleaved, and contains only the content managed
 * by this instance, the value of this property will be the same as that of the
 * elementLength property, and this property does not need to be set explicitly.
 * 
 * If the underlying content is interleaved and contains content for several vertex aspects
 * (location, normals, colors...) interleaved in one memory space, this value should
 * be set by the application to indicate the distance, in bytes, from one element of
 * this aspect to the next.
 *
 * When allocating interleaved vertex memory, setting this property affects the amount of
 * memory allocated by the allocatedVertexCapacity property. If this property is set after
 * the allocatedVertexCapacity property has been set, vertex memory will be reallocated again.
 * To avoid allocating twice, if you need to set this property, do so before setting the
 * allocatedVertexCapacity property.
 *
 * The initial value of this property is the same as the value of the elementLength property.
 */
@property(nonatomic, assign) GLuint vertexStride;

/** @deprecated Renamed to vertexStride. */
@property(nonatomic, assign) GLuint elementStride DEPRECATED_ATTRIBUTE;

/**
 * Indicates whether the vertex content should be normalized during drawing.
 *
 * This property applies only to OpenGL ES 2. When using OpenGL ES 1, this property can be ignored.
 *
 * Under OpenGL ES 2, vertex content that is provided in an integer format (eg. the elementType property
 * is set to anything other than GL_FLOAT), this property indicates whether the element content should
 * be normalized, by being divided by their maximum range, to convert them into floating point variables
 * between 0 & 1 (for unsigned integer types), or -1 & +1 (for signed integer types).
 *
 * If this property is set to YES, the element content will be normalized, otherwise it will be
 * used as is. The normalization activity takes place in the GL engine.
 *
 * The default value of this property is NO, indicating that the element content will not be
 * normalized during drawing.
 */
@property(nonatomic, assign) BOOL shouldNormalizeContent;

/**
 * If the underlying content has been loaded into a GL engine vertex buffer object, this
 * property holds the ID of that GL buffer as provided by the GL engine when the
 * createGLBuffer method was invoked. If the createGLBuffer method was not invoked,
 * and the underlying vertex was not loaded into a GL VBO, this property will be zero.
 */
@property(nonatomic, assign) GLuint bufferID;

/**
 * The GL engine buffer target. Must be one of GL_ARRAY_BUFFER or GL_ELEMENT_ARRAY_BUFFER.
 *
 * The default value is GL_ARRAY_BUFFER. Subclasses that manage index content will override.
 */
@property(nonatomic, readonly) GLenum bufferTarget;

/**
 * The GL engine buffer usage hint, used by the GL engine to arrange content for access when
 * loading content into a server-side vertex buffer object.
 *
 * The default value is GL_STATIC_DRAW, indicating to the GL engine that the content will
 * generally not be re-accessed after loading. If you will be updating the content frequently,
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
 * Configure this vertex array to use the same underlying vertex content as the specified
 * other vertex array, with the content used by this array interleaved with the content from
 * the other vertex array. This can be repeated with other arrays to interleave the content
 * from several vertex arrays into one underlying memory buffer.
 *
 * This is a convenience method that sets the vertices, vertexStride, and vertexCount
 * properties of this vertex array to be the same as those of the other vertex array,
 * and then sets the elementOffset property of this vertex array to the specified
 * elemOffset value.
 *
 * Returns a pointer to the vertices array, offset by the elemOffset. This is effectively
 * a pointer to the first element in this vertex array, and can be used as a starting
 * point to iterate the array to populate it.
 */
-(GLvoid*) interleaveWith: (CC3VertexArray*) otherVtxArray usingOffset: (GLuint) elemOffset;

/**
 * Configure, or reconfigure, this vertex array to use the same underlying vertex content as
 * the specified other vertex array, with the content used by this array interleaved with the
 * content from the other vertex array. This can be repeated with other arrays to interleave
 * the content from several vertex arrays into one underlying memory buffer.
 *
 * This is a convenience method that invokes the interleaveWith:usingOffset: method, passing
 * the existing value of the elementOffset property of this vertex array for the elemOffset.
 *
 * Returns a pointer to the vertices array, offset by the elementOffset of this vertex array.
 * This is effectively a pointer to the first element in this vertex array, and can be used
 * as a starting point to iterate the array to populate it.
 *
 * This method assumes that the elementOffset property has already been set. The returned
 * pointer will not be accurate if the elementOffset property has not been set already.
 *
 * Because of this, when creating a new mesh containing several interleaved vertex arrays,
 * it is better to use the interleaveWith:usingOffset: method. This method is useful when
 * changing the vertex capacity of the mesh, and you want to retain the existing elementCount
 * property of each vertex array.
 */
-(GLvoid*) interleaveWith: (CC3VertexArray*) otherVtxArray;

/**
 * Allocates, reallocates, or deallocates underlying memory for the specified number of vertices,
 * taking into consideration the amount of memory required by each vertex. Specifically, the total
 * amount of memory allocated will be (allocatedVertexCapacity * self.vertexStride) bytes.
 *
 * Setting this property affects the value of the vertices and vertexCount properties. After
 * setting this property, the vertices property will point to the allocated memory, and the
 * vertexCount property will be set to the same value as this property. After setting this
 * property, if you will not be using all of the allocated vertices immediately, you should
 * set the value of the vertexCount property to the actual number of vertices in use.
 *
 * Use of this property is not required if the vertex content has already been loaded into memory
 * by a file loader, or defined by a static array. In that situation, you should set the vertices
 * and vertexCount properties directly, and avoid using this property.
 *
 * Since memory allocation is dependent on the vertex stride, before setting this property, ensure
 * that the vertexStride, or elementSize and elementType properties have been set appropriately.
 * If the underlying content is to be interleaved, set the value of the vertexStride property to the
 * appropriate value before setting this property. If the underlying content will NOT be interleaved,
 * the vertexStride property can be determined by the elementType and elementSize properties, and
 * you should set the correct values of those two properties before setting the value of this property.
 *
 * This property may be set repeatedly to manage the underlying mesh vertex content as a
 * dynamically-sized array, growing and shrinking the allocated memory as needed. When doing
 * so, keep in mind the vertices property can change as a result of any reallocation of memory.
 *
 * In addition, you can set this property to zero to safely deallocate all memory used by the
 * vertex content of this array. After setting this property to zero, the value of the vertices
 * property will be a NULL pointer, and the value of the vertexCount property will be zero.
 *
 * When setting the value of this property to a new non-zero value, all current vertex content,
 * up to the lesser of the new and old values of this property, will be preserved. However,
 * keep in mind that, if the memory allocation has increased, that vertex content may have been
 * moved to a new location, resulting in a change to the vertices property.
 *
 * If the value of this property is increased (including from zero on the first assignement),
 * vertex content for those vertices beyond the old value of this property will be undefined,
 * and must be populated by the application before attempting to draw that vertex content.
 *
 * If you are not ready to populate the newly allocated vertex content yet, after setting the value
 * of this property, you can set the value of the vertexCount property to a value less than the
 * value of this property (including to zero) to stop such undefined vertex content from being drawn.
 *
 * When interleaving content, this method should be invoked on only one of the CC3VertexArray
 * instances that are sharing the underlying content (typically the CC3VertexLocations instance).
 * After allocating on one CC3VertexArray instances, set the vertices property of the other
 * instances to be equal to the vertices property of the CC3VertexArray instance on which this
 * method was invoked (or just simply to the pointer returned by this method).
 */
@property(nonatomic, assign) GLuint allocatedVertexCapacity;


#pragma mark Binding GL artifacts

/** @deprecated This functionality has been replaced by the allocatedVertexCapacity property. */
-(GLvoid*) allocateElements: (GLuint) vtxCount DEPRECATED_ATTRIBUTE;

/** @deprecated This functionality has been replaced by the allocatedVertexCapacity property. */
-(GLvoid*) reallocateElements: (GLuint) vtxCount DEPRECATED_ATTRIBUTE;

/** @deprecated This functionality has been replaced by the allocatedVertexCapacity property. */
-(void) deallocateElements DEPRECATED_ATTRIBUTE;

/** @deprecated This functionality is now managed by the mesh. */
-(BOOL) ensureCapacity: (GLuint) vtxCount DEPRECATED_ATTRIBUTE;

/** @deprecated This property is no longer used, and is fixed at 1.25. */
@property(nonatomic, assign) GLfloat capacityExpansionFactor DEPRECATED_ATTRIBUTE;

/**
 * Indicates whether this instance should allow the vertex content to be copied to a vertex
 * buffer object within the GL engine when the createGLBuffer method is invoked.
 *
 * The initial value of this property is YES. In most cases, this is appropriate, but for
 * specific meshes, it might make sense to retain content in main memory and submit it to the
 * GL engine during each frame rendering.
 *
 * As an alternative to setting this property to NO, consider leaving it as YES, and making
 * use of the updateGLBuffer and updateGLBufferStartingAt:forLength: to dynamically update
 * the content in the GL engine buffer. Doing so permits the content to be copied to the GL engine
 * only when it has changed, and permits copying only the range of content that has changed,
 * both of which offer performance improvements over submitting all of the vertex content on
 * each frame render.
 */
@property(nonatomic, assign) BOOL shouldAllowVertexBuffering;

/** 
 * If the shouldAllowVertexBuffering property is set to YES, creates a vertex buffer
 * object (VBO) within the GL engine, copies the content referenced by the vertices into
 * the GL engine  (which may make use of VRAM), and sets the value of the bufferID
 * property to that of the new GL buffer.
 *
 * If memory for the vertices was allocated via the allocatedVertexCapacity property,
 * the GL VBO size is set to the same as the amount allocated by this instance. If
 * memory was allocated externally, the GL VBO size is set to the value of vertexCount.
 * 
 * Calling this method is optional. Using GL engine buffers is more efficient than passing
 * arrays on each GL draw call, but is optional. If you choose not to call this method,
 * this instance will pass the mesh content properties to the GL engine on each draw call.
 *
 * If the GL engine cannot allocate space for any of the buffers, this instance will
 * revert to passing the array content for any unallocated buffer on each draw call.
 *
 * When using interleaved content, this method should be invoked on only one of the 
 * CC3VertexArrays that share the content. The bufferID property of that instance should
 * then be copied to the other vertex arrays.
 *
 * Consider using the createGLBuffers of the mesh class instead of this method, which
 * automatically handles the buffering all vertex arrays used by the mesh, and correctly
 * coordinates buffering interleaved content.
 *
 * It is safe to invoke this method more than once, but subsequent invocations will do nothing.
 *
 * This method is invoked automatically by the createGLBuffers method of the mesh class, which
 * also coordinates the invocations across multiple CC3VertexArray instances when interleaved
 * content is shared between them, along with the subsequent copying of the bufferID's.
 */
-(void) createGLBuffer;

/**
 * Deletes the GL engine buffers created with createGLBuffer.
 *
 * After calling this method, if they have not been released by createGLBuffer,
 * the vertex content will be passed to the GL engine on each subsequent draw operation.
 * It is safe to call this method even if GL buffers have not been created.
 * 
 * This method may be invoked at any time to free up GL memory, but only if this vertex
 * array will not be used again, or if the content was not released by releaseRedundantContent.
 * This would be the case if the allocatedVertexCapacity property was not set.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deleteGLBuffer;

/**
 * Updates the GL engine buffer with the element content contained in this array,
 * starting at the vertex at the specified offsetIndex, and extending for
 * the specified number of vertices.
 */
-(void) updateGLBufferStartingAt: (GLuint) offsetIndex forLength: (GLuint) vertexCount;

/** Updates the GL engine buffer with all of the element content contained in this array. */
-(void) updateGLBuffer;

/**
 * Returns whether the underlying vertex content has been loaded into a GL engine vertex
 * buffer object. Vertex buffer objects are engaged via the createGLBuffer method.
 */
@property(nonatomic, readonly) BOOL isUsingGLBuffer;

/**
 * Indicates whether this instance should release the content held in the elments array
 * when the releaseRedundantContent method is invoked.
 *
 * The initial value of this property is YES. In most cases, this is appropriate,
 * but in some circumstances it might make sense to retain some content (usually the
 * vertex locations) in main memory for potantial use in collision detection, etc.
 */
@property(nonatomic, assign) BOOL shouldReleaseRedundantContent;

/** @deprecated Renamed to shouldReleaseRedundantContent. */
@property(nonatomic, assign) BOOL shouldReleaseRedundantData DEPRECATED_ATTRIBUTE;

/**
 * Once the vertices content has been buffered into a GL vertex buffer object (VBO)
 * within the GL engine, via the createGLBuffer method, this method can be used
 * to release the content in main memory that is now redundant.
 *
 * If the shouldReleaseRedundantContent property is set to NO, or if the vertices
 * content has not been successfully buffered to a VBO in the GL engine. this method
 * does nothing. It is safe to invokde this method even if createGLBuffer has not
 * been invoked, and even if VBO buffering was unsuccessful.
 *
 * Typically, this method is not invoked directly by the application. Instead, 
 * consider using the same method on a node assembly in order to release as much
 * memory as possible in one simply method invocation.
 *
 * Subclasses may extend this behaviour to remove content loaded, for example, from files,
 * but should ensure that content is only released if bufferId is valid (not zero),
 * and the shouldReleaseRedundantContent property is set to YES.
 */
-(void) releaseRedundantContent;

/** @deprecated Renamed to releaseRedundantContent. */
-(void) releaseRedundantData DEPRECATED_ATTRIBUTE;

/**
 * Binds the vertex content to the vertex attribute at the specified index in the GL engine.
 *
 * This is invoked automatically from the CC3Mesh containing this instance.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) bindContentToAttributeAt: (GLint) vaIdx withVisitor: (CC3NodeDrawingVisitor*) visitor;


#pragma mark Accessing vertices

/**
 * Returns a pointer to the element in the underlying content at the specified index.
 * The implementation takes into consideration the vertexStride and elementOffset
 * properties to locate the aspect of interest in this instance.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, or the index is beyond the vertexCount,
 * this method will raise an assertion exception.
 */
-(GLvoid*) addressOfElement: (GLuint) index;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the
 * specified source vertex index to memory starting at the specified destination vertex index.
 *
 * You can use this method to copy content from one area in the vertex array to another area.
 * 
 * This is a fast straight memory copy, and assumes that vertex content is consecutive and is
 * spaced as defined by the vertexStride property. If vertex content is interleaved, the content
 * in between consecutive elements of this vertex array will also be copied.
 */
-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the
 * specified source vertex index to memory starting at the specified destination address pointer.
 * 
 * You can use this method to copy content out of this vertex array to a memory location outside
 * this vertex array.
 * 
 * This is a fast straight memory copy, assumes that vertex content is consecutive and is spaced
 * as defined by the vertexStride property, and deposits the vertex content at the destination
 * address in exactly the same format as in this vertex array. If vertex content is interleaved,
 * the content in between consecutive elements of this vertex array will also be copied.
 */
-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx toAddress: (GLvoid*) dstPtr;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the
 * specified source address to memory starting at the specified destination vertex index.
 * 
 * You can use this method to copy content into this vertex array from a memory location outside
 * this vertex array.
 * 
 * This is a fast straight memory copy, assumes that vertex content is consecutive is spaced
 * as defined by the vertexStride property, and that the vertex content at the source address
 * is structured identically to the content in this vertex array. If vertex content is interleaved,
 * the content in between consecutive elements of this vertex array will also be copied.
 */
-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr to: (GLuint) dstIdx;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the
 * specified source address to memory starting at the specified destination address.
 * 
 * You can use this method to copy content between two memory location outside this vertex array.
 * 
 * This is a fast straight memory copy, assumes that vertex content is consecutive and is spaced as
 * defined by the vertexStride property, and that the vertex content at both the source and destination
 * addresses are structured identically to the content of this vertex array. If vertex content is
 * interleaved, the content in between consecutive elements of this vertex array will also be copied.
 */
-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr toAddress: (GLvoid*) dstPtr;

/**
 * Returns a string containing a description of the elements of this vertex array, with
 * the contents of each element output on a different line. The number of values output
 * on each line is dictated by the elementSize property.
 *
 * The output contains the all of the vertices in this vertex array. The total number
 * of values output will therefore be (elementSize * vertexCount).
 */
-(NSString*) describeVertices;

/**
 * Returns a string containing a description of the specified elements, with the contents
 * of each element output on a different line. The number of values output on each line
 * is dictated by the elementSize property.
 *
 * The output contains the number of elements specified, starting at the first element in
 * this vertex array, and is limited to the number of vertices in this array. The total
 * number of values output will therefore be (elementSize * MIN(vtxCount, vertexCount)).
 */
-(NSString*) describeVertices: (GLuint) vtxCount;

/**
 * Returns a string containing a description of the specified elements, with the contents
 * of each element output on a different line. The number of values output on each line
 * is dictated by the elementSize property. 
 *
 * The output contains the number of vertices specified, starting at the element at the
 * specified index, and is limited to the number of vertices in this array. The total number
 * of values output will therefore be (elementSize * MIN(vtxCount, vertexCount - startElem)).
 */
-(NSString*) describeVertices: (GLuint) vtxCount startingAt: (GLuint) startElem;

/** @deprecated Renamed to describeVertices. */
-(NSString*) describeElements DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to describeVertices:. */
-(NSString*) describeElements: (GLuint) vtxCount DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to describeVertices:startingAt:. */
-(NSString*) describeElements: (GLuint) vtxCount startingAt: (GLuint) startElem DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3DrawableVertexArray

/**
 * This abstract subclass of  CC3VertexArray adds the functionality to draw the vertex
 * content to the display through the GL engine.
 *
 * The underlying content is drawn by invoking the drawWithVisitor: method, and can be drawn
 * in a single GL call for all vertices, or the vertices can be arranged in strips, and
 * the strips drawn serially.
 *
 * You define vertex strips using the stripCount and stripLengths properties, or using
 * the allocateStripLengths: method to set both properties at once.
 * 
 * Using vertex strips performs more GL calls, and will be less efficient, but in some
 * applications, might assist in the organization of mesh vertex content.
 *
 * Alternately, a subset of the vertices may be drawn by invoking the
 * drawFrom:forCount:withVisitor: method instead of the drawWithVisitor: method.
 */
@interface CC3DrawableVertexArray : CC3VertexArray {
	GLenum _drawingMode;
	GLuint _stripCount;
	GLuint* _stripLengths;
	BOOL _stripLengthsAreRetained : 1;
}

/**
 * The drawing mode indicating how the vertices are connected (points, lines, triangles...).
 * This must be set with a valid GL drawing mode enumeration.
 *
 * The default value is GL_TRIANGLES.
 */
@property(nonatomic, assign) GLenum drawingMode;

/**
 * The underlying content can be drawn in strips, using multiple GL calls, rather than
 * a single call. This property indicates the number of strips to draw. A value of
 * zero indicates that vertex drawing should be done in a single GL call.
 */
@property(nonatomic, assign) GLuint stripCount;

/**
 * An array of values, each indicating the number of vertices to draw in the corresponding
 * strip. The stripCount property indicates the number of items in this array. 
 * If drawing is not performed in strips (stripCount is zero), this property will be NULL.
 *
 * An easy way to create a suitable array for this property, and set the associated
 * stripCount property at the same time, is to invoke the allocateStripLengths: method.
 */
@property(nonatomic, assign) GLuint* stripLengths;

/** @deprecated Renamed to firstVertex on CC3VertexLocations. */
@property(nonatomic, readonly) GLuint firstElement DEPRECATED_ATTRIBUTE;

/**
 * Draws the vertices, either in strips, or in a single call, depending on the value
 * of the stripCount property.
 *
 * This method is invoked automatically from the draw method of CC3Mesh.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Draws the specified number of vertices, starting at the specified vertex index,
 * in a single GL draw call.
 *
 * This method can be used to draw a subset of thevertices. This can be used when this array
 * holds content for a number of meshes, or when content is being sectioned for palette matrices.
 *
 * This abstract implementation collects drawing performance statistics if the visitor
 * is configured to do so. Subclasses will override to perform appropriate drawing
 * activity, but should also invoke this superclass implementation to perform the
 * collection of performance content.
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
-(void) allocateStripLengths: (GLuint) sCount;

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
@property(nonatomic, readonly) GLuint faceCount;

/**
 * Returns the number of faces to be drawn from the specified number
 * of vertex indices, based on the drawingMode of this array.
 */ 
-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc;

/**
 * Returns the number of vertex indices required to draw the specified
 * number of faces, based on the drawingMode of this array.
 */ 
-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc;

/** @deprecated Renamed to faceCountFromVertexIndexCount:. */
-(GLuint) faceCountFromVertexCount: (GLuint) vc DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexIndexCountFromFaceCount:. */
-(GLuint) vertexCountFromFaceCount: (GLuint) fc DEPRECATED_ATTRIBUTE;


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
-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex;

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
	GLuint _firstVertex;
	CC3Box _boundingBox;
	CC3Vector _centerOfGeometry;
	GLfloat _radius;
	BOOL _boundaryIsDirty : 1;
	BOOL _radiusIsDirty : 1;
}

/**
 * An index reference to the first element that will be drawn.
 *
 * Typically, all vertices are to be drawn, and this property will be zero. In some applications,
 * large sets of underlying content may be used for the vertex arrays of more than one mesh.
 * In such a case, it may be desirable to start drawing from an vertex that is not the first
 * vertex of the array. This property can be set to indicate at which element index to start drawing.
 * If drawing is being performed in strips, this will be the index of the start of the first strip to be drawn.
 *
 * The initial value is zero.
 */
@property(nonatomic, assign) GLuint firstVertex;

/** @deprecated Renamed to firstVertex. */
@property(nonatomic, assign) GLuint firstElement DEPRECATED_ATTRIBUTE;

/** Returns the axially-aligned bounding box of this mesh. */
@property(nonatomic, readonly) CC3Box boundingBox;

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
 * Returns the location element at the specified index in the underlying vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * This implementation takes into consideration the elementSize property. If the value
 * of the elementSize property is 2, the returned vector will contain zero in the Z component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector) locationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the underlying vertex content to
 * the specified location value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * This implementation takes into consideration the elementSize property. If the value
 * of the elementSize property is 2, the Z component of the specified vector will be
 * ignored. If the value of the elementSize property is 4, the specified vector will
 * be converted to a 4D vector, with the W component set to one, before storing.
 * 
 * If the new vertex location changes the bounding box of this instance, and this
 * instance is being used by any mesh nodes, be sure to invoke the markBoundingVolumeDirty
 * method on all mesh nodes that use this vertex array, to ensure that the boundingVolume
 * encompasses the new vertex location.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setLocation: (CC3Vector) aLocation at: (GLuint) index;

/**
 * Returns the location element at the specified index in the underlying vertex content,
 * as a four-dimensional location in the 4D homogeneous coordinate space.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * This implementation takes into consideration the elementSize property. If the
 * value of the elementSize property is 3, the returned vector will contain one
 * in the W component. If the value of the elementSize property is 2, the returned
 * vector will contain zero in the Z component and one in the W component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector4) homogeneousLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the underlying vertex content to
 * the specified four-dimensional location in the 4D homogeneous coordinate space.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * This implementation takes into consideration the elementSize property. If the value
 * of the elementSize property is 3, the W component of the specified vector will be
 * ignored. If the value of the elementSize property is 2, both the W and Z components
 * of the specified vector will be ignored.
 * 
 * If the new vertex location changes the bounding box of this instance, and this
 * instance is being used by any mesh nodes, be sure to invoke the markBoundingVolumeDirty
 * method on all mesh nodes that use this vertex array, to ensure that the boundingVolume
 * encompasses the new vertex location.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index;

/**
 * Changes the mesh vertices so that the origin of the mesh is at the specified location.
 *
 * The origin of the mesh is the location (0,0,0) in the local coordinate system, and is the
 * location around which all transforms are performed.
 *
 * This method can be used to adjust the mesh structure to make it easier to apply transformations,
 * by moving the origin of the transformations to a more convenient location in the mesh.
 *
 * This method changes the location component of every vertex in the mesh. This can be quite costly,
 * and should only be performed once, to adjust a mesh so that it is easier to manipulate. As an
 * alternate, you should consider changing the origin of the mesh at development time using a 3D editor.
 * 
 * Do not use this method to move your model around. Instead, use the transform properties (location,
 * rotation and scale) of the CC3MeshNode that contains this mesh, and let the GL engine do the heavy
 * lifting of transforming the mesh vertices.
 * 
 * If this mesh is being used by any mesh nodes, be sure to invoke the markBoundingVolumeDirty method
 * on all nodes that use this mesh, to ensure that the boundingVolume is recalculated using the new
 * location values. Invoking this method on the CC3MeshNode instead will automatically invoke the
 * markBoundingVolumeDirty method.
 *
 * This method ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) moveMeshOriginTo: (CC3Vector) aLocation;

/**
 * Changes the mesh vertices so that the origin of the mesh is at the center of geometry of the mesh.
 *
 * The origin of the mesh is the location (0,0,0) in the local coordinate system, and is the
 * location around which all transforms are performed.
 *
 * This method can be used to adjust the mesh structure to make it easier to apply transformations,
 * by moving the origin of the transformations to the center of the mesh.
 *
 * This method changes the location component of every vertex in the mesh. This can be quite costly,
 * and should only be performed once, to adjust a mesh so that it is easier to manipulate. As an
 * alternate, you should consider changing the origin of the mesh at development time using a 3D editor.
 * 
 * Do not use this method to move your model around. Instead, use the transform properties (location,
 * rotation and scale) of the CC3MeshNode that contains this mesh, and let the GL engine do the heavy
 * lifting of transforming the mesh vertices.
 * 
 * If this mesh is being used by any mesh nodes, be sure to invoke the markBoundingVolumeDirty method
 * on all nodes that use this mesh, to ensure that the boundingVolume is recalculated using the new
 * location values. Invoking this method on the CC3MeshNode instead will automatically invoke the
 * markBoundingVolumeDirty method.
 *
 * This method ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) moveMeshOriginToCenterOfGeometry;

/** @deprecated Renamed to moveMeshOriginTo:. */
-(void) movePivotTo: (CC3Vector) aLocation DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to moveMeshOriginToCenterOfGeometry. */
-(void) movePivotToCenterOfGeometry DEPRECATED_ATTRIBUTE;

/**
 * Returns the face from the mesh at the specified index.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 *
 * The returned face structure contains only the locations of the vertices. If the vertex
 * locations are interleaved with other vertex content, such as color or texture coordinates,
 * or other padding, that content will not appear in the returned face structure.
 *
 * This method takes into consideration the drawingMode of this vertex array,
 * and any padding (stride) between the vertex indices.
 *
 * This method is only meaningful if the vertices are drawn directly from this vertex
 * array, without using vertex indexing. If vertex indexing is in use (the mesh contains
 * an instance of CC3VertexIndices) the order of the vertices in this array will likely
 * not be accurate.
 */
-(CC3Face) faceAt: (GLuint) faceIndex;

/**
 * Returns the mesh face that is made up of the three vertices at the three indices
 * within the specified face indices structure. Because indexing is used, the three
 * vertices that make up the face may not be contiguous within this array.
 *
 * The returned face structure contains only the locations of the vertices. If the vertex
 * locations are interleaved with other vertex content, such as color or texture coordinates,
 * or other padding, that content will not appear in the returned face structure.
 */
-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices;

@end


#pragma mark -
#pragma mark CC3VertexNormals

/** A CC3VertexArray that manages the normal aspect of an array of vertices. */
@interface CC3VertexNormals : CC3VertexArray

/**
 * Returns the normal element at the specified index in the underlying vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector) normalAt: (GLuint) index;

/**
 * Sets the normal element at the specified index in the underlying vertex content to
 * the specified normal value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setNormal: (CC3Vector) aNormal at: (GLuint) index;

/** Reverses the direction of all of the normals in this mesh. */
-(void) flipNormals;

@end


#pragma mark -
#pragma mark CC3VertexTangents

/** A CC3VertexArray that manages the tangent or bitangent aspect of an array of vertices. */
@interface CC3VertexTangents : CC3VertexArray

/**
 * Returns the tangent element at the specified index in the underlying vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector) tangentAt: (GLuint) index;

/**
 * Sets the tangent element at the specified index in the underlying vertex content to
 * the specified tangent value.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setTangent: (CC3Vector) aTangent at: (GLuint) index;

@end


#pragma mark -
#pragma mark CC3VertexColors

/** A CC3VertexArray that manages the per-vertex color aspect of an array of vertices. */
@interface CC3VertexColors : CC3VertexArray

/**
 * Returns the color element at the specified index in the underlying vertex content.
 *
 * If the underlying vertex content is not of type GLfloat, the color components are
 * converted to GLfloat before the color value is returned.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(ccColor4F) color4FAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the underlying vertex content to
 * the specified color value.
 *
 * If the underlying vertex content is not of type GLfloat, the color components are
 * converted to the appropriate type (typically GLubyte) before being set in the
 * vertex content.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setColor4F: (ccColor4F) aColor at: (GLuint) index;

/**
 * Returns the color element at the specified index in the underlying vertex content.
 *
 * If the underlying vertex content is not of type GLubyte, the color components are
 * converted to GLubyte before the color value is returned.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(ccColor4B) color4BAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the underlying vertex content to
 * the specified color value.
 *
 * If the underlying vertex content is not of type GLubyte, the color components are
 * converted to the appropriate type (typically GLfloat) before being set in the
 * vertex content.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setColor4B: (ccColor4B) aColor at: (GLuint) index;


#pragma mark CCRGBAProtocol and CCBlendProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * Querying this property returns the RGB components of the first vertex.
 *
 * When setting this property, the RGB values of each vertex are set to the specified color,
 * without affecting the opacity value of each individual vertex. If the content of this vertex
 * array has been copied to a GL buffer, that buffer is automatically updated.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * Querying this property returns the alpha component of the first vertex.
 *
 * When setting this property, the alpha values of each vertex is set to the specified
 * opacity, without affecting the RGB color value of each individual vertex. If the content
 * of this vertex array has been copied to a GL buffer, that buffer is automatically updated. 
 */
@property(nonatomic, assign) GLubyte opacity;

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
 * invoked to flip the mesh content for a texture, either horizontally or vertically.
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
	CGSize _mapSize;
	CGRect _textureRectangle;
	BOOL _expectsVerticallyFlippedTextures : 1;
}

/**
 * Returns the texture coordinate element at the specified index in the underlying vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(ccTex2F) texCoord2FAt: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the underlying vertex
 * content to the specified texture coordinate value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index;

/**
 * Indicates whether the texture coordinates of this mesh expects that the texture
 * was flipped upside-down during texture loading.
 * 
 * The vertical axis of the coordinate system of OpenGL is inverted relative to the
 * CoreGraphics view coordinate system. As a result, some texture file formats may be
 * loaded upside down. Most common file formats, including JPG, PNG & PVR are loaded
 * right-way up, but using proprietary texture formats developed for other platforms
 * may result in textures being loaded upside-down.
 *
 * The value of this property is used in combination with the value of the 
 * isUpsideDown property of a texture to determine whether the texture
 * will be oriented correctly when displayed using these texture coordinates.
 *
 * The alignWithTexture: method compares the value of this property with the
 * isUpsideDown property of the texture to automatically determine
 * whether these texture coordinates need to be flipped vertically in order
 * to display the texure correctly, and will do so if needed. As part
 * of that inversion, the value of this property will also be flipped, to
 * indicate that the texture coordinates are now aligned differently.
 *
 * The value of this property does not affect the behaviour of, nor
 * is affected by, the flipVertically , alignWithInvertedTexture:,
 * alignWithTextureCoverage:, or alignWithInvertedTextureCoverage: methods.
 * 
 * The initial value of this property is determined by the value of the class-side
 * defaultExpectsVerticallyFlippedTextures property at the time an instance of
 * this class is created and initialized. If you want all meshes to behave the same
 * way, with respect to this property, set the value of that class-side property.
 * 
 * The value of this property is set when the underlying mesh texture coordinates are
 * built or loaded. See the same property on the CC3NodesResource class to understand
 * how this property is set during mesh resource loading.
 */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures;

/**
 * This class-side property determines the initial value of the
 * expectsVerticallyFlippedTextures property when an instance
 * of this class is created and initialized.
 *
 * See the notes for that property for more information.
 *
 * The initial value of this class-side property is NO.
 */
+(BOOL) defaultExpectsVerticallyFlippedTextures;

/**
 * This class-side property determines the initial value of the
 * expectsVerticallyFlippedTextures property when an instance
 * of this class are created and initialized.
 *
 * See the notes for that property for more information.
 *
 * The initial value of this class-side property is NO.
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
 * For the sake of efficiency, if the specified texCoverage is the same as the
 * value submitted in the previous invocation (or is equal to (1, 1) on the
 * first invocation), this method does nothing, to avoid updating the texture
 * coordinates when no change has occurred.
 *
 * For subsequent invocations, if the specified texCoverage is the same as the
 * value submitted in the previous invocation, this method does nothing, to
 * avoid updating all the texture coordinates to the value they currently have.
 *
 * Care should be taken when using this method, as it changes the actual vertex content.
 * This may cause mapping conflicts if the same vertex content is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithTextureCoverage: (CGSize) texCoverage;

/** @deprecated Renamed to alignWithTextureCoverage:. */
-(void) alignWithTextureMapSize: (CGSize) texCoverage DEPRECATED_ATTRIBUTE;

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
 * result, unlike the alignWithTextureCoverage: method, this method updates all the
 * texture coordinates on each invocation, regardless of whether the specified
 * texCoverage is the same as on the previous invocation.
 *
 * Care should be taken when using this method, as it changes the actual vertex content.
 * This may cause mapping conflicts if the same vertex content is shared by other
 * CC3MeshNodes that use different textures.
 */
-(void) alignWithInvertedTextureCoverage: (CGSize) texCoverage;

/** @deprecated Renamed to alignWithInvertedTextureCoverage:. */
-(void) alignWithInvertedTextureMapSize: (CGSize) texCoverage DEPRECATED_ATTRIBUTE;

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
 * than the value of the isUpsideDown property of the specified texture, the
 * texture coordinates are not oriented vertically for the texture. To align them,
 * this method delegates to the alignWithInvertedTextureCoverage:, passing the mapSize
 * of the specified texture, to both align the texture coordinates to the usable size
 * of the texture, and to flip the texture coordinates to align with the texture.
 *
 * If the value of the expectsVerticallyFlippedTextures property is the same
 * as the value of the isUpsideDown property of the specified texture, the
 * texture coordinates are correctly oriented vertically for the texture. This
 * method delegates to the alignWithTextureCoverage:, passing the mapSize of the
 * specified texture, to align the texture coordinates to the usable size of
 * the texture, but does not flip the texture coordinates.
 *
 * To avoid updating the texture coordinates when no change has occurred, if the
 * coordinates do not need to be flipped vertically, and the specified texture has
 * the same usable area as the texture used on the previous invocation (or has a
 * full usable area on the first invocation), this method does nothing.
 *
 * Care should be taken when using this method, as it changes the actual vertex content.
 * This may cause mapping conflicts if the same vertex content is shared by other
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
 * coordinates on each invocation, regardless of whether the specified texCoverage
 * is the same as on the previous invocation.
 *
 * Care should be taken when using this method, as it changes the actual vertex content.
 * This may cause mapping conflicts if the same vertex content is shared by other
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
 * This property facilitates the use of sprite-sheets, where the mesh is covered by a small
 * fraction of a larger texture. This technique has many uses, including animating a texture
 * onto a mesh, where each section of the full texture is really a different frame of a
 * texture animation, or simply loading one larger texture and using parts of it to texture
 * many different meshes.
 *
 * The dimensions of this rectangle are taken as fractional portions of the full area of the
 * texture. Therefore, a rectangle with zero origin, and unit size ((0.0, 0.0), (1.0, 1.0))
 * indicates that the mesh should be covered with the complete texture.
 * 
 * A rectangle of smaller size, and/or a non-zero origin, indicates that the mesh should be
 * covered by a fractional area of the texture. For example, a rectangular value for this
 * property with origin at (0.5, 0.5), and size of (0.5, 0.5) indicates that only the top-right
 * quarter of the texture will be used to cover this mesh.
 *
 * The bounds of the texture rectangle must fit within a unit rectangle. Both the bottom-left
 * and top-right corners must lie between zero and one in both the X and Y directions.
 *
 * The dimensions of the rectangle in this property are independent of the size specified in
 * the  alignWithTextureCoverage: and alignWithInvertedTextureCoverage: methods. A unit rectangle
 * value for this property will automatically take into consideration the adjustment made to
 * the mesh by those methods, and will display only the part of the texture defined by them.
 * Rectangular values for this property that are smaller than the unit rectangle will be
 * relative to the displayable area defined by alignWithTextureCoverage: and
 * alignWithInvertedTextureCoverage:.
 *
 * As an example, if the alignWithTextureCoverage: method was used to limit the mesh to using
 * only 80% of the texture (perhaps when using a non-POT texture), and this property was set
 * to a rectangle with origin at (0.5, 0.0) and size (0.5, 0.5), the mesh will be covered by
 * the bottom-right quarter of the usable 80% of the overall texture.
 *
 * The initial value of this property is a rectangle with origin at zero, and unit size,
 * indicating that the mesh will be covered with the complete usable area of the texture.
 */
@property(nonatomic, assign) CGRect textureRectangle;

/**
 * Returns the effective texture rectangle, taking into consideration the usable area of the
 * texture and whether this vertex array is configured for an inverted texture.
 *
 * The value returned is the value of the textureRectangle property, modulated by the mapSize
 * property of the texture. If the expectsVerticallyFlippedTextures property is YES, the
 * height of the returned rectangle will be negative.
 */
@property(nonatomic, readonly) CGRect effectiveTextureRectangle;

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
 * alignWithTextureCoverage: and alignWithInvertedTextureCoverage: methods, or derived
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
 * actual vertex content, it manages indexes that reference the vertices of the other vertex
 * arrays. The bufferTarget property is GL_ELEMENT_ARRAY_BUFFER, the elementSize
 * property is 1, and the elementType is either GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE
 *
 * Because an index datum does not describe an aspect of a particular vertex, but rather
 * points to a vertex, index content cannot be interleaved with the vertex content. As such,
 * the content underlying a CC3VertexIndices is never interleaved and shared with the content
 * underlying the other vertex arrays in a mesh.
 */
@interface CC3VertexIndices : CC3DrawableVertexArray

/** @deprecated Use allocatedVertexCapacity property instead. */
-(GLuint*) allocateTriangles: (GLuint) triangleCount;

/**
 * Returns the index element at the specified index in the underlying vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLuint) indexAt: (GLuint) index;

/**
 * Sets the index element at the specified index in the underlying vertex content, to
 * the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setIndex: (GLuint) vertexIndex at: (GLuint) index;

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
 * The indices in the returned face are of type GLuint, regardless of whether the
 * elementType property is GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE.
 */
-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex;

/**
 * Convenience method to populate this index array from the specified run-length
 * encoded array.
 *
 * Run-length encoded arrays are used to compactly store a set of variable-length
 * sub-arrays of indexes, where the first element of each sub-array indicates the
 * number of content elements contained in that sub-array.
 *
 * For example, if the first element of the array (element zero) contains the value 5,
 * then the next 5 elements of the array contain the first 5 content elements of the first
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
-(void) populateFromRunLengthArray: (GLushort*) runLenArray ofLength: (GLuint) rlaLen;


#pragma mark Accessing vertices

/**
 * Copies vertex indices for the specified number of vertices from memory starting at the specified
 * source vertex index to memory starting at the specified destination vertex index, and offsets
 * each value by the specified offset amount. The value at the destination vertex will be that of
 * the source vertex, plus the specified offset.
 *
 * You can use this method to copy content from one area in the vertex array to another area, while
 * adjusting for movement of the underlying vertex content pointed to by these vertex indices.
 */
-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx offsettingBy: (GLint) offset;

/**
 * Copies vertex indices for the specified number of vertices from memory starting at the specified
 * source vertex index to memory starting at the specified destination address pointer, and offsets
 * each value by the specified offset amount. The value at the destination vertex will be that of
 * the source vertex, plus the specified offset.
 *
 * You can use this method to copy content out of this vertex array to a memory location outside
 * this vertex array, while adjusting for movement of the underlying vertex content pointed to by
 * these vertex indices.
 *
 * This is a fast copy that assumes that the vertex content at the destination is of the same type
 * (GL_UNSIGNED_BYTE or GL_UNSIGNED_SHORT) as the vertex content in this vertex array.
 */
-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx toAddress: (GLvoid*) dstPtr offsettingBy: (GLint) offset;

/**
 * Copies vertex indices for the specified number of vertices from memory starting at the specified
 * source address pointer to memory starting at the specified destination vertex index, and offsets
 * each value by the specified offset amount. The value at the destination vertex will be that of
 * the source vertex, plus the specified offset.
 *
 * You can use this method to copy content into this vertex array from a memory location outside
 * this vertex array, while adjusting for movement of the underlying vertex content pointed to by
 * these vertex indices.
 *
 * This is a fast copy that assumes that the vertex content at the source is of the same type
 * (GL_UNSIGNED_BYTE or GL_UNSIGNED_SHORT) as the vertex content in this vertex array.
 */
-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr to: (GLuint) dstIdx offsettingBy: (GLint) offset;

/**
 * Copies vertex content for the specified number of vertices from memory starting at the
 * specified source address to memory starting at the specified destination address.
 * 
 * You can use this method to copy content between two memory location outside this vertex array.
 * 
 * This is a fast straight memory copy, assumes that vertex content is consecutive and is spaced as
 * defined by the vertexStride property, and that the vertex content at both the source and destination
 * addresses are structured identically to the content of this vertex array. If vertex content is
 * interleaved, the content in between consecutive elements of this vertex array will also be copied.
 */
/**
 * Copies vertex indices for the specified number of vertices from memory starting at the specified
 * source address pointer to memory starting at the specified destination address pointer, and offsets
 * each value by the specified offset amount. The value at the destination vertex will be that of the
 * source vertex, plus the specified offset.
 *
 * You can use this method to copy content between two memory location outside this vertex array,
 * while adjusting for movement of the underlying vertex content pointed to by these vertex indices.
 *
 * This is a fast copy that assumes that the vertex content at the source and destination is of the
 * same type (GL_UNSIGNED_BYTE or GL_UNSIGNED_SHORT) as the vertex content in this vertex array.
 */
-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr toAddress: (GLvoid*) dstPtr offsettingBy: (GLint) offset;

@end


#pragma mark -
#pragma mark CC3VertexPointSizes

/** A CC3VertexArray that manages the point sizes aspect of an array of point sprite vertices. */
@interface CC3VertexPointSizes : CC3VertexArray

/**
 * Returns the point size element at the specified index in the underlying vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLfloat) pointSizeAt: (GLuint) index;

/**
 * Sets the point size element at the specified index in the underlying vertex content,
 * to the specified location value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setPointSize: (GLfloat) aSize at: (GLuint) index;

@end


#pragma mark -
#pragma mark CC3VertexBoneWeights

/**
 * A CC3VertexArray that manages a collection of bone weights for each vertex. Each bone weight
 * indicates how much that particular bone influences the movement of the vertex for a mesh that
 * uses vertex skinning. Vertex skinning is the manipulation of a soft-body mesh under control
 * of a skeleton of bone nodes.
 *
 * For each vertex, the bone to which the weight should be applied is identified by the bone
 * index specified in the corresponding entry in the CC3VertexBoneIndices vertex array.
 *
 * This vertex array works together with an instace of a CC3VertexBoneIndices vertex array.
 * The elementSize property of the two vertex arrays must be equal, and under OpenGL ES 1.1,
 * must not be larger than the maximum number of available bone influences allowed by the 
 * platform, which can be retreived from CC3OpenGL.sharedGL.maxNumberOfBoneInfluencesPerVertex.
*/
@interface CC3VertexBoneWeights : CC3VertexArray

/**
 * Returns the weight value, for the specified influence index within the vertex, for the
 * vertex at the specified index within the underlying vertex content.
 *
 * The weight indicates how much a particular bone influences the movement of the particular 
 * vertex. Several weights are stored for each vertex, one for each bone that influences the 
 * movement of that vertex. The specified influenceIndex parameter must be between zero, and
 * the elementSize property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLfloat) weightForBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Sets the weight value, for the specified influence index within the vertex, for the
 * vertex at the specified index within the underlying vertex content.
 *
 * The weight indicates how much a particular bone influences the movement of the particular
 * vertex. Several weights are stored for each vertex, one for each bone that influences the
 * movement of that vertex. The specified influenceIndex parameter must be between zero, and
 * the elementSize property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setWeight: (GLfloat) weight forBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Returns the weights of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several weights are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the returned array is the same for each vertex
 * in this vertex array, as defined by the elementSize property.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct vertices.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLfloat*) boneWeightsAt: (GLuint) vtxIndex;

/**
 * Sets the weights of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several weights are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the specified input array must therefore be at 
 * least as large as the value of the elementSize property.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct vertices.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setBoneWeights: (GLfloat*) weights at: (GLuint) vtxIndex;


#pragma mark Deprecated methods

/** *@deprecated Renamed to weightForBoneInfluence:at:. */
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setWeight:forBoneInfluence:at:. */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to boneWeightsAt:. */
-(GLfloat*) weightsAt: (GLuint) vtxIndex DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setBoneWeights:at:. */
-(void) setWeights: (GLfloat*) weights at: (GLuint) vtxIndex DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3VertexBoneIndices

/**
 * A CC3VertexArray that manages a collection of bone indices for each vertex. Each bone index
 * indicates one of several bones that influence the location of the vertex for a mesh that
 * uses vertex skinning. Vertex skinning is the manipulation of a soft-body mesh under control
 * of a skeleton of bone nodes.
 *
 * For each vertex, the amount each bone should influence the vertex movement is identified 
 * by the weight specified in the corresponding entry in the CC3VertexBoneWeights vertex array.
 *
 * This vertex array works together with an instace of a CC3VertexBoneWeights vertex array.
 * The elementSize property of the two vertex arrays must be equal, and under OpenGL ES 1.1,
 * must not be larger than the maximum number of available bone influences allowed by the
 * platform, which can be retreived from CC3OpenGL.sharedGL.maxNumberOfBoneInfluencesPerVertex.
 */
@interface CC3VertexBoneIndices : CC3VertexArray

/**
 * Returns the index of the bone, that provides the influence at the specified influence index
 * within a vertex, for the vertex at the specified index within the underlying vertex content.
 *
 * The bone index indicates which bone provides the particular influence for the movement of
 * the particular vertex. Several bone indices are stored for each vertex, one for each bone
 * that influences the movement of that vertex. The specified influenceIndex parameter must
 * be between zero, and the elementSize property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLuint) boneIndexForBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Sets the index of the bone, that provides the influence at the specified influence index
 * within a vertex, for the vertex at the specified index within the underlying vertex content.
 *
 * The bone index indicates which bone provides the particular influence for the movement of
 * the particular vertex. Several bone indices are stored for each vertex, one for each bone
 * that influences the movement of that vertex. The specified influenceIndex parameter must
 * be between zero, and the elementSize property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setBoneIndex: (GLuint) boneIndex forBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Returns the indices of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several indices are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the returned array is the same for each vertex
 * in this vertex array, as defined by the elementSize property.
 *
 * The bone indices can be stored in this array as either type GLushort or type GLubyte.
 * The returned array will be of the type of index stored by this vertex array, and it is
 * up to the application to know which type will be returned, and cast the returned array
 * accordingly. The type can be determined by the elementType property of this array, 
 * which will return one of GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE, respectively.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct vertices.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLvoid*) boneIndicesAt: (GLuint) vtxIndex;

/**
 * Sets the indices of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several indices are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the specified input array must therefore be at
 * least as large as the value of the elementSize property.
 *
 * The bone indices can be stored in this array as either type GLushort or type GLubyte.
 * The specified array must be of the type of index stored by this vertex array, and it
 * is up to the application to know which type is required, and provide that type of
 * array accordingly. The type can be determined by the elementType property of this
 * array, which will return one of GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the elementType altogether, you can use the setBoneIndex:forBoneInfluence:at:
 * method, which sets the bone index values one at a time, and automatically converts the input 
 * type to the correct stored type.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct vertices.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setBoneIndices: (GLvoid*) boneIndices at: (GLuint) vtxIndex;


#pragma mark Deprecated methods

/** *@deprecated Renamed to boneIndexForBoneInfluence:at:. */
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setBoneIndex:forBoneInfluence:at:. */
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to boneIndicesAt:. */
-(GLvoid*) matrixIndicesAt: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setBoneIndices:at:. */
-(void) setMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index DEPRECATED_ATTRIBUTE;

@end


#pragma mark Deprecated vertex array classes

#define CC3VertexWeights CC3VertexBoneWeights
#define CC3VertexMatrixIndices CC3VertexBoneIndices

