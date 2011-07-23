/*
 * CCNodeController.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CCNodeController.h for full API documentation.
 */

#import "CCNodeController.h"

// The event notification type for device orientation rotations
#define kDeviceOrientationNotification @"UIDeviceOrientationDidChangeNotification"

// The height of the device camera toolbar
#define kDeviceCameraToolbarHeight 54.0


#pragma mark CCNode interface category for controlled node support

@implementation CCNode (ControlledCCNodeProtocol)

-(void) deviceOrientationDidChange: (ccDeviceOrientation) newOrientation {
	if (children_) {
		for (CCNode* child in children_) {
			[child deviceOrientationDidChange: newOrientation];
		}
	}
}

@end


#pragma mark CCNodeController implementation

@implementation CCNodeController

@synthesize controlledNode, defaultCCDeviceOrientation;

- (void)dealloc {
	// Force deregistration of notifications
	if(doesAutoRotate) {
		self.doesAutoRotate = NO;
	}
	[controlledNode release];
	[picker release];
    [super dealloc];
}

-(CCNode<ControlledCCNodeProtocol>*) controlledNode {
	return controlledNode;
}

-(void) setControlledNode: (CCNode<ControlledCCNodeProtocol>*) aNode {
	id oldNode = controlledNode;
	controlledNode = [aNode retain];
	[oldNode release];
	aNode.controller = self;
}

-(void) runSceneOnNode: (CCNode<ControlledCCNodeProtocol>*) aNode {
	self.controlledNode = aNode;
	CCDirector* dir = [CCDirector sharedDirector];
	CCScene *scene = [CCScene node];
	[scene addChild: aNode];
	if(dir.runningScene) {
		[dir replaceScene: scene];
	} else {
		[dir runWithScene: scene];
	}
}


#pragma mark Device orientation support

-(BOOL) doesAutoRotate {
	return doesAutoRotate;
}

// Register or deregister for device orientation notifications
-(void) setDoesAutoRotate: (BOOL) shouldAutoRotate {
	if(doesAutoRotate != shouldAutoRotate) {
		doesAutoRotate = shouldAutoRotate;
		if(doesAutoRotate) {
			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			[[NSNotificationCenter defaultCenter]
			 addObserver: self
			 selector: @selector(deviceOrientationDidChange:)
			 name: kDeviceOrientationNotification
			 object: nil];
		} else {
			[[NSNotificationCenter defaultCenter]
			 removeObserver: self
			 name: kDeviceOrientationNotification
			 object: nil];
			[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		}
	}
}

-(void) deviceOrientationDidChange: (NSNotification *)notification {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	ccDeviceOrientation ccOrientation;
	
	// Not all UIDeviceOrientation enumerations are mapped to ccDeviceOrientations.
	// Ignore those that are not.
	switch (orientation) {
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			ccOrientation = (ccDeviceOrientation)orientation;
			break;
		default:
			return;		// Abort change if orientation not supported
	}
	if (ccOrientation != [CCDirector sharedDirector].deviceOrientation) {
		[CCDirector sharedDirector].deviceOrientation = ccOrientation;
		[controlledNode deviceOrientationDidChange: ccOrientation];
	}
}


#pragma mark Device camera support

-(BOOL) isOverlayingDeviceCamera {
	return isOverlayingDeviceCamera;
}

-(void) setIsOverlayingDeviceCamera: (BOOL) aBool {
	if(aBool != self.isOverlayingDeviceCamera) {
		if(!aBool || self.isDeviceCameraAvailable) {

			// Before switching, if the CCNode is running, send it onExit to stop it
			BOOL nodeRunning = controlledNode.isRunning;
			if(nodeRunning) {
				[controlledNode onExit];
			}

			// Let subclasses of this controller know about the pending change
			[self willChangeIsOverlayingDeviceCamera];

			// Update the value
			isOverlayingDeviceCamera = aBool;

			if(aBool) {
				// If overlaying, present the picker modally.
				[self presentModalViewController: self.picker animated: NO];
			} else {
				// If reverting, dismiss the modal picker.
				[self dismissModalViewControllerAnimated: NO];
			}

			// Let subclasses of this controller know that the change has happened
			[self didChangeIsOverlayingDeviceCamera];

			// After switching, if the CCNode was running, send it onEnter to restart it
			if(nodeRunning) {
				[controlledNode onEnter];
			}
		}
	}
}

// Default does nothing, subclasses can override
-(void) willChangeIsOverlayingDeviceCamera {}

// Default does nothing, subclasses can override
-(void) didChangeIsOverlayingDeviceCamera {}

-(BOOL) isDeviceCameraAvailable {
	// Check picker first as simple shortcut...we'll only have a picker if device camera is actually avaiable
	return picker || [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

-(UIImagePickerController*) picker {
	if(!picker && self.isDeviceCameraAvailable) {
		picker = [self newDeviceCameraPicker];
	}
	return picker;
}

// Allocates and initializes a picker controller for the device camera.
// Will return nil if the device does not support a camera.
-(UIImagePickerController*) newDeviceCameraPicker {
	UIImagePickerController* newPicker = nil;
	if(self.isDeviceCameraAvailable) {
		newPicker = [UIImagePickerController new];
		newPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		newPicker.delegate = nil;
		newPicker.cameraOverlayView = self.view;
		
		// Hide the camera and navigation controls, force full screen, 
		// and scale the device camera image to cover the full screen
		newPicker.showsCameraControls = NO;
		newPicker.navigationBarHidden = YES;
		newPicker.toolbarHidden = YES;
		newPicker.wantsFullScreenLayout = YES;
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		CGFloat deviceCameraScaleup = screenHeight / (screenHeight - kDeviceCameraToolbarHeight);
		newPicker.cameraViewTransform = CGAffineTransformScale(newPicker.cameraViewTransform, deviceCameraScaleup, deviceCameraScaleup);
	}
	return newPicker;
}


#pragma mark Instance initialization and management

-(id) init {
    if( (self = [super init]) ) {
		isOverlayingDeviceCamera = NO;
		doesAutoRotate = NO;
		defaultCCDeviceOrientation = kCCDeviceOrientationLandscapeLeft;
		
		// Set the controller's view to the OpenGL view, and set the view's
		// background color to clear so that device camera can show through.
		// Set view to opaque for better performance.
		UIView* myView = [CCDirector sharedDirector].openGLView;
		self.view = myView;
		myView.backgroundColor = [UIColor clearColor];
		myView.opaque = YES;
	}
	return self;
}

+(id) controller {
	return [[[self alloc] init] autorelease];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

	// If picker exists, and we're not currently overlaying the device camera, release the picker
	if(picker && !self.isOverlayingDeviceCamera) {
		UIImagePickerController* p = picker;
		picker = nil;
		[p release];
	}
}


@end
