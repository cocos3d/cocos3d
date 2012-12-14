/*
 * CC3GLProgramContext.h
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

#import "CC3GLProgram.h"
#import "CC3GLSLVariable.h"


#pragma mark -
#pragma mark CC3GLProgramContext

/** 
 * CC3GLProgramContext holds a CC3GLProgram for a particular use, such as a by a particular node.
 *
 * A single CC3GLProgram object can be used by many nodes and other contexts. The CC3GLProgramContext
 * contains state and behaviour specific to a particular use of the program, including providing
 * storage for local values for certain customized program variables in use by the node.
 *
 * A particular program may make use of many uniforms. In most, or many, cases, the uniform will 
 * have a semantic defined, and the content of the uniform will automatically be extracted from
 * the environment, including from the content of the node itself. For uniforms without a defined
 * semantic, the content of the uniform must be set by accessing it through this program context.
 *
 * When retrieving a uniform variable through this program context, be aware that the content value
 * of any uniform variable with a defined semantic is derived automatically from the environment,
 * and cannot be retrieved or set directly.
*/
@interface CC3GLProgramContext : NSObject {
	CC3GLProgram* _program;
	NSMutableDictionary* _uniformsByName;
}

/**
 * Returns the program for which this instance is providing a context.
 *
 * Setting this property will redefine the variables that can be retrieved via the uniform... methods.
 */
@property(nonatomic, retain) CC3GLProgram* program;


#pragma mark Uniforms

/** 
 * Returns the uniform with the specified name, or nil if no uniform is defined for the specified name.
 *
 * When retrieving a uniform variable using this method, be aware that the content value of any
 * uniform variable with a defined semantic is derived automatically from the environment, and
 * cannot be retrieved or set directly.
 */
-(CC3GLSLUniform*) uniformNamed: (NSString*) name;

/**
 * Returns the uniform with the specified semantic, or nil if no uniform is defined for the specified semantic.
 *
 * When retrieving a uniform variable using this method, be aware that the content value of any
 * uniform variable with a defined semantic is derived automatically from the environment, and
 * cannot be retrieved or set directly.
 */
-(CC3GLSLUniform*) uniformWithSemantic: (GLenum) semantic;

/** 
 * Returns the uniform at the specified program location, or nil if no uniform is at the specified location.
 *
 * The specified uniformLocation value is the location assigned to the uniform by the GL engine, and available
 * through the location property of the uniform itself. It does not always correspond to the index of the
 * uniform in a particular array.
 *
 * When retrieving a uniform variable using this method, be aware that the content value of any
 * uniform variable with a defined semantic is derived automatically from the environment, and
 * cannot be retrieved or set directly.
 */
-(CC3GLSLUniform*) uniformAtLocation: (GLint) uniformLocation;


#pragma mark Drawing

/** Binds the program, populates the uniforms and applies them to the program. */
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor;


#pragma mark Allocation and initialization

/** Initializes this instance for use with the specified program. */
-(id) initForProgram: (CC3GLProgram*) program;

/** Allocates and initializes an autoreleased instance for use with the specified program. */
+(id) contextForProgram: (CC3GLProgram*) program;

/** Returns a detailed description of this instance, including a description of each uniform and attribute. */
-(NSString*) fullDescription;

@end
