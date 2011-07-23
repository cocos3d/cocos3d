/*
 * ControllableCCLayer.h
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010 The Brenwill Workshop Ltd.
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
#import "CCNodeController.h"


/**
 * A CCLayerColor that implements the ControlledCCNodeProtocol protocol, and therefore
 * can be controlled by a CCNodeController to automatically rotate when the device
 * orientation changes, and to permit this layer to be overlaid on the device camera
 * if it exists, permitting "augmented reality" displays
 *
 * This layer is a subclass of CCLayerColor, but may be initialized to behave as either
 * a CCLayerColor or a basic CCLayer, respectively, by using the initWithColor:width:height:
 * method to create a backdrop color and blend, or the basic init method to initialize
 * without a backdrop color or blend.
 *
 * Since layers generally cover the whole screen, the initial value of the
 * alignContentSizeWithDeviceOrientation property is YES, indicating that, by default,
 * this layer will rotate its contentSize as the device orientation changes between
 * portrait and landscape.
 *
 * When overlaying the device camera, this layer will use a transparent GL clear color
 * and will not draw any backdrop color blend. When not overlaying the device camera,
 * this layer will use opaque black as the GL clear color, and will draw a backdrop color
 * blend if it has been configured with one.
 */
@interface ControllableCCLayer : CCLayerColor<ControlledCCNodeProtocol> {
	CCNodeController* controller;
	CGSize homeContentSize;
	BOOL isColored;
	BOOL alignContentSizeWithDeviceOrientation;
}

/**
 * Template method that is called automatically during initialization, regardless of the actual
 * init* method that was invoked. Subclasses can override to setup their own initial state
 * without having to override all of the possible superclass init methods, but must call this
 * superclass implementation first. This method cannot be used in place of the standard init*
 * methods, and should not be invoked directly.
 */
-(void) initInitialState;


#pragma mark Device orientation support

/**
 * Indicates whether or not a background color and blend have been specified and will be drawn
 * as a backdrop to this layer. The value of this property is set during initialization.
 *
 * This class subclasses from CCLayerColor, and an instance may be initialized to draw
 * a backdrop color using the initWithColor:width:height: initialization method, in which
 * case the value of this property will be YES. Alternately, an instance may be initialized
 * without a backdrop color using the basic init initialization method init, in which case
 * the value of this property will be NO.
 */
@property(nonatomic, readonly) BOOL isColored;

/**
 * The content size of the layer when it is in its home orientation (kCCDeviceOrientationPortrait).
 * This therefore gives the dimensions of the CCLayer before it is rotated and sized to fit
 * the current device orientation.
 */
@property(nonatomic, readonly) CGSize homeContentSize;

/**
 * Indicates whether this CCLayer should adjust the content size when the device orientation
 * changes. If this property is set to YES, when the device changes from any portrait
 * orientation to any landscape orientation, the CCNode will transpose its contentSize.
 * The overall contentSize area remains the same size, but the axes will be aligned to the
 * new orientation. If this property is set to NO, the contentSize is not adjusted as the
 * device orientation change. The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL alignContentSizeWithDeviceOrientation;

/**
 * Called automatically whenever the contentSize of this layer is changed. Default implementation
 * updates the homeContentSize to either the new contentSize, or its transpose, depending on
 * whether the device is in portrait or landscape mode, respectively. Subclasses can override
 * to perform other operations, but should be sure to call the superclass implementation first.
 */
-(void) didUpdateContentSizeFrom: (CGSize) oldSize;

/**
 * Called automatically whenever the homeContentSize of this layer is changed.
 * Default implementation does nothing. Subclasses can override to perform other
 * operations, but should be sure to call the superclass implementation first.
 */
-(void) didUpdateHomeContentSizeFrom: (CGSize) oldHomeSize;


#pragma mark Device camera overlay support

/**
 * Indicates whether this layer is currently overlaying the view of the device camera,
 * permitting an augmented reality view. This property is readonly and is retrieved by this
 * node from its controller. If no controller has been assigned, this property will default
 * to NO. When this property is true, this this layer will generally behave in a way that
 * is friendly to a background device camera image. When true, this layer will set its 
 * background GL color to transparent, and will not draw a background color or texture.
 */
@property(nonatomic, readonly) BOOL isOverlayingDeviceCamera;

/**
 * Called automatically when this layer is first displayed, and subsequently whenever the layer
 * is overlayed on the camera, or reverted back to a normal display. This method is called just
 * before the backdrop is changed. Default is to perform the standard CCLayer onExit behaviour.
 * Subclasses may override to perform other functions. Subclasses that do override should call
 * this superclass implementation first, before performing any customized activities.
 */
-(void) onExit;

/**
 * Called automatically when this layer is first displayed, and subsequently whenever the layer
 * is overlayed on the camera, or reverted back to a normal display. This method is called just
 * after the backdrop is changed. Default is to perform the standard CCLayer onEnter behaviour.
 * Subclasses may override to perform other functions such as updating user interface controls
 * or hiding or displaying visible elements that depend on whether or not the backgrop display
 * is coming from the device camera or not. For example, when the backdrop is not the device
 * camera, the application may choose to diplay a background color, image, or skybox.
 * Subclasses that override should call this superclass implementation first, before performing
 * any customized activities.
 */
-(void) onEnter;


@end
