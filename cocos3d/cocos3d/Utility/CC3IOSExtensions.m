/*
 * CC3IOSExtensions.m
 *
 * cocos3d 0.7.1
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




#pragma mark -
#pragma mark NSObject extensions

@implementation NSObject (CC3)
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

@end

@implementation UIPanGestureRecognizer (CC3)

-(CGPoint) translation { return [self translationInView: self.view]; }

-(CGPoint) velocity { return [self velocityInView: self.view]; }

@end


#pragma mark -
#pragma mark UIColor extensions

@implementation UIColor (CC3)

-(ccColor4F) asCCColor4F {
	ccColor4F rgba = (ccColor4F){ 1.0, 1.0, 1.0, 1.0 };  // initialize to white
	
	CGColorRef cgColor= self.CGColor;
	size_t componentCount = CGColorGetNumberOfComponents(cgColor);
	const CGFloat* colorComponents = CGColorGetComponents(cgColor);
	switch(componentCount) {
		case 4:			// RGB + alpha: set alpha then fall through to RGB 
			rgba.a = colorComponents[3];
		case 3:			// RGB: alpha already set
			rgba.r = colorComponents[0];
			rgba.g = colorComponents[1];
			rgba.b = colorComponents[2];
			break;
		case 2:			// gray scale + alpha: set alpha then fall through to gray scale
			rgba.a = colorComponents[1];
		case 1:		// gray scale: alpha already set
			rgba.r = colorComponents[0];
			rgba.g = colorComponents[0];
			rgba.b = colorComponents[0];
			break;
		default:	// if all else fails, return white which is already set
			break;
	}
	return rgba;
}

+(UIColor*) colorWithCCColor4F: (ccColor4F) rgba {
	return [UIColor colorWithRed: rgba.r green: rgba.g blue: rgba.b alpha: rgba.a];
}

@end

