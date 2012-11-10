/*
 * CCNodeAdornments.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd.
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


#pragma mark CCNodeAdornmentBase implementation

@implementation CCNodeAdornmentBase

@synthesize actionDuration;

-(int) zOrder {
	return [super zOrder];
}

-(void) setZOrder: (int) z {
	zOrder_ = z;
}

// Abstract implementation does nothing.
-(void) activate {}

// Abstract implementation does nothing.
-(void) deactivate {}

-(id) init {
	return [self initWithActionDuration: 0.0];
}

+(id) adornment {
	return [[[self alloc] init] autorelease];
}

-(id) initWithActionDuration: (ccTime) aDuration {
	if( (self = [super init]) ) {
		actionDuration = aDuration;
		zOrder_ = kAdornmentOverZOrder;
	}
	return self;
}

+(id) adornmentWithActionDuration: (ccTime) aDuration {
	return [[[self alloc] initWithActionDuration: aDuration] autorelease];
}

@end


#pragma mark CCNodeAdornmentOverlayFader implementation

// A (hopefully) unique tag that identifies the currently activated fade-in
// or fade-out action. This tag is used to cancel the action if needed. 
#define kFadeActionTag 0xfade0001


@implementation CCNodeAdornmentOverlayFader

@synthesize peakOpacity, adornmentNode;

-(void) dealloc {
	adornmentNode = nil;		// retained as child
	[super dealloc];
}

-(id) initWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity fadeDuration: (ccTime) aDuration {
	NSAssert(aNode, @"CCNodeAdornment node must not be nil");
	if( (self = [super initWithActionDuration: aDuration]) ) {
		peakOpacity = opacity;
		self.contentSize = aNode.contentSize;
		aNode.visible = NO;
		[aNode setOpacity: 0];
		adornmentNode = aNode;
		[self addChild: aNode];
	}
	return self;
}

+(id) adornmentWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity fadeDuration: (ccTime) aDuration {
	return [[[self alloc] initWithAdornmentNode: aNode peakOpacity: opacity fadeDuration: (ccTime) aDuration] autorelease];
}

-(id) initWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity {
	return [self initWithAdornmentNode: aNode peakOpacity: opacity fadeDuration: kDefaultFadeDuration];
}

+(id) adornmentWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity {
	return [[[self alloc] initWithAdornmentNode: aNode peakOpacity: opacity] autorelease];
}

-(id) initWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode {
	return [self initWithAdornmentNode: aNode peakOpacity: kFullOpacity];
}

+(id) adornmentWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode {
	return [[[self alloc] initWithAdornmentNode: aNode] autorelease];
}

// When activated, make the adornment node visible and establish an action
// to fade it in up to the peak opacity. The action is tagged so that it
// can be easily found if it needs to be cancelled.
-(void) activate {
	[adornmentNode stopActionByTag: kFadeActionTag];	// Cancel any existing fade action
	CCAction* fadeAction = [CCFadeTo actionWithDuration: self.actionDuration opacity: peakOpacity];
	fadeAction.tag = kFadeActionTag;
	adornmentNode.visible = YES;
	[adornmentNode runAction: fadeAction];
}

// When deactivated, establish an action sequence to first fade the adornment node
// back to fully transparent, and then explicitly hide the adornment. Although this
// last step is visually redundant, it makes subsequent drawing of the invisible
// adornment node more efficient. The action is tagged so that it can be easily found
// if it needs to be cancelled.
-(void) deactivate {
	[adornmentNode stopActionByTag: kFadeActionTag];	// Cancel any existing fade action
	CCFiniteTimeAction* fadeAction = [CCFadeOut actionWithDuration: self.actionDuration];
	CCFiniteTimeAction* hideAction = [CCHide action];
	CCFiniteTimeAction* fadeThenHideAction = [CCSequence actionOne: fadeAction 
															   two: hideAction];
	fadeThenHideAction.tag = kFadeActionTag;
	[adornmentNode runAction: fadeThenHideAction];
}

@end


#pragma mark CCNodeAdornmentScaler implementation

// A (hopefully) unique tag that identifies the currently activated scaling action.
// This tag is used to cancel the action if needed. 
#define kScaleActionTag 0x5ca1e001


@implementation CCNodeAdornmentScaler

@synthesize activatedScale;

-(id) initToScaleBy: (CGSize) aScale scaleDuration: (ccTime) aDuration {
	if( (self = [super init]) ) {
		self.actionDuration = aDuration;
		activatedScale = aScale;
	}
	return self;
}

+(id) adornmentToScaleBy: (CGSize) aScale scaleDuration: (ccTime) aDuration {
	return [[[self alloc] initToScaleBy: aScale scaleDuration: aDuration] autorelease];
}

-(id) initToScaleBy: (CGSize) aScale {
	return [self initToScaleBy: aScale scaleDuration: kDefaultScalingDuration];
}

+(id) adornmentToScaleBy: (CGSize) aScale {
	return [[[self alloc] initToScaleBy: aScale] autorelease];
}

-(id) initToScaleUniformlyBy: (float) aScale scaleDuration: (ccTime) aDuration {
	return [self initToScaleBy: CGSizeMake(aScale, aScale) scaleDuration: aDuration];
}

+(id) adornmentToScaleUniformlyBy: (float) aScale scaleDuration: (ccTime) aDuration {
	return [[[self alloc] initToScaleUniformlyBy: aScale scaleDuration: aDuration] autorelease];
}

-(id) initToScaleUniformlyBy: (float) aScale {
	return [self initToScaleUniformlyBy: aScale scaleDuration: kDefaultScalingDuration];
}

+(id) adornmentToScaleUniformlyBy: (float) aScale {
	return [[[self alloc] initToScaleUniformlyBy: aScale] autorelease];
}

// Sets the value of originalScale from the current parent.
-(void) setOriginalScaleFromParent {
	CCNode* p = self.parent;
	originalScale = CGSizeMake(p.scaleX, p.scaleY);
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
	float finalScaleX = originalScale.width * activatedScale.width;
	float finalScaleY = originalScale.height * activatedScale.height;
	CCAction* scaleAction = [CCScaleTo actionWithDuration: self.actionDuration
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
	CCAction* scaleAction = [CCScaleTo actionWithDuration: self.actionDuration
												   scaleX: originalScale.width
												   scaleY: originalScale.height];
	scaleAction.tag = kScaleActionTag;
	[p runAction: scaleAction];
}

@end


#pragma mark AdornableMenuItemToggle CCMenuItemToggle extention implementation

@implementation AdornableMenuItemToggle

-(void) dealloc {
	adornment = nil;		// retained as child
	[super dealloc];
}

-(CCNode<CCNodeAdornmentProtocol>*) adornment {
	return adornment;
}

// Add the adornment as a child, removing any previous adornment.
-(void) setAdornment: (CCNode<CCNodeAdornmentProtocol>*) aNode {
	[self removeChild: adornment cleanup: YES];
	adornment = aNode;
	if(aNode) {
		[self addChild: aNode];
	}
}

// When this menu item is selected, activate the adornment
-(void) selected {
	[super selected];
	[adornment activate];
}

// When this menu item is unselected, deactivate the adornment
-(void) unselected {
	[super unselected];
	[adornment deactivate];
}

@end


#pragma mark AdornableMenuItemImage CCMenuItemToggle extention implementation

@implementation AdornableMenuItemImage

-(void) dealloc {
	adornment = nil;		// retained as child
	[super dealloc];
}

-(CCNode<CCNodeAdornmentProtocol>*) adornment {
	return adornment;
}

// Add the adornment as a child, removing any previous adornment.
-(void) setAdornment: (CCNode<CCNodeAdornmentProtocol>*) aNode {
	[self removeChild: adornment cleanup: YES];
	adornment = aNode;
	if(aNode) {
		[self addChild: aNode];
	}
}

// When this menu item is selected, activate the adornment
-(void) selected {
	[super selected];
	[adornment activate];
}

// When this menu item is unselected, deactivate the adornment
-(void) unselected {
	[super unselected];
	[adornment deactivate];
}

@end

