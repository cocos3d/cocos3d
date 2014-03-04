/*
 * CC3UIViewController.h
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
#import "CC3CC2Extensions.h"

#if CC3_IOS

#pragma mark -
#pragma mark CC3UIViewController interface

/**
 * CC3UIViewController extends CC3ViewController to provide functionality specific to iOS.
 *
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
@interface CC3UIViewController : CC3ViewController {
	Class _viewClass;
	NSString* _viewColorFormat;
	NSUInteger _supportedInterfaceOrientations;
	CGRect _viewBounds;
	GLenum _viewDepthFormat;
	GLuint _viewPixelSamples;
	BOOL _shouldUseRetina : 1;
}


#pragma mark View management

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
@property(nonatomic, retain) Class viewClass;

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
 * This property is used by the loadView method as it creates the view, when the view property
 * is first accessed and the view property has not already been established.
 *
 * The initial value is GL_DEPTH_COMPONENT16. You can set this property prior to referencing the
 * view property of this controller in order to have the view created with a different depth format.
 *
 * Valid values for this property are:
 * - GL_DEPTH_COMPONENT16	(or GL_DEPTH_COMPONENT16_OES)
 * - GL_DEPTH_COMPONENT24	(or GL_DEPTH_COMPONENT24_OES)
 * - GL_DEPTH24_STENCIL8	(or GL_DEPTH24_STENCIL8_OES)
 * - GL_ZERO
 *
 * In the list above, the OES extension is optional.
 *
 * The value GL_DEPTH_COMPONENT24 uses 24 bits per pixel to track depth, and provides higher
 * fidelity in depth testing GL_DEPTH_COMPONENT16.
 *
 * The value GL_DEPTH24_STENCIL8 is required if shadow volumes, or other types of stencilling
 * will be used in your 3D scene.
 *
 * The value GL_ZERO will turn off all depth testing. This is almost never used in a 3D scene.
 *
 * As a convenience, if you require a stencil buffer, consider setting the shouldUseStencilBuffer
 * property instead of setting the value of this property.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Once the view property has been established, reading this property returns the depthFormat 
 * property of the view itself. Prior to the view being established, reading this property
 * returns the value to which it has been set.
 *
 * The initial value of this property is GL_DEPTH_COMPONENT16.
 */
@property(nonatomic, assign) GLenum viewDepthFormat;

/**
 * Indicates whether the view should be created with an underlying stencil buffer.
 *
 * This property is linked to the value of the viewDepthFormat property, and is provided
 * as a configuration convenience.
 *
 * Setting this property to YES will set the value of the viewDepthFormat property to 
 * GL_DEPTH24_STENCIL8. Setting this property to NO will set the value of the 
 * viewDepthFormat property to GL_DEPTH_COMPONENT16.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Reading this property will return YES if the value of the viewDepthFormat property
 * is GL_DEPTH24_STENCIL8, and will return NO otherwise.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL viewShouldUseStencilBuffer;

/**
 * Indicates the number of OpenGL ES rendering samples to be used for each pixel in the view.
 *
 * This property is used by the loadView method as it creates the view, when the view property
 * is first accessed and the view property has not already been established.
 *
 * The initial value is one. You can set this property prior to referencing the view property
 * of this controller in order to have the view created with a different number of samples
 * per pixel. Setting this value to a number larger than one will smooth out the lines and 
 * edges of your displayed models.
 *
 * The value set will be clamped to the maximum allowable value for the platform. That maximum
 * value can be retrieved from CC3OpenGL.sharedGL.maxNumberOfPixelSamples, and generally has a
 * value of 4 on all current devices that support multisampling.
 *
 * Retrieving the value of the CC3OpenGL.sharedGL.maxNumberOfPixelSamples property can only be
 * done once the OpenGL ES context has been established, which is generally performed when the
 * view is created. This creates a bit of a chicken-and-egg situation where you might need the
 * maximum pixel samples value before you create the view, but can't retrieve it until the view
 * has been created. This particular value does not vary much from device to device, so the 
 * work-around is to determine the maximum value at development time, and then select a pixel
 * samples value accordingly.
 *
 * Setting the value of this property to zero is the same as setting it to one, and either
 * value will effectively turn multisampling off.
 *
 * To have effect, this property must be set before the view property is first accessed.
 *
 * Once the view property has been established, reading this property returns the pixelSamples
 * property of the view itself. Prior to the view being established, reading this property
 * returns the value to which it has been set. The initial value of this property is one.
 */
@property(nonatomic, assign) GLuint viewPixelSamples;

/**
 * If running on an iOS device that supports a high-resolution Retina display, enable
 * high-resolution rendering. Returns whether high-resolution rendering has been enabled.
 *
 * This method may be invoked either before or after the view has been loaded or attached.
 */
-(BOOL) enableRetinaDisplay: (BOOL) enable;


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


#pragma mark Instance initialization and management

/** Allocates and initializes an autoreleased instance. */
+(id) controller;

#if CC3_CC2_2
/** Cast the returned object as id to treat this method as an instance initializer. */
+(id) sharedDirector;
#endif


#pragma mark Deprecated functionality

/** @deprecated Use the supportedInterfaceOrientations property to define the allowed orientations. */
@property(nonatomic, assign) BOOL doesAutoRotate DEPRECATED_ATTRIBUTE;

/** @deprecated Use the supportedInterfaceOrientations property to define the allowed orientations. */
@property(nonatomic, assign) UIDeviceOrientation defaultCCDeviceOrientation DEPRECATED_ATTRIBUTE;

/** @deprecated Set superclass controlledNode property and run layer in CCScene on CCDirector instead. */
-(void) runSceneOnNode: (CCNode*) aNode DEPRECATED_ATTRIBUTE;

@end

#endif // CC3_IOS


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


