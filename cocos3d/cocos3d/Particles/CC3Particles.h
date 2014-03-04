/*
 * CC3Particles.h
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

#import "CC3MeshNode.h"


@class CC3ParticleEmitter, CC3ParticleNavigator;


#pragma mark -
#pragma mark CC3ParticleProtocol

/**
 * CC3ParticleProtocol represents a single particle emitted by a CC3ParticleEmitter particle emitter.
 *
 * When creating a particle system, you write application-specific implementation of CC3ParticleProtocol
 * to embody the state and life-cycle behaviour of each particle. You do not always need to create a
 * customized subclass of CC3ParticleEmitter.
 * 
 * To implement a specific particle system, create an implementation of CC3ParticleProtocol, and override
 * the initializeParticle and updateBeforeTransform: methods (and possibly the updateAfterTransform:
 * method) to define the initial state, and life-cycle behaviour of the particle.
 *
 * Particles can be added to an emitter by the application directly, or can be created and emitted
 * from the emitter automatically, based on configuration within the emitter. In both cases, the
 * interaction on the particle is the same.
 *
 * When a particle starts its life, the emitter will automatically invoke the initializeParticle
 * method on the particle.
 *
 * Then, during the life-cycle of a particle, the emitter will periodically update the particle by
 * invoking the updateBeforeTransform: and updateAfterTransform: callback methods. These method
 * invocations include the time interval since the last update, so that the particle can emulate
 * realistic real-time behaviour.
 *
 * Be aware that, in the interests of performance and memory conservation, expired particles may be
 * cached and reused, and particle emission may not always involve instantiating a new instance of
 * your CC3ParticleProtocol implementation class.
 *
 * With this in mind, you should not depend on init method being invoked during particle emission.
 * All code that establishes the initial emitted state of a particle should be included in the
 * initializeParticle method.
 *
 * From within the initializeParticle, updateBeforeTransform: and updateAfterTransform methods,
 * the particle has access to the emitter (and the node hierarchy and scene it sits in) through
 * the emitter property. In addition, the particle can read and manipulate its own drawable content. 
 *
 * Beyond these basic drawable content properties, when you create in implementation of
 * CC3ParticleProtocol, you should add any other content that is needed to determine the behaviour
 * of your particle. For example, you might include a velocity property for particles that are
 * following a path (or even a path object to define that path more explicitly), and a timeToLive
 * property, for particles that have a finite lifespan. There are several protocol extensions,
 * such as CC3MortalParticleProtocol and CC3UniformlyMovingParticleProtocol that provide standard
 * definitions of basic additional functionality in this respect.
 *
 * It is up to the particle to determine when it expires. Some particles may never expire.
 * Others may keep track of their life or path and expire at a certain time or place.
 *
 * Once your custom particle has detemined that it has expired, in the updateBeforeTransform: or
 * updateAfterTransform method, you can set the isAlive property of the particle to NO. When either
 * of those methods returns, the emitter will then automatically remove the particle (and set it
 * aside for possible reuse). Expired particles are not drawn and do not receive further
 * updateBeforeTransform: or updateAfterTransform: callback method invocations.
 *
 * You can also set the isAlive property to NO in the initializeParticle method
 * to cause the emission of the particle to be aborted.
 */
@protocol CC3ParticleProtocol <CC3Object>

/**
 * The emitter that emitted this particle.
 *
 * This property is set automatically when the particle is added to the emitter, or emitted
 * automatically by the emitter. The application should not set this property directly.
 * Doing so will cause the particle to abort emission.
 */
@property(nonatomic, assign) CC3ParticleEmitter* emitter;

/**
 * Indicates whether this particle is alive or not. When a particle is added to the emitter,
 * or emitted automatically by the emitter, the value of this property is automatically set
 * to YES by the emitter before the initializeParticle method is invoked.
 *
 * You can set this property to NO from within the updateBeforeTransform: or updateAfterTransform:
 * method to indicate that this particle has expired. When either of those methods returns, the
 * emitter will then automatically remove the particle (and set it aside for possible reuse).
 * Expired particles are not drawn and do not receive further updateBeforeTransform: or
 * updateAfterTransform: method invocations.
 *
 * You can also set the isAlive property to NO in the initializeParticle method to cause the
 * emission of the particle to be aborted.
 */
@property(nonatomic, assign) BOOL isAlive;


#pragma mark Initializing and cleaning up

/**
 * This template callback method is invoked automatically at the beginning of the particle's
 * life-cycle, when this particle is added to the emitter manually by the application, or when
 * the particle is emitted automatically by the emitter.
 *
 * You should implement this method to establish any initial state of the particle.
 *
 * During execution of this method, you can access and set the initial values of the particle
 * properties. The emitter property can be used to access further information in the emitter or
 * other aspects of the 3D scene.
 *
 * This method is invoked after the the isAlive property has been set to YES, and after the emitter
 * and its navigator have set any particle state that they want to initialize. In this method, you
 * can change any of the particle state prior to it being emitted. You can also set the isAlive
 * property of the particle to NO to cause the addition or emission of the particle to be aborted.
 *
 * When this method is invoked, the particle may have just been instantiated, or it may be an
 * older expired particle that is being reused. With this in mind, this method should include
 * all code that establishes the initial state of a particle. You should not rely on any state
 * set in the init method of the particle.
 * 
 * If you have subclassed another class that implements the CC3ParticleProtocol protocol, you should
 * be sure to invoke this method on the superclass as part of your implementation, to give the
 * superclass an opportunity to initialize the state it manages. You should also check the state
 * of the isAlive property as set by the superclass before performing further initialization.
 */
-(void) initializeParticle;

/**
 * The standard object initialization method that is invoked when this instance is instantiated.
 *
 * In the interests of performance and memory conservation, expired particles may be cached and
 * reused by the emitter. Your particle should not rely on any state set in this method. Most
 * initialization should be performed in the initializeParticle method, which is invoked each
 * time the particle is used or reused by the emitter.
 */
-(id) init;

/**
 * This template callback method is invoked automatically at the end of the particle's lifecycle,
 * when this particle has expired and been removed from active use.
 *
 * Since the emitter may hold onto the particle in an inactive state for future reuse, this method
 * provides the particle with the opportunity to release any content that depends on the particle
 * being alive and in use.
 */
-(void) finalizeParticle;

/** Returns a string containing a more complete description of this particle. */
-(NSString*) fullDescription;


#pragma mark Updating

/**
 * This template callback method is invoked automatically whenever the emitter is updated during a
 * scheduled 3D scene update. This method is invoked on the particles after the updateBeforeTransform:
 * method is invoked on the emitter, and before the emitter and particles are transformed.
 *
 * This method will only be invoked on the particles if the shouldUpdateParticlesBeforeTransform
 * property of the emitter is set to YES. As an optimization, for particles that do not need to
 * be updated before they are transformed, that property can be set to NO to avoid an unnecessary
 * iteration of the particles.
 *
 * You can override this method to control the behaviour and motion of the particle during its lifetime.
 *
 * The specified visitor includes a deltaTime property, which is the time interval since the last
 * update, so that the particle can emulate realistic real-time behaviour
 *
 * It is up to the particle to determine when it expires. Some particles may never expire. Particles
 * that do have a finite lifespan will keep track of their lifecycle, and accumulate the deltaTime
 * property of the specified visitor to keep track of the passing of time.
 *
 * Once the particle has detemined that it has expired, you can set the isAlive property of the
 * particle to NO in this method. When this method returns, if the isAlive property has been set to
 * NO, the emitter will automatically remove this particle (and set it aside for possible reuse).
 * Expired particles are not drawn and do not receive further updateBeforeTransform: method invocations.
 *
 * During execution of this method, you can access and set the particle's properties. The emitter
 * property can be used to access further information in the emitter or other aspects of the 3D scene.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;

/**
 * This template callback method is invoked automatically whenever the emitter is updated during a
 * scheduled 3D scene update. This method is invoked on the particles after the emitter and particles
 * have been transformed, and before the updateAfterTransform: method is invoked on the emitter.
 *
 * Because this method is invoked after the emitter has been transformed, you can access global
 * transform properties of the particle and emitter from within this method.
 *
 * The specified visitor includes a deltaTime property, which is the time interval since the last
 * update, so that the particle can emulate realistic real-time behaviour
 *
 * This method will only be invoked on the particles if the shouldUpdateParticlesAfterTransform
 * property of the emitter is set to YES. As an optimization, for particles that do not need to
 * be updated after they are transformed, that property can be set to NO to avoid an unnecessary
 * iteration of the particles.
 *
 * Although it is recommended that you determine whether a particle should expire in the
 * updateBeforeTransform: method to avoid transforming a particle you no longer need, you can
 * also set the isAlive property of the particle to NO in this method to cause the emitter to
 * remove this particle (and set it aside for possible reuse). Expired particles are not drawn
 * and do not receive further updateAfterTransform: method invocations.
 */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3ParticleEmitter

/**
 * Constant representing an infinite interval of time.
 *
 * This can be used with the emissionDuration and emissionInterval properties.
 */
static const CCTime kCC3ParticleInfiniteInterval = kCC3MaxGLfloat;

/**
 * Constant representing an infinite rate of emission.
 *
 * This can be used with the emissionRate property, and indicates
 * that all particles should be emitted at once.
 */
static const CCTime kCC3ParticleInfiniteEmissionRate = kCC3MaxGLfloat;

/**
 * Constant representing an unlimited number of particles.
 *
 * This can be used with the maximumParticleCapacity property, and indicates that there
 * is no pre-defined maximum limit to the number of particles that will be emitted.
 */
static const GLuint kCC3ParticlesNoMax = UINT_MAX;

/**
 * A CC3MeshNode that emits 3D particles.
 *
 * Particles are small, simple objects that can each have their own location, movement,
 * color, and lifetime. They are used where many simple and similar objects are needed.
 * Examples might include confetti, stars, tiles, bricks, etc.
 *
 * One key way that particles differ from mesh nodes is that all vertices for all of the particles
 * managed by an emitter are submitted to the GL engine in a single draw call. This is much more
 * efficient than each mesh making its own GL call, and for large numbers of small objects, this
 * technique dramatically improves performance.
 *
 * Particles can be added to an emitter directly, using the emitParticle: method, can be created
 * and emitted from the emitter manually, using the emitParticle and emitParticles: method, or
 * can be emitted automatically at a pre-determined rate from the emitter by setting the emission
 * properties of the emitter.
 
 * Typically, particles are automatically created and emitted by the emitter at some predetermined
 * rate and pattern, such as a fountain, fire, hose, etc. and follow a pre-determined algorithmic
 * path with a finite life span.
 *
 * Alternately, particles can be added to the emitter by the application directly, with the emitter
 * containing and managing the particles, but leaving the application in control of particle control
 * and interaction. In this use case, the emitter acts as a mesh batching system, allowing the meshes
 * from a large number of distinct objects to be submitted to the GL engine in a single draw call.
 * For example, the application may want to create a large number of bricks, tiles, plants, etc.,
 * and have them efficiently managed and rendered by an emitter.
 *
 * All particles added to or emitted by this emitter will be covered by the same material, and optional
 * texture, as determined by the material and texture properties of this emitter node. But each particle
 * may have its own location, movement, orientation, normals, and colors.
 *
 * Although all particles are covered by the same material and texture, if the vertexContentTypes
 * property of this emitter is configured with the kCC3VertexContentColor component, then each
 * particle can be assigned a different color. And for particles that support texture mapping,
 * such as mesh particles, then each particle can be covered by a different section of the
 * texture assigned to the emitter, effectivly allowing each particle to be textured differently.
 *
 * Particles managed by a CC3ParticleEmitter live in the 3D scene, as distinct from the 2D
 * particles available through the cocos2d CCParticleSystem class.
 * 
 * For many particle effects, 2D is sufficient, and can be quite effective. You can use a cocos2d
 * CCParticleSystem instance with a CC3Billboard, to embed 2D particle systems within a 3D cocos3d scene.
 *
 * However, for applications that need particles to move in three dimensions, you can use this class,
 * or one of its specialized subclasses. Each particle emitted by this emitter has a 3D location,
 * and can appear in front of or behind other 3D objects, depending on relative distance from the camera.
 *
 * A particle system embodies three classes working together to emit and control particles.
 *   -# The emitter is responsible for generating and managing particles of a particular type.
 *      Particles that have expired can be reused, reinitialized and re-emitted by the emitter.
 *      Typically, you will use one of the standard emitters.
 *   -# The navigator is attached to the emitter and configures the lifetime and path of the
 *      particle. You can use one of the standard navigators, but you will often write your
 *      own navigator to provide more interesting emission characterstics and finer control
 *      of how each particle is configured.
 *   -# The particle itself is responsible for executing the behaviour and motion of the particle
 *      throughout its lifespan. You will generally always write your own particle subclass.
 *
 * When a particle is added or emitted, all three of these objects get a chance to initialize
 * and configure the particle. Typically, the emitter is responsible for instanitating a new
 * particle, or arranging to reuse an expired particle. The navigator initializes the lifetime
 * and path configuration information within the particle, or the particle itself can do so
 * during its own initialization. During this process, the emitter invokes the initializeParticle:
 * method on itself and the navigator, and then the initializeParticle method on the particle.
 *
 * The isAlive property is automatically set to YES before the initializeParticle method is
 * invoked on the particle, so you don't have to set it there. You can, however, set it to
 * NO during execution of the initializeParticle method, to abort the emission of that particle.
 *
 * Subsequently, on each update pass, the emitter will automatically invoke the updateBeforeTransform:
 * method (and optionally the updateAfterTransform: method) on the particle. You will override this
 * method to define the behaviour of your particles over time. If your particles have a finite lifespan,
 * you can indicate that a particle has expired by having the particle set its own isAlive property
 * to NO within the updateBeforeTransform: (or updateAfterTransform:) method. The emitte will then
 * arrange to remove the particle and set it aside for future reuse.
 *
 * To enhance performance and memory, particles that have expired are retained and reused as further
 * particles are emitted. This is transparent to the particles (and the developer), as the reused
 * particle follow the same initialize/update life-cycle described above. The isAlive property is
 * reset to YES, and the initializeParticle: methods of the emitter and navigator, and the
 * initializeParticle method of the particle are invoked when the particle is reused and emitted again.
 *
 * Like all mesh nodes, the emitter contains a CC3Material instance that determines how the particle
 * content will blend with content from other 3D objects that overlap this emitter, and to specify
 * the texture that covers the particles.
 *
 * You can indicate the rate at which particle are emitted by setting either of the emissionRate
 * or emissionInterval properties. You can set for how long the emitter should emit particles
 * using the emissionDuration property.
 *
 * For emitters with finite emissionDuration, you can set the shouldRemoveOnFinish to YES to
 * indicate that the emitter should remove itself automatically from the 3D scene, once all
 * particles have expired, cleaning up all memory usage by the emitter and particles along the
 * way. This features allows you to set a transient particle generator, such as an explosion,
 * going and then forget about it.
 *
 * By default, the boundingVolume of the emitter will automatically be recalculated every time
 * a particle moves. Although this is convenient and ensures accuracy, recalculating the bounding
 * volume can often be an expensive operation. To avoid this, you can manually set static boundaries
 * in the boundingVolume of this emitter node and then set the shouldUseFixedBoundingVolume property
 * of this emitter to YES to indicate that you don't want the emitter to recalculate its
 * boundingVolume on each update.
 *
 * During development, you can verify the size of this static bounding volume your settings by
 * setting the shouldDrawBoundingVolume property to YES to make the bounding volume visible to
 * ensure that the bounding volume is sized appropriately to contain all the particles, without
 * being overly expansive.
 *
 * You may be wondering how to determine the correct static bounding volume properties. You can do
 * this at development time by setting the shouldMaximize property of the boundingVolume of this
 * emitter to YES, and setting the shouldUseFixedBoundingVolume property of this emitter to NO, so
 * that the boundingVolume will be recalculated on each update. After the emitter has finished,
 * output the boundingVolume to the log using LogDebug to record the maximume size that the bounding
 * volume grew to during particle emission. This will give you an idea of how big to set the static
 * boundary properties of the boundingVolume of your emitter.
 *
 * All memory used by the particles and the underlying vertex mesh is managed by this
 * emitter node, and is deallocated automatically when the emitter is released.
 */
@interface CC3ParticleEmitter : CC3MeshNode {
	NSMutableArray* _particles;
	CC3ParticleNavigator* _particleNavigator;
	Class _particleClass;
	GLuint _currentParticleCapacity;
	GLuint _maximumParticleCapacity;
	GLuint _particleCapacityExpansionIncrement;
	GLuint _particleCount;
	CCTime _emissionDuration;
	CCTime _elapsedTime;
	CCTime _emissionInterval;
	CCTime _timeSinceEmission;
	BOOL _shouldRemoveOnFinish : 1;
	BOOL _isEmitting : 1;
	BOOL _wasStarted : 1;
	BOOL _shouldUpdateParticlesBeforeTransform : 1;
	BOOL _shouldUpdateParticlesAfterTransform : 1;
}

/**
 * The customized implementation of CC3ParticleProtocol used to instantiate new particles that
 * are emitted by this emitter.
 *
 * This property must be set before emission begins.
 *
 * When setting this property to a particular particle class, that class must implement the
 * protocols specified by the requiredParticleProtocol property of both this emitter and the
 * particle navigator. This restriction permits specialized emitters and navigators to limit
 * the particles to those that can be configured by the emitter and particle navigator.
 *
 * The initial value of this property is nil, and no particles will be automatically emitted
 * by this emitter.
 *
 * Although not common, you can change this property during particle emission in order to have
 * the emitter emit particles with different behaviour, as long as the new particle class
 * implements the protocols specified by the requiredParticleProtocol property of both this
 * emitter and the particle navigator
 */
@property(nonatomic, retain) Class particleClass;

/**
 * The protocol required for particles emitted by this emitter.
 *
 * This implementation returns @protocol(CC3ParticleProtocol), permitting all particles to
 * be initialized. In a subclass, you  may override to support more specific protocols, based
 * on your needs for configuring particles. When doing so, your protocol must also conform to
 * the base CC3ParticleProtocol protocol.
 *
 * Because each configuration is unique, this library contains a number of building-block
 * configuration protocols that may be applied to a particle. And you will often want to create
 * your own particle configuration protocols. Since this property may contain only a single
 * protocol, you can create a custom protocol that wraps all of the protocols that you want
 * to use to configure your particle, and assign that custom protocol to this property.
 *
 * For example, you may want to use both the CC3UniformlyFadingParticleProtocol and
 * CC3UniformlyRotatingParticleProtocol protocols to configure a rotating, colored particle.
 * To encompass both requirements, you should create another custom protocol that wraps
 * (conforms to) both of those protocols, and assign it to this requiredParticleProtocol property.
 */
@property(nonatomic, retain, readonly) Protocol* requiredParticleProtocol;

/**
 * For particles that follow a planned life-cycle and trajectory, the particle navigator configures that
 * life-cycle and trajectory into each particle prior to the particle being emitted by this emitter.
 *
 * The particle navigator is strictly used during initial configuration of the particle.
 * It does not play any active part in managing the life-cycle or trajectory of the particle
 * once it has been emitted.
 *
 * A particle navigator is not required for particles that can determine their own life-cycle
 * and trajectory dynamically, without the need for configuration.
 *
 * Because the particle navigator may have specialized configuration requirements, when setting
 * this property, the class indicated by the particleClass property is evaluated to see if it
 * supports the protocol required by this navigator, as indicated by the requiredParticleProtocol
 * property of the navigator, and raises an assertion if the particleClass does not support the
 * protocol required by the navigator.
 *
 * The initial value of this property is nil, indicating that the particles will not be
 * configured with a life-cycle and trajectory by a navigator.
 */
@property(nonatomic, retain) CC3ParticleNavigator* particleNavigator;

/**
 * Indicates the length of time that the emitter will emit particles.
 *
 * Setting this value to kCC3ParticleInfiniteDuration indicates that the emitter should continue
 * emitting particles forever, or until the pause or stop method are invoked or the isEmitting is
 * manually set to NO.
 *
 * The initial value is kCC3ParticleInfiniteDuration.
 */
@property(nonatomic, assign) CCTime emissionDuration;

/**
 * For emitters with a finite emissionDuration, indicates the length of time that this
 * emitter has been emitting particles.
 *
 * When the value of this property exceeds the value of the emissionDuration property,
 * the pause method is automatically invoked to cease the emission of particles.
 */
@property(nonatomic, readonly) CCTime elapsedTime;

/**
 * The rate that particles will be emitted, expressed in particles per second.
 * You can use this property as an alternate to the emissionInterval property.
 * 
 * Emission begins when the play method is invoked.
 * 
 * The initial value of this property is zero, indicating that no particles
 * will be automatically emitted.
 *
 * As an alternate to setting this property to engage automatic emission, you can leave this
 * property at its initial value and manually invoke the emitParticle method whenever you
 * determine that you want to emit a particle, or you may use the emitParticle: method to add
 * a particle that you have created outside the emitter.
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
 * As an alternate to setting this property to engage automatic emission, you can leave this
 * property at its initial value and manually invoke the emitParticle method whenever you
 * determine that you want to emit a particle, or you may use the emitParticle: method to add
 * a particle that you have created outside the emitter.
 */
@property(nonatomic, assign) CCTime emissionInterval;

/**
 * Indicates that this emitter should automatically be removed from its parent, and
 * from the 3D scene when it is finished (when the isFinished property turns to YES).
 *
 * This is useful for emitters that are created to generate a transient effect such as an explosion.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldRemoveOnFinish;


#pragma mark Allocation and initialization

/**
 * Indicates the maximum number of particles that can be alive at any one time in the
 * particle system managed by this emitter.
 *
 * The initial number of particles is zero. As the number of particles grows, memory is
 * allocated for them in increments defined by the particleCapacityExpansionIncrement
 * property, until this capacity is reached. Once this value is reached, no further memory
 * will be allocated, and new particles will only be emitted as old ones die off.
 *
 * You can set the value of this property to kCC3ParticlesNoMax to indicate that no pre-defined
 * limit to the number of particles exists. However, you should be careful when designing your
 * particle emitter so it either reaches a steady state, or has a short enough lifetime, that
 * the memory requirements do not continue to grow without bounds.
 * 
 * This property does not define the maximum number of particles that can be emitted over time.
 * As particles age, you can indicate that a particle has expired by setting the isAlive property
 * of the CC3ParticleProtocol to NO in the updateBeforeTransform: or updateAfterTransform: methods
 * of the particle. This frees that particle to be re-initialized and re-emitted at a later time.
 *
 * The value of this property defines the maximum amount of memory that will be allocated
 * for particles, and their vertex content, used by this emitter. When this emitter is
 * deallocated, that memory will automatically be released.
 *
 * The initial value of this property is kCC3ParticlesNoMax, indicating that there is no
 * pre-defined maximum limit to the number of particles that will be emitted.
 */
@property(nonatomic, assign) GLuint maximumParticleCapacity;

/**
 * Indicates the current maximum number of particles that can be alive at any one time in the
 * particle system managed by this emitter, before further memory will need to be allocated.
 * This property is a measure of the amount of memory that has currently been allocated for particles.
 *
 * The initial number of particles is zero, and the initial capacity is zero. As the number
 * of particles grows, memory is allocated for them in increments defined by the
 * particleCapacityExpansionIncrement property, until the maximum capacity defined by the
 * maximumParticleCapacity property is reached. After each memory allocation, this
 * currentParticleCapacity property indicates how many particles can be alive simultaneously
 * before a further memory allocation will be required.
 * 
 * This property does not define the maximum number of particles that can be emitted over time
 * without further expansion. As particles age, you can indicate that a particle has expired by
 * setting theisAlive property of the CC3ParticleProtocol to NO in the updateBeforeTransform: or
 * updateAfterTransform: methods of the particle. This frees that particle to be re-initialized
 * and re-emitted at a later time.
 */
@property(nonatomic, readonly) GLuint currentParticleCapacity;

/**
 * The amount of additional particle capacity that will be allocated each time space for
 * additional particle is created.
 *
 * The initial number of particles is zero. As the number of particles grows, memory is allocated
 * for them in increments defined by this property until the maximum capacity defined by the
 * maximumParticleCapacity property is reached.
 *
 * Setting the value of this property equal to the value of the maximumParticleCapacity property
 * will allocate the memory for all particles in one stage when the first particle is added or
 * emitted. If the number of particles of your emitter is fairly steady, this is the most efficient
 * way to allocate memory. If the number of particles is not easy to quantify in advance, or can
 * vary considerably, it may be best to set this property with value smaller than that of the
 * maximumParticleCapacity property.
 *
 * The initial value of this property is 100.
 */
@property(nonatomic, assign) GLuint particleCapacityExpansionIncrement;

/**
 * Returns whether the maximum number of particles has been reached. This occurs when the value
 * of the particleCount property reaches the value of the maximumParticleCapacity property.
 * When this occurs, no further particles will be emitted until some particles expire.
 */
@property(nonatomic, readonly) BOOL isFull;


#pragma mark Updating

/**
 * Indicates whether the emitter should invoke the updateBeforeTransform: method on each
 * particle before the emitter node and particles have been transformed.
 *
 * Since most active particles need to perform activities before being transformed, such as
 * updating their location, the initial value of this property is YES. If your customized
 * particles do not require such behaviour (for example, static particles such as stars or
 * bling decoration on another node), set the value of this property to NO to avoid unnecessary
 * iteration over a potentially large number of particles.
 */
@property(nonatomic, assign) BOOL shouldUpdateParticlesBeforeTransform;

/**
 * Indicates whether the emitter should invoke the updateAfterTransform: method on each
 * particle after the emitter node and particles have been transformed.
 *
 * Since it is uncommon for particles to need to perform activities after being transformed,
 * the initial value of this property is NO, in order to avoid unnecessary iteration over a
 * potentially large number of particles. If your customized particles have defined behaviour
 * that is to be performed after the particles and emitter have been transformed, set the value
 * of this property to YES.
 */
@property(nonatomic, assign) BOOL shouldUpdateParticlesAfterTransform;

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
 */
-(void) stop;

/**
 * Indicates whether the emitter is currently emitting particles.
 *
 * For emitters with a finite emissionDuration, the value of this property will
 * automatically be set to NO once that emissionDuration has passed.
 *
 * For emitters with infinite emissionDuration, or for emitters with a finite emissionDuration
 * that has not yet passed, setting the value of this property to NO will stop the emitter from
 * emitting any further particles. Particles that have already been emitted will continue to be
 * updated and displayed.
 *
 * Setting this property to YES has the same effect as invoking the play method. Setting this
 * property to NO has the same effect as invoking the pause method.
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
 * Formally, this property returns YES if either the isEmitting property returns YES or the
 * value of the particleCount property is greater than zero. Otherwise this property returns NO.
 *
 * The stop method can be used to force this emitter to be immediately inactive.
 */
@property(nonatomic, readonly) BOOL isActive;

/**
 * Indicates whether particle emission has ceased and all particles have lived out their lives.
 *
 * This property will return YES if the isEmitting property was previously set to YES (or the
 * play method was previously invoked), and the isActive property now has a value of NO.
 *
 * This property is distinguished from the isActive property in that the isActive property
 * will be NO both before and after emission, whereas the isFinished property will be NO
 * both before and during emission, and will be YES only after emission.
 *
 * The stop method can be used to force this condition immediately.
 */
@property(nonatomic, readonly) BOOL isFinished;


#pragma mark Emitting particles

/**
 * Emits a single particle of the type specified in the particleClass property.
 *
 * Each particle is initialized prior to emission. A particle can be initialized in any of the
 * initializeParticle: method of the emitter, the initializeParticle: method of the particle
 * navigator, or the initializeParticle method of the particle itself. Each particle system has
 * different needs. To initialize each particle, you should override a combination of these
 * methods, as appropriate to initialize the particles.
 *
 * For particles that follow a planned life-cycle and trajectory, the initializeParticle: method
 * of the particle navigator is the appropriate place to initialize the life-cycle and trajectory
 * of the particle. For particles that are more self-aware and self-determining, the initializeParticle
 * method of the particle itself may be the best place to initialized the particle.
 *
 * If the emitter is set to emit particles automatically, by setting an emissionRate or
 * emissionInterval, and then invoking play, you do not need to invoke this method directly.
 * It will be invoked automatically when it is time to emit a particle. This is the most
 * common situation, and so in most cases, you will never invoke this method directly.
 *
 * However, there are some situations where the application might want more control over the
 * creation or configuration of particles. One example might be if you want to create a quantity
 * of fixed particles, such as a chain, or lights on a tree, that are not emitted at a steady
 * rate. Another example might be that you want to be able to configure or track each particle
 * from the application code, once it has been created, emitted, and returned from this method.
 *
 * In these situations, you can avoid invoking play (and avoid setting the isEmitting flag set
 * to YES), and then invoke the emitParticle method whenever you want to create a new particle.
 * 
 * This method returns the emitted particle. If the maximum capacity has been reached, as
 * defined by the maximumParticleCapacity property, or if the particle itself aborts the
 * emission by setting the isAlive property to NO in the initializeParticle method of the
 * particle, this method will return nil.
 *
 * You may also use the emitParticle: method to create partiles outside of the emitter and add
 * them to the emitter. You can use that emitParticle: method instead of this method when you
 * want to select different particle classes. This emitParticle class will always emit a
 * particle of the class defined by the particleClass property.
 */
-(id<CC3ParticleProtocol>) emitParticle;

/**
 * Emits the specified number of particles, by invoking the emitParticle method repeatedly.
 *
 * Returns the number of particles that were emitted. If a particle aborts emission, or if
 * the maximum number of particles, as defined by the maximumParticleCapacity property is
 * reached, the returned number may be less that the specified count.
 */
-(GLuint) emitParticles: (GLuint) count;

/**
 * Adds the specified particle to the emitter and emits it.
 *
 * This method allows the application to create and initialize particles outside of the emitter,
 * instead of having the emitter instantiate and intialize them.
 *
 * This method is particularly useful when the application wants to create and emit a particle
 * of a class other than the class indicated by the particleClass method. In doing so, the
 * application must adhere to the requirement that the particle must implement the protocols
 * specified by the requiredParticleProtocol property of both this emitter and the particle
 * navigator. Submitting a particle to this method that does not implement both of these
 * required protocols will raise an assertion exception.
 *
 * This method is also useful when the application does not want particles to be automatically
 * emitted, but wants the emitter to efficiently manage and render a large number of particles
 * created by the application. For example, the application may want to create and manage a large
 * number of bricks, tiles, plants, swarms, etc.
 * 
 * Particles added by this method follow exactly the same initialization and update process as
 * particles that are emitted by this emitter. As with each emitted particle, for each particle
 * added using this method the initializeParticle: method is invoked on each of the emitter and
 * navigator in turn, and then the initializeParticle method is invoked on the particle itself.
 * 
 * There are only two differences between the emitParticle and emitParticle: methods:
 *   - The emitParticle method will reuse an expired particle if one is available. The emitParticle:
 *     method accepts a new particle instance on each invocation.
 *   - The emitParticle method automatically instantiates particles of the class indicated
 *     by the particleClass property. The emitParticle: method allows the application to instantiate
 *     a particle of any class that implements the protocols defined by the requiredParticleProtocol
 *     property of both this emitter and the particle navigator.
 * 
 * You may combine use of the emitParticle method and the emitParticle: method. You may also combine use
 * of automatic emission (by configuring an emission schedule within this emitter and then invoking the
 * play method), and manual emission using a combination of the emitParticle and emitParticle: methods.
 *
 * When using a combination of emission techniques, particles added by this method are eligible
 * to be reused automatically by the emitter once they have expired.
 *
 * When initializing particles outside of the emitter prior to invoking this method, be sure that
 * the emitter property of the particle is set to nil when submitting the particle to this method,
 * as the emitter uses this property as an indication of whether the particle was created outside
 * the emitter, or generated automatically inside the emitter.
 */
-(BOOL) emitParticle: (id<CC3ParticleProtocol>) aParticle;

/**
 * Returns a particle suitable for emission by this emitter. The returned particle can subsequently
 * be emitted from this emitter using the emitParticle: method.
 *
 * The particle emitted may be an existing expired particle that is being reused, or it may be a
 * newly instantiated particle. If an expired particle is available within this emitter, it will
 * be reused. If not, this method invokes the makeParticle method to create a new particle.
 * 
 * You can also use the makeParticle method directly to ensure that a new particle has been created.
 */
-(id<CC3ParticleProtocol>) acquireParticle;

/**
 * Creates a new autoreleased instance of a particle of the type specified by the particleClass property.
 * The returned particle can subsequently be emitted from this emitter using the emitParticle: method.
 *
 * Distinct from the acquireParticle method, this method bypasses the reuse of expired particles
 * and always creates a new autoreleased particle instance.
 */
-(id<CC3ParticleProtocol>) makeParticle;

/**
 * Template method that initializes the particle. This method is invoked automatically
 * from the emitParticle method just prior to the emission of the specified particle.
 *
 * This method is invoked after the isAlive property of the particle has been set to YES,
 * and prior to the invocation of the initializeParticle: on the particle navigator and the
 * initializeParticle method on the particle.
 * 
 * In this method, you can set the isAlive property of the particle to NO to cause the
 * emission of the particle to be aborted.
 * 
 * When this method is invoked, the particle may have just been instantiated, or it may be an
 * older expired particle that is being reused. With this in mind, this method should include all
 * code that establishes the initial emitted state of a particle that is to be set by the emitter.
 * You should not rely on any state set in the instance initializer of the particle class.
 *
 * This method is invoked automatically by the emitter when a particle is emitted.
 * Usually the application never has need to invoke this method directly.
 */
-(void) initializeParticle: (id<CC3ParticleProtocol>) aParticle;


#pragma mark Accessing particles

/**
 * The array of particles.
 *
 * The application must not change the contents of this array directly.
 */
@property(nonatomic, retain, readonly) NSArray* particles;

/**
 * The number of particles that are currently alive and being displayed by this emitter. The value of
 * this property will increase as particles are emitted, and will decrease as particles age and expire.
 */
@property(nonatomic, readonly) GLuint particleCount;

/** Returns the particle at the specified index within the particles array. */
-(id<CC3ParticleProtocol>) particleAt: (GLuint) aParticleIndex;

/**
 * Returns the particle that contains the vertex at the specified index, or nil if no particle
 * contains the specified vertex.
 */
-(id<CC3ParticleProtocol>) particleWithVertexAt: (GLuint) vtxIndex;

/**
 * Returns the particle that contains the vertex index at the specified index, or nil if no particle
 * contains the specified vertex index.
 *
 * If the mesh of this emitter contains a vertex index array, the value returned by this method may
 * be different than that returned by the particleWithVertexAt: method, which references the index of
 * the vertex, whereas this method references the index of the vertex index that points to the vertex.
 *
 * If the mesh of this emitter does not contain a vertex index array, the value returned by this
 * method will be the same as the value returned by the particleWithVertexAt: method, because in
 * that case, there is a one-to-one relationship between a vertex and its index.
 */
-(id<CC3ParticleProtocol>) particleWithVertexIndexAt: (GLuint) index;

/**
 * Returns the particle that contains the face at the specified index, or nil if no particle
 * contains the specified face.
 *
 * This is a convenience method that determines the first vertex index associated with the
 * specified face, taking into consideration the drawingMode of this emitter, and then invokes
 * the particleWithVertexIndexAt: method to retrieve the particle from that vertex index.
 */
-(id<CC3ParticleProtocol>) particleWithFaceAt: (GLuint) faceIndex;

/**
 * Removes the specified particle from the emitter, sets the isAlive property of the particle to NO,
 * and retains the particle for reuse.
 *
 * Normally, the recommended mechanism for removing a particle is to set its isAlive property to NO,
 * which will cause the particle to automatically be removed on the next update loop, if either of the
 * shouldUpdateParticlesBeforeTransform or shouldUpdateParticlesAfterTransform properties is set to YES.
 *
 * This method may be used instead, in cases where the shouldUpdateParticlesBeforeTransform and
 * shouldUpdateParticlesAfterTransform properties are both set to NO, or where the update loop is delayed
 * (perhaps due to less frequent updates of the particles), and the particle must be removed immediately.
 *
 * If the specified particle is not currently alive, or has already been removed, this method does nothing.
 */
-(void) removeParticle: (id<CC3ParticleProtocol>) aParticle;

/** Removes all the particles from the emitter. They remain cached for reuse. */
-(void) removeAllParticles;


@end


#pragma mark -
#pragma mark CC3ParticleNavigator

/**
 * A particle navigator is assigned to a single particle emitter, and is responsible for configuring
 * the life cycle and emission path of the particle on behalf of the emitter.
 *
 * When creating your own particle system, customization is accomplished primarily by creating
 * your own implementation of the CC3ParticleProtocol, and your own CC3ParticleNavigator subclass.
 * You are encouraged to create subclasses of CC3ParticleNavigator (perhaps starting from one of
 * the existing provided subclasses).
 *
 * During particle initialization, the emitter, the navigator, and the particle itself are given a
 * chance to participate in the initialization of the particle. The navigator is distinct from the
 * emitter itself in that the navigator is primarily designed to direct the shape of the emission,
 * by setting particle properties such as the location, direction, and speed of the particle.
 * This separation of responsibilities often means that a single navigator class can be used to
 * direct any type of particle.
 *
 * For example, a particle navigator designed to emit partiles in the the shape of a fountain could
 * be used to create a fountain of point particles, a fountain of mesh particles, or a fountain of
 * some other class of particles that supported the protocol required by the navigator.
 *
 * Similarly, a navigator designed to lay particles out on a grid, or sprinkle stars across the
 * sky could do so with point particles or mesh particles.
 * 
 * The particle navigator is only involved in the initialization of the particle. It does not
 * interact with the particle once it has been emitted.
 *
 * Different particle navigators will have different requirements for configuring particles.
 * The requiredParticleProtocol property of this navigator indicates the protocol that the
 * particles must support in order to be prepared by this navigator during initialization.
 */
@interface CC3ParticleNavigator : NSObject <NSCopying> {
	CC3ParticleEmitter* _emitter;
}

/**
 * The emitter whose particles are prepared by this navigator.
 *
 * This property is set automatically when the navigator is attached to the emitter.
 * Usually the application never needs to set this property directly.
 */
@property(nonatomic, assign) CC3ParticleEmitter* emitter;

/**
 * The protocol required by this particle navigator on the particles, in order for this navigator
 * to configure the particles.
 *
 * This implementation returns @protocol(CC3ParticleProtocol), permitting all particles to
 * be initialized. In a subclass, you  may override to support more specific protocols, based
 * on your needs for configuring particles. When doing so, your protocol must also conform to
 * the base CC3ParticleProtocol protocol.
 *
 * Because each configuration is unique, this library contains a number of building-block
 * configuration protocols that may be applied to a particle. And you will often want to create
 * your own particle configuration protocols. Since this property may contain only a single
 * protocol, you can create a custom protocol that wraps all of the protocols that you want
 * to use to configure your particle, and assign that custom protocol to this property.
 *
 * For example, you may want to use both the CC3UniformlyFadingParticleProtocol and
 * CC3MortalParticleProtocol protocols to configure a fading particle that has a finite life.
 * To encompass both requirements, you should create another custom protocol that wraps
 * (conforms to) both of those protocols, and assign it to this requiredParticleProtocol property.
 */
@property(nonatomic, retain, readonly) Protocol* requiredParticleProtocol;

/**
 * Template method that initializes the particle. For particles that follow a planned life-cycle
 * and trajectory, this navigator configures that life-cycle and trajectory for the particle
 * prior to the particle being emitted.
 *
 * This method is invoked automatically from the emitter after the emitter has initialized
 * the particle and before the initializeParticle method is invoked on the particle itself.
 *
 * Subclasses will override this method to configure the particle. Subclasses should always invoke
 * the superclass implementation to ensure the superclass initialization behaviour is performed.
 * 
 * In this method, you can set the isAlive property of the particle to NO to cause the
 * emission of the particle to be aborted.
 * 
 * When this method is invoked, the particle may have just been instantiated, or it may be an
 * older expired particle that is being reused. With this in mind, this method should include all
 * code that establishes the initial emitted state of a particle that is to be set by the navigator.
 * You should not rely on any state set in the instance initializer of the particle class.
 *
 * This method is invoked automatically by the emitter when a particle is emitted.
 * Usually the application never has need to invoke this method directly.
 */
-(void) initializeParticle: (id<CC3ParticleProtocol>) aParticle;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) navigator;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or copyWithZone:
 * method. In most situations, the application should use the copy method, and should never
 * need to invoke this method directly.
 * 
 * Subclasses that add additional instance state (instance variables) should extend copying by
 * overriding this method to copy that additional state. Superclass that override this method should
 * be sure to invoke the superclass implementation to ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3ParticleNavigator*) another;

@end


#pragma mark -
#pragma mark CC3CommonVertexArrayParticleProtocol

/**
 * CC3CommonVertexArrayParticleProtocol defines the requirements for particles that are emitted
 * and managed by the CC3CommonVertexArrayParticleEmitter class.
 *
 * A CC3CommonVertexArrayParticleEmitter maintains the vertices of all particles in common
 * vertex arrays.
 */
@protocol CC3CommonVertexArrayParticleProtocol <CC3ParticleProtocol>

/** Returns the number of vertices in this particle. */
@property(nonatomic, readonly) GLuint vertexCount;

/**
 * Returns the range of vertices in the underlying mesh that are managed by this particle.
 *
 * The location element of the returned range structure contains the index to the first vertex
 * of this particle, and the length element contains the same value as the vertexCount property.
 */
@property(nonatomic, readonly) NSRange vertexRange;

/**
 * Returns the number of vertex indices required for the mesh of this particle.
 *
 * Not all meshes use vertex indices. If indexed drawing is used by this particle, this method returns
 * the number of vertex indices in the particle. If indexed drawing is not used by this particle, this
 * property returns the same value as the vertexCount property, indicating, in effect, the number of
 * indices that would be required if this particle was converted to using indexed drawing.
 *
 * This behaviour allows a particle that does not use indexed drawing to be added to an emitter that
 * does use indexed drawing. When this happens, the missing vertex indices are automatically synthesized.
 */
@property(nonatomic, readonly) GLuint vertexIndexCount;

/**
 * Returns the range of vertex indices in the underlying mesh that are managed by this particle.
 *
 * The location element of the returned range structure contains the index to the first vertex index
 * of this particle, and the length element contains the same value as the vertexIndexCount property.
 *
 * Not all meshes use vertex indices. If indexed drawing is used by this particle, this method returns
 * the range of vertex indices in the particle. If indexed drawing is not used by this particle, this
 * property returns the same value as the vertexRange property, indicating, in effect, the range of
 * indices that would be required if this particle was converted to using indexed drawing.
 *
 * This behaviour allows a particle that does not use indexed drawing to be added to an emitter that
 * does use indexed drawing. When this happens, the missing vertex indices are automatically synthesized.
 */
@property(nonatomic, readonly) NSRange vertexIndexRange;

/** Returns whether this particle uses indexed vertices. */
@property(nonatomic, readonly) BOOL hasVertexIndices;

@end


#pragma mark -
#pragma mark CC3CommonVertexArrayParticleEmitter

/**
 * A CC3CommonVertexArrayParticleEmitter maintains the vertices of all particles in common
 * vertex arrays.
 *
 * This class forms the basis of both point particle emitters and mesh particle emitters.
 */
@interface CC3CommonVertexArrayParticleEmitter : CC3ParticleEmitter {
	NSRange _dirtyVertexRange;
	NSRange _dirtyVertexIndexRange;
	BOOL _wasVertexCapacityChanged;
}

@end


#pragma mark -
#pragma mark CC3ParticleBase

/**
 * CC3ParticleBase is a convenience class that forms a base implementation of the
 * CC3ParticleProtocol protocol.
 */
@interface CC3ParticleBase : NSObject <CC3ParticleProtocol, CCRGBAProtocol, NSCopying> {
	CC3ParticleEmitter* _emitter;
}

/**
 * The location of this particle in the local coordinate system of the emitter.
 *
 * You can set this property in the initializeParticle and updateBeforeTransform: methods
 * to move the particle around.
 *
 * The initial value of this property, set prior to the invocation of the 
 * initializeParticle method, is kCC3VectorZero.
 */
@property(nonatomic, assign) CC3Vector location;

/**
 * The location of the particle in 3D space, relative to the global origin.
 *
 * This is calculated by using the globalTransformMatrix of the emitter to transform
 * the location of this particle.
 */
@property(nonatomic, readonly) CC3Vector globalLocation;

/**
 * If this particle has individual color content, (which can be checked with the hasColor
 * property), this property indicates the color in which this particle will appear.
 *
 * If this particle has individual color content, you can set this property at any
 * time to define the color of the entire particle.
 *
 * Particles are configured for individual color content by including the kCC3VertexContentColor
 * component flag when setting the vertexContentTypes property of the emitter.
 *
 * Setting this property will set the color of all vertices in the particle to the assigned color.
 *
 * Reading this property returns the color value of the first vertex in the particle. If this
 * particle does not support individual color content, this property will always return the value
 * of the diffuseColor property of the emitter. In this condition, it is safe to set this property,
 * but changes will have no effect.
 */
@property(nonatomic, assign) ccColor4F color4F;

/**
 * If this particle has individual color content, (which can be checked with the hasColor
 * property), this property indicates the color in which this particle will appear.
 *
 * If this particle has individual color content, you can set this property at any
 * time to define the color of the entire particle.
 *
 * Particles are configured for individual color content by including the kCC3VertexContentColor
 * component flag when setting the vertexContentTypes property of the emitter.
 *
 * Setting this property will set the color of all vertices in the particle to the assigned color.
 * 
 * Reading this property returns the color value of the first vertex in the particle. If this
 * particle does not support individual color content, this property will always return the value
 * of the diffuseColor property of the emitter. In this condition, it is safe to set this property,
 * but changes will have no effect.
 */
@property(nonatomic, assign) ccColor4B color4B;

/**
 * Indicates whether this particle has individual color content. This is determine by the
 * configuration of the emitter. Within an emitter, either all particles have this content, or none do.
 *
 * When this property returns YES, each particle can be set to a different color. When this property
 * returns NO, all particles will have the color specified by the diffuseColor property of the emitter.
 *
 * Particles are configured for individual color content by including the kCC3VertexContentColor
 * component flag when setting the vertexContentTypes property of the emitter.
 */
@property(nonatomic, readonly) BOOL hasColor;

/**
 * Removes this particle from the emitter. The differs from setting the isAlive property to NO,
 * in that the removal is processed immediately, using the removeParticle: method of the emitter.
 */
-(void) remove;


#pragma mark CCRGBAProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * If this particle has individual color content, (which can be checked with the hasColor
 * property), this property indicates the color in which this particle will appear.
 *
 * If this particle has individual color content, you can set this property at any
 * time to define the color of the entire particle.
 *
 * Particles are configured for individual color content by including the kCC3VertexContentColor
 * component flag when setting the vertexContentTypes property of the emitter.
 *
 * Setting this property will set the color of all vertices in the particle to the assigned color.
 * 
 * Reading this property returns the color value of the first vertex in the particle. If this
 * particle does not support individual color content, this property will always return the value
 * of the diffuseColor property of the emitter. In this condition, it is safe to set this property,
 * but changes will have no effect.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * If this particle has individual color content, (which can be checked with the hasColor
 * property), this property indicates the opacity in which this particle will appear.
 *
 * If this particle has individual color content, you can set this property at any
 * time to define the opacity of the entire particle.
 *
 * Particles are configured for individual color content by including the kCC3VertexContentColor
 * component flag when setting the vertexContentTypes property of the emitter.
 *
 * Setting this property will set the opacity of all vertices in the particle to the assigned value.
 *
 * Reading this property returns the color value of the first vertex in the particle. If this
 * particle does not support individual color content, this property will always return the value
 * of the opacity of the diffuseColor property of the emitter. In this condition, it is safe to
 * set this property, but changes will have no effect.
 */
@property(nonatomic, assign) GLubyte opacity;


#pragma mark Allocation and initialization

/**
 * Initializes this instance.
 *
 * When initializing a particle, be aware that, in the interests of performance and memory
 * conservation, expired particles can and will be cached and reused, and particle emission
 * may not always involve instantiating a new instance of your particle class.
 *
 * With this in mind, you should not depend on the init method being invoked during particle
 * emission. All code that establishes the initial emitted state of a  particle should be
 * included in the initializeParticle method, or should be set in the initializeParticle:
 * method of the particle emitter or particle navigator.
 */
-(id) init;

/**
 * Allocates and initializes an autoreleased instance.
 *
 * When initializing a particle, be aware that, in the interests of performance and memory
 * conservation, expired particles can and will be cached and reused, and particle emission
 * may not always involve instantiating a new instance of your particle class.
 *
 * With this in mind, you should not depend on the init method being invoked during particle
 * emission. All code that establishes the initial emitted state of a  particle should be
 * included in the initializeParticle method, or should be set in the initializeParticle:
 * method of the particle emitter or particle navigator.
 */
+(id) particle;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or copyWithZone:
 * method. In most situations, the application should use the copy method, and should never
 * need to invoke this method directly.
 * 
 * Subclasses that add additional instance state (instance variables) should extend copying by
 * overriding this method to copy that additional state. Superclass that override this method should
 * be sure to invoke the superclass implementation to ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3ParticleBase*) another;

@end

