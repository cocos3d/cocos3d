/*
 * CC3DemoMashUpAppDelegate.m
 *
 * Cocos3D 2.0.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3DemoMashUpAppDelegate.h for full API documentation.
 */

#import "CC3DemoMashUpAppDelegate.h"
#import "CC3DemoMashUpLayer.h"
#import "CC3DemoMashUpScene.h"

@implementation CC3DemoMashUpAppDelegate

@synthesize window=_window, glView=_glView;

-(void) applicationDidFinishLaunching: (NSNotification*) aNotification {
	CCDirectorMac* director = (CCDirectorMac*)CCDirector.sharedDirector;
	
	// enable FPS and SPF
	[director setDisplayStats: YES];
	
	// connect the OpenGL view with the director
	[director setView: _glView];

	// Must use kCCDirectorResize_NoScale to allow the CC3Layer to automatically fill the
	// window as the window is resized, and to accurately track mouse events. For Mac Retina,
	// we also need to force the content scale back to 1 and reshape the projection accordingly.
	[director setResizeMode: kCCDirectorResize_NoScale];
	[director setContentScaleFactor: 1.0f];
	[_glView reshape];
	
	// Enable "moving" mouse event. Default no.
	[_window setAcceptsMouseMovedEvents: NO];
	
	// Center main window
	[_window center];
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer that supports 3D rendering.
	CC3Layer* cc3Layer = [CC3DemoMashUpLayer layer];
	
	// Wrap the 3D layer in a 2D scene and run it in the director
	[CCDirector.sharedDirector runWithScene: [cc3Layer asCCScene]];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) theApplication {
	return YES;
}

-(void) dealloc { [CC3OpenGL terminateOpenGL]; }


#pragma mark AppDelegate - IBActions

-(IBAction) toggleFullScreen: (id) sender {
	CCDirectorMac *director = (CCDirectorMac*)CCDirector.sharedDirector;
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
