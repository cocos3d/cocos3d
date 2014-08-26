/**
 *  AppDelegate.h
 *  CC3HelloWorld
 *
 *  Created by Bill Hollings on 2014/08/24.
 *  Copyright The Brenwill Workshop Ltd. 2014. All rights reserved.
 */

#import "CC3Environment.h"

#if CC3_CC2_RENDER_QUEUE	//================================================================

#import "CC3DeviceCameraOverlayUIViewController.h"

/**
 * App Delegate for Cocos2D v3 and above.
 *
 * This makes use of the simplified start-up configuration of Cocos2D v3, and is required
 * when using Cocos2D 3.1 and above, because Cocos2D 3.1 initialization requires that the
 * OpenGL view (and context) is available during CCDirector initialization.
 */
@interface AppDelegate : CCAppDelegate
@end


#else	//================================================================================


#import <UIKit/UIKit.h>
#import "CC3DeviceCameraOverlayUIViewController.h"

/**
 * App Delegate for Cocos2D below v3.
 *
 * This assembles the CCDirector and the GL view programmatically.
 *
 * This implementation cannot be used when using Cocos2D 3.1 and above, because Cocos2D 3.1
 * initialization requires that the OpenGL view (and context) is available during CCDirector
 * initialization.
 */
@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow* _window;
	CC3DeviceCameraOverlayUIViewController* _viewController;
}
@end

#endif	// CC3_CC2_RENDER_QUEUE
