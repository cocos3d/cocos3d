/*
 * CC3MeshParticleSamples.h
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

#import "CC3MeshParticles.h"
#import "CC3ParticleSamples.h"


#pragma mark -
#pragma mark CC3MortalMeshParticle

/**
 * CC3MortalMeshParticle is a mesh particle implementation of the CC3MortalParticleProtocol,
 * as a particle that has a finite life.
 *
 * To make evolutionary changes to this particle, implement the updateBeforeTransform: method.
 * In doing so, be sure to invoke the superclass implementation, which checks whether this
 * particle is still alive or has expired. Once the superclass implementation returns, you can
 * check the isAlive property before spending time making any further modifications.
 */
@interface  CC3MortalMeshParticle  : CC3ScalableMeshParticle <CC3MortalParticleProtocol> {
	ccTime lifeSpan;
	ccTime timeToLive;
}

/**
 * This template callback method is invoked automatically whenever the emitter is updated
 * during a scheduled 3D scene update.
 *
 * The CC3MortalMeshParticle implementation checks to see if the whether this particle is
 * still alive or has expired, and sets the isAlive property accordingly.
 *
 * You can override this method to update the evolution of the particle. You should invoke this
 * superclass implementation and test the isAlive property before making any further modifications.
 *
 * Subclasses that override this method should invoke this superclass implementation first,
 * and should check the isAlive property prior to making any further modifications..
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3SprayMeshParticle

/**
 * CC3SprayMeshParticle is a type of CC3MortalMeshParticle that implements the
 * CC3SprayParticleProtocol to configure the particle to move in a straight line at a steady speed.
 */
@interface  CC3SprayMeshParticle  : CC3MortalMeshParticle <CC3SprayParticleProtocol> {
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


#pragma mark -
#pragma mark CC3UniformlyEvolvingMeshParticle

/**
 * CC3UniformlyEvolvingMeshParticle is a CC3SprayMeshParticle whose rotation and color can
 * also be configured to evolve as defined by the CC3UniformlyRotatingParticleProtocol and
 * CC3UniformlyFadingParticleProtocol protocols.
 */
@interface CC3UniformlyEvolvingMeshParticle : CC3SprayMeshParticle
													<CC3UniformlyRotatingParticleProtocol,
													 CC3UniformlyFadingParticleProtocol> {
	CC3Vector rotationVelocity;
	GLubyte rotationVelocityType;
	ccColor4F colorVelocity;
}

@end


#pragma mark -
#pragma mark CC3MultiTemplateMeshParticleEmitter

/**
 * CC3MultiTemplateMeshParticleEmitter is a type of CC3MeshParticleEmitter that supports multiple
 * particle template meshes, one of which can be selected and assigned to each particle as it is
 * emitted.
 *
 * Multiple particle templates can be added to this emitter using the addParticleTemplateMesh:
 * method. The implementation of the assignTemplateMeshToParticle: method defines how a particular
 * template mesh is selected by the emitter and assigned to a particle as it is being emitted.
 *
 * For particles created by the application outside the emitter, and added to the emitter with the
 * emitParticle: method, the application can directly set the templateMesh property of the mesh
 * particle prior to invoking the emitParticle: method of this emitter. With this technique, each
 * particle can use a different mesh template, and so each paticle can be a different shape.
 * If the templateMesh property of a particle submitted to the emitParticle: method is nil, this
 * emitter will select one of the particle templates that have been added to this emitter, and
 * assign it to the particle.
 *
 * For particles created within the emitter, and emitted automatically, or via the emitParticle
 * method, this emitter will select one of the particle templates that have been added to this
 * emitter, and assign it to the particle. In this scenario, each particle will be the same shape.
 *
 * This class inherits the particleTemplateMesh property from CC3MeshParticleEmitter. If that
 * property has also been set, mesh selection will be made from the set of meshes comprised of
 * the template meshes added with the addParticleTemplateMesh: method, and the template mesh
 * assigned to the particleTemplateMesh property.
 */
 @interface CC3MultiTemplateMeshParticleEmitter : CC3MeshParticleEmitter {
	CCArray* particleTemplateMeshes;
}

/**
 * The collection of meshes that can be assigned as the templateMesh of each particle emitted
 * from, or added to, this emitter.
 *
 * When a particle is emitted automatically, of via the emitParticle method, or the emitParticle:
 * method is invoked on a particle that does not already have templateMesh, one of these meshes
 * is selected and assigned as the templateMesh of the particle before it is initialized.
 * The particle template mesh is assigned by the assignTemplateMeshToParticle: method.
 *
 * If the particleTemplateMesh property inherited from the CC3MeshParticleEmitter has also been
 * set, mesh selection will be made from the set of meshes comprised of the combination of the
 * mesh in the particleTemplateMesh property and the meshes in this collection.
 *
 * See the notes for the CC3MeshParticleProtocol templateMesh and CC3MeshParticleEmitter
 * particleTemplateMesh for more information.
 */
@property(nonatomic, retain, readonly) CCArray* particleTemplateMeshes;

/**
 * Adds the specified mesh to the collection of meshes in the particleTemplateMeshes property.
 *
 * When a particle is emitted, or the emitParticle: method is invoked on a particle that does
 * not already have templateMesh, one of these meshes is selected and assigned as the templateMesh
 * of the particle before it is initialized. The particle template mesh is assigned by the
 * assignTemplateMeshToParticle: method.
 *
 * See the notes for the CC3MeshParticleProtocol templateMesh and CC3MeshParticleEmitter
 * particleTemplateMesh for more information.
 */
-(void) addParticleTemplateMesh: (CC3VertexArrayMesh*) aVtxArrayMesh;

/** Removes the specified mesh from the collection of meshes in the particleTemplateMeshes property. */
-(void) removeParticleTemplateMesh: (CC3VertexArrayMesh*) aVtxArrayMesh;

/**
 * Template method that sets the templateMesh property of the specified particle.
 *
 * This implementation sets the templateMesh property of the particle to a mesh randomly 
 * selected from the particleTemplateMeshes collection.
 *
 * If the superclass particleTemplateMesh property of this emitter has also been set, it is
 * included in the selection options, effectively increasing the selection options by one.
 *
 * Subclasses may override this implementation to create some other selection methodology.
 *
 * This method is invoked automatically when a particle is emitted, or the emitParticle: method is
 * invoked with a particle that does not already have a templateMesh. The application should never
 * need to invoke this method directly.
 */
-(void) assignTemplateMeshToParticle: (id<CC3MeshParticleProtocol>) aParticle;

@end


