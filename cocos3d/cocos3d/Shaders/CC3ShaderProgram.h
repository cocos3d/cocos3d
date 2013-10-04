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

@protocol CC3ShaderProgramMatcher, CC3RenderSurface;
@class CC3ShaderProgramContext, CC3NodeDrawingVisitor, CC3MeshNode;


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
 * The initial value of this property is set to the value of the defaultShaderPreamble property.
 * If you change this property, you should concatenate the value of the defaultShaderPreamble to
 * the additional preamble content that you require.
 */
@property(nonatomic, retain) NSString* shaderPreamble;

/**
 * Returns a string containing GLSL source code to be used as a default preamble for the
 * source code of the shader.
 *
 * The value of this property defines the initial value of the shaderPreamble property.
 *
 * To allow platform-specific requirements, the value of this property is retrieved from
 * CC3OpenGL.sharedGL.defaultShaderPreamble. For OpenGL on the OSX platform, this property
 * contains define statements to remove precision qualifiers of all variables in the GLSL
 * source code and to set the #version declaration. For OpenGL ES 2.0 on the iOS platform,
 * this property returns an empty string.
 *
 * Subclasses may override this property to return additional shader preamble content, such
 * as standard define statements, etc.
 */
@property(nonatomic, readonly) NSString* defaultShaderPreamble;


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
 * shaders to and from the cache, and is used to create the name for each shader that is
 * loaded from a file.
 *
 * This implementation returns the lastComponent of the specified file path.
 */
+(NSString*) shaderNameFromFilePath: (NSString*) aFilePath;

/**
 * Returns a description formatted as a source-code line for loading this shader from a source code file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code, if you want to load shaders individually. However, normally,
 * your shaders will be loaded, compiled, and cached as a result of creating a shader program.
 */
-(NSString*) constructorDescription;


#pragma mark Shader cache

/** Removes this shader instance from the cache. */
-(void) remove;

/**
 * Adds the specified shader to the collection of loaded shaders.
 *
 * The specified shader should be compiled prior to being added here.
 *
 * Shaders are accessible via their names through the getShaderNamed: method, and each
 * shader name should be unique. If a shader with the same name as the specified shader
 * already exists in this cache, an assertion error is raised.
 *
 * This cache is a weak cache, meaning that it does not hold strong references to the shaders
 * that are added to it. As a result, the specified shader will automatically be deallocated
 * and removed from this cache once all external strong references to it have been released.
 */
+(void) addShader: (CC3Shader*) shader;

/** Returns the shader with the specified name, or nil if a shader with that name has not been added. */
+(CC3Shader*) getShaderNamed: (NSString*) name;

/** 
 * Removes the specified shader from the shader cache. If the shader is
 * not retained elsewhere, it will be deallocated, and will be removed from the GL engine.
 *
 * Removing a shader from the GL engine does not affect the operation of shaders that have
 * been linked into a CC3ShaderProgram. It is common to remove shaders after you have created
 * all of the CC3ShaderPrograms that will use that shader.
 */
+(void) removeShader: (CC3Shader*) shader;

/**
 * Removes the shader with the specified name from the shader cache.
 * If the shader is not retained elsewhere, it will be deallocated, and will be removed
 * from the GL engine.
 *
 * Removing a shader from the GL engine does not affect the operation of that shader if
 * it has been linked into a CC3ShaderProgram. It is common to remove shaders after you have 
 * created all of the CC3ShaderPrograms that will use that shader.
 */
+(void) removeShaderNamed: (NSString*) name;

/**
 * Removes from the cache all shaders that are instances of any subclass of the receiver.
 *
 * Removing cached shaders does not affect the operation of shaders that have been linked
 * into a CC3ShaderProgram. It is common to invoke this method after you have created all of
 * your CC3ShaderPrograms from the loaded shaders.
 *
 * You can use this method to selectively remove specific types of shaders, based on the
 * shader class, by invoking this method on that class. If you invoke this method on the
 * CC3Shader class, this cache will be compltely cleared. However, if you invoke this method
 * on one of its subclasses, only those shaders that are instances of that subclass (or one
 * of its subclasses in turn) will be removed, leaving the remaining shaders in the cache.
 */
+(void) removeAllShaders;

/**
 * Returns whether shaders are being pre-loaded.
 *
 * See the setIsPreloading setter method for a description of how and when to use this property.
 */
+(BOOL) isPreloading;

/**
 * Sets whether shaders are being pre-loaded.
 *
 * Shaders that are added to this cache while the value of this property is YES will be strongly
 * cached and cannot be deallocated until specifically removed from this cache. You must manually
 * remove any shaders added to this cache while the value of this property is YES.
 *
 * Shaders that are added to this cache while the value of this property is NO will be weakly
 * cached, and will automatically be deallocated and removed from this cache once all references
 * to the shader program outside this cache are released.
 *
 * You can set the value of this property at any time, and can vary it between YES and NO
 * to accomodate your specific loading patterns.
 *
 * The initial value of this property is NO, meaning that shaders will be weakly cached in this
 * cache, and will automatically be removed if not used by a shader program. You can set this
 * property to YES in order to pre-load shaders that will not be immediately used in the scene,
 * but which you wish to keep in the cache for later use.
 */
+(void) setIsPreloading: (BOOL) isPreloading;

/**
 * Returns a description of the contents of this cache, with each entry formatted as a
 * source-code line for loading the shader from a source code file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code, if you want to load shaders individually. However, normally,
 * your shaders will be loaded, compiled, and cached as a result of creating a shader program.
 */
+(NSString*) cachedShadersDescription;

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

/** 
 * The vertex shader used by this program.
 *
 * Normally this property is set during initialization. If you set this property directly,
 * you must invoke the link method, and optionally, the prewarm method, once both shaders
 * have been set via this property and the fragmentShader property.
 */
@property(nonatomic, retain) CC3VertexShader* vertexShader;

/**
 * The fragment shader used by this program.
 *
 * Normally this property is set during initialization. If you set this property directly,
 * you must invoke the link method, and optionally, the prewarm method, once both shaders
 * have been set via this property and the vertexShader property.
 */
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

/** Returns the number of uniforms declared and in use by this program. */
@property(nonatomic, readonly) GLuint uniformCount;

/** Returns the number of memory storage elements consumed by the uniform variables used by this program. */
@property(nonatomic, readonly) GLuint uniformStorageElementCount;

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

/** Returns the number of vertex attributes declared and in use by this program. */
@property(nonatomic, readonly) GLuint attributeCount;

/** 
 * Returns the vertex attribute with the specified semantic and index,
 * or nil if no attribute is defined for the specified semantic.
 */
-(CC3GLSLAttribute*) attributeForSemantic: (GLenum) semantic at: (GLuint) semanticIndex;

/**
 * Returns the vertex attribute with the specified semantic at index zero,
 * or nil if no attribute is defined for the specified semantic.
 */
-(CC3GLSLAttribute*) attributeForSemantic: (GLenum) semantic;

/** Returns the vertex attribute with the specified name, or nil if no attribute is defined for the specified name. */
-(CC3GLSLAttribute*) attributeNamed: (NSString*) name;

/** Returns the vertex attribute at the specified location, or nil if no attribute is defined at the specified location. */
-(CC3GLSLAttribute*) attributeAtLocation: (GLint) attrLocation;


#pragma mark Linking

/** 
 * Links the vertex and fragment shaders into this shader program.
 *
 * The vertexShader, fragmentShader, and semanticDelegate properties must be set prior
 * to invoking this method.
 *
 * This method is automatically invoked during instance initialization if the vertex and
 * fragment shaders are provided. If you create this instance without shaders and add them
 * later, you can invoke this method once the vertexShader and fragmentShader properties
 * have been set.
 */
-(void) link;

/**
 * Pre-warms this shader program by using it to render a small mesh node to an off-screen surface.
 *
 * The GL engine may choose to defer some final shader program compilation steps until the
 * first time the shader program is used to render a mesh. This can cause the first frame of
 * the first mesh drawn with the shader program to take significantly longer than subsequent
 * renderings with that shader program, which can often result in a transient, but noticable,
 * "freezing" of the scene. This is particularly apparent for new meshes that are added to
 * the scene at any point other than during scene initialization.
 *
 * To avoid this, this method can be invoked to cause this shader program to render a small
 * mesh to an off-screen rendering surface, in order to force this shader program to perform
 * its final compilation and linking steps at a controlled, and predicatble, time.
 *
 * This method is automatically invoked during instance initialization if the vertex and
 * fragment shaders are provided. If you create this instance without shaders and add them
 * later, you can invoke this method once the vertexShader and fragmentShader properties
 * have been set, and the link method has been invoked.
 */
-(void) prewarm;


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

/**
 * Resets the GL state management used by this shader program, including the values of
 * all variables.
 */
-(void) resetGLState;


#pragma mark Allocation and initialization

/**
 * Initializes this instance by setting the vertexShader and programShader properties to the
 * specified shaders, and invoking the link and prewarm methods to prepare this instance for use.
 *
 * The semanticDelegate property is set to the default semantic delegate returned from the
 * semanticDelegate property of the program matcher in the class-side programMatcher property.
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
-(id) initWithVertexShader: (CC3VertexShader*) vertexShader
		 andFragmentShader: (CC3FragmentShader*) fragmentShader;

/**
 * Returns an instance by setting the vertexShader and programShader properties to the 
 * specified shaders, and invoking the link and prewarm methods to prepare the instance for use.
 *
 * The semanticDelegate property is set to the default semantic delegate returned from the
 * semanticDelegate property of the program matcher in the class-side programMatcher property.
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
+(id) programWithVertexShader: (CC3VertexShader*) vertexShader
			andFragmentShader: (CC3FragmentShader*) fragmentShader;

/**
 * Initializes this instance by setting the vertexShader and programShader properties to shaders
 * compiled from the GLSL source code loaded from the specified files, and invoking the link and
 * prewarm methods to prepare this instance for use.
 *
 Initializes this instance by compiling and linking the GLSL source code loaded from the
 * specified vertex and fragment shader files.
 *
 * If a shader has already been loaded, compiled, and cached, the cached shader will be
 * reused, and will not be reloaded and recompiled from the file.
 *
 * The specified file paths may be either absolute paths, or relative to the application
 * resource directory. If the files are located directly in the application resources
 * directory, the specified file paths can simply be the names of the files.
 *
 * The semanticDelegate property is set to the default semantic delegate returned from the
 * semanticDelegate property of the program matcher in the class-side programMatcher property.
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
-(id) initFromVertexShaderFile: (NSString*) vshFilePath
		 andFragmentShaderFile: (NSString*) fshFilePath;

/**
 * Returns an instance by setting the vertexShader and programShader properties to shaders
 * compiled from the GLSL source code loaded from the specified files, and invoking the link
 * and prewarm methods to prepare the instance for use.
 *
 * If either shader has already been loaded, compiled, and cached, the cached shader will
 * be reused, and will not be reloaded and recompiled from the file.
 *
 * The specified file paths may be either absolute paths, or relative to the application
 * resource directory. If the files are located directly in the application resources
 * directory, the specified file paths can simply be the names of the files.
 *
 * The semanticDelegate property is set to the default semantic delegate returned from the
 * semanticDelegate property of the program matcher in the class-side programMatcher property.
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
+(id) programFromVertexShaderFile: (NSString*) vshFilePath
			andFragmentShaderFile: (NSString*) fshFilePath;

/**
 * Initializes this instance by setting the semanticDelegate property to the specified
 * semantic delgate, setting the vertexShader and programShader properties to the specified
 * shaders, and invoking the link and prewarm methods to prepare this instance for use.
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
			 andFragmentShader: (CC3FragmentShader*) fragmentShader;

/**
 * Returns an instance by setting the semanticDelegate property to the specified semantic
 * delgate, setting the vertexShader and programShader properties to the specified shaders,
 * and invoking the link and prewarm methods to prepare the instance for use.
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
				andFragmentShader: (CC3FragmentShader*) fragmentShader;

/**
 * Initializes this instance by setting the semanticDelegate property to the specified
 * semantic delgate, setting the vertexShader and programShader properties to shaders
 * compiled from the GLSL source code loaded from the specified files, and invoking the
 * link and prewarm methods to prepare this instance for use.
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
 * Returns an instance by setting the semanticDelegate property to the specified semantic
 * delgate, setting the vertexShader and programShader properties to shaders compiled from
 * the GLSL source code loaded from the specified files, and invoking the link and prewarm
 * methods to prepare this instance for use.
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

/** 
 * Returns a description formatted as a source-code line for loading this program from shader source code files.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code.
 */
-(NSString*) constructorDescription;


#pragma mark Program cache

/** Removes this program instance from the cache. */
-(void) remove;

/**
 * Adds the specified program to the collection of loaded programs.
 *
 * The specified program should be compiled and linked prior to being added here.
 *
 * Programs are accessible via their names through the getProgramNamed: method, and each
 * program name should be unique. If a program with the same name as the specified program
 * already exists in this cache, an assertion error is raised.
 *
 * This cache is a weak cache, meaning that it does not hold strong references to the programs
 * that are added to it. As a result, the specified program will automatically be deallocated
 * and removed from this cache once all external strong references to it have been released.
 */
+(void) addProgram: (CC3ShaderProgram*) program;

/** Returns the program with the specified name, or nil if a program with that name has not been added. */
+(CC3ShaderProgram*) getProgramNamed: (NSString*) name;

/** Removes the specified program from the program cache. */
+(void) removeProgram: (CC3ShaderProgram*) program;

/** Removes the program with the specified name from the program cache. */
+(void) removeProgramNamed: (NSString*) name;

/**
 * Removes from the cache all shader programs that are instances of any subclass of the receiver.
 *
 * You can use this method to selectively remove specific types of shader programs, based on
 * the shader program class, by invoking this method on that class. If you invoke this method
 * on the CC3ShaderProgram class, this cache will be compltely cleared. However, if you invoke
 * this method on one of its subclasses, only those shader programs that are instances of that
 * subclass (or one of its subclasses in turn) will be removed, leaving the remaining shader 
 * programs in the cache.
 */
+(void) removeAllPrograms;

/** 
 * Returns whether shader programs are being pre-loaded.
 *
 * See the setIsPreloading setter method for a description of how and when to use this property.
 */
+(BOOL) isPreloading;

/**
 * Sets whether shader programs are being pre-loaded.
 *
 * Shader programs that are added to this cache while the value of this property is YES will
 * be strongly cached and cannot be deallocated until specifically removed from this cache.
 * You must manually remove any shader programs added to this cache while the value of this
 * property is YES.
 *
 * Shader programs that are added to this cache while the value of this property is NO will
 * be weakly cached, and will automatically be deallocated and removed from this cache once
 * all references to the shader program outside this cache are released.
 *
 * If you will be loading resources such as models and textures on a background thread while
 * the scene is running, you will find that any shader programs that are loaded while the
 * scene is running will often create a brief, but noticable, pause in the scene while the
 * final stages of the shader program are conmpiled and configured.
 *
 * You can avoid this pause by pre-loading all of the shader programs that your scene will
 * need during scene initialization. They will then automatically be recalled from this cache
 * when needed by the models that you load mid-scene. In order for them to be available in
 * this cache at that time, the value of this property must be set to YES for the duration
 * of the pre-loading stage during scene initialization.
 *
 * You can set the value of this property at any time, and can vary it between YES and NO
 * to accomodate your specific loading patterns.
 *
 * The initial value of this property is NO, meaning that shader programs will be weakly
 * cached in this cache, and will automatically be removed if not used by a model. You can
 * set this property to YES in order to pre-load shader programs that will not be immediately
 * used in the scene, but which you wish to keep in the cache for later use.
 */
+(void) setIsPreloading: (BOOL) isPreloading;

/**
 * Invoked to indicate that scene drawing is about to begin.
 *
 * This method invokes the same method on each instance in the cache.
 */
+(void) willBeginDrawingScene;

/**
 * Returns a description of the contents of this cache, with each entry formatted as a
 * source-code line for loading the shader program from shader source code files.
 *
 * During development time, you can log this string, then copy and paste it into a 
 * pre-loading function within your app code.
 */
+(NSString*) cachedProgramsDescription;



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


#pragma mark -
#pragma mark CC3ShaderProgramPrewarmer

/**
 * Utility class that pre-warms shader programs by using them to render a small mesh node
 * to an off-screen surface.
 *
 * The GL engine may choose to defer some final shader program compilation steps until the
 * first time the shader program is used to render a mesh. This can cause the first frame of
 * the first mesh drawn with the shader program to take significantly longer than subsequent
 * renderings with that shader program, which can often result in a transient, but noticable,
 * "freezing" of the scene. This is particularly apparent for new meshes that are added to
 * the scene at any point other than during scene initialization.
 *
 * To avoid this, this class contains a small mesh and an off-screen rendering surface to which
 * the mesh can be rendered using a shader program, in order to force that shader program to
 * perform its final compilation and linking steps at a controlled, and predicatble, time.
 */
@interface CC3ShaderProgramPrewarmer : CC3Identifiable {
	id<CC3RenderSurface> _prewarmingSurface;
	CC3MeshNode* _prewarmingMeshNode;
	CC3NodeDrawingVisitor* _drawingVisitor;
}

/** 
 * The surface to which the prewarmingMeshNode is rendered in order to pre-warm a shader program.
 *
 * If not set directly, this property will be initialized to a minimal off-screen surface that
 * contains only a color buffer, with no depth buffer.
 */
@property(nonatomic, retain) id<CC3RenderSurface> prewarmingSurface;

/** 
 * The mesh node that is rendered to the prewarmingSurface in order to pre-warm a shader program.
 *
 * If not set directly, this property will be lazily initialized to a minimal mesh consisting
 * of a single triangular face containing only location content in the verticies.
 */
@property(nonatomic, retain) CC3MeshNode* prewarmingMeshNode;

/** 
 * The drawing visitor used to render the prewarmingMeshNode to the prewarmingSurface.
 *
 * If not set directly, this property will be lazily initialized to a a basic drawing visitor.
 */
@property(nonatomic, retain) CC3NodeDrawingVisitor* drawingVisitor;

/** Pre-warms the specified shader program by rendering the prewarmingMeshNode to the prewarmingSurface. */
-(void) prewarmShaderProgram: (CC3ShaderProgram*) program;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance with the specified name. */
+(id) prewarmerWithName: (NSString*) name;

@end
