/*
 * CC3OpenGLESHints.h
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
#pragma mark CC3OpenGLESStateTrackerHintEnumeration

/**
 * CC3OpenGLESStateTrackerHintEnumeration tracks an enumeration GL state value for a hint.
 *
 * This implementation uses GL function glGetFixedv to read the value from the
 * GL engine, and GL function glHint to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerHintEnumeration : CC3OpenGLESStateTrackerEnumeration {}

/** Sets the value of the hint to GL_FASTEST. */
-(void) useFastest;

/** Sets the value of the hint to GL_NICEST. */
-(void) useNicest;

/** Sets the value of the hint to GL_DONT_CARE. */
-(void) useDontCare;

@end


#pragma mark -
#pragma mark CC3OpenGLESHints

/** CC3OpenGLESHints manages trackers for GL hints. */
@interface CC3OpenGLESHints : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerHintEnumeration* fog;
	CC3OpenGLESStateTrackerHintEnumeration* generateMipMap;
	CC3OpenGLESStateTrackerHintEnumeration* lineSmooth;
	CC3OpenGLESStateTrackerHintEnumeration* perspectiveCorrection;
	CC3OpenGLESStateTrackerHintEnumeration* pointSmooth;
}

/** Tracks the fog hint (GL name GL_FOG_HINT). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerHintEnumeration* fog;

/** Tracks the generate mipmap hint (GL name GL_GENERATE_MIPMAP_HINT). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerHintEnumeration* generateMipMap;

/** Tracks the line smoothing hint (GL name GL_LINE_SMOOTH_HINT). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerHintEnumeration* lineSmooth;

/** Tracks the perspective correction hint (GL name GL_PERSPECTIVE_CORRECTION_HINT). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerHintEnumeration* perspectiveCorrection;

/** Tracks the point smoothing hint (GL name GL_POINT_SMOOTH_HINT). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerHintEnumeration* pointSmooth;

@end
