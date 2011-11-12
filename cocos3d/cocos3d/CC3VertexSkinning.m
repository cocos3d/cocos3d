/*
 * CC3VertexSkinning.m
 *
 * cocos3d 0.6.3
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
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
 * See header file CC3VertexSkinning.h for full API documentation.
 */

#import "CC3VertexSkinning.h"
#import "CC3Camera.h"
#import "CC3World.h"
#import "CC3NodeAnimation.h"
#import "CC3OpenGLES11Engine.h"

@interface CC3Identifiable (TemplateMethods)
-(void) populateFrom: (CC3Identifiable*) another;
@end

@interface CC3Node (TemplateMethods)
-(void) copyChildrenFrom: (CC3Node*) another;
-(void) cacheRestPoseMatrix;
@end


#pragma mark -
#pragma mark CC3Node skinning extensions

@implementation CC3Node (Skinning)

-(BOOL) isSkeletonRigid {
	return (CC3IsWithinTolerance(scale.x, 1.0f, self.scaleTolerance) &&
			CC3IsWithinTolerance(scale.y, 1.0f, self.scaleTolerance) &&
			CC3IsWithinTolerance(scale.z, 1.0f, self.scaleTolerance) &&
			(parent ? parent.isSkeletonRigid : YES));
}

//-(BOOL) isSkeletonRigid {
//	return (scale.x == 1.0f && scale.y == 1.0f && scale.z == 1.0f) && (parent ? parent.isSkeletonRigid : YES);
//}

-(void) bindRestPose {
	for (CC3Node* child in children) {
		[child bindRestPose];
	}
}

-(void) reattachBonesFrom: (CC3Node*) aNode {
	for (CC3Node* child in children) {
		[child reattachBonesFrom: aNode];
	}
}

-(BOOL) hasSoftBodyContent {
	for (CC3Node* child in children) {
		if (child.hasSoftBodyContent) return YES;
	}
	return NO;
}

-(void) cacheRestPoseMatrix {}

@end


@interface CC3MeshNode (TemplateMethods)
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end


#pragma mark -
#pragma mark CC3SoftBodyNode

@implementation CC3SoftBodyNode

/** Attaches any contained bone batches to the new skeleton copy under this soft body node. */
-(void) copyChildrenFrom: (CC3Node*) another {
	[super copyChildrenFrom: another];
	[self reattachBonesFrom: self];
}

/** Release a visitor to calculate the bind pose transforms relative to this soft-body node. */
-(void) bindRestPose {
	[[CC3SkeletonRestPoseBindingVisitor visitor] visit: self];
}

/** We're at the top of the skeleton now. If we've come this far, it's rigid. */
-(BOOL) isSkeletonRigid { return YES; }

@end


#pragma mark -
#pragma mark CC3SkinMeshNode

@implementation CC3SkinMeshNode

@synthesize skinSections, restPoseTransformMatrix;

-(void) dealloc {
	[skinSections release];
	[restPoseTransformMatrix release];
	[super dealloc];
}

-(void) addSkinSection: (CC3SkinSection*) aSkinSection {
	[skinSections addObject: aSkinSection];
}

-(CC3SkinMesh*) skinnedMesh {
	return (CC3SkinMesh*)mesh;
}

-(void) retainVertexMatrixIndices {
	[self.skinnedMesh retainVertexMatrixIndices];
}

-(void) doNotBufferVertexMatrixIndices {
	[self.skinnedMesh doNotBufferVertexMatrixIndices];
}

-(void) retainVertexWeights {
	[self.skinnedMesh retainVertexWeights];
}

-(void) doNotBufferVertexWeights {
	[self.skinnedMesh doNotBufferVertexWeights];
}


#pragma mark Accessing vertex data

-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	CC3SkinMesh* sm = self.skinnedMesh;
	return sm ? [sm weightForVertexUnit: vertexUnit at: index] : 0.0f;
}

-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	[self.skinnedMesh setWeight: aWeight forVertexUnit: vertexUnit at: index];
}

-(void) updateVertexWeightsGLBuffer {
	[self.skinnedMesh updateVertexWeightsGLBuffer];
}

-(GLushort) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	CC3SkinMesh* sm = self.skinnedMesh;
	return sm ? [sm matrixIndexForVertexUnit: vertexUnit at: index] : 0;
}

-(void) setMatrixIndex: (GLushort) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	[self.skinnedMesh setMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

-(void) updateVertexMatrixIndicesGLBuffer {
	[self.skinnedMesh updateVertexMatrixIndicesGLBuffer];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		skinSections = [[CCArray array] retain];
		restPoseTransformMatrix = [[CC3GLMatrix identity] retain];
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3SkinMeshNode*) another {
	[super populateFrom: another];

	[restPoseTransformMatrix populateFrom: another.restPoseTransformMatrix];

	[skinSections removeAllObjects];
	CCArray* otherBatches = another.skinSections;
	for (CC3SkinSection* bb in otherBatches) {
		[skinSections addObject: [[bb copyForNode: self] autorelease]];		// retained in array
	}
}

-(void) reattachBonesFrom: (CC3Node*) aNode {
	for (CC3SkinSection* boneBatch in skinSections) {
		[boneBatch reattachBonesFrom: aNode];
	}
	[super reattachBonesFrom: aNode];
}

-(BOOL) hasSoftBodyContent  { return YES; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %i skin sections", super.description, skinSections.count];
}


#pragma mark Transformations

/** Caches the transform matrix rest pose matrix. */
-(void) cacheRestPoseMatrix {
	[restPoseTransformMatrix populateFrom: transformMatrix];
}


#pragma mark Drawing

/**
 * Overridden to skip the manipulation of the modelview matrix stack.
 * 
 * Vertex skinning does not use the modelview matrix stack. Instead, it uses a
 * palette of matrices that is used to manipulate the vertices of a mesh based
 * on a weighted average of the influence of the position of several bone nodes.
 * This activity is handled through the drawing of the contained CC3SkinMesh.
 */
-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@", self);
	[visitor draw: self];
}

/** 
 * Draws the mesh vertices to the GL engine.
 *
 * Enables palette matrices, delegates to the contained collection of CC3SkinSections
 * to draw the mesh in batches, then disables palette matrices again.
 */
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11StateTrackerServerCapability* gles11MatrixPalette = [CC3OpenGLES11Engine engine].serverCapabilities.matrixPalette;
	
	[gles11MatrixPalette enable];			// Enable the matrix palette
	
	[super drawMeshWithVisitor: visitor];	// Bind the arrays
	
	for (CC3SkinSection* boneBatch in skinSections) {
		[boneBatch drawVerticesOfMesh: mesh withVisitor: visitor];
	}
	
	[gles11MatrixPalette disable];			// We are finished with the matrix pallete so disable it.
}

@end


#pragma mark -
#pragma mark CC3SkinMesh

@interface CC3Mesh (TemplateMethods)
-(void) drawVerticesFrom: (GLuint) vertexIndex
				forCount: (GLuint) vertexCount
			 withVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@implementation CC3SkinMesh

@synthesize boneWeights, boneMatrixIndices;

-(void) dealloc {
	[boneWeights release];
	[boneMatrixIndices release];
	[super dealloc];
}


#pragma mark Accessing vertex data


-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	return boneWeights ? [boneWeights weightForVertexUnit: vertexUnit at: index] : 0.0f;
}

-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	[boneWeights setWeight: aWeight forVertexUnit: vertexUnit at: index];
}

-(void) updateVertexWeightsGLBuffer {
	[boneWeights updateGLBuffer];
}

-(GLushort) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	return boneMatrixIndices ? [boneMatrixIndices matrixIndexForVertexUnit: vertexUnit at: index] : 0;
}

-(void) setMatrixIndex: (GLushort) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	[boneMatrixIndices setMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

-(void) updateVertexMatrixIndicesGLBuffer {
	[boneMatrixIndices updateGLBuffer];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		boneMatrixIndices = nil;
		boneWeights = nil;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3SkinMesh*) another {
	[super populateFrom: another];
	
	self.boneWeights = another.boneWeights;						// retained but not copied
	self.boneMatrixIndices = another.boneMatrixIndices;			// retained but not copied
}

-(void) createGLBuffers {
	[super createGLBuffers];
	if (interleaveVertices) {
		boneMatrixIndices.bufferID = vertexLocations.bufferID;
		boneWeights.bufferID = vertexLocations.bufferID;
	} else {
		[boneMatrixIndices createGLBuffer];
		[boneWeights createGLBuffer];
	}
}

-(void) deleteGLBuffers {
	[super deleteGLBuffers];
	[boneMatrixIndices deleteGLBuffer];
	[boneWeights deleteGLBuffer];
}

-(void) releaseRedundantData {
	[super releaseRedundantData];
	[boneMatrixIndices releaseRedundantData];
	[boneWeights releaseRedundantData];
}

-(void) retainVertexMatrixIndices {
	boneMatrixIndices.shouldReleaseRedundantData = NO;
}

-(void) doNotBufferVertexMatrixIndices {
	if (interleaveVertices) {
		[self doNotBufferVertexLocations];
	} else {
		boneMatrixIndices.shouldAllowVertexBuffering = NO;
	}
}

-(void) retainVertexWeights {
	boneWeights.shouldReleaseRedundantData = NO;
}

-(void) doNotBufferVertexWeights {
	if (interleaveVertices) {
		[self doNotBufferVertexLocations];
	} else {
		boneWeights.shouldAllowVertexBuffering = NO;
	}
}


#pragma mark Updating

-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLsizei) vertexCount {
	[super updateGLBuffersStartingAt: offsetIndex forLength: vertexCount];
	if (!interleaveVertices) {
		[boneMatrixIndices updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		[boneWeights updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
	}
}


#pragma mark Drawing

/**
 * Template method that binds a pointer to the vertex matrix index data to the GL engine.
 * If this mesh has no vertex matrix index data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexMatrixIndices unbind class method.
 */
-(void) bindBoneMatrixIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (boneMatrixIndices) {
		[boneMatrixIndices bindWithVisitor:visitor];
	} else {
		[CC3VertexMatrixIndices unbind];
	}
}

/**
 * Template method that binds a pointer to the vertex weight data to the GL engine.
 * If this mesh has no vertex weight data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexWeights unbind class method.
 */
-(void) bindBoneWeightsWithVisitor:(CC3NodeDrawingVisitor*) visitor {
	if (boneWeights) {
		[boneWeights bindWithVisitor:visitor];
	} else {
		[CC3VertexWeights unbind];
	}
}

/** Overridden to do nothing. Skinned meshes are drawn by the CC3SkinSections. */
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

@end


#pragma mark -
#pragma mark CC3SkinSection

@interface CC3SkinSection (TemplateMethods)
-(void) populateFrom: (CC3SkinSection*) another;
@end

@implementation CC3SkinSection

@synthesize bones, vertexStart, vertexCount;

-(void) dealloc {
	[bones release];
	node = nil;				// not retained
	[super dealloc];
}

-(void) addBone: (CC3Bone*) aBone {
	[bones addObject: aBone];
}


#pragma mark Allocation and initialization

-(id) init { return [self initForNode: nil]; }

-(id) initForNode: (CC3SkinMeshNode*) aNode {
	if ( (self = [super init]) ) {
		node = aNode;							// not retained
		bones = [[CCArray array] retain];
		vertexStart = 0;
	}
	return self;
}

+(id) boneBatchForNode: (CC3SkinMeshNode*) aNode {
	return [[[self alloc] initForNode: aNode] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [self copyForNode: nil withZone: zone];
}

-(id) copyForNode: (CC3SkinMeshNode*) aNode {
	return [self copyForNode: aNode withZone: nil];
}
	
-(id) copyForNode: (CC3SkinMeshNode*) aNode withZone: (NSZone*) zone {
	CC3SkinSection* aCopy = [[[self class] allocWithZone: zone] initForNode: aNode];
	[aCopy populateFrom: self];
	return aCopy;
}

-(void) reattachBonesFrom: (CC3Node*) aNode {
	CCArray* oldBones = [bones autorelease];
	bones = [[CCArray array] retain];
	for (CC3Bone* ob in oldBones) {
		[self addBone: (CC3Bone*)[aNode getNodeNamed: ob.name]];
	}
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3SkinSection*) another {

	vertexStart = another.vertexStart;
	vertexCount = another.vertexCount;

	[bones removeAllObjects];
	CCArray* otherBones = another.bones;
	for (CC3Bone* bone in otherBones) {
		[self addBone: bone];			// Retained but not copied...will be swapped for...
	}									// ...copied bones later by reattacheBonesFrom:
}


#pragma mark Drawing

-(void) drawVerticesOfMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {
	
	CC3OpenGLES11Matrices* gles11Matrices = [CC3OpenGLES11Engine engine].matrices;
	CC3GLMatrix* boneMatrix = visitor.scratchMatrix;	// Temp scratch matrix
	
	GLuint boneNum = 0;
	for (CC3Bone* bone in bones) {
		
		// Apply the bone's pose to the bone matrix, then add the matrix of the current mesh node.
		[bone applyPoseTo: boneMatrix];
		[boneMatrix multiplyByMatrix: node.restPoseTransformMatrix];
		
		// Load this palette matrix from the modelview matrix and the bone matrix.
		CC3OpenGLES11MatrixPalette* gles11PaletteMatrix = [gles11Matrices paletteAt: boneNum++];
		[gles11PaletteMatrix loadFromModelView];
		[gles11PaletteMatrix multiply: boneMatrix.glMatrix];
	}
	
	LogTrace(@"%@: Drawing batch %@", [self class], [boneBatch fullDescription]);
	[mesh drawVerticesFrom: vertexStart forCount: vertexCount withVisitor: visitor];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %i bones", [self class], bones.count];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ %@", [self description], bones];
}

@end


#pragma mark -
#pragma mark CC3Bone

@implementation CC3Bone

@synthesize restPoseInvertedMatrix;

-(void) dealloc {
	[restPoseInvertedMatrix release];
	[super dealloc];
}

-(BOOL) hasSoftBodyContent  { return YES; }

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		restPoseInvertedMatrix = [[CC3GLMatrix matrix] retain];
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Bone*) another {
	[super populateFrom: another];
	
	[restPoseInvertedMatrix populateFrom: another.restPoseInvertedMatrix];
}


#pragma mark Transformations

-(void) applyPoseTo: (CC3GLMatrix*) boneMatrix {
	[boneMatrix populateFrom: self.transformMatrix];
	[boneMatrix multiplyByMatrix: restPoseInvertedMatrix];
}

/** Inverts the transform matrix and caches it as the inverted rest pose matrix. */
-(void) cacheRestPoseMatrix {
	
	[restPoseInvertedMatrix populateFrom: transformMatrix];
	
	// If the transform is rigid (only rotation & translation), use faster inversion.
	if (self.isSkeletonRigid) {
		[restPoseInvertedMatrix invertRigid];
	} else {
		[restPoseInvertedMatrix invertAffine];
	}
	
	LogTrace(@"%@ with global scale (%.6f, %.6f, %.6f) and tolerance %.6f rest pose %@ inverted %@to %@", self,
			 self.globalScale.x, self.globalScale.y, self.globalScale.z,
			 self.scaleTolerance, transformMatrix,
			 (self.isSkeletonRigid ? @"rigidly " : @""), restPoseInvertedMatrix);
}

@end


#pragma mark -
#pragma mark CC3SkeletonRestPoseBindingVisitor

@interface CC3NodeVisitor (TemplateMethods)
-(void) processBeforeChildren: (CC3Node*) aNode;
@end

@implementation CC3SkeletonRestPoseBindingVisitor

/** Initialized to localize to the starting node. */
-(id) init {
	if ( (self = [super init]) ) {
		shouldLocalizeToStartingNode = YES;
		shouldRestoreTransforms = YES;
	}
	return self;
}

/** Perform transform, then tell node to cache the transform matrix. */
-(void) processBeforeChildren: (CC3Node*) aNode {
	[super processBeforeChildren: aNode];
	[aNode cacheRestPoseMatrix];
}

@end
