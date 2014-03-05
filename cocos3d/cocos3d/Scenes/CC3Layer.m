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
#import "CC3GLView.h"


@implementation CC3Layer

@synthesize cc3Scene=_cc3Scene, shouldAlwaysUpdateViewport=_shouldAlwaysUpdateViewport;

- (void)dealloc {
	self.cc3Scene = nil;			// Close, remove & release the scene
	[self cc3RemoveAllGestureRecognizers];
	[_cc3GestureRecognizers release];
	[super dealloc];
}

 -(void) setCc3Scene: (CC3Scene*) aScene {
	 if (aScene == _cc3Scene) return;

	 [self closeCC3Scene];						// Close the old scene.
	 [_cc3Scene wasRemoved];					// Stop actions in old scene (if shouldStopActionsWhenRemoved set).
	 _cc3Scene.cc3Layer = nil;					// Detach this layer from old scene.

	 [_cc3Scene release];
	 _cc3Scene = [aScene retain];

	 _cc3Scene.cc3Layer = self;								// Point the scene back here
	 if (self.isRunningInActiveScene) [self openCC3Scene];	// If already running, open the new scene right away
}


#pragma mark Allocation and initialization

-(id) init {
	if( (self = [super init]) ) {
		_shouldAlwaysUpdateViewport = NO;
		self.mousePriority = 0;
		[self initializeControls];
	}
	return self;
}

-(void) initializeControls {}


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

-(ccColor3B) color { return _cc3Scene.color; }

-(void)	setColor: (ccColor3B) color { _cc3Scene.color = color; }

-(GLubyte) opacity { return _cc3Scene.opacity; }

-(void) setOpacity: (GLubyte) opacity { _cc3Scene.opacity = opacity; }


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
	[_cc3Scene open];				// Open the scene
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
-(void) closeCC3Scene { [_cc3Scene close]; }

-(void) update: (CCTime)dt { [_cc3Scene updateScene: dt]; }

// Lazily initialized
-(NSArray*) cc3GestureRecognizers {
	if ( !_cc3GestureRecognizers ) _cc3GestureRecognizers = [NSMutableArray new];	// retained
	return _cc3GestureRecognizers;
}

-(void) cc3AddGestureRecognizer: (UIGestureRecognizer*) gesture {
	[((NSMutableArray*)self.cc3GestureRecognizers) addObject: gesture];
	[self.controller.view addGestureRecognizer: gesture];
}

-(void) cc3RemoveGestureRecognizer: (UIGestureRecognizer*) gesture {
	[self.controller.view removeGestureRecognizer: gesture];
	[_cc3GestureRecognizers removeObjectIdenticalTo: gesture];
}

-(void) cc3RemoveAllGestureRecognizers {
	NSArray* myGRs = [_cc3GestureRecognizers copy];
	for (UIGestureRecognizer* gr in myGRs) [self cc3RemoveGestureRecognizer: gr];
	[myGRs release];
}


#pragma mark Drawing

-(void) draw {
	if (_shouldAlwaysUpdateViewport) [self updateViewport];
	[_cc3Scene drawScene];
}


#pragma mark CC3ControllableLayer support

/**
 * Invoked automatically when the content size has changed.
 * Updates the viewport to match the new layer dimensions.
 */
-(void) didUpdateContentSizeFrom: (CGSize) oldSize {
	[super didUpdateContentSizeFrom: oldSize];
	[self updateViewport];
}

-(void) updateViewport {
	CGSize viewSize = CCDirector.sharedDirector.viewSizeInPixels;
	CGRect gbb = self.globalBoundingBoxInPixels;
	
	// Check whether the viewport covers the full UIView.
	BOOL isFullView = (CGPointEqualToPoint(gbb.origin, CGPointZero) &&
					   CGSizeEqualToSize(gbb.size, viewSize));

	CC3Camera* cam = self.cc3Scene.activeCamera;
	cam.viewport = CC3ViewportFromCGRect(gbb);
	cam.shouldClipToViewport = !isFullView;

	[super updateViewport];
}

/**
 * Invoked automatically when the window has been resized while running in OSX.
 * Resize this layer to fill the window.
 */
-(void) reshapeProjection: (CGSize) newWindowSize { self.contentSize = newWindowSize; }


#pragma mark Touch handling

// Handle touch events one at a time.
-(void) registerWithTouchDispatcher {
	[CCDirector.sharedDirector.touchDispatcher addTargetedDelegate: self
														  priority: self.touchPriority
												   swallowsTouches:YES];
}

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

/** Handles the initial finger-down touch events. */
-(BOOL) ccTouchBegan: (UITouch *)touch withEvent: (UIEvent *)event {
	return [self handleTouch: touch ofType: kCCTouchBegan];
}

/** Handles the final finger-up touch events. */
-(void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchEnded];
}

/** Handles cancelled touch events. */
-(void) ccTouchCancelled: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchCancelled];
}

/**
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, copy the following method implementation to your CC3Layer subclass.
 */
//-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
//	[self handleTouch: touch ofType: kCCTouchMoved];
//}

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
 * Handles mouse hover movement events under OSX
 * By default, "mouseMoved" is disabled. To enable it, uncomment this method, and set the
 * acceptsMouseMovedEvents property of the main window to YES during app initialization.
 */
//-(BOOL) ccMouseMoved:(NSEvent*)event {}


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
	[_cc3Scene touchEvent: touchType at: touchPoint];
	return YES;
}

@end


