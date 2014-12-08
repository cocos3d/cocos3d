/*
 * CC3PerformanceAppDelegate.m
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
 * See header file CC3PerformanceAppDelegate.h for full API documentation.
 */

#import "CC3PerformanceAppDelegate.h"
#import "CC3PerformanceLayer.h"


#define kAnimationFrameRate		60		// Animation frame rate

#if CC3_CC2_RENDER_QUEUE	//================================================================

/** App Delegate for Cocos2D v3 and above. */
@implementation CC3PerformanceAppDelegate

// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
// This method is a good place to add one time setup code that only runs when your app is first launched.
-(BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions {
	
	// Setup Cocos2D with reasonable defaults for everything.
	// With Cocos3D, you MUST include CCSetupDepthFormat as GL_DEPTH_COMPONENT16 or GL_DEPTH_COMPONENT24
	// if you don't need shadow volumes, or GL_DEPTH24_STENCIL8 if you want to use shadow volumes.
	// See CCAppDelegate.h for more options.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:
	 @{
	   CCSetupDepthFormat: @GL_DEPTH_COMPONENT16,				// 3D rendering requires a depth buffer
	   CCSetupShowDebugStats: @(YES),							// Show the FPS and draw call label.
	   CCSetupAnimationInterval: @(1.0 / kAnimationFrameRate),	// Framerate (defaults to 60 FPS).
	   CCSetupScreenOrientation: CCScreenOrientationAll,		// Support all device orientations dyanamically
//	   CCSetupMultiSampling: @(YES),							// Use multisampling on the main view
//	   CCSetupNumberOfSamples: @(4),							// Number of samples to use per pixel (max 4)
	   }];
	
	return YES;
}

/** Returns the initial 2D CCScene. Our 2D scene contains a CC3Layer holding a 3D CC3Scene. */
-(CCScene*) startScene {
	
	// Create the customized CC3Layer that supports 3D rendering,
	// wrap the layer in a 2D scene and return the 2D scene.
	return [[CC3PerformanceLayer layer] asCCScene];
}

@end


#else	//================================================================================


/** App Delegate for Cocos2D below v3. */
@implementation CC3PerformanceAppDelegate

#if !CC3_CC2_1
/**
 * In Cocos2D 2.x, the view controller and CCDirector are one and the same, and we create the
 * controller using the singleton mechanism. To establish the correct CCDirector/UIViewController
 * class, this MUST be performed before any other references to the CCDirector singleton!!
 *
 * NOTE: As of iOS6, supported device orientations are an intersection of the mask established for the
 * UIViewController (as set in this method here), and the values specified in the project 'Info.plist'
 * file, under the 'Supported interface orientations' and 'Supported interface orientations (iPad)'
 * keys. Specifically, although the mask here is set to UIInterfaceOrientationMaskAll, to ensure that
 * all orienatations are enabled under iOS6, be sure that those settings in the 'Info.plist' file also
 * reflect all four orientation values. By default, the 'Info.plist' settings only enable the two
 * landscape orientations. These settings can also be set on the Summary page of your project.
 */
-(void) establishDirectorController {
	_viewController = CC3DeviceCameraOverlayUIViewController.sharedDirector;
	_viewController.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
	_viewController.viewShouldUseStencilBuffer = NO;	// No shadow volumes in this app
	_viewController.viewPixelSamples = 1;				// Set to 4 for antialiasing multisampling
	_viewController.animationInterval = (1.0f / kAnimationFrameRate);
	_viewController.displayStats = YES;
	[_viewController enableRetinaDisplay: YES];
}

#else

/**
 * In Cocos2D 1.x, the view controller and CCDirector are different objects.
 *
 * NOTE: As of iOS6, supported device orientations are an intersection of the mask established for the
 * UIViewController (as set in this method here), and the values specified in the project 'Info.plist'
 * file, under the 'Supported interface orientations' and 'Supported interface orientations (iPad)'
 * keys. Specifically, although the mask here is set to UIInterfaceOrientationMaskAll, to ensure that
 * all orienatations are enabled under iOS6, be sure that those settings in the 'Info.plist' file also
 * reflect all four orientation values. By default, the 'Info.plist' settings only enable the two
 * landscape orientations. These settings can also be set on the Summary page of your project.
 */
-(void) establishDirectorController {
	
	// Use CADisplayLink director for better animation.
	CCDirector.directorType = kCCDirectorTypeDisplayLink;
	
	// Create the view controller for the 3D view.
	_viewController = [CC3DeviceCameraOverlayUIViewController new];
	_viewController.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
	_viewController.viewShouldUseStencilBuffer = YES;	// Shadow volumes make use of stencil buffer
	_viewController.viewPixelSamples = 1;				// Set to 4 for antialiasing multisampling
	
	// Create the CCDirector, set the frame rate, and attach the view.
	CCDirector *director = CCDirector.sharedDirector;
	director.runLoopCommon = YES;		// Improves display link integration with UIKit
	director.animationInterval = (1.0f / kAnimationFrameRate);
	director.displayFPS = YES;
	director.openGLView = _viewController.view;
	
	// Enables High Res mode on Retina Displays and maintains low res on all other devices
	// This must be done after the GL view is assigned to the director!
	[director enableRetinaDisplay: YES];
}
#endif	// !CC3_CC2_1

-(BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions {
	
	// Establish the view controller and CCDirector (in Cocos2D 2.x, these are one and the same)
	[self establishDirectorController];
	
	// Create the window, make the controller (and its view) the root of the window, and present the window
	_window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	[_window addSubview: _viewController.view];
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
	[_viewController.view layoutSubviews];		// iOS8 does not invoke layoutSubviews from makeKeyAndVisible
	
	// Set to YES for Augmented Reality 3D overlay on device camera.
	// This must be done after the window is made visible!
//	_viewController.isOverlayingDeviceCamera = YES;
	
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer and CC3Scene, and run it in the CCDirector.
	[CCDirector.sharedDirector runWithScene: [[CC3PerformanceLayer layer] asCCScene]];
	
	return YES;
}

-(void) applicationWillResignActive: (UIApplication*) application {
	[_viewController pauseAnimation];
}

-(void) applicationDidBecomeActive: (UIApplication*) application {
	[CCDirector.sharedDirector resume];
}

-(void) applicationDidReceiveMemoryWarning: (UIApplication*) application {
}

-(void) applicationDidEnterBackground: (UIApplication*) application {
	[_viewController stopAnimation];
}

-(void) applicationWillEnterForeground: (UIApplication*) application {
	[_viewController startAnimation];
}

-(void)applicationWillTerminate: (UIApplication*) application {
	[CC3OpenGL terminateOpenGL];
}

-(void) applicationSignificantTimeChange: (UIApplication*) application {
	[CCDirector.sharedDirector setNextDeltaTimeZero: YES];
}

@end

#endif	// CC3_CC2_RENDER_QUEUE
