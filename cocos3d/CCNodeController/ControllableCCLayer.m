/*
 * ControllableCCLayer.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010 The Brenwill Workshop Ltd.
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
 * See header file ControllableCCLayer.h for full API documentation.
 */

#import "ControllableCCLayer.h"


@implementation ControllableCCLayer

@synthesize controller, isColored, homeContentSize, alignContentSizeWithDeviceOrientation;

- (void)dealloc {
	controller = nil;		// delegate - not retained
    [super dealloc];
}

// Initializes without a colored background.
- (id) init {
	if( (self = [super init]) ) {
		isColored = NO;
		[self initInitialState];
	}
	return self;
}

// Initializes with a colored background.
- (id) initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h {
	if( (self = [super initWithColor: color width: w  height: h]) ) {
		isColored = YES;
		[self initInitialState];
	}
	return self;
}

// Initializes the instance, including setting the alignContentSizeWithDeviceOrientation property to YES.
-(void) initInitialState {
	alignContentSizeWithDeviceOrientation = YES;
}

// Superclass template method override.
// If this CCLayerColor has been configured with a background color and blending function
// and is not currently overlaying the device camera and this CCLayerColor, draws the
// background color blend, otherwise does nothing.
-(void) draw {
	if(self.isColored && !self.isOverlayingDeviceCamera) {
		[super draw];
	}
}


#pragma mark Device orientation support

// Overridden to call didUpdateContentSizeFrom: notification template method
// if the content size really did change.
-(void) setContentSize: (CGSize) aSize {
	CGSize oldSize = self.contentSize;
	[super setContentSize: aSize];
	if(!CGSizeEqualToSize(aSize, oldSize) ) {
		[self didUpdateContentSizeFrom: oldSize];
	}
}

// Default behaviour updates the homeContentSize from the contentSize, taking into consideration
// the current device location. When in landscape orientation, the homeContentSize is the transpose
// of contentSize. Subclasses that override should be sure to call this superclass implementation.
-(void) didUpdateContentSizeFrom: (CGSize) oldSize {
	CGSize oldHomeSize = self.homeContentSize;
	CGSize newHomeSize;
	CGSize cs = self.contentSize;
	switch([[CCDirector sharedDirector]deviceOrientation]) {
		case kCCDeviceOrientationLandscapeLeft:
		case kCCDeviceOrientationLandscapeRight:
			newHomeSize = CGSizeMake(cs.height, cs.width);
			break;
		case kCCDeviceOrientationPortrait:
		case kCCDeviceOrientationPortraitUpsideDown:
			newHomeSize = cs;
			break;
		default:
			NSAssert(NO, @"Unknown device orientation");
			newHomeSize = oldHomeSize;
			break;
	}
	if(!CGSizeEqualToSize(newHomeSize, oldHomeSize) ) {
		homeContentSize = newHomeSize;
		[self didUpdateHomeContentSizeFrom: oldHomeSize];
	}
}

// Default does nothing. Subclasses can override, but should call this superclass implementation.
-(void) didUpdateHomeContentSizeFrom: (CGSize) oldHomeSize {}

// Called from the CCNodeController when the device orientation has changed.
-(void) deviceOrientationDidChange: (ccDeviceOrientation) newOrientation {
	
	// If configured to align with the device orientation, transpose the
	// contentSize if we are flipping between portrait and landscape mode.
	// The homeContentSize is used to keep track of portrait contentSize.
	if(alignContentSizeWithDeviceOrientation) {
		CGSize hcs = self.homeContentSize;
		switch(newOrientation) {
			case kCCDeviceOrientationLandscapeLeft:
			case kCCDeviceOrientationLandscapeRight:
				self.contentSize = CGSizeMake(hcs.height, hcs.width);
				break;
			case kCCDeviceOrientationPortrait:
			case kCCDeviceOrientationPortraitUpsideDown:
				self.contentSize = hcs;
				break;
			default:
				NSAssert(NO, @"Change to unknown device orientation");
				break;
		}
	}
	// Propagate to child nodes
	[super deviceOrientationDidChange: newOrientation];
}


#pragma mark Device camera support

-(BOOL) isOverlayingDeviceCamera {
	return controller ? controller.isOverlayingDeviceCamera : NO;
}

// Called when this layer is first diplayed, and subsequently whenever the
// layer is overlayed on the camera, or reverted back to a normal display.
// If this layer is overlaying the device camera, the GL clear color is
// set to transparent black, otherwise it is set to opaque black.
-(void) onEnter {
	[super onEnter];
	if(self.isOverlayingDeviceCamera) {
		glClearColor(0.0, 0.0, 0.0, 0.0);		// Transparent black
	} else {
		glClearColor(0.0, 0.0, 0.0, 1.0);		// Opaque black
	}
}

// Called when this layer is first diplayed, and subsequently whenever the
// layer is overlayed on the camera, or reverted back to a normal display.
-(void) onExit {
	[super onExit];
}
	
@end
