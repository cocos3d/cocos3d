/*
 * MainViewController.m
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
 * See header file MainViewController.h for full API documentation.
 */

#import "MainViewController.h"
#import "CC3DemoMashUpLayer.h"
#import "CC3PerformanceLayer.h"
#import "MainLayer.h"
#import "IntroScene.h"
#import "CC3CC2Extensions.h"


#define kAnimationFrameRate		60		// Animation frame rate


@implementation MainViewController

@synthesize cc3FrameView=_cc3FrameView;
@synthesize sceneSelectorControl=_sceneSelectorControl;
@synthesize progressView=_progressView;


#pragma mark 3D scene selection

/**
 * Received from the specified segmented control.
 *
 * Takes note of which 3D scene has been selected, disables further user interaction
 * during the loading of, and transition to, the new 3D scene.
 */
-(IBAction) requestChange3DSceneFromSegmentControl: (UISegmentedControl*) sender {
	_selectedScene = (SelectedScene)sender.selectedSegmentIndex;
	[self disableUI];

	// The delay and disconnect added here gives the UI a chance to refresh
	// before the scene-loading operation starts.
	[self performSelector: @selector(loadSelected3DScene) withObject: nil afterDelay: 0];
}

/** Opens a new 3D controller, with a new, previously selected, 3D scene, and re-enables the UI. */
-(void) loadSelected3DScene {
	switch (_selectedScene) {
		case kSelectedSceneMashUp:
			LogInfo(@"MashUp scene selected");
			[self openScene: [self makeDemoMashUpScene]];
			break;
		case kSelectedSceneTiles:
			LogInfo(@"Tiles scene selected");
			[self openScene: [self makeDemo3DTilesScene]];
			break;
		case kSelectedScenePerformance:
			LogInfo(@"Performance scene selected");
			[self openScene: [self makePerformanceScene]];
			break;
		case kSelectedSceneNone:
			[self openScene: [self makeIntroScene]];
		default:
			LogInfo(@"No scene selected");
			break;
	}

	// Enable the UI only after a short delay. This gives the main thread loop a chance to drain
	// any touch events on the controls accumulated while they were disabled, before enabling them.
	// Although a shorter delay is possible, we've chosen 0.5 seconds as visually appealing, as it
	// appears more deliberate than, say, a 0.2 second delay.
	[self performSelector: @selector(enableUI) withObject: nil afterDelay: 0.5];
}


#pragma mark 3D scene and display layer

#if CC3_CC2_CLASSIC

/** Opens the specified 2D scene (containing the 3D scene). */
-(void) openScene: (CCScene*) ccScene {
	[CCDirector.sharedDirector replaceScene: ccScene];
}

#else

/** Opens the specified 2D scene (containing the 3D scene), using a randomly-selected transition. */
-(void) openScene: (CCScene*) ccScene {

	// For an Augmented Reality 3D overlay on the device camera, uncomment the following line.
	// This must be done after the window is made visible. If the 3D scene contains a backdrop
	// (eg. DemoMashUpScene), comment out setting the backdrop property. For the 2D IntroScene,
	// comment out setting the background property. Since this app uses Storyboards, the Background
	// color of the background UIViews in the Storyboards (BaseView & FrameView) must be set to
	// Clear Color, and their Opaque properties must be turned off.
//	[self showDeviceCameraWith2DScene: ccScene];

	[CCDirector.sharedDirector replaceScene: ccScene withTransition: [self getRandomTransition]];
}

/** Returns a Cocos2D scene transition of a randomly-selected style and direction. */
-(CCTransition*) getRandomTransition {
	
	// Select a random transition direction
	CCTransitionDirection direction = CCTransitionDirectionInvalid;
	switch (CC3RandomUIntBelow(4)) {
		case 0:
			direction = CCTransitionDirectionUp;
			break;
		case 1:
			direction = CCTransitionDirectionDown;
			break;
		case 2:
			direction = CCTransitionDirectionRight;
			break;
		case 3:
		default:
			direction = CCTransitionDirectionLeft;
			break;
	}
	
	// Create and return a transition of a random type.
	NSTimeInterval duration = 1.0;
	switch (CC3RandomUIntBelow(6)) {
		case 0:
			return [CCTransition transitionCrossFadeWithDuration: duration];
		case 1:
			return [CCTransition transitionFadeWithDuration: duration];
		case 2:
			return [CCTransition transitionMoveInWithDirection: direction duration: duration];
		case 3:
			return [CCTransition transitionRevealWithDirection: direction duration: duration];
		case 4:
		default:
			return [CCTransition transitionPushWithDirection: direction duration: duration];
	}
}

/** To create an Augmented Reality display, set the specified CCScene as transparent, and engage a controller for the device camera. */
-(void) showDeviceCameraWith2DScene: (CCScene*) scene2D {
	scene2D.colorRGBA = [CCColor colorWithCcColor4f: kCCC4FBlackTransparent];

	if (!_deviceCameraController) {
		_deviceCameraController = [[CC3DeviceCameraOverlayUIViewController alloc] init];
		_deviceCameraController.isOverlayingDeviceCamera = YES;
	}
}

#endif	// CC3_CC2_CLASSIC

/** Creates and returns a CCScene containing the 3D content of the CC3Demo3DTiles demo. */
-(CCScene*) makeDemo3DTilesScene { return [[MainLayer layer] asCCScene]; }

/** Creates and returns a CCScene containing the 3D content of the CC3DemoMashUp demo. */
-(CCScene*) makeDemoMashUpScene { return [[CC3DemoMashUpLayer layer] asCCScene]; }

/** Creates and returns a CCScene containing the 3D content of the CC3Performance demo. */
-(CCScene*) makePerformanceScene { return [[CC3PerformanceLayer layer] asCCScene]; }

/** Creates and returns a static 2D layer instructing the user to select a demo. */
-(CCScene*) makeIntroScene { return [IntroScene node]; }


#pragma mark User interface interaction

/** Disables user interaction and runs a progress view during scene loading. */
-(void) disableUI {
	_sceneSelectorControl.enabled = NO;

	// Depending on order views were added, the progress view might be behind the GL view. Bring it to the front.
	[_cc3FrameView bringSubviewToFront: _progressView];
	[_progressView startAnimating];
}

/** Stops the progress view and enables user interaction. */
-(void) enableUI {
	[_progressView stopAnimating];
	_sceneSelectorControl.enabled = YES;
}


#pragma mark View management

/** After device rotation, re-align the frame of the GL view to fill the frame view. */
-(void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CCDirector.sharedDirector.view.frame = _cc3FrameView.bounds;
}

/** 
 * Once this controller's view is loaded, create the CCGLView and add it to the framing view.
 *
 * Since the user interface allows the same 3D scene to be repeatedly loaded and removed,
 * we cannot use background resource loading, because GL objects must be deleted using the 
 * same GL context on which they were loaded. To ensure we don't run into trouble when 3D 
 * scenes are removed, we turn background loading off here.
 */
-(void) viewDidLoad {
    [super viewDidLoad];
	[_cc3FrameView addSubview: [self createGLView]];
	CC3Backgrounder.sharedBackgrounder.shouldRunTasksOnRequestingThread = YES;
}

/** 
 * Creates and returns the CCGLView.
 * Also creates the CCDirector singleton, links it to the CCGLView, 
 * and sets an initial static 2D intro scene.
 */
-(CCGLView*) createGLView {
	
	// Create the view first, since it creates the GL context, which CCDirector expects during init.
	CCGLView* glView = [CCGLView viewWithFrame: _cc3FrameView.bounds
								   pixelFormat: kEAGLColorFormatRGBA8
								   depthFormat: GL_DEPTH24_STENCIL8		// Shadow volumes require a stencil
							preserveBackbuffer: NO
							   numberOfSamples: 1];

	// Create and configure the CCDirector singleton.
#if CC3_CC2_1
	// Use CADisplayLink director for better animation.
	CCDirector.directorType = kCCDirectorTypeDisplayLink;
#endif	// CC3_CC2_1

	CCDirector* director = CCDirector.sharedDirector;
	director.animationInterval = (1.0f / kAnimationFrameRate);
	director.displayStats = YES;
	director.view = glView;

	// Run the initial static 2D intro scene
	[director runWithScene: [[self makeIntroScene] asCCScene]];
	
	return glView;
}

@end
