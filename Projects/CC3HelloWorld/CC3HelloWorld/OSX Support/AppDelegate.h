/**
 *  AppDelegate.h
 *  CC3HelloWorld
 *
 *  Created by Bill Hollings on 2014/08/24.
 *  Copyright The Brenwill Workshop Ltd. 2014. All rights reserved.
 */

#import "CC3Environment.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow* _window;
	CCGLView* _glView;
}

/** The window in which the app is displayed. */
@property (strong) IBOutlet NSWindow* window;

/** The view in which the 3D scene is displayed. */
@property (strong) IBOutlet CCGLView* glView;

/** Toggles the screen between standard and full-screen. */
-(IBAction) toggleFullScreen: (id) sender;

@end
