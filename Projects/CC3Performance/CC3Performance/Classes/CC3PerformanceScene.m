/*
 * CC3PerformanceScene.m
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
 * See header file CC3PerformanceScene.h for full API documentation.
 */

#import "CC3PerformanceScene.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3ModelSampleFactory.h"
#import "CGPointExtension.h"
#import "CC3PODResourceNode.h"
#import "CC3UIViewController.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3Actions.h"

// Model names
#define kNodeGridName			@"NodeGrid"
#define kHelloWorldName			@"Hello"
#define kBeachBallName			@"BeachBall"
#define kGlobeName				@"Globe"
#define kDieCubeName			@"Cube"
#define kMascotName				@"cocos2d_3dmodel_unsubdivided"

// File names
#define kLogoFileName			@"Default.png"
#define kHelloWorldFileName		@"hello-world.pod"
#define kBeachBallFileName		@"BeachBall.pod"
#define kGlobeTextureFile		@"Earth_1024.jpg"
#define kMascotPODFile			@"cocos3dMascot.pod"
#define kDieCubePODFile			@"DieCube.pod"


@implementation CC3PerformanceScene

@synthesize availableTemplateNodes=_availableTemplateNodes, templateNode=_templateNode;
@synthesize perSideCount=_perSideCount, shouldAnimateNodes=_shouldAnimateNodes;
@synthesize playerDirectionControl=_playerDirectionControl;
@synthesize playerLocationControl=_playerLocationControl;

-(void) dealloc {
	[_templateNode release];
	[_availableTemplateNodes release];
	_nodeGrid = nil;				// Not retained.
	
	[super dealloc];
}

/**
 * When the template node is changed, layout the
 * grid with copies of the new template node.
 */
-(void) setTemplateNode:(CC3Node *) aNode {
	id oldNode = _templateNode;
	_templateNode = [aNode retain];
	[oldNode release];
	[self layoutGrid];
}

/**
 * When the quantity of nodes is changed, layout the grid
 * with the new number of copies of the template node.
 */
-(void) setPerSideCount: (uint) aCount {
	_perSideCount = aCount;
	[self layoutGrid];
}

/** When animation is turned on or off, if the node has animation, turn it on or off as well. */
-(void) setShouldAnimateNodes: (BOOL) shouldAnimateNodes {
	if (_shouldAnimateNodes == shouldAnimateNodes) return;
	_shouldAnimateNodes = shouldAnimateNodes;
	[self animationWasChanged];
}

/**
 * Constructs the 3D scene.
 *
 * Adds a camera and light source, and a NodeGrid instance, which is used to
 * populate the scene with copies of the template node that the user selects.
 *
 * This method also creates an array of available template nodes of different model
 * types. The nodes in this array are not added to the scene directly. Instead,
 * they are used as templates for creating copies. Once the user selects a model
 * type, the NodeGrid is populated with copies of the selected template node.
 */
-(void) initializeScene {
	
	// Improve performance by avoiding clearing the depth buffer when transitioning
	// between 2D content and 3D content.
	self.shouldClearDepthBuffer = NO;
	
	// There are no translucent nodes that need to be reordered.
	self.drawingSequencer = [CC3NodeArraySequencer sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	self.drawingSequencer.allowSequenceUpdates = NO;

	_shouldAnimateNodes = NO;	// Start with static nodes.

	// Create the camera, place it back a bit, and add it to the scene
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 100.0, 200.0 );
	cam.targetLocation = kCC3VectorZero;
	[self addChild: cam];

	// Create a light and attach it to the camera, but off to the left.
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -20.0, 0.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];
	
	// Create the node grid and add it to the scene.
	_nodeGrid = [NodeGrid nodeWithName: kNodeGridName];
	[self addChild: _nodeGrid];
	
	// Populate the array of available templates.
	_availableTemplateNodes = [[NSMutableArray array] retain];
	CC3Node* aNode;
	CC3MeshNode* meshNode;
	CC3LineNode* lineNode;
	CC3ResourceNode* rezNode;
	
	// Make a simple plane template available. Only 2 faces per node.
	CC3PlaneNode* planeNode = [CC3PlaneNode nodeWithName: @"Simple plane"];
	[planeNode populateAsCenteredRectangleWithSize: CGSizeMake(30.0, 30.0)];
	planeNode.texture = [CC3Texture textureFromFile: kLogoFileName];
	[self configureAndAddTemplate: planeNode];
	
	// Make a simple box template available. Only 6 faces per node.
	CC3BoxNode* boxNode = [CC3BoxNode nodeWithName: @"Simple box"];
	CC3Box box = CC3BoxFromMinMax(cc3v(-10.0, -10.0, -10.0), cc3v( 10.0,  10.0,  10.0));
	[boxNode populateAsSolidBox: box];
	boxNode.color = ccORANGE;
	[self configureAndAddTemplate: boxNode];

	// Make a circular ring out of lines
	#define kRingLineCount 36
	CC3Vector ringVertices[kRingLineCount + 1];
	for (int i = 0; i < kRingLineCount; i++) {
		GLfloat ra = (GLfloat)i * kCC3TwoPi / kRingLineCount;
		GLfloat rx = cosf(ra);
		GLfloat ry = sinf(ra);
		ringVertices[i] = cc3v(rx, ry, 0.0);
	}
	ringVertices[kRingLineCount] = ringVertices[0];		// Join up to the start
	lineNode = [CC3LineNode nodeWithName: @"Ring of lines"];
	[lineNode populateAsLineStripWith: (kRingLineCount + 1)
							 vertices: ringVertices
							andRetain: YES];
	lineNode.color = ccGREEN;
	lineNode.lineWidth = 2.0;
	lineNode.uniformScale = 10.0;
	[self configureAndAddTemplate: lineNode];
	
	// Mascot model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromFile: kMascotPODFile
			  expectsVerticallyFlippedTextures: YES];
	aNode = [rezNode getNodeNamed: kMascotName];
	aNode.name = @"Complex textured mesh with high face-count";
	aNode.rotation = cc3v(0.0, -90.0, 0.0);
	aNode.uniformScale = 5.0;
	[self configureAndAddTemplate: aNode];
	
	// Die cube model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromFile: kDieCubePODFile];
	aNode = [rezNode getNodeNamed: kDieCubeName];
	aNode.name = @"Untextured mesh with very high face-count";
	aNode.uniformScale = 10.0;
	[self configureAndAddTemplate: aNode];
	
	// Globe with texture
	meshNode = [CC3MeshNode nodeWithName: kGlobeName];
	[meshNode populateAsSphereWithRadius: 1.0f andTessellation: CC3TessellationMake(32, 32)];
	meshNode.texture = [CC3Texture textureFromFile: kGlobeTextureFile];
	meshNode.name = @"Textured sphere with high face-count";
	meshNode.rotation = cc3v(0.0, -90.0, 0.0);	// starting rotation
	meshNode.uniformScale = 15.0;
	[self configureAndAddTemplate: meshNode];
	
	// Beachball with no texture, but with several subnodes
	rezNode = [CC3PODResourceNode nodeFromFile: kBeachBallFileName];
	aNode = [rezNode getNodeNamed: kBeachBallName];
	aNode.name = @"Opaque ball containing 4 subnodes";
	aNode.uniformScale = 15.0;
	aNode.isOpaque = YES;
	[self configureAndAddTemplate: aNode];

	// Translucent beachball
	aNode = [aNode copy];
	aNode.name = @"Translucent ball containing 4 subnodes";
	aNode.isOpaque = NO;
	[self configureAndAddTemplate: aNode];
	
	// Make a blue teapot template available.
	aNode = [[CC3ModelSampleFactory factory] makeUniColoredTeapotNamed: @"Single-color teapot" withColor: kCCC4FBlue];
	aNode.uniformScale = 100.0;
	[self configureAndAddTemplate: aNode];
	
	// Make a multicolored teapot template available.
	aNode = [[CC3ModelSampleFactory factory] makeMultiColoredTeapotNamed: @"Vertex-colored teapot"];
	aNode.uniformScale = 100.0;
	[self configureAndAddTemplate: aNode];
	
	// Make a textured teapot template available.
	meshNode = [CC3ModelSampleFactory.factory makeTexturableTeapotNamed: @"Textured teapot"];
	meshNode.texture = [CC3Texture textureFromFile: kLogoFileName];
	meshNode.uniformScale = 100.0;
	[self configureAndAddTemplate: meshNode];

	// Make a model template with a large number of faces available.
	rezNode = [CC3PODResourceNode nodeFromFile: kHelloWorldFileName];
	aNode = [rezNode getNodeNamed: kHelloWorldName];
	aNode.name = @"Mesh with high face count";
	aNode.uniformScale = 12.0;
	[self configureAndAddTemplate: aNode];
	
	// Animated dragon from POD resource
	// The model animation that was loaded from the POD into track zero is a concatenation of
	// several separate movements, such as gliding and flapping. Extract the distinct movements
	// from the base animation and add those distinct movement animations as separate tracks.
	rezNode = [CC3PODResourceNode nodeFromFile: @"Dragon.pod"];
	aNode = [rezNode getNodeNamed: @"Dragon.pod-SoftBody"];
	aNode.name = @"Skinned mesh with many animated bones.";
	aNode.uniformScale = 0.5;
	_flapTrack = [aNode addAnimationFromFrame: 61 toFrame: 108];
	[self configureAndAddTemplate: aNode];
	
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
	
	// Start with one copy of the first available template node.
	_templateIndex = 0;
	self.templateNode = (CC3Node*)[_availableTemplateNodes objectAtIndex: _templateIndex];
	self.perSideCount = 1;
}

/**
 * Provides standard configuration for the specified template model,
 * and add it to the list of templates.
 */
-(void) configureAndAddTemplate: (CC3Node*) templateNode {
	[templateNode createGLBuffers];
	[templateNode releaseRedundantContent];
	[templateNode selectShaderPrograms];
	[_availableTemplateNodes addObject: templateNode];
}


#pragma mark Updating

-(void) animationWasChanged {
	if ( !_templateNode.containsAnimation) return;

	if (_shouldAnimateNodes) {
		CC3Animate* flap = [CC3Animate actionWithDuration: 1.5 onTrack: _flapTrack];
		[self runAction: [CCRepeatForever actionWithAction: flap]];
	} else {
		[self stopAllActions];
	}
}

/** 
 * Called periodically as part of the CCLayer scheduled update mechanism.
 * This is where model objects are updated.
 *
 * For this scene, the camera direction and location are updated
 * under control of the user interface.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateCameraFromControls: visitor.deltaTime];
}


/** Update the location and direction of looking of the 3D camera */
-(void) updateCameraFromControls: (ccTime) dt {
	
	CC3Camera* cam = self.activeCamera;
	
	// Update the location of the player (the camera)
	if ( _playerLocationControl.x || _playerLocationControl.y ) {
		// Get the X-Y delta value of the control and scale it to something suitable
		CGPoint delta = ccpMult(_playerLocationControl, dt * 100.0);
		
		// We want to move the camera up and down and side to side. Up will always be
		// scene up (typically Y-axis), and side to side will be a line in the X-Z plane
		// along the "right" vector of the camera. Since the scene up is orthogonal to
		// the X-Z plane, for convenience, combine these two axes (scene up and camera right)
		// into a single control vector by simply adding them. You could also run these
		// calculations independently instead of combining into one vector.
		CC3Vector controlVector = CC3VectorAdd(cam.rightDirection, _activeCamera.referenceUpDirection);
		
		// Scale the control vector by the control delta, using the X-component of the control
		// delta value for both the X and Z axes of the camera's right vector. This represents
		// the movement of the camera. The new location is simply the old location plus the movement.
		cam.location = CC3VectorAdd(cam.location, CC3VectorScale(controlVector,
																 cc3v(delta.x, delta.y, delta.x)));
	}
	
	// Update the direction the camera is pointing by panning and inclining.
	if ( _playerDirectionControl.x || _playerDirectionControl.y ) {
		CGPoint delta = ccpMult(_playerDirectionControl, dt * 30.0);		// Factor to set speed of rotation.
		CC3Vector camRot = cam.rotation;
		camRot.y -= delta.x;
		camRot.x += delta.y;
		cam.rotation = camRot;
	}
}

/** Layout (perSideCount * perSideCount) copies of the templateNode into a grid. */
-(void) layoutGrid { [_nodeGrid populateWith: self.templateNode perSide: self.perSideCount]; }

-(void) increaseNodes { self.perSideCount++; }

-(void) decreaseNodes { self.perSideCount = MAX(self.perSideCount - 1, 1); }

-(void) nextNodeType {
	_templateIndex++;
	if (_templateIndex >= _availableTemplateNodes.count) _templateIndex = 0;
	self.templateNode = [_availableTemplateNodes objectAtIndex: _templateIndex];
}

-(void) prevNodeType {
	_templateIndex--;
	if (_templateIndex < 0) _templateIndex = _availableTemplateNodes.count - 1;
	self.templateNode = [_availableTemplateNodes objectAtIndex: _templateIndex];
}

/**
 * Choose the update visitor class to use based on whether the nodes should be animated
 * to force the transform matrices of each node to be recalculated on each update.
 *
 * If the nodes should be animated, use a CC3AnimatingVisitor instance, otherwise use
 * a normal CC3NodeUpdatingVisitor instance.
 */
-(id) updateVisitorClass { return [CC3AnimatingVisitor class]; }

@end


#pragma mark -
#pragma mark CC3AnimatingVisitor

@interface CC3NodeVisitor (TemplateMethods)
-(void) processBeforeChildren: (CC3Node*) aNode;
@end

@implementation CC3AnimatingVisitor

/**
 * Returns whether the specified node is a copy of the template by checking if it has
 * the same name. For speed, the names are tested for identity, rather than content.
 */
-(BOOL) nodeIsFromTemplate: (CC3Node*) aNode {
	return (aNode.name == ((CC3PerformanceScene*)self.startingNode).templateNode.name);
}

/** Returns whether the nodes should be animated. */
-(BOOL) shouldAnimateNodes { return ((CC3PerformanceScene*)self.startingNode).shouldAnimateNodes; }

/**
 * If the node is one of the copies of the template node, rotate it a bit.
 * The rotation direction and magnitude is derived from the node's unique tag,
 * so that each template copy rotates a little differently than any of the others.
 */
-(void) processBeforeChildren: (CC3Node*) aNode {
	if (self.shouldAnimateNodes && [self nodeIsFromTemplate: aNode] && !aNode.containsAnimation ) {
		ccTime dt = self.deltaTime;
		GLfloat direction = SIGN((GLfloat)(aNode.tag % 2) - 0.5);
		GLfloat magnitude = (GLfloat)(aNode.tag % 8) + 4;
		CC3Vector deltaRot = cc3v(direction * magnitude * 5.0 * dt,
								  direction * magnitude * 7.0 * dt,
								  0.0);
		aNode.rotation = CC3VectorAdd(aNode.rotation, deltaRot);
	}
	[super processBeforeChildren: aNode];
}

@end

