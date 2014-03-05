/*
 * CC3PODVertexSkinning.m
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
 * 
 * See header file CC3PODVertexSkinning.h for full API documentation.
 */

#import "CC3PODVertexSkinning.h"
#import "CC3PODMesh.h"
#import "CC3VertexSkinning.h"
#import "CC3PVRTModelPOD.h"
#import "CC3PODNode.h"


#pragma mark -
#pragma mark CC3PODSkinMeshNode

@implementation CC3PODSkinMeshNode

-(GLint) podIndex { return _podIndex; }

-(void) setPodIndex: (GLint) aPODIndex { _podIndex = aPODIndex; }

-(GLint) podContentIndex { return _podContentIndex; }

-(void) setPodContentIndex: (GLint) aPODIndex { _podContentIndex = aPODIndex; }

-(GLint) podParentIndex { return _podParentIndex; }

-(void) setPodParentIndex: (GLint) aPODIndex { _podParentIndex = aPODIndex; }

-(GLint) podMaterialIndex { return _podMaterialIndex; }

-(void) setPodMaterialIndex: (GLint) aPODIndex { _podMaterialIndex = aPODIndex; }

/** 
 * Overridden to verify that the mesh is not constructed from triangle strips,
 * which are not compatible with the way that skin sections render mesh sections.
 */
-(void) setMesh: (CC3Mesh*) mesh {
	CC3Assert(mesh.drawingMode != GL_TRIANGLE_STRIP,
			  @"%@ does not support the use of triangle strips."
			  @" Vertex-skinned meshes must be constructed from triangles.", self);
	[super setMesh: mesh];
}

/** Overridden to extract the bone batches from the associated POD mesh structure */
-(id) initAtIndex: (GLint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		if (self.podContentIndex >= 0) {
			SPODMesh* psm = (SPODMesh*)[aPODRez meshPODStructAtIndex: self.podContentIndex];
			GLint batchCount = psm->sBoneBatches.nBatchCnt;
			for (GLint batchIndex = 0; batchIndex < batchCount; batchIndex++) {
				[_skinSections addObject: [CC3PODSkinSection skinSectionFromBatchAtIndex: batchIndex
																			fromSPODMesh: psm
																				 forNode: self]];
			}
		}
	}
	return self; 
}

-(void) populateFrom: (CC3PODSkinMeshNode*) another {
	[super populateFrom: another];
	
	_podIndex = another.podIndex;
	_podContentIndex = another.podContentIndex;
	_podParentIndex = another.podParentIndex;
	_podMaterialIndex = another.podMaterialIndex;
}

/** Link the nodes in the bone batches. */
-(void) linkToPODNodes: (NSArray*) nodeArray {
	[super linkToPODNodes: nodeArray];
	for (CC3PODSkinSection* skinSctn in _skinSections) [skinSctn linkToPODNodes: nodeArray];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (POD index: %i)", [super description], _podIndex];
}

@end

	
#pragma mark -
#pragma mark CC3PODSkinSection

@implementation CC3PODSkinSection

-(id) init {
	if ( (self = [super init]) ) {
		_podBoneCount = 0;
		_podBoneNodeIndices = NULL;
	}
	return self;
}

-(id) initFromBatchAtIndex: (GLint) aBatchIndex
			  fromSPODMesh: (PODStructPtr) aSPODMesh
				   forNode: (CC3SkinMeshNode*) aNode {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	if ( (self = [self initForNode: aNode]) ) {
		CPVRTBoneBatches* pBatches = &psm->sBoneBatches;
		GLint batchCount = pBatches->nBatchCnt;
			
		GLint currFaceOffset = pBatches->pnBatchOffset[aBatchIndex];
		GLint nextFaceOffset = (aBatchIndex < batchCount - 1)
									? pBatches->pnBatchOffset[aBatchIndex + 1]
									: psm->nNumFaces;
			
		_vertexStart = [aNode.mesh vertexIndexCountFromFaceCount: currFaceOffset];
		_vertexCount =  [aNode.mesh vertexIndexCountFromFaceCount: (nextFaceOffset - currFaceOffset)];
			
		_podBoneCount = pBatches->pnBatchBoneCnt[aBatchIndex];
		_podBoneNodeIndices = &(pBatches->pnBatches[aBatchIndex * pBatches->nBatchBoneMax]);
	}
	return self;
}

+(id) skinSectionFromBatchAtIndex: (GLint) aBatchIndex
					 fromSPODMesh: (PODStructPtr) aSPODMesh
						  forNode: (CC3SkinMeshNode*) aNode {
	return [[[self alloc] initFromBatchAtIndex: aBatchIndex fromSPODMesh: aSPODMesh forNode: aNode] autorelease];

}

-(void) linkToPODNodes: (NSArray*) nodeArray {
	for (GLint boneNum = 0; boneNum < _podBoneCount; boneNum++) {
		GLint boneIndex = _podBoneNodeIndices[boneNum];
		CC3Bone* boneNode = [nodeArray objectAtIndex: boneIndex];
		LogTrace(@"Adding bone node %@ at index %i to %@", boneNode, boneIndex, self);
		[self addBone: boneNode];
	}
	_podBoneNodeIndices = NULL;		// Remove reference since this array will be released
	_podBoneCount = 0;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ from original bone count %i of indices at %p",
			[super fullDescription], _podBoneCount, _podBoneNodeIndices];
}

@end


#pragma mark -
#pragma mark CC3PODBone

@implementation CC3PODBone

-(GLint) podIndex { return _podIndex; }

-(void) setPodIndex: (GLint) aPODIndex { _podIndex = aPODIndex; }

-(GLint) podContentIndex { return _podContentIndex; }

-(void) setPodContentIndex: (GLint) aPODIndex { _podContentIndex = aPODIndex; }

-(GLint) podParentIndex { return _podParentIndex; }

-(void) setPodParentIndex: (GLint) aPODIndex { _podParentIndex = aPODIndex; }

-(void) populateFrom: (CC3PODNode*) another {
	[super populateFrom: another];
	
	_podIndex = another.podIndex;
	_podContentIndex = another.podContentIndex;
	_podParentIndex = another.podParentIndex;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (POD index: %i)", [super description], _podIndex];
}

@end

