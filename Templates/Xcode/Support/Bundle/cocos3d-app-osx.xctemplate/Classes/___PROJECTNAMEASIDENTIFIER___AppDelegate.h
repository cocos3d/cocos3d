/**
 *  ___PROJECTNAMEASIDENTIFIER___AppDelegate.h
 *  ___PROJECTNAME___
 *
 *  Created by ___FULLUSERNAME___ on ___DATE___.
 *  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
 */

#import "CC3NSViewController.h"

@interface ___PROJECTNAMEASIDENTIFIER___AppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow* _window;
	CC3GLView* _glView;
	CC3NSViewController* _viewController;
}

/** The window in which the app is displayed. */
@property (strong) IBOutlet NSWindow* window;

/** The view in which the 3D scene is displayed. */
@property (strong) IBOutlet CC3GLView* glView;

/** Toggles the screen between standard and full-screen. */
-(IBAction) toggleFullScreen: (id) sender;

@end
