/*
 * CC3OpenGLES11Foundation.h
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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


#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "CC3OpenGLES11Intercept.h"


#pragma mark -
#pragma mark GL supporting structures & functions

/** Returns a string containing the name of the specified GL enumeration code. */
NSString* NSStringFromGLEnum(GLenum gle);

/** Returns a text description of the specified GL error code. */
NSString* GetGLErrorText(GLenum errCode);

/**
 * LogGLErrorState logs an ERROR level description of any glError that
 * occurrs, and logs a TRACE level description if no error has occurred.
 * 
 * Use the LogGLErrorState() macro and the GL_LOGGING_ENABLED compile switch
 * to turn checking and logging of GL error state. Be sure to set the compiler
 * switch GL_LOGGING_ENABLED to 0 when compiling for production code release,
 * to avoid the overhead of making the GL error state call. This is important
 * to maximize the GL state machine throughput.
 *
 * Do NOT call the DoLogGLErrorState function directly!
 */
#ifndef GL_ERROR_LOGGING_ENABLED
	#define GL_ERROR_LOGGING_ENABLED		0
#endif

#if GL_ERROR_LOGGING_ENABLED
	#define LogGLErrorState() DoLogGLErrorState()
#else
	#define LogGLErrorState()
#endif
void DoLogGLErrorState();


