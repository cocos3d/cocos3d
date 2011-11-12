/*
 * CC3Resource.h
 *
 * cocos3d 0.6.3
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


#import "CC3Identifiable.h"


/**
 * CC3Resource is a wrapper class around a resource structure loaded from a data file
 * containing 3D resources. It handles loading object data from files, and creating
 * CC3Nodes from that data.
 *
 * This is an abstract class. Specific subclasses will load files of specific types.
 *
 * Of the methods defined in this class, subclasses must override the primitive
 * template method loadFromFile:. Other methods defined by this class have been
 * implemented using this primitive method. As a result, subclasses do not need
 * to override any of the other methods defined by this class.
 *
 * Access to 3D data objects loaded from the file is through the nodes property,
 * which contains the root nodes of a structural 3D node assembly constructed from
 * the 3D data loaded from the file. Subclasses should ensure that the nodes array
 * property is fully populated upon successful completion of the loadFromFile: method.
 */
@interface CC3Resource : CC3Identifiable {
	CCArray* nodes;
	NSString* directory;
	BOOL wasLoaded;
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


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance, without loading a file.
 * The file can be loaded later using the loadFromFile: method.
 *
 * Use this method if you want to perform initialization activities prior to
 * file loading.
 */
+(id) resource;

/**
 * This template method is the primary method for loading this resource.
 *
 * Populates the internal data structures from the file at the specified path,
 * which must be an absolute path, extracts the nodes from the data, and returns
 * whether the loading was successful.
 *
 * This is a template method. This implementation performs the following:
 *   - Tests that a file has not already been loaded into this instance, and logs
 *     an error if it has.
 *   - Logs the header information for loading this resource.
 *   - If the name property of this instance has not been set, sets it from the
 *     name of the file as extracted from the specified file path.
 *   - If the directory property of this instance has not been set, sets it from
 *     the directory path as extracted from the specified file path.
 *
 * Subclasses must override this method to perform the actual file loading,
 * parsing, and node extraction, but should be sure to invoke this superclass
 * implementation to ensure the above tasks are performed.
 * 
 * Once this method has been successfully invoked, the application may immediately
 * access the nodes property to retrieve the node assemblies contained in this resource.
 */
-(BOOL) loadFromFile: (NSString*) aFilePath;

/**
 * Initializes this instance and populates the internal data structures
 * from the file at the specified path, which must be an absolute path,
 * and extracts the nodes from the data.
 *
 * This method invokes the loadFromFile: template method to perform the
 * actual file loading.
 *
 * This method will return nil if the file could not be loaded.
 */
-(id) initFromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance, and populates the
 * internal data structures from the file at the specified path, which
 * must be an absolute path, and extracts the nodes from the data.
 *
 * This method invokes the loadFromFile: template method to perform the
 * actual file loading.
 *
 * This method will return nil if the file could not be loaded.
 */
+(id) resourceFromFile: (NSString*) aFilePath;

/**
 * Populates the internal data structures from the file at the specified
 * resource path, extracts the nodes from the data, and returns whether
 * the loading was successful.
 *
 * This method invokes the loadFromFile: template method to perform the
 * actual file loading.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 */
-(BOOL) loadFromResourceFile: (NSString*) aRezPath;

/**
 * Initializes this instance and populates the internal data structures
 * from the file at the specified resource path, and extracts the nodes
 * from the data.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 *
 * This method invokes the loadFromFile: template method to perform the
 * actual file loading.
 *
 * This method will return nil if the file could not be loaded.
 */
-(id) initFromResourceFile: (NSString*) aRezPath;

/**
 * Allocates and initializes an autoreleased instance, populates the
 * internal data structures from the file at the specified resource path,
 * and extracts the nodes from the data.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 *
 * This method invokes the loadFromFile: template method to perform the
 * actual file loading.
 *
 * This method will return nil if the file could not be loaded.
 */
+(id) resourceFromResourceFile: (NSString*) aRezPath;
	
@end
