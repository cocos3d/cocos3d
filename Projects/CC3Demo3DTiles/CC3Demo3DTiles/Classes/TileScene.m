/*
 * TileScene.m
 *
 * Cocos3D 2.0.2
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
 * See header file TileScene.h for full API documentation.
 */

#import "TileScene.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3Actions.h"
#import "CC3PODResourceNode.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3VertexSkinning.h"
#import "CGPointExtension.h"

// Model names
#define kBoxName				@"Box"
#define kBeachBallName			@"BeachBall"
#define kDieCubeName			@"Cube"
#define kMascotName				@"cocos2d_3dmodel_unsubdivided"

// File names
#define kBeachBallFileName		@"BeachBall.pod"
#define kMascotPODFile			@"cocos3dMascot.pod"
#define kDieCubePODFile			@"DieCube.pod"

#define kTileLightIndex			0
#define kLampName				@"Lamp"

#define kGlideAnimationTrack	1
#define kFlapAnimationTrack		2


@implementation TileScene

/** Constructs the 3D scene with a camera and light source, and a single mesh node. */
-(void) initializeScene {

	// Improve performance by avoiding clearing the depth buffer when transitioning
	// between 2D content and 3D content.
	self.shouldClearDepthBuffer = NO;

	// There are no translucent nodes that need to be reordered.
	self.drawingSequencer = [CC3NodeArraySequencer sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	self.drawingSequencer.allowSequenceUpdates = NO;

	// Add a standard backdrop
	self.backdrop = [CC3Backdrop nodeWithColor: ccc4f(0.2, 0.24, 0.43, 1.0)];

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
	
	// Select the main node for the scene
	[self selectMainNode];
}


#pragma mark Main node

-(CC3Node*) mainNode { return _mainNode; }

-(void) setMainNode: (CC3Node*) aNode {
	[_mainNode remove];		// remove any existing as child node
	_mainNode = aNode;
	[self addChild: aNode];
}

/** Selects the main node from the collection of templates. */
-(void) selectMainNode {
	// Choose either to display a random model in each tile, or the same model
	// in each tile by uncommenting one of these lines and commenting out the other.
	CC3Node* aNode = [[self.nodeTemplates objectAtIndex: CC3RandomUIntBelow(self.nodeTemplates.count)] copy];
//	CC3Node* aNode = [[self.nodeTemplates objectAtIndex: 0] copy];	// Choose any index below template count

	// The shouldColorTile property is actually tracked by the userData property!
	if (aNode.shouldColorTile) aNode.color = self.randomColor;

	// If the node is animated, initiate a CC3ActionAnimate action on it
	if (aNode.containsAnimation) {

		// The dragon model now contains three animation tracks: a gliding track, a flapping
		// track, and the original concatenation of animation loaded from the POD file into
		// track zero. We want the dragon flying and flapping its wings. So, we give the flapping
		// track a weight of one, and the gliding and original tracks a weighting of zero.
		[aNode setAnimationBlendingWeight: 0.0f onTrack: 0];
		[aNode setAnimationBlendingWeight: 0.0f onTrack: kGlideAnimationTrack];
		[aNode setAnimationBlendingWeight: 1.0f onTrack: kFlapAnimationTrack];

		// Create the CC3ActionAnimate action to run the animation. The duration is randomized so
		// that when multiple dragons are visible, they are not all flapping in unison.
		CCTime flapTime = CC3RandomFloatBetween(1.0, 2.0);
		[aNode runAction: [[CC3ActionAnimate actionWithDuration: flapTime onTrack: kFlapAnimationTrack] repeatForever]];
	}

	self.mainNode = aNode;		// Set the node as the main node of this scene, for easy access
}

/** Returns a random color. */
-(CCColorRef) randomColor {
	switch (CC3RandomUIntBelow(6)) {
		case 0:
			return CCColorRefFromCCC4F(kCCC4FRed);
		case 1:
			return CCColorRefFromCCC4F(kCCC4FGreen);
		case 2:
			return CCColorRefFromCCC4F(kCCC4FBlue);
		case 3:
			return CCColorRefFromCCC4F(kCCC4FYellow);
		case 4:
			return CCColorRefFromCCC4F(kCCC4FOrange);
		case 5:
		default:
			return CCColorRefFromCCC4F(kCCC4FWhite);
	}
}

/** When the scene opens up, move the camera to frame the main node of the scene. */
-(void) onOpen { [self.activeCamera moveToShowAllOf: _mainNode withPadding: 0.1]; }


#pragma mark Node Templates

/** Array of templates, used by all instances. */
static NSMutableArray* _nodeTemplates = nil;

/**
 * Returns an array of template nodes. The array is lazily created and populated the first
 * time this method is invoked, which must originate from within the initializeScene method
 * to ensure that any GL activity is bracketed by the appropriate GL init and cleanup actions.
 */
-(NSArray*) nodeTemplates {
	if (!_nodeTemplates) {
		_nodeTemplates = [NSMutableArray array];
		[self initializeTemplates];
	}
	return _nodeTemplates;
}

/** 
 * Initialize the node templates. This must be invoked from within the TileScene initializeScene
 * method to ensure that any GL activity is bracketed by the appropriate GL init and cleanup actions.
 */
-(void) initializeTemplates {
	CC3Node* n;
	CC3MeshNode* mn;
	CC3ResourceNode* rezNode;
	
	// Make a simple box template available. Only 6 faces per node.
	mn = [CC3BoxNode nodeWithName: kBoxName];
	[mn populateAsSolidBox: CC3BoxFromMinMax(cc3v(-1.0, -1.0, -1.0), cc3v( 1.0,  1.0,  1.0))];
	mn.shouldColorTile = YES;
	[self configureAndAddTemplate: mn];
	
	// Mascot model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromFile: kMascotPODFile
			  expectsVerticallyFlippedTextures: YES];
	mn = [rezNode getMeshNodeNamed: kMascotName];
	[mn moveMeshOriginToCenterOfGeometry];
	mn.rotation = cc3v(0.0, -90.0, 0.0);
	[self configureAndAddTemplate: mn];
	
	// Die cube model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromFile: kDieCubePODFile];
	n = [rezNode getNodeNamed: kDieCubeName];
	[self configureAndAddTemplate: n];
	
	// Beachball from POD resource with no texture, but with several subnodes
	rezNode = [CC3PODResourceNode nodeFromFile: kBeachBallFileName];
	n = [rezNode getNodeNamed: kBeachBallName];
	n.isOpaque = YES;
	[self configureAndAddTemplate: n];
	
	// Animated dragon from POD resource
	// The model animation that was loaded from the POD into track zero is a concatenation of
	// several separate movements, such as gliding and flapping. Extract the distinct movements
	// from the base animation and add those distinct movement animations as separate tracks.
	rezNode = [CC3PODResourceNode nodeFromFile: @"Dragon.pod"];
	n = [rezNode getNodeNamed: @"Dragon.pod-SoftBody"];
	[n addAnimationFromFrame: 0 toFrame: 60 asTrack: kGlideAnimationTrack];
	[n addAnimationFromFrame: 61 toFrame: 108 asTrack: kFlapAnimationTrack];
	
	[n ensureRigidSkeleton];	// Dragon skeleton contains no scale, so animate as a rigid skeleton.
	
#if !CC3_GLSL
	// The fixed pipeline of OpenGL ES 1.1 cannot make use of the tangent-space normal
	// mapping texture that is applied to the dragon, and the result is that the dragon
	// looks black. Extract the diffuse texture (from texture unit 1), remove all texture,
	// and set the diffuse texture as the only texture (in texture unit 0).
	CC3MeshNode* dgnBody = [rezNode getMeshNodeNamed: @"Dragon"];
	CC3Material* dgnMat = dgnBody.material;
	CC3Texture* dgnTex = [dgnMat textureForTextureUnit: 1];
	[dgnMat removeAllTextures];
	dgnMat.texture = dgnTex;
#endif
	
	[self configureAndAddTemplate: n];
}

/**
 * Provides standard configuration for the specified template model,
 * and add it to the list of templates.
 */
-(void) configureAndAddTemplate: (CC3Node*) templateNode {
	templateNode.touchEnabled = YES;
	[templateNode selectShaders];
	[templateNode createGLBuffers];
	[templateNode releaseRedundantContent];
	[_nodeTemplates addObject: templateNode];
}


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
	CCActionInterval* tintUp = [CC3ActionTintEmissionTo actionWithDuration: 0.2f colorTo: kCCC4FCyan];
	CCActionInterval* tintDown = [CC3ActionTintEmissionTo actionWithDuration: 0.5f colorTo: kCCC4FBlack];
	[_mainNode runAction: [CCActionSequence actionOne: tintUp two: tintDown]];
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


