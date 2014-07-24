/*
 * CC3ViewController.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3Environment.h"
#import "CC3EAGLView.h"


// CC3ViewController and its subclasses are not used for Cocos2D 3.1 and above.
#if CC3_CC2_RENDER_QUEUE

#if CC3_IOS
#	define CC3ViewController	UIViewController
#endif
#if CC3_OSX
#	define CC3ViewController	NSViewController
#endif

#else

// For Cocos2D 3.0 and below, the superclass of the CC3ViewController depends on the platform.
#if CC3_OGLES_2
#	define CC3VCSuperclass		CCDirectorDisplayLink
#endif
#if CC3_OGLES_1
#	define CC3VCSuperclass		UIViewController
#endif
#if CC3_OGL
#	define CC3VCSuperclass		NSViewController
#endif


#pragma mark -
#pragma mark CC3ViewController interface

/** An instance of CC3ViewController manages the CCGLView to support the 3D environment. */
@interface CC3ViewController : CC3VCSuperclass

/** The view of a CC3ViewController must be of type CCGLView. */
@property(nonatomic, retain) CCGLView* view;

/**
 * Starts the Cocos2D/3D animation.
 *
 * You should invoke this method when the application enters the foreground.
 *
 * Use the stopAnimation method to stop the animation.
 */
-(void) startAnimation;

/**
 * Reduces Cocos2D/3D animation to a minimum.
 *
 * Invoke this method when you want to reliquish CPU to perform some other task, such as
 * displaying other views or windows. To ensure a responsive UI, you should invoke this
 * method just before displaying other view components, such as modal or popover controllers.
 *
 * Use the resumeAnimation method to restore the original animation level.
 */
-(void) pauseAnimation;

/**
 * Restores Cocos2D/3D animation to its original operating level, after having been
 * temporarily reduced by a prior invocation of the pauseAnimation method.
 */
-(void) resumeAnimation;

/** 
 * Stops the Cocos2D/3D animation.
 *
 * You should invoke this method when the application will enter the background.
 *
 * Use the startAnimation method to start the animation again.
 */
-(void) stopAnimation;


#pragma mark Deprecated

/** @deprecated No longer used. */
@property(nonatomic, retain) CCNode* controlledNode __deprecated;

/**
 * @deprecated No longer used by base class.
 * See the CC3DeviceCameraOverlayUIViewController subclass for an implementation of this property.
 */
@property(nonatomic, assign) BOOL isOverlayingDeviceCamera __deprecated;

@end

#endif // CC3_CC2_RENDER_QUEUE
