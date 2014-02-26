/*
 * CC3PerformanceLayer.m
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
 * See header file CC3PerformanceLayer.h for full API documentation.
 */

#import "CC3PerformanceLayer.h"
#import "CC3PerformanceScene.h"
#import "ccMacros.h"


/** Scale and position the buttons so they are usable at various screen resolutions. */
#if APPORTABLE
#	define kControlSizeScale		(MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) / 1024.0f)
#	define kControlPositionScale	kControlSizeScale
#else
#	define kControlSizeScale		CC_CONTENT_SCALE_FACTOR()
#	define kControlPositionScale	1.0
#endif	// APPORTABLE

/** Parameters for setting up the joystick and button controls */
#define kJoystickSideLength		(80.0 * kControlPositionScale)
#define kJoystickSidePadding	(8.0 * kControlPositionScale)
#define kJoystickBottomPadding	(12.0 * kControlPositionScale)
#define kStatsLineSpacing		(16.0 * kControlPositionScale)
#define kAdornmentRingThickness	(4.0 * kControlPositionScale)

#define kJoystickThumbFileName		@"JoystickThumb.png"
#define kArrowUpButtonFileName		@"ArrowUpButton48x48.png"
#define kAnimateNodesButtonFileName	@"GridButton48x48.png"
#define kButtonRingFileName			@"ButtonRing48x48.png"
#define kPeakShineOpacity			255
#define kButtonAdornmentScale		1.5

@implementation CC3PerformanceLayer

/**
 * Returns the contained CC3Scene, cast into the appropriate type.
 * This is a convenience method to perform automatic casting.
 */
-(CC3PerformanceScene*) performanceScene { return (CC3PerformanceScene*)super.cc3Scene; }

/** Initialize all the 2D user controls. */
-(void) initializeControls {
	[self addJoysticks];
	[self addButtons];
	[self addStatsLabels];
	[self scheduleUpdate];
}

/** Creates the two joysticks that control the 3D camera direction and location. */
-(void) addJoysticks {
	CCSprite* jsThumb;
	
	// The joystick that controls the player's (camera's) direction
	jsThumb = [CCSprite spriteWithFile: kJoystickThumbFileName];
	jsThumb.scale = kControlSizeScale;
	
	_directionJoystick = [Joystick joystickWithThumb: jsThumb
											andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];
	
	_directionJoystick.position = ccp(kJoystickSidePadding, kJoystickBottomPadding + kStatsLineSpacing);
	[self addChild: _directionJoystick];
	
	// The joystick that controls the player's (camera's) location
	jsThumb = [CCSprite spriteWithFile: kJoystickThumbFileName];
	jsThumb.scale = kControlSizeScale;
	
	_locationJoystick = [Joystick joystickWithThumb: jsThumb
										   andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];
	[self positionLocationJoystick];
	[self addChild: _locationJoystick];
}

/**
 * Creates a button (actually a single-item menu) that will invoke the specified selector
 * as its callback when it is pressed. The button is adorned with a ring aound the button
 * that fades in when pressed, and fades back out when released.
 */
-(CCMenuItem*) addButtonWithImageFile: (NSString*) imageFile withSelector: (SEL) callbackSelector {
	AdornableMenuItemImage* mi;
	
	// Set up the menu item and position it in the bottom center of the layer
	mi = [AdornableMenuItemImage itemWithNormalImage: imageFile
									   selectedImage: imageFile
											  target: self
											selector: callbackSelector];	
	// Instead of having different normal and selected images, the toggle menu item uses an
	// adornment, which is displayed whenever an item is selected.
	CCNodeAdornmentBase* adornment;
	
	// The adornment is a ring that fades in around the menu item and then fades out when
	// the menu item is no longer selected.
	CCSprite* ringSprite = [CCSprite spriteWithFile: kButtonRingFileName];
	adornment = [CCNodeAdornmentOverlayFader adornmentWithAdornmentNode: ringSprite];
	adornment.zOrder = kAdornmentUnderZOrder;
	
	// Attach the adornment to the menu item and center it on the menu item
	adornment.position = ccpCompMult(ccpFromSize(mi.contentSize), mi.anchorPoint);
	mi.adornment = adornment;
	
	CCMenu* viewMenu = [CCMenu menuWithItems: mi, nil];
	viewMenu.position = CGPointZero;
	[self addChild: viewMenu];
	
	return mi;
}

/** Creates buttons (actually single-item menus) for user interaction. */
-(void) addButtons {

	// Add button to allow user to increase the number of nodes in the 3D scene.
	_increaseNodesMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(increaseNodesSelected:)];
	_increaseNodesMI.scale = kControlSizeScale;

	// Add button to allow user to decrease the number of nodes in the 3D scene.
	_decreaseNodesMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(decreaseNodesSelected:)];
	_decreaseNodesMI.rotation = 180.0f;
	_decreaseNodesMI.scale = kControlSizeScale;
	
	// Add button to allow user to select the next node type.
	_nextNodeTypeMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(nextNodeTypeSelected:)];
	_nextNodeTypeMI.scale = kControlSizeScale;
	
	// Add button to allow user to select the previous node type.
	_prevNodeTypeMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(prevNodeTypeSelected:)];
	_prevNodeTypeMI.rotation = 180.0f;
	_prevNodeTypeMI.scale = kControlSizeScale;
	
	// Add button to allow user to increase the number of nodes in the 3D scene.
	_animateNodesMI = [self addButtonWithImageFile: kAnimateNodesButtonFileName
									  withSelector: @selector(animateNodesSelected:)];
	_animateNodesMI.scale = kControlSizeScale;
	
	[self positionButtons];
}

// Creates a label to be used for statistics, adds it as a child, and returns it.
-(CCLabelBMFont*) addStatsLabel: (NSString*) labelText {
	CCLabelBMFont* aLabel = [CCLabelBMFont labelWithString: labelText fntFile:@"arial16.fnt"];
	[aLabel setAnchorPoint: ccp(0.0, 0.0)];
	aLabel.scale = kControlSizeScale;
	[self addChild: aLabel];
	return aLabel;
}

// Add several labels that display performance statistics.
-(void) addStatsLabels {
	CCTexture2DPixelFormat currentFormat = [CCTexture defaultAlphaPixelFormat];
	[CCTexture setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGBA4444];
	
	_nodeNameLabel = [self addStatsLabel: @""];
	_nodeNameLabel.anchorPoint = ccp(0.5, 0.0);
	[_nodeNameLabel setColor: ccYELLOW];

	_updateTitleLabel = [self addStatsLabel: @"Updates:"];
	[_updateTitleLabel setColor: ccYELLOW];

	_updateRateLabel = [self addStatsLabel: @"0"];
	_nodesUpdatedLabel = [self addStatsLabel: @"0"];
	_nodesTransformedLabel = [self addStatsLabel: @"0"];
	
	_drawingTitleLabel = [self addStatsLabel: @"Drawing:"];
	[_drawingTitleLabel setColor: ccYELLOW];

	_frameRateLabel = [self addStatsLabel: @"0"];
	_nodesVisitedForDrawingLabel = [self addStatsLabel: @"0"];
	_nodesDrawnLabel = [self addStatsLabel: @"0"];
	_drawCallsLabel = [self addStatsLabel: @"0"];
	_facesPresentedLabel = [self addStatsLabel: @"0"];

	[CCTexture setDefaultAlphaPixelFormat: currentFormat];

	[self positionStatsLabels];
}

/**
 * Positions the right-side location joystick at the right of the layer.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the joystick in the correct location within the new layer dimensions.
 */
-(void) positionLocationJoystick {
	_locationJoystick.position = ccp(self.contentSize.width - kJoystickSideLength - kJoystickSidePadding,
									 kJoystickBottomPadding + kStatsLineSpacing);
}

/**
 * Positions the view switching and invasion buttons between the two joysticks.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the button in the correct location within the new layer dimensions.
 */
-(void) positionButtons {
	GLfloat xPos;
	GLfloat middle = self.contentSize.width / 2.0;
	GLfloat yPosTop = ((kJoystickSideLength + _increaseNodesMI.contentSize.height * kControlSizeScale) / 2.0)
						+ kJoystickBottomPadding - kAdornmentRingThickness;
	GLfloat yPosBtm = ((kJoystickSideLength - _decreaseNodesMI.contentSize.height * kControlSizeScale) / 2.0)
						+ kJoystickBottomPadding + kAdornmentRingThickness;
	GLfloat yPosMid = (kJoystickSideLength / 2.0) + kJoystickBottomPadding;

	xPos = middle - (_increaseNodesMI.contentSize.width * kControlSizeScale);
	_increaseNodesMI.position = ccp(xPos, yPosTop);
	_decreaseNodesMI.position = ccp(xPos, yPosBtm);

	xPos = middle;
	_animateNodesMI.position = ccp(xPos, yPosMid);
	
	xPos = middle + (_nextNodeTypeMI.contentSize.width * kControlSizeScale);
	_nextNodeTypeMI.position = ccp(xPos, yPosTop);
	_prevNodeTypeMI.position = ccp(xPos, yPosBtm);
}

/**
 * Layout the performance labels in text table,
 * drawing stats on the left, update stats on the right.
 */
-(void) positionStatsLabels {
	CGFloat leftTab = kJoystickSidePadding;
	CGFloat rightTab = _locationJoystick.position.x - 32.0;
	GLfloat vertPos = self.contentSize.height - kJoystickSidePadding;
	
	vertPos -= kStatsLineSpacing;
	_drawingTitleLabel.position = ccp(leftTab, vertPos);
	_updateTitleLabel.position = ccp(rightTab, vertPos);
	
	vertPos -= kStatsLineSpacing;
	_frameRateLabel.position = ccp(leftTab, vertPos);
	_updateRateLabel.position = ccp(rightTab, vertPos);

	vertPos -= kStatsLineSpacing;
	_nodesVisitedForDrawingLabel.position = ccp(leftTab, vertPos);
	_nodesUpdatedLabel.position = ccp(rightTab, vertPos);
	
	vertPos -= kStatsLineSpacing;
	_nodesDrawnLabel.position = ccp(leftTab, vertPos);
	_nodesTransformedLabel.position = ccp(rightTab, vertPos);
	
	vertPos -= kStatsLineSpacing;
	_drawCallsLabel.position = ccp(leftTab, vertPos);

	vertPos -= kStatsLineSpacing;
	_facesPresentedLabel.position = ccp(leftTab, vertPos);

	// Center the name of the node type just above the buttons
	_nodeNameLabel.position = ccp(self.contentSize.width / 2.0,
								  _increaseNodesMI.position.y +
								  (_increaseNodesMI.contentSize.height / 2.0) + kJoystickSidePadding);
}

#pragma mark Updating

/**
 * Updates the player (camera) direction and location from the joystick controls
 * and then updates the 3D scene.
 */
-(void) update: (CCTime)dt {
	
	// Update the player direction and position in the scene from the joystick velocities
	self.performanceScene.playerDirectionControl = _directionJoystick.velocity;
	self.performanceScene.playerLocationControl = _locationJoystick.velocity;
	[super update: dt];
}

/** The user has pressed the increase nodes button. Tell the 3D scene. */
-(void) increaseNodesSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceScene increaseNodes];
}

/** The user has pressed the decrease nodes button. Tell the 3D scene. */
-(void) decreaseNodesSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceScene decreaseNodes];
}

/** The user has pressed the button to select the next node type. Tell the 3D scene. */
-(void) nextNodeTypeSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceScene nextNodeType];
	[_nodeNameLabel setString: self.performanceScene.templateNode.name];
}

/** The user has pressed the button to select the previous node type. Tell the 3D scene. */
-(void) prevNodeTypeSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceScene prevNodeType];
	[_nodeNameLabel setString: self.performanceScene.templateNode.name];
}

/** The user has pressed the button to toggle between animating the nodes. Tell the 3D scene. */
-(void) animateNodesSelected: (CCMenuItemToggle*) menuItem {
	CC3PerformanceScene* pScene = [self performanceScene];
	pScene.shouldAnimateNodes = !pScene.shouldAnimateNodes;
}

/**
 * Called automatically when the contentSize has changed.
 * Move the location joystick to keep it in the bottom right corner of this layer
 * and the switch view button to keep it centered between the two joysticks.
 */
-(void) didUpdateContentSizeFrom: (CGSize) oldSize {
	[super didUpdateContentSizeFrom: oldSize];
	[self positionLocationJoystick];
	[self positionButtons];
	[self positionStatsLabels];
}

#pragma mark Drawing

-(void) setCc3Scene:(CC3Scene *) aCC3Scene {
	[super setCc3Scene: aCC3Scene];

	// To get histograms of update and drawing rates, use
	// CC3PerformanceStatisticsHistogram instead of CC3PerformanceStatistics.
	// The histograms are printed to the log.
	aCC3Scene.performanceStatistics = [CC3PerformanceStatistics statistics];
//	aCC3Scene.performanceStatistics = [CC3PerformanceStatisticsHistogram statistics];

	[_nodeNameLabel setString: self.performanceScene.templateNode.name];
}

//Specifies how often stats should be updated, in seconds
#define kStatisticsReportingInterval 0.5

/** Overridden to update the performance statistics labels. */
-(void) draw {
	[super draw];
	CC3PerformanceStatistics* stats = self.cc3Scene.performanceStatistics;
	if (stats.accumulatedFrameTime >= kStatisticsReportingInterval) {

		LogTrace(@"%@", stats.fullDescription);	// Log the results as well
		
		// Drawing statistics
		[_frameRateLabel setString: [NSString stringWithFormat: @"fps: %.0f", stats.frameRate]];
		[_nodesVisitedForDrawingLabel setString: [NSString stringWithFormat: @"nodes: %.0f",
												 stats.averageNodesVisitedForDrawingPerFrame]];
		[_nodesDrawnLabel setString: [NSString stringWithFormat: @"drawn: %.0f",
									 stats.averageNodesDrawnPerFrame]];
		[_drawCallsLabel setString: [NSString stringWithFormat: @"gl calls: %.0f",
									stats.averageDrawingCallsMadePerFrame]];
		[_facesPresentedLabel setString: [NSString stringWithFormat: @"faces: %.0f",
										 stats.averageFacesPresentedPerFrame]];

		// Update statistics
		[_updateRateLabel setString: [NSString stringWithFormat: @"ups: %.0f", stats.updateRate]];
		[_nodesUpdatedLabel setString: [NSString stringWithFormat: @"nodes: %.0f",
									   stats.averageNodesUpdatedPerUpdate]];
		[_nodesTransformedLabel setString: [NSString stringWithFormat: @"xfmed: %.0f",
										   stats.averageNodesTransformedPerUpdate]];

		[stats reset];
	}
}

@end
