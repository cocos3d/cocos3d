/*
 * CC3Mesh.h
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

#import "CC3Node.h"
#import "CC3Material.h"

@class CC3FaceArray;

/**
 * Variable type that holds a bitwise-OR of flags enumerating the types of vertex content
 * contained within a mesh. Valid components of this type include:
 *   - kCC3VertexContentLocation
 *   - kCC3VertexContentNormal
 *   - kCC3VertexContentColor
 *   - kCC3VertexContentTextureCoordinates
 *   - kCC3VertexContentPointSize
 *   - kCC3VertexContentWeights
 *   - kCC3VertexContentMatrixIndices
 *
 * In addition, an absence of any bitwise-OR components in a CC3VertexContent is represented by kCC3VertexContentNone.
 * 
 * All valid meshes must contain a kCC3VertexContentLocation, and a meshes will raise
 * an assertion if an attempt is made to set the vertex content without that component.
 *
 * Not all meshes can contain all of the vertex content itemized above. In general, all
 * meshes can contain the first four vertex content types. Specialized mesh subclasses
 * can contain other combinations as follows:
 *   - kCC3VertexContentPointSize is accepted by CC3PointParticleMesh in support of point particles.
 *   - kCC3VertexContentWeights and kCC3VertexContentMatrixIndices are accepted by CC3SkinMesh
 *     in support of skinned meshes controlled by bone-rigging.
 *
 * Meshes that do not support a particular vertex component type will silently ignore that
 * component in a CC3VertexContent.
 */
typedef enum {
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates
	 * an absence of any vertex content.
	 */
	kCC3VertexContentNone				= 0,
	
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates
	 * each vertex contains its own location information.
	 *
	 * Vertices must always include location info.
	 */
	kCC3VertexContentLocation			= 1 << 0,
	
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates
	 * each vertex contains its normal information.
	 *
	 * This component is required if and only if the mesh is to interact with light sources.
	 */
	kCC3VertexContentNormal				= 1 << 1,
	
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates
	 * each vertex contains its own color information.
	 *
	 * This component is required if and only if each vertex on the mesh will have its own color.
	 * If this component is not included, all vertices in the mesh will have the color specified
	 * by the coloring properties of the material of the mesh node.
	 */
	kCC3VertexContentColor				= 1 << 2,
	
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates
	 * each vertex maps to a position on a texture.
	 *
	 * This component is required if and only if the mesh is covered by a texture.
	 */
	kCC3VertexContentTextureCoordinates	= 1 << 3,
	
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates
	 * each vertex contains point size information.
	 *
	 * This component is required if and only if the vertices are part of a point pariticle mesh
	 * (eg. CC3PointParticleMesh), and each particle will have its own size. If this component
	 * is not included in a point particle mesh, all particles will have the same size.
	 */
	kCC3VertexContentPointSize			= 1 << 4,
	
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates each vertex contains
	 * a series of weights to allow the vertex to be manipulated by a series of weighted
	 * matrix transforms.
	 *
	 * This component is required if and only if the mesh is a vertex skinned mesh (eg. CC3SkinMesh).
	 * This component requires that the kCC3VertexContentMatrixIndices also be specified.
	 */
	kCC3VertexContentWeights				= 1 << 5,
	
	/**
	 * Bitwise-OR component of CC3VertexContent variables that indicates each vertex contains
	 * a series of matrix indices to allow the vertex to be manipulated by a series of weighted
	 * matrix transforms.
	 *
	 * This component is required if and only if the mesh is a vertex skinned mesh (eg. CC3SkinMesh).
	 * This component requires that the kCC3VertexContentMatrixIndices also be specified.
	 */
	kCC3VertexContentMatrixIndices		= 1 << 6
} CC3VertexContent;

/** Indicates that a face has no neighbour over a particular edge. */
#define kCC3FaceNoNeighbour  ((GLuint)~0)

/**
 * For each edge in a face, contains an index to the adjacent face,
 * or kCC3FaceNoNeighbour if the face has no neighbour over that edge.
 */
typedef struct {
	GLuint edges[3];		/**< Indices to the 3 neighbouring faces, in winding order. */
} CC3FaceNeighbours;

/** Returns a string description of the specified CC3FaceNeighbours struct. */
static inline NSString* NSStringFromCC3FaceNeighbours(CC3FaceNeighbours faceNeighbours) {
	return [NSString stringWithFormat: @"(%u, %u, %u)",
			faceNeighbours.edges[0], faceNeighbours.edges[1], faceNeighbours.edges[2]];
}

/**
 * Represents a point of intersection on the mesh.
 * 
 * This might represent an intersection point between this mesh and a ray or another mesh.
 */
typedef struct {
	GLuint faceIndex;		/**< The index of the face that was intersected. */
	CC3Face face;			/**< The face that was intersected. */
	CC3Plane facePlane;		/**< The plane equation of the face that was intersected. */
	CC3Vector location;		/**< The location of the intersection, in local cartesian coordinates. */
	GLfloat distance;		/**< The distance from the startLocation of the ray to the intersection location. */
	CC3BarycentricWeights barycentricLocation;	/**< The location of the intersection, in barycentric coordinates. */
	BOOL wasBackFace : 1;	/**< Indicates whether the intersected originated on the back side of the face. Useful for ray intersections. */
} CC3MeshIntersection;

/** Returns a string description of the specified CC3MeshIntersection struct. */
static inline NSString* NSStringFromCC3MeshIntersection(CC3MeshIntersection mi) {
	return [NSString stringWithFormat: @"(%@ face intersection at location %@ (%@ barycentric) in face %@ at index %i and plane %@ at ray distance %.3f)",
			(mi.wasBackFace ? @"Back" : @"Front"), NSStringFromCC3Vector(mi.location),
			NSStringFromCC3BarycentricWeights(mi.barycentricLocation), NSStringFromCC3Face(mi.face),
			mi.faceIndex, NSStringFromCC3Plane(mi.facePlane), mi.distance];
			
}

/**
 * Returns a pointer to the CC3MeshIntersection structure contained within the specified array of
 * CC3MeshIntersection structures that has the smallest distance component. The hitCount parameter
 * indicates the size of the meshHits array. Returns NULL if hitCount is zero.
 */
static inline CC3MeshIntersection* CC3NearestMeshIntersection(CC3MeshIntersection* meshHits, NSUInteger hitCount) {
	CC3MeshIntersection* nearestHit = NULL;
	for (NSUInteger hitIdx = 0; hitIdx < hitCount; hitIdx++) {
		if (!nearestHit || meshHits[hitIdx].distance < nearestHit->distance) nearestHit = &meshHits[hitIdx];
	}
	return nearestHit;
}

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
 * the application to organize the CC3MeshNodes within the CC3Scene so that nodes using the
 * same mesh are drawn together, before moving on to other mesh models. This strategy
 * can minimize the number of mesh switches in the GL engine, which improves performance. 
 *
 * CC3Mesh is an abstract class. Subclasses can be created for loading and managing
 * meshes from different sources and third-party libraries.
 */
@interface CC3Mesh : CC3Identifiable {
	CC3FaceArray* faces;
}

/** Returns whether this mesh contains data for vertex locations. */
@property(nonatomic, readonly) BOOL hasVertexLocations;

/** Returns whether this mesh contains data for vertex normals. */
@property(nonatomic, readonly) BOOL hasVertexNormals;

/** @deprecated Replaced by hasVertexNormals. */
@property(nonatomic, readonly) BOOL hasNormals DEPRECATED_ATTRIBUTE;

/** Returns whether this mesh contains data for vertex colors.  */
@property(nonatomic, readonly) BOOL hasVertexColors;

/**
 * Returns the symbolic content type of the vertex color, which indicates the range of values
 * stored for each vertex color.
 *
 * This property will return one of the values: GL_FLOAT, GL_UNSIGNED_BYTE, or GL_FIXED,
 * or will return GL_FALSE if this mesh does not support individual vertex colors.
 *
 * You can use the value returned by this property to select whether to access individual vertex
 * color content as bytes or floats, in order to retain accuracy and avoid unnecessary type conversions.
 */
@property(nonatomic, readonly) GLenum vertexColorType;

/** @deprecated Replaced by hasVertexColors. */
@property(nonatomic, readonly) BOOL hasColors DEPRECATED_ATTRIBUTE;

/** Returns whether this mesh contains data for vertex texture coordinates. */
@property(nonatomic, readonly) BOOL hasVertexTextureCoordinates;

/** Returns whether this mesh uses index vertices. */
@property(nonatomic, readonly) BOOL hasVertexIndices;

/** The center of geometry of this mesh. */
@property(nonatomic, readonly) CC3Vector centerOfGeometry;

/** Returns the the smallest axis-aligned-bounding-box (AABB) that surrounds the mesh. */
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


#pragma mark CCRGBAProtocol and CCBlendProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * Querying this property returns the RGB components of the first vertex in this mesh, or ccBLACK
 * if this mesh contains no per-vertex color content.
 *
 * When setting this property, if this mesh contains per-vertex color content, the RGB values of each
 * vertex in this mesh are set to the specified color, without affecting the opacity value of each
 * individual vertex. If the vertex color content of this mesh has been copied to a GL buffer, that
 * GL buffer is automatically updated.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * Querying this property returns the alpha component of the first vertex in this mesh, or zero
 * if this mesh contains no per-vertex color content.
 *
 * When setting this property, if this mesh contains per-vertex color content, the alpha values of
 * each vertex in this mesh is set to the specified opacity, without affecting the RGB color value
 * of each individual vertex. If the vertex color content of this mesh has been copied to a GL buffer,
 * that GL buffer is automatically updated.
 */
@property(nonatomic, assign) GLubyte opacity;


#pragma mark Vertex management

/**
 * For meshes that store their vertex content in arrays, indicates whether the
 * vertex data should be interleaved, or separated by aspect.
 * 
 * The initial value is NO, indicating that the vertex data is not interleaved.
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
 *   - kCC3VertexContentPointSize
 *   - kCC3VertexContentWeights
 *   - kCC3VertexContentMatrixIndices
 *
 * To indicate that this mesh should contain particular vertex content, construct a
 * bitwise-OR combination of one or more of the component types listed above, and set
 * this property to that combined value.
 *
 * This property is a convenience property. You can also construct the mesh by managing the
 * content directly. The effect that this property has on the internal structure of this mesh
 * depends on the subclass. In particular, see notes for this property on the CC3VertexArrayMesh,
 * CC3PointParticleMesh, and CC3SkinMesh subclasses for more details, and specific use cases
 * with those subclasses.
 *
 * Not all meshes can contain all of the vertex content itemized above. In general, all
 * meshes can contain the first four vertex content types. Specialized mesh subclasses
 * can contain other combinations as follows:
 *   - kCC3VertexContentPointSize is accepted by CC3PointParticleMesh in support of point particles.
 *   - kCC3VertexContentWeights and kCC3VertexContentMatrixIndices are accepted by CC3SkinMesh
 *     in support of skinned meshes controlled by bone-rigging.
 *
 * Meshes that do not support a particular vertex component type will silently ignore that
 * component of this property.
 * 
 * When reading this property, if no content has been defined for this mesh, this property
 * will return kCC3VertexContentNone.
 */
@property(nonatomic, assign) CC3VertexContent vertexContentTypes;


/** @deprecated Renamed to ensureVertexCapacity on CC3VertexArrayMesh subclass. */
-(BOOL) ensureCapacity: (GLuint) vtxCount DEPRECATED_ATTRIBUTE;

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
 * Returns whether the underlying vertex data has been loaded into GL engine vertex
 * buffer objects. Vertex buffer objects are engaged via the createGLBuffers method.
 */
@property(nonatomic, readonly) BOOL isUsingGLBuffers;

/**
 * Once the vertex data has been buffered into a GL vertex buffer object (VBO)
 * within the GL engine, via the createGLBuffer method, this method can be used
 * to release the data in main memory that is now redundant.
 *
 * Typically, this method is not invoked directly by the application. Instead, 
 * consider using the same method on a node assembly in order to release as much
 * memory as possible in one simply method invocation.
 */
-(void) releaseRedundantData;

/**
 * Convenience method to cause all vertex content data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * All vertex content, such as location, normal, color, texture coordinates, point size,
 * weights and matrix indices will be retained.
 * 
 * Invoking this method does NOT cause vertex index data to be retained. To retain vertex
 * index data, use the retainVertexIndices method.
 */
-(void) retainVertexContent;

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
 * Convenience method to cause all vertex content to be skipped when createGLBuffers is invoked.
 * The vertex content is not buffered to a a GL VBO, is retained in application memory, and is
 * submitted to the GL engine on each frame render.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexContent method.
 */
-(void) doNotBufferVertexContent;

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


#pragma mark Textures

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
 * The alignTextureUnit:withTexture: method compares the value of this property
 * with the isFlippedVertically property of the texture to automatically determine
 * whether these texture coordinates need to be flipped vertically in order to
 * display the texture correctly, and will do so if needed. As part of that inversion,
 * the value of this property will also be flipped, to indicate that the texture
 * coordinates are now aligned differently.
 *
 * The alignTextureUnit:withTexture: method is invoked automatically when a
 * texture is assigned to cover this mesh in the mesh node. If you need to
 * adjust the value of this property, you sould do so before setting a texture
 * or material into the mesh node.
 *
 * When multi-texturing is being used on this mesh, you can use the
 * expectsVerticallyFlippedTexture:inTextureUnit: method for finer control
 * of orienting textures for each texture unit. When multi-texturing is
 * being used, setting this value of this property will invoke the
 * expectsVerticallyFlippedTexture:inTextureUnit: method to set the same
 * value for each texture unit.
 *
 * Reading the value of this property will return YES if the property-reading
 * method expectsVerticallyFlippedTextureInTextureUnit: returns YES for
 * any texture unit, otherwise this property will return NO.
 * 
 * The initial value of this property is set when the underlying mesh texture
 * coordinates are built or loaded. See the expectsVerticallyFlippedTextures
 * property on the CC3Resource class to understand how this property is set
 * during mesh resource loading.
 * 
 * When building meshes programmatically, you should endeavour to design the
 * mesh so that this property will be YES if you will be using vertically-flipped
 * textures (all texture file formats except PVR).
 */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures;

/**
 * Returns whether the texture coordinates for the specfied texture unit expects
 * that the texture was flipped upside-down during texture loading.
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
 * The alignTextureUnit:withTexture: method compares the value of this property
 * with the isFlippedVertically property of the texture to automatically determine
 * whether these texture coordinates need to be flipped vertically in order to
 * display the texture correctly, and will do so if needed. As part of that inversion,
 * the value of this property for the specified texture unit will also be flipped,
 * to indicate that the texture coordinates are now aligned differently.
 *
 * The alignTextureUnit:withTexture: method is invoked automatically when a
 * texture is assigned to cover this mesh in the mesh node. If you need to
 * adjust the value of this property, you sould do so before setting a texture
 * or material into the mesh node.
 * 
 * The initial value of this property is set when the underlying mesh texture
 * coordinates are built or loaded. See the expectsVerticallyFlippedTextures
 * property on the CC3Resource class to understand how this property is set
 * during mesh resource loading.
 * 
 * When building meshes programmatically, you should endeavour to design the
 * mesh so that this property will be YES if you will be using vertically-flipped
 * textures (all texture file formats except PVR).
 */
-(BOOL) expectsVerticallyFlippedTextureInTextureUnit: (GLuint) texUnit;

/**
 * Sets whether the texture coordinates for the specfied texture unit expects
 * that the texture was flipped upside-down during texture loading.
 *
 * See the notes of the expectsVerticallyFlippedTextureInTextureUnit: method
 * for a discussion of texture coordinate orientation.
 *
 * Setting the value of this property will change the way the texture coordinates
 * are aligned when a texture is assigned to cover this texture unit for this mesh.
 */
-(void) expectsVerticallyFlippedTexture: (BOOL) expectsFlipped inTextureUnit: (GLuint) texUnit;

/**
 * Aligns the texture coordinates of the specified texture unit to the specified texture.
 * 
 * Under iOS, textures that do not have dimensions that are a power-of-two, will
 * be padded to dimensions of a power-of-two on loading. The result is that the
 * texture will be physically larger than is expected by these texture coordinates.
 *
 * The usable area of the texture is indicated by its mapSize property, and invoking
 * this method will align these texture coordinates with the usable size of the
 * specified texture.
 *
 * If the value of the expectsVerticallyFlippedTexture:InTextureUnit: property
 * is different than the value of the isFlippedVertically property of the specified
 * texture, the texture coordinates are not oriented vertically for the texture.
 * If so, this method also flips the texture coordinates to align with the texture.
 *
 * Thhis method is invoked automatically when a texture is assigned to cover this
 * mesh in the mesh node. Normally, the application has no need to invoke this
 * method directly. However, you can invoke this method manually if you have
 * changed the texture coordinate alignment using the
 * expectsVerticallyFlippedTexture:inTextureUnit: method.
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
-(void) alignTextureUnit: (GLuint) texUnit withTexture: (CC3Texture*) aTexture;

/**
 * @deprecated The alignment performed by this method is now performed automatically
 * whenever a texture or material is attached to the mesh node holding this mesh.
 * Use the property-setting method expectsVerticallyFlippedTexture:inTextureUnit:
 * to indicate whether the texture  mesh is aligned with vertically-flipped textures
 * prior to setting the texture or material into your mesh node. 
 */
-(void) alignWithTexturesIn: (CC3Material*) aMaterial DEPRECATED_ATTRIBUTE;

/**
 * @deprecated The alignment performed by this method is now performed automatically
 * whenever a texture or material is attached to the mesh node holding this mesh.
 * Use the property-setting method expectsVerticallyFlippedTexture:inTextureUnit:
 * to indicate whether the texture  mesh is aligned with vertically-flipped textures
 * prior to setting the texture or material into your mesh node. 
 */
-(void) alignWithInvertedTexturesIn: (CC3Material*) aMaterial DEPRECATED_ATTRIBUTE;

/**
 * Convenience method that flips the texture coordinate mapping vertically
 * for the specified texture channels. This has the effect of flipping the
 * texture for that texture channel vertically on the model. and can be
 * useful for creating interesting effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 */
-(void) flipVerticallyTextureUnit: (GLuint) texUnit;

/**
 * Convenience method that flips the texture coordinate mapping vertically
 * for all texture units. This has the effect of flipping the textures
 * vertically on the model. and can be useful for creating interesting
 * effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 *
 * This has the same effect as invoking the flipVerticallyTextureUnit:
 * method for all texture units.
 */
-(void) flipTexturesVertically;

/**
 * Convenience method that flips the texture coordinate mapping horizontally
 * for the specified texture channels. This has the effect of flipping the
 * texture for that texture channel horizontally on the model. and can be
 * useful for creating interesting effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 */
-(void) flipHorizontallyTextureUnit: (GLuint) texUnit;

/**
 * Convenience method that flips the texture coordinate mapping horizontally
 * for all texture units. This has the effect of flipping the textures
 * horizontally on the model. and can be useful for creating interesting
 * effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 *
 * This has the same effect as invoking the flipHorizontallyTextureUnit:
 * method for all texture units.
 */
-(void) flipTexturesHorizontally;

/**
 * Configures the mesh so that a texture applied to the specified texture unit will
 * be repeated the specified number of times across the mesh, in each dimension.
 * The repeatFactor argument contains two numbers, corresponding to how many times
 * in each dimension the texture should be repeated.
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
 * You can specify a fractional value for either of the components of the repeatFactor
 * to expand the texture in that dimension so that only part of the texture appears
 * in that dimension, while potentially repeating multiple times in the other dimension.
 */
-(void) repeatTexture: (ccTex2F) repeatFactor forTextureUnit: (GLuint) texUnit;

/**
 * Configures the mesh so that the textures in all texture units will be repeated the
 * specified number of times across the mesh, in each dimension. The repeatFactor
 * argument contains two numbers, corresponding to how many times in each dimension
 * the texture should be repeated.
 *
 * This has the same effect as invoking the repeatTexture:forTextureUnit: method
 * for each texture unit.
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
 * The drawing mode indicating how the vertices are connected (points, lines,
 * triangles...).
 *
 * This must be set with a valid GL drawing mode enumeration.
 * The default value is GL_TRIANGLES.
 */
@property(nonatomic, assign) GLenum drawingMode;

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
 * be used by the CC3MeshNode that wraps this mesh. This method is invoked automatically
 * by the CC3MeshNode instance when this mesh is attached to the CC3MeshNode.
 *
 * This abstract implementation always returns nil, and the node will never be considered
 * to be inside the camera frustum, or to intersect with any other bounding volume.
 * Subclasses will override to provide an appropriate and useful bounding volume instance.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume;


#pragma mark Managing vertex data

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
 * Indicates the number of vertices in this mesh.
 *
 * Usually, you should treat this property as read-only. However, there may be
 * occasions with meshes that contain dynamic content, such as particle systems,
 * where it may be appropriate to set the value of this property.
 *
 * Setting the value of this property changes the amount of vertex content that
 * will be submitted to the GL engine during drawing.
 *
 * When setting this property, care should be taken to ensure that the value is
 * not set larger than the number of vertices that were allocated for this mesh.
 */
@property(nonatomic, assign) GLuint vertexCount;

/**
 * If indexed drawing is used by this mesh, indicates the number of vertex
 * indices in the mesh.
 *
 * If indexed drawing is not used by this mesh, this property has no effect,
 * and reading it will return zero.
 *
 * Usually, you should treat this property as read-only. However, there may be
 * occasions with meshes that contain dynamic content, such as particle systems,
 * where it may be appropriate to set the value of this property.
 *
 * Setting the value of this property changes the amount of vertex content that
 * will be submitted to the GL engine during drawing.
 *
 * When setting this property, care should be taken to ensure that the value is
 * not set larger than the number of vertices that were allocated for this mesh.
 */
@property(nonatomic, assign) GLuint vertexIndexCount;

/**
 * Returns the location element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * vertex data. If the dimensionality is 2, the returned vector will contain zero in
 * the Z component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * vertex data. If the dimensionality is 2, the Z component of the specified vector
 * will be ignored. If the dimensionality is 4, the specified vector will be converted
 * to a 4D vector, with the W component set to one, before storing.
 * 
 * If this mesh is being used by any mesh nodes, be sure to invoke the markBoundingVolumeDirty
 * method on all nodes that use this mesh, to ensure that the boundingVolume is recalculated
 * using the new location values.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexLocationsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index;

/**
 * Returns the location element at the specified index in the underlying vertex data,
 * as a four-dimensional location in the 4D homogeneous coordinate space.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the elementSize property. If the
 * value of the elementSize property is 3, the returned vector will contain one
 * in the W component. If the value of the elementSize property is 2, the returned
 * vector will contain zero in the Z component and one in the W component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the underlying vertex data to
 * the specified four-dimensional location in the 4D homogeneous coordinate space.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * data. If the dimensionality is 3, the W component of the specified vector will be
 * ignored. If the dimensionality is 2, both the W and Z components of the specified
 * vector will be ignored.
 * 
 * If this mesh is being used by any mesh nodes, be sure to invoke the markBoundingVolumeDirty
 * method on all nodes that use this mesh, to ensure that the boundingVolume is recalculated
 * using the new location values.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexLocationsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index;

/**
 * Returns the normal element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexNormalAt: (GLuint) index;

/**
 * Sets the normal element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexNormalsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4F) vertexColor4FAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexColorsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4B) vertexColor4BAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexColorsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the specified texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the specified texture unit index, to the specified texture coordinate value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBufferForTextureUnit: method
 * to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the commonly used texture unit zero.
 *
 * This is a convenience method that is equivalent to invoking the
 * vertexTexCoord2FForTextureUnit:at: method, with zero as the texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the commonly used texture unit zero, to the specified texture coordinate value.
 *
 * This is a convenience method that delegates to the setVertexTexCoord2F:forTextureUnit:at:
 * method, passing in zero for the texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBuffer method to ensure that
 * the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index;

/** @deprecated Use the vertexTexCoord2FForTextureUnit:at: method instead, */
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/** @deprecated Use the setVertexTexCoord2F:forTextureUnit:at: method instead, */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/**
 * Returns the index element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLuint) vertexIndexAt: (GLuint) index;

/**
 * Sets the index element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexIndicesGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index;

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

/**
 * Convenience method to update the GL engine buffers with the vertex content data in this mesh.
 *
 * This updates the content of each vertex. It does not update the vertex indices. To update
 * the vertex index data to the GL engine, use the updateVertexIndicesGLBuffer method.
 */
-(void) updateGLBuffers;

/** Updates the GL engine buffer with the vertex index data in this mesh. */
-(void) updateVertexIndicesGLBuffer;


#pragma mark Faces

/**
 * Additional information about the faces in the mesh.
 *
 * This property does not contain vertex information for the faces. That is contained
 * within the mesh itself. As such, most meshes do not require this additional information
 * about the faces of the mesh. This property provides additional information about the
 * faces that can be used in certain customized lighting and shadowing effects.
 *
 * If this property is not set directly, it will be lazily initialized on first access.
 *
 * Since the face array contains static information about a mesh, when copying a mesh,
 * the face array is not itself copied by default. This avoids duplication of data that
 * does not change between two copies of the same mesh object. Instead, both mesh copies
 * will share a reference to the same face array instance. If you need to create separate
 * copies of the faces array when copying a mesh, you must explicitly create a copy.
 */
@property(nonatomic, retain) CC3FaceArray* faces;

/**
 * Indicates whether information about the faces of this mesh should be cached.
 *
 * If this property is set to NO, accessing information about the faces through the
 * methods faceAt:, faceIndicesAt:, faceCenterAt:, faceNormalAt:, or facePlaneAt:,
 * will be calculated dynamically from the mesh data.
 *
 * If such data will be accessed frequently, this repeated dynamic calculation may
 * cause a noticable impact to performance. In such a case, this property can be
 * set to YES to cause the data to be calculated once and cached, improving the
 * performance of subsequent accesses to information about the faces.
 *
 * However, caching information about the faces will increase the amount of memory
 * required by the mesh, sometimes significantly. To avoid this additional memory
 * overhead, in general, you should leave this property set to NO, unless intensive
 * access to face information is causing a performance impact.
 *
 * An example of a situation where the use of this property may be noticable,
 * is when adding shadow volumes to nodes. Shadow volumes make intense use of
 * accessing face information about the mesh that is casting the shadow.
 *
 * When the value of this property is set to NO, any data cached during previous
 * access through the indicesAt:, centerAt:, normalAt:, or planeAt:, methods will
 * be cleared.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldCacheFaces;

/**
 * Returns the number of faces in this mesh.
 *
 * This is calculated from the number of vertices, taking into
 * consideration the type of primitives that this mesh is drawing.
 */
@property(nonatomic, readonly) GLuint faceCount;

/**
 * Returns the number of faces to be drawn from the specified number of
 * vertex indices, based on the type of primitives that this mesh is drawing.
 */ 
-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc;

/**
 * Returns the number of vertex indices required to draw the specified number
 * of faces, based on the type of primitives that this mesh is drawing.
 */ 
-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc;

/** @deprecated Renamed to faceCountFromVertexIndexCount:. */
-(GLuint) faceCountFromVertexCount: (GLuint) vc DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexIndexCountFromFaceCount:. */
-(GLuint) vertexCountFromFaceCount: (GLuint) fc DEPRECATED_ATTRIBUTE;

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
 * or other padding, that data will not appear in the returned face structure. For that
 * remaining vertex data, you can use the faceIndicesAt: method to retrieve the indices
 * of the vertex data, and then use the vertex accessor methods to retrieve the individual
 * vertex data components.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Face) faceAt: (GLuint) faceIndex;

/**
 * Returns the mesh face that is made up of the three vertices at the three indices
 * within the specified face indices structure.
 *
 * The returned face structure contains only the locations of the vertices. If the vertex
 * locations are interleaved with other vertex data, such as color or texture coordinates,
 * or other padding, that data will not appear in the returned face structure. For that
 * remaining vertex data, you can use the faceIndicesAt: method to retrieve the indices
 * of the vertex data, and then use the vertex accessor methods to retrieve the individual
 * vertex data components.
 */
-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices;

/**
 * Returns the face from the mesh at the specified index, as indices into the mesh vertices.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 *
 * The returned structure reference contains the indices of the three vertices that
 * make up the triangular face. These indices index into the actual vertex data within
 * the layout of the mesh.
 *
 * This method takes into consideration any padding (stride) between the vertex indices.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex;

/**
 * Returns the center of the mesh face at the specified index.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Vector) faceCenterAt: (GLuint) faceIndex;

/**
 * Returns the normal of the mesh face at the specified index.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Vector) faceNormalAt: (GLuint) faceIndex;

/**
 * Returns the plane of the mesh face at the specified index.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Plane) facePlaneAt: (GLuint) faceIndex;

/** Returns the indices of the neighbours of the mesh face at the specified index. */
-(CC3FaceNeighbours) faceNeighboursAt: (GLuint) faceIndex;

/**
 * Populates the specified array with information about the intersections of the specified ray
 * and this mesh, up to the specified maximum number of intersections.
 *
 * This method returns the actual number of intersections found (up to the specified maximum).
 * This value indicates how many of the elements of the specifed intesections array were populated
 * during the execution of this method. The contents of elements beyond that number are undefined.
 *
 * Each of the populated elements of the intersections array contains information about the face
 * on which the intersection occurred, the location of the intersection, and the distance from the
 * ray startLocation where the intersection occurred. The location and distance components are
 * specified in the local coordinates system of this mesh.
 *
 * The intersections array is not sorted in any way. In particular, when the array contains multiple
 * entries, the first element in the array does not necessily contain the closest intersection.
 * If you need to determine the closest intersection, you can iterate the intersections array and
 * compare the values of the location element of each intersection.
 *
 * To use this method, allocate an array of CC3MeshIntersection structures, pass a reference to it
 * in the intersections parameter, and indicate the size of that array in the maxHitCount parameter.
 *
 * The method iterates through the faces in the mesh until the indicated number of intersections are
 * found, or until all the faces in the mesh have been inspected. Therefore, to keep performance high,
 * you should set the maxHitCount parameter no higher than the number of intersections that are useful
 * to you. For example, specifiying a value of one for the maxHitCount parameter will cause this method
 * to return as soon as the first intersection is found. In most cases, this is all that is needed.
 * 
 * The allowBackFaces parameter is used to indicate whether to include intersections where the ray
 * pierces a face from its back face. Typically, this means that the ray has intersected the face
 * as the ray exits on the far side of the mesh. In most cases you will interested only where the
 * ray intersects the near side of the mesh, in which case you can set this parameter to NO.
 *
 * The allowBehind parameter is used to indicate whether to include intersections that occur behind
 * the startLocation of the ray, in the direction opposite to the direction of the ray. Typically,
 * this might mean the mesh is located behind the ray startLocation, or it might mean the ray starts
 * inside the mesh. Again,in most cases, you will be interested only in intersections that occur in
 * the direction the ray is pointing, and can ususally set this parameter to NO.
 */
-(GLuint) findFirst: (GLuint) maxHitCount
	  intersections: (CC3MeshIntersection*) intersections
		 ofLocalRay: (CC3Ray) aRay
	acceptBackFaces: (BOOL) acceptBackFaces
	acceptBehindRay: (BOOL) acceptBehind;


#pragma mark Mesh context switching

/**
 * Resets the tracking of the mesh switching functionality.
 *
 * This is invoked automatically by the CC3Scene at the beginning of each frame drawing cycle.
 * Usually, the application never needs to invoke this method directly.
 */
+(void) resetSwitching;

@end


#pragma mark -
#pragma mark CC3FaceArray

/**
 * CC3FaceArray holds additional cached calculated information about mesh faces,
 * such as the centers, normals, planes and neighbours of each face.
 *
 * The additional face data is maintained in separate internal arrays, and each
 * type of data is lazily allocated and initialized when accessed the first time.
 * So, requesting information about the center of a face will cause all of the
 * face centers to be calculated and cached, but will not cause the face normals
 * or planes to be calculated and cached. They will be calculated and cached when
 * a face normal or plane is explicitly requested.
 */
@interface CC3FaceArray : CC3Identifiable {
	CC3Mesh* mesh;
	CC3FaceIndices* indices;
	CC3Vector* centers;
	CC3Vector* normals;
	CC3Plane* planes;
	CC3FaceNeighbours* neighbours;
	BOOL shouldCacheFaces;
	BOOL indicesAreRetained;
	BOOL centersAreRetained;
	BOOL normalsAreRetained;
	BOOL planesAreRetained;
	BOOL neighboursAreRetained;
	BOOL indicesAreDirty;
	BOOL centersAreDirty;
	BOOL normalsAreDirty;
	BOOL planesAreDirty;
	BOOL neighboursAreDirty;
}

/**
 * The mesh containing the vertices for which this face array is managing faces.
 *
 * Setting this property will cause the centers, normals, planes and neighbours
 * properties to be deallocated and then re-built on the next access.
 */
@property(nonatomic, assign) CC3Mesh* mesh;

/**
 * Indicates the number of faces in this array, as retrieved from the mesh.
 *
 * The value of this property will be zero until the mesh property is set.
 */
@property(nonatomic, readonly) GLuint faceCount;

/**
 * Indicates whether information about the faces of this mesh should be cached.
 *
 * If this property is set to NO, accessing information about the faces through
 * the methods indicesAt:, centerAt:, normalAt:, or planeAt:, will be calculated
 * dynamically from the mesh data.
 *
 * If such data will be accessed frequently, this repeated dynamic calculation may
 * cause a noticable impact to performance. In such a case, this property can be
 * set to YES to cause the data to be calculated once and cached, improving the
 * performance of subsequent accesses to information about the faces.
 *
 * However, caching information about the faces will increase the amount of memory
 * required by the mesh, sometimes significantly. To avoid this additional memory
 * overhead, in general, you should leave this property set to NO, unless intensive
 * access to face information is causing a performance impact.
 *
 * An example of a situation where the use of this property may be noticable,
 * is when adding shadow volumes to nodes. Shadow volumes make intense use of
 * accessing face information about the mesh that is casting the shadow.
 *
 * When the value of this property is set to NO, any data cached during previous
 * access through the indicesAt:, centerAt:, normalAt:, or planeAt:, methods will
 * be cleared.
 *
 * Because the face neighbour data returned by the neighboursAt: method is
 * a function of the relationship between faces, that data is always cached,
 * and is not affected by the setting of this property.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldCacheFaces;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) faceArray;

/** Allocates and initializes an unnamed autoreleased instance with the specified tag. */
+(id) faceArrayWithTag: (GLuint) aTag;

/**
 * Allocates and initializes an autoreleased instance with the specified name and an
 * automatically generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) faceArrayWithName: (NSString*) aName;

/** Allocates and initializes an autoreleased instance with the specified tag and name. */
+(id) faceArrayWithTag: (GLuint) aTag withName: (NSString*) aName;


#pragma mark Indices

/**
 * An array containing the vertex indices of each face.
 *
 * This property will be lazily initialized on the first access after the mesh
 * property has been set, by an automatic invocation of the populateIndices method.
 * When created in this manner, the memory allocated to hold the data in the
 * returned array will be managed by this instance.
 *
 * Alternately, this property may be set directly to an array that was created
 * externally. In this case, the underlying data memory is not managed by this
 * instance, and it is up to the application to manage the allocation and
 * deallocation of the underlying data memory, and to ensure that the array is
 * large enough to contain the number of CC3FaceIndices structures specified by
 * the faceCount property.
 */
@property(nonatomic, assign) CC3FaceIndices* indices;

/**
 * Returns the vertex indices of the face at the specified index,
 * lazily initializing the indices property if needed.
 */
-(CC3FaceIndices) indicesAt: (GLuint) faceIndex;

/**
 * Populates the contents of the indices property from the associated mesh,
 * automatically allocating memory for the property if needed.
 *
 * This method is invoked automatically on the first access of the indices
 * property after the mesh property has been set. Usually, the application
 * never needs to invoke this method directly.
 *
 * However, if the indices property has been set to an array created outside
 * this instance, this method may be invoked to populate that array from the mesh.
 */
-(void) populateIndices;

/**
 * Allocates underlying memory for the indices property, and returns a pointer
 * to the allocated memory.
 *
 * This method will allocate enough memory for the indices property to hold
 * the number of CC3FaceIndices structures specified by the faceCount property.
 *
 * This method is invoked automatically by the populateIndices method.
 * Usually, the application never needs to invoke this method directly.
 *
 * It is safe to invoke this method more than once, but understand that any 
 * previously allocated memory will be safely released prior to the allocation
 * of the new memory. The memory allocated earlier will therefore be lost and
 * should not be referenced.
 * 
 * The memory allocated will automatically be released when this instance
 * is deallocated.
 */
-(CC3FaceIndices*) allocateIndices;

/**
 * Deallocates the underlying memory that was previously allocated with the
 * allocateIndices method. It is safe to invoke this method more than once,
 * or even if the allocateIndices method was not previously invoked.
 *
 * This method is invoked automatically when allocateIndices is invoked,
 * and when this instance is deallocated. Usually, the application never
 * needs to invoke this method directly.
 */
-(void) deallocateIndices;

/** Marks the indices data as dirty. It will be automatically repopulated on the next access. */
-(void) markIndicesDirty;


#pragma mark Centers

/**
 * An array containing the location of the center of each face.
 *
 * This property will be lazily initialized on the first access after the mesh
 * property has been set, by an automatic invocation of the populateCenters method.
 * When created in this manner, the memory allocated to hold the data in the
 * returned array will be managed by this instance.
 *
 * Alternately, this property may be set directly to an array that was created
 * externally. In this case, the underlying data memory is not managed by this
 * instance, and it is up to the application to manage the allocation and
 * deallocation of the underlying data memory, and to ensure that the array is
 * large enough to contain the number of CC3Vector structures specified by the
 * faceCount property.
 */
@property(nonatomic, assign) CC3Vector* centers;

/**
 * Returns the center of the face at the specified index,
 * lazily initializing the centers property if needed.
 */
-(CC3Vector) centerAt: (GLuint) faceIndex;

/**
 * Populates the contents of the centers property from the associated mesh,
 * automatically allocating memory for the property if needed.
 *
 * This method is invoked automatically on the first access of the centers
 * property after the mesh property has been set. Usually, the application
 * never needs to invoke this method directly.
 *
 * However, if the centers property has been set to an array created outside
 * this instance, this method may be invoked to populate that array from the mesh.
 *
 * In addition, if the mesh is deformed in some way, the application may invoke
 * this method in order to recalculate updated face centers.
 */
-(void) populateCenters;

/**
 * Allocates underlying memory for the centers property, and returns a pointer
 * to the allocated memory.
 *
 * This method will allocate enough memory for the centers property to hold
 * the number of CC3Vector structures specified by the faceCount property.
 *
 * This method is invoked automatically by the populateCenters method.
 * Usually, the application never needs to invoke this method directly.
 *
 * It is safe to invoke this method more than once, but understand that any 
 * previously allocated memory will be safely released prior to the allocation
 * of the new memory. The memory allocated earlier will therefore be lost and
 * should not be referenced.
 * 
 * The memory allocated will automatically be released when this instance
 * is deallocated.
 */
-(CC3Vector*) allocateCenters;

/**
 * Deallocates the underlying memory that was previously allocated with the
 * allocateCenters method. It is safe to invoke this method more than once,
 * or even if the allocateCenters method was not previously invoked.
 *
 * This method is invoked automatically when allocateCenters is invoked,
 * and when this instance is deallocated. Usually, the application never
 * needs to invoke this method directly.
 */
-(void) deallocateCenters;

/** Marks the centers data as dirty. It will be automatically repopulated on the next access. */
-(void) markCentersDirty;


#pragma mark Normals

/**
 * An array containing the normal vector for each face.
 *
 * This property will be lazily initialized on the first access after the mesh
 * property has been set, by an automatic invocation of the populateNormals method.
 * When created in this manner, the memory allocated to hold the data in the
 * returned array will be managed by this instance.
 *
 * Alternately, this property may be set directly to an array that was created
 * externally. In this case, the underlying data memory is not managed by this
 * instance, and it is up to the application to manage the allocation and
 * deallocation of the underlying data memory, and to ensure that the array is
 * large enough to contain the number of CC3Vector structures specified by the
 * faceCount property.
 */
@property(nonatomic, assign) CC3Vector* normals;

/**
 * Returns the normal of the face at the specified index,
 * lazily initializing the normals property if needed.
 */
-(CC3Vector) normalAt: (GLuint) faceIndex;

/**
 * Populates the contents of the normals property from the associated mesh,
 * automatically allocating memory for the property if needed.
 *
 * This method is invoked automatically on the first access of the normals
 * property after the mesh property has been set, or from the ensureNormals
 * method. Usually, the application never needs to invoke this method directly.
 *
 * However, if the normals property has been set to an array created outside
 * this instance, this method may be invoked to populate that array from the mesh.
 *
 * In addition, if the mesh is deformed in some way, the application may invoke
 * this method in order to recalculate updated face normals.
 */
-(void) populateNormals;

/**
 * Allocates underlying memory for the normals property, and returns a pointer
 * to the allocated memory.
 *
 * This method will allocate enough memory for the normals property to hold
 * the number of CC3Vector structures specified by the faceCount property.
 *
 * This method is invoked automatically by the populateNormals method.
 * Usually, the application never needs to invoke this method directly.
 *
 * It is safe to invoke this method more than once, but understand that any 
 * previously allocated memory will be safely released prior to the allocation
 * of the new memory. The memory allocated earlier will therefore be lost and
 * should not be referenced.
 * 
 * The memory allocated will automatically be released when this instance
 * is deallocated.
 */
-(CC3Vector*) allocateNormals;

/**
 * Deallocates the underlying memory that was previously allocated with the
 * allocateNormals method. It is safe to invoke this method more than once,
 * or even if the allocateNormals method was not previously invoked.
 *
 * This method is invoked automatically when allocateNormals is invoked,
 * and when this instance is deallocated. Usually, the application never
 * needs to invoke this method directly.
 */
-(void) deallocateNormals;

/** Marks the normals data as dirty. It will be automatically repopulated on the next access. */
-(void) markNormalsDirty;


#pragma mark Planes

/**
 * An array containing the plane equation for each face.
 *
 * This property will be lazily initialized on the first access after the mesh
 * property has been set, by an automatic invocation of the populatePlanes method.
 * When created in this manner, the memory allocated to hold the data in the
 * returned array will be managed by this instance.
 *
 * Alternately, this property may be set directly to an array that was created
 * externally. In this case, the underlying data memory is not managed by this
 * instance, and it is up to the application to manage the allocation and
 * deallocation of the underlying data memory, and to ensure that the array is
 * large enough to contain the number of CC3Plane structures specified by the
 * faceCount property.
 */
@property(nonatomic, assign) CC3Plane* planes;

/**
 * Returns the plane of the face at the specified index,
 * lazily initializing the planes property if needed.
 */
-(CC3Plane) planeAt: (GLuint) faceIndex;

/**
 * Populates the contents of the planes property from the associated mesh,
 * automatically allocating memory for the property if needed.
 *
 * This method is invoked automatically on the first access of the planes
 * property after the mesh property has been set. Usually, the application
 * never needs to invoke this method directly.
 *
 * However, if the planes property has been set to an array created outside
 * this instance, this method may be invoked to populate that array from the mesh.
 *
 * In addition, if the mesh is deformed in some way, the application may invoke
 * this method in order to recalculate updated face planes.
 */
-(void) populatePlanes;

/**
 * Allocates underlying memory for the planes property, and returns a pointer
 * to the allocated memory.
 *
 * This method will allocate enough memory for the planes property to hold
 * the number of CC3Plane structures specified by the faceCount property.
 *
 * This method is invoked automatically by the populatePlanes method.
 * Usually, the application never needs to invoke this method directly.
 *
 * It is safe to invoke this method more than once, but understand that any 
 * previously allocated memory will be safely released prior to the allocation
 * of the new memory. The memory allocated earlier will therefore be lost and
 * should not be referenced.
 * 
 * The memory allocated will automatically be released when this instance
 * is deallocated.
 */
-(CC3Plane*) allocatePlanes;

/**
 * Deallocates the underlying memory that was previously allocated with the
 * allocatePlanes method. It is safe to invoke this method more than once,
 * or even if the allocatePlanes method was not previously invoked.
 *
 * This method is invoked automatically when allocatePlanes is invoked,
 * and when this instance is deallocated. Usually, the application never
 * needs to invoke this method directly.
 */
-(void) deallocatePlanes;

/** Marks the planes data as dirty. It will be automatically repopulated on the next access. */
-(void) markPlanesDirty;


#pragma mark Neighbours

/**
 * An array containing neighbour data for each face. Each element in this array
 * contains a CC3FaceNeighbours strucutre which keeps track of the indices to
 * the neighbouring faces of each face.
 *
 * This property will be lazily initialized on the first access after the mesh
 * property has been set, by an automatic invocation of the populateNeighbours method.
 * When created in this manner, the memory allocated to hold the data in the
 * returned array will be managed by this instance.
 *
 * Alternately, this property may be set directly to an array that was created
 * externally. In this case, the underlying data memory is not managed by this
 * instance, and it is up to the application to manage the allocation and
 * deallocation of the underlying data memory, and to ensure that the array is
 * large enough to contain the number of CC3FaceNeighbours structures specified
 * by the faceCount property.
 */
@property(nonatomic, assign) CC3FaceNeighbours* neighbours;

/**
 * Returns the neighbours of the face at the specified index,
 * lazily initializing the neighbours property if needed.
 */
-(CC3FaceNeighbours) neighboursAt: (GLuint) faceIndex;

/**
 * Populates the contents of the neighbours property from the associated mesh,
 * automatically allocating memory for the property if needed.
 *
 * This method is invoked automatically on the first access of the neighbours
 * property after the mesh property has been set. Usually, the application
 * never needs to invoke this method directly.
 *
 * However, if the neighbours property has been set to an array created outside
 * this instance, this method may be invoked to populate that array from the mesh.
 */
-(void) populateNeighbours;

/**
 * Allocates underlying memory for the neighbours property, and returns a pointer
 * to the allocated memory.
 *
 * This method will allocate enough memory for the normals property to hold
 * the number of CC3FaceNeighbours structures specified by the faceCount property.
 *
 * This method is invoked automatically by the populateNeighbours method.
 * Usually, the application never needs to invoke this method directly.
 *
 * It is safe to invoke this method more than once, but understand that any 
 * previously allocated memory will be safely released prior to the allocation
 * of the new memory. The memory allocated earlier will therefore be lost and
 * should not be referenced.
 * 
 * The memory allocated will automatically be released when this instance
 * is deallocated.
 */
-(CC3FaceNeighbours*) allocateNeighbours;

/**
 * Deallocates the underlying memory that was previously allocated with the
 * allocateNeighbours method. It is safe to invoke this method more than once,
 * or even if the allocateNeighbours method was not previously invoked.
 *
 * This method is invoked automatically when allocateNeighbours is invoked,
 * and when this instance is deallocated. Usually, the application never
 * needs to invoke this method directly.
 */
-(void) deallocateNeighbours;

/** Marks the neighbours data as dirty. It will be automatically repopulated on the next access. */
-(void) markNeighboursDirty;

@end

