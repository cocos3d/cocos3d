/*
 * CC3PointParticles.m
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
 * See header file CC3PointParticles.h for full API documentation.
 */

#import "CC3PointParticles.h"
#import "CCDirector.h"


@interface CC3Node (TemplateMethods)
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
@end

@interface CC3ParticleEmitter (TemplateMethods)
-(void) updateParticlesBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;
-(void) addDirtyVertex: (GLuint) vtxIdx;
-(void) addDirtyVertexIndex: (GLuint) vtxIdx;
-(void) removeParticle: (id<CC3ParticleProtocol>) aParticle atIndex: (GLuint) anIndex;
-(void) acceptParticle: (id<CC3ParticleProtocol>) aParticle;
@end


#pragma mark -
#pragma mark CC3PointParticleEmitter

@implementation CC3PointParticleEmitter

@synthesize particleSize=_particleSize, shouldSmoothPoints=_shouldSmoothPoints;
@synthesize particleSizeMinimum=_particleSizeMinimum, particleSizeMaximum=_particleSizeMaximum;
@synthesize particleSizeAttenuation=_particleSizeAttenuation;
@synthesize shouldNormalizeParticleSizesToDevice=_shouldNormalizeParticleSizesToDevice;

-(GLfloat) normalizedParticleSize {
	return [self normalizeParticleSizeToDevice: self.particleSize];
}

-(GLfloat) normalizedParticleSizeMinimum {
	return [self normalizeParticleSizeToDevice: self.particleSizeMinimum];
}

-(GLfloat) normalizedParticleSizeMaximum {
	return [self normalizeParticleSizeToDevice: self.particleSizeMaximum];
}


-(Protocol*) requiredParticleProtocol { return @protocol(CC3PointParticleProtocol); }

// Deprecated
-(CC3PointParticleMesh*) particleMesh { return (CC3PointParticleMesh*)self.mesh; }

// Deprecated property
-(CC3AttenuationCoefficients) particleSizeAttenuationCoefficients { return self.particleSizeAttenuation; }
-(void) setParticleSizeAttenuationCoefficients: (CC3AttenuationCoefficients) attenuationCoefficients {
	self.particleSizeAttenuation = attenuationCoefficients;
}

-(GLfloat) unityScaleDistance {
	GLfloat sqDistAtten = _particleSizeAttenuation.c;
	return (sqDistAtten > 0.0f) ? sqrt(1.0 / sqDistAtten) : 0.0f;
}

-(void) setUnityScaleDistance: (GLfloat) aDistance {
	if (aDistance > 0.0)
		_particleSizeAttenuation = (CC3AttenuationCoefficients){0.0, 0.0, 1.0 / (aDistance * aDistance)};
	else
		_particleSizeAttenuation = kCC3AttenuationNone;
}

// Deprecated
-(CC3VertexContent) particleContentTypes { return self.vertexContentTypes; }
-(GLuint) maxParticles { return self.maximumParticleCapacity; }


#pragma mark Vertex management

// Overridden to retain all vertex content in memory.
-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	super.vertexContentTypes = vtxContentTypes;
	self.drawingMode = GL_POINTS;
}


#pragma mark Accessing vertex data

-(GLfloat) particleSizeAt: (GLuint) vtxIndex {
	return _mesh ? [self denormalizeParticleSizeFromDevice: [_mesh vertexPointSizeAt: vtxIndex]] : 0.0f;
}

-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex {
	[_mesh setVertexPointSize: [self normalizeParticleSizeToDevice: aSize] at: vtxIndex];
	[self addDirtyVertex: vtxIndex];
}

-(void) updateParticleSizesGLBuffer { [self.mesh updatePointSizesGLBuffer]; }

-(void) retainVertexPointSizes {
	[self.mesh retainVertexPointSizes];
	[super retainVertexPointSizes];
}

-(void) doNotBufferVertexPointSizes {
	[self.mesh doNotBufferVertexPointSizes];
	[super doNotBufferVertexPointSizes];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_globalCameraLocation = kCC3VectorNull;
		_areParticleNormalsDirty = NO;
		self.particleSize = kCC3DefaultParticleSize;
		_particleSizeMinimum = kCC3ParticleSizeMinimumNone;
		_particleSizeMaximum = kCC3ParticleSizeMaximumNone;
		_particleSizeAttenuation = kCC3AttenuationNone;
		_shouldSmoothPoints = NO;
		_shouldNormalizeParticleSizesToDevice = YES;
		_shouldDisableDepthMask = YES;
		[[self class] deviceScaleFactor];	// Force init the static deviceScaleFactor before accessing it.
		[self ensureMaterial];				// We need blending, so start with a material.
	}
	return self;
}

/** Overridden to configure for blending. */
-(CC3Material*) makeMaterial {
	CC3Material* mat = [CC3Material material];
	mat.diffuseColor = kCCC4FWhite;
	mat.sourceBlend = GL_SRC_ALPHA;
	mat.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
	return mat;
}

// Implementation of deprecated method, for other deprecated methods to invoke
-(void) deprecatedPopulateForMaxParticles: (GLuint) numParticles
								   ofType: (Class) aParticleClass
							   containing: (CC3VertexContent) contentTypes {
	[self stop];
	self.particleClass = aParticleClass;
	self.vertexContentTypes = contentTypes;
	self.maximumParticleCapacity = numParticles;
}

-(void) populateForMaxParticles: (GLuint) numParticles
						 ofType: (id) aParticleClass
					 containing: (CC3VertexContent) contentTypes {
	[self deprecatedPopulateForMaxParticles: numParticles
									 ofType: aParticleClass
								 containing: contentTypes];
}

-(void) populateForMaxParticles: (GLuint) numParticles ofType: (id) aParticleClass {
	[self deprecatedPopulateForMaxParticles: numParticles
									 ofType: aParticleClass
								 containing: kCC3VertexContentLocation];
}

-(void) populateForMaxParticles: (GLuint) numParticles
					 containing: (CC3VertexContent) contentTypes {
	[self deprecatedPopulateForMaxParticles: numParticles
									 ofType: [self particleClass]
								 containing: contentTypes];
}

-(void) populateForMaxParticles: (GLuint) numParticles {
	[self deprecatedPopulateForMaxParticles: numParticles
									 ofType: [self particleClass]
								 containing: kCC3VertexContentLocation];
}
	
-(void) populateFrom: (CC3PointParticleEmitter*) another {
	[super populateFrom: another];
	
	_particleSize = another.particleSize;
	_particleSizeMinimum = another.particleSizeMinimum;
	_particleSizeMaximum = another.particleSizeMaximum;
	_shouldSmoothPoints = another.shouldSmoothPoints;
	_shouldNormalizeParticleSizesToDevice = another.shouldNormalizeParticleSizesToDevice;
	_particleSizeAttenuation = another.particleSizeAttenuation;
}


#pragma mark Updating

-(void) initializeParticle: (id<CC3PointParticleProtocol>) aPointParticle {
	[super initializeParticle: aPointParticle];
	
	// particleCount not yet incremented, so it points to this particle
	aPointParticle.particleIndex = _particleCount;

	// Set the particle size directly so the CC3PointParticleProtocol does not need to support size
	[self setParticleSize: self.particleSize at: _particleCount];
}

/** Marks the range of vertices in the underlying mesh that are affected by this particle. */
-(void) acceptParticle: (id<CC3PointParticleProtocol>) aParticle {
	[super acceptParticle: aParticle];
	[self setParticleNormal: aParticle];
}

/** Returns whether this mesh is making use of normals and lighting. */
-(BOOL) hasIlluminatedNormals { return _mesh && _mesh.hasVertexNormals && self.shouldUseLighting; }

-(void) markTransformDirty {
	[super markTransformDirty];
	_areParticleNormalsDirty = YES;
}

-(void) nodeWasTransformed: (CC3Node*) aNode {
	[super nodeWasTransformed: aNode];
	if (aNode.isCamera) {
		_globalCameraLocation = aNode.globalLocation;
		_areParticleNormalsDirty = YES;
	}
}

/** Overridden to update the normals of the particles before the GL mesh is updated by parent.  */
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateParticleNormals: visitor];
	[super processUpdateAfterTransform: visitor];
}

/**
 * If the particles have normals that interact with lighting, and the global direction from the
 * emitter to the camera has changed (by a movement of either the emitter or the camera), this
 * method transforms that direction to the local coordinates of the emitter and points the normal
 * vector of each particle to the new local camera direction. Each particle will point in a slightly
 * different direction, depending on how far it is from the origin of the emitter.
 */
-(void) updateParticleNormals: (CC3NodeUpdatingVisitor*) visitor {
	if (self.hasIlluminatedNormals) {
		// If we haven't already registered as a camera listener, do so now.
		// Get the current cam location, because cam might not immediately callback.
		if (CC3VectorIsNull(_globalCameraLocation)) {
			CC3Camera* cam = self.activeCamera;
			_globalCameraLocation = cam.globalLocation;
			[cam addTransformListener: self];
			LogTrace(@"%@ registered as listener of camera at %@",
						  self, NSStringFromCC3Vector(_globalCameraLocation));
		}

		if (_areParticleNormalsDirty) {
			LogTrace(@"%@ updating particle normals from camera location %@",
						  self, NSStringFromCC3Vector(_globalCameraLocation));
			
			// Get the direction to the camera and transform it to local coordinates
			CC3Vector camDir = CC3VectorDifference(_globalCameraLocation, self.globalLocation);
			camDir = [self.globalTransformMatrixInverted transformDirection: camDir];
			for (id<CC3PointParticleProtocol> p in _particles) [p pointNormalAt: camDir];
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
-(void) setParticleNormal: (id<CC3PointParticleProtocol>) pointParticle {
	if (self.hasIlluminatedNormals) {
		CC3Vector camDir = CC3VectorDifference(_globalCameraLocation, self.globalLocation);
		camDir = [self.globalTransformMatrixInverted transformDirection: camDir];
		[pointParticle pointNormalAt: camDir];
	}
}


#pragma mark Accessing particles

-(id<CC3PointParticleProtocol>) pointParticleAt: (GLuint) aParticleIndex {
	return (id<CC3PointParticleProtocol>)[self particleAt: aParticleIndex];
}

/**
 * Remove the current particle from the active particles, but keep it cached for future use.
 * To do this, decrement the particle count and swap the current particle with the last living
 * particle. This is done without releasing either particle from the particles collection.
 *
 * The previously-last particle is now in the slot that the removed particle was taken from,
 * and vice-versa. Update their indices, and move the underlying vertex data.
 */
-(void) removeParticle: (id<CC3PointParticleProtocol>) aParticle atIndex: (GLuint) anIndex {
	[super removeParticle: aParticle atIndex: anIndex];		// Decrements particleCount and vertexCount
	
	// Get the last living particle
	id<CC3PointParticleProtocol> lastParticle = [self pointParticleAt: _particleCount];
	
	// Swap the particles in the particles array
	[_particles exchangeObjectAtIndex: anIndex withObjectAtIndex: _particleCount];
	
	// Update the particle's index. This also updates the vertex indices array, if it exists.
	aParticle.particleIndex = _particleCount;
	lastParticle.particleIndex = anIndex;
	
	// Update the underlying mesh
	[self.mesh copyVertices: 1 from: _particleCount to: anIndex];
	
	// Mark the vertex and vertex indices as dirty
	[self addDirtyVertex: anIndex];
	[self addDirtyVertexIndex: anIndex];
}


#pragma mark Drawing

/** Overridden to set the particle properties in addition to other configuration. */
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[super configureDrawingParameters: visitor];
	[self configurePointProperties: visitor];
}

/**
 * Enable particles in each texture unit being used by the material,
 * and set GL point size, size attenuation and smoothing.
 */
-(void) configurePointProperties: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;

	// Enable point sprites and shader point sizing (gl_PointSize) for OGL
	[gl enablePointSprites: YES];
	[gl enableShaderPointSize: YES];

	// Enable texture coordinate replacing in each texture unit used by the material.
	GLuint texCount = _material ? _material.textureCount : 0;
	for (GLuint texUnit = 0; texUnit < texCount; texUnit++)
		[gl enablePointSpriteCoordReplace: YES at: texUnit];
	
	// Set default point size
	gl.pointSize = self.normalizedParticleSize;
	gl.pointSizeMinimum = self.normalizedParticleSizeMinimum;
	gl.pointSizeMaximum = self.normalizedParticleSizeMaximum;
	gl.pointSizeAttenuation = _particleSizeAttenuation;
	[gl enablePointSmoothing: _shouldSmoothPoints];
}

-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[super cleanupDrawingParameters: visitor];
	[self cleanupPointProperties: visitor];
}

/** Disable particles again in each texture unit being used by the material. */
-(void) cleanupPointProperties: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;

	// Disable point sprites again, but leave point sizing enabled
	[gl enablePointSprites: NO];

	// Disable texture coordinate replacing again in each texture unit used by the material.
	GLuint texCount = _material ? _material.textureCount : 0;
	for (GLuint texUnit = 0; texUnit < texCount; texUnit++)
		[gl enablePointSpriteCoordReplace: NO at: texUnit];
}

#define kCC3DeviceScaleFactorBase 480.0f
static GLfloat _deviceScaleFactor = 0.0f;

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
	if (_deviceScaleFactor == 0.0f) {
		CGSize viewSize = CCDirector.sharedDirector.viewSizeInPixels;
		_deviceScaleFactor = MAX(viewSize.height, viewSize.width) / kCC3DeviceScaleFactorBase;
	}
	return _deviceScaleFactor;
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
	return _shouldNormalizeParticleSizesToDevice ? (aSize * _deviceScaleFactor) : aSize;
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
	return _shouldNormalizeParticleSizesToDevice ? (aSize / _deviceScaleFactor) : aSize;
}

@end


#pragma mark -
#pragma mark CC3PointParticle

/** Re-declaration of deprecated methods to suppress compiler warnings within this class. */
@protocol CC3PointParticleDeprecated
-(void) update: (CCTime) dt;
@end

@implementation CC3PointParticle

-(CC3PointParticleEmitter*) emitter { return (CC3PointParticleEmitter*)_emitter; }

-(void) setEmitter: (CC3PointParticleEmitter*) anEmitter {
	CC3Assert([anEmitter isKindOfClass: [CC3PointParticleEmitter class]], @"%@ may only be emitted by a CC3PointParticleEmitter.", self);
	super.emitter = anEmitter;
}

-(BOOL) isAlive { return _isAlive; }

-(void) setIsAlive: (BOOL) alive { _isAlive = alive; }

-(GLuint) particleIndex { return _particleIndex; }

/** Overridden to update the underlying vertex indices array, if it exists. */
-(void) setParticleIndex: (GLuint) anIndex {
	_particleIndex = anIndex;
	[_emitter setVertexIndex: anIndex at: anIndex];	// Ignored if not using indexed drawing
}

-(GLuint) vertexCount { return 1; }

-(NSRange) vertexRange { return NSMakeRange(_particleIndex, self.vertexCount); }

-(GLuint) vertexIndexCount { return 1; }

-(NSRange) vertexIndexRange { return NSMakeRange(_particleIndex, self.vertexIndexCount); }

-(CC3Vector) location { return [_emitter vertexLocationAt: _particleIndex]; }

-(void) setLocation: (CC3Vector) aLocation { [_emitter setVertexLocation: aLocation at: _particleIndex]; }

-(CC3Vector) normal { return [_emitter vertexNormalAt: _particleIndex]; }

-(void) setNormal: (CC3Vector) aNormal { [_emitter setVertexNormal: aNormal at: _particleIndex]; }

-(BOOL) hasNormal { return _emitter.mesh.hasVertexNormals; }

-(ccColor4F) color4F { return self.hasColor ? [_emitter vertexColor4FAt: _particleIndex] : [super color4F]; }

-(void) setColor4F: (ccColor4F) aColor { [_emitter setVertexColor4F: aColor at: _particleIndex]; }

-(ccColor4B) color4B { return self.hasColor ? [_emitter vertexColor4BAt: _particleIndex] : [super color4B]; }

-(void) setColor4B: (ccColor4B) aColor { [_emitter setVertexColor4B: aColor at: _particleIndex]; }

-(GLfloat) size {
	CC3PointParticleEmitter* pe = self.emitter;
	return self.hasSize ? [pe particleSizeAt: _particleIndex] : pe.particleSize;
}

-(void) setSize: (GLfloat) aSize { [self.emitter setParticleSize: aSize at: _particleIndex]; }

-(BOOL) hasSize { return self.emitter.mesh.hasVertexPointSizes; }

-(BOOL) hasVertexIndices { return NO; }

// Deprecated property
-(GLuint) index { return self.particleIndex; }
-(void) setIndex: (GLuint) anIdx { self.particleIndex = anIdx; }

// Deprecated
-(void) update: (CCTime) dt {}

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[(id<CC3PointParticleDeprecated>)self update: visitor.deltaTime];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ at index %i", [super description], _particleIndex];
}

- (NSString*) fullDescription {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@", [self description]];
	[desc appendFormat:@"\n\tlocation: %@", NSStringFromCC3Vector(self.location)];
	if (self.hasColor) [desc appendFormat:@", colored: %@", NSStringFromCCC4F(self.color4F)];
	if (self.hasNormal) [desc appendFormat:@", normal: %@", NSStringFromCC3Vector(self.normal)];
	if (self.hasSize) [desc appendFormat:@", size: %.3f", self.size];
	return desc;
}


#pragma mark Updating

-(void) pointNormalAt: (CC3Vector) camLoc {
	self.normal = CC3VectorNormalize(CC3VectorDifference(camLoc, self.location));
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_particleIndex = 0;
	}
	return self;
}

// Deprecated
-(id) initFromEmitter: (CC3PointParticleEmitter*) anEmitter {
	if ( (self = [self init]) ) {
		self.emitter = anEmitter;			// weak reference
	}
	return self;
}

// Deprecated
+(id) particleFromEmitter: (CC3PointParticleEmitter*) anEmitter {
	return [[[self alloc] initFromEmitter: anEmitter] autorelease];
}

-(void) populateFrom: (CC3PointParticle*) another {
	[super populateFrom: another];
	_particleIndex = another.particleIndex;
}

@end


#pragma mark -
#pragma mark Deprecated CC3PointParticleMesh

@implementation CC3PointParticleMesh

// Deprecated
-(GLuint) particleCount { return self.vertexCount; }
-(void) setParticleCount: (GLuint) numParticles { self.vertexCount = numParticles; }
-(GLfloat) particleSizeAt: (GLuint) vtxIndex { return [self vertexPointSizeAt: vtxIndex]; }
-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex { [self setVertexPointSize: aSize at: vtxIndex]; }
-(void) updateParticleSizesGLBuffer { [self updatePointSizesGLBuffer]; }

@end

