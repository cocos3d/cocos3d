/*
 * CC3DemoMashUpAppDelegate.m
 *
 * cocos3d 2.0.0
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
 * See header file CC3DemoMashUpAppDelegate.h for full API documentation.
 */

#import "CC3DemoMashUpAppDelegate.h"
#import "CC3DemoMashUpLayer.h"
#import "CC3DemoMashUpScene.h"
#import "CC3CC2Extensions.h"


#define kAnimationFrameRate		60		// Animation frame rate

#if CC3_CC2_CLASSIC

@implementation CC3DemoMashUpAppDelegate

#if CC3_CC2_1
/**
 * In cocos2d 1.x, the view controller and CCDirector are different objects.
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
	
	// Establish the type of CCDirector to use.
	// Try to use CADisplayLink director and if it fails (SDK < 3.1) use the default director.
	// This must be the first thing we do and must be done before establishing view controller.
	if( ! [CCDirector setDirectorType: kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType: kCCDirectorTypeDefault];
	
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

#else

/**
 * In cocos2d 2.x, the view controller and CCDirector are one and the same, and we create the
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
	_viewController.viewShouldUseStencilBuffer = YES;	// Shadow volumes make use of stencil buffer
	_viewController.viewPixelSamples = 1;				// Set to 4 for antialiasing multisampling
	_viewController.animationInterval = (1.0f / kAnimationFrameRate);
	_viewController.displayStats = YES;
	[_viewController enableRetinaDisplay: YES];
}
#endif	// CC3_CC2_1

-(void) applicationDidFinishLaunching: (UIApplication*) application {

	// Establish the view controller and CCDirector (in cocos2d 2.x, these are one and the same)
	[self establishDirectorController];
	
	// Create the window, make the controller (and its view) the root of the window, and present the window
	_window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	[_window addSubview: _viewController.view];
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
	
	// Set to YES for Augmented Reality 3D overlay on device camera.
	// This must be done after the window is made visible!
//	_viewController.isOverlayingDeviceCamera = YES;
	
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer that supports 3D rendering.
	CC3Layer* cc3Layer = [CC3DemoMashUpLayer layer];
	
	// Create the customized 3D scene and attach it to the layer.
	// Could also just create this inside the customer layer.
	cc3Layer.cc3Scene = [CC3DemoMashUpScene scene];
	
	// Assign to a generic variable so we can uncomment options below to play with the capabilities
	CC3ControllableLayer* controlledLayer = cc3Layer;
	
	// The 3D layer can run either directly in the scene, or it can run as a smaller
	// "sub-window" within any standard CCLayer. So you can have a mostly 2D window,
	// with a smaller 3D window embedded in it. To experiment with this smaller, square,
	// embedded 3D window, uncomment the following lines:
//	CGSize cs = cc3Layer.contentSize;		// The layer starts out "full-screen".
//	GLfloat sideLen = MIN(cs.width, cs.height) - 100.0f;
//	cc3Layer.contentSize = CGSizeMake(sideLen, sideLen);
//	cc3Layer.position = ccp(50.0, 50.0);
//	controlledLayer = [CC3ControllableLayer layer];
//	[controlledLayer addChild: cc3Layer];
	
	// The smaller 3D layer can even be moved around on the screen dyanmically. To see this in
	// action, uncomment the lines above as described, and also uncomment the following two lines.
//	cc3Layer.position = ccp(0.0, 0.0);
//	[cc3Layer runAction: [CCMoveTo actionWithDuration: 15.0 position: ccp(500.0, 250.0)]];

	// Set the layer in the controller
	_viewController.controlledNode = controlledLayer;

	// Wrap the layer in a 2D scene and run it in the director
	CCScene *scene = [CCScene node];
	[scene addChild: controlledLayer];
	[CCDirector.sharedDirector runWithScene: scene];
}

-(void) applicationWillResignActive: (UIApplication*) application {
	[_viewController pauseAnimation];
}

/** Resume the cocos3d/cocos2d action. */
-(void) resumeApp { [_viewController resumeAnimation]; }

-(void) applicationDidBecomeActive: (UIApplication*) application {
	
	// Workaround to fix the issue of drop to 40fps on iOS4.X on app resume.
	// Adds short delay before resuming the app.
	[NSTimer scheduledTimerWithTimeInterval: 0.25
									 target: self
								   selector: @selector(resumeApp)
								   userInfo: nil
									repeats: NO];
	
	// If dropping to 40fps is not an issue, remove above, and uncomment the following to avoid delay.
	//	[self resumeApp];
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
	[_viewController terminateOpenGL];
}

-(void) applicationSignificantTimeChange: (UIApplication*) application {
	[CCDirector.sharedDirector setNextDeltaTimeZero: YES];
}

@end

#else

@implementation CC3DemoMashUpAppDelegate

// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
// This method is a good place to add one time setup code that only runs when your app is first launched.
-(BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions {
	
	// Setup Cocos2D with reasonable defaults for everything.
	// See CCAppDelegate.h for more options.
	// With Cocos3D, you MUST include CCSetupDepthFormat as GL_DEPTH_COMPONENT16 or GL_DEPTH24_STENCIL8 !!
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:
	 @{
	   CCSetupDepthFormat: @GL_DEPTH24_STENCIL8,	// This app uses shadow volumes which require a stencil buffer
	   CCSetupShowDebugStats: @(YES),				// Show the FPS and draw call label.
	   CCSetupAnimationInterval: @(1.0 / kAnimationFrameRate),	// Framerate (defaults to 60 FPS).
//	   CCSetupScreenOrientation: CCScreenOrientationPortrait,	// Run in portrait mode.
	   }];
	
	return YES;
}

/** Returns the initial 2D CCScene. Our 2D scene contains a CC3Layer holding a 3D CC3Scene. */
-(CCScene*) startScene {

	// Create the customized CC3Layer that supports 3D rendering.
	CC3Layer* cc3Layer = [CC3DemoMashUpLayer layer];
	
	// Create the customized 3D scene and attach it to the layer.
	// Could also just create this inside the customer layer.
	cc3Layer.cc3Scene = [CC3DemoMashUpScene scene];
	
	// Wrap the layer in a 2D scene and run it in the director
	CCScene *scene = [CCScene node];
	[scene addChild: cc3Layer];
	return scene;
}

@end

#endif	// CC3_CC2_CLASSIC



