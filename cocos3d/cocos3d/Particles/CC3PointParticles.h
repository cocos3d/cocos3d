/*
 * CC3PointParticles.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Particles.h"
#import "CC3Mesh.h"
#import "CC3Camera.h"

@class CC3PointParticleMesh;


#pragma mark -
#pragma mark CC3PointParticleProtocol

/**
 * CC3PointParticleProtocol defines the requirements for point particles that are emitted
 * and managed by the CC3PointParticleEmitter class.
 *
 * Relative to mesh particles, point particles are extremely efficient and performance-friendly,
 * since they comprise only a single vertex per particle, and do not need to be transformed.
 * However, they are limited in that they can comprise only a single rectangular 2D texture.
 *
 * Point particles can be located, colored, and textured. Point particles cannot be rotated
 * or given a 3D appearance. Point particles do not support a texture rectangle, and so all
 * particles from a single emitter must be textured identically. 
 */
@protocol CC3PointParticleProtocol <CC3CommonVertexArrayParticleProtocol>

/**
 * The index of this particle within the collection of particles managed by the emitter.
 *
 * You should not assume that this property will be consistent during the lifetime of
 * the particle. It can and will change spontaneously as other particles expire and
 * the emitter manages its collection of particles.
 *
 * This property is set by the particle emitter as it manages its collection of particles.
 * The application must treat this property as read-only, and must never set this property directly.
 *
 * At any time, this value is unique across all current living particles managed by the emitter.
 */
@property(nonatomic, assign) GLuint particleIndex;

/**
 * Invoked automatically, if the particle has vertex normal content, to point the normal vector
 * of the particle at the specified location, which is expressed in terms of the local coordinate
 * system of the emitter.
 *
 * To point the particle itself at the location, we use vector math. The vector from the emitter to
 * the particle is subtracted from the vector from the emitter to the specified location. The result
 * is a vector that points from the particle to the given location. This vector is normalized and
 * set in the normal property.
 *
 * This method is invoked automatically by the emitter if the particle has a normal, and the
 * shouldUseLighting property of the emitter is set to YES, to keep the normal of the particle
 * pointed towards the camera, so that the particle will appear to interact with the scene lighting.
 */
-(void) pointNormalAt: (CC3Vector) camLoc;

@end


#pragma mark -
#pragma mark CC3PointParticleEmitter

/** Default size for particles. */
static const GLfloat kCC3DefaultParticleSize = 32.0;

/** Constant used with the particleSizeMinimum property to indicate no minimum size for particles. */
static const GLfloat kCC3ParticleSizeMinimumNone = 1.0;

/**
 * Constant used with the particleSizeMaximum property to indicate no maximum size
 * for particles, beyond any platform limit.
 */
static const GLfloat kCC3ParticleSizeMaximumNone = kCC3MaxGLfloat;

/** @deprecated Replaced with CC3VertexContent. */
typedef CC3VertexContent CC3PointParticleVertexContent __deprecated;

/** @deprecated Replaced with kCC3VertexContentLocation. */
static const CC3VertexContent kCC3PointParticleContentLocation __deprecated	= kCC3VertexContentLocation;

/** @deprecated Replaced with kCC3VertexContentNormal. */
static const CC3VertexContent kCC3PointParticleContentNormal __deprecated = kCC3VertexContentNormal;

/** @deprecated Replaced with kCC3VertexContentColor. */
static const CC3VertexContent kCC3PointParticleContentColor __deprecated = kCC3VertexContentColor;

/** @deprecated Replaced with kCC3VertexContentPointSize. */
static const CC3VertexContent kCC3PointParticleContentSize __deprecated = kCC3VertexContentPointSize;

/**
 * CC3PointParticleEmitter emits particles that conform to the CC3PointParticleProtocol protocol.
 *
 * Each particle has its own location, and may optionally be configued with its own color
 * and individual size, and each particle may be configured with a vertex normal so that
 * it can interact with light sources. This particle content is defined by the
 * vertexContentTypes property of this emitter. 
 * 
 * Each point particle emitted displays the same texture, which is determined by the texture
 * property of this emitter node. Be aware that OpenGL point particles use the entire texture,
 * which you should generally ensure has dimensions that are power-of-two. Non-POT textures will
 * be padded by iOS when loaded, for compatibility with the graphics hardware. Although the
 * padding is generally transparent, it may throw off the expected location of your particle.
 *
 * In general, point particles will contain transparent content. As such, you will likely want
 * to set the blendFunc property to one of the following:
 *   - {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA} - Standard realistic translucent blending
 *                                              (this is the initial setting).
 *   - {GL_SRC_ALPHA, GL_ONE} - Additive blending, to have overlapping particles build on,
 *                              and intensify, each other
 *
 * For CC3PointParticleEmitter, the initial value of the shouldDisableDepthMask property
 * is YES, so that the particles do not enage in Z-fighting with each other. You can
 * experiment with changing this to NO if your emitter is better suited to it.
 *
 * You can also experiment with the shouldDisableDepthTest and depthFunction properties
 * to see if change them helps you get the look you are trying to achieve.
 *
 * You can control characteristics about the sizes of the particles, and how that size should
 * change with distance from the camera, using the particleSize, particleSizeMinimum,
 * particleSizeMaximum, particleSizeAttenuation, and unityScaleDistance properties.
 *
 * All memory used by the particles and the underlying vertex mesh is managed by the
 * emitter node, and is deallocated automatically when the emitter is released.
 */
@interface CC3PointParticleEmitter : CC3CommonVertexArrayParticleEmitter {
	CC3Vector _globalCameraLocation;
	CC3AttenuationCoefficients _particleSizeAttenuation;
	GLfloat _particleSize;
	GLfloat _particleSizeMinimum;
	GLfloat _particleSizeMaximum;
	BOOL _shouldSmoothPoints : 1;
	BOOL _shouldNormalizeParticleSizesToDevice : 1;
	BOOL _areParticleNormalsDirty : 1;
}

/** @deprecated Use the mesh property. */
@property(nonatomic, retain, readonly) CC3PointParticleMesh* particleMesh __deprecated;

/** @deprecated Replaced by the more generic vertexContentTypes. */
@property(nonatomic, readonly) CC3VertexContent particleContentTypes __deprecated;

/** @deprecated Replaced by maximumParticleCapacity. */
@property(nonatomic, readonly) GLuint maxParticles __deprecated;

/**
 * If the kCC3VertexContentPointSize component was not specified in the vertexContentTypes
 * property, all particles will be emitted at the same size, as specified by this property.
 *
 * If the kCC3VertexContentPointSize component was specified, the size of each particle can
 * be individually set during the initialization of that particle. The size of each particle
 * defaults to this value, if not set to something else during its initialization.
 *
 * The initial value is kCC3DefaultParticleSize.
 */
@property(nonatomic, assign) GLfloat particleSize;

/**
 * The miniumum size for point particles. Particle sizes will not be allowed to shrink below this
 * value when distance attenuation is engaged.
 *
 * You can use this property to limit how small particles will become as they recede from the camera.
 *
 * The initial value of this property is kCC3ParticleSizeMinimumNone, indicating that particles
 * will be allowed to shrink to one pixel if needed.
 */
@property(nonatomic, assign) GLfloat particleSizeMinimum;

/**
 * The maxiumum size for point particles. Particle sizes will not be allowed to grow beyond this
 * value when distance attenuation is engaged.
 *
 * You can use this property to limit how large particles will become as they approach the camera.
 *
 * The initial value of this property is kCC3ParticleSizeMaximumNone, indicating that particles
 * will be allowed to grow until clamped by any platform limits.
 */
@property(nonatomic, assign) GLfloat particleSizeMaximum;

/**
 * The distance from the camera, in 3D space, at which the particle will be displayed
 * at unity scale (its natural size).
 *
 * The value of this property defines how the apparent size of the particle will change as it
 * moves closer to, or farther from, the camera. If the particle is closer to the camera than
 * this distance, the particle will appear proportionally larger than its natural size, and if
 * the particle is farther away from the camera than this distance, the particle will appear
 * proportionally smaller than its natural size.
 * 
 * The natural size of the particle is expressed in pixels and is set either by the particleSize
 * property of this emitter, or by the size property of the individual particle if the
 * vertexContentTypes property of this emitter includes the kCC3VertexContentPointSize value.
 *
 * Setting the value of this property to zero indicates that the size of the particles should stay
 * constant, at their natural size, regardless of how far the particle is from the camera.
 *
 * Setting this property replaces the need to set the value of the particleSizeAttenuation property,
 * which offers a wider range of distance attenuation options, but is more complicated to use.
 *
 * The initial value of this property is zero, indicating that distance attenuation is not applied,
 * and each particle will appear at its natural size regardless of how far it is from the camera.
 */
@property(nonatomic, assign) GLfloat unityScaleDistance;

/**
 * The coefficients of the attenuation function that affects the size of a particle based on its
 * distance from the camera. The sizes of the particles are attenuated according to the formula
 * 1/sqrt(a + (b * r) + (c * r * r)), where r is the radial distance from the particle to the camera,
 * and a, b and c are the coefficients from this property.
 *
 * As an alternate to setting this property, you can set the unityScaleDistance property to establish
 * standard proportional distance attenuation.
 *
 * The initial value of this property is kCC3AttenuationNone, indicating no attenuation with distance.
 */
@property(nonatomic, assign) CC3AttenuationCoefficients particleSizeAttenuation;

/** @deprecated Property renamed to particleSizeAttenuation. */
@property(nonatomic, assign) CC3AttenuationCoefficients particleSizeAttenuationCoefficients __deprecated;

/**
 * Indicates whether the particle sizes should be adjusted so that particles appear
 * to be a consistent size across all device screen resolutions
 *
 * The 3D camera frustum is consistent across all devices, making the view of the 3D scene consistent
 * across all devices. However, particle size is defined in terms of pixels, and particles will appear
 * larger or smaller. relative to 3D artifacts, on different screen resolutions.
 * 
 * If this property is set to YES, the actual size of each particle, as submitted to the GL engine,
 * will be adjusted so that it appears to be the same size across all devices, relative to the 3D nodes.
 *
 * If this property is set to NO, the actual size of each particle will be drawn in the same absolute
 * pixel size across all devices, which may make it appear to be smaller or larger, relative to the
 * 3D artifacts around it, on different devices.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldNormalizeParticleSizesToDevice;

/**
 * Returns the value of the particleSize property. If the shouldNormalizeParticleSizesToDevice
 * property is set to YES, the returned value will be normalized. For further explanation, see
 * the notes for the shouldNormalizeParticleSizesToDevice property.
 */
@property(nonatomic, readonly) GLfloat normalizedParticleSize;

/**
 * Returns the value of the particleSizeMinimum property. If the shouldNormalizeParticleSizesToDevice
 * property is set to YES, the returned value will be normalized. For further explanation, see
 * the notes for the shouldNormalizeParticleSizesToDevice property.
 */
@property(nonatomic, readonly) GLfloat normalizedParticleSizeMinimum;

/**
 * Returns the value of the particleSizeMaximum property. If the shouldNormalizeParticleSizesToDevice
 * property is set to YES, the returned value will be normalized. For further explanation, see
 * the notes for the shouldNormalizeParticleSizesToDevice property.
 */
@property(nonatomic, readonly) GLfloat normalizedParticleSizeMaximum;

/** Indicates whether points should be smoothed (antialiased). The initial value is NO. */
@property(nonatomic, assign) BOOL shouldSmoothPoints;


#pragma mark Accessing vertex data

/**
 * Returns the particle size element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 *
 * You typically do not use this method directly. Instead, use the size property
 * of the individual particle from within your custom CC3PointParticle subclass.
 */
-(GLfloat) particleSizeAt: (GLuint) vtxIndex;

/**
 * Sets the particle size element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the updateParticleSizesGLBuffer
 * method to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 *
 * You typically do not use this method directly. Instead, use the size property
 * of the individual particle from within your custom CC3PointParticle subclass.
 */
-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex;

/**
 * Updates the GL engine buffer with the particle size data in this mesh.
 *
 * For particle emitters, this method is invoked automatically when particles
 * have been updated from within your CC3PointParticle subclass. Usually, the
 * application should never have need to invoke this method directly. 
 */
-(void) updateParticleSizesGLBuffer;

/**
 * Convenience method to cause the vertex point size data to be retained in application
 * memory when releaseRedundantContent is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex point sizes will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantContent is invoked.
 *
 * This method is invoked automatically when the vertexContentTypes property is set.
 * Usually, the application should never have need to invoke this method directly.
 */
-(void) retainVertexPointSizes;

/**
 * Convenience method to cause the vertex point size data to be skipped when createGLBuffers
 * is invoked. The vertex data is not buffered to a GL VBO, is retained in application memory,
 * and is submitted to the GL engine on each frame render.
 *
 * Only the vertex point sizes will not be buffered to a GL VBO. Any other vertex content, such as
 * locations, or texture coordinates, will be buffered to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexPointSizes method.
 */
-(void) doNotBufferVertexPointSizes;


#pragma mark Accessing particles

/** Returns the particle at the specified index within the particles array, cast as a point particle. */
-(id<CC3PointParticleProtocol>) pointParticleAt: (GLuint) aParticleIndex;


#pragma mark Vertex management

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (GLuint) numParticles
						 ofType: (id) aParticleClass
					 containing: (CC3VertexContent) contentTypes __deprecated;

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (GLuint) maxParticles ofType: (id) aParticleClass __deprecated;

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (GLuint) numParticles
					 containing: (CC3VertexContent) contentTypes __deprecated;

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (GLuint) maxParticles __deprecated;

@end


#pragma mark -
#pragma mark CC3PointParticle

/**
 * CC3PointParticle is a standard base implementation of the CC3PointParticleProtocol.
 *
 * CC3PointParticle provides accessors for the particle normal and size.
 */
@interface CC3PointParticle : CC3ParticleBase <CC3PointParticleProtocol> {
	GLuint _particleIndex;
	BOOL _isAlive : 1;
}

/**
 * The emitter that emitted this particle.
 *
 * For CC3PointParticle, the emitter must be of type CC3PointParticleEmitter.
 */
@property(nonatomic, unsafe_unretained) CC3PointParticleEmitter* emitter;

/**
 * If this particle has vertex normal content, (which can be checked with the hasNormal property),
 * this property indicates the vertex normal that the particle uses to interact with light sources.
 * 
 * This property is automatically and dynamically adjusted by the emitter, based on the particle's
 * orientation with respect to the camera. Unless you have specific reason to change this property,
 * and know what you are doing, you should leave the value of this property alone.
 *
 * If this particle does not have vertex normal content, this property will always return kCC3VectorZero.
 * In this condition, it is safe to set this property, but changes will have no effect.
 */
@property(nonatomic, assign) CC3Vector normal;

/**
 * Indicates whether this particle has vertex normal content, as determined by the vertexContentTypes
 * property of the emitter. Within an emitter, either all particles have normal content, or none do.
 *
 * When this property returns YES, each particle will have a normal vector and will interact with
 * light sources. When this property returns NO, each particle will ignore lighting conditions.
 */
@property(nonatomic, readonly) BOOL hasNormal;

/**
 * If this particle has individual size content, (which can be checked with the hasSize property),
 * this property indicates the size at which this particle will appear.
 *
 * If this particle has individual size content, you can set this property at any time to define
 * the size of the particle.
 * 
 * If this particle does not have individual size content, this property will always return the
 * value of the particleSize property of the emitter. In this condition, it is safe to set this
 * property, but changes will have no effect.
 */
@property(nonatomic, assign) GLfloat size;

/**
 * Indicates whether this particle has vertex size content, as determined by the vertexContentTypes
 * property of the emitter. Within an emitter, either all particles have size content, or none do.
 *
 * When this property returns YES, each particle can be set to a different size. When this property
 * returns NO, all particles will have the size specified by the particleSize property of the emitter.
 */
@property(nonatomic, readonly) BOOL hasSize;

/** @deprecated Replaced by the particleIndex property. */
@property(nonatomic, assign) GLuint index __deprecated;

/** @deprecated Replaced by the updateBeforeTransform: method. */
-(void) update: (CCTime) dt __deprecated;

/** @deprecated Use the init method instead, and set emitter property directly. */
-(id) initFromEmitter: (CC3PointParticleEmitter*) anEmitter;

/** @deprecated Use the particle method instead, and set emitter property directly. */
+(id) particleFromEmitter: (CC3PointParticleEmitter*) anEmitter;

@end


#pragma mark -
#pragma mark Deprecated CC3PointParticleMesh

__deprecated
/**
 * Deprecated.
 * @deprecated Functionality moved to CC3Mesh.
 */
@interface CC3PointParticleMesh : CC3Mesh

/** @deprecated Use vertexCount instead. Point particles have one vertex per particle. */
@property(nonatomic, assign) GLuint particleCount __deprecated;

/** @deprecated Replaced by pointSizeAt:. */
-(GLfloat) particleSizeAt: (GLuint) vtxIndex __deprecated;

/** @deprecated Replaced by setPointSize:at:. */
-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex __deprecated;

/** @deprecated Replaced by updatePointSizesGLBuffer. */
-(void) updateParticleSizesGLBuffer __deprecated;

@end
