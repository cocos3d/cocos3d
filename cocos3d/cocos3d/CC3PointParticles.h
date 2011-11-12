/*
 * CC3PointParticles.h
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
 */

/** @file */	// Doxygen marker

#import "CC3MeshNode.h"
#import "CC3VertexArrayMesh.h"
#import "CC3Camera.h"

@class CC3PointParticle, CC3PointParticleMesh;

/**
 * Constant representing an infinite interval of time.
 *
 * This can be used with the emissionDuration and emissionInterval properties.
 */
static const ccTime kCC3ParticleInfiniteInterval = CGFLOAT_MAX;

/**
 * Constant representing an infinite rate of emission.
 *
 * This can be used with the emissionRate property, and indicates
 * that all particles should be emitted at once.
 */
static const ccTime kCC3ParticleInfiniteEmissionRate = CGFLOAT_MAX;

/** Default size for particles. */
static const GLfloat kCC3DefaultParticleSize = 32.0;

/** Constant used with the particleSizeMinimum property to indicate no minimum size for particles. */
static const GLfloat kCC3ParticleSizeMinimumNone = 1.0;

/**
 * Constant used with the particleSizeMaximum property to indicate no maximum size
 * for particles, beyond any platform limit.
 */
static const GLfloat kCC3ParticleSizeMaximumNone = CGFLOAT_MAX;

/**
 * Variable type that holds a bitwise-OR of flags enumerating the types of content that
 * should be included in the point particles. Valid components of this type include:
 *   - kCC3PointParticleContentLocation
 *   - kCC3PointParticleContentNormal
 *   - kCC3PointParticleContentColor
 *   - kCC3PointParticleContentSize
 */
typedef uint CC3PointParticleVertexContent;

/**
 * Bitwise-OR component of CC3PointParticleVertexContent variables that indicates
 * each particle should contain its own location information.
 *
 * Particles always include location info, and so use of this component is optional.
 */
static const CC3PointParticleVertexContent kCC3PointParticleContentLocation	= 0;

/**
 * Bitwise-OR component of CC3PointParticleVertexContent variables that indicates
 * each particle should contain its own vertex normal information.
 *
 * This component is required if and only if the particles are to interact with light sources.
 */
static const CC3PointParticleVertexContent kCC3PointParticleContentNormal	= 1 << 0;

/**
 * Bitwise-OR component of CC3PointParticleVertexContent variables that indicates
 * each particle should contain its own color information.
 *
 * This component is required if and only if each particle will have its own color.
 * If this component is not included, all particles will have the color specified by
 * the diffuseColor property of the material of the emitter node.
 */
static const CC3PointParticleVertexContent kCC3PointParticleContentColor	= 1 << 1;

/**
 * Bitwise-OR component of CC3PointParticleVertexContent variables that indicates
 * each particle should contain its own size information.
 *
 * This component is required if and only if each particle will have its own size.
 * If this component is not included, all particles will have the size specified by
 * the particleSize property of the emitter node.
 */
static const CC3PointParticleVertexContent kCC3PointParticleContentSize		= 1 << 2;


/**
 * A CC3MeshNode that emits 3D point particles.
 *
 * Particles emitted by CC3PointParticleEmitter live in the 3D world, as distinct from
 * the 2D particles available through the cocos2d CCParticleSystem class.
 * 
 * For many particle effects, 2D is sufficient, and can be quite effective. You can
 * use a cocos2d CCParticleSystem instance with a CC3Billboard, to embed 2D particle
 * systems within a 3D cocos3d world.
 *
 * However, for applications that need particles to move in three dimensions, you can
 * use this class. Each particle emitted by CC3PointParticleEmitter has a 3D location,
 * will appear in front of or behind other 3D objects, depending on relative distance
 * from the camera, and can be configured to automatically appear smaller or larger
 * depending on distance from the camera.
 * 
 * Each particle emitted displays the same texture, which is determined by the texture
 * property of this emitter node. Be aware that OpenGL point particles use the entire
 * texture, which you should generally ensure has dimensions that are power-of-two.
 * Non-POT textures will be padded by iOS when loaded, for compatibility with the
 * graphics hardware. Although the padding is generally transparent, it may throw off
 * the expected location of your particle.
 *
 * Each particle has its own location, and may optionally be configued with its own color
 * and individual size, and each particle may be configured with a vertex normal so that
 * it can interact with light sources. These particle components are determined by the
 * parameters of the populateForMaxParticles:ofType:... initialization methods.
 *
 * The populateForMaxParticles:ofType:... initialization methods also specify the maximum
 * number of particles that will be emitted concurrently, and the type of particle that
 * will be emitted.
 *
 * When creating a particle system, you write application-specific subclasses of
 * CC3PointParticle to embody the state and life-cycle behaviour of each particle,
 * and you usually, but not always, write a customized subclass of CC3PointParticleEmitter
 * to assist with initialization of the particles during emission.
 * 
 * Each particle is an instance of a subclass of CC3PointParticle, which is an abstract
 * class that manages the basic location, color, size and vertex normal content of
 * particles. Application-specific subclasses define and control particle behaviour,
 * such as life span, velocity, etc.
 *
 * To define your own particle behaviour, you create a subclass of CC3PointParticle
 * and indicate to the emitter that you want it to use that subclass by passing that
 * class as an argument to one of the populateForMaxParticles:ofType:... methods.
 *
 * To define the emission characteristics for your particle system, such as minimum
 * and maximum particle lifespans, emission directions, color ranges, etc, you can
 * create a customized subclass of CC3PointParticleEmitter.
 *
 * When an emitter first emits a particle of your CC3PointParticle subclass, it invokes
 * the initializeParticle: method on itself. The default implementation of that method
 * invokes the initializeParticle method on the particle. You should override either or
 * both of these methods to configure the particle, and create the initial conditions
 * and content of a particle, prior to it being emitted.
 *
 * Subsequently, on each update pass, the emitter will automatically invoke the update:
 * method on the particle. You can override this method to define the behaviour of your
 * particles over time. If your particles have a finite lifespan, you can indicate that
 * a particle has expired by having the particle set its own isAlive property to NO
 * within the update: method.
 *
 * The isAlive property is automatically set to YES before the initializeParticle method
 * is invoked on the particle, so you don't have to set it there. You can, however, set
 * it to NO during execution of the initializeParticle method, to abort the emission of
 * that particle.
 *
 * To enhance performance and memory, particles that have expired are retained and reused
 * as further particles are emitted. This is transparent to the particles (and the developer),
 * as the reused particle follow the same life-cycle. The isAlive property is reset to YES,
 * and theinitializeParticle: method of the emitter, and the initializeParticle method of
 * the particle are invoked when the particle is emitted again.
 *
 * Like all mesh nodes, the emitter contains a CC3Material instance that determines how
 * the content will blend with content from other 3D objects that overlap this emitter.
 *
 * In general, the particles will contain transparent content. As such, you will likely
 * want to set the blendFunc property to one of the following:
 *   - {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA} - Standard realistic translucent blending.
 *   - {GL_SRC_ALPHA, GL_ONE} - Additive blending, to have overlapping particles build on,
 *     and intensify, each other
 *
 * For CC3PointParticleEmitter, the iniital value of the shouldDisableDepthMask property
 * is YES, so that the particles do not enage in Z-fighting with each other. You can
 * experiment with changing this to NO if your emitter is better suited to it.
 *
 * You can also experiment with the shouldDisableDepthTest and depthFunction properties
 * to see if change them helps you get the look you are trying to achieve.
 *
 * You can indicate the rate at which particle are emitted by setting either of the
 * emissionRate or emissionInterval properties. You can set for how long the emitter
 * should emit particles using the emissionDuration property.
 *
 * For emitters with finite duration, you can set the shouldRemoveOnFinish to YES to
 * indicate that the emitter should remove itself automatically from the 3D world, once
 * all particles have expired, cleaning up all memory usage by the emitter and particles
 * along the way. This features allows you to set a transient particle generator, such
 * as an explosion, going and then forget about it.
 *
 * You can control characteristics about the sizes of the particles, and how that size
 * should change with distance from the camera, using the particleSize, unityScaleDistance,
 * particleSizeAttenuationCoefficients, particleSizeMinimum, and particleSizeMaximum methods
 * properties.
 *
 * Once you have initialized the emitter with one of the populateForMaxParticles:ofType:...
 * methods, and set whatever emitter properties you need, you can start the emission of
 * particles using the play method. Particle emission can be paused using the pause method,
 * or stopped altogether using the stop method.
 *
 * If you do not want to have the emitter automatically emit particles, and want to control
 * directly the creation of new particles, simply avoid invoking the play method (and avoid
 * setting the isEmitting property to YES), and invoke the emitParticle method whenever you
 * want to emit a particle.
 *
 * You should set the boundingVolumeProperty to some non-zero value to help size the
 * boundingVolume of this node so that particles do not disappear prematurely from the
 * edge of the screen. You can verify your settings during development time by setting
 * the shouldDrawLocalContentWireframeBox property to YES to draw a boundingBox around
 * this emitter and all the particles.
 *
 * By default, the boundingVolume of the emitter will automatically be recalculated every
 * time a particle moves. Although this is convenient and ensures accuracy, recalculating
 * the bounding volume can often be an expensive operation. To avoid this, you can manually
 * set static boundaries in the boundingVolume of this emitter node and then set the
 * shouldUseFixedBoundingVolume property of this emitter to YES to indicate that you don't
 * want the emitter to recalculate its boundingVolume on each update.
 *
 * You may be wondering how to determine the correct static boundingVolume boundary
 * properties. You can do this at development time by setting the shouldMaximize property
 * of the boundingVolume of the emitter to YES, and setting the shouldUseFixedBoundingVolume
 * property of this emitter to NO, so that the boundingVolume will be recalculated on each
 * update. After the emitter has finished, output the boundingVolume to the log using
 * LogDeubg to record the maximume size that the bounding volume grew to during particle
 * emission. This will give you an idea of how big to set the static boundary properties
 * of the boundingVolume of your emitter.
 *
 * The implementation of this CC3PointParticleEmitter class requires that the mesh property
 * is set with an instance of CC3PointParticleMesh mesh (or a subclass), which is tailored
 * for point particles. Further, if that mesh contains color or size data for each vertex
 * in addition to location data, the vertex data must be interleaved, and the interleaveData
 * property of the mesh must be set to YES. Generally, you do not have to worry about this,
 * as the correct type of mesh is automatically created and configured when you invoke one
 * of the populateForMaxParticles:ofType:... methods.
 *
 * All memory used by the particles and the underlying vertex mesh is managed by the
 * emitter node, and is deallocated automatically when the emitter is released.
 */
@interface CC3PointParticleEmitter : CC3MeshNode {
	CCArray* particles;
	CC3Camera* cachedCamera;
	CC3Vector globalCameraLocation;
	id particleClass;
	GLuint maxParticles;
	GLuint particleCount;
	CC3AttenuationCoefficients particleSizeAttenuationCoefficients;
	CC3PointParticleVertexContent particleContentTypes;
	ccTime emissionDuration;
	ccTime elapsedTime;
	ccTime emissionInterval;
	ccTime timeSinceEmission;
	GLfloat particleSize;
	GLfloat particleSizeMinimum;
	GLfloat particleSizeMaximum;
	BOOL shouldSmoothPoints;
	BOOL shouldRemoveOnFinish;
	BOOL shouldNormalizeParticleSizesToDevice;
	BOOL isEmitting;
	BOOL wasStarted;
	BOOL verticesAreDirty;
}

/**
 * The array of particles.
 *
 * The value of this property will be nil until the array is created by invoking
 * one of the populateForMaxParticles:... methods.
 */
@property(nonatomic, readonly) CCArray* particles;

/**
 * The map of additional types of vertex content, in addtion to the mandatory vertex
 * location content. The value is a bit-map constructed by OR-ing together zero or
 * more of the following CC3PointParticleVertexContent values:
 *   - kCC3PointParticleContentNormal
 *   - kCC3PointParticleContentColor
 *   - kCC3PointParticleContentSize
 *
 * Since location content is mandatory, the kCC3PointParticleContentLocation indicator
 * will not appear in the bit-map in this property.
 *
 * For example, a value of (kCC3PointParticleContentColor | kCC3PointParticleContentSize)
 * indicates that each particle vertex will be drawn using location, color and size data.
 *
 * The value of this property is set by invoking one of the populateForMaxParticles:... methods.
 */
@property(nonatomic, readonly) CC3PointParticleVertexContent particleContentTypes;

/**
 * The customized subclass of CC3PointParticle used to instantiate new particles that
 * are emitted by this emitter.
 * 
 * This property is initially set by the populateForMaxParticles:... method, and you
 * generally would never change it. However, it is possible to change this property
 * at any time in order to have the emitter emit different types of particles during
 * its lifetime. All of these particles will have to use the same texture, but might
 * enage different behaviours to control their paths or life-cycles.
 */
@property(nonatomic, assign) id particleClass;

/**
 * The maximum number of particles that will be alive at any one time in the particle
 * system managed by this emitter. The value of this property is set when one of the
 * populateForMaxParticles:... methods is invoked.
 * 
 * This does not define the maximum number of particles that can be emitted over time.
 * As particles age, you can indicate that a particle has expired by setting the
 * isAlive property of the CC3PointParticle to NO in the update: method of the particle.
 * This frees up that particle to be re-initialized and re-emitted.
 *
 * The value of this property defines the amount of memory that will be allocated for
 * particles, and their specifications, used by this emitter. When this emitter is
 * deallocated, that memory will automatically be released.
 */
@property(nonatomic, readonly) GLuint maxParticles;

/**
 * The number of particles that are currently alive and being displayed by this emitter.
 * The value of this property will increase as particles are emitted, and will decrease
 * as particles age and expire.
 */
@property(nonatomic, readonly) GLuint particleCount;

/**
 * Indicates the length of time that the emitter will emit particles.
 *
 * Setting this value to kCC3ParticleInfiniteDuration indicates that the emitter should
 * continue to emit particles forever, or until the pause or stop method are invoked,
 * or until isEmitting is manually set to NO.
 *
 * The initial value is kCC3ParticleInfiniteDuration.
 */
@property(nonatomic, assign) ccTime emissionDuration;

/**
 * For emitters with a finite emissionDuration, indicates the length of time that this
 * emitter has been emitting particles.
 *
 * When the value of this property exceeds the value of the emissionDuration property,
 * the pause method is automatically invoked to cease the emission of particles.
 */
@property(nonatomic, readonly) ccTime elapsedTime;

/**
 * The rate that particles will be emitted, expressed in particles per second.
 * You can use this property as an alternate to the emissionInterval property.
 * 
 * Emission begins when the play method is invoked.
 * 
 * The initial value of this property is zero, indicating that no particles
 * will be automatically emitted.
 *
 * As an alternate to setting this property to engage automatic emission, you can
 * leave this property at its initial value and manually invoke the emitParticle
 * method whenever you determine that you want to emit a particle.
 */
@property(nonatomic, assign) GLfloat emissionRate;

/**
 * The interval between each emission of a particle, expressed in seconds.
 * You can use this property as an alternate to the emissionRate property.
 * 
 * Emission begins when the play method is invoked.
 * 
 * The initial value of this property is kCC3ParticleInfiniteDuration,
 * indicating that no particles will be automatically emitted.
 *
 * As an alternate to setting this property to engage automatic emission, you can
 * leave this property at its initial value and manually invoke the emitParticle
 * method whenever you determine that you want to emit a particle.
 */
@property(nonatomic, assign) ccTime emissionInterval;

/**
 * If the kCC3PointParticleContentSize component was not specified in the
 * populateForMaxParticles:... method, all particles will be emitted at the
 * same size, which is specified by this property.
 *
 * If the kCC3PointParticleContentSize component was specified, the size of
 * each particle can be individually set during the initialization of that
 * particle. The size of each particle defaults to this value, if not set
 * to something else during its initialization.
 *
 * The initial value is kCC3DefaultParticleSize.
 */
@property(nonatomic, assign) GLfloat particleSize;

/**
 * The miniumum size for point particles. Particle sizes will not be allowed
 * to shrink below this value when distance attenuation is engaged.
 *
 * You can use this property to limit how small particles will become as they
 * recede from the camera.
 *
 * The initial value of this property is kCC3ParticleSizeMinimumNone,
 * indicating that particles will be allowed to shrink to one pixel if needed.
 */
@property(nonatomic, assign) GLfloat particleSizeMinimum;

/**
 * The maxiumum size for point particles. Particle sizes will not be allowed
 * to grow below this value when distance attenuation is engaged.
 *
 * You can use this property to limit how large particles will become as they
 * approach the camera.
 *
 * The initial value of this property is kCC3ParticleSizeMaximumNone, indicating
 * that particles will be allowed to grow until clamped by any platform limits.
 */
@property(nonatomic, assign) GLfloat particleSizeMaximum;

/**
 * The distance from the camera, in 3D space, at which the particle will be displayed
 * at unity scale (its natural size).
 *
 * The value of this property defines how the apparent size of the particle will change
 * as it moves closer to, or farther from, the camera. If the particle is closer to the
 * camera than this distance, the particle will appear proportionally larger than its
 * natural size, and if the particle is farther away from the camera than this distance,
 * the particle will appear proportionally smaller than its natural size.
 * 
 * The natural size of the particle is expressed in pixels and is set either by the
 * particleSize property of this emitter, or by the size property of the individual
 * particle if the particleContentTypes property of this emitter includes the
 * kCC3PointParticleContentSize value.
 *
 * Setting the value of this property to zero indicates that the size of the particles
 * should stay constant, at their natural size, regardless of how far the particle is
 * from the camera.
 *
 * Setting this property replaces the need to set the value of the
 * particleSizeAttenuationCoefficients property, which is more complicated
 * to use, but offers a wider range of distance attenuation options.
 *
 * The initial value of this property is zero, indicating that distance attenuation
 * is not applied, and each particle will appear at its natural size regardless of
 * how far it is from the camera.
 */
@property(nonatomic, assign) GLfloat unityScaleDistance;

/**
 * The coefficients of the attenuation function that affects the size of a particle
 * based on its distance from the camera. The sizes of the particles are attenuated
 * according to the formula 1/sqrt(a + (b * r) + (c * r * r)), where r is the radial
 * distance from the particle to the camera, and a, b and c are the coefficients
 * from this property.
 *
 * As an alternate to setting this property, you can set the unityScaleDistance
 * property to establish standard proportional distance attenuation.
 *
 * The initial value of this property is kCC3ParticleSizeAttenuationNone,
 * indicating no attenuation with distance.
 */
@property(nonatomic, assign) CC3AttenuationCoefficients particleSizeAttenuationCoefficients;

/** Indicates whether points should be smoothed (antialiased). The initial value is NO. */
@property(nonatomic, assign) BOOL shouldSmoothPoints;

/**
 * Indicates that this emitter should automatically be removed from its parent,
 * and from the 3D world when it is finished (once the isFinished turns to YES).
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldRemoveOnFinish;

/**
 * Returns whether the maximum number of particles has been reached. This occurs
 * when the value of the particleCount property reaches the value of the
 * maxParticles property. When this occurs, no further particles will be emitted
 * until some particles expire.
 */
@property(nonatomic, readonly) BOOL isFull;

/**
 * The CC3Mesh used by this node, cast as a CC3PointParticleMesh, for convenience
 * in accessing the additional behavour available to support particle vertices.
 */
@property(nonatomic, readonly) CC3PointParticleMesh* particleMesh;


#pragma mark Accessing vertex data

/**
 * Returns the particle size element at the specified index from the vertex data.
 *
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 *
 * You typically do not use this method directly. Instead, use the size property
 * of the individual particle from within your custom CC3PointParticle subclass.
 */
-(GLfloat) particleSizeAt: (GLsizei) index;

/**
 * Sets the particle size element at the specified index in the vertex data to
 * the specified value.
 * 
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateParticleSizesGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 *
 * You typically do not use this method directly. Instead, use the size property
 * of the individual particle from within your custom CC3PointParticle subclass.
 */
-(void) setParticleSize: (GLfloat) aSize at: (GLsizei) index;

/**
 * Updates the GL engine buffer with the particle size data in this mesh.
 *
 * For particle emitters, this method is invoked automatically when particles
 * have been updated from within your CC3PointParticle subclass. Usually, the
 * application should never have need to invoke this method directly. 
 */
-(void) updateParticleSizesGLBuffer;


#pragma mark Allocation and initialization

/**
 * Prepares this emitter to manage the specified maximum number of simultaneous particles,
 * each to be instantiated from the specified class, and containing the specified drawable
 * content in each particle, in addition to the mandatory particle location content.
 *
 * The aParticleClass parameter must be a Class that is a subclass of the Class returned
 * by the particleClass method. This argument is not an instance of that class. You would
 * typically specify this parameter as [MyPointParticleSubclass class].
 *
 * The contentTypes parameter is a bitwise-OR of zero or more CC3PointParticleVertexContent
 * values. For example, a value for contentTypes of (kCC3PointParticleContentColor |
 * kCC3PointParticleContentSize) indicates that each particle will be drawn using location,
 * color and size information.
 *
 * Permitted components for this parameter include:
 *   - kCC3PointParticleContentLocation
 *   - kCC3PointParticleContentNormal
 *   - kCC3PointParticleContentColor
 *   - kCC3PointParticleContentSize
 *
 * Since location content is mandatory, the kCC3PointParticleContentLocation does
 * not need to be included in the contentTypes bit-map.
 *
 * For example, a value of (kCC3PointParticleContentColor | kCC3PointParticleContentSize)
 * indicates that each particle vertex will be drawn using location, color and size data.
 *
 * If kCC3PointParticleContentColor is included, each particle may have its own color.
 * If kCC3PointParticleContentSize is included, each particle may have its own size.
 * If kCC3PointParticleContentNormal is included, each particle will individually
 * interact with light sources, otherwise they will ignore lighting, and the
 * shouldUseLighting
 *
 * Memory will be allocated for the specified number of point-particle vertices,
 * each containing the specified particle content.
 *
 * The texture used to draw each point particle is set using the texture property
 * of this emitter.
 */
-(void) populateForMaxParticles: (GLuint) numParticles
						 ofType: (id) aParticleClass
					 containing: (CC3PointParticleVertexContent) contentTypes;

/**
 * Prepares this emitter to manage the specified maximum number of simultaneous particles,
 * each to be instantiated from the specified class, and containing only the mandatory
 * particle location drawable content.
 *
 * The aParticleClass parameter must be a Class that is a subclass of CC3PointParticle.
 * It is not an instance of a CC3PointParticle subclass. You would typically specify
 * this parameter as [MyPointParticleSubclass class].
 *
 * Memory will be allocated for the specified number of point-particle vertices,
 * each containing the specified particle content.
 *
 * The texture used to draw each point particle is set using the texture property
 * of this emitter.
 */
-(void) populateForMaxParticles: (GLuint) maxParticles ofType: (id) aParticleClass;

/**
 * Prepares this emitter to manage the specified maximum number of simultaneous particles,
 * each to be instantiated from the class returned by the particleClass method, and
 * containing the specified drawable content in each particle, in addition to the mandatory
 * particle location content.
 *
 * The contentTypes parameter is a bitwise-OR of zero or more CC3PointParticleVertexContent
 * values. For example, a value for contentTypes of (kCC3PointParticleContentColor |
 * kCC3PointParticleContentSize) indicates that each particle will be drawn using location,
 * color and size information.
 *
 * Permitted components for this parameter include:
 *   - kCC3PointParticleContentLocation
 *   - kCC3PointParticleContentNormal
 *   - kCC3PointParticleContentColor
 *   - kCC3PointParticleContentSize
 *
 * Since location content is mandatory, the kCC3PointParticleContentLocation does
 * not need to be included in the contentTypes bit-map.
 *
 * For example, a value of (kCC3PointParticleContentColor | kCC3PointParticleContentSize)
 * indicates that each particle vertex will be drawn using location, color and size data.
 *
 * If kCC3PointParticleContentColor is included, each particle may have its own color.
 * If kCC3PointParticleContentSize is included, each particle may have its own size.
 * If kCC3PointParticleContentNormal is included, each particle will individually
 * interact with light sources, otherwise they will ignore lighting, and the
 * shouldUseLighting
 *
 * Memory will be allocated for the specified number of point-particle vertices,
 * each containing the specified particle content.
 *
 * The texture used to draw each point particle is set using the texture property
 * of this emitter.
 */
-(void) populateForMaxParticles: (GLuint) numParticles
					 containing: (CC3PointParticleVertexContent) contentTypes;

/**
 * Prepares this emitter to manage the specified maximum number of simultaneous particles,
 * each to be instantiated from the class returned by the particleClass method, and
 * containing only the mandatory particle location drawable content.
 *
 * Memory will be allocated for the specified number of point-particle vertices,
 * each containing the specified particle content.
 *
 * The texture used to draw each point particle is set using the texture property
 * of this emitter.
 */
-(void) populateForMaxParticles: (GLuint) maxParticles;

/**
 * Returns the class of particle that is usable by this emitter.
 *
 * Subclasses may tie their behaviour to a particular type (subclass) of CC3PointParticle,
 * particularly when initializing the state of the particles. The emitter subclass can
 * use this method to return the type of CC3PointParticle it is expecting.
 *
 * The populateForMaxParticles:ofType:... methods verify that the specified class is
 * correct, and otherwise raise an assertion.
 *
 * In all cases, subclasses of the returned Class are acceptable.
 *
 * This implementation returns the generic CC3PointParticle class. Subclasses that need
 * to restrict the particle type can return a subclass of CC3PointParticle.
 */
-(id) particleClass;

/**
 * Convenience method to cause the vertex point size data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex point sizes will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 *
 * This method is invoked automatically by the populateForMaxParticles:ofType:...
 * method, if needed.  Usually, the application should never have need to invoke
 * this method directly.
 */
-(void) retainVertexPointSizes;

/**
 * Convenience method to cause the vertex point size data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a GL VBO,
 * is retained in application memory, and is submitted to the GL engine on
 * each frame render.
 *
 * Only the vertex point sizes will not be buffered to a GL VBO. Any other
 * vertex data, such as locations, or texture coordinates, will be buffered
 * to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexPointSizes method.
 */
-(void) doNotBufferVertexPointSizes;


#pragma mark Updating

/** Begins, or resumes, the emission of particles by setting the isEmitting property to YES. */
-(void) play;

/**
 * Ceases the emission of particles by setting the isEmitting property to NO.
 * Particles that have already been emitted will continue to be updated and displayed.
 *
 * Particle emission can be resumed by invoking the play method again.
 *
 * As an alternate to stopping emission manually, you can set the emissionDuration
 * property to cause particles to be emitted for a finite time and then stop.
 */
-(void) pause;

/**
 * Ceases the emission of particles by setting the isEmitting property to NO.
 * Particles that have already been emitted will no longer be updated and displayed,
 * effectively causing those particles to abruptly disappear from view.
 *
 * Particle emission can be restarted by invoking the play method again.
 *
 * In most cases, for best visual effect, you should use the pause method instead
 * to stop the emission of of new particles, but allow those that have already been
 * emitted to live out their lives.
 *
 * As an alternate to stopping emission manually, you can set the emissionDuration
 * property to cause particles to be emitted for a finite time and then stop.
 */
-(void) stop;

/**
 * Indicates whether the emitter is currently emitting particles.
 *
 * For emitters with a finite emissionDuration, the value of this property will
 * automatically be set to NO once that emissionDuration has passed.
 *
 * For emitters with infinite emissionDuration, or for emitters with a finite
 * emissionDuration that has not yet passed, setting the value of this property
 * to NO will stop the emitter from emitting any further particles.
 *
 * Emission can be started or restarted by setting this property to YES.
 */
@property(nonatomic, assign) BOOL isEmitting;

/**
 * Indicates whether this emitter is active.
 *
 * It is active if either particles are currently being emitted, or particles have
 * been emitted but have not yet lived out their lives.
 *
 * Formally, this property returns YES if either the isEmitting property returns YES
 * or the value of the particleCount property is greater than zero. Otherwise this
 * property returns NO.
 *
 * The stop method can be used to force this emitter to be immediately inactive.
 */
@property(nonatomic, readonly) BOOL isActive;

/**
 * Indicates whether particle emission has ceased and all particles have lived out their lives.
 *
 * This will only return YES if all of the following activities have occurred:
 *   - The play method was previously invoked, or the isEmitting property was set to YES.
 *   - The emissionDuration has elapsed or the pause method was invoked.
 *   - All particles have been marked as no longer alive within their update: method.
 *
 * The stop method can be used to short-circuit the last two activities.
 */
@property(nonatomic, readonly) BOOL isFinished;

/**
 * Emits a particle, using the newParticle method, and initializes it.
 *
 * to initialize each particle, you should override the initializeParticle: template
 * method in a subclass of this class, and/or the initializeParticle method of your
 * CC3PointParticle subclass.
 *
 * If the emitter is set to emit particles automatically, by setting an emissionRate
 * or emissionInterval, and then invoking play, you do not need to invoke this method
 * directly. It will be invoked automatically when it is time to emit a particle.
 * This is the most common situation, and so in most cases, you will never invoke this
 * method directly.
 *
 * However, there are some situations where the application might want more control
 * over the creation of particles. One example might be if you want to create a
 * quantity of fixed particles, such as a chain, or lights on a tree, that are not
 * emitted at a steady rate. Another example might be that you do not want the
 * particles to be emitted at a steady rate.
 *
 * In these situations, you can avoid invoking play (and avoid setting the isEmitting
 * flag set to YES), and then invoke the emitParticle method whenever you want to
 * create a new particle.
 *
 * If the number of particles currently alive, as indicated by the value of the
 * particleCount property has reached the maximum number of particls, as indicated
 * by the value of the maxParticles property, this method will do nothing.
 *
 * This method returns whether the particle was actually emitted. If the maximum
 * number of particles has been reached, or if the particle itself aborts the
 * emission by setting the isAlive property to NO in the initializeParticle method
 * of the particle, this method will return NO, otherwise it will return YES.
 */
-(BOOL) emitParticle;

/**
 * Template method that initializes the particle. This method is invoked automatically
 * from the emitParticle method just prior to the emission of the specified particle.
 *
 * This implementation invokes the initializeParticle method of the particle.
 * Emitter subclasses that need to configure a particle before it is emitted
 * can override this method to do so.
 *
 * This method is invoked automatically by the emitter when a particle is emitted.
 * Usually the application never has need to invoke this method directly.
 */
-(void) initializeParticle: (CC3PointParticle*) aParticle;


#pragma mark Drawing

/**
 * Indicates whether the particle sizes should be adjusted so that particles appear
 * to be a consistent size across all device screen resolutions
 *
 * The 3D camera frustum is consistent across all devices, making the view of the 3D
 * scene consistent across all devices. However, particle size is defined in terms of
 * pixels, and particles will appear larger or smaller. relative to 3D artifacts,
 * on different screen resolutions.
 * 
 * If this property is set to YES, the actual size of each particle, as submitted to
 * the GL engine, will be adjusted so that it appears to be the same size across all
 * devices, relative to the 3D nodes.
 *
 * If this property is set to NO, the actual size of each particle will be drawn in
 * the same absolute pixel size across all devices, which may make it appear to be
 * smaller or larger, relative to the 3D artifacts around it, on different devices.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldNormalizeParticleSizesToDevice;

@end


#pragma mark -
#pragma mark CC3PointParticleMesh

/**
 * A mesh whose vertices are used to display point particles.
 *
 * This mesh adds the vertexPointSizes property to add a vertex array that manages
 * an optional particle size datum for each vertex.
 *
 * Each vertex in the vertex arrays defines the visual characteristics for single point
 * particle. This data must include a location, so the vertexLocations array is required
 * by this model (as with any other mesh). In addition, optional characteristics may be
 * specified for each vertex: particle normal, color and size. Therefore, instances of
 * this mesh may also include vertexNormals, vertexColors, and vertexPointSizes arrays
 * (through the CC3VertexArrayMesh superclass).
 *
 * Since only one vertex is used per point particle, and that data is usually updated
 * frequently by the application, there is little advantage to using indices during
 * drawing. In general, therefore, this mesh will not typically make use of a
 * vertexIndices array.
 *
 * This subclass also contains several properties and population methods to assist in
 * accessing and managing the data in the vertex arrays.
 *
 * When creating a particle system, you do not typically need to interact with this
 * class, or create a customized subclass of CC3PointParticleMesh.
 */
@interface CC3PointParticleMesh : CC3VertexArrayMesh {
	CC3VertexPointSizes* vertexPointSizes;
}

/**
 * Indicates the number of particles that are alive and being displayed.
 *
 * This corresponds to the elementCount property of the drawable vertexLocations
 * vertex array. Setting the value of this property modifies the elementCount of
 * all vertex arrays so that only particleCount vertices are drawn.
 */
@property(nonatomic, assign) GLsizei particleCount;

/**
 * The vertex array instance managing a particle size datum for each particle.
 *
 * Setting this property is optional. Many particle systems do not require individual
 * sizing for each particle.
 */
@property(nonatomic, retain) CC3VertexPointSizes* vertexPointSizes;

/** Indicates whether this mesh contains data for vertex point sizes. */
@property(nonatomic, readonly) BOOL hasPointSizes;

/**
 * Configures this instance to manage the specified maximum number of simultaneous
 * particles.
 *
 * Each particle will be placed at a vertex in the contained vertex arrays.
 *
 * The contentTypes parameter is a bitwise-OR of zero or more CC3PointParticleVertexContent
 * values. For example, a value for contentTypes of (kCC3PointParticleContentColor |
 * kCC3PointParticleContentSize) indicates that each particle will be drawn using location,
 * color and size information.
 *
 * Permitted components for this parameter include:
 *   - kCC3PointParticleContentLocation
 *   - kCC3PointParticleContentNormal
 *   - kCC3PointParticleContentColor
 *   - kCC3PointParticleContentSize
 *
 * Since location content is mandatory, the kCC3PointParticleContentLocation does
 * not need to be included in the contentTypes bit-map. Each particle contains at
 * least a location element, so this method always creates and configures a
 * vertexLocations array.
 *
 * If the kCC3PointParticleContentColor component is specified, the elementType
 * property of the resulting vertexColorArray is set to GL_UNSIGNED_BYTE. However,
 * you may manipulate the data in this array using either byte or float color values,
 * via the setVertexColor4B:at: or setVertexColor4F:at: methods, respectivlely.
 *
 * Since only one vertex is used per particle, and that data is usually updated
 * frequently by the application, there is little advantage to using indices during
 * drawing. Therefore, drawing is performed by the vertexLocations array, which is
 * configured with a drawingMode property set to GL_POINTS.
 *
 * Since the vertex data will be frequently updated, the bufferUsage property of the
 * vertexLocations array is set to GL_DYNAMIC_DRAW.
 *
 * Location, normal, color and size data is interleaved. Therefore, all vertex arrays
 * have the same values in the elements and elementStride properties.
 * 
 * This method automatically allocates memory to hold enough vertex data for the
 * specified maximum number of particles, where each particle contains a location,
 * plus the content indicated by the contentsType parameter.
 *
 * This method also sets the value of the particleCount property to numParticles.
 */
-(void) populateForMaxParticles: (GLuint) numParticles
					 containing: (CC3PointParticleVertexContent) contentTypes;

/**
 * Convenience method to cause the vertex point size data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex point sizes will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexPointSizes;

/**
 * Convenience method to cause the vertex point size data to be skipped when
 * createGLBuffers is invoked. The vertex data is not buffered to a a GL VBO,
 * is retained in application memory, and is submitted to the GL engine on
 * each frame render.
 *
 * Only the vertex point sizes will not be buffered to a GL VBO. Any other
 * vertex data, such as locations, or texture coordinates, will be buffered
 * to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory,
 * so, if you have invoked this method, you do NOT also need to invoke the
 * retainVertexPointSizes method.
 */
-(void) doNotBufferVertexPointSizes;


#pragma mark Accessing vertex data

/**
 * Returns the particle size element at the specified index from the vertex data.
 *
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat) particleSizeAt: (GLsizei) index;

/**
 * Sets the particle size element at the specified index in the vertex data to
 * the specified value.
 * 
 * The index refers to elements, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateParticleSizesGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setParticleSize: (GLfloat) aSize at: (GLsizei) index;

/** Updates the GL engine buffer with the particle size data in this mesh. */
-(void) updateParticleSizesGLBuffer;

@end


#pragma mark -
#pragma mark CC3PointParticle

/**
 * CC3PointParticle is an abstract class that represents a single particle emitted
 * by a CC3PointParticleEmitter.
 *
 * When creating a particle system, you write application-specific subclasses of
 * CC3PointParticle to embody the state and life-cycle behaviour of each particle.
 * You do not typically need to create a customized subclass of CC3PointParticleEmitter.
 * 
 * To implement a specific particle system, create a subclass of CC3PointParticle,
 * and override the initializeParticle and update: methods to define the initial state,
 * and life-cycle behaviour of the particle.
 *
 * It is enough to customize your CC3PointParticle class. You do not typically need
 * to create a customized subclass of CC3PointParticleEmitter itself.
 *
 * Particles are emitted automatically by the CC3PointParticleEmitter. The emitter
 * will automatically invoke the initializeParticle callback method on each particle
 * as it is emitted.
 *
 * Be aware that, in the interests of performance and memory conservation, expired
 * particles may be cached and reused, and particle emission may not always involve
 * instantiating a new instance of your CC3PointParticle class.
 *
 * With this in mind, you should not depend on initFromEmitter: method being invoked
 * during particle emission. All code that establishes the initial emitted state of
 * a particle should be included in the initializeParticle method.
 *
 * During the life-cycle of a particle, the emitter will automatically periodically
 * update the particle by invoking the update: callback method. This method invocation
 * includes the time interval since the last update, so that the particle can emulate
 * realistic real-time behaviour.
 *
 * From within the initializeParticle and update: methods, the parrticle has access
 * to the emitter (and the node hierarchy and world it sits in) through the emitter
 * property. In addition, the particle can read and manipulate drawable content
 * through the location, normal, color4F/color4B, and size properties. For example,
 * a particle may change its location by changing the location property, or its
 * color by changing the color4F property.
 *
 * The normal property indicates the vertex normal that the particle uses to interact
 * with light sources. This property is automatically and dynamically adjusted by the
 * emitter, based on the particle's orientation with respect to the camera. Unless you
 * have specific reason to do so, and know what you are doing, you should leave the
 * value of this property alone.
 *
 * The value of the location property always has meaning, but the normal, color4B,
 * color4F and size properties are only active if the emitter was configured so
 * that particles will have normal, color and size content. If the emitter was not
 * configured for any of these particle content, then the reading the resulting
 * property will simply return zeros, and setting the property will have no effect.
 * It is, however, safe to read and write these properties, they just won't have
 * any effect. So, you can safely write a CC3PointParticle subclass that blindly 
 * manipulates its own color, and it simply won't have any effect when used with
 * an emitter that has been configured not to include color content in the particles.
 *
 * Beyond these basic drawable content properties, when you create a subclass of
 * CC3PointParticle, you should add any other content that is needed to determine the
 * behaviour of your particle. For example, you might include a velocity property for
 * particle that are following a path (or even a path object to define that path more
 * explicitly), and a timeToLive property, for particle that have a finite lifespan.
 *
 * It is up to the particle to determine when it expires. Some particles may never
 * expire. For those that do, you might typically define a lifeSpan or timeToLive
 * property within the particle that the particle decrements in the update: method.
 *
 * Once the particle has detemined that it has expired, in the update: method, you
 * can set the isAlive property of the particle to NO. When the update: method
 * returns, the emitter will then automatically remove the particle (and set it
 * aside for possible reuse). Expired particles are not drawn and do not receive
 * further update: method invocations.
 *
 * You can also set the isAlive property to NO in the initializeParticle method
 * to cause the emission of the particle to be aborted.
 */
@interface CC3PointParticle : NSObject {
	CC3PointParticleEmitter* emitter;
	GLuint index;
	BOOL isAlive;
}

/** The emitter that emitted this particle. */
@property(nonatomic, readonly) CC3PointParticleEmitter* emitter;

/**
 * The index of this particle within the collection of particles managed by the emitter.
 *
 * You should not assume that this property will be consistent during the lifetime of
 * the particle. It can and will change spontaneously as other particles expire and
 * the emitter manages the sequence of particles.
 *
 * At any time, this value is unique across all current living particles managed by the emitter.
 */
@property(nonatomic, readonly) GLuint index;

/**
 * Indicates whether this particle is alive or not. When a particle is emitted,
 * the value of this property is automatically set to YES by the emitter before
 * the initializeParticle method is invoked.
 *
 * You can set this property to NO from within the update: method to indicate that
 * this particle has expired. When the update: method returns, the emitter will then
 * automatically remove the particle (and set it aside for possible reuse). Expired
 * particles are not drawn and do not receive further update: method invocations.
 *
 * You can also set the isAlive property to NO in the initializeParticle method
 * to cause the emission of the particle to be aborted.
 */
@property(nonatomic, assign) BOOL isAlive;

/**
 * The location of this particle in the local coordinate system of the emitter.
 *
 * You can set this particle in the initializeParticle and update: methods to
 * move the particle around.
 *
 * The initial value of this property, set prior to the invocation of the 
 * initializeParticle method, is kCC3VectorZero.
 */
@property(nonatomic, assign) CC3Vector location;

/**
 * If this particle has vertex normal content, (which can be checked with the hasNormal
 * property), this property indicates the vertex normal that the particle uses to 
 * interact with light sources.
 * 
 * This property is automatically and dynamically adjusted by the emitter, based on the
 * particle's orientation with respect to the camera. Unless you have specific reason
 * to change this property, and know what you are doing, you should leave the value of
 * this property alone.
 *
 * If this particle does not have vertex normal content, this property will always
 * return kCC3VectorZero. In this condition, it is safe to set this property, but
 * changes will have no effect.
 *
 * The initial value of this property, set prior to the invocation of the 
 * initializeParticle method, is kCC3VectorZero.
 */
@property(nonatomic, assign) CC3Vector normal;

/**
 * Indicates whether this particle has vertex normal content. This is determined by
 * the configuration of the emitter. Within an emitter, either all particles have
 * this content, or none do.
 *
 * When this property returns YES, each particle will have a normal vector and will
 * interact with light sources. When this property returns NO, each particle will
 * ignore lighting conditions.
 */
@property(nonatomic, readonly) BOOL hasNormal;

/**
 * If this particle has individual color content, (which can be checked with the
 * hasColor property), this property indicates the color in which this particle
 * will appear.
 *
 * If this particle has individual color content, you can set this property at any
 * time to define the color of the particle.
 * 
 * If this particle does not have individual color content, this property will always
 * return the value of the diffuseColor property of the emitter. In this condition,
 * it is safe to set this property, but changes will have no effect.
 *
 * The initial value of this property, set prior to the invocation of the 
 * initializeParticle method, the value of the diffuseColor property of the emitter.
 */
@property(nonatomic, assign) ccColor4F color4F;

/**
 * If this particle has individual color content, (which can be checked with the
 * hasColor property), this property indicates the color in which this particle
 * will appear.
 *
 * If this particle has individual color content, you can set this property at any
 * time to define the color of the particle.
 * 
 * If this particle does not have individual color content, this property will always
 * return the value of the diffuseColor property of the emitter. In this condition,
 * it is safe to set this property, but changes will have no effect.
 *
 * The initial value of this property, set prior to the invocation of the 
 * initializeParticle method, the value of the diffuseColor property of the emitter.
 */
@property(nonatomic, assign) ccColor4B color4B;

/**
 * Indicates whether this particle has individual color content. This is determined
 * by the configuration of the emitter. Within an emitter, either all particles have
 * this content, or none do.
 *
 * When this property returns YES, each particle can be set to a different color.
 * When this property returns NO, all particles will have the color specified by the
 * diffuseColor property of the emitter.
 */
@property(nonatomic, readonly) BOOL hasColor;


/**
 * If this particle has individual size content, (which can be checked with the
 * hasSize property), this property indicates the size at which this particle
 * will appear.
 *
 * If this particle has individual size content, you can set this property at any
 * time to define the size of the particle.
 * 
 * If this particle does not have individual size content, this property will always
 * return the value of the particleSize property of the emitter. In this condition,
 * it is safe to set this property, but changes will have no effect.
 *
 * The initial value of this property, set prior to the invocation of the 
 * initializeParticle method, is the value of the particleSize property of the emitter.
 */
@property(nonatomic, assign) GLfloat size;

/**
 * Indicates whether this particle has individual size content. This is determined
 * by the configuration of the emitter. Within an emitter, either all particles have
 * this content, or none do.
 *
 * When this property returns YES, each particle can be set to a different size.
 * When this property returns NO, all particles will have the size specified by the
 * particleSize property of the emitter.
 */
@property(nonatomic, readonly) BOOL hasSize;

/** Returns a string containing a more complete description of this particle. */
-(NSString*) fullDescription;


#pragma mark Allocation and initialization

/**
 * Initializes this instance for the specified emitter.
 *
 * When overriding this method, be aware that, in the interests of performance and
 * memory conservation, expired particles can and will be cached and reused, and
 * particle emission may not always involve instantiating a new instance of your
 * CC3PointParticle class.
 *
 * With this in mind, you should not depend on this method being invoked during
 * particle emission. All code that establishes the initial emitted state of a 
 * particle should be included in the initializeParticle method.
 */
-(id) initFromEmitter: (CC3PointParticleEmitter*) anEmitter;

/** Allocates and initializes an autoreleased instance for the specified emitter. */
+(id) particleFromEmitter: (CC3PointParticleEmitter*) anEmitter;

/**
 * This template callback method is invoked automatically when this particle is emitted.
 *
 * You should override this method to establish the initial state of the particle.
 *
 * During execution of this method, you can access and set the initial values of the
 * location, normal, color and size properties. The emitter property can be used to
 * access further information in the emitter or other aspects of the 3D world.
 *
 * The isAlive property is set to YES prior to the invocation of this method.
 * You can set the isAlive property to NO in this method to cause the emission
 * of the particle to be aborted.
 *
 * When this method is invoked, the particle may have just been instantiated, or
 * it may be an older expired particle that is being reused. With this in mind,
 * this method should include all code that establishes the initial emitted state
 * of a particle. You should not rely on any state set in the initFromEmitter:
 * method, (with the exception of the emitter property).
 *
 * This implementation does nothing. You do not need to invoke this superclass
 * implementation from your overridden method implementation.
 */
-(void) initializeParticle;


#pragma mark Updating

/**
 * This template callback method is invoked automatically whenever the emitter is
 * updated during a scheduled 3D world update.
 *
 * You should override this method to control the behaviour of the particle during
 * its lifetime.
 *
 * During execution of this method, you can access and set the values of the location,
 * normal, color and size properties. The emitter property can be used to access further
 * information in the emitter or other aspects of the 3D world.
 *
 * It is up to the particle to determine when it expires. Some particles may never
 * expire. For those that do, you might typically define a lifeSpan or timeToLive
 * property within the particle that the particle decrements in this method.
 *
 * Once the particle has detemined that it has expired, in this method, you can set
 * the isAlive property of the particle to NO. When this method returns, the emitter
 * will then automatically remove the particle (and set it aside for possible reuse).
 * Expired particles are not drawn and do not receive further update: method invocations.
 *
 * This implementation does nothing. You do not need to invoke this superclass
 * implementation from your overridden method implementation.
 */
-(void) update: (ccTime) dt;

@end


#pragma mark -
#pragma mark CC3MortalPointParticle

/**
 * CC3MortalPointParticle is a type of CC3PointParticle that has a finite life.
 *
 * To use particles of this type, the emitter should set the lifeSpan property of
 * the particle to a finite time during particle initialization prior to emission.
 *
 * In the update: method, particles of this type automatically keep track of the
 * passing of time, and when the particle has passed its life span, the particle
 * automatically expires, and sets its isAlive property is set to NO.
 *
 * While the particle is alive, the update: method invokes the udpateLife: method,
 * which subclasses should override (instead of the udpate: method itself), to
 * update the behaviour of the particle over its lifetime.
 *
 * CC3MortalPointParticles are commonly emitted by a CC3MortalPointParticleEmitter,
 * which sets the lifeSpan to a random value with a defined range of possible
 * lifespans. Alternately, you can create a custom CC3PointParticleEmitter subclass
 * to set the lifeSpan property based on some other criteria.
 */
@interface  CC3MortalPointParticle  : CC3PointParticle {
	ccTime lifeSpan;
	ccTime timeToLive;
}

/**
 * Indicates the overall life span of the particle.
 *
 * The emitter should set this property once during initialization, prior to emission.
 */
@property(nonatomic, assign) ccTime lifeSpan;

/**
 * Indicates the remaining time the particle has to live.
 *
 * This property is automatically decremented as the particle ages. Once this property
 * reaches zero, the particle will automatically expire itself.
 */
@property(nonatomic, readonly) ccTime timeToLive;

/**
 * Invoked automatically from the udpate: method, while the particle is alive.
 * Subclasses should override this method to update the behaviour of the particle
 * over its lifetime
 *
 * This implementation does nothing. You do not need to invoke this superclass
 * implementation from your overridden method implementation.
 */
-(void) updateLife: (ccTime) dt;

@end


#pragma mark -
#pragma mark CC3MortalPointParticleEmitter

/**
 * CC3MortalPointParticleEmitter emits particles of type CC3MortalPointParticle.
 *
 * A particle of type CC3MortalPointParticle has a finite life. and when that
 * lifetime is finished, the particle will automatically expire itself.
 *
 * During initialization of each particle, the lifeSpan property of the particle
 * is set to a random value between the values of the minParticleLifeSpan
 * and maxParticleLifeSpan properties of this emitter.
 *
 * Subclasses typically override the initializeMortalParticle: method to intialize
 * the particle further. A subclass may alternately choose to override the
 * initializeParticle: method instead if a different method of determining the
 * lifeSpan of the particle is required.
 *
 * See the notes of the initializeParticle: and initializeMortalParticle: methods
 * for more information.
 */
@interface CC3MortalPointParticleEmitter : CC3PointParticleEmitter {
	ccTime minParticleLifeSpan;
	ccTime maxParticleLifeSpan;
}

/**
 * Indicates the lower limit of the range of possible particle life spans.
 *
 * When a particle is emitted, the lifeSpan property will be set to a random value
 * between the value of this property and the value of the maxParticleLifeSpan property.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) ccTime minParticleLifeSpan;

/**
 * Indicates the upper limit of the range of possible particle life spans.
 *
 * When a particle is emitted, the lifeSpan property will be set to a random value
 * between the value of the minParticleLifeSpan property and the value of this property.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) ccTime maxParticleLifeSpan;

/**
 * Template method that initializes the particle. This method is invoked automatically
 * from the emitParticle method just prior to the emission of the specified particle.
 *
 * This implementation sets the lifeSpan property of the particle to a random value
 * between the values of the minParticleLifeSpan and maxParticleLifeSpan properties
 * of this emitter, invokes the initializeMortalParticle: method to initialize the
 * particle further, and finally invokes the initializeParticle method of the particle.
 *
 * This method is invoked automatically by the emitter when a particle is emitted.
 * Usually the application never has need to invoke this method directly.
 */
-(void) initializeParticle: (CC3PointParticle*) aParticle;

/**
 * Template method that initializes the particle after its lifeSpan property
 * has been set. This method is invoked automatically from the initializeParticle:
 * method just prior to the emission of the specified particle.
 *
 * This implementation does nothing. Subclasses can override to initialize the particle
 * with further state, after the lifeSpan property of the particle has been set.
 * Subclasses that override do not need to invoke this superclass implementation.
 *
 * This method is invoked automatically by the emitter when a particle is emitted.
 * Usually the application never has need to invoke this method directly.
 */
-(void) initializeMortalParticle: (CC3PointParticle*) aParticle;

@end


#pragma mark -
#pragma mark CC3UniformMotionParticle

/**
 * CC3UniformMotionParticle is a type of CC3MortalPointParticle that moves in
 * a straight line in a single direction at a steady speed.
 *
 * The direction and speed are specified by the velocity property. To produce
 * uniform motion, on each update, the updateLife: method multiplies this velocity
 * by the interval since the previous update, and the resulting distance vector
 * is added to the location of this particle
 */
@interface  CC3UniformMotionParticle  : CC3MortalPointParticle {
	CC3Vector velocity;
}

/**
 * Indicates the velocity of this particle. This vector combines both speed and
 * direction, with the speed determined by the length of the vector.
 *
 * The updateLife: method multiplies this velocity by the interval since the previous
 * update, and adds the resulting distance vector to the location of this particle.
 */
@property(nonatomic, assign) CC3Vector velocity;

/**
 * Invoked automatically from the udpate: method, while the particle is alive.
 *
 * The direction and speed are specified by the velocity property. To produce
 * uniform motion, this method multiplies this velocity by the interval since
 * the previous update, and the resulting distance vector is added to the
 * location of this particle
 *
 * Subclasses that override this method should invoke this superclass implementation.
 */
-(void) updateLife: (ccTime) dt;

@end


#pragma mark -
#pragma mark CC3UniformEvolutionParticle

/**
 * CC3UniformEvolutionParticle is a type of CC3MortalPointParticle that moves
 * in a straight line in a single direction at a steady speed, and which can
 * optionally have color and size that linearly move from an intitial color
 * and size to a final color and size.
 *
 * The direction and speed are specified by the velocity property. The rate of
 * change of the particle's color and size are specified by the colorVelocity
 * and sizeVelocity properties respectively.
 *
 * To produce uniform evolution, the updateLife: method multiplies each of these
 * three velocities by the interval since the previous update, and adds each
 * result, accordingly, to the location, color and size properties of this particle.
 * Color and size are only updated if this particle supports that content.
 */
@interface  CC3UniformEvolutionParticle  : CC3UniformMotionParticle {
	GLfloat sizeVelocity;
	ccColor4F colorVelocity;
}

/**
 * Indicates the rate that this particle changes size.
 *
 * If this particle has size content, the updateLife: method multiplies this
 * velocity by the interval since the previous update, and adds the result to
 * the size of this particle.
 */
@property(nonatomic, assign) GLfloat sizeVelocity;

/**
 * Indicates the rate that this particle changes color.
 *
 * If this particle has size content, the updateLife: method multiplies this
 * velocity by the interval since the previous update, and adds the result to
 * the color of this particle.
 */
@property(nonatomic, assign) ccColor4F colorVelocity;

/**
 * Invoked automatically from the udpate: method, while the particle is alive.
 *
 * The direction and speed are specified by the velocity property. The rate of
 * change of the particle's color and size are specified by the colorVelocity
 * and sizeVelocity properties respectively.
 *
 * To produce uniform evolution, this method multiplies each of these three
 * velocities by the interval since the previous update, and adds each result,
 * accordingly, to the location, color and size properties of this particle.
 * Color and size are only updated if this particle supports that content.
 *
 * Subclasses that override this method should invoke this superclass implementation.
 */
-(void) updateLife: (ccTime) dt;

@end
