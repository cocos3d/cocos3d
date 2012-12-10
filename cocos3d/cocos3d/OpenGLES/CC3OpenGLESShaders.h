/*
 * CC3OpenGLESShaders.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3OpenGLESStateTracker.h"
#import "CC3GLProgram.h"


#pragma mark -
#pragma mark CC3OpenGLESShaders

/** CC3OpenGLESShaders manages GLSL program objects. */
@interface CC3OpenGLESShaders : CC3OpenGLESStateTrackerManager {
	CCArray* _programs;
	CC3GLProgram* _activeProgram;
}

/** Returns the program that is currently bound to the GL engine. */
@property(nonatomic, readonly) CC3GLProgram* activeProgram;

/** Tracks state for each GLSL program. */
//@property(nonatomic, retain) CCArray* programs;

/** Returns the number of active programs. */
//@property(nonatomic, readonly) GLuint programCount;

/**
 * Returns the tracker for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxLights.value.
 */
//-(CC3OpenGLESProgramContext*) programAt: (GLuint) index;

/** Unbinds all GL programs from the GL engine. */
-(void) unbind;

@end
