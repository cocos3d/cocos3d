/*
 * CC3PODResource.mm
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

@synthesize pvrtModel, allNodes, meshModels, materials, textures, textureParameters;

-(void) dealloc {
	[allNodes release];
	[meshModels release];
	[materials release];
	[textures release];
	if (self.pvrtModel) {
		delete self.pvrtModelImpl;
	}
	[super dealloc];
}

-(CPVRTModelPOD*) pvrtModelImpl {
	return (CPVRTModelPOD*)pvrtModel;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		pvrtModel = new CPVRTModelPOD();
		allNodes = [[NSMutableArray array] retain];
		meshModels = [[NSMutableArray array] retain];
		materials = [[NSMutableArray array] retain];
		textures = [[NSMutableArray array] retain];
		self.textureParameters = kCC3DefaultTextureParameters;
		wasLoaded = NO;
	}
	return self;
}

-(BOOL) loadFromFile: (NSString*) aFilepath {
	if (wasLoaded) {
		LogError(@"%@ has already been loaded from POD file '%@'", self, aFilepath);
		return wasLoaded;
	}
	LogTrace(@"Loading POD file '%@'", aFilepath);
	self.name = aFilepath;
	wasLoaded = (self.pvrtModelImpl->ReadFromFile([aFilepath cStringUsingEncoding:NSUTF8StringEncoding]) == PVR_SUCCESS);
	if (wasLoaded) {
		[self build];
	} else {
		LogError(@"Could not load POD file '%@'", aFilepath);
	}
	return wasLoaded;
}

-(void) build {
	LogTrace(@"Building %@", self);
	[self buildTextures];
	[self buildMaterials];
	[self buildMeshModels];
	[self buildNodes];
}


#pragma mark Accessing node data and building nodes

-(uint) nodeCount {
	return self.pvrtModelImpl->nNumNode;
}

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
	return [CC3PODNode nodeAtIndex: nodeIndex fromPODResource: self];
}

-(PODStructPtr) nodePODStructAtIndex: (uint) nodeIndex {
	return &self.pvrtModelImpl->pNode[nodeIndex];
}


#pragma mark Accessing mesh data and building mesh nodes

-(uint) meshNodeCount {
	return self.pvrtModelImpl->nNumMeshNode;
}

-(CC3MeshNode*) meshNodeAtIndex: (uint) meshIndex {
	// mesh nodes appear first in the node array
	return (CC3MeshNode*)[self nodeAtIndex: meshIndex];
}

-(CC3MeshNode*) buildMeshNodeAtIndex: (uint) meshIndex {
	return [CC3PODMeshNode nodeAtIndex: meshIndex fromPODResource: self];
}

-(PODStructPtr) meshNodePODStructAtIndex: (uint) meshIndex {
	// mesh nodes appear first in the node array
	return [self nodePODStructAtIndex: meshIndex];
}

-(uint) meshModelCount {
	return self.pvrtModelImpl->nNumMesh;
}

-(void) buildMeshModels {
	uint mCount = self.meshModelCount;
	
	// Build the array containing all materials in the PVRT structure
	for (uint i = 0; i < mCount; i++) {
		[meshModels addObject: [self buildMeshModelAtIndex: i]];
	}
}

-(CC3Mesh*) meshModelAtIndex: (uint) meshIndex {
	return (CC3Mesh*)[meshModels objectAtIndex: meshIndex];
}

-(CC3Mesh*) buildMeshModelAtIndex: (uint) meshIndex {
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

-(CC3Texture*) buildTextureAtIndex: (uint) textureIndex {
	SPODTexture* pst = (SPODTexture*)[self texturePODStructAtIndex: textureIndex];
	CC3Texture* texNode = [CC3Texture textureFromFile: [NSString stringWithUTF8String: pst->pszName]];
	texNode.textureParameters = self.textureParameters;
	return texNode;
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
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ from file %@", [self class], self.name];
	if (self.pvrtModelImpl->nFlags & PVRTMODELPODSF_FIXED) {		// highlight if fixed point
		[desc appendFormat: @" (FIXED POINT!)"];
	}
	[desc appendFormat: @" containing %u nodes", self.nodeCount];
	[desc appendFormat: @" (%u mesh nodes)", self.meshNodeCount];
	[desc appendFormat: @", %u meshes", self.meshModelCount];
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
