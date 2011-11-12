/*
 * CC3PointParticleSamples.h
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

#import "CC3PointParticles.h"


#pragma mark -
#pragma mark CC3PointParticleHoseEmitter

/**
 * CC3PointParticleHoseEmitter emits CC3UniformMotionParticle particles in a
 * stream, as if from the nozzle of a hose.
 *
 * A CC3PointParticleHoseEmitter instance is made up of two parts: the emitter
 * and the nozzle, each of which is a node.
 * 
 * Particles live within the context of the emitter node, and movement of the
 * emitter node affects all of the particles already emitted by that node.
 * For example, if the emitter is rotating, the particles will rotate along
 * with it as they live out their lives.
 *
 * The location and rotation of the nozzle node determine where the particles
 * will be emitted, and in what direction, respectively. Moving the nozzle
 * does not effect the movement of the particles that have already been emitted.
 * 
 * By default, the nozzle node is a child node of this emitter. However, you can
 * change the parent node of the nozzle to some other object, by invoking the
 * addChild: method on the other object, with the nozzle node as the argument.
 *
 * By assigning the nozzle to a different parent node, you can have the nozzle
 * track another node, and emit particles as that node travels. For example,
 * you might attach the nozzle to the tail of a rocket node, to emit a trail
 * of particles behind the rocket as the rocket moves.
 *
 * The parent of the nozzle (the rocket, for example) does not need to be a
 * child or descendant of the emitter. Like any node, the location and rotation
 * properties of the nozzle are specified relative to its parent (the rocket).
 *
 * Note the difference in behaviour of the particles by having the nozzle
 * move instead of the emitter. In the rocket example, if the emitter was
 * attached to the tail of the rocket, the emitted particles would move
 * along with the emitter, making it very difficult to calculate realistic
 * paths for the particles. By making the emitter stationary, and attaching
 * only the nozzle to the rocket, the point of emission moves with the rocket,
 * but the particles move and live out their lives in fixed space, and it
 * becomes much simpler to calculate their movement.
 *
 * You can even combine the two frames of reference for interesting effects.
 * You can put both the emitter and the nozzle in separate motion. For example,
 * to create clouds moving on a rotating globe, you could place the emitter at
 * the center of the globe, so that it and the cloud particles rotate around
 * with the globe, and have the nozzle also moving across the surface of the
 * globe to simulate the clouds travelling across the surface of the globe.
 * 
 * For such a complicated scenario to work, keep in mind that the emitter and
 * the parent of the nozzle should share a common ancestor node (in this example,
 * the globe), to make it easy for the particles to transition from the nozzle
 * frame of reference to that of the emitter.
 *
 * You can set the shape of the nozzle using the dispersionAngle property,
 * which specifies how tight or wide the spray will be, and you can set a
 * range of speeds for the particles as they leave the emitter.
 *
 * CC3PointParticleHoseEmitter inherits from CC3MortalPointParticleEmitter,
 * which allows you to set a range of finite lifespans for the particles.
 */
@interface CC3PointParticleHoseEmitter : CC3MortalPointParticleEmitter {
	CC3Node* nozzle;
	CC3GLMatrix* nozzleMatrix;
	CGSize nozzleShape;
	GLfloat minParticleSpeed;
	GLfloat maxParticleSpeed;
	BOOL shouldPrecalculateNozzleTangents;
}

/**
 * The nozzle of the emitter.
 *
 * The location and rotation of the nozzle node determine where the particles
 * will be emitted, and in what direction, respectively. Moving the nozzle
 * does not effect the movement of the particles that have already been emitted.
 * 
 * By default, the nozzle node is a child node of this emitter. However, you can
 * change the parent node of the nozzle to some other object, by invoking the
 * addChild: method on the other object, with the nozzle node as the argument.
 *
 * By assigning the nozzle to a different parent node, you can have the nozzle
 * track another node, and emit particles as that node travels. For example,
 * you might attach the nozzle to the tail of a rocket node, to emit a trail
 * of particles behind the rocket as the rocket moves.
 *
 * The parent of the nozzle does not need to be a child or descendant of the
 * emitter. Like any node, the location and rotation properties of the nozzle
 * are specified relative to its parent (the rocket).
 */
@property(nonatomic, retain) CC3Node* nozzle;

/**
 * The matrix used to transform the initial location and velocity (combining
 * direction and speed) of each particle from the local coordinates of the
 * nozzle to the local coordinates of the emitter.
 *
 * If the nozzle has been assigned a different parent than the emitter, this
 * matrix is recalculated during each update by combining the transformMatrix
 * of the nozzle and the transformMatrixInverted of the emitter.
 */
@property(nonatomic, readonly) CC3GLMatrix* nozzleMatrix;

/**
 * Indicates the angle of dispersion of the spray from the nozzle. This is specified
 * as both a width and height, permitting flexible shapes for the nozzle.
 *
 * During the emission of each particle, a random emission direction is chosen within
 * the angles specified by this property.
 *
 * The values are specified in degrees between zero and 180. The lower the angle,
 * the tighter the stream.
 *
 * A different value can be specified for each of the width and height of the
 * nozzle opening. Setting both width and height to small angles will create
 * a tightly focused beam of particles. Setting both width and height to larger
 * angles will result in particles emitted in a wide spray. Setting one or other
 * of the width or height to a small angle and the other to a large angle will
 * create a fan effect, where the particles are tightly constrained in one dimension,
 * but spray widely in the other.
 * 
 * For small dispersion angles, (> 90 degrees), you can avoid two expensive tangent
 * calculations every time a particle is emitted by setting the
 * shouldPrecalculateNozzleTangents to YES. This has the effect of precalculating the
 * tangent of the dispersionAngle, and then randomizing on the value of that tangent
 * instead of randomizing the value of the angle. For small angles, the effect is
 * effectively the same. But for larger angles (approaching 180), randomizing the
 * tangents has a very different effect than randomizing the emission angle, you you
 ( will find that the emission tends to cluster around the edges for large dispersion
 * angles if the shouldPrecalculateNozzleTangents property is set to YES.
 */
@property(nonatomic, assign) CGSize dispersionAngle;

/**
 * Indicates whether the emitter should precalculate tangent values for the dispersion
 * angles, and then select a value from that range of tangents in order to detemrine
 * a random direction for a particle.
 *
 * During the emission of each particle, a random emission direction is chosen within
 * the angles specified by the dispersionAngle property. In order to convert the angles
 * to direction, a tangent calculation must be made for each of the two random angles.
 *
 * For small dispersion angles (typically > 90 degrees), calculating the tangent once
 * for each of the width and height of the dispersionAngle property, and then selecting
 * a random value from the range of tangents provides equivalent randomization to selecting
 * a random angle and then calculating its tangent. But in the first case, a tangent is
 * only calculated once, for the dispersion angle itself, instead of each time a random
 * angle is chosen.
 *
 * However, as the dispersion angle increases (approaching 180 degrees), the equivalent
 * tangent grows exponentially, and the tangent range become ever larger, ending at
 * infinity at 180 degrees. Therefore, as the dispersion angle increases, selecting a
 * random value from the tangent range results in most angles clustering around the limit,
 * resulting in very poor randomization.
 *
 * If this property is set to NO, whenever a particle is emitted, a random angle will
 * be chosen within the range defined by the dispersionAngle property, for each of the
 * width and height. Tangents are then calculated, and the particle direction set.
 *
 * If this property is set to YES, the dispersionAngle property will be converted into
 * tangents, and whenever a particle is emitted, a random tangent value will be chosen
 * within the range of tangents, and the particle direction will be set from that,
 * without having to calculate a tangent from an angle for each particle.
 *
 * The initial value of this property is NO, indicating that two random angles will be
 * chosen for each emitted particle, from which tangents will calculated trigonometrically,
 * and the particle direction will be determined from that. If you are using small
 * dispersion angles (less than 90 degrees), to improve performance, you can set this
 * property to YES to avoid additional trigonometric tangent calculations.
 */
@property(nonatomic, assign) BOOL shouldPrecalculateNozzleTangents;

/**
 * Indicates the lower bound of the range from which the speed of the particle will be chosen.
 *
 * Whenever a particle is emitted, its speed is determined by choosing a random value
 * between the values specified by the minParticleSpeed and maxParticleSpeed properties.
 * This speed value is then combined with the randomized initial direction to form the
 * initial velocity of the particle.
 */
@property(nonatomic, assign) GLfloat minParticleSpeed;

/**
 * Indicates the upper bound of the range from which the speed of the particle will be chosen.
 *
 * Whenever a particle is emitted, its speed is determined by choosing a random value
 * between the values specified by the minParticleSpeed and maxParticleSpeed properties.
 * This speed value is then combined with the randomized initial direction to form the
 * initial velocity of the particle.
 */
@property(nonatomic, assign) GLfloat maxParticleSpeed;

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
 * When used as the ending color for a CC3VariegatedPointParticleHoseEmitter,
 * indicates that the starting color should simply fade out, rather than
 * change to an ending color.
 */
static const ccColor4F kCC3ParticleFadeOut = { kCC3ParticleConstantComponent,
											   kCC3ParticleConstantComponent,
											   kCC3ParticleConstantComponent,
											   0.0f };

/**
 * CC3VariegatedPointParticleHoseEmitter is a type of CC3PointParticleHoseEmitter
 * whose particles can have a color and size that evolves during the lifetime of
 * the particle.
 *
 * CC3VariegatedPointParticleHoseEmitter emit particles of type CC3UniformEvolutionParticle,
 * and can set an individual initial and final color and size for each particle, each
 * selected randomly from a range of values.
 *
 * Although each particle is capable of having individual color and size values, you
 * can configure whether either or both of these will be used when configuring this
 * emitter using one of the populateForMaxParticles:... methods. For example, you may
 * want particles with individual color, but not individual size.
 */
@interface CC3VariegatedPointParticleHoseEmitter : CC3PointParticleHoseEmitter {
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
 * Indicates the lower bound of the range from which the initial size of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its starting size is determined by choosing
 * a random value between the values specified by the minParticleStartingSize
 * and maxParticleStartingSize properties.
 */
@property(nonatomic, assign) GLfloat minParticleStartingSize;

/**
 * Indicates the upper bound of the range from which the initial size of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its starting size is determined by choosing
 * a random value between the values specified by the minParticleStartingSize
 * and maxParticleStartingSize properties.
 */
@property(nonatomic, assign) GLfloat maxParticleStartingSize;

/**
 * Indicates the lower bound of the range from which the final size of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its final size is determined by choosing
 * a random value between the values specified by the minParticleEndingSize
 * and maxParticleEndingSize properties. This is used to determine the rate
 * at which the size will change while the particle is alive, and the result
 * is set into the sizeVelocity property of the particle.
 *
 * In addition to a specific size value, you can use the special value
 * kCC3ParticleConstantSize to indicate that the final size of the particle
 * should be the same as the starting size. Using this value for either
 * minParticleEndingSize or maxParticleEndingSize will allow the starting size
 * to be set randomly and to stay constant throughout the life of the particle.
 */
@property(nonatomic, assign) GLfloat minParticleEndingSize;

/**
 * Indicates the upper bound of the range from which the final size of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its final size is determined by choosing
 * a random value between the values specified by the minParticleEndingSize
 * and maxParticleEndingSize properties. This is used to determine the rate
 * at which the size will change while the particle is alive, and the result
 * is set into the sizeVelocity property of the particle.
 *
 * In addition to a specific size value, you can use the special value
 * kCC3ParticleConstantSize to indicate that the final size of the particle
 * should be the same as the starting size. Using this value for either
 * minParticleEndingSize or maxParticleEndingSize will allow the starting size
 * to be set randomly and to stay constant throughout the life of the particle.
 */
@property(nonatomic, assign) GLfloat maxParticleEndingSize;

/**
 * Indicates the lower bound of the range from which the initial color of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a
 * random value between the values specified by the minParticleStartingColor and
 * maxParticleStartingColor properties. The color is randomized by choosing a random
 * value for each component from the numerical range defined by the value of that
 * component in the minParticleStartingColor and maxParticleStartingColor properties.
 */
@property(nonatomic, assign) ccColor4F minParticleStartingColor;

/**
 * Indicates the upper bound of the range from which the initial color of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a
 * random value between the values specified by the minParticleStartingColor and
 * maxParticleStartingColor properties. The color is randomized by choosing a random
 * value for each component from the numerical range defined by the value of that
 * component in the minParticleStartingColor and maxParticleStartingColor properties.
 */
@property(nonatomic, assign) ccColor4F maxParticleStartingColor;

/**
 * Indicates the lower bound of the range from which the final color of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a
 * random value between the values specified by the minParticleStartingColor and
 * maxParticleStartingColor properties. The color is randomized by choosing a random
 * value for each component from the numerical range defined by the value of that
 * component in the minParticleStartingColor and maxParticleStartingColor properties.
 *
 * This final color is used to determine the rate at which the color will change
 * while the particle is alive, and the result is set into the colorVelocity
 * property of the particle.
 *
 * In addition to a specific final color value, you can use the special values:
 *   - kCC3ParticleConstantColor
 *   - kCC3ParticleFadeOut
 * to indicate, respectively, that the final color of the particle should be the same
 * as the starting color, or that the final color should be the same as the starting
 * color, except that it should fade away during the lifetime of the particle.
 *
 * In a more general sense, setting any of the component values of either
 * the minParticleEndingColor or maxParticleEndingColor properties to
 * kCC3ParticleConstantComponent will cause the value of that component
 * to stay constant throughout the lifetime of the particle.
 */
@property(nonatomic, assign) ccColor4F minParticleEndingColor;


/**
 * Indicates the upper bound of the range from which the final color of the
 * particle will be chosen.
 *
 * Whenever a particle is emitted, its starting color is determined by choosing a
 * random value between the values specified by the minParticleStartingColor and
 * maxParticleStartingColor properties. The color is randomized by choosing a random
 * value for each component from the numerical range defined by the value of that
 * component in the minParticleStartingColor and maxParticleStartingColor properties.
 *
 * This final color is used to determine the rate at which the color will change
 * while the particle is alive, and the result is set into the colorVelocity
 * property of the particle.
 *
 * In addition to a specific final color value, you can use the special values:
 *   - kCC3ParticleConstantColor
 *   - kCC3ParticleFadeOut
 * to indicate, respectively, that the final color of the particle should be the same
 * as the starting color, or that the final color should be the same as the starting
 * color, except that it should fade away during the lifetime of the particle.
 *
 * In a more general sense, setting any of the component values of either
 * the minParticleEndingColor or maxParticleEndingColor properties to
 * kCC3ParticleConstantComponent will cause the value of that component
 * to stay constant throughout the lifetime of the particle.
 */
@property(nonatomic, assign) ccColor4F maxParticleEndingColor;

@end



