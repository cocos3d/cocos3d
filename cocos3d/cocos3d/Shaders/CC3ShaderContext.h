/*
 * CC3ShaderContext.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3Shaders.h"
#import "CC3GLSLVariable.h"

// Legacy naming support
#define CC3GLProgramContext				CC3ShaderContext
#define CC3ShaderProgramContext			CC3ShaderContext

#pragma mark -
#pragma mark CC3ShaderContext

/** 
 * CC3ShaderContext holds a CC3ShaderProgram for a particular use, such as a by a particular node.
 *
 * A single CC3ShaderProgram object can be used by many nodes and other contexts. The CC3ShaderContext
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
@interface CC3ShaderContext : NSObject <NSCopying> {
	CC3ShaderProgram* _program;
	CC3ShaderProgram* _pureColorProgram;
	NSMutableArray* _uniforms;
	NSMutableDictionary* _uniformsByName;
	BOOL _shouldEnforceCustomOverrides : 1;
	BOOL _shouldEnforceVertexAttributes : 1;
}

/**
 * Returns the program for which this instance is providing a context.
 *
 * Setting this property will redefine the variables that can be retrieved via the
 * uniform... methods, and will clear the pureColorProgram so that a new pureColorProgram
 * will be matched to the new program on next access.
 */
@property(nonatomic, retain) CC3ShaderProgram* program;

/** 
 * Returns the program to use to render this node in a pure color, such as used when rendering
 * the node during paint-basede node picking as a result of a touch event.
 *
 * If this property is not set directly, it will be set automatically on first access, by
 * retrieving the picking program that matches the shader program in the program property.
 * This will usually be a program that has the same vertex shader as the shader program in
 * the program property, but has a fragment shader that paints in a single color. By using
 * the same vertex shader, the vertices are guaranteed to be rendered in the same locations.
 */
@property(nonatomic, retain) CC3ShaderProgram* pureColorProgram;

/**
 * Indicates whether this context should ensure that all uniforms with an unknown semantic
 * must have a uniform override established.
 *
 * Uniform variables whose semantic is unknown cannot be resolved automatically from scene
 * content, and generally require that a uniform override be established in this context,
 * in order for a meaningful uniform value to be passed to the shader program.
 *
 * If the value of this property is YES, when a uniform of unknown semantic is processed by
 * the populateUniform:withVisitor: method, and a uniform override has not been established
 * in this context for that uniform by the application, the populateUniform:withVisitor: 
 * method will return NO. This will generally result in an assertion error being raised.
 *
 * If the value of this property is NO, the populateUniform:withVisitor: method will return 
 * YES under the same conditions. This will cause the uniform to use its current value, which
 * might be an initial default identity value, or might be a value set by another mesh node
 * that is using the same shader program.
 *
 * The initial value of this property is YES, indicating that the application must provide
 * an override for any uniform whose semantic is unknown. In most cases, you should leave
 * the value of this property set to YES, to avoid unpredictable behaviour. However, there
 * might be some occasions, particularly when the value is never set by any mesh node, and
 * the default identity value is acceptable.
 */
@property(nonatomic, assign) BOOL shouldEnforceCustomOverrides;

/**
 * Indicates whether this context should ensure that all vertex attributes have a valid semantic.
 *
 * If the value of this property is YES, when a vertex attribute variable of unknown semantic
 * is processed, an assertion error will be raised. 
 *
 * If the value of this property is NO, no assertion error will be raised, and the attribute
 * will remain unpopulated. Under these conditions, the shader may render the node in an
 * unexpected manner.
 *
 * The initial value of this property is YES, indicating that the application must ensure
 * that all vertex attributes must have a valid, resolvable semantic. You may set the value
 * of this property to NO if your shader has been designed to handle the case where the
 * vertex attribute is not set.
 */
@property(nonatomic, assign) BOOL shouldEnforceVertexAttributes;


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
 * and only needs to make changes to the content of this uniform when it wants to change that content.
 * Specifically, the application does not need to access, or set the content of, the uniform during 
 * each frame update or render cycle. Once set, the content of this uniform will automatically be
 * applied to the GL engine for this context (typically a CC3MeshNode), on each render cycle.
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
 * Returns whether the specified uniform was updated. If the uniform was not updated, and the
 * semantic of the uniform is unknown, the value returned by this method depends on the value of
 * the shouldEnforceCustomOverrides property. If this context does not update a uniform  whose
 * semantic is unknown, and the shouldEnforceCustomOverrides property is set to YES (the default),
 * this method will return NO, indicating that the uniform is unresolvable, and likely in error. 
 * This will typically result in an assertion error being raised, to indicate that the application
 * should set the override. However, if the shouldEnforceCustomOverrides property is set to NO,
 * this method will return YES under the same conditions, which will cause the shader program
 * to use the current value of the uniform variable, which might be an initial default identity
 * value, or might be a value set by another mesh node that is using the same shader program.
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

/** 
 * Allocates and initializes an instance without specifying a program during init.
 *
 * The program can be set later using the program property.
 */
+(id) context;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or copyWithZone: method.
 * In most situations, the application should use the copy method, and should never need to invoke
 * this method directly.
 *
 * Subclasses that add additional instance state (instance variables) should extend copying by
 * overriding this method to copy that additional state. Superclass that override this method should
 * be sure to invoke the superclass implementation to ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3ShaderContext*) another;

/** Returns a detailed description of this instance, including a description of each uniform and attribute. */
-(NSString*) fullDescription;

@end
