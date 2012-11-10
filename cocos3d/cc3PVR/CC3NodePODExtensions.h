/*
 * CC3NodePODExtensions.h
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


#import "CC3Node.h"
#import "CC3IdentifiablePODExtensions.h"
#import "CC3NodeAnimation.h"

@class CC3PODNodeAnimation;


#pragma mark -
#pragma mark CC3Node extensions for PVR POD data

/** Extensions to CC3Node to support PVR POD data. */
@interface CC3Node (PVRPOD)

/**
 * The index of the POD data that forms the type-specific content of this node.
 *
 * This is distinct from the podIndex property, which is the index of the data
 * for the node, which may be of any node type. Once the type is established,
 * the type-specific content is indexed by the podContentIndex property.
 *
 * This abstract implementation does not map this property to an instance
 * variable, and always returns kCC3PODNilIndex. Concrete subclasses must
 * override to map to an actual instance variable.
 */
@property(nonatomic, assign) int podContentIndex;

/**
 * The index of the parent node of this node.
 * This will be -1 if this node has no parent.
 *
 * This abstract implementation does not map this property to an instance
 * variable, and always returns kCC3PODNilIndex. Concrete subclasses must
 * override to map to an actual instance variable.
 */
@property(nonatomic, assign) int podParentIndex;

/**
 * The index of the node that is the target of this node.
 * This node will be linked to its target in the linkToPODNodes: method.
 *
 * This abstract implementation does not map this property to an instance
 * variable, and always returns kCC3PODNilIndex. Concrete subclasses must
 * override to map to an actual instance variable.
 */
@property(nonatomic, assign) int podTargetIndex;

/** Indicates whether this POD is a base node, meaning that it has no parent. */
@property(nonatomic, readonly) BOOL isBasePODNode;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance from the data of
 * this type at the specified index within the specified POD resource.
 */
+(id) nodeAtIndex: (int) aPODIndex fromPODResource: (CC3PODResource*) aPODRez;

/**
 * Returns the underlying SPODNode data structure from the specified resource,
 * for the SPODNode at the specified index.
 *
 * The returned pointer must be cast to SPODNode before accessing any internals
 * of the data structure.
 */
-(PODStructPtr) nodePODStructAtIndex: (uint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez;

/**
 * Create links to the nodes in the specified array.
 *
 * This implementation attaches this node to its parent as identified by the
 * podParentIndex property. Subclasses may override to perform other linking.
 */
-(void) linkToPODNodes: (CCArray*) nodeArray;

@end


#pragma mark -
#pragma mark CC3PODNodeAnimation

/** 
 * POD files can contain information to animate the nodes.
 * A CC3PODNodeAnimation instance manages the animation of a single node.
 * It is held by the node itself, in the animation property, and is activated
 * when the establishAnimationFrameAt: method is invoked on the node.
 */
@interface CC3PODNodeAnimation : CC3NodeAnimation {

	GLuint* animatedLocationIndices;
	GLfloat* animatedLocations;			// 3 floats per frame of animation.
	
	GLuint* animatedQuaternionsIndices;
	GLfloat* animatedQuaternions;		// 4 floats per frame of animation.
	
	GLuint* animatedScaleIndices;
	GLfloat* animatedScales;			// 7 floats per frame of animation.
}

/**
 * Initializes this instance to animate nodes using animation data found in the specified
 * SPODNode structure, containing the specified number of animation frames.
 *
 * Usually it's only worth instantiating an instance of this class if
 * the SPODNode actually contains animation data. This can be checked
 * with the sPODNodeDoesContainAnimation: class method.
 */
-(id) initFromSPODNode: (PODStructPtr) pSPODNode withFrameCount: (GLuint) numFrames;

/**
 * Allocates and initializes an autoreleased instance to animate nodes using animation
 * data found in the specified SPODNode structure, containing the specified number of
 * animation frames.
 *
 * Usually it's only worth instantiating an instance of this class if
 * the SPODNode actually contains animation data. This can be checked
 * with the sPODNodeDoesContainAnimation: class method.
 */
+(id) animationFromSPODNode: (PODStructPtr) pSPODNode withFrameCount: (GLuint) numFrames;

/** Returns whether the specified SPODNode structure contains animation data. */
+(BOOL) sPODNodeDoesContainAnimation: (PODStructPtr) pSPODNode;

@end
