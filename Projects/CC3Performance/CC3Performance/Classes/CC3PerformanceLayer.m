/*
 * CC3PerformanceLayer.m
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
 * See header file CC3PerformanceLayer.h for full API documentation.
 */

#import "CC3PerformanceLayer.h"
#import "CC3PerformanceScene.h"
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
#define kButtonFrameHeight			(80.0 * kControlPositionScale)
#define kButtonPadding				(8.0 * kControlPositionScale)
#define kStatsLineSpacing			(16.0 * kControlPositionScale)
#define kStatsLabelRightTabInset	(130.0 * kControlPositionScale)
#define kAdornmentRingThickness		(4.0 * kControlPositionScale)

#define kArrowUpButtonFileName		@"ArrowUpButton48x48.png"
#define kAnimateNodesButtonFileName	@"GridButton48x48.png"
#define kButtonRingFileName			@"ButtonRing48x48.png"


@interface CC3Layer (ProtectedMethods)
-(void) drawSceneWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end


@implementation CC3PerformanceLayer

/**
 * Returns the contained CC3Scene, cast into the appropriate type.
 * This is a convenience method to perform automatic casting.
 */
-(CC3PerformanceScene*) performanceScene { return (CC3PerformanceScene*)super.cc3Scene; }

/** Initialize all the 2D user controls. */
-(void) initializeControls {
	[self addButtons];
	[self addStatsLabels];
	[self scheduleUpdate];
}

/** Creates buttons (actually single-item menus) for user interaction. */
-(void) addButtons {

	// Add button to allow user to increase the number of nodes in the 3D scene.
	_increaseNodesButton = [self addButtonWithCallbackSelector: @selector(increaseNodesSelected)
												 withImageFile: kArrowUpButtonFileName];

	// Add button to allow user to decrease the number of nodes in the 3D scene.
	_decreaseNodesButton = [self addButtonWithCallbackSelector: @selector(decreaseNodesSelected)
												 withImageFile: kArrowUpButtonFileName];
	_decreaseNodesButton.rotation = 180.0f;
	
	// Add button to allow user to select the next node type.
	_nextNodeTypeButton = [self addButtonWithCallbackSelector: @selector(nextNodeTypeSelected)
												withImageFile: kArrowUpButtonFileName];
	
	// Add button to allow user to select the previous node type.
	_prevNodeTypeButton = [self addButtonWithCallbackSelector: @selector(prevNodeTypeSelected)
												withImageFile: kArrowUpButtonFileName];
	_prevNodeTypeButton.rotation = 180.0f;
	
	// Add button to allow user to increase the number of nodes in the 3D scene.
	_animateNodesButton = [self addButtonWithCallbackSelector: @selector(animateNodesSelected)
												withImageFile: kAnimateNodesButtonFileName];

	[self positionButtons];
}

/**
 * Adds a UI button to this layer, and returns the button. The button will display the image
 * in the specified file, and is adorned with a ring adornment that will be activated when the
 * button is touched. The button will invoke the specified callback method on this instance
 * when the button is pressed and released by the user. The type of button used depends on
 * whether we are using Cocos2D v3, or Cocos2D v2/v1.
 */
-(CC_BUTTON_CLASS*) addButtonWithCallbackSelector: (SEL) callBackSelector
									withImageFile: (NSString*) imgFileName {
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
	
	// Add a ring adornment that fades in around the button and then fades out when the button is deselected.
	CCSprite* ringSprite = [CCSprite spriteWithImageNamed: kButtonRingFileName];
	CCNodeAdornmentBase* adornment = [CCNodeAdornmentOverlayFader adornmentWithSprite: ringSprite];
	adornment.zOrder = kAdornmentUnderZOrder;
	adornment.position = ccpCompMult(ccpFromSize(button.contentSize), button.anchorPoint);
	button.adornment = adornment;
	
	button.scale = kControlSizeScale;
	return button;
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
	CCTexturePixelFormat currentFormat = [CCTexture defaultAlphaPixelFormat];
	[CCTexture setDefaultAlphaPixelFormat: CCTexturePixelFormat_RGBA4444];
	
	_nodeNameLabel = [self addStatsLabel: @""];
	_nodeNameLabel.anchorPoint = ccp(0.5, 0.0);
	_nodeNameLabel.color = CCColorRefFromCCC4F(kCCC4FYellow);

	_updateTitleLabel = [self addStatsLabel: @"Updates:"];
	_updateTitleLabel.color = CCColorRefFromCCC4F(kCCC4FYellow);

	_updateRateLabel = [self addStatsLabel: @"0"];
	_nodesUpdatedLabel = [self addStatsLabel: @"0"];
	_nodesTransformedLabel = [self addStatsLabel: @"0"];
	
	_drawingTitleLabel = [self addStatsLabel: @"Drawing:"];
	_drawingTitleLabel.color = CCColorRefFromCCC4F(kCCC4FYellow);

	_frameRateLabel = [self addStatsLabel: @"0"];
	_nodesVisitedForDrawingLabel = [self addStatsLabel: @"0"];
	_nodesDrawnLabel = [self addStatsLabel: @"0"];
	_drawCallsLabel = [self addStatsLabel: @"0"];
	_facesPresentedLabel = [self addStatsLabel: @"0"];

	[CCTexture setDefaultAlphaPixelFormat: currentFormat];

	[self positionStatsLabels];
}

/**
 * Positions the view switching and invasion buttons between the two joysticks.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the button in the correct location within the new layer dimensions.
 */
-(void) positionButtons {
	GLfloat xPos;
	GLfloat middle = self.contentSize.width / 2.0;
	GLfloat yPosTop = ((kButtonFrameHeight + _increaseNodesButton.contentSize.height * kControlSizeScale) / 2.0)
						+ kButtonPadding - kAdornmentRingThickness;
	GLfloat yPosBtm = ((kButtonFrameHeight - _decreaseNodesButton.contentSize.height * kControlSizeScale) / 2.0)
						+ kButtonPadding + kAdornmentRingThickness;
	GLfloat yPosMid = (kButtonFrameHeight / 2.0) + kButtonPadding;

	xPos = middle - (_increaseNodesButton.contentSize.width * kControlSizeScale);
	_increaseNodesButton.position = ccp(xPos, yPosTop);
	_decreaseNodesButton.position = ccp(xPos, yPosBtm);

	xPos = middle;
	_animateNodesButton.position = ccp(xPos, yPosMid);
	
	xPos = middle + (_nextNodeTypeButton.contentSize.width * kControlSizeScale);
	_nextNodeTypeButton.position = ccp(xPos, yPosTop);
	_prevNodeTypeButton.position = ccp(xPos, yPosBtm);
}

/**
 * Layout the performance labels in text table,
 * drawing stats on the left, update stats on the right.
 */
-(void) positionStatsLabels {
	CGFloat leftTab = kButtonPadding;
	CGFloat rightTab = self.contentSize.width - kStatsLabelRightTabInset;
	GLfloat vertPos = self.contentSize.height - kButtonPadding;
	
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
								  _increaseNodesButton.position.y +
								  (_increaseNodesButton.contentSize.height / 2.0) + kButtonPadding);
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
-(void) increaseNodesSelected {
	[self.performanceScene increaseNodes];
}

/** The user has pressed the decrease nodes button. Tell the 3D scene. */
-(void) decreaseNodesSelected {
	[self.performanceScene decreaseNodes];
}

/** The user has pressed the button to select the next node type. Tell the 3D scene. */
-(void) nextNodeTypeSelected {
	[self.performanceScene nextNodeType];
	[_nodeNameLabel setString: self.performanceScene.templateNode.name];
}

/** The user has pressed the button to select the previous node type. Tell the 3D scene. */
-(void) prevNodeTypeSelected {
	[self.performanceScene prevNodeType];
	[_nodeNameLabel setString: self.performanceScene.templateNode.name];
}

/** The user has pressed the button to toggle between animating the nodes. Tell the 3D scene. */
-(void) animateNodesSelected {
	CC3PerformanceScene* pScene = [self performanceScene];
	pScene.shouldAnimateNodes = !pScene.shouldAnimateNodes;
}

/**
 * Called automatically when the contentSize has changed.
 * Move the location joystick to keep it in the bottom right corner of this layer
 * and the switch view button to keep it centered between the two joysticks.
 */
-(void) contentSizeChanged {
	[super contentSizeChanged];
	[self positionButtons];
	[self positionStatsLabels];
}

#pragma mark Drawing

-(void) setCc3Scene:(CC3PerformanceScene *) aCC3Scene {
	[super setCc3Scene: aCC3Scene];

	// To get histograms of update and drawing rates, use
	// CC3PerformanceStatisticsHistogram instead of CC3PerformanceStatistics.
	// The histograms are printed to the log.
	aCC3Scene.performanceStatistics = [CC3PerformanceStatistics statistics];
//	aCC3Scene.performanceStatistics = [CC3PerformanceStatisticsHistogram statistics];

	[_nodeNameLabel setString: aCC3Scene.templateNode.name];
}

//Specifies how often stats should be updated, in seconds
#define kStatisticsReportingInterval 0.5

/** Overridden to update the performance statistics labels. */
-(void) drawSceneWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super drawSceneWithVisitor: visitor];
	
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
