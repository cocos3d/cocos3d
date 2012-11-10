/*
 * CC3PointParticles.m
 *
 * cocos3d 0.7.2
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
 * See header file CC3PointParticles.h for full API documentation.
 */

#import "CC3PointParticles.h"
#import "CC3OpenGLES11Engine.h"
#import "CCDirector.h"


@interface CC3PointParticle (TemplateMethods)
/** @deprecated Use emitter instead. */
@property(nonatomic, readonly) CC3PointParticleEmitter* pointEmitter DEPRECATED_ATTRIBUTE;
@end

@interface CC3Node (TemplateMethods)
-(void) transformMatrixChanged;
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) ensureMaterial;
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
@end

@interface CC3ParticleEmitter (TemplateMethods)
-(void) updateParticlesBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;
-(void) addDirtyVertex: (NSUInteger) vtxIdx;
-(void) addDirtyVertexIndex: (NSUInteger) vtxIdx;
-(void) removeParticle: (id<CC3ParticleProtocol>) aParticle atIndex: (NSUInteger) anIndex;
-(void) acceptParticle: (id<CC3ParticleProtocol>) aParticle;
@end


#pragma mark -
#pragma mark CC3PointParticleEmitter

@interface CC3PointParticleEmitter (TemplateMethods)
@property(nonatomic, readonly) BOOL hasIlluminatedNormals;
-(void) configurePointProperties: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupPointProperties: (CC3NodeDrawingVisitor*) visitor;
-(void) setParticleNormal: (id<CC3PointParticleProtocol>) pointParticle;
-(void) updateParticleNormals: (CC3NodeUpdatingVisitor*) visitor;
-(GLfloat) normalizeParticleSizeToDevice: (GLfloat) aSize;
-(GLfloat) denormalizeParticleSizeFromDevice: (GLfloat) aSize;
+(GLfloat) deviceScaleFactor;
@end

@implementation CC3PointParticleEmitter

@synthesize particleSize, particleSizeMinimum, particleSizeMaximum;
@synthesize shouldSmoothPoints, shouldNormalizeParticleSizesToDevice;
@synthesize particleSizeAttenuationCoefficients;

-(Protocol*) requiredParticleProtocol { return @protocol(CC3PointParticleProtocol); }

/** Overridden to ensure that the mesh is a CC3VertexArrayMesh. */
-(CC3PointParticleMesh*) mesh { return (CC3PointParticleMesh*)mesh; }

/** Overridden to ensure that the mesh is a CC3VertexArrayMesh. */
-(void) setMesh: (CC3PointParticleMesh*) aMesh {
	NSAssert1([aMesh isKindOfClass: [CC3PointParticleMesh class]], @"The mesh of %@ must be of type CC3PointParticleMesh.", self);
	super.mesh = aMesh;
}

// Deprecated
-(CC3PointParticleMesh*) particleMesh { return self.mesh; }

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

// Deprecated
-(CC3VertexContent) particleContentTypes { return self.vertexContentTypes; }
-(NSUInteger) maxParticles { return self.maximumParticleCapacity; }


#pragma mark Vertex management

// Overridden to retain all vertex content in memory.
-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	super.vertexContentTypes = vtxContentTypes;
	self.drawingMode = GL_POINTS;
}


#pragma mark Accessing vertex data

-(GLfloat) particleSizeAt: (GLuint) vtxIndex {
	CC3PointParticleMesh* pm = self.mesh;
	return pm ? [self denormalizeParticleSizeFromDevice: [pm vertexPointSizeAt: vtxIndex]] : 0.0f;
}

-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex {
	[self.mesh setVertexPointSize: [self normalizeParticleSizeToDevice: aSize] at: vtxIndex];
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
		globalCameraLocation = kCC3VectorNull;
		areParticleNormalsDirty = NO;
		self.particleSize = kCC3DefaultParticleSize;
		particleSizeMinimum = kCC3ParticleSizeMinimumNone;
		particleSizeMaximum = kCC3ParticleSizeMaximumNone;
		particleSizeAttenuationCoefficients = kCC3ParticleSizeAttenuationNone;
		shouldSmoothPoints = NO;
		shouldNormalizeParticleSizesToDevice = YES;
		shouldDisableDepthMask = YES;
		[[self class] deviceScaleFactor];	// Force init the static deviceScaleFactor before accessing it.
		[self ensureMaterial];				// We need blending, so start with a material.
	}
	return self;
}

-(void) makeMesh { self.mesh = [CC3PointParticleMesh mesh]; }

/** Overridden to configure for blending. */
-(void) makeMaterial {
	CC3Material* mat = [CC3Material material];
	mat.diffuseColor = kCCC4FWhite;
	mat.sourceBlend = GL_SRC_ALPHA;
	mat.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
	self.material = mat;
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
	
	particleSize = another.particleSize;
	particleSizeMinimum = another.particleSizeMinimum;
	particleSizeMaximum = another.particleSizeMaximum;
	shouldSmoothPoints = another.shouldSmoothPoints;
	shouldNormalizeParticleSizesToDevice = another.shouldNormalizeParticleSizesToDevice;
	particleSizeAttenuationCoefficients = another.particleSizeAttenuationCoefficients;
}


#pragma mark Updating

-(void) initializeParticle: (id<CC3PointParticleProtocol>) aPointParticle {
	[super initializeParticle: aPointParticle];
	
	// particleCount not yet incremented, so it points to this particle
	aPointParticle.particleIndex = particleCount;

	// Set the particle size directly so the CC3PointParticleProtocol does not need to support size
	[self setParticleSize: self.particleSize at: particleCount];
}

/** Marks the range of vertices in the underlying mesh that are affected by this particle. */
-(void) acceptParticle: (id<CC3PointParticleProtocol>) aParticle {
	[super acceptParticle: aParticle];
	[self setParticleNormal: aParticle];
}

/** Returns whether this mesh is making use of normals and lighting. */
-(BOOL) hasIlluminatedNormals { return mesh && mesh.hasVertexNormals && self.shouldUseLighting; }

-(void) transformMatrixChanged {
	[super transformMatrixChanged];
	areParticleNormalsDirty = YES;
}

-(void) nodeWasTransformed: (CC3Node*) aNode {
	[super nodeWasTransformed: aNode];
	if (aNode.isCamera) {
		globalCameraLocation = aNode.globalLocation;
		areParticleNormalsDirty = YES;
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
		if (CC3VectorIsNull(globalCameraLocation)) {
			CC3Camera* cam = self.activeCamera;
			globalCameraLocation = cam.globalLocation;
			[cam addTransformListener: self];
			LogTrace(@"%@ registered as listener of camera at %@",
						  self, NSStringFromCC3Vector(globalCameraLocation));
		}

		if (areParticleNormalsDirty) {
			LogTrace(@"%@ updating particle normals from camera location %@",
						  self, NSStringFromCC3Vector(globalCameraLocation));
			
			// Get the direction to the camera and transform it to local coordinates
			CC3Vector camDir = CC3VectorDifference(globalCameraLocation, self.globalLocation);
			camDir = [self.transformMatrixInverted transformDirection: camDir];
			for (id<CC3PointParticleProtocol> p in particles) {
				[p pointNormalAt: camDir];
			}
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
		CC3Vector camDir = CC3VectorDifference(globalCameraLocation, self.globalLocation);
		camDir = [self.transformMatrixInverted transformDirection: camDir];
		[pointParticle pointNormalAt: camDir];
	}
}


#pragma mark Accessing particles

-(id<CC3PointParticleProtocol>) pointParticleAt: (NSUInteger) aParticleIndex {
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
-(void) removeParticle: (id<CC3PointParticleProtocol>) aParticle atIndex: (NSUInteger) anIndex {
	[super removeParticle: aParticle atIndex: anIndex];		// Decrements particleCount and vertexCount
	
	// Get the last living particle
	id<CC3PointParticleProtocol> lastParticle = [self pointParticleAt: particleCount];
	
	// Swap the particles in the particles array
	[particles exchangeObjectAtIndex: anIndex withObjectAtIndex: particleCount];
	
	// Update the particle's index. This also updates the vertex indices array, if it exists.
	aParticle.particleIndex = particleCount;
	lastParticle.particleIndex = anIndex;
	
	// Update the underlying mesh
	[self.mesh copyVertices: 1 from: particleCount to: anIndex];
	
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
	[self cleanupPointProperties: visitor];
}

/** Disable particles again in each texture unit being used by the material. */
-(void) cleanupPointProperties: (CC3NodeDrawingVisitor*) visitor {
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

@end


#pragma mark -
#pragma mark CC3PointParticleMesh

@interface CC3VertexArrayMesh (TemplateMethods)
-(void) createVertexContent: (CC3VertexContent) vtxContentTypes;
-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLuint) elemCount;
@end

@implementation CC3PointParticleMesh

-(void) dealloc {
	[vertexPointSizes release];
	[super dealloc];
}

-(void) setName: (NSString*) aName {
	super.name = aName;
	[vertexPointSizes deriveNameFrom: self];
}

-(CC3VertexPointSizes*) vertexPointSizes { return vertexPointSizes; }

-(void) setVertexPointSizes: (CC3VertexPointSizes*) vtxSizes {
	[vertexPointSizes autorelease];
	vertexPointSizes = [vtxSizes retain];
	[vertexPointSizes deriveNameFrom: self];
}

-(BOOL) hasVertexPointSizes { return (vertexPointSizes != nil); }

// Deprecated
-(GLuint) particleCount { return self.vertexCount; }
-(void) setParticleCount: (GLuint) numParticles { self.vertexCount = numParticles; }


#pragma mark Vertex management

// Overridden to check for and add point size content.
-(CC3VertexContent) vertexContentTypes {
	CC3VertexContent vtxContent = super.vertexContentTypes;
	if (self.hasVertexPointSizes) vtxContent |= kCC3VertexContentPointSize;
	return vtxContent;
}

// Keep the compiler happy with re-declaration for documentation purposes
-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	super.vertexContentTypes = vtxContentTypes;
}

// Overridden to check for and add point size content.
-(void) createVertexContent: (CC3VertexContent) vtxContentTypes {
	
	// Construct all the other vertex arrays
	[super createVertexContent: vtxContentTypes];
	
	// Point sizes
	if (vtxContentTypes & kCC3VertexContentPointSize) {
		if (!vertexPointSizes) self.vertexPointSizes = [CC3VertexPointSizes vertexArray];
	} else {
		self.vertexPointSizes = nil;
	}
}

-(GLuint) vertexStride {
	GLuint stride = super.vertexStride;
	if (vertexPointSizes) stride += vertexPointSizes.elementLength;
	return stride;
}

-(void) setVertexStride: (GLuint) vtxStride {
	super.vertexStride = vtxStride;
	if (shouldInterleaveVertices) vertexPointSizes.vertexStride = vtxStride;
}

-(GLuint) updateVertexStride {
	GLuint stride = [super updateVertexStride];
	
	if (vertexPointSizes) {
		if (shouldInterleaveVertices) vertexPointSizes.elementOffset = stride;
		stride += vertexPointSizes.elementLength;
	}
	
	self.vertexStride = stride;
	return stride;
}

-(void) populateFrom: (CC3PointParticleMesh*) another {
	[super populateFrom: another];
	
	// Share vertex arrays between copies
	self.vertexPointSizes = another.vertexPointSizes;		// retained but not copied
}

/**
 * If the shouldInterleaveVertices property is set to NO, creates GL vertex buffer object for
 * the point size vertex array by invoking createGLBuffer.
 *
 * If the shouldInterleaveVertices property is set to YES, indicating that the underlying data
 * is shared across the contained vertex arrays, the bufferID property of the point sizes
 * vertex array is copied from the vertexLocations vertex array.
 */
-(void) createGLBuffers {
	[super createGLBuffers];
	if (shouldInterleaveVertices) {
		vertexPointSizes.bufferID = vertexLocations.bufferID;
	} else {
		[vertexPointSizes createGLBuffer];
	}
}

-(void) deleteGLBuffers {
	[super deleteGLBuffers];
	[vertexPointSizes deleteGLBuffer];
}

-(BOOL) isUsingGLBuffers {
	if (super.isUsingGLBuffers) return YES;
	if (vertexPointSizes && vertexPointSizes.isUsingGLBuffer) return YES;
	return NO;
}

-(void) releaseRedundantData {
	[super releaseRedundantData];
	[vertexPointSizes releaseRedundantData];
}

-(void) retainVertexContent {
	[super retainVertexContent];
	[self retainVertexPointSizes];
}

-(void) retainVertexPointSizes {
	if ( !self.hasVertexPointSizes ) return;
	
	if (shouldInterleaveVertices) [self retainVertexLocations];
	vertexPointSizes.shouldReleaseRedundantData = NO;
}

-(void) doNotBufferVertexContent {
	[super doNotBufferVertexContent];
	[self doNotBufferVertexPointSizes];
}

-(void) doNotBufferVertexPointSizes {
	if (shouldInterleaveVertices) [self doNotBufferVertexLocations];
	vertexPointSizes.shouldAllowVertexBuffering = NO;
}

-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx {
	[super copyVertices: vtxCount from: srcIdx to: dstIdx];
	if ( !shouldInterleaveVertices ) {
		[vertexPointSizes copyVertices: self.vertexCount from: srcIdx to: dstIdx];
	}
}

-(void) copyVertexAt: (GLuint) srcIdx from: (CC3VertexArrayMesh*) srcMesh to: (GLuint) dstIdx {
	[super copyVertexAt: srcIdx from: srcMesh to: dstIdx];
	if (self.hasVertexPointSizes) [self setVertexPointSize: [srcMesh vertexPointSizeAt: srcIdx] at: dstIdx];
}


#pragma mark Accessing vertex data

-(void) setAllocatedVertexCapacity: (GLuint) vtxCount {
	if (vtxCount == self.allocatedVertexCapacity) return;

	super.allocatedVertexCapacity = vtxCount;
	if (self.shouldInterleaveVertices) {
		[vertexPointSizes interleaveWith: vertexLocations];
	} else {
		vertexPointSizes.allocatedVertexCapacity = vtxCount;
	}
}

-(void) setVertexCount: (GLuint) vCount {
	super.vertexCount = vCount;
	vertexPointSizes.vertexCount = vCount;
}

-(GLfloat) vertexPointSizeAt: (GLuint) vtxIndex {
	return vertexPointSizes ? [vertexPointSizes pointSizeAt: vtxIndex] : 0.0f;
}

-(void) setVertexPointSize: (GLfloat) aSize at: (GLuint) vtxIndex {
	[vertexPointSizes setPointSize: aSize at: vtxIndex];
}

-(void) updatePointSizesGLBuffer { [vertexPointSizes updateGLBuffer]; }

// Deprecated
-(GLfloat) particleSizeAt: (GLuint) vtxIndex { return [self vertexPointSizeAt: vtxIndex]; }
-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex { [self setVertexPointSize: aSize at: vtxIndex]; }
-(void) updateParticleSizesGLBuffer { [self updatePointSizesGLBuffer]; }


#pragma mark Updating

-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLuint) vertexCount {
	[super updateGLBuffersStartingAt: offsetIndex forLength: vertexCount];
	if (!shouldInterleaveVertices) {
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

/** Re-declaration of deprecated methods to suppress compiler warnings within this class. */
@protocol CC3PointParticleDeprecated
-(void) update: (ccTime) dt;
@end

@implementation CC3PointParticle

-(CC3PointParticleEmitter*) emitter { return (CC3PointParticleEmitter*)emitter; }

-(void) setEmitter: (CC3PointParticleEmitter*) anEmitter {
	NSAssert1([anEmitter isKindOfClass: [CC3PointParticleEmitter class]], @"%@ may only be emitted by a CC3PointParticleEmitter.", self);
	super.emitter = anEmitter;
}

-(BOOL) isAlive { return isAlive; }

-(void) setIsAlive: (BOOL) alive { isAlive = alive; }

-(NSUInteger) particleIndex { return particleIndex; }

/** Overridden to update the underlying vertex indices array, if it exists. */
-(void) setParticleIndex: (NSUInteger) anIndex {
	particleIndex = anIndex;
	[emitter setVertexIndex: anIndex at: anIndex];	// Ignored if not using indexed drawing
}

// Deprecated
-(CC3PointParticleEmitter*) pointEmitter { return self.emitter; }

-(GLuint) vertexCount { return 1; }

-(NSRange) vertexRange { return NSMakeRange(particleIndex, self.vertexCount); }

-(GLuint) vertexIndexCount { return 1; }

-(NSRange) vertexIndexRange { return NSMakeRange(particleIndex, self.vertexIndexCount); }

-(CC3Vector) location { return [emitter vertexLocationAt: particleIndex]; }

-(void) setLocation: (CC3Vector) aLocation { [emitter setVertexLocation: aLocation at: particleIndex]; }

-(CC3Vector) normal { return [emitter vertexNormalAt: particleIndex]; }

-(void) setNormal: (CC3Vector) aNormal { [emitter setVertexNormal: aNormal at: particleIndex]; }

-(BOOL) hasNormal { return self.emitter.mesh.hasVertexNormals; }

-(ccColor4F) color4F { return self.hasColor ? [emitter vertexColor4FAt: particleIndex] : [super color4F]; }

-(void) setColor4F: (ccColor4F) aColor { [emitter setVertexColor4F: aColor at: particleIndex]; }

-(ccColor4B) color4B { return self.hasColor ? [emitter vertexColor4BAt: particleIndex] : [super color4B]; }

-(void) setColor4B: (ccColor4B) aColor { [emitter setVertexColor4B: aColor at: particleIndex]; }

-(GLfloat) size {
	CC3PointParticleEmitter* pe = self.emitter;
	return self.hasSize ? [pe particleSizeAt: particleIndex] : pe.particleSize;
}

-(void) setSize: (GLfloat) aSize { [self.emitter setParticleSize: aSize at: particleIndex]; }

-(BOOL) hasSize { return self.emitter.mesh.hasVertexPointSizes; }

-(BOOL) hasVertexIndices { return NO; }

// Deprecated property
-(NSUInteger) index { return self.particleIndex; }
-(void) setIndex: (NSUInteger) anIdx { self.particleIndex = anIdx; }

// Deprecated
-(void) update: (ccTime) dt {}

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[(id<CC3PointParticleDeprecated>)self update: visitor.deltaTime];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ at index %i", [super description], particleIndex];
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


#pragma mark Updating

-(void) pointNormalAt: (CC3Vector) camLoc {
	self.normal = CC3VectorNormalize(CC3VectorDifference(camLoc, self.location));
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		particleIndex = 0;
	}
	return self;
}

// Deprecated
-(id) initFromEmitter: (CC3PointParticleEmitter*) anEmitter {
	if ( (self = [self init]) ) {
		self.emitter = anEmitter;			// not retained
	}
	return self;
}

// Deprecated
+(id) particleFromEmitter: (CC3PointParticleEmitter*) anEmitter {
	return [[[self alloc] initFromEmitter: anEmitter] autorelease];
}

-(void) populateFrom: (CC3PointParticle*) another {
	[super populateFrom: another];
	particleIndex = another.particleIndex;
}

@end


#pragma mark -
#pragma mark CC3Node point particles extensions

@implementation CC3Node (PointParticles)

-(void) retainVertexPointSizes {
	for (CC3Node* child in children) {
		[child retainVertexPointSizes];
	}
}

-(void) doNotBufferVertexPointSizes {
	for (CC3Node* child in children) {
		[child doNotBufferVertexPointSizes];
	}
}

@end


#pragma mark -
#pragma mark CC3Mesh point particles extensions

@implementation CC3Mesh (PointParticles)

-(BOOL) hasVertexPointSizes { return NO; }

// Deprecated
-(BOOL) hasPointSizes { return self.hasVertexPointSizes; }


#pragma mark Managing vertex content

-(GLfloat) vertexPointSizeAt: (GLuint) vtxIndex { return 0.0f; }

-(void) setVertexPointSize: (GLfloat) aSize at: (GLuint) vtxIndex {}

-(void) updatePointSizesGLBuffer {}

-(void) retainVertexPointSizes {}

-(void) doNotBufferVertexPointSizes {}

@end
