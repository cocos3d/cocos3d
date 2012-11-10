/*
 * CC3PointParticleSamples.m
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
 * See header file CC3PointParticleSamples.h for full API documentation.
 */

#import "CC3PointParticleSamples.h"

/** Re-declaration of deprecated methods to suppress compiler warnings within this class. */
@protocol CC3MortalPointParticleDeprecated
-(void) updateLife: (ccTime) dt;
@end


#pragma mark -
#pragma mark CC3MortalPointParticle

@implementation CC3MortalPointParticle

@synthesize lifeSpan, timeToLive;

-(void) setLifeSpan: (ccTime) anInterval {
	lifeSpan = anInterval;
	timeToLive = lifeSpan;
}

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	ccTime dt = visitor.deltaTime;
	timeToLive -= dt;
	if (timeToLive <= 0.0) {
		self.isAlive = NO;
	} else {
		[((id<CC3MortalPointParticleDeprecated>)self) updateLife: dt];
	}
}

-(void) populateFrom: (CC3MortalPointParticle*) another {
	[super populateFrom: another];
	lifeSpan = another.lifeSpan;
	timeToLive = another.timeToLive;
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tlifeSpan: %.3f, timeToLive: %.3f",
			[super fullDescription], lifeSpan, timeToLive];
}

// Deprecated
-(void) updateLife: (ccTime) dt {}

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

-(CC3RandomMortalParticleNavigator*) mortalParticleNavigator { return (CC3RandomMortalParticleNavigator*)particleNavigator; }

-(ccTime) minParticleLifeSpan { return self.mortalParticleNavigator.minParticleLifeSpan; }

-(void) setMinParticleLifeSpan: (ccTime) minLifeSpan {
	self.mortalParticleNavigator.minParticleLifeSpan = minLifeSpan;
}

-(ccTime) maxParticleLifeSpan { return self.mortalParticleNavigator.maxParticleLifeSpan; }

-(void) setMaxParticleLifeSpan: (ccTime) maxLifeSpan {
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

@synthesize velocity;

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super updateBeforeTransform: visitor];
	if( !self.isAlive ) return;

	self.location = CC3VectorAdd(self.location, CC3VectorScaleUniform(self.velocity, visitor.deltaTime));
}

-(id) init {
	if ( (self = [super init]) ) {
		velocity = kCC3VectorZero;
	}
	return self;
}

-(void) populateFrom: (CC3SprayPointParticle*) another {
	[super populateFrom: another];
	velocity = another.velocity;
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tvelocity: %@",
			[super fullDescription], NSStringFromCC3Vector(velocity)];
}

@end

// Deprecated class
@implementation CC3UniformMotionParticle
@end


#pragma mark -
#pragma mark CC3UniformlyEvolvingPointParticle

@implementation CC3UniformlyEvolvingPointParticle

@synthesize colorVelocity, sizeVelocity;

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super updateBeforeTransform: visitor];
	if( !self.isAlive ) return;
	
	ccTime dt = visitor.deltaTime;
	
	if (self.hasSize) self.size = self.size + (sizeVelocity * dt);
	
	if (self.hasColor) {
		// We have to do the math on each component instead of using the color math functions
		// because the functions clamp prematurely, and we need negative values for the velocity.
		ccColor4F currColor = self.color4F;
		self.color4F = CCC4FMake(CLAMP(currColor.r + (colorVelocity.r * dt), 0.0, 1.0),
								 CLAMP(currColor.g + (colorVelocity.g * dt), 0.0, 1.0),
								 CLAMP(currColor.b + (colorVelocity.b * dt), 0.0, 1.0),
								 CLAMP(currColor.a + (colorVelocity.a * dt), 0.0, 1.0));
	}
}

-(void) populateFrom: (CC3UniformlyEvolvingPointParticle*) another {
	[super populateFrom: another];
	sizeVelocity = another.sizeVelocity;
	colorVelocity = another.colorVelocity;
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
	self.colorVelocity = CCC4FMake(colVel.r / lifeSpan,
								   colVel.g / lifeSpan,
								   colVel.b / lifeSpan,
								   colVel.a / lifeSpan);
	
	self.sizeVelocity /= lifeSpan;
}

@end


#pragma mark -
#pragma mark CC3VariegatedPointParticleHoseEmitter

@implementation CC3VariegatedPointParticleHoseEmitter

@synthesize minParticleStartingSize, maxParticleStartingSize, minParticleEndingSize, maxParticleEndingSize;
@synthesize minParticleStartingColor, maxParticleStartingColor, minParticleEndingColor, maxParticleEndingColor;


#pragma mark Allocation and initialization


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.particleNavigator = [CC3HoseParticleNavigator navigator];
		self.particleClass = [CC3VariegatedPointParticle class];
		minParticleStartingSize = kCC3DefaultParticleSize;
		maxParticleStartingSize = kCC3DefaultParticleSize;
		minParticleEndingSize = kCC3DefaultParticleSize;
		maxParticleEndingSize = kCC3DefaultParticleSize;
		minParticleStartingColor = kCCC4FWhite;
		maxParticleStartingColor = kCCC4FWhite;
		minParticleEndingColor = kCCC4FWhite;
		maxParticleEndingColor = kCCC4FWhite;
	}
	return self;
}

-(Protocol*) requiredParticleProtocol { return @protocol(CC3VariegatedPointParticleProtocol); }

-(void) populateFrom: (CC3VariegatedPointParticleHoseEmitter*) another {
	[super populateFrom: another];
	
	minParticleStartingSize = another.minParticleStartingSize;
	maxParticleStartingSize = another.maxParticleStartingSize;
	minParticleEndingSize = another.minParticleEndingSize;
	maxParticleEndingSize = another.maxParticleEndingSize;
	minParticleStartingColor = another.minParticleStartingColor;
	maxParticleStartingColor = another.maxParticleStartingColor;
	minParticleEndingColor = another.minParticleEndingColor;
	maxParticleEndingColor = another.maxParticleEndingColor;
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
		ccColor4F startColor = RandomCCC4FBetween(minParticleStartingColor, maxParticleStartingColor);
		aParticle.color4F = startColor;
		
		// End color is treated differently. If any component of either min or max is negative,
		// it indicates that the corresponding component of the start color should be used,
		// otherwise a random value between min and max is chosen.
		// This allows random colors to be chosen, but to have them stay constant.
		// For exmaple, setting all color components to -1 and alpha to zero, indicates that
		// the particle should stay the same color, but fade away.
		ccColor4F endColor;
		endColor.r = CC3RandomOrAlt(minParticleEndingColor.r, maxParticleEndingColor.r, startColor.r);
		endColor.g = CC3RandomOrAlt(minParticleEndingColor.g, maxParticleEndingColor.g, startColor.g);
		endColor.b = CC3RandomOrAlt(minParticleEndingColor.b, maxParticleEndingColor.b, startColor.b);
		endColor.a = CC3RandomOrAlt(minParticleEndingColor.a, maxParticleEndingColor.a, startColor.a);
		
		// We have to do the math on each component instead of using the color math functions
		// because the functions clamp prematurely, and we need negative values for the velocity.
		aParticle.colorVelocity = CCC4FMake((endColor.r - startColor.r),
											(endColor.g - startColor.g),
											(endColor.b - startColor.b),
											(endColor.a - startColor.a));
	}
	
	// Set the particle's initial size and size velocity, which is calculated by taking the
	// difference of the start and end sizes. This assumes that the color changes over one second.
	// The particle itself will figure out how the overall change should be adjusted for its lifespan.
	if(self.mesh.hasVertexPointSizes) {
		GLfloat startSize = CC3RandomFloatBetween(minParticleStartingSize, maxParticleStartingSize);
		aParticle.size = startSize;
		
		// End size is treated differently. If either min or max is negative, it indicates that
		// the start size should be used, otherwise a random value between min and max is chosen.
		// This allows a random size to be chosen, but to have it stay constant.
		GLfloat endSize = CC3RandomOrAlt(minParticleEndingSize, maxParticleEndingSize, startSize);
		
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

-(CC3HoseParticleNavigator*) hoseNavigator { return (CC3HoseParticleNavigator*)particleNavigator; }

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


