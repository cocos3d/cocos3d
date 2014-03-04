/*
 * CC3Resource.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * 3D resource content. Concrete subclasses will load files of specific types.
 *
 * Typically, the application uses the resourceFromFile: to retrieve an instance. The loaded
 * instances are automtaically placed in a cache, so that subsequent inocations of the
 * resourceFromFile: method will not cause the file to be loaded again.
 *
 * The application can also bypass the cache by using the alloc and initFromFile: methods to
 * load an instance without placing it in the cache. It can subsequently be added to the cache
 * using the addResource: method.
 *
 * The application can also use the resource method to create a new instance that is not
 * automatically loaded, and then use the loadFromFile: method to load the resource from
 * file. The addResource: method can then be used to add the instance to the cache. This
 * technique can be used when additional configuration, such as the directory property,
 * need to be set prior to loading the file.
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
	BOOL _isBigEndian : 1;
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
 * Indicates whether the source content was encoded on a big-endian platform.
 *
 * Many resource file formats encode their content in a platform-independant manner,
 * so not all resource file types will be affected by the value of this property.
 *
 * Most OSX and iOS platforms are little-endian, so this property defaults to NO. You can set the
 * value of this property to YES prior to reading any content from resource file types whose content
 * is dependent on platform endianess if you know the data was encoded on a big-endian platform.
 */
@property(nonatomic, assign) BOOL isBigEndian;

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

/**
 * Saves the content of this resource to the file at the specified file path and returns whether
 * the saving was successful.
 *
 * The specified file path may be either an absolute path, or a path relative to the application
 * resource directory. If the file is located directly in the application resources directory,
 * the specified file path can simply be the name of the file.
 *
 * Not all types of resources support saving back to a file. This base implementation raises an
 * assertion error indicating that saving is not supported, and returns NO. Subclasses that manage
 * a resource type that can be saved will override this method to perform the saving activity.
 */
-(BOOL) saveToFile: (NSString*) aFilePath;


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
 * Normally, you should use the resourceFromFile: method to reuse the cached instance instead of
 * creating and initializing a new instance. The resourceFromFile: method automatically invokes
 * this method if an instance does not exist in the resource cache, in order to create and load
 * the resource from the file, and after doing so, places the newly loaded instance into the cache.
 *
 * However, by invoking the alloc method and then invoking this method directly, the application
 * can load the resource without first checking the resource cache. The resource can then be placed
 * in the cache using the addResource: method. If you load two separate resources from the same
 * file, be sure to set a distinct name for each before adding both resources to the cache.
 * By default, the name of the resource is the file name.
 *
 * If you need to set additional configuration info, such as the directory property, prior
 * to loading the resource, consider using the init or resource methods and then invoking
 * the loadFromFile: method instead.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * This method will return nil if the file could not be loaded.
 */
-(id) initFromFile: (NSString*) aFilePath;

/**
 * Returns a resource instance loaded from the specified file.
 *
 * Resources loaded through this method are cached. If the resource was already loaded and is in
 * the cache, it is retrieved and returned. If the resource has not in the cache, it is loaded
 * from the specified file, placed into the cache, and returned. It is therefore safe to invoke
 * this method any time the resource is needed, without having to worry that the resource will
 * be repeatedly loaded from file.
 *
 * To clear a resource instance from the cache, use the removeResource: method.
 *
 * To load the file directly, bypassing the cache, use the alloc and initFromFile: methods.
 * This technique can be used to load the same resource twice, perhaps to configure each separately.
 * Each distinct resource can then be given its own name, and added to the cache separately.
 * However, when choosing to do so, be aware that resources often consume significant memory.
 * Consider copying resource components instead of loading the entire resource, if you need
 * to create multiple instances of a few resource components.
 *
 * If you need to set additional configuration info, such as the directory property, prior to
 * loading the resource, consider using the resource method and then invoking the loadFromFile:
 * method to load the file, and the addResource: method to add that instance to the cache.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * This method will return nil if the file is not in the cache and could not be loaded.
 */
+(id) resourceFromFile: (NSString*) aFilePath;

/** 
 * Returns a resource name derived from the specified file path.
 *
 * This method is used to standardize the naming of shaders, to ease in adding and retrieving
 * resources to and from the cache, and is used to create the name for each resource that is
 * loaded from a file.
 *
 * This implementation returns the lastComponent of the specified file path.
 */
+(NSString*) resourceNameFromFilePath: (NSString*) aFilePath;

/**
 * Returns a description formatted as a source-code line for loading this resource from its file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code.
 */
-(NSString*) constructorDescription;


#pragma mark Resource cache

/** Removes this resource instance from the cache. */
-(void) remove;

/**
 * Adds the specified resource to the collection of loaded resources.
 *
 * Resources are accessible via their names through the getResourceNamed: method, and each
 * resource name should be unique. If a resource with the same name as the specified resource
 * already exists in this cache, an assertion error is raised.
 *
 * This cache is a weak cache, meaning that it does not hold strong references to the resources
 * that are added to it. As a result, the specified resource will automatically be deallocated
 * and removed from this cache once all external strong references to it have been released.
 */
+(void) addResource: (CC3Resource*) resource;

/**
 * Returns the cached resource with the specified name,
 * or nil if a resource with that name has not been cached.
 */
+(CC3Resource*) getResourceNamed: (NSString*) rezName;

/** Removes the specified resource from the resource cache. */
+(void) removeResource: (CC3Resource*) resource;

/** Removes the resource with the specified name from the resource cache. */
+(void) removeResourceNamed: (NSString*) name;

/** 
 * Removes from the cache all resources that are instances of any subclass of the receiver.
 *
 * You can use this method to selectively remove specific types of resources, based on
 * the resource class, by invoking this method on that class. If you invoke this method
 * on the CC3Resource class, this cache will be compltely cleared. However, if you invoke
 * this method on one of its subclasses, only those resources that are instances of that
 * subclass (or one of its subclasses in turn) will be removed, leaving the remaining
 * resources in the cache.
 */
+(void) removeAllResources;

/**
 * Returns whether resources are being pre-loaded.
 *
 * See the setIsPreloading setter method for a description of how and when to use this property.
 */
+(BOOL) isPreloading;

/**
 * Sets whether resources are being pre-loaded.
 *
 * Resources that are added to this cache while the value of this property is YES will be
 * strongly cached and cannot be deallocated until specifically removed from this cache.
 * You must manually remove any resources added to this cache while the value of this 
 * property is YES.
 *
 * Resources that are added to this cache while the value of this property is NO will be
 * weakly cached, and will automatically be deallocated and removed from this cache once
 * all references to the resource outside this cache are released.
 *
 * You can set the value of this property at any time, and can vary it between YES and NO
 * to accomodate your specific loading patterns.
 *
 * The initial value of this property is NO, meaning that resources will be weakly cached
 * in this cache, and will automatically be removed if not used in the scene. You can set
 * this property to YES in order to pre-load resources that will not be immediately used
 * in the scene, but which you wish to keep in the cache for later use.
 */
+(void) setIsPreloading: (BOOL) isPreloading;

/**
 * Returns a description of the contents of this cache, with each entry formatted as a
 * source-code line for loading the resource from its file.
 *
 * During development time, you can log this string, then copy and paste it into a
 * pre-loading function within your app code.
 */
+(NSString*) cachedResourcesDescription;


#pragma mark Deprecated functionality

/** @deprecated Property moved to CC3NodesResource subclass. */
@property( nonatomic, retain, readonly) NSArray* nodes DEPRECATED_ATTRIBUTE;

/** @deprecated Property moved to CC3NodesResource subclass. */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures DEPRECATED_ATTRIBUTE;

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

/** @deprecated Property moved to CC3NodesResource subclass. */
+(BOOL) defaultExpectsVerticallyFlippedTextures;

/** @deprecated Property moved to CC3NodesResource subclass. */
+(void) setDefaultExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped;

@end
