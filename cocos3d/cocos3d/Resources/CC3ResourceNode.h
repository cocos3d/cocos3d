/*
 * CC3ResourceNode.h
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
#import "CC3Resource.h"


/**
 * A CC3ResourceNode is a CC3Node that that wraps an instance of CC3Resource in
 * the resource property, extracts the nodes from that resource, and forms the
 * root of the resulting node structural assembly.
 *
 * The underlying CC3Resource instance can either be set directly, or subclasses
 * can override the resourceClass property to allow the resource property to be
 * lazily created when it is first accessed.
 *
 * Once this resource node contains a resource, this resource node can be loaded
 * using the loadFromFile: method.
 *
 * As shortcuts, for subclasses that override the resourceClass property, there
 * are also several class and instance initialization methods for this class that
 * will load the file automatically during instance initialization.
 *
 * However, before using any of these shortcut methods, you should take into
 * consideration whether you need to set the the expectsVerticallyFlippedTextures
 * property prior to loading, as explained here.
 *
 * Under iOS, a texture whose width and height are not each a power-of-two, will be
 * converted to a size whose width and height are a power-of-two. The result is a
 * texture that can have empty space on the top and right sides. If the texture
 * coordinates of the mesh do not take this into consideration, the result will be
 * that only the lower left of the mesh will be covered by the texture.
 * 
 * In addition, the vertical axis of the coordinate system of OpenGL is inverted
 * relative to the iOS view coordinate system. This results in textures being
 * displayed upside-down, relative to the OpenGL coordinate system.
 *
 * The contained CC3Resource will automatically adjust the meshes to compensate for
 * this. Meshes loaded by this resource loader will have their texture coordinates
 * adjusted to align with the usable area of an NPOT texture, and to vertically
 * flip a texture that has been loaded upside-down.
 *
 * To determine whether textures will need to be vertically flipped, the loader
 * needs to know whether or not the meshes have already been flipped (by the 3D
 * editor or file exporter). The expectsVerticallyFlippedTextures property
 * can be set to indicate to the loader whether the texture coordinates have
 * already been flipped. If the value of that property needs to be changed,
 * it should be set before the file is loaded.
 *
 * When a copy is made of a CC3ResourceNode instance, a copy is not made of the
 * encapsulated CC3Resource instance. Instead, the CC3Resource is retained by
 * reference and shared between both the original CC3ResourceNode, and the new copy.
 */
@interface CC3ResourceNode : CC3Node {
	CC3Resource* resource;
}

/**
 * The underlying CC3Resource instance containing the 3D nodes.
 * 
 * Setting this property will remove all child nodes of this CC3ResourceNode
 * and replace them with the nodes extracted from the nodes property of the
 * new CC3Resource instance, if they have already been loaded.
 *
 * If this node has not yet been assigned a name, it will be set to the name
 * of the resource when this property is set.
 *
 * If the resource has not already been loaded when it is set here, it may
 * be loaded using the loadFromFile: methods of this resource node instance.
 * 
 * For subclasses of CC3ResourceNode that override the resourceClass property,
 * if this resource property is not explicitly set, it is lazily created, as an
 * instance of the class identified by the resourceClass property, when this
 * resource property is first accessed. Since the resourceClass property depends
 * on the type of resource file format to be loaded, lazy creation of the resource
 * property from the resourceClass property requires the creation of a subclass
 * of CC3ResourceNode that defines the appropriate resourceClass value.
 */
@property(nonatomic, retain) CC3Resource* resource;

/**
 * Returns the class of the CC3Resource instance used to load 3D data files.
 * This returned value is used by the initializers that load the file,
 * and must be overridden in a sublcass if those initializers are to be used.
 * 
 * Default implementation triggers and assertion and returns CC3Resource.
 * Subclasses must override.
 */
-(Class) resourceClass;

/**
 * Using the contained resource, loads the file at the specified file path,
 * extracts the loaded CC3Nodes from the contained resource, and adds them
 * as child nodes to this resource node.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * If not already set, the name of this node will be set to that of the
 * resource, which is usually the name of the file loaded.
 */
-(void) loadFromFile: (NSString*) aFilepath;

/**
 * Initializes this instance and, using the contained resource, loads the file
 * at the specified file path, extracts the loaded CC3Nodes from the contained
 * resource, and adds them as child nodes to this resource node.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this node will be set to that of the resource, which is
 * usually the name of the file loaded.
 */
-(id) initFromFile: (NSString*) aFilepath;

/**
 * Allocates and initializes an autoreleased instance and, using the contained
 * resource, loads the file at the specified file path, extracts the loaded CC3Nodes
 * from the contained resource, and adds them as child nodes to this resource node.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this node will be set to that of the resource, which is
 * usually the name of the file loaded.
 */
+(id) nodeFromFile: (NSString*) aFilepath;

/**
 * Initializes this instance and, using the contained resource, loads the file
 * at the specified file path, extracts the loaded CC3Nodes from the contained
 * resource, and adds them as child nodes to this resource node.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this node will be set to the specified name.
 */
-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFilepath;

/**
 * Allocates and initializes an autoreleased instance and, using the contained
 * resource, loads the file at the specified file path, extracts the loaded CC3Nodes
 * from the contained resource, and adds them as child nodes to this resource node.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this node will be set to the specified name.
 */
+(id) nodeWithName: (NSString*) aName fromFile: (NSString*) aFilepath;


#pragma mark Aligning texture coordinates to NPOT and iOS-inverted textures

/**
 * Indicates whether the texture coordinates of the meshes that will be loaded
 * by the CC3Resource loader expect that the texture will be flipped upside-down
 * during texture loading.
 *
 * This property is a convenience property that simply gets and sets the same
 * property on the contained CC3Resource instance.
 * 
 * The vertical axis of the coordinate system of OpenGL is inverted relative to
 * the iOS view coordinate system. This results in textures from most file formats
 * being oriented upside-down, relative to the OpenGL coordinate system. All file
 * formats except PVR format will be oriented upside-down after loading.
 *
 * If the value of this property is YES, the texture coordinates of meshes loaded
 * by the CC3Resource will be assumed to have already been flipped vertically,
 * (typically by the 3D editor or file exporter) to align with textures that will
 * be vertically flipped by the texture loader.
 *
 * If the value of this property is NO, the texture coordinates of meshes loaded by
 * the CC3Resource loader will be assumed to have their original orientation, and
 * aligned with textures that have not been vertically flipped by the texture loader.
 *
 * The value of this property is then used to cause the meshes to automatically
 * correctly align themselves with the orientation of any texture applied to them.
 *
 * For meshes that are based on vertex arrays, this property is used to set the
 * same property on each CC3VertexTextureCoordinates instance created and loaded
 * by this resource. When a texture is assigned to cover the mesh, the value of
 * that CC3VertexTextureCoordinates property is used in combination with the value
 * of the isFlippedVertically property of a texture to determine whether the texture
 * coordinates should automatically be reoriented when displaying that texture.
 */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures;


#pragma mark Deprecated file loading methods

/**
 * @deprecated Use the loadFromFile: method instead, which supports both absolute
 * file paths and file paths that are relative to the resources directory.
 */
-(void) loadFromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the initFromFile: method instead, which supports both absolute
 * file paths and file paths that are relative to the resources directory.
 */
-(id) initFromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the nodeFromFile: method instead, which supports both absolute
 * file paths and file paths that are relative to the resources directory.
 */
+(id) nodeFromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the initWithName:FromFile: method instead, which supports both
 * absolute file paths and file paths that are relative to the resources directory.
 */
-(id) initWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the nodeWithName:FromFile: method instead, which supports both
 * absolute file paths and file paths that are relative to the resources directory.
 */
+(id) nodeWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

@end



