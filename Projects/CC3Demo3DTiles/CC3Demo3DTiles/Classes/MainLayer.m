/*
 * MainLayer.m
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
 * See header file MainLayer.h for full API documentation.
 */


// Import the interfaces
#import "MainLayer.h"
#import "TileLayer.h"
#import "TileScene.h"
#import "CC3PODResourceNode.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3IOSExtensions.h"
#import "CC3Actions.h"
#import "CC3VertexSkinning.h"

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

// Model names
#define kBoxName				@"Box"
#define kBeachBallName			@"BeachBall"
#define kDieCubeName			@"Cube"
#define kMascotName				@"cocos2d_3dmodel_unsubdivided"

// File names
#define kBeachBallFileName		@"BeachBall.pod"
#define kMascotPODFile			@"cocos3dMascot.pod"
#define kDieCubePODFile			@"DieCube.pod"

#define kArrowUpButtonFileName	@"ArrowUpButton48x48.png"
#define kButtonRingFileName		@"ButtonRing48x48.png"
#define kGridPadding			(4 * kControlPositionScale)
#define kMinTileSideLen			(8 * kControlPositionScale)

@interface CCNode (ProtectedMethods)
-(void) contentSizeChanged;
@end


// MainLayer implementation
@implementation MainLayer

-(id) init {
	if( (self = [super init]) ) {
		_tiles = [NSMutableArray array];
		_tilesPerSide = 1;
		[self initializeControls];
		[self addTiles];
	}
	return self;
}


# pragma mark UI Controls

/** Initialize all the 2D user controls. */
-(void) initializeControls {
	[self addLabel];
	[self addButtons];
	[self positionControls];
	[self scheduleUpdate];
}

-(void) addLabel {
	_label = [CCLabelTTF labelWithString:@"Tiles: 888" fontName:@"Arial" fontSize: 20];
	_label.anchorPoint = ccp(1.0, 0.0);		// Align bottom-right
	_label.scale = kControlPositionScale;	// Scale text for Android
	[self addChild: _label z: 10];			// Draw on top
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

/**
 * Positions the view switching and invasion buttons between the two joysticks.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the buttons in the correct location within the new layer dimensions.
 */
-(void) positionControls {
	GLfloat xPos, yPos;
	GLfloat middle = self.contentSize.height / 2.0;

	xPos = self.contentSize.width - (_increaseNodesButton.contentSize.width / 2.0) * kControlSizeScale;

	yPos = middle + (_increaseNodesButton.contentSize.height / 2.0) * kControlSizeScale;
	_increaseNodesButton.position = ccp(xPos, yPos);
	
	yPos = middle - (_decreaseNodesButton.contentSize.height / 2.0) * kControlSizeScale;
	_decreaseNodesButton.position = ccp(xPos, yPos);
	
	_label.position =  ccp(self.contentSize.width , 0.0);
}

/** 
 * Called automatically when the contentSize has changed. 
 * Reposition the controls and tiles to match the new layer shape.
 * This method will be invoked for the first time when this layer is first initialized,
 * which is before the controls and templates have been created.
 */
-(void) contentSizeChanged {
	[super contentSizeChanged];
	[self positionControls];
	[self addTiles];
}

/** Invoked automatically when the OS view has been resized. Resize this layer to match the new view shape. */
-(void) viewDidResizeTo: (CGSize) newViewSize {
	self.contentSize = CCNodeSizeFromViewSize(newViewSize);
	[super viewDidResizeTo: newViewSize];	// Propagate to descendants
}


#pragma mark Tiling

/** Creates a grid of CC3Layers, with each side of the grid having tilesPerSide CC3Layers. */
-(void) addTiles {
	[self removeTiles];
	CGSize mySize = self.contentSize;
	CGSize gridSize = CGSizeMake(mySize.width - (_increaseNodesButton.contentSize.width * kControlSizeScale),
								 mySize.height - kGridPadding);
	CGSize tileSize = CGSizeMake(gridSize.width / _tilesPerSide - kGridPadding,
								 gridSize.height / _tilesPerSide - kGridPadding);
	
	CGRect tileBounds = CGRectMake(kGridPadding, kGridPadding, tileSize.width, tileSize.height);
	for (int r = 0; r < _tilesPerSide; r++) {
		for (int c = 0; c < _tilesPerSide; c++) {
			[self addTileIn: tileBounds];
			tileBounds.origin.x += tileSize.width + kGridPadding;
		}
		// Move back and up...like a typewriter carriage return
		tileBounds.origin.x = kGridPadding;							// Back to the first column
		tileBounds.origin.y += tileSize.height + kGridPadding;		// Move to next row
	}
	
	_label.string = [NSString stringWithFormat: @"Tiles: %u", _tilesPerSide * _tilesPerSide];
}

/**
 * Creates a new CC3Layer with the specified bounds, containing a new CC3Scene,
 * and adds the CC3Layer to this layer.
 */
-(void) addTileIn: (CGRect) bounds {
	CC3Layer* tileLayer = [TileLayer layer];
	tileLayer.position = bounds.origin;
	tileLayer.contentSize = bounds.size;
	[self addChild: tileLayer];
	[_tiles addObject: tileLayer];
}

-(void) removeTiles {
	for (CCNode* child in _tiles) [self removeChild: child cleanup: YES];
	[_tiles removeAllObjects];
}


#pragma mark Updating

-(void) update: (CCTime)dt { for (CC3Layer* tile in _tiles) [tile update: dt]; }

/**
 * The user has pressed the increase nodes button.
 * Add one row and column to the grid, but limit the smaller side of the tile to a min length.
 */
-(void) increaseNodesSelected {
	CGSize cs = self.contentSize;
	CGFloat maxTPS = MIN(cs.width, cs.height) / (kMinTileSideLen + kGridPadding);
	_tilesPerSide = MIN(_tilesPerSide + 1, maxTPS);
	[self addTiles];
}

/**
 * The user has pressed the decrease nodes button.
 * Remove one row and column, but always show at least one.
 */
-(void) decreaseNodesSelected {
	_tilesPerSide = MAX(_tilesPerSide - 1, 1);
	[self addTiles];
}


@end
