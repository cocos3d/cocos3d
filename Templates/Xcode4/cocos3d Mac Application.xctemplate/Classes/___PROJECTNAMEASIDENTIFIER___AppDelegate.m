//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#import "___PROJECTNAMEASIDENTIFIER___Layer.h"
#import "___PROJECTNAMEASIDENTIFIER___Scene.h"

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate
@synthesize window=window_, glView=glView_;

-(void) applicationDidFinishLaunching: (NSNotification*) aNotification {
	CCDirectorMac *director = (CCDirectorMac*)CCDirector.sharedDirector;
	
	// enable FPS and SPF
	[director setDisplayStats: YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];
	
	// Must use kCCDirectorResize_NoScale to allow the CC3Layer to automatically fill
	// the window as the window is resized, and to accurately track mouse events.
	[director setResizeMode: kCCDirectorResize_NoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents: NO];
	
	// Center main window
	[window_ center];
	
	CC3Layer* cc3Layer = [___PROJECTNAMEASIDENTIFIER___Layer node];
	cc3Layer.cc3Scene = [___PROJECTNAMEASIDENTIFIER___Scene scene];
	
	CCScene *scene = [CCScene node];
	[scene addChild: cc3Layer];
	[director runWithScene: scene];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) theApplication {
	return YES;
}

-(void) dealloc {
	[[CCDirector sharedDirector] end];
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

-(IBAction) toggleFullScreen: (id) sender {
	CCDirectorMac *director = (CCDirectorMac*)CCDirector.sharedDirector;
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
