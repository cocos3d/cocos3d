/*
 * CC3CAFResource.h
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


#import "CC3CSFResource.h"
#import "CC3CALNode.h"


/** 
 * CC3CAFResource is a CC3NodesResource that loads animated node from a Cal3D-compatible CAF file.
 *
 * After this resource has been loaded, you should populate the nodes in this resource with content
 * extracted from a CSF resource, using the populateNodesFromCSFResource: method.
 */
@interface CC3CAFResource : CC3NodesResource {
	int _nodeCount;
	CCTime _animationDuration;
	int _fileVersion;
	int _flags;
	BOOL _isCompressed : 1;
	BOOL _wasCSFResourceAttached : 1;
	BOOL _shouldSwapYZ : 1;
}

/** Returns the file format version, extracted from the file. */
@property(nonatomic, readonly) int fileVersion;

/** Returns whether the file contains compressed animation content. */
@property(nonatomic, readonly) BOOL isCompressed;

/** Returns file content format flags. */
@property(nonatomic, readonly) int flags;

/** Returns the animation duration in seconds. */
@property(nonatomic, readonly) CCTime animationDuration;

/**
 * Indicates whether the Y & Z elements of animated locations and quaternions loaded by this
 * resource should be swapped during loading. When swapped, the new Z value is also negated.
 *
 * If set to YES, for each location and quaternion in the animation content, the Z value will be set
 * from the negated Y value of the loaded quaternion, and the Y value will be set from the Z value.
 *
 * This setting can be used to correct possible coordinate system orientation discrepancies
 * between the CAF exporters and cocos3d.
 *
 * The initial value of this property is set from the value of the class-side
 * defaultShouldSwapYZ property.
 */
@property(nonatomic, assign) BOOL shouldSwapYZ;

/**
 * Indicates the value that the shouldSwapYZ property should be initially set to
 * when any new instance of this class is created.
 *
 * The initial value of this property is YES.
 */
+(BOOL) defaultShouldSwapYZ;

/**
 * Indicates the value that the shouldSwapYZ property should be initially set to
 * when any new instance of this class is created.
 *
 * The initial value of this property is YES.
 */
+(void) setDefaultShouldSwapYZ: (BOOL) shouldSwap;


#pragma mark Allocation and initialization

/**
 * Initializes this instance and invokes the loadFromFile: method to populate this instance from
 * the contents of the file at the specified cafFilePath.
 *
 * Once loaded, this instance is attached to the CSF resource loaded from the specified csfFilePath
 * by invoking the linkToCSFResource method. The CSF resource is retrieved from the resource cache
 * if it already exists, otherwise it is loaded and cached as well.
 *
 * Normally, you should use the resourceFromFile:linkedToCSFFile: method to reuse the cached
 * instance instead of creating and initializing a new instance. The resourceFromFile:linkedToCSFFile:
 * method automatically invokes this method if an instance does not exist in the resource cache,
 * in order to create and load the resource from the file, and after doing so, places the newly
 * loaded instance into the cache.
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
-(id) initFromFile: (NSString*) cafFilePath linkedToCSFFile: (NSString*) csfFilePath;

/**
 * Returns a resource instance loaded from the specified cafFilePath.
 *
 * Once loaded, the instance is attached to the CSF resource loaded from the specified csfFilePath
 * by invoking the linkToCSFResource method. The CSF resource is retrieved from the resource cache
 * if it already exists, otherwise it is loaded and cached as well.
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
+(id) resourceFromFile: (NSString*) cafFilePath linkedToCSFFile: (NSString*) csfFilePath;


#pragma mark Linking to other CAL files

/**
 * Returns whether this resource has been populated from its corresponding CSF resource.
 *
 * The initial value of this property is NO. It is changed to YES once the linkToCSFResource:
 * method has been invoked.
 */
@property(nonatomic, readonly) BOOL wasCSFResourceAttached;

/**
 * Populates the content of the nodes in this resource with some of the contents of the nodes
 * in the specified CSF resource.
 *
 * The CAF and CSF files are exported from the 3D editor as part of a single, self-consistent
 * export. The specified CSF resource must be from the same export as this CAF resource.
 * Typically, the export package will include a single CSF file and multiple CAF files.
 *
 * The CAF file format contains only the calIndex value of each node, and a single track of
 * animation content. The CSF file format contains node names, locations, rotations, and
 * hierarchical structure.
 *
 * For each node in this CAF resource, this method uses its calIndex property to retrieve the
 * corresponding node contained in the specified CSF resource. Once retrieved, the following
 * content is copied from the node in the CSF resource to the node in this CAF resource:
 *   - node name
 *
 * After the CSF content has been extracted, the wasCSFResourceAttached property of this CAF
 * resource will be set to YES, but the CSF resource is not retained by this CAF resource.
 *
 * This method should be invoked once after this CAF resource has been loaded. Invoking this
 * method prior to loading this resource will result in nothing happening. It is safe to invoke
 * this method more than once, but subsequent invocations will have no effect.
 */
-(void) linkToCSFResource: (CC3CSFResource*) csfRez;

@end


#pragma mark -
#pragma mark Adding animation to nodes

/** Extension category to provide support for CAF animation. */
@interface CC3Node (CAFAnimation)

/**
 * Adds the animation contained in the specified CAF file to this node and all its descendants.
 * The animation is added as the specified track.
 *
 * If the specified CAF file has already been loaded, it is retrieved from the resource cache.
 * If the CAF file has not been loaded, it will be loaded and placed in the resource cache.
 * However, the adding of the animation will fail, because the CAF file requires linking to
 * an associated CSF file. Only use this method if you know that the CAF file has already been
 * loaded and linked to a CSF file. If you are not sure, use the
 * addAnimationFromCAFFile:linkedToCSFFile:asTrack: method instead.
 */
-(void) addAnimationFromCAFFile: (NSString*) cafFilePath asTrack: (GLuint) trackID;

/**
 * Adds the animation contained in the specified CAF file, which is linked to the specified CSF
 * file, to this node and all its descendants. The animation is added as the specified track.
 *
 * If the specified CAF file has already been loaded, it is retrieved from the resource cache.
 * If the CAF file has not been loaded, it will be loaded from the specified CAF file, placed
 * in the resource cache, and linked to the CSF resource loaded from the specified CSF file.
 *
 * Similarly, if the CSF resource is required in order for it to be linked to a newly-loaded CAF file,
 * and it has already been loaded, it is retrieved from the resource cache. If the CSF resource has
 * not been loaded, it will be loaded from the specified CSF file and placed in the resource cache.
 */
-(void) addAnimationFromCAFFile: (NSString*) cafFilePath
				linkedToCSFFile: (NSString*) csfFilePath
						asTrack: (GLuint) trackID;

/**
 * Adds the animation contained in the specified CAF file to this node and all its descendants.
 * The animation is added in a new track, whose ID is returned from this method.
 *
 * If the specified CAF file has already been loaded, it is retrieved from the resource cache. If
 * the CAF file has not been loaded, it will be loaded and placed in the resource cache. However, 
 * the adding of the animation will fail, because the CAF file requires linking to an associated CSF
 * file. Only use this method if you know that the CAF file has already been loaded and linked to
 * a CSF file. If you are not sure, use the addAnimationFromCAFFile:linkedToCSFFile: method instead.
 */
-(GLuint) addAnimationFromCAFFile: (NSString*) cafFilePath;

/**
 * Adds the animation contained in the specified CAF file to this node and all its descendants.
 * The animation is added in a new track, whose ID is returned from this method.
 *
 * If the specified CAF file has already been loaded, it is retrieved from the resource cache.
 * If the CAF file has not been loaded, it will be loaded from the specified CAF file, placed
 * in the resource cache, and linked to the CSF resource loaded from the specified CSF file.
 *
 * Similarly, if the CSF resource is required in order for it to be linked to a newly-loaded CAF file,
 * and it has already been loaded, it is retrieved from the resource cache. If the CSF resource has
 * not been loaded, it will be loaded from the specified CSF file and placed in the resource cache.
 */
-(GLuint) addAnimationFromCAFFile: (NSString*) cafFilePath
				  linkedToCSFFile: (NSString*) csfFilePath;

@end
