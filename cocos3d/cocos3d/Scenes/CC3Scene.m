/*
 * CC3Scene.m
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
 * See header file CC3Scene.h for full API documentation.
 */

#import "CC3Scene.h"
#import "CC3Layer.h"
#import "CC3MeshNode.h"
#import "CC3VertexArrayMesh.h"
#import "CC3Material.h"
#import "CC3Light.h"
#import "CC3Billboard.h"
#import "CC3ShadowVolumes.h"
#import "CC3AffineMatrix.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"
#import "CGPointExtension.h"
#import "ccMacros.h"


#pragma mark -
#pragma mark CC3Scene

@interface CC3Node (TemplateMethods)
-(id) transformVisitorClass;
@end

@interface CC3Scene (TemplateMethods)
-(void) activeCameraChangedFrom: (CC3Camera*) oldCam;
-(void) updateCamera: (ccTime) dt;
-(void) updateTargets: (ccTime) dt;
-(void) updateFog: (ccTime) dt;
-(void) updateShadows: (ccTime) dt;
-(void) updateBillboards: (ccTime) dt;
-(void) collectFrameInterval;
-(void) open3D;
-(void) close3D;
-(void) openViewport;
-(void) closeViewport;
-(void) open3DCamera;
-(void) close3DCamera;
-(void) illuminate;
-(void) drawFog;
-(void) drawShadows;
-(void) draw2DBillboards;
-(void) visitForDrawingWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) checkNeedShadowVisitor;
-(void) updateDrawSequence;
-(BOOL) addToDrawingSequencer: (CC3Node*) aNode;
-(BOOL) removeFromDrawingSequencer: (CC3Node*) aNode;
@end


@implementation CC3Scene

@synthesize cc3Layer, activeCamera, ambientLight, minUpdateInterval, maxUpdateInterval;
@synthesize touchedNodePicker, drawingSequencer, drawingSequenceVisitor;
@synthesize drawVisitor, shadowVisitor, updateVisitor, transformVisitor;
@synthesize viewportManager, performanceStatistics, fog, lights;
@synthesize shouldClearDepthBufferBefore3D, shouldClearDepthBufferBefore2D;

/**
 * Descendant nodes will be removed by superclass. Their removal may invoke
 * didRemoveDescendant:, which references several of these instance variables.
 * Make sure they are all made nil in addition to being released here.
 */
- (void)dealloc {
	cc3Layer = nil;							// Not retained
	self.viewportManager = nil;				// Use setter to release and make nil
	self.drawingSequencer = nil;			// Use setter to release and make nil
	self.activeCamera = nil;				// Use setter to release and make nil
	self.touchedNodePicker = nil;			// Use setter to release and make nil
	self.drawVisitor = nil;					// Use setter to release and make nil
	self.shadowVisitor = nil;				// Use setter to release and make nil
	self.updateVisitor = nil;				// Use setter to release and make nil
	self.transformVisitor = nil;			// Use setter to release and make nil
	self.drawingSequenceVisitor = nil;		// Use setter to release and make nil
	self.fog = nil;							// Use setter to stop any actions
	[targettingNodes release];
	targettingNodes = nil;
	[lights release];
	lights = nil;
	[billboards release];
	billboards = nil;
	
    [super dealloc];
}

-(UIViewController*) controller { return cc3Layer.controller; }

-(CC3Camera*) activeCamera { return activeCamera; }

-(void) setActiveCamera: (CC3Camera*) aCamera {
	if (aCamera != activeCamera) {
		CC3Camera* oldCam = activeCamera;
		activeCamera = [aCamera retain];
		[self activeCameraChangedFrom: oldCam];
		[oldCam release];
	}
}

/** The active camera has changed. Update whoever cares. */
-(void) activeCameraChangedFrom: (CC3Camera*) oldCam {

	// For any targetting nodes that were targetted to the old camera,
	// set the target to the new camera.
	CCArray* targNodes = [targettingNodes autoreleasedCopy];
	for (CC3Node* tn in targNodes) {
		// If the node should always target the camera, or if the target
		// is already the old camera, set its target to the new camera.
		if (tn.shouldAutotargetCamera || (oldCam && (tn.target == oldCam))) {
			tn.target = activeCamera;
		}
	}
	
	// Move other non-target camera listeners (eg- shadow casting volumes) over
	CCArray* camListeners = [oldCam.transformListeners autoreleasedCopy];
	for(id<CC3NodeTransformListenerProtocol> aListener in camListeners) {
		[oldCam removeTransformListener: aListener];
		[activeCamera addTransformListener: aListener];
	}
	
	// Ensure infinite depth of field is preserved
	activeCamera.hasInfiniteDepthOfField = oldCam.hasInfiniteDepthOfField;
}

-(void) setFog: (CC3Fog*) aFog {
	if (aFog != fog) {
		[fog stopAllActions];		// Ensure all actions stopped before releasing
		[fog release];
		fog = [aFog retain];
	}
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		targettingNodes = [[CCArray array] retain];
		lights = [[CCArray array] retain];
		billboards = [[CCArray array] retain];
		shouldClearDepthBufferBefore3D = YES;
		shouldClearDepthBufferBefore2D = YES;
		self.touchedNodePicker = [CC3TouchedNodePicker pickerOnScene: self];
		self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirst];
		self.viewportManager = [CC3ViewportManager viewportManagerOnScene: self];
		self.drawVisitor = [[self drawVisitorClass] visitor];
		self.shadowVisitor = nil;
		self.updateVisitor = [[self updateVisitorClass] visitor];
		self.transformVisitor = [[self transformVisitorClass] visitor];
		self.drawingSequenceVisitor = [CC3NodeSequencerVisitor visitorWithScene: self];
		fog = nil;
		activeCamera = nil;
		ambientLight = kCC3DefaultLightColorAmbientScene;
		minUpdateInterval = kCC3DefaultMinimumUpdateInterval;
		maxUpdateInterval = kCC3DefaultMaximumUpdateInterval;
		[self initializeScene];
	}
	return self;
}

// Default does nothing. Subclasses will customize.
-(void) initializeScene {}

+(id) scene { return [[self new] autorelease]; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Scene*) another {
	[super populateFrom: another];
	
	// Lights, targetting nodes, billboards & drawing sequence collections,
	// plus activeCamera will be populated as children are added.
	// No need to configure node picker.
	[viewportManager populateFrom: another.viewportManager];
	
	[drawingSequencer release];
	drawingSequencer = [another.drawingSequencer copy];					// retained
	
	[performanceStatistics release];
	performanceStatistics = [another.performanceStatistics copy];		// retained

	self.drawVisitor = [[another.drawVisitor class] visitor];			// retained
	self.shadowVisitor = [[another.shadowVisitor class] visitor];		// retained
	self.updateVisitor = [[another.updateVisitor class] visitor];		// retained
	self.transformVisitor = [[another.transformVisitor class] visitor];	// retained
	self.drawingSequenceVisitor = [[another.drawingSequenceVisitor class] visitorWithScene: self];	// retained
	self.touchedNodePicker = [[another.touchedNodePicker class] pickerOnScene: self];		// retained

	[fog release];
	fog = [another.fog copy];											// retained
	
	ambientLight = another.ambientLight;
	minUpdateInterval = another.minUpdateInterval;
	maxUpdateInterval = another.maxUpdateInterval;
}


#pragma mark Updating scene state

-(void) open {
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
 * Does nothing if this instance is not running.
 */
-(void) updateScene: (ccTime) dt {
	[performanceStatistics addUpdateTime: dt];
	if( !self.isRunning) return;

	// Clamp the specified interval to a range defined by the minimum and maximum
	// update intervals. If the maximum update interval limit is zero or negative,
	// its value is ignored, and the dt value is not limited to a maximum value.
	ccTime dtClamped = CLAMP(dt, minUpdateInterval,
							 (maxUpdateInterval > 0.0 ? maxUpdateInterval : dt));
	
	LogTrace(@"******* %@ starting update: %.2f ms (clamped from %.2f ms)",
			 self, dtClamped * 1000.0, dt * 1000.0);
	
	[touchedNodePicker dispatchPickedNode];
	
	updateVisitor.deltaTime = dtClamped;
	[updateVisitor visit: self];
	
	[self updateTargets: dtClamped];
	[self updateCamera: dtClamped];
	[self updateBillboards: dtClamped];
	[self updateFog: dtClamped];
	[self updateShadows: dtClamped];
	[self updateDrawSequence];
	
	LogTrace(@"******* %@ exiting update", self);
}

-(void) updateScene {
	BOOL wasRunning = isRunning;
	isRunning = YES;
	[self updateScene: minUpdateInterval];
	isRunning = wasRunning;
}

/** 
 * Template method to update the direction pointed to by any targetting nodes in this scene.
 * Iterates through all the targetting nodes in this scene, updating their target tracking.
 */
-(void) updateTargets: (ccTime) dt {
	transformVisitor.shouldVisitChildren = YES;
	transformVisitor.shouldLocalizeToStartingNode = NO;
	for (CC3Node* tn in targettingNodes) {
		[tn trackTargetWithVisitor: transformVisitor];
	}
}

/** Template method to update the camera's projection. */
-(void) updateCamera: (ccTime) dt {
	[activeCamera buildProjection];
}

/** Template method to update any fog characteristics. */
-(void) updateFog: (ccTime) dt {
	[fog update: dt];
}

/** Template method to update shadows cast by the lights. */
-(void) updateShadows: (ccTime) dt {
	for (CC3Light* lgt in lights) {
		[lgt updateShadows];
	}
}

/**
 * Template method to update any billboards.
 * Iterates through all billboards, instructing them to align with the camera if needed.
 */
-(void) updateBillboards: (ccTime) dt {
	for (CC3Billboard* bb in billboards) {
		[bb alignToCamera: activeCamera];
	}
	LogTrace(@"%@ updated %u billboards", self, billboards.count);
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

-(void) drawScene {

	// Check and clear any GL error that occurred before 3D code
	LogGLErrorState(@"before drawing %@", self);
	LogTrace(@"******* %@ starting drawing visit", self);

	[self collectFrameInterval];	// Collect the frame interval in the performance statistics.
	
	if (self.visible) {
		[self open3D];
		[self openViewport];
		[self open3DCamera];
		[touchedNodePicker pickTouchedNode];
		[self illuminate];
		[self drawFog];
		[self visitForDrawingWithVisitor: drawVisitor];
		[self drawShadows];
		[self close3DCamera];
		[self closeViewport];
		[self close3D];
		[self draw2DBillboards];	// Back to 2D now
	}
	
	// Check and clear any GL error that occurred during 3D code
	LogGLErrorState(@"after drawing %@", self);
	LogTrace(@"******* %@ exiting drawing visit", self);
}

/**
 * Extract the interval since the previous frame from the CCDirector,
 * and add it to the performance statistics.
 */
-(void) collectFrameInterval {
	if (performanceStatistics) {
		[performanceStatistics addFrameTime: [[CCDirector sharedDirector] frameInterval]];
	}
}

/**
 * Template method that opens the GL drawing environment for 3D drawing. This is invoked
 * on each frame. Using state trackers, GL state is only changed when state really has changed.
 */
-(void) open3D {
	LogTrace(@"%@ opening the 3D scene", self);

	// Retrieves the GLES state trackers to set initial state
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	
	// Open tracking of GL state. Where needed, will cache current 2D GL state items
	// for later reinstatement in the close3D method.
	[gles11Engine open];
	
	// Ensure drawing is not slowed down by unexpected alpha testing and logic ops
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = gles11Engine.serverCapabilities;
	[gles11ServCaps.alphaTest disable];
	[gles11ServCaps.colorLogicOp disable];
}

/**
 * Template method that reverts the GL drawing environment back to the configuration
 * needed for 2D drawing. This is the compliment of the open3D method. Where needed,
 * reverts any GL state back to what is needed for 2D. Using state trackers, GL state
 * is only changed when state really has changed.
 */
-(void) close3D {
	LogTrace(@"%@ closing the 3D scene", self);

	// Close tracking of GL state, reverting to 2D values where required.
	[[CC3OpenGLES11Engine engine] close];
	
	// Clear the depth buffer so that subsequent cocos2d rendering will occur
	// on top of the 3D rendering. We can't simply turn depth testing off
	// because cocos2d can use depth testing for 3D transition effects.
	if (shouldClearDepthBufferBefore2D) {
		[[CC3OpenGLES11Engine engine].state clearDepthBuffer];
	}
}

/** Template method that opens the 3D camera. */
-(void) openViewport { [viewportManager openViewport]; }

/** Template method that closes the 3D camera. This is the compliment of the open3DCamera method. */
-(void) closeViewport { [viewportManager closeViewport]; }


/** Template method that opens the 3D camera. */
-(void) open3DCamera { [activeCamera open]; }

/** Template method that closes the 3D camera. This is the compliment of the open3DCamera method. */
-(void) close3DCamera { [activeCamera close]; }

/**
 * Template method that turns on lighting of the 3D scene. Turns on global ambient lighting,
 * and iterates through the CC3Light instances, turning them on. If the 2D scene uses any
 * lights, they are disabled.
 */
-(void) illuminate {
	[CC3Light disableReservedLights];		// disable any lights used by 2D scene

	BOOL hasLighting = (lights.count > 0 || !ccc4FEqual(ambientLight, kCCC4FBlackTransparent));
	[CC3OpenGLES11Engine engine].serverCapabilities.lighting.value = hasLighting;

	LogTrace(@"%@ lighting is %@", self, (hasLighting ? @"on" : @"off"));
	
	// Set the ambient light for the whole scene
	[CC3OpenGLES11Engine engine].lighting.sceneAmbientLight.value = ambientLight;

	// Turn on any individual lights
	for (CC3Light* lgt in lights) [lgt turnOn];
}

-(ccColor4F) totalIllumination {
	ccColor4F totLgt = self.ambientLight;
	LogTrace(@"Start with scene ambient illumination %@", NSStringFromCCC4F(totLgt));
	for (CC3Light* lgt in lights) {
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
	for (CC3Light* lgt in lights) {
		[lgt updateRelativeIntensityFrom: totLgt];
	}
}

-(BOOL) doesContainShadows { return shadowVisitor != nil; }

/** Template method to draw shadows cast by the lights. */
-(void) drawShadows {
	if (self.doesContainShadows) {
		[CC3OpenGLES11Engine engine].state.clearStencil = 0;
		for (CC3Light* lgt in lights) {
			[lgt drawShadowsWithVisitor: shadowVisitor];
		}
	}
}

/** If this scene contains fog, draw it, otherwise unbind fog from the GL engine. */
-(void) drawFog {
	if (fog) {
		[fog draw];
	} else {
		[CC3Fog unbind];
	}
}

/**
 * Draws any 2D overlay billboards.
 * This is invoked after close3D, so the drawing of billboards occurs in 2D.
 */
-(void) draw2DBillboards {
	LogTrace(@"%@ drawing %i billboards", self, billboards.count);

	if (activeCamera && (billboards.count > 0)) {
		CC3OpenGLES11Engine* gles11Engine;
		CC3OpenGLES11StateTrackerViewport* gles11Scissor;
		CC3OpenGLES11StateTrackerServerCapability* gles11ScissorTest;
		
		CC3Viewport vp = viewportManager.viewport;
		BOOL isFullView = viewportManager.isFullView;
		
		// Since billboards draw outside the 3D environment, if the CC3Layer does not
		// cover the full screen, billboards can be drawn outside the CC3Layer.
		// Enable scissoring to the viewport dimensions to clip to the layer bounds.
		if ( !isFullView ) {
			gles11Engine = [CC3OpenGLES11Engine engine];
			gles11Scissor = gles11Engine.state.scissor;
			gles11ScissorTest = gles11Engine.serverCapabilities.scissorTest;
			
			[gles11ScissorTest enable];
			gles11Scissor.value = vp;
		}
		
		CGRect lb = viewportManager.layerBoundsLocal;
		for (CC3Billboard* bb in billboards) {
			[bb draw2dWithinBounds: lb];
		}
		
		// All done...turn scissoring back off now. This is happening after the
		// close3D method, so we need to close the scissor trackers manually.
		if ( !isFullView ) {
			[gles11ScissorTest close];
			[gles11Scissor close];
		}
	}
}

/** Visits this scene for drawing (or picking) using the specified visitor. */
-(void) visitForDrawingWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	visitor.shouldClearDepthBuffer = shouldClearDepthBufferBefore3D;
	visitor.drawingSequencer = drawingSequencer;
	visitor.shouldVisitChildren = YES;
	[visitor visit: self];
}

-(id) drawVisitorClass {
	return [CC3NodeDrawingVisitor class];
}


#pragma mark Drawing sequencer

-(BOOL) isUsingDrawingSequence { return (drawingSequencer != nil); }

/**
 * Property setter overridden to add all the decendent nodes of this scene
 * into the new  node sequencer.
 */
-(void) setDrawSequencer:(CC3NodeSequencer*) aNodeSequencer {
	id oldDSS = drawingSequencer;
	drawingSequencer = [aNodeSequencer retain];
	[oldDSS release];

	CCArray* allNodes = [self flatten];
	for (CC3Node* aNode in allNodes) {
		[drawingSequencer add: aNode withVisitor: drawingSequenceVisitor];
	}
}

-(void) updateDrawSequence {
	if (drawingSequencer && drawingSequencer.allowSequenceUpdates) {
		[drawingSequencer updateSequenceWithVisitor: drawingSequenceVisitor];
		LogTrace(@"%@ updated %@", self, [drawingSequencer fullDescription]);
	}
}

/**
 * A property on a descendant node has changed that potentially affects its order in
 * the drawing sequence. To put it in the correct drawing order, remove it from the
 * drawingSequencer and then re-add it.
 */
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode {
	if (drawingSequencer) {
		if ([drawingSequencer remove: aNode withVisitor: drawingSequenceVisitor]) {
			[drawingSequencer add: aNode withVisitor: drawingSequenceVisitor];
		}
	}
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
	CCArray* allAdded = [aNode flatten];
	for (CC3Node* addedNode in allAdded) {
	
		// Attempt to add the node to the draw sequence sorter.
		[drawingSequencer add: addedNode withVisitor: drawingSequenceVisitor];
		
		// If the node has a target, add it to the collection of such nodes
		if (addedNode.hasTarget) {
			LogTrace(@"Adding targetting node %@", addedNode.fullDescription);
			[targettingNodes addObject: addedNode];
		}
		
		// If the node is a light, add it to the collection of lights
		if (addedNode.isLight) [lights addObject: addedNode];
		
		// if the node is the first camera to be added, make it the active camera.
		if (addedNode.isCamera && !activeCamera) self.activeCamera = (CC3Camera*)addedNode;
		
		// If the node is a billboard, add it to the collection of billboards
		if (addedNode.isBillboard) [billboards addObject: addedNode];
		
		// If the node is a shadow, check if we need to add the shadow visitor
		if (addedNode.isShadowVolume) [self checkNeedShadowVisitor];
	}
}

/**
 * Overridden to attempt to remove each node to the drawingSequencer, and to remove any nodes
 * that require special handling, like lights and billboards from their respective caches.
 * The node being removed is first flattened, so that this processing is performed not only
 * on that node, but all its hierarchical decendants.
 */
-(void) didRemoveDescendant: (CC3Node*) aNode {
	LogTrace(@"Removing %@ as descendant of %@", aNode, self);
	
	// Collect all the nodes being removed, including all descendants,
	// and see if they require special treatment
	CCArray* allRemoved = [aNode flatten];
	for (CC3Node* removedNode in allRemoved) {
		
		// Attempt to remove the node to the draw sequence sorter.
		[drawingSequencer remove: removedNode withVisitor: drawingSequenceVisitor];
		
		// If the node has a target, remove it from the collection of such nodes
		if (removedNode.hasTarget) {
			LogTrace(@"Removing targetting node %@", removedNode);
			[targettingNodes removeObjectIdenticalTo: removedNode];
		}
		
		// If the node is a light, remove it from the collection of lights
		if (removedNode.isLight) [lights removeObjectIdenticalTo: removedNode];
		
		// If the node is a billboard, remove it from the collection of billboards
		if (removedNode.isBillboard) [billboards removeObjectIdenticalTo: removedNode];
		
		// If the node is a shadow, check if we need to remove the shadow visitor
		if (removedNode.isShadowVolume) [self checkNeedShadowVisitor];
	}
}

/** 
 * A target has been set in a descendant. If the target is not nil, add the descendant
 * to the collection of targetting nodes, if it has not been added before. If the target
 * is nil, remove the descendant node from the collection of targetting nodes.
 */
-(void) didSetTargetInDescendant: (CC3Node*) aNode {
	if (aNode.hasTarget) {
		if ( ![targettingNodes containsObject: aNode] ) {
			LogTrace(@"Adding targetting node %@ with target %@", aNode, aNode.target);
			[targettingNodes addObject: aNode];
		}
	} else {
		LogTrace(@"Removing targetting node %@", aNode);
		[targettingNodes removeObjectIdenticalTo: aNode];
	}
}

/**
 * Check to see if any lights are casting shadows. If they are, ensure the shadowVisitor
 * exists. If no lights are casting a shadow, and the shadowVisitor exists, remove it.
 */
-(void) checkNeedShadowVisitor {
	BOOL needsShadowVisitor = NO;
	for (CC3Light* lgt in lights) {
		needsShadowVisitor |= lgt.hasShadows;
	}
	if (needsShadowVisitor && !shadowVisitor) {
		self.shadowVisitor = [CC3ShadowDrawingVisitor visitor];
	}
	if (!needsShadowVisitor && shadowVisitor) {
		self.shadowVisitor = nil;
	}
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
	[touchedNodePicker pickNodeFromTouchEvent: tType at: tPoint];
}

/** Default does nothing. Subclasses that handle touch events will override. */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {}

-(id) pickVisitorClass {
	return [CC3NodePickingVisitor class];
}

@end


#pragma mark -
#pragma mark CC3TouchedNodePicker

@implementation CC3TouchedNodePicker

@synthesize pickVisitor;

-(void) dealloc {
	[pickVisitor release];
	scene = nil;			// not retained
	pickedNode = nil;		// not retained
	[super dealloc];
}

/** Returns the touch point mapped to the device-oriented GL coordinate space. */
-(CGPoint) glTouchPoint { return [scene.viewportManager glPointFromCC2Point: touchPoint]; }


#pragma mark Allocation and initialization

-(id) init { return [self initOnScene: nil]; }

-(id) initOnScene: (CC3Scene*) aCC3Scene {
	if ( (self = [super init]) ) {
		scene = aCC3Scene;
		self.pickVisitor = [[scene pickVisitorClass] visitor];
		touchPoint = CGPointZero;
		wasTouched = NO;
		wasPicked = NO;
		pickedNode = nil;
		queuedTouchCount = 0;
	}
	return self;
}

+(id) pickerOnScene: (CC3Scene*) aCC3Scene {
	return [[[self alloc] initOnScene: aCC3Scene] autorelease];
}

// Deprecated
-(id) initOnWorld: (CC3Scene*) aCC3Scene { return [self initOnScene: aCC3Scene]; }
+(id) handlerOnWorld: (CC3Scene*) aCC3Scene { return [self pickerOnScene: aCC3Scene]; }


#pragma mark Touch handling

-(void) pickNodeFromTouchEvent: (uint) tType at: (CGPoint) tPoint {

	// If the touch type is different than the previous touch type,
	// add the touch type to the queue. Only the types are queued...not the location.
	@synchronized(self) {
		if (queuedTouchCount == 0 || tType != touchQueue[queuedTouchCount - 1] ) {
			if (queuedTouchCount == kCC3TouchQueueLength) queuedTouchCount = 0;
			touchQueue[queuedTouchCount++] = tType;
			wasTouched = YES;
		}
	}

	// Update the touch location, even if the touch type is the same as the previous touch.
	touchPoint = tPoint;

	LogTrace(@"%@ touched %@ at %@. Queue length now %u.", self, NSStringFromTouchType(tType),
			 NSStringFromCGPoint(touchPoint), queuedTouchCount);
}

-(void) pickTouchedNode {
	if (wasTouched) {
		wasTouched = NO;

		[scene visitForDrawingWithVisitor: pickVisitor];
		pickedNode = pickVisitor.pickedNode;

		wasPicked = YES;
	}
}

-(void) dispatchPickedNode {
	if (wasPicked) {
		wasPicked = NO;
		
		uint touchesToDispatch[kCC3TouchQueueLength];

		uint touchCount;
		@synchronized(self) {
			touchCount = queuedTouchCount;
			memcpy(touchesToDispatch, touchQueue, (touchCount * sizeof(uint)));
			queuedTouchCount = 0;
		}

		for (int i = 0; i < touchCount; i++) {
			LogTrace(@"%@ dispatching %@ with picked node %@ at %@ GL %@ touched node %@",
					 self, NSStringFromTouchType(touchQueue[i]), pickedNode.touchableNode,
					 NSStringFromCGPoint(touchPoint), NSStringFromCGPoint(self.glTouchPoint), pickedNode);

			[scene nodeSelected: pickedNode.touchableNode byTouchEvent: touchQueue[i] at: touchPoint];
		}
	}
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@", [self class]];
}

@end


#pragma mark -
#pragma mark CC3ViewportManager

@interface CC3ViewportManager (TemplateMethods)
-(void) updateDeviceRotationAngle:(GLfloat) anAngle;
@property(nonatomic, readonly) CC3Vector glToCC2PointMapX;
@property(nonatomic, readonly) CC3Vector glToCC2PointMapY;
@property(nonatomic, readonly) CC3Vector cc2ToGLPointMapX;
@property(nonatomic, readonly) CC3Vector cc2ToGLPointMapY;
@end


@implementation CC3ViewportManager

@synthesize layerBounds, viewport, deviceRotationMatrix, isFullView;

-(void) dealloc {
	[deviceRotationMatrix release];
	scene = nil;			// not retained
	[super dealloc];
}

-(CGRect) layerBoundsLocal {
	CGRect localBounds;
	localBounds.origin = CGPointMake(0.0, 0.0);
	localBounds.size = layerBounds.size;
	return localBounds;
}

#pragma mark Allocation and initialization

-(id) init { return [self initOnScene: nil]; }

-(id) initOnScene: (CC3Scene*) aCC3Scene {
	if ( (self = [super init]) ) {
		scene = aCC3Scene;
		self.deviceRotationMatrix = [CC3AffineMatrix matrix];
		layerBounds = CGRectZero;
		viewport = CC3ViewportMake(0, 0, 0, 0);
		glToCC2PointMapX = cc3v( 1.0,  0.0, 0.0 );
		glToCC2PointMapY = cc3v( 0.0,  1.0, 0.0 );
		cc2ToGLPointMapX = cc3v( 1.0,  0.0, 0.0 );
		cc2ToGLPointMapY = cc3v( 0.0,  1.0, 0.0 );
		isFullView = NO;
	}
	return self;
}

+(id) viewportManagerOnScene: (CC3Scene*) aCC3Scene {
	return [[[self alloc] initOnScene: aCC3Scene] autorelease];
}

// Deprecated
-(id) initOnWorld: (CC3Scene*) aCC3Scene { return [self initOnScene: aCC3Scene]; }
+(id) viewportManagerOnWorld: (CC3Scene*) aCC3Scene { return [self viewportManagerOnScene: aCC3Scene]; }

// Protected properties for copying
-(CC3Vector) glToCC2PointMapX { return glToCC2PointMapX; }
-(CC3Vector) glToCC2PointMapY { return glToCC2PointMapY; }
-(CC3Vector) cc2ToGLPointMapX { return cc2ToGLPointMapX; }
-(CC3Vector) cc2ToGLPointMapY { return cc2ToGLPointMapY; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// The scene ivar is set by the new CC3Scene, since it changes with the copy.
-(void) populateFrom: (CC3ViewportManager*) another {

	[deviceRotationMatrix release];
	deviceRotationMatrix = [another.deviceRotationMatrix copy];		//retained

	layerBounds = another.layerBounds;
	viewport = another.viewport;
	glToCC2PointMapX = another.glToCC2PointMapX;
	glToCC2PointMapY = another.glToCC2PointMapY;
	cc2ToGLPointMapX = another.cc2ToGLPointMapX;
	cc2ToGLPointMapY = another.cc2ToGLPointMapY;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3ViewportManager* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}


#pragma mark Drawing

-(void) openViewport {
	LogTrace(@"%@ opening 3D viewport %@ as %@fullscreen", self,
			 NSStringFromCC3Viewport(viewport), (isFullView ? @"" : @"not "));

	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11State* gles11State = gles11Engine.state;
	
	gles11State.viewport.value = viewport;

	if ( !isFullView ) {
		[gles11Engine.serverCapabilities.scissorTest enable];
		gles11State.scissor.value = viewport;
	}
}

-(void) closeViewport {}


#pragma mark Converting points

/**
 * Converts the projected position into 2D homogeneous coordinates by setting Z to 1.0, then
 * maps the X and Y of the homogeneous point by dotting it with the X and Y mapping vectors.
 */
-(CGPoint) glPointFromCC2Point: (CGPoint) cc2Point {
	CC3Vector homogeneousPoint = cc3v(cc2Point.x, cc2Point.y, 1.0);
	return ccp(CC3VectorDot(cc2ToGLPointMapX, homogeneousPoint),
			   CC3VectorDot(cc2ToGLPointMapY, homogeneousPoint));	
}

/**
 * Converts the projected position into 2D homogeneous coordinates by setting Z to 1.0, then
 * maps the X and Y of the homogeneous point by dotting it with the X and Y mapping vectors.
 */
-(CGPoint) cc2PointFromGLPoint: (CGPoint) glPoint {
	CC3Vector homogeneousPoint = cc3v(glPoint.x, glPoint.y, 1.0);
	return ccp(CC3VectorDot(glToCC2PointMapX, homogeneousPoint),
			   CC3VectorDot(glToCC2PointMapY, homogeneousPoint));
}


#pragma mark Device orientation

/**
 * Using the specified view bounds and deviceOrientation, updates the GL viewport and the
 * device rotation matrix, and establishes conversion mappings between GL points and cocos2d
 * points, in both directions. These conversion mappings are used by the complimentary methods
 * glPointFromCC2Point: and cc2PointFromGLPoint:.
 *
 * Depending on orientation, the GL viewport needs to be moved around in the larger window to
 * keep it aligned with the layer content size and global position. We had to add one-pixel
 * padding in some cases to keep the viewport aligned with the layer position and size.
 *
 * The device rotation matrix is calculated from the angle of rotation associated with each
 * device orientation.
 *
 * The conversion mappings map back and forth between GL coordinates and cocos2d coordinates.
 * Each conversion mapping is a pair of vectors, each of which holds a transformation to
 * calculate either the X or Y coordinate of the final converted point. One can think of
 * the pair of vectors representing a 3x2 matrix. Like all matrix transformations, the
 * converted point is calculated as a series of dot-products between the vectors in the
 * matrix and the incoming point to be converted.
 *
 * The vectors are or order 3 to permit a constant translation component in the calculation.
 * Each of the X and Y components of the final point is therefore a mathematical combination
 * of both the X and Y component of the incoming point, plus the constant translation component.
 *
 * To include the constant translation component in the calculation, during conversion, the
 * incoming 2D point will be converted to a 3D vector with a Z-component set to one.
 *
 * If vx and vy are the pair of conversion mapping vectors, the resulting calculations
 * can be stated as:
 *   - Xout = (Xvx * Xin) + (Yvx * Yin) + (Zvx * 1.0)
 *   - Yout = (Xvy * Xin) + (Yvy * Yin) + (Zvy * 1.0)
 *
 * Thanks to cocos3d user Robert Szeleney who pointed out a previous issue where the
 * viewport bounds were unnecessarily being constrained to the window bounds, thereby
 * restricting the movement of the CC3Layer and 3D scene, and for suggesting the fix. 
 */
-(void) updateBounds: (CGRect) bounds withDeviceOrientation: (ccDeviceOrientation) deviceOrientation {
	CGSize winSz = [[CCDirector sharedDirector] winSizeInPixels];
	CC3Viewport vp;
	CGPoint bOrg = bounds.origin;
	CGSize bSz = bounds.size;

	// Mark whether the viewport covers the full UIView. Test both Portrait and Landscape orientations.
	isFullView = (CGPointEqualToPoint(bOrg, CGPointZero) &&
				  (CGSizeEqualToSize(bSz, winSz) ||
				   CGSizeEqualToSize(bSz, CGSizeMake(winSz.height, winSz.width))));
	
	// CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	GLfloat c2g = CC_CONTENT_SCALE_FACTOR();		// Ratio of CC2 points to GL pixels...
	GLfloat g2c = 1.0 / c2g;						// ...and its inverse.
	
	switch(deviceOrientation) {
			
		case kCCDeviceOrientationLandscapeLeft:
			[self updateDeviceRotationAngle: -90.0f];
			
			vp.x = (GLint)bOrg.y;
			vp.y = (GLint)(winSz.width - (bOrg.x + bSz.width));
			vp.w = (GLint)(bSz.height);
			vp.h = (GLint)(bSz.width);
			
			glToCC2PointMapX = cc3v(  0.0, -g2c, (vp.y + vp.h) * g2c );
			glToCC2PointMapY = cc3v(  g2c,  0.0, -vp.x * g2c );
			cc2ToGLPointMapX = cc3v(  0.0,  c2g,  vp.x );
			cc2ToGLPointMapY = cc3v( -c2g,  0.0,  vp.y + vp.h );
			
			LogTrace(@"Orienting to LandscapeLeft with bounds: %@ in window: %@ and viewport: %@ is %@fullscreen",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz),
					 NSStringFromCC3Viewport(vp), (isFullView ? @"" : @"not "));
			break;
			
		case kCCDeviceOrientationLandscapeRight:
			[self updateDeviceRotationAngle: 90.0f];
			
			vp.x = (GLint)(winSz.height - (bOrg.y + bSz.height));
			vp.y = (GLint)bOrg.x;
			vp.w = (GLint)(bSz.height);
			vp.h = (GLint)(bSz.width);
			
			glToCC2PointMapX = cc3v(  0.0,  g2c, -vp.y * g2c );
			glToCC2PointMapY = cc3v( -g2c,  0.0, (vp.x + vp.w) * g2c );
			cc2ToGLPointMapX = cc3v(  0.0, -c2g,  vp.x + vp.w );
			cc2ToGLPointMapY = cc3v(  c2g,  0.0,  vp.y );
			
			LogTrace(@"Orienting to LandscapeRight with bounds: %@ in window: %@ and viewport: %@ is %@fullscreen",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz),
					 NSStringFromCC3Viewport(vp), (isFullView ? @"" : @"not "));
			break;
			
		case kCCDeviceOrientationPortraitUpsideDown:
			[self updateDeviceRotationAngle: 180.0f];
			
			vp.x = (GLint)(winSz.width - (bOrg.x + bSz.width));
			vp.y = (GLint)(winSz.height - (bOrg.y + bSz.height));
			vp.w = (GLint)bSz.width;
			vp.h = (GLint)bSz.height;
			
			glToCC2PointMapX = cc3v( -g2c,  0.0, (vp.x + vp.w) * g2c );
			glToCC2PointMapY = cc3v(  0.0, -g2c, (vp.y + vp.h) * g2c );
			cc2ToGLPointMapX = cc3v( -c2g,  0.0,  vp.x + vp.w );
			cc2ToGLPointMapY = cc3v(  0.0, -c2g,  vp.y + vp.h );
			
			LogTrace(@"Orienting to PortraitUpsideDown with bounds: %@ in window: %@ and viewport: %@ is %@fullscreen",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz),
					 NSStringFromCC3Viewport(vp), (isFullView ? @"" : @"not "));
			break;
			
		case kCCDeviceOrientationPortrait:
		default:
			[self updateDeviceRotationAngle: 0.0f];
			
			vp.x = (GLint)bOrg.x;
			vp.y = (GLint)bOrg.y;
			vp.w = (GLint)bSz.width;
			vp.h = (GLint)bSz.height;
			
			glToCC2PointMapX = cc3v(  g2c,  0.0, -vp.x * g2c );
			glToCC2PointMapY = cc3v(  0.0,  g2c, -vp.y * g2c );
			cc2ToGLPointMapX = cc3v(  c2g,  0.0,  vp.x );
			cc2ToGLPointMapY = cc3v(  0.0,  c2g,  vp.y );

			LogTrace(@"Orienting to Portrait with bounds: %@ in window: %@ and viewport: %@ is %@fullscreen",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz),
					 NSStringFromCC3Viewport(vp), (isFullView ? @"" : @"not "));
			break;
	}
	
	// Set the layerBounds and viewport, and tell the camera that we've been updated
	layerBounds = bounds;
	viewport = vp;
	[scene.activeCamera markProjectionDirty];
}

/**
 * Rebuilds the deviceRotationMatrix from the specified rotation angle, and marks the
 * camera's transfom as dirty so that the camera's modelview matrix will be rebuilt.
 */
-(void) updateDeviceRotationAngle:(GLfloat) anAngle {
	[deviceRotationMatrix populateIdentity];
	[deviceRotationMatrix rotateBy: cc3v(0.0f, 0.0f, anAngle)];
	[scene.activeCamera markTransformDirty];
}

@end
