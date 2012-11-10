/*
 * CC3PODResource.h
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


#import "CC3Resource.h"
#import "CC3PVRFoundation.h"
#import "CC3Camera.h"
#import "CC3MeshNode.h"
#import "CC3Light.h"
#import "CC3Material.h"


/**
 * CC3PODResource is a CC3Resource that wraps a PVR POD data structure loaded from a file.
 * It handles loading object data from POD files, and creating CC3Nodes from that data.
 * This class is the cornerstone of POD file management, and is typically one of only two
 * POD-based classes that your application needs to be aware of, the other being
 * CC3PODResourceNode, which is a CC3ResourceNode that, in turn, wraps an instance
 * of this class. 
 *
 * CC3PODResource includes many properties and methods geared towards extracing object
 * data from the underlying complex POD resource structure. However, most of the properties
 * and methods exist as template methods to support internal behaviour and for overriding
 * in subclasses that might customize object creation from the POD data.
 *
 * Basic use of this class is straightforward:
 *   -# Allocate and initialize the CC3PODResource instance and load a POD file into the
 *      internal structures. This action also builds all the objects from the resource
 *      data structures (depending on the initializer used, loading can be triggered from
 *      the initializer, or can be performed separately).
 *   -# Access the nodes property to retrieve the fully-built node assembly.
 *
 * The array of nodes accessible via the nodes property are the root nodes of a hierarchical
 * structure of nodes. The loading step takes care of assembling this structural assembly.
 *
 * If this resource contains soft-body components such as skinned meshes, the corresponding
 * skinned mesh nodes and skeleton bone nodes are collected together and wrapped in a single
 * soft body node that appears in the nodes array.
 * 
 * In addition to this core functionality, this class includes many methods for accessing
 * data structures within the resource, and extracting object content from those data
 * structures, should the application have the need to do so. However, in almost all cases,
 * the basic two-step process of loading and retrieving the node assembly is all that is needed.
 *
 * Much of the building of the node assembly from the underlying data strucutres is handled
 * in template methods that are identified here in the interface for ease of overriding in
 * a customized subclass. Although not necessary, some applications may find it necessary
 * or convenient to override one or more of these template methods to modify the objects that
 * are extracted from the underlying file data, perhaps customizing them for the application,
 * or correcting idiosyncracies that might have been exported into the POD file from a 3D
 * editor. This capability can be useful if you are using a POD file of a 3D model that you
 * did not create yourself, and cannot edit.
 *
 * When customizing a subclass to change the properties of the objects returned, you will
 * most likely override one or more of the following methods:
 *   - buildMeshNodeAtIndex:
 *   - buildLightAtIndex:
 *   - buildCameraAtIndex:
 *   - buildStructuralNodeAtIndex:
 *   - buildMaterialAtIndex:
 *   - buildTextureAtIndex:
 *
 * In most cases, the overridden method can simply invoke the superclass implementation
 * on this class, and then change the properties of the extracted object. In other cases
 * you may want to extract and return a customized subclass of the object of interest.
 */
@interface CC3PODResource : CC3Resource {
	PODClassPtr pvrtModel;
	CCArray* allNodes;
	CCArray* meshes;
	CCArray* materials;
	CCArray* textures;
	ccTexParams textureParameters;
}

/**
 * The underlying C++ CPVRTModelPOD class. It is defined here as a generic pointer
 * so that it can be imported into header files without the need for the including
 * file to support C++ This must be cast to a pointer to CPVRTModelPOD before accessing
 * any elements within the class.
 */
@property(nonatomic, readonly) PODClassPtr pvrtModel;

/**
 * The total number of nodes in the POD file.
 * This is also the count of the allNodes array.
 */
@property(nonatomic, readonly) uint nodeCount;

/**
 * A collection of all of the nodes extracted from the POD file.
 * This is the equivalent of flattening the nodes array.
 */
@property(nonatomic, readonly) CCArray* allNodes;

/** The total number of mesh nodes in the POD file. */
@property(nonatomic, readonly) uint meshNodeCount;

/** The total number of lights in the POD file. */
@property(nonatomic, readonly) uint lightCount;

/** The total number of cameras in the POD file. */
@property(nonatomic, readonly) uint cameraCount;

/**
 * The total number of meshes in the POD file. This is different than the
 * meshNodeCount because mesh models may be used by more than one mesh node.
 */
@property(nonatomic, readonly) uint meshCount;

/** A collection of the CC3Meshs extracted from  the POD file. */
@property(nonatomic, readonly) CCArray* meshes;

/** The number of materials in the POD file. */
@property(nonatomic, readonly) uint materialCount;

/** A collection of the CC3Materials extracted from  the POD file. */
@property(nonatomic, readonly) CCArray* materials;

/** The number of different textures in the POD file. */
@property(nonatomic, readonly) uint textureCount;

/** A collection of the CC3Textures extracted from  the POD file. */
@property(nonatomic, readonly) CCArray* textures;

/** @deprecated Use the CC3Texture class-side property defaultTextureParameters instead. */
@property(nonatomic, assign) ccTexParams textureParameters DEPRECATED_ATTRIBUTE;

/** The number of frames of animation in the POD file. */
@property(nonatomic, readonly) uint animationFrameCount;

/** The global ambient light of the scene in the POD file. */
@property(nonatomic, readonly) ccColor4F ambientLight;

/** The background color of the scene in the POD file. */
@property(nonatomic, readonly) ccColor4F backgroundColor;


#pragma mark Allocation and initialization

/**
 * Template method that extracts and builds all components. This is automatically
 * invoked from the loadFromPODFile: method if the POD file was successfully loaded.
 * The application should not invoke this method directly.
 * 
 * The order of component extraction and building is:
 *   - textures, by invoking the buildTextures template method
 *   - materials, by invoking the buildMaterials template method
 *   - mesh models, by invoking the buildMeshes template method
 *   - nodes, by invoking the buildNodes template method
 *   - a soft body node if needed
 *
 * This template method can be overridden in a subclass if specialized processing is required.
 */
-(void) build;


#pragma mark Accessing node data and building nodes

/** Returns the node at the specified index in the allNodes array. */
-(CC3Node*) nodeAtIndex: (uint) nodeIndex;

/** Returns the node with the specified name from the allNodes array. */
-(CC3Node*) nodeNamed: (NSString*) aName;

/**
 * Template method that extracts and builds the nodes from the underlying data.
 * This is automatically invoked from the build method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass if specialized processing is required.
 */
-(void) buildNodes;

/**
 * Builds the node at the specified index. Checks the type of node, and invokes one
 * of the following template methods:
 *   - buildMeshNodeAtIndex:
 *   - buildLightAtIndex:
 *   - buildCameraAtIndex:
 *   - buildStructuralNodeAtIndex:
 *
 * This is automatically invoked from the buildNodes method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass if specialized processing is required.
 */
-(CC3Node*) buildNodeAtIndex: (uint) nodeIndex;

/**
 * Builds the structural node at the specified index.
 * 
 * This is automatically invoked from the buildNodeAtIndex: method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass to adjust the properties
 * of the new node. The subclass can invoke this superclass method, and then change
 * properties as required.
 */
-(CC3Node*) buildStructuralNodeAtIndex: (uint) nodeIndex;

/**
 * Returns the underlying SPODNode data structure from the POD file, for the SPODNode
 * at the specified index.
 *
 * The returned pointer must be cast to SPODNode before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) nodePODStructAtIndex: (uint) nodeIndex;

/**
 * Returns whether the specified node index is an ancestor of the specified
 * child node index. If it is, once the nodes are assembled into their structural
 * hierarchy, the node with the specified child index will be a descendant of the
 * specified node index.
 */
-(BOOL) isNodeIndex: (int) aNodeIndex ancestorOfNodeIndex: (int) childIndex;

/**
 * Returns whether the specified node index represents a bone node that is part
 * of a skeleton node assembly that will be used to control vertex skinning.
 */
-(BOOL) isBoneNode: (uint) nodeIndex;

/**
 * If this resource contains soft-body components such as skinned meshes, the corresponding
 * skinned mesh nodes and skeleton bone nodes are collected together and wrapped in a single
 * soft body node.
 */
-(void) buildSoftBodyNode;


#pragma mark Accessing mesh data and building mesh nodes

/**
 * Returns the meshIndex'th mesh node.
 * Note that meshIndex is an ordinal number indicating the rank of the mesh node,
 * and is not a direct index into the allNodes array.
 */
-(CC3MeshNode*) meshNodeAtIndex: (uint) meshIndex;

/**
 * Builds the meshIndex'th mesh node.
 * Note that meshIndex is an ordinal number indicating the rank of the mesh node.
 * 
 * This is automatically invoked from the buildNodeAtIndex: method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass to adjust the properties
 * of the new node. The subclass can invoke this superclass method, and then change
 * properties as required.
 */
-(CC3MeshNode*) buildMeshNodeAtIndex: (uint) meshIndex;

/**
 * Returns the SPODNode structure of the meshIndex'th mesh node.
 * Note that meshIndex is an ordinal number indicating the rank of the mesh node.
 *
 * The returned pointer must be cast to SPODNode before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) meshNodePODStructAtIndex: (uint) meshIndex;

/**
 * Returns the meshIndex'th mesh.
 * Note that meshIndex is an ordinal number indicating the rank of the mesh.
 */
-(CC3Mesh*) meshAtIndex: (uint) meshIndex;

/** @deprecated Renamed to meshAtIndex:. */
-(CC3Mesh*) meshModelAtIndex: (uint) meshIndex DEPRECATED_ATTRIBUTE;

/**
 * Template method that extracts and builds the meshes from the underlying data.
 * This is automatically invoked from the build method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass if specialized processing is required.
 */
-(void) buildMeshes;

/**
 * Builds the meshIndex'th mesh.
 * Note that meshIndex is an ordinal number indicating the rank of the mesh.
 */
-(CC3Mesh*) buildMeshAtIndex: (uint) meshIndex;

/**
 * Returns meshIndex'th SPODMesh structure from the data structures.
 * Note that meshIndex is an ordinal number indicating the rank of the mesh.
 *
 * The returned pointer must be cast to SPODMesh before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) meshPODStructAtIndex: (uint) meshIndex;


#pragma mark Accessing light data and building light nodes

/**
 * Returns the lightIndex'th light node.
 * Note that lightIndex is an ordinal number indicating the rank of the light node,
 * and is not a direct index into the allNodes array.
 */
-(CC3Light*) lightAtIndex: (uint) lightIndex;

/**
 * Builds the lightIndex'th light node.
 * Note that lightIndex is an ordinal number indicating the rank of the light node.
 * 
 * This is automatically invoked from the buildNodeAtIndex: method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass to adjust the properties
 * of the new node. The subclass can invoke this superclass method, and then change
 * properties as required.
 */
-(CC3Light*) buildLightAtIndex: (uint) lightIndex;

/**
 * Returns the SPODNode structure of the lightIndex'th light node.
 * Note that lightIndex is an ordinal number indicating the rank of the light node.
 *
 * The returned pointer must be cast to SPODNode before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) lightNodePODStructAtIndex: (uint) lightIndex;

/**
 * Returns lightIndex'th SPODLight structure from the data structures.
 *
 * The returned pointer must be cast to SPODLight before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) lightPODStructAtIndex: (uint) lightIndex;


#pragma mark Accessing cameras data and building camera nodes

/**
 * Returns the cameraIndex'th camera node.
 * Note that cameraIndex is an ordinal number indicating the rank of the camera node,
 * and is not a direct index into the allNodes array.
 */
-(CC3Camera*) cameraAtIndex: (uint) cameraIndex;

/**
 * Builds the cameraIndex'th camera node.
 * Note that cameraIndex is an ordinal number indicating the rank of the camera node.
 * 
 * This is automatically invoked from the buildNodeAtIndex: method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass to adjust the properties
 * of the new node. The subclass can invoke this superclass method, and then change
 * properties as required.
 */
-(CC3Camera*) buildCameraAtIndex: (uint) cameraIndex;

/**
 * Returns the SPODNode structure of the cameraIndex'th light node.
 * Note that cameraIndex is an ordinal number indicating the rank of the camera node.
 *
 * The returned pointer must be cast to SPODNode before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) cameraNodePODStructAtIndex: (uint) cameraIndex;

/**
 * Returns cameraIndex'th SPODCamera structure from the data structures.
 *
 * The returned pointer must be cast to SPODCamera before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) cameraPODStructAtIndex: (uint) cameraIndex;


#pragma mark Accessing material data and building materials

/**
 * Returns the materialIndex'th material.
 * Note that materialIndex is an ordinal number indicating the rank of the material.
 */
-(CC3Material*) materialAtIndex: (uint) materialIndex;

/** Returns the material with the specified name from the materials array. */
-(CC3Material*) materialNamed: (NSString*) aName;

/**
 * Template method that extracts and builds the materials from the underlying data.
 * This is automatically invoked from the build method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass if specialized processing is required.
 */
-(void) buildMaterials;

/**
 * Builds the materialIndex'th material.
 * Note that materialIndex is an ordinal number indicating the rank of the material.
 * 
 * This is automatically invoked from the buildMaterials method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass to adjust the properties
 * of the new node. The subclass can invoke this superclass method, and then change
 * properties as required.
 */
-(CC3Material*) buildMaterialAtIndex: (uint) materialIndex;

/**
 * Returns materialIndex'th SPODMaterial structure from the data structures.
 * Note that materialIndex is an ordinal number indicating the rank of the material.
 *
 * The returned pointer must be cast to SPODMaterial before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) materialPODStructAtIndex: (uint) materialIndex;


#pragma mark Accessing texture data and building textures

/**
 * Returns the textureIndex'th texture.
 * Note that textureIndex is an ordinal number indicating the rank of the texture.
 */
-(CC3Texture*) textureAtIndex: (uint) textureIndex;

/**
 * Template method that extracts and builds the textures from the underlying data.
 * This is automatically invoked from the build method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass if specialized processing is required.
 */
-(void) buildTextures;

/**
 * Builds the textureIndex'th texture.
 * Note that textureIndex is an ordinal number indicating the rank of the texture.
 * 
 * This is automatically invoked from the buildTextures method.
 * The application should not invoke this method directly.
 *
 * This template method can be overridden in a subclass to adjust the properties
 * of the new node. The subclass can invoke this superclass method, and then change
 * properties as required.
 */
-(CC3Texture*) buildTextureAtIndex: (uint) textureIndex;

/**
 * Returns textureIndex'th SPODTexture structure from the data structures.
 * Note that textureIndex is an ordinal number indicating the rank of the texture.
 *
 * The returned pointer must be cast to SPODTexture before accessing any internals of
 * the data structure.
 */
-(PODStructPtr) texturePODStructAtIndex: (uint) textureIndex;

@end
