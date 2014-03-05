/*
 * CC3NodeVisitor.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3GLView.h"

@interface CC3Node (TemplateMethods)
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;
-(void) processUpdateAfterTransform: (CC3NodeUpdatingVisitor*) visitor;
@end

@interface CC3Scene (TemplateMethods)
@property(nonatomic, readonly) CC3TouchedNodePicker* touchedNodePicker;
@end


#pragma mark -
#pragma mark CC3NodeVisitor

@implementation CC3NodeVisitor

@synthesize currentNode=_currentNode, startingNode=_startingNode;
@synthesize shouldVisitChildren=_shouldVisitChildren, camera=_camera;

-(void) dealloc {
	_startingNode = nil;			// weak reference
	_currentNode = nil;				// weak reference
	[_camera release];
	[_pendingRemovals release];
	[super dealloc];
}

-(CC3PerformanceStatistics*) performanceStatistics { return _startingNode.performanceStatistics; }

-(CC3Camera*) camera {
	if (!_camera) self.camera = self.defaultCamera;
	return _camera;
}

-(CC3Camera*) defaultCamera { return _startingNode.activeCamera; }

-(BOOL) visit: (CC3Node*) aNode {
	BOOL rslt = NO;
	
	if (!aNode) return rslt;			// Must have a node to work on
	
	_currentNode = aNode;				// Make the node being processed available. Not retained.

	if (!_startingNode) {				// If this is the first node, start up
		_startingNode = aNode;			// Not retained
		[self open];					// Open the visitor
	}

	rslt = [self process: aNode];		// Process the node and its children recursively

	if (aNode == _startingNode) {		// If we're back to the first node, finish up
		[self close];					// Close the visitor
		_startingNode = nil;			// Not retained
	}
	
	_currentNode = nil;					// Done with this node now.

	return rslt;
}

/** Template method that is invoked automatically during visitation to process the specified node. */
-(BOOL) process: (CC3Node*) aNode {
	BOOL rslt = NO;
	LogTrace(@"%@ visiting %@ %@ children", self, aNode, (_shouldVisitChildren ? @"and" : @"but not"));
	
	[self processBeforeChildren: aNode];	// Heavy lifting before visiting children
	
	// Recurse through the child nodes if required
	if (_shouldVisitChildren) rslt = [self processChildrenOf: aNode];

	[self processAfterChildren: aNode];		// Heavy lifting after visiting children

	return rslt;
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
-(BOOL) processChildrenOf: (CC3Node*) aNode {
	CC3Node* currNode = _currentNode;		// Remember current node
	
	NSArray* children = aNode.children;
	for (CC3Node* child in children) {
		if ( [self visit: child] ) {
			_currentNode = currNode;		// Restore current node
			return YES;
		}
	}
	
	_currentNode = currNode;				// Restore current node
	return NO;
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
	if (!_pendingRemovals) _pendingRemovals = [[NSMutableArray array] retain];
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

-(GLuint) textureCount { return self.currentMeshNode.textureCount; }

-(CC3TextureUnit*) currentTextureUnitAt: (GLuint) texUnit {
	return [self.currentMaterial textureForTextureUnit: texUnit].textureUnit;
}

-(CC3ShaderProgram*) currentShaderProgram { return self.currentMeshNode.shaderProgram; }

-(CC3Mesh*) currentMesh { return self.currentMeshNode.mesh; }

-(NSUInteger) lightCount { return self.scene.lights.count; }

-(CC3Light*) lightAt: (GLuint) index {
	NSArray* lights = self.scene.lights;
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
#pragma mark CC3NodeUpdatingVisitor

@implementation CC3NodeUpdatingVisitor

@synthesize deltaTime=_deltaTime;

-(void) processBeforeChildren: (CC3Node*) aNode {
	LogTrace(@"Updating %@ after %.3f ms", aNode, _deltaTime * 1000.0f);
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
#pragma mark CC3NodeDrawingVisitor

@implementation CC3NodeDrawingVisitor

@synthesize deltaTime=_deltaTime;
@synthesize shouldDecorateNode=_shouldDecorateNode;
@synthesize isDrawingEnvironmentMap=_isDrawingEnvironmentMap;
@synthesize current2DTextureUnit=_current2DTextureUnit;
@synthesize currentCubeTextureUnit=_currentCubeTextureUnit;
@synthesize currentColor=_currentColor;

-(void) dealloc {
	_drawingSequencer = nil;				// weak reference
	_currentSkinSection = nil;				// weak reference
	_gl = nil;								// weak reference
	[_renderSurface release];
	[_boneMatricesGlobal release];
	[_boneMatricesEyeSpace release];
	[_boneMatricesModelSpace release];
	
	[super dealloc];
}

-(CC3OpenGL*) gl {
	if (!_gl) _gl = CC3OpenGL.sharedGL;
	return _gl;
}

-(void) clearGL { _gl = nil; }		// weak reference

-(id<CC3RenderSurface>) renderSurface {
	if ( !_renderSurface ) self.renderSurface = self.defaultRenderSurface;
	return _renderSurface;
}

-(id<CC3RenderSurface>) defaultRenderSurface { return self.scene.viewSurface; }

-(void) setRenderSurface: (id<CC3RenderSurface>) renderSurface {
	if (renderSurface == _renderSurface) return;
	[_renderSurface release];
	_renderSurface = [renderSurface retain];
	[self alignCameraViewport];
}

-(void) setCamera: (CC3Camera*) camera {
	[super setCamera: camera];
	[self alignCameraViewport];
}

-(void) alignCameraViewport {
	// If the viewport of the camera has not been set directly, align it to the surface shape.
	// Invoked during setter. Don't use getter, to avoid infinite recursion when camera is nil.
	if ( CC3ViewportIsZero(_camera.viewport) )
		_camera.viewport = CC3ViewportFromOriginAndSize(kCC3IntPointZero, self.renderSurface.size);
}

-(void) alignShotWith: (CC3NodeDrawingVisitor*) otherVisitor {
	self.camera = otherVisitor.camera;
	self.renderSurface = otherVisitor.renderSurface;
}

/** 
 * Overridden to return either the real shader program, or the pure-color shader program,
 * depending on whether the node should be decorated. For example, during node picking,
 * the node is not decorated, and the pure-color program will be used.
 * The shaderProgram will be selected if it has not been assigned already.
 */
-(CC3ShaderProgram*) currentShaderProgram {
	return (self.shouldDecorateNode
			? self.currentMeshNode.shaderProgram
			: self.currentMeshNode.shaderContext.pureColorProgram);
}

-(void) processBeforeChildren: (CC3Node*) aNode {
	[self.performanceStatistics incrementNodesVisitedForDrawing];
	if ([self shouldDrawNode: aNode]) [aNode transformAndDrawWithVisitor: self];
	_currentSkinSection = nil;
}

-(BOOL) shouldDrawNode: (CC3Node*) aNode {
	return aNode.hasLocalContent
			&& [self isNodeVisibleForDrawing: aNode]
			&& [self doesNodeIntersectFrustum: aNode];
}

/** If we're drawing in clip-space, ignore the frustum. */
-(BOOL) doesNodeIntersectFrustum: (CC3Node*) aNode {
	return [aNode doesIntersectFrustum: self.camera.frustum];
}

-(BOOL) isNodeVisibleForDrawing: (CC3Node*) aNode { return aNode.visible; }

-(BOOL) processChildrenOf: (CC3Node*) aNode {
	if ( !_drawingSequencer ) return [super processChildrenOf: aNode];

	// Remember current node and whether children should be visited
	CC3Node* currNode = _currentNode;
	BOOL currSVC = _shouldVisitChildren;
	
	_shouldVisitChildren = NO;	// Don't delve into node hierarchy if using sequencer
	[_drawingSequencer visitNodesWithNodeVisitor: self];
	
	// Restore current node and whether children should be visited
	_shouldVisitChildren = currSVC;
	_currentNode = currNode;
	
	return NO;
}

/** Prepares GL programs, activates the rendering surface, and opens the scene and the camera. */
-(void) open {
	[super open];

	[CC3ShaderProgram willBeginDrawingScene];

	[self activateRenderSurface];
	[self openScene];
	[self openCamera];
}

/** Activates the render surface. Subsequent GL drawing will be directed to this surface. */
-(void) activateRenderSurface { [self.renderSurface activate]; }

/** If this visitor was started on a CC3Scene node, set up for drawing an entire scene. */
-(void) openScene {
	if ( !_startingNode.isScene) return;
	CC3Scene* scene = self.scene;
	_deltaTime = scene.deltaFrameTime;
	_drawingSequencer = scene.drawingSequencer;
}

/** Template method that opens the 3D camera. */
-(void) openCamera {
	[self.camera openWithVisitor: self];

#if !CC3_GLSL
	// Hack for OpenGL & OpenGL ES fixed pipeline to force update of light position/direction
	// AFTER modelview matrix has been updated, as required by OpenGL fixed pipeline.
	// See http://www.opengl.org/archives/resources/faq/technical/lights.htm#ligh0050
	[self.scene illuminateWithVisitor: self];
#endif	// !CC3_GLSL

}

/** Close the camera. */
-(void) close {
	[self closeCamera];
	_drawingSequencer = nil;
	[super close];
}

/** Close the camera. This is the compliment of the openCamera method. */
-(void) closeCamera { [self.camera closeWithVisitor: self]; }

-(void) draw: (CC3Node*) aNode {
	LogTrace(@"Drawing %@", aNode);
	[aNode drawWithVisitor: self];
	[self.performanceStatistics incrementNodesDrawn];
}

-(void) resetTextureUnits {
	// Under OGLES 2.0 & OGL, the required texture units are determined by the shader uniforms.
	// Under OGLES 1.1, they are determined by the number of textures attached to the mesh node.
	CC3ShaderProgram* sp = self.currentShaderProgram;
	_current2DTextureUnit = 0;
	_currentCubeTextureUnit = sp ? sp.texture2DCount : self.textureCount;
}

-(void) disableUnusedTextureUnits {

	// Determine the maximum number of textures of each type that could be used
	// Under OGLES 2.0 & OGL, this is determined by the shader uniforms.
	// Under OGLES 1.1, this is determined by the number of textures attached to the mesh node.
	CC3ShaderProgram* sp = self.currentShaderProgram;
	GLuint tex2DMax = sp ? sp.texture2DCount : self.textureCount;
	GLuint texCubeMax = tex2DMax + (sp ? sp.textureCubeCount : 0);
	CC3OpenGL* gl = self.gl;
	
	// Disable remaining unused 2D textures
	for (GLuint tuIdx = _current2DTextureUnit; tuIdx < tex2DMax; tuIdx++)
		[gl disableTexturingAt: tuIdx];
	
	// Disable remaining unused cube textures
	for (GLuint tuIdx = _currentCubeTextureUnit; tuIdx < texCubeMax; tuIdx++)
		[gl disableTexturingAt: tuIdx];
	
	// Ensure remaining system texture units are disabled
	[gl disableTexturingFrom: texCubeMax];
}


#pragma mark Accessing node contents

-(ccColor4B) currentColor4B { return CCC4BFromCCC4F(self.currentColor); }

-(void) setCurrentColor4B: (ccColor4B) color4B { self.currentColor = CCC4FFromCCC4B(color4B); }

-(CC3SkinSection*) currentSkinSection { return _currentSkinSection; }

-(void) setCurrentSkinSection: (CC3SkinSection*) currentSkinSection {
	_currentSkinSection = currentSkinSection;
	[self resetBoneMatrices];
}


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
	if ( !projMtx || _currentNode.shouldDrawInClipSpace)
		CC3Matrix4x4PopulateIdentity(&_projMatrix);
	else
		[projMtx populateCC3Matrix4x4: &_projMatrix];

	_isVPMtxDirty = YES;
	_isMVPMtxDirty = YES;

	// For fixed rendering pipeline, also load onto the matrix stack
	[self.gl loadProjectionMatrix: &_projMatrix];
}

-(void) populateViewMatrixFrom: (CC3Matrix*) viewMtx {
	if ( !viewMtx || _currentNode.shouldDrawInClipSpace)
		CC3Matrix4x3PopulateIdentity(&_viewMatrix);
	else
		[viewMtx populateCC3Matrix4x3: &_viewMatrix];
	
	_isVPMtxDirty = YES;
	_isMVMtxDirty = YES;
	_isMVPMtxDirty = YES;
	
	// For fixed rendering pipeline, also load onto the matrix stack
	[self.gl loadModelviewMatrix: &_viewMatrix];
}

-(void) populateModelMatrixFrom: (CC3Matrix*) modelMtx {
	if ( !modelMtx )
		CC3Matrix4x3PopulateIdentity(&_modelMatrix);
	else
		[modelMtx populateCC3Matrix4x3: &_modelMatrix];
	
	_isMVMtxDirty = YES;
	_isMVPMtxDirty = YES;
	
	// For fixed rendering pipeline, also load onto the matrix stack
	[self.gl loadModelviewMatrix: self.modelViewMatrix];
}

-(CC3Matrix4x3*) globalBoneMatrixAt: (GLuint) index {
	[self ensureBoneMatrices: _boneMatricesGlobal forSpace: self.modelMatrix];
	return [_boneMatricesGlobal elementAt: index];
}

-(CC3Matrix4x3*) eyeSpaceBoneMatrixAt: (GLuint) index {
	[self ensureBoneMatrices: _boneMatricesEyeSpace forSpace: self.modelViewMatrix];
	return [_boneMatricesEyeSpace elementAt: index];
}

-(CC3Matrix4x3*) modelSpaceBoneMatrixAt: (GLuint) index {
	[self ensureBoneMatrices: _boneMatricesModelSpace forSpace: NULL];
	return [_boneMatricesModelSpace elementAt: index];
}

/**
 * Ensures that the specified bone matrix array has been populated from the bones of the
 * current skin section. If the specified space matrix is not NULL, it is used to transform
 * the bone matrices into some other space (eg- global space, eye space), otherwise, the
 * bone matrices are left in their local space coordinates (model space).
 * Once populated, the bone matrix array is marked as being ready, so it won't be populated
 * again until being marked as not ready.
 */
-(void) ensureBoneMatrices: (CC3DataArray*) boneMatrices forSpace: (CC3Matrix4x3*) spaceMatrix {
	if (boneMatrices.isReady) return;
	
	CC3Matrix4x3 sbMtx;
	CC3SkinSection* skin = self.currentSkinSection;
	GLuint boneCnt = skin.boneCount;
	[boneMatrices ensureElementCapacity: boneCnt];
	for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
		CC3Matrix* boneMtx = [skin transformMatrixForBoneAt: boneIdx];
		CC3Matrix4x3* pBoneSpaceMtx = [boneMatrices elementAt: boneIdx];
		if (spaceMatrix) {
			// Use the space matrix to transform the bone matrix.
			[boneMtx populateCC3Matrix4x3: &sbMtx];
			CC3Matrix4x3Multiply(pBoneSpaceMtx, spaceMatrix, &sbMtx);
		} else
			[boneMtx populateCC3Matrix4x3: pBoneSpaceMtx];	// Use the untransformed bone matrix.
	}
	boneMatrices.isReady = YES;
}

/** Resets the bone matrices so they will be populated when requested for the current skin section. */
-(void) resetBoneMatrices {
	_boneMatricesGlobal.isReady = NO;
	_boneMatricesEyeSpace.isReady = NO;
	_boneMatricesModelSpace.isReady = NO;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_gl = nil;
		_renderSurface = nil;
		_drawingSequencer = nil;
		_currentSkinSection = nil;
		_boneMatricesGlobal = [[CC3DataArray alloc] initWithElementSize: sizeof(CC3Matrix4x3)];	// retained
		_boneMatricesEyeSpace = [[CC3DataArray alloc] initWithElementSize: sizeof(CC3Matrix4x3)];	// retained
		_boneMatricesModelSpace = [[CC3DataArray alloc] initWithElementSize: sizeof(CC3Matrix4x3)];	// retained
		CC3Matrix4x3PopulateIdentity(&_modelMatrix);
		CC3Matrix4x3PopulateIdentity(&_viewMatrix);
		CC3Matrix4x4PopulateIdentity(&_projMatrix);
		_isVPMtxDirty = YES;
		_isMVMtxDirty = YES;
		_isMVPMtxDirty = YES;
		_shouldDecorateNode = YES;
		_isDrawingEnvironmentMap = NO;
	}
	return self;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, drawing %@nodes in seq %@", [super fullDescription],
			(_shouldDecorateNode ? @"and decorating " : @""), _drawingSequencer];
}

@end


#pragma mark -
#pragma mark CC3NodePickingVisitor

@implementation CC3NodePickingVisitor

@synthesize tagColorShift=_tagColorShift;

-(void) dealloc {
	[_pickedNode release];
	[super dealloc];
}

/** 
 * Since node picking is asynchronous, the picked node is retained when stored here.
 * When accessing, retain and autorelease it, then release and clear the iVar.
 * In the case where this is the last reference, the retain/autorelease will ensure
 * it continues to live for processing by the caller.
 */
-(CC3Node*)pickedNode {
	CC3Node* pn = [[_pickedNode retain] autorelease];
	[_pickedNode release];
	_pickedNode = nil;
	return pn;
}

/** Overridden to initially set the shouldDecorateNode to NO. */
-(id) init {
	if ( (self = [super init]) ) {
		_pickedNode = nil;
		_shouldDecorateNode = NO;
		_tagColorShift = 0;
	}
	return self;
}

/** Clears the render surface and the pickedNode property. */
-(void) open {
	[super open];
	[self.renderSurface clearColorAndDepthContent];
}

/**
 * Reads the color of the pixel at the touch point, maps that to the tag of the CC3Node
 * that was touched, and sets the picked node in the pickedNode property.
 *
 * Clears the depth buffer in case the primary scene rendering is using the same surface.
 */
-(void) close {
		
	// Read the pixel from the framebuffer
	ccColor4B pixColor;
	CC3IntPoint touchPoint = CC3IntPointFromCGPoint([self.camera glPointFromCC2Point: self.scene.touchedNodePicker.touchPoint]);
	[self.renderSurface readColorContentFrom: CC3ViewportMake(touchPoint.x, touchPoint.y, 1, 1) into: &pixColor];
	
	// Fetch the node whose tags is mapped from the pixel color
	[_pickedNode release];
	_pickedNode = [[self.scene getNodeTagged: [self tagFromColor: pixColor]] retain];

	LogTrace(@"%@ picked %@ from color %@ at position %@", self, _pickedNode,
			 NSStringFromCCC4B(pixColor), NSStringFromCC3IntPoint(touchPoint));
	
	[self.renderSurface clearDepthContent];

	[super close];
}


#pragma mark Drawing

-(id<CC3RenderSurface>) defaultRenderSurface { return self.scene.pickingSurface; }

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

/** Maps the specified node to a unique color, and paints the node with that color. */
-(void) paintNode: (CC3Node*) aNode {
	self.currentColor4B = [self colorFromNodeTag: aNode.tag];
	LogTrace(@"%@ painting %@ with color %@", self, aNode, NSStringFromCCC4B(self.currentColor4B));
}

/**
 * Maps the specified integer tag to a color, by spreading the bits of the integer across
 * the red, green and blue unsigned bytes of the color. This permits 2^24 objects to be
 * encoded by colors. This is the compliment of the tagFromColor: method.
 */
-(ccColor4B) colorFromNodeTag: (GLuint) tag {
	tag <<= _tagColorShift;
	GLuint mask = 255;
	GLubyte r = (tag >> 16) & mask;
	GLubyte g = (tag >> 8) & mask;
	GLubyte b = tag & mask;
	return ccc4(r, g, b, 0);	// Alpha ignored during pure-color painting
}

/**
 * Maps the specified color to a tag, by combining the bits of the red, green, and blue
 * colors into a single integer value. This is the compliment of the colorFromNodeTag: method.
 */
-(GLuint) tagFromColor: (ccColor4B) color {
	return (((GLuint)color.r << 16) | ((GLuint)color.g << 8) | (GLuint)color.b) >> _tagColorShift;
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
		_globalPunctureLocation = [aNode.globalTransformMatrix transformLocation: _punctureLocation];
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
		_nodePunctures = [[NSMutableArray array] retain];
		_shouldPunctureFromInside = NO;
		_shouldPunctureInvisibleNodes = NO;
	}
	return self;
}

+(id) visitorWithRay: (CC3Ray) aRay { return [[[self alloc] initWithRay: aRay] autorelease]; }

@end


#pragma mark -
#pragma mark CC3NodeTransformingVisitor

@implementation CC3NodeTransformingVisitor
-(BOOL) shouldLocalizeToStartingNode { return NO; }
-(void) setShouldLocalizeToStartingNode: (BOOL) shouldLocalizeToStartingNode {}
-(BOOL) shouldRestoreTransforms { return NO; }
-(void) setShouldRestoreTransforms: (BOOL) shouldRestoreTransforms {}
-(BOOL) isTransformDirty { return NO; }
-(CC3Matrix*) parentTansformMatrixFor: (CC3Node*) aNode { return aNode.parent.globalTransformMatrix; }
@end


#pragma mark -
#pragma mark Deprecated CC3NodeBoundingBoxVisitor

@implementation CC3NodeBoundingBoxVisitor

@synthesize boundingBox=_boundingBox;
@synthesize shouldLocalizeToStartingNode=_shouldLocalizeToStartingNode;

-(void) close {
	_boundingBox = (_shouldLocalizeToStartingNode
					? _startingNode.boundingBox
					: _startingNode.globalBoundingBox);
	[super close];
}

@end
