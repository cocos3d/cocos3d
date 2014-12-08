/*
 * TileLayer.m
 *
 * Cocos3D 2.0.2
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
 * 
 * See header file TileLayer.h for full API documentation.
 */

#import "TileLayer.h"

@interface CC3Layer (TemplateMethods)
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType;
@end

@implementation TileLayer

-(void) initializeControls {
	self.userInteractionEnabled = YES;	// Enable touch event handling for 3D object picking
}

#if CC3_CC2_CLASSIC

/**
 * The ccTouchMoved:withEvent: method is optional. Since the touch-move events are both
 * voluminous and seldom used, the implementation of this method has been left out of
 * the default CC3Layer implementation. To receive and handle touch-move events for
 * object picking, copy the following method implementation to your CC3Layer subclass.
 *
 * This method is used by Cocos2D versions prior to v3.
 */
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}

#else

/**
 * The touchMoved:withEvent: method is optional. Since the touch-move events are both
 * voluminous and seldom used, the implementation of this method has been left out of
 * the default CC3Layer implementation. To receive and handle touch-move events for
 * object picking, copy the following method implementation to your CC3Layer subclass.
 *
 * This method is used by Cocos2D versions v3 and above.
 */
-(void) touchMoved: (UITouch*) touch withEvent: (UIEvent*) event {
	if ( ![self handleTouch: touch ofType: kCCTouchMoved] )
		[super touchMoved: touch withEvent: event];
}

#endif	// CC3_CC2_CLASSIC

@end
