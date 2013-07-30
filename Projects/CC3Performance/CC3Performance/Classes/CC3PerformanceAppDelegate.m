/*
 * CC3PerformanceAppDelegate.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3PerformanceScene.h"

@implementation CC3PerformanceAppDelegate {
	UIWindow *window;
	CCNodeController *viewController;
}

-(void) dealloc {
	[window release];
	[viewController release];
	[super dealloc];
}

-(void) applicationDidFinishLaunching:(UIApplication*)application {
	
	// Establish the type of CCDirector to use.
	// Try to use CADisplayLink director and if it fails (SDK < 3.1) use the default director.
	// This must be the first thing we do and must be done before establishing view controller.
	if( ! [CCDirector setDirectorType: kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType: kCCDirectorTypeDefault];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565. You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGBA8888];
	
	// Create the view controller for the 3D view.
	viewController = [CCNodeController new];
	viewController.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
	
	// Create the CCDirector, set the frame rate, and attach the view.
	CCDirector *director = CCDirector.sharedDirector;
	director.runLoopCommon = YES;		// Improves display link integration with UIKit
	director.animationInterval = (1.0f / 60);
	director.displayFPS = NO;
	director.openGLView = viewController.view;
	
	// Enables High Res mode on Retina Displays and maintains low res on all other devices
	// This must be done after the GL view is assigned to the director!
//	[director enableRetinaDisplay: YES];
	
	// Create the window, make the controller (and its view) the root of the window, and present the window
	window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	[window addSubview: viewController.view];
	window.rootViewController = viewController;
	[window makeKeyAndVisible];
	
	// Set to YES for Augmented Reality 3D overlay on device camera.
	// This must be done after the window is made visible!
//	viewController.isOverlayingDeviceCamera = YES;
	
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer that supports 3D rendering,
	// and schedule it for automatic updates
	CC3Layer* cc3Layer = [CC3PerformanceLayer node];

	// Create the customized 3D scene, attach it to the layer.
	// Could also just create this inside the customer layer.
	cc3Layer.cc3Scene = [CC3PerformanceScene scene];

	ControllableCCLayer* mainLayer = cc3Layer;
	
	// The 3D layer can run either direcly in the scene, or it can run as a smaller "sub-window"
	// within any standard CCLayer. So you can have a mostly 2D window, with a smaller 3D window
	// embedded in it. To experiment with this smaller embedded 3D window, uncomment the following lines:
//	CGSize winSize = [[CCDirector sharedDirector] winSize];
//	cc3Layer.position = CGPointMake(30.0, 40.0);
//	cc3Layer.contentSize = CGSizeMake(winSize.width - 70.0, winSize.width - 40.0);
//	cc3Layer.alignContentSizeWithDeviceOrientation = YES;
//	mainLayer = [ControllableCCLayer layerWithColor: ccc4(0, 0, 0, 255)];
//	[mainLayer addChild: cc3Layer];

	// Run the layer on the controller.
	[viewController runSceneOnNode: mainLayer];		// attach the layer to the controller and run a scene with it
}

-(void) applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

/** Resume the cocos3d/cocos2d action. */
-(void) resumeApp { [[CCDirector sharedDirector] resume]; }

-(void) applicationDidBecomeActive: (UIApplication*) application {
	
	// Workaround to fix the issue of drop to 40fps on iOS4.X on app resume.
	// Adds short delay before resuming the app.
	[NSTimer scheduledTimerWithTimeInterval: 0.5f
									 target: self
								   selector: @selector(resumeApp)
								   userInfo: nil
									repeats: NO];
	
	// If dropping to 40fps is not an issue, remove above, and uncomment the following to avoid delay.
	//	[self resumeApp];
}

-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

-(void) applicationWillTerminate:(UIApplication *)application {
	[CCDirector.sharedDirector.openGLView removeFromSuperview];
	[CCDirector.sharedDirector end];
}

-(void) applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
