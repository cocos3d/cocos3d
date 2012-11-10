/*
 * CC3ParticleSamples.m
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
 * See header file CC3ParticleSamples.h for full API documentation.
 */

#import "CC3ParticleSamples.h"
#import "CC3AffineMatrix.h"


#pragma mark -
#pragma mark CC3RandomMortalParticleNavigator

@implementation CC3RandomMortalParticleNavigator

@synthesize minParticleLifeSpan, maxParticleLifeSpan;

-(Protocol*) requiredParticleProtocol { return @protocol(CC3MortalParticleProtocol); }

-(id) init {
	if ( (self = [super init]) ) {
		minParticleLifeSpan = 0.0f;
		maxParticleLifeSpan = 0.0f;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3RandomMortalParticleNavigator*) another {
	[super populateFrom: another];
	
	minParticleLifeSpan = another.minParticleLifeSpan;
	maxParticleLifeSpan = another.maxParticleLifeSpan;
}

-(void) initializeParticle: (id<CC3MortalParticleProtocol>) aParticle {
	aParticle.lifeSpan = CC3RandomFloatBetween(minParticleLifeSpan, maxParticleLifeSpan);
}

@end


#pragma mark -
#pragma mark CC3HoseParticleNavigator

/** Converts the angular components of the specified dispersion into tangents. */
static inline CGSize CC3ShapeFromDispersionAngle(CGSize anAngle) {
	return CGSizeMake(tanf(DegreesToRadians(anAngle.width / 2.0)),
					  tanf(DegreesToRadians(anAngle.height / 2.0)));
}

/** Converts the tangential components of the specified aspect into dispersion angles. */
static inline CGSize CC3DispersionAngleFromShape(CGSize anAspect) {
	return CGSizeMake(RadiansToDegrees(2.0 * atanf(anAspect.width)),
					  RadiansToDegrees(2.0 * atanf(anAspect.height)));
}

@interface CC3HoseParticleNavigator (TemplateMethods)
-(void) buildNozzleMatrix;
-(void) checkNozzleParent;
@end

@implementation CC3HoseParticleNavigator

@synthesize nozzleMatrix, minParticleSpeed, maxParticleSpeed;
@synthesize shouldPrecalculateNozzleTangents;

-(void) dealloc {
	self.nozzle = nil;			// Setter clears listener and releases nozzle
	[nozzleMatrix release];
	[super dealloc];
}

-(void) setEmitter: (CC3ParticleEmitter*) anEmitter {
	super.emitter = anEmitter;
	[self checkNozzleParent];
}

-(CC3Node*) nozzle { return nozzle; }

-(void) setNozzle: (CC3Node*) aNode {
	if (aNode == nozzle) return;
	
	[nozzle removeTransformListener: self];
	if (nozzle.parent == emitter) [nozzle remove];
	[nozzle release];

	nozzle = [aNode retain];
	[nozzle addTransformListener: self];
	[self checkNozzleParent];
}

/** If the nozzle does not have a parent, add it to the emitter. */
-(void) checkNozzleParent {
	if ( nozzle && !nozzle.parent ) {
		if (emitter.name) nozzle.name = [NSString stringWithFormat: @"%@-Nozzle", emitter.name];
		[emitter addChild: nozzle];
	}
}

// Protected property for copying
-(CGSize) nozzleShape { return nozzleShape; }

-(CGSize) dispersionAngle {
	return shouldPrecalculateNozzleTangents
				? CC3DispersionAngleFromShape(nozzleShape)
				: nozzleShape;
}

#define kCC3TangentPrecalcThreshold 90.0f

-(void) setDispersionAngle: (CGSize) dispAngle {
	shouldPrecalculateNozzleTangents = (dispAngle.width < kCC3TangentPrecalcThreshold &&
										dispAngle.height < kCC3TangentPrecalcThreshold);
	nozzleShape = shouldPrecalculateNozzleTangents ? CC3ShapeFromDispersionAngle(dispAngle) : dispAngle;
}

/** If we're flipping from one to the other, convert the nozzleShape. */
-(void) setShouldPrecalculateNozzleTangents: (BOOL) shouldPrecalc {
	if ( shouldPrecalculateNozzleTangents && !shouldPrecalc ) {
		nozzleShape = CC3DispersionAngleFromShape(nozzleShape);
	} else if ( !shouldPrecalculateNozzleTangents && shouldPrecalc ) {
		nozzleShape = CC3ShapeFromDispersionAngle(nozzleShape);
	}
	shouldPrecalculateNozzleTangents = shouldPrecalc;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		self.nozzle = [CC3Node node];
		nozzleMatrix = [CC3AffineMatrix new];
		shouldPrecalculateNozzleTangents = YES;
		self.dispersionAngle = CGSizeMake(15.0, 15.0);		// Set after so it will precalc
		minParticleSpeed = 0.0f;
		maxParticleSpeed = 0.0f;
	}
	return self;
}

-(Protocol*) requiredParticleProtocol { return @protocol(CC3SprayParticleProtocol); }

-(void) populateFrom: (CC3HoseParticleNavigator*) another {
	[super populateFrom: another];
	
	self.nozzle = another.nozzle;						// retained
	nozzleMatrix = [another.nozzleMatrix copy];			// retained
	nozzleShape = another.nozzleShape;
	minParticleSpeed = another.minParticleSpeed;
	maxParticleSpeed = another.maxParticleSpeed;
	shouldPrecalculateNozzleTangents = another.shouldPrecalculateNozzleTangents;
}


#pragma mark Updating

-(void) nodeWasTransformed: (CC3Node*) aNode { if (aNode == nozzle) [self buildNozzleMatrix]; }

-(void) nodeWasDestroyed: (CC3Node*) aNode {}

-(void) buildNozzleMatrix {
	if ( nozzle && nozzle.parent != emitter ) {
		[nozzleMatrix populateFrom: nozzle.transformMatrix];
		[nozzleMatrix leftMultiplyBy: emitter.transformMatrixInverted];
	} else {
		[nozzleMatrix populateIdentity];
	}
}

/**
 * Determines the particle's emission location and direction in terms of the local coordinates
 * of the nozzle, and then transforms each of these to the local coordinate system of the emitter.
 */
-(void) initializeParticle: (id<CC3SprayParticleProtocol>) aParticle {
	[super initializeParticle: aParticle];
	
	// The particle starts at the location of the nozzle, converted from the
	// nozzle's local coordinate system to the emitter's local coordinate system.
	aParticle.location = [nozzleMatrix transformLocation: kCC3VectorZero];
	
	// Speed of particle is randomized.
	GLfloat emissionSpeed = CC3RandomFloatBetween(minParticleSpeed, maxParticleSpeed);

	// Emission direction in the nozzle's local coordinate system is towards the negative
	// Z-axis, with randomization in the X & Y directions based on the shape of the nozzle.
	// Randomization is performed either on the dispersion angle, or on the tangents of the
	// dispersion angle, depending on the value of the shouldPrecalculateNozzleTangents.
	CGSize nozzleAspect = CGSizeMake(CC3RandomFloatBetween(-nozzleShape.width, nozzleShape.width),
									 CC3RandomFloatBetween(-nozzleShape.height, nozzleShape.height));
	if ( !shouldPrecalculateNozzleTangents ) nozzleAspect = CC3ShapeFromDispersionAngle(nozzleAspect);
	CC3Vector emissionDir = CC3VectorNormalize(cc3v(nozzleAspect.width, nozzleAspect.height, 1.0f));

	// The combination of emission speed and emission direction is the emission velocity in the
	// nozzle's local coordinates. The particle velocity is then the nozzle emission velocity
	// transformed by the nozzleMatrix to convert it to the emitter's local coordinates.
	CC3Vector emissionVelocity = CC3VectorScaleUniform(emissionDir, emissionSpeed);
	aParticle.velocity = [nozzleMatrix transformDirection: emissionVelocity];
}

@end


