/*
 * CC3NodeVisitor.m
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
 * See header file CC3NodeVisitor.h for full API documentation.
 */

#import "CC3NodeVisitor.h"
#import "CC3World.h"
#import "CC3Layer.h"
#import "CC3VertexArrayMesh.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3EAGLView.h"

@interface CC3World (TemplateMethods)
@property(nonatomic, readonly) CC3TouchedNodePicker* touchedNodePicker;
@end

#pragma mark -
#pragma mark CC3NodeVisitor

@interface CC3NodeVisitor (TemplateMethods)
-(void) processRemovals;
@end

@implementation CC3NodeVisitor

@synthesize startingNode, shouldVisitChildren;

-(void) dealloc {
	[startingNode release];
	[pendingRemovals release];
	[super dealloc];
}

-(CC3PerformanceStatistics*) performanceStatistics {
	return startingNode.performanceStatistics;
}

-(id) init {
	if ( (self = [super init]) ) {
		startingNode = nil;
		pendingRemovals = nil;
		shouldVisitChildren = YES;
	}
	return self;
}

+(id) visitor {
	return [[[self alloc] init] autorelease];
}

-(void) visit: (CC3Node*) aNode {

	if (!aNode) return;		// Must have a node to work on
	
	// If this is the first node, open the visitor
	if (startingNode == nil) {
		startingNode = [aNode retain];
		[self open];
	}

	// Do the heavy lifting before visiting children
	[self processBeforeChildren: aNode];
	
	// Recurse through the child nodes if required
	if (shouldVisitChildren) {
		[self drawChildrenOf: aNode];
	}

	// Do the heavy lifting after visiting children
	[self processAfterChildren: aNode];
	
	// If this is the first node, close the visitor
	if (aNode == startingNode) {
		[self close];
	}
}

-(void) processBeforeChildren: (CC3Node*) aNode {}

-(void) drawChildrenOf: (CC3Node*) aNode {
	NSArray* children = aNode.children;
	for (CC3Node* child in children) {
		[self visit: child];
	}
}

-(void) processAfterChildren: (CC3Node*) aNode {}

-(void) open {}

-(void) close {
	[self processRemovals];
}

-(void) requestRemovalOf: (CC3Node*) aNode {
	if (!pendingRemovals) {
		pendingRemovals = [[NSMutableSet set] retain];
	}
	[pendingRemovals addObject: aNode];
}

-(void) processRemovals {
	if (pendingRemovals) {
		for (CC3Node* n in pendingRemovals) {
			[n remove];
		}
		[pendingRemovals release];
		pendingRemovals = nil;
	}
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@", [self class]];
}

@end


#pragma mark -
#pragma mark CC3NodeTransformingVisitor

@implementation CC3NodeTransformingVisitor

@synthesize shouldLocalizeToStartingNode;

-(void) setShouldLocalizeToStartingNode: (BOOL) shouldLocalize {
	shouldLocalizeToStartingNode = shouldLocalize;
	if (shouldLocalizeToStartingNode) {
		isTransformDirty = YES;
	}
}

-(id) init {
	if ( (self = [super init]) ) {
		isTransformDirty = NO;
		shouldLocalizeToStartingNode = NO;
	}
	return self;
}

/**
 * As each node is visited, remember whether an ancestor was dirty, and restore that
 * indication for the benefit of other nodes that will be visited after this node.
 *
 * This flag cannot be carried by the visitor itself, because it is state associated
 * with a particular node, not the visitor, and a child node could modify it and mess
 * up later siblings of a the parent node.
 */
-(void) visit: (CC3Node*) aNode {
	BOOL wasAncestorDirty = isTransformDirty;
	[super visit: aNode];
	isTransformDirty = wasAncestorDirty;
}

/**
 * Force a transform recalc of this node and all subsequent children if
 * either the specified node, or one of its ancestors has been changed.
 */
-(void) processBeforeChildren: (CC3Node*) aNode {
	
	isTransformDirty = isTransformDirty || aNode.isTransformDirty;
	
	if (isTransformDirty) {
		[self.performanceStatistics incrementNodesTransformed];
		[aNode buildTransformMatrixWithVisitor: self];
	}
}

-(CC3GLMatrix*) parentTansformMatrixFor: (CC3Node*) aNode {
	CC3Node* parentNode = aNode.parent;
	BOOL localizeToThisNode = shouldLocalizeToStartingNode && (aNode == startingNode ||
															   parentNode == startingNode);
	return (parentNode && !localizeToThisNode) ? parentNode.transformMatrix : nil;
}

@end


#pragma mark -
#pragma mark CC3NodeUpdatingVisitor

@implementation CC3NodeUpdatingVisitor

@synthesize deltaTime;

-(id) init {
	return [self initWithDeltaTime: 0.0f];
}

-(id) initWithDeltaTime: (ccTime) dt {
	if ( (self = [super init]) ) {
		deltaTime = dt;
	}
	return self;
}

+(id) visitorWithDeltaTime: (ccTime) dt {
	return [[[self alloc] initWithDeltaTime: dt] autorelease];
}

-(void) processBeforeChildren: (CC3Node*) aNode {
	LogTrace(@"Updating %@ after %.3f ms", aNode, deltaTime * 1000.0f);
	[self.performanceStatistics incrementNodesUpdated];
	[aNode updateBeforeTransform: self];

	// Process the transform AFTER updateBeforeTransform: invoked
	[super processBeforeChildren: aNode];
}

-(void) processAfterChildren: (CC3Node*) aNode {
	[aNode updateAfterTransform: self];
	[super processAfterChildren: aNode];
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVisitor

@implementation CC3NodeBoundingBoxVisitor

@synthesize boundingBox;

-(id) init {
	if ( (self = [super init]) ) {
		boundingBox = kCC3BoundingBoxNull;
	}
	return self;
}

-(void) processAfterChildren: (CC3Node*) aNode {
	[super processAfterChildren: aNode];
	if (aNode.hasLocalContent) {

		// If the bounding box is being localized to the starting node, and the node
		// isthe starting node, don't apply transform to bounding box, because we want
		// the bounding box in the local coordinate system of the startingNode
		CC3LocalContentNode* lcNode = (CC3LocalContentNode*)aNode;
		CC3BoundingBox nodeBox = (shouldLocalizeToStartingNode && (aNode == startingNode)) 
									? lcNode.localContentBoundingBox
									: lcNode.globalLocalContentBoundingBox;

		// Merge the node's bounding box into the aggregate bounding box
		LogTrace(@"Merging %@ from %@ into %@", NSStringFromCC3BoundingBox(nodeBox),
				 aNode, NSStringFromCC3BoundingBox(boundingBox));
		boundingBox = CC3BoundingBoxUnion(boundingBox, nodeBox);
	}
}

/**
 * If the node transforms were changed to be relative to the starting node,
 * brings the transforms back to what they were by rebuilding them again,
 * this time from the normal CC3World perspective.
 */
-(void) close {
	[super close];
	if (shouldLocalizeToStartingNode) {
		[startingNode markTransformDirty];
		[startingNode updateTransformMatrices];
	}
}

@end

#pragma mark -
#pragma mark CC3NodeDrawingVisitor

@interface CC3Node (CC3NodeDrawingVisitor)
-(void) drawLocalContentWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@property(nonatomic, readonly) CC3World* world;
@end

@interface CC3World (CC3NodeDrawingVisitor)
-(void) drawDrawSequenceWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@implementation CC3NodeDrawingVisitor

@synthesize frustum, shouldDecorateNode, textureUnit, textureUnitCount;

-(void) dealloc {
	frustum = nil;		// not retained
	[super dealloc];
}

-(CC3World*) world {
	return (CC3World*)startingNode;
}

-(id) init {
	if ( (self = [super init]) ) {
		self.shouldDecorateNode = YES;
	}
	return self;
}

-(void) processBeforeChildren: (CC3Node*) aNode {
	LogTrace(@"Visiting %@ %@ children", aNode, (shouldVisitChildren ? @"and" : @"but not"));
	[self.performanceStatistics incrementNodesVisitedForDrawing];
	[aNode drawWithVisitor: self];
}

-(void) drawChildrenOf: (CC3Node*) aNode {
	if (self.world.isUsingDrawingSequence) {
		[self.world drawDrawSequenceWithVisitor: self];
	} else {
		[super drawChildrenOf: aNode];
	}
}

/**
 * Establishes the frustum from the currently active camera, initializes mesh and
 * material context switching, and clears the depth buffer every time drawing begins so
 * that 3D rendering will occur over top of any previously rendered 3D or 2D artifacts.
 */
-(void) open {
	[super open];
	frustum = self.world.activeCamera.frustum;

	[CC3Material resetSwitching];
	[CC3VertexArrayMesh resetSwitching];
	
	[[CC3OpenGLES11Engine engine].state clearDepthBuffer];
}

/** Retracts the frustum. */
-(void) close {
	[super close];
	frustum = nil;
}

-(void) drawLocalContentOf: (CC3Node*) aNode {
	[aNode drawLocalContentWithVisitor: self];
	[self.performanceStatistics incrementNodesDrawn];
}

@end


#pragma mark -
#pragma mark CC3NodePickingVisitor

@interface CC3NodePickingVisitor (TemplateMethods)
-(void) paintNode: (CC3Node*) aNode;
-(ccColor4B) colorFromNodeTag: (GLuint) tag;
-(GLuint) tagFromColor: (ccColor4B) color;
-(void) drawBackdrop;
@end

@implementation CC3NodePickingVisitor

@synthesize pickedNode;

-(void) dealloc {
	[pickedNode release];
	[super dealloc];
}

/** Overridden to initially set the shouldDecorateNode to NO. */
-(id) init {
	if ( (self = [super init]) ) {
		self.shouldDecorateNode = NO;
	}
	return self;
}

/**
 * Clears the pickedNode property, ensures that lighting, blending, and fog are turned off,
 * so that nodes can be drawn in pure colors, and remembers the current color value so that
 * is can be restored after picking. This is necessary when the world has no lighting, to
 * avoid flicker on materials and textures.
 * 
 * Superclass implementation also clears the depth buffer so that the real drawing pass
 * will have a clear depth buffer. Otherwise, pixels from farther objects will not be drawn,
 * since the  nearer objects were already drawn during color picking. This would be a problem
 * if the nearer object is translucent, because we expect to see some of the farther object
 * show through the translucent object. The result would be a noticable flicker in the nearer
 * translucent object.
 *
 * If multisampling antialiasing is being used, we must use a different framebuffer,
 * since the multisampling framebuffer does not support pixel reading.
 */
-(void) open {
	[super open];
	
	[pickedNode release];
	pickedNode = nil;
	
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = gles11Engine.serverCapabilities;
	[gles11ServCaps.lighting disable];
	[gles11ServCaps.blend disable];
	[gles11ServCaps.fog disable];
	
	originalColor = gles11Engine.state.color.value;
	
	// If multisampling antialiasing, bind the picking framebuffer before reading the pixel.
	[[CCDirector sharedDirector].openGLView openPicking];
}

/**
 * Reads the color of the pixel at the touch point, maps that to the tag of the CC3Node
 * that was touched, and sets the picked node in the pickedNode property.
 *
 * If antialiasing multisampling is active, after reading the color of the touched pixel,
 * the multisampling framebuffer is made active in preparation of normal drawing operations.
 *
 * If the
 *
 * Also restores the original GL color value, to avoid flicker on materials and textures
 * if the world has no lighting.
 */
-(void) close {
	CC3OpenGLES11State* gles11State = [CC3OpenGLES11Engine engine].state;
		
	// Read the pixel from the framebuffer
	ccColor4B pixColor = [gles11State readPixelAt: self.world.touchedNodePicker.glTouchPoint];
	
	// Fetch the node whose tags is mapped from the pixel color
	pickedNode = [[self.world getNodeTagged: [self tagFromColor: pixColor]] retain];
	
	LogTrace(@"%@ picked %@ from color (%u, %u, %u, %u)", self, pickedNode,
			 pixColor.r, pixColor.g, pixColor.b, pixColor.a);
	
	// If multisampling antialiasing, rebind the multisampling framebuffer
	[[CCDirector sharedDirector].openGLView closePicking];
	
	[self drawBackdrop];	// Draw the backdrop behind the 3D world

	gles11State.color.value = originalColor;
	[super close];
}

/**
 * Template method that draws the backdrop behind the 3D world.
 *
 * This method is automatically invoked after the 3D world has been drawn in pure
 * solid colors, and prior to the second redrawing with the true coloring, to
 * provide an empty canvas on which to draw the real scene.
 *
 * This implementation simply clears the GL color buffer to create an empty canvas.
 * If the CC3Layer has a colored background, that color is used to clear the GL
 * color buffer, otherwise the current GL clearing color is used.
 *
 * Subclasses can override to do something more sophisticated with the background.
 */
-(void) drawBackdrop {
	CC3OpenGLES11State* gles11State = [CC3OpenGLES11Engine engine].state;
	CC3Layer* cc3Layer = self.world.cc3Layer;
		
	// If the CC3Layer has a background color, use it as the GL clear color
	if (cc3Layer && cc3Layer.isColored) {
		// Remember the current GL clear color
		ccColor4F currClearColor = gles11State.clearColor.value;
		
		// Retrieve the CC3Layer background color
		ccColor3B lcub3 = cc3Layer.color;
		ccColor4F layerColor = CCC4FMake(CCColorFloatFromByte(lcub3.r),
										 CCColorFloatFromByte(lcub3.g),
										 CCColorFloatFromByte(lcub3.b),
										 CCColorFloatFromByte(cc3Layer.opacity));
		
		// Set the GL clear color from the layer color
		gles11State.clearColor.value = layerColor;
		LogTrace(@"%@ clearing background to %@ color: %@",
				 self, cc3Layer, NSStringFromCCC4F(layerColor));
		
		// Clear the color buffer to redraw the background
		[gles11State clearColorBuffer];
		
		// Reinstate the current GL clear color
		gles11State.clearColor.value = currClearColor;
		
	} else {
		// Otherwise use the current clear color
		LogTrace(@"%@ clearing background to default clear color: %@",
				 self, NSStringFromCCC4F(gles11State.clearColor.value));
		
		// Clear the color buffer to redraw the background
		[gles11State clearColorBuffer];
	}
}

/** Overridden to draw the node only if it is touchable, and to draw it in a uniquely identifiable color. */
-(void) drawLocalContentOf: (CC3Node*) aNode {
	if (aNode.isTouchable) {
		[self paintNode: aNode];
		[super drawLocalContentOf: aNode];
	}
}

/** Maps the specified node to a unique color, and paints the node with that color. */
-(void) paintNode: (CC3Node*) aNode {
	ccColor4B color = [self colorFromNodeTag: aNode.tag];
	[CC3OpenGLES11Engine engine].state.color.fixedValue = color;
	LogTrace("%@ painting %@ with color (%u, %u, %u, %u)",
			 self, aNode, color.r, color.g, color.b, color.a);
}

/**
 * Maps the specified integer tag to a color, by spreading the bits of the integer across
 * the red, green and blue unsigned bytes of the color. This permits 2^24 objects to be
 * encoded by colors. This is the compliment of the tagFromColor: method.
 */
-(ccColor4B) colorFromNodeTag: (GLuint) tag {
	GLuint mask = 255;
	GLubyte r = (tag >> 16) & mask;
	GLubyte g = (tag >> 8) & mask;
	GLubyte b = tag & mask;
	return ccc4(r, g, b, 255);
}

/**
 * Maps the specified color to a tag, by combining the bits of the red, green, and blue
 * colors into a single integer value. This is the compliment of the colorFromNodeTag: method.
 */
-(GLuint) tagFromColor: (ccColor4B) color {
	return ((GLuint)color.r << 16) | ((GLuint)color.g << 8) | (GLuint)color.b;
}

@end
