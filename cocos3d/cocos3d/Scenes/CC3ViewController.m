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
#import "CC3ControllableLayer.h"
#import "CC3Logging.h"


@implementation CC3ViewController

@synthesize controlledNode=_controlledNode;

-(void) dealloc {
	[_controlledNode release];
	[super dealloc];
}

-(BOOL) isOverlayingDeviceCamera { return NO; }

-(void) setIsOverlayingDeviceCamera: (BOOL) isOverlayingDeviceCamera {}

-(CC3GLView*) view { return (CC3GLView*)super.view; }

-(void) setView:(CC3GLView *)view {
	CC3Assert(!view || [view isKindOfClass: [CC3GLView class]], @"%@ may only be attached to a CC3GLView. %@ is not of that class.", self, view);
	super.view = view;
}

-(CCNode*) controlledNode { return _controlledNode; }

-(void) setControlledNode: (CCNode*) aNode {
	if (aNode == _controlledNode) return;
	
	[_controlledNode release];
	_controlledNode = [aNode retain];
	
	aNode.controller = self;
}

#if CC3_CC2_2 && CC3_IOS

-(void) startAnimation { [super startAnimation]; }

-(void) stopAnimation { [super stopAnimation]; }

#else

-(void) startAnimation { [CCDirector.sharedDirector startAnimation]; }

-(void) stopAnimation { [CCDirector.sharedDirector stopAnimation]; }

#endif	// CC3_CC2_2 && CC3_IOS

-(void) pauseAnimation { [CCDirector.sharedDirector pause]; }

-(void) resumeAnimation { [CCDirector.sharedDirector resume]; }

-(void) terminateOpenGL {
	self.controlledNode = nil;
	
	// If the controller is not combined with the director, clear the view separately.
	// Then, end the CCDirector.
	if ( ![self isKindOfClass: CCDirector.class] ) self.view = nil;
	[self endDirector];
	
	[CC3OpenGL terminateOpenGL];
}

-(void) endDirector {
	CC3Texture.shouldCacheAssociatedCCTextures = NO;
	[CCDirector.sharedDirector end];
}

@end

