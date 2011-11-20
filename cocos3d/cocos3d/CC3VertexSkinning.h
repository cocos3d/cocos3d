/*
 * CC3VertexSkinning.h
 *
 * cocos3d 0.6.4
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
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


#import "CC3MeshNode.h"
#import "CC3VertexArrayMesh.h"
#import "CC3VertexArrays.h"

@class CC3SkinMesh, CC3Bone, CC3SkinSection;


#pragma mark -
#pragma mark CC3Node skinning extensions

/** CC3Node extension to support descendants that include CC3Bones. */
@interface CC3Node (Skinning)

/**
 * Returns whether the bones in this skeleton, at and above this bone, are rigid.
 * For the skeleton above a particular bone to be rigid, that bone node, and all
 * nodes above that bone must have unity scaling, or must be within the tolerance
 * value specified in the  property of unity scaling.
 *
 * This implementation tests whether this node has unity scaling (within the
 * tolerance set in the  property), and then queries whether
 * the parent node of this node is also rigid. This propagates upwards in the
 * structural hierarchy to the CC3SoftBodyNode, at the root of the skeleton.
 *
 * Since the inverse transforms of the bones are relative to the CC3SoftBodyNode,
 * if all nodes up to the CC3SoftBodyNode are rigid, then the skeleton is rigid.
 */
@property(nonatomic, readonly) BOOL isSkeletonRigid;

/**
 * Binds the rest pose of any skeletons contained within the descendants of this node.
 * This method must be invoked once the initial locations and rotations of each bone
 * in the skeletons are set.
 *
 * These initial bone orientations are those that align with the native structure
 * of the vertices in the mesh, and collectively are known as the rest pose of
 * the skeleton. Changes to the transform properties of the individual bone nodes,
 * relative to the rest pose, will deform the mesh from its natural structure.
 * 
 * The bone transforms must be calculated locally from the perspective of the
 * CC3SoftBodyNode that contains a skeleton and skin mesh. This method should
 * only be invoked on the CC3SoftBodyNode or a structural ancestor of that node,
 * 
 * This implementation simply passes this invocation along to the children of this
 * node. Subclasses contained in the soft-body node will add additional functionality.
 */
-(void) bindRestPose;

/**
 * Returns whether this structural node contains any descendant nodes that are used for
 * soft-body vertex skinning. This would include nodes of type CC3SkinMeshNode or CC3Bone.
 *
 * This property is a convenience used to identify nodes that should be grouped
 * together structurally under a CC3SoftBodyNode.
 */
@property(nonatomic, readonly) BOOL hasSoftBodyContent;

/**
 * After copying a skin mesh node, the newly created copy will still be influenced
 * by the original skeleton. The result is that both the original mesh and the copy
 * will move and be deformed in tandem as the skeleton moves.
 *
 * If you are creating a chorus line of dancing characters, this may be the effect
 * you are after. However, if you are creating a squadron of similar, but independently
 * moving characters, each skin mesh node copy should be controlled by a separate skeleton.
 * 
 * After creating a copy of the skeleton bone node assembly, you can use this method
 * to attach the skin mesh node to the new skeleton. The node that is provided as the
 * argument to this method is the root bone node of the skeleton, or a structural ancestor
 * of the skeleton that does not also include the original skeleton as a descendant.
 *
 * This method iterates through all the bones referenced by any descendant skin mesh nodes,
 * and retrieves a bone with the same name from the structural descendants of the specified node.
 *
 * When copying a CC3SoftBodyNode instance, this method is automatically invoked as part
 * of the copying of the soft-body object, and you do not need to invoke this method directly.
 */
-(void) reattachBonesFrom: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3SoftBodyNode

/**
 * CC3SoftBodyNode is the primary structural component for a soft-body object that
 * uses vertex skinning to manipulate and draw mesh vertices.
 *
 * Vertex skinning is a feature of OpenGL that allows the vertices of a mesh to be
 * manipulated or deformed using an underlying skeleton of bones. This feature is
 * also sometimes referred to as bone-rigging. This feature is used to create
 * realistic movement in soft-body, flexible meshes, such as characters or textiles.
 *
 * A soft-body object consists of two primary components: a skeletal structure, and
 * the skin that covers it. The skeletal structure is constructed from an assembly
 * of CC3Bone instances, and the skin is constructed from one or more CC3SkinMeshNode
 * instances. The CC3SoftBodyNode instance then serves to collect together the bones
 * and skin components, and forms the root of the soft-body object.
 * 
 * The vertices of the skin mesh forms the skin that surrounds the bones of the skeleton.
 * During movement and drawing, the location and rotation of each bone in the skeleton
 * influences the locations of the skin vertices that are attached to that bone.
 * Some skin vertices, particularly those around joints where two bones meet, can be
 * associated with more than one bone, and in that case, the influence that each bone
 * has on the location of a vertex is determined by a weighting associated with each
 * bone for that vertex.
 *
 * The CC3Bone instances are typically assembled into a structural assembly of bones
 * known as a skeleton. The purpose of this skeletal structure is to allow the bones
 * to move and interact with each other in a hierarchical manner.
 *
 * A CC3SkinMeshNode instance represents the skin that covers the skeleton, and contains
 * the mesh that makes up the skin, in the form of a CC3SkinMesh. This mesh includes the
 * bone assignments and weights for each vertex, which specifies how the location of each
 * vertex is influenced by the location and orientation of each nearby bone.
 *
 * A single soft-body object may be covered by a single skin mesh, but more complicated
 * objects may be covered by several skin meshes. As such, a single CC3SoftBodyNode
 * instance may contain one or more CC3SkinMeshNode instances.
 * 
 * For efficiency and control, each skin mesh is usually broken into sections. These skin
 * sections are represented by instances of the CC3SkinSection class. A CC3SkinMeshNode
 * typically holds a single CC3SkinMesh, and several CC3SkinSection instances to define
 * how that skin mesh should be divided into sections. Each CC3SkinSection instance
 * contains a range of vertices, and references to the bones in the skeleton that
 * influence the vertices in that range. All of the vertices of a single CC3SkinSection
 * are drawn in a single GL drawing call.
 *
 * Manipulation of the bones in the skeleton will cause the soft-body to move and flex
 * internally. In addition, like any node, a CC3SoftBodyNode can be moved, rotated and
 * scaled to move, rotate and scale the entire soft-body assembly of skin and bones as
 * a unit. By combining both internal bone animation with movement of the entire
 * CC3SoftBodyNode, you can create realistic movement of your soft-body objects.
 *
 * For example, if your CC3SoftBodyNode represents a character, you could animate the
 * bones in the skeleton within the node to crouch down and then stand up again.
 * During the standing up animation, you could move the entire CC3SoftBodyNode upwards
 * to create a realistic jumping action. Or, you could simply animate the bones in the
 * skeleton through a loop of a step of a walking motion, while at the same time moving
 * the CC3SoftBodyNode forward, making it appear that the character was walking forward.
 *
 * The initial assembly of CC3Bone nodes should be arranged into what is termed the
 * "rest pose". This is the alignment of the bones that will fit the undeformed
 * positions of the vertices that make up the skin. In the rest pose, the bones have
 * no deforming effect on the skin vertices.
 * 
 * Once the initial skeleton has been assembled into the rest pose, you should invoke
 * the bindRestPose method on the CC3SoftBodyNode instance (or any ancestor node of the
 * CC3SoftBodyNode instance) to cause the bones and skin (CC3Bones & CC3SkinMeshNodes)
 * to cache this pose.
 * 
 * Subsequent movement of the bones in the skeleton deform the skin vertices relative
 * to this rest pose, affecting the location of the vertices in the mesh.
 *
 * In almost all soft-body objects, all internal movement of the object is handled via
 * manipulation of the bones. The CC3SkinMeshNodes should not be moved or rotated directly,
 * otherwise the skin will become detached from the bones. However, if you have reason to
 * move the skin mesh nodes, you should re-establish the rest pose and invoke the
 * bindRestPose method again to re-align the bones with the skin.
 *
 * If the CC3SoftBodyNode has been assembled from a file loader, the bindRestPose method
 * will be invoked automatically, and you do not need to invoke it explicitly.
 */
@interface CC3SoftBodyNode : CC3Node
@end


#pragma mark -
#pragma mark CC3SkinMeshNode

/**
 * CC3SkinMeshNode is a CC3MeshNode specialized to use vertex skinning to draw the
 * contents of its mesh. It is one of the key structural descendant nodes of a
 * CC3SoftBodyNode instance.
 *
 * Like all mesh nodes, a CC3SkinMeshNode contains a material and a mesh. For a
 * CC3SkinMeshNode, the mesh must be a CC3SkinMesh, which manages the mesh vertices, 
 * including the vertex weights that determine, for each vertex, how the location
 * of that vertex is influenced by the location and orientation of each skeleton bone.
 *
 * This CC3MeshNode subclass adds a number of methods for accessing and managing the
 * weights and matrix index data associated with each vertex.
 *
 * In addition, the CC3SkinMeshNode contains a collection of skin sections, in the
 * form of CC3SkinSection instances. Each CC3SkinSection instance relates a section of
 * the mesh, in the form of a range of vertices, to a set of bones in the skeleton.
 * 
 * Each CC3SkinSection applies the transformations in the referenced bones to the
 * the vertices in the section of the mesh that it controls, and draws that section
 * of the mesh by drawing the vertices within its range in a single GL call.
 * 
 * After copying a CC3SkinMeshNode, the newly created copy will still be influenced
 * by the original skeleton. The result is that both the original mesh and the copy
 * will move and be deformed in tandem as the skeleton moves.
 *
 * If you are creating a chorus line of dancing characters, this may be the effect
 * you are after. However, if you are creating a squadron of similar, but independently
 * moving characters, each CC3SkinMeshNode copy should be controlled by a separate skeleton.
 * 
 * After creating a copy of the skeleton bone node assembly as well, you can use the
 * reattachBonesFrom: method to attach the skin mesh node to the new skeleton.
 *
 * When copying a CC3SkinMeshNode as part of copying a CC3SoftBodyNode instance, a copy
 * of the skeleton is also created, and the reattachBonesFrom: method is automatically
 * invoked. When copying CC3SoftBodyNode, you do not need to invoke the reattachBonesFrom:
 * method on the new CC3SkinMeshNode directly.
 */
@interface CC3SkinMeshNode : CC3MeshNode {
	CCArray* skinSections;
	CC3GLMatrix* restPoseTransformMatrix;
}

/** The collection of CC3SkinSections that are managed by this node. */
@property(nonatomic,retain, readonly) CCArray* skinSections;

/**
 * Returns the cached rest pose matrix, relative to the soft-body ancestor node.
 * This is the transform matrix of this node when it is in its rest pose, which
 * is the location and rotation that corresponds to the rest pose of the bones.
 *
 * The value of this property is set when the bindRestPose method is invoked.
 */
@property(nonatomic, retain, readonly) CC3GLMatrix* restPoseTransformMatrix;

/** Adds the specified skin section to the collection in the skinSections property. */
-(void) addSkinSection: (CC3SkinSection*) aSkinSection;

/**
 * The CC3Mesh used by this node, cast as a CC3SkinMesh, for convenience
 * in accessing the additional behavour available to support bone vertices.
 */
@property(nonatomic, readonly) CC3SkinMesh* skinnedMesh;

/**
 * Convenience method to cause the vertex matrix index data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex matrix index will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexMatrixIndices;

/**
 * Convenience method to cause the vertex matrix index data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a GL VBO, is retained
 * in application memory, and is submitted to the GL engine on each frame render.
 *
 * Only the vertex matrix index will not be buffered to a GL VBO. Any other vertex data,
 * such as locations, or texture coordinates, will be buffered to a GL VBO when
 * createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexMatrixIndices method.
 */
-(void) doNotBufferVertexMatrixIndices;

/**
 * Convenience method to cause the vertex weight data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex weight will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexWeights;

/**
 * Convenience method to cause the vertex weight data to be skipped when createGLBuffers
 * is invoked. The vertex data is not buffered to a GL VBO, is retained in application
 * memory, and is submitted to the GL engine on each frame render.
 *
 * Only the vertex weight will not be buffered to a GL VBO. Any other vertex data, such
 * as locations, or texture coordinates, will be buffered to a GL VBO when createGLBuffers
 * is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexWeights method.
 */
-(void) doNotBufferVertexWeights;


#pragma mark Accessing vertex data

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
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexWeightsGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexWeightsGLBuffer;

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
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexMatrixIndicesGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setMatrixIndex: (GLushort) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexMatrixIndicesGLBuffer;

@end


#pragma mark -
#pragma mark CC3SkinMesh

/**
 * CC3SkinMesh is a CC3VertexArrayMesh that, in addition to the familiar vertex data such
 * as locations, normals and texture coordinates, adds vertex arrays for bone weights and
 * bone matrix indices.
 *
 * Each element of the CC3VertexMatrixIndices vertex array in the boneMatrixIndices property
 * is a set of index values that reference a set of bones that influence the location of
 * that vertex.
 * 
 * Each element of the CC3VertexWeights vertex array in the boneWeights property contains a
 * corresponding set of weighting values that determine the relative influence that each of
 * the bones identified in the boneMatrixIndices has on transforming the location of the vertex.
 * 
 * For each vertex, there is a one-to-one correspondence between each bone index values
 * and the weights. The first weight is applied to the bone identified by the first index.
 * Therefore, the elementSize property of the vertex arrays in the boneWeights and
 * boneMatrixIndices properties must be the same. The value of these elementSize properties
 * therefore effectively defines how many bones influence each vertex in these arrays, and
 * this value must be the same for all vertices in these arrays.
 *
 * Since the bone indexes can change from vertex to vertex, different vertices can be
 * influenced by a different set of bones, but the absolute number of bones influencing
 * each vertex must be consistent, and is defined by the elementSize properties. For any
 * vertex, the weighting values define the influe that each of the bones has on the vertex.
 * A zero value for a bone weight in a vertex indicates that location of that vertex is
 * not affected by the tranformation of that bone.
 *
 * There is a limit to how many bones may be assigned to each vertex, and this limit is
 * defined by the number of vertex units supported by the platform, and the elementSize
 * property of each of the boneMatrixIndices and boneWeights vertex arrays must not be
 * larger than the number of available vertex units. This value can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 *
 * This CC3Mesh subclass adds a number of methods for accessing and managing the weights
 * and matrix index data associated with each vertex.
 */
@interface CC3SkinMesh : CC3VertexArrayMesh {
	CC3VertexMatrixIndices* boneMatrixIndices;
	CC3VertexWeights* boneWeights;
}

/**
 * The vertex array that manages the indices of the bones that influence each vertex.
 *
 * Each element of the vertex array in this property is a small set of index values that
 * reference a set of bones that influence the location of that vertex.
 * 
 * The elementSize property of the vertex arrays in the boneWeights and boneMatrixIndices
 * properties must be the same, and must not be larger than the maximum number of available
 * vertex units for the platform, which can be retreived from
 * [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 */
@property(nonatomic,retain) CC3VertexMatrixIndices* boneMatrixIndices;

/**
 * The vertex array that manages the weighting that each bone has in influencing each vertex.
 *
 * Each element of the vertex array in this property contains a small set of weighting values
 * that determine the relative influence that each of the bones identified for that vertex in
 * the boneMatrixIndices property has on transforming the location of the vertex.
 * 
 * The elementSize property of the vertex arrays in the boneWeights and boneMatrixIndices
 * properties must be the same, and must not be larger than the maximum number of available
 * vertex units for the platform, which can be retreived from
 * [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 */
@property(nonatomic,retain) CC3VertexWeights* boneWeights;

/**
 * Convenience method to cause the vertex matrix index data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex matrix index will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexMatrixIndices;

/**
 * Convenience method to cause the vertex matrix index data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a GL VBO, is retained
 * in application memory, and is submitted to the GL engine on each frame render.
 *
 * Only the vertex matrix index will not be buffered to a GL VBO. Any other vertex data,
 * such as locations, or texture coordinates, will be buffered to a GL VBO when
 * createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexMatrixIndices method.
 */
-(void) doNotBufferVertexMatrixIndices;

/**
 * Convenience method to cause the vertex weight data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex weight will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexWeights;

/**
 * Convenience method to cause the vertex weight data to be skipped when createGLBuffers
 * is invoked. The vertex data is not buffered to a GL VBO, is retained in application
 * memory, and is submitted to the GL engine on each frame render.
 *
 * Only the vertex weight will not be buffered to a GL VBO. Any other vertex data, such
 * as locations, or texture coordinates, will be buffered to a GL VBO when createGLBuffers
 * is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexWeights method.
 */
-(void) doNotBufferVertexWeights;


#pragma mark Accessing vertex data

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
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexWeightsGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexWeightsGLBuffer;

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
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexMatrixIndicesGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setMatrixIndex: (GLushort) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexMatrixIndicesGLBuffer;

@end


#pragma mark -
#pragma mark CC3SkinSection

/**
 * A CC3SkinSection defines a section of the skin mesh, and contains a collection of
 * bones from the skeleton that influence the locations of the vertices in that section.
 *
 * The skin section is expressed as a range of consecutive vertices from the mesh, as
 * specified by the vertexStart and vertexCount properties. These properties define the
 * first vertex of the section and the number of vertices in the section, respectively.
 *
 * The skin section also contains a collection of bones that influence the vertices
 * in the skin section. The bones are ordered in that collection such that the index
 * of a bone in the collection corresponds to the index held for a vertex in the
 * boneMatrixIndices vertex array of the CC3SkinMesh.
 *
 * Through the CC3VertexMatrixIndices vertex array in the boneMatrixIndices property
 * of the mesh, each vertex identifies several distinct indices into the bones
 * collection of this skin section. The transform matrices from those bones are
 * combined in a weighted fashion, and used to transform the location of the vertex.
 * Each vertex defines its own set of weights through the CC3VertexWeights vertex
 * array in the boneWeights property of the mesh.
 */
@interface CC3SkinSection : NSObject <NSCopying> {
	CC3SkinMeshNode* node;
	CCArray* bones;
	GLint vertexStart;
	GLint vertexCount;
}

/**
 * The collection of bones from the skeleton that influence the subset of mesh vertices
 * that is managed and drawn by this batch.
 * 
 * Each vertex holds a set of indices into this array, to identify the bones that
 * contribute to the transforming of that vertex. The contribution that each bone makes
 * is weighted by the corresponding weights held by the vertex.
 *
 * Any particular vertex will typically only be directly influenced by two or three bones.
 * The maximum number of bones that any vertex can be directly influenced by is determined
 * by the number of vertex units supported by the platform. This limit can be retreived
 * from [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 * 
 * Because different vertices of the skin section may be influenced by different combinations
 * of bones, the number of bones in the collection in this property will generally be larger
 * than the number of bones used per vertex.
 *
 * However, when the vertices are drawn, all of the vertices in this skin section are drawn
 * with a single call to the GL engine. All of the bone transforms that affect any of the
 * vertices being drawn are loaded into the GL engine by this skin section prior to drawing
 * the vertices.
 * 
 * The number of transform matrices that can be simultaneously loaded into the GL engine
 * matrix palette is limited by the platform, and that limit defines the maximum number
 * of bones in the collection in this property. This platform limit can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxPaletteMatrices.value.
 */
@property(nonatomic, retain, readonly) CCArray* bones;

/**
 * An index that indicates which vertex in the mesh begins this skin section.
 *
 * This value is an index of vertices, not of the underlying primitives (floats or bytes).
 *
 * For example, if a mesh has ten vertices, the value of this property can be set to
 * some value between zero and ten, even though each of the vertices contains several
 * components of data (locations, normals, texture coordinates, bone indices and bone
 * weights, making the actual array much longer than ten, in terms of primatives or bytes)
 */
@property(nonatomic,assign) GLint vertexStart;

/**
 * Indicates the number of vertices in this skin section.
 *
 * This value is a count of the nubmer of vertices, not of the number of underlying
 * primitives (floats or bytes).
 *
 * For example, if a mesh has ten vertices, the value of this property can be set to
 * some value between zero and ten, even though each of the vertices contains several
 * components of data (locations, normals, texture coordinates, bone indices and bone
 * weights, making the actual array much longer than ten, in terms of primatives or bytes)
 */
@property(nonatomic,assign) GLint vertexCount;

/**
 * Adds the specified bone node to the collection of bones in the bones property.
 *
 * See the notes for the bones property for more information about bones.
 *
 * When the vertices are drawn, all of the vertices in this skin section are drawn
 * with a single call to the GL engine. All of the bone transforms that affect any
 * of the vertices being drawn are loaded into the GL engine by this skin section
 * prior to drawing the vertices.
 * 
 * The number of transform matrices that can be simultaneously loaded into the
 * GL engine matrix palette is limited by the platform, and that limit defines the maximum
 * number of bones in the collection in this property. This platform limit can be retrieved
 * from [CC3OpenGLES11Engine engine].platform.maxPaletteMatrices.value.
 */
-(void) addBone: (CC3Bone*) aNode;


#pragma mark Allocation and initialization

/** Initializes an instance that will be used by the specified skin mesh node. */
-(id) initForNode: (CC3SkinMeshNode*) aNode;

/**
 * Allocates and initializes an autoreleased instance that will be used
 * by the specified skin mesh node.
 */
+(id) boneBatchForNode: (CC3SkinMeshNode*) aNode;

/** Returns a copy of this skin section, for use by the specified skin mesh node. */
-(id) copyForNode: (CC3SkinMeshNode*) aNode;

/** Returns a copy of this skin section, for use by the specified skin mesh node. */
-(id) copyForNode: (CC3SkinMeshNode*) aNode withZone: (NSZone*) zone;

/**
 * Creating a copy of a skin section is typically done as part of creating a copy of
 * a skin mesh node. After copying, the newly created copy will still be influenced
 * by the original skeleton. The result is that both the original mesh and the copy
 * will move and be deformed in tandem as the skeleton moves.
 *
 * If you are creating a chorus line of dancing characters, this may be the effect
 * you are after. However, if you are creating a squadron of similar, but independently
 * moving characters, each skin mesh node copy should be controlled by a separate skeleton.
 * 
 * After creating a copy of the skeleton bone node assembly, you can use this method
 * to attach the skin mesh node to the new skeleton. The node that is provided as the
 * argument to this method is the root bone node of the skeleton, or a structural ancestor
 * of the skeleton that does not also include the original skeleton as a descendant.
 *
 * This method iterates through all the bones referenced by this skin section, and retrieves
 * a bone with the same name from the structural descendants of the specified node.
 *
 * Typically, you would not invoke this method on the skin section directly. Instead, you
 * would invoke a similar method on the CC3SkinMeshNode, or one of its structural ancestors.
 *
 * When copying a CC3SoftBodyNode instance, this method is automatically invoked as part
 * of the copying of the soft-body object, and you do not need to invoke this method directly.
 */
-(void) reattachBonesFrom: (CC3Node*) aNode;


#pragma mark Drawing

/**
 * Draws the mesh vertices of this skin section.
 *
 * Prior to drawing the vertices, this method iterates through the CC3Bones in the bones
 * property, and loads a transform matrix into the GL matrix palette for each bone.
 * During drawing, each vertex is then transformed by a weighted average of the transform
 * matrices that it identifies as influencing its location.
 *
 * The actual matrix loaded for each bone is derived from a combination of:
 *   - the modelview matrix of the world (MV)
 *   - the transform of the bone (B), relative to the world
 *   - the inverse transform of rest pose of the bone (Br(-1)), relative to the world
 *   - the transform of the skin mesh node (M)
 * 
 * as follows, with * representing matrix multiplication:
 *
 *   MV * B * Br(-1) * M
 * 
 * In practice, to avoid calculating the inverse transform for the rest pose of each bone
 * on every frame render, we can separate each of the rest pose of the bone and the skin
 * mesh node into two components: the transform of the CC3SoftBodyNode, relative to the
 * world, and the transform of the bone and skin mesh node relative to the CC3SoftBodyNode.
 * The above matrix calculation can be expanded and then reduced as follows, with:
 *   - the modelview matrix of the world (MV)
 *   - the transform of the bone (B)
 *   - the transform of the Soft-body node (SB), and its inverse (SB(-1))
 *   - the transform of the rest pose of the bone relative to the
 *     soft-body node (Brsb), and its inverse (Brsb(-1))
 *   - the transform of the skin mesh node relative to the soft-body node (Msb)
 *
 *   MV * B * Br(-1) * M
 *   MV * B * (SB * Brsb)(-1) * (SB * Msb)
 *   MV * B * Brsb(-1) * SB(-1) * SB * Msb
 *   MV * B * Brsb(-1) * (SB(-1) * SB) * Msb
 *   MV * B * Brsb(-1) * Msb
 *
 * The result is dependent only on the inverted rest pose of the bone relative to
 * the soft-body node, and the skin mesh node, also relative to the soft-body node.
 * In practice, neither of these parameters should change as the character moves.
 *
 * Since the two cached matrices are relative to the soft-body node, we can move the
 * soft-body node around, and transform it, without having to recalculate the inverse
 * rest pose matrix on each movement for each bone. The movement of the soft-body node
 * and the bones are the only factors that need to be rebuilt on each update.
 *
 * We can capture the inverse rest pose transform of the bone relative to the soft-body
 * node once and cache it. If we make the assumption that the transform of the skin mesh
 * node, relative to the soft-body node will not change (a fairly safe assumption since
 * it would affect the alignment of the bones to the mesh vertices), we can determine it
 * once and cache it as well. This caching is handled by the bindRestPose method on the
 * respective CC3Bone and CC3SkinMeshNode nodes.
 *
 * This arrangement also has the benefit of avoiding artifacts that sometimes appear
 * in the matrix inversion of the full bone and skin transforms if the CC3SoftBodyNode
 * is set at rotations of exactly 90 degrees (the cosine of the angle is zero).
 * 
 * This method is invoked automatically when a CC3SkinMeshNode is drawn. Usually, the
 * application never needs to invoke this method directly.
 */
-(void) drawVerticesOfMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Returns a description of this skin section that includes a list of the bones. */
-(NSString*) fullDescription;

@end


#pragma mark -
#pragma mark CC3Bone

/**
 * CC3Bone is the building block of skeletons that control the deformation of a skin mesh.
 *
 * When building a skeleton, bones are assembled in a structural assembly, from a root bone
 * out to limb or branch bones. For example, a skeleton for a human character might start
 * with a root spine bone, to which are attached upper-arm and thigh bones, to which are
 * attached, forearm and shin bones, to which are attached hand and foot bones, and so on.
 *
 * In this structual assembly, moving an upper-arm bone to cause the character to reach
 * out, carries the forearm and hand bones along with it. Movement of the forearm bone
 * is then performed relative to the upper-arm bone, and movement of the hand bone is
 * performed relative to the forearm, and so on.
 *
 * CC3Bones are simply specialized structural nodes, and have no content of their own to
 * draw. However, individual bones are referenced by skin sections of the skin mesh node,
 * and the transform matrices of the bones influence the transformations of the vertices
 * of the skin mesh, as the skeleton moves. The applyPoseTo: method handles applying the
 * transform matrix of the bone to the transform matrix for the skin mesh vertices.
 */
@interface CC3Bone : CC3Node {
	CC3GLMatrix* restPoseInvertedMatrix;
}


#pragma mark Transformations

/**
 * Returns the cached inverted rest pose matrix. This is the transform matrix of this
 * bone when it is in its rest pose, which is the location and rotation that corresponds
 * to the undeformed skin mesh. Changes to the transform of this bone, relative to the
 * rest pose, will deform the mesh to create soft-body movement of the mesh vertices.
 *
 * The value of this property is set when the bindRestPose method is invoked.
 */
@property(nonatomic, retain, readonly) CC3GLMatrix* restPoseInvertedMatrix;

/**
 * Applies the changes to the current transform of this bone, relative to the
 * rest pose of this bone, to the specified matrix.
 *
 * The specified bone matrix (BM) is populated from the following components:
 *   - the transform of the bone (B)
 *   - the inverse transform of the rest pose of the bone relative to the
 *     soft-body node (Brsb(-1))
 *
 * as follows:
 *
 *   BM = B * Brsb(-1)
 *
 * The existing contents of the specified boneMatrix are ignored, and it is
 * populated from the above calculation.
 */
-(void) applyPoseTo: (CC3GLMatrix*) boneMatrix;
 
@end


#pragma mark -
#pragma mark CC3SkeletonRestPoseBindingVisitor

/**
 * CC3SkeletonRestPoseBindingVisitor is a CC3NodeVisitor that is passed to an assembly
 * of bone nodes (a skeleton) in order to establish the rest pose transforms for the
 * bones in the skeleton.
 *
 * The skeleton rest pose is calculated relative to the containing CC3SoftBodyNode.
 * This visitor is initialized with the shouldLocalizeToStartingNode set to YES.
 * The visit should be initialized on a CC3SoftBodyNode.
 *
 * CC3SoftBodyNode makes use of a CC3SkeletonRestPoseBindingVisitor to cause the bone
 * and skin mesh node rest pose transform matrices to be cached.
 */
@interface CC3SkeletonRestPoseBindingVisitor : CC3NodeTransformingVisitor
@end


