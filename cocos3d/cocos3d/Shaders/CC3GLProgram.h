/*
 * CC3GLProgram.h
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

#import "CC3Identifiable.h"
#import "CC3Environment.h"
#import "CC3CC2Extensions.h"
#import "CC3GLSLVariable.h"
#import "CC3GLProgramSemantics.h"

#if CC3_GLSL
#import "CCGLProgram.h"
#endif	// CC3_GLSL

@class CC3GLProgramContext, CC3NodeDrawingVisitor;
@protocol CC3GLProgramMatcher;


#pragma mark -
#pragma mark CC3GLProgram

/** 
 * CC3GLProgram represents an OpenGL shader program, containing one vertex shader and one
 * fragment shader, each compiled from GLSL source code.
 *
 * Since a single GL program can be used by many nodes and materials, shaders are cached.
 * The application can use the class-side getProgramNamed: method to retrieve a compiled program
 * from the cache, and the class-side addProgram: method to add a new program to the cache.
 * See the notes of those two methods for more details.
 */
@interface CC3GLProgram : CC3Identifiable {
	id<CC3GLProgramSemanticsDelegate> _semanticDelegate;
	CCArray* _uniformsSceneScope;
	CCArray* _uniformsNodeScope;
	CCArray* _uniformsDrawScope;
	CCArray* _attributes;
	NSString* _vertexShaderPreamble;
	NSString* _fragmentShaderPreamble;
	GLint _maxUniformNameLength;
	GLint _maxAttributeNameLength;
	GLuint _programID;
	BOOL _isSceneScopeDirty : 1;
}

/** Returns the GL program ID. */
@property(nonatomic, readonly) GLuint programID;

/**
 * On each render loop, this CC3GLProgram delegates to this object to populate
 * the current value of each uniform variable from content within the 3D scene.
 *
 * This property must be set prior to the program being compiled.
 */
@property(nonatomic, retain) id<CC3GLProgramSemanticsDelegate> semanticDelegate;

/** Returns the length of the largest uniform name in this program. */
@property(nonatomic, readonly) GLint maxUniformNameLength;

/** Returns the length of the largest attribute name in this program. */
@property(nonatomic, readonly) GLint maxAttributeNameLength;

/** 
 * Returns the uniform with the specified semantic and index,
 * or nil if no uniform is defined for the specified semantic.
 */
-(CC3GLSLUniform*) uniformForSemantic: (GLenum) semantic at: (GLuint) semanticIndex;

/**
 * Returns the uniform with the specified semantic at index zero,
 * or nil if no uniform is defined for the specified semantic.
 */
-(CC3GLSLUniform*) uniformForSemantic: (GLenum) semantic;

/** Returns the uniform with the specified name, or nil if no uniform is defined for the specified name. */
-(CC3GLSLUniform*) uniformNamed: (NSString*) name;

/** Returns the uniform at the specified location, or nil if no uniform is defined at the specified location. */
-(CC3GLSLUniform*) uniformAtLocation: (GLint) uniformLocation;

/** 
 * Returns the attribute with the specified semantic and index,
 * or nil if no attribute is defined for the specified semantic.
 */
-(CC3GLSLAttribute*) attributeForSemantic: (GLenum) semantic at: (GLuint) semanticIndex;

/**
 * Returns the attribute with the specified semantic at index zero,
 * or nil if no attribute is defined for the specified semantic.
 */
-(CC3GLSLAttribute*) attributeForSemantic: (GLenum) semantic;

/** Returns the attribute with the specified name, or nil if no attribute is defined for the specified name. */
-(CC3GLSLAttribute*) attributeNamed: (NSString*) name;

/** Returns the attribute at the specified location, or nil if no attribute is defined at the specified location. */
-(CC3GLSLAttribute*) attributeAtLocation: (GLint) attrLocation;


#pragma mark Compiling

/**
 * Compiles and links the underlying GL program from the specified vertex and fragment
 * shader GLSL source code.
 */
-(void) compileAndLinkVertexShaderBytes: (const GLchar*) vshBytes
				 andFragmentShaderBytes: (const GLchar*) fshBytes;

/**
 * Compiles and links the underlying GL program from the vertex and fragment shader GLSL
 * source code contained in the specified files.
 */
-(void) compileAndLinkVertexShaderFile: (NSString*) vshFilename
				 andFragmentShaderFile: (NSString*) fshFilename;

/** Returns the GLSL source code loaded from the specified file. */
-(GLchar*) glslSourceFromFile:  (NSString*) glslFilename;

/**
 * A string containing GLSL source code to be used as a preamble for the vertex shader
 * source code when compiling the vertex shader.
 *
 * The value of this property can be set prior to invoking one of the compileAndLink... methods.
 * The content of this propery will be prepended to the source code of the vertex shader source
 * code. You can use this property to include compiler builds settings, and other delarations.
 *
 * The initial value of this property is set to the value of the platformPreamble property.
 * If you change this property, you should concatenate the value of the platformPreamble to
 * the additional preamble content that you require.
 */
@property(nonatomic, retain) NSString* vertexShaderPreamble;

/**
 * A string containing GLSL source code to be used as a preamble for the fragment shader
 * source code when compiling the fragment shader.
 *
 * The value of this property can be set prior to invoking one of the compileAndLink... methods.
 * The content of this propery will be prepended to the source code of the fragment shader source
 * code. You can use this property to include compiler builds settings, and other delarations.
 *
 * The initial value of this property is set to the value of the platformPreamble property.
 * If you change this property, you should concatenate the value of the platformPreamble to
 * the additional preamble content that you require.
 */
@property(nonatomic, retain) NSString* fragmentShaderPreamble;

/**
 * Returns a string containing platform-specific GLSL source code to be used as a preamble
 * for the vertex and fragment shader source code when compiling the shaders.
 *
 * The value of this property defines the initial value of both the vertexShaderPreamble
 * and vertexShaderPreamble properties.
 *
 * The value of this property is retrieved from CC3OpenGL.sharedGL.defaultShaderPreamble.
 * For OpenGL on the OSX platform, this property contains define statements to remove precision
 * qualifiers of all variables in the GLSL source code and to set the #version declaration.
 * For OpenGL ES 2.0 on the iOS platform, this property returns an empty string.
 */
@property(nonatomic, readonly) NSString* platformPreamble;


#pragma mark Binding

/** Binds the program to the GL engine and to the specified visitor. */
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Populates the vertex attribute variables. */
-(void) populateVertexAttributesWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** 
 * If the scene scope was previously marked dirty by an invocation of the markSceneScopeDirty
 * method, this method populates all uniform variables that have scene scope, and marks the
 * scene scope as no longer dirty. Further invocations of this method will not re-populate
 * the scene scope variables until markSceneScopeDirty is invoked.
 *
 * This method is lazily invoked by the populateNodeScopeUniformsWithVisitor method. Therefore,
 * scene scope will be populated on each render pass when the first node that uses this program
 * is rendered. Under normal operations, this method need never be explicitly invoked.
 */
-(void) populateSceneScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Populates the uniform variables that have node scope. */
-(void) populateNodeScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Populates the uniform variables that have draw scope. */
-(void) populateDrawScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Marks the scene scope variables as dirty and in need of re-populating.
 *
 * Invoked automatically at the beginning of scene rendering.
 */
-(void) markSceneScopeDirty;

/**
 * Invoked automatically at the beginning of scene rendering.
 *
 * Invokes the markSceneScopeDirty method to mark the scene scope variables as dirty
 * and in need of re-populating.
 */
-(void) willBeginDrawingScene;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with the specified name, attaches the specified semantic delegate,
 * and compiles the program from the specified vertex and fragment shader source code.
 *
 * Since a single GL program can be used by many nodes and materials, shaders are cached.
 * Before invoking this method, you should invoke the class-side getProgramNamed: method to
 * detemine whether a GL program with the specified name exists already, and after invoking
 * this method, you should use the class-side addProgram: method to add the new GL program
 * instance to the program cache.
 *
 * If you want to set properties prior to compiling code, you can create an instance without compiled
 * code by using one of the initialization methods defined by the superclass (eg- initWithName:),
 * set properties including semanticDelegate and possibly the shader preambles, and then invoke the
 * compileAndLinkVertexShaderBytes:andFragmentShaderBytes: method to compile and link the program.
*/
-(id) initWithName: (NSString*) name
andSemanticDelegate: (id<CC3GLProgramSemanticsDelegate>) semanticDelegate
fromVertexShaderBytes: (const GLchar*) vshBytes
andFragmentShaderBytes: (const GLchar*) fshBytes;

/**
 * Initializes this instance with the specified name, attaches the specified semantic delegate, and
 * compiles the program from vertex and fragment shader source code loaded from the specified files.
 *
 * The specified filenames may specified as relative or absolute filenames.
 *
 * Since a single GL program can be used by many nodes and materials, shaders are cached.
 * Before invoking this method, you should invoke the class-side getProgramNamed: method to
 * detemine whether a GL program with the specified name exists already, and after invoking
 * this method, you should use the class-side addProgram: method to add the new GL program
 * instance to the program cache.
 *
 * To make use of a standardized naming scheme, you can use the class-side
 * programNameFromVertexShaderFile:andFragmentShaderFile: method to determine the name to use when
 * invoking this method (and when invoking the getProgramNamed: method prior to this method).
 *
 * If you want to set properties prior to compiling code, you can create an instance without compiled
 * code by using one of the initialization methods defined by the superclass (eg- initWithName:), 
 * set properties including semanticDelegate and possibly the shader preambles, and then invoke the
 * compileAndLinkVertexShaderFile:andFragmentShaderFile: method to compile and link the program.
 */
-(id) initWithName: (NSString*) name
andSemanticDelegate: (id<CC3GLProgramSemanticsDelegate>) semanticDelegate
fromVertexShaderFile: (NSString*) vshFilename
andFragmentShaderFile: (NSString*) fshFilename;

/** Returns a program name created as a simple hyphenated concatenation of the specified vertex and shader filenames. */
+(NSString*) programNameFromVertexShaderFile: (NSString*) vshFilename andFragmentShaderFile: (NSString*) fshFilename;

/** Returns a detailed description of this instance, including a description of each uniform and attribute. */
-(NSString*) fullDescription;


#pragma mark Program cache

/**
 * Adds the specified program to the collection of loaded programs.
 *
 * The specified program should be compiled and linked prior to being added here.
 *
 * Programs are accessible via their names through the getProgramNamed: method, and should be unique.
 * If a program with the same name as the specified program already exists in this cache, an assertion
 * error is raised.
 */
+(void) addProgram: (CC3GLProgram*) program;

/** Returns the program with the specified name, or nil if a program with that name has not been added. */
+(CC3GLProgram*) getProgramNamed: (NSString*) name;

/** Removes the specified program from the collection of loaded programs. */
+(void) removeProgram: (CC3GLProgram*) program;

/** Removes the program with the specified name from the collection of loaded programs. */
+(void) removeProgramNamed: (NSString*) name;

/**
 * Invoked to indicate that scene drawing is about to begin.
 *
 * This method invokes the same method on each instance in the cache.
 */
+(void) willBeginDrawingScene;


#pragma mark Program matching

/**
 * This property contains a helper delegate object that determines which GL program to use when
 * rendering a particular CC3MeshNode.
 *
 * Rendering a mesh node requires a GL program. Typically, the GL program is assigned to the material
 * of the mesh node when the node is created or loaded from a model resource. This is either done by
 * the resource loader based on configuration information, or by the application directly, via the
 * shaderProgram or shaderContext properties on the mesh node or its material.
 *
 * As a convenience, once a mesh node has been constructed and configured, the application can use
 * the program matcher in this property to retrieve GL program suitable for rendering that node.
 *
 * If the application does not assign a specific GL program to a mesh node, the program matcher in
 * this property will be accessed automatically to assign a GL program when the node is rendered.
 *
 * If desired, the application can set a custom program matcher into this property. If the value of
 * this property is not explicitly set by the application, it is lazily initialized to an instance
 * of CC3GLProgramMatcherBase, the first time it is accessed.
 */
+(id<CC3GLProgramMatcher>) programMatcher;

/**
 * This property contains a helper delegate object that determines which GL program to use when
 * rendering a particular CC3MeshNode.
 *
 * Rendering a mesh node requires a GL program. Typically, the GL program is assigned to the material
 * of the mesh node when the node is created or loaded from a model resource. This is either done by
 * the resource loader based on configuration information, or by the application directly, via the
 * shaderProgram or shaderContext properties on the mesh node or its material.
 *
 * As a convenience, once a mesh node has been constructed and configured, the application can use
 * the program matcher in this property to retrieve GL program suitable for rendering that node.
 *
 * If the application does not assign a specific GL program to a mesh node, the program matcher in
 * this property will be accessed automatically to assign a GL program when the node is rendered.
 *
 * If desired, the application can set a custom program matcher into this property. If the value of
 * this property is not explicitly set by the application, it is lazily initialized to an instance
 * of CC3GLProgramMatcherBase, the first time it is accessed.
 */
+(void) setProgramMatcher: (id<CC3GLProgramMatcher>) programMatcher;

@end

