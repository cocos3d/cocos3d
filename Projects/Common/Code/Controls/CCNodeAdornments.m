/*
 * CCNodeAdornments.m
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
 * See header file CCNodeAdornments.h for full API documentation.
 */

#import "CCNodeAdornments.h"
#import "CC3Logging.h"
#import "CC3Environment.h"


#pragma mark CCNodeAdornmentBase implementation

#if COCOS2D_VERSION < 0x020100
#	define CC2_ZORDER zOrder_
#else
#	define CC2_ZORDER _zOrder
#endif

@implementation CCNodeAdornmentBase

@synthesize actionDuration=_actionDuration;

-(NSInteger) zOrder { return [super zOrder]; }

-(void) setZOrder: (NSInteger) z {
	CC2_ZORDER = z;
}

// Abstract implementation does nothing.
-(void) activate {}

// Abstract implementation does nothing.
-(void) deactivate {}

-(id) init { return [self initWithActionDuration: 0.0]; }

+(id) adornment { return [[self alloc] init]; }

-(id) initWithActionDuration: (CCTime) aDuration {
	if( (self = [super init]) ) {
		_actionDuration = aDuration;
		self.zOrder = kAdornmentOverZOrder;
	}
	return self;
}

+(id) adornmentWithActionDuration: (CCTime) aDuration {
	return [[self alloc] initWithActionDuration: aDuration];
}

@end


#pragma mark CCNodeAdornmentOverlayFader implementation

// A (hopefully) unique tag that identifies the currently activated fade-in
// or fade-out action. This tag is used to cancel the action if needed. 
#define kFadeActionTag		(NSInteger)0xfade0001


@implementation CCNodeAdornmentOverlayFader

@synthesize peakOpacity=_peakOpacity, sprite=_sprite;

-(id) initWithSprite: (CCSprite*) sprite
		 peakOpacity: (CCOpacity) opacity
		fadeDuration: (CCTime) aDuration {
	CC3Assert(sprite, @"Sprite must not be nil");
	if( (self = [super initWithActionDuration: aDuration]) ) {
		_peakOpacity = opacity;
		self.contentSize = sprite.contentSize;
		sprite.visible = NO;
		sprite.opacity = 0;
		_sprite = sprite;
		[self addChild: sprite];
	}
	return self;
}

+(id) adornmentWithSprite: (CCSprite*) sprite peakOpacity: (CCOpacity) opacity fadeDuration: (CCTime) aDuration {
	return [[self alloc] initWithSprite: sprite peakOpacity: opacity fadeDuration: aDuration];
}

-(id) initWithSprite: (CCSprite*) sprite peakOpacity: (CCOpacity) opacity {
	return [self initWithSprite: sprite peakOpacity: opacity fadeDuration: kDefaultFadeDuration];
}

+(id) adornmentWithSprite: (CCSprite*) sprite peakOpacity: (CCOpacity) opacity {
	return [[self alloc] initWithSprite: sprite peakOpacity: opacity];
}

-(id) initWithSprite: (CCSprite*) sprite { return [self initWithSprite: sprite peakOpacity: kCCOpacityFull]; }

+(id) adornmentWithSprite: (CCSprite*) sprite { return [[self alloc] initWithSprite: sprite]; }

// When activated, make the adornment node visible and establish an action
// to fade it in up to the peak opacity. The action is tagged so that it
// can be easily found if it needs to be cancelled.
-(void) activate {
	[_sprite stopActionByTag: kFadeActionTag];	// Cancel any existing fade action
	CCAction* fadeAction = [CCActionFadeTo actionWithDuration: self.actionDuration opacity: _peakOpacity];
	fadeAction.tag = kFadeActionTag;
	_sprite.visible = YES;
	[_sprite runAction: fadeAction];
}

// When deactivated, establish an action sequence to first fade the adornment node
// back to fully transparent, and then explicitly hide the adornment. Although this
// last step is visually redundant, it makes subsequent drawing of the invisible
// adornment node more efficient. The action is tagged so that it can be easily found
// if it needs to be cancelled.
-(void) deactivate {
	[_sprite stopActionByTag: kFadeActionTag];	// Cancel any existing fade action
	CCActionInterval* fadeAction = [CCActionFadeOut actionWithDuration: self.actionDuration];
	CCActionInterval* hideAction = [CCActionHide action];
	CCActionInterval* fadeThenHideAction = [CCActionSequence actionOne: fadeAction
																   two: hideAction];
	fadeThenHideAction.tag = kFadeActionTag;
	[_sprite runAction: fadeThenHideAction];
}

@end


#pragma mark CCNodeAdornmentScaler implementation

// A (hopefully) unique tag that identifies the currently activated scaling action.
// This tag is used to cancel the action if needed. 
#define kScaleActionTag 0x5ca1e001


@implementation CCNodeAdornmentScaler

@synthesize activatedScale=_activatedScale;

-(id) initToScaleBy: (CGSize) aScale scaleDuration: (CCTime) aDuration {
	if( (self = [super init]) ) {
		self.actionDuration = aDuration;
		_activatedScale = aScale;
	}
	return self;
}

+(id) adornmentToScaleBy: (CGSize) aScale scaleDuration: (CCTime) aDuration {
	return [[self alloc] initToScaleBy: aScale scaleDuration: aDuration];
}

-(id) initToScaleBy: (CGSize) aScale {
	return [self initToScaleBy: aScale scaleDuration: kDefaultScalingDuration];
}

+(id) adornmentToScaleBy: (CGSize) aScale {
	return [[self alloc] initToScaleBy: aScale];
}

-(id) initToScaleUniformlyBy: (float) aScale scaleDuration: (CCTime) aDuration {
	return [self initToScaleBy: CGSizeMake(aScale, aScale) scaleDuration: aDuration];
}

+(id) adornmentToScaleUniformlyBy: (float) aScale scaleDuration: (CCTime) aDuration {
	return [[self alloc] initToScaleUniformlyBy: aScale scaleDuration: aDuration];
}

-(id) initToScaleUniformlyBy: (float) aScale {
	return [self initToScaleUniformlyBy: aScale scaleDuration: kDefaultScalingDuration];
}

+(id) adornmentToScaleUniformlyBy: (float) aScale {
	return [[self alloc] initToScaleUniformlyBy: aScale];
}

// Sets the value of originalScale from the current parent.
-(void) setOriginalScaleFromParent {
	CCNode* p = self.parent;
	_originalScale = CGSizeMake(p.scaleX, p.scaleY);
}

// Overridden to cache the parent's current scale
-(void) setParent: (CCNode*) aNode {
	[super setParent: aNode];
	[self setOriginalScaleFromParent];
}

// When activated, scale the parent CCNode by the value of the activatedScale property.
// The current scale value of the parent is cached again, in case that scale had been
// changed since this adornment was added to the parent. We do not simply use a deactivation
// scale of 1 / activationScale in case the activation scaling is interrupted by the
// deactivation, and has not fully scaled up at the time the deactivation starts.
// The action is tagged so that it can be easily found if it needs to be cancelled.
-(void) activate {
	CCNode* p = self.parent;
	CCAction* currAction = [p getActionByTag: kScaleActionTag];
	if(currAction) {
		// if we already have an active action, cancel it
		[p stopAction: currAction];
	} else {
		// only cache scale if a scaling action is not active
		// because otherwise scale will be evolvin and we'll cache something halfway
		[self setOriginalScaleFromParent];
	}
	// use scaleTo instead of scaleBy so that final size is deterministic in the case
	// where we have interrupted an active scaling action above
	float finalScaleX = _originalScale.width * _activatedScale.width;
	float finalScaleY = _originalScale.height * _activatedScale.height;
	CCAction* scaleAction = [CCActionScaleTo actionWithDuration: self.actionDuration
														 scaleX: finalScaleX
														 scaleY: finalScaleY];
	scaleAction.tag = kScaleActionTag;
	[p runAction: scaleAction];
}

// When activated, scale the parent CCNode back to its original scale.
// The action is tagged so that it can be easily found if it needs to be cancelled.
-(void) deactivate {
	CCNode* p = self.parent;
	[p stopActionByTag: kScaleActionTag];		// Cancel any existing scaling action
	CCAction* scaleAction = [CCActionScaleTo actionWithDuration: self.actionDuration
														 scaleX: _originalScale.width
														 scaleY: _originalScale.height];
	scaleAction.tag = kScaleActionTag;
	[p runAction: scaleAction];
}

@end


#if CC3_CC2_CLASSIC

#pragma mark AdornableMenuItemToggle

@implementation AdornableMenuItemToggle

-(CCNode<CCNodeAdornmentProtocol>*) adornment { return _adornment; }

// Add the adornment as a child, removing any previous adornment.
-(void) setAdornment: (CCNode<CCNodeAdornmentProtocol>*) aNode {
	[self removeChild: _adornment cleanup: YES];
	_adornment = aNode;
	if(aNode) [self addChild: aNode];
}

// When this menu item is selected, activate the adornment
-(void) selected {
	[super selected];
	[_adornment activate];
}

// When this menu item is unselected, deactivate the adornment
-(void) unselected {
	[super unselected];
	[_adornment deactivate];
}

@end


#pragma mark AdornableMenuItemImage

@implementation AdornableMenuItemImage

-(CCNode<CCNodeAdornmentProtocol>*) adornment { return _adornment; }

// Add the adornment as a child, removing any previous adornment.
-(void) setAdornment: (CCNode<CCNodeAdornmentProtocol>*) aNode {
	[self removeChild: _adornment cleanup: YES];
	_adornment = aNode;
	if(aNode) [self addChild: aNode];
}

// When this menu item is selected, activate the adornment
-(void) selected {
	[super selected];
	[_adornment activate];
}

// When this menu item is unselected, deactivate the adornment
-(void) unselected {
	[super unselected];
	[_adornment deactivate];
}

@end

#else


#pragma mark AdornableButton

@implementation AdornableButton

-(CCNode<CCNodeAdornmentProtocol>*) adornment { return _adornment; }

// Add the adornment as a child, removing any previous adornment.
-(void) setAdornment: (CCNode<CCNodeAdornmentProtocol>*) aNode {
	[self removeChild: _adornment cleanup: YES];
	_adornment = aNode;
	if(aNode) [self addChild: aNode];
}

-(void) setHighlighted: (BOOL) highlighted {
	[super setHighlighted: highlighted];
	if (highlighted)
		[_adornment activate];
	else if (!self.selected)
		[_adornment deactivate];
}

@end

#endif	// CC3_CC2_CLASSIC

