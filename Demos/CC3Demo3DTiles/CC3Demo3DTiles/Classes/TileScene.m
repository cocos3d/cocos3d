/*
 * TileScene.m
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
 * See header file TileScene.h for full API documentation.
 */

#import "TileScene.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3ActionInterval.h"
#import "CC3OpenGLES11Engine.h"
#import "CCTouchDispatcher.h"
#import "CGPointExtension.h"

#define kTileLightIndex		0
#define kLampName			@"Lamp"

@interface TileScene (TemplateMethods)
-(ccColor3B) pickNodeColor;
-(void) rotateMainNodeFromSwipeAt: (CGPoint) touchPoint;
@end

@implementation TileScene

-(void) dealloc {
	mainNode = nil;			// retained as child
	[super dealloc];
}

/** Constructs the 3D scene with a camera and light source, and a single mesh node. */
-(void) initializeScene {

	// Improve performance by avoiding clearing the depth buffer when transitioning
	// between 2D content and 3D content.
	self.shouldClearDepthBufferBefore2D = NO;
	self.shouldClearDepthBufferBefore3D = NO;

	// There are no translucent nodes that need to be reordered.
	self.drawingSequencer = [CC3NodeArraySequencer sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	self.drawingSequencer.allowSequenceUpdates = NO;
							 
	// Create the camera, place it back a bit, and add it to the scene
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.0, 1.0 );
	[self addChild: cam];

	// Create a light and attach it to the camera. Since we are creating many lights
	// across many scenes, we'll force all lights across all scenes to use the same
	// GL light index, to avoid running out of OpenGL lights.
	// The shouldCopyLightIndex property is useful if we will be copying the light
	// (which we do not do here...but it's included for demonstration purposes).
	CC3Light* lamp = [CC3Light lightWithName: kLampName withLightIndex: kTileLightIndex];
	lamp.shouldCopyLightIndex = YES;
	
	// Move the lamp to a random location to one side or the other of the camera (as
	// if it were attached to a boom on the camera, of random length off to one side).
	lamp.location = cc3v( CC3RandomFloatBetween(-5.0, 5.0), 0.0, 0.0 );
	
	[cam addChild: lamp];

	// Turn off ambient lighting so that when the lamp is removed,
	// lighting will be completely disabled.
	self.ambientLight = kCCC4FBlackTransparent;
}

-(CC3Node*) mainNode { return mainNode; }

-(void) setMainNode: (CC3Node*) aNode {
	[mainNode remove];		// remove any existing as child node
	mainNode = aNode;
	[self addChild: aNode];
}

/** When the scene opens up, move the camera to frame the main node of the scene. */
-(void) onOpen { [self.activeCamera moveToShowAllOf: mainNode withPadding: 0.1]; }


#pragma mark Touch events

/**
 * Handle touch events in the scene:
 *   - Touch-down events are used to select nodes. Forward these to the touched node picker.
 *   - Touch-move events are used to generate a swipe gesture to rotate the die cube
 *   - Touch-up events are used to mark the die cube as freewheeling if the touch-up event
 *     occurred while the finger is moving.
 * This is a poor UI. We really should be using the touch-stationary event to mark definitively
 * whether the finger stopped before being lifted. But we're just working with what we have handy.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
	switch (touchType) {
		case kCCTouchBegan:
			break;
		case kCCTouchMoved:
			[self rotateMainNodeFromSwipeAt: touchPoint];
			break;
		case kCCTouchEnded:
			[self pickNodeFromTouchEvent: touchType at: touchPoint];
			break;
		default:
			break;
	}
	
	// For all event types, remember where the touchpoint was, for subsequent events.
	lastTouchEventPoint = touchPoint;
}


/** Set this parameter to adjust the rate of rotation from the length of touch-move swipe. */
#define kSwipeScale 0.6

/**
 * Rotates the die cube, by determining the direction of each touch move event.
 *
 * The touch-move swipe is measured in 2D screen coordinates, which are mapped to
 * 3D coordinates by recognizing that the screen's X-coordinate maps to the camera's
 * rightDirection vector, and the screen's Y-coordinates maps to the camera's upDirection.
 *
 * The cube rotates around an axis perpendicular to the swipe. The rotation angle is
 * determined by the length of the touch-move swipe.
 *
 * To allow freewheeling after the finger is lifted, we set the spin speed and spin axis
 * in the die cube. We indicate for now that the cube is not freewheeling.
 */
-(void) rotateMainNodeFromSwipeAt: (CGPoint) touchPoint {
	
	CC3Camera* cam = self.activeCamera;
	
	// Get the direction and length of the movement since the last touch move event, in
	// 2D screen coordinates. The 2D rotation axis is perpendicular to this movement.
	CGPoint swipe2d = ccpSub(touchPoint, lastTouchEventPoint);
	CGPoint axis2d = ccpPerp(swipe2d);
	
	// Project the 2D axis into a 3D axis by mapping the 2D X & Y screen coords
	// to the camera's rightDirection and upDirection, respectively.
	CC3Vector axis = CC3VectorAdd(CC3VectorScaleUniform(cam.rightDirection, axis2d.x),
								  CC3VectorScaleUniform(cam.upDirection, axis2d.y));
	GLfloat angle = ccpLength(swipe2d) * kSwipeScale;
	
	// Rotate the cube under direct finger control, by directly rotating by the angle
	// and axis determined by the swipe. If the die cube is just to be directly controlled
	// by finger movement, and is not to freewheel, this is all we have to do.
	[mainNode rotateByAngle: angle aroundAxis: axis];
}

// Tint the node to cyan and back again to provide user feedback to touch
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
	LogInfo(@"You selected %@ at %@, or %@ in 2D.", aNode,
				 NSStringFromCC3Vector(aNode ? aNode.globalLocation : kCC3VectorZero),
				 NSStringFromCC3Vector(aNode ? [activeCamera projectNode: aNode] : kCC3VectorZero));
	CCActionInterval* tintUp = [CC3TintEmissionTo actionWithDuration: 0.2f colorTo: kCCC4FCyan];
	CCActionInterval* tintDown = [CC3TintEmissionTo actionWithDuration: 0.5f colorTo: kCCC4FBlack];
	[aNode runAction: [CCSequence actionOne: tintUp two: tintDown]];
}

@end


/**
 * Demonstrates the initialization and disposal of application-specific userData by adding
 * custom extension categories to subclasses of CC3Identifiable (nodes, materials, meshes,
 * textures, etc).
 */
@implementation CC3Node (TilesUserData)

// Allocate memory to hold the user data, which in this case is a simple boolean.
-(void) initUserData {
	userData = calloc(1, sizeof(BOOL));
}

// Free the memory occupied by the userData.
-(void) releaseUserData {
	if (userData) { free(userData); }
}

// Copy the shouldColorTile property from the original instance.
// This property is held in memory tracked by the userData property.
-(void) copyUserDataFrom:(CC3Node *)another {
	self.shouldColorTile = another.shouldColorTile;
}

-(BOOL) shouldColorTile { return *((BOOL*)userData); }

-(void) setShouldColorTile: (BOOL) shouldColor { *((BOOL*)userData) = shouldColor; }

@end


