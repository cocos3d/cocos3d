/*
 * CC3PODVertexSkinning.h
 *
 * cocos3d 2.0.0
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
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

#import "CC3VertexSkinning.h"
#import "CC3VertexArraysPODExtensions.h"
#import "CC3PVRFoundation.h"
#import "CC3PVRTModelPOD.h"


#pragma mark -
#pragma mark CC3PODSkinMeshNode

/** A CC3SkinMeshNode extracted from a POD file. */
@interface CC3PODSkinMeshNode : CC3SkinMeshNode {
	GLint _podIndex;
	GLint _podContentIndex;
	GLint _podParentIndex;
	GLint _podMaterialIndex;
}
@end


#pragma mark -
#pragma mark CC3PODSkinSection

/**
 * A CC3SkinSection extracted from a POD file.
 * 
 * Since the CC3PODSkinSection may be loaded before the corresponding skeleton,
 * the bones to which this skin section will be attached may not exist during
 * loading. This class keeps track of the bone node indices, and creates links
 * to the bones once the entire POD has been loaded.
 */
@interface CC3PODSkinSection : CC3SkinSection {
	GLuint _podBoneCount;
	GLint* _podBoneNodeIndices;
}

/**
 * Initializes an instance from the specified POD SPODMesh structure, 
 * and that will be used by the specified skin mesh node.
 */
-(id) initFromBatchAtIndex: (int) aBatchIndex
			  fromSPODMesh: (PODStructPtr) aSPODMesh
				   forNode: (CC3SkinMeshNode*) aNode;

/**
 * Allocates and initializes an autoreleased instance from the specified POD
 * SPODMesh structure, and that will be used by the specified skin mesh node.
 */
+(id) skinSectionFromBatchAtIndex: (int) aBatchIndex
					 fromSPODMesh: (PODStructPtr) aSPODMesh
						  forNode: (CC3SkinMeshNode*) aNode;

/**
 * Create links to the nodes in the specified array.
 *
 * This implementation iterates through the indices in the boneNodeIndices array,
 * retrieves the CC3Bone node at each index in the specified node array, and
 * adds that bone node to this skin section using the addBone: method.
 */
-(void) linkToPODNodes: (NSArray*) nodeArray;

@end


#pragma mark -
#pragma mark CC3PODBone

/** A CC3Bone extracted from a POD file. */
@interface CC3PODBone : CC3Bone {
	GLint _podIndex;
	GLint _podContentIndex;
	GLint _podParentIndex;
}

@end
