/*
 * CC3GLProgramContext.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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
	CCArray* _uniforms;
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
 * Returns an override for the program uniform with the specified name.
 *
 * The application can use this method to set the value of a uniform directly, either to populate
 * a program uniform whose content cannot be extracted semantically from the environment, or to
 * override the value that would be extracted, with an application-specific value.
 *
 * Invoking this method more than once will return the same uniform override, and the content of the
 * returned uniform is sticky, so the application does not need to keep track of the returned uniform,
 * and only needs to make changes to the content of this uniform when it wants to change that
 * content. Specifically, the application does not need to access, or set the content of, the uniform
 * during each frame update or render cycle. Once set, the content of this uniform will automatically
 * be applied to the GL engine for this context (typically a CC3MeshNode), on each render cycle.
 *
 * By invoking this method, an override uniform is created, and the application takes responsibility
 * for populating the value of this overriden uniform, by invoking any of the set... methods on the
 * returned uniform. If this method has been used to override a program uniform whose content can be
 * extracted semantically from the environment, you can remove this override by invoking the 
 * removeUniformOverride: method with the uniform returned by this method.
 *
 * If the program has no uniform with the specified name, this method does nothing and returns nil.
 */
-(CC3GLSLUniform*) uniformOverrideNamed: (NSString*) name;

/**
 * Returns an override for the program uniform with the specified semantic and semantic index.
 *
 * The semantic describes what type of content the uniform is tracking in the GLSL shader code.
 * It is usually one of the values from the CC3Semantic, although the application can also define
 * values outside the range of this enumeration, if needed. The semantic index is used for
 * semantics that may appear more than once in the scene and in the shader code.
 *
 * For example, the shader might support several lights. The semantic kCC3SemanticLightPositionEyeSpace
 * indicates that the uniform is tracking the position of a light in eye space, and the semantic
 * index then represents the index of a particular light. The index is zero-based.
 *
 * The application can use this method to set the value of a uniform directly, either to populate
 * a program uniform whose content cannot be extracted semantically from the environment, or to
 * override the value that would be extracted, with an application-specific value.
 *
 * Invoking this method more than once will return the same uniform override, and the content of the
 * returned uniform is sticky, so the application does not need to keep track of the returned uniform,
 * and only needs to make changes to the content of this uniform when it wants to change that
 * content. Specifically, the application does not need to access, or set the content of, the uniform
 * during each frame update or render cycle. Once set, the content of this uniform will automatically
 * be applied to the GL engine for this context (typically a CC3MeshNode), on each render cycle.
 *
 * By invoking this method, an override uniform is created, and the application takes responsibility
 * for populating the value of this overriden uniform, by invoking any of the set... methods on the
 * returned uniform. If this method has been used to override a program uniform whose content can be
 * extracted semantically from the environment, you can remove this override by invoking the
 * removeUniformOverride: method with the uniform returned by this method.
 *
 * If the program has no uniform that matches the specified semantic and semantic index,
 * this method does nothing and returns nil.
 */
-(CC3GLSLUniform*) uniformOverrideForSemantic: (GLenum) semantic at: (GLuint) semanticIndex;

/**
 * Returns an override for the program uniform with the specified semantic and semantic index zero.
 *
 * This is a convenience method that invokes the uniformOverrideForSemantic:at: method, passing
 * zero for the semanticIndex argument. See the description of that method for more info.
 */
-(CC3GLSLUniform*) uniformOverrideForSemantic: (GLenum) semantic;

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
 *
 * If the program has no uniform at the specified location, this method does nothing and returns nil.
 */
-(CC3GLSLUniform*) uniformOverrideAtLocation: (GLint) uniformLocation;

/**
 * Removes the specified unifrom override from the uniforms being overridden by this context.
 *
 * The specified uniform must be have previously been retrieved by one of the uniformOverride...
 * method of this context.
 *
 * Attempting to override a uniform whose semantic property is set to kCC3SemanticNone will
 * raise an assertion error, since doing so would leave the program uniform with no way of
 * being populated within the program, which would result in a program execution error.
 */
-(void) removeUniformOverride: (CC3GLSLUniform*) uniform;


#pragma mark Drawing

/**
 * This callback method is invoked from the bindWithVisitor: method of the associated GL program.
 *
 * If this context includes an override uniform that matches the specified program uniform, the
 * content of the specified uniform is updated from the content held in the matching override uniform
 * in this context. If no matching override uniform exists within this context, nothing happens.
 *
 * Returns whether the specified uniform was updated.
 *
 * This context can keep track of content to be used for any uniform in the associated program.
 * This contextual content can be used for uniforms whose content cannot be extracted from a
 * standard semantics, or can be used to override the value that would be extracted from the
 * environment for the semantic of the uniform. To create an override uniform, access it via
 * one of the uniformOverride... methods.
 *
 * If the specified uniform is from a program that is not the same as the program controlled
 * by this context, the override is not populated, and this method returns NO. This can occur
 * when drawing with a different program, such as during node picking.
 */
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor;


#pragma mark Allocation and initialization

/** Initializes this instance for use with the specified program. */
-(id) initForProgram: (CC3GLProgram*) program;

/** Allocates and initializes an autoreleased instance for use with the specified program. */
+(id) contextForProgram: (CC3GLProgram*) program;

/** Returns a detailed description of this instance, including a description of each uniform and attribute. */
-(NSString*) fullDescription;

@end
