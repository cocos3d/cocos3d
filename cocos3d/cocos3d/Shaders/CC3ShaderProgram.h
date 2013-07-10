/*
 * CC3ShaderProgram.h
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
#import "CC3ShaderProgramSemantics.h"

// Legacy naming support
#define CC3GLProgram					CC3ShaderProgram

@class CC3ShaderProgramContext, CC3NodeDrawingVisitor;
@protocol CC3ShaderProgramMatcher;


#pragma mark -
#pragma mark CC3Shader

/**
 * CC3Shader represents an OpenGL shader, compiled from GLSL source code. 
 *
 * CC3Shader is an abstract class. You should instantiate one of the concrete classes:
 * CC3VertexShader or CC3FragmentShader.
 *
 * In most cases, you will create an instance of one of these subclasses by loading and
 * compiling GLSL code from a file using the shaderFromSourceCodeFile: method.
 *
 * Since a single shader can be used by more than one shader program, shaders are cached.
 * The application can use the class-side getShaderNamed: method to retrieve a compiled shader
 * from the cache, and the class-side addShader: method to add a new shader to the cache.
 * The shaderFromSourceCodeFile: method automatically retrieves existing instances from the
 * cache and adds any new instances to the cache.
 *
 * See the notes of the methods described above for more details.
 */
@interface CC3Shader : CC3Identifiable {
	GLuint _shaderID;
	NSString* _shaderPreamble;
}

/** Returns the GL shader ID. */
@property(nonatomic, readonly) GLuint shaderID;

/** Returns the type of shader, either GL_VERTEX_SHADER or GL_FRAGMENT_SHADER. */
-(GLenum) shaderType;


#pragma mark Compiling

/**
 * Compiles this shader from the specified GLSL source code, and returns whether compilation
 * was successful. The value of the shaderPreamble property is prepended to the specified
 * source code prior to compiling.
 */
-(void) compileFromSource: (NSString*) glslSource;

/**
 * A string containing GLSL source code to be used as a preamble for the source code of this shader.
 *
 * The value of this property can be set prior to invoking the compileFromBytes:withPremble: method.
 * The content of this propery will be prepended to the source code of the shader source code.
 * You can use this property to include compiler builds settings, and other delarations.
 *
 * The initial value of this property is set to the value of the platformPreamble property.
 * If you change this property, you should concatenate the value of the platformPreamble to
 * the additional preamble content that you require.
 */
@property(nonatomic, retain) NSString* shaderPreamble;

/**
 * Returns a string containing platform-specific GLSL source code to be used as a preamble
 * for the source code of the shader.
 *
 * The value of this property defines the initial value of the shaderPreamble property.
 *
 * The value of this property is retrieved from CC3OpenGL.sharedGL.defaultShaderPreamble.
 * For OpenGL on the OSX platform, this property contains define statements to remove precision
 * qualifiers of all variables in the GLSL source code and to set the #version declaration.
 * For OpenGL ES 2.0 on the iOS platform, this property returns an empty string.
 */
@property(nonatomic, readonly) NSString* platformPreamble;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with the specified name and compiles this instance from the
 * specified GLSL source code. The value of the shaderPreamble property is prepended to
 * the specified source code prior to compiling.
 *
 * Since a single shader can be used by many shader programs, shaders are cached. Before invoking
 * this method, you should invoke the class-side getShaderNamed: method to detemine whether a
 * shader with the specified name exists already, and after invoking this method, you should use
 * the class-side addShader: method to add the new GL program instance to the shader cache.
 *
 * If you want to set properties prior to compiling the source code, you can create an
 * instance without compiling code by using one of the initialization methods defined by
 * the superclass (eg- initWithName:), set properties such as the shaderPreamble, and then
 * invoke the compileFromSource: to compile this shader from GLSL source code.
 */
-(id) initWithName: (NSString*) name fromSourceCode: (NSString*) glslSource;

/**
 * Initializes this instance compiled from GLSL source code loaded from the specified file path,
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * Since a single shader can be used by many shader programs, shaders are cached. Before invoking
 * this method, you should invoke the class-side getShaderNamed: method to detemine whether a
 * shader with the specified name exists already, and after invoking this method, you should use
 * the class-side addShader: method to add the new GL program instance to the shader cache.
 *
 * If you want to set properties prior to compiling the source code, you can create an
 * instance without compiling code by using one of the initialization methods defined by
 * the superclass (eg- initWithName:), set properties such as the shaderPreamble, and then
 * invoke the compileFromSource: method to compile this shader from GLSL source code.
 */
-(id) initFromSourceCodeFile: (NSString*) aFilePath;

/**
 * Returns an instance compiled from GLSL source code loaded from the file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * Shaders loaded through this method are cached. If the shader was already loaded and is in
 * the cache, it is retrieved and returned. If the shader has not in the cache, it is loaded
 * from the specified file, placed into the cache, and returned. It is therefore safe to invoke
 * this method any time the shader is needed, without having to worry that the shader will be
 * repeatedly loaded from file.
 *
 * To clear a shader instance from the cache, use the removeShader: method.
 *
 * To load the file directly, bypassing the cache, use the alloc and initFromSourceCodeFile:
 * methods. This technique can be used to load the same shader twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 *
 * If you want to set properties prior to compiling the source code, you can create an
 * instance without compiling code by using one of the initialization methods defined by
 * the superclass (eg- initWithName:), set properties such as the shaderPreamble, and then
 * invoke the compileFromSource: method to compile this shader from GLSL source code. Once
 * compiled, you can add the shader to the cache using the addShader: method.
 */
+(id) shaderFromSourceCodeFile: (NSString*) aFilePath;

/** 
 * Returns a shader name derived from the specified file path.
 *
 * This method is used to standardize the naming of shaders, to ease in adding and retrieving
 * shaders to and from the cache.
 */
+(NSString*) shaderNameFromFilePath: (NSString*) aFilePath;


#pragma mark Shader cache

/**
 * Adds the specified shader to the collection of loaded shaders.
 *
 * The specified shader should be compiled prior to being added here.
 *
 * Shaders are accessible via their names through the getShaderNamed: method, and should be
 * unique. If a shader with the same name as the specified shader already exists in this cache,
 * an assertion error is raised.
 */
+(void) addShader: (CC3Shader*) shader;

/** Returns the shader with the specified name, or nil if a shader with that name has not been added. */
+(CC3Shader*) getShaderNamed: (NSString*) name;

/** 
 * Removes the specified shader from the collection of loaded shaders. If the shader is
 * not retained elsewhere, it will be deallocated, and will be removed from the GL engine.
 *
 * Removing a shader from the GL engine does not affect the operation of shaders that have
 * been linked into a CC3ShaderProgram. It is common to remove shaders after you have created
 * all of the CC3ShaderPrograms that will use that shader.
 */
+(void) removeShader: (CC3Shader*) shader;

/**
 * Removes the shader with the specified name from the collection of loaded shaders.
 * If the shader is not retained elsewhere, it will be deallocated, and will be removed
 * from the GL engine.
 *
 * Removing a shader from the GL engine does not affect the operation of that shader if
 * it has been linked into a CC3ShaderProgram. It is common to remove shaders after you have 
 * created all of the CC3ShaderPrograms that will use that shader.
 */
+(void) removeShaderNamed: (NSString*) name;

/** 
 * Removes all loaded shaders from the cache.
 *
 * Removing cached shaders does not affect the operation of shaders that have been linked
 * into a CC3ShaderProgram. It is common to invoke this method after you have created all of
 * your CC3ShaderPrograms from the loaded shaders.
 */
+(void) removeAllShaders;

@end


#pragma mark CC3VertexShader

/** A CC3Shader used as a vertex shader within a shader program. */
@interface CC3VertexShader : CC3Shader
@end


#pragma mark CC3FragmentShader

/** A CC3Shader used as a fragment shader within a shader program. */
@interface CC3FragmentShader : CC3Shader
@end


#pragma mark -
#pragma mark CC3ShaderProgram

/**
 * CC3ShaderProgram represents an OpenGL shader program, containing one vertex shader and one
 * fragment shader, each compiled from GLSL source code.
 *
 * CC3ShaderProgram manages the automatic population of the attributes and uniforms from the
 * scene content by using semantic definitions for each attribute and uniform. This semantic
 * mapping is handled by a delegate held in the semanticDelegate property.
 *
 * Since a single GL program can be used by many nodes and materials, shaders are cached.
 * The application can use the class-side getProgramNamed: method to retrieve a compiled 
 * program from the cache, and the class-side addProgram: method to add a new program to
 * the cache. See the notes of those two methods for more details.
 */
@interface CC3ShaderProgram : CC3Identifiable {
	CC3VertexShader* _vertexShader;
	CC3FragmentShader* _fragmentShader;
	id<CC3ShaderProgramSemanticsDelegate> _semanticDelegate;
	CCArray* _uniformsSceneScope;
	CCArray* _uniformsNodeScope;
	CCArray* _uniformsDrawScope;
	CCArray* _attributes;
	GLint _maxUniformNameLength;
	GLint _maxAttributeNameLength;
	GLuint _programID;
	BOOL _isSceneScopeDirty : 1;
}

/** Returns the GL program ID. */
@property(nonatomic, readonly) GLuint programID;

/** The vertex shader used by this program. */
@property(nonatomic, retain) CC3VertexShader* vertexShader;

/** The fragment shader used by this program. */
@property(nonatomic, retain) CC3FragmentShader* fragmentShader;

/**
 * On each render loop, this CC3ShaderProgram delegates to this object to populate
 * the current value of each uniform variable from content within the 3D scene.
 *
 * This property must be set prior to the program being compiled.
 */
@property(nonatomic, retain) id<CC3ShaderProgramSemanticsDelegate> semanticDelegate;

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


#pragma mark Linking

/** 
 * Links the vertex and fragment shaders into this shader program.
 *
 * The vertexShader, fragmentShader, and semanticDelegate properties must be set prior
 * to invoking this method.
 */
-(void) link;


#pragma mark Binding

/** 
 * Sets the currentShaderProgram property of the specified visitor to this program, 
 * binds this program to the GL engine, and populates the program attributes and uniforms.
 */
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
 * Initializes this instance by attaching the specified semantic delegate, and linking the
 * specified vertex shader and fragment shader into this program.
 *
 * This method uses the programNameFromVertexShaderName:andFragmentShaderName: method to
 * set the name of this instance from the names of the vertex and fragment shaders.
 *
 * Since a single GL program can be used by many nodes and materials, shaders are cached.
 * Before invoking this method, you should invoke the class-side getProgramNamed: method to
 * detemine whether a GL program with the specified name exists already, and after invoking
 * this method, you should use the class-side addProgram: method to add the new GL program
 * instance to the program cache.
 */
-(id) initWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
			  withVertexShader: (CC3VertexShader*) vertexShader
			withFragmentShader: (CC3FragmentShader*) fragmentShader;

/**
 * Returns an instance by attaching the specified semantic delegate, and linking the
 * specified vertex shader and fragment shader into this program.
 *
 * Programs loaded through this method are cached. If the program was already loaded and is in
 * the cache, it is retrieved and returned. If the program has not in the cache, it is loaded,
 * compiled, and linked, placed into the cache, and returned. It is therefore safe to invoke
 * this method any time the program is needed, without having to worry that the program will
 * be repeatedly loaded and compiled from the files.
 *
 * This method uses the programNameFromVertexShaderName:andFragmentShaderName: method to
 * set the name of the instance from the names of the vertex and fragment shaders, and to
 * attempt to retrieve the program from the cache, prior to creating a new program.
 *
 * To clear a program instance from the cache, use the removeProgram: method.
 *
 * To create the program directly, bypassing the cache, use the alloc and
 * initWithSemanticDelegate:withVertexShader:withFragmentShader: methods. This
 * technique can be used to create the same program twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 */
+(id) programWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
				 withVertexShader: (CC3VertexShader*) vertexShader
			   withFragmentShader: (CC3FragmentShader*) fragmentShader;

/**
 * Initializes this instance by attaching the specified semantic delegate, and compiling and
 * linking the GLSL source code loaded from the specified vertex and fragment shader files.
 *
 * If a shader has already been loaded, compiled, and cached, the cached shader will be
 * reused, and will not be reloaded and recompiled from the file.
 *
 * The specified file paths may be either absolute paths, or relative to the application
 * resource directory. If the files are located directly in the application resources 
 * directory, the specified file paths can simply be the names of the files.
 *
 * This method uses the programNameFromVertexShaderName:andFragmentShaderName: method to
 * set the name of this instance from the names of the vertex and fragment shaders.
 *
 * Since a single GL program can be used by many nodes and materials, shaders are cached.
 * Before invoking this method, you should invoke the class-side getProgramNamed: method to
 * detemine whether a GL program with the specified name exists already, and after invoking
 * this method, you should use the class-side addProgram: method to add the new GL program
 * instance to the program cache.
 */
-(id) initWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
		  fromVertexShaderFile: (NSString*) vshFilePath
		 andFragmentShaderFile: (NSString*) fshFilePath;

/**
 * Returns an instance by attaching the specified semantic delegate, and compiling and
 * linking the GLSL source code loaded from the specified vertex and fragment shader files.
 *
 * If either shader has already been loaded, compiled, and cached, the cached shader will
 * be reused, and will not be reloaded and recompiled from the file.
 *
 * The specified file paths may be either absolute paths, or relative to the application
 * resource directory. If the files are located directly in the application resources
 * directory, the specified file paths can simply be the names of the files.
 *
 * Programs loaded through this method are cached. If the program was already loaded and is in
 * the cache, it is retrieved and returned. If the program has not in the cache, it is loaded,
 * compiled, and linked, placed into the cache, and returned. It is therefore safe to invoke
 * this method any time the program is needed, without having to worry that the program will
 * be repeatedly loaded and compiled from the files.
 *
 * This method uses the programNameFromVertexShaderName:andFragmentShaderName: method to
 * set the name of the instance from the names of the vertex and fragment shaders, and to
 * attempt to retrieve the program from the cache, prior to creating a new program.
 *
 * To clear a program instance from the cache, use the removeProgram: method.
 *
 * To create the program directly, bypassing the cache, use the alloc and 
 * initWithSemanticDelegate:fromVertexShaderFile:andFragmentShaderFile: methods. This
 * technique can be used to create the same program twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 */
+(id) programWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
			 fromVertexShaderFile: (NSString*) vshFilePath
			andFragmentShaderFile: (NSString*) fshFilePath;

/** 
 * Returns a program name created as a simple hyphenated concatenation of the specified
 * vertex and shader names.
 *
 * This method is used to standardize the naming of programs, to ease in adding and
 * retrieving programs to and from the cache.
 */
+(NSString*) programNameFromVertexShaderName: (NSString*) vertexShaderName
					   andFragmentShaderName: (NSString*) fragmentShaderName;

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
+(void) addProgram: (CC3ShaderProgram*) program;

/** Returns the program with the specified name, or nil if a program with that name has not been added. */
+(CC3ShaderProgram*) getProgramNamed: (NSString*) name;

/** Removes the specified program from the collection of loaded programs. */
+(void) removeProgram: (CC3ShaderProgram*) program;

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
 * of CC3ShaderProgramMatcherBase, the first time it is accessed.
 */
+(id<CC3ShaderProgramMatcher>) programMatcher;

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
 * of CC3ShaderProgramMatcherBase, the first time it is accessed.
 */
+(void) setProgramMatcher: (id<CC3ShaderProgramMatcher>) programMatcher;

@end

