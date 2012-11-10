/*
 * CC3Layer.m
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
 * See header file CC3Layer.h for full API documentation.
 */

#import "CC3Layer.h"
#import "CC3OpenGLES11Foundation.h"
#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"


@interface CC3Layer (TemplateMethods)
-(void) openCC3Scene;
-(void) closeCC3Scene;
-(void) drawBackdrop;
-(void) drawScene;
-(int) touchPriority;
-(void) drawWorld;		// Deprecated legacy
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType;
-(BOOL) handleTouchType: (uint) touchType at: (CGPoint) touchPoint;
@end

@implementation CC3Layer

@synthesize cc3Scene, shouldAlwaysUpdateViewport;

- (void)dealloc {
	// Legacy iVar cc3World is not cleared here because it is
	// not retained and setting to nil causes deprecation warning.
	self.cc3Scene = nil;			// Close, remove & release the scene
	[self cc3RemoveAllGestureRecognizers];
	[cc3GestureRecognizers release];
    [super dealloc];
}

 -(void) setCc3Scene: (CC3Scene*) aScene {
	 if (aScene != cc3Scene) {
		 [self closeCC3Scene];					// Close the old scene.
		 [cc3Scene wasRemoved];					// Stop actions in old scene (if shouldStopActionsWhenRemoved set).
		 cc3Scene.cc3Layer = nil;				// Detach this layer from old scene.
		 [cc3Scene autorelease];				// Release old scene if it's not assigned to another layer first

		 cc3Scene = [aScene retain];			// Retain the new scene.
		 cc3Scene.cc3Layer = self;				// Point the scene back here
		 if (self.isRunning) [self openCC3Scene];	// If already running, open the new scene right away
	 }
}

// Deprecated cc3World property
-(CC3Scene*) cc3World { return self.cc3Scene; }
-(void) setCc3World: (CC3Scene*) aCC3Scene {
	cc3World = aCC3Scene;							// Hold parallel unretained reference for legacy apps
	self.cc3Scene = aCC3Scene;
	if ( !self.isRunning ) [self updateViewport];	// If not already running, update viewport anyway to support legacy behaviour
}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }


#pragma mark Allocation and initialization

/** Overridden to invoke the initializeControls template method. */
-(void) initInitialState {
	[super initInitialState];
	shouldAlwaysUpdateViewport = NO;
	[self initializeControls];
}

// Spelling mistake on initial API...left in for backwards compatibility
-(void) initializeContols {}

/**
 * For backwards compatibility, default invokes misspelled API method, which in turn does nothing.
 * Subclasses will override, and do not need to invoke this superclass implementation.
 */
-(void) initializeControls { [self initializeContols]; }


#pragma mark Transforming

-(void) setPosition: (CGPoint) newPosition {
	[super setPosition: newPosition];
	[self updateViewport];
}

-(void) setPositionInPixels: (CGPoint) newPosition {
	[super setPositionInPixels: newPosition];
	[self updateViewport];
}

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

-(BOOL) isOpaque { return self.isColored && self.opacity == 255; }


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
	[cc3Scene open];				// Open the scene
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
-(void) closeCC3Scene { [cc3Scene close]; }

-(void) update: (ccTime)dt { [cc3Scene updateScene: dt]; }

// Lazily initialized
-(CCArray*) cc3GestureRecognizers {
	if ( !cc3GestureRecognizers ) cc3GestureRecognizers = [[CCArray array] retain];
	return cc3GestureRecognizers;
}

-(void) cc3AddGestureRecognizer: (UIGestureRecognizer*) gesture {
	[self.cc3GestureRecognizers addObject: gesture];
	[[CCDirector sharedDirector].openGLView addGestureRecognizer: gesture];
}

-(void) cc3RemoveGestureRecognizer: (UIGestureRecognizer*) gesture {
	[[CCDirector sharedDirector].openGLView removeGestureRecognizer: gesture];
	[cc3GestureRecognizers removeObjectIdenticalTo: gesture];
}

-(void) cc3RemoveAllGestureRecognizers {
	CCArray* myGRs = [cc3GestureRecognizers autoreleasedCopy];
	for (UIGestureRecognizer* gr in myGRs) {
		[self cc3RemoveGestureRecognizer: gr];
	}
}


#pragma mark Drawing

/**
 * CCNode template method to draw this layer. Overridden to draw the colored backdrop and
 * then delegates 3D drawing to the contained CC3Scene instance.
 */
-(void) draw {
	[self drawBackdrop];
	[self drawWorld];		// Invoke legacy method in case legacy app has overridden drawWorld
}

/** Delegates to the superclass to draw a colored backdrop if it has been established */
-(void) drawBackdrop {
	LogTrace(@"%@ drawing backdrop", self);
	[super draw];
}

// Deprecated legacy drawing method
-(void) drawWorld { [self drawScene]; }

/**
 * Draws the 3D scene by delegating to the visit method of the contained CC3Scene instance.
 * If the shouldAlwaysUpdateViewport property is set to YES, then the viewport is updated first.
 */
-(void) drawScene {
	if (shouldAlwaysUpdateViewport) [self updateViewport];
	[cc3Scene drawScene];
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

/**
 * Updates the viewport of the contained CC3Scene instance with the dimensions
 * of this layer and the device orientation.
 *
 * Invoked automatically when the position, size, or scale of this layer changes.
 */
-(void) updateViewport {
	[cc3Scene.viewportManager updateBounds: self.globalBoundingBoxInPixels
					 withDeviceOrientation: [[CCDirector sharedDirector] deviceOrientation]];
	[super updateViewport];
}


#pragma mark Touch handling

// Handle touch events one at a time.
-(void) registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self
													 priority: self.touchPriority
											  swallowsTouches:YES];
}

/**
 * The priority at which touch events are delegated to this layer.
 * Default is zero. Subclasses may override.
 */
-(int) touchPriority { return 0; }

// Handles the initial finger-down touch events.
-(BOOL) ccTouchBegan: (UITouch *)touch withEvent: (UIEvent *)event {
	return [self handleTouch: touch ofType: kCCTouchBegan];
}

// Handles the final finger-up touch events.
-(void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchEnded];
}

// Handles cancelled touch events.
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
/*
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
*/

/**
 * Invoked when any of the touch event handler methods are invoked.
 * Returns whether the event was handled by this layer.
 *
 * This implementation checks that the touch event is within the bounds of this
 * layer and, if it is, forwards the event to the handleTouchType:at: method.
 */
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType {
	CGSize cs = self.contentSize;
	CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
	CGPoint nodeTouchPoint = [self convertTouchToNodeSpace: touch];
	if(CGRectContainsPoint(nodeBounds, nodeTouchPoint)) {
		LogTrace(@"%@ touched at: %@", self, NSStringFromCGPoint(nodeTouchPoint));
		return [self handleTouchType: touchType at: nodeTouchPoint];
	}
	return NO;
}

/**
 * Invoked when any of the touch event handler methods are invoked, and the touchEvent
 * occurred within the bounds of this layer. Returns whether the event was handled.
 *
 * This implementation forwards all events to the CC3Scene and always returns YES.
 * Subclasses may override this method to handle some events here instead of in
 * the CC3Scene.
 */
-(BOOL) handleTouchType: (uint) touchType at: (CGPoint) touchPoint {
	[cc3Scene touchEvent: touchType at: touchPoint];
	return YES;
}

@end


