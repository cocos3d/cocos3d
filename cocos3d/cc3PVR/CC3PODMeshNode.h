/*
 * CC3PODMeshNode.h
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


#import "CC3MeshNode.h"
#import "CC3NodePODExtensions.h"


#pragma mark -
#pragma mark CC3MeshNode extensions for PVR POD data

/** Extensions to CC3MeshNode to support PVR POD data. */
@interface CC3MeshNode (PVRPOD)

/** The index of the material in the POD file used by this node. */
@property(nonatomic, assign) int podMaterialIndex;

@end


#pragma mark -
#pragma mark CC3PODMeshNode

/**
 * A CC3MeshNode whose content originates from POD resource data.
 *
 * This is a concrete implementation of the CC3Node category PVRPOD. 
 */
@interface CC3PODMeshNode : CC3MeshNode {
	GLint _podIndex;
	GLint _podContentIndex;
	GLint _podParentIndex;
	GLint _podMaterialIndex;
}

@end
