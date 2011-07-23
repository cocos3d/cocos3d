/*
 * CC3OpenGLES11Foundation.m
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
 * 
 * See header file CC3OpenGLES11Foundation.h for full API documentation.
 */

#import "CC3OpenGLES11Foundation.h"
#import "CC3OpenGLES11Utility.h"
#import "CC3Logging.h"


#pragma mark -
#pragma mark GL supporting functions

NSString* NSStringFromGLEnum(GLenum gle) {
	return [NSString stringWithUTF8String: GLEnumName(gle)];
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
		default:
			return [NSString stringWithFormat: @"Unknown GL error (%i)", errCode];
	}
}

/**
 * Do NOT call this function directly! Use LogGLErrorState instead, to allow
 * this function to be removed at compile time using the GL_ERROR_LOGGING_ENABLED
 * compiler switch.
 */
void DoLogGLErrorState() {
	GLenum errCode = glGetError();
	if (errCode) {
		LogError(@"%@", GetGLErrorText(errCode));
	} else {
		LogTrace(@"%@", GetGLErrorText(errCode));
	}
}
