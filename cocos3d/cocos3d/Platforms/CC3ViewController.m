/*
 * CC3ViewController.m
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
 * 
 * See header file CC3ViewController.h for full API documentation.
 */

#import "CC3ViewController.h"
#import "CC3Logging.h"


#if (!CC3_CC2_RENDER_QUEUE)

@implementation CC3ViewController

-(CCGLView*) view { return (CCGLView*)super.view; }

-(void) setView: (CCGLView*) view {
	CC3Assert(!view || [view isKindOfClass: [CCGLView class]], @"%@ may only be attached to a CCGLView. %@ is not of that class.", self, view);
	super.view = view;
}

#if CC3_IOS && !CC3_CC2_1

-(void) startAnimation { [super startAnimation]; }

-(void) stopAnimation { [super stopAnimation]; }

#else

-(void) startAnimation { [CCDirector.sharedDirector startAnimation]; }

-(void) stopAnimation { [CCDirector.sharedDirector stopAnimation]; }

#endif	// CC3_IOS && !CC3_CC2_1

-(void) pauseAnimation { [CCDirector.sharedDirector pause]; }

-(void) resumeAnimation { [CCDirector.sharedDirector resume]; }


#pragma mark Deprecated

-(CCNode*) controlledNode { return nil; }

-(void) setControlledNode: (CCNode*) aNode {}

-(BOOL) isOverlayingDeviceCamera { return NO; }

-(void) setIsOverlayingDeviceCamera: (BOOL) isOverlayingDeviceCamera {}

@end

#endif // (!CC3_CC2_RENDER_QUEUE)

