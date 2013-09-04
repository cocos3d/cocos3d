/*
 * CC3VertexSkinning.h
 *
 * cocos3d 2.0.0
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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

@class CC3Bone, CC3SkinSection, CC3SoftBodyNode, CC3DeformedFaceArray;


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
 * the mesh that makes up the skin. This mesh includes the bone assignments and weights
 * for each vertex, which specifies how the location of each vertex is influenced by the
 * location and orientation of each nearby bone.
 *
 * A single soft-body object may be covered by a single skin mesh, but more complicated
 * objects may be covered by several skin meshes. As such, a single CC3SoftBodyNode
 * instance may contain one or more CC3SkinMeshNode instances.
 * 
 * For efficiency and control, each skin mesh is usually broken into sections. These skin
 * sections are represented by instances of the CC3SkinSection class. A CC3SkinMeshNode
 * typically holds a single mesh and several CC3SkinSection instances to define how that mesh
 * should be divided into sections. Each CC3SkinSection instance contains a range of vertices,
 * and references to the bones in the skeleton that influence the vertices in that range.
 * All of the vertices of a single CC3SkinSection are drawn in a single GL drawing call.
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
 * CC3SkinMeshNode is a CC3MeshNode specialized to use vertex skinning to draw the contents
 * of its mesh. It is one of the key structural descendant nodes of a CC3SoftBodyNode instance.
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
 * When copying a CC3SkinMeshNode as part of copying a CC3SoftBodyNode instance, a copy of
 * the skeleton is also created, and the reattachBonesFrom: method is automatically invoked.
 * When copying CC3SoftBodyNode, you do not need to invoke the reattachBonesFrom: method on
 * the new CC3SkinMeshNode directly.
 *
 * The use of bounding volumes with skinned meshes can be tricky, because the locations of
 * the vertices are affected both by the location of the mesh node, as with any mesh, but
 * also by the location of the bones. In addition, bone transformation is handled by the
 * GPU, and unless the CPU is also tasked with transforming each vertex, it is difficult
 * for the app to know the true range of the vertices.
 *
 * Because of this, the createBoundingVolumes method will be ignored by instances of this
 * class, and a bounding volume will not automatically be assigned to this node, to ensure
 * that the mesh will not be culled when it shouldn't if the automatic bounding volume is
 * not the correct shape. This mesh will therefore be drawn for each frame, even if it is
 * not in front of the camera (ie- inside the camera's frustum).
 *
 * It is left to the application to determine the best approach to managing the assignment
 * of a bounding volume, possibly using one of the following approaches:
 *
 *   - You can choose to leave this node with no bounding volume, and allow it to be drawn
 *     on each frame. This may be the easiest approach if performance is not critical.
 *
 *   - Or, manually create a bounding volume of the right size and shape for the movement of
 *     the vertices from the perspective of a root bone of the skeleton. Assign the bounding
 *     volume to the root bone by using the boundingVolume property on the root bone and,
 *     once it has been assigned a root bone of the skeleton, use the setSkeletalBoundingVolume:
 *     method on an ancestor node of all of the CC3SkinMeshNodes that are to use that bounding
 *     volume, to assign that bounding volume to all of the appropriate CC3SkinMeshNodes.
 *     A good choice to target for the invocation of this method might be the CC3SoftBodyNode
 *     of the model, or even the CC3ResourceNode above it, if loaded from a file. During
 *     development, you can use the shouldDrawBoundingVolume property to make the bounding
 *     volume visible, to aid in determining and setting the right size and shape for it.
 *
 *   - If you know that the vertices of the skinned mesh node will not move beyond the static
 *     bounding volume defined by the vertices in the rest pose, you can invoke the
 *     createBoundingVolume method to have bounding volume created automatically from the rest
 *     pose of the skinned mesh node. If this is a common requirement, you can also use the
 *     createSkinnedBoundingVolumes methods on any ancestor node to have bounding volumes
 *     automatically created for all descendant skinned mesh nodes.
 */
@interface CC3SkinMeshNode : CC3MeshNode {
	CCArray* _skinSections;
	CC3Matrix* _restPoseTransformMatrix;
	CC3DeformedFaceArray* _deformedFaces;
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


#pragma mark Transformations

/**
 * Callback method that will be invoked when the globalTransformMatrix of the specified bone has changed.
 * The transform matrix of this node is marked as dirty, so that the changes are propagated to
 * descendant nodes, such as shadow volumes, and to update the deformedFaces property.
 *
 * This callback is implemented as distinct from the general notification mechanism of the
 * bone because of its importance, and so that this class and its subclasses do not need to
 * distiguish this callback from other notifications that this instance might register for.
 */
-(void) boneWasTransformed: (CC3Bone*) aBone;


#pragma mark Deprecated methods

/** @deprecated Renamed to vertexWeightForVertexUnit:at: */
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to setVertexWeight:forVertexUnit:at: */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexMatrixIndexForVertexUnit:at: */
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to setVertexMatrixIndex:forVertexUnit:at: */
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

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
 * vertexMatrixIndices vertex array of the mesh.
 *
 * Through the CC3VertexMatrixIndices vertex array in the vertexMatrixIndices property
 * of the mesh, each vertex identifies several distinct indices into the bones
 * collection of this skin section. The transform matrices from those bones are
 * combined in a weighted fashion, and used to transform the location of the vertex.
 * Each vertex defines its own set of weights through the CC3VertexWeights vertex
 * array in the vertexWeights property of the mesh.
 */
@interface CC3SkinSection : NSObject <NSCopying> {
	CC3SkinMeshNode* _node;
	CCArray* _skinnedBones;
	GLint _vertexStart;
	GLint _vertexCount;
}

/** Returns the number of bones in this skin section. */
@property(nonatomic, assign, readonly) GLuint boneCount;

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
 * from the CC3OpenGL.sharedGL.maxNumberOfVertexUnits property.
 * 
 * Because different vertices of the skin section may be influenced by different combinations
 * of bones, the number of bones in the collection in this property will generally be larger
 * than the number of bones used per vertex.
 *
 * However, when the vertices are drawn, all of the vertices in this skin section are drawn with
 * a single call to the GL engine. All of the bone transforms that affect any of the vertices
 * being drawn are loaded into the GL engine by this skin section prior to drawing the vertices.
 * 
 * The number of transform matrices that can be simultaneously loaded into the GL engine
 * matrix palette is limited by the platform, and that limit defines the maximum number
 * of bones in the collection in this property. This platform limit can be retrieved from
 * the CC3OpenGL.sharedGL.maxNumberOfPaletteMatrices property.
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
 * from the CC3OpenGL.sharedGL.maxNumberOfPaletteMatrices property.
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

/** Returns a description of this skin section that includes a list of the bones. */
-(NSString*) fullDescription;


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

/**
 * Returns the matrix used to transform the bone at the specified index within this skin
 * section into global coordinates.
 */
-(CC3Matrix*) getDrawTransformMatrixForBoneAt: (GLuint) boneIdx;

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
	CC3Matrix* _restPoseInvertedMatrix;
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
 * The CC3SkinnedBone instance registers as a transform listener with both the bone and the
 * skin mesh node, and lazily recalculates the drawTransformMatrix and skinTransformMatrix
 * whenever the transform of either the bone or the skin mesh node changes.
 */
@interface CC3SkinnedBone : NSObject <CC3NodeTransformListenerProtocol> {
	CC3Bone* _bone;
	CC3SkinMeshNode* _skinNode;
	CC3Matrix* _drawTransformMatrix;
	CC3Matrix* _skinTransformMatrix;
	BOOL _isDrawTransformDirty : 1;
	BOOL _isSkinTransformDirty : 1;
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
 * CC3DeformedFaceArray extends CC3FaceArray to hold the deformed positions of each vertex.
 * From this, the deformed shape and orientation of each face in the mesh can be retrieved.
 *
 * If configured to cache the face data (if the shouldCacheFaces is set to YES),
 * the instance will register as a transform listener with the skin mesh node,
 * so that the faces can be rebuilt if the skin mesh node or any of the bones move.
 */
@interface CC3DeformedFaceArray : CC3FaceArray {
	CC3SkinMeshNode* _node;
	CC3Vector* _deformedVertexLocations;
	BOOL _deformedVertexLocationsAreRetained : 1;
	BOOL _deformedVertexLocationsAreDirty : 1;
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

/**
 * Returns the nearest structural ancestor node that is a soft-body node,
 * or returns nil if no ancestor nodes are soft-body nodes.
 */
@property(nonatomic, readonly) CC3SoftBodyNode* softBodyNode;

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
 * Mesh nodes whose vertices are deformable by bones are not automatically assigned a bounding
 * volume, because the vertices are not completely under control of the mesh node, complicating
 * the definition of the boundary. Creating bounding volumes for skinned mesh nodes is left to
 * the application.
 *
 * If the bones are animated independently from the mesh node, it is possible that the bones
 * will move the entire mesh far away from the mesh node. In this situation, it is better to
 * have the bounding volume controlled by one of the root bones of the model, but still allow
 * the skinned mesh nodes use this bounding volume to determine if the vertices are within
 * the camera's field of view.
 *
 * To do this, manually create a bounding volume of the right size and shape for the movement
 * of the vertices from the perspective of a root bone of the skeleton. Assign the bounding
 * volume to the root bone by using the boundingVolume property, and once it has been assigned
 * to the skeleton, use this method on an ancestor node of all of the skinned mesh nodes that
 * are to use that bounding volume, to assign that bounding volume to all of the appropriate
 * skinned mesh nodes. A good choice to target for the invocation of this method might be the
 * CC3SoftBodyNode of the model, or even the CC3ResourceNode above it, if loaded from a file.
 *
 * During development, you can use the shouldDrawBoundingVolume property to make the bounding
 * volume visible, to aid in determining and setting the right size and shape for it. 
 */
-(void) setSkeletalBoundingVolume: (CC3NodeBoundingVolume*) boundingVolume;

/** Returns the aggregate scale of this node relative to its closest soft-body ancestor. */
@property(nonatomic, readonly) CC3Vector skeletalScale;

/** @deprecated The transform matrix now keeps track of whether it is a rigid transform. */
@property(nonatomic, readonly) BOOL isSkeletonRigid;

/**
 * Invokes the createBoundingVolume on any skinned mesh node descendants.
 *
 * Skinned mesh nodes are designed to move vertices under the control of external bone nodes.
 * Because of this, the vertices might move well beyond the bounds of a static bounding volume
 * created from the rest pose of the skinned mesh node. For this reason, bounding volumes are
 * not generally automatically created for skinned mesh nodes by the createBoundingVolumes
 * method, and the bounding volumes of skinned mesh nodes are typically created by the app,
 * by determining the maximal extent that the vertices will move, and manually assigning a
 * larger bounding volume to cover that full extent.
 *
 * However, if you know that the vertices of the skinned mesh nodes descendants of this node
 * will not move beyond the static bounding volume defined by the vertices in their rest poses,
 * you can invoke this method to have bounding volumes created automatically from the rest
 * poses of each descendant skinned mesh nodes. This method will not affect the bounding
 * volumes of any non-skinned descendant nodes.
 */
-(void) createSkinnedBoundingVolumes;

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
#pragma mark Deprecated CC3SkinMesh

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated Functionality moved to CC3Mesh.
 */
@interface CC3SkinMesh : CC3Mesh

/** @deprecated Renamed to vertexMatrixIndices. */
@property(nonatomic,retain) CC3VertexMatrixIndices* boneMatrixIndices DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexWeights. */
@property(nonatomic,retain) CC3VertexWeights* boneWeights DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexWeightForVertexUnit:at: */
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to setVertexWeight:forVertexUnit:at: */
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to setVertexMatrixIndex:forVertexUnit:at: */
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexMatrixIndexForVertexUnit:at: */
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

@end

