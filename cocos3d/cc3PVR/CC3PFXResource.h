/*
 * CC3PFXResource.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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


/**
 * CC3PFXResource is a CC3Resource that wraps a PVR PFX data structure loaded from a file.
 * It handles loading object data from PFX files, and creating content from that data.
 * This class is the cornerstone of PFX file management.
 *
 // TODO - REWRITE BELOW HERE
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
@interface CC3PFXResource : CC3Resource {
	PFXClassPtr _pvrtPFXParser;
}

/** Returns the number of effects (GLSL programs) contained in this PFX resource. */
@property(nonatomic, readonly) NSUInteger effectCount;

/** Returns the number of vertex shaders contained in this PFX resource. */
@property(nonatomic, readonly) NSUInteger vertexShaderCount;

/** Returns the number of fragment shaders contained in this PFX resource. */
@property(nonatomic, readonly) NSUInteger fragmentShaderCount;

/** Returns the number of textures contained in this PFX resource. */
@property(nonatomic, readonly) NSUInteger textureCount;

/** Returns the number of render passes contained in this PFX resource. */
@property(nonatomic, readonly) NSUInteger renderPassCount;


@end
