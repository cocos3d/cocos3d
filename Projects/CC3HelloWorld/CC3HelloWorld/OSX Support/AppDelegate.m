/**
 *  AppDelegate.m
 *  CC3HelloWorld
 *
 *  Created by Bill Hollings on 2014/08/24.
 *  Copyright The Brenwill Workshop Ltd. 2014. All rights reserved.
 */

#import "AppDelegate.h"
#import "CC3HelloWorldLayer.h"

@implementation AppDelegate

@synthesize window=_window, glView=_glView;

-(void) applicationDidFinishLaunching: (NSNotification*) aNotification {
	CCDirectorMac *director = (CCDirectorMac*)CCDirector.sharedDirector;
	
	// enable FPS and SPF
	[director setDisplayStats: YES];
	
	// connect the OpenGL view with the director
	[director setView: _glView];
	
	// Must use kCCDirectorResize_NoScale to allow the CC3Layer to automatically fill
	// the window as the window is resized, and to accurately track mouse events.
	[director setResizeMode: kCCDirectorResize_NoScale];
	
	// Enable "moving" mouse event. Default no.
	[_window setAcceptsMouseMovedEvents: NO];
	
	// Center main window
	[_window center];
	
	// ******** START OF COCOS3D SETUP CODE... ********

	// Create the customized CC3Layer that supports 3D rendering.
	CC3Layer* cc3Layer = [CC3HelloWorldLayer layer];
	
	// Wrap the 3D layer in a 2D scene and run it in the director
	[CCDirector.sharedDirector runWithScene: [cc3Layer asCCScene]];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) theApplication {
	return YES;
}

-(void) dealloc {
	[CC3OpenGL terminateOpenGL];
}

#pragma mark AppDelegate - IBActions

-(IBAction) toggleFullScreen: (id) sender {
	CCDirectorMac *director = (CCDirectorMac*)CCDirector.sharedDirector;
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
