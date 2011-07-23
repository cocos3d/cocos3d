/*
 * CC3PODMeshNode.mm
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
 * 
 * See header file CC3PODMeshNode.h for full API documentation.
 */

#import "CC3PODMeshNode.h"
#import "CC3PVRTModelPOD.h"


@interface CC3MeshNode (TemplateMethods)
-(void) populateFrom: (CC3MeshNode*) another;
@end


@implementation CC3PODMeshNode

@synthesize podMaterialIndex;

-(int) podIndex {
	return podIndex;
}

-(void) setPodIndex: (int) aPODIndex {
	podIndex = aPODIndex;
}

-(int) podContentIndex {
	return podContentIndex;
}

-(void) setPodContentIndex: (int) aPODIndex {
	podContentIndex = aPODIndex;
}

-(int) podParentIndex {
	return podParentIndex;
}

-(void) setPodParentIndex: (int) aPODIndex {
	podParentIndex = aPODIndex;
}

-(id) initAtIndex: (int) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		SPODNode* pmn = (SPODNode*)[self nodePODStructAtIndex: aPODIndex
											fromPODResource: (CC3PODResource*) aPODRez];
		// If this node has a mesh, build it
		if (self.podContentIndex >= 0) {
			self.mesh = [aPODRez meshModelAtIndex: self.podContentIndex];
		}
		// If this node has a material, build it
		self.podMaterialIndex = pmn->nIdxMaterial;
		if (self.podMaterialIndex >= 0) {
			self.material = [aPODRez materialAtIndex: self.podMaterialIndex];
		}
	}
	return self; 
}

-(PODStructPtr) nodePODStructAtIndex: (uint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [aPODRez meshNodePODStructAtIndex: aPODIndex];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3PODMeshNode*) another {
	[super populateFrom: another];

	podIndex = another.podIndex;
	podContentIndex = another.podContentIndex;
	podParentIndex = another.podParentIndex;
	podMaterialIndex = another.podMaterialIndex;
}

@end
