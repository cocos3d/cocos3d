/*
 * CC3OpenGLES11Foundation.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * The implementation of the LogGLErrorState and LogGLErrorTrace compiler macros.
 *
 * See the API documentation for those macros for more information on logging and tracing GL errors.
 */
void DoLogGLErrorState(NSString* fmt, ...);

/**
 * LogGLErrorState logs an ERROR level description of any glError that has occurred since it
 * was last called.
 *
 * Like all logging macros, LogGLErrorState takes a format string and a variable length list
 * of arguments. The GL error code and description is also added to the logged information.
 * 
 * Use the LogGLErrorState() macro and the GL_ERROR_LOGGING_ENABLED compiler switch to turn checking
 * and logging of GL error state. Be sure to set the compiler switch GL_ERROR_LOGGING_ENABLED to zero
 * when compiling for production code release, to avoid the overhead of making the GL error state call.
 * This is important to maximize the GL state machine performance.
 *
 * If the compiler switch GL_ERROR_ASSERTION_ENABLED is set to anything other than zero, an assertion
 * error will also be raised to halt execution at the point where the GL error occurred, otherwise,
 * the error will be logged and execution will continue.
 */
#ifndef GL_ERROR_LOGGING_ENABLED
	#define GL_ERROR_LOGGING_ENABLED		0
#endif
#ifndef GL_ERROR_ASSERTION_ENABLED
	#define GL_ERROR_ASSERTION_ENABLED		0
#endif

#if GL_ERROR_LOGGING_ENABLED
	#define LogGLErrorState(fmt, ...)		DoLogGLErrorState(fmt, ##__VA_ARGS__)
#else
	#define LogGLErrorState(...)
#endif

/**
 * LogGLErrorTrace logs an ERROR level description of any glError that has occurred
 * since it was last called.
 *
 * LogGLErrorTrace is distinct from LogGLErrorState in that it is called during
 * every GL call, whereas LogGLErrorState is invoked only once per rendering loop.
 * This permits dual-level detection of GL errors, that can be configured as follows:
 * 
 *   - During development, enable GL_ERROR_LOGGING_ENABLED in all projects, but leave
 *     GL_ERROR_TRACING_ENABLED disabled. This will cause the occurance of a GL error
 *     to be checked and logged once at the end of each rendering loop.
 *   - If such a GL error log is encountered, temporarily enable GL_ERROR_TRACING_ENABLED
 *     in your project to turn on the checking and logging of GL errors on each GL call,
 *     thereby detecting and logging the precise GL call that triggered the GL error.
 *   - Once the GL error is resolved and corrected, disable GL_ERROR_TRACING_ENABLED
 *     to remove the overhead of testing for a GL error on every GL call.
 *
 * The GL_ERROR_TRACING_ENABLED compiler build switch requires that the GL_ERROR_LOGGING_ENABLED
 * compiler build switch is also set.
 * 
 * Like all logging macros, LogGLErrorTrace takes a format string and a variable length list of
 * arguments. The GL error code and description is also added to the logged information.
 * 
 * Use the LogGLErrorTrace() macro and the GL_ERROR_TRACING_ENABLED compile switch to turn checking
 * and logging of GL error tracing. Be sure to set the compiler switch GL_ERROR_TRACING_ENABLED to
 * zero when compiling for production code release, to avoid the overhead of making the GL error
 * state call. This is important to maximize the GL state machine throughput.
 *
 * If the compiler switch GL_ERROR_ASSERTION_ENABLED is set to anything other than zero, an assertion
 * error will also be raised to halt execution at the point where the GL error occurred, otherwise,
 * the error will be logged and execution will continue.
 */
#ifndef GL_ERROR_TRACING_ENABLED
	#define GL_ERROR_TRACING_ENABLED		0
#endif

#if GL_ERROR_TRACING_ENABLED
	#define LogGLErrorTrace(fmt, ...) LogGLErrorState(fmt, ##__VA_ARGS__)
#else
	#define LogGLErrorTrace(...)
#endif

