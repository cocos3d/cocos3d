/*
 * CC3PointParticleSamples.m
 *
 * cocos3d 0.6.4
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
 * 
 * See header file CC3PointParticleSamples.h for full API documentation.
 */

#import "CC3PointParticleSamples.h"


#pragma mark -
#pragma mark CC3PointParticleHoseEmitter

/** Converts the angular components of the specified dispersion into tangents. */
CGSize CC3ShapeFromDispersionAngle(CGSize anAngle) {
	return CGSizeMake(tanf(DegreesToRadians(anAngle.width / 2.0)),
					  tanf(DegreesToRadians(anAngle.height / 2.0)));
}

/** Converts the tangential components of the specified aspect into dispersion angles. */
CGSize CC3DispersionAngleFromShape(CGSize anAspect) {
	return CGSizeMake(RadiansToDegrees(2.0 * atanf(anAspect.width)),
					  RadiansToDegrees(2.0 * atanf(anAspect.height)));
}

@interface CC3PointParticleEmitter (TempalteMethods)
-(void) populateFrom: (CC3PointParticleEmitter*) another;
-(void) checkEmission: (ccTime) dt;
@end

@interface CC3PointParticleHoseEmitter (TemplateMethods)
-(NSString*) nozzleName;
-(void) buildNozzleMatrix;
@end

@implementation CC3PointParticleHoseEmitter

@synthesize nozzle, nozzleMatrix, minParticleSpeed, maxParticleSpeed;
@synthesize shouldPrecalculateNozzleTangents;

-(void) dealloc {
	[nozzle release];
	[nozzleMatrix release];
	[super dealloc];
}

-(CGSize) dispersionAngle {
	return shouldPrecalculateNozzleTangents
				? CC3DispersionAngleFromShape(nozzleShape)
				: nozzleShape;
//	return CGSizeMake(RadiansToDegrees(2.0 * atanf(nozzleShape.width)),
//					  RadiansToDegrees(2.0 * atanf(nozzleShape.height)));
}

-(void) setDispersionAngle: (CGSize) dispAngle {
	if (shouldPrecalculateNozzleTangents) {
		nozzleShape = CC3ShapeFromDispersionAngle(dispAngle);
	} else {
		nozzleShape = dispAngle;
	}
//	nozzleShape = CGSizeMake(tanf(DegreesToRadians(dispAngle.width / 2.0)),
//							  tanf(DegreesToRadians(dispAngle.height / 2.0)));
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

-(void) buildNozzleMatrix {
	if ( nozzle && nozzle.parent != self ) {
		[nozzleMatrix populateFrom: nozzle.transformMatrix];
		[nozzleMatrix leftMultiplyByMatrix: self.transformMatrixInverted];
	} else if ( !nozzleMatrix.isIdentity ) {
		[nozzleMatrix populateIdentity];
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.nozzle = [CC3Node nodeWithName: [self nozzleName]];
		[self addChild: nozzle];
		nozzleMatrix = [[CC3GLMatrix identity] retain];
		nozzleShape = CGSizeMake(15.0, 15.0);
		minParticleSpeed = 0.0f;
		maxParticleSpeed = 0.0f;
		shouldPrecalculateNozzleTangents = NO;
	}
	return self;
}

-(id) particleClass {
	return [CC3UniformMotionParticle class];
}

/**
 * The name to use when creating the nozzle node. For uniqueness, includes
 * the tag of this node in case this node has no name, or a very common name.
 */
-(NSString*) nozzleName {
	return [NSString stringWithFormat: @"%@-%u-Nozzle", self.name, self.tag];
}

// Protected property for copying
-(CGSize) nozzleShape { return nozzleShape; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3PointParticleHoseEmitter*) another {
	[super populateFrom: another];
	
	self.nozzle = another.nozzle;						// retained
	nozzleMatrix = [another.nozzleMatrix copy];			// retained
	nozzleShape = another.nozzleShape;
	minParticleSpeed = another.minParticleSpeed;
	maxParticleSpeed = another.maxParticleSpeed;
	shouldPrecalculateNozzleTangents = another.shouldPrecalculateNozzleTangents;
}


#pragma mark Updating

-(void) checkEmission: (ccTime) dt {
	if (isEmitting) {
		[self buildNozzleMatrix];
	}
	[super checkEmission: dt];
}

/**
 * Determines the particle's emission location and direction in terms of the local coordinates
 * of the nozzle, and then transforms each of these to the local coordinate system of the emitter.
 */
-(void) initializeMortalParticle: (CC3MortalPointParticle*) aParticle {
	
	// We want to configure a CC3UniformMotionParticle.
	CC3UniformMotionParticle* ump = (CC3UniformMotionParticle*)aParticle;
	
	// The particle starts at the location of the nozzle, converted from the
	// nozzle's local coordinate system to the emitter's local coordinate system.
	ump.location = [nozzleMatrix transformLocation: kCC3VectorZero];
	
	// Speed of particle is randomized.
	GLfloat emissionSpeed = CC3RandomFloatBetween(minParticleSpeed, maxParticleSpeed);

	// Emission direction in the nozzle's local coordinate system is towards the negative
	// Z-axis, with randomization in the X & Y directions based on the shape of the nozzle.
	// Randomization is performed either on the dispersion angle, or on the tangents of the
	// dispersion angle, depending on the value of the shouldPrecalculateNozzleTangents.
	CGSize nozzleAspect = CGSizeMake(CC3RandomFloatBetween(-nozzleShape.width, nozzleShape.width),
									 CC3RandomFloatBetween(-nozzleShape.height, nozzleShape.height));
	if ( !shouldPrecalculateNozzleTangents ) {
		nozzleAspect = CC3ShapeFromDispersionAngle(nozzleAspect);
	}
	CC3Vector emissionDir = CC3VectorNormalize(cc3v(nozzleAspect.width, nozzleAspect.height, -1.0f));

	// The combination of emission speed and emission direction is the emission velocity in the
	// nozzle's local coordinates. The particle velocity is then the nozzle emission velocity
	// transformed by the nozzleMatrix to convert it to the emitter's local coordinates.
	CC3Vector emissionVelocity = CC3VectorScaleUniform(emissionDir, emissionSpeed);
	ump.velocity = [nozzleMatrix transformDirection: emissionVelocity];
}

@end


#pragma mark -
#pragma mark CC3VariegatedPointParticleHoseEmitter

@implementation CC3VariegatedPointParticleHoseEmitter

@synthesize minParticleStartingSize, maxParticleStartingSize, minParticleEndingSize, maxParticleEndingSize;
@synthesize minParticleStartingColor, maxParticleStartingColor, minParticleEndingColor, maxParticleEndingColor;


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
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

-(id) particleClass {
	return [CC3UniformEvolutionParticle class];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
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

-(void) initializeMortalParticle: (CC3MortalPointParticle*) aParticle {
	[super initializeMortalParticle: aParticle];
	
	// We want to configure a CC3UniformEvolutionParticle.
	CC3UniformEvolutionParticle* uep = (CC3UniformEvolutionParticle*)aParticle;
	
	// Set the particle's initial color and color velocity, which is calculated by
	// taking the difference of the start and end colors and dividing by the lifeSpan.
	if (mesh.hasColors) {
		ccColor4F startColor = RandomCCC4FBetween(minParticleStartingColor, maxParticleStartingColor);
		uep.color4F = startColor;

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
		GLfloat lifeRate = 1.0 / uep.lifeSpan;
		uep.colorVelocity = CCC4FMake((endColor.r - startColor.r) * lifeRate,
									  (endColor.g - startColor.g) * lifeRate,
									  (endColor.b - startColor.b) * lifeRate,
									  (endColor.a - startColor.a) * lifeRate);
	}
	
	// Set the particle's initial size and size velocity, which is calculated by
	// taking the difference of the start and end sizes and dividing by the lifeSpan.
	if(self.particleMesh.hasPointSizes) {
		GLfloat startSize = CC3RandomFloatBetween(minParticleStartingSize, maxParticleStartingSize);
		uep.size = startSize;

		// End size is treated differently. If either min or max is negative, it indicates that
		// the start size should be used, otherwise a random value between min and max is chosen.
		// This allows a random size to be chosen, but to have it stay constant.
		GLfloat endSize = CC3RandomOrAlt(minParticleEndingSize, maxParticleEndingSize, startSize);

		uep.sizeVelocity = (endSize - startSize) / uep.lifeSpan;
	}
}

@end


