/*
 * MainLayer.m
 *
 * cocos3d 0.6.3
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
 * See header file MainLayer.h for full API documentation.
 */


// Import the interfaces
#import "MainLayer.h"
#import "TileLayer.h"
#import "TileWorld.h"
#import "CC3PODResourceNode.h"
#import "CC3ParametricMeshNodes.h"

// Model names
#define kBoxName				@"Box"
#define kBeachBallName			@"BeachBall"
#define kDieCubeName			@"Cube"
#define kMascotName				@"cocos2d_3dmodel_unsubdivided"

// File names
#define kBallsFileName			@"Balls.pod"
#define kMascotPODFile			@"cocos3dMascot.pod"
#define kDieCubePODFile			@"DieCube.pod"

#define kArrowUpButtonFileName @"ArrowUpButton48x48.png"
#define kButtonRingFileName @"ButtonRing48x48.png"
#define kGridPadding 4
#define kMinTileSideLen 8


@interface MainLayer (TemplateMethods)
-(void) initializeControls;
-(void) addLabel;
-(void) addButtons;
-(CCMenuItem*) addButtonWithImageFile: (NSString*) imageFile withSelector: (SEL) callbackSelector;
-(void) positionControls;
-(void) addTiles;
-(void) addTileIn: (CGRect) bounds;
-(void) removeTiles;
-(void) initializeTemplates;
-(CC3World*) makeWorld;
-(ccColor3B) pickNodeColor;
@end

// MainLayer implementation
@implementation MainLayer

- (void) dealloc {
	[tiles release];
	[templates release];
	increaseNodesMI = nil;				// retained as child
	decreaseNodesMI = nil;				// retained as child

	[super dealloc];
}

-(id) init {
	if( (self=[super init])) {
		tiles = [[NSMutableArray array] retain];
		templates = [[NSMutableArray array] retain];
		tilesPerSide = 1;
		[self initializeTemplates];
		[self initializeControls];
		[self addTiles];
	}
	return self;
}


# pragma mark UI Controls

/** Initialize all the 2D user controls. */
-(void) initializeControls {
	
	// Turn depth testing off for 2D content to improve performance and allow us to reduce
	// the clearing of the depth buffer when transitioning from the 3D world to the 2D world.
	// See the notes for the CC3World shouldClearDepthBufferBefore2D property for more info.
	[[CCDirector sharedDirector] setDepthTest: NO];

	[self addLabel];
	[self addButtons];
	[self positionControls];
	[self scheduleUpdate];
}

-(void) addLabel {
	label = [CCLabelTTF labelWithString:@"Tiles per side: 88" fontName:@"Arial" fontSize: 22];
	label.anchorPoint = ccp(1.0, 0.0);		// Alight bottom-right
	[self addChild: label z: 10];			// Draw on top
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

/**
 * Positions the view switching and invasion buttons between the two joysticks.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the button in the correct location within the new layer dimensions.
 */
-(void) positionControls {
	GLfloat xPos, yPos;
	GLfloat middle = self.contentSize.height / 2.0;

	xPos = self.contentSize.width - (increaseNodesMI.contentSize.width / 2.0);

	yPos = middle + (increaseNodesMI.contentSize.height / 2.0);
	increaseNodesMI.position = ccp(xPos, yPos);
	
	yPos = middle - (decreaseNodesMI.contentSize.height / 2.0);
	decreaseNodesMI.position = ccp(xPos, yPos);
	
	label.position =  ccp(self.contentSize.width , 0.0);
}

#pragma mark Model Templates

-(void) initializeTemplates {
	CC3MeshNode* mn;
	CC3ResourceNode* rezNode;

	// Make a simple box template available. Only 6 faces per node.
	mn = [CC3BoxNode nodeWithName: kBoxName];
	CC3BoundingBox bBox;
	bBox.minimum = cc3v(-1.0, -1.0, -1.0);
	bBox.maximum = cc3v( 1.0,  1.0,  1.0);
	[mn populateAsSolidBox: bBox];
	mn.material = [CC3Material material];
	mn.isTouchEnabled = YES;
	mn.shouldColorTile = YES;
	[templates addObject: mn];
	
	// Mascot model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kMascotPODFile];
	mn = (CC3MeshNode*)[rezNode getNodeNamed: kMascotName];
	[mn remove];		// Remove from the POD resource
	[mn movePivotToCenterOfGeometry];
	mn.rotation = cc3v(0.0, -90.0, 0.0);
	mn.isTouchEnabled = YES;
	[templates addObject: mn];
	
	// Die cube model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kDieCubePODFile];
	mn = (CC3MeshNode*)[rezNode getNodeNamed: kDieCubeName];
	[mn remove];		// Remove from the POD resource
	mn.isTouchEnabled = YES;
	[templates addObject: mn];
	
	// Ball models from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kBallsFileName];
	
	// Beachball with no texture, but with several subnodes
	mn = (CC3MeshNode*)[rezNode getNodeNamed: kBeachBallName];
	[mn remove];		// Remove from the POD resource
	mn.isOpaque = YES;
	mn.isTouchEnabled = YES;
	[templates addObject: mn];
}


#pragma mark Tiling

/** Creates a grid of CC3Layers, with each side of the grid having tilesPerSide CC3Layers. */
-(void) addTiles {
	[self removeTiles];
	CGSize mySize = self.contentSize;
	CGSize gridSize = CGSizeMake(mySize.width - increaseNodesMI.contentSize.width,
								 mySize.height - kGridPadding);
	CGSize tileSize = CGSizeMake(gridSize.width / tilesPerSide - kGridPadding,
								 gridSize.height / tilesPerSide - kGridPadding);
	
	CGRect tileBounds = CGRectMake(kGridPadding, kGridPadding, tileSize.width, tileSize.height);
	for (int r = 0; r < tilesPerSide; r++) {
		for (int c = 0; c < tilesPerSide; c++) {
			[self addTileIn: tileBounds];
			tileBounds.origin.x += tileSize.width + kGridPadding;
		}
		// Move back and up...like a typewriter carriage return
		tileBounds.origin.x = kGridPadding;							// Back to the first column
		tileBounds.origin.y += tileSize.height + kGridPadding;		// Move to next row
	}
	
	label.string = [NSString stringWithFormat: @"Tiles per side: %u", tilesPerSide];
}

/**
 * Creates a new CC3Layer with the specified bounds, creates a new CC3World, frames
 * the mainNode of the world in the camera, and adds the CC3Layer to this layer.
 */
-(void) addTileIn: (CGRect) bounds {
//	CCLayer* tileLayer = [CCLayerColor layerWithColor: ccc4(50, 60, 110, 255)];
	CC3Layer* tileLayer = [TileLayer layerWithColor: ccc4(50, 60, 110, 255)];
	tileLayer.position = bounds.origin;
	tileLayer.contentSize = bounds.size;
	tileLayer.cc3World = [self makeWorld];

	[((TileWorld*)tileLayer.cc3World) frameMainNode];	// Focuses the camera on the main node.

	[self addChild: tileLayer];
	[tiles addObject: tileLayer];
}

/**
 * Creates a new world and chooses one of the template nodes
 * and sets it as the main node of the world.
 */
-(CC3World*) makeWorld {
	TileWorld* world = [TileWorld world];		// A new world
	
	// Choose either to display a random model in each tile, or the same model
	// in each tile by uncommenting one of these lines and commenting out the other.
	CC3Node* aNode = [[templates objectAtIndex: CC3RandomUIntBelow(templates.count)] copyAutoreleased];
//	CC3Node* aNode = [[templates objectAtIndex: 0] copyAutoreleased];

	// The shouldColorTile property is actually tracked by the userData property!
	if (aNode.shouldColorTile) {
		aNode.color = [self pickNodeColor];
	}
	world.mainNode = aNode;
	[world createGLBuffers];
	return world;
}

-(ccColor3B) pickNodeColor {
	switch (CC3RandomUIntBelow(6)) {
		case 0:
			return ccRED;
		case 1:
			return ccGREEN;
		case 2:
			return ccBLUE;
		case 3:
			return ccYELLOW;
		case 4:
			return ccORANGE;
		case 5:
		default:
			return ccWHITE;
	}
}

-(void) removeTiles {
	for (CCNode* child in tiles) {
		[self removeChild: child cleanup: YES];
	}
	[tiles removeAllObjects];
}


#pragma mark Updating

-(void) update: (ccTime)dt {
	for (CC3Layer* tile in tiles) {
		[tile update: dt];
	}
}

/**
 * The user has pressed the increase nodes button.
 * Add one row and column to the grid, but limit the smaller side of the tile to a min length.
 */
-(void) increaseNodesSelected: (CCMenuItemToggle*) menuItem {
	CGSize cs = self.contentSize;
	CGFloat maxTPS = MIN(cs.width, cs.height) / (kMinTileSideLen + kGridPadding);
	tilesPerSide = MIN(tilesPerSide + 1, maxTPS);
	[self addTiles];
}

/**
 * The user has pressed the decrease nodes button.
 * Remove one row and column, but always show at least one.
 */
-(void) decreaseNodesSelected: (CCMenuItemToggle*) menuItem {
	tilesPerSide = MAX(tilesPerSide - 1, 1);
	[self addTiles];
}


@end
