/*
 * AppDelegate.m
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
 * See header file AppDelegate.h for full API documentation.
 */

#import "AppDelegate.h"
#import "MainLayer.h"


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
	   CCSetupDepthFormat: @GL_DEPTH_COMPONENT16,				// 3D rendering requires a depth buffer
	   CCSetupShowDebugStats: @(YES),							// Show the FPS and draw call label.
	   CCSetupAnimationInterval: @(1.0 / kAnimationFrameRate),	// Framerate (defaults to 60 FPS).
	   CCSetupScreenOrientation: CCScreenOrientationLandscape,	// Display in landscape
//	   CCSetupMultiSampling: @(YES),							// Use multisampling on the main view
//	   CCSetupNumberOfSamples: @(4),							// Number of samples to use per pixel (max 4)
	   }];
	
	return YES;
}

/** Returns the initial 2D CCScene. Our 2D scene contains a CC3Layer holding a 3D CC3Scene. */
-(CCScene*) startScene {

	// Create the customized CC3Layer that supports 3D rendering,
	// wrap the layer in a 2D scene and return the 2D scene.
	return [[MainLayer layer] asCCScene];
}

@end


#else	//================================================================================


/** App Delegate for Cocos2D below v3. */
@implementation AppDelegate

-(BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions {
	
#if CC3_CC2_1
	// Use CADisplayLink director for better animation.
	CCDirector.directorType = kCCDirectorTypeDisplayLink;
#endif	// CC3_CC2_1

	// Create the CCDirector, set the frame rate, and attach the view.
	CCDirector* director = CCDirector.sharedDirector;
	director.animationInterval = (1.0f / kAnimationFrameRate);
	director.displayStats = YES;
	director.view = [CCGLView viewWithFrame: UIScreen.mainScreen.bounds
								pixelFormat: kEAGLColorFormatRGBA8
								depthFormat: GL_DEPTH_COMPONENT16
						 preserveBackbuffer: NO
							numberOfSamples: 1];		// Change to 4 for multisampling
	
	// Create the window, make the controller (and its view) the root of the window, and present the window
	_window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
	[_window addSubview: director.view];

#if CC3_CC2_1
	UIViewController* viewController = [UIViewController new];
	viewController.view = director.view;
	_window.rootViewController = viewController;
#else
	_window.rootViewController = director;
#endif	// CC3_CC2_1

	[_window makeKeyAndVisible];
	[director.view layoutSubviews];		// iOS8 does not invoke layoutSubviews from makeKeyAndVisible
	
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer and CC3Scene, and run it in the CCDirector.
	[CCDirector.sharedDirector runWithScene: [[MainLayer layer] asCCScene]];
	
	return YES;
}

-(void) applicationWillResignActive: (UIApplication*) application {
	[CCDirector.sharedDirector pause];
}

-(void) applicationDidBecomeActive: (UIApplication*) application {
	[CCDirector.sharedDirector resume];
}

-(void) applicationDidReceiveMemoryWarning: (UIApplication*) application {
}

-(void) applicationDidEnterBackground: (UIApplication*) application {
	[CCDirector.sharedDirector stopAnimation];
}

-(void) applicationWillEnterForeground: (UIApplication*) application {
	[CCDirector.sharedDirector startAnimation];
}

-(void)applicationWillTerminate: (UIApplication*) application {
	[CC3OpenGL terminateOpenGL];
}

-(void) applicationSignificantTimeChange: (UIApplication*) application {
	[CCDirector.sharedDirector setNextDeltaTimeZero: YES];
}

@end

#endif	// CC3_CC2_RENDER_QUEUE
