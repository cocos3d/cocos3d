/*
 * CC3Resource.h
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


#import "CC3Texture.h"


/**
 * CC3Resource is a wrapper class around a resource structure loaded from a data file
 * containing 3D resources. It handles loading model and texture data from files, and
 * creating CC3Nodes from that data.
 *
 * The loadFromFile: method is used to load this resource. Once this method has been
 * successfully invoked, access to 3D data objects loaded from the file is through
 * the nodes property, which contains the root nodes of a structural 3D node assembly
 * constructed from the 3D data loaded from the file.
 *
 * As shortcuts, there are also class and instance initialization methods that will
 * invoke the loadFromFile: method automatically during instance initialization.
 *
 * However, before using any of these shortcut methods, you should take into
 * consideration whether you need to set the directory or expectsVerticallyFlippedTextures
 * properties prior to loading, as explained here.
 *
 * By default, additional resources (typically textures), are loaded from the same
 * directory that the file containing the content of this resource is located.
 * If this is not the case, you can set the directory property prior to invoking
 * the loadFromFile: method, in order to establish another directory from which
 * additional resources such as textures will be loaded.
 *
 * You do not need to set the directory property if these additional resources
 * are in the same directory as the file loaded by this resource.
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
 * This instance will automatically adjust the meshes to compensate for this.
 * Meshes loaded by this resource loader will have their texture coordinates
 * adjusted to align with the usable area of an NPOT texture, and to vertically
 * flip a texture that has been loaded upside-down.
 *
 * To determine whether textures will need to be vertically flipped, the loader
 * needs to know whether or not the meshes have already been flipped (by the 3D
 * editor or file exporter). The expectsVerticallyFlippedTextures property
 * can be set to indicate to the loader whether the texture coordinates have
 * already been flipped. If the value of this property needs to be changed,
 * it should be set before the file is loaded.
 *
 * The class-side property defaultExpectsVerticallyFlippedTextures can be
 * used to set all instances to load one way or the other.
 *
 * This is an abstract class. Specific subclasses will load files of specific types.
 *
 * Subclasses must override the primitive template method processFile:. All other
 * loading and initialization methods defined by this class are implemented using
 * this primitive method, and subclasses do not need to override any of these other
 * loading and initialization methods.
 *
 * Subclasses should ensure that the nodes array property is fully populated upon
 * successful completion of the processFile: method.
 */
@interface CC3Resource : CC3Identifiable {
	CCArray* nodes;
	NSString* directory;
	BOOL expectsVerticallyFlippedTextures : 1;
	BOOL wasLoaded : 1;
}

/**
 * A collection of the root nodes of the node assembly extracted from the file.
 * Each of these nodes will usually contain child nodes.
 */
@property(nonatomic, readonly) CCArray* nodes;

/**
 * The directory where additional resources (typically textures) can be found.
 *
 * By default, this property will be set to the directory where the resource
 * file is located, as indicated by the file path provided when the loadFromFile:
 * method is invoked.
 *
 * The application may set this property to a different directory if appropriate,
 * but must do so before the loadFromFile: method is invoked.
 */
@property(nonatomic, retain) NSString* directory;

/**
 * Indicates whether the resource has been successfully loaded.
 *
 * The initial value of this property is NO, but will change to YES if the
 * loadFromFile: method successfully loads the resource.
 */
@property(nonatomic, readonly) BOOL wasLoaded;

/**
 * Loads the resources from the file at the specified file path, populating the
 * internal data structures, extracts the nodes from the data, and returns whether
 * the loading was successful.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * If the instance is instantiated with one of the file-loading initialization method,
 * this method will be invoked automatically during instance initialization. If the
 * instance is instantiated without using one of the file-loading methods, this method
 * can be invoked directly to load the file.
 *
 * This implementation performs the following:
 *   - Tests that this instance has not already been loaded, and logs an error if it has.
 *   - Logs the header information for loading this resource.
 *   - If the name property of this instance has not been set, sets it from the
 *     name of the file as extracted from the specified file path.
 *   - If the directory property of this instance has not been set, sets it from
 *     the directory path as extracted from the absolute file path.
 *   - Invokes the processFile: method to perform the loading of the file contents.
 *
 * By default, additional resources (typically textures), are loaded from the same
 * directory that the file containing the content of this resource is located.
 * If this is not the case, you can set the directory property prior to invoking
 * this method, in order to establish another directory from which additional
 * resources such as textures will be loaded.
 *
 * You do not need to set the directory property if these additional resources
 * are in the same directory as the file loaded by this resource.
 *
 * Subclasses must override the processFile: method to perform the actual file loading,
 * parsing, and node extraction.
 * 
 * Once this method has been successfully invoked, the application may immediately
 * access the nodes property to retrieve the node assemblies contained in this resource.
 */
-(BOOL) loadFromFile: (NSString*) aFilePath;

/**
 * Template method that processes the contents of the file at the specified
 * file path, which must be an absolute file path, and returns whether the
 * file was successfully loaded.
 *
 * The application should not invoke this method directly.
 * Use the loadFromFile: method instead.
 *
 * This implementation does nothing, and returns NO. Subclasses must override
 * this method. Subclasses must ensure that the nodes array property is fully
 * populated upon successful completion of this method.
 */
-(BOOL) processFile: (NSString*) anAbsoluteFilePath;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance, without loading a file.
 * The file can be loaded later using the loadFromFile: method.
 *
 * Use this method if you want to perform initialization activities prior to file
 * loading, such as setting the directory or expectsVerticallyFlippedTextures properties.
 */
+(id) resource;

/**
 * Initializes this instance and invokes the loadFromFile: method to populate
 * this instance from the contents of the file at the specified file path. 
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * This method will return nil if the file could not be loaded.
 */
-(id) initFromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance, and invokes the loadFromFile:
 * method to populate the instance from the contents of the file at the specified file path. 
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * This method will return nil if the file could not be loaded.
 */
+(id) resourceFromFile: (NSString*) aFilePath;


#pragma mark Aligning texture coordinates to NPOT and iOS-inverted textures

/**
 * Indicates whether the texture coordinates of the meshes that will be loaded
 * by this resource loader expect that the texture will be flipped upside-down
 * during texture loading.
 * 
 * The vertical axis of the coordinate system of OpenGL is inverted relative to
 * the iOS view coordinate system. This results in textures from most file formats
 * being oriented upside-down, relative to the OpenGL coordinate system. All file
 * formats except PVR format will be oriented upside-down after loading.
 *
 * If the value of this property is YES, the texture coordinates of meshes loaded
 * by this resource loader will be assumed to have already been flipped vertically,
 * (typically by the 3D editor or file exporter) to align with textures that will
 * be vertically flipped by the texture loader.
 *
 * If the value of this property is NO, the texture coordinates of meshes loaded
 * by this resource loader will be assumed to have their original orientation, and
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
 * 
 * The initial value of this property is determined by the value of the class-side
 * defaultExpectsVerticallyFlippedTextures property at the time an instance of
 * this class is created and initialized. If you want all meshes to behave the same
 * way, with respect to this property, set the value of that class-side property.
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


#pragma mark Deprecated file loading methods

/**
 * @deprecated Use the loadFromFile: method instead, which supports both absolute
 * file paths and file paths that are relative to the resources directory.
 */
-(BOOL) loadFromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the initFromFile: method instead, which supports both absolute
 * file paths and file paths that are relative to the resources directory.
 */
-(id) initFromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the resourceFromFile: method instead, which supports both
 * absolute file paths and file paths that are relative to the resources directory.
 */
+(id) resourceFromResourceFile: (NSString*) aRezPath DEPRECATED_ATTRIBUTE;

@end
