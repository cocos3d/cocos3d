/*
 * CC3PODResource.mm
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
#import "CC3PFXResource.h"
#import "CC3CC2Extensions.h"


@implementation CC3PODResource

@synthesize pvrtModel=_pvrtModel, allNodes=_allNodes, meshes=_meshes;
@synthesize materials=_materials, textures=_textures, textureParameters=_textureParameters;
@synthesize shouldAutoBuild = _shouldAutoBuild;
@synthesize ambientLight=_ambientLight, backgroundColor=_backgroundColor;
@synthesize animationFrameCount=_animationFrameCount, animationFrameRate=_animationFrameRate;

-(void) dealloc {
	[_allNodes release];
	[_meshes release];
	[_materials release];
	[_textures release];

	[self deleteCPVRTModelPOD];

	[super dealloc];
}

-(CPVRTModelPOD*) pvrtModelImpl { return (CPVRTModelPOD*)_pvrtModel; }

-(void) createCPVRTModelPOD { if ( !_pvrtModel ) _pvrtModel = new CPVRTModelPOD(); }

-(void) deleteCPVRTModelPOD {
	if (_pvrtModel) delete self.pvrtModelImpl;
	_pvrtModel = NULL;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_pvrtModel = NULL;
		_allNodes = [NSMutableArray new];		// retain
		_meshes = [NSMutableArray new];			// retain
		_materials = [NSMutableArray new];		// retain
		_textures = [NSMutableArray new];		// retain
		_textureParameters = [CC3Texture defaultTextureParameters];
		_shouldAutoBuild = YES;
	}
	return self;
}

-(BOOL) processFile: (NSString*) anAbsoluteFilePath {

	// Split the path into directory and file names and set the PVR read path to the directory and
	// pass the unqualified file name to the parser. This allows the parser to locate any additional
	// files that might be read as part of the parsing.
	NSString* fileName = anAbsoluteFilePath.lastPathComponent;
	NSString* dirName = anAbsoluteFilePath.stringByDeletingLastPathComponent;

	CPVRTResourceFile::SetReadPath([dirName stringByAppendingString: @"/"].UTF8String);
	
	[self createCPVRTModelPOD];
	BOOL wasLoaded = (self.pvrtModelImpl->ReadFromFile(fileName.UTF8String) == PVR_SUCCESS);
	
	if (wasLoaded && _shouldAutoBuild) [self build];
	
	return wasLoaded;
}


#pragma mark Building

-(void) build {
	[self buildSceneInfo];
	LogRez(@"Building %@", self.fullDescription);
	[self buildTextures];
	[self buildMaterials];
	[self buildMeshes];
	[self buildNodes];
	[self buildSoftBodyNode];
	[self deleteCPVRTModelPOD];
}

-(BOOL) saveToFile: (NSString*) aFilePath {
	
	CC3Assert(_pvrtModel, @"%@ cannot be saved because the POD file content has been built and released from memory."
			  " Set the shouldAutoBuild property to NO before loading the POD file content in order to be able to save it back to a file.", self);
	
	// Ensure the path is absolute, converting it if needed.
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
	
	MarkRezActivityStart();
	
	BOOL wasSaved = (self.pvrtModelImpl->SavePOD(absFilePath.UTF8String) == PVR_SUCCESS);
	
	if (wasSaved)
		LogRez(@"%@ saved resources to file '%@' in %.3f ms", self, aFilePath, GetRezActivityDuration() * 1000);
	else
		LogError(@"%@ could not save resources to file '%@'", self, absFilePath);
	
	return wasSaved;
}

-(BOOL) saveAnimationToFile: (NSString*) aFilePath {
	
	CC3Assert(_pvrtModel, @"%@ could not save animation content because the POD file content has been built and released from memory."
			  " Set the shouldAutoBuild property to NO before loading the POD file content in order to be able to save the animation content to a file.", self);
	
	// Ensure the path is absolute, converting it if needed.
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
	
	MarkRezActivityStart();

	CPVRTModelPOD* myPod = self.pvrtModelImpl;
	CPVRTModelPOD* pod = new CPVRTModelPOD();
	
	// Scene animation content
	pod->nNumFrame = myPod->nNumFrame;
	pod->nFPS = myPod->nFPS;
	pod->nFlags = myPod->nFlags;

	// Allocate enough memory for the nodes and copy them over,
	// except for the content and material references
	pod->pNode = NULL;
	GLuint nodeCnt = myPod->nNumNode;
	pod->nNumNode = nodeCnt;
	if (nodeCnt) {
		pod->pNode = (SPODNode*)calloc(nodeCnt, sizeof(SPODNode));
		for(GLuint nodeIdx = 0; nodeIdx < nodeCnt; nodeIdx++) {
			PVRTModelPODCopyNode(myPod->pNode[nodeIdx], pod->pNode[nodeIdx], myPod->nNumFrame);
			pod->pNode[nodeIdx].nIdx = -1;
			pod->pNode[nodeIdx].nIdxMaterial = -1;
		}
	}
	
	// Ensure remaining content is blank. Constructor does not initialize to safe empty state!!
	pod->pfColourBackground[0] = pod->pfColourBackground[1] = pod->pfColourBackground[2] = 0.0;
	pod->pfColourAmbient[0] = pod->pfColourAmbient[1] = pod->pfColourAmbient[2] = 0.0;

	pod->nNumMeshNode = 0;
	
	pod->nNumCamera = 0;
	pod->pCamera = NULL;
	
	pod->nNumLight = 0;
	pod->pLight = NULL;
	
	pod->nNumMesh = 0;
	pod->pMesh = NULL;
	
	pod->nNumMaterial = 0;
	pod->pMaterial = NULL;

	pod->nNumTexture = 0;
	pod->pTexture = NULL;
	
	pod->nUserDataSize = 0;
	pod->pUserData = NULL;
	
	pod->InitImpl();
	
	BOOL wasSaved = (pod->SavePOD(absFilePath.UTF8String) == PVR_SUCCESS);

	delete pod;
	
	if (wasSaved)
		LogRez(@"%@ saved animation content to file '%@' in %.3f ms", self, aFilePath, GetRezActivityDuration() * 1000.0);
	else
		LogError(@"%@ could not save animation content to file '%@'", self, absFilePath);
	
	return wasSaved;
}


#pragma mark Accessing scene info

-(void) buildSceneInfo {
	CPVRTModelPOD* pod = self.pvrtModelImpl;
	GLfloat* rgb;
	
	rgb = pod->pfColourAmbient;
	_ambientLight = ccc4f(rgb[0], rgb[1], rgb[2], 1.0);

	rgb = pod->pfColourBackground;
	_backgroundColor = ccc4f(rgb[0], rgb[1], rgb[2], 1.0);

	_animationFrameCount = pod->nNumFrame;
	_animationFrameRate = pod->nFPS;
	
	// Assign any user data and take ownership of managing its memory
	if (pod->pUserData && pod->nUserDataSize > 0) {
		self.userData = [NSData dataWithBytesNoCopy: pod->pUserData length: pod->nUserDataSize];
		pod->pUserData = NULL;		// Clear reference so SPODNode won't try to free it.
	}
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self];
	if (_pvrtModel && self.pvrtModelImpl->nFlags & PVRTMODELPODSF_FIXED) [desc appendFormat: @" (FIXED POINT!!)"];
	[desc appendFormat: @" containing %u nodes", self.nodeCount];
	[desc appendFormat: @" (%u mesh nodes)", self.meshNodeCount];
	[desc appendFormat: @", %u meshes", self.meshCount];
	[desc appendFormat: @", %u cameras", self.cameraCount];
	[desc appendFormat: @", %u lights", self.lightCount];
	[desc appendFormat: @", %u materials", self.materialCount];
	[desc appendFormat: @", %u textures", self.textureCount];
	[desc appendFormat: @", ambient light %@", NSStringFromCCC4F(self.ambientLight)];
	[desc appendFormat: @", background color %@", NSStringFromCCC4F(self.backgroundColor)];
	[desc appendFormat: @", %u frames of animation at %.1f FPS", self.animationFrameCount, self.animationFrameRate];
	return desc;
}


#pragma mark Accessing node data and building nodes

-(GLuint) nodeCount { return _pvrtModel ? self.pvrtModelImpl->nNumNode : 0; }

-(CC3Node*) nodeAtIndex: (GLuint) nodeIndex {
	return (CC3Node*)[_allNodes objectAtIndex: nodeIndex];
}

-(CC3Node*) nodeNamed: (NSString*) aName {
	NSString* lcName = [aName lowercaseString];
	GLuint nCnt = self.nodeCount;
	for (GLuint i = 0; i < nCnt; i++) {
		CC3Node* aNode = [self nodeAtIndex: i];
		if ([[aNode.name lowercaseString] isEqualToString: lcName]) return aNode;
	}
	return nil;
}

-(void) buildNodes {
	GLuint nCount = self.nodeCount;

	// Build the array containing ALL nodes in the PVRT structure
	for (GLuint i = 0; i < nCount; i++) [_allNodes addObject: [self buildNodeAtIndex: i]];

	// Link the nodes with each other. This includes assembling the nodes into a structural
	// parent-child hierarchy, and connecting targetting nodes with their targets.
	// Base nodes, which have no parent, form the entries of the nodes array.
	for (CC3Node* aNode in _allNodes) {
		[aNode linkToPODNodes: _allNodes];
		if (aNode.isBasePODNode) [self addNode: aNode];
	}
}

-(CC3Node*) buildNodeAtIndex: (GLuint) nodeIndex {
	// Mesh nodes are arranged first
	if (nodeIndex < self.meshNodeCount) return [self buildMeshNodeAtIndex: nodeIndex];

	// Then light nodes
	if (nodeIndex < self.meshNodeCount + self.lightCount)
		return [self buildLightAtIndex: (nodeIndex - self.meshNodeCount)];
	
	// Then camera nodes
	if (nodeIndex < self.meshNodeCount + self.lightCount + self.cameraCount)
		return [self buildCameraAtIndex: (nodeIndex - (self.meshNodeCount + self.lightCount))];

	// Finally general nodes, including structural nodes or targets for lights or cameras
	return [self buildStructuralNodeAtIndex: nodeIndex];
}

-(CC3Node*) buildStructuralNodeAtIndex: (GLuint) nodeIndex {
	if ( [self isBoneNode: nodeIndex] )
		return [self.boneNodeClass nodeAtIndex: nodeIndex fromPODResource: self];
	return [self.structuralNodeClass nodeAtIndex: nodeIndex fromPODResource: self];
}

-(PODStructPtr) nodePODStructAtIndex: (GLuint) nodeIndex { return &self.pvrtModelImpl->pNode[nodeIndex]; }

-(BOOL) isNodeIndex: (GLint) aNodeIndex ancestorOfNodeIndex: (GLint) childIndex {

	// Return YES if nodes are the same
	if (aNodeIndex == childIndex) return YES;

	// Get the SPOD structure of the child, and extract the index of its parent node.
	// Return no parent
	SPODNode* psn = (SPODNode*)[self nodePODStructAtIndex: childIndex];
	GLint parentIndex = psn->nIdxParent;
	if (parentIndex < 0) return NO;

	// Invoke recursion on the index of the parent node
	return [self isNodeIndex: aNodeIndex ancestorOfNodeIndex: parentIndex];
}

-(BOOL) isBoneNode: (GLuint) aNodeIndex {
	GLuint mCount = self.meshCount;
	// Cycle through the meshes
	for (GLuint mi = 0; mi < mCount; mi++) {
		SPODMesh* psm = (SPODMesh*)[self meshPODStructAtIndex: mi];
		CPVRTBoneBatches* pbb = &psm->sBoneBatches;

		// Cycle through the bone batches within each mesh
		for (GLint batchIndex = 0; batchIndex < pbb->nBatchCnt; batchIndex++) {
			GLint boneCount = pbb->pnBatchBoneCnt[batchIndex];
			GLint* boneNodeIndices = &(pbb->pnBatches[batchIndex * pbb->nBatchBoneMax]);

			// Cycle through the bones of each batch. If the bone node is a child of
			// the specified node, then the specified node is a bone as well.
			for (GLint boneIndex = 0; boneIndex < boneCount; boneIndex++) {
				if ( [self isNodeIndex: aNodeIndex ancestorOfNodeIndex: boneNodeIndices[boneIndex]] ) return YES;
			}
		}
	}
	return NO;
}

-(void) buildSoftBodyNode {
	NSArray* myNodes = self.nodes;
	NSMutableArray* softBodyComponents = [NSMutableArray arrayWithCapacity: myNodes.count];
	for (CC3Node* baseNode in myNodes)
		if (baseNode.hasSoftBodyContent) [softBodyComponents addObject: baseNode];

	if (softBodyComponents.count > 0) {
		NSString* sbName = [NSString stringWithFormat: @"%@-SoftBody", self.name];
		CC3SoftBodyNode* sbn = [self.softBodyNodeClass nodeWithName: sbName];
		for (CC3Node* sbc in softBodyComponents) {
			[sbn addChild: sbc];
			[self removeNode: sbc];
		}
		[sbn bindRestPose];
		[self addNode: sbn];
	}
}


#pragma mark Accessing mesh data and building mesh nodes

-(GLuint) meshNodeCount { return _pvrtModel ? self.pvrtModelImpl->nNumMeshNode : 0; }

// mesh nodes appear first in the node array
-(CC3MeshNode*) meshNodeAtIndex: (GLuint) meshIndex { return (CC3MeshNode*)[self nodeAtIndex: meshIndex]; }

/** If we are vertex skinning, return a skin mesh node, otherwise return a generic mesh node. */
-(CC3MeshNode*) buildMeshNodeAtIndex: (GLuint) meshNodeIndex {
	SPODNode* psn = (SPODNode*)[self meshNodePODStructAtIndex: meshNodeIndex];
	SPODMesh* psm = (SPODMesh*)[self meshPODStructAtIndex: psn->nIdx];
	if (psm->sBoneBatches.nBatchCnt)
		return [self.skinMeshNodeClass nodeAtIndex: meshNodeIndex fromPODResource: self];
	return [self.meshNodeClass nodeAtIndex: meshNodeIndex fromPODResource: self];
}

// mesh nodes appear first in the node array
-(PODStructPtr) meshNodePODStructAtIndex: (GLuint) meshIndex { return [self nodePODStructAtIndex: meshIndex]; }

-(GLuint) meshCount { return _pvrtModel ? self.pvrtModelImpl->nNumMesh : 0; }

// Build the array containing all materials in the PVRT structure
-(void) buildMeshes {
	GLuint mCount = self.meshCount;
	for (GLuint i = 0; i < mCount; i++) [_meshes addObject: [self buildMeshAtIndex: i]];
}

-(CC3Mesh*) meshAtIndex: (GLuint) meshIndex { return (CC3Mesh*)[_meshes objectAtIndex: meshIndex]; }

// Deprecated method.
-(CC3Mesh*) meshModelAtIndex: (GLuint) meshIndex { return [self meshAtIndex: meshIndex]; }

-(CC3Mesh*) buildMeshAtIndex: (GLuint) meshIndex {
	return [self.meshClass meshAtIndex: meshIndex fromPODResource: self];
}

-(PODStructPtr) meshPODStructAtIndex: (GLuint) meshIndex { return &self.pvrtModelImpl->pMesh[meshIndex]; }


#pragma mark Accessing light data and building light nodes

-(GLuint) lightCount { return _pvrtModel ? self.pvrtModelImpl->nNumLight : 0; }

// light nodes appear after all the mesh nodes in the node array
-(CC3Light*) lightAtIndex: (GLuint) lightIndex {
	return (CC3Light*)[self nodeAtIndex: (self.meshNodeCount + lightIndex)];
}

-(CC3Light*) buildLightAtIndex: (GLuint) lightIndex {
	return [self.lightClass nodeAtIndex: lightIndex fromPODResource: self];
}

// light nodes appear after all the mesh nodes in the node array
-(PODStructPtr) lightNodePODStructAtIndex: (GLuint) lightIndex {
	return [self nodePODStructAtIndex: (self.meshNodeCount + lightIndex)];
}

-(PODStructPtr) lightPODStructAtIndex: (GLuint) lightIndex { return &self.pvrtModelImpl->pLight[lightIndex]; }


#pragma mark Accessing cameras data and building camera nodes

-(GLuint) cameraCount { return _pvrtModel ? self.pvrtModelImpl->nNumCamera : 0; }

-(CC3Camera*) cameraAtIndex: (GLuint) cameraIndex {
	return (CC3Camera*)[self nodeAtIndex: (self.meshNodeCount + self.lightCount + cameraIndex)];
}

-(CC3Camera*) buildCameraAtIndex: (GLuint) cameraIndex {
	return [self.cameraClass nodeAtIndex: cameraIndex fromPODResource: self];
}

// camera nodes appear after all the mesh nodes and light nodes in the node array
-(PODStructPtr) cameraNodePODStructAtIndex: (GLuint) cameraIndex {
	return [self nodePODStructAtIndex: (self.meshNodeCount + self.lightCount + cameraIndex)];
}

-(PODStructPtr) cameraPODStructAtIndex: (GLuint) cameraIndex {
	return &self.pvrtModelImpl->pCamera[cameraIndex];
}


#pragma mark Accessing material data and building materials

-(GLuint) materialCount { return _pvrtModel ? self.pvrtModelImpl->nNumMaterial : 0; }

// Fail safely when node references a material that is not in the POD
-(CC3Material*) materialAtIndex: (GLuint) materialIndex {
	if (materialIndex >= _materials.count) {
		LogRez(@"This POD has no material at index %i", materialIndex);
		return nil;
	}
	return (CC3Material*)[_materials objectAtIndex: materialIndex];
}

-(CC3Material*) materialNamed: (NSString*) aName {
	NSString* lcName = [aName lowercaseString];
	GLuint mCnt = self.materialCount;
	for (GLuint i = 0; i < mCnt; i++) {
		CC3Material* aMat = [self materialAtIndex: i];
		if ([[aMat.name lowercaseString] isEqualToString: lcName]) return aMat;
	}
	return nil;
}

// Build the array containing all materials in the PVRT structure
-(void) buildMaterials {
	GLuint mCount = self.materialCount;
	for (GLuint i = 0; i < mCount; i++) [_materials addObject: [self buildMaterialAtIndex: i]];
}

-(CC3Material*) buildMaterialAtIndex: (GLuint) materialIndex {
	return [self.materialClass materialAtIndex: materialIndex fromPODResource: self];
}

-(PODStructPtr) materialPODStructAtIndex: (GLuint) materialIndex {
	return &self.pvrtModelImpl->pMaterial[materialIndex];
}


#pragma mark Accessing texture data and building textures

-(GLuint) textureCount { return _pvrtModel ? self.pvrtModelImpl->nNumTexture : 0; }

-(CC3Texture*) textureAtIndex: (GLuint) textureIndex {
	NSObject* tex = [_textures objectAtIndex: textureIndex];
	return (tex.isNull) ? nil : (CC3Texture*)tex;
}

-(void) buildTextures {
	GLuint tCount = self.textureCount;
	
	// Build the array containing all textures in the PVRT structure
	for (GLuint i = 0; i < tCount; i++) {
		CC3Texture* tex = [self buildTextureAtIndex: i];
		// Add the texture, or if it couldn't be built, an null placeholder
		[_textures addObject: (tex ? tex : NSNull.null)];
	}
}

/** Loads the texture file from the directory indicated by the directory property. */
-(CC3Texture*) buildTextureAtIndex: (GLuint) textureIndex {
	SPODTexture* pst = (SPODTexture*)[self texturePODStructAtIndex: textureIndex];
	NSString* texFile = [NSString stringWithUTF8String: pst->pszName];
	NSString* texPath = [self.directory stringByAppendingPathComponent: texFile];
	CC3Texture* tex = [CC3Texture textureFromFile: texPath];
	tex.textureParameters = _textureParameters;
	LogRez(@"Creating %@ at POD index %u from: '%@'", tex, textureIndex, texPath);
	return tex;
}

-(PODStructPtr) texturePODStructAtIndex: (GLuint) textureIndex {
	return &self.pvrtModelImpl->pTexture[textureIndex];
}


#pragma mark Content classes

-(Class) structuralNodeClass { return [CC3PODNode class]; }

-(Class) meshNodeClass { return [CC3PODMeshNode class]; }

-(Class) meshClass { return [CC3PODMesh class]; }

-(Class) materialClass { return [CC3PODMaterial class]; }

-(Class) skinMeshNodeClass { return [CC3PODSkinMeshNode class]; }

-(Class) boneNodeClass { return [CC3PODBone class]; }

-(Class) softBodyNodeClass { return [CC3SoftBodyNode class]; }

-(Class) lightClass { return [CC3PODLight class]; }

-(Class) cameraClass { return [CC3PODCamera class]; }

-(Class) pfxResourceClass { return [CC3PFXResource class]; }

@end


#pragma mark -
#pragma mark Adding animation to nodes

@implementation CC3Node (PODAnimation)

-(void) addAnimationFromPODFile: (NSString*) podFilePath asTrack: (GLuint) trackID {
	[self addAnimationInResource: [CC3PODResource resourceFromFile: podFilePath ] asTrack: trackID];
}

-(GLuint) addAnimationFromPODFile: (NSString*) podFilePath {
	return [self addAnimationInResource: [CC3PODResource resourceFromFile: podFilePath ]];
}

@end


