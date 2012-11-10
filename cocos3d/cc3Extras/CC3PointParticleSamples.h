/*
 * CC3PointParticleSamples.h
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
 */

/** @file */	// Doxygen marker

#import "CC3PointParticles.h"
#import "CC3ParticleSamples.h"


#pragma mark -
#pragma mark CC3MortalPointParticle

/**
 * CC3MortalPointParticle is a point particle implementation of the CC3MortalParticleProtocol
 * that has a finite life.
 *
 * To make evolutionary changes to this particle, implement the updateBeforeTransform: method.
 * In doing so, be sure to invoke the superclass implementation, which checks whether this
 * particle is still alive or has expired. Once the superclass implementation returns, you can
 * check the isAlive property before spending time making any further modifications.
 */
@interface  CC3MortalPointParticle  : CC3PointParticle <CC3MortalParticleProtocol> {
	ccTime lifeSpan;
	ccTime timeToLive;
}

/**
 * This template callback method is invoked automatically whenever the emitter is updated
 * during a scheduled 3D scene update.
 *
 * The CC3MortalPointParticle implementation checks to see if the whether this particle is
 * still alive or has expired, and sets the isAlive property accordingly.
 *
 * You can override this method to update the evolution of the particle. You should invoke this
 * superclass implementation and test the isAlive property before making any further modifications.
 *
 * Subclasses that override this method should invoke this superclass implementation first,
 * and should check the isAlive property prior to making any further modifications..
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;

/** @deprecated
 * Override the updateBeforeTransform: method, invoke the superclass implementation, and then
 * test the isAlive property of this particle before any further modifications.
 */
-(void) updateLife: (ccTime) dt DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3MortalPointParticleEmitter

/**
 * Deprecated.
 * @deprecated Do not use this class. This class has been introduced into the hierarchy
 * strictly to permit the library to maintain the deprecated CC3MortalPointParticleEmitter
 * as a parent class of other deprecated classes in this library.
 */
@interface CC3MortalPointParticleEmitterDeprecated : CC3PointParticleEmitter {}

/** @deprecated Replaced by minParticleLifeSpan property on the CC3RandomMortalParticleNavigator attached to this instance. */
@property(nonatomic, assign) ccTime minParticleLifeSpan;

/** @deprecated Replaced by maxParticleLifeSpan property on the CC3RandomMortalParticleNavigator attached to this instance. */
@property(nonatomic, assign) ccTime maxParticleLifeSpan;

/** @deprecated Life-span and trajectory now initialized by the CC3RandomMortalParticleNavigator attached to this instance. */
-(void) initializeMortalParticle: (CC3MortalPointParticle*) aParticle;

@end

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated This functionality has been separated into several more general classes. Use a
 * CC3PointParticleEmitter configured with a CC3RandomMortalParticleNavigator to emit particles
 * that support the CC3MortalParticleProtocol, such as particles of type CC3MortalPointParticle.
 */
@interface CC3MortalPointParticleEmitter : CC3MortalPointParticleEmitterDeprecated {}
@end


#pragma mark -
#pragma mark CC3SprayPointParticle

/**
 * CC3SprayPointParticle is a type of CC3MortalPointParticle that implements the
 * CC3SprayParticleProtocol to configure the particle to move in a straight line at a steady speed.
 */
@interface  CC3SprayPointParticle  : CC3MortalPointParticle <CC3SprayParticleProtocol> {
	CC3Vector velocity;
}

/**
 * This template callback method is invoked automatically whenever the emitter is updated
 * during a scheduled 3D scene update.
 *
 * The direction and speed are specified by the velocity property. To produce uniform motion,
 * this method multiplies this velocity by the interval since the previous update, and the
 * resulting distance vector is added to the location of this particle
 *
 * Subclasses that override this method should invoke this superclass implementation first,
 * and should check the isAlive property prior to making any further modifications..
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;

@end

DEPRECATED_ATTRIBUTE
/**
 * Deprecated and renamed to CC3SprayPointParticle.
 * @deprecated Renamed to CC3SprayPointParticle to clarify its type.
 */
@interface CC3UniformMotionParticle : CC3SprayPointParticle
@end


#pragma mark -
#pragma mark CC3UniformlyGrowingPointParticleProtocol

/**
 * CC3UniformlyGrowingPointParticleProtocol defines behaviour required for point particles
 * whose size grows or shrinks at a steady rate.
 *
 * Size can only be applied to individual particles if the emitter has been configured to
 * contain vertex point size content (kCC3VertexContentPointSize).
 *
 * This protocol can be used with point particles. Mesh particle do not have a point size.
 */
@protocol CC3UniformlyGrowingPointParticleProtocol <CC3PointParticleProtocol>

/** Indicates the current size of this point particle.  */
@property(nonatomic, assign) GLfloat size;

/**
 * Indicates the rate at which this particle changes size.
 *
 * If this particle has size content, the updateBeforeTransform: method multiplies this velocity
 * by the interval since the previous update, and adds the result to the size of this particle.
 */
@property(nonatomic, assign) GLfloat sizeVelocity;

@end


#pragma mark -
#pragma mark CC3UniformlyEvolvingPointParticle

/**
 * CC3UniformlyEvolvingPointParticle is a type of CC3SprayPointParticle that implements the
 * CC3UniformlyGrowingPointParticleProtocol and CC3UniformlyFadingParticleProtocol protocols
 * to configure steadily changing color and size that vary linearly from an intitial color
 * and size to a final color and size.
 *
 * The rate of change of the particle's color and size are specified by the colorVelocity 
 * and sizeVelocity properties respectively.
 *
 * To produce uniform evolution, the updateBeforeTransform: method multiplies each of these
 * velocities by the interval since the previous update, and adds each result, accordingly,
 * to the color and size properties of this particle. Color and size are only updated if the
 * underlying mesh supports that content.
 */
@interface  CC3UniformlyEvolvingPointParticle : CC3SprayPointParticle
												<CC3UniformlyGrowingPointParticleProtocol,
												CC3UniformlyFadingParticleProtocol> {
	GLfloat sizeVelocity;
	ccColor4F colorVelocity;
}

/**
 * This template callback method is invoked automatically whenever the emitter is updated
 * during a scheduled 3D scene update.
 *
 * The direction and speed are specified by the velocity property. The rate of change of the
 * particle's color and size are specified by the colorVelocity and sizeVelocity properties respectively.
 *
 * To produce uniform evolution, this method multiplies each of these three velocities by the interval
 * since the previous update, and adds each result, accordingly, to the location, color and size
 * properties of this particle. Color and size are only updated if this particle supports that content.
 *
 * Subclasses that override this method should invoke this superclass implementation first,
 * and should check the isAlive property prior to making any further modifications..
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;

@end

DEPRECATED_ATTRIBUTE
/** 
 * Deprecated and renamed to CC3UniformlyEvolvingPointParticle.
 * @deprecated Renamed to CC3UniformlyEvolvingPointParticle to clarify its type.
 */
@interface CC3UniformEvolutionParticle : CC3UniformlyEvolvingPointParticle
@end


#pragma mark -
#pragma mark CC3VariegatedPointParticleProtocol

/**
 * CC3VariegatedPointParticleProtocol is used by the CC3VariegatedPointParticleHoseEmitter,
 * and combines the CC3UniformlyGrowingPointParticleProtocol and CC3UniformlyFadingParticleProtocol
 * protocols, and is a particle that steadily changes size and color. It also includes the
 * CC3MortalParticleProtocol to permit the emitter to extract the lifespan of the particle
 * in order to calculate the rates at which to evolve the size and color of the particle.
 *
 * This protocol can be used with point particles. Mesh particle do not have a point size.
 */
@protocol CC3VariegatedPointParticleProtocol <CC3UniformlyGrowingPointParticleProtocol,
											  CC3UniformlyFadingParticleProtocol,
											  CC3MortalParticleProtocol>
@end


#pragma mark -
#pragma mark CC3VariegatedPointParticleHoseEmitter

/**
 * CC3VariegatedPointParticle is the type of particle emitted by a CC3VariegatedPointParticleHoseEmitter.
 * It supports the CC3VariegatedPointParticleProtocol and allows the emitter to configure the
 * particle with a steadily changing color and size, based on the lifespan of the particle.
 */
@interface CC3VariegatedPointParticle : CC3UniformlyEvolvingPointParticle <CC3VariegatedPointParticleProtocol> {}
@end


#pragma mark -
#pragma mark CC3VariegatedPointParticleHoseEmitter

/**
 * When used as an ending size or component of an ending color for a
 * CC3VariegatedPointParticleHoseEmitter, indicates that that component
 * should stay constant at the value at which it started.
 */
#define kCC3ParticleConstantComponent	-1.0

/**
 * When used as the ending size for a CC3VariegatedPointParticleHoseEmitter,
 * indicates that the size should stay constant at the starting size.
 */
static const GLfloat kCC3ParticleConstantSize = kCC3ParticleConstantComponent;

/**
 * When used as the ending color for a CC3VariegatedPointParticleHoseEmitter,
 * indicates that the color should stay constant at the starting color.
 */
static const ccColor4F kCC3ParticleConstantColor = { kCC3ParticleConstantComponent,
													 kCC3ParticleConstantComponent,
													 kCC3ParticleConstantComponent,
													 kCC3ParticleConstantComponent };

/**
 * When used as the ending color for a CC3VariegatedPointParticleHoseEmitter, indicates
 * that the starting color should simply fade out, rather than change to an ending color.
 */
static const ccColor4F kCC3ParticleFadeOut = { kCC3ParticleConstantComponent,
											   kCC3ParticleConstantComponent,
											   kCC3ParticleConstantComponent,
											   0.0f };

/**
 * CC3VariegatedPointParticleHoseEmitter is a type of CC3PointParticleEmitter whose particles
 * can have a color and size that evolves during the lifetime of the particle.
 *
 * CC3VariegatedPointParticleHoseEmitter configures particles of that support the
 * CC3VariegatedPointParticleProtocol, and can set an individual initial and final color
 * and size for each particle, each selected randomly from a range of values.
 */
@interface CC3VariegatedPointParticleHoseEmitter : CC3PointParticleEmitter {
	GLfloat minParticleStartingSize;
	GLfloat maxParticleStartingSize;
	GLfloat minParticleEndingSize;
	GLfloat maxParticleEndingSize;
	ccColor4F minParticleStartingColor;
	ccColor4F maxParticleStartingColor;
	ccColor4F minParticleEndingColor;
	ccColor4F maxParticleEndingColor;
}

/**
 * Indicates the lower bound of the range from which the initial size of the particle will be chosen.
 *
 * Whenever a particle is emitted, its starting size is determined by choosing a random value between
 * the values specified by the minParticleStartingSize and maxParticleStartingSize properties.
 */
@property(nonatomic, assign) GLfloat minParticleStartingSize;

/**
 * Indicates the upper bound of the range from which the initial size of the particle will be chosen.
 *
 * Whenever a particle is emitted, its starting size is determined by choosing a random value between
 * the values specified by the minParticleStartingSize and maxParticleStartingSize properties.
 */
@property(nonatomic, assign) GLfloat maxParticleStartingSize;

/**
 * Indicates the lower bound of the range from which the final size of the particle will be chosen.
 *
 * Whenever a particle is emitted, its final size is determined by choosing a random value between
 * the values specified by the minParticleEndingSize and maxParticleEndingSize properties. This is
 * used to determine the rate at which the size will change while the particle is alive, and the
 * result is set into the sizeVelocity property of the particle.
 *
 * In addition to a specific size value, you can use the special value kCC3ParticleConstantSize to
 * indicate that the final size of the particle should be the same as the starting size. Using this
 * value for either minParticleEndingSize or maxParticleEndingSize will allow the starting size to
 * be set randomly and to stay constant throughout the life of the particle.
 */
@property(nonatomic, assign) GLfloat minParticleEndingSize;

/**
 * Indicates the upper bound of the range from which the final size of the particle will be chosen.
 *
 * Whenever a particle is emitted, its final size is determined by choosing a random value between
 * the values specified by the minParticleEndingSize and maxParticleEndingSize properties. This is
 * used to determine the rate at which the size will change while the particle is alive, and the
 * result is set into the sizeVelocity property of the particle.
 *
 * In addition to a specific size value, you can use the special value kCC3ParticleConstantSize to
 * indicate that the final size of the particle should be the same as the starting size. Using this
 * value for either minParticleEndingSize or maxParticleEndingSize will allow the starting size to
 * be set randomly and to stay constant throughout the life of the particle.
 */
@property(nonatomic, assign) GLfloat maxParticleEndingSize;

/**
 * Indicates the lower bound of the range from which the initial color of the particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a random value between
 * the values specified by the minParticleStartingColor and maxParticleStartingColor properties. The
 * color is randomized by choosing a random value for each component from the numerical range defined
 * by the value of that component in the minParticleStartingColor and maxParticleStartingColor properties.
 */
@property(nonatomic, assign) ccColor4F minParticleStartingColor;

/**
 * Indicates the upper bound of the range from which the initial color of the particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a random value between
 * the values specified by the minParticleStartingColor and maxParticleStartingColor properties. The
 * color is randomized by choosing a random value for each component from the numerical range defined
 * by the value of that component in the minParticleStartingColor and maxParticleStartingColor properties.
 */
@property(nonatomic, assign) ccColor4F maxParticleStartingColor;

/**
 * Indicates the lower bound of the range from which the final color of the particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a random value between
 * the values specified by the minParticleStartingColor and maxParticleStartingColor properties. The
 * color is randomized by choosing a random value for each component from the numerical range defined
 * by the value of that component in the minParticleStartingColor and maxParticleStartingColor properties.
 *
 * This final color is used to determine the rate at which the color will change while the particle
 * is alive, and the result is set into the colorVelocity property of the particle.
 *
 * In addition to a specific final color value, you can use the special values:
 *   - kCC3ParticleConstantColor
 *   - kCC3ParticleFadeOut
 * to indicate, respectively, that the final color of the particle should be the same as the starting
 * color, or that the final color should be the same as the starting color, except that it should fade
 * away during the lifetime of the particle.
 *
 * In a more general sense, setting any of the component values of either the minParticleEndingColor
 * or maxParticleEndingColor properties to kCC3ParticleConstantComponent will cause the value of that
 * component to stay constant throughout the lifetime of the particle.
 */
@property(nonatomic, assign) ccColor4F minParticleEndingColor;


/**
 * Indicates the upper bound of the range from which the final color of the particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a random value between
 * the values specified by the minParticleStartingColor and maxParticleStartingColor properties. The
 * color is randomized by choosing a random value for each component from the numerical range defined
 * by the value of that component in the minParticleStartingColor and maxParticleStartingColor properties.
 *
 * This final color is used to determine the rate at which the color will change while the particle
 * is alive, and the result is set into the colorVelocity property of the particle.
 *
 * In addition to a specific final color value, you can use the special values:
 *   - kCC3ParticleConstantColor
 *   - kCC3ParticleFadeOut
 * to indicate, respectively, that the final color of the particle should be the same as the starting
 * color, or that the final color should be the same as the starting color, except that it should fade
 * away during the lifetime of the particle.
 *
 * In a more general sense, setting any of the component values of either the minParticleEndingColor
 * or maxParticleEndingColor properties to kCC3ParticleConstantComponent will cause the value of that
 * component to stay constant throughout the lifetime of the particle.
 */
@property(nonatomic, assign) ccColor4F maxParticleEndingColor;

@end


#pragma mark -
#pragma mark CC3PointParticleHoseEmitter

/**
 * Deprecated.
 * @deprecated Do not use this class. This class has been introduced into the hierarchy
 * strictly to permit the library to maintain the deprecated CC3PointParticleHoseEmitter
 * as a parent class of other deprecated classes in this library.
 */
@interface CC3PointParticleHoseEmitterDeprecated : CC3MortalPointParticleEmitterDeprecated {}

/** @deprecated This property is now on the contained CC3HoseParticleNavigator. */
@property(nonatomic, retain) CC3Node* nozzle;

/** @deprecated This property is now on the contained CC3HoseParticleNavigator. */
@property(nonatomic, readonly) CC3Matrix* nozzleMatrix;

/** @deprecated This property is now on the contained CC3HoseParticleNavigator. */
@property(nonatomic, assign) CGSize dispersionAngle;

/** @deprecated This property is now on the contained CC3HoseParticleNavigator. */
@property(nonatomic, assign) BOOL shouldPrecalculateNozzleTangents;

/** @deprecated This property is now on the contained CC3HoseParticleNavigator. */
@property(nonatomic, assign) GLfloat minParticleSpeed;

/** @deprecated This property is now on the contained CC3HoseParticleNavigator. */
@property(nonatomic, assign) GLfloat maxParticleSpeed;

@end

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated This functionality has been separated into several more general classes.
 * Use a CC3PointParticleEmitter configured with a CC3HoseParticleNavigator to emit
 * particles that support the CC3UniformlyMovingParticleProtocol, such as particles of
 * type CC3SprayPointParticle.
 */
@interface CC3PointParticleHoseEmitter : CC3PointParticleHoseEmitterDeprecated {}
@end



