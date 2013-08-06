/*
 * CC3ControllableLayer.h
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
 */

/** @file */	// Doxygen marker

#import "CC3ViewController.h"
#import "CC3OSExtensions.h"
#import "CCLayer.h"


/**
 * A CCLayer that can be controlled by a CC3ViewController to automatically rotate when
 * the device orientation changes, and to permit this layer to be overlaid on the device
 * camera if it exists, permitting "augmented reality" displays.
 */
@interface CC3ControllableLayer : CCLayer {
	CC3ViewController* _controller;
	BOOL _alignContentSizeWithDeviceOrientation : 1;
}


#pragma mark Device orientation support

/**
 * Indicates whether this layer should adjust its content size when the device orientation
 * changes. If this property is set to YES, when the device changes from any portrait
 * orientation to any landscape orientation, this layer will transpose its contentSize. 
 * The overall contentSize area remains the same size, but the axes will be aligned to the
 * new orientation. If this property is set to NO, the contentSize is not adjusted as the
 * device orientation change.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL alignContentSizeWithDeviceOrientation;

/**
 * Called automatically whenever the contentSize of this layer is changed.
 *
 * Default implementation does nothing. Superclasses that care that the content size
 * has changed will override.
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

/** Initializes this instance to be controlled by the specified controller, which may not be nil. */
-(id) initWithController: (CC3ViewController*) controller;

/** 
 * Allocates and initializes an autoreleased instance controlled by the specified controller,
 * which may not be nil. */
+(id) layerWithController: (CC3ViewController*) controller;

/** @deprecated CC3ControllableLayer no longer draws a backdrop. Use init instead. */
-(id) initWithColor: (ccColor4B) color DEPRECATED_ATTRIBUTE;

/** @deprecated CC3ControllableLayer no longer draws a backdrop. Use node instead. */
+(id) layerWithColor: (ccColor4B) color DEPRECATED_ATTRIBUTE;

/** @deprecated CC3ControllableLayer no longer draws a backdrop. Use CC3Scene backdrop property instead. */
@property(nonatomic, readonly) BOOL isColored DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CCNode extension to support controlling nodes from a CC3UIViewController

/** Extension to CCNode to support structural node hierarchies containing controlled nodes. */
@interface CCNode (CC3ControllableLayer)

/**
 * The controller that is controlling this node. This property is available to support delegation from
 * this node. This property is set automatically when this node is attached to the controller, and should
 * not be set by the application directly.
 *
 * In this default implementation, setting the value of this property simply sets the value of the same
 * property in each child CCNode to the same value. Reading the value of this property returns the value
 * of the same property from the parent of this CCNode, or returns nil if this node has no parent.
 */
@property(nonatomic, assign) CC3ViewController* controller;

/**
 * Invoked automatically by a CC3ViewController when the orientation of the view (portrait, landscape,
 * etc) has changed using UIKit autorotation. The CCNode may take action such as transposing its contentSize,
 * or reorganizing its child nodes, to better fit the new screen shape.
 *
 * This default implementation simply invokes the same method on each child CCNode.
 * Subclasses that support the ability to be controlled by a CC3ViewController will override.
 */
-(void) viewDidRotateFrom: (UIInterfaceOrientation) oldOrientation to: (UIInterfaceOrientation) newOrientation;

@end


#pragma mark Deprecated ControllableCCLayer interface

/** @deprecated Replaced with CC3ControllableLayer. */
#define ControllableCCLayer CC3ControllableLayer

