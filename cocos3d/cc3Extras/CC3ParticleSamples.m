/*
 * CC3ParticleSamples.m
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
 * See header file CC3ParticleSamples.h for full API documentation.
 */

#import "CC3ParticleSamples.h"
#import "CC3AffineMatrix.h"


#pragma mark -
#pragma mark CC3RandomMortalParticleNavigator

@implementation CC3RandomMortalParticleNavigator

@synthesize minParticleLifeSpan=_minParticleLifeSpan, maxParticleLifeSpan=_maxParticleLifeSpan;

-(Protocol*) requiredParticleProtocol { return @protocol(CC3MortalParticleProtocol); }

-(id) init {
	if ( (self = [super init]) ) {
		_minParticleLifeSpan = 0.0f;
		_maxParticleLifeSpan = 0.0f;
	}
	return self;
}

-(void) populateFrom: (CC3RandomMortalParticleNavigator*) another {
	[super populateFrom: another];
	
	_minParticleLifeSpan = another.minParticleLifeSpan;
	_maxParticleLifeSpan = another.maxParticleLifeSpan;
}

-(void) initializeParticle: (id<CC3MortalParticleProtocol>) aParticle {
	aParticle.lifeSpan = CC3RandomFloatBetween(_minParticleLifeSpan, _maxParticleLifeSpan);
}

@end


#pragma mark -
#pragma mark CC3HoseParticleNavigator

/** Converts the angular components of the specified dispersion into tangents. */
static inline CGSize CC3ShapeFromDispersionAngle(CGSize anAngle) {
	return CGSizeMake(tanf(CC3DegToRad(anAngle.width / 2.0)),
					  tanf(CC3DegToRad(anAngle.height / 2.0)));
}

/** Converts the tangential components of the specified aspect into dispersion angles. */
static inline CGSize CC3DispersionAngleFromShape(CGSize anAspect) {
	return CGSizeMake(CC3RadToDeg(2.0 * atanf(anAspect.width)),
					  CC3RadToDeg(2.0 * atanf(anAspect.height)));
}

@implementation CC3HoseParticleNavigator

@synthesize minParticleSpeed=_minParticleSpeed, maxParticleSpeed=_maxParticleSpeed;
@synthesize shouldPrecalculateNozzleTangents=_shouldPrecalculateNozzleTangents;

-(void) dealloc {
	self.nozzle = nil;			// Setter clears listener and releases nozzle
	[_nozzleMatrix release];
	
	[super dealloc];
}

-(void) setEmitter: (CC3ParticleEmitter*) anEmitter {
	super.emitter = anEmitter;
	[self checkNozzleParent];
}

-(CC3Node*) nozzle { return _nozzle; }

-(void) setNozzle: (CC3Node*) aNode {
	if (aNode == _nozzle) return;
	
	[_nozzle removeTransformListener: self];
	if (_nozzle.parent == _emitter) [_nozzle remove];

	[_nozzle release];
	_nozzle = [aNode retain];
	
	[_nozzle addTransformListener: self];
	[self checkNozzleParent];
}

/** If the nozzle does not have a parent, add it to the emitter. */
-(void) checkNozzleParent {
	if ( _nozzle && !_nozzle.parent ) {
		if (_emitter.name) _nozzle.name = [NSString stringWithFormat: @"%@-Nozzle", _emitter.name];
		[_emitter addChild: _nozzle];
	}
}

// Protected property for copying
-(CGSize) nozzleShape { return _nozzleShape; }

-(CGSize) dispersionAngle {
	return _shouldPrecalculateNozzleTangents
				? CC3DispersionAngleFromShape(_nozzleShape)
				: _nozzleShape;
}

#define kCC3TangentPrecalcThreshold 90.0f

-(void) setDispersionAngle: (CGSize) dispAngle {
	_shouldPrecalculateNozzleTangents = (dispAngle.width < kCC3TangentPrecalcThreshold &&
										dispAngle.height < kCC3TangentPrecalcThreshold);
	_nozzleShape = _shouldPrecalculateNozzleTangents ? CC3ShapeFromDispersionAngle(dispAngle) : dispAngle;
}

/** If we're flipping from one to the other, convert the nozzleShape. */
-(void) setShouldPrecalculateNozzleTangents: (BOOL) shouldPrecalc {
	if ( _shouldPrecalculateNozzleTangents && !shouldPrecalc ) {
		_nozzleShape = CC3DispersionAngleFromShape(_nozzleShape);
	} else if ( !_shouldPrecalculateNozzleTangents && shouldPrecalc ) {
		_nozzleShape = CC3ShapeFromDispersionAngle(_nozzleShape);
	}
	_shouldPrecalculateNozzleTangents = shouldPrecalc;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		self.nozzle = [CC3Node node];
		_nozzleMatrix = [CC3AffineMatrix new];				// retained
		_shouldPrecalculateNozzleTangents = YES;
		self.dispersionAngle = CGSizeMake(15.0, 15.0);		// Set after so it will precalc
		_minParticleSpeed = 0.0f;
		_maxParticleSpeed = 0.0f;
	}
	return self;
}

-(Protocol*) requiredParticleProtocol { return @protocol(CC3SprayParticleProtocol); }

-(void) populateFrom: (CC3HoseParticleNavigator*) another {
	[super populateFrom: another];
	
	self.nozzle = another.nozzle;
	[_nozzleMatrix populateFrom: another.nozzleMatrix];
	_nozzleShape = another.nozzleShape;
	_minParticleSpeed = another.minParticleSpeed;
	_maxParticleSpeed = another.maxParticleSpeed;
	_shouldPrecalculateNozzleTangents = another.shouldPrecalculateNozzleTangents;
}


#pragma mark Updating

-(void) nodeWasTransformed: (CC3Node*) aNode { if (aNode == _nozzle) _nozzleMatrix.isDirty = YES; }

-(void) nodeWasDestroyed: (CC3Node*) aNode {}

-(CC3Matrix*) nozzleMatrix {
	if (_nozzleMatrix.isDirty) {
		if ( _nozzle && _nozzle.parent != _emitter ) {
			[_nozzleMatrix populateFrom: _nozzle.globalTransformMatrix];
			[_nozzleMatrix leftMultiplyBy: _emitter.globalTransformMatrixInverted];
		} else
			[_nozzleMatrix populateIdentity];

		_nozzleMatrix.isDirty = NO;
	}
	return _nozzleMatrix;
}

/**
 * Determines the particle's emission location and direction in terms of the local coordinates
 * of the nozzle, and then transforms each of these to the local coordinate system of the emitter.
 */
-(void) initializeParticle: (id<CC3SprayParticleProtocol>) aParticle {
	[super initializeParticle: aParticle];
	
	// The particle starts at the location of the nozzle, converted from the
	// nozzle's local coordinate system to the emitter's local coordinate system.
	aParticle.location = [self.nozzleMatrix transformLocation: kCC3VectorZero];
	
	// Speed of particle is randomized.
	GLfloat emissionSpeed = CC3RandomFloatBetween(_minParticleSpeed, _maxParticleSpeed);

	// Emission direction in the nozzle's local coordinate system is towards the negative
	// Z-axis, with randomization in the X & Y directions based on the shape of the nozzle.
	// Randomization is performed either on the dispersion angle, or on the tangents of the
	// dispersion angle, depending on the value of the shouldPrecalculateNozzleTangents.
	CGSize nozzleAspect = CGSizeMake(CC3RandomFloatBetween(-_nozzleShape.width, _nozzleShape.width),
									 CC3RandomFloatBetween(-_nozzleShape.height, _nozzleShape.height));
	if ( !_shouldPrecalculateNozzleTangents ) nozzleAspect = CC3ShapeFromDispersionAngle(nozzleAspect);
	CC3Vector emissionDir = CC3VectorNormalize(cc3v(nozzleAspect.width, nozzleAspect.height, 1.0f));

	// The combination of emission speed and emission direction is the emission velocity in the
	// nozzle's local coordinates. The particle velocity is then the nozzle emission velocity
	// transformed by the nozzleMatrix to convert it to the emitter's local coordinates.
	CC3Vector emissionVelocity = CC3VectorScaleUniform(emissionDir, emissionSpeed);
	aParticle.velocity = [self.nozzleMatrix transformDirection: emissionVelocity];
}

@end


