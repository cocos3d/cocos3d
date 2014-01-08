/*
 * CC3OpenGLES2.h
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

#if CC3_OGLES_2

#if APPORTABLE
#	define CC3OpenGLClass		CC3OpenGLES2Android
#else
#	define CC3OpenGLClass		CC3OpenGLES2IOS
#endif	// APPORTABLE


#pragma mark CC3OpenGLES2

/** Manages the OpenGLES 2.0 state for a single GL context. */
@interface CC3OpenGLES2 : CC3OpenGLProgPipeline {

@public
	CC3Vector value_Vertex_Shader_Precision[6];
	CC3Vector value_Fragment_Shader_Precision[6];
}

@end


#pragma mark CC3OpenGLES2IOS

/** Manages the OpenGLES 2.0 state for a single GL context under iOS. */
@interface CC3OpenGLES2IOS : CC3OpenGLES2

@end


#pragma mark CC3OpenGLES2Android

/** Manages the OpenGLES 2.0 state for a single GL context under Android. */
@interface CC3OpenGLES2Android : CC3OpenGLES2

@end

#endif	// CC3_OGLES_2