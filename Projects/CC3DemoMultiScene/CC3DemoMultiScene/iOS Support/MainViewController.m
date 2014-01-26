/*
 * MainViewController.m
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
 * See header file MainViewController.h for full API documentation.
 */

#import "MainViewController.h"
#import "CC3DeviceCameraOverlayUIViewController.h"
#import "CC3DemoMashUpLayer.h"
#import "CC3DemoMashUpScene.h"
#import "CC3PerformanceLayer.h"
#import "CC3PerformanceScene.h"
#import "MainLayer.h"


#define kAnimationFrameRate		60		// Animation frame rate

@implementation MainViewController

@synthesize cc3Controller=_cc3Controller;
@synthesize cc3FrameView=_cc3FrameView;
@synthesize sceneSelectorControl=_sceneSelectorControl;
@synthesize progressView=_progressView;

#pragma mark 3D scene selection

/**
 * Received from the specified segmented control.
 *
 * Take note of which 3D scene has been selected, disable further user interation during the initial
 * loading of the new 3D scene, and trigger the closing of the current 3D scene. The new 3D scene
 * will be loaded once the current 3D scene has been closed. Since closing the current 3D scene
 * is performed asynchonously, we get a callback when that is complete, and we can then load the
 * new scene from there.
 */
-(IBAction) requestChange3DSceneFromSegmentControl: (UISegmentedControl*) sender {
	_selectedScene = sender.selectedSegmentIndex;
	[self disableUI];
	[_cc3Controller.view removeFromSuperview];

	// The delay added here before closing the current 3D scene gives the UI a chance
	// to refresh before the scene closing operation starts.
	[self performSelector: @selector(close3DController) withObject: nil afterDelay: 0];
}

/**
 * Opens a new 3D controller, with a new, previously selected, 3D scene.
 * This method is invoked asynchronously from the didTerminateOpenGL callback.
 */
-(void) loadSelected3DScene {
	switch (_selectedScene) {
		case kSelectedSceneMashUp:
			LogInfo(@"MashUp scene selected");
			[self open3DControllerWithShadows: YES];
			[self open3DLayer: [self makeDemoMashUpLayer]];
			break;
		case kSelectedSceneTiles:
			LogInfo(@"Tiles scene selected");
			[self open3DControllerWithShadows: NO];
			[self open3DLayer: [self makeDemo3DTilesLayer]];
			break;
		case kSelectedScenePerformance:
			LogInfo(@"Performance scene selected");
			[self open3DControllerWithShadows: NO];
			[self open3DLayer: [self makePerformanceLayer]];
			break;
		case kSelectedSceneNone:
		default:
			LogInfo(@"No scene selected");
			break;
	}

	// Enable the UI only after a short delay. This gives the main thread loop a chance to drain
	// any touch events on the controls accumulated while they were disabled, before enabling them.
	// It also allows any background loading in the 3D scene, that is started when the view is
	// first opened, to start before possibly queuing a request to close the OpenGL environment,
	// which must be processed after (not before) the background loading starts. Although a
	// shorter delay is possible, we've chosen 0.5 seconds as visually appealing, as it appears
	// more deliberate than, say, a 0.2 second delay.
	[self performSelector: @selector(enableUI) withObject: nil afterDelay: 0.5];
}

/** 
 * Creates and opens a new 3D controller. The supportShadows argument indicates whether the
 * controller should be configured to support shadows. The frame of the GL view is set to 
 * fill the framing container view.
 */
-(void) open3DControllerWithShadows: (BOOL) supportShadows {
	CC3Assert(!_cc3Controller, @"%@ already exists. Close it before opening it again.", _cc3Controller);
	
	// Ensure the 3D controller has been created, set its view bounds to fill the placeholder
	// frame view that is part of the parent view controller, and add the 3D view to the frame view.
	_cc3Controller = [self makeCC3ControllerWithShadows: supportShadows];
	_cc3Controller.view.frame = [_cc3FrameView bounds];
	[_cc3FrameView addSubview: _cc3Controller.view];
}

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
-(CC3UIViewController*) makeCC3ControllerWithShadows: (BOOL) supportShadows {
	
	// Establish the type of CCDirector to use.
	// Try to use CADisplayLink director and if it fails (SDK < 3.1) use the default director.
	// This must be the first thing we do and must be done before establishing view controller.
	if( ! [CCDirector setDirectorType: kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType: kCCDirectorTypeDefault];
	
	// Create the view controller for the 3D view.
	CC3UIViewController* cc3VC = [CC3DeviceCameraOverlayUIViewController new];
	cc3VC.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
	cc3VC.viewShouldUseStencilBuffer = supportShadows;	// Shadow volumes make use of stencil buffer
	cc3VC.viewPixelSamples = 1;							// Set to 4 for antialiasing multisampling
	
	// Create the CCDirector, set the frame rate, and attach the view.
	CCDirector *director = CCDirector.sharedDirector;
	director.runLoopCommon = YES;		// Improves display link integration with UIKit
	director.animationInterval = (1.0f / kAnimationFrameRate);
	director.displayFPS = YES;
	director.openGLView = cc3VC.view;
	
	// Enables High Res mode on Retina Displays and maintains low res on all other devices
	// This must be done after the GL view is assigned to the director!
	[director enableRetinaDisplay: YES];

	return cc3VC;
}
#endif

#if CC3_CC2_2
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
-(CC3UIViewController*) makeCC3ControllerWithShadows: (BOOL) supportShadows {
	CC3UIViewController* cc3VC = CC3DeviceCameraOverlayUIViewController.sharedDirector;
	cc3VC.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
	cc3VC.viewShouldUseStencilBuffer = supportShadows;	// Shadow volumes make use of stencil buffer
	cc3VC.viewPixelSamples = 1;							// Set to 4 for antialiasing multisampling
	cc3VC.animationInterval = (1.0f / kAnimationFrameRate);
	cc3VC.displayStats = YES;
	[cc3VC enableRetinaDisplay: YES];
	return cc3VC;
}
#endif

/**
 * Closes the current 3D controller, removes the controller's view from the view hierarchy,
 * and shuts down all OpenGL behaviour.
 *
 * If a current controller exists, once it is closed, and OpenGL is terminated, the 
 * didTerminateOpenGL callback will trigger the loading of the new selected 3D scene.
 * If there is no current controller to close, no callback will be sent, so load the
 * new selected 3D scene immediately.
 */
-(void) close3DController {
	if (_cc3Controller) {
		[_cc3Controller terminateOpenGL];
		_cc3Controller = nil;
	} else {
		[self loadSelected3DScene];
	}
}


#pragma mark 3D scene and display layer

/** Opens the specified 3D layer (containing a 3D scene), on the 3D controller. */
-(void) open3DLayer: (CC3ControllableLayer*) layer3D {
	CC3Assert(_cc3Controller, @"The view controller for %@ has not be created.", layer3D);
	
	// Set the 3D layer in the 3D controller
	_cc3Controller.controlledNode = layer3D;
	
	// Wrap the 3D layer in a 2D scene and run it in the director
	CCScene* cc2Scene = [CCScene node];
	[cc2Scene addChild: layer3D];
	[CCDirector.sharedDirector runWithScene: cc2Scene];
}

/** Creates and returns a 3D layer and scene to display the CC3Demo3DTiles demo scene. */
-(CC3ControllableLayer*) makeDemo3DTilesLayer { return [MainLayer layer]; }

/** Creates and returns a 3D layer and scene to display the CC3DemoMashUp demo scene. */
-(CC3Layer*) makeDemoMashUpLayer {
	CC3Layer* cc3Layer = [CC3DemoMashUpLayer layer];
	cc3Layer.cc3Scene = [CC3DemoMashUpScene scene];
	return cc3Layer;
}

/** Creates and returns a 3D layer and scene to display the CC3Performance demo scene. */
-(CC3Layer*) makePerformanceLayer {
	CC3Layer* cc3Layer = [CC3PerformanceLayer layer];
	cc3Layer.cc3Scene = [CC3PerformanceScene scene];
	return cc3Layer;
}


#pragma mark User interface interaction

/** Disables user interaction. */
-(void) disableUI {
	[_progressView startAnimating];
	_sceneSelectorControl.enabled = NO;
}

/** Enables user interaction. */
-(void) enableUI {
	[_progressView stopAnimating];
	_sceneSelectorControl.enabled = YES;
}

/**
 * This callback method (from the CC3OpenGLDelegate protocol) is invoked once the current
 * 3D scene has been closed, and OpenGL has been terminated. Loads the new selected 3D scene.
 */
-(void) didTerminateOpenGL {
	LogInfo(@"OpenGL is dead. Long live OpenGL! on %@", NSThread.currentThread);
	[self loadSelected3DScene];
}


#pragma mark View management

/** After device rotation, re-align the frame of the GL view to fill the frame view. */
-(void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	_cc3Controller.view.frame = [_cc3FrameView bounds];
}

/** 
 * Adds this controller as the delegate of the OpenGL context,
 * so that we can be notified when the OpenGL context is terminated.
 */
-(void) viewDidLoad {
    [super viewDidLoad];
	CC3OpenGL.delegate = self;
}

/** If the view disappears, shut down the 3D controller and scene. */
-(void)viewWillDisappear: (BOOL) animated {
    [self close3DController];
	[super viewWillDisappear: animated];
}

@end
