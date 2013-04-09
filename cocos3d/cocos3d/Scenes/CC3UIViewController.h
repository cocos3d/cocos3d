/*
 * CC3UIViewController.h
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

#import "CC3IOSExtensions.h"
#import "CC3OSXExtensions.h"
#import "CC3CC2Extensions.h"

#if CC3_IOS

#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

@class CC3AVCameraView;

// The superclass of the CC3UIViewController depends on whether we're using cocos2d 2.x or 1.x
#if CC3_CC2_1
#	define CC3UIVCSuperclass UIViewController
#else
#	define CC3UIVCSuperclass CCDirectorDisplayLink
#endif


#pragma mark -
#pragma mark CC3UIViewController interface

/**
 * An instance of CC3UIViewController manages a single CCNode (typically a CCLayer) as changes
 * occur to the device orientation (portrait, landscape, etc).
 *
 * The loadView method of this controller will automatically create the correct type and configuration of a
 * view suitable for use with cocos3d. You can customize the creation of this view by setting the viewClass,
 * viewBounds, viewColorFormat, viewDepthFormat, viewShouldUseStencilBuffer, and viewPixelSamples properties
 * prior to accessing the view property of this controller for the first time.
 *
 * If the configuration provided by these properties is not sufficient, you can subclass this class and
 * override the loadView method, or you can create the appropriate view directly, and set it into the
 * view property of this controller.
 *
 * You can use the supportedInterfaceOrientations property of this controller to configure auto-rotation
 * of the view as the device orientation changes. Although the supportedInterfaceOrientations method is
 * defined in iOS6, for consistency, this property can also be used in iOS versions below iOS6.
 */
@interface CC3UIViewController : CC3UIVCSuperclass {
	CCNode* _controlledNode;
	Class _viewClass;
	NSString* _viewColorFormat;
	NSUInteger _supportedInterfaceOrientations;
	CGRect _viewBounds;
	GLenum _viewDepthFormat;
	GLuint _viewPixelSamples;
	BOOL _viewWasLaidOut : 1;
	BOOL _shouldUseRetina : 1;
}


#pragma mark View management

/** The view of a CC3UIViewController must be of type CCGLView. */
@property(nonatomic, retain) CCGLView* view;

/**
 * Invoked automatically the first time the view property is requested, and is currently nil.
 *
 * This implementation creates a view of the type indicated by the viewClass property of this instance,
 * with parameters defined by the viewBounds, viewColorFormat, viewDepthFormat, viewShouldUseStencilBuffer,
 * and viewPixelSamples properties of this instance. The view will not preserve the back buffer, and will
 * not be attached to a share group.
 *
 * If your needs cannot be accommodated by configuring the viewBounds, viewColorFormat, viewDepthFormat,
 * viewShouldUseStencilBuffer, and viewPixelSamples properties of this instance, you can either create
 * the view externally and set the view property of this controller, or subclass this controller and
 * override this method to create the appropriate view and set it in the view property.
 */
-(void) loadView;

/**
 * Indicates the class of the view.
 *
 * This property is used by the loadView method as it creates the view, when the view property is first
 * accessed and the view property has not already been established.
 *
 * The initial value of this property is CC3GLView. You can change the value returned by this property
 * prior to accessing the view property for the first time. Once the view property has been established,
 * reading this property returns the class property of the view itself.
 */
@property(nonatomic, assign) Class viewClass;

/**
 * Indicates the bounds of the view.
 *
 * This property is used by the loadView method as it creates the view, when the view property is first
 * accessed and the view property has not already been established.
 *
 * The initial value of this property is the bounds of the UIScreen mainScreen property. You can set
 * this property prior to referencing the view property of this controller in order to have the view
 * created with different bounds.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Once the view property has been established, reading this property returns the bounds property of the
 * view itself. Prior to the view being established, reading this property returns the value to which it
 * has been set. The initial value of this property is the bounds of the UIScreen mainScreen property.
 */
@property(nonatomic, assign) CGRect viewBounds;

/**
 * Indicates the pixel color format of the view.
 *
 * This property is used by the loadView method as it creates the view, when the view property is first
 * accessed and the view property has not already been established.
 *
 * The initial value is kEAGLColorFormatRGBA8. You can set this property prior to referencing the
 * view property of this controller in order to have the view created with a different color format.
 *
 * Valid values for this property are kEAGLColorFormatRGBA8 and kEAGLColorFormatRGB565.
 *
 * The value kEAGLColorFormatRGBA8 is required if models and textures will display transparency
 * or fading. You can set this property to kEAGLColorFormatRGB565 to save display memory if you
 * do not require any transparency or fading.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Once the view property has been established, reading this property returns the pixelFormat property
 * of the view itself. Prior to the view being established, reading this property returns the value to
 * which it has been set. The initial value of this property is kEAGLColorFormatRGBA8.
 */
@property(nonatomic, retain) NSString* viewColorFormat;

/**
 * Indicates the depth format of the view.
 *
 * This property is used by the loadView method as it creates the view, when the view property is first
 * accessed and the view property has not already been established.
 *
 * The initial value is GL_DEPTH_COMPONENT16. You can set this property prior to referencing the
 * view property of this controller in order to have the view created with a different depth format.
 *
 * Valid values for this property are:
 * - GL_DEPTH_COMPONENT16 (or GL_DEPTH_COMPONENT16_OES)
 * - GL_DEPTH_COMPONENT24_OES
 * - GL_DEPTH24_STENCIL8_OES
 * - GL_ZERO
 *
 * GL_DEPTH_COMPONENT16 and GL_DEPTH_COMPONENT16_OES are aliases to each other, and both use
 * 16 bits per pixel to track depth.
 *
 * The value GL_DEPTH_COMPONENT24_OES uses 24 bits per pixel to track depth, and provides higher
 * fidelity in depth testing GL_DEPTH_COMPONENT16 (or GL_DEPTH_COMPONENT16_OES).
 *
 * The value GL_DEPTH24_STENCIL8_OES is required if shadow volumes, or other types of stencilling
 * will be used in your 3D scene.
 *
 * The value GL_ZERO will turn off all depth testing. This is almost never used in a 3D scene.
 *
 * As a convenience, if you require a stencil buffer, consider setting the shouldUseStencilBuffer
 * property instead of setting the value of this property.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Once the view property has been established, reading this property returns the depthFormat property
 * of the view itself. Prior to the view being established, reading this property returns the value to
 * which it has been set.
 *
 * The initial value of this property is GL_DEPTH_COMPONENT16.
 */
@property(nonatomic, assign) GLenum viewDepthFormat;

/**
 * Indicates whether the view should be created with an underlying stencil buffer.
 *
 * This property is linked to the value of the viewDepthFormat property, and is provided as a
 * configuration convenience.
 *
 * Setting this property to YES will set the value of the viewDepthFormat property to GL_DEPTH24_STENCIL8_OES.
 * Setting this property to NO will set the value of the viewDepthFormat property to GL_DEPTH_COMPONENT16.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Reading this property will return YES if the value of the viewDepthFormat property is GL_DEPTH24_STENCIL8_OES,
 * and will return NO otherwise.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL viewShouldUseStencilBuffer;

/**
 * Indicates the number of OpenGL ES rendering samples to be used for each pixel in the view.
 *
 * This property is used by the loadView method as it creates the view, when the view property is first
 * accessed and the view property has not already been established.
 *
 * The initial value is one. You can set this property prior to referencing the view property of this
 * controller in order to have the view created with a different number of samples per pixel. Setting
 * this value to a number larger than one will smooth out the lines and edges of your displayed models.
 *
 * The value set will be clamped to the maximum allowable value for the platform. That maximum value
 * can be retrieved from CC3OpenGL.sharedGL.maxNumberOfPixelSamples, and generally has a value of
 * four on all current devices that support multisampling.
 *
 * Retrieving the value of the CC3OpenGL.sharedGL.maxNumberOfPixelSamples property can only be done
 * once the OpenGL ES context has been established, which is generally performed when the view is
 * created. This creates a bit of a chicken-and-egg situation where you might need the maximum pixel
 * samples value before you create the view, but can't retrieve it until the view has been created.
 * This particular value does not vary much from device to device, so the work-around is to determine
 * the maximum value at development time, and then select a pixel samples value accordingly.
 *
 * Setting the value of this property to zero is the same as setting it to one, and either value will
 * effectively turn multisampling off.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Once the view property has been established, reading this property returns the pixelSamples property
 * of the view itself. Prior to the view being established, reading this property returns the value to
 * which it has been set. The initial value of this property is one.
 *
 * Multisampling is currently incompatible with using the stencil buffer. If the viewShouldUseStencilBuffer
 * property returns YES, the value of this property cannot be set higher than one .
 */
@property(nonatomic, assign) GLuint viewPixelSamples;

/**
 * If running on an iOS device that supports a high-resolution Retina display, enable
 * high-resolution rendering. Returns whether high-resolution rendering has been enabled.
 *
 * This method may be invoked either before or after the view has been loaded or attached.
 */
-(BOOL) enableRetinaDisplay: (BOOL) enable;


#pragma mark Scene management

/**
 * The CCNode that is being controlled by this controller. This is typically an instance of CCLayer.
 *
 * The application should keep this property synchronized with changes in the running scene of the
 * shared CCDirector. The convenience method runSceneOnNode: can be used to automatically handle
 * this coordination.
 *
 * If the view has not yet been added to the view hierarchy, you can either set this property directly,
 * or use the runSceneOnNode: to do so. Once the view has been subsequently added to the view hierarchy,
 * the viewDidAppear: method of this controller will check to see if the CCDirector is running a scene
 * yet, and if not will invoke the  runSceneOnNode: method of this controller with the value of this
 * controlledNode property as the argument.
 *
 * However, once the CCDirector is running a scene, you should invoke the runSceneOnNode: method
 * to change both the running scene, and this controlledNode property together, instead of setting
 * this property directly. If in doubt, use the runSceneOnNode: method instead of this property.
 */
@property(nonatomic, retain) CCNode* controlledNode;

/**
 * This is a convenience method designed to change the displayed cocos2d scene, and keep the CCNode
 * being controlled by this controller (typically an instance of CCLayer) synchronized with the scene
 * being run by the shared CCDirector.
 *
 * This method sets the controlledNode property of this controller to the specified node, wraps the
 * specified node in a CCScene (if it is not already a CCScene), and runs the new scene by invoking
 * either replaceScene: or runWithScene: on the shared CCDirector, depending on whether the director
 * is already running a scene.
 *
 * This method can be invoked either before or after the view associated with this controller has
 * been added to the view hierarchy. If after, the transition to the CCScene corresponding to the
 * specified CCNode will occur immediately. However, if this method is invoked before the view has
 * been added to the view hierarchy, this method has the same effect as setting the controlledNode
 * property directly, and the running of the CCScene corresponding to the specified CCNode will be
 * deferred until the view is added to the view hierarchy, at which point it will be run automatically.
 * This ensures that the view is in place, and the CCScene can derive its corresponding size before
 * an attempt is made to run that CCScene.
 *
 * Consequently, during app startup, when the view has not been loaded and the CCDirector does not
 * yet have a running scene, you can set the controlledNode property directly instead of invoking
 * this method. But once a scene is running, you should use this method to both change the scene,
 * and change the controlledNode property together. When in doubt, use this method instead of
 * setting the controlledNode property directly.
 */
-(void) runSceneOnNode: (CCNode*) aNode;

/**
 * Standard UIViewController callback that is invoked automatically when the view has been laid out.
 *
 * If the CCDirector does not have a running scene, and the controlledNode property of this
 * controller is not nil, the runSceneOnNode: method is automatically invoked, with the
 * controlledNode of this controller as the argument.
 *
 * Subclasses that override this method to perform additional processing on view loading
 * should be sure to invoke this superclass implementation.
 *
 * Although this method was introduced in iOS5, it is invoked automatically from CC3GLView
 * and CC3GLView even when running under iOS4 and below.
 */
-(void) viewDidLayoutSubviews;

/**
 * Reduces cocos2d/3d animation to a minimum.
 *
 * Invoke this method when you want to reliquish CPU to perform some other task, such as displaying
 * UIKit components. To ensure a responsive UI, you should invoke this method just before displaying
 * UIKit components, such as modal or popover controllers. Once the UIKit components have been
 * dismissed, you can use the resumeAnimation method to restore the original animation level.
 *
 * Use the resumeAnimation method to restore the original animation level.
 */
-(void) pauseAnimation;

/**
 * Restores cocos2d/3d animation to its original operating level, after having been temporarily
 * reduced by a prior invocation of the pauseAnimation method.
 */
-(void) resumeAnimation;


#pragma mark Device orientation

/**
 * Returns whether the UI idiom is the iPad.
 *
 * Where different UI behaviour is required between iPad & iPhone idioms, it is recommended that
 * you use UIViewController cluser classes to separate this behaviour. This class-side property
 * can then be used to determine which concrete class to instantiate.
 */
+(BOOL) isPadUI;

/**
 * Returns whether the UI idiom is the iPhone.
 *
 * Where different UI behaviour is required between iPad & iPhone idioms, it is recommended that
 * you use UIViewController cluser classes to separate this behaviour. This class-side property
 * can then be used to determine which concrete class to instantiate.
 */
+(BOOL) isPhoneUI;

/**
 * The user interface orientations allowed by this controller. You set this property to indicate which
 * user interface orientations are supported by this controller.
 *
 * To indicate more than one allowed orientation, the value of this property can be set to a bitwise-OR
 * combination of UIInterfaceOrientationMask values. If the controller supports all orientations, the
 * value of this property can be set to the special value UIInterfaceOrientationMaskAll.
 *
 * The initial value of this property is UIInterfaceOrientationMaskLandscape, indicating that the controller
 * supports both landscape orientations, but neither portrait orientation.
 */
@property(nonatomic, assign) NSUInteger supportedInterfaceOrientations;

/**
 * Indicates whether this controller is overlaying the view of the device camera.
 *
 * This base implementation always returns NO, indicating that the device camera is not being
 * displayed. Subclasses of UIViewController that support device camera overlay can override.
 */
@property(nonatomic, assign, readonly) BOOL isOverlayingDeviceCamera;


#pragma mark Instance initialization and management

/** Allocates and initializes an autoreleased instance. */
+(id) controller;

#if CC3_CC2_2
/** Cast the returned object as id to treat this method as an instance initializer. */
+(id) sharedDirector;
#endif


#pragma mark Deprecated functionality left over from CCNodeController

/** @deprecated Use the supportedInterfaceOrientations property to define the allowed orientations. */
@property(nonatomic, assign) BOOL doesAutoRotate DEPRECATED_ATTRIBUTE;

/** @deprecated Use the supportedInterfaceOrientations property to define the allowed orientations. */
@property(nonatomic, assign) UIDeviceOrientation defaultCCDeviceOrientation DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3DeviceCameraOverlayUIViewController

/**
 * CC3AugmentedRealityUIViewController is a CC3UIViewController that adds the ability to
 * display the 3D scene as an overlay on a background generated by the device camera.
 */
@interface CC3DeviceCameraOverlayUIViewController : CC3UIViewController {
	CC3AVCameraView* _deviceCameraView;
	BOOL _isOverlayingDeviceCamera : 1;
}

/** Indicates whether this device supports a camera. */
@property(nonatomic, readonly) BOOL isDeviceCameraAvailable;

/**
 * Controls whether the controlled CCNode is overlaying the view of the device camera.
 *
 * This property can only be set to YES if a camera is actually available on the device.
 *
 * If the device supports a camera, setting this property to YES will cause the controller
 * to immediately open a view of the device camera and overlay the CCNode view on top of
 * the device camera view.
 *
 * Setting this property to NO will cause the controller to close the device camera
 * (if it was open) and display the CCNode without the camera background.
 *
 * This property should only be set once the view has been added to the window and the
 * window has been keyed and made visible.
 *
 * Displaying the scene overlaying the device camera requires combining two graphic scenes.
 * This is not without a performance cost, and you should expect to see a drop in animation
 * frame rate as a result.
 *
 * Converting back and forth between the device camera overlay and a normal view is not a trivial
 * activity. The simple act of changing this property causes the following sequence of actions:
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
 *   - If this property is being set to YES, the CC3AVCameraView instance in the deviceCameraView
 *     property is added to the window behind the view of this controller. If this property is
 *     being set to NO, the CC3AVCameraView instance is removed from the window.
 *
 *   - This controller is sent a didChangeIsOverlayingDeviceCamera message.
 *
 *   - If the CCNode was running, it is sent an onEnter message to cause it to restart,
 *     be ready for actions, and, in the case of CCLayers, re-register for touch events.
 *     CCNode subclasses can also override onEnter to perform other activities associated
 *     with adjusting their world following the overlay changing (such as hiding or showing
 *     child CCNodes based on whether or not the device camera is now overlayed.
 *
 * The value of this property is initially set to NO.
 */
@property(nonatomic, assign, readwrite) BOOL isOverlayingDeviceCamera;

/**
 * Invoked automatically just before the isOverlayingDeviceCamera property is about to be
 * changed, and before the deviceCameraView has been added to or removed from the window.
 * The isOverlayingDeviceCamera property still has the old value when this call is made.
 * Default does nothing. Subclasses can override
 */
-(void) willChangeIsOverlayingDeviceCamera;

/**
 * Invoked automatically just after the isOverlayingDeviceCamera property has been changed, and after
 * the deviceCameraView has been added to or removed from the window. The isOverlayingDeviceCamera
 * property has the new value when this call is made. Default does nothing. Subclasses can override
 */
-(void) didChangeIsOverlayingDeviceCamera;

/** 
 * Returns the view being used to display the device camera behind the 3D scene, lazily
 * creating if if necessary, or returns nil if the device does not support a camera.
 */
@property(nonatomic, readonly) CC3AVCameraView* deviceCameraView;

@end


#pragma mark -
#pragma mark CC3AVCameraView

/** A UIView that holds a AVCaptureVideoPreviewLayer layer for displaying the device camera feed. */
@interface CC3AVCameraView : UIView

/** The underlying layer cast as a AVCaptureVideoPreviewLayer. */
@property(nonatomic, readonly, retain) AVCaptureVideoPreviewLayer* layer;
@end

#endif // CC3_IOS


#pragma mark -
#pragma mark CCNode extension to support controlling nodes from a CC3UIViewController

/** Extension to CCNode to support structural node hierarchies containing controlled nodes. */
@interface CCNode (CC3UIViewController)

/**
 * The controller that is controlling this node. This property is available to support delegation from
 * this node. This property is set automatically when this node is attached to the controller, and should
 * not be set by the application directly.
 *
 * In this default implementation, setting the value of this property simply sets the value of the same
 * property in each child CCNode to the same value. Reading the value of this property returns the value
 * of the same property from the parent of this CCNode, or returns nil if this node has no parent.
 */
@property(nonatomic, assign) CC3UIViewController* controller;

/**
 * Invoked automatically by a CC3UIViewController when the orientation of the view (portrait, landscape,
 * etc) has changed using UIKit autorotation. The CCNode may take action such as transposing its contentSize,
 * or reorganizing its child nodes, to better fit the new screen shape.
 *
 * This default implementation simply invokes the same method on each child CCNode.
 * Subclasses that support the ability to be controlled by a CC3UIViewController will override.
 */
-(void) viewDidRotateFrom: (UIInterfaceOrientation) oldOrientation to: (UIInterfaceOrientation) newOrientation;

@end


#pragma mark Deprecated CCNodeController interface and ControlledCCNodeProtocol protocol

/** @deprecated Replaced with CC3DeviceCameraOverlayUIViewController. */
#define CCNodeController CC3DeviceCameraOverlayUIViewController

DEPRECATED_ATTRIBUTE
/**
 * Deprecated and unused.
 * @deprecated This protocol is no longer needed, as the methods of this protocol have been
 * added as a category to CCNode.
 */
@protocol ControlledCCNodeProtocol
@end


