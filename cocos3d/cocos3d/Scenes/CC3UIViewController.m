/*
 * CC3UIViewController.m
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
 * See header file CC3UIViewController.h for full API documentation.
 */

#import "CC3UIViewController.h"
#import "CC3Logging.h"
#import "CC3GLView-GL.h"
#import "CC3GLView-GLES2.h"
#import "CC3GLView-GLES1.h"

#if CC3_IOS

#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>


// The height of the device camera toolbar
#define kDeviceCameraToolbarHeight 54.0


#pragma mark CC3UIViewController implementation

@implementation CC3UIViewController

@synthesize controlledNode=_controlledNode, viewColorFormat=_viewColorFormat, viewDepthFormat=_viewDepthFormat;
@synthesize viewBounds=_viewBounds, viewPixelSamples=_viewPixelSamples, viewClass=_viewClass;

-(void) dealloc {
	[_controlledNode release];
    [super dealloc];
}


#pragma mark View management

#if COCOS2D_VERSION < 0x020100
#	define CC2_VIEW view_
#else
#	define CC2_VIEW __view
#endif

#if CC3_CC2_1
-(CCGLView*) view { return (CCGLView*)super.view; }
#endif	// CC3_CC2_1
#if CC3_CC2_2
// In cocos2d 2.x, view is tracked separately and does not lazily init. Restore that functionality.
-(CCGLView*) view {
	if ( !CC2_VIEW ) {
		[self loadView];
		[self viewDidLoad];
	}
	return (CCGLView*)super.view;
}
#endif	// CC3_CC2_2

/** Ensure that retina display is established if required. */
-(void) setView:(CCGLView *)view {
	CC3Assert(!view || [view isKindOfClass: [CCGLView class]], @"%@ may only be attached to a CCGLView. %@ is not of that class.", self, view);
	super.view = view;
	[self checkRetinaDisplay];
}

-(Class) viewClass { return (self.isViewLoaded) ? self.view.class : _viewClass; }

-(CGRect) viewBounds { return (self.isViewLoaded) ? self.view.bounds : _viewBounds; }

-(NSString*) viewColorFormat { return (self.isViewLoaded) ? self.view.pixelFormat : _viewColorFormat; }

-(GLenum) viewDepthFormat { return (self.isViewLoaded) ? self.view.depthFormat : _viewDepthFormat; }

-(BOOL) viewShouldUseStencilBuffer { return (self.viewDepthFormat == GL_DEPTH24_STENCIL8_OES); }

-(void) setViewShouldUseStencilBuffer: (BOOL) viewShouldUseStencilBuffer {
	self.viewDepthFormat = viewShouldUseStencilBuffer ? GL_DEPTH24_STENCIL8_OES : GL_DEPTH_COMPONENT16;
}

-(GLuint) viewPixelSamples {
	if (self.isViewLoaded) return self.view.pixelSamples;
	if (self.viewShouldUseStencilBuffer) return 1;
	return _viewPixelSamples;
}

-(void) loadView {
	self.view = [self.viewClass viewWithFrame: self.viewBounds
								  pixelFormat: self.viewColorFormat
								  depthFormat: self.viewDepthFormat
						   preserveBackbuffer: NO
								   sharegroup: nil
								multiSampling: (self.viewPixelSamples > 1)
							  numberOfSamples: self.viewPixelSamples];
}

-(CGRect) viewCreationBounds { return UIScreen.mainScreen.bounds; }

-(BOOL) enableRetinaDisplay: (BOOL) enable {
	_shouldUseRetina = enable;
	return [self checkRetinaDisplay];
}

-(BOOL) checkRetinaDisplay {
#if CC3_IOS
#if CC3_CC2_2
	return [super enableRetinaDisplay: _shouldUseRetina];
#endif	// CC3_CC2_2
#if CC3_CC2_1
	return [CCDirector.sharedDirector enableRetinaDisplay: _shouldUseRetina];
#endif	// CC3_CC2_1
#else
	return NO;
#endif	// CC3_IOS
}


#pragma mark Scene management

-(CCNode*) controlledNode { return _controlledNode; }

-(void) setControlledNode: (CCNode*) aNode {
	if (aNode == _controlledNode) return;

	[_controlledNode release];
	_controlledNode = [aNode retain];
	aNode.controller = self;
}

-(void) runSceneOnNode: (CCNode*) aNode {
	self.controlledNode = aNode;

	if ( !aNode || !_viewWasLaidOut ) return;

	CCScene* scene;
	if ( [aNode isKindOfClass: [CCScene class]] ) {
		scene = (CCScene*)aNode;
	} else {
		scene = [CCScene node];
		[scene addChild: aNode];
	}

	CCDirector* dir = CCDirector.sharedDirector;
	if(dir.runningScene) [dir replaceScene: scene];
	else [dir runWithScene: scene];
}

/**
 * Invoked from the UIView during layout, to ensure that the CCDirector is running a scene.
 *
 * If the CCDirector does not have a running scene, attempt to run a scene on the
 * CCNode being controlled by this controller.
 */
-(void) ensureScene { if ( !CCDirector.sharedDirector.hasScene ) [self runSceneOnNode: self.controlledNode]; }

-(void) viewDidLayoutSubviews {
	// viewDidLayoutSubviews was introduced in iOS5. Make sure it's okay to propagate upwards
	if ( [[self superclass] respondsToSelector: @selector(viewDidLayoutSubviews)] )
		[super viewDidLayoutSubviews];
	LogTrace(@"%@ viewDidLayoutSubviews", self);
	_viewWasLaidOut = YES;
	[self ensureScene];
}

-(void) pauseAnimation { [[CCDirector sharedDirector] pause]; }

-(void) resumeAnimation { [[CCDirector sharedDirector] resume]; }


#pragma mark Device orientation

+(BOOL) isPadUI { return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad; }

+(BOOL) isPhoneUI { return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone; }

/**
 * UIKit callback template method invoked automatically when device rotation is changed.
 *
 * Returns the interface orientations supported by this controller.
 *
 * This method was introduced in iOS6.
 */
-(NSUInteger) supportedInterfaceOrientations {
	LogTrace(@"%@ checking supported UI orientations: %i", self.class, _supportedInterfaceOrientations);
	return _supportedInterfaceOrientations;
}

-(void) setSupportedInterfaceOrientations: (NSUInteger) uiOrientationBitMask {
	CC3Assert(uiOrientationBitMask, @"%@ supportedInterfaceOrientations must contain at least one valid orientation", self);
	_supportedInterfaceOrientations = uiOrientationBitMask;
}

/**
 * Returns whether the UIKit should rotate the view automatically.
 *
 * This method was introduced in iOS6 and is invoked automatically, and must be provided in order to have
 * the supportedInterfaceOrientations method invoked.
 *
 * Returns YES if this controller uses UIKit autorotation, and the supportedInterfaceOrientations property
 * has more than one orientation configured. This last test is made using a standard "is a power-of-two"
 * test. If the mask is not a power-of-two, then it includes more than one orientation.
 */
-(BOOL) shouldAutorotate { return (_supportedInterfaceOrientations & (_supportedInterfaceOrientations - 1)) != 0; }

/**
 * UIKit callback template method invoked automatically when device rotation is changed.
 *
 * Determines whether the orientation is supported, and returns whether the UIView should rotate to that orientation.
 *
 * As of iOS6, this method is deprecated and is no longer invoked. The supportedInterfaceOrientations
 * property is used instead.
 */
 -(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) uiOrientation {
	LogTrace(@"%@ should %@autorotate to UI orientation %@", self.class,
			 (CC3UIInterfaceOrientationMaskIncludesUIOrientation(_supportedInterfaceOrientations, uiOrientation) ? @"" : @"not "),
			 NSStringFromUIInterfaceOrientation(uiOrientation));

	 return CC3UIInterfaceOrientationMaskIncludesUIOrientation(_supportedInterfaceOrientations, uiOrientation);
}

/** UIKit callback template method invoked automatically when device rotation is changed.  */
-(void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) uiOrientation duration:(NSTimeInterval)duration {
 	[_controlledNode viewDidRotateFrom: self.interfaceOrientation to: uiOrientation];
}

-(BOOL) isOverlayingDeviceCamera { return NO; }


#pragma mark Instance initialization and management

#if CC3_CC2_2
+(id) sharedDirector { return super.sharedDirector; }
#endif

// CCDirector must be in portrait orientation for autorotation to work
-(id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil {
	if( (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil]) ) {
		_viewWasLaidOut = NO;
		_shouldUseRetina = NO;
		self.viewClass = [CC3GLView class];
		self.viewBounds = UIScreen.mainScreen.bounds;
		self.viewColorFormat = kEAGLColorFormatRGBA8;
		self.viewDepthFormat = GL_DEPTH_COMPONENT16;
		self.viewPixelSamples = 1;
		self.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
#if CC3_CC2_1
		CCDirector.sharedDirector.deviceOrientation = UIDeviceOrientationPortrait;		// Force to portrait
#endif
	}
	return self;
}

+(id) controller { return [[[self alloc] init] autorelease]; }

-(NSString*) description { return [NSString stringWithFormat: @"%@", self.class]; }


#pragma mark Deprecated functionality left over from CCNodeController

-(BOOL) doesAutoRotate { return self.shouldAutorotate; }
-(void) setDoesAutoRotate: (BOOL) doesAutoRotate { self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll; }
-(UIDeviceOrientation) defaultCCDeviceOrientation { return UIDeviceOrientationPortrait; }
-(void) setDefaultCCDeviceOrientation: (UIDeviceOrientation) defaultCCDeviceOrientation {}

@end


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
			BOOL nodeRunning = _controlledNode.isRunning;
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
		
		_deviceCameraView = [[CC3AVCameraView alloc] initWithFrame: self.view.frame];
		AVCaptureVideoPreviewLayer* avLayer = _deviceCameraView.layer;
		avLayer.session = avSession;
		avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
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

#endif // CC3_IOS


#pragma mark -
#pragma mark CCNode extension to support controlling nodes from a CC3UIViewController

@implementation CCNode (CC3UIViewController)

-(CC3UIViewController*) controller { return self.parent.controller; }

-(void) setController: (CC3UIViewController*) aController {
	for (CCNode* child in self.children) child.controller = aController;
}

-(void) viewDidRotateFrom: (UIInterfaceOrientation) oldOrientation to: (UIInterfaceOrientation) newOrientation {
	for (CCNode* child in self.children)
		[child viewDidRotateFrom: oldOrientation to: newOrientation];
}

@end
