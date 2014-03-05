/*
 * CC3Scene.m
 *
 * cocos3d 2.0.0
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
 * See header file CC3Scene.h for full API documentation.
 */

#import "CC3Scene.h"
#import "CC3Layer.h"
#import "CC3MeshNode.h"
#import "CC3Material.h"
#import "CC3Light.h"
#import "CC3Billboard.h"
#import "CC3ShadowVolumes.h"
#import "CC3AffineMatrix.h"
#import "CC3CC2Extensions.h"
#import "CGPointExtension.h"
#import "ccMacros.h"


#pragma mark -
#pragma mark CC3Scene

@interface CC3Node (TemplateMethods)
@property(nonatomic, unsafe_unretained, readwrite) CC3Node* parent;	// Backdrop needs to have parent set
@end


@implementation CC3Scene

@synthesize cc3Layer=_cc3Layer, ambientLight=_ambientLight, touchedNodePicker=_touchedNodePicker;
@synthesize minUpdateInterval=_minUpdateInterval, maxUpdateInterval=_maxUpdateInterval;
@synthesize drawingSequenceVisitor=_drawingSequenceVisitor;
@synthesize viewDrawingVisitor=_viewDrawingVisitor, shadowVisitor=_shadowVisitor;
@synthesize envMapDrawingVisitor=_envMapDrawingVisitor;
@synthesize updateVisitor=_updateVisitor;
@synthesize performanceStatistics=_performanceStatistics;
@synthesize deltaFrameTime=_deltaFrameTime, backdrop=_backdrop, fog=_fog, lights=_lights;
@synthesize elapsedTimeSinceOpened=_elapsedTimeSinceOpened;

/**
 * Descendant nodes will be removed by superclass. Their removal may invoke
 * didRemoveDescendant:, which references several of these instance variables.
 * Make sure they are all made nil in addition to being released here!
 */
-(void) dealloc {
	LogInfo(@"Deallocating %@ on thread %@", self, NSThread.currentThread);
	
	self.cc3Layer = nil;					// Use setter to make nil
	self.backdrop = nil;					// Use setter to stop any actions
	self.fog = nil;							// Use setter to stop any actions
	self.activeCamera = nil;				// Use setter to release and make nil
	self.drawingSequencer = nil;			// Use setter to release and make nil
	self.drawingSequenceVisitor = nil;		// Use setter to release and make nil
	self.viewDrawingVisitor = nil;			// Use setter to release and make nil
	self.envMapDrawingVisitor = nil;		// Use setter to release and make nil
	self.updateVisitor = nil;				// Use setter to release and make nil
	self.shadowVisitor = nil;				// Use setter to release and make nil
	self.touchedNodePicker = nil;			// Use setter to release and make nil
	self.performanceStatistics = nil;		// Use setter to release and make nil
	
	[_lights release];
	_lights = nil;							// Make nil so won't be referenced during parent dealloc
	[_billboards release];
	_billboards = nil;						// Make nil so won't be referenced during parent dealloc
	
	[super dealloc];
}

-(BOOL) isScene { return YES; }

-(CC3ViewController*) controller { return _cc3Layer.controller; }

-(CC3Camera*) activeCamera { return _activeCamera; }

-(void) setActiveCamera: (CC3Camera*) aCamera {
	if (aCamera == _activeCamera) return;
	
	CC3Camera* oldCam = _activeCamera;
	_activeCamera = [aCamera retain];
	[self activeCameraChangedFrom: oldCam];
	[oldCam release];
}

/** The active camera has changed. Update whoever cares. */
-(void) activeCameraChangedFrom: (CC3Camera*) oldCam {

	CC3Camera* newCam = self.activeCamera;
	
	// Update the visitors that make use of the active camera
	self.updateVisitor.camera = newCam;
	self.viewDrawingVisitor.camera = newCam;
	self.shadowVisitor.camera = newCam;
	self.touchedNodePicker.pickVisitor.camera = newCam;

	// Ensure camera screen-rendering configuration is preserved
	newCam.viewport = oldCam.viewport;
	newCam.hasInfiniteDepthOfField = oldCam.hasInfiniteDepthOfField;
	
	// Move camera listeners (eg- shadow casting volumes && nodes targetting the camera) to new camera.
	// If the listener is a node that should always target the camera, or its target is already the old
	// camera, set its target to the new camera. Otherwise, just transfer the listener.
	NSSet* camListeners = oldCam.transformListeners;
	for(id<CC3NodeTransformListenerProtocol> aListener in camListeners) {
		CC3Node* tn = (CC3Node*)aListener;
		if ([tn isKindOfClass: [CC3Node class]] &&
			(tn.shouldAutotargetCamera || (oldCam && (tn.target == oldCam)))) {
			tn.target = newCam;
		} else {
			[oldCam removeTransformListener: aListener];
			[newCam addTransformListener: aListener];
		}
	}
}

-(void) setBackdrop: (CC3MeshNode*) backdrop {
	if (backdrop == _backdrop) return;
	
	[_backdrop stopAllActions];		// Ensure all actions stopped before releasing
	
	[_backdrop release];
	_backdrop = [backdrop retain];
	
	_backdrop.parent = self;		// Ensure shaders can access scene content
}

-(void) setFog: (CC3Fog*) fog {
	if (fog == _fog) return;
	
	[_fog stopAllActions];			// Ensure all actions stopped before releasing

	[_fog release];
	_fog = [fog retain];

	_fog.parent = self;				// Ensure shaders can access scene content
}

-(void) setIsRunning: (BOOL) shouldRun {
	[super setIsRunning: shouldRun];

	_backdrop.isRunning = shouldRun;
	_fog.isRunning = shouldRun;
}

// Deprecated
-(BOOL) shouldClearDepthBuffer { return NO; }
-(void) setShouldClearDepthBuffer: (BOOL) shouldClear {}
-(BOOL) shouldClearDepthBufferBefore2D { return NO; }
-(void) setShouldClearDepthBufferBefore2D: (BOOL) shouldClear {}
-(BOOL) shouldClearDepthBufferBefore3D { return NO; }
-(void) setShouldClearDepthBufferBefore3D: (BOOL) shouldClear {}
-(id) transformVisitor { return nil; }
-(void) setTransformVisitor: (id) transformVisitor {}


#pragma mark CCRGBAProtocol and CCBlendProtocol support

-(ccColor3B) color { return _backdrop ? _backdrop.color : super.color; }

-(void) setColor: (ccColor3B) color { _backdrop.color = color; }

-(GLubyte) opacity { return _backdrop ? _backdrop.opacity : super.opacity; }

-(void) setOpacity: (GLubyte) opacity {
	_backdrop.opacity = opacity;
	super.opacity = opacity;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_lights = [NSMutableArray new];			// retained
		_billboards = [NSMutableArray new];		// retained
		self.drawingSequenceVisitor = [CC3NodeSequencerVisitor visitorWithScene: self];
		self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirst];
		self.viewDrawingVisitor = [[self viewDrawVisitorClass] visitor];
		self.envMapDrawingVisitor = nil;
		self.shadowVisitor = nil;
		self.updateVisitor = [[self updateVisitorClass] visitor];
		self.touchedNodePicker = [CC3TouchedNodePicker pickerOnScene: self];
		_cc3Layer = nil;
		_backdrop = nil;
		_fog = nil;
		_activeCamera = nil;
		_performanceStatistics = nil;
		_ambientLight = kCC3DefaultLightColorAmbientScene;
		_minUpdateInterval = kCC3DefaultMinimumUpdateInterval;
		_maxUpdateInterval = kCC3DefaultMaximumUpdateInterval;
		_deltaFrameTime = 0;
		_timeAtOpen = 0;
		_elapsedTimeSinceOpened = 0;
		_shouldDisplayPickingRender = NO;
		[self initializeSceneAndClose3D];
		LogGLErrorState(@"after initializing %@", self);
	}
	return self;
}

-(void) initializeSceneAndClose3D {
	[self initializeScene];
	[self close3DWithVisitor: _viewDrawingVisitor];
}

// Default does nothing. Subclasses will customize.
-(void) initializeScene {}

+(id) scene { return [[self new] autorelease]; }

-(void) populateFrom: (CC3Scene*) another {
	[super populateFrom: another];
	
	// Lights, targetting nodes, billboards & drawing sequence collections,
	// plus activeCamera will be populated as children are added.
	// No need to configure node picker.
	
	self.drawingSequencer = [another.drawingSequencer autoreleasedCopy];
	self.performanceStatistics = [another.performanceStatistics autoreleasedCopy];

	// Env map visitor is created lazily
	self.viewDrawingVisitor = [[another.viewDrawingVisitor class] visitor];		// retained
	self.shadowVisitor = [[another.shadowVisitor class] visitor];				// retained
	self.updateVisitor = [[another.updateVisitor class] visitor];				// retained
	self.drawingSequenceVisitor = [[another.drawingSequenceVisitor class] visitorWithScene: self];	// retained
	self.touchedNodePicker = [[another.touchedNodePicker class] pickerOnScene: self];		// retained

	self.backdrop = [another.backdrop autoreleasedCopy];
	self.fog = [another.fog autoreleasedCopy];
	
	_ambientLight = another.ambientLight;
	_minUpdateInterval = another.minUpdateInterval;
	_maxUpdateInterval = another.maxUpdateInterval;
	_shouldDisplayPickingRender = another.shouldDisplayPickingRender;
}


#pragma mark Updating scene state

-(void) open {
	_timeAtOpen = NSDate.timeIntervalSinceReferenceDate;
	_elapsedTimeSinceOpened = 0;
	[self play];
	[self updateScene];
	[self onOpen];
}

-(void) onOpen {}

-(void) close {
	[self pause];
	[self onClose];
}

-(void) onClose {}

-(void) play { self.isRunning = YES; }

-(void) pause { self.isRunning = NO; }

/**
 * If needed, clamps the specified interval value, then invokes a sequence of template methods.
 * Does nothing except update times if this instance is not running.
 */
-(void) updateScene: (CCTime) dt {
	[self updateTimes: dt];

	if( !self.isRunning) return;

	// Clamp the specified interval to a range defined by the minimum and maximum
	// update intervals. If the maximum update interval limit is zero or negative,
	// its value is ignored, and the dt value is not limited to a maximum value.
	_deltaFrameTime = CLAMP(dt, _minUpdateInterval,
							(_maxUpdateInterval > 0.0 ? _maxUpdateInterval : dt));
	
	LogTrace(@"******* %@ starting update: %.2f ms (clamped from %.2f ms)",
			 self, _deltaFrameTime * 1000.0, dt * 1000.0);
	
	[_touchedNodePicker dispatchPickedNode];
	
	_updateVisitor.deltaTime = _deltaFrameTime;
	[_updateVisitor visit: self];
	
	[self updateCamera: _deltaFrameTime];
	[self updateBillboards: _deltaFrameTime];
	[self updateShadows: _deltaFrameTime];
	[self updateDrawSequence];
	
	LogTrace(@"******* %@ exiting update", self);
}

-(void) updateScene {
	BOOL wasRunning = _isRunning;
	_isRunning = YES;
	[self updateScene: _minUpdateInterval];
	_isRunning = wasRunning;
}

/** Updates various scene timing values. */
-(void) updateTimes: (CCTime) dt {
	_elapsedTimeSinceOpened = NSDate.timeIntervalSinceReferenceDate - _timeAtOpen;
	[_performanceStatistics addUpdateTime: dt];
}

/** Template method to update the camera. */
-(void) updateCamera: (CCTime) dt {}

/** Template method to update shadows cast by the lights. */
-(void) updateShadows: (CCTime) dt { for (CC3Light* lgt in _lights) [lgt updateShadows]; }

/**
 * Template method to update any billboards.
 * Iterates through all billboards, instructing them to align with the camera if needed.
 */
-(void) updateBillboards: (CCTime) dt {
	for (CC3Billboard* bb in _billboards) [bb alignToCamera: _activeCamera];
	LogTrace(@"%@ updated %u billboards", self, _billboards.count);
}

/**
 * Returns the class of visitor that will be instantiated in the updateScene:
 * method to perform update operations.
 *
 * The returned class must be a subclass of CC3NodeUpdatingVisitor. This implementation
 * returns CC3NodeUpdatingVisitor. Subclasses may override the visitor class to
 * customize the behaviour during update visits.
 */
-(id) updateVisitorClass { return [CC3NodeUpdatingVisitor class]; }


#pragma mark Drawing

-(CC3GLViewSurfaceManager*) viewSurfaceManager { return self.controller.view.surfaceManager; }

-(id<CC3RenderSurface>) viewSurface { return self.viewSurfaceManager.renderingSurface; }

-(id<CC3RenderSurface>) pickingSurface { return self.viewSurfaceManager.pickingSurface; }

-(void) drawScene { [self drawSceneWithVisitor: _viewDrawingVisitor]; }
	
-(void) drawSceneWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ( !self.visible ) return;
	
	// Check and clear any GL error that occurred before 3D code
	LogGLErrorState(@"before drawing %@", self);
	LogTrace(@"******* %@ entering drawing visit", self);
	
	[self collectFrameInterval];	// Collect the frame interval in the performance statistics.

	[self open3DWithVisitor: visitor];
	
	[_touchedNodePicker pickTouchedNode];
	
	if (!_shouldDisplayPickingRender) [self drawSceneContentWithVisitor: visitor];

	[self close3DWithVisitor: visitor];
	[self draw2DBillboardsWithVisitor: visitor];	// Back to 2D now

	// Check and clear any GL error that occurred during 3D code
	LogGLErrorState(@"after drawing %@", self);
	LogTrace(@"******* %@ exiting drawing visit", self);
}

-(void) drawSceneContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[self illuminateWithVisitor: visitor];		// Light up your world!
	[self drawBackdropWithVisitor: visitor];	// Draw the backdrop if it exists

	[visitor visit: self];						// Draw the scene components
	
	// Shadows are drawn with a specialized visitor
	[_shadowVisitor alignShotWith: visitor];
	[self drawShadowsWithVisitor: _shadowVisitor];
}

-(void) drawSceneContentForEnvironmentMapWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.renderSurface clearColorAndDepthContent];
	[self drawSceneContentWithVisitor: visitor];
}

-(void) drawBackdropWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (self.controller.isOverlayingDeviceCamera) return;
	[visitor visit: self.backdrop];
}

/**
 * Extract the interval since the previous frame from the CCDirector,
 * and add it to the performance statistics.
 */
-(void) collectFrameInterval {
	if (_performanceStatistics)
		[_performanceStatistics addFrameTime: [[CCDirector sharedDirector] frameInterval]];
}

-(void) open3DWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ opening the 3D scene", self);
	[visitor.gl alignFor3DDrawing];
}

-(void) close3DWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ closing the 3D scene", self);

	CC3OpenGL* gl = visitor.gl;
	
	// Setup drawing configuration for cocos2d
	[gl alignFor2DDrawing];

	// Re-align culling as expected by cocos2d
	[gl enableCullFace: NO];
	gl.cullFace = GL_BACK;
	gl.frontFace = GL_CCW;

	// Make sure the drawing surface is set back to the view surface
	[self.viewSurface activate];

	// Set depth testing to 2D values, and close depth testing,
	// either by turning it off, or clearing the depth buffer
	gl.depthFunc = GL_LEQUAL;
	gl.depthMask = YES;
	[self closeDepthTestWithVisitor: visitor];
	
	// Reset the viewport to the 2D canvas and disable scissor clipping to the viewport.
	CGSize viewSize = CCDirector.sharedDirector.viewSizeInPixels;
	gl.viewport = CC3ViewportMake(0, 0, viewSize.width, viewSize.height);
	[gl enableScissorTest: NO];

	// Disable lights and fog. Done outside alignFor2DDrawing: because they apply to billboards
	[gl enableLighting: NO];
	[gl enableTwoSidedLighting: NO];
	for (CC3Light* lgt in _lights) [lgt turnOffWithVisitor: visitor];
	[gl enableFog: NO];
}

-(void) closeDepthTestWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.gl enableDepthTest: NO];
}

-(void) illuminateWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[CC3Light disableReservedLightsWithVisitor: visitor];	// disable any lights used by 2D scene

	LogTrace(@"%@ lighting is %@", self, (self.isIlluminated ? @"on" : @"off"));

	// Set the ambient light for the whole scene
	visitor.gl.sceneAmbientLightColor = _ambientLight;

	// Turn on any individual lights
	for (CC3Light* lgt in _lights) [lgt turnOnWithVisitor: visitor];

	[self configureFogWithVisitor: visitor];
}

-(BOOL) isIlluminated {
	return (_lights.count > 0 ||
			!(ccc4FEqual(_ambientLight, kCCC4FBlack) ||
			  ccc4FEqual(_ambientLight, kCCC4FBlackTransparent)));
}

-(ccColor4F) totalIllumination {
	ccColor4F totLgt = self.ambientLight;
	LogTrace(@"Start with scene ambient illumination %@", NSStringFromCCC4F(totLgt));
	for (CC3Light* lgt in _lights) {
		if (lgt.visible) {
			LogTrace(@"Adding illumination from %@", lgt.fullDescription);
			ccColor4F la = lgt.ambientColor;
			ccColor4F ld = lgt.diffuseColor;
			totLgt.r += (la.r + ld.r);
			totLgt.g += (la.g + ld.g);
			totLgt.b += (la.b + ld.b);
			totLgt.a += (la.a + ld.a);
		}
	}
	return totLgt;
}

-(void) updateRelativeLightIntensities {
	ccColor4F totLgt = self.totalIllumination;
	for (CC3Light* lgt in _lights) [lgt updateRelativeIntensityFrom: totLgt];
}

-(BOOL) doesContainShadows { return _shadowVisitor != nil; }

/** Template method to draw shadows cast by the lights. */
-(void) drawShadowsWithVisitor:  (CC3NodeDrawingVisitor*) visitor {
	if ( !self.doesContainShadows ) return;
	visitor.gl.clearStencil = 0;
	[visitor.renderSurface clearStencilContent];
	for (CC3Light* lgt in _lights) [lgt drawShadowsWithVisitor: visitor];
}

/** If this scene contains fog, configure it in the GL engine. */
-(void) configureFogWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.gl bindFog: _fog withVisitor: visitor];
}

/**
 * Draws any 2D overlay billboards.
 * This is invoked after close3D, so the drawing of billboards occurs in 2D.
 */
-(void) draw2DBillboardsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ drawing %i billboards", self, _billboards.count);
	CC3Viewport vp = self.activeCamera.viewport;
	CGRect localBounds = CGRectMake(0.0f, 0.0f, vp.w, vp.h);
	for (CC3Billboard* bb in _billboards) [bb draw2dWithinBounds: localBounds];
}

-(id) viewDrawVisitorClass { return [CC3NodeDrawingVisitor class]; }

-(CC3NodeDrawingVisitor*) envMapDrawingVisitor {
	if ( !_envMapDrawingVisitor ) {
		self.envMapDrawingVisitor = [[self viewDrawVisitorClass] visitor];
		_envMapDrawingVisitor.isDrawingEnvironmentMap = YES;
		_envMapDrawingVisitor.camera = [CC3Camera nodeWithName: @"EnvMapCamera"];
		_envMapDrawingVisitor.camera.fieldOfView = 90.0f;
	}
	return _envMapDrawingVisitor;
}


#pragma mark Drawing sequencer

-(BOOL) isUsingDrawingSequence { return (_drawingSequencer != nil); }

-(CC3NodeSequencer*) drawingSequencer { return _drawingSequencer; }

/**
 * Property setter overridden to add all the decendent nodes of this scene
 * into the new  node sequencer.
 */
-(void) setDrawingSequencer:(CC3NodeSequencer*) aNodeSequencer {
	if (aNodeSequencer == _drawingSequencer) return;
	
	[_drawingSequencer release];
	_drawingSequencer = [aNodeSequencer retain];
	
	if (_drawingSequencer) {
		NSArray* allNodes = [self flatten];
		for (CC3Node* aNode in allNodes)
			[_drawingSequencer add: aNode withVisitor: _drawingSequenceVisitor];
	}
}

-(void) updateDrawSequence {
	if (_drawingSequencer && _drawingSequencer.allowSequenceUpdates) {
		[_drawingSequencer updateSequenceWithVisitor: _drawingSequenceVisitor];
		LogTrace(@"%@ updated %@", self, [_drawingSequencer fullDescription]);
	}
}

/**
 * A property on a descendant node has changed that potentially affects its order in
 * the drawing sequence. To put it in the correct drawing order, remove it from the
 * drawingSequencer and then re-add it.
 */
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode {
	if (_drawingSequencer)
		if ([_drawingSequencer remove: aNode withVisitor: _drawingSequenceVisitor])
			[_drawingSequencer add: aNode withVisitor: _drawingSequenceVisitor];
}


#pragma mark Node structural hierarchy

/** Overridden. I am the scene. */
-(CC3Scene*) scene { return self; }

/**
 * Overridden to attempt to add each node to the drawingSequencer, and to add any nodes
 * that require special handling, like cameras, lights and billboards to their respective
 * caches. The node being added is first flattened, so that this processing is performed
 * not only on that node, but all its hierarchical decendants.
 */
-(void) didAddDescendant: (CC3Node*) aNode {
	LogTrace(@"Adding %@ as descendant to %@", aNode, self);
	
	// Collect all the nodes being added, including all descendants,
	// and see if they require special treatment
	NSArray* allAdded = [aNode flatten];
	for (CC3Node* addedNode in allAdded) {
	
		// Attempt to add the node to the draw sequence sorter.
		[_drawingSequencer add: addedNode withVisitor: _drawingSequenceVisitor];
		
		// If the node is a light, add it to the collection of lights
		if (addedNode.isLight) [_lights addObject: addedNode];
		
		// if the node is the first camera to be added, make it the active camera.
		if (addedNode.isCamera && !_activeCamera) self.activeCamera = (CC3Camera*)addedNode;
		
		// If the node is a billboard, add it to the collection of billboards
		if (addedNode.isBillboard) [_billboards addObject: addedNode];
		
		// If the node is a shadow, check if we need to add the shadow visitor
		if (addedNode.isShadowVolume) [self checkNeedShadowVisitor];
	}
}

/**
 * Overridden to attempt to remove each node from the drawingSequencer, and to remove any nodes
 * that require special handling, like lights and billboards from their respective caches.
 * The node being removed is first flattened, so that this processing is performed not only
 * on that node, but all its hierarchical decendants.
 */
-(void) didRemoveDescendant: (CC3Node*) aNode {
	LogTrace(@"Removing %@ as descendant of %@", aNode, self);
	
	// Collect all the nodes being removed, including all descendants,
	// and see if they require special treatment
	NSArray* allRemoved = [aNode flatten];
	for (CC3Node* removedNode in allRemoved) {
		
		// Attempt to remove the node to the draw sequence sorter.
		[_drawingSequencer remove: removedNode withVisitor: _drawingSequenceVisitor];
		
		// If the node is a light, remove it from the collection of lights
		if (removedNode.isLight) [_lights removeObjectIdenticalTo: removedNode];
		
		// If the node is a billboard, remove it from the collection of billboards
		if (removedNode.isBillboard) [_billboards removeObjectIdenticalTo: removedNode];
		
		// If the node is a shadow, check if we need to remove the shadow visitor
		if (removedNode.isShadowVolume) [self checkNeedShadowVisitor];
	}
}

/**
 * Check to see if any lights are casting shadows. If they are, ensure the shadowVisitor
 * exists. If no lights are casting a shadow, and the shadowVisitor exists, remove it.
 */
-(void) checkNeedShadowVisitor {
	BOOL needsShadowVisitor = NO;
	for (CC3Light* lgt in _lights) needsShadowVisitor |= lgt.hasShadows;
	if (needsShadowVisitor && !_shadowVisitor) self.shadowVisitor = [CC3ShadowDrawingVisitor visitor];
	if (!needsShadowVisitor && _shadowVisitor) self.shadowVisitor = nil;
}


#pragma mark Touch handling

-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
	switch (touchType) {
		case kCCTouchBegan:
			[self pickNodeFromTouchEvent: touchType at: touchPoint];
			break;
		case kCCTouchMoved:
			break;
		case kCCTouchEnded:
			break;
		default:
			break;
	}
}

-(void) pickNodeFromTapAt: (CGPoint) tPoint {
	[self pickNodeFromTouchEvent: kCCTouchEnded at: tPoint];
}

-(void) pickNodeFromTouchEvent: (uint) tType at: (CGPoint) tPoint {
	[_touchedNodePicker pickNodeFromTouchEvent: tType at: tPoint];
}

/** Default does nothing. Subclasses that handle touch events will override. */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {}

-(id) pickVisitorClass { return [CC3NodePickingVisitor class]; }

-(BOOL) shouldDisplayPickingRender { return _shouldDisplayPickingRender; }

-(void) setShouldDisplayPickingRender: (BOOL) shouldDisplayPickingRender {
	CC3Assert( !(shouldDisplayPickingRender && self.viewSurfaceManager.shouldUseDedicatedPickingSurface),
			  @"The node picking render surface is not visible to the view. Ensure multisampling is disabled,"
			  @" and the shouldUseDedicatedPickingSurface property in the viewSurfaceManager is set to NO.");
	_shouldDisplayPickingRender = shouldDisplayPickingRender;
}

@end


#pragma mark -
#pragma mark CC3TouchedNodePicker

@implementation CC3TouchedNodePicker

@synthesize pickVisitor=_pickVisitor, touchPoint=_touchPoint, pickedNode=_pickedNode;

-(void) dealloc {
	_scene = nil;				// weak reference
	[_pickVisitor release];
	[_pickedNode release];
	
	[super dealloc];
}

#pragma mark Touch handling

-(void) pickNodeFromTouchEvent: (uint) tType at: (CGPoint) tPoint {

	// If the touch type is different than the previous touch type,
	// add the touch type to the queue. Only the types are queued...not the location.
	@synchronized(self) {
		if (_queuedTouchCount == 0 || tType != _touchQueue[_queuedTouchCount - 1] ) {
			if (_queuedTouchCount == kCC3TouchQueueLength) _queuedTouchCount = 0;
			_touchQueue[_queuedTouchCount++] = tType;
			_wasTouched = YES;
		}
	}

	// Update the touch location, even if the touch type is the same as the previous touch.
	_touchPoint = tPoint;

	LogTrace(@"%@ touched %@ at %@. Queue length now %u.", self, NSStringFromTouchType(tType),
			 NSStringFromCGPoint(_touchPoint), _queuedTouchCount);
}

-(void) pickTouchedNode {
	if ( !(_wasTouched || _scene.shouldDisplayPickingRender) ) return;
	
	_wasPicked = _wasTouched;
	_wasTouched = NO;
	
	// Draw the scene for node picking. Don't bother drawing the backdrop.
	[_pickVisitor visit: _scene];
	
	self.pickedNode = _pickVisitor.pickedNode;
}

-(void) dispatchPickedNode {
	if (!_wasPicked) return;

	_wasPicked = NO;
		
	uint touchesToDispatch[kCC3TouchQueueLength];

	uint touchCount;
	@synchronized(self) {
		touchCount = _queuedTouchCount;
		memcpy(touchesToDispatch, _touchQueue, (touchCount * sizeof(uint)));
		_queuedTouchCount = 0;
	}

	for (int i = 0; i < touchCount; i++) {
		LogTrace(@"%@ dispatching %@ with picked node %@ at %@ GL %@ touched node %@",
				 self, NSStringFromTouchType(_touchQueue[i]), _pickedNode.touchableNode,
				 NSStringFromCGPoint(_touchPoint), NSStringFromCGPoint(self.glTouchPoint), _pickedNode);
		[_scene nodeSelected: _pickedNode.touchableNode byTouchEvent: _touchQueue[i] at: _touchPoint];
	}
	
	self.pickedNode = nil;	// Clear the node once it has been dispatched
}


#pragma mark Allocation and initialization

-(id) init { return [self initOnScene: nil]; }

-(id) initOnScene: (CC3Scene*) aCC3Scene {
	if ( (self = [super init]) ) {
		_scene = aCC3Scene;					// weak reference
		self.pickVisitor = [[_scene pickVisitorClass] visitor];
		_touchPoint = CGPointZero;
		_wasTouched = NO;
		_wasPicked = NO;
		_pickedNode = nil;
		_queuedTouchCount = 0;
	}
	return self;
}

+(id) pickerOnScene: (CC3Scene*) aCC3Scene { return [[[self alloc] initOnScene: aCC3Scene] autorelease]; }

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

@end


#pragma mark -
#pragma mark CC3Node extension for scene

@implementation CC3Node (Scene)
-(BOOL) isScene { return NO; }
@end

