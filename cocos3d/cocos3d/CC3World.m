/*
 * CC3World.m
 *
 * cocos3d 0.6.0-sp
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
 * See header file CC3World.h for full API documentation.
 */

#import "CC3World.h"
#import "CC3MeshNode.h"
#import "CC3VertexArrayMesh.h"
#import "CC3Material.h"
#import "CC3Light.h"
#import "CC3Billboard.h"
#import "CC3OpenGLES11Engine.h"
#import "CCTouchDispatcher.h"
#import "CGPointExtension.h"
#import "ccMacros.h"


#pragma mark -
#pragma mark CC3World

@interface CC3Node (TemplateMethods)
-(void) drawChildrenWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) updateWithVisitor: (CC3NodeTransformingVisitor*) visitor;
-(void) updateTransformMatrices;
-(void) populateFrom: (CC3Node*) another;
@end

@interface CC3ViewportManager (CC3WorldCopying)
@property(nonatomic, assign) CC3World* world;
@end

@interface CC3World (TemplateMethods)
-(void) updateCamera: (ccTime) dt;
-(void) updateTargets: (ccTime) dt;
-(void) updateFog: (ccTime) dt;
-(void) updateBillboards: (ccTime) dt;
-(id) updateVisitorClass;
-(void) drawDrawSequenceWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) collectFrameInterval;
-(void) open3D;
-(void) close3D;
-(void) openViewport;
-(void) closeViewport;
-(void) open3DCamera;
-(void) close3DCamera;
-(void) illuminate;
-(void) drawFog;
-(void) drawBillboards;
-(id) drawVisitorClass;
-(id) pickVisitorClass;
-(void) populateDrawSequence;
-(void) updateDrawSequence;
-(BOOL) addToDrawingSequencer: (CC3Node*) aNode;
-(BOOL) removeFromDrawingSequencer: (CC3Node*) aNode;
@property(nonatomic, readonly) CC3WorldTouchHandler* touchHandler;
@end


@implementation CC3World

@synthesize activeCamera, ambientLight, minUpdateInterval, maxUpdateInterval;
@synthesize drawingSequencer, viewportManager, performanceStatistics, fog;

- (void)dealloc {
	[drawingSequence release];
	[drawingSequencer release];
	[targettingNodes release];
	[lights release];
	[cameras release];
	[billboards release];
	[activeCamera release];
	[touchHandler release];
	[viewportManager release];
	[fog release];
    [super dealloc];
}

// Protected property
-(CC3WorldTouchHandler*) touchHandler { return touchHandler; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		targettingNodes = [[NSMutableArray array] retain];
		lights = [[NSMutableArray array] retain];
		cameras = [[NSMutableArray array] retain];
		billboards = [[NSMutableArray array] retain];
		drawingSequence = [[NSArray array] retain];
		touchHandler = [[CC3WorldTouchHandler handlerOnWorld: self] retain];
		self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirst];
		self.viewportManager = [CC3ViewportManager viewportManagerOnWorld: self];
		fog = nil;
		activeCamera = nil;
		ambientLight = kCC3DefaultLightColorAmbientWorld;
		minUpdateInterval = kCC3DefaultMinimumUpdateInterval;
		maxUpdateInterval = kCC3DefaultMaximumUpdateInterval;
		[self initializeWorld];
	}
	return self;
}

// Default does nothing. Subclasses will customize.
-(void) initializeWorld {}

+(id) world {
	return [[self new] autorelease];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3World*) another {
	[super populateFrom: another];
	
	// Lights, cameras, targetting nodes, billboards & drawing sequence collections,
	// plus activeCamera will be populated as children are added.
	// No need to configure touch handler.
	[viewportManager release];
	viewportManager = [another.viewportManager copy];				// retained
	viewportManager.world = self;
	
	[drawingSequencer release];
	drawingSequencer = [another.drawingSequencer retain];			// retained...not copied
	
	[performanceStatistics release];
	performanceStatistics = [another.performanceStatistics copy];	// retained

	[fog release];
	fog = [another.fog copy];										// retained
	
	ambientLight = another.ambientLight;
	minUpdateInterval = another.minUpdateInterval;
	maxUpdateInterval = another.maxUpdateInterval;
}


#pragma mark Updating world state

-(void) play {
	self.isRunning = YES;
}

-(void) pause {
	self.isRunning = NO;
}

/**
 * If needed, clamps the specified interval value, then invokes a sequence of template methods.
 * Does nothing if this instance is not running.
 */
-(void) updateWorld: (ccTime) dt {
	[performanceStatistics addUpdateTime: dt];
	if(self.isRunning) {
		// Clamp the specified interval to a range defined by the minimum and maximum
		// update intervals. If the maximum update interval limit is zero or negative,
		// its value is ignored, and the dt value is not limited to a maximum value.
		ccTime dtClamped = CLAMP(dt, minUpdateInterval,
								(maxUpdateInterval > 0.0 ? maxUpdateInterval : dt));

		LogTrace(@"******* %@ starting update: %.2f ms (clamped from %.2f ms)",
				 self, dtClamped * 1000.0, dt * 1000.0);

		[touchHandler dispatchPickedNode];
		[self updateWithVisitor: [[self updateVisitorClass] visitorWithWorld: self
																andDeltaTime: dtClamped]];
		[self updateTargets: dtClamped];
		[self updateCamera: dtClamped];
		[self updateBillboards: dtClamped];
		[self updateFog: dtClamped];
		[self updateDrawSequence];

		LogTrace(@"******* %@ exiting update", self);
	}
}

/** Overridden to open and close the visitor before and after updating, respectively. */
-(void) updateWithVisitor: (CC3NodeUpdatingVisitor*) visitor {
	[visitor open];
	[super updateWithVisitor: visitor];
	[visitor close];
}

/** 
 * Template method to update the direction pointed to by any targetting nodes in this world.
 * Iterates through all the targetting nodes in this world, updating their target tracking.
 */
-(void) updateTargets: (ccTime) dt {
	for (CC3TargettingNode* tn in targettingNodes) {
		[tn trackTarget];
	}
}

/**
 * Template method to update the camera's perspective,
 * including both projection and modelview matrices.
 */
-(void) updateCamera: (ccTime) dt {
	[activeCamera buildPerspective];
}

/** Template method to update any fog characteristics. */
-(void) updateFog: (ccTime) dt {
	[fog update: dt];
}

/**
 * Template method to update any billboards.
 * Iterates through all billboards, instructing them to face the current camera position.
 */
-(void) updateBillboards: (ccTime) dt {
	for (CC3Billboard* bb in billboards) {
		[bb faceCamera: activeCamera];
	}
	LogTrace(@"%@ updated %u billboards", self, billboards.count);
}

-(void) updateWorld {
	[self updateWorld: minUpdateInterval];
}

/**
 * Returns the class of visitor that will be instantiated in the updateWorld: method,
 * and passed to the updateWithVisitor: method during update operations.
 *
 * The returned class must be a subclass of CC3NodeUpdatingVisitor. This implementation
 * returns CC3NodeUpdatingVisitor. Subclasses may override to customized the behaviour
 * of the update visits.
 */
-(id) updateVisitorClass {
	return [CC3NodeUpdatingVisitor class];
}

/** Default does nothing. Subclasses that handle touch events will override. */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {}


#pragma mark Drawing

-(void) drawWorld {
	LogGLErrorState();			// Check and clear any GL error that occurred before 3D code
	LogTrace(@"******* %@ starting drawing visit", self);
	[self collectFrameInterval];	// Collect the frame interval in the performance statistics.
	
	if (self.visible) {
		[self open3D];
		[self openViewport];
		[self open3DCamera];
		[touchHandler pickTouchedNode];
		[self illuminate];
		[self drawFog];
		[self drawWithVisitor: [[self drawVisitorClass] visitorWithWorld: self]];
		[self close3DCamera];
		[self closeViewport];
		[self close3D];
		[self drawBillboards];	// Back to 2D now
	}
	
	LogGLErrorState();			// Check and clear any GL error that occurred during 3D code
	LogTrace(@"******* %@ exiting drawing visit", self);
}

/**
 * Overridden to open and close the visitor before and after drawing, respectively,
 * and to avoid checking the world itself against the camera frustum.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor open];
	if(self.visible && visitor.shouldVisitChildren) {
		[self drawChildrenWithVisitor: visitor];
	}
	[visitor close];
}


/** Overridden to make use of the drawingSequence if it is available. */
-(void) drawChildrenWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (self.isUsingDrawingSequence) {
		[self drawDrawSequenceWithVisitor: visitor];
	} else {
		[super drawChildrenWithVisitor: visitor];
	}
}

/**
 * Template method that draws children by cycling through the nodes in the drawingSequence,
 * instead of drawing hierarchically. Sets the visitor not to visit the children of the
 * nodes in the drawingSequence.
 */
-(void) drawDrawSequenceWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	visitor.shouldVisitChildren = NO;
	for (CC3Node* child in drawingSequence) {
		[child drawWithVisitor: visitor];
	}
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
	LogTrace(@"%@ opening the 3D world", self);

	// Retrieves the GLES state trackers to set initial state
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = gles11Engine.serverCapabilities;
	CC3OpenGLES11State* gles11State = gles11Engine.state;
	
	// Open tracking of GL state. Where needed, will cache current 2D GL state items
	// for later reinstatement in the close3D method.
	[gles11Engine open];

	// Specify culling capabilities needed for 3D
	[gles11ServCaps.cullFace enable];
	gles11State.cullFace.value = GL_BACK;
	gles11State.frontFace.value = GL_CCW;

	// Specify 3D depth testing capabilities
	[gles11ServCaps.depthTest enable];				// Enable depth testing
	gles11State.depthMask.value = YES;				// Enble writing to depth buffer
	gles11State.depthFunction.value = GL_LEQUAL;	// Set depth comparison function
	
	gles11State.shadeModel.value = GL_SMOOTH;		// Enable smooth shading
	
	// Ensure drawing is not slowed down by unexpected alpha testing and logic ops
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
	LogTrace(@"%@ closing the 3D world", self);

	// Close tracking of GL state, reverting to 2D values where required.
	[[CC3OpenGLES11Engine engine] close];
	
	// Clear the depth buffer so that subsequent cocos2d rendering will occur
	// on top of the 3D rendering. We can't simply turn depth testing off
	// because cocos2d can use depth testing for 3D transition effects.
	[[CC3OpenGLES11Engine engine].state clearDepthBuffer];
}

/** Template method that opens the 3D camera. */
-(void) openViewport {
	[viewportManager openViewport];
}	

/** Template method that closes the 3D camera. This is the compliment of the open3DCamera method. */
-(void) closeViewport {
	[viewportManager closeViewport];
}


/** Template method that opens the 3D camera. */
-(void) open3DCamera {
	[activeCamera open];
}	

/** Template method that closes the 3D camera. This is the compliment of the open3DCamera method. */
-(void) close3DCamera {
	[activeCamera close];
}

/**
 * Template method that turns on lighting of the 3D world. Turns on global ambient lighting,
 * and iterates through the CC3Light instances, turning them on. If the 2D world uses any
 * lights, they are disabled.
 */
-(void) illuminate {
	LogTrace(@"%@ lighting the 3D world", self);

	[CC3Light disableReservedLights];		// disable any lights used by 2D world

	BOOL hasLighting = (lights.count > 0 || !ccc4FEqual(ambientLight, kCCC4FBlackTransparent));
	[CC3OpenGLES11Engine engine].serverCapabilities.lighting.value = hasLighting;

	// Set the ambient light for the whole world
	[CC3OpenGLES11Engine engine].lighting.worldAmbientLight.value = ambientLight;

	// Turn on any individual lights
	for (CC3Light* lgt in lights) {
		[lgt turnOn];
	}
}

/** If this world contains fog, draw it, otherwise unbind fog from the GL engine. */
-(void) drawFog {
	if (fog) {
		[fog draw];
	} else {
		[CC3Fog unbind];
	}
}

/**
 * Draws any billboards.
 * This is invoked after close3D, so the drawing of billboards occurs in 2D.
 */
-(void) drawBillboards {
	LogTrace(@"%@ drawing %i billboards", self, billboards.count);

	if (activeCamera && (billboards.count > 0)) {
		CC3Viewport vp = viewportManager.viewport;

		// Since billboards draw outside the 3D camera, if the CC3Layer does not
		// cover the full screen, billboards can be drawn outside the CC3Layer.
		// Enable scissoring to the viewport dimensions to clip to the layer bounds.
		[[CC3OpenGLES11Engine engine].serverCapabilities.scissorTest enable];
		[CC3OpenGLES11Engine engine].state.scissor.value = vp;
		
		for (CC3Billboard* bb in billboards) {
			[bb draw2dWithinBounds: viewportManager.layerBoundsLocal];
		}
		
		// All done...turn scissoring back off now.
		// This is happening after the close3D method, so we need to close
		// the scissor trackers manually.
		[[CC3OpenGLES11Engine engine].serverCapabilities.scissorTest close];
		[[CC3OpenGLES11Engine engine].state.scissor close];
	}
}

/**
 * Returns the class of visitor that will be instantiated in the drawWorld method,
 * and passed to the drawWithVisitor: method during drawing operations.
 *
 * The returned class must be a subclass of CC3NodeDrawingVisitor. This implementation
 * returns CC3NodeDrawingVisitor. Subclasses may override to customized the behaviour
 * of the drawing visits.
 */
-(id) drawVisitorClass {
	return [CC3NodeDrawingVisitor class];
}

/**
 * Returns the class of visitor that will be instantiated in the touchHandler
 * pickTouchedNode method, and passed to the drawWithVisitor: method in order
 * to paint each node a unique color so that the node under the touched pixel
 * can be identified.
 *
 * The returned class must be a subclass of CC3NodePickingVisitor. This implementation
 * returns CC3NodePickingVisitor. Subclasses may override to customized the behaviour
 * of the drawing visits.
 */
-(id) pickVisitorClass {
	return [CC3NodePickingVisitor class];
}


#pragma mark Drawing sequencer

-(BOOL) isUsingDrawingSequence {
	return (drawingSequencer != nil);
}

/**
 * Property setter overridden to add all the decendent nodes of this world
 * into the new  node sequencer, and then generate a new drawSequence.
 */
-(void) setDrawSequencer:(CC3NodeSequencer*) aNodeSequencer {
	id oldDSS = drawingSequencer;
	drawingSequencer = [aNodeSequencer retain];
	[oldDSS release];

	CC3NodeSequencerVisitor* seqVisitor = [CC3NodeSequencerVisitor visitorWithWorld: self];
	NSArray* allNodes = [self flatten];
	for (CC3Node* aNode in allNodes) {
		[drawingSequencer add: aNode withVisitor: seqVisitor];
	}
	[self populateDrawSequence];
}

/** Populates a new linear draw sequence from the nodes in the drawSequencer. */
-(void) populateDrawSequence {
	[drawingSequence release];
	drawingSequence = [ (drawingSequencer ? drawingSequencer.nodes : [NSArray array]) retain];
	LogTrace("%@ created draw sequence of %u children: %@", self, drawingSequence.count, drawingSequence);
}

-(void) updateDrawSequence {
	if (drawingSequencer && [drawingSequencer updateSequenceWithVisitor:
								[CC3NodeSequencerMisplacedNodeVisitor visitorWithWorld: self]]) {
		LogTrace(@"%@", [drawingSequencer fullDescription]);
		[self populateDrawSequence];
	}
}


#pragma mark Node structural hierarchy

/**
 * Overridden to attempt to add each node to the drawingSequencer, and to add any nodes
 * that require special handling, like cameras, lights and billboards to their respective
 * caches. The node being added is first flattened, so that this processing is performed
 * not only on that node, but all its hierarchical decendants.
 */
-(void) didAddDescendant: (CC3Node*) aNode {
	LogTrace(@"Adding %@ as descendant to %@", aNode, self);
	BOOL drawSeqChanged = NO;
	CC3NodeSequencerVisitor* seqVisitor = [CC3NodeSequencerVisitor visitorWithWorld: self];
	
	// Collect all the nodes being added, including all descendants,
	// and see if they require special treatment
	NSArray* allAdded = [aNode flatten];
	for (CC3Node* addedNode in allAdded) {
	
		// Attempt to add the node to the draw sequence sorter and remember if it was added.
		drawSeqChanged |= drawingSequencer
							? [drawingSequencer add: addedNode withVisitor: seqVisitor]
							: NO;
		
		// If the node is a targetting node, add it to the collection of such nodes
		if ( [addedNode isKindOfClass: [CC3TargettingNode class]] ) {
			LogTrace(@"Adding targetting node %@", addedNode);
			[targettingNodes addObject: addedNode];
		}
		
		// If the node is a light, add it to the collection of lights
		if ( [addedNode isKindOfClass: [CC3Light class]] ) {
			LogTrace(@"Adding light %@", addedNode);
			[lights addObject: addedNode];
		}
		
		// If the node is a camera, add it to the collection of cameras, and
		// if the node is the first camera to be added, make it the active camera.
		if ( [addedNode isKindOfClass: [CC3Camera class]] ) {
			((CC3Camera*)addedNode).world = self;
			[cameras addObject: addedNode];
			if ( !activeCamera ) {
				self.activeCamera = (CC3Camera*)addedNode;
				LogTrace(@"Assigning %@ as the active camera", self.activeCamera);
			}
		}
		
		// If the node is a billboard, add it to the collection of billboards
		if ( [addedNode isKindOfClass: [CC3Billboard class]] ) {
			LogTrace(@"Adding billboard %@", addedNode);
			[billboards addObject: addedNode];
		}
	}

	// If the draw sequence was changed, re-populate it.
	if (drawSeqChanged) {
		[self populateDrawSequence];
	}
}

/**
 * Overridden to attempt to remove each node to the drawingSequencer, and to remove any nodes
 * that require special handling, like cameras, lights and billboards from their respective
 * caches. The node being removed is first flattened, so that this processing is performed
 * not only on that node, but all its hierarchical decendants.
 */
-(void) didRemoveDescendant: (CC3Node*) aNode {
	LogTrace(@"Removing %@ as descendant of %@", aNode, self);
	BOOL drawSeqChanged = NO;
	CC3NodeSequencerVisitor* seqVisitor = [CC3NodeSequencerVisitor visitorWithWorld: self];
	
	// Collect all the nodes being removed, including all descendants,
	// and see if they require special treatment
	NSArray* allRemoved = [aNode flatten];
	for (CC3Node* removedNode in allRemoved) {
		
		// Attempt to remove the node to the draw sequence sorter and remember if it was removed.
		drawSeqChanged |= drawingSequencer
							? [drawingSequencer remove: removedNode withVisitor: seqVisitor]
							: NO;
		
		// If the node is a targetting node, remove it from the collection of such nodes
		if ( [removedNode isKindOfClass: [CC3TargettingNode class]] ) {
			LogTrace(@"Removing targetting node %@", removedNode);
			[targettingNodes removeObjectIdenticalTo: removedNode];
		}
		
		// If the node is a light, remove it from the collection of lights
		if ( [removedNode isKindOfClass: [CC3Light class]] ) {
			LogTrace(@"Removing light %@", removedNode);
			[lights removeObjectIdenticalTo: removedNode];
		}
		
		// If the node is a camera, remove it from the collection of cameras,
		// and if it is the active camera, make the next camera active if one is available.
		if ( [removedNode isKindOfClass: [CC3Camera class]] ) {
			[cameras removeObjectIdenticalTo: removedNode];
			if (removedNode == activeCamera) {
				self.activeCamera = cameras.count ? [cameras objectAtIndex: 0] : nil;
				LogTrace(@"Assigning %@ as the active camera", self.activeCamera);
			}
			((CC3Camera*)removedNode).world = nil;
		}
		
		// If the node is a billboard, remove it from the collection of billboards
		if ( [removedNode isKindOfClass: [CC3Billboard class]] ) {
			LogTrace(@"Removing billboard %@", removedNode);
			[billboards removeObjectIdenticalTo: removedNode];
		}
	}
	
	// If the draw sequence was changed, re-populate it.
	if (drawSeqChanged) {
		[self populateDrawSequence];
	}
}

/**
 * A property on a descendant node has changed that potentially affects its order
 * in the drawingSequence. To put it in the correct position within the sequencer,
 * remove it from the drawingSequencer and then re-add it.
 */
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode {
	CC3NodeSequencerVisitor* seqVisitor = [CC3NodeSequencerVisitor visitorWithWorld: self];
	BOOL drawSeqChanged = NO;
	
	// Remove the node and then re-add it to make sure it it sequenced correctly
	drawSeqChanged |= drawingSequencer
						? [drawingSequencer remove: aNode withVisitor: seqVisitor]
						: NO;
	drawSeqChanged |= drawingSequencer
						? [drawingSequencer add: aNode withVisitor: seqVisitor]
						: NO;
	
	// If the draw sequence was changed, re-populate it.
	if (drawSeqChanged) {
		[self populateDrawSequence];
	}
}


#pragma mark Touch handling

// Forward to the encapsulated touch handler.
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
	[touchHandler touchEvent: touchType at: touchPoint];
}

@end


#pragma mark -
#pragma mark CC3WorldTouchHandler

@interface CC3WorldTouchHandler (TemplateMethods)
-(NSString*) nameOfTouchType: (uint) tType;
@end


@implementation CC3WorldTouchHandler

-(void) dealloc {
	world = nil;			// not retained
	pickedNode = nil;		// not retained
	[super dealloc];
}

/** Returns the touch point mapped to the device-oriented GL coordinate space. */
-(CGPoint) glTouchPoint {
	return [world.viewportManager glPointFromCC2Point: touchPoint];
}


#pragma mark Allocation and initialization

-(id) init {
	return [self initOnWorld: nil];
}

-(id) initOnWorld: (CC3World*) aCC3World {
	if ( (self = [super init]) ) {
		world = aCC3World;
		touchPoint = CGPointZero;
		wasTouched = NO;
		wasPicked = NO;
		pickedNode = nil;
		queuedTouchCount = 0;
	}
	return self;
}

+(id) handlerOnWorld: (CC3World*) aCC3World {
	return [[[self alloc] initOnWorld: aCC3World] autorelease];
}


#pragma mark Touch handling

-(void) touchEvent: (uint) tType at: (CGPoint) tPoint {

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

	LogTrace(@"%@ touched %@ at %@. Queue length now %u.", self, [self nameOfTouchType: tType],
			 NSStringFromCGPoint(touchPoint), queuedTouchCount);
}

-(void) pickTouchedNode {
	if (wasTouched) {
		wasTouched = NO;
		CC3NodePickingVisitor* pickVisitor = [[world pickVisitorClass] visitorWithWorld: world];
		[world drawWithVisitor: pickVisitor];
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
					 self, [self nameOfTouchType: touchQueue[i]], pickedNode.touchableNode,
					 NSStringFromCGPoint(touchPoint), NSStringFromCGPoint(self.glTouchPoint), pickedNode);

			[world nodeSelected: pickedNode.touchableNode byTouchEvent: touchQueue[i] at: touchPoint];
		}
	}
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@", [self class]];
}

-(NSString*) nameOfTouchType: (uint) tType {
	switch (tType) {
		case kCCTouchBegan:
			return @"kCCTouchBegan";
		case kCCTouchMoved:
			return @"kCCTouchMoved";
		case kCCTouchEnded:
			return @"kCCTouchEnded";
		case kCCTouchCancelled:
			return @"kCCTouchCancelled";
		default:
			return [NSString stringWithFormat: @"unknown touch type (%u)", tType];
	}
}

@end


#pragma mark -
#pragma mark CC3ViewportManager

@interface CC3ViewportManager (TemplateMethods)
-(void) updateDeviceRotationAngle:(GLfloat) anAngle;
@property(nonatomic, assign) CC3World* world;
@property(nonatomic, readonly) CC3Vector glToCC2PointMapX;
@property(nonatomic, readonly) CC3Vector glToCC2PointMapY;
@property(nonatomic, readonly) CC3Vector cc2ToGLPointMapX;
@property(nonatomic, readonly) CC3Vector cc2ToGLPointMapY;
@end


@implementation CC3ViewportManager

@synthesize layerBounds, viewport, deviceRotationMatrix;

-(void) dealloc {
	[deviceRotationMatrix release];
	world = nil;			// not retained
	[super dealloc];
}

-(CGRect) layerBoundsLocal {
	CGRect localBounds;
	localBounds.origin = CGPointMake(0.0, 0.0);
	localBounds.size = layerBounds.size;
	return localBounds;
}

#pragma mark Allocation and initialization

-(id) init {
	return [self initOnWorld: nil];
}

-(id) initOnWorld: (CC3World*) aCC3World {
	if ( (self = [super init]) ) {
		world = aCC3World;
		self.deviceRotationMatrix = [CC3GLMatrix identity];
		layerBounds = CGRectZero;
		viewport = CC3ViewportMake(0, 0, 0, 0);
		glToCC2PointMapX = cc3v( 1.0,  0.0, 0.0 );
		glToCC2PointMapY = cc3v( 0.0,  1.0, 0.0 );
		cc2ToGLPointMapX = cc3v( 1.0,  0.0, 0.0 );
		cc2ToGLPointMapY = cc3v( 0.0,  1.0, 0.0 );
	}
	return self;
}

+(id) viewportManagerOnWorld: (CC3World*) aCC3World {
	return [[[self alloc] initOnWorld: aCC3World] autorelease];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// The world ivar is set by the new CC3World, since it changes with the copy.
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

// Protected properties for copying
-(CC3Vector) glToCC2PointMapX { return glToCC2PointMapX; }
-(CC3Vector) glToCC2PointMapY { return glToCC2PointMapY; }
-(CC3Vector) cc2ToGLPointMapX { return cc2ToGLPointMapX; }
-(CC3Vector) cc2ToGLPointMapY { return cc2ToGLPointMapY; }
-(CC3World*) world { return world; }
-(void) setWorld: (CC3World*) aCC3World { world = aCC3World; }


#pragma mark Drawing

-(void) openViewport {
	LogTrace(@"%@ opening 3D viewport %@", self, NSStringFromCC3Viewport(viewport));
	[CC3OpenGLES11Engine engine].state.viewport.value = viewport;
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
 */
-(void) updateBounds: (CGRect) bounds withDeviceOrientation: (ccDeviceOrientation) deviceOrientation {
	CGSize winSz = [[CCDirector sharedDirector] winSizeInPixels];
	CC3Viewport vp;
	CGPoint bOrg = bounds.origin;
	CGSize bSz = bounds.size;
	
	// CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	GLfloat c2g = CC_CONTENT_SCALE_FACTOR();		// Ratio of CC2 points to GL pixels...
	GLfloat g2c = 1.0 / c2g;						// ...and its inverse.
	
	switch(deviceOrientation) {
			
		case kCCDeviceOrientationLandscapeLeft:
			[self updateDeviceRotationAngle: -90.0f];
			
			vp.x = MAX((GLint)bOrg.y, 0);
			vp.y = (GLint)(winSz.width - (bOrg.x + bSz.width));
			vp.w = MIN((GLint)(bSz.height), winSz.height);
			vp.h = MIN((GLint)(bSz.width), winSz.width);
			
			glToCC2PointMapX = cc3v(  0.0, -g2c, (vp.y + vp.h) * g2c );
			glToCC2PointMapY = cc3v(  g2c,  0.0, -vp.x * g2c );
			cc2ToGLPointMapX = cc3v(  0.0,  c2g,  vp.x );
			cc2ToGLPointMapY = cc3v( -c2g,  0.0,  vp.y + vp.h );
			
			LogTrace(@"Orienting to LandscapeLeft with bounds: %@ in window: %@ and viewport: %@",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz), NSStringFromCC3Viewport(vp));
			break;
			
		case kCCDeviceOrientationLandscapeRight:
			[self updateDeviceRotationAngle: 90.0f];
			
			vp.x = MAX((GLint)(winSz.height - (bOrg.y + bSz.height)), 0);
			vp.y = MAX((GLint)bOrg.x, 0);
			vp.w = MIN((GLint)(bSz.height), winSz.height);
			vp.h = MIN((GLint)(bSz.width), winSz.width);
			
			glToCC2PointMapX = cc3v(  0.0,  g2c, -vp.y * g2c );
			glToCC2PointMapY = cc3v( -g2c,  0.0, (vp.x + vp.w) * g2c );
			cc2ToGLPointMapX = cc3v(  0.0, -c2g,  vp.x + vp.w );
			cc2ToGLPointMapY = cc3v(  c2g,  0.0,  vp.y );
			
			LogTrace(@"Orienting to LandscapeRight with bounds: %@ in window: %@ and viewport: %@",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz), NSStringFromCC3Viewport(vp));
			break;
			
		case kCCDeviceOrientationPortraitUpsideDown:
			[self updateDeviceRotationAngle: 180.0f];
			
			vp.x = MAX((GLint)(winSz.width - (bOrg.x + bSz.width)), 0);
			vp.y = (GLint)(winSz.height - (bOrg.y + bSz.height));
			vp.w = MIN((GLint)bSz.width, winSz.width);
			vp.h = MIN((GLint)bSz.height, winSz.height);
			
			glToCC2PointMapX = cc3v( -g2c,  0.0, (vp.x + vp.w) * g2c );
			glToCC2PointMapY = cc3v(  0.0, -g2c, (vp.y + vp.h) * g2c );
			cc2ToGLPointMapX = cc3v( -c2g,  0.0,  vp.x + vp.w );
			cc2ToGLPointMapY = cc3v(  0.0, -c2g,  vp.y + vp.h );
			
			LogTrace(@"Orienting to PortraitUpsideDown with bounds: %@ in window: %@ and viewport: %@",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz), NSStringFromCC3Viewport(vp));
			break;
			
		default:
			[self updateDeviceRotationAngle: 0.0f];
			
			vp.x = MAX((GLint)bOrg.x, 0);
			vp.y = MAX((GLint)bOrg.y, 0);
			vp.w = MIN((GLint)bSz.width, winSz.width);
			vp.h = MIN((GLint)bSz.height, winSz.height);
			
			glToCC2PointMapX = cc3v(  g2c,  0.0, -vp.x * g2c );
			glToCC2PointMapY = cc3v(  0.0,  g2c, -vp.y * g2c );
			cc2ToGLPointMapX = cc3v(  c2g,  0.0,  vp.x );
			cc2ToGLPointMapY = cc3v(  0.0,  c2g,  vp.y );

			LogTrace(@"Orienting to Portrait with bounds: %@ in window: %@ and viewport: %@",
					 NSStringFromCGRect(bounds), NSStringFromCGSize(winSz), NSStringFromCC3Viewport(vp));
			break;
	}
	
	// Set the layerBounds and viewport, and tell the camera that we've been updated
	layerBounds = bounds;
	viewport = vp;
	[world.activeCamera markProjectionDirty];
}

/**
 * Rebuilds the deviceRotationMatrix from the specified rotation angle, and marks the
 * camera's transfom as dirty so that the camera's modelview matrix will be rebuilt.
 */
-(void) updateDeviceRotationAngle:(GLfloat) anAngle {
	[deviceRotationMatrix populateIdentity];
	[deviceRotationMatrix rotateByZ: anAngle];
	[world.activeCamera markTransformDirty];
}

@end
