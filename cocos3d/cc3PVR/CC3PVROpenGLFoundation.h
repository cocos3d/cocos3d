/*
 * CC3PVROpenGLFoundation.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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

/** Running on an Apple OS. Required for Apportable. */
#ifndef __APPLE__
#	define __APPLE__		1
#endif

/** Running on iOS */
#ifndef CC3_IOS
#	define CC3_IOS			defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
#endif

/** Running on OSX */
#ifndef CC3_OSX
#	define CC3_OSX			defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#endif

/** Running on Android via Apportable. Explicitly set as a build setting. */
#ifndef APPORTABLE
#	define APPORTABLE		0
#endif

#if CC3_IOS
#	define TARGET_OS_IPHONE		1
#endif

/** Running some form of OpenGL ES under iOS. */
#ifndef CC3_OGLES
#	define CC3_OGLES		(CC3_IOS)
#endif

/** Allow build settings to force the use of OGLES 1 if compiling for older iOS devices. */
#ifndef CC3_PVR_OGLES_1
#	define CC3_PVR_OGLES_1		0
#endif

/** Running OpenGL ES 1 under iOS. */
#ifndef CC3_OGLES_1
#	define CC3_OGLES_1		((CC3_OGLES) && (CC3_PVR_OGLES_1))
#endif

/** Running OpenGL ES 2 under iOS. */
#ifndef CC3_OGLES_2
#	define CC3_OGLES_2		((CC3_OGLES) && (!CC3_PVR_OGLES_1))
#endif

/** Running OpenGL under OSX on the Mac. */
#ifndef CC3_OGL
#	define CC3_OGL			(CC3_OSX)
#endif

#if CC3_OGLES_1
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#endif	// CC3_OGLES_1

#if CC3_OGLES_2
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#endif	// CC3_OGLES_2

#if CC3_OGL
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#endif	// CC3_OGL

