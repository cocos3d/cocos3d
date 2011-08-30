/*
 * CC3DemoMashUpLayer.h
 *
 * cocos3d 0.6.1
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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
 */


#import "CC3Layer.h"
#import "Joystick.h"
#import "CCNodeAdornments.h"


/**
 * A sample application-specific CC3Layer subclass that contains two joystick controls
 * for controlling the movement of the 3D camera, a button control that rotates the
 * camera to point at different aspects of the scene, and a button control to cause
 * the world to be invaded by an army of robots.
 */
@interface CC3DemoMashUpLayer : CC3Layer {
	Joystick* directionJoystick;
	Joystick* locationJoystick;
	AdornableMenuItemImage* switchViewMI;
	AdornableMenuItemImage* invasionMI;
	AdornableMenuItemImage* sunlightMI;
	AdornableMenuItemImage* zoomMI;
}

@end
