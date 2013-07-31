//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "CC3NSViewController.h"

@interface ___PROJECTNAMEASIDENTIFIER___AppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow* _window;
	CC3GLView* _glView;
	CC3NSViewController* _viewController;
}

@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet CC3GLView* glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
