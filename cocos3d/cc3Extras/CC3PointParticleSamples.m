/*
 * CC3PointParticleSamples.m
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
 * See header file CC3PointParticleSamples.h for full API documentation.
 */

#import "CC3PointParticleSamples.h"


/** Re-declaration of deprecated methods to suppress compiler warnings within this class. */
@protocol CC3MortalPointParticleDeprecated
-(void) updateLife: (CCTime) dt;
@end


#pragma mark -
#pragma mark CC3MortalPointParticle

@implementation CC3MortalPointParticle

@synthesize lifeSpan=_lifeSpan, timeToLive=_timeToLive;

-(void) setLifeSpan: (CCTime) anInterval {
	_lifeSpan = anInterval;
	_timeToLive = _lifeSpan;
}

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	CCTime dt = visitor.deltaTime;
	_timeToLive -= dt;
	if (_timeToLive <= 0.0)
		self.isAlive = NO;
	else
		[((id<CC3MortalPointParticleDeprecated>)self) updateLife: dt];
}

-(void) populateFrom: (CC3MortalPointParticle*) another {
	[super populateFrom: another];
	
	_lifeSpan = another.lifeSpan;
	_timeToLive = another.timeToLive;
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tlifeSpan: %.3f, timeToLive: %.3f",
			[super fullDescription], _lifeSpan, _timeToLive];
}

// Deprecated
-(void) updateLife: (CCTime) dt {}

@end


#pragma mark -
#pragma mark CC3MortalPointParticleEmitter

/**
 * Class added as a substitute for CC3MortalPointParticleEmitter, so that classes in this library
 * that previously subclassed from CC3MortalPointParticleEmitter will retain functionality without
 * having to declare they are subclassing from a deprecated class.
 */ 
@implementation CC3MortalPointParticleEmitterDeprecated

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.particleNavigator = [CC3RandomMortalParticleNavigator navigator];
		self.particleClass = [CC3MortalPointParticle class];
	}
	return self;
}

-(CC3RandomMortalParticleNavigator*) mortalParticleNavigator { return (CC3RandomMortalParticleNavigator*)_particleNavigator; }

-(CCTime) minParticleLifeSpan { return self.mortalParticleNavigator.minParticleLifeSpan; }

-(void) setMinParticleLifeSpan: (CCTime) minLifeSpan {
	self.mortalParticleNavigator.minParticleLifeSpan = minLifeSpan;
}

-(CCTime) maxParticleLifeSpan { return self.mortalParticleNavigator.maxParticleLifeSpan; }

-(void) setMaxParticleLifeSpan: (CCTime) maxLifeSpan {
	self.mortalParticleNavigator.maxParticleLifeSpan = maxLifeSpan;
}

-(void) initializeParticle: (CC3MortalPointParticle*) aParticle {
	[self initializeMortalParticle: aParticle];
}

-(void) initializeMortalParticle: (CC3MortalPointParticle*) aParticle {}

@end

@implementation CC3MortalPointParticleEmitter
@end


#pragma mark -
#pragma mark CC3SprayPointParticle

@implementation CC3SprayPointParticle

@synthesize velocity=_velocity;

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super updateBeforeTransform: visitor];
	if( !self.isAlive ) return;

	self.location = CC3VectorAdd(self.location, CC3VectorScaleUniform(self.velocity, visitor.deltaTime));
}

-(id) init {
	if ( (self = [super init]) ) {
		_velocity = kCC3VectorZero;
	}
	return self;
}

-(void) populateFrom: (CC3SprayPointParticle*) another {
	[super populateFrom: another];
	_velocity = another.velocity;
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tvelocity: %@",
			[super fullDescription], NSStringFromCC3Vector(_velocity)];
}

@end

// Deprecated class
@implementation CC3UniformMotionParticle
@end


#pragma mark -
#pragma mark CC3UniformlyEvolvingPointParticle

@implementation CC3UniformlyEvolvingPointParticle

@synthesize colorVelocity=_colorVelocity, sizeVelocity=_sizeVelocity;

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super updateBeforeTransform: visitor];
	if( !self.isAlive ) return;
	
	CCTime dt = visitor.deltaTime;
	
	if (self.hasSize) self.size = self.size + (_sizeVelocity * dt);
	
	if (self.hasColor) {
		// We have to do the math on each component instead of using the color math functions
		// because the functions clamp prematurely, and we need negative values for the velocity.
		ccColor4F currColor = self.color4F;
		self.color4F = ccc4f(CLAMP(currColor.r + (_colorVelocity.r * dt), 0.0f, 1.0f),
							 CLAMP(currColor.g + (_colorVelocity.g * dt), 0.0f, 1.0f),
							 CLAMP(currColor.b + (_colorVelocity.b * dt), 0.0f, 1.0f),
							 CLAMP(currColor.a + (_colorVelocity.a * dt), 0.0f, 1.0f));
	}
}

-(void) populateFrom: (CC3UniformlyEvolvingPointParticle*) another {
	[super populateFrom: another];
	
	_sizeVelocity = another.sizeVelocity;
	_colorVelocity = another.colorVelocity;
}

@end

// Deprecated class
@implementation CC3UniformEvolutionParticle
@end


#pragma mark -
#pragma mark CC3VariegatedPointParticle

@implementation CC3VariegatedPointParticle

/**
 * Adjusts the velocity of the color and point size by dividing by the life span.
 *
 * This is done here, because the color and size velocity is determined by the
 * CC3VariegatedPointParticleHoseEmitter that created the particle, but the lifeSpan is
 * not available until the navigator sets it. Since the emitter initializes the particle 
 * first, then the navigator, and then the particle itself, we can get the particle to
 * adjust the velocity now that the lifeSpan is known.
 *
 * An alternative to this process could be to have the navigator determine the color and
 * size velocities. It is done this way here to highlight the interaction between the
 * three levels of initialization. This also allows the navigator to focus on the particle's
 * path, and the emitter to focus on the visuals, and lets the particle itself stitch it
 * all together as needed for any particular application.
 */
-(void) initializeParticle {
	[super initializeParticle];

	ccColor4F colVel = self.colorVelocity;
	self.colorVelocity = ccc4f(colVel.r / _lifeSpan,
							   colVel.g / _lifeSpan,
							   colVel.b / _lifeSpan,
							   colVel.a / _lifeSpan);
	
	self.sizeVelocity /= _lifeSpan;
}

@end


#pragma mark -
#pragma mark CC3VariegatedPointParticleHoseEmitter

@implementation CC3VariegatedPointParticleHoseEmitter

@synthesize minParticleStartingSize=_minParticleStartingSize, maxParticleStartingSize=_maxParticleStartingSize;
@synthesize minParticleEndingSize=_minParticleEndingSize, maxParticleEndingSize=_maxParticleEndingSize;
@synthesize minParticleStartingColor=_minParticleStartingColor, maxParticleStartingColor=_maxParticleStartingColor;
@synthesize minParticleEndingColor=_minParticleEndingColor, maxParticleEndingColor=_maxParticleEndingColor;


#pragma mark Allocation and initialization


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.particleNavigator = [CC3HoseParticleNavigator navigator];
		self.particleClass = [CC3VariegatedPointParticle class];
		_minParticleStartingSize = kCC3DefaultParticleSize;
		_maxParticleStartingSize = kCC3DefaultParticleSize;
		_minParticleEndingSize = kCC3DefaultParticleSize;
		_maxParticleEndingSize = kCC3DefaultParticleSize;
		_minParticleStartingColor = kCCC4FWhite;
		_maxParticleStartingColor = kCCC4FWhite;
		_minParticleEndingColor = kCCC4FWhite;
		_maxParticleEndingColor = kCCC4FWhite;
	}
	return self;
}

-(Protocol*) requiredParticleProtocol { return @protocol(CC3VariegatedPointParticleProtocol); }

-(void) populateFrom: (CC3VariegatedPointParticleHoseEmitter*) another {
	[super populateFrom: another];
	
	_minParticleStartingSize = another.minParticleStartingSize;
	_maxParticleStartingSize = another.maxParticleStartingSize;
	_minParticleEndingSize = another.minParticleEndingSize;
	_maxParticleEndingSize = another.maxParticleEndingSize;
	_minParticleStartingColor = another.minParticleStartingColor;
	_maxParticleStartingColor = another.maxParticleStartingColor;
	_minParticleEndingColor = another.minParticleEndingColor;
	_maxParticleEndingColor = another.maxParticleEndingColor;
}


#pragma mark Updating

/** Returns a random number between min and max, or returns alt if either min or max is negative. */
#define CC3RandomOrAlt(min, max, alt) (((min) >= 0.0f && (max) >= 0.0f) ? CC3RandomFloatBetween((min), (max)) : (alt))

-(void) initializeParticle: (id<CC3VariegatedPointParticleProtocol>) aParticle {
	[super initializeParticle: aParticle];
	
	// Set the particle's initial color and color velocity, which is calculated by taking the
	// difference of the start and end colors. This assumes that the color changes over one second.
	// The particle itself will figure out how the overall change should be adjusted for its lifespan.
	if (self.mesh.hasVertexColors) {
		ccColor4F startColor = RandomCCC4FBetween(_minParticleStartingColor, _maxParticleStartingColor);
		aParticle.color4F = startColor;
		
		// End color is treated differently. If any component of either min or max is negative,
		// it indicates that the corresponding component of the start color should be used,
		// otherwise a random value between min and max is chosen.
		// This allows random colors to be chosen, but to have them stay constant.
		// For exmaple, setting all color components to -1 and alpha to zero, indicates that
		// the particle should stay the same color, but fade away.
		ccColor4F endColor;
		endColor.r = CC3RandomOrAlt(_minParticleEndingColor.r, _maxParticleEndingColor.r, startColor.r);
		endColor.g = CC3RandomOrAlt(_minParticleEndingColor.g, _maxParticleEndingColor.g, startColor.g);
		endColor.b = CC3RandomOrAlt(_minParticleEndingColor.b, _maxParticleEndingColor.b, startColor.b);
		endColor.a = CC3RandomOrAlt(_minParticleEndingColor.a, _maxParticleEndingColor.a, startColor.a);
		
		// We have to do the math on each component instead of using the color math functions
		// because the functions clamp prematurely, and we need negative values for the velocity.
		aParticle.colorVelocity = ccc4f((endColor.r - startColor.r),
										(endColor.g - startColor.g),
										(endColor.b - startColor.b),
										(endColor.a - startColor.a));
	}
	
	// Set the particle's initial size and size velocity, which is calculated by taking the
	// difference of the start and end sizes. This assumes that the color changes over one second.
	// The particle itself will figure out how the overall change should be adjusted for its lifespan.
	if(self.mesh.hasVertexPointSizes) {
		GLfloat startSize = CC3RandomFloatBetween(_minParticleStartingSize, _maxParticleStartingSize);
		aParticle.size = startSize;
		
		// End size is treated differently. If either min or max is negative, it indicates that
		// the start size should be used, otherwise a random value between min and max is chosen.
		// This allows a random size to be chosen, but to have it stay constant.
		GLfloat endSize = CC3RandomOrAlt(_minParticleEndingSize, _maxParticleEndingSize, startSize);
		
		aParticle.sizeVelocity = (endSize - startSize);
	}
}

@end


#pragma mark -
#pragma mark CC3PointParticleHoseEmitter

/**
 * Class added as a substitute for CC3PointParticleHoseEmitter, so that classes in this library that
 * previously subclassed from CC3PointParticleHoseEmitter will retain functionality without having
 * to declare they are subclassing from a deprecated class.
 */ 
@implementation CC3PointParticleHoseEmitterDeprecated

-(CC3HoseParticleNavigator*) hoseNavigator { return (CC3HoseParticleNavigator*)_particleNavigator; }

// Deprecated properties delegated to navigator
-(CC3Node*) nozzle { return self.hoseNavigator.nozzle; }
-(void) setNozzle: (CC3Node*) aNode { self.hoseNavigator.nozzle = aNode; }

-(CC3Matrix*) nozzleMatrix { return self.hoseNavigator.nozzleMatrix; }

-(GLfloat) minParticleSpeed { return self.hoseNavigator.minParticleSpeed; }
-(void) setMinParticleSpeed: (GLfloat) speed { self.hoseNavigator.minParticleSpeed = speed; }

-(GLfloat) maxParticleSpeed { return self.hoseNavigator.maxParticleSpeed; }
-(void) setMaxParticleSpeed: (GLfloat) speed { self.hoseNavigator.maxParticleSpeed = speed; }

-(CGSize) dispersionAngle { return self.hoseNavigator.dispersionAngle; }
-(void) setDispersionAngle: (CGSize) dispAngle { self.hoseNavigator.dispersionAngle = dispAngle; }

-(BOOL) shouldPrecalculateNozzleTangents { return self.hoseNavigator.shouldPrecalculateNozzleTangents; }
-(void) setShouldPrecalculateNozzleTangents: (BOOL) shouldPrecalc {
	self.hoseNavigator.shouldPrecalculateNozzleTangents = shouldPrecalc;
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.particleNavigator = [CC3HoseParticleNavigator navigator];
		self.particleClass = [CC3SprayPointParticle class];
	}
	return self;
}

@end

@implementation CC3PointParticleHoseEmitter
@end

