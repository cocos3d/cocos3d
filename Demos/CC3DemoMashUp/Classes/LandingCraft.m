/*
 * LandingCraft.m
 *
 * cocos3d 0.6.1
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file LandingCraft.h for full API documentation.
 */

#import "LandingCraft.h"
#import "CC3ActionInterval.h"
#import "CCActionInstant.h"

#define kDropHeight 700.0

@implementation LandingCraft

-(void) populateArmyWith: (CC3Node*) templateNode {

	// To help demonstrate that the hordes of actioned nodes that make up this army are being managed
	// correctly, log the current number of nodes and actions, before the army has been created.
	LogInfo(@"Before populating %@ there are %i instances of CC3Identifiable subclasses in existance, and  %u actions running.",
			self, [CC3Identifiable instanceCount], [[CCActionManager sharedManager] numberOfRunningActions]);

	// Create many copies (invadersPerHalfSide * 2) ^ 2,
	// and space them out throughout the area of the ground plane, in a grid pattern.
	int invadersPerHalfSide = 5;
	GLfloat spacing = 1000.0f / invadersPerHalfSide;
	for (int ix = -invadersPerHalfSide; ix <= invadersPerHalfSide; ix++) {
		for (int iz = -invadersPerHalfSide; iz <= invadersPerHalfSide; iz++) {
			GLfloat xLoc = spacing * ix;
			GLfloat zLoc = spacing * iz;

			// Don't drop invaders into the central area where the main robot is.
			if (fabsf(xLoc) > 100.0f || fabsf(zLoc) > 100.0f) {
				CC3Node* invader = [templateNode copyAutoreleased];
				invader.location = cc3v(xLoc, kDropHeight, zLoc);

				// If the invader has an animation, run its animation, otherwise rotate
				// it horizontally. In either case, the rate of motion is randomized so
				// that each invader moves at its own speed.
				CCActionInterval* invaderAction;
				if (invader.containsAnimation) {
					invaderAction = [CC3Animate actionWithDuration: RandomFloatBetween(2.5, 10.0)];
				} else {
					invaderAction = [CC3RotateBy actionWithDuration: 1.0
														   rotateBy: cc3v(0.0, RandomFloatBetween(30.0, 90.0), 0.0)];
				}
				CCActionInterval* groundAction = [CCRepeat actionWithAction: invaderAction times: UINT_MAX];

				// Create a landing action that is a bouncing drop of random duration, to simulate raining down.
				CC3Vector landingLocation = cc3v(invader.location.x, 0.0, invader.location.z);
				CCActionInterval* landingAction = [CCEaseBounceOut actionWithAction:
													[CC3MoveTo actionWithDuration: RandomFloatBetween(1.0, 2.0) 
																		   moveTo: landingLocation]];

				// Set up a sequence on the invader...first drop, and then animate or rotate
				[invader runAction: [CCSequence actionOne: landingAction two: groundAction]];
				[invader runAction: landingAction];

				[self addChild: invader];		// Add the child to the landing craft
			}
		}
	}
	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
	
	// To help demonstrate that the hordes of actioned nodes that make up this army are being managed
	// correctly, log the current number of nodes and actions, now that the army has been created.
	LogInfo(@"After populating %@ there are %i instances of CC3Identifiable subclasses in existance, and  %u actions running.",
			self, [CC3Identifiable instanceCount], [[CCActionManager sharedManager] numberOfRunningActions]);
}

/**
 * Uses a CCSequence action to first fade the army away,
 * and then invokes the cleanUp callback to remove the invaders.
 */
-(void) evaporate {
	CCActionInterval* fadeOut = [CCFadeOut actionWithDuration: 1.0];
	CCActionInstant* cleanUp = [CCCallFunc actionWithTarget: self selector: @selector(cleanUp)];
	[self runAction: [CCSequence actionOne: fadeOut two: cleanUp]];
}

/** Callback to actually remove the army. Stop all actions, then remove this instance from the world. */
-(void) cleanUp {
	[self stopAllActions];
	for (CC3Node* child in children) {
		[child stopAllActions];
	}
	[super remove];
}

@end


@implementation CCActionManager (LandingCraft)

-(uint) numberOfRunningActions {
	uint total = 0;
	for(tHashElement *element=targets; element != NULL; ) {	
		id target = element->target;
		element = element->hh.next;
		total += [self numberOfRunningActionsInTarget:target];
	}
	return total;
}

@end

