/*
 * CC3Layer.m
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
 * See header file CC3Layer.h for full API documentation.
 */

#import "CC3Layer.h"
#import "CC3OpenGLFoundation.h"
#import "CC3Environment.h"
#import "CC3CC2Extensions.h"

@interface CC3Scene (ProtectedMethods)
-(void) setDeprecatedCC3Layer: (CC3Layer*) cc3Layer;
@end

@interface CCNode (ProtectedMethods)
-(void) contentSizeChanged;
@end


@implementation CC3Layer

@synthesize shouldAlwaysUpdateViewport=_shouldAlwaysUpdateViewport;
@synthesize shouldTrackViewSize=_shouldTrackViewSize;

-(void) dealloc {
	self.cc3Scene = nil;			// Close, remove & release the scene
	[_surfaceManager release];
	
	[self cc3RemoveAllGestureRecognizers];
	[_cc3GestureRecognizers release];

	[self deleteRenderStreamGroupMarker];

	[super dealloc];
}

-(CC3Scene*) cc3Scene {
	if (!_cc3Scene) self.cc3Scene = [self.cc3SceneClass scene];
	return _cc3Scene;
}

-(void) setCc3Scene: (CC3Scene*) aScene {
	 if (aScene == _cc3Scene) return;

	 [self closeCC3Scene];						// Close the old scene.
	 [_cc3Scene wasRemoved];					// Stop actions in old scene (if shouldStopActionsWhenRemoved set).
	 _cc3Scene.deprecatedCC3Layer = nil;		// Detach this layer from old scene.

	 [_cc3Scene release];
	 _cc3Scene = [aScene retain];

	 _cc3Scene.deprecatedCC3Layer = self;					// Point the scene back here
	 if (self.isRunningInActiveScene) [self openCC3Scene];	// If already running, open the new scene right away
	 
	 [self deleteRenderStreamGroupMarker];
}

-(Class) cc3SceneClass {
	Class sceneClass = nil;
	NSString* baseName = nil;
	NSString* layerClassName = NSStringFromClass(self.class);
	
	// If layer class name ends in "Layer", strip it and try some combinations
	if ( [layerClassName hasSuffix: @"Layer"] ) {
		baseName = [layerClassName substringToIndex: (layerClassName.length - @"Layer".length)];

		// Try HelloLayer -> HelloScene
		sceneClass = NSClassFromString([NSString stringWithFormat: @"%@Scene", baseName]);
		if (sceneClass && [sceneClass isSubclassOfClass: CC3Scene.class]) return sceneClass;
		
		// Try HelloLayer -> Hello
		sceneClass = NSClassFromString(baseName);
		if (sceneClass && [sceneClass isSubclassOfClass: CC3Scene.class]) return sceneClass;
	}

	// Try Hello -> HelloScene (including HelloLayer -> HelloLayerScene)
	sceneClass = NSClassFromString([NSString stringWithFormat: @"%@Scene", layerClassName]);
	if (sceneClass && [sceneClass isSubclassOfClass: CC3Scene.class]) return sceneClass;
	
	CC3Assert(NO, @"%@ could not determine the appropriate class to instantiate to automatically populate the cc3Scene property.", self);
	return nil;
}

/** 
 * Override to set the shouldAlwaysUpdateViewport to YES if the parent is not the root CCScene,
 * so that the viewport will be updated as ancestor nodes are moved around.
 */
-(void) setParent:(CCNode *)parent {
	[super setParent:parent];
	self.shouldAlwaysUpdateViewport = (parent && ![parent isKindOfClass: CCScene.class]);
}


#pragma mark Allocation and initialization

-(instancetype) init {
	_shouldTrackViewSize = YES;		// Could be overridden during init if contentSize set to something other than view size
	if( (self = [super init]) ) {
		_shouldAlwaysUpdateViewport = NO;
		[self initializeControls];
	}
	return self;
}

-(void) initializeControls {}

-(NSString*) description { return [NSString stringWithFormat: @"%@ on %@", self.class, _cc3Scene]; }


#pragma mark Transforming

-(void) setPosition: (CGPoint) newPosition {
	[super setPosition: newPosition];
	[self updateViewport];
}

#if CC3_CC2_1
-(void) setPositionInPixels: (CGPoint) newPosition {
	[super setPositionInPixels: newPosition];
	[self updateViewport];
}
#endif

-(void) setScale: (float) s {
	[super setScale: s];
	[self updateViewport];
}

-(void) setScaleX: (float) newScaleX {
	[super setScaleX: newScaleX];
	[self updateViewport];
}

-(void) setScaleY: (float) newScaleY {
	[super setScaleY: newScaleY];
	[self updateViewport];
}


#pragma mark CCRGBAProtocol and CCBlendProtocol support

-(CCColorRef) color { return self.cc3Scene.color; }

-(void)	setColor: (CCColorRef) color { self.cc3Scene.color = color; }

-(CCOpacity) opacity { return self.cc3Scene.opacity; }

-(void) setOpacity: (CCOpacity) opacity { self.cc3Scene.opacity = opacity; }


#pragma mark Surfaces

-(CC3SceneDrawingSurfaceManager*) surfaceManager {
	if (!_surfaceManager) self.surfaceManager = [self.surfaceManagerClass surfaceManager];
	return _surfaceManager;
}

-(void) setSurfaceManager: (CC3SceneDrawingSurfaceManager*) surfaceManager {
	CC3Assert([surfaceManager isKindOfClass: self.surfaceManagerClass],
			  @"The surface manager must be a type of %@", self.surfaceManagerClass);

	if (surfaceManager == _surfaceManager) return;

	[_surfaceManager release];
	
	_surfaceManager = [surfaceManager retain];
	[self updateViewport];
}

-(Class) surfaceManagerClass { return CC3SceneDrawingSurfaceManager.class; }


#pragma mark Updating layer

/** Invoked from cocos2d when this layer is first displayed. Opens the 3D scene. */
-(void) onEnter {
	[super onEnter];
	[self onOpenCC3Layer];
	[self openCC3Scene];
}

-(void) onOpenCC3Layer {}

/** Invoked automatically either from onEnter, or if new scene attached and layer is running. */
-(void) openCC3Scene {
	[self updateViewport];			// Set the camera viewport
	[self.cc3Scene open];			// Open the scene
}

/** Invoked from cocos2d when this layer is removed. Closes the 3D scene.  */
-(void) onExit {
	[self closeCC3Scene];
	[self onCloseCC3Layer];
	[self cc3RemoveAllGestureRecognizers];
	[super onExit];
}

-(void) onCloseCC3Layer {}

/** Invoked automatically either from onExit, or if old scene removed and layer is running. */
-(void) closeCC3Scene { [_cc3Scene close]; }	// Must not use property accessor!

-(void) update: (CCTime)dt { [self.cc3Scene updateScene: dt]; }

// Lazily initialized
-(NSArray*) cc3GestureRecognizers {
	if ( !_cc3GestureRecognizers ) _cc3GestureRecognizers = [NSMutableArray new];	// retained
	return _cc3GestureRecognizers;
}

-(void) cc3AddGestureRecognizer: (UIGestureRecognizer*) gesture {
	[((NSMutableArray*)self.cc3GestureRecognizers) addObject: gesture];
	[CCDirector.sharedDirector.view addGestureRecognizer: gesture];
}

-(void) cc3RemoveGestureRecognizer: (UIGestureRecognizer*) gesture {
	[CCDirector.sharedDirector.view removeGestureRecognizer: gesture];
	[_cc3GestureRecognizers removeObjectIdenticalTo: gesture];
}

-(void) cc3RemoveAllGestureRecognizers {
	NSArray* myGRs = [_cc3GestureRecognizers copy];
	for (UIGestureRecognizer* gr in myGRs) [self cc3RemoveGestureRecognizer: gr];
	[myGRs release];
}


#pragma mark Drawing

/** Draw the 3D scene with the specified drawing visitor. */
-(void) drawSceneWithVisitor: (CC3NodeDrawingVisitor*) visitor {

	// Ensure the visitor uses the surface manager of this layer
	visitor.surfaceManager = self.surfaceManager;
	
	if (_shouldAlwaysUpdateViewport) [self updateViewport];
	
	[self.cc3Scene drawSceneWithVisitor: visitor];
}

/** Drawing under Cocos2D 3.0 and before. */
-(void) draw { [self drawSceneWithVisitor: self.cc3Scene.viewDrawingVisitor]; }

#if CC3_CC2_RENDER_QUEUE

/** Drawing under Cocos2D 3.1 and after. */
-(void) draw: (CCRenderer*) renderer transform: (const GLKMatrix4*) transform {
	
	// Let the drawing visitor know about the renderer and transform
	CC3NodeDrawingVisitor* visitor = self.cc3Scene.viewDrawingVisitor;
	visitor.ccRenderer = renderer;
	[visitor populateLayerTransformMatrixFrom: transform];
	
	// Get a render command for this layer, tell it the visitor to use, and queue it
	CC3LayerRenderCommand* renderCmd = self.renderCommand;
	renderCmd.visitor = visitor;
	[renderer enqueueRenderCommand: renderCmd];
}

/** Returns a CCRenderer render command to render this layer.  */
-(CC3LayerRenderCommand*) renderCommand {
	return [CC3LayerRenderCommand renderCommandForCC3Layer: self];
}

#endif	// CC3_CC2_RENDER_QUEUE


#pragma mark Resizing support

-(void) contentSizeChanged {
	[super contentSizeChanged];
	
	[self updateViewport];
	
	if ( !CGSizeEqualToSize(self.contentSize, CCDirector.sharedDirector.viewSize) )
		self.shouldTrackViewSize = NO;
}

-(void) updateViewport {
	CGSize viewSize = CCDirector.sharedDirector.viewSizeInPixels;
	CGRect gbb = self.globalBoundingBoxInPixels;
	
	// Check whether the viewport covers the full UIView.
	BOOL isFullView = (CGPointEqualToPoint(gbb.origin, CGPointZero) &&
					   CGSizeEqualToSize(gbb.size, viewSize));

	// Convert the bounds of this layer to a viewport
	CC3Viewport vp = CC3ViewportFromCGRect(gbb);
	
	// Set the viewport into the view surface and the camera
	_surfaceManager.viewSurfaceOrigin = vp.origin;
	_surfaceManager.size = vp.size;
	
	CC3Camera* cam = self.cc3Scene.activeCamera;
	cam.viewport = vp;
	cam.shouldClipToViewport = !isFullView;

	[super updateViewport];
}

/**
 * Invoked automatically when the OS view has been resized.
 * Ensure view surfaces are resized, and if appropriate, resize this layer.
 */
-(void) viewDidResizeTo: (CGSize) newViewSize {

	// Ensure the size of all view surfaces is updated to match new view size.
	CC3ViewSurfaceManager.sharedViewSurfaceManager.size = CC3IntSizeFromCGSize(newViewSize);
	
	// If this layer should track the size of the view, update the size of this layer.
	if (self.shouldTrackViewSize) self.contentSize = CCNodeSizeFromViewSize(newViewSize);

	[super viewDidResizeTo: newViewSize];	// Propagate to descendants
}


#pragma mark Touch handling

/**
 * The priority at which touch events are delegated to this layer.
 * Default is zero. Subclasses may override.
 */
-(NSInteger) touchPriority { return 0; }

/**
 * The priority at which mouse events are delegated to this layer.
 * Default is zero. Subclasses may override.
 */
-(NSInteger) mouseDelegatePriority { return 0; }

#if CC3_CC2_CLASSIC

#if CC3_IOS

// Handle touch events one at a time.
-(void) registerWithTouchDispatcher {
	[CCDirector.sharedDirector.touchDispatcher addTargetedDelegate: self
														  priority: self.touchPriority
												   swallowsTouches:YES];
}

/** Handles the initial finger-down touch events. */
-(BOOL) ccTouchBegan: (UITouch*) touch withEvent: (UIEvent*) event {
	return [self handleTouch: touch ofType: kCCTouchBegan];
}

/** Handles the final finger-up touch events. */
-(void) ccTouchEnded: (UITouch*) touch withEvent: (UIEvent*) event {
	[self handleTouch: touch ofType: kCCTouchEnded];
}

/** Handles cancelled touch events. */
-(void) ccTouchCancelled: (UITouch*) touch withEvent: (UIEvent*) event {
	[self handleTouch: touch ofType: kCCTouchCancelled];
}

/**
 * The ccTouchMoved:withEvent: method is optional. Since the touch-move events are both 
 * voluminous and seldom used, the implementation of this method has been left out of 
 * the default CC3Layer implementation. To receive and handle touch-move events for 
 * object picking, copy the following method implementation to your CC3Layer subclass.
 */
//-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
//	[self handleTouch: touch ofType: kCCTouchMoved];
//}

/**
 * Invoked when any of the touch event handler methods are invoked.
 * Returns whether the event was handled by this layer.
 *
 * This implementation checks that the touch event is within the bounds of this
 * layer and, if it is, forwards the event to the handleTouchType:at: method.
 */
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType {
	return [self validateAndProcessTouchAt: [self convertTouchToNodeSpace: touch]
									ofType: touchType];
}

#endif	// CC3_IOS

#if CC3_OSX

/** Handles mouse down events under OSX. */
-(BOOL) ccMouseDown:(NSEvent*) event {
	return [self handleMouseEvent: event ofType: kCCTouchBegan];
}

/** Handles mouse drag events under OSX. */
-(BOOL) ccMouseDragged: (NSEvent*) event {
	return [self handleMouseEvent: event ofType: kCCTouchMoved];
}

/** Handles mouse up events under OSX. */
-(BOOL) ccMouseUp: (NSEvent*) event {
	return [self handleMouseEvent: event ofType: kCCTouchEnded];
}

/**
 * Invoked when any of the mouse event handler methods are invoked.
 * Returns whether the event was handled by this layer.
 *
 * This implementation checks that the mouse event is within the bounds of this
 * layer and, if it is, forwards the event to the handleTouchType:at: method.
 */
-(BOOL) handleMouseEvent: (NSEvent*) event ofType: (uint) touchType {
	return [self validateAndProcessTouchAt: [self cc3ConvertNSEventToNodeSpace: event]
									ofType: touchType];
}

#endif	// CC3_OSX

#else	// v3 event handling

#if CC3_IOS

/** Handles the initial finger-down touch events. */
-(void) touchBegan: (UITouch*) touch withEvent: (UIEvent*) event {
	if ( ![self handleTouch: touch ofType: kCCTouchBegan] )
		[super touchBegan: touch withEvent: event];
}

/** Handles the final finger-up touch events. */
-(void) touchEnded: (UITouch*) touch withEvent: (UIEvent*) event {
	if ( ![self handleTouch: touch ofType: kCCTouchEnded] )
		[super touchEnded: touch withEvent: event];
}

/**
 * The touchMoved:withEvent: method is optional. Since the touch-move events are both 
 * voluminous and seldom used, the implementation of this method has been left out of
 * the default CC3Layer implementation. To receive and handle touch-move events for 
 * object picking, copy the following method implementation to your CC3Layer subclass.
 */
//-(void) touchMoved: (UITouch*) touch withEvent: (UIEvent*) event {
//	if ( ![self handleTouch: touch ofType: kCCTouchMoved] )
//		[super touchMoved: touch withEvent: event];
//}

/** Handles cancelled touch events. */
-(void) touchCancelled: (UITouch*) touch withEvent: (UIEvent*) event {
	if ( ![self handleTouch: touch ofType: kCCTouchCancelled] )
		[super touchCancelled: touch withEvent: event];
}

/**
 * Invoked when any of the touch event handler methods are invoked.
 * Returns whether the event was handled by this layer.
 *
 * This implementation checks that the touch event is within the bounds of this
 * layer and, if it is, forwards the event to the handleTouchType:at: method.
 */
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType {
	return [self validateAndProcessTouchAt: [touch locationInNode: self]
									ofType: touchType];
}

#endif	// CC3_IOS

#if CC3_OSX

/** Handles mouse down events under OSX. */
-(void) mouseDown: (NSEvent*) event {
	if ( ![self handleMouseEvent: event ofType: kCCTouchBegan] )
		[super mouseDown: event];
}

/** Handles mouse drag events under OSX. */
-(void) mouseDragged: (NSEvent*) event {
	if ( ![self handleMouseEvent: event ofType: kCCTouchMoved] )
		[super mouseDragged: event];
}

/** Handles mouse up events under OSX. */
-(void) mouseUp: (NSEvent*) event {
	if ( ![self handleMouseEvent: event ofType: kCCTouchEnded] )
		[super mouseUp: event];
}

/**
 * Invoked when any of the mouse event handler methods are invoked.
 * Returns whether the event was handled by this layer.
 *
 * This implementation checks that the mouse event is within the bounds of this
 * layer and, if it is, forwards the event to the handleTouchType:at: method.
 */
-(BOOL) handleMouseEvent: (NSEvent*) event ofType: (uint) touchType {
	return [self validateAndProcessTouchAt: [event locationInNode: self]
									ofType: touchType];
}

#endif	// CC3_OSX

#endif	// CC3_CC2_CLASSIC

/** 
 * Processes an iOS touch or OSX mouse event at the specified point and returns whether
 * the touch event was handled or not.
 *
 * Verifies that the specified touch point is within the bounds of this layer,
 * then invokes the handleTouchType:at: method.
 */
-(BOOL) validateAndProcessTouchAt: (CGPoint) touchPoint ofType: (uint) touchType {
	CGSize cs = self.contentSize;
	CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
	if(CGRectContainsPoint(nodeBounds, touchPoint)) {
		LogTrace(@"%@ touched at: %@", self, NSStringFromCGPoint(touchPoint));
		return [self handleTouchType: touchType at: touchPoint];
	}
	return NO;
}

-(BOOL) handleTouchType: (uint) touchType at: (CGPoint) touchPoint {
	[self.cc3Scene touchEvent: touchType at: touchPoint];
	return YES;
}


#pragma mark Developer support

/** Lazily allocate and populate a char string built from the description property. */
-(const char*) renderStreamGroupMarker {
	if ( !_renderStreamGroupMarker ) {
		NSString* desc = self.description;
		NSUInteger buffLen = desc.length + 1;		// Plus null-term char
		_renderStreamGroupMarker = calloc(buffLen, sizeof(char));
		[desc getCString: _renderStreamGroupMarker maxLength: buffLen encoding: NSUTF8StringEncoding];
	}
	return _renderStreamGroupMarker;
}

/** Delete the memory used by the render stream group marker string. */
-(void) deleteRenderStreamGroupMarker {
	free(_renderStreamGroupMarker);
	_renderStreamGroupMarker = NULL;
}

@end


#if CC3_CC2_RENDER_QUEUE

#pragma mark -
#pragma mark CC3LayerRenderCommand

@interface CCRenderer (TemplateMethods)
-(void) bindVAO: (BOOL) bind;
@end

@implementation CC3LayerRenderCommand

@synthesize visitor=_visitor;

-(void) dealloc {
	[_cc3Layer release];
	[_visitor release];
	[super dealloc];
}

-(NSInteger) globalSortOrder { return 0; }

-(void) invokeOnRenderer: (CCRenderer*) renderer {
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	[gl pushGroupMarkerC: _cc3Layer.renderStreamGroupMarker];
	
	[renderer bindVAO: NO];
	[_cc3Layer drawSceneWithVisitor: _visitor];
	
	[gl popGroupMarker];
}


#pragma mark Allocation and initialization

-(instancetype) initForCC3Layer: (CC3Layer*) layer {
	if((self = [super init])){
		_cc3Layer = [layer retain];		// retained
	}
	
	return self;
}

+(instancetype) renderCommandForCC3Layer: (CC3Layer*) layer {
	return [[[self alloc] initForCC3Layer: layer] autorelease];
}

@end

#endif	// CC3_CC2_RENDER_QUEUE
