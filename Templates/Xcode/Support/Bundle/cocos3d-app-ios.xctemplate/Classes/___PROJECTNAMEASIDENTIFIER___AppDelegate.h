/**
 *  ___PROJECTNAMEASIDENTIFIER___AppDelegate.h
 *  ___PROJECTNAME___
 *
 *  Created by ___FULLUSERNAME___ on ___DATE___.
 *  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
 */

#import "CC3Environment.h"

#if !CC3_CC2_CLASSIC

/** App Delegate for Cocos2D v3 and above. */
@interface ___PROJECTNAMEASIDENTIFIER___AppDelegate : CCAppDelegate
@end

#else

#import <UIKit/UIKit.h>
#import "CC3DeviceCameraOverlayUIViewController.h"

/** App Delegate for Cocos2D below v3. */
@interface ___PROJECTNAMEASIDENTIFIER___AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow* _window;
	CC3DeviceCameraOverlayUIViewController* _viewController;
}
@end

#endif	// !CC3_CC2_CLASSIC
