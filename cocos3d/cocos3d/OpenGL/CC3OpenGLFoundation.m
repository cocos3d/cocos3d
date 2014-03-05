/*
 * CC3OpenGLFoundation.m
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
 * 
 * See header file CC3OpenGLFoundation.h for full API documentation.
 */

#import "CC3OpenGLFoundation.h"
#import "CC3OpenGLUtility.h"
#import "CC3Logging.h"


#pragma mark -
#pragma mark GL supporting functions

NSString* NSStringFromGLEnum(GLenum gle) {
	return [NSString stringWithUTF8String: CC3GLEnumName(gle)];
}

BOOL CC3DepthFormatIncludesStencil(GLenum depthFormat) {
	switch (depthFormat) {
		case GL_DEPTH_STENCIL:			// textures
		case GL_DEPTH24_STENCIL8:		// renderbuffers
			return YES;
			break;
		default:
			return NO;
	}
}

NSString* GetGLErrorText(GLenum errCode) {
	switch (errCode) {
		case GL_NO_ERROR:
			return @"GL_NO_ERROR: It's all good";
		case GL_INVALID_ENUM:
			return @"GL_INVALID_ENUM: Bad enumerated argument";
		case GL_INVALID_VALUE:
			return @"GL_INVALID_VALUE: Numeric argument is out of range";
		case GL_INVALID_OPERATION:
			return @"GL_INVALID_OPERATION: Operation not allowed in current state";
		case GL_STACK_OVERFLOW:
			return @"GL_STACK_OVERFLOW: Operation would cause stack overflow";
		case GL_STACK_UNDERFLOW:
			return @"GL_STACK_UNDERFLOW: Operation would cause stack underflow";
		case GL_OUT_OF_MEMORY:
			return @"GL_OUT_OF_MEMORY: Not enough memory to perform operation";
		case GL_INVALID_FRAMEBUFFER_OPERATION:
			return @"GL_INVALID_FRAMEBUFFER_OPERATION: Operation not allowed on frame buffer";
		default:
			return [NSString stringWithFormat: @"Unknown GL error (0x%04X)", errCode];
	}
}

static BOOL _shouldLogGLCalls = NO;

void CC3StartLoggingGLCalls(void) {
	if ( !_shouldLogGLCalls ) {
		printf("Starting GL logging.\n");
		_shouldLogGLCalls = YES;
	}
}

void CC3StopLoggingGLCalls(void) {
	if (_shouldLogGLCalls) {
		printf("Stopping GL logging.\n");
		_shouldLogGLCalls = NO;
	}
}

void DoLogGLErrorState(NSString* fmt, ...) {
	va_list args;
	va_start(args, fmt);
	GLenum errCode = glGetError();
	if (errCode) {
		NSString* glTxt = [[NSString alloc] initWithFormat: fmt arguments: args];
		NSString* errText = [[NSString alloc] initWithFormat: @"[***GL ERROR***] %@ from %@.%@",
							 GetGLErrorText(errCode), glTxt,
							 (GL_ERROR_TRACING_ENABLED ? @"" : @" To investigate further, set the preprocessor macro GL_ERROR_TRACING_ENABLED=1 in your project build settings.")];
		CC3AssertC(!GL_ERROR_ASSERTION_ENABLED,
				  @"%@ To disable this assertion and just log the GL error, set the preprocessor macro GL_ERROR_ASSERTION_ENABLED=0 in your project build settings.\n",
				  errText);
		printf("%s\n", [errText UTF8String]);
		[glTxt release];
		[errText release];
	} else if (_shouldLogGLCalls) {
		NSString* glTxt = [[NSString alloc] initWithFormat: fmt arguments: args];
		printf("%s\n", [glTxt UTF8String]);
		[glTxt release];
	}
	va_end(args);
}

