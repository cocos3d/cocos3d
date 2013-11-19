/*
 * MainLayer.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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

/** Scale and position the buttons so they are usable at various screen resolutions. */
#if APPORTABLE
#	define kControlSizeScale		(MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) / 1024.0f)
#	define kControlPositionScale	kControlSizeScale
#else
#	define kControlSizeScale		CC_CONTENT_SCALE_FACTOR()
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


// MainLayer implementation
@implementation MainLayer

-(id) initWithController: (CC3ViewController*) controller {
	if( (self = [super initWithController: controller]) ) {
		_tiles = [NSMutableArray array];
		_templates = [NSMutableArray array];
		_backdropTemplate = nil;
		_tilesPerSide = 1;
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
	// the clearing of the depth buffer when transitioning from the 3D scene to the 2D scene.
	// See the notes for the CC3Scene shouldClearDepthBufferBefore2D property for more info.
	[[CCDirector sharedDirector] setDepthTest: NO];

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
	_increaseNodesMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(increaseNodesSelected:)];
	
	// Add button to allow user to decrease the number of nodes in the 3D scene.
	_decreaseNodesMI = [self addButtonWithImageFile: kArrowUpButtonFileName
									  withSelector: @selector(decreaseNodesSelected:)];
	_decreaseNodesMI.rotation = 180.0f;
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
	mi.scale = kControlSizeScale;
	
	CCMenu* viewMenu = [CCMenu menuWithItems: mi, nil];
	viewMenu.position = CGPointZero;
	[self addChild: viewMenu];
	
	return mi;
}

/**
 * Positions the view switching and invasion buttons between the two joysticks.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the buttons in the correct location within the new layer dimensions.
 */
-(void) positionControls {
	GLfloat xPos, yPos;
	GLfloat middle = self.contentSize.height / 2.0;

	xPos = self.contentSize.width - (_increaseNodesMI.contentSize.width / 2.0) * kControlSizeScale;

	yPos = middle + (_increaseNodesMI.contentSize.height / 2.0) * kControlSizeScale;
	_increaseNodesMI.position = ccp(xPos, yPos);
	
	yPos = middle - (_decreaseNodesMI.contentSize.height / 2.0) * kControlSizeScale;
	_decreaseNodesMI.position = ccp(xPos, yPos);
	
	_label.position =  ccp(self.contentSize.width , 0.0);
}

/** 
 * Called automatically when the contentSize has changed. 
 * Reposition the controls and tiles to match the new layer shape.
 * This method will be invoked for the first time when this layer is first initialized,
 * which is before the controls and templates have been created.
 */
-(void) didUpdateContentSizeFrom: (CGSize) oldSize {
	[super didUpdateContentSizeFrom: oldSize];
	[self positionControls];
	[self addTiles];
}

#pragma mark Model Templates

-(void) initializeTemplates {
	CC3Node* n;
	CC3MeshNode* mn;
	CC3ResourceNode* rezNode;

	// The node to use as a backdrop for each scene.
	_backdropTemplate = [CC3ClipSpaceNode nodeWithColor: ccc4f(0.2, 0.24, 0.43, 1.0)];
	[_backdropTemplate createGLBuffers];
	[_backdropTemplate selectShaderPrograms];
	
	// Make a simple box template available. Only 6 faces per node.
	mn = [CC3BoxNode nodeWithName: kBoxName];
	[mn populateAsSolidBox: CC3BoxFromMinMax(cc3v(-1.0, -1.0, -1.0), cc3v( 1.0,  1.0,  1.0))];
	mn.shouldColorTile = YES;
	[self configureAndAddTemplate: mn];
	
	// Mascot model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromFile: kMascotPODFile
			  expectsVerticallyFlippedTextures: YES];
	mn = [rezNode getMeshNodeNamed: kMascotName];
	[mn moveMeshOriginToCenterOfGeometry];
	mn.rotation = cc3v(0.0, -90.0, 0.0);
	[self configureAndAddTemplate: mn];
	
	// Die cube model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromFile: kDieCubePODFile];
	n = [rezNode getNodeNamed: kDieCubeName];
	[self configureAndAddTemplate: n];
	
	// Beachball from POD resource with no texture, but with several subnodes
	rezNode = [CC3PODResourceNode nodeFromFile: kBeachBallFileName];
	n = [rezNode getNodeNamed: kBeachBallName];
	n.isOpaque = YES;
	[self configureAndAddTemplate: n];

	// Animated dragon from POD resource
	// The model animation that was loaded from the POD into track zero is a concatenation of
	// several separate movements, such as gliding and flapping. Extract the distinct movements
	// from the base animation and add those distinct movement animations as separate tracks.
	rezNode = [CC3PODResourceNode nodeFromFile: @"Dragon.pod"];
	n = [rezNode getNodeNamed: @"Dragon.pod-SoftBody"];
	_glideTrack = [n addAnimationFromFrame: 0 toFrame: 60];
	_flapTrack = [n addAnimationFromFrame: 61 toFrame: 108];
	
#if !CC3_GLSL
	// The fixed pipeline of OpenGL ES 1.1 cannot make use of the tangent-space normal
	// mapping texture that is applied to the dragon, and the result is that the dragon
	// looks black. Extract the diffuse texture (from texture unit 1), remove all texture,
	// and set the diffuse texture as the only texture (in texture unit 0).
	CC3MeshNode* dgnBody = [rezNode getMeshNodeNamed: @"Dragon"];
	CC3Material* dgnMat = dgnBody.material;
	CC3Texture* dgnTex = [dgnMat textureForTextureUnit: 1];
	[dgnMat removeAllTextures];
	dgnMat.texture = dgnTex;
#endif

	[self configureAndAddTemplate: n];
}

/**
 * Provides standard configuration for the specified template model,
 * and add it to the list of templates.
 */
-(void) configureAndAddTemplate: (CC3Node*) templateNode {
	templateNode.touchEnabled = YES;
	[templateNode selectShaderPrograms];
	[templateNode createGLBuffers];
	[templateNode releaseRedundantContent];
	[_templates addObject: templateNode];
}


#pragma mark Tiling

/** Creates a grid of CC3Layers, with each side of the grid having tilesPerSide CC3Layers. */
-(void) addTiles {
	[self removeTiles];
	CGSize mySize = self.contentSize;
	CGSize gridSize = CGSizeMake(mySize.width - (_increaseNodesMI.contentSize.width * kControlSizeScale),
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
 * Creates a new CC3Layer with the specified bounds, creates a new CC3Scene,
 * and adds the CC3Layer to this layer.
 */
-(void) addTileIn: (CGRect) bounds {
	CC3Layer* tileLayer = [TileLayer layerWithController: self.controller];
	tileLayer.position = bounds.origin;
	tileLayer.contentSize = bounds.size;
	tileLayer.cc3Scene = [self makeScene];
	[self addChild: tileLayer];
	[_tiles addObject: tileLayer];
}

/**
 * Creates a new scene and chooses one of the template nodes
 * and sets it as the main node of the scene.
 */
-(CC3Scene*) makeScene {

	// In no templates are available, return a nil scene.
	if (_templates.count == 0) return nil;
		
	TileScene* scene = [TileScene scene];		// A new scene
	
	// Add the backdrop to the scene.
	scene.backdrop = [_backdropTemplate copy];
	
	// Choose either to display a random model in each tile, or the same model
	// in each tile by uncommenting one of these lines and commenting out the other.
	CC3Node* aNode = [[_templates objectAtIndex: CC3RandomUIntBelow(_templates.count)] copy];
//	CC3Node* aNode = [[templates objectAtIndex: 0] copy];	// Choose any index below template count

	// The shouldColorTile property is actually tracked by the userData property!
	if (aNode.shouldColorTile) aNode.color = [self pickNodeColor];
	
	// If the node is animated, initiate a CC3Animate action on it
	if (aNode.containsAnimation) {
		
		// The dragon model now contains three animation tracks: a gliding track, a flapping
		// track, and the original concatenation of animation loaded from the POD file into
		// track zero. We want the dragon flying and flapping its wings. So, we give the flapping
		// track a weight of one, and the gliding and original tracks a weighting of zero.
		[aNode setAnimationBlendingWeight: 0.0f onTrack: 0];
		[aNode setAnimationBlendingWeight: 0.0f onTrack: _glideTrack];
		[aNode setAnimationBlendingWeight: 1.0f onTrack: _flapTrack];

		// Create the CC3Animate action to run the animation. The duration is randomized so
		// that when multiple dragons are visible, they are not all flapping in unison.
		ccTime flapTime = CC3RandomFloatBetween(1.0, 2.0);
		CC3Animate* flap = [CC3Animate actionWithDuration: flapTime onTrack: _flapTrack];
		[aNode runAction: [CCRepeatForever actionWithAction: flap]];
	}
	
	scene.mainNode = aNode;		// Set the node as the main node of the scene, for easy access

	return scene;
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
	for (CCNode* child in _tiles) [self removeChild: child cleanup: YES];
	[_tiles removeAllObjects];
}


#pragma mark Updating

-(void) update: (ccTime)dt {
	for (CC3Layer* tile in _tiles) [tile update: dt];
}

/**
 * The user has pressed the increase nodes button.
 * Add one row and column to the grid, but limit the smaller side of the tile to a min length.
 */
-(void) increaseNodesSelected: (CCMenuItemToggle*) menuItem {
	CGSize cs = self.contentSize;
	CGFloat maxTPS = MIN(cs.width, cs.height) / (kMinTileSideLen + kGridPadding);
	_tilesPerSide = MIN(_tilesPerSide + 1, maxTPS);
	[self addTiles];
}

/**
 * The user has pressed the decrease nodes button.
 * Remove one row and column, but always show at least one.
 */
-(void) decreaseNodesSelected: (CCMenuItemToggle*) menuItem {
	_tilesPerSide = MAX(_tilesPerSide - 1, 1);
	[self addTiles];
}


@end
