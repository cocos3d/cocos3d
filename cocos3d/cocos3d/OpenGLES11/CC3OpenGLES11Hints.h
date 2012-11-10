/*
 * CC3OpenGLES11Hints.h
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
#pragma mark CC3OpenGLES11StateTrackerHintEnumeration

/**
 * CC3OpenGLES11StateTrackerHintEnumeration tracks an enumeration GL state value for a hint.
 *
 * This implementation uses GL function glGetFixedv to read the value from the
 * GL engine, and GL function glHint to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerHintEnumeration : CC3OpenGLES11StateTrackerEnumeration {}

/** Sets the value of the hint to GL_FASTEST. */
-(void) useFastest;

/** Sets the value of the hint to GL_NICEST. */
-(void) useNicest;

/** Sets the value of the hint to GL_DONT_CARE. */
-(void) useDontCare;

@end


#pragma mark -
#pragma mark CC3OpenGLES11Hints

/** CC3OpenGLES11Hints manages trackers for GL hints. */
@interface CC3OpenGLES11Hints : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerHintEnumeration* fog;
	CC3OpenGLES11StateTrackerHintEnumeration* generateMipMap;
	CC3OpenGLES11StateTrackerHintEnumeration* lineSmooth;
	CC3OpenGLES11StateTrackerHintEnumeration* perspectiveCorrection;
	CC3OpenGLES11StateTrackerHintEnumeration* pointSmooth;
}

/** Tracks the fog hint (GL name GL_FOG_HINT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerHintEnumeration* fog;

/** Tracks the generate mipmap hint (GL name GL_GENERATE_MIPMAP_HINT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerHintEnumeration* generateMipMap;

/** Tracks the line smoothing hint (GL name GL_LINE_SMOOTH_HINT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerHintEnumeration* lineSmooth;

/** Tracks the perspective correction hint (GL name GL_PERSPECTIVE_CORRECTION_HINT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerHintEnumeration* perspectiveCorrection;

/** Tracks the point smoothing hint (GL name GL_POINT_SMOOTH_HINT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerHintEnumeration* pointSmooth;

@end
