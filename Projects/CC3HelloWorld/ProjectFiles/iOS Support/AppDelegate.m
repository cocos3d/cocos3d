/**
 *  AppDelegate.m
 *  CC3HelloWorld
 *
 *  Created by Bill Hollings on 2014/08/24.
 *  Copyright The Brenwill Workshop Ltd. 2014. All rights reserved.
 */

#import "AppDelegate.h"
#import "CC3HelloWorldLayer.h"
#import "CC3CC2Extensions.h"

#define kAnimationFrameRate		60		// Animation frame rate


#if CC3_CC2_RENDER_QUEUE	//================================================================

/** App Delegate for Cocos2D v3 and above. */
@implementation AppDelegate

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
	   CCSetupDepthFormat: @GL_DEPTH_COMPONENT16,				// Change to @GL_DEPTH24_STENCIL8 if using shadow volumes, which require a stencil buffer
	   CCSetupShowDebugStats: @(YES),							// Show the FPS and draw call label.
	   CCSetupAnimationInterval: @(1.0 / kAnimationFrameRate),	// Framerate (defaults to 60 FPS).
	   CCSetupScreenOrientation: CCScreenOrientationAll,		// Support all device orientations dyanamically
//	   CCSetupMultiSampling: @(YES),							// Use multisampling on the main view
//	   CCSetupNumberOfSamples: @(4),							// Number of samples to use per pixel (max 4)
	   }];
	
	// For an Augmented Reality 3D overlay on the device camera, uncomment the following lines.
	// This must be done after the window is made visible. The 3D scene contains a solid backdrop.
	// To see the device camera behind the 3D scene, remove this backdrop, by commenting out the
	// addBackdrop invocation in the initializeScene method of CC3DemoMashUpScene.
//	CC3DeviceCameraOverlayUIViewController* viewController = [[CC3DeviceCameraOverlayUIViewController alloc] init];
//	viewController.isOverlayingDeviceCamera = YES;
	
	return YES;
}

/** Returns the initial 2D CCScene. Our 2D scene contains a CC3Layer holding a 3D CC3Scene. */
-(CCScene*) startScene {
	
	// Create the customized CC3Layer that supports 3D rendering.
	CC3Layer* cc3Layer = [CC3HelloWorldLayer layer];
	
	// As an alternte to running "full-screen", the CC3Layer can run as a smaller "sub-window"
	// within any standard CCNode. That allows you to have a mostly 2D window, with a smaller
	// 3D window embedded in it. To experiment with this smaller, square, embedded 3D window,
	// uncomment the following lines:
//	CGSize cs = cc3Layer.contentSize;		// The layer starts out "full-screen".
//	GLfloat sideLen = MIN(cs.width, cs.height) - 200.0f;
//	cc3Layer.contentSize = CGSizeMake(sideLen, sideLen);
//	cc3Layer.position = ccp(100.0, 100.0);
	
	// The smaller 3D layer can even be moved around on the screen dyanmically. To see this in
	// action, uncomment the lines above as described, and also uncomment the following two lines.
//	cc3Layer.position = ccp(0.0, 0.0);
//	[cc3Layer runAction: [CCActionMoveTo actionWithDuration: 15.0 position: ccp(500.0, 250.0)]];

	// Wrap the 3D layer in a 2D scene and return it
	return [cc3Layer asCCScene];
}

@end


#else	//================================================================================


/** App Delegate for Cocos2D below v3. */
@implementation AppDelegate

#if !CC3_CC2_1
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
	_viewController.viewShouldUseStencilBuffer = NO;		// Set to YES if using shadow volumes
	_viewController.viewPixelSamples = 1;					// Set to 4 for antialiasing multisampling
	_viewController.animationInterval = (1.0f / kAnimationFrameRate);
	_viewController.displayStats = YES;
	[_viewController enableRetinaDisplay: YES];
}

#else

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
	_viewController.viewShouldUseStencilBuffer = NO;	// Set to YES if using shadow volumes
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
	
	// Establish the view controller and CCDirector (in cocos2d 2.x, these are one and the same)
	[self establishDirectorController];
	
	// Create the window, make the controller (and its view) the root of the window, and present the window
	_window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	[_window addSubview: _viewController.view];
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
	[_viewController.view layoutSubviews];		// iOS8 does not invoke layoutSubviews from makeKeyAndVisible
	
	// For an Augmented Reality 3D overlay on the device camera, uncomment the following line.
	// This must be done after the window is made visible. The 3D scene contains a solid backdrop.
	// To see the device camera behind the 3D scene, remove this backdrop, by commenting out the
	// addBackdrop invocation in the initializeScene method of CC3DemoMashUpScene.
//	_viewController.isOverlayingDeviceCamera = YES;

	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer that supports 3D rendering.
	CC3Layer* cc3Layer = [CC3HelloWorldLayer layer];
	
	// As an alternate to running "full-screen", the CC3Layer can run as a smaller "sub-window"
	// within any standard CCNode. That allows you to have a mostly 2D window, with a smaller
	// 3D window embedded in it. To experiment with this smaller, square, embedded 3D window,
	// uncomment the following lines:
//	CGSize cs = cc3Layer.contentSize;		// The layer starts out "full-screen".
//	GLfloat sideLen = MIN(cs.width, cs.height) - 200.0f;
//	cc3Layer.contentSize = CGSizeMake(sideLen, sideLen);
//	cc3Layer.position = ccp(100.0, 100.0);
	
	// The smaller 3D layer can even be moved around on the screen dyanmically. To see this in
	// action, uncomment the lines above as described, and also uncomment the following two lines.
//	cc3Layer.position = ccp(0.0, 0.0);
//	[cc3Layer runAction: [CCActionMoveTo actionWithDuration: 15.0 position: ccp(500.0, 250.0)]];
	
	// Wrap the 3D layer in a 2D scene and run it in the director
	[CCDirector.sharedDirector runWithScene: [cc3Layer asCCScene]];
	
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
