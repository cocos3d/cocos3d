/*
 * CC3CALNode.h
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


#import "CC3Node.h"


/** 
 * A CC3CALNode extracted from a file.
 *
 * During extraction from the file, nodes of this type are related to each other through index values.
 *
 * Only CC3ArrayNodeAnimation should be used for animating this type of node.
 *
 * CAF bones do not contain scale content. When a skeleton model whose bones do contain scale
 * content is exported to a CAF file, the animation location content is incorrectly scaled.
 *
 * To compensate, when using a CC3CALNode to hold animation content loaded from a CAF file, invoke
 * the correctAnimationToSkeletalScale: method, passing the skeletalScale of the node to which the
 * animation contained in the CC3CALNode is to be attached. This should only be done once, and
 * subsequent invocations of that method will be ignored. Consequently, the animation held in a
 * CC3CALNode should only be used to animate bones that have the same skeletalScale.
 */
@interface CC3CALNode : CC3Node {
	GLint _calIndex;
	GLint _calParentIndex;
	BOOL _isAnimationCorrectedForScale : 1;
}

/** The index of this node in the resource file. */
@property(nonatomic, assign) GLint calIndex;

/** The index of the parent of this node in the resource file. */
@property(nonatomic, assign) GLint calParentIndex;

/** Returns whether this node is a base node. It is if the calParentIndex is negative. */
@property(nonatomic, readonly) BOOL isBaseCALNode;

/**
 * Links this node to its parent by retrieving the node at the position in the array
 * specified by the calParentIndex of this node.
 */
-(void) linkToCALNodes: (NSArray*) nodeArray;

/**
 * Retrieves the first node found with the specified calIndex, anywhere in the structural hierarchy
 * of descendants of this node (not just direct children). The hierarchy search is depth-first.
 */
-(CC3CALNode*) getNodeWithCALIndex: (GLint) calIndex;

/** Indicates whether the contained animation has been corrected for the scale of the node. */
@property(nonatomic, readonly) BOOL isAnimationCorrectedForScale;

/**
 * Corrects the animation contained in this node to align with the specified skeletalScale.
 *
 * CAF bones do not contain scale content. When a skeleton model whose bones do contain scale
 * content is exported to a CAF file, the location content of this animation is not correctly scaled.
 *
 * To compensate, invoke this method, passing the skeletalScale of the node to which this animation
 * is to be attached.
 *
 * When this method is invoked, if the value of the isAnimationCorrectedForScale property
 * is NO, each location in the animation contained in this node (on all animation tracks)
 * is scaled by the inverse of the specified scale. Once this is complete, the value of
 * the isAnimationCorrectedForScale property is set to YES.
 *
 * Since this scaling should only be done once, subsequent invocations of this method will
 * be ignored. Consequently, the contained animation should only be used to animate bones
 * that have the same skeletalScale.
 *
 * This method is invoked automatically when this CAL node is retrieved from the CAF resource
 * using the CC3CAFResource getNodeMatching: method. Normally, the application never has
 * need to invoke this method.
 */
-(void)	correctAnimationToSkeletalScale: (CC3Vector) aScale;

@end
