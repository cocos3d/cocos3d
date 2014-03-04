/*
 * CC3ControllableLayer.h
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
 */

/** @file */	// Doxygen marker

#import "CC3ViewController.h"
#import "CC3OSExtensions.h"

#if (CC3_CC2_1 || CC3_CC2_2)
#import "CCLayer.h"
#endif

/**
 * A CCLayer that keeps track of the CC3ViewController that is controlling the CC3GLView,
 * and provides support for overlaying the device camera, and adapting to changes to the
 * device orientation.
 */
@interface CC3ControllableLayer : CCLayer {
	CC3ViewController* _controller;
}


#pragma mark Device orientation support

/**
 * This callback method is invoked automatically whenever the contentSize property of this layer
 * is changed. This method is not invoked if the contentSize property is set to its current value.
 *
 * Default implementation does nothing. Subclasses can override this method to organize child
 * nodes or perspective to the new contentSize.
 *
 * When the device orientation changes, the CC3UIViewController will set the contentSize of
 * the CCNode in its controlledNode property to match the new view size and shape. If the
 * node being controlled is an instance of CC3ControllableLayer, this method will therefore
 * automatically be invoked. Subclasses can use this to adapt to the new size caused by the
 * device orientation change.
 */
-(void) didUpdateContentSizeFrom: (CGSize) oldSize;


#pragma mark Device camera overlay support

/**
 * Indicates whether this layer is currently overlaying the view of the device camera, permitting
 * an augmented reality view. This property is readonly and is retrieved by this node from its
 * controller. If no controller has been assigned, this property will default to NO. When this
 * property is YES, this layer will generally behave in a way that is friendly to a background
 * device camera image. When true, this layer will set its background GL color to transparent,
 * and will not draw a background color or texture.
 */
@property(nonatomic, readonly) BOOL isOverlayingDeviceCamera;


#pragma mark Allocation and initialization

/** Allocates and initializes a layer. */
+(id) layer;


#pragma mark Deprecated functionality

/** 
 * @deprecated CC3ControllableLayer no longer automatically resizes on device orientation. 
 * This property always returns NO, and setting this property has no effect. When the  device
 * is rotated, the contentSize property of the CCNode held in the controlledNode property of the
 * CC3UIViewController is set to match the new orientation. Override didUpdateContentSizeFrom:
 * to react to this change.
 */
@property(nonatomic, assign) BOOL alignContentSizeWithDeviceOrientation DEPRECATED_ATTRIBUTE;

/** @deprecated CC3ControllableLayer no longer draws a backdrop. Use CC3Scene backdrop property instead. */
@property(nonatomic, readonly) BOOL isColored DEPRECATED_ATTRIBUTE;

/** @deprecated Use init instead. */
-(id) initWithColor: (ccColor4B) color DEPRECATED_ATTRIBUTE;

/** @deprecated Use layer instead. */
+(id) layerWithColor: (ccColor4B) color DEPRECATED_ATTRIBUTE;

/** @deprecated Use init instead. The controller property is set automatically when the layer, or an ancestor is assigned to a controller. */
-(id) initWithController: (CC3ViewController*) controller DEPRECATED_ATTRIBUTE;

/** @deprecated Use layer instead. The controller property is set automatically when the layer, or an ancestor is assigned to a controller. */
+(id) layerWithController: (CC3ViewController*) controller DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CCNode extension to support controlling nodes from a CC3UIViewController

/** Extension to CCNode to support structural node hierarchies containing controlled nodes. */
@interface CCNode (CC3ControllableLayer)

/**
 * The controller that is controlling this node. This property is available to support delegation
 * from this node. This property is set automatically when this node is attached to the controller,
 * and should not be set by the application directly.
 *
 * In this default implementation, setting the value of this property simply sets the value of
 * the same property in each child CCNode to the same value. Reading the value of this property
 * returns the value of the same property from the parent of this CCNode, or returns nil if this
 * node has no parent.
 */
@property(nonatomic, assign) CC3ViewController* controller;

/**
 * Invoked automatically by a CC3UIViewController when the orientation of the view (portrait,
 * landscape, etc) has changed using UIKit autorotation.
 *
 * This default implementation simply invokes the same method on each child CCNode.
 * Subclasses that are interested in device changes will override.
 *
 * In addition to invoking this method, the controller will also set the contentSize of the
 * CCNode in its controlledNode property to match the new view size. CCNode sublcasses can
 * override the setContentSize: method to adapt to the new size. In particular, the
 * CC3ControlledNode subclass automatically invokes the didUpdateContentSizeFrom: callback
 * method when its contentSize property is changed.
 */
-(void) viewDidRotateFrom: (UIInterfaceOrientation) oldOrientation to: (UIInterfaceOrientation) newOrientation;

@end


#pragma mark Deprecated ControllableCCLayer interface

/** @deprecated Replaced with CC3ControllableLayer. */
#define ControllableCCLayer CC3ControllableLayer

