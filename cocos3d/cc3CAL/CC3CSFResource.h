/*
 * CC3CSFResource.h
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


#import "CC3NodesResource.h"
#import "CC3CALNode.h"


/** CC3CSFResource is a CC3NodesResource that loads a node hierarchy from a Cal3D-compatible CSF file. */
@interface CC3CSFResource : CC3NodesResource {
	NSMutableArray* _allNodes;
	int _nodeCount;
	int _fileVersion;
	ccColor4F _ambientLight;
}

/** The file format version, extracted from the file. */
@property(nonatomic, readonly) int fileVersion;

/** The color of the ambient light in the scene. */
@property(nonatomic, readonly) ccColor4F ambientLight;

/**
 * A collection of all of the nodes extracted from the CSF file.
 * This is the equivalent of flattening the nodes array.
 */
@property(nonatomic, retain, readonly) NSArray* allNodes;

/**
 * Retrieves the first node found with the specified calIndex, anywhere in the nodes contained
 * in this resource. This performs a simple linear search through the all-nodes collection..
 */
-(CC3CALNode*) getNodeWithCALIndex: (GLint) calIndex;

@end
