/*
 * CC3PODMeshNode.mm
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
 * 
 * See header file CC3PODMeshNode.h for full API documentation.
 */

#import "CC3PODMeshNode.h"
#import "CC3PVRTModelPOD.h"
#import "CC3PODMaterial.h"
#import "CC3PFXResource.h"


#pragma mark -
#pragma mark CC3MeshNode extensions for PVR POD data

@implementation CC3MeshNode (PVRPOD)

// Subclasses must override to use instance variable.
-(GLint) podMaterialIndex { return 0; }

// Subclasses must override to use instance variable.
-(void) setPodMaterialIndex: (GLint) aPODIndex {}

-(id) initAtIndex: (GLint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		SPODNode* pmn = (SPODNode*)[self nodePODStructAtIndex: aPODIndex
											  fromPODResource: (CC3PODResource*) aPODRez];
		// If this node has a mesh, build it
		if (self.podContentIndex >= 0) {
			self.mesh = [aPODRez meshAtIndex: self.podContentIndex];
		}
		// If this node has a material, build it
		self.podMaterialIndex = pmn->nIdxMaterial;
		if (self.podMaterialIndex >= 0)
			self.material = [aPODRez materialAtIndex: self.podMaterialIndex];
	}
	return self; 
}

-(PODStructPtr) nodePODStructAtIndex: (uint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [aPODRez meshNodePODStructAtIndex: aPODIndex];
}

@end


#pragma mark -
#pragma mark CC3PODMeshNode

@implementation CC3PODMeshNode

-(GLint) podIndex { return _podIndex; }

-(void) setPodIndex: (GLint) aPODIndex { _podIndex = aPODIndex; }

-(GLint) podContentIndex { return _podContentIndex; }

-(void) setPodContentIndex: (GLint) aPODIndex { _podContentIndex = aPODIndex; }

-(GLint) podParentIndex { return _podParentIndex; }

-(void) setPodParentIndex: (GLint) aPODIndex { _podParentIndex = aPODIndex; }

-(GLint) podMaterialIndex { return _podMaterialIndex; }

-(void) setPodMaterialIndex: (GLint) aPODIndex { _podMaterialIndex = aPODIndex; }

-(void) populateFrom: (CC3PODMeshNode*) another {
	[super populateFrom: another];

	_podIndex = another.podIndex;
	_podContentIndex = another.podContentIndex;
	_podParentIndex = another.podParentIndex;
	_podMaterialIndex = another.podMaterialIndex;
}

-(void) setMaterial: (CC3PODMaterial*) aMaterial {
	[super setMaterial: aMaterial];
	if ( [aMaterial isKindOfClass: [CC3PODMaterial class]] )
		[aMaterial.pfxEffect populateMeshNode: self];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (POD index: %i)", [super description], _podIndex];
}

@end
