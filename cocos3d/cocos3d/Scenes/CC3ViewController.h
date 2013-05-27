/*
 * CC3ViewController.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 */

/** @file */	// Doxygen marker

#import "CC3GLView-GL.h"
#import "CC3GLView-GLES2.h"
#import "CC3GLView-GLES1.h"

// The superclass of the CC3ViewController depends on the platform
#if CC3_OGLES_2
#	define CC3VCSuperclass CCDirectorDisplayLink
#endif
#if CC3_OGLES_1
#	define CC3VCSuperclass UIViewController
#endif
#if CC3_OGL
#	define CC3VCSuperclass NSViewController
#endif


#pragma mark -
#pragma mark CC3ViewController interface

/** An instance of CC3ViewController manages the CC3GLView to support the 3D environment. */
@interface CC3ViewController : CC3VCSuperclass {
	CCNode* _controlledNode;
}

/**
 * The CCNode that is being controlled by this controller. This is typically an instance of CCLayer.
 *
 * The application should keep this property synchronized with changes in the running scene of the
 * shared CCDirector.
 */
@property(nonatomic, retain) CCNode* controlledNode;

/**
 * Indicates whether this controller is overlaying the view of the device camera.
 *
 * This base implementation always returns NO, indicating that the device camera is not being
 * displayed. Subclasses that support device camera overlay can override.
 */
@property(nonatomic, readonly) BOOL isOverlayingDeviceCamera;

/** The view of a CC3ViewController must be of type CC3GLView. */
@property(nonatomic, retain) CC3GLView* view;

/**
 * Reduces cocos2d/3d animation to a minimum.
 *
 * Invoke this method when you want to reliquish CPU to perform some other task, such as
 * displaying other views or windows. To ensure a responsive UI, you should invoke this
 * method just before displaying other view components, such as modal or popover controllers.
 *
 * Use the resumeAnimation method to restore the original animation level.
 */
-(void) pauseAnimation;

/**
 * Restores cocos2d/3d animation to its original operating level, after having been
 * temporarily reduced by a prior invocation of the pauseAnimation method.
 */
-(void) resumeAnimation;

@end

