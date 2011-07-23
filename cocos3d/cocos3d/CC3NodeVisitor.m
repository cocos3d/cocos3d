/*
 * CC3NodeVisitor.m
 *
 * cocos3d 0.6.0-sp
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
#import "CC3VertexArrayMesh.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3EAGLView.h"

@interface CC3Node (TemplateMethods)
-(void) buildTransformMatrix;
-(void) updateChildrenWithVisitor: (CC3NodeTransformingVisitor*) visitor;
@end

@interface CC3World (TemplateMethods)
@property(nonatomic, readonly) CC3WorldTouchHandler* touchHandler;
@end

#pragma mark -
#pragma mark CC3NodeVisitor

@interface CC3NodeVisitor (TemplateMethods)
-(void) visitNodeBeforeUpdatingTransform: (CC3Node*) aNode;
-(void) visitNodeAfterUpdatingTransform: (CC3Node*) aNode;
-(void) processRemovals;
@end


@implementation CC3NodeVisitor

@synthesize world, performanceStatistics, shouldVisitChildren;

-(void) dealloc {
	[world release];
	[pendingRemovals release];
	performanceStatistics = nil;		// not retained
	[super dealloc];
}

-(void) setWorld:(CC3World *) aWorld {
	id oldWorld = world;
	world = [aWorld retain];
	[oldWorld release];
	performanceStatistics = world.performanceStatistics;
}

-(id) init {
	return [self initWithWorld: nil];
}

+(id) visitor {
	return [[[self alloc] init] autorelease];
}

-(id) initWithWorld: (CC3World*) theWorld {
	if ( (self = [super init]) ) {
		self.world = theWorld;
		shouldVisitChildren = YES;
	}
	return self;
}

+(id) visitorWithWorld: (CC3World*) theWorld {
	return [[[self alloc] initWithWorld: theWorld] autorelease];
}

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

-(id) initWithWorld: (CC3World*) theWorld {
	if ( (self = [super initWithWorld: theWorld]) ) {
		isTransformDirty = NO;
	}
	return self;
}

-(void) updateNode: (CC3Node*) aNode {

	// Remember whether an ancestor was dirty.
	BOOL wasAncestorDirty = isTransformDirty;
	
	// Give this visitor a chance to do something before building the transform matrix.
	[self visitNodeBeforeUpdatingTransform: aNode];
	
	// Force a transform recalc if either the specified node,
	// or one of its ancestors has been changed.
	isTransformDirty = aNode.isTransformDirty || wasAncestorDirty;
	
	if (isTransformDirty) {
		[performanceStatistics incrementNodesTransformed];
		[aNode buildTransformMatrix];
	}
	
	// If we should, update child nodes as well
	if (shouldVisitChildren) {
		[aNode updateChildrenWithVisitor: self];
	}
	
	// Give this visitor a chance to do something after building the transform matrix.
	[self visitNodeAfterUpdatingTransform: aNode];
	
	// Restore the original indication of whether the ancestor was dirty for
	// the benefit of other nodes that will be visited
	isTransformDirty = wasAncestorDirty;
}

/**
 * Template method that is invoked automatically for each node visited, before the
 * transformation matrix is recalculated.
 *
 * This method is invoked prior to testing whether the node transformMatrix should be
 * recalculated. At this point, the isTransformDirty flag on the visitor reflects the
 * state of the parent node, and indicates whether the transformMatrix of any of the
 * node's ancestors was rebuilt.
 *
 * Since this method is invoked prior to recalculation of the transformMatrix, the node's
 * global properties: globalLocation, globalRotation and globalScale are not current.
 *
 * When nodes are visited hierarchically during transformations, this method will be
 * invoked prior to the invocation of the same method on any of the node's descendants.
 * 
 * This implementation does nothing. Subclasses may override
 */
-(void) visitNodeBeforeUpdatingTransform: (CC3Node*) aNode {}

/**
 * Template method that is invoked automatically for each node visited, after the
 * transformation matrix is recalculated.
 *
 * At this point, the isTransformDirty flag on the visitor reflects whether the transformMatrix
 * of this node or that of any of its ancestors was rebuilt.
 *
 * Since this method is invoked after to recalculation of the transformMatrix, the node's
 * global properties: globalLocation, globalRotation and globalScale are valid and can be used.
 *
 * When nodes are visited hierarchically during transformations, this method will be
 * invoked after the invocation of the same method on all of the node's descendants.
 * 
 * This implementation does nothing. Subclasses may override.
 */
-(void) visitNodeAfterUpdatingTransform: (CC3Node*) aNode {}

@end


#pragma mark -
#pragma mark CC3NodeUpdatingVisitor

@implementation CC3NodeUpdatingVisitor

@synthesize deltaTime;

-(id) init {
	return [self initWithWorld: nil];
}

-(id) initWithWorld: (CC3World*) theWorld {
	return [self initWithWorld: theWorld andDeltaTime: 0.0f];
}

-(id) initWithWorld: (CC3World*) theWorld andDeltaTime: (ccTime) dt {
	if ( (self = [super initWithWorld: theWorld]) ) {
		deltaTime = dt;
	}
	return self;
}

+(id) visitorWithWorld: (CC3World*) theWorld andDeltaTime: (ccTime) dt {
	return [[[self alloc] initWithWorld: theWorld andDeltaTime: dt] autorelease];
}

/**
 * Template method that is invoked automatically for each node visited, before the
 * transformation matrix is recalculated.
 * 
 * This method delegates to the node by invoking the updateBeforeTransform: on the node.
 * It also increments the nodesUdated property of the CC3World's performanceStatistics.
 *
 * This method is invoked prior to testing whether the node transformMatrix should be
 * recalculated. At this point, the isTransformDirty flag on the visitor reflects the
 * state of the parent node, and indicates whether the transformMatrix of any of the
 * node's ancestors was rebuilt.
 *
 * Since this method is invoked prior to recalculation of the transformMatrix, the node's
 * global properties: globalLocation, globalRotation and globalScale are not current.
 *
 * When nodes are visited hierarchically during transformations, this method will be
 * invoked prior to the invocation of the same method on any of the node's descendants.
 */
-(void) visitNodeBeforeUpdatingTransform: (CC3Node*) aNode {
	LogTrace(@"Updating %@ after %.3f ms", aNode, deltaTime * 1000.0f);
	[performanceStatistics incrementNodesUpdated];
	[aNode updateBeforeTransform: self];
}

/**
 * Template method that is invoked automatically for each node visited, after the
 * transformation matrix is recalculated.
 * 
 * This method delegates to the node by invoking the updateAfterTransform: on the node.
 *
 * At this point, the isTransformDirty flag on the visitor reflects whether the transformMatrix
 * of this node or that of any of its ancestors was rebuilt.
 *
 * Since this method is invoked after to recalculation of the transformMatrix, the node's
 * global properties: globalLocation, globalRotation and globalScale are valid and can be used.
 *
 * When nodes are visited hierarchically during transformations, this method will be
 * invoked after the invocation of the same method on all of the node's descendants.
 */
-(void) visitNodeAfterUpdatingTransform: (CC3Node*) aNode {
	[aNode updateAfterTransform: self];
}

@end


#pragma mark -
#pragma mark CC3NodeDrawingVisitor

@interface CC3Node (CC3NodeDrawingVisitor)
-(void) drawLocalContentWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@implementation CC3NodeDrawingVisitor

@synthesize frustum, shouldDecorateNode, textureUnit, textureUnitCount;

-(void) dealloc {
	frustum = nil;		// not retained
	[super dealloc];
}

/**
 * Establishes the frustum from the currently active camera, initializes mesh and
 * material context switching, and clears the depth buffer every time drawing begins so
 * that 3D rendering will occur over top of any previously rendered 3D or 2D artifacts.
 */
-(void) open {
	[super open];
	frustum = world.activeCamera.frustum;

	[CC3Material resetSwitching];
	[CC3VertexArrayMesh resetSwitching];
	
	[[CC3OpenGLES11Engine engine].state clearDepthBuffer];
}

/** Retracts the frustum, and sets the nodeProcessed property into the statistics. */
-(void) close {
	frustum = nil;
}

-(id) initWithWorld: (CC3World*) theWorld {
	if ( (self = [super initWithWorld: theWorld]) ) {
		self.shouldDecorateNode = YES;
	}
	return self;
}

-(void) drawLocalContentOf: (CC3Node*) aNode {
	[aNode drawLocalContentWithVisitor: self];
	[performanceStatistics incrementNodesDrawn];
}

@end


#pragma mark -
#pragma mark CC3NodePickingVisitor

@interface CC3NodePickingVisitor (TemplateMethods)
-(void) paintNode: (CC3Node*) aNode;
-(ccColor4B) colorFromNodeTag: (GLuint) tag;
-(GLuint) tagFromColor: (ccColor4B) color;
@end

@implementation CC3NodePickingVisitor

@synthesize pickedNode;

-(void) dealloc {
	[pickedNode release];
	[super dealloc];
}

/** Overridden to initially set the shouldDecorateNode to NO. */
-(id) initWithWorld: (CC3World*) theWorld {
	if ( (self = [super initWithWorld: theWorld]) ) {
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
 * Also restores the original GL color value, to avoid flicker on materials and textures
 * if the world has no lighting.
 */
-(void) close {
	CC3OpenGLES11State* gles11State = [CC3OpenGLES11Engine engine].state;
	if (world) {
		
		// Read the pixel from the framebuffer
		ccColor4B pixColor = [gles11State readPixelAt: world.touchHandler.glTouchPoint];
		
		// Fetch the node whose tags is mapped from the pixel color
		pickedNode = [[world getNodeTagged: [self tagFromColor: pixColor]] retain];
		
		LogTrace(@"%@ picked %@ from color (%u, %u, %u, %u)", self, pickedNode,
				 pixColor.r, pixColor.g, pixColor.b, pixColor.a);
	}
	
	// If multisampling antialiasing, rebind the multisampling framebuffer
	[[CCDirector sharedDirector].openGLView closePicking];

	gles11State.color.value = originalColor;
	[super close];
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
