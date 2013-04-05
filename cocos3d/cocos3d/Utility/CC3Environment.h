/*
 * CC3Environment.h
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


#import "cocos2d.h"

/** OS platform macros */
# define CC3_IOS			defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
# define CC3_OSX			defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

/** Create convenience tests for whether we are linking to cocos2d 1.x or 2.x. */
#ifndef CC3_CC2_1
#	define CC3_CC2_1		(COCOS2D_VERSION < 0x020000)
#endif
#ifndef CC3_CC2_2
#	define CC3_CC2_2		!(CC3_CC2_1)
#endif

/** Running some form of OpenGL ES under iOS. */
#ifndef CC3_OGLES
#	define CC3_OGLES		(CC3_IOS)
#endif

/** Running OpenGL ES 1 under iOS. */
#ifndef CC3_OGLES_1
#	define CC3_OGLES_1		((CC3_CC2_1) && (CC3_OGLES))
#endif

/** Running OpenGL ES 2 under iOS. */
#ifndef CC3_OGLES_2
#	define CC3_OGLES_2		((CC3_CC2_2) && (CC3_OGLES))
#endif

/** Running OpenGL under OSX on the Mac. */
#ifndef CC3_OGL
#	define CC3_OGL			(CC3_OSX)
#endif

/** Running an OpenGL version that supports GLSL (either OpenGL ES 2 or OpenGL). */
#ifndef CC3_GLSL
#	define CC3_GLSL			(CC3_CC2_2)
#endif
