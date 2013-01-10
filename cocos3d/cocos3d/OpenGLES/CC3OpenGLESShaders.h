/*
 * CC3OpenGLESShaders.h
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


#import "CC3OpenGLESStateTracker.h"
#import "CC3GLProgram.h"
#import "CC3NodeVisitor.h"


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
 * If this property is not set directly, it will be lazily initialized, the first time this
 * property is accessed. as follows:
 *   - The name of the program is kCC3DefaultGLProgramName.
 *   - The vertex shader source code is loaded from the file named kCC3DefaultVertexShaderSourceFile.
 *   - The fragment shader source code is loaded from the file named kCC3DefaultFragmentShaderSourceFile.
 *   - The semanticDelgate of the program is of type CC3GLProgramSemanticsByVarName.
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


#pragma mark Binding

/** Binds the GL program used for painting nodes with a pure color, including during node picking. */
-(void) bindPureColorProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Unbinds all GL programs from the GL engine. */
-(void) unbind;

@end
