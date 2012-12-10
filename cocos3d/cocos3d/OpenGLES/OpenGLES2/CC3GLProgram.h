/*
 * CC3GLProgram.h
 *
 * cocos3d 2.0.0
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

#import "CC3Environment.h"
#import "CC3CC2Extensions.h"
#import "CC3GLSLVariable.h"
#import "CC3GLProgramSemantics.h"

#if CC3_OGLES_2
#import "CCGLProgram.h"
#endif


#pragma mark -
#pragma mark CC3GLProgram

/** CC3GLProgram extends CCGLProgram to provide specialized behaviour for cocos3d. */
@interface CC3GLProgram : CCGLProgram {
	id<CC3GLProgramSemanticsDelegate> _semanticDelegate;
	CCArray* _uniforms;
	CCArray* _attributes;
	GLint _maxUniformNameLength;
	GLint _maxAttributeNameLength;
}

/**
 * On each render loop, this CC3GLProgram delegates to this object to populate
 * the current value of each uniform variable from content within the 3D scene.
 */
@property(nonatomic, retain) id<CC3GLProgramSemanticsDelegate> semanticDelegate;

/** Returns the length of the largest uniform name in this program. */
@property(nonatomic, readonly) GLint maxUniformNameLength;

/** Returns the length of the largest attribute name in this program. */
@property(nonatomic, readonly) GLint maxAttributeNameLength;

/** Binds the program, populates the uniforms and applies them to the program. */
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** 
 * Returns the uniform definition for the uniform with the specified semantic,
 * or nil if no uniform is defined for the specified semantic.
 */
-(CC3GLSLUniform*) uniformWithSemantic: (GLenum) semantic;

/**
 * Returns the attribute definition for the attribute with the specified semantic,
 * or nil if no attribute is defined for the specified semantic.
 */
-(CC3GLSLAttribute*) attributeWithSemantic: (GLenum) semantic;

/**
 * Extracts the uniforms and attributes from the GLSL program.
 *
 * This should be invoked after the semanticDelegate has been assigned, and after
 * this program has been successfully compiled and linked,
 */
-(void) extractVariables;

/** Returns a detailed description of this instance, including a description of each uniform and attribute. */
-(NSString*) fullDescription;

@end
