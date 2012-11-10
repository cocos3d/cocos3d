/*
 * CC3VertexSkinning.m
 *
 * cocos3d 0.7.2
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3Scene.h"
#import "CC3NodeAnimation.h"
#import "CC3AffineMatrix.h"
#import "CC3OpenGLES11Engine.h"


@interface CC3Node (TemplateMethods)
-(void) copyChildrenFrom: (CC3Node*) another;
-(void) cacheRestPoseMatrix;
-(void) transformMatrixChanged;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@interface CC3FaceArray (TemplateMethods)
-(CC3Face) faceAt: (GLuint) faceIndex;
@end


#pragma mark -
#pragma mark CC3SoftBodyNode

@implementation CC3SoftBodyNode

/** Attaches any contained skin sections to the new skeleton copy under this soft body node. */
-(void) copyChildrenFrom: (CC3Node*) another {
	[super copyChildrenFrom: another];
	[self reattachBonesFrom: self];
}

/** Release a visitor to calculate the bind pose transforms relative to this soft-body node. */
-(void) bindRestPose {
	[[CC3SkeletonRestPoseBindingVisitor visitor] visit: self];
}

-(CC3SoftBodyNode*) softBodyNode { return self; }

@end


#pragma mark -
#pragma mark CC3SkinMeshNode

@implementation CC3SkinMeshNode

@synthesize skinSections, restPoseTransformMatrix;

-(void) dealloc {
	[skinSections release];
	[restPoseTransformMatrix release];
	[deformedFaces release];
	[super dealloc];
}

-(CC3SkinSection*) skinSectionForVertexIndexAt: (GLint) index {
	for (CC3SkinSection* skinSctn in skinSections) {
		if ( [skinSctn containsVertexIndex: index] ) return skinSctn;
	}
	return nil;
}

-(CC3SkinSection*) skinSectionForFaceIndex: (GLint) faceIndex {
	return [self skinSectionForVertexIndexAt: [self vertexIndexCountFromFaceCount: faceIndex]];
}

-(CC3SkinMesh*) skinnedMesh {
	return (CC3SkinMesh*)mesh;
}

-(void) retainVertexMatrixIndices {
	[self.skinnedMesh retainVertexMatrixIndices];
	[super retainVertexMatrixIndices];
}

-(void) doNotBufferVertexMatrixIndices {
	[self.skinnedMesh doNotBufferVertexMatrixIndices];
	[super doNotBufferVertexMatrixIndices];
}

-(void) retainVertexWeights {
	[self.skinnedMesh retainVertexWeights];
	[super retainVertexWeights];
}

-(void) doNotBufferVertexWeights {
	[self.skinnedMesh doNotBufferVertexWeights];
	[super doNotBufferVertexWeights];
}


#pragma mark Accessing vertex data

-(GLuint) vertexUnitCount {
	CC3SkinMesh* sm = self.skinnedMesh;
	return sm ? sm.vertexUnitCount : 0;
}

-(GLfloat) vertexWeightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	CC3SkinMesh* sm = self.skinnedMesh;
	return sm ? [sm vertexWeightForVertexUnit: vertexUnit at: index] : 0.0f;
}

// Deprecated
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexWeightForVertexUnit: vertexUnit at: index];
}

-(void) setVertexWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self.skinnedMesh setVertexWeight: aWeight forVertexUnit: vertexUnit at: index];
}

// Deprecated
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexWeight: aWeight forVertexUnit: vertexUnit at: index];
}

-(GLfloat*) vertexWeightsAt: (GLuint) index {
	CC3SkinMesh* sm = self.skinnedMesh;
	return sm ? [sm vertexWeightsAt: index] : NULL;
}

-(void) setVertexWeights: (GLfloat*) weights at: (GLuint) index {
	[self.skinnedMesh setVertexWeights: weights at: index];
}

-(void) updateVertexWeightsGLBuffer {
	[self.skinnedMesh updateVertexWeightsGLBuffer];
}

-(GLuint) vertexMatrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	CC3SkinMesh* sm = self.skinnedMesh;
	return sm ? [sm vertexMatrixIndexForVertexUnit: vertexUnit at: index] : 0;
}

// Deprecated
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexMatrixIndexForVertexUnit: vertexUnit at: index];
}

-(void) setVertexMatrixIndex: (GLuint) aMatrixIndex
			   forVertexUnit: (GLuint) vertexUnit
						  at: (GLuint) index {
	[self.skinnedMesh setVertexMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

// Deprecated
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}
	
-(GLvoid*) vertexMatrixIndicesAt: (GLuint) index {
	CC3SkinMesh* sm = self.skinnedMesh;
	return sm ? [sm vertexMatrixIndicesAt: index] : NULL;
}

-(void) setVertexMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index {
	[self.skinnedMesh setVertexMatrixIndices: mtxIndices at: index];
}

-(GLenum) matrixIndexType {
	return self.skinnedMesh.matrixIndexType;
}

-(void) updateVertexMatrixIndicesGLBuffer {
	[self.skinnedMesh updateVertexMatrixIndicesGLBuffer];
}


#pragma mark Faces

-(void) setShouldCacheFaces: (BOOL) shouldCache {
	self.deformedFaces.shouldCacheFaces = shouldCache;
	super.shouldCacheFaces = shouldCache;
}

-(CC3DeformedFaceArray*) deformedFaces {
	if ( !deformedFaces ) {
		NSString* facesName = [NSString stringWithFormat: @"%@-DeformedFaces", self.name];
		self.deformedFaces = [CC3DeformedFaceArray faceArrayWithName: facesName];
	}
	return deformedFaces;
}

-(void) setDeformedFaces: (CC3DeformedFaceArray*) aFaceArray {
	id old = deformedFaces;
	deformedFaces = [aFaceArray retain];
	[old release];
	deformedFaces.node = self;
}

-(CC3Face) deformedFaceAt: (GLuint) faceIndex {
	return [self.deformedFaces faceAt: faceIndex];
}

-(CC3Vector) deformedFaceCenterAt: (GLuint) faceIndex {
	return [self.deformedFaces centerAt: faceIndex];
}

-(CC3Vector) deformedFaceNormalAt: (GLuint) faceIndex {
	return [self.deformedFaces normalAt: faceIndex];
}

-(CC3Plane) deformedFacePlaneAt: (GLuint) faceIndex {
	return [self.deformedFaces planeAt: faceIndex];
}

-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex {
	return [self.deformedFaces deformedVertexLocationAt: vertexIndex fromFaceAt: faceIndex];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		skinSections = [[CCArray array] retain];
		restPoseTransformMatrix = [CC3AffineMatrix new];
		deformedFaces = nil;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3SkinMeshNode*) another {
	[super populateFrom: another];

	// The deformedFaces instance is not copied, since the deformed faces
	// are different for each mesh node and is created lazily if needed.
	
	[restPoseTransformMatrix populateFrom: another.restPoseTransformMatrix];

	[skinSections removeAllObjects];
	CCArray* otherSkinSections = another.skinSections;
	for (CC3SkinSection* ss in otherSkinSections) {
		[skinSections addObject: [[ss copyForNode: self] autorelease]];		// retained in array
	}
}

-(void) reattachBonesFrom: (CC3Node*) aNode {
	for (CC3SkinSection* skinSctn in skinSections) {
		[skinSctn reattachBonesFrom: aNode];
	}
	[super reattachBonesFrom: aNode];
}

-(BOOL) hasSoftBodyContent  { return YES; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %i skin sections",
			super.description, skinSections.count];
}


#pragma mark Transformations

-(void) transformMatrixChanged {
	[super transformMatrixChanged];
	[deformedFaces clearDeformableCaches];		// Avoid creating lazily if not already created.
}

/** Caches the transform matrix rest pose matrix. */
-(void) cacheRestPoseMatrix {
	[restPoseTransformMatrix populateFrom: transformMatrix];
}

-(void) boneWasTransformed: (CC3Bone*) aBone { [self markTransformDirty]; }


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
	
	for (CC3SkinSection* skinSctn in skinSections) {
		[skinSctn drawVerticesOfMesh: mesh withVisitor: visitor];
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

@interface CC3VertexArrayMesh (TemplateMethods)
-(void) createVertexContent: (CC3VertexContent) vtxContentTypes;
@end

@implementation CC3SkinMesh

-(void) dealloc {
	[vertexWeights release];
	[vertexMatrixIndices release];
	[super dealloc];
}

-(void) setName: (NSString*) aName {
	super.name = aName;
	[vertexWeights deriveNameFrom: self];
	[vertexMatrixIndices deriveNameFrom: self];
}

-(CC3VertexWeights*) vertexWeights { return vertexWeights; }

-(void) setVertexWeights: (CC3VertexWeights*) vtxWgts {
	[vertexWeights autorelease];
	vertexWeights = [vtxWgts retain];
	[vertexWeights deriveNameFrom: self];
}

-(BOOL) hasVertexWeights { return (vertexWeights != nil); }

-(CC3VertexMatrixIndices*) vertexMatrixIndices { return vertexMatrixIndices; }

-(void) setVertexMatrixIndices: (CC3VertexMatrixIndices*) vtxMtxInd {
	[vertexMatrixIndices autorelease];
	vertexMatrixIndices = [vtxMtxInd retain];
	[vertexMatrixIndices deriveNameFrom: self];
}

-(BOOL) hasVertexMatrixIndices { return (vertexMatrixIndices != nil); }

// Deprecated properties.
-(CC3VertexMatrixIndices*) boneMatrixIndices { return self.vertexMatrixIndices; }
-(void) setBoneMatrixIndices: (CC3VertexMatrixIndices*) bmi { self.vertexMatrixIndices = bmi; }
-(CC3VertexWeights*) boneWeights { return self.vertexWeights; }
-(void) setBoneWeights: (CC3VertexWeights*) bw { self.vertexWeights = bw; }


#pragma mark Managing vertex data

-(CC3VertexContent) vertexContentTypes {
	CC3VertexContent vtxContent = super.vertexContentTypes;
	if (self.hasVertexWeights) vtxContent |= kCC3VertexContentWeights;
	if (self.hasVertexMatrixIndices) vtxContent |= kCC3VertexContentMatrixIndices;
	return vtxContent;
}

// Keep the compiler happy with re-declaration for documentation purposes
-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	super.vertexContentTypes = vtxContentTypes;
}

-(void) createVertexContent: (CC3VertexContent) vtxContentTypes {
	
	// Construct all the other vertex arrays
	[super createVertexContent: vtxContentTypes];
	
	// Weights
	if (vtxContentTypes & kCC3VertexContentWeights) {
		if (!vertexWeights) self.vertexWeights = [CC3VertexWeights vertexArray];
	} else {
		self.vertexWeights = nil;
	}
	
	// Matrix indices
	if (vtxContentTypes & kCC3VertexContentMatrixIndices) {
		if (!vertexMatrixIndices) self.vertexMatrixIndices = [CC3VertexMatrixIndices vertexArray];
	} else {
		self.vertexMatrixIndices = nil;
	}
}

-(void) setAllocatedVertexCapacity: (GLuint) vtxCount {
	if (vtxCount == self.allocatedVertexCapacity) return;
	
	super.allocatedVertexCapacity = vtxCount;
	if (self.shouldInterleaveVertices) {
		[vertexWeights interleaveWith: vertexLocations];
		[vertexMatrixIndices interleaveWith: vertexLocations];
	} else {
		vertexWeights.allocatedVertexCapacity = vtxCount;
		vertexMatrixIndices.allocatedVertexCapacity = vtxCount;
	}
}

-(GLuint) vertexStride {
	GLuint stride = super.vertexStride;
	if (vertexWeights) stride += vertexWeights.elementLength;
	if (vertexMatrixIndices) stride += vertexMatrixIndices.elementLength;
	return stride;
}

-(void) setVertexStride: (GLuint) vtxStride {
	super.vertexStride = vtxStride;
	if (shouldInterleaveVertices) {
		vertexWeights.vertexStride = vtxStride;
		vertexMatrixIndices.vertexStride = vtxStride;
	}
}

-(GLuint) updateVertexStride {
	GLuint stride = [super updateVertexStride];
	
	if (vertexWeights) {
		if (shouldInterleaveVertices) vertexWeights.elementOffset = stride;
		stride += vertexWeights.elementLength;
	}
	if (vertexMatrixIndices) {
		if (shouldInterleaveVertices) vertexMatrixIndices.elementOffset = stride;
		stride += vertexMatrixIndices.elementLength;
	}
	
	self.vertexStride = stride;
	return stride;
}

-(void) setVertexCount: (GLuint) vCount {
	super.vertexCount = vCount;
	vertexWeights.vertexCount = vCount;
	vertexMatrixIndices.vertexCount = vCount;
}

-(GLuint) vertexUnitCount {
	return vertexWeights ? vertexWeights.elementSize : 0;
}

-(GLfloat) vertexWeightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return vertexWeights ? [vertexWeights weightForVertexUnit: vertexUnit at: index] : 0.0f;
}

// Deprecated
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexWeightForVertexUnit: vertexUnit at: index];
}

-(void) setVertexWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[vertexWeights setWeight: aWeight forVertexUnit: vertexUnit at: index];
}

// Deprecated
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexWeight: aWeight forVertexUnit: vertexUnit at: index];
}

-(GLfloat*) vertexWeightsAt: (GLuint) index {
	return vertexWeights ? [vertexWeights weightsAt: index] : NULL;
}

-(void) setVertexWeights: (GLfloat*) weights at: (GLuint) index {
	[vertexWeights setWeights: weights at: index];
}

-(void) updateVertexWeightsGLBuffer {
	[vertexWeights updateGLBuffer];
}

-(GLuint) vertexMatrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return vertexMatrixIndices ? [vertexMatrixIndices matrixIndexForVertexUnit: vertexUnit at: index] : 0;
}

// Deprecated
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexMatrixIndexForVertexUnit: vertexUnit at: index];
}

-(void) setVertexMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[vertexMatrixIndices setMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

// Deprecated
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

-(GLvoid*) vertexMatrixIndicesAt: (GLuint) index {
	return vertexMatrixIndices ? [vertexMatrixIndices matrixIndicesAt: index] : NULL;
}

-(void) setVertexMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index {
	[vertexMatrixIndices setMatrixIndices: mtxIndices at: index];
}

-(GLenum) matrixIndexType {
	return vertexMatrixIndices.elementType;
}

-(void) updateVertexMatrixIndicesGLBuffer {
	[vertexMatrixIndices updateGLBuffer];
}

-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx {
	[super copyVertices: vtxCount from: srcIdx to: dstIdx];
	if ( !shouldInterleaveVertices ) {
		[vertexMatrixIndices copyVertices: vtxCount from: srcIdx to: dstIdx];
		[vertexWeights copyVertices: vtxCount from: srcIdx to: dstIdx];
	}
}

-(void) copyVertexAt: (GLuint) srcIdx from: (CC3VertexArrayMesh*) srcMesh to: (GLuint) dstIdx {
	[super copyVertexAt: srcIdx from: srcMesh to: dstIdx];
	if (self.hasVertexWeights) [self setVertexWeights: [srcMesh vertexWeightsAt: srcIdx] at: dstIdx];
	if (self.hasVertexMatrixIndices) [self setVertexMatrixIndices: [srcMesh vertexMatrixIndicesAt: srcIdx] at: dstIdx];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		vertexMatrixIndices = nil;
		vertexWeights = nil;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3SkinMesh*) another {
	[super populateFrom: another];
	
	self.vertexWeights = another.vertexWeights;						// retained but not copied
	self.vertexMatrixIndices = another.vertexMatrixIndices;			// retained but not copied
}

-(void) createGLBuffers {
	[super createGLBuffers];
	if (shouldInterleaveVertices) {
		GLuint commonBufferId = vertexLocations.bufferID;
		vertexMatrixIndices.bufferID = commonBufferId;
		vertexWeights.bufferID = commonBufferId;
	} else {
		[vertexMatrixIndices createGLBuffer];
		[vertexWeights createGLBuffer];
	}
}

-(void) deleteGLBuffers {
	[super deleteGLBuffers];
	[vertexMatrixIndices deleteGLBuffer];
	[vertexWeights deleteGLBuffer];
}

-(BOOL) isUsingGLBuffers {
	if (super.isUsingGLBuffers) return YES;
	if (vertexMatrixIndices && vertexMatrixIndices.isUsingGLBuffer) return YES;
	if (vertexWeights && vertexWeights.isUsingGLBuffer) return YES;
	return NO;
}

-(void) releaseRedundantData {
	[super releaseRedundantData];
	[vertexMatrixIndices releaseRedundantData];
	[vertexWeights releaseRedundantData];
}

-(void) retainVertexContent {
	[super retainVertexContent];
	[self retainVertexMatrixIndices];
	[self retainVertexWeights];
}

-(void) retainVertexMatrixIndices {
	if ( !self.hasVertexMatrixIndices ) return;

	if (shouldInterleaveVertices) [self retainVertexLocations];
	vertexMatrixIndices.shouldReleaseRedundantData = NO;
}

-(void) doNotBufferVertexContent {
	[super doNotBufferVertexContent];
	[self doNotBufferVertexMatrixIndices];
	[self doNotBufferVertexWeights];
}

-(void) doNotBufferVertexMatrixIndices {
	if (shouldInterleaveVertices) [self doNotBufferVertexLocations];
	vertexMatrixIndices.shouldAllowVertexBuffering = NO;
}

-(void) retainVertexWeights {
	if ( !self.hasVertexWeights ) return;

	if (shouldInterleaveVertices) [self retainVertexLocations];
	vertexWeights.shouldReleaseRedundantData = NO;
}

-(void) doNotBufferVertexWeights {
	if (shouldInterleaveVertices) [self doNotBufferVertexLocations];
	vertexWeights.shouldAllowVertexBuffering = NO;
}


#pragma mark Updating

-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLuint) vertexCount {
	[super updateGLBuffersStartingAt: offsetIndex forLength: vertexCount];
	if (!shouldInterleaveVertices) {
		[vertexMatrixIndices updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		[vertexWeights updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
	}
}


#pragma mark Drawing

/**
 * Template method that binds a pointer to the vertex matrix index data to the GL engine.
 * If this mesh has no vertex matrix index data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexMatrixIndices unbind class method.
 */
-(void) bindBoneMatrixIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (vertexMatrixIndices) {
		[vertexMatrixIndices bindWithVisitor:visitor];
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
	if (vertexWeights) {
		[vertexWeights bindWithVisitor:visitor];
	} else {
		[CC3VertexWeights unbind];
	}
}

/** Overridden to do nothing. Skinned meshes are drawn by the CC3SkinSections. */
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

@end


#pragma mark -
#pragma mark CC3SkinSection

@implementation CC3SkinSection

@synthesize vertexStart, vertexCount;

-(void) dealloc {
	[skinnedBones release];
	node = nil;				// not retained
	[super dealloc];
}

-(CCArray*) bones {
	CCArray* bones = [CCArray array];
	for (CC3SkinnedBone* sb in skinnedBones) {
		[bones addObject: sb.bone];
	}
	return bones;
}

-(void) addBone: (CC3Bone*) aBone {
	[skinnedBones addObject: [CC3SkinnedBone skinnedBoneWithSkin: node onBone: aBone]];
}

-(BOOL) containsVertexIndex: (GLint) aVertexIndex {
	return (aVertexIndex >= vertexStart) && (aVertexIndex < vertexStart + vertexCount);
}

-(CC3Vector)  deformedVertexLocationAt:  (GLuint) vtxIdx {
	CC3SkinMesh* skinMesh = [node skinnedMesh];
	
	// The locations of this vertex before and after deformation.
	// The latter is to be calculated and returned by this method.
	CC3Vector restLoc = [skinMesh vertexLocationAt: vtxIdx];
	CC3Vector defLoc = kCC3VectorZero;
	
	// Calc the weighted sum of the deformation contributed by each bone to this vertex.
	// Iterate through the vertex units associated with this vertex.
	GLuint vuCnt = skinMesh.vertexUnitCount;
	for (GLuint vuIdx = 0; vuIdx < vuCnt; vuIdx++) {
		
		// Get a bone and its weighting for this vertex.
		GLfloat vtxWt = [skinMesh vertexWeightForVertexUnit: vuIdx at: vtxIdx];
		GLuint vtxBoneIdx = [skinMesh vertexMatrixIndexForVertexUnit: vuIdx at: vtxIdx];
		CC3SkinnedBone* skinnedBone = ((CC3SkinnedBone*)[skinnedBones objectAtIndex: vtxBoneIdx]);
		
		// Use the bone to deform the vertex, apply the weighting for this bone,
		// and add to the summed location.
		CC3Vector boneDefLoc = [skinnedBone.skinTransformMatrix transformLocation: restLoc];
		CC3Vector wtdBoneDefLoc = CC3VectorScaleUniform(boneDefLoc, vtxWt);
		defLoc = CC3VectorAdd(defLoc, wtdBoneDefLoc);

		LogTrace(@"%@ vu: %i, bone at %i, weight %.3f transforming vertex at %i: %@ to %@ to wtd: %@ to sum: %@ %@ node rest pose: %@",
					  self, vuIdx, vtxBoneIdx, vtxWt, vtxIdx,
					  NSStringFromCC3Vector(restLoc),
					  NSStringFromCC3Vector(boneDefLoc),
					  NSStringFromCC3Vector(wtdBoneDefLoc),
					  NSStringFromCC3Vector(defLoc),
					  bonePoseMtx, node.restPoseTransformMatrix);
	}
	return defLoc;
}


#pragma mark Allocation and initialization

-(id) init { return [self initForNode: nil]; }

-(id) initForNode: (CC3SkinMeshNode*) aNode {
	if ( (self = [super init]) ) {
		node = aNode;							// not retained
		skinnedBones = [[CCArray array] retain];
		vertexStart = 0;
		vertexCount = 0;
	}
	return self;
}

+(id) skinSectionForNode: (CC3SkinMeshNode*) aNode {
	return [[[self alloc] initForNode: aNode] autorelease];
}

// Extract the old bones into an array, and for each, look for the
// bone with the same name as a descendant of the specified node.
-(void) reattachBonesFrom: (CC3Node*) aNode {
	CCArray* oldBones = self.bones;
	[skinnedBones removeAllObjects];
	for (CC3Bone* ob in oldBones) {
		[self addBone: (CC3Bone*)[aNode getNodeNamed: ob.name]];
	}
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3SkinSection*) another {

	vertexStart = another.vertexStart;
	vertexCount = another.vertexCount;

	[skinnedBones removeAllObjects];
	CCArray* otherBones = another.bones;
	for (CC3Bone* bone in otherBones) {
		[self addBone: bone];			// Retained but not copied...will be swapped for copied...
	}									// ...bones via later invocation of reattachBonesFrom:
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


#pragma mark Drawing

-(void) drawVerticesOfMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {
	
	CC3OpenGLES11Matrices* gles11Matrices = [CC3OpenGLES11Engine engine].matrices;
	CC3Matrix4x4 glMtx;
	
	GLuint boneNum = 0;
	for (CC3SkinnedBone* sb in skinnedBones) {

		// Load this palette matrix from the modelview matrix and the apply the bone draw matrix.
		CC3OpenGLES11MatrixPalette* gles11PaletteMatrix = [gles11Matrices paletteAt: boneNum++];
		[gles11PaletteMatrix loadFromModelView];
		[sb.drawTransformMatrix populateCC3Matrix4x4: &glMtx];
		[gles11PaletteMatrix multiply: glMtx.elements];
	}

	[mesh drawVerticesFrom: vertexStart forCount: vertexCount withVisitor: visitor];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %i bones, vertices from %u to %u for %@",
			[self class], skinnedBones.count, vertexStart, (vertexStart + vertexCount - 1), node];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ %@", [self description], self.bones];
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
		restPoseInvertedMatrix = [CC3AffineMatrix new];
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

-(void) applyPoseTo: (CC3Matrix*) boneMatrix {
	[boneMatrix populateFrom: self.transformMatrix];
	[boneMatrix multiplyBy: restPoseInvertedMatrix];
}

/** Inverts the transform matrix and caches it as the inverted rest pose matrix. */
-(void) cacheRestPoseMatrix {
	[restPoseInvertedMatrix populateFrom: transformMatrix];
	[restPoseInvertedMatrix invert];
	LogTrace(@"%@ with global scale %@ and rest pose %@ %@ inverted to %@",
			 self, NSStringFromCC3Vector(self.globalScale), transformMatrix,
			 (restPoseInvertedMatrix.isRigid ? @"rigidly" : @"adjoint"), restPoseInvertedMatrix);
	LogTrace(@"Validating right multiply: %@ \nvalidating left multiply: %@",
			 [CC3AffineMatrix matrixByMultiplying: transformMatrix by: restPoseInvertedMatrix],
			 [CC3AffineMatrix matrixByMultiplying: restPoseInvertedMatrix by: transformMatrix]);
}

@end


#pragma mark -
#pragma mark CC3SkinnedBone

@implementation CC3SkinnedBone

@synthesize bone, skinNode;

-(void) dealloc {
	[skinNode removeTransformListener: self];
	skinNode = nil;		// Weak reference

	[bone removeTransformListener: self];
	bone = nil;			// Weak reference

	[drawTransformMatrix release];
	[skinTransformMatrix release];
	[super dealloc];
}

-(void) markTransformDirty {
	isSkinTransformDirty = YES;
	isDrawTransformDirty = YES;
}

-(CC3Matrix*) drawTransformMatrix {
	if ( !drawTransformMatrix ) {
		drawTransformMatrix = [CC3AffineMatrix new];
	}
	if (isDrawTransformDirty) {
		[bone applyPoseTo: drawTransformMatrix];
		[drawTransformMatrix multiplyBy: skinNode.restPoseTransformMatrix];
		isDrawTransformDirty = NO;
		isSkinTransformDirty = YES;
	}
	return drawTransformMatrix;
}

-(CC3Matrix*) skinTransformMatrix {
	if ( !skinTransformMatrix ) {
		skinTransformMatrix = [CC3AffineMatrix new];
	}
	if (isSkinTransformDirty) {
		[skinTransformMatrix populateFrom: self.drawTransformMatrix];
		[skinTransformMatrix leftMultiplyBy: skinNode.transformMatrixInverted];
		isSkinTransformDirty = NO;
	}
	return skinTransformMatrix;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for bone %@ of skin %@", self.class, bone, skinNode];
}


#pragma mark Allocation and initialization

// This will raise an assertion without a skin node or bone.
-(id) init { return [self initWithSkin: nil onBone: nil]; }

-(id) initWithSkin: (CC3SkinMeshNode*) aNode onBone: (CC3Bone*) aBone {
	NSAssert1(aNode, @"%@ must be initialized with a skin node.", self.class);
	NSAssert1(aBone, @"%@ must be initialized with a bone.", self.class);
	if ( (self = [super init]) ) {

		skinNode = aNode;
		[skinNode addTransformListener: self];

		bone = aBone;
		[bone addTransformListener: self];

		drawTransformMatrix = nil;
		skinTransformMatrix = nil;
	}
	return self;
}

/**
 * Allocates and initializes an autoreleased instance that
 * applies the specified bone to the specified mesh node.
 */
+(id) skinnedBoneWithSkin: (CC3SkinMeshNode*) aNode onBone: (CC3Bone*) aBone {
	return [[[self alloc] initWithSkin: aNode onBone: aBone] autorelease];
}

/** Either the bone or skin node were transformed. Mark the transforms of this skinned bone dirty. */
-(void) nodeWasTransformed: (CC3Node*) aNode {
	[self markTransformDirty];
	if (aNode == bone) [skinNode boneWasTransformed: bone];
}

/**
 * If either of the nodes to whom I have registered as a
 * listener disappears before I do, clear the reference to it.
 */
-(void) nodeWasDestroyed: (CC3Node*) aNode {
	if (aNode == skinNode) skinNode = nil;
	if (aNode == bone) bone = nil;
}

@end


#pragma mark -
#pragma mark CC3DeformedFaceArray

@implementation CC3DeformedFaceArray

@synthesize node;

-(void) dealloc {
	self.node = nil;		// Will clear this object as a listener to the existing node.
	[self deallocateDeformedVertexLocations];
	[super dealloc];
}

/**
 * Clears all caches so that they will be lazily initialized
 * on next access using the new mesh data.
 */
-(void) setNode: (CC3SkinMeshNode*) aNode {
	node = aNode;							// Weak link
	self.mesh = aNode.mesh;
	[self deallocateDeformedVertexLocations];
}

/**
 * Adds this array as listener to bone movements.
 * If turning off, clears all caches except neighbours.
 */
-(void) setShouldCacheFaces: (BOOL) shouldCache {
	super.shouldCacheFaces = shouldCache;
	if ( !shouldCacheFaces ) [self deallocateDeformedVertexLocations];
}

-(void) clearDeformableCaches {
	[self markCentersDirty];
	[self markNormalsDirty];
	[self markPlanesDirty];
	[self markDeformedVertexLocationsDirty];
}

-(GLuint) vertexCount { return mesh ? mesh.vertexCount : 0;}

-(CC3Face) faceAt: (GLuint) faceIndex {
	CC3FaceIndices faceIndices = [node faceIndicesAt: faceIndex];
	if (shouldCacheFaces) {
		CC3Vector* vtxLocs = self.deformedVertexLocations;
		return CC3FaceMake(vtxLocs[faceIndices.vertices[0]],
						   vtxLocs[faceIndices.vertices[1]],
						   vtxLocs[faceIndices.vertices[2]]);
	} else {
		CC3SkinSection* ss = [node skinSectionForFaceIndex: faceIndex];
		return CC3FaceMake([ss  deformedVertexLocationAt: faceIndices.vertices[0]],
						   [ss  deformedVertexLocationAt: faceIndices.vertices[1]],
						   [ss  deformedVertexLocationAt: faceIndices.vertices[2]]);
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		node = nil;
		deformedVertexLocations = NULL;
		deformedVertexLocationsAreRetained = NO;
		deformedVertexLocationsAreDirty = YES;
	}
	return self;
}

// Phantom properties used during copying
-(BOOL) deformedVertexLocationsAreRetained { return deformedVertexLocationsAreRetained; }
-(BOOL) deformedVertexLocationsAreDirty { return deformedVertexLocationsAreDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3DeformedFaceArray*) another {
	[super populateFrom: another];
	
	node = another.node;		// not retained
	
	// If deformed vertex locations should be retained, allocate memory and copy the data over.
	[self deallocateDeformedVertexLocations];
	if (another.deformedVertexLocationsAreRetained) {
		[self allocateDeformedVertexLocations];
		memcpy(deformedVertexLocations, another.deformedVertexLocations, (self.vertexCount * sizeof(CC3Vector)));
	} else {
		deformedVertexLocations = another.deformedVertexLocations;
	}
	deformedVertexLocationsAreDirty = another.deformedVertexLocationsAreDirty;
}


#pragma mark Deformed vertex locations

-(CC3Vector*) deformedVertexLocations {
	if (deformedVertexLocationsAreDirty || !deformedVertexLocations) {
		[self populateDeformedVertexLocations];
	}
	return deformedVertexLocations;
}

-(void) setDeformedVertexLocations: (CC3Vector*) vtxLocs {
	[self deallocateDeformedVertexLocations];			// Safely disposes existing vertices
	deformedVertexLocations = vtxLocs;
}

-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex {
	if (shouldCacheFaces) {
		return self.deformedVertexLocations[vertexIndex];
	}
	return [[node skinSectionForFaceIndex: faceIndex]  deformedVertexLocationAt: vertexIndex];
}

-(CC3Vector*) allocateDeformedVertexLocations {
	[self deallocateDeformedVertexLocations];
	GLuint vtxCount = self.vertexCount;
	if (vtxCount) {
		deformedVertexLocations = calloc(vtxCount, sizeof(CC3Vector));
		deformedVertexLocationsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u deformed vertex locations", self, vtxCount);
	}
	return deformedVertexLocations;
}

-(void) deallocateDeformedVertexLocations {
	if (deformedVertexLocationsAreRetained && deformedVertexLocations) {
		free(deformedVertexLocations);
		deformedVertexLocations = NULL;
		deformedVertexLocationsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated deformed vertex locations", self, self.vertexCount);
	}
}

-(void) populateDeformedVertexLocations {
	LogTrace(@"%@ populating %u deformed vertex locations", self, self.vertexCount);
	if ( !deformedVertexLocations ) [self allocateDeformedVertexLocations];
	
	// Mark all the location vectors in the cached array as unset, so we can keep
	// track of which vertices have been set, as we iterate through the mesh vertices.
	GLuint vtxCount = self.vertexCount;
	for (int vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
		deformedVertexLocations[vtxIdx] = kCC3VectorNull;
	}

	// Determine whether the mesh is indexed.
	// If it is, we iterate through the indexes.
	// If it isn't, we iterate through the vertices.
	GLuint vtxIdxCount = [mesh vertexIndexCount];
	BOOL meshIsIndexed = (vtxIdxCount > 0);
	if (!meshIsIndexed) {
		vtxIdxCount = vtxCount;
	}

	// The skin sections are assigned to contiguous ranges of vertex indices.
	// We can avoid looking up the skin section for each vertex by assuming that they
	// will appear in groups, check the current skin section for each vertex index,
	// and only change when needed.
	
	// Get the skin section of the first vertex
	CC3SkinSection* ss = [node skinSectionForVertexIndexAt: 0];
	for (int vtxIdxPos = 0; vtxIdxPos < vtxIdxCount; vtxIdxPos++) {

		// Make sure the current skin section deforms this vertex, otherwise get the correct one
		if ( ![ss containsVertexIndex: vtxIdxPos] ) {
			ss = [node skinSectionForVertexIndexAt: vtxIdxPos];
			LogTrace(@"Selecting %@ for vertex at %i", ss, vtxIdxPos);
		}
		
		// Get the actual vertex index. If the mesh is indexed, we look it up, from the vertex
		// index position. If the mesh is not indexed, then it IS the vertex index position.
		GLuint vtxIdx = meshIsIndexed ? [mesh vertexIndexAt: vtxIdxPos] : vtxIdxPos;
		
		// If the cached vertex location has not yet been set, use the skin section to
		// deform the vertex location at the current index, and set it into the cache array.
		if ( CC3VectorIsNull(deformedVertexLocations[vtxIdx]) ) {
			deformedVertexLocations[vtxIdx] = [ss  deformedVertexLocationAt: vtxIdx];
			
			LogTrace(@"Setting deformed vertex %i to %@", vtxIdx,
						  NSStringFromCC3Vector(deformedVertexLocations[vtxIdx]));
		}
	}
	deformedVertexLocationsAreDirty = NO;
}

-(void) markDeformedVertexLocationsDirty { deformedVertexLocationsAreDirty = YES; }

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


#pragma mark -
#pragma mark CC3Node skinning extensions

@implementation CC3Node (Skinning)

-(BOOL) isSkeletonRigid { return transformMatrix.isRigid; }

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

-(CC3SoftBodyNode*) softBodyNode { return parent.softBodyNode; }

-(void) retainVertexMatrixIndices {
	for (CC3Node* child in children) {
		[child retainVertexMatrixIndices];
	}
}

-(void) doNotBufferVertexMatrixIndices {
	for (CC3Node* child in children) {
		[child doNotBufferVertexMatrixIndices];
	}
}

-(void) retainVertexWeights {
	for (CC3Node* child in children) {
		[child retainVertexWeights];
	}
}

-(void) doNotBufferVertexWeights {
	for (CC3Node* child in children) {
		[child doNotBufferVertexWeights];
	}
}

@end


#pragma mark -
#pragma mark CC3MeshNode skinning extensions

@implementation CC3MeshNode (Skinning)


#pragma mark Faces

-(CC3Face) deformedFaceAt: (GLuint) faceIndex {
	return [self faceAt: faceIndex];
}

-(CC3Vector) deformedFaceCenterAt: (GLuint) faceIndex {
	return [self faceCenterAt: faceIndex];
}

-(CC3Vector) deformedFaceNormalAt: (GLuint) faceIndex {
	return [self faceNormalAt: faceIndex];
}

-(CC3Plane) deformedFacePlaneAt: (GLuint) faceIndex {
	return [self facePlaneAt: faceIndex];
}

-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex {
	return [self vertexLocationAt: vertexIndex];
}

@end


#pragma mark -
#pragma mark CC3Mesh skinning extensions

/** CC3Mesh extension to define polymorphic methods to support vertex skinning. */
@implementation CC3Mesh (Skinning)

-(BOOL) hasVertexWeights { return NO; }

// Deprecated
-(BOOL) hasWeights { return self.hasVertexWeights; }

-(BOOL) hasVertexMatrixIndices { return NO; }

// Deprecated
-(BOOL) hasMatrixIndices { return self.hasVertexMatrixIndices; }


#pragma mark Accessing vertex data

-(void) retainVertexMatrixIndices {}

-(void) doNotBufferVertexMatrixIndices {}

-(void) retainVertexWeights {}

-(void) doNotBufferVertexWeights {}

-(GLuint) vertexUnitCount { return 0; }

-(GLfloat) vertexWeightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index { return 0.0f; }

-(void) setVertexWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {}

-(GLfloat*) vertexWeightsAt: (GLuint) index { return NULL; }

-(void) setVertexWeights: (GLfloat*) weights at: (GLuint) index {}

-(void) updateVertexWeightsGLBuffer {}

-(GLuint) vertexMatrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index { return 0; }

-(void) setVertexMatrixIndex: (GLuint) aMatrixIndex
			   forVertexUnit: (GLuint) vertexUnit
						  at: (GLuint) index {}

-(GLvoid*) vertexMatrixIndicesAt: (GLuint) index { return NULL; }

-(void) setVertexMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index {}

-(void) updateVertexMatrixIndicesGLBuffer {}

-(GLenum) matrixIndexType { return GL_FALSE; }

@end
