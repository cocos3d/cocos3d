/*
 * CC3MeshParticles.m
 *
 * cocos3d 2.0.0
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
 * See header file CC3MeshParticles.h for full API documentation.
 */

#import "CC3MeshParticles.h"
#import "CC3Camera.h"
#import "CC3IOSExtensions.h"
#import "CGPointExtension.h"


#pragma mark -
#pragma mark Protected template methods

@interface CC3MeshNode (TemplateMethods)
@property(nonatomic, readonly) Class mutableRotatorClass;
@property(nonatomic, readonly) Class directionalRotatorClass;
@property(nonatomic, readonly) Class targettingRotatorClass;
@property(nonatomic, assign) BOOL shouldReverseForwardDirection;
@end

@interface CC3ParticleEmitter (TemplateMethods)
-(void) addDirtyVertexRange: (NSRange) aRange;
-(void) addDirtyVertexIndexRange: (NSRange) aRange;
-(void) removeParticle: (id<CC3ParticleProtocol>) aParticle atIndex: (NSUInteger) anIndex;
@end

@interface CC3CommonVertexArrayParticleEmitter (TemplateMethods)
-(void) updateParticleMeshWithVisitor: (CC3NodeUpdatingVisitor*) visitor;
@end

@interface CC3MeshParticleEmitter (TemplateMethods)
-(void) copyTemplateContentToParticle: (id<CC3MeshParticleProtocol>) aParticle;
-(BOOL) shouldTransformParticles: (CC3NodeTransformingVisitor*) visitor;
-(void) transformParticles;
@end

@interface CC3MeshParticle (TemplateMethods)
@property(nonatomic, readonly) CC3VertexArrayMesh* mesh;
@property(nonatomic, readonly) BOOL shouldTrackTarget;
@property(nonatomic, readonly) CC3MutableRotator* mutableRotator;
@property(nonatomic, readonly) CC3DirectionalRotator* directionalRotator;
@property(nonatomic, readonly) BOOL doesUseTranslationOnly;
-(void) translateVertices;
-(void) fullyTransformVertices;
-(void) applyLocalTransformsTo: (CC3Matrix4x3*) mtx;
-(void) prepareForTransform: (CC3Matrix4x3*) mtx;
-(void) applyTranslationTo: (CC3Matrix4x3*) mtx;
-(void) applyRotationTo: (CC3Matrix4x3*) mtx;
-(void) applyScalingTo: (CC3Matrix4x3*) mtx;
@end


#pragma mark -
#pragma mark CC3MeshParticleEmitter

@implementation CC3MeshParticleEmitter

@synthesize isParticleTransformDirty, shouldTransformUnseenParticles;

-(void) dealloc {
	[particleTemplateMesh release];
	[super dealloc];
}

-(Protocol*) requiredParticleProtocol { return @protocol(CC3MeshParticleProtocol); }

-(CC3VertexArrayMesh*) particleTemplateMesh { return particleTemplateMesh; }

-(void) setParticleTemplateMesh: (CC3VertexArrayMesh*) aVtxArrayMesh {
	if (aVtxArrayMesh == particleTemplateMesh) return;
	
	[particleTemplateMesh release];
	particleTemplateMesh = [aVtxArrayMesh retain];

	// Add vertex content if not already set, and align the drawing mode
	if (self.vertexContentTypes == kCC3VertexContentNone) {
		self.vertexContentTypes = aVtxArrayMesh.vertexContentTypes;
	}
	self.drawingMode = aVtxArrayMesh.drawingMode;
	LogTrace(@"Particle template mesh of %@ set to %@ drawing %@ with %i vertices and %i vertex indices",
			 self, aVtxArrayMesh, NSStringFromGLEnum(self.drawingMode),
			 aVtxArrayMesh.vertexCount, aVtxArrayMesh.vertexIndexCount);
}

-(CC3MeshNode*) particleTemplate { return nil; }

-(void) setParticleTemplate: (CC3MeshNode*) aParticleTemplate {
	NSAssert2([aParticleTemplate.mesh isKindOfClass: [CC3VertexArrayMesh class]],
			  @"%@ is not a CC3VertexArrayMesh. %@ requires that the mesh used for the particle template be a CC3VertexArrayMesh",
			  aParticleTemplate.mesh, self);
	self.particleTemplateMesh = (CC3VertexArrayMesh*)aParticleTemplate.mesh;
	self.material = [aParticleTemplate.material autoreleasedCopy];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.particleClass = [CC3MeshParticle class];
		particleTemplateMesh = nil;
		isParticleTransformDirty = NO;
		shouldTransformUnseenParticles = YES;
	}
	return self;
}

-(void) populateFrom: (CC3MeshParticleEmitter*) another {
	[super populateFrom: another];
	
	self.particleTemplateMesh = another.particleTemplateMesh;
	isParticleTransformDirty = another.isParticleTransformDirty;
	shouldTransformUnseenParticles = another.shouldTransformUnseenParticles;
}


#pragma mark Vertex management

-(void) copyTemplateContentToParticle: (id<CC3MeshParticleProtocol>) aParticle {
	
	// Get the particle template mesh
	CC3VertexArrayMesh* templateMesh = aParticle.templateMesh;
	
	// Copy vertex content
	GLuint vtxCount = aParticle.vertexCount;
	GLuint firstVtx = aParticle.firstVertexOffset;
	[self.mesh copyVertices: vtxCount from: 0 inMesh: templateMesh to: firstVtx];

	// If this mesh does not have vertex indices, we're done
	if ( !self.mesh.hasVertexIndices ) return;

	// Copy vertex indices, taking into consideration the staring index of the vertex content in this mesh.
	GLuint vtxIdxCount = aParticle.vertexIndexCount;
	GLuint firstVtxIdx = aParticle.firstVertexIndexOffset;
	[self.mesh copyVertexIndices: vtxIdxCount from: 0 inMesh: templateMesh to: firstVtxIdx offsettingBy: firstVtx];
	[self addDirtyVertexIndexRange: NSMakeRange(firstVtxIdx, vtxIdxCount)];
}


#pragma mark Emitting particles

-(id<CC3MeshParticleProtocol>) emitParticle { return (id<CC3MeshParticleProtocol>)[super emitParticle]; }

-(BOOL) emitParticle: (id<CC3MeshParticleProtocol>) aParticle {
	if ( !aParticle.templateMesh ) [self assignTemplateMeshToParticle: aParticle];
	return [super emitParticle: aParticle];
}

-(id<CC3MeshParticleProtocol>) acquireParticle {
	id<CC3MeshParticleProtocol> aParticle = (id<CC3MeshParticleProtocol>)[super acquireParticle];
	[self assignTemplateMeshToParticle: aParticle];
	return aParticle;
}

-(id<CC3MeshParticleProtocol>) makeParticle {
	id<CC3MeshParticleProtocol> aParticle = (id<CC3MeshParticleProtocol>)[super makeParticle];
	[self assignTemplateMeshToParticle: aParticle];
	return aParticle;
}

-(void) assignTemplateMeshToParticle: (id<CC3MeshParticleProtocol>) aParticle {
	NSAssert1(particleTemplateMesh, @"The particleTemplateMesh property of %@ must be set before particles can be emitted.", self);
	aParticle.templateMesh = particleTemplateMesh;
}

-(void) initializeParticle: (id<CC3MeshParticleProtocol>) aParticle {
	// The vertex offsets depend on particleCount, which has not yet been incremented.
	aParticle.firstVertexOffset = self.vertexCount;
	aParticle.firstVertexIndexOffset = self.vertexIndexCount;
	[self copyTemplateContentToParticle: aParticle];
}

/** If the particles need to be transformed, do so before updating the particle mesh. */
-(void) updateParticleMeshWithVisitor: (CC3NodeUpdatingVisitor*) visitor {
	if ( [self shouldTransformParticles: visitor] ) [self transformParticles];
	[super updateParticleMeshWithVisitor: (CC3NodeUpdatingVisitor*) visitor];
}


#pragma mark Accessing particles

-(id<CC3MeshParticleProtocol>) meshParticleAt: (NSUInteger) aParticleIndex {
	return (id<CC3MeshParticleProtocol>)[self particleAt: aParticleIndex];
}

/**
 * Removes the current particle from the active particles, but possibly keep it cached for future use.
 *
 * If the particle being removed has the same number of vertices and vertex indices as the last living
 * particle, swap the particle being removed with that last living particle. To do this, swap the
 * particles in the particles collection, and copy the vertex content and indices from the last living
 * particle into the slot of the particle being removed.
 *
 * If the particle being removed does not have the same number of vertices and vertex indices as the
 * last living particle, we can't swap them. The particle must be removed, and the all of the vertex
 * content for all following particles must be copied down to fill in the gap left by the removed
 * particle. The vertex indices must also be copied down to fill in the gap and, in addition, must
 * be adjusted to point to the newly moved vertex content.
 */
-(void) removeParticle: (id<CC3MeshParticleProtocol>) aParticle atIndex: (NSUInteger) anIndex {
	[super removeParticle: aParticle atIndex: anIndex];		// Decrements particleCount and vertexCount
	
	NSUInteger partCount = self.particleCount;	// Get the decremented particleCount
	
	// Particle being removed
	id<CC3MeshParticleProtocol> deadParticle = aParticle;
	GLuint deadFirstVtx = deadParticle.firstVertexOffset;
	GLuint deadVtxCount = deadParticle.vertexCount;
	GLuint deadFirstVtxIdx = deadParticle.firstVertexIndexOffset;
	GLuint deadVtxIdxCount = deadParticle.vertexIndexCount;
	
	// Last living particle
	id<CC3MeshParticleProtocol> lastParticle = [self meshParticleAt: partCount];
	GLuint lastFirstVtx = lastParticle.firstVertexOffset;
	GLuint lastVtxCount = lastParticle.vertexCount;
	GLuint lastFirstVtxIdx = lastParticle.firstVertexIndexOffset;
	GLuint lastVtxIdxCount = lastParticle.vertexIndexCount;

	// Remove the template mesh from the particle, even if the particle will be reused.
	// This gives the emitter a chance to use a different template mesh when it reuses the particle.
	// Clear it before removing the particle, because the particle may disappear when removed from
	// this emitter. First, take note of whether the last particle has the same template mesh as the
	// last particle. This knowledge is used below when copying vertex indices.
	BOOL isSameTemplateMesh = (deadParticle.templateMesh == lastParticle.templateMesh);
	deadParticle.templateMesh = nil;
	
	if (anIndex >= partCount) {
		LogTrace(@"Removing %@ at %i by by doing nothing, since particle count is now %i.", aParticle, anIndex, partCount);
	} else if (deadVtxCount == lastVtxCount && deadVtxIdxCount == lastVtxIdxCount) {
		// If the two particles have the same number of vertices and vertex indices, we can swap them.
		LogTrace(@"Removing %@ at %i by swapping particles of identical size.", aParticle, anIndex);
		
		// Move the last living particle into the slot that is being vacated
		[particles exchangeObjectAtIndex: anIndex withObjectAtIndex: partCount];
		
		// Swap the vertex offsets of the two particles
		deadParticle.firstVertexOffset = lastFirstVtx;
		deadParticle.firstVertexIndexOffset = lastFirstVtxIdx;
		lastParticle.firstVertexOffset = deadFirstVtx;
		lastParticle.firstVertexIndexOffset = deadFirstVtxIdx;
		
		// Update the underlying mesh vertex content and mark the updated vertex dirty
		[self.mesh copyVertices: deadVtxCount from: lastFirstVtx to: deadFirstVtx];
		[self addDirtyVertexRange: deadParticle.vertexRange];

		// If the template meshes are the same, we don't need to update the vertex indices.
		if ( !isSameTemplateMesh ) {
			[self.mesh.vertexIndices copyVertices: lastVtxIdxCount
											 from: lastFirstVtxIdx
											   to: deadFirstVtxIdx
									 offsettingBy: (deadFirstVtx - lastFirstVtx)];
			[self addDirtyVertexIndexRange: deadParticle.vertexIndexRange];
		}
		
	} else {
		LogTrace(@"Removing %@ at %i by removing particle with %i vertices from collection.", aParticle, anIndex, deadVtxCount);
		
		// Move the vertices in the mesh to fill the gap created by the removed particle
		GLuint srcVtxStart = (deadFirstVtx + deadVtxCount);	// Start after removed particle
		GLuint srcVtxEnd = (lastFirstVtx + lastVtxCount);		// End after last living particle
		GLuint vtxCount = srcVtxEnd - srcVtxStart;
		GLuint dstVtxStart = deadFirstVtx;
		[self.mesh copyVertices: vtxCount from: srcVtxStart to: dstVtxStart];
		[self addDirtyVertexRange: NSMakeRange(dstVtxStart, vtxCount)];
		
		// If the mesh has vertex indices, move them to fill the gap created by the removed particle
		// and adjust their values to fill the gap created in the vertex content.
		GLuint srcVtxIdxStart = (deadFirstVtxIdx + deadVtxIdxCount);	// Start after removed particle
		GLuint srcVtxIdxEnd = (lastFirstVtxIdx + lastVtxIdxCount);	// End after last living particle
		GLuint vtxIdxCount = srcVtxIdxEnd - srcVtxIdxStart;
		GLuint dstVtxIdxStart = deadFirstVtxIdx;
		[self.mesh copyVertexIndices: vtxIdxCount from: srcVtxIdxStart to: dstVtxIdxStart offsettingBy: -deadVtxCount];
		[self addDirtyVertexIndexRange: NSMakeRange(dstVtxIdxStart, vtxIdxCount)];
		
		// Remove the particle from particles collection,
		// Do this last in case the particle is only being held by this collection.
		[particles removeObjectAtIndex: anIndex];
		
		// Adjust the firstVertexOffset and firstVertexIndexOffset properties of each remaining
		// particle to fill in the gap created by removing the particle from the mesh arrays.
		// Do this after the dead particle has been removed from the collection.
		for (NSUInteger partIdx = anIndex; partIdx < partCount; partIdx++) {
			id<CC3MeshParticleProtocol> mp = [self meshParticleAt: partIdx];
			mp.firstVertexOffset -= deadVtxCount;
			mp.firstVertexIndexOffset -= deadVtxIdxCount;
		}
	}
}

/*
-(void) removeParticle: (id<CC3MeshParticleProtocol>) aParticle atIndex: (NSUInteger) anIndex {
	[super removeParticle: aParticle atIndex: anIndex];		// Decrements particleCount and vertexCount
	
	NSUInteger partCount = self.particleCount;	// Get the decremented particleCount
	
	// Particle being removed
	id<CC3MeshParticleProtocol> deadParticle = aParticle;
	GLuint deadFirstVtx = deadParticle.firstVertexOffset;
	GLuint deadVtxCount = deadParticle.vertexCount;
	GLuint deadFirstVtxIdx = deadParticle.firstVertexIndexOffset;
	GLuint deadVtxIdxCount = deadParticle.vertexIndexCount;
	
	// Last living particle
	id<CC3MeshParticleProtocol> lastParticle = [self meshParticleAt: partCount];
	GLuint lastFirstVtx = lastParticle.firstVertexOffset;
	GLuint lastVtxCount = lastParticle.vertexCount;
	GLuint lastFirstVtxIdx = lastParticle.firstVertexIndexOffset;
	GLuint lastVtxIdxCount = lastParticle.vertexIndexCount;
	
	if (anIndex >= partCount) {
		LogTrace(@"Removing %@ at %i by by doing nothing, since particle count is now %i.", aParticle, anIndex, partCount);
	} else if (deadVtxCount == lastVtxCount && deadVtxIdxCount == lastVtxIdxCount) {
		// If the two particles have the same number of vertices and vertex indices, we can swap them.
		LogTrace(@"Removing %@ at %i by swapping particles of identical size.", aParticle, anIndex);
		
		// Move the last living particle into the slot that is being vacated
		[particles exchangeObjectAtIndex: anIndex withObjectAtIndex: partCount];
		
		// Swap the vertex offsets of the two particles
		deadParticle.firstVertexOffset = lastFirstVtx;
		deadParticle.firstVertexIndexOffset = lastFirstVtxIdx;
		lastParticle.firstVertexOffset = deadFirstVtx;
		lastParticle.firstVertexIndexOffset = deadFirstVtxIdx;
		
		// Update the underlying mesh vertex content and mark the updated vertex dirty
		[self.mesh copyVertices: deadVtxCount from: lastFirstVtx to: deadFirstVtx];
		[self addDirtyVertexRange: deadParticle.vertexRange];
		
		// If the template meshes are different, also update the underlying mesh indices and
		// mark the updated indices dirty. Don't need this step if both particles use the same
		// template mesh, and therefore the indices for each particle are identical.
		if (deadParticle.templateMesh != lastParticle.templateMesh) {
			[self.mesh.vertexIndices copyVertices: lastVtxIdxCount
											 from: lastFirstVtxIdx
											   to: deadFirstVtxIdx
									 offsettingBy: (deadFirstVtx - lastFirstVtx)];
			[self addDirtyVertexIndexRange: deadParticle.vertexIndexRange];
		}
		
	} else {
		LogTrace(@"Removing %@ at %i by removing particle with %i vertices from collection.", aParticle, anIndex, deadVtxCount);
		
		// Move the vertices in the mesh to fill the gap created by the removed particle
		GLuint srcVtxStart = (deadFirstVtx + deadVtxCount);	// Start after removed particle
		GLuint srcVtxEnd = (lastFirstVtx + lastVtxCount);		// End after last living particle
		GLuint vtxCount = srcVtxEnd - srcVtxStart;
		GLuint dstVtxStart = deadFirstVtx;
		[self.mesh copyVertices: vtxCount from: srcVtxStart to: dstVtxStart];
		[self addDirtyVertexRange: NSMakeRange(dstVtxStart, vtxCount)];
		
		// If the mesh has vertex indices, move them to fill the gap created by the removed particle
		// and adjust their values to fill the gap created in the vertex content.
		GLuint srcVtxIdxStart = (deadFirstVtxIdx + deadVtxIdxCount);	// Start after removed particle
		GLuint srcVtxIdxEnd = (lastFirstVtxIdx + lastVtxIdxCount);	// End after last living particle
		GLuint vtxIdxCount = srcVtxIdxEnd - srcVtxIdxStart;
		GLuint dstVtxIdxStart = deadFirstVtxIdx;
		[self.mesh copyVertexIndices: vtxIdxCount from: srcVtxIdxStart to: dstVtxIdxStart offsettingBy: -deadVtxCount];
		[self addDirtyVertexIndexRange: NSMakeRange(dstVtxIdxStart, vtxIdxCount)];
		
		// Remove the particle from particles collection,
		// Do this last in case the particle is only being held by this collection.
		[particles removeObjectAtIndex: anIndex];
		
		// Adjust the firstVertexOffset and firstVertexIndexOffset properties of each remaining
		// particle to fill in the gap created by removing the particle from the mesh arrays.
		// Do this after the dead particle has been removed from the collection.
		for (NSUInteger partIdx = anIndex; partIdx < partCount; partIdx++) {
			id<CC3MeshParticleProtocol> mp = [self meshParticleAt: partIdx];
			mp.firstVertexOffset -= deadVtxCount;
			mp.firstVertexIndexOffset -= deadVtxIdxCount;
		}
	}
	
	// Remove the template mesh from the particle, even if the particle will be reused.
	// This gives the emitter a chance to use a different template mesh when it reuses the particle.
	// Do this after moving the vertices around above, since it can depend on the template mesh.
	aParticle.templateMesh = nil;
}
*/

#pragma mark Transformations

/** Overridden so that the transform is considered dirty if any of the particles need to be transformed. */
-(BOOL) isTransformDirty { return super.isTransformDirty || self.isParticleTransformDirty; }

-(void) markParticleTransformDirty { isParticleTransformDirty = YES; }

/**
 * Template method that returns whether the particles should be tranformed.
 *
 * Particles are only transformed if they are dirty and either visible or touchable.
 * If the bounding volume is fixed, and the emitter is not in the camera's field of view,
 * then the particles are not transformed.
 * 
 * Subclasses may override this methods to change how this decision is made.
 */
-(BOOL) shouldTransformParticles: (CC3NodeTransformingVisitor*) visitor {
	if ( !self.isParticleTransformDirty ) return NO;
	if ( !(self.visible || self.isTouchable) ) return NO;
	if ((self.shouldUseFixedBoundingVolume || !self.shouldTransformUnseenParticles) &&
		![self doesIntersectFrustum: visitor.camera.frustum]) return NO;
	return YES;
}

-(void) transformParticles {
	NSUInteger partCount = self.particleCount;
	LogTrace(@"%@ transforming %i particles", self, particleCount);

	for (NSUInteger partIdx = 0; partIdx < partCount; partIdx++) {
		id<CC3MeshParticleProtocol> mp = [particles objectAtIndex: partIdx];
		[mp transformVertices];
	}
	isParticleTransformDirty = NO;
}

@end


#pragma mark -
#pragma mark CC3MeshParticle

@implementation CC3MeshParticle

@synthesize isTransformDirty=_isTransformDirty, rotator, templateMesh, isColorDirty=_isColorDirty;

-(void) dealloc {
	[rotator release];
	[templateMesh release];
	[super dealloc];
}

-(CC3MeshParticleEmitter*) emitter { return (CC3MeshParticleEmitter*)emitter; }

-(void) setEmitter: (CC3MeshParticleEmitter*) anEmitter {
	NSAssert1([anEmitter isKindOfClass: [CC3MeshParticleEmitter class]], @"%@ may only be emitted by a CC3MeshParticleEmitter.", self);
	super.emitter = anEmitter;
}

-(CC3VertexArrayMesh*) mesh { return self.emitter.mesh; }

-(BOOL) isAlive { return _isAlive; }

-(void) setIsAlive: (BOOL) alive { _isAlive = alive; }

-(GLuint) firstVertexOffset { return firstVertexOffset; }

-(void) setFirstVertexOffset: (GLuint) vtxOffset { firstVertexOffset = vtxOffset; }

-(GLuint) vertexCount { return templateMesh ? templateMesh.vertexCount : 0; }

-(NSRange) vertexRange { return NSMakeRange(self.firstVertexOffset, self.vertexCount); }

-(GLuint) firstVertexIndexOffset { return firstVertexIndexOffset; }

-(void) setFirstVertexIndexOffset: (GLuint) vtxIdxOffset { firstVertexIndexOffset = vtxIdxOffset; }

-(GLuint) vertexIndexCount {
	return self.hasVertexIndices ? templateMesh.vertexIndexCount : self.vertexCount;
}

-(NSRange) vertexIndexRange { return NSMakeRange(self.firstVertexIndexOffset, self.vertexIndexCount); }

-(BOOL) hasVertexIndices { return (templateMesh && templateMesh.hasVertexIndices); }


#pragma mark Transformation properties

-(void) markTransformDirty {
	_isTransformDirty = YES;
	[self.emitter markParticleTransformDirty];
}

-(CC3Vector) location { return location; }

-(void) setLocation: (CC3Vector) aLocation {
	location = aLocation;
	[self markTransformDirty];
}

-(void) translateBy: (CC3Vector) aVector { self.location = CC3VectorAdd(self.location, aVector); }

-(CC3Vector) rotation { return rotator.rotation; }

-(void) setRotation: (CC3Vector) aRotation {
	// This test for change avoids unnecessarily creating and transforming a mutable rotator
	if ( !self.shouldTrackTarget && !CC3VectorsAreEqual(aRotation, rotator.rotation) ) {
		self.mutableRotator.rotation = aRotation;
		[self markTransformDirty];
	}
}

-(void) rotateBy: (CC3Vector) aRotation {
	if ( !self.shouldTrackTarget ) {
		[self.mutableRotator rotateBy: aRotation];
		[self markTransformDirty];
	}
}

-(CC3Quaternion) quaternion { return rotator.quaternion; }

-(void) setQuaternion: (CC3Quaternion) aQuaternion {
	// This test for change avoids unnecessarily creating and transforming a mutable rotator
	if ( !self.shouldTrackTarget && !CC3QuaternionsAreEqual(aQuaternion, rotator.quaternion) ) {
		self.mutableRotator.quaternion = aQuaternion;
		[self markTransformDirty];
	}
}

-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion {
	if ( !self.shouldTrackTarget ) {
		[self.mutableRotator rotateByQuaternion: aQuaternion];
		[self markTransformDirty];
	}
}

-(CC3Vector) rotationAxis { return rotator.rotationAxis; }

-(void) setRotationAxis: (CC3Vector) aDirection {
	// This test for change avoids unnecessarily creating and transforming a mutable rotator
	if ( !self.shouldTrackTarget && !CC3VectorsAreEqual(aDirection, rotator.rotationAxis) ) {
		self.mutableRotator.rotationAxis = aDirection;
		[self markTransformDirty];
	}
}

-(GLfloat) rotationAngle { return rotator.rotationAngle; }

-(void) setRotationAngle: (GLfloat) anAngle {
	if ( !self.shouldTrackTarget && (anAngle != rotator.rotationAngle) ) {
		self.mutableRotator.rotationAngle = anAngle;
		[self markTransformDirty];
	}
}

-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	if (!self.shouldTrackTarget) {
		[self.mutableRotator rotateByAngle: anAngle aroundAxis: anAxis];
		[self markTransformDirty];
	}
}

-(CC3Vector) forwardDirection { return self.directionalRotator.forwardDirection; }

-(void) setForwardDirection: (CC3Vector) aDirection {
	if (!self.shouldTrackTarget) {
		self.directionalRotator.forwardDirection = aDirection;
		[self markTransformDirty];
	}
}

-(CC3Vector) upDirection { return self.directionalRotator.upDirection; }

-(CC3Vector) referenceUpDirection { return self.directionalRotator.referenceUpDirection; }

-(void) setReferenceUpDirection: (CC3Vector) aDirection {
	self.directionalRotator.referenceUpDirection = aDirection;
	[self markTransformDirty];
}

-(CC3Vector) rightDirection { return self.directionalRotator.rightDirection; }

-(BOOL) shouldTrackTarget { return rotator.shouldTrackTarget; }


#pragma mark Rotator

/**
 * Returns the rotator property, cast as a CC3MutableRotator.
 *
 * If the rotator is not already a CC3MutableRotator, a new CC3MutableRotator
 * is created and its state is copied from the current rotator.
 *
 * This design allows particles that do not require rotation to use the empty and smaller
 * CC3Rotator instance, but allows an automatic upgrade to a mutable rotator
 * when the node needs to make changes to the rotational properties.
 *
 * This property should only be accessed if the intention is to swap the existing
 * rotator with a directional rotator.
 */
-(CC3MutableRotator*) mutableRotator {
	if ( !rotator.isMutable ) {
		CC3MutableRotator* mRotator = (CC3MutableRotator*)[[emitter mutableRotatorClass] rotator];
		[mRotator populateFrom: rotator];
		LogTrace(@"%@ swapping %@ for existing %@", self, mRotator, rotator);
		self.rotator = mRotator;
	}
	return (CC3MutableRotator*)rotator;
}

/**
 * Returns the rotator property, cast as a CC3DirectionalRotator.
 *
 * If the rotator is not already a CC3DirectionalRotator, a new CC3DirectionalRotator
 * is created and its state is copied from the current rotator.
 *
 * This design allows most particles to use a simpler and smaller CC3Rotator instance,
 * but allow an automatic upgrade to a larger and more complex directional rotator
 * when the node needs to make use of pointing or tracking functionality.
 *
 * This implementation returns a reversing directional rotator class that orients
 * the positive-Z axis of the node along the forwardDirection.
 *
 * This property should only be accessed if the intention is to swap the existing
 * rotator with a directional rotator.
 */
-(CC3DirectionalRotator*) directionalRotator {
	if ( !rotator.isDirectional ) {
		CC3DirectionalRotator* dRotator = (CC3DirectionalRotator*)[[emitter directionalRotatorClass] rotator];
		[dRotator populateFrom: rotator];
		dRotator.shouldReverseForwardDirection = emitter.shouldReverseForwardDirection;
		LogTrace(@"%@ swapping %@ for existing %@", self, dRotator, rotator);
		self.rotator = dRotator;
	}
	return (CC3DirectionalRotator*)rotator;
}

/**
 * Returns the rotator property, cast as a CC3TargettingRotator.
 *
 * If the rotator is not already a CC3TargettingRotator, a new CC3TargettingRotator
 * is created and its state is copied from the current rotator.
 *
 * This design allows most particles to use a simpler and smaller CC3Rotator instance,
 * but allow an automatic upgrade to a larger and more complex directional rotator
 * when the node needs to make use of pointing or tracking functionality.
 *
 * This implementation returns a reversing directional rotator class that orients
 * the positive-Z axis of the node along the forwardDirection.
 *
 * This property should only be accessed if the intention is to swap the existing
 * rotator with a directional rotator.
 */
-(CC3TargettingRotator*) targettingRotator {
	if ( !rotator.isTargettable ) {
		CC3TargettingRotator* tRotator = (CC3TargettingRotator*)[[emitter targettingRotatorClass] rotator];
		[tRotator populateFrom: rotator];
		tRotator.shouldReverseForwardDirection = emitter.shouldReverseForwardDirection;
		LogTrace(@"%@ swapping %@ for existing %@", self, tRotator, rotator);
		self.rotator = tRotator;
	}
	return (CC3TargettingRotator*)rotator;
}


#pragma mark Color

-(ccColor4F) color4F {
	return (self.hasColor && self.vertexCount > 0) ? [self vertexColor4FAt: 0] : [super color4F];
}

-(void) setColor4F: (ccColor4F) aColor {
	if (self.hasColor && self.vertexCount > 0) {
		[self setVertexColor4F: aColor at: 0];
		[self markColorDirty];
	}
}

-(ccColor4B) color4B {
	return (self.hasColor && self.vertexCount > 0) ? [self vertexColor4BAt: 0] : [super color4B];
}

-(void) setColor4B: (ccColor4B) aColor {
	if (self.hasColor && self.vertexCount > 0) {
		[self setVertexColor4B: aColor at: 0];
		[self markColorDirty];
	}
}


#pragma mark Texture support

-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit {

	// The texture coordinates of the template mesh, and its effective texture rectangle.
	CC3VertexTextureCoordinates* tmplVtxTexCoords = [templateMesh textureCoordinatesForTextureUnit: texUnit];
	CGRect tmplTexRect = tmplVtxTexCoords.effectiveTextureRectangle;

	// Determine the origin of the texture rectangle of this particle, in UV coordinates.
	// This origin is relative to the template texture rectangle, so offset it and scale it
	// by the origin and size of the template texture rectangle.
	CGPoint trOrg;
	trOrg.x = tmplTexRect.origin.x + (aRect.origin.x * tmplTexRect.size.width);
	trOrg.y = tmplTexRect.origin.y + (aRect.origin.y * tmplTexRect.size.height);
	
	// For each vertex, take the offset of the tex coord UV point, relative to the template
	// texture rectangle, scale it by the particle texture rectangle, and offset it by the
	// origin of the particle texture rectangle.
	GLuint vtxCount = self.vertexCount;
	for (GLuint vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
		ccTex2F tmplVTC = [tmplVtxTexCoords texCoord2FAt: vtxIdx];
		ccTex2F adjVTC;
		adjVTC.u = trOrg.x + ((tmplVTC.u - tmplTexRect.origin.x) * aRect.size.width);
		adjVTC.v = trOrg.y + ((tmplVTC.v - tmplTexRect.origin.y) * aRect.size.height);
		[self setVertexTexCoord2F: adjVTC forTextureUnit: texUnit at: vtxIdx];
	}
}

-(CGRect) textureRectangle { return CGRectNull; }

-(void) setTextureRectangle: (CGRect) aRect {
	GLuint tcCount = self.mesh.textureCoordinatesArrayCount;
	for (GLuint tcIdx = 0; tcIdx < tcCount; tcIdx++) {
		[self setTextureRectangle: aRect forTextureUnit: tcIdx];
	}
}


#pragma mark Transformations

/** Returns whether the mesh vertices can be transformed using only translation. */
-(BOOL) doesUseTranslationOnly { return !rotator.isMutable; }

// If no rotation or scale has been applied, perform an optimized translation operation
// on the vertices, instead of a full tranformation.
-(void) transformVertices {
	if (_isTransformDirty) {
		if (self.doesUseTranslationOnly) {
			[self translateVertices];
		} else {
			[self fullyTransformVertices];
		}
		_isTransformDirty = NO;
	}

	[self transformVertexColors];
}

-(void) translateVertices {
	LogTrace(@"%@ translating vertices", self);
	GLuint vtxCount = self.vertexCount;
	for (GLuint vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
		CC3Vector vtxLoc = [templateMesh vertexLocationAt: vtxIdx];
		[self setVertexLocation: CC3VectorAdd(vtxLoc, location) at: vtxIdx];
	}
}

/**
 * Transform the vertices using translation, rotation and scaling, by allocating a transform matrix
 * and transforming it in place using the location, rotator, and scale properties of this particle.
 */
-(void) fullyTransformVertices {
	LogTrace(@"%@ transforming vertices", self);
	BOOL hasNorms = self.hasVertexNormals;
	GLuint vtxCount = self.vertexCount;
	
	// Populate a transform matrix from the transform properties of this particle.
	CC3Matrix4x3 tfmMtx;
	[self applyLocalTransformsTo: &tfmMtx];
	
	for (GLuint vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
		// Transform the vertex location using the full transform matrix
		CC3Vector4 vtxLoc = [templateMesh vertexHomogeneousLocationAt: vtxIdx];
		vtxLoc = CC3Matrix4x3TransformCC3Vector4(&tfmMtx, vtxLoc);
		[self setVertexHomogeneousLocation: vtxLoc at: vtxIdx];
		
		// Transform the vertex normal using only the rotational transform to avoid scaling the normal.
		if (hasNorms) {
			CC3Vector vtxNorm = [templateMesh vertexNormalAt: vtxIdx];
			vtxNorm = [self.rotator transformDirection: vtxNorm];
			[self setVertexNormal: vtxNorm at: vtxIdx];
		}
	}
}

/** Apply the location, rotation and scaling transforms to the specified matrix data. */
-(void) applyLocalTransformsTo: (CC3Matrix4x3*) mtx {
	[self prepareForTransform: mtx];
	[self applyTranslationTo: mtx];
	[self applyRotationTo: mtx];
}

/**
 * Template method that prepares the specified matrix to be transformed by the transform
 * properties of this particle. This implementation starts the matrix as an identity matrix.
 */
-(void) prepareForTransform: (CC3Matrix4x3*) mtx {
	CC3Matrix4x3PopulateIdentity(mtx);
}

/** Template method that applies the local location property to the specified matrix. */
-(void) applyTranslationTo: (CC3Matrix4x3*) mtx {
	CC3Matrix4x3TranslateBy(mtx, self.location);
	LogTrace(@"%@ translated to %@", self, NSStringFromCC3Vector(self.location));
}

/** Template method that applies the rotation in the rotator to the specified transform matrix. */
-(void) applyRotationTo: (CC3Matrix4x3*) mtx {
	[rotator.rotationMatrix multiplyIntoCC3Matrix4x3: mtx];
	LogTrace(@"%@ rotated to %@", self, NSStringFromCC3Vector(rotator.rotation));
}

-(void) markColorDirty { _isColorDirty = YES; }

-(void) transformVertexColors {
	if ( !_isColorDirty ) return;
	
	ccColor4F vtxColF;
	ccColor4B vtxColB;
	GLuint vCnt = self.vertexCount;
	switch (emitter.vertexColorType) {
		case GL_FLOAT:
			vtxColF = self.color4F;
			for (GLuint vIdx = 0; vIdx < vCnt; vIdx++) [self setVertexColor4F: vtxColF at: vIdx];
			break;
		case GL_FIXED:
		case GL_UNSIGNED_BYTE:
			vtxColB = self.color4B;
			for (GLuint vIdx = 0; vIdx < vCnt; vIdx++) [self setVertexColor4B: vtxColB at: vIdx];
			break;
		default:
			break;
	}
	
	_isColorDirty = NO;
}


#pragma mark Accessing vertex data

-(CC3Vector) vertexLocationAt: (GLuint) vtxIndex {
	return [self.emitter vertexLocationAt: (firstVertexOffset + vtxIndex)];
}

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) vtxIndex {
	[self.emitter setVertexLocation: aLocation at: (firstVertexOffset + vtxIndex)];
}

-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) vtxIndex {
	return [self.emitter vertexHomogeneousLocationAt: (firstVertexOffset + vtxIndex)];
}

-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) vtxIndex {
	[self.emitter setVertexHomogeneousLocation: aLocation at: (firstVertexOffset + vtxIndex)];
}

-(CC3Vector) vertexNormalAt: (GLuint) vtxIndex {
	return [self.emitter vertexNormalAt: (firstVertexOffset + vtxIndex)];
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) vtxIndex {
	[self.emitter setVertexNormal: aNormal at: (firstVertexOffset + vtxIndex)];
}

-(ccColor4F) vertexColor4FAt: (GLuint) vtxIndex {
	return [self.emitter vertexColor4FAt: (firstVertexOffset + vtxIndex)];
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) vtxIndex {
	[self.emitter setVertexColor4F: aColor at: (firstVertexOffset + vtxIndex)];
}

-(ccColor4B) vertexColor4BAt: (GLuint) vtxIndex {
	return [self.emitter vertexColor4BAt: (firstVertexOffset + vtxIndex)];
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) vtxIndex {
	[self.emitter setVertexColor4B: aColor at: (firstVertexOffset + vtxIndex)];
}

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) vtxIndex {
	return [self.emitter vertexTexCoord2FForTextureUnit: texUnit at: (firstVertexOffset + vtxIndex)];
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) vtxIndex {
	[self.emitter setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: (firstVertexOffset + vtxIndex)];
}

-(ccTex2F) vertexTexCoord2FAt: (GLuint) vtxIndex {
	return [self vertexTexCoord2FForTextureUnit: 0 at: vtxIndex];
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) vtxIndex {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: 0 at: vtxIndex];
}

-(GLuint) vertexIndexAt: (GLuint) vtxIndex {
	return [self.emitter vertexIndexAt: (firstVertexIndexOffset + vtxIndex)] - firstVertexOffset;
}

-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) vtxIndex {
	[self.emitter setVertexIndex: (vertexIndex + firstVertexOffset)
							  at: (firstVertexIndexOffset + vtxIndex)];
}

-(BOOL) hasVertexLocations { return self.mesh.hasVertexLocations; }

-(BOOL) hasVertexNormals { return self.mesh.hasVertexNormals; }

-(BOOL) hasVertexColors { return self.mesh.hasVertexColors; }

-(BOOL) hasVertexTextureCoordinates { return self.mesh.hasVertexTextureCoordinates; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		self.rotator = [CC3Rotator rotator];
		templateMesh = nil;
		location = kCC3VectorZero;
		firstVertexOffset = 0;
		firstVertexIndexOffset = 0;
		_isTransformDirty = YES;		// Force transform on first update
		_isColorDirty = YES;			// Force color update
	}
	return self;
}

-(void) populateFrom: (CC3MeshParticle*) another {
	[super populateFrom: another];
	self.rotator = [another.rotator autoreleasedCopy];
	templateMesh = another.templateMesh;	// not retained
	location = another.location;
	firstVertexOffset = another.firstVertexOffset;
	firstVertexIndexOffset = another.firstVertexIndexOffset;
	_isTransformDirty = another.isTransformDirty;
	_isColorDirty = another.isColorDirty;
}

@end


#pragma mark -
#pragma mark CC3ScalableMeshParticle

@implementation CC3ScalableMeshParticle


#pragma mark Transformation properties

-(CC3Vector) scale { return scale; }

-(void) setScale: (CC3Vector) aScale {
	scale = aScale;
	[self markTransformDirty];
}

-(GLfloat) uniformScale {
	return (self.isUniformlyScaledLocally)
					? scale.x 
					: CC3VectorLength(scale) / kCC3VectorUnitCubeLength;
}

-(void) setUniformScale:(GLfloat) aValue { self.scale = cc3v(aValue, aValue, aValue); }

-(BOOL) isUniformlyScaledLocally { return (scale.x == scale.y) && (scale.x == scale.z); }


#pragma mark Transformations

/** Returns whether the mesh vertices can be transformed using only translation. */
-(BOOL) doesUseTranslationOnly { return super.doesUseTranslationOnly && self.isTransformRigid; }

-(BOOL) isTransformRigid { return CC3VectorsAreEqual(scale, kCC3VectorUnitCube); }

/** Invoke super, then apply the scaling transforms to the specified matrix data. */
-(void) applyLocalTransformsTo: (CC3Matrix4x3*) mtx {
	[super applyLocalTransformsTo: mtx];
	[self applyScalingTo: mtx];
}

/** Template method that applies the local scale property to the specified transform matrix. */
-(void) applyScalingTo: (CC3Matrix4x3*) mtx {
	CC3Matrix4x3ScaleBy(mtx, self.scale);
	LogTrace(@"%@ scaled to %@", self, NSStringFromCC3Vector(self.scale));
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		scale = kCC3VectorUnitCube;
	}
	return self;
}

-(void) populateFrom: (CC3ScalableMeshParticle*) another {
	[super populateFrom: another];
	scale = another.scale;
}

@end
