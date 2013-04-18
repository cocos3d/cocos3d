/*
 * CC3OpenGLES1Compatibility.h
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

/**
 * When compiling against OpenGL ES 1, this file adds some compatibility with declarations
 * and functionality provided by OpenGL ES 2 under cocos3d.
 */

#import "CC3Environment.h"

#if CC3_OGLES_1

// GL functions
#define glClearDepth					glClearDepthf
#define glGenerateMipmap				glGenerateMipmapOES


// General symbolic constants

#ifndef GL_DEPTH_COMPONENT16
#define GL_DEPTH_COMPONENT16			GL_DEPTH_COMPONENT16_OES
#endif

#ifndef GL_INCR_WRAP
#define GL_INCR_WRAP					GL_INCR_WRAP_OES
#endif

#ifndef GL_DECR_WRAP
#define GL_DECR_WRAP					GL_DECR_WRAP_OES
#endif

// Allow code to referenc the following enums, even though they are not usable under OpenGL ES 1.1.
#ifndef GL_TEXTURE_CUBE_MAP
#define GL_TEXTURE_CUBE_MAP               0x8513
#endif

#endif	// CC3_OGLES_1
