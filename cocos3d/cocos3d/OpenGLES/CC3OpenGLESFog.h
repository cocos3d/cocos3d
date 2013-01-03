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
#pragma mark CC3OpenGLESStateTrackerFogColor

/**
 * CC3OpenGLESStateTrackerFogColor tracks a color GL state value for fog.
 *
 * This implementation uses GL function glGetFloatv to read the value from the
 * GL engine, and GL function glFogfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerFogColor : CC3OpenGLESStateTrackerColor {}
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerFogFloat

/**
 * CC3OpenGLESStateTrackerFogFloat tracks a float GL state value for fog.
 *
 * This implementation uses GL function glGetFloatv to read the value from the
 * GL engine, and GL function glFogf to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerFogFloat : CC3OpenGLESStateTrackerFloat {}
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerFogEnumeration

/**
 * CC3OpenGLESStateTrackerFogEnumeration tracks an enumeration GL state value for fog.
 *
 * This implementation uses GL function glGetFixedv to read the value from the
 * GL engine, and GL function glFogx to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerFogEnumeration : CC3OpenGLESStateTrackerEnumeration {}
@end


#pragma mark -
#pragma mark CC3OpenGLESFog

/** CC3OpenGLESFog manages trackers for fog state. */
@interface CC3OpenGLESFog : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerFogColor* color;
	CC3OpenGLESStateTrackerFogEnumeration* mode;
	CC3OpenGLESStateTrackerFogFloat* density;
	CC3OpenGLESStateTrackerFogFloat* start;
	CC3OpenGLESStateTrackerFogFloat* end;
}

/** Tracks fog color (GL name GL_FOG_COLOR). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFogColor* color;

/** Tracks fog mode (GL name GL_FOG_MODE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFogEnumeration* mode;

/** Tracks fog density used in the exponential functions (GL name GL_FOG_DENSITY). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFogFloat* density;

/** Tracks fog start distance used in the linear function (GL name GL_FOG_START). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFogFloat* start;

/** Tracks fog end distance used in the linear function (GL name GL_FOG_END). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFogFloat* end;

@end
