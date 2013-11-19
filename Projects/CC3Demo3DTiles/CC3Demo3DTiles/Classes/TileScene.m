/*
 * TileScene.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3Actions.h"
#import "CC3UtilityMeshNodes.h"
#import "CCTouchDispatcher.h"
#import "CGPointExtension.h"

#define kTileLightIndex		0
#define kLampName			@"Lamp"

@interface TileScene (TemplateMethods)
-(ccColor3B) pickNodeColor;
-(void) rotateMainNodeFromSwipeAt: (CGPoint) touchPoint;
@end

@implementation TileScene

/** Constructs the 3D scene with a camera and light source, and a single mesh node. */
-(void) initializeScene {

	// Improve performance by avoiding clearing the depth buffer when transitioning
	// between 2D content and 3D content.
	self.shouldClearDepthBuffer = NO;

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

-(CC3Node*) mainNode { return _mainNode; }

-(void) setMainNode: (CC3Node*) aNode {
	[_mainNode remove];		// remove any existing as child node
	_mainNode = aNode;
	[self addChild: aNode];
}

/** When the scene opens up, move the camera to frame the main node of the scene. */
-(void) onOpen { [self.activeCamera moveToShowAllOf: _mainNode withPadding: 0.1]; }


#pragma mark Touch events

/**
 * Handle touch events in the scene:
 *   - Touch-move events are used to rotate the main node based on how the finger is moving.
 *   - Touch-up events are used to give visual feedback via a tint-up-and-down.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
	switch (touchType) {
		case kCCTouchBegan:
			break;
		case kCCTouchMoved:
			[self rotateMainNodeFromSwipeAt: touchPoint];
			break;
		case kCCTouchEnded:
			[self flashMainNodeAt: touchPoint];
			break;
		default:
			break;
	}
	
	// For all event types, remember where the touchpoint was, for subsequent events.
	_lastTouchEventPoint = touchPoint;
}


/** Set this parameter to adjust the rate of rotation from the length of touch-move swipe. */
#define kSwipeScale 0.6

/**
 * Rotates the main node, by determining the direction of each touch move event.
 *
 * The touch-move swipe is measured in 2D screen coordinates, which are mapped to
 * 3D coordinates by recognizing that the screen's X-coordinate maps to the camera's
 * rightDirection vector, and the screen's Y-coordinates maps to the camera's upDirection.
 *
 * The node rotates around an axis perpendicular to the swipe. The rotation angle is
 * determined by the length of the touch-move swipe.
 */
-(void) rotateMainNodeFromSwipeAt: (CGPoint) touchPoint {
	
	CC3Camera* cam = self.activeCamera;
	
	// Get the direction and length of the movement since the last touch move event,
	// in 2D screen coordinates. The 2D rotation axis is perpendicular to this movement.
	CGPoint swipe2d = ccpSub(touchPoint, _lastTouchEventPoint);
	CGPoint axis2d = ccpPerp(swipe2d);
	
	// Project the 2D axis into a 3D axis by mapping the 2D X & Y screen coords
	// to the camera's rightDirection and upDirection, respectively.
	CC3Vector axis = CC3VectorAdd(CC3VectorScaleUniform(cam.rightDirection, axis2d.x),
								  CC3VectorScaleUniform(cam.upDirection, axis2d.y));
	GLfloat angle = ccpLength(swipe2d) * kSwipeScale;
	
	// Rotate the node under direct finger control, by directly rotating by the angle
	// and axis determined by the swipe.
	[_mainNode rotateByAngle: angle aroundAxis: axis];
}

/** For dramatic effect, tint the node up and down when the user lets go. */
-(void) flashMainNodeAt: (CGPoint) touchPoint {
	CCActionInterval* tintUp = [CC3TintEmissionTo actionWithDuration: 0.2f colorTo: kCCC4FCyan];
	CCActionInterval* tintDown = [CC3TintEmissionTo actionWithDuration: 0.5f colorTo: kCCC4FBlack];
	[_mainNode runAction: [CCSequence actionOne: tintUp two: tintDown]];
}

@end


@implementation CC3Node (TilesUserData)

-(void) initUserData { self.userData = [NSNumber numberWithBool: NO]; }

-(BOOL) shouldColorTile { return ((NSNumber*)self.userData).boolValue; }

-(void) setShouldColorTile: (BOOL) shouldColor { self.userData = [NSNumber numberWithBool: shouldColor]; }

-(void) copyUserDataFrom:(CC3Node *)another {
	self.shouldColorTile = another.shouldColorTile;
}

@end


