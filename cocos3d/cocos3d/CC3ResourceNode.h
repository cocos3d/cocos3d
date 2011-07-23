/*
 * CC3ResourceNode.h
 *
 * cocos3d 0.6.0-sp
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


#import "CC3Node.h"
#import "CC3Resource.h"


/**
 * A CC3ResourceNode is a CC3Node that that wraps an instance of a subclass of
 * CC3Resource in the resource property, extracts the nodes from that resource,
 * and forms the root of the resulting node structural assembly.
 *
 * All that is needed is to set the resource property to an instance of a subclass of
 * CC3Resource. Once the resource property has been set, this node can simply be added
 * to a CC3World as a child node. Since the node structural assembly is hierarchical,
 * adding this node to the CC3World will automatically add all the nodes extracted
 * from the 3D data file.
 *
 * There are several ways to instantiate an instance of CC3ResourceNode. The simplest
 * way is to simply use the inherited node class method. Once instantiated, the
 * resource property can be set.
 *
 * There are also several class and instance initialization methods that will
 * load directly from a file and set the resource property from that file.
 * To make use of these methods, this class must be subclassed, and the subclass
 * must override the resourceClass method to indicate witch resource type is to
 * be loaded.
 *
 * When a copy is made of a CC3ResourceNode instance, a copy is not made of the encapsulated
 * CC3Resource instance. Instead, the CC3Resource is retained by reference and shared between
 * both the original CC3ResourceNode, and the new copy.
 */
@interface CC3ResourceNode : CC3Node {
	CC3Resource* resource;
}

/**
 * The underlying CC3Resource instance containing the 3D nodes.
 * 
 * Setting this property will remove all child nodes of this CC3ResourceNode
 * and replace them with the nodes extracted from the nodes property of the
 * new CC3Resource instance.
 *
 * If this node has not yet been assigned a name, it will be set to the name
 * of the resource when this property is set.
 * 
 * When setting this property to a resource, the resource should already be
 * loaded before setting this property.
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
 * Loads the file at the specified path, which must be an absolute path, into
 * an instance of the subclass of CC3Resource specified by the resourceClass
 * method, and sets the resource property to that CC3Resource subclass instance.
 *
 * If this node has not yet been assigned a name, it will be set to the name
 * of the loaded resource.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
-(void) loadFromFile: (NSString*) aFilepath;

/**
 * Initializes this instance, loads the file at the specified path, which must
 * be an absolute path, into an instance of the subclass of CC3Resource specified
 * by the resourceClass method, and sets the resource property to that CC3Resource
 * subclass instance.
 *
 * The name of this node will be set to that of the resource.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
-(id) initFromFile: (NSString*) aFilepath;

/**
 * Allocates and initializes an autoreleased instance, loads the file at the
 * specified path, which must be an absolute path, into an instance of the
 * subclass of CC3Resource specified by the resourceClass method, and sets the
 * resource property to that CC3Resource subclass instance.
 *
 * The name of this node will be set to that of the resource.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
+(id) nodeFromFile: (NSString*) aFilepath;

/**
 * Initializes this instance, loads the file at the specified path, which must
 * be an absolute path, into an instance of the subclass of CC3Resource specified
 * by the resourceClass method, and sets the resource property to that CC3Resource
 * subclass instance.
 *
 * The name of this node will be set to the specified name.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFilepath;

/**
 * Allocates and initializes an autoreleased instance, loads the file at the
 * specified path, which must be an absolute path, into an instance of the
 * subclass of CC3Resource specified by the resourceClass method, and sets the
 * resource property to that CC3Resource subclass instance.
 *
 * The name of this node will be set to the specified name.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
+(id) nodeWithName: (NSString*) aName fromFile: (NSString*) aFilepath;

/**
 * Loads the file at the specified resource path into an instance of the subclass
 * of CC3Resource specified by the resourceClass method, and sets the resource
 * property to that CC3Resource subclass instance.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 *
 * If this node has not yet been assigned a name, it will be set to the name
 * of the loaded resource.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
-(void) loadFromResourceFile: (NSString*) aRezPath;

/**
 * Initializes this instance, loads the file at the specified resource path into
 * an instance of the subclass of CC3Resource specified by the resourceClass
 * method, and sets the resource property to that CC3Resource subclass instance.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 *
 * The name of this node will be set to that of the resource.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
-(id) initFromResourceFile: (NSString*) aRezPath;

/**
 * Allocates and initializes an autoreleased instance, loads the file at the
 * specified resource path into an instance of the subclass of CC3Resource
 * specified by the resourceClass method, and sets the resource property to
 * that CC3Resource subclass instance.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 *
 * The name of this node will be set to that of the resource.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
+(id) nodeFromResourceFile: (NSString*) aRezPath;

/**
 * Initializes this instance, loads the file at the specified resource path into
 * an instance of the subclass of CC3Resource specified by the resourceClass
 * method, and sets the resource property to that CC3Resource subclass instance.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 *
 * The name of this node will be set to the specified name.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
-(id) initWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath;

/**
 * Allocates and initializes an autoreleased instance, loads the file at the
 * specified resource path into an instance of the subclass of CC3Resource
 * specified by the resourceClass method, and sets the resource property to
 * that CC3Resource subclass instance.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 *
 * The name of this node will be set to the specified name.
 *
 * To make use of this method, create a subclass that overrides resourceClass.
 */
+(id) nodeWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath;

@end



