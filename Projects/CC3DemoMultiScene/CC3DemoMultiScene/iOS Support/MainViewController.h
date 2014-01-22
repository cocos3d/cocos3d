/*
 * MainViewController.h
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
#import "CC3UIViewController.h"

typedef enum {
	kSelectedSceneMashUp,			/**< The MashUp scene was selected. */
	kSelectedSceneTiles,			/**< The Tiles scene was selected. */
	kSelectedScenePerformance,		/**< The Performance scene was selected. */
	kSelectedSceneNone,				/**< The Tiles scene was selected. */
} SelectSceneControlIndex;

/**
 * The main application view controller.
 *
 * An instance of this controller is instantiated in the main app Storyboard.
 * This controller loads and manages different CC3UIViewControllers, through
 * user interaction with standard UI controls.
 */
@interface MainViewController : UIViewController {
    CC3UIViewController* _cc3Controller;
	UIView* _cc3FrameView;
	UIActivityIndicatorView* _progressView;
}

/** 
 * The current CC3UIViewController that is controlling the OpenGL view, and managing
 * the 3D scene content.
 *
 * Different controllers are created and destroyed through user interaction with the
 * UI controls on this controller.
 */
@property (nonatomic, strong, readonly) CC3UIViewController* cc3Controller;

/** 
 * The UIView that is used as a container for the OpenGL view that is manage by the
 * CC3ViewController in the cc3Controller property. This allows different OpenGL views
 * to be installed as needed, while defining consistent bounds for those OpenGL views.
 *
 * When a CC3UIViewController is loaded, its view is added as a subview of this view,
 * and the bounds of the OpenGL view are set to those of this view.
 */
@property (strong, nonatomic) IBOutlet UIView* cc3FrameView;

/** A standard activity progress view, displayed while the 3D scene is loading, or being removed. */
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* progressView;

#pragma mark Event handling

/** 
 * Invoked when an on-screen control indicates that the user has selected a particular
 * 3D scene for display. 
 */
-(IBAction) requestChange3DSceneFrom: (UISegmentedControl*) sender;

/** 
 * Closes the current 3D controller. This can be invoked directly from the user interface,
 * of indirectly as a result of changing the 3D scene.
 */
-(void) close3DController;
	
@end
