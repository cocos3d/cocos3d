/*
 * CC3Resource.h
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


#import "CC3Identifiable.h"


/**
 * CC3Resource is an abstract wrapper class around content loaded from a file containing
 * 3D resources. Concrete subclasses will load files of specific types.
 *
 * The loadFromFile: method is used to load this resource. Once this method has been successfully
 * invoked, access to 3D objects loaded from the file are through properties defined by subclasses.
 *
 * As shortcuts, there are also class and instance initialization methods that will
 * invoke the loadFromFile: method automatically during instance initialization.
 *
 * However, if this resource can load textures, before using any of these shortcut methods, you
 * should take into consideration whether you need to set the directory property prior to loading.
 *
 * By default, additional resources (for example textures), are loaded from the same directory
 * that the file containing the content of this resource is located. If this is not the case,
 * you can set the directory property prior to invoking the loadFromFile: method, in order to
 * establish another directory from which additional resources such as textures will be loaded.
 * You do not need to set the directory property if these additional resources are in the same
 * directory as the file loaded by this resource.
 *
 * Subclasses must override the primitive template method processFile:. All other loading and
 * initialization methods defined by this class are implemented using this primitive method,
 * and subclasses do not need to override any of these other loading and initialization methods.
 */
@interface CC3Resource : CC3Identifiable {
	NSString* _directory;
	BOOL _wasLoaded : 1;
}

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
 * Loads the resources from the file at the specified file path and returns whether the loading
 * was successful.
 *
 * The specified file path may be either an absolute path, or a path relative to the application
 * resource directory. If the file is located directly in the application resources directory,
 * the specified file path can simply be the name of the file.
 *
 * If the instance is instantiated with one of the file-loading initialization method, this method
 * will be invoked automatically during instance initialization. If the instance is instantiated
 * without using one of the file-loading methods, this method can be invoked directly to load the file.
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
 * By default, additional resources (typically textures), are loaded from the same directory
 * that the file containing the content of this resource is located. If this is not the case,
 * you can set the directory property prior to invoking this method, in order to establish
 * another directory from which additional resources will be loaded. You do not need to set
 * the directory property if these additional resources are in the same directory as the file
 * loaded by this resource.
 *
 * Subclasses must override the processFile: method to perform the actual file loading and parsing.
 *
 * Once this method has been successfully invoked, the application may immediately access the content
 * contained in this resource, through properties and methods defined by the concrete subclasses.
 */
-(BOOL) loadFromFile: (NSString*) aFilePath;

/**
 * Template method that processes the contents of the file at the specified file path, which must
 * be an absolute file path, and returns whether the file was successfully loaded.
 *
 * The application should not invoke this method directly. Use the loadFromFile: method instead.
 *
 * This implementation does nothing, and returns NO. Concrete subclasses must override this method,
 * and should ensure that the file content is available upon successful completion of this method.
 */
-(BOOL) processFile: (NSString*) anAbsoluteFilePath;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance, without loading a file.
 * The file can be loaded later by invoking the loadFromFile: method.
 *
 * Use this method if you want to perform initialization activities prior to file
 * loading, such as setting the directory property.
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


#pragma mark Deprecated functionality

/** @deprecated Property moved to CC3NodesResource subclass. */
@property(nonatomic, readonly) CCArray* nodes DEPRECATED_ATTRIBUTE;

/** @deprecated Property moved to CC3NodesResource subclass. */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures DEPRECATED_ATTRIBUTE;

/** @deprecated Property moved to CC3NodesResource subclass. */
+(BOOL) defaultExpectsVerticallyFlippedTextures;

/** @deprecated Property moved to CC3NodesResource subclass. */
+(void) setDefaultExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped;

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
