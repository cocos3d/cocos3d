/*
 * CC3IOSExtensions.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3IOSExtensions.h for full API documentation.
 */

#import "CC3IOSExtensions.h"
#import "CC3Foundation.h"


#pragma mark -
#pragma mark NSObject extensions

@implementation NSObject (CC3)

-(id) autoreleasedCopy { return [[self copy] autorelease]; }

// Deprecated
-(id) copyAutoreleased { return [[self copy] autorelease]; }

@end


#pragma mark -
#pragma mark Gesture Recognizer extensions

@implementation UIGestureRecognizer (CC3)

-(void) cancel {
    self.enabled = NO;
    self.enabled = YES;
}

-(CGPoint) location { return [self locationInView: self.view]; }

-(NSString*) stateName {
	switch (self.state) {
		case UIGestureRecognizerStatePossible:
			return @"UIGestureRecognizerStatePossible";
		case UIGestureRecognizerStateBegan:
			return @"UIGestureRecognizerStateBegan";
		case UIGestureRecognizerStateChanged:
			return @"UIGestureRecognizerStateChanged";
		case UIGestureRecognizerStateEnded:
			return @"UIGestureRecognizerStateEnded";
		case UIGestureRecognizerStateCancelled:
			return @"UIGestureRecognizerStateCancelled";
		case UIGestureRecognizerStateFailed:
			return @"UIGestureRecognizerStateFailed";
		default:
			return @"GestureRecognizerStateUnknown";
	}
}

@end

@implementation UIPanGestureRecognizer (CC3)

-(CGPoint) translation { return [self translationInView: self.view]; }

-(CGPoint) velocity { return [self velocityInView: self.view]; }

@end


#pragma mark -
#pragma mark UIColor extensions

@implementation UIColor (CC3)

-(ccColor4F) asCCColor4F { return CCC4FFromCGColor(self.CGColor); }

+(UIColor*) colorWithCCColor4F: (ccColor4F) rgba {
	return [UIColor colorWithRed: rgba.r green: rgba.g blue: rgba.b alpha: rgba.a];
}

@end


#pragma mark -
#pragma mark Miscellaneous extensions and functions

/** Returns a string description of the specified UIInterfaceOrientation. */
NSString* NSStringFromUIInterfaceOrientation(UIInterfaceOrientation uiOrientation) {
	switch (uiOrientation) {
		case UIInterfaceOrientationLandscapeLeft:
			return @"UIInterfaceOrientationLandscapeLeft";
		case UIInterfaceOrientationLandscapeRight:
			return @"UIInterfaceOrientationLandscapeRight";
		case UIInterfaceOrientationPortraitUpsideDown:
			return @"UIInterfaceOrientationPortraitUpsideDown";
		case UIInterfaceOrientationPortrait:
		default:
			return @"UIInterfaceOrientationPortrait";
	}
}

/** Returns a string description of the specified UIDeviceOrientation. */
NSString* NSStringFromUIDeviceOrientation(UIDeviceOrientation deviceOrientation) {
	switch (deviceOrientation) {
		case UIDeviceOrientationPortrait:
			return @"UIDeviceOrientationPortrait";
		case UIDeviceOrientationPortraitUpsideDown:
			return @"UIDeviceOrientationPortraitUpsideDown";
		case UIDeviceOrientationLandscapeLeft:
			return @"UIDeviceOrientationLandscapeLeft";
		case UIDeviceOrientationLandscapeRight:
			return @"UIDeviceOrientationLandscapeRight";
		case UIDeviceOrientationFaceUp:
			return @"UIDeviceOrientationFaceUp";
		case UIDeviceOrientationFaceDown:
			return @"UIDeviceOrientationFaceDown";
		case UIDeviceOrientationUnknown:
		default:
			return @"UIDeviceOrientationUnknown";
	}
}

