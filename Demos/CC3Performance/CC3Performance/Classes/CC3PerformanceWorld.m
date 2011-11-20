/*
 * CC3PerformanceWorld.m
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
 * See header file CC3PerformanceWorld.h for full API documentation.
 */

#import "CC3PerformanceWorld.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3ModelSampleFactory.h"
#import "CGPointExtension.h"
#import "CC3PODResourceNode.h"
#import "CC3OpenGLES11Engine.h"

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
#define kBallsFileName			@"Balls.pod"
#define kMascotPODFile			@"cocos3dMascot.pod"
#define kDieCubePODFile			@"DieCube.pod"


@class CC3AnimatingVisitor;

@interface CC3PerformanceWorld (TemplateMethods)
-(void) layoutGrid;
-(void) updateCameraFromControls: (ccTime) dt;
@end

@implementation CC3PerformanceWorld

@synthesize availableTemplateNodes, templateNode, perSideCount, shouldAnimateNodes;
@synthesize playerDirectionControl, playerLocationControl;

-(void) dealloc {
	[templateNode release];
	[availableTemplateNodes release];
	nodeGrid = nil;				// Not retained.
	
	[super dealloc];
}

/**
 * When the template node is changed, layout the
 * grid with copies of the new template node.
 */
-(void) setTemplateNode:(CC3Node *) aNode {
	id oldNode = templateNode;
	templateNode = [aNode retain];
	[oldNode release];
	[self layoutGrid];
}

/**
 * When the quantity of nodes is changed, layout the grid
 * with the new number of copies of the template node.
 */
-(void) setPerSideCount: (uint) aCount {
	perSideCount = aCount;
	[self layoutGrid];
}

/**
 * Constructs the 3D world.
 *
 * Adds a camera and light source, and a NodeGrid instance, which is used to
 * populate the world with copies of the template node that the user selects.
 *
 * This method also creates an array of available template nodes of different model
 * types. The nodes in this array are not added to the world directly. Instead,
 * they are used as templates for creating copies. Once the user selects a model
 * type, the NodeGrid is populated with copies of the selected template node.
 */
-(void) initializeWorld {
	
	// Improve performance by avoiding clearing the depth buffer when transitioning
	// between 2D content and 3D content. Since we are drawing 2D content on top of
	// the 3D content, we must also turn off depth testing when drawing 2D content.
	self.shouldClearDepthBufferBefore2D = NO;
	self.shouldClearDepthBufferBefore3D = NO;
	[[CCDirector sharedDirector] setDepthTest: NO];
	
	// There are no translucent nodes that need to be reordered.
	self.drawingSequencer = [CC3NodeArraySequencer sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	self.drawingSequencer.allowSequenceUpdates = NO;

	// To compare the performance cost of the GL drawing activity, uncomment the
	// following line. Uncommenting this line will cause the vertex array binding
	// and drawing calls to be skipped. The application will perform all updating
	// and drawing activities except the final vertex binding and drawing GL calls.
	// The application will perform all model updates, animation, matrix
	// transformations, culling, node sequencing, and other normal activities. 
	// In addition, many GL calls will still be made, including those for establishing
	// lighting, materials, and the loading of all projection and modelview matrices.
	// Only the final vertex array binding and drawing calls will not be made.
	// See the class and method notes of CC3OpenGLES11VertexArrays to better
	// understand exactly which GL calls will not be made.
//	[CC3OpenGLES11Engine engine].vertices = nil;

	shouldAnimateNodes = NO;	// Start with static nodes.

	// Create the camera, place it back a bit, and add it to the world
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 100.0, 200.0 );
	cam.targetLocation = kCC3VectorZero;
	[self addChild: cam];

	// Create a light and attach it to the camera, but off to the left.
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -20.0, 0.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];
	
	// Create the node grid and add it to the world.
	nodeGrid = [NodeGrid nodeWithName: kNodeGridName];
	[self addChild: nodeGrid];
	
	// Populate the array of available templates.
	availableTemplateNodes = [[NSMutableArray array] retain];
	CC3MeshNode* aNode;
	CC3ResourceNode* rezNode;
	
	// Make a simple plane template available. Only 2 faces per node.
	aNode = [CC3PlaneNode nodeWithName: @"Simple plane"];
	[aNode populateAsCenteredTexturedRectangleWithSize: CGSizeMake(30.0, 30.0)];
	aNode.texture = [CC3Texture textureFromFile: kLogoFileName];
	[aNode alignInvertedTextures];
	[availableTemplateNodes addObject: aNode];
	
	// Make a simple box template available. Only 6 faces per node.
	aNode = [CC3BoxNode nodeWithName: @"Simple box"];
	CC3BoundingBox bBox;
	bBox.minimum = cc3v(-10.0, -10.0, -10.0);
	bBox.maximum = cc3v( 10.0,  10.0,  10.0);
	[aNode populateAsSolidBox: bBox];
	aNode.material = [CC3Material material];
	aNode.color = ccORANGE;
	[availableTemplateNodes addObject: aNode];

	// Make a circular ring out of lines
	#define kRingLineCount 36
	CC3Vector ringVertices[kRingLineCount + 1];
	for (int i = 0; i < kRingLineCount; i++) {
		GLfloat ra = (GLfloat)i * (2 * M_PI) / kRingLineCount;
		GLfloat rx = cosf(ra);
		GLfloat ry = sinf(ra);
		ringVertices[i] = cc3v(rx, ry, 0.0);
	}
	ringVertices[kRingLineCount] = ringVertices[0];		// Join up to the start
	aNode = [CC3LineNode nodeWithName: @"Ring of lines"];
	[aNode populateAsLineStripWith: (kRingLineCount + 1)
						  vertices: ringVertices
						 andRetain: YES];
	aNode.color = ccGREEN;
	((CC3LineNode*)aNode).lineWidth = 2.0;
	aNode.uniformScale = 10.0;
	[availableTemplateNodes addObject: aNode];	
	
	// Mascot model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kMascotPODFile];
	aNode = (CC3MeshNode*)[rezNode getNodeNamed: kMascotName];
	[aNode remove];
	aNode.name = @"Complex textured mesh with high face-count";
	aNode.rotation = cc3v(0.0, -90.0, 0.0);
	aNode.uniformScale = 5.0;
	[availableTemplateNodes addObject: aNode];
	
	// Die cube model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kDieCubePODFile];
	aNode = (CC3MeshNode*)[rezNode getNodeNamed: kDieCubeName];
	[aNode remove];
	aNode.name = @"Untextured mesh with very high face-count";
	aNode.uniformScale = 10.0;
	[availableTemplateNodes addObject: aNode];
	
	// Ball models from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kBallsFileName];
	
	// Globe with texture
	aNode = (CC3MeshNode*)[rezNode getNodeNamed: kGlobeName];
	[aNode remove];
	aNode.name = @"Textured sphere with high face-count";
	aNode.rotation = cc3v(0.0, -90.0, 0.0);	// starting rotation
	aNode.uniformScale = 15.0;
	[availableTemplateNodes addObject: aNode];
	
	// Beachball with no texture, but with several subnodes
	aNode = (CC3MeshNode*)[rezNode getNodeNamed: kBeachBallName];
	[aNode remove];
	aNode.name = @"Opaque ball containing 4 subnodes";
	aNode.uniformScale = 15.0;
	aNode.isOpaque = YES;
	[availableTemplateNodes addObject: aNode];

	// Translucent beachball
	aNode = [aNode copy];
	aNode.name = @"Translucent ball containing 4 subnodes";
	aNode.isOpaque = NO;
	[availableTemplateNodes addObject: aNode];
	
	// Make a blue teapot template available.
	aNode = [[CC3ModelSampleFactory factory] makeUniColoredTeapotNamed: @"Single-color teapot" withColor: kCCC4FBlue];
	aNode.uniformScale = 100.0;
	[availableTemplateNodes addObject: aNode];
	
	// Make a multicolored teapot template available.
	aNode = [[CC3ModelSampleFactory factory] makeMultiColoredTeapotNamed: @"Vertex-colored teapot"];
	aNode.uniformScale = 100.0;
	[availableTemplateNodes addObject: aNode];
	
	// Make a textured teapot template available.
	aNode = [[CC3ModelSampleFactory factory] makeLogoTexturedTeapotNamed: @"Textured teapot"];
	aNode.uniformScale = 100.0;
	[availableTemplateNodes addObject: aNode];

	// Make a model template with a large number of faces available.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kHelloWorldFileName];
	aNode = (CC3MeshNode*)[rezNode getNodeNamed: kHelloWorldName];
	[aNode remove];
	aNode.name = @"Mesh with very high face count";
	aNode.uniformScale = 12.0;
	[availableTemplateNodes addObject: aNode];
	
	// Start with one copy of the first available template node.
	self.templateNode = (CC3Node*)[availableTemplateNodes objectAtIndex: 0];
	self.perSideCount = 1;
}

/** 
 * Called periodically as part of the CCLayer scheduled update mechanism.
 * This is where model objects are updated.
 *
 * For this world, the camera direction and location are updated
 * under control of the user interface.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateCameraFromControls: visitor.deltaTime];
}


/** Update the location and direction of looking of the 3D camera */
-(void) updateCameraFromControls: (ccTime) dt {
	
	// Update the location of the player (the camera)
	if ( playerLocationControl.x || playerLocationControl.y ) {
		// Get the X-Y delta value of the control and scale it to something suitable
		CGPoint delta = ccpMult(playerLocationControl, dt * 100.0);
		
		// We want to move the camera up and down and side to side. Up will always be
		// world up (typically Y-axis), and side to side will be a line in the X-Z plane
		// along the "right" vector of the camera. Since the world up is orthogonal to
		// the X-Z plane, for convenience, combine these two axes (world up and camera right)
		// into a single control vector by simply adding them. You could also run these
		// calculations independently instead of combining into one vector.
		CC3Vector controlVector = CC3VectorAdd(activeCamera.rightDirection, activeCamera.worldUpDirection);
		
		// Scale the control vector by the control delta, using the X-component of the control
		// delta value for both the X and Z axes of the camera's right vector. This represents
		// the movement of the camera. The new location is simply the old location plus the movement.
		activeCamera.location = CC3VectorAdd(activeCamera.location,
											 CC3VectorScale(controlVector,
															cc3v(delta.x, delta.y, delta.x)));
	}
	
	// Update the direction the camera is pointing by panning and inclining.
	if ( playerDirectionControl.x || playerDirectionControl.y ) {
		CGPoint delta = ccpMult(playerDirectionControl, dt * 30.0);		// Factor to set speed of rotation.
		CC3Vector camRot = activeCamera.rotation;
		camRot.y -= delta.x;
		camRot.x += delta.y;
		activeCamera.rotation = camRot;	
	}
}

/** Layout (perSideCount * perSideCount) copies of the templateNode into a grid. */
-(void) layoutGrid {
	[nodeGrid populateWith: self.templateNode perSide: self.perSideCount];
}

-(void) increaseNodes {
	self.perSideCount += 2;
}

-(void) decreaseNodes {
	uint perSide = self.perSideCount;
	if (perSide > 2) {
		self.perSideCount = self.perSideCount - 2;
	}
}

-(void) nextNodeType {
	int nextIndex = [availableTemplateNodes indexOfObjectIdenticalTo: self.templateNode] + 1;
	if (nextIndex >= availableTemplateNodes.count) {
		nextIndex = 0;
	}
	self.templateNode = [availableTemplateNodes objectAtIndex: nextIndex];
}

-(void) prevNodeType {
	int prevIndex = [availableTemplateNodes indexOfObjectIdenticalTo: self.templateNode] - 1;
	if (prevIndex < 0) {
		prevIndex = availableTemplateNodes.count - 1;
	}
	self.templateNode = [availableTemplateNodes objectAtIndex: prevIndex];
}

/**
 * Choose the update visitor class to use based on whether the nodes should be animated
 * to force the transform matrices of each node to be recalculated on each update.
 *
 * If the nodes should be animated, use a CC3AnimatingVisitor instance, otherwise use
 * a normal CC3NodeUpdatingVisitor instance.
 */
-(id) updateVisitorClass {
	return [CC3AnimatingVisitor class];
}

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
	return (aNode.name == ((CC3PerformanceWorld*)startingNode).templateNode.name);
}

/** Returns whether the nodes should be animated. */
-(BOOL) shouldAnimateNodes {
	return ((CC3PerformanceWorld*)startingNode).shouldAnimateNodes;
}

/**
 * If the node is one of the copies of the template node, rotate it a bit.
 * The rotation direction and magnitude is derived from the node's unique tag,
 * so that each template copy rotates a little differently than any of the others.
 */
-(void) processBeforeChildren: (CC3Node*) aNode {
	if (self.shouldAnimateNodes && [self nodeIsFromTemplate: aNode]) {
		GLfloat direction = SIGN((GLfloat)(aNode.tag % 2) - 0.5);
		GLfloat magnitude = (GLfloat)(aNode.tag % 8) + 4;
		CC3Vector deltaRot = cc3v(direction * magnitude * 5.0 * deltaTime,
								  direction * magnitude * 7.0 * deltaTime,
								  0.0);
		aNode.rotation = CC3VectorAdd(aNode.rotation, deltaRot);
	}
	[super processBeforeChildren: aNode];
}

@end

