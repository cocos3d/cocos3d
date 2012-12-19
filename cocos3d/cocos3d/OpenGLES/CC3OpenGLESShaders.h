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

/**
 * CC3OpenGLESShaders manages loaded GLSL program objects.
 */
@interface CC3OpenGLESShaders : CC3OpenGLESStateTrackerManager {
	NSMutableDictionary* _programsByName;
	CC3GLProgram* _defaultProgram;
	CC3GLProgram* _activeProgram;
	NSString* _defaultVertexShaderSourceFile;
	NSString* _defaultFragmentShaderSourceFile;
}

/** Returns the program that is currently bound to the GL engine. */
@property(nonatomic, readonly) CC3GLProgram* activeProgram;

/** 
 * Returns the program that is used as a default if a material does not specify a specific shader program.
 *
 * If this property is not set directly, it will be lazily initialized from the value returned from the
 * makeDefaultProgram method, the first time this property is accessed.
 *
 * If this property has not been directly set to another program, this program can also be retrieved
 * using the getProgramNamed: property with the kCC3DefaultGLProgramName name.
 */
@property(nonatomic, retain) CC3GLProgram* defaultProgram;

/**
 * Adds the specified program to the collection of loaded progams.
 *
 * The specified program should be compiled and linked prior to being added here.
 *
 * Programs are accessible via their names through the getProgramNamed: method, and should be unique.
 * If a program with the same name as the specified program already exists in this cache, an assertion
 * error is raised.
 */
-(void) addProgram: (CC3GLProgram*) program;

/** Returns the program with the specified name, or nil if a program with that name has not been added. */
-(CC3GLProgram*) getProgramNamed: (NSString*) name;

/** Removes the specified program from the collection of loaded programs. */
-(void) removeProgram: (CC3GLProgram*) program;

/** Removes the program with the specified name from the collection of loaded programs. */
-(void) removeProgramNamed: (NSString*) name;

/**
 * Template method that creates and returns a program to be set into the defaultProgram property.
 *
 * This implementation creates and returns a compiled, linked and autoreleased program with the
 * following characteristics:
 *   - The name of the program is kCC3DefaultGLProgramName.
 *   - The vertex shader source code is loaded from the file named kCC3DefaultVertexShaderSourceFile.
 *   - The fragment shader source code is loaded from the file named kCC3DefaultFragmentShaderSourceFile.
 *   - The semanticDelgate of the program is of type CC3GLProgramSemanticsDelegateByVarNames.
 *
 * This method is invoked automatically by the defaultProgram property. The application should
 * never need to invoke this method directly.
 */
-(CC3GLProgram*) makeDefaultProgram;

/**
 * The name of the file containing the GLSL source code for the default vertex shader.
 *
 * This file is used by the makeDefaultProgram method to create the default GL program held in the
 * defaultProgram property. This property can be set to nil to stop a default program from being created.
 *
 * When using OpenGL ES 1, the initial value of this property is nil.
 */
@property(nonatomic, retain) NSString* defaultVertexShaderSourceFile;

/**
 * The name of the file containing the GLSL source code for the default fragment shader.
 *
 * This file is used by the makeDefaultProgram method to create the default GL program held in the
 * defaultProgram property. This property can be set to nil to stop a default program from being created.
 *
 * When using OpenGL ES 1, the initial value of this property is nil.
 */
@property(nonatomic, retain) NSString* defaultFragmentShaderSourceFile;



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
