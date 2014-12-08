/*
 * CC3DemoMashUpAppDelegate.h
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
 * copies of the Software , and to permit persons to whom the Software is
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
@interface CC3DemoMashUpAppDelegate : CCAppDelegate {
	CC3DeviceCameraOverlayUIViewController* _viewController;
}
@end


#else	//================================================================================


#import <UIKit/UIKit.h>
#import "CC3DeviceCameraOverlayUIViewController.h"

/** 
 * App Delegate for Cocos2D below v3.
 *
 * This makes use of CC3DeviceCameraOverlayUIViewController to optionally display the scene 
 * over the device controller.
 *
 * This implementation cannot be used when using Cocos2D 3.1 and above, because Cocos2D 3.1 
 * initialization requires that the OpenGL view (and context) is available during CCDirector 
 * initialization.
 */
@interface CC3DemoMashUpAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow* _window;
	CC3DeviceCameraOverlayUIViewController* _viewController;
}
@end

#endif	// CC3_CC2_RENDER_QUEUE
