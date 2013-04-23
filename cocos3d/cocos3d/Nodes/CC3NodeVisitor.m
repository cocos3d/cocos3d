/*
 * CC3NodeVisitor.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3Scene.h"
#import "CC3Layer.h"
#import "CC3Mesh.h"
#import "CC3NodeSequencer.h"
#import "CC3VertexSkinning.h"
#import "CC3GLView-GL.h"
#import "CC3GLView-GLES2.h"
#import "CC3GLView-GLES1.h"

@interface CC3Node (TemplateMethods)
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor;
@end

@interface CC3Scene (TemplateMethods)
@property(nonatomic, readonly) CC3TouchedNodePicker* touchedNodePicker;
@end


#pragma mark -
#pragma mark CC3NodeVisitor

@interface CC3NodeVisitor (TemplateMethods)
-(void) process: (CC3Node*) aNode;
-(void) processBeforeChildren: (CC3Node*) aNode;
-(void) processChildrenOf: (CC3Node*) aNode;
-(void) processAfterChildren: (CC3Node*) aNode;
-(void) open;
-(void) close;
-(void) processRemovals;
@end

@implementation CC3NodeVisitor

@synthesize currentNode=_currentNode, startingNode=_startingNode;
@synthesize shouldVisitChildren=_shouldVisitChildren, camera=_camera;

-(void) dealloc {
	_currentNode = nil;				// not retained
	_startingNode = nil;			// not retained
	_camera = nil;					// not retained
	[_pendingRemovals release];
	[super dealloc];
}

-(CC3PerformanceStatistics*) performanceStatistics { return _startingNode.performanceStatistics; }

-(void) visit: (CC3Node*) aNode {
	if (!aNode) return;					// Must have a node to work on
	
	_currentNode = aNode;				// Make the node being processed available.

	if (!_startingNode) {				// If this is the first node, start up
		_startingNode = aNode;			// Not retained
		if (!_camera) self.camera = aNode.activeCamera;	// Retrieve and cache the camera using setter. Not retained
		[self open];					// Open the visitor
	}

	[self process: aNode];				// Process the node and its children recursively

	if (aNode == _startingNode) {		// If we're back to the first node, finish up
		[self close];					// Close the visitor
		_camera = nil;					// Not retained
		_startingNode = nil;				// Not retained
	}
	
	_currentNode = nil;					// Done with this node now.
}

/** Template method that is invoked automatically during visitation to process the specified node. */
-(void) process: (CC3Node*) aNode {
	LogTrace(@"%@ visiting %@ %@ children", self, aNode, (shouldVisitChildren ? @"and" : @"but not"));
	
	[self processBeforeChildren: aNode];	// Heavy lifting before visiting children
	
	// Recurse through the child nodes if required
	if (_shouldVisitChildren) [self processChildrenOf: aNode];

	[self processAfterChildren: aNode];		// Heavy lifting after visiting children
}

/**
 * Template method that is invoked automatically to process the specified node when
 * that node is visited, before the visit: method is invoked on the child nodes of
 * the specified node.
 * 
 * This abstract implementation does nothing. Subclasses will override to process
 * each node as it is visited.
 */
-(void) processBeforeChildren: (CC3Node*) aNode {}

/**
 * If the shouldVisitChildren property is set to YES, this template method is invoked
 * automatically to cause the visitor to visit the child nodes of the specified node .
 *
 * This implementation invokes the visit: method on this visitor for each of the
 * children of the specified node. This establishes a depth-first traveral of the
 * node hierarchy.
 *
 * Subclasses may override this method to establish a different traversal.
 */
-(void) processChildrenOf: (CC3Node*) aNode {
	CC3Node* currNode = _currentNode;	// Remember current node
	
	CCArray* children = aNode.children;
	for (CC3Node* child in children) {
		[self visit: child];
	}

	_currentNode = currNode;				// Restore current node
}

/**
 * Invoked automatically to process the specified node when that node is visited,
 * after the visit: method is invoked on the child nodes of the specified node.
 * 
 * This abstract implementation does nothing. Subclasses will override to process
 * each node as it is visited.
 */
-(void) processAfterChildren: (CC3Node*) aNode {}

/**
 * Template method that prepares the visitor to perform a visitation run. This method
 * is invoked automatically prior to the first node being visited. It is not invoked
 * for each node visited.
 *
 * This implementation does nothing. Subclasses can override to initialize their state,
 * or to set any external state needed, such as GL state, prior to starting a visitation
 * run, and should invoke this superclass implementation.
 */
-(void) open {}

/**
 * Invoked automatically after the last node has been visited during a visitation run.
 * This method is invoked automatically after all nodes have been visited.
 * It is not invoked for each node visited.
 *
 * This implementation processes the removals of any nodes that were requested to
 * be removed via the requestRemovalOf: method during the visitation run. Subclasses
 * can override to clean up their state, or to reset any external state, such as GL
 * state, upon completion of a visitation run, and should invoke this superclass
 * implementation to process any removal requests.
 */
-(void) close { [self processRemovals]; }

-(void) requestRemovalOf: (CC3Node*) aNode {
	if (!_pendingRemovals) {
		_pendingRemovals = [[CCArray array] retain];
	}
	[_pendingRemovals addObject: aNode];
}

-(void) processRemovals {
	for (CC3Node* n in _pendingRemovals) [n remove];
	[_pendingRemovals removeAllObjects];
}


#pragma mark Accessing node contents

-(CC3Scene*) scene { return _startingNode.scene; }

-(CC3MeshNode*) currentMeshNode { return (CC3MeshNode*)self.currentNode; }

-(CC3Material*) currentMaterial { return self.currentMeshNode.material; }

-(CC3TextureUnit*) currentTextureUnitAt: (GLuint) texUnit {
	return [self.currentMaterial textureForTextureUnit: texUnit].textureUnit;
}

-(CC3Mesh*) currentMesh { return self.currentMeshNode.mesh; }

-(NSUInteger) lightCount { return self.scene.lights.count; }

-(CC3Light*) lightAt: (GLuint) index {
	CCArray* lights = self.scene.lights;
	if (index < lights.count) return [lights objectAtIndex: index];
	return nil;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_currentNode = nil;
		_startingNode = nil;
		_camera = nil;
		_pendingRemovals = nil;
		_shouldVisitChildren = YES;
	}
	return self;
}

+(id) visitor { return [[[self alloc] init] autorelease]; }

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ visiting %@ %@ children, %lu removals",
			[self description], _startingNode, (_shouldVisitChildren ? @"and" : @"but not"),
			(unsigned long)_pendingRemovals.count];
}

@end


#pragma mark -
#pragma mark CC3NodeTransformingVisitor

@implementation CC3NodeTransformingVisitor

@synthesize shouldLocalizeToStartingNode=_shouldLocalizeToStartingNode;
@synthesize shouldRestoreTransforms=_shouldRestoreTransforms, isTransformDirty=_isTransformDirty;

-(id) init {
	if ( (self = [super init]) ) {
		_isTransformDirty = NO;
		_shouldLocalizeToStartingNode = NO;
		_shouldRestoreTransforms = NO;
	}
	return self;
}

-(void) open {
	[super open];
	_isTransformDirty = _shouldLocalizeToStartingNode;
}

/**
 * As each node is visited, remember whether an ancestor was dirty, and restore that
 * indication for the benefit of other nodes that will be visited after this node.
 *
 * This flag cannot be carried by the visitor itself, because it is state associated
 * with a particular node, not the visitor, and a child node could modify it and mess
 * up later siblings of a the parent node.
 */
-(void) process: (CC3Node*) aNode {
	BOOL wasAncestorDirty = _isTransformDirty;
	[super process: aNode];
	_isTransformDirty = wasAncestorDirty;
}

/**
 * Force a transform recalc of this node and all subsequent children if
 * either the specified node, or one of its ancestors has been changed.
 */
-(void) processBeforeChildren: (CC3Node*) aNode {
	
	_isTransformDirty = _isTransformDirty || aNode.isTransformDirty;
	
	if (_isTransformDirty) {
		[self.performanceStatistics incrementNodesTransformed];
		[aNode buildTransformMatrixWithVisitor: self];
	}
}

/**
 * If the node transforms were changed to be relative to the starting node,
 * brings the transforms back to what they were by rebuilding them again,
 * this time from the normal CC3Scene perspective.
 */
-(void) close {
	[super close];
	if (_shouldLocalizeToStartingNode && _shouldRestoreTransforms) {
		[_startingNode markTransformDirty];
		[_startingNode updateTransformMatrices];
	}
}

-(CC3Matrix*) parentTansformMatrixFor: (CC3Node*) aNode {
	CC3Node* parentNode = aNode.parent;
	BOOL localizeToThisNode = _shouldLocalizeToStartingNode && (aNode == _startingNode ||
															   parentNode == _startingNode);
	return localizeToThisNode ? nil : aNode.parentTransformMatrix;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, localize: %@, dirty: %@",
			[super fullDescription], NSStringFromBoolean(_shouldLocalizeToStartingNode),
			NSStringFromBoolean(_isTransformDirty)];
}

@end


#pragma mark -
#pragma mark CC3NodeUpdatingVisitor

@implementation CC3NodeUpdatingVisitor

@synthesize deltaTime=_deltaTime;

-(void) processBeforeChildren: (CC3Node*) aNode {
	LogTrace(@"Updating %@ after %.3f ms", aNode, deltaTime * 1000.0f);
	[self.performanceStatistics incrementNodesUpdated];
	[aNode processUpdateBeforeTransform: self];

	// Process the transform AFTER updateBeforeTransform: invoked
	[super processBeforeChildren: aNode];
}

-(void) processAfterChildren: (CC3Node*) aNode {
	[aNode processUpdateAfterTransform: self];
	[super processAfterChildren: aNode];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, dt: %.3f ms",
			[super fullDescription], _deltaTime * 1000.0f];
}

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVisitor

@interface CC3Node (CC3NodeBoundingBoxVisitor)
-(BOOL) shouldContributeToParentBoundingBox;
@end

@implementation CC3NodeBoundingBoxVisitor

@synthesize boundingBox=_boundingBox;

-(id) init {
	if ( (self = [super init]) ) {
		_boundingBox = kCC3BoundingBoxNull;
		_shouldRestoreTransforms = YES;
	}
	return self;
}

-(void) open {
	[super open];
	_boundingBox = kCC3BoundingBoxNull;
}

-(void) processAfterChildren: (CC3Node*) aNode {
	[super processAfterChildren: aNode];
	if (aNode.shouldContributeToParentBoundingBox) {

		// If the bounding box is being localized to the starting node, and the node
		// is the starting node, don't apply transform to bounding box, because we want
		// the bounding box in the local coordinate system of the startingNode
		CC3LocalContentNode* lcNode = (CC3LocalContentNode*)aNode;
		CC3BoundingBox nodeBox = (_shouldLocalizeToStartingNode && (aNode == _startingNode))
									? lcNode.localContentBoundingBox
									: lcNode.globalLocalContentBoundingBox;

		// Merge the node's bounding box into the aggregate bounding box
		LogTrace(@"Merging %@ from %@ into %@", NSStringFromCC3BoundingBox(nodeBox),
				 aNode, NSStringFromCC3BoundingBox(boundingBox));
		_boundingBox = CC3BoundingBoxUnion(_boundingBox, nodeBox);
	}
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, box: %@",
			[super fullDescription], NSStringFromCC3BoundingBox(_boundingBox)];
}

@end


#pragma mark -
#pragma mark CC3NodeDrawingVisitor

@interface CC3NodeDrawingVisitor (TemplateMethods)
-(BOOL) shouldDrawNode: (CC3Node*) aNode;
-(BOOL) isNodeVisibleForDrawing: (CC3Node*) aNode;
@end

@implementation CC3NodeDrawingVisitor

@synthesize gl=_gl, drawingSequencer=_drawingSequencer, deltaTime=_deltaTime;
@synthesize shouldDecorateNode=_shouldDecorateNode, shouldClearDepthBuffer=_shouldClearDepthBuffer;
@synthesize currentTextureUnitIndex=_currentTextureUnitIndex, textureUnitCount=_textureUnitCount;
@synthesize currentColor=_currentColor, currentSkinSection=_currentSkinSection;
@synthesize currentShaderProgram=_currentShaderProgram;

-(void) dealloc {
	[_gl release];
	_drawingSequencer = nil;		// not retained
	_currentSkinSection = nil;		// not retained
	_currentShaderProgram = nil;	// not retained
	[super dealloc];
}

-(CC3OpenGL*) gl {
	if ( !_gl) self.gl = CC3OpenGL.sharedGL;
	return _gl;
}

-(void) processBeforeChildren: (CC3Node*) aNode {
	[self.performanceStatistics incrementNodesVisitedForDrawing];
	if ([self shouldDrawNode: aNode]) [aNode transformAndDrawWithVisitor: self];
	_currentSkinSection = nil;		// not retained
}

-(BOOL) shouldDrawNode: (CC3Node*) aNode {
	return aNode.hasLocalContent
			&& [self isNodeVisibleForDrawing: aNode]
			&& [aNode doesIntersectFrustum: _camera.frustum];
}

-(BOOL) isNodeVisibleForDrawing: (CC3Node*) aNode { return aNode.visible; }

-(void) processChildrenOf: (CC3Node*) aNode {
	if (_drawingSequencer) {
		CC3Node* currNode = _currentNode;	// Remember current node

		_shouldVisitChildren = NO;
		[_drawingSequencer visitNodesWithNodeVisitor: self];

		_currentNode = currNode;				// Restore current node
	} else {
		[super processChildrenOf: aNode];
	}
}

/** Populates the cached view and projection matrices. */
-(void) setCamera:(CC3Camera *)camera {
	super.camera = camera;
	[self populateProjMatrixFrom: camera.projectionMatrix];
	[self populateViewMatrixFrom: camera.viewMatrix];
}

/**
 * Attaches the CC3OpenGL instance, initializes mesh and material context switching, prepares
 * GL programs for rendering, and optionally clears the depth buffer every time drawing begins
 * so that 3D rendering will occur over top of any previously rendered 3D or 2D artifacts.
 */
-(void) open {
	[super open];

	[CC3Material resetSwitching];
	[CC3Mesh resetSwitching];
	[CC3GLProgram willBeginDrawingScene];
	
	if (_shouldClearDepthBuffer) [self.gl clearDepthBuffer];
}

-(void) draw: (CC3Node*) aNode {
	[aNode drawWithVisitor: self];
	[self.performanceStatistics incrementNodesDrawn];
}

-(void) disableUnusedTextureUnits {
	_textureUnitCount = _currentTextureUnitIndex;
	[_gl disableTexturingFrom: _currentTextureUnitIndex];
}


#pragma mark Accessing node contents

-(ccColor4B) currentColor4B { return CCC4BFromCCC4F(self.currentColor); }

-(void) setCurrentColor4B: (ccColor4B) color4B { self.currentColor = CCC4FFromCCC4B(color4B); }


#pragma mark Environmental matrices

-(CC3Matrix4x4*) projMatrix { return &_projMatrix; }

-(CC3Matrix4x3*) viewMatrix { return &_viewMatrix; }

-(CC3Matrix4x3*) modelMatrix { return &_modelMatrix; }

-(CC3Matrix4x3*) modelViewMatrix {
	if (_isMVMtxDirty) {
		CC3Matrix4x3Multiply(&_modelViewMatrix, &_viewMatrix, &_modelMatrix);
		_isMVMtxDirty = NO;
	}
	return &_modelViewMatrix;
}

-(CC3Matrix4x4*) viewProjMatrix {
	if (_isVPMtxDirty) {
		CC3Matrix4x4 v4x4;
		CC3Matrix4x4PopulateFrom4x3(&v4x4, &_viewMatrix);
		CC3Matrix4x4Multiply(&_viewProjMatrix, &_projMatrix, &v4x4);
		_isVPMtxDirty = NO;
	}
	return &_viewProjMatrix;
}

-(CC3Matrix4x4*) modelViewProjMatrix {
	if (_isMVPMtxDirty) {
		CC3Matrix4x4 m4x4;
		CC3Matrix4x4PopulateFrom4x3(&m4x4, self.modelViewMatrix);
		CC3Matrix4x4Multiply(&_modelViewProjMatrix, &_projMatrix, &m4x4);
		_isMVPMtxDirty = NO;
	}
	return &_modelViewProjMatrix;
}

-(void) populateProjMatrixFrom: (CC3Matrix*) projMtx {
	if (projMtx)
		[projMtx populateCC3Matrix4x4: &_projMatrix];
	else
		CC3Matrix4x4PopulateIdentity(&_projMatrix);

	_isVPMtxDirty = YES;
	_isMVPMtxDirty = YES;
}

-(void) populateViewMatrixFrom: (CC3Matrix*) viewMtx {
	if (viewMtx)
		[viewMtx populateCC3Matrix4x3: &_viewMatrix];
	else
		CC3Matrix4x3PopulateIdentity(&_viewMatrix);

	_isVPMtxDirty = YES;
	_isMVMtxDirty = YES;
	_isMVPMtxDirty = YES;
}

-(void) populateModelMatrixFrom: (CC3Matrix*) modelMtx {
	if (modelMtx)
		[modelMtx populateCC3Matrix4x3: &_modelMatrix];
	else
		CC3Matrix4x3PopulateIdentity(&_modelMatrix);

	_isMVMtxDirty = YES;
	_isMVPMtxDirty = YES;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_drawingSequencer = nil;
		_currentSkinSection = nil;
		_currentShaderProgram = nil;
		_shouldDecorateNode = YES;
		_shouldClearDepthBuffer = YES;
	}
	return self;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, drawing nodes in seq %@, tex: %i of %i units, decorating: %@, clear depth: %@",
			[super fullDescription], _drawingSequencer, _currentTextureUnitIndex, _textureUnitCount,
			NSStringFromBoolean(_shouldDecorateNode), NSStringFromBoolean(_shouldClearDepthBuffer)];
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

@synthesize pickedNode=_pickedNode;

-(void) dealloc {
	[_pickedNode release];
	[super dealloc];
}

/** Overridden to initially set the shouldDecorateNode to NO. */
-(id) init {
	if ( (self = [super init]) ) {
		_shouldDecorateNode = NO;
	}
	return self;
}

/**
 * Clears the pickedNode property, ensures that lighting, blending, and fog are turned off,
 * so that nodes can be drawn in pure colors, and remembers the current color value so that
 * is can be restored after picking. This is necessary when the scene has no lighting, to
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
	
	[_pickedNode release];
	_pickedNode = nil;
	
	CC3OpenGL* gl = self.gl;
	[gl enableLighting: NO];
	[gl enableBlend: NO];
	[gl enableFog: NO];
	
	// If multisampling antialiasing, bind the picking framebuffer before reading the pixel.
	[CCDirector.sharedDirector.ccGLView openPicking];
}

/**
 * Reads the color of the pixel at the touch point, maps that to the tag of the CC3Node
 * that was touched, and sets the picked node in the pickedNode property.
 *
 * If antialiasing multisampling is active, after reading the color of the touched pixel,
 * the multisampling framebuffer is made active in preparation of normal drawing operations.
 *
 * Draws the backdrop to avoid flicker.
 */
-(void) close {
		
	// Read the pixel from the framebuffer
	ccColor4B pixColor = [self.gl readPixelAt: self.scene.touchedNodePicker.glTouchPoint];
	
	// Fetch the node whose tags is mapped from the pixel color
	_pickedNode = [[self.scene getNodeTagged: [self tagFromColor: pixColor]] retain];

	LogTrace(@"%@ picked %@ from color %@ at position %@",
			 self, _pickedNode, NSStringFromCCC4B(pixColor),
			 NSStringFromCGPoint(self.scene.touchedNodePicker.glTouchPoint));
	
	// If multisampling antialiasing, rebind the multisampling framebuffer
	[CCDirector.sharedDirector.ccGLView closePicking];
	
	[self drawBackdrop];	// Draw the backdrop behind the 3D scene

	[super close];
}


#pragma mark Drawing

/**
 * Overridden because what matters here is not visibility, but touchability.
 * Invisible nodes will be drawn if touchable.
 */
-(BOOL) isNodeVisibleForDrawing: (CC3Node*) aNode { return aNode.isTouchable; }

/** Overridden to draw the node in a uniquely identifiable color. */
-(void) draw: (CC3Node*) aNode {
	[self paintNode: aNode];
	[super draw: aNode];
}

/**
 * Template method that draws the backdrop behind the 3D scene.
 *
 * This method is automatically invoked after the 3D scene has been drawn in pure solid colors, and
 * prior to the second redrawing with the true coloring, to provide an empty canvas on which to draw
 * the real scene, and to make sure that the depth buffer is cleared before the second redrawing.
 *
 * This implementation simply clears the GL color buffer to create an empty canvas. If the CC3Layer
 * has a colored background, that color is used to clear the GL color buffer, otherwise the current
 * GL clearing color is used.
 *
 * To minimize flicker, if the background is translucent, the color buffer is not cleared.
 *
 * In addition, the depth buffer needs to be cleared in between drawing the pure colors for node picking,
 * and drawing the real scene, to ensure that the the two passes do not interfere with each other, which
 * would cause flicker. To that end, if this visitor is configured NOT to clear the depth buffer at the
 * start of each drawing pass, the depth buffer is cleared here when the color buffer is cleared.
 *
 * This use of clearing the color buffer, instead of redrawing the CC3Layer backdrop, is used because
 * redrawing the CC3Layer involves delving back into the 2D scene, and losing knowledge of the GL state.
 *
 * Subclasses can override to do something more sophisticated with the background.
 */
-(void) drawBackdrop {
	CC3OpenGL* gl = self.gl;
	CC3Layer* cc3Layer = self.scene.cc3Layer;
	
	// Only clear the color if the layer is opaque. This is to stop flicker
	// of the background if it is translucent. Unfortunately, flicker WILL occur
	// if BOTH the object and the CC3Layer background are translucent.
	GLbitfield colorFlag = cc3Layer.isOpaque ? GL_COLOR_BUFFER_BIT : 0;
	
	// If the depth buffer will not be cleared as part of normal drawing,
	// do it now, while we are clearing the color buffer.
	GLbitfield depthFlag = _shouldClearDepthBuffer ? 0 : GL_DEPTH_BUFFER_BIT;

	// Ensure that the depth buffer is writable (may have been turned off during node drawing)
	if (depthFlag) gl.depthMask = YES;
	
	// If the CC3Layer has a background color, use it as the GL clear color
	if (colorFlag) {
		if (cc3Layer.isColored) {
			// Remember the current GL clear color
			ccColor4F currClearColor = gl->value_GL_COLOR_CLEAR_VALUE;
			
			// Retrieve the CC3Layer background color
			ccColor4F layerColor = CCC4FFromColorAndOpacity(cc3Layer.color, cc3Layer.opacity);
			
			// Set the GL clear color from the layer color
			gl.clearColor = layerColor;
			LogTrace(@"%@ clearing background to %@ color: %@ %@ clearing depth buffer", self,
					 cc3Layer, NSStringFromCCC4F(layerColor), (depthFlag ? @"and" : @"but not"));
			
			// Clear the color buffer redraw the background, and depth buffer if required
			[gl clearBuffers: (colorFlag | depthFlag)];
			
			// Reinstate the current GL clear color
			gl.clearColor = currClearColor;
			
		} else {
			// Otherwise use the current clear color
			LogTrace(@"%@ clearing background to default clear color: %@ %@ clearing depth buffer",
					 self, NSStringFromCCC4F(gl->value_GL_COLOR_CLEAR_VALUE),
					 (depthFlag ? @"and" : @"but not"));
			
			// Clear the color buffer redraw the background, and depth buffer if required
			[gl clearBuffers: (colorFlag | depthFlag)];
		}
	} else if (depthFlag) {
		LogTrace(@"%@ clearing depth buffer", self);
		[gl clearBuffers: depthFlag];		// Clear the depth buffer only
	} else {
		LogTrace(@"%@ clearing neither color or depth buffer", self);
	}
}

/** Maps the specified node to a unique color, and paints the node with that color. */
-(void) paintNode: (CC3Node*) aNode {
	self.currentColor4B = [self colorFromNodeTag: aNode.tag];
	LogTrace(@"%@ painting %@ with color %@", self, aNode, NSStringFromCCC4B(self.currentColor4B));
}

/**
 * Maps the specified integer tag to a color, by spreading the bits of the integer across
 * the red, green and blue unsigned bytes of the color. This permits 2^24 objects to be
 * encoded by colors. This is the compliment of the tagFromColor: method. The alpha value
 * is set to zero to ensure that the painting is not visible under translucent nodes,
 * especially when translucent nodes are directly painted over the device camera.
 */
-(ccColor4B) colorFromNodeTag: (GLuint) tag {
	GLuint mask = 255;
	GLubyte r = (tag >> 16) & mask;
	GLubyte g = (tag >> 8) & mask;
	GLubyte b = tag & mask;
	return ccc4(r, g, b, 0);	// Zero alpha to ensure coloring is not visible
}

/**
 * Maps the specified color to a tag, by combining the bits of the red, green, and blue
 * colors into a single integer value. This is the compliment of the colorFromNodeTag: method.
 */
-(GLuint) tagFromColor: (ccColor4B) color {
	return ((GLuint)color.r << 16) | ((GLuint)color.g << 8) | (GLuint)color.b;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, picked: %@", super.fullDescription, _pickedNode];
}

@end


#pragma mark -
#pragma mark CC3NodePuncture

@implementation CC3NodePuncture

@synthesize node=_node, sqGlobalPunctureDistance=_sqGlobalPunctureDistance;
@synthesize punctureLocation=_punctureLocation, globalPunctureLocation=_globalPunctureLocation;

-(void) dealloc {
	[_node release];
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) initOnNode: (CC3Node*) aNode fromRay: (CC3Ray) aRay {
	if ( (self = [super init]) ) {
		_node = [aNode retain];
		_punctureLocation = [aNode locationOfGlobalRayIntesection: aRay];
		_globalPunctureLocation = [aNode.transformMatrix transformLocation: _punctureLocation];
		_sqGlobalPunctureDistance = CC3VectorDistanceSquared(_globalPunctureLocation, aRay.startLocation);
	}
	return self;
}

+(id) punctureOnNode: (CC3Node*) aNode fromRay: (CC3Ray) aRay {
	return [[[self alloc] initOnNode: aNode fromRay: aRay] autorelease];
}

@end


#pragma mark -
#pragma mark CC3NodePuncturingVisitor

@implementation CC3NodePuncturingVisitor

@synthesize ray=_ray, shouldPunctureFromInside=_shouldPunctureFromInside;
@synthesize shouldPunctureInvisibleNodes=_shouldPunctureInvisibleNodes;

-(void) dealloc {
	[_nodePunctures release];
	[super dealloc];
}

-(CC3NodePuncture*) nodePunctureAt:  (NSUInteger) index {
	return (CC3NodePuncture*)[_nodePunctures objectAtIndex: index];
}

-(NSUInteger) nodeCount { return _nodePunctures.count; }

-(CC3Node*) puncturedNodeAt: (NSUInteger) index { return [self nodePunctureAt: index].node; }

-(CC3Node*) closestPuncturedNode { return (self.nodeCount > 0) ? [self puncturedNodeAt: 0] : nil; }

-(CC3Vector) punctureLocationAt: (NSUInteger) index {
	return [self nodePunctureAt: index].punctureLocation;
}

-(CC3Vector) closestPunctureLocation {
	return (self.nodeCount > 0) ? [self punctureLocationAt: 0] : kCC3VectorNull;
}

-(CC3Vector) globalPunctureLocationAt: (NSUInteger) index {
	return [self nodePunctureAt: index].globalPunctureLocation;
}

-(CC3Vector) closestGlobalPunctureLocation {
	return (self.nodeCount > 0) ? [self globalPunctureLocationAt: 0] : kCC3VectorNull;
}

-(void) open {
	[super open];
	[_nodePunctures removeAllObjects];
}

/**
 * Utility method that returns whether the specified node is punctured by the ray.
 *   - Returns NO if the node has no bounding volume.
 *   - Returns NO if the node is invisible, unless the shouldPunctureInvisibleNodes property
 *     has been set to YES.
 *   - Returns NO if the ray starts within the bounding volume, unless the 
 *     shouldPunctureFromInside property has been set to YES.
 */
-(BOOL) doesPuncture: (CC3Node*) aNode {
	CC3BoundingVolume* bv = aNode.boundingVolume;
	if ( !bv ) return NO;
	if ( !_shouldPunctureInvisibleNodes && !aNode.visible ) return NO;
	if ( !_shouldPunctureFromInside && [bv doesIntersectLocation: _ray.startLocation] ) return NO;
	return [bv doesIntersectRay: _ray];
}

-(void) processBeforeChildren: (CC3Node*) aNode {
	if ( [self doesPuncture: aNode] ) {
		CC3NodePuncture* np = [CC3NodePuncture punctureOnNode: aNode fromRay: _ray];
		NSUInteger nodeCount = _nodePunctures.count;
		for (NSUInteger i = 0; i < nodeCount; i++) {
			CC3NodePuncture* existNP = [_nodePunctures objectAtIndex: i];
			if (np.sqGlobalPunctureDistance < existNP.sqGlobalPunctureDistance) {
				[_nodePunctures insertObject: np atIndex: i];
				return;
			}
		}
		[_nodePunctures addObject: np];
	}
}

#pragma mark Allocation and initialization

-(id) init { return [self initWithRay: CC3RayFromLocDir(kCC3VectorNull, kCC3VectorNull)]; }

-(id) initWithRay: (CC3Ray) aRay {
	if ( (self = [super init]) ) {
		_ray = aRay;
		_nodePunctures = [[CCArray array] retain];
		_shouldPunctureFromInside = NO;
		_shouldPunctureInvisibleNodes = NO;
	}
	return self;
}

+(id) visitorWithRay: (CC3Ray) aRay { return [[[self alloc] initWithRay: aRay] autorelease]; }

@end
