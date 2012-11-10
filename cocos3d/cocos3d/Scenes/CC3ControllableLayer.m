/*
 * CC3ControllableLayer.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd.
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
#import "CC3IOSExtensions.h"
#import "CC3CC2Extensions.h"
#import "CC3Logging.h"


@implementation CC3ControllableLayer

@synthesize isColored=isColored_, alignContentSizeWithDeviceOrientation=alignContentSizeWithDeviceOrientation_;

-(void) dealloc {
	controller_ = nil;		// delegate - not retained
    [super dealloc];
}

// Override to store the controller in the unretained iVar
-(UIViewController*) controller { return controller_; }
-(void) setController: (UIViewController*) aController { controller_ = aController; }


#pragma mark Drawing

// Initializes without a colored background.
// Must avoid super init because as of cocos2d 1.1, it sets the contentSize to zero.
- (id) init {
	CGSize s = CCDirector.sharedDirector.winSize;
	if( (self = [super initWithColor: ccc4(0,0,0,0) width: s.width  height: s.height]) ) {
		isColored_ = NO;
		[self initInitialState];
	}
	return self;
}

// Initializes with a colored background.
- (id) initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h {
	LogTrace(@"%@ creating with width: %.1f height: %.1f", self, w, h);
	if( (self = [super initWithColor: color width: w  height: h]) ) {
		isColored_ = YES;
		[self initInitialState];
	}
	return self;
}

// Initializes the instance, including setting the alignContentSizeWithDeviceOrientation property to YES.
-(void) initInitialState {
	alignContentSizeWithDeviceOrientation_ = YES;
}


#pragma mark Drawing

/**
 * Superclass template method override. If this layer has been configured with a background color,
 * and is not overlaying the device camera, the background color blend is drawn, otherwise it is not.
 */
-(void) draw { if(self.isColored && !self.isOverlayingDeviceCamera) [super draw]; }


#pragma mark Device orientation support

-(void) setContentSize: (CGSize) aSize {
	CGSize oldSize = self.contentSize;
	[super setContentSize: aSize];
	if( !CGSizeEqualToSize(aSize, oldSize) ) [self didUpdateContentSizeFrom: oldSize];
}

-(void) didUpdateContentSizeFrom: (CGSize) oldSize {}

/**
 * Invoked by the CC3UIViewController when the device orientation has changed. If configured to align
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
			LogTrace(@"%@ changing orientation aspect from %@ to %@", self,
					 NSStringFromUIDeviceOrientation(oldOrientation),
					 NSStringFromUIDeviceOrientation(newOrientation));
		}
	}
	
	// Propagate to child nodes
	[super viewDidRotateFrom: oldOrientation to: newOrientation];
}


#pragma mark Device camera support

-(BOOL) isOverlayingDeviceCamera { return controller_ ? controller_.isOverlayingDeviceCamera : NO; }

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

// Keep the compiler happy with method re-declaration for documentation
-(void) onExit { [super onExit]; }

@end



#pragma mark -
#pragma mark UIViewController extension support

@implementation UIViewController (CC3ControllableLayer)

-(BOOL) isOverlayingDeviceCamera { return NO; }

@end























