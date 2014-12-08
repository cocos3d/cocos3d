/*
 * MainViewController.h
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
 * copies of the Software , and to permit persons to whom the Software is
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

#import <UIKit/UIKit.h>
#import "CC3DeviceCameraOverlayUIViewController.h"


/**
 * Identifies the types of scenes that can be selected by the scene selector control.
 * The values correspond to the indices of the scene selector UISegmentedControl.
 */
typedef enum {
	kSelectedSceneMashUp,			/**< The MashUp scene was selected. */
	kSelectedSceneTiles,			/**< The Tiles scene was selected. */
	kSelectedScenePerformance,		/**< The Performance scene was selected. */
	kSelectedSceneNone,				/**< No scene was selected. */
} SelectedScene;

/**
 * The main application view controller.
 *
 * An instance of this controller is instantiated in the main app Storyboard. This controller 
 * loads and manages different Cocos3D scenes, through user interaction with standard UI controls.
 * This controller supports user selection of several separate 3D scenes, and coordinates
 * the transition between them. When the user selects a different 3D scene, the new 3D scene
 * is created and loaded, an animated transition is run from the old 3D scene to the new,
 * and the old scene is released and deallocated.
 *
 * Since the user interface allows the same 3D scene to be repeatedly loaded and removed,
 * background resource loading cannot be used, because GL objects must be deleted using the
 * same GL context on which they were loaded. To ensure we don't run into trouble when 3D
 * scenes are removed, this controller turns background loading off so that each 3D scene
 * is loaded in the foreground.
 */
@interface MainViewController : UIViewController {
	UIView* _cc3FrameView;
	UISegmentedControl* _sceneSelectorControl;
	UIActivityIndicatorView* _progressView;
	SelectedScene _selectedScene;
	CC3DeviceCameraOverlayUIViewController* _deviceCameraController;
}

/** 
 * This generic UIView is used as a container for the CCGLView view that displays the Cocos3D
 * (and Cocos2D) scene. Since the CCGLView is created programmatically, this view is used within
 * the Storyboard to define the size and position of the CCGLView. Once created programmatically,
 * the CCGLView is added as a subview of this view, and made the same size as this view.
 */
@property (strong, nonatomic) IBOutlet UIView* cc3FrameView;

/** The UI control for selecting the 3D scene to display. */
@property (strong, nonatomic) IBOutlet UISegmentedControl* sceneSelectorControl;

/** 
 * A standard activity progress view, displayed during the transition between 3D scenes,
 * while a 3D scene is loading, or being removed.
 */
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* progressView;


#pragma mark Event handling

/**
 * Received from the specified segmented control to indicate that the user has selected
 * a new 3D scene for display.
 */
-(IBAction) requestChange3DSceneFromSegmentControl: (UISegmentedControl*) sender;

@end
