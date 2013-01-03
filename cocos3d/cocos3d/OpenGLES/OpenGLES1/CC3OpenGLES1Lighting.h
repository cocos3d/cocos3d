/*
 * CC3OpenGLES1Lighting.h
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


#import "CC3OpenGLESLighting.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightFloat

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1StateTrackerLightFloat : CC3OpenGLESStateTrackerFloat

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightColor

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1StateTrackerLightColor : CC3OpenGLESStateTrackerColor

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightVector

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1StateTrackerLightVector : CC3OpenGLESStateTrackerVector

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightVector4

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1StateTrackerLightVector4 : CC3OpenGLESStateTrackerVector4

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLES1Light

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1Light : CC3OpenGLESLight
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerSceneLightColor

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1StateTrackerSceneLightColor : CC3OpenGLESStateTrackerColor {}
@end


#pragma mark -
#pragma mark CC3OpenGLES1Lighting

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1Lighting : CC3OpenGLESLighting
@end

#endif