/*
 * CC3OpenGLES11Fog.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFogColor

/**
 * CC3OpenGLES11StateTrackerFogColor tracks a color GL state value for fog.
 *
 * This implementation uses GL function glGetFloatv to read the value from the
 * GL engine, and GL function glFogfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerFogColor : CC3OpenGLES11StateTrackerColor {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFogFloat

/**
 * CC3OpenGLES11StateTrackerFogFloat tracks a float GL state value for fog.
 *
 * This implementation uses GL function glGetFloatv to read the value from the
 * GL engine, and GL function glFogf to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerFogFloat : CC3OpenGLES11StateTrackerFloat {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFogEnumeration

/**
 * CC3OpenGLES11StateTrackerFogEnumeration tracks an enumeration GL state value for fog.
 *
 * This implementation uses GL function glGetFixedv to read the value from the
 * GL engine, and GL function glFogx to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerFogEnumeration : CC3OpenGLES11StateTrackerEnumeration {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11Fog

/** CC3OpenGLES11Fog manages trackers for fog state. */
@interface CC3OpenGLES11Fog : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerFogColor* color;
	CC3OpenGLES11StateTrackerFogEnumeration* mode;
	CC3OpenGLES11StateTrackerFogFloat* density;
	CC3OpenGLES11StateTrackerFogFloat* start;
	CC3OpenGLES11StateTrackerFogFloat* end;
}

/** Tracks fog color (GL name GL_FOG_COLOR). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFogColor* color;

/** Tracks fog mode (GL name GL_FOG_MODE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFogEnumeration* mode;

/** Tracks fog density used in the exponential functions (GL name GL_FOG_DENSITY). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFogFloat* density;

/** Tracks fog start distance used in the linear function (GL name GL_FOG_START). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFogFloat* start;

/** Tracks fog end distance used in the linear function (GL name GL_FOG_END). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerFogFloat* end;

@end
