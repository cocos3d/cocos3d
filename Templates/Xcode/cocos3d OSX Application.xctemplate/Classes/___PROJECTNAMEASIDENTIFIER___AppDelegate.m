/**
 *  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
 *  ___PROJECTNAME___
 *
 *  Created by ___FULLUSERNAME___ on ___DATE___.
 *  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
 */

#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#import "___PROJECTNAMEASIDENTIFIER___Layer.h"
#import "___PROJECTNAMEASIDENTIFIER___Scene.h"

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate

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
	
	// Create the view controller to coordinate the CC3Layer and window view
	_viewController = [CC3NSViewController new];	// retained
	_viewController.view = _glView;

	CC3Layer* cc3Layer = [___PROJECTNAMEASIDENTIFIER___Layer layer];
	cc3Layer.cc3Scene = [___PROJECTNAMEASIDENTIFIER___Scene scene];
	_viewController.controlledNode = cc3Layer;
	
	// Wrap the layer in a 2D scene and run it in the director
	CCScene *scene = [CCScene node];
	[scene addChild: cc3Layer];
	[director runWithScene: scene];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) theApplication {
	return YES;
}

-(void) dealloc {
	[[CCDirector sharedDirector] end];
}

#pragma mark AppDelegate - IBActions

-(IBAction) toggleFullScreen: (id) sender {
	CCDirectorMac *director = (CCDirectorMac*)CCDirector.sharedDirector;
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
