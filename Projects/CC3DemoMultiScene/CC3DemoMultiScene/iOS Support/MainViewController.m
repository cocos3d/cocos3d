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


#define kAnimationFrameRate		60		// Animation frame rate

@implementation MainViewController

@synthesize cc3Controller=_cc3Controller;
@synthesize cc3FrameView=_cc3FrameView;
@synthesize progressView=_progressView;

#pragma mark 3D scene selection

/** 
 * Show the animated progress view, and then delegate to the change3DSceneTo: method.
 * The performSelector:withObject:afterDelay: method is used to avoid blocking the
 * progress view.
 */
-(IBAction) requestChange3DSceneFrom: (UISegmentedControl*) sender {
	[_progressView startAnimating];
	[self performSelector: @selector(change3DSceneTo:)
			   withObject: [NSNumber numberWithInt: (sender.selectedSegmentIndex)]
			   afterDelay: 0];
}

/** 
 * Closes the current 3D controller, and opens a new 3D controller, with a new 3D scene,
 * as selected by the specified segment index.
 */
-(void) change3DSceneTo: (NSNumber*) segmentIndex {
	[self close3DController];
	switch (segmentIndex.intValue) {
		case kSelectedSceneMashUp:
			LogInfo(@"MashUp scene selected");
			[self open3DControllerWithShadows: YES];
			[self open3DLayer: [self makeDemoMashUpLayer]];
			break;
		case kSelectedSceneTiles:
			LogInfo(@"Tiles scene selected");
			break;
		case kSelectedScenePerformance:
			LogInfo(@"Performance scene selected");
			break;
		case kSelectedSceneNone:
		default:
			LogInfo(@"No scene selected");
		break;
	}
	[_progressView stopAnimating];
}

/** 
 * Creates and opens a new 3D controller. The supportShadows argument indicates whether
 * the controller should be configured to support shadows. The frame of the GL view is
 * set to fill the framing container view.
 */
-(void) open3DControllerWithShadows: (BOOL) supportShadows {
	CC3Assert(!_cc3Controller, @"%@ already exists. Close it before opening it again.", _cc3Controller);
	
	// Ensure the 3D controller has been created, set its view bounds to fill the placeholder
	// frame view that is part of the parent view controller, and add the 3D view to the frame view.
	_cc3Controller = [self makeCC3ControllerWithShadows: supportShadows];
	_cc3Controller.view.frame = [_cc3FrameView bounds];
	[_cc3FrameView addSubview: _cc3Controller.view];
}

/** Opens the specified 3D layer (containing a 3D scene), on the 3D controller. */
-(void) open3DLayer: (CC3Layer*) cc3Layer {
	CC3Assert(_cc3Controller, @"The view controller for %@ has not be created.", cc3Layer);
	
	// Set the 3D layer in the 3D controller
	_cc3Controller.controlledNode = cc3Layer;
	
	// Wrap the 3D layer in a 2D scene and run it in the director
	CCScene* cc2Scene = [CCScene node];
	[cc2Scene addChild: cc3Layer];
	[CCDirector.sharedDirector runWithScene: cc2Scene];
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

/** Creates and returns a 3D layer and scene to display the CC3DemoMashUp scene. */
-(CC3Layer*) makeDemoMashUpLayer {
	CC3Layer* cc3Layer = [CC3DemoMashUpLayer layer];
	cc3Layer.cc3Scene = [CC3DemoMashUpScene scene];
	return cc3Layer;
}

/**
 * Closes the current 3D controller, removes the controller's view from the view hierarchy,
 * and shuts down all OpenGL behaviour.
 */
-(void) close3DController {
	[_cc3Controller.view removeFromSuperview];
	[_cc3Controller endOpenGL];
	_cc3Controller = nil;
}


#pragma mark View management

/** After device rotation, re-align the frame of the GL view to fill the frame view. */
-(void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	_cc3Controller.view.frame = [_cc3FrameView bounds];
}

-(void) viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

/** If the view disappears, shut down the 3D controller and scene. */
-(void)viewWillDisappear: (BOOL) animated {
    [self close3DController];
	[super viewWillDisappear: animated];
}

-(void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
