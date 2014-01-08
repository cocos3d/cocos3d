/*
 * CC3IOSExtensions.h
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


/* Base library of extensions to iOS frameworks to support cocos3d. */

#import "CC3Environment.h"

#if CC3_IOS

#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UIColor.h>
#import "CC3OpenGLFoundation.h"

// Define when compiling with lower SDK's
#ifndef __IPHONE_5_0
#	define __IPHONE_5_0     50000
#endif
#ifndef __IPHONE_6_0
#	define __IPHONE_6_0     60000
#endif
#ifndef __IPHONE_7_0
#	define __IPHONE_7_0     70000
#endif

/** iOS equivalents for OSX declaration */
#define NSEvent		NSObject


#pragma mark -
#pragma mark Gesture Recognizer extensions

/** Extension category to support cocos3d functionality. */
@interface UIGestureRecognizer (CC3)

/** Cancels this gesture recognizer. */
-(void) cancel;

/**
 * Returns the location of the gesture in the view to which this recognizer is attached.
 * 
 * This is a convenience property that returns the same result as invoking
 * locationInView: with the value of the view property of this recognizer.
 */
@property(nonatomic, readonly) CGPoint location;

/** Returns the name of the current value of the state property. */
@property(nonatomic, readonly) NSString* stateName;

@end

/** Extension category to support cocos3d functionality. */
@interface UIPanGestureRecognizer (CC3)

/**
 * Returns the translation of the gesture in the view to which this recognizer is attached.
 * 
 * This is a convenience property that returns the same result as invoking
 * translationInView: with the value of the view property of this recognizer.
 */
@property(nonatomic, readonly) CGPoint translation;

/**
 * Returns the velocity of the gesture in the view to which this recognizer is attached.
 * 
 * This is a convenience property that returns the same result as invoking
 * velocityInView: with the value of the view property of this recognizer.
 */
@property(nonatomic, readonly) CGPoint velocity;

@end


#pragma mark -
#pragma mark UIKit extensions

/** For consistency, add compilation support for UIInterfaceOrientationMask for SDK's below iOS 6.0. */
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
typedef enum {
	UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
	UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
	UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
	UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
	UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
	UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
	UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
} UIInterfaceOrientationMask;
#endif


/** Returns the UIInterfaceOrientationMask corresponding to the specified UIInterfaceOrientation. */
static inline UIInterfaceOrientationMask CC3UIInterfaceOrientationMaskFromUIInterfaceOrientation(UIInterfaceOrientation uiOrientation) {
	switch (uiOrientation) {
		case UIInterfaceOrientationLandscapeLeft:
			return UIInterfaceOrientationMaskLandscapeLeft;
		case UIInterfaceOrientationLandscapeRight:
			return UIInterfaceOrientationMaskLandscapeRight;
		case UIInterfaceOrientationPortraitUpsideDown:
			return UIInterfaceOrientationMaskPortraitUpsideDown;
		case UIInterfaceOrientationPortrait:
		default:
			return UIInterfaceOrientationMaskPortrait;
	}
}

/** Returns whether the specified UIInterfaceOrientationMask includes the specified UIInterfaceOrientation. */
static inline BOOL CC3UIInterfaceOrientationMaskIncludesUIOrientation(NSUInteger uiOrientationMask,
																	  UIInterfaceOrientation uiOrientation) {
	return (uiOrientationMask & CC3UIInterfaceOrientationMaskFromUIInterfaceOrientation(uiOrientation)) != 0;
}

/**
 * Returns the UIDeviceOrientation corresponding to the specified UIInterfaceOrientation.
 *
 * For landscape mode, device orientation is the opposite to the UI orientation (Left <=> Right),
 * otherwise the device orientation is the same as the UI orientation.
 */
static inline UIDeviceOrientation CC3UIDeviceOrientationFromUIInterfaceOrientation(UIInterfaceOrientation uiOrientation) {
	switch (uiOrientation) {
		case UIInterfaceOrientationLandscapeLeft:
			return UIDeviceOrientationLandscapeRight;
		case UIInterfaceOrientationLandscapeRight:
			return UIDeviceOrientationLandscapeLeft;
		case UIInterfaceOrientationPortrait:
			return UIDeviceOrientationPortrait;
		case UIInterfaceOrientationPortraitUpsideDown:
			return UIDeviceOrientationPortraitUpsideDown;
		default:
			return UIDeviceOrientationUnknown;
	}
}


#pragma mark -
#pragma mark UIView extensions

@interface UIView (CC3)

/** Returns this view's controller, or nil if it doesn't have one. */
@property(nonatomic, readonly) UIViewController* viewController;

@end


#pragma mark -
#pragma mark UIViewController extensions

@interface UIViewController (CC3)
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_5_0
/** Add to prior versions of iOS to support forward compatibility. */
-(void) viewDidLayoutSubviews;
#endif
@end


#pragma mark -
#pragma mark UIColor extensions

/** Extension category to support cocos3d functionality. */
@interface UIColor(CC3)

/** Returns a transparent ccColor4F struct containing the RGBA values for this color. */
-(ccColor4F) asCCColor4F;

/** Returns an autoreleased UIColor instance created from the RGBA values in the specified ccColor4F. */
+(UIColor*) colorWithCCColor4F: (ccColor4F) rgba;

@end


#pragma mark -
#pragma mark Open GL Context

/** GL context under iOS */
#define CC3GLContext	EAGLContext

/** Extension category to support cocos3d functionality. */
@interface EAGLContext (CC3)

/** Ensures this GL context is the GL context for the currently running thread. */
-(void) ensureCurrentContext;

/** Clears the GL context for the currently running thread. */
+(void) clearCurrentContext;

/** 
 * Returns a GL context that shares GL content with this context.
 *
 * The returned context can be used wherever a separate GL context that shares common GL
 * content with this is required. Typically, this method is used to retrieve a secondary
 * GL context to be used for background loading on a different thread.
 */
-(CC3GLContext*) asSharedContext;

@end


#pragma mark -
#pragma mark Miscellaneous extensions and functions

/** Returns a string description of the specified UIInterfaceOrientation. */
NSString* NSStringFromUIInterfaceOrientation(UIInterfaceOrientation uiOrientation);

/** Returns a string description of the specified UIDeviceOrientation. */
NSString* NSStringFromUIDeviceOrientation(UIDeviceOrientation deviceOrientation);


#endif	// CC3_IOS
