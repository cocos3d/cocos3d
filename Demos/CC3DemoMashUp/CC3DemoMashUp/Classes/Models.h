/*
 * Models.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3Node.h"
#import "CCActionManager.h"
#import "CC3PODLight.h"
#import "CC3PointParticles.h"
#import "CC3MeshParticleSamples.h"
#import "CC3ParametricMeshNodes.h"


#pragma mark -
#pragma mark IntroducingPODResource

/**
 * Customized POD resource class to handle the idiosyncracies of how the POD file is
 * handled in the original PVRT demo app. This is not normally necessary. Normally,
 * the POD file should be created accurately to reflect the scene.
 */
@interface IntroducingPODResource : CC3PODResource {}
@end


#pragma mark -
#pragma mark IntroducingPODLight

/**
 * Customized light class to handle the idiosyncracies of how lights from the POD file
 * is handled in the original PVRT demo app. This is not normally necessary. Normally,
 * the POD file should be created accurately to reflect the scene.
 */
@interface IntroducingPODLight : CC3PODLight {}
@end



#pragma mark -
#pragma mark HeadPODResource

/**
 * Customized POD resource class to handle the idiosyncracies of the POD file containing
 * the purple floating head. That POD file contains a reference to texture that does not
 * exist, so we override the texture loading behaviour to avoid it, rather than generate
 * spurious errors. This is not normally necessary. Normally, the POD file should be
 * created accurately to reflect the scene.
 */
@interface HeadPODResource : CC3PODResource {}
@end


#pragma mark -
#pragma mark PhysicsMeshNode

/**
 * A specialized mesh node that tracks its instantaneous global velocity, even when
 * controlled by a CCAction, and even when moved as part of another larger node.
 *
 * After each update, this node compares its previous global location to the current
 * global location, and calculates an instantaneous velocity.
 */
@interface PhysicsMeshNode : CC3MeshNode {
	CC3Vector previousGlobalLocation;
	CC3Vector velocity;
}

/** The global location of this node on the previous update. */
@property(nonatomic, readonly) CC3Vector previousGlobalLocation;

/** The current velocity, as calculated during the previous update. */
@property(nonatomic, readonly) CC3Vector velocity;

@end


#pragma mark -
#pragma mark DoorMeshNode

/** Simple class that models a door that can be open or closed.  */
@interface DoorMeshNode : CC3MeshNode {
	BOOL isOpen;
}

/** Indicates whether the door is open or closed. */
@property(nonatomic, assign) BOOL isOpen;

@end


#pragma mark -
#pragma mark SpinningNode

/**
 * A customized node that automatically rotates by adjusting its rotational aspects on
 * each update pass, and can slow the rotation speed over time based on a friction property.
 *
 * To rotate a node using changes in rotation using the rotateBy... family of methods,
 * as is done to this node, does NOT requre a specialized class. This specialized class
 * is required to handle the freewheeling and friction nature of the behaviour after the
 * rotation has begun.
 */
@interface SpinningNode : CC3Node {
	CC3Vector spinAxis;
	GLfloat spinSpeed;
	GLfloat friction;
	BOOL isFreeWheeling;
}

/**
 * The axis that the cube spins around.
 *
 * This is different than the rotationAxis property, because this is the axis around which
 * a CHANGE in rotation will occur. Depending on how the node is already rotated, this may
 * be very different than the rotationAxis.
 */
@property(nonatomic, assign) CC3Vector spinAxis;

/**
 * The speed of rotation. This value can be directly updated, and then will automatically
 * be slowed down over time according to the value of the friction property.
 */
@property(nonatomic, assign) GLfloat spinSpeed;

/**
 * The friction value that is applied to the spinSpeed to slow it down over time.
 *
 * A value of zero will not slow rotation down at all and the node will continue
 * spinning indefinitely.
 */
@property(nonatomic, assign) GLfloat friction;

/** Indicates whether the node is spinning without direct control by touch events. */
@property(nonatomic, assign) BOOL isFreeWheeling;

@end


#pragma mark -
#pragma mark LandingCraft

/**
 * LandingCraft is a specialized node that creates and holds an army of other nodes, based on
 * a template node that is repeatedly copied, and the copies are distributed around the scene.
 */
@interface LandingCraft : CC3Node

/**
 * Creates many copies of the specified template node, and places them around the scene.
 * Each of the copies is independently animated at different speeds using CCActionIntervals,
 * to demonstrate the individuality of nodes, even though they share the same mesh data.
 *
 * The landing motion rains the invading nodes down from the sky, again using CCActionIntervals.
 * These actions are also independently timed so that the invading nodes drop randomly like rain.
 */
-(void) populateArmyWith: (CC3Node*) templateNode;

/** Removes the invasion army by fading them away and then removing them from the scene. */
-(void) evaporate;

@end


/**
 * Category extention to the CCActionManager class to extract the total number of CCActions
 * that are currently running. This is just used to log that number, to demonstrate that
 * the multitude of CCActions are being cleaned up properly when the invading army is removed.
 */
@interface CCActionManager (LandingCraft)

/** The total number of currently running actions. */
-(uint) numberOfRunningActions;

@end


#pragma mark -
#pragma mark HangingParticles

#define kParticlesPerSide		30
#define kParticlesSpacing		40


#pragma mark -
#pragma mark HangingPointParticle

/**
 * A point particle type that simply hangs where it is located. When the particle is initialized,
 * the location is set from the index, so that the particles are laid out in a simple rectangular
 * grid in the X-Z plane, with kParticlesPerSide particles on each side of the grid. This particle
 * type contains no additional state information.
 */
@interface HangingPointParticle : CC3PointParticle
@end


#pragma mark -
#pragma mark HangingMeshParticle

/**
 * A mesh particle type that simply hangs where it is located. When the particle is initialized,
 * the location is set from the index, so that the particles are laid out in a simple rectangular
 * grid in the X-Z plane, with kParticlesPerSide particles on each side of the grid. This particle
 * type contains no additional state information.
 */
@interface HangingMeshParticle : CC3ScalableMeshParticle {
	GLfloat rotationSpeed;
	GLfloat accumulatedAngleChange;
}

/**
 * The speed of rotation, in degrees per second.
 *
 * This initial value is set to a random value during initialization.
 */
@property(nonatomic, assign) GLfloat rotationSpeed;

@end


#pragma mark -
#pragma mark RotatingFadingMeshParticle

/** A mesh particle type that rotates steadily around a random axis, and fades over its lifetime.  */
@interface RotatingFadingMeshParticle : CC3UniformlyEvolvingMeshParticle {}
@end


#pragma mark -
#pragma mark CylinderLabel

/**
 * A mesh node whose mesh is created from a text label that is wrapped around the arc of a circle
 * whose center is behind the text. The effect is like a marquee on a round tower.
 *
 * This example demonstrates both the use of bitmapped text labels, and the ability to
 * manipulate the locations of vertices programmatically.
 */
@interface CylinderLabel : CC3BitmapLabelNode {
	GLfloat radius;
}

/**
 * The radius of the cylinder. This defines the curvature of the text label.
 *
 * The initial value is 1000.
 */
@property(nonatomic, assign) GLfloat radius;

@end


