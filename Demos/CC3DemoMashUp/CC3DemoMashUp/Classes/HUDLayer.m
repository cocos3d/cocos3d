/*
 * HUDLayer.m
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
 * See header file HUDLayer.h for full API documentation.
 */

#import "HUDLayer.h"
#import "CC3DemoMashUpLayer.h"

@implementation HUDLayer

-(void) initializeControls {
	self.isTouchEnabled = YES;		// Enable touch event handling
	[self scheduleUpdate];
}

/**
 * Overridden to handle touch events here, instead of passing them to the CC3Scene.
 *
 * When a touch ended event occurs, close this layer.
 */
-(BOOL) handleTouchType: (uint) touchType at: (CGPoint) touchPoint {
	switch (touchType) {
		case kCCTouchEnded:
			[((CC3DemoMashUpLayer*)self.parent) toggleGlobeHUDFromTouchAt: touchPoint];
			break;
		default:
			break;
	}
	return YES;
}

@end
