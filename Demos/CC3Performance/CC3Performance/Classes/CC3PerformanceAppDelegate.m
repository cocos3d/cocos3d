/*
 * CC3PerformanceAppDelegate.m
 *
 * cocos3d 0.6.4
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd.
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
 * See header file CC3PerformanceAppDelegate.h for full API documentation.
 */

#import "cocos2d.h"

#import "CC3PerformanceAppDelegate.h"
#import "CC3PerformanceLayer.h"
#import "CC3PerformanceWorld.h"
#import "CC3EAGLView.h"

@implementation CC3PerformanceAppDelegate

@synthesize window;

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[viewController release];
	[super dealloc];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	CCDirector *director = [CCDirector sharedDirector];

	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];

	[director setAnimationInterval:1.0/60];
//	[director setDisplayFPS:YES];
	
	// Alloc & init the EAGLView
	//  1. Transparency (alpha blending), and device camera overlay requires an alpha channel,
	//     so must use RGBA8 color format. If not using device overlay or alpha blending
	//     (transparency) in any 3D or 2D graphics this can be changed to kEAGLColorFormatRGB565.
	//	2. 3D rendering requires a depth format of 16 bit.
	//  3. For highest performance, multisampling antialiasing is disabled by default.
	//     To enable multisampling antialiasing, set the multiSampling parameter to YES.
	//     You can also change the number of samples used with the numberOfSamples parameter.
	//  4. If you are using BOTH multisampling antialiasing AND node picking from touch events,
	//     use the CC3EAGLView class instead of EAGLView. When using EAGLView, multisampling
	//     antialiasing interferes with the color-testing algorithm used for touch-event node picking.
	EAGLView *glView = [CC3EAGLView viewWithFrame: [window bounds]
									  pixelFormat: kEAGLColorFormatRGBA8
									  depthFormat: GL_DEPTH_COMPONENT16_OES
							   preserveBackbuffer: NO
									   sharegroup: nil
									multiSampling: NO
								  numberOfSamples: 4];
	
	// Turn on multiple touches if needed
	[glView setMultipleTouchEnabled: YES];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
						
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
						
	
	// make the GL view a child of the main window and present it
	[window addSubview: glView];
	[window makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer that supports 3D rendering,
	// and schedule it for automatic updates
	CC3Layer* cc3Layer = [CC3PerformanceLayer node];
	[cc3Layer scheduleUpdate];

	// Create the customized 3D world, attach it to the layer, and start it playing.
	cc3Layer.cc3World = [CC3PerformanceWorld world];

	ControllableCCLayer* mainLayer = cc3Layer;
	
	// The 3D layer can run either direcly in the scene, or it can run as a smaller "sub-window"
	// within any standard CCLayer. So you can have a mostly 2D window, with a smaller 3D window
	// embedded in it. To experiment with this smaller embedded 3D window, uncomment the following lines:
//	CGSize winSize = [[CCDirector sharedDirector] winSize];
//	cc3Layer.position = CGPointMake(30.0, 40.0);
//	cc3Layer.contentSize = CGSizeMake(winSize.width - 70.0, winSize.width - 40.0);
//	cc3Layer.alignContentSizeWithDeviceOrientation = YES;
//	mainLayer = [ControllableCCLayer layerWithColor: ccc4(0, 0, 0, 255)];
//	[mainLayer addChild: cc3Layer];
	
	// The controller is optional. If you want to auto-rotate the view when the device orientation
	// changes, or if you want to display a device camera behind a combined 3D & 2D scene
	// (augmented reality), use a controller. Otherwise you can simply remove the following lines
	// and uncomment the lines below these lines that uses the traditional CCDirector scene startup.
	viewController = [[CCNodeController controller] retain];
	viewController.doesAutoRotate = YES;
	[viewController runSceneOnNode: mainLayer];		// attach the layer to the controller and run a scene with it
	
	// If a controller is NOT used, uncomment the following standard CCDirector scene startup lines,
	// and remove the lines above that reference viewContoller.
//	CCScene *scene = [CCScene node];
//	[scene addChild: mainLayer];
//	[[CCDirector sharedDirector] runWithScene: scene];
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
