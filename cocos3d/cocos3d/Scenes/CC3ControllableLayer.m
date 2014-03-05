/*
 * CC3ControllableLayer.m
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
 * See header file CC3ControllableLayer.h for full API documentation.
 */

#import "CC3ControllableLayer.h"
#import "CC3CC2Extensions.h"
#import "CC3OpenGL.h"
#import "CC3Logging.h"


@implementation CC3ControllableLayer

-(void) dealloc {
	_controller = nil;		// weak reference
	[super dealloc];
}

/** If not set directly, try to retrieve it from an ancestor controllable node. */
-(CC3ViewController*) controller {
	if (!_controller) self.controller = super.controller;
	CC3Assert(_controller, @"%@ requires a controller.", self);
	return _controller;
}

-(void) setController: (CC3ViewController*) aController {
	_controller = aController;		// weak reference
}


#pragma mark Allocation and initialization

-(id) init {
	if( (self = [super init]) ) {
		_controller = nil;
		[self initInitialState];		// Deprecated legacy
	}
	return self;
}

+(id) layer { return [[[self alloc] init] autorelease]; }

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }


#pragma mark Device orientation support

-(void) setContentSize: (CGSize) aSize {
	CGSize oldSize = self.contentSize;
	[super setContentSize: aSize];
	if( !CGSizeEqualToSize(aSize, oldSize) ) [self didUpdateContentSizeFrom: oldSize];
}

-(void) didUpdateContentSizeFrom: (CGSize) oldSize {}


#pragma mark Device camera support

-(BOOL) isOverlayingDeviceCamera { return self.controller.isOverlayingDeviceCamera; }

// If this layer is overlaying the device camera, the GL clear color is
// set to transparent black, otherwise it is set to opaque black.
-(void) onEnter {
	[super onEnter];
	CC3OpenGL.sharedGL.clearColor = self.isOverlayingDeviceCamera ? kCCC4FBlackTransparent : kCCC4FBlack;
}


#pragma mark Deprecated functionality

-(BOOL) alignContentSizeWithDeviceOrientation { return NO; }
-(void) setAlignContentSizeWithDeviceOrientation: (BOOL) alignContentSizeWithDeviceOrientation {}
-(id) initWithColor: (ccColor4B) color { return [self init]; }
+(id) layerWithColor: (ccColor4B) color { return [[[self alloc] init] autorelease]; }
-(void) initInitialState {}
-(BOOL) isColored { return NO; }
-(id) initWithController: (CC3ViewController*) controller {
	if( (self = [self init]) ) {
		self.controller = controller;
	}
	return self;
}
+(id) layerWithController: (CC3ViewController*) controller {
	return [[[self alloc] initWithController: controller] autorelease];
}


@end


#pragma mark -
#pragma mark CCNode extension to support controlling nodes from a CC3ViewController

@implementation CCNode (CC3ViewController)

-(CC3ViewController*) controller { return self.parent.controller; }

-(void) setController: (CC3ViewController*) aController {
	for (CCNode* child in self.children) child.controller = aController;
}

-(void) viewDidRotateFrom: (UIInterfaceOrientation) oldOrientation to: (UIInterfaceOrientation) newOrientation {
	for (CCNode* child in self.children)
		[child viewDidRotateFrom: oldOrientation to: newOrientation];
}

@end






















