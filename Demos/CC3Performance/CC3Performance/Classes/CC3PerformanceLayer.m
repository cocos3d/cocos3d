/*
 * CC3PerformanceLayer.m
 *
 * cocos3d 0.6.4
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
 * See header file CC3PerformanceLayer.h for full API documentation.
 */

#import "CC3PerformanceLayer.h"
#import "CC3PerformanceWorld.h"
#import "ccMacros.h"


/** Parameters for setting up the joystick and button controls */
#define kJoystickThumbFileName  @"JoystickThumb.png"
#define kJoystickSideLength  80.0
#define kJoystickSidePadding  8.0
#define kJoystickBottomPadding  12.0
#define kStatsLineSpacing 16.0
#define kAdornmentRingThickness  4.0
#define kArrowUpButtonFileName @"ArrowUpButton48x48.png"
#define kAnimateNodesButtonFileName @"GridButton48x48.png"
#define kButtonRingFileName @"ButtonRing48x48.png"
#define kPeakShineOpacity 255
#define kButtonAdornmentScale 1.5

@interface CC3Layer (TemplateMethods)
-(void) drawWorld;
@end

@interface CC3PerformanceLayer (TemplateMethods)
-(void) addJoysticks;
-(void) addButtons;
-(void) addStatsLabels;
-(void) positionLocationJoystick;
-(void) positionButtons;
-(void) positionPerformanceLabels;
@property(nonatomic, readonly) CC3PerformanceWorld* performanceWorld;
@end


@implementation CC3PerformanceLayer

- (void)dealloc {
	directionJoystick = nil;				// retained as child
	locationJoystick = nil;					// retained as child
	increaseNodesMI = nil;					// retained as child
	decreaseNodesMI = nil;					// retained as child
	nextNodeTypeMI = nil;					// retained as child
	prevNodeTypeMI = nil;					// retained as child
	animateNodesMI = nil;					// retained as child
	nodeNameLabel = nil;					// retained as child
	updateTitleLabel = nil;					// retained as child
	updateRateLabel = nil;					// retained as child
	nodesUpdatedLabel = nil;				// retained as child
	nodesTransformedLabel = nil;			// retained as child
	drawingTitleLabel = nil;				// retained as child
	frameRateLabel = nil;					// retained as child
	nodesVisitedForDrawingLabel = nil;		// retained as child
	nodesDrawnLabel = nil;					// retained as child
	drawCallsLabel = nil;					// retained as child
	facesPresentedLabel = nil;				// retained as child
    [super dealloc];
}

/**
 * Returns the contained CC3World, cast into the appropriate type.
 * This is a convenience method to perform automatic casting.
 */
-(CC3PerformanceWorld*) performanceWorld {
	return (CC3PerformanceWorld*) cc3World;
}

/** Initialize all the 2D user controls. */
-(void) initializeControls {
	[self addJoysticks];
	[self addButtons];
	[self addStatsLabels];
	[self positionPerformanceLabels];
}

/** Creates the two joysticks that control the 3D camera direction and location. */
-(void) addJoysticks {
	CCSprite* jsThumb;
	
	// Change thumb scale if you like smaller or larger controls.
	// Initially, just compensate for Retina display.
	GLfloat thumbScale = CC_CONTENT_SCALE_FACTOR();
	
	// The joystick that controls the player's (camera's) direction
	jsThumb = [CCSprite spriteWithFile: kJoystickThumbFileName];
	jsThumb.scale = thumbScale;
	
	directionJoystick = [Joystick joystickWithThumb: jsThumb
											andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];
	
	directionJoystick.position = ccp(kJoystickSidePadding, kJoystickBottomPadding + kStatsLineSpacing);
	[self addChild: directionJoystick];
	
	// The joystick that controls the player's (camera's) location
	jsThumb = [CCSprite spriteWithFile: kJoystickThumbFileName];
	jsThumb.scale = thumbScale;
	
	locationJoystick = [Joystick joystickWithThumb: jsThumb
										   andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];
	[self positionLocationJoystick];
	[self addChild: locationJoystick];
}

/**
 * Creates a button (actually a single-item menu) that will invoke the specified selector
 * as its callback when it is pressed. The button is adorned with a ring aound the button
 * that fades in when pressed, and fades back out when released.
 */
-(CCMenuItem*) addButtonWithImageFile: (NSString*) imageFile withSelector: (SEL) callbackSelector {
	AdornableMenuItemImage* mi;
	
	// Set up the menu item and position it in the bottom center of the layer
	mi = [AdornableMenuItemImage itemFromNormalImage: imageFile
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
	increaseNodesMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(increaseNodesSelected:)];

	// Add button to allow user to decrease the number of nodes in the 3D scene.
	decreaseNodesMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(decreaseNodesSelected:)];
	decreaseNodesMI.rotation = 180.0f;
	
	// Add button to allow user to select the next node type.
	nextNodeTypeMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									 withSelector: @selector(nextNodeTypeSelected:)];
	
	// Add button to allow user to select the previous node type.
	prevNodeTypeMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									 withSelector: @selector(prevNodeTypeSelected:)];
	prevNodeTypeMI.rotation = 180.0f;
	
	// Add button to allow user to increase the number of nodes in the 3D scene.
	animateNodesMI = [self addButtonWithImageFile: kAnimateNodesButtonFileName
									  withSelector: @selector(animateNodesSelected:)];
	
	[self positionButtons];
}

// Creates a label to be used for statistics, adds it as a child, and returns it.
-(CCLabelBMFont*) addStatsLabel: (NSString*) labelText {
	CCLabelBMFont* aLabel = [CCLabelBMFont labelWithString: labelText fntFile:@"arial16.fnt"];
	[aLabel setAnchorPoint: ccp(0.0, 0.0)];
	[self addChild: aLabel];
	return aLabel;
}

// Add several labels that display performance statistics.
-(void) addStatsLabels {
	CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
	[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGBA4444];
	
	nodeNameLabel = [self addStatsLabel: @""];
	nodeNameLabel.anchorPoint = ccp(0.5, 0.0);
	[nodeNameLabel setColor: ccYELLOW];

	updateTitleLabel = [self addStatsLabel: @"Updates:"];
	[updateTitleLabel setColor: ccYELLOW];

	updateRateLabel = [self addStatsLabel: @""];
	nodesUpdatedLabel = [self addStatsLabel: @""];
	nodesTransformedLabel = [self addStatsLabel: @""];
	
	drawingTitleLabel = [self addStatsLabel: @"Drawing:"];
	[drawingTitleLabel setColor: ccYELLOW];

	frameRateLabel = [self addStatsLabel: @""];
	nodesVisitedForDrawingLabel = [self addStatsLabel: @""];
	nodesDrawnLabel = [self addStatsLabel: @""];
	drawCallsLabel = [self addStatsLabel: @""];
	facesPresentedLabel = [self addStatsLabel: @""];

	[CCTexture2D setDefaultAlphaPixelFormat: currentFormat];
}

/**
 * Positions the right-side location joystick at the right of the layer.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the joystick in the correct location within the new layer dimensions.
 */
-(void) positionLocationJoystick {
	locationJoystick.position = ccp(self.contentSize.width - kJoystickSideLength - kJoystickSidePadding,
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
	GLfloat yPosTop = ((kJoystickSideLength + increaseNodesMI.contentSize.height) / 2.0) 
						+ kJoystickBottomPadding - kAdornmentRingThickness;
	GLfloat yPosBtm = ((kJoystickSideLength - decreaseNodesMI.contentSize.height) / 2.0)
						+ kJoystickBottomPadding + kAdornmentRingThickness;
	GLfloat yPosMid = (kJoystickSideLength / 2.0) + kJoystickBottomPadding;

	xPos = middle - (increaseNodesMI.contentSize.width);
	increaseNodesMI.position = ccp(xPos, yPosTop);
	decreaseNodesMI.position = ccp(xPos, yPosBtm);

	xPos = middle;
	animateNodesMI.position = ccp(xPos, yPosMid);
	
	xPos = middle + (nextNodeTypeMI.contentSize.width);
	nextNodeTypeMI.position = ccp(xPos, yPosTop);
	prevNodeTypeMI.position = ccp(xPos, yPosBtm);
}

/**
 * Layout the performance labels in text table,
 * drawing stats on the left, update stats on the right.
 */
-(void) positionPerformanceLabels {
	CGFloat leftTab = kJoystickSidePadding;
	CGFloat rightTab = locationJoystick.position.x - 32.0;
	GLfloat vertPos = self.contentSize.height - kJoystickSidePadding;
	
	vertPos -= kStatsLineSpacing;
	drawingTitleLabel.position = ccp(leftTab, vertPos);
	updateTitleLabel.position = ccp(rightTab, vertPos);
	
	vertPos -= kStatsLineSpacing;
	frameRateLabel.position = ccp(leftTab, vertPos);
	updateRateLabel.position = ccp(rightTab, vertPos);

	vertPos -= kStatsLineSpacing;
	nodesVisitedForDrawingLabel.position = ccp(leftTab, vertPos);
	nodesUpdatedLabel.position = ccp(rightTab, vertPos);
	
	vertPos -= kStatsLineSpacing;
	nodesDrawnLabel.position = ccp(leftTab, vertPos);
	nodesTransformedLabel.position = ccp(rightTab, vertPos);
	
	vertPos -= kStatsLineSpacing;
	drawCallsLabel.position = ccp(leftTab, vertPos);

	vertPos -= kStatsLineSpacing;
	facesPresentedLabel.position = ccp(leftTab, vertPos);

	// Center the name of the node type just above the buttons
	nodeNameLabel.position = ccp(self.contentSize.width / 2.0,
								 increaseNodesMI.position.y +
								 (increaseNodesMI.contentSize.height / 2.0) + kJoystickSidePadding);
}

#pragma mark Updating

/**
 * Updates the player (camera) direction and location from the joystick controls
 * and then updates the 3D world.
 */
-(void) update: (ccTime)dt {
	
	// Update the player direction and position in the world from the joystick velocities
	self.performanceWorld.playerDirectionControl = directionJoystick.velocity;
	self.performanceWorld.playerLocationControl = locationJoystick.velocity;
	[super update: dt];
}

/** The user has pressed the increase nodes button. Tell the 3D world. */
-(void) increaseNodesSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceWorld increaseNodes];
}

/** The user has pressed the decrease nodes button. Tell the 3D world. */
-(void) decreaseNodesSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceWorld decreaseNodes];
}

/** The user has pressed the button to select the next node type. Tell the 3D world. */
-(void) nextNodeTypeSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceWorld nextNodeType];
	[nodeNameLabel setString: self.performanceWorld.templateNode.name];
}

/** The user has pressed the button to select the previous node type. Tell the 3D world. */
-(void) prevNodeTypeSelected: (CCMenuItemToggle*) menuItem {
	[self.performanceWorld prevNodeType];
	[nodeNameLabel setString: self.performanceWorld.templateNode.name];
}

/** The user has pressed the button to toggle between animating the nodes. Tell the 3D world. */
-(void) animateNodesSelected: (CCMenuItemToggle*) menuItem {
	CC3PerformanceWorld* pWorld = [self performanceWorld];
	pWorld.shouldAnimateNodes = !pWorld.shouldAnimateNodes;
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
	[self positionPerformanceLabels];
}

#pragma mark Drawing

-(void) setCc3World:(CC3World *) world {
	[super setCc3World: world];

	// To get histograms of update and drawing rates, use
	// CC3PerformanceStatisticsHistogram instead of CC3PerformanceStatistics.
	// The histograms are printed to the log.
	cc3World.performanceStatistics = [CC3PerformanceStatistics statistics];
//	cc3World.performanceStatistics = [CC3PerformanceStatisticsHistogram statistics];

	[nodeNameLabel setString: self.performanceWorld.templateNode.name];
}

//Specifies how often stats should be updated, in seconds
#define kStatisticsReportingInterval 0.5

/** Overridden to update the performance statistics labels. */
-(void) drawWorld {
	[super drawWorld];
	CC3PerformanceStatistics* stats = cc3World.performanceStatistics;
	if (stats.accumulatedFrameTime >= kStatisticsReportingInterval) {

		LogTrace(@"%@", stats.fullDescription);	// Log the results as well
		
		// Drawing statistics
		[frameRateLabel setString: [NSString stringWithFormat: @"fps: %.0f", stats.frameRate]];
		[nodesVisitedForDrawingLabel setString: [NSString stringWithFormat: @"nodes: %.0f",
												 stats.averageNodesVisitedForDrawingPerFrame]];
		[nodesDrawnLabel setString: [NSString stringWithFormat: @"drawn: %.0f",
									 stats.averageNodesDrawnPerFrame]];
		[drawCallsLabel setString: [NSString stringWithFormat: @"gl calls: %.0f",
									stats.averageDrawingCallsMadePerFrame]];
		[facesPresentedLabel setString: [NSString stringWithFormat: @"faces: %.0f",
										 stats.averageFacesPresentedPerFrame]];

		// Update statistics
		[updateRateLabel setString: [NSString stringWithFormat: @"ups: %.0f", stats.updateRate]];
		[nodesUpdatedLabel setString: [NSString stringWithFormat: @"nodes: %.0f",
									   stats.averageNodesUpdatedPerUpdate]];
		[nodesTransformedLabel setString: [NSString stringWithFormat: @"xfmed: %.0f",
										   stats.averageNodesTransformedPerUpdate]];

		[stats reset];
	}
}

@end
