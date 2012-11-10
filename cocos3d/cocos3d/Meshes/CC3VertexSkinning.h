/*
 * CC3VertexSkinning.h
 *
 * cocos3d 0.7.2
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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

@class CC3SkinMesh, CC3Bone, CC3SkinSection, CC3SoftBodyNode, CC3DeformedFaceArray;


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
 * relative to the surrounding CC3SoftBodyNode, otherwise the skin will become detached
 * from the bones. However, if you have reason to move the skin mesh nodes relative to
 * the soft-body node, you should re-establish the rest pose and invoke the bindRestPose
 * method again to re-align the bones with the skin.
 *
 * If the CC3SoftBodyNode has been assembled from a file loader, the bindRestPose method
 * will usually be invoked automatically, and you do not need to invoke it explicitly.
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
	CC3Matrix* restPoseTransformMatrix;
	CC3DeformedFaceArray* deformedFaces;
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
@property(nonatomic, retain, readonly) CC3Matrix* restPoseTransformMatrix;

/**
 * Returns the skin section that deforms the specified vertex.
 *
 * Each skin section operates on a consecutive array of vertex indices.
 * If this mesh uses vertex indexing, the specified index should be an
 * index into the vertex index array.
 *
 * If this mesh does not use vertex indexing, then the specified index
 * should be the index of the vertex in the vertex locations array.
 */
-(CC3SkinSection*) skinSectionForVertexIndexAt: (GLint) index;

/**
 * Returns the skin section that deforms the specified face.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 */
-(CC3SkinSection*) skinSectionForFaceIndex: (GLint) faceIndex;

/**
 * The CC3Mesh used by this node, cast as a CC3SkinMesh, for convenience
 * in accessing the additional behavour available to support bone vertices.
 */
@property(nonatomic, readonly) CC3SkinMesh* skinnedMesh;


#pragma mark Accessing vertex data

/**
 * Returns the number of vertex units used by this skin mesh. This value indicates
 * how many bones influence each vertex, and corresponds to the number of weights
 * and matrix indices attached to each vertex.
 */
@property(nonatomic, readonly) GLuint vertexUnitCount;

/**
 * Returns the weight element, for the specified vertex unit, at the specified index in
 * the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding to
 * one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat) vertexWeightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index;

/** @deprecated Renamed to vertexWeightForVertexUnit:at: */
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/**
 * Sets the weight element, for the specified vertex unit, at the specified index in
 * the underlying vertex data, to the specified value.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding to
 * one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexWeightsGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index;

/** @deprecated Renamed to setVertexWeight:forVertexUnit:at: */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/**
 * Returns a pointer to an array of the weight elements at the specified vertex
 * index in the underlying vertex data.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The number of
 * elements in the returned array is the same for all vertices in this mesh, and
 * can be retrieved from the vertexUnitCount property.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct elements.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat*) vertexWeightsAt: (GLuint) index;

/**
 * Sets the weight elements at the specified vertex index in the underlying vertex data,
 * to the values in the specified array.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The number of
 * weight elements is the same for all vertices in this mesh, and can be retrieved
 * from the vertexUnitCount property. The number of elements in the specified input
 * array must therefore be at least as large as the value of the vertexUnitCount property.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexWeightsGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexWeights: (GLfloat*) weights at: (GLuint) index;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexWeightsGLBuffer;

/**
 * Returns the matrix index element, for the specified vertex unit, at the specified
 * index in the underlying vertex data.
 *
 * Several matrix indices are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLuint) vertexMatrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index;

/** @deprecated Renamed to vertexMatrixIndexForVertexUnit:at: */
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/**
 * Sets the matrix index element, for the specified vertex unit, at the specified index
 * in the underlying vertex data, to the specified value.
 *
 * Several matrix indices are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexMatrixIndicesGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexMatrixIndex: (GLuint) aMatrixIndex
			   forVertexUnit: (GLuint) vertexUnit
						  at: (GLuint) index;

/** @deprecated Renamed to setVertexMatrixIndex:forVertexUnit:at: */
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/**
 * Returns a pointer to an array of the matrix indices at the specified vertex
 * index in the underlying vertex data.
 *
 * Several matrix index values are stored for each vertex, one per vertex unit,
 * corresponding to one for each bone that influences the location of the vertex.
 * The number of elements in the returned array is the same for all vertices in
 * this mesh, and can be retrieved from the vertexUnitCount property.
 * 
 * The matrix indices can be stored in this mesh as either type GLushort or type
 * GLubyte. The returned array will be of the type of index stored by this vertex
 * array, and it is up to the application to know which type will be returned,
 * and cast the returned array accordingly. The type can be determined by the
 * matrixIndexType property of this mesh, which will return one of GL_UNSIGNED_SHORT
 * or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the matrixIndexType property altogether, you can use the
 * vertexMatrixIndexForVertexUnit:at: method, which retrieves the matrix index
 * values one at a time, and automatically converts the stored type to GLushort.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct elements.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLvoid*) vertexMatrixIndicesAt: (GLuint) index;

/**
 * Sets the matrix index elements at the specified vertex index in the underlying
 * vertex data, to the values in the specified array.
 *
 * Several matrix index values are stored for each vertex, one per vertex unit,
 * corresponding to one for each bone that influences the location of the vertex.
 * The number of elements is the same for all vertices in this mesh, and can be
 * retrieved from the vertexUnitCount property. The number of elements in the specified input
 * array must therefore be at least as large as the value of the vertexUnitCount property.
 * 
 * The matrix indices can be stored in this mesh as either type GLushort or type GLubyte.
 * The specified array must be of the type of index stored by this mesh, and it is up to
 * the application to know which type is required, and provide that type of array accordingly.
 * The type can be determined by the matrixIndexType property of this mesh, which will return
 * one of GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the matrixIndexType property altogether, you can use the
 * setVertexMatrixIndex:forVertexUnit:at: method, which sets the matrix index values
 * one at a time, and automatically converts the input type to the correct stored type.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexMatrixIndicesGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index;

/**
 * Returns the type of data stored for each bone matrix index.
 *
 * The value returned by this property will be either GL_UNSIGNED_SHORT or
 * GL_UNSIGNED_BYTE, corresponding to each matrix index being stored in either
 * a type GLushort or type GLubyte, respectively.
 */
@property(nonatomic, readonly) GLenum matrixIndexType;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexMatrixIndicesGLBuffer;

/**
 * Contains information about the faces and vertices in the mesh that have been
 * deformed by the current position of the underlying bones.
 *
 * This property contains deformed vertex information for the faces, and additional
 * information about the faces that can be used in certain customized lighting and
 * shadowing effects.
 *
 * If this property is not set directly, it will be lazily initialized on first access.
 */
@property(nonatomic, retain) CC3DeformedFaceArray* deformedFaces;


#pragma mark Transformations

/**
 * Callback method that will be invoked when the transformMatrix of the specified bone has changed.
 * The transform matrix of this node is marked as dirty, so that the changes are propagated to
 * descendant nodes, such as shadow volumes, and to update the deformedFaces property.
 *
 * This callback is implemented as distinct from the general notification mechanism of the
 * bone because of its importance, and so that this class and its subclasses do not need to
 * distiguish this callback from other notifications that this instance might register for.
 */
-(void) boneWasTransformed: (CC3Bone*) aBone;

@end


#pragma mark -
#pragma mark CC3SkinMesh

/**
 * CC3SkinMesh is a CC3VertexArrayMesh that, in addition to the familiar vertex data such
 * as locations, normals and texture coordinates, adds vertex arrays for bone weights and
 * bone matrix indices.
 *
 * Each element of the CC3VertexMatrixIndices vertex array in the vertexMatrixIndices property
 * is a set of index values that reference a set of bones that influence the location of
 * that vertex.
 * 
 * Each element of the CC3VertexWeights vertex array in the vertexWeights property contains a
 * corresponding set of weighting values that determine the relative influence that each of
 * the bones identified in the vertexMatrixIndices has on transforming the location of the vertex.
 * 
 * For each vertex, there is a one-to-one correspondence between each bone index values
 * and the weights. The first weight is applied to the bone identified by the first index.
 * Therefore, the elementSize property of the vertex arrays in the vertexWeights and
 * vertexMatrixIndices properties must be the same. The value of these elementSize properties
 * therefore effectively defines how many bones influence each vertex in these arrays, and
 * this value must be the same for all vertices in these arrays.
 *
 * Since the bone indexes can change from vertex to vertex, different vertices can be
 * influenced by a different set of bones, but the absolute number of bones influencing
 * each vertex must be consistent, and is defined by the elementSize properties. For any
 * vertex, the weighting values define the influence that each of the bones has on the vertex.
 * A zero value for a bone weight in a vertex indicates that location of that vertex is
 * not affected by the tranformation of that bone.
 *
 * There is a limit to how many bones may be assigned to each vertex, and this limit is
 * defined by the number of vertex units supported by the platform, and the elementSize
 * property of each of the vertexMatrixIndices and vertexWeights vertex arrays must not be
 * larger than the number of available vertex units. This value can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 *
 * This CC3Mesh subclass adds a number of methods for accessing and managing the weights
 * and matrix index data associated with each vertex.
 */
@interface CC3SkinMesh : CC3VertexArrayMesh {
	CC3VertexMatrixIndices* vertexMatrixIndices;
	CC3VertexWeights* vertexWeights;
}

/**
 * The vertex array that manages the indices of the bones that influence each vertex.
 *
 * Each element of the vertex array in this property is a small set of index values that
 * reference a set of bones that influence the location of that vertex.
 * 
 * The elementSize property of the vertex arrays in the vertexWeights and vertexMatrixIndices
 * properties must be the same, and must not be larger than the maximum number of available
 * vertex units for the platform, which can be retreived from
 * [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 */
@property(nonatomic,retain) CC3VertexMatrixIndices* vertexMatrixIndices;

/** @deprecated Renamed to vertexMatrixIndices. */
@property(nonatomic,retain) CC3VertexMatrixIndices* boneMatrixIndices DEPRECATED_ATTRIBUTE;

/**
 * The vertex array that manages the weighting that each bone has in influencing each vertex.
 *
 * Each element of the vertex array in this property contains a small set of weighting values
 * that determine the relative influence that each of the bones identified for that vertex in
 * the vertexMatrixIndices property has on transforming the location of the vertex.
 * 
 * The elementSize property of the vertex arrays in the vertexWeights and vertexMatrixIndices
 * properties must be the same, and must not be larger than the maximum number of available
 * vertex units for the platform, which can be retreived from
 * [CC3OpenGLES11Engine engine].platform.maxVertexUnits.value.
 */
@property(nonatomic,retain) CC3VertexWeights* vertexWeights;

/** @deprecated Renamed to vertexWeights. */
@property(nonatomic,retain) CC3VertexWeights* boneWeights DEPRECATED_ATTRIBUTE;


#pragma mark Vertex management

/**
 * Indicates the types of content contained in each vertex of this mesh.
 *
 * Each vertex can contain several types of content, optionally including location, normal,
 * color, texture coordinates, and vertex skinning weights and matrices. To identify this
 * various content, this property is a bitwise-OR of flags that enumerate the types of
 * content contained in each vertex of this mesh.
 *
 * Valid component flags of this property include:
 *   - kCC3VertexContentLocation
 *   - kCC3VertexContentNormal
 *   - kCC3VertexContentColor
 *   - kCC3VertexContentTextureCoordinates
 *   - kCC3VertexContentWeights
 *   - kCC3VertexContentMatrixIndices
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
 *   - kCC3VertexContentWeights - automatically constructs a CC3VertexWeights instance
 *     in the vertexWeights property, that holds several GLfloat values per vertex.
 *   - kCC3VertexContentMatrixIndices - automatically constructs a CC3VertexMatrixIndices instance
 *     in the vertexMatrixIndices property, that holds several GLubyte values per vertex.
 * 
 * This property is a convenience property. Instead of using this property, you can create the
 * appropriate vertex arrays in those properties directly.
 * 
 * The vertex arrays constructed by this property will be configured to use interleaved data
 * if the shouldInterleaveVertices property is set to YES. You should ensure the value of the
 * shouldInterleaveVertices property to the desired value before setting the value of this property.
 * The initial value of the shouldInterleaveVertices property is YES.
 * 
 * The CC3VertexWeights and CC3VertexMatrixIndices vertex arrays created with this property, are
 * each initialized with a value of zero in the elementSize property. After creating these vertex
 * arrays with this property, you must access these two vertex arrays, via the vertexWeights and
 * vertexMatrixIndices properties respectively, and set the elementSize properties to a value that
 * is appropriate for your vertex skinning needs. Once you have done so, if the vertex content is
 * interleaved, invoke the updateVertexStride method on this instance to automatically align the
 * elementOffset and vertexStride properties of all the contained vertex arrays to the correct
 * interleaved vertex content.
 *
 * If the content is interleaved, for each vertex, the content is held in the structures identified in
 * the list above, in the order that they appear in the list. You can use this consistent organization
 * to create an enclosing structure to access all data for a single vertex, if it makes it easier to
 * access vertex data that way. If vertex content is not specified, it is simply absent, and the content
 * from the following type will be concatenated directly to the content from the previous type.
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

/** @deprecated Renamed to vertexWeightForVertexUnit:at: */
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to setVertexWeight:forVertexUnit:at: */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to setVertexMatrixIndex:forVertexUnit:at: */
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexMatrixIndexForVertexUnit:at: */
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

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
 * vertexMatrixIndices vertex array of the CC3SkinMesh.
 *
 * Through the CC3VertexMatrixIndices vertex array in the vertexMatrixIndices property
 * of the mesh, each vertex identifies several distinct indices into the bones
 * collection of this skin section. The transform matrices from those bones are
 * combined in a weighted fashion, and used to transform the location of the vertex.
 * Each vertex defines its own set of weights through the CC3VertexWeights vertex
 * array in the vertexWeights property of the mesh.
 */
@interface CC3SkinSection : NSObject <NSCopying> {
	CC3SkinMeshNode* node;
	CCArray* skinnedBones;
	GLint vertexStart;
	GLint vertexCount;
}

/**
 * The collection of bones from the skeleton that influence the mesh vertices that are
 * managed and drawn by this skin section.
 * 
 * Each vertex holds a set of indices into this mesh, to identify the bones that
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
 *
 * The array returned by this property is created anew for each read. Do not add or remove
 * bones from the returned array directly. To add a bone, use the addBone: method.
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
 * This value is a count of the number of vertices, not of the number of underlying
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

/**
 * Returns whether this skin section contains the specified vertex index.
 *
 * It does if the vertex index is equal to or greater than the vertexStart property
 * and less than the the sum of the vertexStart and vertexCount properties.
 */
-(BOOL) containsVertexIndex: (GLint) aVertexIndex;

/**
 * Returns the location of the vertex at the specified index within the mesh,
 * after the vertex location has been deformed by the bone transforms.
 *
 * This implementation retrieves the vertex location from the mesh and transforms
 * it using the matrices and weights defined by the bones in this skin section. 
 */
-(CC3Vector)  deformedVertexLocationAt:  (GLuint) vtxIdx;


#pragma mark Allocation and initialization

/** Initializes an instance that will be used by the specified skin mesh node. */
-(id) initForNode: (CC3SkinMeshNode*) aNode;

/**
 * Allocates and initializes an autoreleased instance that will be used
 * by the specified skin mesh node.
 */
+(id) skinSectionForNode: (CC3SkinMeshNode*) aNode;

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
 *   - the modelview matrix of the scene (MV)
 *   - the transform of the bone (B), relative to the scene
 *   - the inverse transform of the rest pose of the bone (Br(-1)), relative to the scene
 *   - the transform of the skin mesh node (M)
 * 
 * as follows, with * representing matrix multiplication:
 *
 *   MV * B * Br(-1) * M
 * 
 * In practice, to avoid calculating the inverse transform for the rest pose of each bone
 * on every frame render, we can separate the rest pose of the bone and the skin mesh node
 * each into two components: the transform of the CC3SoftBodyNode, relative to the
 * scene, and the transform of the bone and skin mesh node relative to the CC3SoftBodyNode.
 * The above matrix calculation can be expanded and then reduced as follows, with:
 *   - the modelview matrix of the scene (MV)
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
	CC3Matrix* restPoseInvertedMatrix;
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
@property(nonatomic, retain, readonly) CC3Matrix* restPoseInvertedMatrix;

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
-(void) applyPoseTo: (CC3Matrix*) boneMatrix;
 
@end


#pragma mark -
#pragma mark CC3SkinnedBone

/**
 * CC3SkinnedBone combines the transforms of a bone and a skin mesh node,
 * and applies these transforms to deform the vertices during rendering,
 * or when the deformed location of a vertex is accessed programmatically.
 *
 * An instance keeps track of two related transform matrices, a drawTransformMatrix,
 * which is used by the GL engine to deform the vertices during drawing, and a
 * skinTransformMatrix, which is used to deform a vertex into the local coordinate
 * system of the skin mesh node, so that it can be used programmatically.
 *
 * The CC3SkinnedBone instance registers as a transform listener with both the
 * bone and the skin mesh node, and lazily recalculates the drawTransformMatrix
 * and skinTransformMatrix whenever the transform of either the bone or the skin
 * mesh node changes.
 */
@interface CC3SkinnedBone : NSObject <CC3NodeTransformListenerProtocol> {
	CC3Bone* bone;
	CC3SkinMeshNode* skinNode;
	CC3Matrix* drawTransformMatrix;
	CC3Matrix* skinTransformMatrix;
	BOOL isDrawTransformDirty : 1;
	BOOL isSkinTransformDirty : 1;
}

/** Returns the bone whose transforms are being tracked. */
@property(nonatomic, assign, readonly) CC3Bone* bone;

/** Returns the skin mesh node whose transforms are being tracked. */
@property(nonatomic, assign, readonly) CC3SkinMeshNode* skinNode;

/**
 * Returns the transform matrix used to draw the deformed nodes during mesh rendering.
 * This transform matrix combines the transform of the bone, the rest pose of the
 * bone, and the rest pose of the skin mesh node.
 *
 * This transform matrix is lazily recomputed the first time this property is
 * accessed after the transform is marked dirty via the markTransformDirty method.
 * This occurs automatically when either the bone or the skin mesh node being
 * tracked by this instance is transformed.
 */
@property(nonatomic, retain, readonly) CC3Matrix* drawTransformMatrix;

/**
 * Returns the transform matrix used to deform vertex locations when retrieved from
 * the mesh for use by the application. This transform matrix combines the transform
 * of the drawTransformMatrix with the inverse transform of the skin mesh node.
 *
 * The transform matrix returned can be applied to a mesh vertex location to determine
 * its location after deformation, in the local coordinate system of the skin mesh node.
 *
 * This transform matrix is lazily recomputed the first time this property is
 * accessed after the transform is marked dirty via the markTransformDirty method.
 * This occurs automatically when either the bone or the skin mesh node being
 * tracked by this instance is transformed.
 */
@property(nonatomic, retain, readonly) CC3Matrix* skinTransformMatrix;

/**
 * Marks the transform matrices as dirty.
 *
 * Once marked as dirty each of the drawTransformMatrix and skinTransformMatrix matrices
 * will be lazily recalculated the next time its respective property is accessed.
 *
 * This method is invoked automatically when the transform of either the bone or the
 * skin mesh node being tracked by this instance is transformed. The application should
 * never need to invoke this method directly.
 */
-(void) markTransformDirty;


#pragma mark Allocation and initialization

/** Initializes this instance to apply the specified bone to the specified skin mesh node. */
-(id) initWithSkin: (CC3SkinMeshNode*) aNode onBone: (CC3Bone*) aBone;

/**
 * Allocates and initializes an autoreleased instance to
 * apply the specified bone to the specified skin mesh node.
 */
+(id) skinnedBoneWithSkin: (CC3SkinMeshNode*) aNode onBone: (CC3Bone*) aBone;

@end

#pragma mark -
#pragma mark CC3DeformedFaceArray

/**
 * CC3DeformedFaceArray extends CC3FaceArray to hold the deformed positions of each
 * vertex. From this, the deformed shape and orientation of each face in the mesh
 * can be retrieved.
 *
 * If configured to cache the face data (if the shouldCacheFaces is set to YES),
 * the instance will register as a transform listener with the skin mesh node,
 * so that the faces can be rebuilt if the skin mesh node or any of the bones move.
 */
@interface CC3DeformedFaceArray : CC3FaceArray {
	CC3SkinMeshNode* node;
	CC3Vector* deformedVertexLocations;
	BOOL deformedVertexLocationsAreRetained : 1;
	BOOL deformedVertexLocationsAreDirty : 1;
}

/**
 * The skin mesh node containing the vertices for which this face array is managing faces.
 *
 * Setting this property will also set the mesh property, and will cause the
 * deformedVertexLocations, centers, normals, planes and neighbours properties
 * to be deallocated and then re-built on the next access.
 */
@property(nonatomic, assign) CC3SkinMeshNode* node;

/**
 * Indicates the number of vertices in the deformedVertexLocations array,
 * as retrieved from the mesh.
 *
 * The value of this property will be zero until either the node or mesh properties are set.
 */
@property(nonatomic, readonly) GLuint vertexCount;

/**
 * An array containing the vertex locations of the underlying mesh,
 * as deformed by the current position and orientation of the bones.
 *
 * This property will be lazily initialized on the first access after the node
 * property has been set, by an automatic invocation of the populateDeformedVertexLocations
 * method. When created in this manner, the memory allocated to hold the data in
 * the returned array will be managed by this instance.
 *
 * Alternately, this property may be set directly to an array that was created
 * externally. In this case, the underlying data memory is not managed by this
 * instance, and it is up to the application to manage the allocation and
 * deallocation of the underlying data memory, and to ensure that the array is
 * large enough to contain the number of CC3Vector structures specified by
 * the vertexCount property.
 */
@property(nonatomic, assign) CC3Vector* deformedVertexLocations;

/**
 * Returns the deformed vertex location of the face at the specified vertex index,
 * that is contained in the face with the specified index, lazily initializing the
 * deformedVertexLocations property if needed.
 */
-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex;

/**
 * Populates the contents of the deformedVertexLocations property from the associated
 * mesh, automatically allocating memory for the property if needed.
 *
 * This method is invoked automatically on the first access of the deformedVertexLocations
 * property after the node property has been set. Usually, the application never needs to
 * invoke this method directly.
 *
 * However, if the deformedVertexLocations property has been set to an array created
 * outside this instance, this method may be invoked to populate that array from the mesh.
 */
-(void) populateDeformedVertexLocations;

/**
 * Allocates underlying memory for the deformedVertexLocations property, and returns
 * a pointer to the allocated memory.
 *
 * This method will allocate enough memory for the deformedVertexLocations property
 * to hold the number of CC3Vector structures specified by the vertexCount property.
 *
 * This method is invoked automatically by the populateDeformedVertexLocations
 * method. Usually, the application never needs to invoke this method directly.
 *
 * It is safe to invoke this method more than once, but understand that any 
 * previously allocated memory will be safely released prior to the allocation
 * of the new memory. The memory allocated earlier will therefore be lost and
 * should not be referenced.
 * 
 * The memory allocated will automatically be released when this instance
 * is deallocated.
 */
-(CC3Vector*) allocateDeformedVertexLocations;

/**
 * Deallocates the underlying memory that was previously allocated with the
 * allocateDeformedVertexLocations method. It is safe to invoke this method
 * more than once, or even if the allocateDeformedVertexLocations method was
 * not previously invoked.
 *
 * This method is invoked automatically when allocateDeformedVertexLocations
 * is invoked, and when this instance is deallocated. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) deallocateDeformedVertexLocations;

/** Marks the deformed vertices data as dirty. It will be automatically repopulated on the next access. */
-(void) markDeformedVertexLocationsDirty;

/**
 * Clears any caches that contain deformable information.
 *
 * This includes deformed vertices, plus face centers, normals and planes.
 */
-(void) clearDeformableCaches;

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


#pragma mark -
#pragma mark CC3Node skinning extensions

/** CC3Node extension to support ancestors and descendants that make use of vertex skinning. */
@interface CC3Node (Skinning)

/** @deprecated The transform matrix now keeps track of whether it is a rigid transform. */
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

/**
 * Returns the nearest structural ancestor node that is a soft-body node,
 * or returns nil if no ancestor nodes are soft-body nodes.
 */
@property(nonatomic, readonly) CC3SoftBodyNode* softBodyNode;

/**
 * Convenience method to cause the vertex matrix index data of this node and all descendant
 * nodes to be retained in application memory when releaseRedundantData is invoked, even if
 * it has been buffered to a GL VBO.
 *
 * Only the vertex matrix index will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexMatrixIndices;

/**
 * Convenience method to cause the vertex matrix index data of this node and all
 * descendant nodes to be skipped when createGLBuffers is invoked. The vertex data
 * is not buffered to a GL VBO, is retained in application memory, and is submitted
 * to the GL engine on each frame render.
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
 * Convenience method to cause the vertex weight data of this node and all descendant
 * nodes  to be retained in application memory when releaseRedundantData is invoked,
 * even if it has been buffered to a GL VBO.
 *
 * Only the vertex weight will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexWeights;

/**
 * Convenience method to cause the vertex weight data of this node and all descendant
 * nodes to be skipped when createGLBuffers is invoked. The vertex data is not buffered
 * to a GL VBO, is retained in application memory, and is submitted to the GL engine on
 * each frame render.
 *
 * Only the vertex weight will not be buffered to a GL VBO. Any other vertex data, such
 * as locations, or texture coordinates, will be buffered to a GL VBO when createGLBuffers
 * is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexWeights method.
 */
-(void) doNotBufferVertexWeights;

@end


#pragma mark -
#pragma mark CC3MeshNode skinning extensions

/** CC3MeshNode extension to define polymorphic methods to support vertex skinning. */
@interface CC3MeshNode (Skinning)


#pragma mark Faces

/**
 * Returns the face from the mesh at the specified index.
 * 
 * If the vertices of this mesh node represent the skin covering the bones of a 
 * soft-body, the vertex locations of the returned face take into consideration the
 * current deformation caused by motion of the bones underlying the this skin mesh.
 * Otherwise, this method returns the same value as the faceAt: method.
 *
 * In either case, the vertex locations of the returned face are specified in the
 * local coordinate system of this node.
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
 */
-(CC3Face) deformedFaceAt: (GLuint) faceIndex;

/**
 * Returns the center of the mesh face at the specified index.
 * 
 * If the vertices of this mesh node represent the skin covering the bones of a 
 * soft-body, the returned location takes into consideration the current deformation
 * caused by motion of the bones underlying the this skin mesh. The returned location
 * is the center of the face in its location and orientation after the skin has been
 * deformed by the current position of the underlying bones. Otherwise, this method
 * returns the same value as the faceCenterAt: method.
 *
 * In either case, the returned face center is specified in the local coordinate
 * system of this node.
 */
-(CC3Vector) deformedFaceCenterAt: (GLuint) faceIndex;

/**
 * Returns the normal of the mesh face at the specified index.
 * 
 * If the vertices of this mesh node represent the skin covering the bones of a 
 * soft-body, the returned normal takes into consideration the current deformation
 * caused by motion of the bones underlying the this skin mesh. The returned vector
 * is the normal of the face in its orientation after the skin has been deformed
 * by the current position of the underlying bones. Otherwise, this method returns
 * the same value as the faceNormalAt: method.
 * 
 * In either case, the returned face normal is specified in the local coordinate
 * system of this node.
 */
-(CC3Vector) deformedFaceNormalAt: (GLuint) faceIndex;

/**
 * Returns the plane of the mesh face at the specified index.
 * 
 * If the vertices of this mesh node represent the skin covering the bones of a 
 * soft-body, the returned plane takes into consideration the current deformation
 * caused by motion of the bones underlying the this skin mesh. The returned plane
 * is the plane of the face in its location and orientation after the skin has been
 * deformed by the current position of the underlying bones. Otherwise, this method
 * returns the same value as the facePlaneAt: method.
 * 
 * In either case, the returned face plane is specified in the local coordinate
 * system of this node.
 */
-(CC3Plane) deformedFacePlaneAt: (GLuint) faceIndex;

/**
 * Returns the vertex from the mesh at the specified vtxIndex, that is within the
 * face at the specified faceIndex.
 * 
 * If the vertices of this mesh node represent the skin covering the bones of a 
 * soft-body, the returned vertex location takes into consideration the current
 * deformation caused by motion of the bones underlying the this skin mesh.
 * Otherwise, this method returns the same value as the vertexLocationAt: method.
 *
 * In either case, the returned vertex location is specified in the local coordinate
 * system of this node.
 *
 * The specified faceIndex value refers to the index of the face that contains the
 * vertex. It is required to determine the skin section whose bones are deforming
 * the vertex location at the specified vertex index. The specified faceIndex must
 * be between zero, inclusive, and the value of the faceCount property, exclusive.
 *
 * The specified vtxIndex must be between zero, inclusive, and the value of the
 * vertexCount property, exclusive.
 */
-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex;

@end


#pragma mark -
#pragma mark CC3Mesh skinning extensions

/** CC3Mesh extension to define polymorphic methods to support vertex skinning. */
@interface CC3Mesh (Skinning)

/** Indicates whether this mesh contains data for vertex weights. */
@property(nonatomic, readonly) BOOL hasVertexWeights;

/** @deprecated Replaced by hasVertexWeights. */
@property(nonatomic, readonly) BOOL hasWeights DEPRECATED_ATTRIBUTE;

/** Indicates whether this mesh contains data for vertex matrix indices. */
@property(nonatomic, readonly) BOOL hasVertexMatrixIndices;

/** @deprecated Replaced by hasVertexMatrixIndices. */
@property(nonatomic, readonly) BOOL hasMatrixIndices DEPRECATED_ATTRIBUTE;


#pragma mark Accessing vertex data

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

/**
 * Returns the number of vertex units used by this skin mesh. This value indicates
 * how many bones influence each vertex, and corresponds to the number of weights
 * and matrix indices attached to each vertex.
 */
@property(nonatomic, readonly) GLuint vertexUnitCount;

/**
 * Returns the weight element, for the specified vertex unit, at the specified index in
 * the underlying vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding to
 * one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat) vertexWeightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index;

/**
 * Sets the weight element, for the specified vertex unit, at the specified index in
 * the underlying vertex data, to the specified value.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding to
 * one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexWeightsGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index;

/**
 * Returns a pointer to an array of the weight elements at the specified vertex
 * index in the underlying vertex data.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The number of
 * elements in the returned array is the same for all vertices in this mesh, and
 * can be retrieved from the vertexUnitCount property.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct elements.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat*) vertexWeightsAt: (GLuint) index;

/**
 * Sets the weight elements at the specified vertex index in the underlying vertex data,
 * to the values in the specified array.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * Several weights are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The number of
 * weight elements is the same for all vertices in this mesh, and can be retrieved
 * from the vertexUnitCount property. The number of elements in the specified input
 * array must therefore be at least as large as the value of the vertexUnitCount property.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexWeightsGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexWeights: (GLfloat*) weights at: (GLuint) index;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexWeightsGLBuffer;

/**
 * Returns the matrix index element, for the specified vertex unit, at the specified
 * index in the underlying vertex data.
 *
 * Several matrix indices are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLuint) vertexMatrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index;

/**
 * Sets the matrix index element, for the specified vertex unit, at the specified index
 * in the underlying vertex data, to the specified value.
 *
 * Several matrix indices are stored for each vertex, one per vertex unit, corresponding
 * to one for each bone that influences the location of the vertex. The specified vertexUnit
 * parameter must be between zero inclusive, and the vertexUnitCount property, exclusive.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexMatrixIndicesGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexMatrixIndex: (GLuint) aMatrixIndex
			   forVertexUnit: (GLuint) vertexUnit
						  at: (GLuint) index;

/**
 * Returns a pointer to an array of the matrix indices at the specified vertex
 * index in the underlying vertex data.
 *
 * Several matrix index values are stored for each vertex, one per vertex unit,
 * corresponding to one for each bone that influences the location of the vertex.
 * The number of elements in the returned array is the same for all vertices in
 * this mesh, and can be retrieved from the vertexUnitCount property.
 * 
 * The matrix indices can be stored in this mesh as either type GLushort or type
 * GLubyte. The returned array will be of the type of index stored by this vertex
 * array, and it is up to the application to know which type will be returned,
 * and cast the returned array accordingly. The type can be determined by the
 * matrixIndexType property of this mesh, which will return one of GL_UNSIGNED_SHORT
 * or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the matrixIndexType property altogether, you can use the
 * vertexMatrixIndexForVertexUnit:at: method, which retrieves the matrix index
 * values one at a time, and automatically converts the stored type to GLushort.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct elements.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLvoid*) vertexMatrixIndicesAt: (GLuint) index;

/**
 * Sets the matrix index elements at the specified vertex index in the underlying
 * vertex data, to the values in the specified array.
 *
 * Several matrix index values are stored for each vertex, one per vertex unit,
 * corresponding to one for each bone that influences the location of the vertex.
 * The number of elements is the same for all vertices in this mesh, and can be
 * retrieved from the vertexUnitCount property. The number of elements in the specified input
 * array must therefore be at least as large as the value of the vertexUnitCount property.
 * 
 * The matrix indices can be stored in this mesh as either type GLushort or type GLubyte.
 * The specified array must be of the type of index stored by this mesh, and it is up to the
 * application to know which type is required, and provide that type of array accordingly.
 * The type can be determined by the matrixIndexType property of this mesh, which will
 * return one of GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the matrixIndexType property altogether, you can use the
 * setVertexMatrixIndex:forVertexUnit:at: method, which sets the matrix index
 * values one at a time, and automatically converts the input type to the
 * correct stored type.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexMatrixIndicesGLBuffer method to ensure that the GL VBO that
 * holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index;

/**
 * Returns the type of data stored for each bone matrix index.
 *
 * The value returned by this property will be either GL_UNSIGNED_SHORT or
 * GL_UNSIGNED_BYTE, corresponding to each matrix index being stored in either
 * a type GLushort or type GLubyte, respectively.
 */
@property(nonatomic, readonly) GLenum matrixIndexType;

/** Updates the GL engine buffer with the vertex weight data in this mesh. */
-(void) updateVertexMatrixIndicesGLBuffer;

@end

