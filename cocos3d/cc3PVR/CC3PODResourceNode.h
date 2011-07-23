/*
 * CC3PODResourceNode.h
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


#import "CC3ResourceNode.h"
#import "CC3PODResource.h"
#import "CC3World.h"


/** A CC3ResourceNode that that wraps a CC3PODResource PVR POD resource. */
@interface CC3PODResourceNode : CC3ResourceNode {}
	
@end


#pragma mark -
#pragma mark CC3World extensions to support PVR POD content

/**
 * This category extends CC3World to add convenience methods for loading
 * POD content directly into the CC3World instance, adding the extracted
 * and configured nodes as child nodes to the CC3World.
 */
@interface CC3World (PVRPOD)

/**
 * Instantiates an instance of CC3PODResourceNode, loads it from the POD
 * file at the specified path, which must be an absolute path, and adds
 * the CC3PODResourceNode instance as a child node to this CC3World instance.
 * The name of the resource node will be that of the file.
 */
-(void) addContentFromPODFile: (NSString*) aFilepath;

/**
 * Instantiates an instance of CC3PODResourceNode with the specified name, loads
 * it from the POD file at the specified path, which must be an absolute path, and
 * adds the CC3PODResourceNode instance as a child node to this CC3World instance.
 */
-(void) addContentFromPODFile: (NSString*) aFilepath withName: (NSString*) aName;

/**
 * Instantiates an instance of CC3PODResourceNode, loads it from the POD
 * file at the specified resource path, and adds the CC3PODResourceNode
 * instance as a child node to this CC3World instance.
 * The name of the resource node will be that of the file.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 */
-(void) addContentFromPODResourceFile: (NSString*) aRezPath;

/**
 * Instantiates an instance of CC3PODResourceNode with the specified name,
 * loads it from the POD file at the specified resource path, and adds the
 * CC3PODResourceNode instance as a child node to this CC3World instance.
 *
 * The specified file path is a path relative to the resource directory.
 * Typically this means that the specified path can just be the name of
 * the file, with no path information.
 */
-(void) addContentFromPODResourceFile: (NSString*) aRezPath withName: (NSString*) aName;

@end

