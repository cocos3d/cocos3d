/*
 * CC3OpenGLESFog.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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

/** @file */	// Doxygen marker


#import "CC3OpenGLESStateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLESFog

/** CC3OpenGLESFog manages trackers for fog state. */
@interface CC3OpenGLESFog : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerColor* color;
	CC3OpenGLESStateTrackerEnumeration* mode;
	CC3OpenGLESStateTrackerFloat* density;
	CC3OpenGLESStateTrackerFloat* start;
	CC3OpenGLESStateTrackerFloat* end;
}

/** Tracks fog color (GL name GL_FOG_COLOR). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerColor* color;

/** Tracks fog mode (GL name GL_FOG_MODE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* mode;

/** Tracks fog density used in the exponential functions (GL name GL_FOG_DENSITY). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFloat* density;

/** Tracks fog start distance used in the linear function (GL name GL_FOG_START). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFloat* start;

/** Tracks fog end distance used in the linear function (GL name GL_FOG_END). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFloat* end;

@end
