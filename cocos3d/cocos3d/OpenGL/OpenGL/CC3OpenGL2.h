/*
 * CC3OpenGL2.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3OpenGLProgPipeline.h"
#import "CC3OpenGLFixedPipeline.h"

#if CC3_OGL

#define CC3OpenGLClass		CC3OpenGL2

#if CC3_GLSL
#define CC3OGL2_SUPERCLASS	CC3OpenGLProgPipeline
#else
#define CC3OGL2_SUPERCLASS	CC3OpenGLFixedPipeline
#endif	// CC3_GLSL

/** Manages the OpenGL state for a single GL context. */
@interface CC3OpenGL2 : CC3OGL2_SUPERCLASS {
	
	GLbitfield value_GL_TEXTURE_CUBE_MAP;				// Track up to 32 texture units
	GLbitfield isKnownCap_GL_TEXTURE_CUBE_MAP;			// Track up to 32 texture units

	BOOL valueCap_GL_VERTEX_PROGRAM_POINT_SIZE : 1;
	BOOL isKnownCap_GL_VERTEX_PROGRAM_POINT_SIZE : 1;
}
@end

#endif	// CC3_OGL