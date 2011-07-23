/*
 * CC3Mesh.h
 *
 * cocos3d 0.6.0-sp
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
#import "CC3VertexArrays.h"

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
 * This abstract implementation always returns a bounding box containing two zero vectors.
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
 * This effectively causes vertex location data to be ignored during any subsequent
 * invocation of the releaseRedundantData method, even if it has been buffered to a GL VBO.
 *
 * Only the vertex location will be retained. Any other vertex data, such as normals, or
 * texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 *
 * For the CC3VertexArrayMesh subclass, if you also want to retain other vertex data,
 * you can set the shouldReleaseRedundantData property to NO on the associated vertex arrays.
 */
-(void) retainVertexLocations;


#pragma mark Drawing

/**
 * Draws the mesh data to the GL engine. The specified visitor encapsulates
 * the frustum of the currently active camera, and certain drawing options.
 *
 * If this mesh is different than the last mesh drawn, this method binds this
 * mesh data to the GL engine. Otherwise, if this mesh is the same as the mesh
 * already bound, it is not bound again, Once binding is complete, this method then performs
 * the GL draw operations.
 * 
 * This is invoked automatically from the draw method of the CC3MeshNode instance that is
 * using this mesh. Usually, the application never needs to invoke this method directly.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Returns an allocated, initialized, autorelease instance of the bounding volume to
 * be used by the CC3MeshNode that wraps this mesh. This method is called automatically
 * by the CC3MeshNode instance when this mesh is attached to the CC3MeshNode.
 *
 * This abstract implementation always returns nil. Subclasses will override to provide
 * an appropriate and useful bounding volume instance.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume;


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
