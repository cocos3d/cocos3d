/*
 * CC3DemoMashUpLayer.m
 *
 * Cocos3D 2.0.2
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
 * See header file CC3DemoMashUpLayer.h for full API documentation.
 */

#import "CC3DemoMashUpLayer.h"
#import "CC3DemoMashUpScene.h"
#import "CC3Actions.h"
#import "CC3CC2Extensions.h"
#import "HUDLayer.h"
#import "HUDScene.h"
#import "ccMacros.h"


/** Cocos2D v3 auto-scales images for Retina. Cocos2D v2 & v1 do not. This affects the button sizes. */
#if CC3_CC2_CLASSIC
#	define kSpriteScale				1.0
#else
#	define kSpriteScale				(CCDirector.sharedDirector.contentScaleFactor)
#endif	// CC3_CC2_CLASSIC

/** Scale and position the buttons so they are usable at various screen resolutions. */
#if APPORTABLE
#	define kControlSizeScale		(MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) / (1024.0f * kSpriteScale))
#	define kControlPositionScale	kControlSizeScale
#else
#	define kControlSizeScale		(CCDirector.sharedDirector.contentScaleFactor / kSpriteScale)
#	define kControlPositionScale	1.0
#endif	// APPORTABLE

/** Parameters for setting up the joystick and button controls */
#define kJoystickSideLength				(80.0 * kControlPositionScale)
#define kButtonGrid						(40.0 * kControlPositionScale)
#define kJoystickPadding				(8.0 * kControlPositionScale)
#define kHUDPadding						(8.0 * kControlPositionScale)
#define kJoystickThumbFileName			@"JoystickThumb.png"
#define kSwitchViewButtonFileName		@"ArrowLeftButton48x48.png"
#define kInvasionButtonFileName			@"GridButton48x48.png"
#define kSunlightButtonFileName			@"SunlightButton48x48.png"
#define kZoomButtonFileName				@"ZoomButton48x48.png"
#define kShadowButtonFileName			@"ShadowButton48x48.png"
#define kShadowButtonLatchedFileName	@"ShadowButtonLatched48x48.png"
#define kButtonRingFileName				@"ButtonRing48x48.png"
#define kButtonShineFileName			@"Shine48x48.png"
#define kGlobeName						@"Globe"
#define kPeakShineOpacity				180
#define kButtonAdornmentScale			1.5


// Gesture support under Android is less sophisticated and more challenging than under iOS.
// When running on Android, avoid using gestures, and use underlying touch events instead.
// You can change this definition if you don't want to use gestures at all.
#define kShouldUseGestures				(CC3_IOS && !APPORTABLE)

@interface CC3Layer (TemplateMethods)
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType;
@end

@implementation CC3DemoMashUpLayer

/**
 * Returns the contained CC3Scene, cast into the appropriate type.
 * This is a convenience method to perform automatic casting.
 */
-(CC3DemoMashUpScene*) mashUpScene { return (CC3DemoMashUpScene*) self.cc3Scene; }

-(void) setCc3Scene: (CC3DemoMashUpScene*) aScene {
	[super setCc3Scene: aScene];
	aScene.primaryCC3DemoMashUpLayer = self;	// Point the scene back here
}

-(void) initializeControls {
	
	// Set the userInteractionEnabled property to NO to control the scene using gestures,
	// and to YES to control the scene using lower-level touch and mouse events.
	self.userInteractionEnabled = !kShouldUseGestures;
	
	[self addJoysticks];
	[self addSwitchViewButton];
	[self addInvasionButton];
	[self addSunlightButton];
	[self addZoomButton];
	[self addShadowButton];
	[self positionButtons];
	[self scheduleUpdate];		// Schedule updates on each frame
}

/** Creates the two joysticks that control the 3D camera direction and location. */
-(void) addJoysticks {
	CCSprite* jsThumb;

	// The joystick that controls the player's (camera's) direction
	jsThumb = [CCSprite spriteWithImageNamed: kJoystickThumbFileName];
	jsThumb.scale = kControlSizeScale;
	
	_directionJoystick = [Joystick joystickWithThumb: jsThumb
											 andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];

	// If you want to see the size of the Joystick backdrop, comment out the line above and uncomment the
	// following line, which include a simple backdrop image. The thumb and backdrop can be any CCNode.
//	_directionJoystick = [Joystick joystickWithThumb: jsThumb
//										 andBackdrop: [CCSprite spriteWithImageNamed: @"BrushedSteel.png"]];
	
	CGPoint jsMiddle = _directionJoystick.anchorPointInPoints;
	_directionJoystick.position = ccp(jsMiddle.x + kJoystickPadding, jsMiddle.y + kJoystickPadding);
	[self addChild: _directionJoystick];
	
	// The joystick that controls the player's (camera's) location
	jsThumb = [CCSprite spriteWithImageNamed: kJoystickThumbFileName];
	jsThumb.scale = kControlSizeScale;
	
	_locationJoystick = [Joystick joystickWithThumb: jsThumb
											andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];
	[self addChild: _locationJoystick];
	[self positionLocationJoystick];
}

/**
 * Creates a button that will allow the user to switch between different views of the 3D scene.
 * The type of button depends on whether we are using Cocos2D v3, or the legacy Cocos2D v2/v1.
 */
-(void) addSwitchViewButton {
	// The button uses an adornment, which is displayed whenever the button is selected.
	CCNodeAdornmentBase* adornment;
	
	// The adornment is a ring that fades in around the button and fades out when the button is deselected.
	CCSprite* ringSprite = [CCSprite spriteWithImageNamed: kButtonRingFileName];
	adornment = [CCNodeAdornmentOverlayFader adornmentWithSprite: ringSprite];
	adornment.zOrder = kAdornmentUnderZOrder;
	
	// Or the adornment could scale the button it is when selected.
	// To try a scaler adornment, uncomment the following line.
//	adornment = [CCNodeAdornmentScaler adornmentToScaleUniformlyBy: kButtonAdornmentScale];

	_switchViewButton = [self addButtonWithCallbackSelector: @selector(switchViewSelected)
											  withImageFile: kSwitchViewButtonFileName
											  withAdornment: adornment];
}

/**
 * Creates a button that will allow the user to create a robot invasion.
 * The type of button depends on whether we are using Cocos2D v3, or the legacy Cocos2D v2/v1.
 */
-(void) addInvasionButton {

	// The button uses an adornment, which is displayed whenever the button is selected.
	// The adornment is a ring that fades in around the button and fades out when the button is deselected.
	CCSprite* ringSprite = [CCSprite spriteWithImageNamed: kButtonRingFileName];
	CCNodeAdornmentBase* adornment = [CCNodeAdornmentOverlayFader adornmentWithSprite: ringSprite];
	adornment.zOrder = kAdornmentUnderZOrder;

	_invasionButton = [self addButtonWithCallbackSelector: @selector(invade)
											  withImageFile: kInvasionButtonFileName
											withAdornment: adornment];
}

/**
 * Creates a button that will allow the user to turn the sun on or off.
 * The type of button depends on whether we are using Cocos2D v3, or the legacy Cocos2D v2/v1.
 */
-(void) addSunlightButton {
	
	// The button uses an adornment, which is displayed whenever the button is selected.
	// The adornment is a ring that fades in around the button and fades out when the button is deselected.
	CCSprite* ringSprite = [CCSprite spriteWithImageNamed: kButtonRingFileName];
	CCNodeAdornmentBase* adornment = [CCNodeAdornmentOverlayFader adornmentWithSprite: ringSprite];
	adornment.zOrder = kAdornmentUnderZOrder;

	_sunlightButton = [self addButtonWithCallbackSelector: @selector(cycleLights)
											withImageFile: kSunlightButtonFileName
											withAdornment: adornment];
}

/**
 * Creates a button that will allow the user to move between viewing the whole scene and
 * viewing from the previous position.
 * The type of button depends on whether we are using Cocos2D v3, or the legacy Cocos2D v2/v1.
 */
-(void) addZoomButton {
	// The button uses an adornment, which is displayed whenever the button is selected.
	// The adornment is a shine that fades in on the button and fades out when the button is deselected.
	CCSprite* shineSprite = [CCSprite spriteWithImageNamed: kButtonShineFileName];
	shineSprite.color = CCColorRefFromCCC4F(kCCC4FWhite);
	CCNodeAdornmentBase* adornment = [CCNodeAdornmentOverlayFader adornmentWithSprite: shineSprite
																		  peakOpacity: kPeakShineOpacity];
	_zoomButton = [self addButtonWithCallbackSelector: @selector(cycleZoom)
											withImageFile: kZoomButtonFileName
										withAdornment: adornment];
}

/**
 * Creates a toggle button that will allow the user to toggle shadows on and off for a selected node.
 * The type of button depends on whether we are using Cocos2D v3, or the legacy Cocos2D v2/v1.
 */
-(void) addShadowButton {
	// The button uses an adornment, which is displayed whenever the button is selected. The adornment
	// is a ring that fades in around the button and fades out when the button is no longer selected.
	CCSprite* ringSprite = [CCSprite spriteWithImageNamed: kButtonRingFileName];
	CCNodeAdornmentBase* adornment = [CCNodeAdornmentOverlayFader adornmentWithSprite: ringSprite];
	adornment.zOrder = kAdornmentUnderZOrder;

	_shadowButton = [self addToggleButtonWithCallbackSelector: @selector(toggleShadows)
												withImageFile: kShadowButtonFileName
										 withLatchedImageFile: kShadowButtonLatchedFileName
												withAdornment: adornment];
}

/**
 * Adds a UI button to this layer, and returns the button. The button will display the image
 * in the specified file, and is adorned with the specified visual adornment that will be
 * activated when the button is touched. The button will invoke the specified callback method
 * on this instance when the button is pressed and released by the user. The type of button
 * used depends on whether we are using Cocos2D v3, or Cocos2D v2/v1.
 */
-(CC_BUTTON_CLASS*) addButtonWithCallbackSelector: (SEL) callBackSelector
									withImageFile: (NSString*) imgFileName
									withAdornment: (CCNode<CCNodeAdornmentProtocol>*) adornment {
	CC_BUTTON_CLASS* button;
	
#if CC3_CC2_CLASSIC
	button = [AdornableMenuItemImage itemWithNormalImage: imgFileName
										   selectedImage: imgFileName
												  target: self
												selector: callBackSelector];
	CCMenu* viewMenu = [CCMenu menuWithItems: button, nil];
	viewMenu.position = CGPointZero;
	[self addChild: viewMenu];
#else
	button = [AdornableButton buttonWithTitle: nil
								  spriteFrame: [CCSpriteFrame frameWithImageNamed: imgFileName]];
	[button setTarget: self selector: callBackSelector];
	[self addChild: button];
#endif	// CC3_CC2_CLASSIC
	
	adornment.position = ccpCompMult(ccpFromSize(button.contentSize), button.anchorPoint);
	button.adornment = adornment;
	
	button.scale = kControlSizeScale;
	return button;
}

/**
 * Adds a toggle UI button to this layer, and returns the button. The button will display
 * the image in the specified file, and is adorned with the specified visual adornment that
 * will be activated when the button is touched. The button will invoke the specified callback
 * method on this instance when the button is pressed and released by the user. The type of
 * button used depends on whether we are using Cocos2D v3, or Cocos2D v2/v1.
 */
-(CC_BUTTON_CLASS*) addToggleButtonWithCallbackSelector: (SEL) callBackSelector
										  withImageFile: (NSString*) imgFileName
								   withLatchedImageFile: (NSString*) imgLatchFileName
										  withAdornment: (CCNode<CCNodeAdornmentProtocol>*) adornment {
	CC_BUTTON_CLASS* button;
	
#if CC3_CC2_CLASSIC
	CCMenuItem* b = [CCMenuItemImage itemWithNormalImage: imgFileName
										   selectedImage: imgFileName];
	CCMenuItem* bl = [CCMenuItemImage itemWithNormalImage: imgLatchFileName
											selectedImage: imgLatchFileName];
	button = [AdornableMenuItemToggle itemWithTarget: self
											selector: callBackSelector
											   items: b, bl, nil];
	CCMenu* viewMenu = [CCMenu menuWithItems: button, nil];
	viewMenu.position = CGPointZero;
	[self addChild: viewMenu];
#else
	button = [AdornableButton buttonWithTitle: nil
								  spriteFrame: [CCSpriteFrame frameWithImageNamed: imgFileName]];
	[button setTarget: self selector: callBackSelector];
	button.togglesSelectedState = YES;
	[self addChild: button];
#endif	// CC3_CC2_CLASSIC
	
	adornment.position = ccpCompMult(ccpFromSize(button.contentSize), button.anchorPoint);
	button.adornment = adornment;
	
	button.scale = kControlSizeScale;
	return button;
}

/**
 * Positions the right-side location joystick at the right of the layer.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the joystick in the correct location within the new layer dimensions.
 */
-(void) positionLocationJoystick {
	CGPoint jsMiddle = _locationJoystick.anchorPointInPoints;
	_locationJoystick.position = ccp(self.contentSize.width - (jsMiddle.x + kJoystickPadding),
									 (jsMiddle.y + kJoystickPadding));

}

/**
 * Positions the buttons between the two joysticks.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the button in the correct location within the new layer dimensions.
 */
-(void) positionButtons {
	GLfloat middle = self.contentSize.width / 2.0;
	GLfloat btnY = (kJoystickPadding * 0.5) + (kButtonGrid * 0.5);

	_shadowButton.position = ccp(middle - (kButtonGrid * 0.5), btnY);
	_zoomButton.position = ccp(middle + (kButtonGrid * 0.5), btnY);

	btnY += kButtonGrid;
	_switchViewButton.position = ccp(middle - (kButtonGrid * 1.0), btnY);
	_invasionButton.position = ccp(middle, btnY);
	_sunlightButton.position = ccp(middle + (kButtonGrid * 1.0), btnY);
}


#pragma mark Updating

/**
 * Updates the player (camera) direction and location from the joystick controls
 * and then updates the 3D scene.
 */
-(void) update: (CCTime)dt {
	
	// Update the player direction and position in the scene from the joystick velocities
	self.mashUpScene.playerDirectionControl = _directionJoystick.velocity;
	self.mashUpScene.playerLocationControl = _locationJoystick.velocity;
	[super update: dt];
}

/** The user has pressed the switch camera view button. Tell the 3D scene so it can move the camera. */
-(void) switchViewSelected { [self.mashUpScene switchCameraTarget]; }

/** The user has pressed the invade button. Tell the 3D scene. */
-(void) invade { [self.mashUpScene invade]; }

/** The user has pressed the cycle lights button. Tell the 3D scene. */
-(void) cycleLights { [self.mashUpScene cycleLights]; }

/** The user has pressed the zoom button. Tell the 3D scene. */
-(void) cycleZoom { [self.mashUpScene cycleZoom]; }

/** The user has pressed the shadow button. Tell the 3D scene. */
-(void) toggleShadows { self.mashUpScene.isManagingShadows = !self.mashUpScene.isManagingShadows; }

/**
 * Called automatically when the contentSize has changed.
 * Move the location joystick to keep it in the bottom right corner of this layer
 * and the switch view button to keep it centered between the two joysticks.
 */
-(void) contentSizeChanged {
	[super contentSizeChanged];
	[self positionLocationJoystick];
	[self positionButtons];
}


#pragma mark HUD window

/**
 * Opens a small, semi-transparent child HUD (Heads-Up-Display) window on top of the
 * main scene. This HUD window contains a close-up of the rotating globe. This window
 * is a separate CC3Layer containing a separate CC3Scene that contains a copy of the
 * globe node.
 *
 * The HUD window starts minimized at the point on the globe that was touched, and
 * smoothly expands to the top-right corner of the main scene.
 */
-(void) openGlobeHUDFromTouchAt: (CGPoint) touchPoint {
	if (_hudLayer) return;
	
	// Determine an appropriate size for the HUD child window.
	CGSize mySize = self.contentSize;
	GLfloat hudSide = MIN(mySize.width, mySize.height) * 0.5 - (kHUDPadding * 2);
	
	// Create the HUD CC3Layer, with a semi-transparent background, set its position
	// to the touch-point (offset by the size of the layer), and set its final size.
	// Start it with a small scale.
	_hudLayer = [HUDLayer layer];
	_hudLayer.position = touchPoint;
	_hudLayer.contentSize = CGSizeMake(hudSide, hudSide);
	_hudLayer.scale = 0.1;

	// Create and add a new CC3Scene, containing just a copy of the rotating globe,
	// for the HUD layer, and ensure its camera frames the globe.
	_hudLayer.cc3Scene = [self makeHUDScene];

	// Run actions to move and scale the HUD layer from its starting position
	// and size to its final expanded position and size.
	CGPoint hudMiddle = _hudLayer.anchorPointInPoints;
	CGPoint hudPos = ccp(mySize.width - (hudMiddle.x + kHUDPadding),
						 mySize.height - (hudMiddle.y + kHUDPadding));
	[_hudLayer runAction: [CCActionMoveTo actionWithDuration: 1.0 position: hudPos]];
	[_hudLayer runAction: [CCActionScaleTo actionWithDuration: 1.0 scale: 1.0]];
	[self addChild: _hudLayer];
}

/**
 * Returns a new CC3Scene containing a copy of the globe from the main scene.
 * Sets the globe rotating and makes it semi-transparent.
 */
-(CC3Scene*) makeHUDScene {
	CC3Scene* hudScene = [HUDScene scene];
	
	CC3Node* globe = [[self.cc3Scene getNodeNamed: kGlobeName] copy];
	globe.location = kCC3VectorZero;
	globe.rotation = kCC3VectorZero;
	[globe runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0, 30, 0)]];
	[hudScene addChild: globe];
	[hudScene createGLBuffers];		// Won't really do anything because the Globe mesh...
									// ...has already been buffered in main scene
	hudScene.opacity = (kCCOpacityFull * 0.75);		// Makes everything in the scene somewhat translucent
	return hudScene;
}

/** Closes the HUD window by using CCActions to fade it out and then remove it. */
-(void) closeGlobeHUDFromTouchAt: (CGPoint) touchPoint {
	[_hudLayer stopAllActions];
	CCActionInterval* fadeHUD = [CCActionFadeTo actionWithDuration: 1.0 opacity: 0];
	CCActionInstant* removeHUD = [CCActionCallFunc actionWithTarget: self
														   selector: @selector(removeGlobeHUD)];
	[_hudLayer runAction: [CCActionSequence actionOne: fadeHUD two: removeHUD]];
}

/** Removes the HUD window if it exists. */
-(void) removeGlobeHUD {
	if (_hudLayer) [self removeChild: _hudLayer cleanup: YES];
	_hudLayer = nil;
}

/** Toggles between opening and closing the HUD window. */
-(void) toggleGlobeHUDFromTouchAt: (CGPoint) touchPoint {
	if (_hudLayer)
		[self closeGlobeHUDFromTouchAt: touchPoint];
	else
		[self openGlobeHUDFromTouchAt: touchPoint];
}

-(BOOL) isShowingHUD { return (_hudLayer != nil); }


#pragma mark Touch handling

/**
 * Handle touch move event under Cocos2D v2 and below.
 *
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, it must be implemented here.
 *
 * This method will not be invoked if gestures have been enabled.
 */
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}

/**
 * Handle touch move event under Cocos2D v3 and above.
 *
 * The touchMoved:withEvent: method is optional. Since the touch-move events are both
 * voluminous and seldom used, the implementation of this method has been left out of
 * the default CC3Layer implementation. To receive and handle touch-move events for
 * object picking, it must be implemented here.
 *
 * This method will not be invoked if gestures have been enabled.
 */
-(void) touchMoved: (UITouch*) touch withEvent: (UIEvent*) event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}

#if CC3_IOS
#pragma mark Gesture support

/**
 * Invoked when this layer is being opened on the view.
 *
 * If we want to use gestures, we add the gesture recognizers here.
 *
 * By using the cc3AddGestureRecognizer: method to add the gesture recognizers,
 * we ensure that they will be torn down when this layer is removed from the view.
 *
 * This layer has child buttons on it. To ensure that those buttons receive their
 * touch events, we set cancelsTouchesInView to NO on the tap gestures recognizer
 * so that that gesture recognizer allows the touch events to propagate to the buttons.
 * We do not need to do that for the other recognizers because we don't want buttons
 * to receive touch events in the middle of a pan or pinch.
 */
-(void) onOpenCC3Layer {
	if (self.isUserInteractionEnabled) return;
	
	// Register for tap gestures to select 3D nodes.
	// This layer has child buttons on it. To ensure that those buttons receive their
	// touch events, we set cancelsTouchesInView to NO so that the gesture recognizer
	// allows the touch events to propagate to the buttons.
	UITapGestureRecognizer* tapSelector = [[UITapGestureRecognizer alloc]
										   initWithTarget: self action: @selector(handleTapSelection:)];
	tapSelector.numberOfTapsRequired = 1;
	tapSelector.cancelsTouchesInView = NO;		// Ensures touches are passed to buttons
	[self cc3AddGestureRecognizer: tapSelector];
	
	// Register for single-finger dragging gestures used to spin the two cubes.
	UIPanGestureRecognizer* dragPanner = [[UIPanGestureRecognizer alloc]
										  initWithTarget: self action: @selector(handleDrag:)];
	dragPanner.minimumNumberOfTouches = 1;
	dragPanner.maximumNumberOfTouches = 1;
	[self cc3AddGestureRecognizer: dragPanner];

	// Register for double-finger dragging to pan the camera.
	UIPanGestureRecognizer* cameraPanner = [[UIPanGestureRecognizer alloc]
											initWithTarget: self action: @selector(handleCameraPan:)];
	cameraPanner.minimumNumberOfTouches = 2;
	cameraPanner.maximumNumberOfTouches = 2;
	[self cc3AddGestureRecognizer: cameraPanner];
	
	// Register for double-finger dragging to pan the camera.
	UIPinchGestureRecognizer* cameraMover = [[UIPinchGestureRecognizer alloc]
											 initWithTarget: self action: @selector(handleCameraMove:)];
	[self cc3AddGestureRecognizer: cameraMover];
}

/**
 * This handler is invoked when a single-tap gesture is recognized.
 *
 * If the tap occurs within a descendant CCNode that wants to capture the touch,
 * such as a menu or button, the gesture is cancelled. Otherwise, the tap is 
 * forwarded to the CC3Scene to pick the 3D node under the tap.
 */
-(void) handleTapSelection: (UITapGestureRecognizer*) gesture {

	// Once the gesture has ended, convert the UI location to a 2D node location and
	// pick the 3D node under that location. Don't forget to test that the gesture is
	// valid and does not conflict with touches handled by this layer or its descendants.
	if ( [self cc3ValidateGesture: gesture] && (gesture.state == UIGestureRecognizerStateEnded) ) {
		CGPoint touchPoint = [self cc3ConvertUIPointToNodeSpace: gesture.location];
		[self.mashUpScene pickNodeFromTapAt: touchPoint];
	}
}

/**
 * This handler is invoked when a single-finger drag gesture is recognized.
 *
 * If the drag starts within a descendant CCNode that wants to capture the touch,
 * such as a menu or button, the gesture is cancelled.
 *
 * The CC3Scene marks where dragging begins to determine the node that is underneath
 * the touch point at that time, and is further notified as dragging proceeds.
 * It uses the velocity of the drag to spin the cube nodes. Finally, the scene is
 * notified when the dragging gesture finishes.
 *
 * The dragging movement is normalized to be specified relative to the size of the
 * layer, making it independant of the size of the layer.
 */
-(void) handleDrag: (UIPanGestureRecognizer*) gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
			if ( [self cc3ValidateGesture: gesture] ) {
				[self.mashUpScene startDraggingAt: [self cc3ConvertUIPointToNodeSpace: gesture.location]];
			}
			break;
		case UIGestureRecognizerStateChanged:
			[self.mashUpScene dragBy: [self cc3NormalizeUIMovement: gesture.translation]
						  atVelocity:[self cc3NormalizeUIMovement: gesture.velocity]];
			break;
		case UIGestureRecognizerStateEnded:
			[self.mashUpScene stopDragging];
			break;
		default:
			break;
	}
}

/**
 * This handler is invoked when a double-finger pan gesture is recognized.
 *
 * If the panning starts within a descendant CCNode that wants to capture the touch,
 * such as a menu or button, the gesture is cancelled.
 *
 * The CC3Scene marks the camera orientation when dragging begins, and is notified
 * as dragging proceeds. It uses the relative translation of the panning movement
 * to determine the new orientation of the camera. Finally, the scene is notified
 * when the dragging gesture finishes.
 *
 * The dragging movement is normalized to be specified relative to the size of the
 * layer, making it independant of the size of the layer.
 */
-(void) handleCameraPan: (UIPanGestureRecognizer*) gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
			if ( [self cc3ValidateGesture: gesture] ) [self.mashUpScene startPanningCamera];
			break;
		case UIGestureRecognizerStateChanged:
			[self.mashUpScene panCameraBy: [self cc3NormalizeUIMovement: gesture.translation]];
			break;
		case UIGestureRecognizerStateEnded:
			[self.mashUpScene stopPanningCamera];
			break;
		default:
			break;
	}
}


/**
 * This handler is invoked when a pinch gesture is recognized.
 *
 * If the pinch starts within a descendant CCNode that wants to capture the touch,
 * such as a menu or button, the gesture is cancelled.
 *
 * The CC3Scene marks the camera location when pinching begins, and is notified
 * as pinching proceeds. It uses the relative scale of the pinch gesture to determine
 * a new location for the camera. Finally, the scene is notified when the pinching
 * gesture finishes.
 *
 * Note that the pinching does not zoom the camera, although the visual effect is
 * very similar. For this application, moving the camera is more flexible and useful
 * than zooming. But other application might prefer to use the pinch gesture scale
 * to modify the uniformScale or fieldOfView properties of the camera, to perform
 * a true zooming effect.
 */
-(void) handleCameraMove: (UIPinchGestureRecognizer*) gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
			if ( [self cc3ValidateGesture: gesture] ) [self.mashUpScene startMovingCamera];
			break;
		case UIGestureRecognizerStateChanged:
			[self.mashUpScene moveCameraBy: gesture.scale];
			break;
		case UIGestureRecognizerStateEnded:
			[self.mashUpScene stopMovingCamera];
			break;
		default:
			break;
	}
}
#endif	// CC3_IOS

@end
