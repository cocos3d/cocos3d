/*
 * CC3VertexSkinning.m
 *
 * cocos3d 2.0.0
 * Author: Chris Myers, Bill Hollings
 * Copyright (c) 2011 Chris Myers. All rights reserved.
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
-(void) addCopiesOfChildrenFrom: (CC3Node*) another;
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
-(void) addCopiesOfChildrenFrom: (CC3Node*) another {
	[super addCopiesOfChildrenFrom: another];
	[self reattachBonesFrom: self];
}

-(CC3SoftBodyNode*) softBodyNode { return self; }

-(CC3Vector) skeletalScale { return kCC3VectorUnitCube; }

@end


#pragma mark -
#pragma mark CC3SkinMeshNode

@implementation CC3SkinMeshNode

@synthesize skinSections=_skinSections;

-(void) dealloc {
	[_skinSections release];
	[_skeletalTransformMatrix release];
	[_skeletalTransformMatrixInverted release];
	[_deformedFaces release];

	[super dealloc];
}

-(CC3SkinSection*) skinSectionForVertexIndexAt: (GLint) index {
	for (CC3SkinSection* ss in _skinSections) if ( [ss containsVertexIndex: index] ) return ss;
	return nil;
}

-(CC3SkinSection*) skinSectionForFaceIndex: (GLint) faceIndex {
	return [self skinSectionForVertexIndexAt: [self vertexIndexCountFromFaceCount: faceIndex]];
}

-(BOOL) hasSkeleton {
	for (CC3SkinSection* ss in _skinSections) if (ss.hasSkeleton) return YES;
	return NO;
}

-(BOOL) hasRigidSkeleton { return _hasRigidSkeleton; }

-(void) ensureRigidSkeleton {
	_hasRigidSkeleton = self.hasSkeleton;
	[super ensureRigidSkeleton];
}


#pragma mark Faces

-(void) setShouldCacheFaces: (BOOL) shouldCache {
	self.deformedFaces.shouldCacheFaces = shouldCache;
	super.shouldCacheFaces = shouldCache;
}

-(CC3DeformedFaceArray*) deformedFaces {
	if ( !_deformedFaces ) {
		NSString* facesName = [NSString stringWithFormat: @"%@-DeformedFaces", self.name];
		self.deformedFaces = [CC3DeformedFaceArray faceArrayWithName: facesName];
	}
	return _deformedFaces;
}

-(void) setDeformedFaces: (CC3DeformedFaceArray*) aFaceArray {
	if (aFaceArray == _deformedFaces) return;
	
	[_deformedFaces release];
	_deformedFaces = [aFaceArray retain];

	_deformedFaces.node = self;
}

-(CC3Face) deformedFaceAt: (GLuint) faceIndex { return [self.deformedFaces faceAt: faceIndex]; }

-(CC3Vector) deformedFaceCenterAt: (GLuint) faceIndex { return [self.deformedFaces centerAt: faceIndex]; }

-(CC3Vector) deformedFaceNormalAt: (GLuint) faceIndex { return [self.deformedFaces normalAt: faceIndex]; }

-(CC3Plane) deformedFacePlaneAt: (GLuint) faceIndex { return [self.deformedFaces planeAt: faceIndex]; }

-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex {
	return [self.deformedFaces deformedVertexLocationAt: vertexIndex fromFaceAt: faceIndex];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_skinSections = [NSMutableArray new];						// retained
		_skeletalTransformMatrix = [CC3AffineMatrix new];			// retained
		_skeletalTransformMatrixInverted = [CC3AffineMatrix new];	// retained
		_deformedFaces = nil;
	}
	return self;
}

-(void) populateFrom: (CC3SkinMeshNode*) another {
	[super populateFrom: another];

	// The deformedFaces instance is not copied, since the deformed faces
	// are different for each mesh node and is created lazily if needed.
	// The skeletal transform matrices are not copied

	[_skinSections removeAllObjects];
	NSArray* otherSkinSections = another.skinSections;
	for (CC3SkinSection* ss in otherSkinSections)
		[_skinSections addObject: [[ss copyForNode: self] autorelease]];	// retained in array
}

-(void) reattachBonesFrom: (CC3Node*) aNode {
	for (CC3SkinSection* skinSctn in _skinSections) [skinSctn reattachBonesFrom: aNode];
	[super reattachBonesFrom: aNode];
}

-(BOOL) hasSoftBodyContent  { return YES; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %lu skin sections",
			super.description, (unsigned long)_skinSections.count];
}


#pragma mark Transformations

-(void) markTransformDirty {
	[super markTransformDirty];
	_skeletalTransformMatrix.isDirty = YES;
	_skeletalTransformMatrixInverted.isDirty = YES;
	[_deformedFaces clearDeformableCaches];
}

-(CC3Matrix*) skeletalTransformMatrix {
	if (_skeletalTransformMatrix.isDirty) {
		[_skeletalTransformMatrix populateFrom: self.globalTransformMatrix];
		[_skeletalTransformMatrix leftMultiplyBy: self.softBodyNode.globalTransformMatrixInverted];
		_skeletalTransformMatrix.isDirty = NO;
	}
	return _skeletalTransformMatrix;
}

-(CC3Matrix*) skeletalTransformMatrixInverted {
	if (_skeletalTransformMatrixInverted.isDirty) {
		[_skeletalTransformMatrixInverted populateFrom: self.skeletalTransformMatrix];
		[_skeletalTransformMatrixInverted invert];
		_skeletalTransformMatrixInverted.isDirty = NO;
	}
	return _skeletalTransformMatrixInverted;
}

-(void) boneWasTransformed: (CC3Bone*) aBone { [_deformedFaces clearDeformableCaches]; }


#pragma mark Drawing

/**
 * Returns a spherical bounding volume that will be sized to encompass the vertices of the
 * skin mesh in its bind pose. A sphere is used because for many bone-rigged characters, 
 * the bones remain within the sphere determmined by the rest pose.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume {
	return [CC3NodeSphericalBoundingVolume boundingVolume];
}

/** Overridden to skip auto-creating a bounding volume. */
-(void) createBoundingVolumes { for (CC3Node* child in _children) [child createBoundingVolumes]; }

/** Overridden to auto-create a bounding volume. */
-(void) createSkinnedBoundingVolumes {
	[self createBoundingVolume];
	for (CC3Node* child in _children) [child createSkinnedBoundingVolumes];
}

/** Use this bounding volume, then pass along to my descendants. */
-(void) setSkeletalBoundingVolume: (CC3NodeBoundingVolume*) boundingVolume {
	self.boundingVolume = boundingVolume;
	super.skeletalBoundingVolume = boundingVolume;
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
	
	[_mesh bindWithVisitor: visitor];	// Bind the arrays
	
	for (CC3SkinSection* skinSctn in _skinSections)
		[skinSctn drawVerticesOfMesh: _mesh withVisitor: visitor];
	
	[gl enableMatrixPalette: NO];		// We are finished with the matrix pallete so disable it.
}

@end


#pragma mark -
#pragma mark CC3SkinSection

@implementation CC3SkinSection

@synthesize vertexStart=_vertexStart, vertexCount=_vertexCount;

-(void) dealloc {
	_node = nil;				// weak reference
	[_skinnedBones release];
	
	[super dealloc];
}

-(BOOL) hasSkeleton { return self.boneCount > 0; }

-(GLuint) boneCount { return (GLuint)_skinnedBones.count; }

-(NSArray*) bones {
	NSMutableArray* bones = [NSMutableArray array];
	for (CC3SkinnedBone* sb in _skinnedBones) [bones addObject: sb.bone];
	return bones;
}

-(CC3Bone*) boneAt: (GLuint) boneIdx {
	return ((CC3SkinnedBone*)[_skinnedBones objectAtIndex: boneIdx]).bone;
}

-(void) addBone: (CC3Bone*) aBone {
	[_skinnedBones addObject: [CC3SkinnedBone skinnedBoneWithSkin: _node onBone: aBone]];
}

-(BOOL) hasRigidSkeleton {
	for (CC3SkinnedBone* sb in _skinnedBones) if ( !sb.bone.skeletalTransformMatrix.isRigid ) return NO;
	return (_skinnedBones.count > 0);	// YES if all bones returned YES, but NO if no bones.
}

-(BOOL) containsVertexIndex: (GLint) aVertexIndex {
	return (aVertexIndex >= _vertexStart) && (aVertexIndex < _vertexStart + _vertexCount);
}

-(CC3Vector) deformedVertexLocationAt:  (GLuint) vtxIdx {
	CC3Mesh* skinMesh = _node.mesh;
	
	// The locations of this vertex before and after deformation.
	// The latter is to be calculated and returned by this method.
	CC3Vector restLoc = [skinMesh vertexLocationAt: vtxIdx];
	CC3Vector defLoc = kCC3VectorZero;
	
	// Calc the weighted sum of the deformation contributed by each bone to this vertex.
	// Iterate through the bones associated with this vertex.
	GLuint vuCnt = skinMesh.vertexBoneCount;
	for (GLuint vuIdx = 0; vuIdx < vuCnt; vuIdx++) {
		
		// Get a bone and its weighting for this vertex.
		GLfloat vtxWt = [skinMesh vertexWeightForBoneInfluence: vuIdx at: vtxIdx];
		GLuint vtxBoneIdx = [skinMesh vertexBoneIndexForBoneInfluence: vuIdx at: vtxIdx];
		CC3SkinnedBone* skinnedBone = ((CC3SkinnedBone*)[_skinnedBones objectAtIndex: vtxBoneIdx]);
		
		// Use the bone to deform the vertex, apply the weighting for this bone,
		// and add to the summed location.
		CC3Vector boneDefLoc = [skinnedBone.transformMatrix transformLocation: restLoc];
		CC3Vector wtdBoneDefLoc = CC3VectorScaleUniform(boneDefLoc, vtxWt);
		defLoc = CC3VectorAdd(defLoc, wtdBoneDefLoc);

		LogTrace(@"%@ vu: %i, bone at %i, weight %.3f transforming vertex at %i: %@ to %@ to wtd: %@ to sum: %@",
				 self, vuIdx, vtxBoneIdx, vtxWt, vtxIdx,
				 NSStringFromCC3Vector(restLoc),
				 NSStringFromCC3Vector(boneDefLoc),
				 NSStringFromCC3Vector(wtdBoneDefLoc),
				 NSStringFromCC3Vector(defLoc));
	}
	return defLoc;
}


#pragma mark Allocation and initialization

-(id) init { return [self initForNode: nil]; }

-(id) initForNode: (CC3SkinMeshNode*) aNode {
	if ( (self = [super init]) ) {
		_node = aNode;							// weak reference
		_skinnedBones = [NSMutableArray new];	// retained
		_vertexStart = 0;
		_vertexCount = 0;
	}
	return self;
}

+(id) skinSectionForNode: (CC3SkinMeshNode*) aNode {
	return [((CC3SkinSection*)[self alloc]) initForNode: aNode];
}

// Extract the old bones into an array, and for each, look for the
// bone with the same name as a descendant of the specified node.
-(void) reattachBonesFrom: (CC3Node*) aNode {
	NSArray* oldBones = self.bones;
	[_skinnedBones removeAllObjects];
	for (CC3Bone* ob in oldBones) [self addBone: (CC3Bone*)[aNode getNodeNamed: ob.name]];
}

-(void) populateFrom: (CC3SkinSection*) another {

	_vertexStart = another.vertexStart;
	_vertexCount = another.vertexCount;

	// Each bone is retained but not copied, and will be swapped for copied bones via reattachBonesFrom:
	[_skinnedBones removeAllObjects];
	NSArray* otherBones = another.bones;
	for (CC3Bone* bone in otherBones) [self addBone: bone];
}

-(id) copyWithZone: (NSZone*) zone { return [self copyForNode: nil withZone: zone]; }

-(id) copyForNode: (CC3SkinMeshNode*) aNode { return [self copyForNode: aNode withZone: nil]; }

-(id) copyForNode: (CC3SkinMeshNode*) aNode withZone: (NSZone*) zone {
	CC3SkinSection* aCopy = [((CC3SkinSection*)[[self class] allocWithZone: zone]) initForNode: aNode];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %i bones, vertices from %u to %u for %@",
			[self class], self.boneCount, _vertexStart, (_vertexStart + _vertexCount - 1), _node];
}

-(NSString*) fullDescription { return [NSString stringWithFormat: @"%@ %@", [self description], self.bones]; }


#pragma mark Drawing

-(void) drawVerticesOfMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {

#if !CC3_GLSL
	GLuint boneCnt = self.boneCount;
	for (GLuint boneNum = 0; boneNum < boneCnt; boneNum++) {
		CC3SkinnedBone* sb = [_skinnedBones objectAtIndex: boneNum];

		// Load this palette matrix from the modelview matrix and the apply the bone draw matrix.
		// Since the CC3SkinMeshNode does not transform the modelview stack, the modelview will
		// only contain the view matrix. All other transforms are captured in the bone matrices.
		CC3Matrix4x3 mtx;
		CC3Matrix4x3PopulateFrom4x3(&mtx, visitor.modelViewMatrix);
		[sb.transformMatrix multiplyIntoCC3Matrix4x3: &mtx];
		[visitor.gl loadPaletteMatrix: &mtx at: boneNum];
	}
#endif	// !CC3_GLSL

	visitor.currentSkinSection = self;
	[mesh drawVerticesFrom: _vertexStart forCount: _vertexCount withVisitor: visitor];
}

-(CC3Matrix*) transformMatrixForBoneAt: (GLuint) boneIdx {
	return ((CC3SkinnedBone*)[_skinnedBones objectAtIndex: boneIdx]).transformMatrix;
}

@end


#pragma mark -
#pragma mark CC3Bone

@implementation CC3Bone

@synthesize restPoseSkeletalTransformMatrixInverted=_restPoseSkeletalTransformMatrixInverted;

-(void) dealloc {
	[_skeletalTransformMatrix release];
	[_restPoseSkeletalTransformMatrixInverted release];
	
	[super dealloc];
}

-(BOOL) hasSoftBodyContent  { return YES; }

-(void) ensureRigidSkeleton {
	self.uniformScale = 1.0f;
	[self disableScaleAnimation];
	[super ensureRigidSkeleton];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_skeletalTransformMatrix = [CC3AffineMatrix new];					// retained
		_restPoseSkeletalTransformMatrixInverted = [CC3AffineMatrix new];	// retained
	}
	return self;
}

-(void) populateFrom: (CC3Bone*) another {
	[super populateFrom: another];
	
	// The skeletal transform matrix is not copied
	[_restPoseSkeletalTransformMatrixInverted populateFrom: another.restPoseSkeletalTransformMatrixInverted];
}


#pragma mark Transformations

-(void) markTransformDirty {
	[super markTransformDirty];
	_skeletalTransformMatrix.isDirty = YES;
}

-(CC3Matrix*) skeletalTransformMatrix {
	if (_skeletalTransformMatrix.isDirty) {
		[_skeletalTransformMatrix populateFrom: self.globalTransformMatrix];
		[_skeletalTransformMatrix leftMultiplyBy: self.softBodyNode.globalTransformMatrixInverted];
		_skeletalTransformMatrix.isDirty = NO;
	}
	return _skeletalTransformMatrix;
}

-(void) bindRestPose {
	[self cacheRestPoseMatrix];
	[super bindRestPose];
}

/** Inverts the transform matrix and caches it as the inverted rest pose matrix. */
-(void) cacheRestPoseMatrix {
	[_restPoseSkeletalTransformMatrixInverted populateFrom: self.skeletalTransformMatrix];
	[_restPoseSkeletalTransformMatrixInverted invert];
	LogTrace(@"%@ with global scale %@ and rest pose %@ %@ inverted to %@",
			 self, NSStringFromCC3Vector(self.globalScale), _skeletalTransformMatrix,
			 (_restPoseSkeletalTransformMatrixInverted.isRigid ? @"rigidly" : @"adjoint"), _restPoseSkeletalTransformMatrixInverted);
	LogTrace(@"Validating right multiply: %@ \nvalidating left multiply: %@",
			 [CC3AffineMatrix matrixByMultiplying: _skeletalTransformMatrix by: _restPoseSkeletalTransformMatrixInverted],
			 [CC3AffineMatrix matrixByMultiplying: _restPoseSkeletalTransformMatrixInverted by: _skeletalTransformMatrix]);
}

@end


#pragma mark -
#pragma mark CC3SkinnedBone

@implementation CC3SkinnedBone

@synthesize bone=_bone, skinNode=_skinNode;

-(void) dealloc {
	[_skinNode removeTransformListener: self];
	_skinNode = nil;								// weak reference

	[_bone removeTransformListener: self];
	_bone = nil;									// weak reference
	
	[_transformMatrix release];

	[super dealloc];
}

-(void) markTransformDirty { _transformMatrix.isDirty = YES; }

-(CC3Matrix*) transformMatrix {
	if (_transformMatrix.isDirty) {
		[_transformMatrix populateFrom: _skinNode.skeletalTransformMatrixInverted];
		[_transformMatrix multiplyBy: _bone.skeletalTransformMatrix];
		[_transformMatrix multiplyBy: _bone.restPoseSkeletalTransformMatrixInverted];
		[_transformMatrix multiplyBy: _skinNode.skeletalTransformMatrix];
		_transformMatrix.isDirty = NO;
	}
	return _transformMatrix;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for bone %@ of skin %@", self.class, _bone, _skinNode];
}


#pragma mark Allocation and initialization

// This will raise an assertion without a skin node or bone.
-(id) init { return [self initWithSkin: nil onBone: nil]; }

-(id) initWithSkin: (CC3SkinMeshNode*) aNode onBone: (CC3Bone*) aBone {
	CC3Assert(aNode, @"%@ must be initialized with a skin node.", self.class);
	CC3Assert(aBone, @"%@ must be initialized with a bone.", self.class);
	if ( (self = [super init]) ) {

		_skinNode = aNode;							// weak reference
		[_skinNode addTransformListener: self];

		_bone = aBone;								// weak reference
		[_bone addTransformListener: self];

		_transformMatrix = [CC3AffineMatrix new];	// retained
		[self markTransformDirty];
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
	if (aNode == _bone) [_skinNode boneWasTransformed: _bone];
}

/**
 * If either of the nodes to whom I have registered as a
 * listener disappears before I do, clear the reference to it.
 */
-(void) nodeWasDestroyed: (CC3Node*) aNode {
	if (aNode == _skinNode) _skinNode = nil;	// weak reference
	if (aNode == _bone) _bone = nil;			// weak reference
}

@end


#pragma mark -
#pragma mark CC3DeformedFaceArray

@implementation CC3DeformedFaceArray

@synthesize node=_node;

-(void) dealloc {
	_node = nil;								// weak reference
	[self deallocateDeformedVertexLocations];

	[super dealloc];
}

/**
 * Clears all caches so that they will be lazily initialized
 * on next access using the new mesh data.
 */
-(void) setNode: (CC3SkinMeshNode*) aNode {
	_node = aNode;								// weak reference
	self.mesh = aNode.mesh;
	[self deallocateDeformedVertexLocations];
}

/**
 * Adds this array as listener to bone movements.
 * If turning off, clears all caches except neighbours.
 */
-(void) setShouldCacheFaces: (BOOL) shouldCache {
	super.shouldCacheFaces = shouldCache;
	if ( !_shouldCacheFaces ) [self deallocateDeformedVertexLocations];
}

-(void) clearDeformableCaches {
	[self markCentersDirty];
	[self markNormalsDirty];
	[self markPlanesDirty];
	[self markDeformedVertexLocationsDirty];
}

-(GLuint) vertexCount { return _mesh ? _mesh.vertexCount : 0;}

-(CC3Face) faceAt: (GLuint) faceIndex {
	CC3FaceIndices faceIndices = [_node faceIndicesAt: faceIndex];
	if (_shouldCacheFaces) {
		CC3Vector* vtxLocs = self.deformedVertexLocations;
		return CC3FaceMake(vtxLocs[faceIndices.vertices[0]],
						   vtxLocs[faceIndices.vertices[1]],
						   vtxLocs[faceIndices.vertices[2]]);
	} else {
		CC3SkinSection* ss = [_node skinSectionForFaceIndex: faceIndex];
		return CC3FaceMake([ss  deformedVertexLocationAt: faceIndices.vertices[0]],
						   [ss  deformedVertexLocationAt: faceIndices.vertices[1]],
						   [ss  deformedVertexLocationAt: faceIndices.vertices[2]]);
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_node = nil;
		_deformedVertexLocations = NULL;
		_deformedVertexLocationsAreRetained = NO;
		_deformedVertexLocationsAreDirty = YES;
	}
	return self;
}

// Phantom properties used during copying
-(BOOL) deformedVertexLocationsAreRetained { return _deformedVertexLocationsAreRetained; }
-(BOOL) deformedVertexLocationsAreDirty { return _deformedVertexLocationsAreDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3DeformedFaceArray*) another {
	[super populateFrom: another];
	
	_node = another.node;		// weak reference
	
	// If deformed vertex locations should be retained, allocate memory and copy the data over.
	[self deallocateDeformedVertexLocations];
	if (another.deformedVertexLocationsAreRetained) {
		[self allocateDeformedVertexLocations];
		memcpy(_deformedVertexLocations, another.deformedVertexLocations, (self.vertexCount * sizeof(CC3Vector)));
	} else {
		_deformedVertexLocations = another.deformedVertexLocations;
	}
	_deformedVertexLocationsAreDirty = another.deformedVertexLocationsAreDirty;
}


#pragma mark Deformed vertex locations

-(CC3Vector*) deformedVertexLocations {
	if (_deformedVertexLocationsAreDirty || !_deformedVertexLocations)
		[self populateDeformedVertexLocations];
	return _deformedVertexLocations;
}

-(void) setDeformedVertexLocations: (CC3Vector*) vtxLocs {
	[self deallocateDeformedVertexLocations];			// Safely disposes existing vertices
	_deformedVertexLocations = vtxLocs;
}

-(CC3Vector) deformedVertexLocationAt: (GLuint) vertexIndex fromFaceAt: (GLuint) faceIndex {
	if (_shouldCacheFaces) return self.deformedVertexLocations[vertexIndex];
	return [[_node skinSectionForFaceIndex: faceIndex]  deformedVertexLocationAt: vertexIndex];
}

-(CC3Vector*) allocateDeformedVertexLocations {
	[self deallocateDeformedVertexLocations];
	GLuint vtxCount = self.vertexCount;
	if (vtxCount) {
		_deformedVertexLocations = calloc(vtxCount, sizeof(CC3Vector));
		_deformedVertexLocationsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u deformed vertex locations", self, vtxCount);
	}
	return _deformedVertexLocations;
}

-(void) deallocateDeformedVertexLocations {
	if (_deformedVertexLocationsAreRetained && _deformedVertexLocations) {
		free(_deformedVertexLocations);
		_deformedVertexLocations = NULL;
		_deformedVertexLocationsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated deformed vertex locations", self, self.vertexCount);
	}
}

-(void) populateDeformedVertexLocations {
	LogTrace(@"%@ populating %u deformed vertex locations", self, self.vertexCount);
	if ( !_deformedVertexLocations ) [self allocateDeformedVertexLocations];
	
	// Mark all the location vectors in the cached array as unset, so we can keep
	// track of which vertices have been set, as we iterate through the mesh vertices.
	GLuint vtxCount = self.vertexCount;
	for (int vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++)
		_deformedVertexLocations[vtxIdx] = kCC3VectorNull;

	// Determine whether the mesh is indexed.
	// If it is, we iterate through the indexes.
	// If it isn't, we iterate through the vertices.
	GLuint vtxIdxCount = [_mesh vertexIndexCount];
	BOOL meshIsIndexed = (vtxIdxCount > 0);
	if (!meshIsIndexed) vtxIdxCount = vtxCount;

	// The skin sections are assigned to contiguous ranges of vertex indices.
	// We can avoid looking up the skin section for each vertex by assuming that they
	// will appear in groups, check the current skin section for each vertex index,
	// and only change when needed.
	
	// Get the skin section of the first vertex
	CC3SkinSection* ss = [_node skinSectionForVertexIndexAt: 0];
	for (int vtxIdxPos = 0; vtxIdxPos < vtxIdxCount; vtxIdxPos++) {

		// Make sure the current skin section deforms this vertex, otherwise get the correct one
		if ( ![ss containsVertexIndex: vtxIdxPos] ) {
			ss = [_node skinSectionForVertexIndexAt: vtxIdxPos];
			LogTrace(@"Selecting %@ for vertex at %i", ss, vtxIdxPos);
		}
		
		// Get the actual vertex index. If the mesh is indexed, we look it up, from the vertex
		// index position. If the mesh is not indexed, then it IS the vertex index position.
		GLuint vtxIdx = meshIsIndexed ? [_mesh vertexIndexAt: vtxIdxPos] : vtxIdxPos;
		
		// If the cached vertex location has not yet been set, use the skin section to
		// deform the vertex location at the current index, and set it into the cache array.
		if ( CC3VectorIsNull(_deformedVertexLocations[vtxIdx]) ) {
			_deformedVertexLocations[vtxIdx] = [ss deformedVertexLocationAt: vtxIdx];
			
			LogTrace(@"Setting deformed vertex %i to %@", vtxIdx,
						  NSStringFromCC3Vector(_deformedVertexLocations[vtxIdx]));
		}
	}
	_deformedVertexLocationsAreDirty = NO;
}

-(void) markDeformedVertexLocationsDirty { _deformedVertexLocationsAreDirty = YES; }

@end


#pragma mark -
#pragma mark CC3Node skinning extensions

@implementation CC3Node (Skinning)

-(CC3Vector) skeletalScale { return _parent ? CC3VectorScale(_parent.skeletalScale, _scale) : _scale; }

-(void) bindRestPose { for (CC3Node* child in _children) [child bindRestPose]; }

-(void) reattachBonesFrom: (CC3Node*) aNode { for (CC3Node* child in _children) [child reattachBonesFrom: aNode]; }

-(BOOL) hasSoftBodyContent {
	for (CC3Node* child in _children) if (child.hasSoftBodyContent) return YES;
	return NO;
}

-(void) ensureRigidSkeleton { for (CC3Node* child in _children) [child ensureRigidSkeleton]; }

-(CC3SoftBodyNode*) softBodyNode { return _parent.softBodyNode; }

-(void) createSkinnedBoundingVolumes {
	for (CC3Node* child in _children) [child createSkinnedBoundingVolumes];
}

-(void) setSkeletalBoundingVolume: (CC3NodeBoundingVolume*) boundingVolume {
	for (CC3Node* child in _children) child.skeletalBoundingVolume = boundingVolume;
}

@end


#pragma mark -
#pragma mark CC3MeshNode skinning extensions

@implementation CC3MeshNode (Skinning)

-(BOOL) hasSkeleton { return NO; }

-(BOOL) hasRigidSkeleton { return NO; }


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
#pragma mark Deprecated CC3SkeletonRestPoseBindingVisitor

@implementation CC3SkeletonRestPoseBindingVisitor
@end
