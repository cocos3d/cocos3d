/*
 * CC3ControllableLayer.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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

@synthesize alignContentSizeWithDeviceOrientation=_alignContentSizeWithDeviceOrientation;

-(void) dealloc {
	_controller = nil;		// delegate - not retained
    [super dealloc];
}

// Override to store the controller in the unretained iVar
-(CC3ViewController*) controller { return _controller; }
-(void) setController: (CC3ViewController*) aController { _controller = aController; }


#pragma mark Allocation and initialization

// Will fail assertion with nil controller
-(id) init { return [self initWithController: nil]; }

-(id) initWithController: (CC3ViewController*) controller {
	CC3Assert(controller, @"%@ requires a CC3ViewController controller.", self);
	if( (self = [super init]) ) {
		_controller = controller;		// not retained
		_alignContentSizeWithDeviceOrientation = YES;
		[self initInitialState];		// Deprecated legacy
	}
	return self;
}

+(id) layerWithController: (CC3ViewController*) controller {
	return [[[self alloc] initWithController: controller] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

// Deprecated legacy
-(id) initWithColor: (ccColor4B) color { return [self init]; }
+(id) layerWithColor: (ccColor4B) color { return [[[self alloc] init] autorelease]; }
-(void) initInitialState {}
-(BOOL) isColored { return NO; }


#pragma mark Device orientation support

-(void) setContentSize: (CGSize) aSize {
	CGSize oldSize = self.contentSize;
	[super setContentSize: aSize];
	if( !CGSizeEqualToSize(aSize, oldSize) ) [self didUpdateContentSizeFrom: oldSize];
}

-(void) didUpdateContentSizeFrom: (CGSize) oldSize {}

/**
 * Invoked by the CC3ViewController when the device orientation has changed. If configured to align
 * with the device orientation, transpose the contentSize when flipping between portrait and landscape.
 */
-(void) viewDidRotateFrom: (UIInterfaceOrientation) oldOrientation to: (UIInterfaceOrientation) newOrientation {
	
	if(self.alignContentSizeWithDeviceOrientation) {
		// Explicit tests both ways, since xor or == will not be accurate if functions
		// return truth values that are not exactly 1.
		BOOL isChangingAspect = ((UIInterfaceOrientationIsLandscape(oldOrientation) &&
								  UIInterfaceOrientationIsPortrait(newOrientation)) ||
								 (UIInterfaceOrientationIsPortrait(oldOrientation) &&
								  UIInterfaceOrientationIsLandscape(newOrientation)));
		if (isChangingAspect) {
			CGSize cs = self.contentSize;
			self.contentSize = CGSizeMake(cs.height, cs.width);
		}
	}
	
	// Propagate to child nodes
	[super viewDidRotateFrom: oldOrientation to: newOrientation];
}


#pragma mark Device camera support

-(BOOL) isOverlayingDeviceCamera { return _controller ? _controller.isOverlayingDeviceCamera : NO; }

// If this layer is overlaying the device camera, the GL clear color is
// set to transparent black, otherwise it is set to opaque black.
-(void) onEnter {
	[super onEnter];
	CC3OpenGL.sharedGL.clearColor = self.isOverlayingDeviceCamera ? kCCC4FBlackTransparent : kCCC4FBlack;
}

// Keep the compiler happy with method re-declaration for documentation
-(void) onExit { [super onExit]; }

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






















