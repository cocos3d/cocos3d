/*
 * CC3VertexSkinning.m
 *
 * cocos3d 2.0.0
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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


@interface CC3Node (TemplateMethods)
-(void) copyChildrenFrom: (CC3Node*) another;
-(void) cacheRestPoseMatrix;
-(void) transformMatrixChanged;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@interface CC3Mesh (TemplateMethods)
-(void) drawVerticesFrom: (GLuint) vertexIndex
				forCount: (GLuint) vertexCount
			 withVisitor: (CC3NodeDrawingVisitor*) visitor;
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
-(void) bindRestPose { [[CC3SkeletonRestPoseBindingVisitor visitor] visit: self]; }

-(CC3SoftBodyNode*) softBodyNode { return self; }

-(CC3Vector) skeletalScale { return kCC3VectorUnitCube; }

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
	for (CC3SkinSection* skinSctn in skinSections)
		if ( [skinSctn containsVertexIndex: index] ) return skinSctn;
	return nil;
}

-(CC3SkinSection*) skinSectionForFaceIndex: (GLint) faceIndex {
	return [self skinSectionForVertexIndexAt: [self vertexIndexCountFromFaceCount: faceIndex]];
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
	for (CC3SkinSection* ss in otherSkinSections)
		[skinSections addObject: [[ss copyForNode: self] autorelease]];		// retained in array
}

-(void) reattachBonesFrom: (CC3Node*) aNode {
	for (CC3SkinSection* skinSctn in skinSections) [skinSctn reattachBonesFrom: aNode];
	[super reattachBonesFrom: aNode];
}

-(BOOL) hasSoftBodyContent  { return YES; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %lu skin sections",
			super.description, (unsigned long)skinSections.count];
}


#pragma mark Transformations

-(void) transformMatrixChanged {
	[super transformMatrixChanged];
	[deformedFaces clearDeformableCaches];		// Avoid creating lazily if not already created.
}

/** Caches the transform matrix rest pose matrix. */
-(void) cacheRestPoseMatrix { [restPoseTransformMatrix populateFrom: transformMatrix]; }

-(void) boneWasTransformed: (CC3Bone*) aBone { [self markTransformDirty]; }


#pragma mark Drawing

/**
 * Overridden to skip the manipulation of the modelview matrix stack.
 *
 * Vertex skinning does not use the modelview matrix stack. Instead, it uses a palette of
 * matrices that is used to manipulate the vertices of a mesh based on a weighted average
 * of the influence of the position of several bone nodes. This activity is handled through
 * the drawing of the contained mesh.
 *
 * The model transform matrix is not applied to the fixed pipeline matrix stack. However,
 * it is made available to shaders in the programmable pipeline. The shader may then choose
 * to use or ignore it.
 */
-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@", self);
	[visitor populateModelMatrixFrom: nil];
//	[visitor populateModelMatrixFrom: transformMatrix];
	[visitor draw: self];
}

/** 
 * Draws the mesh vertices to the GL engine.
 *
 * Enables palette matrices, binds the mesh to the GL engine, delegates to the contained
 * collection of CC3SkinSections to draw the mesh in batches, then disables palette matrices again.
 */
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	
	[gl enableMatrixPalette: YES];		// Enable the matrix palette
	
	[mesh bindWithVisitor: visitor];	// Bind the arrays
	
	for (CC3SkinSection* skinSctn in skinSections)
		[skinSctn drawVerticesOfMesh: mesh withVisitor: visitor];
	
	[gl enableMatrixPalette: NO];		// We are finished with the matrix pallete so disable it.
}


#pragma mark Deprecated methods

// Deprecated
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexWeightForVertexUnit: vertexUnit at: index];
}

// Deprecated
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexWeight: aWeight forVertexUnit: vertexUnit at: index];
}

// Deprecated
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexMatrixIndexForVertexUnit: vertexUnit at: index];
}

// Deprecated
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

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

-(GLuint) boneCount { return (GLuint)skinnedBones.count; }

-(CCArray*) bones {
	CCArray* bones = [CCArray array];
	for (CC3SkinnedBone* sb in skinnedBones) [bones addObject: sb.bone];
	return bones;
}

-(void) addBone: (CC3Bone*) aBone {
	[skinnedBones addObject: [CC3SkinnedBone skinnedBoneWithSkin: node onBone: aBone]];
}

-(BOOL) containsVertexIndex: (GLint) aVertexIndex {
	return (aVertexIndex >= vertexStart) && (aVertexIndex < vertexStart + vertexCount);
}

-(CC3Vector)  deformedVertexLocationAt:  (GLuint) vtxIdx {
	CC3Mesh* skinMesh = node.mesh;
	
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
	for (CC3Bone* ob in oldBones) [self addBone: (CC3Bone*)[aNode getNodeNamed: ob.name]];
}

-(void) populateFrom: (CC3SkinSection*) another {

	vertexStart = another.vertexStart;
	vertexCount = another.vertexCount;

	// Each bone is retained but not copied, and will be swapped for copied bones via reattachBonesFrom:
	[skinnedBones removeAllObjects];
	CCArray* otherBones = another.bones;
	for (CC3Bone* bone in otherBones) [self addBone: bone];
}

-(id) copyWithZone: (NSZone*) zone { return [self copyForNode: nil withZone: zone]; }

-(id) copyForNode: (CC3SkinMeshNode*) aNode { return [self copyForNode: aNode withZone: nil]; }

-(id) copyForNode: (CC3SkinMeshNode*) aNode withZone: (NSZone*) zone {
	CC3SkinSection* aCopy = [[[self class] allocWithZone: zone] initForNode: aNode];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %i bones, vertices from %u to %u for %@",
			[self class], self.boneCount, vertexStart, (vertexStart + vertexCount - 1), node];
}

-(NSString*) fullDescription { return [NSString stringWithFormat: @"%@ %@", [self description], self.bones]; }


#pragma mark Drawing

-(void) drawVerticesOfMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {

#if !CC3_GLSL
	GLuint boneCnt = self.boneCount;
	for (GLuint boneNum = 0; boneNum < boneCnt; boneNum++) {
		CC3SkinnedBone* sb = [skinnedBones objectAtIndex: boneNum];

		// Load this palette matrix from the modelview matrix and the apply the bone draw matrix.
		// Since the CC3SkinMeshNode does not transform the modelview stack, the modelview will
		// only contain the view matrix. All other transforms are captured in the bone matrices.
		CC3Matrix4x3 mtx;
		CC3Matrix4x3PopulateFrom4x3(&mtx, visitor.modelViewMatrix);
		[sb.drawTransformMatrix multiplyIntoCC3Matrix4x3: &mtx];
		[visitor.gl loadPaletteMatrix: &mtx at: boneNum];
	}
#endif	// !CC3_GLSL

	visitor.currentSkinSection = self;
	[mesh drawVerticesFrom: vertexStart forCount: vertexCount withVisitor: visitor];
}

-(CC3Matrix*) getDrawTransformMatrixForBoneAt: (GLuint) boneIdx {
	return ((CC3SkinnedBone*)[skinnedBones objectAtIndex: boneIdx]).drawTransformMatrix;
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
	if ( !drawTransformMatrix ) drawTransformMatrix = [CC3AffineMatrix new];
	if (isDrawTransformDirty) {
		[bone applyPoseTo: drawTransformMatrix];
		[drawTransformMatrix multiplyBy: skinNode.restPoseTransformMatrix];
		isDrawTransformDirty = NO;
		isSkinTransformDirty = YES;
	}
	return drawTransformMatrix;
}

-(CC3Matrix*) skinTransformMatrix {
	if ( !skinTransformMatrix ) skinTransformMatrix = [CC3AffineMatrix new];
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
	CC3Assert(aNode, @"%@ must be initialized with a skin node.", self.class);
	CC3Assert(aBone, @"%@ must be initialized with a bone.", self.class);
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
		_shouldLocalizeToStartingNode = YES;
		_shouldRestoreTransforms = YES;
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

-(CC3Vector) skeletalScale { return parent ? CC3VectorScale(parent.skeletalScale, scale) : scale; }

-(BOOL) isSkeletonRigid { return transformMatrix.isRigid; }

-(void) bindRestPose { for (CC3Node* child in children) [child bindRestPose]; }

-(void) reattachBonesFrom: (CC3Node*) aNode { for (CC3Node* child in children) [child reattachBonesFrom: aNode]; }

-(BOOL) hasSoftBodyContent {
	for (CC3Node* child in children) if (child.hasSoftBodyContent) return YES;
	return NO;
}

-(void) cacheRestPoseMatrix {}

-(CC3SoftBodyNode*) softBodyNode { return parent.softBodyNode; }

@end


#pragma mark -
#pragma mark CC3MeshNode skinning extensions

@implementation CC3MeshNode (Skinning)


#pragma mark Faces

-(CC3Face) deformedFaceAt: (GLuint) faceIndex { return [self faceAt: faceIndex]; }

-(CC3Vector) deformedFaceCenterAt: (GLuint) faceIndex { return [self faceCenterAt: faceIndex]; }

-(CC3Vector) deformedFaceNormalAt: (GLuint) faceIndex { return [self faceNormalAt: faceIndex]; }

-(CC3Plane) deformedFacePlaneAt: (GLuint) faceIndex { return [self facePlaneAt: faceIndex]; }

-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex {
	return [self vertexLocationAt: vertexIndex];
}

@end


#pragma mark -
#pragma mark Deprecated CC3SkinMesh

@implementation CC3SkinMesh

-(CC3VertexMatrixIndices*) boneMatrixIndices { return self.vertexMatrixIndices; }
-(void) setBoneMatrixIndices: (CC3VertexMatrixIndices*) bmi { self.vertexMatrixIndices = bmi; }
-(CC3VertexWeights*) boneWeights { return self.vertexWeights; }
-(void) setBoneWeights: (CC3VertexWeights*) bw { self.vertexWeights = bw; }
-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexWeightForVertexUnit: vertexUnit at: index];
}
-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexWeight: aWeight forVertexUnit: vertexUnit at: index];
}
-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self vertexMatrixIndexForVertexUnit: vertexUnit at: index];
}
-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[self setVertexMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

@end
