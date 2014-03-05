/*
 * CC3MeshParticleSamples.m
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
 * See header file CC3MeshParticleSamples.h for full API documentation.
 */

#import "CC3MeshParticleSamples.h"
#import "CC3CC2Extensions.h"


#pragma mark -
#pragma mark CC3MortalMeshParticle

@implementation CC3MortalMeshParticle

@synthesize lifeSpan=_lifeSpan, timeToLive=_timeToLive;

-(void) setLifeSpan: (CCTime) anInterval {
	_lifeSpan = anInterval;
	_timeToLive = _lifeSpan;
}

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	_timeToLive -= visitor.deltaTime;
	if (_timeToLive <= 0.0) self.isAlive = NO;
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tlifeSpan: %.3f, timeToLive: %.3f",
			[super fullDescription], _lifeSpan, _timeToLive];
}

-(id) init {
	if ( (self = [super init]) ) {
		_lifeSpan = 0.0f;
		_timeToLive = 0.0f;
	}
	return self;
}

-(void) populateFrom: (CC3MortalMeshParticle*) another {
	[super populateFrom: another];
	
	_lifeSpan = another.lifeSpan;
	_timeToLive = another.timeToLive;
}

@end


#pragma mark -
#pragma mark CC3SprayMeshParticle

@implementation CC3SprayMeshParticle

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

-(void) populateFrom: (CC3SprayMeshParticle*) another {
	[super populateFrom: another];
	_velocity = another.velocity;
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tvelocity: %@",
			[super fullDescription], NSStringFromCC3Vector(_velocity)];
}

@end


#pragma mark -
#pragma mark CC3UniformlyEvolvingMeshParticle

@implementation CC3UniformlyEvolvingMeshParticle

@synthesize colorVelocity=_colorVelocity;

-(CC3Vector) rotationVelocity {
	switch (_rotationVelocityType) {
		case kCC3RotationTypeAxisAngle: {
			CC3Vector4 axisAngle = CC3Vector4FromCC3Vector(self.rotationAxis, self.rotationAngleVelocity);
			return CC3RotationFromQuaternion(CC3QuaternionFromAxisAngle(axisAngle));
		}
		default:
			return _rotationVelocity;
	}
}

-(void) setRotationVelocity: (CC3Vector) aVector {
	_rotationVelocity = aVector;
	_rotationVelocityType = kCC3RotationTypeEuler;
}

-(GLfloat) rotationAngleVelocity {
	switch (_rotationVelocityType) {
		case kCC3RotationTypeEuler: {
			CC3Quaternion quat = CC3QuaternionFromRotation(self.rotationVelocity);
			CC3Vector4 axisAngle = CC3AxisAngleFromQuaternion(quat);
			return axisAngle.w;
		}
		default:
			return _rotationVelocity.x;
	}
}

-(void) setRotationAngleVelocity:(GLfloat) anAngle {
	_rotationVelocity = cc3v(anAngle, anAngle, anAngle);
	_rotationVelocityType = kCC3RotationTypeAxisAngle;
}


#pragma mark Updating

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[super updateBeforeTransform: visitor];
	if( !self.isAlive ) return;
	
	CCTime dt = visitor.deltaTime;
	
	switch (_rotationVelocityType) {
		case kCC3RotationTypeEuler: {
			CC3Vector rotVel = self.rotationVelocity;
			if ( !CC3VectorIsZero(rotVel) ) [self rotateBy: CC3VectorScaleUniform(rotVel, dt)];
			break;
		}
		case kCC3RotationTypeAxisAngle: {
			GLfloat rotAngVel = self.rotationAngleVelocity;
			if (rotAngVel != 0.0f) self.rotationAngle += rotAngVel * dt;
			break;
		}
		default:
			break;
	}
	
	if ( self.hasColor && !CCC4FAreEqual(_colorVelocity, kCCC4FBlackTransparent) ) {
		// We have to do the math on each component instead of using the color math functions
		// because the functions clamp prematurely, and we need negative values for the velocity.
		ccColor4F currColor = self.color4F;
		ccColor4F newColor = ccc4f(CLAMP(currColor.r + (_colorVelocity.r * dt), 0.0f, 1.0f),
								   CLAMP(currColor.g + (_colorVelocity.g * dt), 0.0f, 1.0f),
								   CLAMP(currColor.b + (_colorVelocity.b * dt), 0.0f, 1.0f),
								   CLAMP(currColor.a + (_colorVelocity.a * dt), 0.0f, 1.0f));
		self.color4F = newColor;
		LogTrace(@"Updating color of %@ from %@ to %@", self,
					  NSStringFromCCC4F(currColor), NSStringFromCCC4F(newColor));
	}
	
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_rotationVelocity = kCC3VectorZero;
		_rotationVelocityType = kCC3RotationTypeUnknown;
		_colorVelocity = kCCC4FBlackTransparent;
	}
	return self;
}

// Protected properties for copying
-(GLubyte) rotationVelocityType { return _rotationVelocityType; }

-(void) populateFrom: (CC3UniformlyEvolvingMeshParticle*) another {
	[super populateFrom: another];
	
	_rotationVelocity = another.rotationVelocity;
	_rotationVelocityType = another.rotationVelocityType;
	_colorVelocity = another.colorVelocity;
}

- (NSString*) fullDescription {
	return [NSMutableString stringWithFormat:@"%@\n\tvelocity: %@",
			[super fullDescription], NSStringFromCC3Vector(_velocity)];
}

@end


#pragma mark -
#pragma mark CC3MultiTemplateMeshParticleEmitter

@implementation CC3MultiTemplateMeshParticleEmitter

@synthesize particleTemplateMeshes=_particleTemplateMeshes;

-(void) dealloc {
	[_particleTemplateMeshes release];
	[super dealloc];
}

-(void) addParticleTemplateMesh: (CC3Mesh*) aVtxArrayMesh {
	[_particleTemplateMeshes addObject: aVtxArrayMesh];
	LogTrace(@"%@ added particle template mesh %@ with %i vertices and %i vertex indices",
				  self, aVtxArrayMesh, aVtxArrayMesh.vertexCount, aVtxArrayMesh.vertexIndexCount);
}

/** Removes the specified mesh from the collection of meshes in the particleTemplateMeshes property. */
-(void) removeParticleTemplateMesh: (CC3Mesh*) aVtxArrayMesh {
	[_particleTemplateMeshes removeObjectIdenticalTo: aVtxArrayMesh];
}

-(void) assignTemplateMeshToParticle: (id<CC3MeshParticleProtocol>) aParticle {
	NSUInteger tmCount = _particleTemplateMeshes.count + (_particleTemplateMesh ? 1 : 0);
	CC3Assert(tmCount > 0, @"No particle template meshes available in %@. Use the addParticleTemplateMesh: method to add template meshes for the particles.", self);

	NSUInteger tmIdx = CC3RandomUIntBelow(tmCount);
	aParticle.templateMesh = (tmIdx < _particleTemplateMeshes.count)
									? [_particleTemplateMeshes objectAtIndex: tmIdx]
									: _particleTemplateMesh;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_particleTemplateMeshes = [NSMutableArray new];			// retained
	}
	return self;
}

@end





