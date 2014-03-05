/*
 * CC3DeviceCameraOverlayUIViewController.m
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
 * See header file CC3DeviceCameraOverlayUIViewController.h for full API documentation.
 */

#import "CC3DeviceCameraOverlayUIViewController.h"

#if CC3_IOS

#if CC3_AV_CAPTURE_SUPPORTED

#import "CC3ControllableLayer.h"
#import "CC3Logging.h"
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>


#pragma mark -
#pragma mark CC3DeviceCameraOverlayUIViewController

@implementation CC3DeviceCameraOverlayUIViewController

-(void) dealloc {
	[_deviceCameraView release];
	[super dealloc];
}

-(BOOL) isOverlayingDeviceCamera { return _isOverlayingDeviceCamera; }

-(void) setIsOverlayingDeviceCamera: (BOOL) aBool {
	if(aBool != self.isOverlayingDeviceCamera) {
		if(!aBool || self.isDeviceCameraAvailable) {

			// Before switching, if the CCNode is running, send it onExit to stop it
			BOOL nodeRunning = _controlledNode.isRunningInActiveScene;
			if(nodeRunning) [_controlledNode onExit];

			// Let subclasses of this controller know about the pending change
			[self willChangeIsOverlayingDeviceCamera];

			// Update the value
			_isOverlayingDeviceCamera = aBool;

			if(aBool) {
				// If overlaying, set the background color to clear, and add the picker view.
				UIView* myView = self.view;
				UIWindow* window = myView.window;
				myView.backgroundColor = [UIColor clearColor];
				[window addSubview: self.deviceCameraView];
				[window bringSubviewToFront: myView];
				[_deviceCameraView.layer.session startRunning];
			} else {
				// If reverting, remove the clear background color, and remove the picker view from the window.
				self.view.backgroundColor = nil;
				[_deviceCameraView.layer.session stopRunning];
				[_deviceCameraView removeFromSuperview];
			}

			// Let subclasses of this controller know that the change has happened
			[self didChangeIsOverlayingDeviceCamera];

			// After switching, if the CCNode was running, send it onEnter to restart it
			if(nodeRunning) [_controlledNode onEnter];
		}
	}
}

// Default does nothing, subclasses can override
-(void) willChangeIsOverlayingDeviceCamera {}

// Default does nothing, subclasses can override
-(void) didChangeIsOverlayingDeviceCamera {}

// Check view first as simple shortcut...we'll only have a view if device camera is actually avaiable
-(BOOL) isDeviceCameraAvailable {
	return _deviceCameraView || [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

-(CC3AVCameraView*) deviceCameraView {
	if ( !_deviceCameraView && self.isDeviceCameraAvailable ) {
		
		AVCaptureDevice* camDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
		AVCaptureInput* avInput = [AVCaptureDeviceInput deviceInputWithDevice: camDevice error: nil];
		AVCaptureSession* avSession = [[[AVCaptureSession alloc] init] autorelease];
		[avSession addInput: avInput];
		
		_deviceCameraView = [[CC3AVCameraView alloc] initWithFrame: self.view.frame];	// retained
		
		AVCaptureVideoPreviewLayer* avLayer = _deviceCameraView.layer;
		avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		avLayer.session = avSession;
	}
	return _deviceCameraView;
}


#pragma mark Instance initialization and management

-(id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil {
	if( (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil]) ) {
		_deviceCameraView = nil;
		_isOverlayingDeviceCamera = NO;
	}
	return self;
}

+(id) controller { return [[[self alloc] init] autorelease]; }

-(void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	// If overlay view exists, and we're not currently overlaying the device camera, release it
	if( !self.isOverlayingDeviceCamera ) {
		[_deviceCameraView release];
		_deviceCameraView = nil;
	}
}

@end


#pragma mark -
#pragma mark CC3AVCameraView

@implementation CC3AVCameraView

-(AVCaptureVideoPreviewLayer*) layer { return (AVCaptureVideoPreviewLayer*)super.layer; }

+(Class) layerClass { return [AVCaptureVideoPreviewLayer class]; }

@end

#endif	// CC3_AV_CAPTURE_SUPPORTED

#endif // CC3_IOS
