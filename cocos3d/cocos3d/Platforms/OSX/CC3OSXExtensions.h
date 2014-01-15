/*
 * CC3OSXExtensions.h
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

#if CC3_OSX

/** OSX equivalents for iOS declaration */
#define UITouch						NSObject
#define UIEvent						NSObject
#define UIGestureRecognizer			NSObject

#define NSTextAlignmentLeft			NSLeftTextAlignment
#define NSTextAlignmentCenter		NSCenterTextAlignment
#define NSTextAlignmentRight		NSRightTextAlignment
#define NSTextAlignmentJustified	NSJustifiedTextAlignment
#define NSTextAlignmentNatural		NSNaturalTextAlignment

static inline NSString* NSStringFromCGPoint(CGPoint pt) { return NSStringFromPoint(*(NSPoint*)&pt); }

static inline NSString* NSStringFromCGSize(CGSize sz) { return NSStringFromSize(*(NSSize*)&sz); }

static inline NSString* NSStringFromCGRect(CGRect rect) { return NSStringFromRect(*(NSRect*)&rect); }

typedef enum {
    UIDeviceOrientationUnknown,
    UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    UIDeviceOrientationFaceUp,              // Device oriented flat, face up
    UIDeviceOrientationFaceDown             // Device oriented flat, face down
} UIDeviceOrientation;

typedef enum {
    UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
    UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
    UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
    UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
} UIInterfaceOrientation;


/** For consistency, add compilation support for UIInterfaceOrientationMask introduced in iOS 6.0. */
typedef enum {
	UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
	UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
	UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
	UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
	UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
	UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
	UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
} UIInterfaceOrientationMask;

#define UIDeviceOrientationIsValidInterfaceOrientation(orientation) ((orientation) == UIDeviceOrientationPortrait || (orientation) == UIDeviceOrientationPortraitUpsideDown || (orientation) == UIDeviceOrientationLandscapeLeft || (orientation) == UIDeviceOrientationLandscapeRight)
#define UIInterfaceOrientationIsPortrait(orientation)  ((orientation) == UIInterfaceOrientationPortrait || (orientation) == UIInterfaceOrientationPortraitUpsideDown)
#define UIInterfaceOrientationIsLandscape(orientation) ((orientation) == UIInterfaceOrientationLandscapeLeft || (orientation) == UIInterfaceOrientationLandscapeRight)


#pragma mark -
#pragma mark Open GL Context

/** GL context under iOS */
#define CC3GLContext	NSOpenGLContext

/** Extension category to support cocos3d functionality. */
@interface NSOpenGLContext (CC3)

/** Ensures this GL context is the GL context for the currently running thread. */
-(void) ensureCurrentContext;

/**
 * Returns a GL context that shares GL content with this context.
 *
 * The returned context can be used wherever a separate GL context that shares common GL
 * content with this is required. Typically, this method is used to retrieve a secondary
 * GL context to be used for background loading on a different thread.
 */
-(CC3GLContext*) asSharedContext;

@end

#endif	// CC3_OSX
