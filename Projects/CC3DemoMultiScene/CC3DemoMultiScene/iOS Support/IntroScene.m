/*
 * IntroScene.M
 *
 * Cocos3D 2.0.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file IntroScene.h for full API documentation.
 */

#import "IntroScene.h"
#import "CC3Logging.h"
#import "CC3CC2Extensions.h"

/** Cocos2D v3 auto-scales images for Retina. Cocos2D v2 & v1 do not. This affects controls sizes. */
#if CC3_CC2_CLASSIC
#	define kSpriteScale				1.0
#else
#	define kSpriteScale				(CCDirector.sharedDirector.contentScaleFactor)
#endif	// CC3_CC2_CLASSIC

/** Scale and position the controls so they are usable at various screen resolutions. */
#if APPORTABLE
#	define kControlSizeScale		(MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) / (1024.0f * kSpriteScale))
#	define kControlPositionScale	kControlSizeScale
#else
#	define kControlSizeScale		(CCDirector.sharedDirector.contentScaleFactor / kSpriteScale)
#	define kControlPositionScale	1.0
#endif	// APPORTABLE

@interface CCNode (ProtectedMethods)
-(void) contentSizeChanged;
@end

@implementation IntroScene

/** Invoked automatically when the OS view has been resized. Resize this layer to match the new view shape. */
-(void) viewDidResizeTo: (CGSize) newViewSize {
	self.contentSize = CCNodeSizeFromViewSize(newViewSize);
	[super viewDidResizeTo: newViewSize];	// Propagate to descendants
}

/**
 * Called automatically when the contentSize has changed.
 * Moves and sizes content to be appropriate for the new size.
 */
-(void) contentSizeChanged {
	[super contentSizeChanged];
	[self positionContent];
}

/** Sizes the background to fit, and position the label in the center of the scene. */
-(void) positionContent {
	CGSize cs = self.contentSize;
	_background.contentSize = cs;
	_label.position = ccp(cs.width / 2.0f, cs.height / 2.0f);

#if !CC3_CC2_1
	_label.fontSize = (_nominalLabelSize.width > cs.width * 0.9) ? 18.0f : 36.0f;
#endif	// !CC3_CC2_1

}

#if CC3_CC2_1
/** For earlier Cocos2D, viewDidResizeTo: is invoked too early for initial layout. */
-(void) onEnter {
	self.contentSize = CCDirector.sharedDirector.winSize;
	[super onEnter];
}
#endif	// CC3_CC2_1



#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		[self initializeContent];
	}
	return self;
}

/** Adds a colored background and a label telling the user how to select a 3D scene to display. */
-(void) initializeContent {
#if CC3_CC2_CLASSIC
	_background = [CCLayerColor layerWithColor: ccc4(77, 77, 77, 255)];
#else
	_background = [CCNodeColor nodeWithColor: [CCColor colorWithRed: 0.3f green: 0.3f blue: 0.3f alpha: 1.0f]];
#endif	// CC3_CC2_CLASSIC
	[self addChild: _background];
	
	// Add a label, position it by its center, and scale it for the device
	_label = [CCLabelTTF labelWithString: @"Use the buttons below\nto select a demo"
								fontName: @"Chalkduster"
								fontSize: 18.0f];
	_nominalLabelSize = _label.contentSizeInPixels;

// Align horizontally
#if CC3_CC2_1												// Cocos2D 1.1 has not alignment option
#elif CC3_CC2_2
	_label.horizontalAlignment = kCCTextAlignmentCenter;	// Cocos2D 2.1
#else
	_label.horizontalAlignment = CCTextAlignmentCenter;		// Cocos2D 3.x
#endif	// !CC3_CC2_1

	[_label setAnchorPoint: ccp(0.5, 0.5)];
	_label.scale = kControlSizeScale;
	[self addChild: _label];
	
	[self positionContent];
}

@end
