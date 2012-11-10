/*
 * CC3PODResource.mm
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
 * 
 * See header file CC3PODResource.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}
#import "CC3PODResource.h"
#import "CC3PVRTModelPOD.h"
#import "CC3PODNode.h"
#import "CC3PODMeshNode.h"
#import "CC3PODCamera.h"
#import "CC3PODLight.h"
#import "CC3PODMesh.h"
#import "CC3PODMaterial.h"
#import "CC3PODVertexSkinning.h"
#import "CC3CC2Extensions.h"
#import "CCTextureCache.h"


/**
 * A placeholder object used to mark places in arrays where valid input is not present
 * Arrays may not hold nil, therefore this singleton placeholder object is used instead.
 */
static const id placeHolder = [NSObject new];


@interface CC3PODResource (TemplateMethods)

/** The underlying pvrtModel property, cast to the correct CPVRTModelPOD C++ class. */
@property(nonatomic, readonly)  CPVRTModelPOD* pvrtModelImpl;
@end


@implementation CC3PODResource

@synthesize pvrtModel, allNodes, meshes, materials, textures, textureParameters;

-(void) dealloc {
	[allNodes release];
	[meshes release];
	[materials release];
	[textures release];
	if (self.pvrtModelImpl) delete (CPVRTModelPOD*)self.pvrtModelImpl;
	pvrtModel = NULL;
	[super dealloc];
}

-(CPVRTModelPOD*) pvrtModelImpl { return (CPVRTModelPOD*)pvrtModel; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		pvrtModel = new CPVRTModelPOD();
		allNodes = [[CCArray array] retain];
		meshes = [[CCArray array] retain];
		materials = [[CCArray array] retain];
		textures = [[CCArray array] retain];
		textureParameters = [CC3Texture defaultTextureParameters];
	}
	return self;
}

-(BOOL) processFile: (NSString*) anAbsoluteFilePath {
	wasLoaded = (self.pvrtModelImpl->ReadFromFile([anAbsoluteFilePath cStringUsingEncoding:NSUTF8StringEncoding]) == PVR_SUCCESS);
	if (wasLoaded) [self build];
	return wasLoaded;
}

-(void) build {
	LogRez(@"Building %@", self.fullDescription);
	[self buildTextures];
	[self buildMaterials];
	[self buildMeshes];
	[self buildNodes];
	[self buildSoftBodyNode];
}


#pragma mark Accessing node data and building nodes

-(uint) nodeCount { return self.pvrtModelImpl->nNumNode; }

-(CC3Node*) nodeAtIndex: (uint) nodeIndex {
	return (CC3Node*)[allNodes objectAtIndex: nodeIndex];
}

-(CC3Node*) nodeNamed: (NSString*) aName {
	NSString* lcName = [aName lowercaseString];
	uint nCnt = self.nodeCount;
	for (uint i = 0; i < nCnt; i++) {
		CC3Node* aNode = [self nodeAtIndex: i];
		if ([[aNode.name lowercaseString] isEqualToString: lcName]) {
			return aNode;
		}
	}
	return nil;
}

-(void) buildNodes {
	uint nCount = self.nodeCount;

	// Build the array containing ALL nodes in the PVRT structure
	for (uint i = 0; i < nCount; i++) {
		[allNodes addObject: [self buildNodeAtIndex: i]];
	}

	// Link the nodes with each other. This includes assembling the nodes into a structural
	// parent-child hierarchy, and connecting targetting nodes with their targets.
	// Base nodes, which have no parent, form the entries of the nodes array.
	for (CC3Node* aNode in allNodes) {
		[aNode linkToPODNodes: allNodes];
		if (aNode.isBasePODNode) {
			[self.nodes addObject: aNode];
		}
	}
}

-(CC3Node*) buildNodeAtIndex: (uint) nodeIndex {
	// Mesh nodes are arranged first
	if (nodeIndex < self.meshNodeCount) {
		return [self buildMeshNodeAtIndex: nodeIndex];
	}
	// Then light nodes
	if (nodeIndex < self.meshNodeCount + self.lightCount) {
		return [self buildLightAtIndex: (nodeIndex - self.meshNodeCount)];
	}
	// Then camera nodes
	if (nodeIndex < self.meshNodeCount + self.lightCount + self.cameraCount) {
		return [self buildCameraAtIndex: (nodeIndex - (self.meshNodeCount + self.lightCount))];
	}
	// Finally general nodes, including structural nodes or targets for lights or cameras
	return [self buildStructuralNodeAtIndex: nodeIndex];
}

-(CC3Node*) buildStructuralNodeAtIndex: (uint) nodeIndex {
	if ( [self isBoneNode: nodeIndex] ) {
		return [CC3PODBone nodeAtIndex: nodeIndex fromPODResource: self];
	}
	return [CC3PODNode nodeAtIndex: nodeIndex fromPODResource: self];
}

-(PODStructPtr) nodePODStructAtIndex: (uint) nodeIndex {
	return &self.pvrtModelImpl->pNode[nodeIndex];
}

-(BOOL) isNodeIndex: (int) aNodeIndex ancestorOfNodeIndex: (int) childIndex {

	// Return YES if nodes are the same
	if (aNodeIndex == childIndex) return YES;

	// Get the SPOD structure of the child, and extract the index of its parent node.
	// Return no parent
	SPODNode* psn = (SPODNode*)[self nodePODStructAtIndex: childIndex];
	int parentIndex = psn->nIdxParent;
	if (parentIndex < 0) return NO;

	// Invoke recursion on the index of the parent node
	return [self isNodeIndex: aNodeIndex ancestorOfNodeIndex: parentIndex];
}

-(BOOL) isBoneNode: (uint) aNodeIndex {
	uint mCount = self.meshCount;
	// Cycle through the meshes
	for (uint mi = 0; mi < mCount; mi++) {
		SPODMesh* psm = (SPODMesh*)[self meshPODStructAtIndex: mi];
		CPVRTBoneBatches* pbb = &psm->sBoneBatches;

		// Cycle through the bone batches within each mesh
		for (int batchIndex = 0; batchIndex < pbb->nBatchCnt; batchIndex++) {
			int boneCount = pbb->pnBatchBoneCnt[batchIndex];
			int* boneNodeIndices = &(pbb->pnBatches[batchIndex * pbb->nBatchBoneMax]);

			// Cycle through the bones of each batch. If the bone node is a child of
			// the specified node, then the specified node is a bone as well.
			for (int boneIndex = 0; boneIndex < boneCount; boneIndex++) {
				if ( [self isNodeIndex: aNodeIndex ancestorOfNodeIndex: boneNodeIndices[boneIndex]] ) {
					return YES;
				}
			}
		}
	}
	return NO;
}

-(void) buildSoftBodyNode {
	CCArray* softBodyComponents = [CCArray arrayWithCapacity: nodes.count];
	for (CC3Node* baseNode in nodes) {
		if (baseNode.hasSoftBodyContent) {
			[softBodyComponents addObject: baseNode];
		}
	}
	if (softBodyComponents.count > 0) {
		NSString* sbName = [NSString stringWithFormat: @"%@-SoftBody", self.name];
		CC3SoftBodyNode* sbn = [CC3SoftBodyNode nodeWithName: sbName];
		for (CC3Node* sbc in softBodyComponents) {
			[sbn addChild: sbc];
			[nodes removeObjectIdenticalTo: sbc];
		}
		[sbn bindRestPose];
		[nodes addObject: sbn];
	}
}


#pragma mark Accessing mesh data and building mesh nodes

-(uint) meshNodeCount {
	return self.pvrtModelImpl->nNumMeshNode;
}

-(CC3MeshNode*) meshNodeAtIndex: (uint) meshIndex {
	// mesh nodes appear first in the node array
	return (CC3MeshNode*)[self nodeAtIndex: meshIndex];
}

/** If we are vertex skinning, return a skin mesh node, otherwise return a generic mesh node. */
-(CC3MeshNode*) buildMeshNodeAtIndex: (uint) meshNodeIndex {
	SPODNode* psn = (SPODNode*)[self meshNodePODStructAtIndex: meshNodeIndex];
	SPODMesh* psm = (SPODMesh*)[self meshPODStructAtIndex: psn->nIdx];
	if (psm->sBoneBatches.nBatchCnt) {
		return [CC3PODSkinMeshNode nodeAtIndex: meshNodeIndex fromPODResource: self];
	}
	return [CC3PODMeshNode nodeAtIndex: meshNodeIndex fromPODResource: self];
}

-(PODStructPtr) meshNodePODStructAtIndex: (uint) meshIndex {
	// mesh nodes appear first in the node array
	return [self nodePODStructAtIndex: meshIndex];
}

-(uint) meshCount {
	return self.pvrtModelImpl->nNumMesh;
}

-(void) buildMeshes {
	uint mCount = self.meshCount;
	
	// Build the array containing all materials in the PVRT structure
	for (uint i = 0; i < mCount; i++) {
		[meshes addObject: [self buildMeshAtIndex: i]];
	}
}

-(CC3Mesh*) meshAtIndex: (uint) meshIndex {
	return (CC3Mesh*)[meshes objectAtIndex: meshIndex];
}

// Deprecated method.
-(CC3Mesh*) meshModelAtIndex: (uint) meshIndex { return [self meshAtIndex: meshIndex]; }

/** If we have skinning bones, return a skinned mesh, otherwise return a generic mesh. */
-(CC3Mesh*) buildMeshAtIndex: (uint) meshIndex {
	SPODMesh* psm = (SPODMesh*)[self meshPODStructAtIndex: meshIndex];
	if (psm->sBoneBatches.nBatchCnt) {
		return [CC3PODSkinMesh meshAtIndex:meshIndex fromPODResource:self];
	}
	return [CC3PODMesh meshAtIndex: meshIndex fromPODResource: self];
}

-(PODStructPtr) meshPODStructAtIndex: (uint) meshIndex {
	return &self.pvrtModelImpl->pMesh[meshIndex];
}


#pragma mark Accessing light data and building light nodes

-(uint) lightCount {
	return self.pvrtModelImpl->nNumLight;
}

-(CC3Light*) lightAtIndex: (uint) lightIndex {
	// light nodes appear after all the mesh nodes in the node array
	return (CC3Light*)[self nodeAtIndex: (self.meshNodeCount + lightIndex)];
}

-(CC3Light*) buildLightAtIndex: (uint) lightIndex {
	return [CC3PODLight nodeAtIndex: lightIndex fromPODResource: self];
}

-(PODStructPtr) lightNodePODStructAtIndex: (uint) lightIndex {
	// light nodes appear after all the mesh nodes in the node array
	return [self nodePODStructAtIndex: (self.meshNodeCount + lightIndex)];
}

-(PODStructPtr) lightPODStructAtIndex: (uint) lightIndex {
	return &self.pvrtModelImpl->pLight[lightIndex];
}


#pragma mark Accessing cameras data and building camera nodes

-(uint) cameraCount {
	return self.pvrtModelImpl->nNumCamera;
}

-(CC3Camera*) cameraAtIndex: (uint) cameraIndex {
	return (CC3Camera*)[self nodeAtIndex: (self.meshNodeCount + self.lightCount + cameraIndex)];
}

-(CC3Camera*) buildCameraAtIndex: (uint) cameraIndex {
	return [CC3PODCamera nodeAtIndex: cameraIndex fromPODResource: self];
}

-(PODStructPtr) cameraNodePODStructAtIndex: (uint) cameraIndex {
	// camera nodes appear after all the mesh nodes and light nodes in the node array
	return [self nodePODStructAtIndex: (self.meshNodeCount + self.lightCount + cameraIndex)];
}

-(PODStructPtr) cameraPODStructAtIndex: (uint) cameraIndex {
	return &self.pvrtModelImpl->pCamera[cameraIndex];
}


#pragma mark Accessing material data and building materials

-(uint) materialCount {
	return self.pvrtModelImpl->nNumMaterial;
}

-(CC3Material*) materialAtIndex: (uint) materialIndex {
	return (CC3Material*)[materials objectAtIndex: materialIndex];
}

-(CC3Material*) materialNamed: (NSString*) aName {
	NSString* lcName = [aName lowercaseString];
	uint mCnt = self.materialCount;
	for (uint i = 0; i < mCnt; i++) {
		CC3Material* aMat = [self materialAtIndex: i];
		if ([[aMat.name lowercaseString] isEqualToString: lcName]) {
			return aMat;
		}
	}
	return nil;
}

-(void) buildMaterials {
	uint mCount = self.materialCount;
	
	// Build the array containing all materials in the PVRT structure
	for (uint i = 0; i < mCount; i++) {
		[materials addObject: [self buildMaterialAtIndex: i]];
	}
}

-(CC3Material*) buildMaterialAtIndex: (uint) materialIndex {
	return [CC3PODMaterial materialAtIndex: materialIndex fromPODResource: self];
}

-(PODStructPtr) materialPODStructAtIndex: (uint) materialIndex {
	return &self.pvrtModelImpl->pMaterial[materialIndex];
}


#pragma mark Accessing texture data and building textures

-(uint) textureCount {
	return self.pvrtModelImpl->nNumTexture;
}

-(CC3Texture*) textureAtIndex: (uint) textureIndex {
	id tex = [textures objectAtIndex: textureIndex];
	return (tex != placeHolder) ? (CC3Texture*)tex : nil;
}

-(void) buildTextures {
	uint tCount = self.textureCount;
	
	// Build the array containing all textures in the PVRT structure
	for (uint i = 0; i < tCount; i++) {
		CC3Texture* tex = [self buildTextureAtIndex: i];
		// Add the texture, or if it couldn't be built, an empty texture
		[textures addObject: (tex ? tex : placeHolder)];
	}
}

/** Loads the texture file from the directory indicated by the directory property. */
-(CC3Texture*) buildTextureAtIndex: (uint) textureIndex {
	SPODTexture* pst = (SPODTexture*)[self texturePODStructAtIndex: textureIndex];
	NSString* texFile = [NSString stringWithUTF8String: pst->pszName];
	NSString* texPath = [directory stringByAppendingPathComponent: texFile];
	CC3Texture* tex = [CC3Texture textureFromFile: texPath];
	tex.textureParameters = textureParameters;
	LogRez(@"Creating %@ at POD index %u from: '%@'", tex, textureIndex, texPath);
	return tex;
}

-(PODStructPtr) texturePODStructAtIndex: (uint) textureIndex {
	return &self.pvrtModelImpl->pTexture[textureIndex];
}


#pragma mark Accessing miscellaneuous content

-(uint) animationFrameCount {
	return self.pvrtModelImpl->nNumFrame;
}

-(ccColor4F) ambientLight {
	GLfloat* amb = self.pvrtModelImpl->pfColourAmbient;
	return CCC4FMake(amb[0], amb[1], amb[2], 1.0);
}

-(ccColor4F) backgroundColor {
	GLfloat* bg = self.pvrtModelImpl->pfColourBackground;
	return CCC4FMake(bg[0], bg[1], bg[2], 1.0);
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ from file %@", [self class], self.name];
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self];
	if (self.pvrtModelImpl->nFlags & PVRTMODELPODSF_FIXED) {		// highlight if fixed point
		[desc appendFormat: @" (FIXED POINT!!)"];
	}
	[desc appendFormat: @" containing %u nodes", self.nodeCount];
	[desc appendFormat: @" (%u mesh nodes)", self.meshNodeCount];
	[desc appendFormat: @", %u meshes", self.meshCount];
	[desc appendFormat: @", %u cameras", self.cameraCount];
	[desc appendFormat: @", %u lights", self.lightCount];
	[desc appendFormat: @", %u materials", self.materialCount];
	[desc appendFormat: @", %u textures", self.textureCount];
	[desc appendFormat: @", %u frames", self.animationFrameCount];
	[desc appendFormat: @", ambient light %@", NSStringFromCCC4F(self.ambientLight)];
	[desc appendFormat: @", background color %@", NSStringFromCCC4F(self.backgroundColor)];
	return desc;
}

@end
