/*
 * CC3PointParticles.m
 *
 * cocos3d 0.6.3
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
 * See header file CC3PointParticles.h for full API documentation.
 */

#import "CC3PointParticles.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3World.h"


#pragma mark -
#pragma mark CC3PointParticleEmitter

@interface CC3PointParticle (TemplateMethods)
-(void) initForIndex: (GLuint) anIndex;
-(void) pointNormalToCameraAt: (CC3Vector) camLoc;
@property(nonatomic, readwrite) GLuint index;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) populateFrom: (CC3MeshNode*) another;
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
@property(nonatomic, assign, readwrite) CC3Node* parent;
@end

@interface CC3PointParticleEmitter (TemplateMethods)
@property(nonatomic, retain, readwrite) CC3Camera* activeCamera;
-(void) configureParticleProperties: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupParticleProperties: (CC3NodeDrawingVisitor*) visitor;
-(void) createMaterial;
-(void) checkDuration: (ccTime) dt;
-(void) checkEmission: (ccTime) dt;
-(CC3PointParticle*) newParticle;
-(void) updateParticles: (ccTime) dt;
-(void) removeParticleAtIndex: (GLuint) anIndex;
-(void) setParticleNormal: (CC3PointParticle*) pointParticle;
-(void) updateParticleNormals: (CC3NodeUpdatingVisitor*) visitor;
-(void) updateParticleMesh;
-(void) markVerticesDirty;
-(GLfloat) normalizeParticleSizeToDevice: (GLfloat) aSize;
-(GLfloat) denormalizeParticleSizeFromDevice: (GLfloat) aSize;
+(GLfloat) deviceScaleFactor;
@end


@implementation CC3PointParticleEmitter

@synthesize particles, particleClass, maxParticles, particleCount;
@synthesize emissionDuration, emissionInterval, elapsedTime;
@synthesize particleContentTypes, isEmitting, shouldRemoveOnFinish;
@synthesize particleSize, particleSizeMinimum, particleSizeMaximum;
@synthesize shouldSmoothPoints, shouldNormalizeParticleSizesToDevice;
@synthesize particleSizeAttenuationCoefficients;

-(void) dealloc {
	[particles release];
	[cachedCamera release];
	particleClass = nil;		// not retained
	[super dealloc];
}

/** Overridden to use cached value if it exists. */
-(CC3Camera*) activeCamera {
	if ( !cachedCamera ) {
		self.activeCamera = super.activeCamera;
	}
	return cachedCamera;
}

-(void) setActiveCamera: (CC3Camera*) aCamera {
	[cachedCamera autorelease];
	cachedCamera = aCamera;
}

-(CC3PointParticleMesh*) particleMesh {
	return (CC3PointParticleMesh*)mesh;
}

-(BOOL) isFull {
	return particleCount == maxParticles;
}

-(ccTime) emissionInterval {
	return emissionInterval;
}

-(void) setEmissionInterval: (ccTime) anInterval {
	emissionInterval = MAX(anInterval, 0.0);		// Force it to non-negative.
}

-(GLfloat) emissionRate {
	// Handle special cases first
	if (emissionInterval <= 0.0f) return kCC3ParticleInfiniteEmissionRate;
	if (emissionInterval == kCC3ParticleInfiniteInterval) return 0.0f;

	return 1.0f / emissionInterval;
}

-(void) setEmissionRate: (GLfloat) aRatePerSecond {
	// Handle special cases first
	if (aRatePerSecond <= 0.0f) {
		emissionInterval = kCC3ParticleInfiniteInterval;
	}
	if (aRatePerSecond == kCC3ParticleInfiniteEmissionRate) {
		emissionInterval = 0.0f;
	}
	emissionInterval = 1.0f / aRatePerSecond;
}

-(GLfloat) unityScaleDistance {
	GLfloat sqDistAtten = particleSizeAttenuationCoefficients.c;
	return (sqDistAtten > 0.0f) ? sqrt(1.0 / sqDistAtten) : 0.0f;
}

-(void) setUnityScaleDistance: (GLfloat) aDistance {
	if (aDistance > 0.0) {
		particleSizeAttenuationCoefficients = (CC3AttenuationCoefficients){0.0, 0.0, 1.0 / (aDistance * aDistance)};
	} else {
		particleSizeAttenuationCoefficients = kCC3ParticleSizeAttenuationNone;
	}
}

/** Overridden to reset the camera so it will be lazily reacquired. */
-(void) setParent: (CC3Node*) aNode {
	[super setParent: aNode];
	self.activeCamera = nil;
}


#pragma mark Accessing vertex data

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLsizei) index {
	[super setVertexLocation: aLocation at: index];
	[self markVerticesDirty];
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLsizei) index {
	[super setVertexNormal: aNormal at: index];
	[self markVerticesDirty];
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLsizei) index {
	[super setVertexColor4F: aColor at: index];
	[self markVerticesDirty];
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLsizei) index {
	[super setVertexColor4B: aColor at: index];
	[self markVerticesDirty];
}

-(GLfloat) particleSizeAt: (GLsizei) index {
	CC3PointParticleMesh* pm = self.particleMesh;
	return pm ? [self denormalizeParticleSizeFromDevice: [pm particleSizeAt: index]] : 0.0f;
}

-(void) setParticleSize: (GLfloat) aSize at: (GLsizei) index {
	[self.particleMesh setParticleSize: [self normalizeParticleSizeToDevice: aSize] at: index];
	[self markVerticesDirty];
}

-(void) updateParticleSizesGLBuffer {
	[self.particleMesh updateParticleSizesGLBuffer];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		particles = nil;
		particleClass = nil;
		cachedCamera = nil;
		globalCameraLocation = kCC3VectorZero;
		self.particleSize = kCC3DefaultParticleSize;
		particleSizeMinimum = kCC3ParticleSizeMinimumNone;
		particleSizeMaximum = kCC3ParticleSizeMaximumNone;
		particleSizeAttenuationCoefficients = kCC3ParticleSizeAttenuationNone;
		emissionDuration = kCC3ParticleInfiniteInterval;
		emissionInterval = kCC3ParticleInfiniteInterval;
		particleContentTypes = kCC3PointParticleContentLocation;
		elapsedTime = 0.0f;
		timeSinceEmission = 0.0f;
		maxParticles = 0;
		particleCount = 0;
		shouldSmoothPoints = NO;
		shouldRemoveOnFinish = NO;
		shouldNormalizeParticleSizesToDevice = YES;
		shouldDisableDepthMask = YES;
		isEmitting = NO;
		wasStarted = NO;
		verticesAreDirty = NO;
		[[self class] deviceScaleFactor];	// Force init the static deviceScaleFactor before accessing it.
		[self createMaterial];
	}
	return self;
}

/**
 * Template method invoked during initialization to create the material.
 *
 * Subclasses may override if necessary.
 */
-(void) createMaterial {
	NSString* matName = [NSString stringWithFormat: @"%@-Material", self.name];
	CC3Material* mat = [CC3Material materialWithName: matName];
	mat.diffuseColor = kCCC4FWhite;
	mat.sourceBlend = GL_SRC_ALPHA;
	mat.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
	self.material = mat;
}

-(void) populateForMaxParticles: (GLuint) numParticles
						 ofType: (id) aParticleClass
					 containing: (CC3PointParticleVertexContent) contentTypes {

	NSAssert3( [aParticleClass isSubclassOfClass: [self particleClass]],
			  @"%@ only emits particles of type %@ and its subclasses, and does not support particles of type %@.",
			  [self class], [self particleClass], aParticleClass );

	[self stop];
	particleContentTypes = contentTypes;
	maxParticles = numParticles;
	particleClass = aParticleClass;
	
	particleCount = 0;
	[particles release];
	particles = [[CCArray arrayWithCapacity: maxParticles] retain];

	// Build the mesh vertex arrays to hold the specified contentTypes
	NSString* meshName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3PointParticleMesh* ppm = [CC3PointParticleMesh meshWithName: meshName];
	[ppm populateForMaxParticles: maxParticles containing: particleContentTypes];
	self.mesh = ppm;
	[self markVerticesDirty];

	// If we've asked for normals, assume we want to use lighting, otherwise turn it off
	self.shouldUseLighting = ppm.hasNormals;
}

-(void) populateForMaxParticles: (GLuint) numParticles ofType: (id) aParticleClass {
	[self populateForMaxParticles: numParticles
						   ofType: aParticleClass
					   containing: kCC3PointParticleContentLocation];
}

-(void) populateForMaxParticles: (GLuint) numParticles
					 containing: (CC3PointParticleVertexContent) contentTypes {
	[self populateForMaxParticles: numParticles
						   ofType: [self particleClass]
					   containing: contentTypes];
}

-(void) populateForMaxParticles: (GLuint) numParticles {
	[self populateForMaxParticles: numParticles containing: kCC3PointParticleContentLocation];
}
	
-(id) particleClass {
	return [CC3PointParticle class];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3PointParticleEmitter*) another {
	[super populateFrom: another];

	[self populateForMaxParticles: another.maxParticles
						   ofType: another.particleClass
					   containing: another.particleContentTypes];
	
	self.activeCamera = another.activeCamera;			// retained
	emissionInterval = another.emissionInterval;
	emissionDuration = another.emissionDuration;
	shouldRemoveOnFinish = another.shouldRemoveOnFinish;
	particleSize = another.particleSize;
	particleSizeMinimum = another.particleSizeMinimum;
	particleSizeMaximum = another.particleSizeMaximum;
	shouldSmoothPoints = another.shouldSmoothPoints;
	shouldRemoveOnFinish = another.shouldRemoveOnFinish;
	shouldNormalizeParticleSizesToDevice = another.shouldNormalizeParticleSizesToDevice;
	particleSizeAttenuationCoefficients = another.particleSizeAttenuationCoefficients;
}

-(void) retainVertexPointSizes {
	[self.particleMesh retainVertexPointSizes];
}

-(void) doNotBufferVertexPointSizes {
	[self.particleMesh doNotBufferVertexPointSizes];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ is %@emitting %i of %i particles of type %@ every %@ ms for %.1f of %@ seconds",
			[self class], (isEmitting ? @"" : @"not "), particleCount, maxParticles, particleClass,
			(emissionInterval == kCC3ParticleInfiniteInterval ? @"endless" : [NSString stringWithFormat: @"%.1f", emissionInterval * 1000.0f]),
			elapsedTime,
			(emissionDuration == kCC3ParticleInfiniteInterval ? @"endless" : [NSString stringWithFormat: @"%.1f", emissionDuration])];
}


#pragma mark -
#pragma mark Updating

/**
 * Marks that the vertices are dirty. This is invoked anytime the content of,
 * or quantity of, the vertices is changed. This can be caused by a change to
 * any of the the location, normal, color or size of a particle, or by the
 * emission or expiration of a particle.
 */
-(void) markVerticesDirty {
	verticesAreDirty = YES;
}

/**
 * Invoked during node updates.
 * Emits new particles, updates existing particles, and expires aging particles.
 */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super updateAfterTransform: visitor];

	ccTime dt = visitor.deltaTime;
	LogTrace(@"Updating after %.1f ms: %@", (dt * 1000.0f), self);
	
	// If emitting and it's time to quit emitting, do so.
	[self checkDuration: dt];
	
	// For each particle, invoke the update: method. 
	// Particles can also be removed during the update process.
	[self updateParticles: dt];
	
	// If needed, update the normal value in each particle to point towards the camera
	[self updateParticleNormals: visitor];
	
	// Check if it's time to emit a particle.
	[self checkEmission: dt];

	// If any particle was added or changed, update the mesh.
	[self updateParticleMesh];
	
	// If emission has stopped and all the particles have been killed off and the
	// emitter should be removed when finished, remove the emitter from its parent.
	if (self.isFinished && self.shouldRemoveOnFinish) {
		LogTrace(@"%@ is exhausted and is being removed", self);
		[visitor requestRemovalOf: self];
	}
}

/** Template method that checks if its time to quit emitting. */
-(void) checkDuration: (ccTime) dt {
	if (isEmitting && (emissionDuration != kCC3ParticleInfiniteInterval)) {
		elapsedTime += dt;
		if (elapsedTime >= emissionDuration) {
			[self pause];
		}
	}
}

/**
 * Template method that checks if its time to emit a particle,
 * and if so, invokes the emitParticle method to emit the particle.
 */
-(void) checkEmission: (ccTime) dt {
	if (isEmitting) {
		timeSinceEmission += dt;
		while ( !self.isFull && (timeSinceEmission >= emissionInterval) ) {
			timeSinceEmission -= emissionInterval;
			[self emitParticle];
		}
	}
}

/**
 * If we're not already full, invokes the newParticle method to create a new
 * particle, initializes it, and if it is still alive, adds it to the particles array.
 */
-(BOOL) emitParticle {
	// Can't add particles if there's no space
	if (self.isFull) return NO;
	
	// Emitting will access vertices outside the current elementCount of the
	// vertex array, so set that property to the end of the vertex array.
	// It will be set back to the number of active particles before drawing.
	self.particleMesh.particleCount = maxParticles;
	
	CC3PointParticle* pointParticle = [self newParticle];

	[self initializeParticle: pointParticle];		// Initialize the particle

	// If particle not aborted during initialization increment the particle count
	// and set the particle's normal, if appropriate.
	if (pointParticle.isAlive) {
		particleCount++;
		[self setParticleNormal: pointParticle];
		[self markVerticesDirty];
		return YES;
	} else {
		// Since we haven't added anything, set the mesh back to the right size now.
		// It won't be set later because nothing was changed.
		self.particleMesh.particleCount = particleCount;
		return NO;
	}
}

-(void) initializeParticle: (CC3PointParticle*) aParticle {
	[aParticle initializeParticle];
}

/**
 * Template method to create a new particle, or reuse an existing expired particle.
 * The index of the particle is established, and if it is newly instantiated, the
 * particle is added to the particles array.
 */
-(CC3PointParticle*) newParticle {
	NSAssert1(particleClass, @"%@ does not have its particleClass property assigned. This is needed for instantiating particles.", [self class]);
	CC3PointParticle* particle;
	if (particleCount < particles.count) {

		// Reuse the next available cached particle.
		particle = (CC3PointParticle*)[particles objectAtIndex: particleCount];
		LogTrace(@"%@ reusing particle %u", self, particleCount);

	} else {
		
		// No more cached particles. Instantiate one and add it to the particles collection. 
		particle = [particleClass particleFromEmitter: self];
		[particles addObject: particle];
		LogTrace(@"%@ creating new particle %u", self, particleCount);

	}
	// Initialize for the particle's index and other standard initial state.
	[particle initForIndex: particleCount];
	return particle;
}

/**
 * For each particle, invoke the update: method.
 * If the particle has expired, remove it from the particles array.
 */
-(void) updateParticles: (ccTime) dt {
	GLint i = 0;
	while (i < particleCount) {
		CC3PointParticle* p = [particles objectAtIndex: i];
		
		[p update: dt];
		
		if (p.isAlive) {
			i++;			// Move on to next particle
		} else {
			// Remove the particle from active use and don't increment iterator.
			LogTrace(@"Expiring %@", [p fullDescription]);
			[self removeParticleAtIndex: i];
		}
	}
}

/**
 * Determine the global vector that points from the emitter to the camera,
 * transform it to the local coordinates of the emitter and point the
 * particle normal to the new local camera location.

 * Determines the global direction from the emitter to the camera, transforms it to the
 * local coordinates of the emitter and points the normal vector of the particle to the
 * new local camera location. Each particle normal will point in a slightly different
 * direction, depending on how far the particle is from the origin of the emitter.
 */
-(void) setParticleNormal: (CC3PointParticle*) pointParticle {
	CC3Camera* cam = self.activeCamera;
	if (cam && mesh && mesh.hasNormals) {
		CC3Vector camDir = CC3VectorDifference(cam.globalLocation, self.globalLocation);
		camDir = [self.transformMatrixInverted transformDirection: camDir];
		[pointParticle pointNormalToCameraAt: camDir];
	}
}

/**
 * Determines the global direction from the emitter to the camera. If it has changed,
 * transforms it to the local coordinates of the emitter and points the normal vector
 * of each particle to the new local camera location. Each particle will point in a
 * slightly different direction, depending on how far it is from the origin of the emitter.
 *
 * The camera direction is deemed to have changed if either the transformation matrix of
 * this node has changed (location or rotation change), or if the location of the camera
 * has changed.
 */
-(void) updateParticleNormals: (CC3NodeUpdatingVisitor*) visitor {
	CC3Camera* cam = self.activeCamera;
	if (cam && mesh && mesh.hasNormals) {
		CC3Vector gCamLoc = cam.globalLocation;
		if ( visitor.isTransformDirty || !CC3VectorsAreEqual(gCamLoc, globalCameraLocation) ) {
			globalCameraLocation = gCamLoc;		// Remember the new camera location

			// Get the direction to the camera and transform it to local coordinates
			CC3Vector camDir = CC3VectorDifference(gCamLoc, self.globalLocation);
			camDir = [self.transformMatrixInverted transformDirection: camDir];
			for (CC3PointParticle* p in particles) {
				[p pointNormalToCameraAt: camDir];
			}
		}
	}
}

/**
 * Remove the current particle from the active particles, but keep it cached
 * for future use. To do this, decrement the particle count and swap the current
 * particle with the last living particle. This is done without releasing either
 * particle from the particles collection.
 *
 * The previously-last particle is now in the slot that the removed particle was
 * taken from. Update its index. This will also copy the underlying vertex data
 * of the previously-last particle from its old position in the vertex array to
 * the new position.
 */
-(void) removeParticleAtIndex: (GLuint) anIndex {
	particleCount--;
	[particles exchangeObjectAtIndex: anIndex withObjectAtIndex: particleCount];
	
	CC3PointParticle* p = [particles objectAtIndex: anIndex];
	p.index = anIndex;
	[self markVerticesDirty];
}

/**
 * Updates the particle mesh by updating the particle count, copying the particle
 * vertex data to the GL buffer, and updating the bounding volume of this node.
 */
-(void) updateParticleMesh {
	CC3PointParticleMesh* pm = self.particleMesh;
	if (verticesAreDirty) {
		LogTrace(@"%@ updating mesh with %i particles", self, particleCount);
		pm.particleCount = particleCount;
		[pm updateGLBuffers];
		[self rebuildBoundingVolume];
		verticesAreDirty = NO;
	}
}

/** If transitioning to emitting from not, mark as such and reset timers. */
-(void) setIsEmitting: (BOOL) shouldEmit {
	if (!isEmitting && shouldEmit) {
		elapsedTime = 0.0;
		timeSinceEmission = 0.0;
		wasStarted = YES;
		[self markVerticesDirty];
	}
	isEmitting = shouldEmit;
}

-(void) play {
	self.isEmitting = YES;
}

-(void) pause {
	self.isEmitting = NO;
}

-(void) stop {
	[self pause];						// Stop emitting particles...
	[particles removeAllObjects];		// ...and kill those already emitted.
	particleCount = 0;
}

-(BOOL) isActive {
	return isEmitting || particleCount > 0;
}

// Check for wasStarted needed so it doesn't indicate finished before it starts.
// Otherwise, auto-remove would cause the emitter to be removed immediately.
-(BOOL) isFinished {
	return wasStarted && !self.isActive;
}


#pragma mark Drawing

/** Overridden to test if active as well. If not active, there is nothing to display. */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	return self.isActive && [super doesIntersectFrustum: aFrustum];
}

/** Overridden to set the particle properties in addition to other configuration. */
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[super configureDrawingParameters: visitor];
	[self configureParticleProperties: visitor];
}

/**
 * Enable particles in each texture unit being used by the material,
 * and set GL point size, size attenuation and smoothing.
 */
-(void) configureParticleProperties: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11State* gles11State = gles11Engine.state;

	// Enable point sprites
	[gles11Engine.serverCapabilities.pointSprites enable];

	// Enable texture coordinate replacing in each texture unit used by the material.
	GLuint texCount = material ? material.textureCount : 0;
	for (GLuint texUnit = 0; texUnit < texCount; texUnit++) {
		[[gles11Engine.textures textureUnitAt: texUnit].pointSpriteCoordReplace enable];
	}

	// Set default point size
	gles11State.pointSize.value = [self normalizeParticleSizeToDevice: particleSize];
	
	gles11State.pointSizeMinimum.value = [self normalizeParticleSizeToDevice: particleSizeMinimum];
	gles11State.pointSizeMaximum.value = [self normalizeParticleSizeToDevice: particleSizeMaximum];
	
	// Cast attenuation coefficients to a vector when setting in state tracker
	gles11State.pointSizeAttenuation.value = *(CC3Vector*)&particleSizeAttenuationCoefficients;
	gles11Engine.serverCapabilities.pointSmooth.value = shouldSmoothPoints;
}

-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[super cleanupDrawingParameters: visitor];
	[self cleanupParticleProperties: visitor];
}

/** Disable particles again in each texture unit being used by the material. */
-(void) cleanupParticleProperties: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];

	// Disable point sprites again
	[gles11Engine.serverCapabilities.pointSprites disable];

	// Disable texture coordinate replacing again in each texture unit used by the material.
	GLuint texCount = material ? material.textureCount : 0;
	for (GLuint texUnit = 0; texUnit < texCount; texUnit++) {
		[[gles11Engine.textures textureUnitAt: texUnit].pointSpriteCoordReplace disable];
	}
}

#define kCC3DeviceScaleFactorBase 480.0f
static GLfloat deviceScaleFactor = 0.0f;

/**
 * The scaling factor used to adjust the particle size so that it is drawn at a consistent
 * size across all device screen resolutions, if the  shouldNormalizeParticleSizesToDevice
 * property of the emitter is set to YES.
 *
 * The value returned depends on the device screen window size and is normalized to the
 * original iPhone/iPod Touch screen size of 480 x 320. The value returned for an original
 * iPhone or iPod Touch will be 1.0. The value returned for other devices depends on the
 * screen resolution, and formally, on the screen height as measured in pixels.
 * Devices with larger screen heights in pixels will return a value greater than 1.0.
 * Devices with smaller screen heights in pixels will return a value less than 1.0
 */
+(GLfloat) deviceScaleFactor {
	if (deviceScaleFactor == 0.0f) {
		CGSize winSz = [[CCDirector sharedDirector] winSizeInPixels];
		deviceScaleFactor = MAX(winSz.height, winSz.width) / kCC3DeviceScaleFactorBase;
	}
	return deviceScaleFactor;
}

/**
 * Converts the specified nominal particle size to a device-normalized size,
 * if the shouldNormalizeParticleSizesToDevice property is set to YES.
 *
 * For speed, this method accesses the deviceScaleFactor static variable directly.
 * the deviceScaleFactor method must be invoked once before this access occurs
 * in order to initialize this value correctly.
 */
-(GLfloat) normalizeParticleSizeToDevice: (GLfloat) aSize {
	return shouldNormalizeParticleSizesToDevice ? (aSize * deviceScaleFactor) : aSize;
}

/**
 * Converts the specified device-normalized particle size to a consistent nominal size,
 * if the shouldNormalizeParticleSizesToDevice property is set to YES.
 *
 * For speed, this method accesses the deviceScaleFactor static variable directly.
 * the deviceScaleFactor method must be invoked once before this access occurs
 * in order to initialize this value correctly.
 */
-(GLfloat) denormalizeParticleSizeFromDevice: (GLfloat) aSize {
	return shouldNormalizeParticleSizesToDevice ? (aSize / deviceScaleFactor) : aSize;
}

#pragma mark Wireframe box and descriptor

/** Overridden to set the wireframe to automatically update as parent changes. */
-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {
	[super setShouldDrawLocalContentWireframeBox: shouldDraw];
	self.localContentWireframeBoxNode.shouldAlwaysMeasureParentBoundingBox = YES;
}

@end


#pragma mark -
#pragma mark CC3PointParticleMesh

@interface CC3VertexArrayMesh (TemplateMethods)
-(void) populateFrom: (CC3VertexArrayMesh*) another;
-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLsizei) elemCount;
@end

@implementation CC3PointParticleMesh

@synthesize vertexPointSizes;

-(void) dealloc {
	[vertexPointSizes release];
	[super dealloc];
}

-(GLsizei) particleCount {
	return vertexLocations.elementCount;
}

-(void) setParticleCount: (GLsizei) numParticles {
	vertexLocations.elementCount = numParticles;
	vertexNormals.elementCount = numParticles;
	vertexColors.elementCount = numParticles;
	vertexPointSizes.elementCount = numParticles;
}

-(BOOL) hasPointSizes {
	return (vertexPointSizes != nil);
}


#pragma mark Allocation and initialization

-(void) populateForMaxParticles: (GLuint) numParticles
					 containing: (CC3PointParticleVertexContent) contentTypes {

	NSString* itemName;
	GLsizei stride = 0;

	// Always create vertex location array.
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	self.vertexLocations = [CC3VertexLocations vertexArrayWithName: itemName];
	vertexLocations.drawingMode = GL_POINTS;	// Draw as points
	vertexLocations.elementOffset = stride;		// Offset to location in vertex structure
	stride += sizeof(CC3Vector);				// Add size of location element to stride.
	
	// If each particle is to have a normal, create a vertex colors array.
	if (contentTypes & kCC3PointParticleContentNormal) {
		itemName = [NSString stringWithFormat: @"%@-Normals", self.name];
		self.vertexNormals = [CC3VertexNormals vertexArrayWithName: itemName];
		vertexNormals.elementOffset = stride;	// Offset to normal in vertex structure
		stride += sizeof(CC3Vector);			// Add size of normal element to stride.
	} else {
		self.vertexNormals = nil;
	}
	
	// If each particle is to have its own color, create a vertex colors array.
	if (contentTypes & kCC3PointParticleContentColor) {
		itemName = [NSString stringWithFormat: @"%@-Colors", self.name];
		self.vertexColors = [CC3VertexColors vertexArrayWithName: itemName];
		vertexColors.elementType = GL_UNSIGNED_BYTE;	// Colors as bytes
		vertexColors.elementOffset = stride;			// Offset to color in vertex structure
		stride += sizeof(ccColor4B);					// Build up stride from contents.
	} else {
		self.vertexColors = nil;
	}
	
	// If each particle is to have its own size, create a vertex sizes array.
	if (contentTypes & kCC3PointParticleContentSize) {
		itemName = [NSString stringWithFormat: @"%@-Sizes", self.name];
		self.vertexPointSizes = [CC3VertexPointSizes vertexArrayWithName: itemName];
		vertexPointSizes.elementOffset = stride;			// Offset to particle size in vertex structure
		stride += sizeof(GLfloat);							// Build up stride from contents.
	} else {
		self.vertexPointSizes = nil;
	}

	interleaveVertices = YES;		// Interleave the vertex data

	// Configure all the vertex arrays for use as updatable point particle data
	vertexLocations.shouldReleaseRedundantData = NO;	// Retain vertex data in memory.
	vertexNormals.shouldReleaseRedundantData = NO;		// Retain vertex data in memory.
	vertexColors.shouldReleaseRedundantData = NO;		// Retain vertex data in memory.
	vertexPointSizes.shouldReleaseRedundantData = NO;	// Retain vertex data in memory.
		
	// We'll almost certainly be updating vertices in the buffer.
	vertexLocations.bufferUsage = GL_DYNAMIC_DRAW;
	
	// Set all vertex arrays to full stride for interleaved data.
	// Set this before allocating memory.
	vertexLocations.elementStride = stride;
	vertexNormals.elementStride = stride;
	vertexColors.elementStride = stride;
	vertexPointSizes.elementStride = stride;
	
	// Allocate vertex memory and set all vertex arrays to point to it
	[vertexLocations allocateElements: numParticles];
	
	vertexNormals.elements = vertexLocations.elements;
	vertexNormals.elementCount = vertexLocations.elementCount;

	vertexColors.elements = vertexLocations.elements;
	vertexColors.elementCount = vertexLocations.elementCount;
	
	vertexPointSizes.elements = vertexLocations.elements;
	vertexPointSizes.elementCount = vertexLocations.elementCount;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3PointParticleMesh*) another {
	[super populateFrom: another];
	
	// Share vertex arrays between copies
	self.vertexPointSizes = another.vertexPointSizes;		// retained but not copied
}

/**
 * If the interleaveVertices property is set to NO, creates GL vertex buffer object for
 * the point size vertex array by invoking createGLBuffer.
 *
 * If the interleaveVertices property is set to YES, indicating that the underlying data
 * is shared across the contained vertex arrays, the bufferID property of the point sizes
 * vertex array is copied from the vertexLocations vertex array.
 */
-(void) createGLBuffers {
	[super createGLBuffers];
	if (interleaveVertices) {
		vertexPointSizes.bufferID = vertexLocations.bufferID;
	} else {
		[vertexPointSizes createGLBuffer];
	}
}

-(void) deleteGLBuffers {
	[super deleteGLBuffers];
	[vertexPointSizes deleteGLBuffer];
}

-(void) releaseRedundantData {
	[super releaseRedundantData];
	[vertexPointSizes releaseRedundantData];
}

-(void) retainVertexPointSizes {
	vertexPointSizes.shouldReleaseRedundantData = NO;
}

-(void) doNotBufferVertexPointSizes {
	if (interleaveVertices) {
		[self doNotBufferVertexLocations];
	} else {
		vertexPointSizes.shouldAllowVertexBuffering = NO;
	}
}


#pragma mark Accessing vertex data

-(GLfloat) particleSizeAt: (GLsizei) index {
	return vertexPointSizes ? [vertexPointSizes pointSizeAt: index] : 0.0f;
}

-(void) setParticleSize: (GLfloat) aSize at: (GLsizei) index {
	[vertexPointSizes setPointSize: aSize at: index];
}

-(void) updateParticleSizesGLBuffer {
	[vertexPointSizes updateGLBuffer];
}


#pragma mark Updating

-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLsizei) vertexCount {
	[super updateGLBuffersStartingAt: offsetIndex forLength: vertexCount];
	if (!interleaveVertices) {
		[vertexPointSizes updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
	}
}


#pragma mark Drawing

/**
 * Template method that binds a pointer to the vertex point size data to the GL engine.
 * If this mesh has no vertex point size data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexPointSizes unbind class method.
 */
-(void) bindPointSizesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (vertexPointSizes) {
		[vertexPointSizes bindWithVisitor: visitor];
	} else {
		[CC3VertexPointSizes unbind];
	}
}

@end


#pragma mark -
#pragma mark CC3PointParticle

@implementation CC3PointParticle

@synthesize emitter, index, isAlive;

-(void) dealloc {
	emitter = nil;			// not retained
	[super dealloc];
}

-(CC3Vector) location {
	return [emitter vertexLocationAt: index];
}

-(void) setLocation: (CC3Vector) aLocation {
	[emitter setVertexLocation: aLocation at: index];
}

-(CC3Vector) normal {
	return [emitter vertexNormalAt: index];
}

-(void) setNormal: (CC3Vector) aNormal {
	[emitter setVertexNormal: aNormal at: index];
}

-(BOOL) hasNormal {
	return emitter.particleMesh.hasNormals;
}

-(ccColor4F) color4F {
	return self.hasColor
				? [emitter vertexColor4FAt: index]
				: emitter.diffuseColor;
}

-(void) setColor4F: (ccColor4F) aColor {
	[emitter setVertexColor4F: aColor at: index];
}

-(ccColor4B) color4B {
	return self.hasColor
				? [emitter vertexColor4BAt: index]
				: CCC4BFromCCC4F(emitter.diffuseColor);
}

-(void) setColor4B: (ccColor4B) aColor {
	[emitter setVertexColor4B: aColor at: index];
}

-(BOOL) hasColor {
	return emitter.particleMesh.hasColors;
}

-(GLfloat) size {
	return self.hasSize
				? [emitter particleSizeAt: index]
				: emitter.particleSize;
}

-(void) setSize: (GLfloat) aSize {
	[emitter setParticleSize: aSize at: index];
}

-(BOOL) hasSize {
	return emitter.particleMesh.hasPointSizes;
}

/**
 * When the index changes, the reference to the underlying vertex data contained
 * in the vertex arrays changes. We need to move the vertex data from the old
 * vertex to the new vertex. To do this, we read the vertex data into temporary
 * variables using the current index, set the new index, and set the vertx data
 * back into the array. It will be saved in the new vertex.
 */
-(void) setIndex: (GLuint) anIndex {
	CC3Vector myLoc = self.location;
	CC3Vector myNorm = self.normal;
	ccColor4F myColor = self.color4F;
	GLfloat mySize = self.size;
	
	index = anIndex;
	
	self.location = myLoc;
	self.normal = myNorm;
	self.color4F = myColor;
	self.size = mySize;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ at index %i", [self class], index];
}

- (NSString*) fullDescription {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@", [self description]];
	[desc appendFormat:@"\n\tlocation: %@", NSStringFromCC3Vector(self.location)];
	if (self.hasColor) {
		[desc appendFormat:@", colored: %@", NSStringFromCCC4F(self.color4F)];
	}
	if (self.hasNormal) {
		[desc appendFormat:@", normal: %@", NSStringFromCC3Vector(self.normal)];
	}
	if (self.hasSize) {
		[desc appendFormat:@", size: %.3f", self.size];
	}
	return desc;
}


#pragma mark Allocation and initialization

-(id) init {
	NSAssert1(NO, @"Cannot instantiate %@ using init. Use initFromEmitter:atIndex: instead.", [self class]);
	return nil;
}

-(id) initFromEmitter: (CC3PointParticleEmitter*) anEmitter {
	if ( (self = [super init]) ) {
		emitter = anEmitter;			// not retained
	}
	return self;
}

+(id) particleFromEmitter: (CC3PointParticleEmitter*) anEmitter {
	return [[[self alloc] initFromEmitter: anEmitter] autorelease];
}

/** 
 * Initialize the index, the underlying vertex values, and the isAlive indicator.
 *
 * This is invoked during instance initialization, and also when a cached
 * instance is re-initialized for reuse.
 */
-(void) initForIndex: (GLuint) anIndex {
	index = anIndex;
	self.location = kCC3VectorZero;
	self.normal = kCC3VectorZero;
	self.color4F = emitter.diffuseColor;
	self.size = emitter.particleSize;
	isAlive = YES;
}

-(void) initializeParticle {
	LogTrace(@"Initialized %@", [self fullDescription]);
}


#pragma mark Updating

-(void) update: (ccTime) dt {}

/**
 * Invoked automatically if the particle has vertex normal content to point the 
 * normal vector of the particle at the camera, which is at the specified location,
 * expressed in terms of the local coordinate system of the emitter. This is a
 * vector pointing from the emitter to the camera.
 *
 * To point the particle itself at the camera, we use vector math. The vector from
 * the emitter to the particle is subtracted from the vector from the emitter to
 * the camera. The result is a vector that points from the particle to the camera.
 * This vector is normalized and set in the normal property.
 */
-(void) pointNormalToCameraAt: (CC3Vector) camLoc {
	self.normal = CC3VectorNormalize(CC3VectorDifference(camLoc, self.location));
}

@end


#pragma mark -
#pragma mark CC3MortalPointParticle

@implementation CC3MortalPointParticle

@synthesize lifeSpan, timeToLive;

-(void) setLifeSpan: (ccTime) anInterval {
	lifeSpan = anInterval;
	timeToLive = lifeSpan;
}

-(void) update: (ccTime) dt {
	timeToLive -= dt;
	if (timeToLive > 0.0) {
		[self updateLife: dt];
	} else {
		self.isAlive = NO;
	}
}

-(void) updateLife: (ccTime) dt {}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tlifeSpan: %.3f, timeToLive: %.3f",
			[super fullDescription], lifeSpan, timeToLive];
}


@end


#pragma mark -
#pragma mark CC3MortalPointParticleEmitter

@interface CC3PointParticleEmitter (TempalteMethods)
-(void) checkEmission: (ccTime) dt;
@end

@implementation CC3MortalPointParticleEmitter

@synthesize minParticleLifeSpan, maxParticleLifeSpan;

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		minParticleLifeSpan = 0.0f;
		maxParticleLifeSpan = 0.0f;
	}
	return self;
}

-(id) particleClass {
	return [CC3MortalPointParticle class];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3MortalPointParticleEmitter*) another {
	[super populateFrom: another];

	minParticleLifeSpan = another.minParticleLifeSpan;
	maxParticleLifeSpan = another.maxParticleLifeSpan;
}

/**
 * Casts to a CC3MortalPointParticle, sets the lifeSpan property, invokes
 * the initializeMortalParticle: method, and then invokes the superclass
 * implementation, which invokes initializeParticle on the particle.
 */
-(void) initializeParticle: (CC3PointParticle*) aParticle {
	CC3MortalPointParticle* mp = (CC3MortalPointParticle*)aParticle;
	mp.lifeSpan = CC3RandomFloatBetween(minParticleLifeSpan, maxParticleLifeSpan);
	[self initializeMortalParticle: mp];
	[super initializeParticle: aParticle];
}

-(void) initializeMortalParticle: (CC3MortalPointParticle*) aParticle {}

@end


#pragma mark -
#pragma mark CC3UniformMotionParticle

@implementation CC3UniformMotionParticle

@synthesize velocity;

-(void) updateLife: (ccTime) dt {
	self.location = CC3VectorAdd(self.location, CC3VectorScaleUniform(self.velocity, dt));
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tvelocity: %@",
			[super fullDescription], NSStringFromCC3Vector(velocity)];
}

@end


#pragma mark -
#pragma mark CC3UniformEvolutionParticle

@implementation CC3UniformEvolutionParticle

@synthesize colorVelocity, sizeVelocity;

-(void) updateLife: (ccTime) dt {
	[super updateLife: dt];
	
	if (self.hasColor) {
		// We have to do the math on each component instead of using the color math functions
		// because the functions clamp prematurely, and we need negative values for the velocity.
		ccColor4F currColor = self.color4F;
		self.color4F = CCC4FMake(CLAMP(currColor.r + (colorVelocity.r * dt), 0.0, 1.0),
								 CLAMP(currColor.g + (colorVelocity.g * dt), 0.0, 1.0),
								 CLAMP(currColor.b + (colorVelocity.b * dt), 0.0, 1.0),
								 CLAMP(currColor.a + (colorVelocity.a * dt), 0.0, 1.0));
	}
	
	if (self.hasSize) {
		self.size = self.size + (sizeVelocity * dt);
	}
	
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@, colorVelocity: %@, sizeVelocity: %.3f",
			[super fullDescription], NSStringFromCCC4F(colorVelocity), sizeVelocity];
}

@end
