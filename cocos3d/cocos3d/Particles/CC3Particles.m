/*
 * CC3Particles.m
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
 * See header file CC3Particles.h for full API documentation.
 */

#import "CC3Particles.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3CC2Extensions.h"
#import "CC3Scene.h"
#import <objc/runtime.h>


#pragma mark -
#pragma mark CC3ParticleEmitter

@interface CC3Node (TemplateMethods)
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor;
@end

@implementation CC3ParticleEmitter

-(void) dealloc {
	[_particles release];
	[_particleNavigator release];
	[_particleClass release];

	[super dealloc];
}

@synthesize particles=_particles, particleCount=_particleCount;
@synthesize currentParticleCapacity=_currentParticleCapacity;
@synthesize maximumParticleCapacity=_maximumParticleCapacity;
@synthesize particleCapacityExpansionIncrement=_particleCapacityExpansionIncrement;
@synthesize emissionDuration=_emissionDuration, emissionInterval=_emissionInterval;
@synthesize isEmitting=_isEmitting, elapsedTime=_elapsedTime, shouldRemoveOnFinish=_shouldRemoveOnFinish;
@synthesize shouldUpdateParticlesBeforeTransform=_shouldUpdateParticlesBeforeTransform;
@synthesize shouldUpdateParticlesAfterTransform=_shouldUpdateParticlesAfterTransform;

-(Protocol*) requiredParticleProtocol { return @protocol(CC3ParticleProtocol); }

-(Class) particleClass { return _particleClass; }

// Ensure that the particle class supports the requiredParticleProtocol of both this emitter and the navigator.
-(void) setParticleClass: (Class) aParticleClass {
	CC3Assert(!aParticleClass || [aParticleClass conformsToProtocol: self.requiredParticleProtocol],
			  @"%@ does not conform to the %@ protocol. All particles emitted by %@ must conform to that protocol.", aParticleClass,
			  [NSString stringWithUTF8String: protocol_getName(self.requiredParticleProtocol)], self);
	CC3Assert(!aParticleClass || !_particleNavigator || [aParticleClass conformsToProtocol: _particleNavigator.requiredParticleProtocol],
			  @"%@ does not conform to the %@ protocol. All particles configured by %@ must conform to that protocol.", aParticleClass,
			  [NSString stringWithUTF8String: protocol_getName(_particleNavigator.requiredParticleProtocol)], _particleNavigator);

	[_particleClass release];
	_particleClass = [aParticleClass retain];
}

-(CC3ParticleNavigator*) particleNavigator { return _particleNavigator; }

-(void) setParticleNavigator: (CC3ParticleNavigator*) aNavigator {
	if (aNavigator == _particleNavigator) return;

	CC3Assert(!_particleClass || !aNavigator || [_particleClass conformsToProtocol: aNavigator.requiredParticleProtocol],
			  @"%@ does not conform to the %@ protocol. All particles configured by %@ must conform to that protocol.", _particleClass,
			  [NSString stringWithUTF8String: protocol_getName(aNavigator.requiredParticleProtocol)], aNavigator);

	_particleNavigator.emitter = nil;
	
	[_particleNavigator release];
	_particleNavigator = [aNavigator retain];
	
	_particleNavigator.emitter = self;
}

-(BOOL) isFull { return (_particleCount == _maximumParticleCapacity); }

-(CCTime) emissionInterval { return _emissionInterval; }

-(void) setEmissionInterval: (CCTime) anInterval {
	_emissionInterval = MAX(anInterval, 0.0);		// Force it to non-negative.
}

-(GLfloat) emissionRate {
	// Handle special cases first
	if (_emissionInterval <= 0.0f) return kCC3ParticleInfiniteEmissionRate;
	if (_emissionInterval == kCC3ParticleInfiniteInterval) return 0.0f;

	return 1.0f / _emissionInterval;
}

-(void) setEmissionRate: (GLfloat) aRatePerSecond {
	// Handle special cases first
	if (aRatePerSecond <= 0.0f) _emissionInterval = kCC3ParticleInfiniteInterval;
	if (aRatePerSecond == kCC3ParticleInfiniteEmissionRate) _emissionInterval = 0.0f;
	_emissionInterval = 1.0f / aRatePerSecond;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_particles = [NSMutableArray new];		// retained
		_particleNavigator = nil;
		_maximumParticleCapacity = kCC3ParticlesNoMax;
		_particleCapacityExpansionIncrement = 100;
		_particleCount = 0;
		_emissionDuration = kCC3ParticleInfiniteInterval;
		_emissionInterval = kCC3ParticleInfiniteInterval;
		_elapsedTime = 0.0f;
		_timeSinceEmission = 0.0f;
		_shouldRemoveOnFinish = NO;
		_isEmitting = NO;
		_wasStarted = NO;
		_shouldUpdateParticlesBeforeTransform = YES;
		_shouldUpdateParticlesAfterTransform = NO;
		_particleClass = nil;
	}
	return self;
}

/** Particles are not copied. */
-(void) populateFrom: (CC3ParticleEmitter*) another {
	[super populateFrom: another];

	self.mesh = nil;														// Emitters can't share meshes
	self.vertexContentTypes = another.vertexContentTypes;					// Use setter to establish a new mesh
	self.particleNavigator = [another.particleNavigator autoreleasedCopy];	// Use setter to retain & link back here
	
	_maximumParticleCapacity = another.maximumParticleCapacity;
	_particleCapacityExpansionIncrement = another.particleCapacityExpansionIncrement;
	_emissionInterval = another.emissionInterval;
	_emissionDuration = another.emissionDuration;
	_shouldRemoveOnFinish = another.shouldRemoveOnFinish;
	_shouldUpdateParticlesBeforeTransform = another.shouldUpdateParticlesBeforeTransform;
	_shouldUpdateParticlesAfterTransform = another.shouldUpdateParticlesAfterTransform;
	self.particleClass = another.particleClass;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ is %@emitting %u of %@ particles every %@ ms for %.1f of %@ seconds, and will expand by %u at %u particles",
			[self class], (_isEmitting ? @"" : @"not "), _particleCount,
			(_maximumParticleCapacity == kCC3ParticlesNoMax ? @"endless" : [NSString stringWithFormat: @"%u", _maximumParticleCapacity]),
			(_emissionInterval == kCC3ParticleInfiniteInterval ? @"endless" : [NSString stringWithFormat: @"%.1f", _emissionInterval * 1000.0f]),
			_elapsedTime,
			(_emissionDuration == kCC3ParticleInfiniteInterval ? @"endless" : [NSString stringWithFormat: @"%.1f", _emissionDuration]),
			_particleCapacityExpansionIncrement, (self.currentParticleCapacity + 1)];
}


#pragma mark Updating

/**
 * Invoked during node updates.
 * Emits new particles, updates existing particles, and expires aging particles.
 */
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super processUpdateBeforeTransform: visitor];
	
	CCTime dt = visitor.deltaTime;
	LogTrace(@"Updating after %.1f ms: %@", (dt * 1000.0f), self);
	
	// If configured to update particles before the node is transformed, do so here.
	// For each particle, invoke the updateBeforeTransform: method. 
	// Particles can also be removed during the update process.
	if (_shouldUpdateParticlesBeforeTransform) [self updateParticlesBeforeTransform: visitor];
	
	// If emitting and it's time to quit emitting, do so.
	// Otherwise check if it's time to emit particles.
	[self checkDuration: dt];
	[self checkEmission: dt];
}

/**
 * For each particle, invoke the updateBeforeTransform: method.
 * If the particle has expired, remove it from the particles array.
 */
-(void) updateParticlesBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	GLint i = 0;
	while (i < _particleCount) {
		id<CC3ParticleProtocol> p = [_particles objectAtIndex: i];
		
		[p updateBeforeTransform: visitor];
		
		if (p.isAlive) {
			i++;			// Move on to next particle
		} else {
			// Remove the particle from active use and don't increment iterator.
			LogTrace(@"Expiring %@", [p fullDescription]);
			[self finalizeAndRemoveParticle: p atIndex: i];
		}
	}
}

/** Template method that checks if its time to quit emitting. */
-(void) checkDuration: (CCTime) dt {
	if (_isEmitting && (_emissionDuration != kCC3ParticleInfiniteInterval)) {
		_elapsedTime += dt;
		if (_elapsedTime >= _emissionDuration) [self pause];
	}
}

/**
 * Template method that checks if its time to emit a particle,
 * and if so, invokes the emitParticle method to emit the particle.
 */
-(void) checkEmission: (CCTime) dt {
	if ( !_isEmitting ) return;
	_timeSinceEmission += dt;
	while ( !self.isFull && (_timeSinceEmission >= _emissionInterval) ) {
		_timeSinceEmission -= _emissionInterval;
		[self emitParticle];
	}
}


#pragma mark Emitting particles

-(GLuint) emitParticles: (GLuint) count {
	GLuint emitCount = 0;
	for (GLuint i = 0; i < count; i++) if ( [self emitParticle] ) emitCount++;
	return emitCount;
}

-(id<CC3ParticleProtocol>) emitParticle {
	id<CC3ParticleProtocol> particle = [self acquireParticle];
	return [self emitParticle: particle] ? particle : nil;
}

/** Template method to create a new particle, or reuse an existing expired particle. */
-(id<CC3ParticleProtocol>) acquireParticle {
	if (_particleCount < _particles.count) {
		LogTrace(@"%@ reusing particle at %i", self, _particleCount);
		return [_particles objectAtIndex: _particleCount];
	} else {
		LogTrace(@"%@ creating new particle at %i", self, _particleCount);
		return [self makeParticle];
	}
}

-(BOOL) emitParticle: (id<CC3ParticleProtocol>) aParticle {
	if ( !aParticle || self.isFull ) return NO;		// Can't add particles if there's no space

	CC3Assert([aParticle conformsToProtocol: self.requiredParticleProtocol],
			  @"%@ does not conform to the %@ protocol. All particles emitted by %@ must conform to that protocol.", aParticle,
			  [NSString stringWithUTF8String: protocol_getName(self.requiredParticleProtocol)], self);
	CC3Assert(!_particleNavigator || [aParticle conformsToProtocol: _particleNavigator.requiredParticleProtocol],
			  @"%@ does not conform to the %@ protocol. All particles configured by %@ must conform to that protocol.", aParticle,
			  [NSString stringWithUTF8String: protocol_getName(_particleNavigator.requiredParticleProtocol)], _particleNavigator);
	
	// Ensure that we have capacity for this particle, and add the particle to the living
	// particles, which also attaches the emitter to the particle.
	if ( ![self ensureParticleCapacityFor: aParticle] ) return NO;
	[self addNewParticle: aParticle];

	aParticle.isAlive = YES;
	[self initializeParticle: aParticle];
	if (aParticle.isAlive) [_particleNavigator initializeParticle: aParticle];
	if (aParticle.isAlive) [aParticle initializeParticle];
	
	// If particle not aborted during initialization, accept it.
	if (aParticle.isAlive) [self acceptParticle: aParticle];

	return aParticle.isAlive;
}

/** Ensures space has been allocated for the specified particle. */
-(BOOL) ensureParticleCapacityFor: (id<CC3ParticleProtocol>) aParticle {
	if (aParticle.emitter == self) return YES;			// Reusing a particle so we're good

	// If we are at current capacity, see if we can expand
	if (_particleCount == _currentParticleCapacity) {
		GLuint origCap = _currentParticleCapacity;
		_currentParticleCapacity = MIN(_currentParticleCapacity + _particleCapacityExpansionIncrement,
									   _maximumParticleCapacity);
		return (_currentParticleCapacity > origCap);	// Return if current capacity actually was increased
	}
	return YES;
}

/**
 * If the specified particle is not being reused, it is added to the particles collection,
 * at the end of the living particles, and in front of any expired particles.
 * This emitter is also attached to the particle.
 */
-(void) addNewParticle: (id<CC3ParticleProtocol>) aParticle {
	if (aParticle.emitter == self) return;			// Reusing a particle so we're good

	[_particles insertObject: aParticle atIndex: _particleCount];
	aParticle.emitter = self;
}

/** Template method to create a new particle using the particleClass property. */
-(id<CC3ParticleProtocol>) makeParticle { return [_particleClass particle]; }

-(void) initializeParticle: (id<CC3ParticleProtocol>) aParticle {}

/**
 * Template method that accepts the particle if initialization did not abort the particle.
 *
 * This implementation simply increments the particleCount property. Subclasses may override
 * to perform additional activity to accept the particle.
 */
-(void) acceptParticle: (id<CC3ParticleProtocol>) aParticle { _particleCount++; }

/** Update the particles after the transform, and then update the mesh node.  */
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	
	// If configured to update particles after the node is transformed, do so here.
	// For each particle, invoke the updateBeforeTransform: method. 
	// Particles can also be removed during the update process.
	if (_shouldUpdateParticlesAfterTransform) [self updateParticlesAfterTransform: visitor];
	
	// If emission has stopped and all the particles have been killed off and the
	// emitter should be removed when finished, remove the emitter from its parent.
	if (self.isFinished && self.shouldRemoveOnFinish) {
		LogTrace(@"%@ is exhausted and is being removed", self);
		[visitor requestRemovalOf: self];
	}
	
	[super processUpdateAfterTransform: visitor];
}

/**
 * For each particle, invoke the updateAfterTransform: method.
 * If the particle has expired, remove it from the particles array.
 */
-(void) updateParticlesAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	GLint i = 0;
	while (i < _particleCount) {
		id<CC3ParticleProtocol> p = [_particles objectAtIndex: i];
		
		[p updateAfterTransform: visitor];
		
		if (p.isAlive) {
			i++;			// Move on to next particle
		} else {
			// Remove the particle from active use and don't increment iterator.
			LogTrace(@"Expiring %@", [p fullDescription]);
			[self finalizeAndRemoveParticle: p atIndex: i];
		}
	}
}

/** If transitioning to emitting from not, mark as such and reset timers. */
-(void) setIsEmitting: (BOOL) shouldEmit {
	if (!_isEmitting && shouldEmit) {
		_elapsedTime = 0.0;
		_timeSinceEmission = 0.0;
		_wasStarted = YES;
	}
	_isEmitting = shouldEmit;
}

-(void) play { self.isEmitting = YES; }

-(void) pause { self.isEmitting = NO; }

-(void) stop {
	[self pause];						// Stop emitting particles...
	[self removeAllParticles];			// ...and kill those already emitted.
	[_particles removeAllObjects];
}

-(BOOL) isActive { return self.isEmitting || _particleCount > 0; }

// Check for wasStarted needed so it doesn't indicate finished before it starts.
// Otherwise, auto-remove would cause the emitter to be removed immediately.
-(BOOL) isFinished { return _wasStarted && !self.isActive; }


#pragma mark Accessing particles

-(id<CC3ParticleProtocol>) particleAt: (GLuint) aParticleIndex {
	return [_particles objectAtIndex: aParticleIndex];
}

-(id<CC3ParticleProtocol>) particleWithVertexAt: (GLuint) vtxIndex {
	CC3Assert(NO, @"%@ subclass must implement the particleWithVertexAt: method!", self);
	return nil;
}

-(id<CC3ParticleProtocol>) particleWithVertexIndexAt: (GLuint) index {
	CC3Assert(NO, @"%@ subclass must implement the particleWithVertexIndexAt: method!", self);
	return nil;
}

-(id<CC3ParticleProtocol>) particleWithFaceAt: (GLuint) faceIndex {
	return [self particleWithVertexIndexAt: [self vertexIndexCountFromFaceCount: faceIndex]];
}

-(void) removeParticle: (id<CC3ParticleProtocol>) aParticle {
	GLuint pIdx = (GLuint)[_particles indexOfObjectIdenticalTo: aParticle];
	if (pIdx < _particleCount) {
		aParticle.isAlive = NO;
		[self finalizeAndRemoveParticle: aParticle atIndex: pIdx];
	}
}

/**
 * Finalizes and removes the specified particle. Finalization must happen first, because the
 * particle may be removed to create space, which can result in its deallocation if this emitter
 * is all that is holding onto it.
 */
-(void) finalizeAndRemoveParticle: (id<CC3ParticleProtocol>) aParticle atIndex: (GLuint) anIndex {
	[aParticle finalizeParticle];
	[self removeParticle: aParticle atIndex: anIndex];
}

/**
 * Removes the current particle from the active particles, but keep it cached for future use.
 *
 * This basic implementation simply decrements the particleCount. Subclasses will define behaviour
 * for removing the particle from the particles collection, and for moving the underlying vertex content.
 */
-(void) removeParticle: (id<CC3ParticleProtocol>) aParticle atIndex: (GLuint) anIndex {
	_particleCount--;
}

-(void) removeAllParticles {
	GLuint pCnt = self.particleCount;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		id<CC3ParticleProtocol> aParticle = [self particleAt: pIdx];
		aParticle.isAlive = NO;
		[aParticle finalizeParticle];
	}
	_particleCount = 0;
}



#pragma mark Drawing

/** Overridden to test if active as well. If not active, there is nothing to intersect. */
-(BOOL) doesIntersectBoundingVolume: (CC3BoundingVolume*) otherBoundingVolume {
	return self.isActive && [super doesIntersectBoundingVolume: otherBoundingVolume];
}


#pragma mark Wireframe box and descriptor

/** Overridden to set the wireframe to automatically update as parent changes. */
-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {
	[super setShouldDrawLocalContentWireframeBox: shouldDraw];
	self.localContentWireframeBoxNode.shouldAlwaysMeasureParentBoundingBox = YES;
}

@end


#pragma mark -
#pragma mark CC3ParticleNavigator

@implementation CC3ParticleNavigator

@synthesize emitter=_emitter;

-(void) dealloc {
	_emitter = nil;			// weak reference
	[super dealloc];
}

-(Protocol*) requiredParticleProtocol { return @protocol(CC3ParticleProtocol); }

-(void) initializeParticle: (id<CC3ParticleProtocol>) aParticle {}


#pragma mark Allocation and initialization.

-(id) init {
	if ( (self = [super init]) ) {
		_emitter = nil;
	}
	return self;
}

+(id) navigator { return [[[self alloc] init] autorelease]; }

-(id) copyWithZone: (NSZone*) zone {
	CC3ParticleNavigator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(void) populateFrom: (CC3ParticleNavigator*) another {}

@end


#pragma mark -
#pragma mark CC3CommonVertexArrayParticleEmitter

@interface CC3CommonVertexArrayParticleEmitter (TemplateMethods)
-(void) updateParticleMeshWithVisitor: (CC3NodeUpdatingVisitor*) visitor;
-(void) updateParticleMeshGLBuffers;
-(void) addDirtyVertexRange: (NSRange) aRange;
-(void) addDirtyVertex: (GLuint) vtxIdx;
-(void) addDirtyVertexIndexRange: (NSRange) aRange;
-(void) addDirtyVertexIndex: (GLuint) vtxIdx;
-(void) clearDirtyVertexRanges;
-(BOOL) verticesAreDirty;
-(BOOL) vertexIndicesAreDirty;
@end

@implementation CC3CommonVertexArrayParticleEmitter

-(Protocol*) requiredParticleProtocol { return @protocol(CC3CommonVertexArrayParticleProtocol); }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		[self clearDirtyVertexRanges];
		_wasVertexCapacityChanged = NO;
	}
	return self;
}

// Protected properties for copying
-(NSRange) dirtyVertexRange { return _dirtyVertexRange; }
-(NSRange) dirtyVertexIndexRange { return _dirtyVertexIndexRange; }

-(void) populateFrom: (CC3CommonVertexArrayParticleEmitter*) another {
	[super populateFrom: another];
	_dirtyVertexRange = another.dirtyVertexRange;
	_dirtyVertexIndexRange = another.dirtyVertexIndexRange;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, using %i of %i vertices and %i of %i vertex indices",
			[super fullDescription],
			self.vertexCount, self.mesh.allocatedVertexCapacity,
			self.vertexIndexCount, self.mesh.allocatedVertexIndexCapacity];
}


#pragma mark Vertex management

// Overridden to retain all vertex content in memory and dynamically write to GL buffer.
-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	super.vertexContentTypes = vtxContentTypes;
	[self retainVertexContent];
	self.mesh.vertexLocations.bufferUsage = GL_DYNAMIC_DRAW;
}


#pragma mark Accessing vertex data

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) vtxIndex {
	[super setVertexLocation: aLocation at: vtxIndex];
	[self addDirtyVertex: vtxIndex];
}

-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) vtxIndex {
	[super setVertexHomogeneousLocation: aLocation at: vtxIndex];
	[self addDirtyVertex: vtxIndex];
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) vtxIndex {
	[super setVertexNormal: aNormal at: vtxIndex];
	[self addDirtyVertex: vtxIndex];
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) vtxIndex {
	[super setVertexColor4F: aColor at: vtxIndex];
	[self addDirtyVertex: vtxIndex];
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) vtxIndex {
	[super setVertexColor4B: aColor at: vtxIndex];
	[self addDirtyVertex: vtxIndex];
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) vtxIndex {
	[super setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: vtxIndex];
	[self addDirtyVertex: vtxIndex];
}


#pragma mark Updating

/** Ensures space has been allocated for the specified particle. */
-(BOOL) ensureParticleCapacityFor: (id<CC3CommonVertexArrayParticleProtocol>) aParticle {
	if ( ![super ensureParticleCapacityFor: aParticle] ) return NO;
	
	GLuint currCap, newRqmt, newCap, partVtxCount, meshVtxCount, meshVtxIdxCount;
	CC3Mesh* vaMesh = self.mesh;
	meshVtxCount = vaMesh.vertexCount;

	// Ensure that the vertex content arrays have room, and if not, expand them.
	// Expanding the vertex capacity does not change the value of the vertexCount property.
	currCap = vaMesh.allocatedVertexCapacity;
	partVtxCount = aParticle.vertexCount;
	newRqmt = meshVtxCount + partVtxCount;
	if (newRqmt > currCap) {		// Needs expansion...so expand by a large chunk
		if (_particleCapacityExpansionIncrement == 0) return NO;		// Oops...can't expand
		newCap = currCap + (partVtxCount * _particleCapacityExpansionIncrement);
		vaMesh.allocatedVertexCapacity = newCap;
		vaMesh.vertexCount = meshVtxCount;							// Leave the vertex count unchanged
		if (vaMesh.allocatedVertexCapacity != newCap) return NO;	// Expansion failed
		_wasVertexCapacityChanged = YES;
		LogTrace(@"%@ changed capacity to %i vertices", self, vaMesh.allocatedVertexCapacity);
	}

	// If the underlying mesh uses vertex indices, ensure it has space for the new particle,
	// and if the underlying mesh does not use vertex indices, but the incoming particle does,
	// synthesize vertex indices for all the existing particles. In either case, expanding the
	// vertex index capacity does not change the value of the vertexIndexCount property.
	if (vaMesh.hasVertexIndices) {
		// Ensure that the vertex index array has room, and if not, expand it.
		currCap = vaMesh.allocatedVertexIndexCapacity;
		partVtxCount = aParticle.vertexIndexCount;
		newRqmt = vaMesh.vertexIndexCount + partVtxCount;
		if (newRqmt > currCap) {		// Needs expansion...so expand by a large chunk
			if (_particleCapacityExpansionIncrement == 0) return NO;			// Oops...can't expand
			newCap = currCap + (partVtxCount * _particleCapacityExpansionIncrement);
			meshVtxIdxCount = vaMesh.vertexIndexCount;
			vaMesh.allocatedVertexIndexCapacity = newCap;
			vaMesh.vertexIndexCount = meshVtxIdxCount;			// Leave the vertex count unchanged
			vaMesh.vertexIndices.bufferUsage = GL_DYNAMIC_DRAW;	// Make sure to use dynamic draw
			[vaMesh retainVertexIndices];						// Make sure the indices stick around to be modified
			if (vaMesh.allocatedVertexIndexCapacity != newCap) return NO;	// Expansion failed
			_wasVertexCapacityChanged = YES;
			LogTrace(@"%@ changed capacity to %i vertex indices", self, vaMesh.allocatedVertexIndexCapacity);
		}
	} else if (aParticle.hasVertexIndices) {
		// The underlying mesh does not yet have vertex indices, but the particle requires them.
		// Add a new vertex indices array, with enough capacity for one vertex index per vertex,
		// plus an expansion component.
		if (_particleCapacityExpansionIncrement == 0) return NO;			// Oops...can't expand
		partVtxCount = aParticle.vertexIndexCount;
		newCap = meshVtxCount + (partVtxCount * _particleCapacityExpansionIncrement);
		meshVtxIdxCount = vaMesh.vertexIndexCount;
		vaMesh.allocatedVertexIndexCapacity = newCap;
		vaMesh.vertexIndexCount = meshVtxIdxCount;		// Leave the vertex count unchanged
		vaMesh.vertexIndices.bufferUsage = GL_DYNAMIC_DRAW;	// Make sure to use dynamic draw
		[vaMesh retainVertexIndices];					// Make sure the indices stick around to be modified
		if (vaMesh.allocatedVertexIndexCapacity != newCap) return NO;	// Expansion failed
		_wasVertexCapacityChanged = YES;
		LogTrace(@"%@ created new capacity for %i vertex indices", self, vaMesh.allocatedVertexIndexCapacity);

		// Synthesize vertex indices for the existing vertex content
		for (GLuint vtxIdx = 0; vtxIdx < meshVtxCount; vtxIdx++)
			[vaMesh setVertexIndex: vtxIdx at: vtxIdx];
	}
	
	return YES;
}

/**
 * Adds the specified range to the range of dirty vertices.
 * The result is to form a union of the specified range and the current range.
 */
-(void) addDirtyVertexRange: (NSRange) aRange {
	_dirtyVertexRange = NSUnionRange(_dirtyVertexRange, aRange);
}

/**
 * Adds the specified vertex to the range of dirty vertices.
 * The result is to form a union of the specified vertex and the current range.
 */
-(void) addDirtyVertex: (GLuint) vtxIdx { [self addDirtyVertexRange: NSMakeRange(vtxIdx, 1)]; }

/**
 * Adds the specified range to the range of dirty vertex indices.
 * The result is to form a union of the specified range and the current range.
 */
-(void) addDirtyVertexIndexRange: (NSRange) aRange {
	_dirtyVertexIndexRange = NSUnionRange(_dirtyVertexIndexRange, aRange);
}

/**
 * Adds the specified vertex index to the range of dirty vertex indices.
 * The result is to form a union of the specified vertex index and the current range.
 */
-(void) addDirtyVertexIndex: (GLuint) vtxIdx { [self addDirtyVertexIndexRange: NSMakeRange(vtxIdx, 1)]; }

/** Returns whether any vertices are dirty, by being either expanded or changed. */
-(BOOL) verticesAreDirty { return _wasVertexCapacityChanged || (_dirtyVertexRange.length > 0); }

/** Returns whether any vertex indices are dirty, by being either expanded or changed. */
-(BOOL) vertexIndicesAreDirty { return _wasVertexCapacityChanged || (_dirtyVertexIndexRange.length > 0); }

/** Clears the range of dirty vertices and vertex indices. */
-(void) clearDirtyVertexRanges { _dirtyVertexIndexRange = _dirtyVertexRange = (NSRange){ 0, 0 }; }

/**
 * Process the transform if the vertices have been changed at all,
 * to ensure that particle vertices are transformed.
 */
-(BOOL) isTransformDirty { return self.verticesAreDirty || super.isTransformDirty; }

/** Updates the mesh vertex counts and marks the range of vertices that are affected by this particle. */
-(void) acceptParticle: (id<CC3CommonVertexArrayParticleProtocol>) aParticle {
	[super acceptParticle: aParticle];

	NSRange vtxRange = aParticle.vertexRange;
	self.vertexCount = (GLuint)NSMaxRange(vtxRange);
	[self addDirtyVertexRange: vtxRange];

	NSRange vtxIdxRange = aParticle.vertexIndexRange;
	self.vertexIndexCount = (GLuint)NSMaxRange(vtxIdxRange);
	[self addDirtyVertexIndexRange: vtxIdxRange];
	
	LogTrace(@"%@ accepting particle %@ at %i. Vertex count %i and vertex index count %i",
			 self, aParticle, _particleCount, self.vertexCount, self.vertexIndexCount);
}

/** Updates the mesh after particles have been updated.  */
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super processUpdateBeforeTransform: visitor];
	[self updateParticleMeshWithVisitor: visitor];
}

/**
 * Updates the particle mesh by updating the particle count, copying the particle
 * vertex data to the GL buffer, and updating the bounding volume of this node.
 */
-(void) updateParticleMeshWithVisitor: (CC3NodeUpdatingVisitor*) visitor {
	if (self.verticesAreDirty) {
		LogTrace(@"%@ updating mesh with %i particles", self, _particleCount);
		[self updateParticleMeshGLBuffers];
		[self markBoundingVolumeDirty];
		[self clearDirtyVertexRanges];
		_wasVertexCapacityChanged = NO;
	}
}

/**
 * If the mesh is using GL VBO's, update them. If the mesh was expanded,
 * recreate the VBO's, otherwise update them.
 */
-(void) updateParticleMeshGLBuffers {
	if (self.isUsingGLBuffers) {
		CC3Mesh* vaMesh = self.mesh;
		if (_wasVertexCapacityChanged) {
			[vaMesh deleteGLBuffers];
			[vaMesh createGLBuffers];
			LogTrace(@"%@ re-created GL buffers because buffer capacity has changed to %i vertices and %i vertex indices.",
					 self, vaMesh.allocatedVertexCapacity, vaMesh.allocatedVertexIndexCapacity);
		} else {
			[vaMesh updateGLBuffersStartingAt: (GLuint)_dirtyVertexRange.location
									forLength: (GLuint)_dirtyVertexRange.length];
			
			if (vaMesh.hasVertexIndices && self.vertexIndicesAreDirty)
				[vaMesh.vertexIndices updateGLBufferStartingAt: (GLuint)_dirtyVertexIndexRange.location
													 forLength: (GLuint)_dirtyVertexIndexRange.length];

			LogTrace(@"%@ updated vertex content GL buffer (ID %i) range (%i, %i) of %i vertices (out of %i allocated as %@) and index GL buffer (ID %i) range (%i, %i) of %i indices (out of %i allocated as %@) for %i particles",
					 self, vaMesh.vertexLocations.bufferID, _dirtyVertexRange.location, _dirtyVertexRange.length, self.vertexCount, vaMesh.allocatedVertexCapacity, NSStringFromGLEnum(vaMesh.vertexLocations.bufferUsage),
					 vaMesh.vertexIndices.bufferID, _dirtyVertexIndexRange.location, _dirtyVertexIndexRange.length, self.vertexIndexCount, vaMesh.allocatedVertexIndexCapacity, NSStringFromGLEnum(vaMesh.vertexIndices.bufferUsage), _particleCount);
		}
	} else {
		LogTrace(@"%@ not updating GL buffers because they are not in use for this mesh.", self);
	}
}


#pragma mark Accessing particles

-(id<CC3CommonVertexArrayParticleProtocol>) commonVertexArrayParticleAt: (GLuint) aParticleIndex {
	return (id<CC3CommonVertexArrayParticleProtocol>)[self particleAt: aParticleIndex];
}

-(id<CC3ParticleProtocol>) particleWithVertexAt: (GLuint) vtxIndex {
	GLuint pCnt = self.particleCount;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		id<CC3CommonVertexArrayParticleProtocol> cvap = [self commonVertexArrayParticleAt: pIdx];
		if (NSLocationInRange(vtxIndex, cvap.vertexRange)) return cvap;
	}
	return nil;
}

-(id<CC3ParticleProtocol>) particleWithVertexIndexAt: (GLuint) index {
	GLuint pCnt = self.particleCount;
	for (GLuint pIdx = 0; pIdx < pCnt; pIdx++) {
		id<CC3CommonVertexArrayParticleProtocol> cvap = [self commonVertexArrayParticleAt: pIdx];
		if (NSLocationInRange(index, cvap.vertexIndexRange)) return cvap;
	}
	return nil;
}

/** Shrinks the mesh vertex count by the vertex count of the particle. */
-(void) removeParticle: (id<CC3CommonVertexArrayParticleProtocol>) aParticle atIndex: (GLuint) anIndex {
	[super removeParticle: aParticle atIndex: anIndex];		// Decrements particleCount
	self.vertexCount -= aParticle.vertexCount;
	self.vertexIndexCount -= aParticle.vertexIndexCount;
	LogTrace(@"%@ removing %@ at %i and reducing vertex count by %i and vertex index count by %i",
			 self, aParticle, anIndex, aParticle.vertexCount, aParticle.vertexIndexCount);
}	

-(void) removeAllParticles {
	[super removeAllParticles];

	[self addDirtyVertexRange: NSMakeRange(0, self.vertexCount)];
	self.vertexCount = 0;		// After setting dirty range

	[self addDirtyVertexIndexRange: NSMakeRange(0, self.vertexIndexCount)];
	self.vertexIndexCount = 0;		// After setting dirty range
}

@end


#pragma mark -
#pragma mark CC3ParticleBase

@implementation CC3ParticleBase

@synthesize emitter=_emitter;

-(void) dealloc {
	_emitter = nil;			// weak reference
	[super dealloc];
}

// Alloc iVar in subclases to consolidate storage
-(BOOL) isAlive {
	CC3Assert(NO, @"%@ does not implement the isAlive property", self);
	return NO;
}

// Alloc iVar in subclases to consolidate storage
-(void) setIsAlive: (BOOL) alive {
	CC3Assert(NO, @"%@ does not implement the isAlive property", self);
}

-(CC3Vector) location { return kCC3VectorNull; }

-(void) setLocation: (CC3Vector) aLocation {}

-(CC3Vector) globalLocation { return [self.emitter.globalTransformMatrix transformLocation: self.location]; }

-(ccColor4F) color4F { return _emitter.diffuseColor; }

-(void) setColor4F: (ccColor4F) aColor {}

-(ccColor4B) color4B { return CCC4BFromCCC4F(self.color4F); }

-(void) setColor4B: (ccColor4B) aColor {}

-(BOOL) hasColor { return _emitter.mesh.hasVertexColors; }

-(void) remove { [self.emitter removeParticle: self]; }


#pragma mark CCRGBAProtocol support

-(ccColor3B) color {
	ccColor4B c4 = self.color4B;
	return *(ccColor3B*)&c4;
}

-(void) setColor: (ccColor3B) color {
	self.color4B = ccc4(color.r, color.g, color.b, self.opacity);
}

-(GLubyte) opacity { return self.color4B.a; }

-(void) setOpacity: (GLubyte) opacity {
	ccColor4B c4 = self.color4B;
	c4.a = opacity;
	self.color4B = c4;
}

-(ccColor3B) displayedColor { return self.color; }

-(BOOL) isCascadeColorEnabled { return NO; }

-(void) setCascadeColorEnabled:(BOOL)cascadeColorEnabled {}

-(void) updateDisplayedColor: (ccColor3B) color {}

-(GLubyte) displayedOpacity { return self.opacity; }

-(BOOL) isCascadeOpacityEnabled { return NO; }

-(void) setCascadeOpacityEnabled: (BOOL) cascadeOpacityEnabled {}

-(void) updateDisplayedOpacity: (GLubyte) opacity {}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

- (NSString*) fullDescription {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@", [self description]];
	[desc appendFormat:@"\n\tlocation: %@", NSStringFromCC3Vector(self.location)];
	if (self.hasColor) {
		[desc appendFormat:@", colored: %@", NSStringFromCCC4F(self.color4F)];
	}
	return desc;
}


#pragma mark Allocation, initialization & finalization

-(void) initializeParticle {}

-(void) finalizeParticle {}

-(id) init {
	if ( (self = [super init]) ) {
		_emitter = nil;
		self.isAlive = NO;
	}
	return self;
}

+(id) particle { return [[[self alloc] init] autorelease]; }

-(id) copyWithZone: (NSZone*) zone {
	CC3ParticleBase* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(void) populateFrom: (CC3ParticleBase*) another {
	self.emitter = another.emitter;
	self.isAlive = another.isAlive;
}


#pragma mark Updating

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {}

@end
