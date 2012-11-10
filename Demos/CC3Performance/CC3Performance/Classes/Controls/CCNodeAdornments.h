/*
 * CCNodeAdornments.h
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
 */

/** @file */	// Doxygen marker

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/**
 * Constants that can be used to set the Z-Order of an adornment
 * to place it under or over the base node.
 */
#define kAdornmentOverZOrder 10
#define kAdornmentUnderZOrder -10


#pragma mark CCNodeAdornmentProtocol declaration

/**
 * Adornments are CCNodes that support the CCNodeAdornmentProtocol, and can be added to other
 * CCNodes that support the AdornableCCNodeProtocol protocol in order to add transient visual
 * characteristics to the adorned CCNode. Examples of adornments might be a shine, a surrounding
 * ring, an overlay label, or an action that scales, rotates, or otherwise temporarily changes
 * the adorned CCNode.
 */
@protocol CCNodeAdornmentProtocol

/**
 * Activates this adornment. Typically this will trigger a CCAction to animate the
 * appearance of the adornment over the base CCNode, or will alter the base node in some way.
 */
-(void) activate;

/**
 * Deactivates this adornment. Typically this will trigger a CCAction to animate the
 * reversion to the unadorned base CCNode.
 */
-(void) deactivate;

@end


#pragma mark AdornableCCNodeProtocol declaration

/**
 * Describes the behaviour required for CCNodes that can be adorned with an adornment.
 * Adornments are themselves CCNodes that support the CCNodeAdornmentProtocol protocol,
 * and typical implementations of AdornableCCNodeProtocol will add the adornment as
 * a child. Concrete implementations of AdornableCCNodeProtocol will be subclassed from
 * a specific subclass of CCNode (eg: CCLayer, CCMenuItem, etc).
 */
@protocol AdornableCCNodeProtocol

/** The adornment CCNode that is attached to this CCNode. */
@property(nonatomic, retain) CCNode<CCNodeAdornmentProtocol>* adornment;

@end


#pragma mark CCNodeAdornmentBase interface

/**
 * A base implementation of the CCNodeAdornmentProtocol as a CCNode extension.
 * This base class can be used to create concrete adornment subclasses.
 * Initial zOrder is set to kAdornmentOverZOrder. This places the adornment above the
 * content of the adorned node (which may have other children aside from the adornment).
 * The implementation of activate and deactivate in this abstract class do nothing.
 */
@interface CCNodeAdornmentBase : CCNode<CCNodeAdornmentProtocol> {
	ccTime actionDuration;
}

/**
 * Overridden to expose the zOrder property to be assignable for CCNodeAdornments.
 * Setting zOrder in an adornment before adding it to the base CCNode allows the
 * adornment to be placed either over or under the base CCNode and its other children.
 * Initial value is kAdornmentOverZOrder, which places the adornment above the content
 * of the adorned CCNode.
 */
@property(nonatomic, assign) int zOrder;

/**
 * Most adornments will invoke a CCActionInterval when activated and deactivated in
 * order to animate the display or reversion of the adornment. The duration of these
 * actions is controlled by the value of this property.
 */
@property(nonatomic, assign) ccTime actionDuration;

/** Initializes this instance with a value of zero for the actionDuration property. */
-(id) init;

/**
 * Allocates and initializes an autoreleased instance with a value of zero
 * for the actionDuration property.
 */
+(id) adornment;

/** Initializes this instance with the specified value for the actionDuration property. */
-(id) initWithActionDuration: (ccTime) aDuration;

/**
 * Allocates and initializes an autoreleased instance with the specified value
 * for the actionDuration property.
 */
+(id) adornmentWithActionDuration: (ccTime) aDuration;


@end


#pragma mark CCNodeAdornmentOverlayFader interface

/** The default duration of the fade-in and fade-out actions of the CCNodeAdornmentOverlayFader */
#define kDefaultFadeDuration 0.25

// The numberic opacity value associated with full opacity.
#define kFullOpacity 255


/**
 * An adornment CCNode that wraps a separate visible child CCNode, and implements the
 * CCNodeAdornmentProtocol such that, when activated, will fade the visible child CCNode
 * in over the adorned CCNode, and, when deactivated, will fade that child CCNode out to
 * make it invisible again. It is the child CCNode that defines what the actual adornment
 * will look like. That child may be any CCNode.
 */
@interface CCNodeAdornmentOverlayFader : CCNodeAdornmentBase {
	CCNode<CCRGBAProtocol>* adornmentNode;
	GLubyte peakOpacity;
}

/**
 * The visible CCNode to be displayed as the visual child adornment.
 * Typically this will be a CCSprite, but may be any CCNode.
 */
@property(nonatomic, readonly) CCNode<CCRGBAProtocol>* adornmentNode;

/**
 * When activated, this CCNodeAdornmentOverlayFader instance will fade the adornmentNode
 * in from zero opacity to the value of this peakOpacity property, and when deactivated,
 * will fade the adornmentNode back to zero opacity.
 *
 * This value defaults to kFullOpacity, indicating that the adornmentNode should fade
 * in from fully transparent to fully opaque. Setting this property to a lower value
 * will allow the base CCNode to remain partially visible, making the adornmentNode
 * appear as a "shine" over the base CCNode.
 */
@property(nonatomic, assign) GLubyte peakOpacity;

/**
 * Initializes this instance to use the specified CCNode as the visual adornmentNode and,
 * when activated, to fade the adornmentNode in from fully transparent up to the specified
 * opacity, over the specified duration.
 */
-(id) initWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity fadeDuration: (ccTime) aDuration;

/**
 * Allocates and initializes an autoreleased instance to use the specified CCNode
 * as the visual adornmentNode and, when activated, to fade the adornmentNode in
 * from fully transparent up to the specified opacity, over the specified duration.
 */
+(id) adornmentWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity fadeDuration: (ccTime) aDuration;

/**
 * Initializes this instance to use the specified CCNode as the visual adornmentNode and,
 * when activated, to fade the adornmentNode in from fully transparent up to the specified
 * opacity. The fade duration will default to kDefaultFadeDuration.
 */
-(id) initWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity;

/**
 * Allocates and initializes an autoreleased instance to use the specified CCNode as the
 * visual adornmentNode and, when activated, to fade the adornmentNode in from fully
 * transparent up to the specified opacity. The fade duration will default to kDefaultFadeDuration.
 */
+(id) adornmentWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode peakOpacity: (GLubyte) opacity;

/**
 * Initializes this instance to use the specified CCNode as the visual adornmentNode and,
 * when activated, to fade the adornmentNode in from fully transparent to fully opaque.
 * The fade duration will default to kDefaultFadeDuration.
 */
-(id) initWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode;

/**
 * Allocates and initializes an autoreleased instance to use the specified CCNode as the
 * visual adornmentNode and, when activated, to fade the adornmentNode in from fully
 * transparent fully opaque. The fade duration will default to kDefaultFadeDuration.
 */
+(id) adornmentWithAdornmentNode: (CCNode<CCRGBAProtocol>*) aNode;

@end


#pragma mark CCNodeAdornmentScaler interface

/** The default duration of the scaling up and down actions of the CCNodeAdornmentScaler */
#define kDefaultScalingDuration 0.25

/**
 * An adornment CCNode that implements the CCNodeAdornmentProtocol such that, when activated,
 * will scale the adorned CCNode (the parent of this adornment), making it appear either
 * larger or smaller and, when deactivated, will return the adorned CCNode to its original scale.
 */
@interface CCNodeAdornmentScaler : CCNodeAdornmentBase {
	CGSize activatedScale;
	CGSize originalScale;
}

/**
 * When activated, this CCNodeAdornmentScaler instance will scale the adorned CCNode by this
 * scaling factor. This scaling is applied on top of any scaling applied to the adorned CCNode
 * at the time this adornment is activated. For example, if the adorned CCNode is already scaled
 * by a factor of two and this activatedScale property is set to a value of three, then the final
 * scale of the adorned CCNode when the adornment is activated will be six. If needed, different
 * scaling values can be set for the width and height to cause non-uniform scaling.
 */
@property(nonatomic, assign) CGSize activatedScale;

/**
 * Initializes this instance to scale the adorned CCNode by the specified factor over
 * the specified duration. The width and height scaling components may be set to
 * different values to cause non-uniform scaling.
 */
-(id) initToScaleBy: (CGSize) aScale scaleDuration: (ccTime) aDuration;

/**
 * Allocates and initializes an autoreleased instance to scale the adorned CCNode by
 * the specified factor over the specified duration. The width and height scaling
 * components may be set to different values to cause non-uniform scaling.
 */
+(id) adornmentToScaleBy: (CGSize) aScale scaleDuration: (ccTime) aDuration;

/**
 * Initializes this instance to scale the adorned CCNode by the specified factor.
 * The duration of this scaling will default to kDefaultScalingDuration. The width and
 * height scaling components may be set to different values to cause non-uniform scaling.
 */
-(id) initToScaleBy: (CGSize) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the adorned CCNode by the
 * specified factor. The duration of this scaling will default to kDefaultScalingDuration.
 * The width and height scaling components may be set to different values to cause
 * non-uniform scaling.
 */
+(id) adornmentToScaleBy: (CGSize) aScale;

/**
 * Initializes this instance to scale the adorned CCNode by the specified factor over
 * the specified duration. Scaling will be uniform in both width and height.
 */
-(id) initToScaleUniformlyBy: (float) aScale scaleDuration: (ccTime) aDuration;

/**
 * Allocates and initializes an autoreleased instance to scale the adorned CCNode by
 * the specified factor over the specified duration. Scaling will be uniform in both
 * width and height.
 */
+(id) adornmentToScaleUniformlyBy: (float) aScale scaleDuration: (ccTime) aDuration;

/**
 * Initializes this instance to scale the adorned CCNode by the specified factor.
 * The duration of this scaling will default to kDefaultScalingDuration.
 * Scaling will be uniform in both width and height.
 */
-(id) initToScaleUniformlyBy: (float) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the adorned CCNode by the
 * specified factor. The duration of this scaling will default to kDefaultScalingDuration.
 * Scaling will be uniform in both width and height.
 */
+(id) adornmentToScaleUniformlyBy: (float) aScale;

@end


#pragma mark AdornableMenuItemToggle CCMenuItemToggle extention interface

/**
 * A concrete subclass of CCMenuItemToggle that supports a visual adornment via the 
 * AdornableCCNodeProtocol. When the menu item is selected by the user, the adornment will be
 * activated, and when the item is deselected by the user, the adornment will be deactivated.
 */
@interface AdornableMenuItemToggle : CCMenuItemToggle<AdornableCCNodeProtocol> {
	CCNode<CCNodeAdornmentProtocol>* adornment;
}

@end


#pragma mark AdornableMenuItemImage CCMenuItemImage extention interface

/**
 * A concrete subclass of CCMenuItemImage that supports a visual adornment via the
 * AdornableCCNodeProtocol. When the menu item is selected by the user, the adornment will be
 * activated, and when the item is deselected by the user, the adornment will be deactivated.
 */
@interface AdornableMenuItemImage : CCMenuItemImage<AdornableCCNodeProtocol> {
	CCNode<CCNodeAdornmentProtocol>* adornment;
}

@end



