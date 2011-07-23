/*
 * CCNodeController.h
 *
 * cocos3d 0.6.0-sp
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
 */

/** @file */	// Doxygen marker

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#pragma mark ControlledCCNodeProtocol protocol

@class CCNodeController;	// let the protocol know in advance about the CCNodeController

/**
 * This protocol adds to a CCNode the ability to be managed by a CCNodeController
 * so that the CCNode can react dynamically to changes in the device orientation
 * (portrait, landscape, etc), as well as to allow the CCNode to act as an overlay
 * for the device camera, permitting "augmented reality" displays.
 */
@protocol ControlledCCNodeProtocol

/**
 * The controller that is controlling this node. This property is available to support
 * delegation from this node. This property is set automatically when this node is
 * attached to the controller, and should not be set by the application directly.
 */
@property(nonatomic, assign) CCNodeController* controller;

/**
 * Called automatically by the controller when the orientation of the device (portrait,
 * landscape, etc) has changed. The CCNode may take action such as transposing its
 * contentSize, or reorganizing its child nodes, to better fit the new screen shape.
 */
-(void) deviceOrientationDidChange: (ccDeviceOrientation) newOrientation;

@end


#pragma mark CCNode interface category for controlled node support

/** Methods added to the base CCNode to support structural node hierarchies containing controlled nodes. */
@interface CCNode (ControlledCCNodeProtocol)

/**
 * Called automatically on the child node of a controlled node to propagate the notification of
 * the change in device orientation. By adding this to the base CCNode, it allows the parent
 * controlled node to propagate to all its children without regard to type, and allows other
 * controlled nodes to be buried in a structural node hierarchy. This base implementation simply
 * propagates the notification to its children. Actual controlled node subclasses will override.
 * @since v1.1
 */
-(void) deviceOrientationDidChange: (ccDeviceOrientation) newOrientation;

@end


#pragma mark CCNodeController interface

/**
 * An instance of CCNodeController manages a single CCNode (typically a CCLayer) as
 * changes occur to the device orientation (portrait, landscape, etc). The controller
 * can also overlay both the CCNode and the underlying EAGLView on top of the view
 * of the device camera, providing an "augmented reality" display.
 */
@interface CCNodeController : UIViewController {
	CCNode<ControlledCCNodeProtocol>* controlledNode;
	UIImagePickerController* picker;
	BOOL isOverlayingDeviceCamera;
	BOOL doesAutoRotate;
	ccDeviceOrientation defaultCCDeviceOrientation;
}


#pragma mark Node control

/**
 * The CCNode that is being controlled by this controller. The application should keep
 * this property synchronized with changes in the running scene of the shared CCDirector.
 * The convenience method runSceneOnNode: can be used to enforce this.
 */
@property(nonatomic, retain) CCNode<ControlledCCNodeProtocol>* controlledNode;

/**
 * This is a convenience method designed to keep the CCNode<ControlledCCNodeProtocol> being
 * controlled by this controller synchronized with the scene being run by the shared CCDirector.
 * This method changes the CCNode<ControlledCCNodeProtocol> under control to the specified node,
 * then wraps that node in a CCScene and causes that scene to be run by the shared CCDirector by
 * calling either replaceScene: on the shared CCDirector if it is already running a scene, or
 * runWithScene: on the shared CCDirector if it is not already running a scene.
 */
-(void) runSceneOnNode: (CCNode<ControlledCCNodeProtocol>*) aNode;


#pragma mark Device orientation support

/**
 * Indicates whether the controller should automatically rotate the rendering of the CCNode
 * as the device orientation changes. The value of this property is initially set to NO.
 *
 * If this property is set to YES, this controller will listen for notifications of device
 * orientation change, and propagate those changes to the cocos2d framework and the controlled
 * CCNode<ControlledCCNodeProtocol>'s through its deviceOrientationDidChange: method.
 *
 * If this property is set to NO, the application may still change the orientation of the CCNode
 * when needed (eg- upon user control) by manually calling the CCNode<ControlledCCNodeProtocol>'s
 * deviceOrientationDidChange: method.
 */
@property(nonatomic, assign) BOOL doesAutoRotate;

/**
 * Within cocos2d, not all UIDeviceOrientation enumerations are mapped to ccDeviceOrientations.
 * When the device is in a UIDeviceOrientation that is not mapped to a ccDeviceOrientation,
 * (typically UIDeviceOrientationFaceDown or UIDeviceOrientationFaceUp), the controller will
 * orient the CCNode to this defaultCCDeviceOrientation.
 * The value of this property is initially set to kCCDeviceOrientationLandscapeLeft.
 */
@property(nonatomic, assign) ccDeviceOrientation defaultCCDeviceOrientation;

/**
 * Called automatically when the orientation of the device (portrait, landscape, etc)
 * has changed. Propagates the change in orientation into the cocos2d framework.
 *
 * The current UIDeviceOrientation is mapped to a corresponding ccDeviceOrientation.
 * The new ccDeviceOrientation is set in the CCDirector singleton and the CCNode is sent
 * a deviceOrientationDidChange: message.
 *
 * Subclasses may override to add further behaviour, and then call this superclass
 * implementation to have ccocos2D made aware of the change.
 */
-(void) deviceOrientationDidChange: (NSNotification *)notification;


#pragma mark Device camera support

/** Indicates whether this device supports a camera. */
@property(nonatomic, readonly) BOOL isDeviceCameraAvailable;

/**
 * Controls whether the controlled CCNode is overlaying the view of the device camera.
 * The value of this property is initially set to NO.
 * This property can only be set to YES if a camera is actually available on the device.
 *
 * If the device supports a camera, setting this property to YES will cause the controller
 * to immediately open a view of the device camera and overlay the CCNode view on top of
 * the device camera view. 
 * 
 * Setting this property to NO will cause the controller to close the device camera
 * (if it was open) and display the CCNode without the camera background.
 *
 * Converting back and forth between the device camera overlay and a normal view is not
 * a trivial activity. The simple act of changing this property causes the following
 * sequence of actions:
 *
 *   - If the CCNode is currently running, it is sent an onExit message to cause it to
 *     stop running, clean up any active actions, and reset its touch event handling.
 *     CCNode subclasses can also override onExit to perform other activities associated
 *     with cleaning up prior to the overlay changing.
 *
 *   - This controller is sent a willChangeIsOverlayingDeviceCamera message.
 *
 *   - The isOverlayingDeviceCamera property of this controller is changed.
 *
 *   - If the isOverlayingDeviceCamera property is being set to YES, the picker
 *     UIImagePickerController is presented modally. If the isOverlayingDeviceCamera
 *     property is being set to NO, the modal picker UIImagePickerController is dismissed.
 *
 *   - This controller is sent a didChangeIsOverlayingDeviceCamera message.
 *
 *   - If the CCNode was running, it is sent an onEnter message to cause it to restart,
 *     be ready for actions, and, in the case of CCLayers, re-register for touch events.
 *     CCNode subclasses can also override onEnter to perform other activities associated
 *     with adjusting their world following the overlay changing (such as hiding or showing
 *     child CCNodes based on whether or not the device camera is now overlayed.
 */
@property(nonatomic, assign) BOOL isOverlayingDeviceCamera;

/**
 * Called automatically just before the isOverlayingDeviceCamera property is about
 * to be changed, and before the picker has been modally presented or dismissed.
 * The isOverlayingDeviceCamera property still has the old value when this call is made.
 * Default does nothing. Subclasses can override
 */
-(void) willChangeIsOverlayingDeviceCamera;

/**
 * Called automatically just after the isOverlayingDeviceCamera property has been
 * changed, and after the picker has been modally presented or dismissed.
 * The isOverlayingDeviceCamera property has the new value when this call is made.
 * Default does nothing. Subclasses can override
 */
-(void) didChangeIsOverlayingDeviceCamera;

/**
 * The UIImagePickerController instance that this controller uses to overlay the
 * CCNode on the device camera image. This property will always return nil if
 * the device does not support a camera.
 */
@property(nonatomic, readonly) UIImagePickerController* picker;

/**
 * If the device supports a camera, returns a newly allocated and initialized
 * UIImagePickerController, suitable for use in overlaying the EAGLView underlying the CCNode
 * on top of the device camera image. Returns nil if the device does not suport a camera.
 * It is the responsibility of the caller to manage the releasing of the returned picker.
 *
 * This method is automatically called when the picker property is first accessed.
 * It should not be called directly otherwise. Subclasses can override this method
 * to modify the characteristics of the returned picker.
 */
-(UIImagePickerController*) newDeviceCameraPicker;


#pragma mark Instance initialization and management

/** Allocates and initializes an autoreleased instance. */
+(id) controller;

	
@end
