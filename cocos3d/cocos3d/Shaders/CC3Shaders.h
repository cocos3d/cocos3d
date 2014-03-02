/*
 * CC3Shaders.h
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

#import "CC3Identifiable.h"
#import "CC3Environment.h"
#import "CC3CC2Extensions.h"
#import "CC3GLSLVariable.h"
#import "CC3ShaderSemantics.h"

// Legacy naming support
#define CC3GLProgram					CC3ShaderProgram
#define CC3ShaderProgramPrewarmer		CC3ShaderPrewarmer

@protocol CC3ShaderMatcher, CC3RenderSurface;
@class CC3ShaderContext, CC3NodeDrawingVisitor, CC3MeshNode;
@class CC3ShaderSourceCode, CC3ShaderSourceCodeStrings;
@class CC3ShaderSourceCodeLineNumberLocalizingVisitor;
@class CC3ShaderSourceCodeSegmentAccumulatingVisitor;
@class CC3ShaderSourceCodeCompilationStringVisitor;
@class CC3ShaderSourceCodeCompilationStringCountVisitor;


#pragma mark -
#pragma mark CC3Shader

/**
 * CC3Shader represents an OpenGL shader, compiled from GLSL source code.
 *
 * CC3Shader is an abstract class, and has two concrete classes: CC3VertexShader and CC3FragmentShader.
 *
 * Since a single shader can be used by more than one shader program, shaders are cached,
 * and are retrieved automatically when a CC3ShaderProgram that requires the shaders is
 * created. Typically, the application does not create instances of CC3Shader directly.
 */
@interface CC3Shader : CC3Identifiable {
	CC3ShaderSourceCode* _shaderPreamble;
	GLuint _shaderID;
	BOOL _wasLoadedFromFile : 1;
}

/** Returns the GL shader ID. */
@property(nonatomic, readonly) GLuint shaderID;

/** Returns the type of shader, either GL_VERTEX_SHADER or GL_FRAGMENT_SHADER. */
-(GLenum) shaderType;


#pragma mark Compiling

/**
 * Compiles this shader from the specified shader source code, and returns whether compilation
 * was successful. The value of the shaderPreamble property is prepended to the specified source
 * code prior to compiling.
 */
-(void) compileFromSourceCode: (CC3ShaderSourceCode*) shSrcCode;

/**
 * Compiles this shader from the specified GLSL source code, and returns whether compilation
 * was successful. The value of the shaderPreamble property is prepended to the specified
 * source code prior to compiling.
 *
 * The implementation of this method creates a CC3ShaderSourceCode instance from the specified
 * source code string and then invokes the compileFromSourceCode: method.
 */
-(void) compileFromSourceCodeString: (NSString*) srcCodeString;

/**
 * The shader source code object associated with the shaderPreambleString property.
 *
 * You can set the shader preamble source code by either setting this property or setting
 * the shaderPreambleString property.
 *
 * This preamble may contain #import or #include directives to load additional source code from
 * other files. The #import and #include directives perform identically. Regardless of which you
 * choose to use, if the same file is imported or included more than once (perhaps through nesting),
 * the loader will ensure that only one copy of each source file is loaded.
 */
@property(nonatomic, retain) CC3ShaderSourceCode* shaderPreamble;

/**
 * A string containing GLSL source code to be used as a preamble for the source code of this shader.
 *
 * The value of this property can be set prior to invoking the compileFromSourceCode: or
 * compileFromSourceCodeString: method. The content of this propery will be prepended to the shader
 * source code. You can use this property to include compiler builds settings, and other delarations.
 * 
 * This preamble may contain #import or #include directives to load additional source code from
 * other files. The #import and #include directives perform identically. Regardless of which you
 * choose to use, if the same file is imported or included more than once (perhaps through nesting),
 * the loader will ensure that only one copy of each source file is loaded.
 *
 * This is a convenience property that uses the shaderPreamble property to actually hold the
 * preamble source code. Setting this property also changes the contents of theshaderPreamble
 * property. Reading this property retrieves a string representation of the preamble source code
 * held in the shaderPreamble property.
 *
 * The initial value of this property is set to the value of the defaultShaderPreambleString 
 * property. If you change this property, you should usually concatenate the value of the
 * defaultShaderPreambleString property to the additional preamble content that you require.
 */
@property(nonatomic, retain) NSString* shaderPreambleString;

/**
 * Returns the shader source object containing GLSL source code to be used as a default
 * preamble for the source code of the shader.
 *
 * The value of this property defines the initial value of the shaderPreamble property.
 *
 * To allow platform-specific requirements, the value of this property is retrieved from
 * CC3OpenGL.sharedGL.defaultShaderPreamble, and contains platform-specific defines.
 *
 * In addition, for OpenGL on the OSX platform, this property contains define statements
 * to remove any precision qualifiers of all variables in the GLSL source code and to set
 * the GLSL #version declaration.
 *
 * Subclasses may override this property to return additional shader preamble content,
 * such as standard define statements, etc. Subclasses may find it easier to override the
 * defaultShaderPreambleString property instead.
 *
 * This preamble may contain #import or #include directives to load additional source code from
 * other files. The #import and #include directives perform identically. Regardless of which you
 * choose to use, if the same file is imported or included more than once (perhaps through nesting),
 * the loader will ensure that only one copy of each source file is loaded.
 */
@property(nonatomic, retain, readonly) CC3ShaderSourceCode* defaultShaderPreamble;

/**
 * Returns a string containing GLSL source code to be used as a default preamble for the
 * source code of the shader.
 *
 * The value of this property defines the initial value of the shaderPreambleString property.
 *
 * To allow platform-specific requirements, the value of this property is retrieved from
 * CC3OpenGL.sharedGL.defaultShaderPreamble, and contains platform-specific defines.
 *
 * In addition, for OpenGL on the OSX platform, this property contains define statements
 * to remove any precision qualifiers of all variables in the GLSL source code and to set
 * the GLSL #version declaration.
 *
 * Subclasses may override this property to return additional shader preamble content, such
 * as standard define statements, etc.
 *
 * This preamble may contain #import or #include directives to load additional source code from
 * other files. The #import and #include directives perform identically. Regardless of which you
 * choose to use, if the same file is imported or included more than once (perhaps through nesting),
 * the loader will ensure that only one copy of each source file is loaded.
 */
@property(nonatomic, retain, readonly) NSString* defaultShaderPreambleString;


#pragma mark Allocation and initialization

/**
 * Initializes this instance compiled from GLSL source code in the specified shader source code,
 *
 * Prior to compiling, the value of the shaderPreamble property is prepended to the the specified
 * shader source code.
 *
 * The name of this instance is set to the name of the specified shader source code, and the tag
 * is set to an automatically generated unique tag value.
 *
 * The specified shader source code may contain #import or #include directives to load additional 
 * source code from other files. The #import and #include directives perform identically. 
 * Regardless of which you choose to use, if the same file is imported or included more than once
 * (perhaps through nesting), the loader will ensure that only one copy of each source file is loaded.
 *
 * Since a single shader can be used by many shader programs, shaders are cached. Typically,
 * this method is not invoked directly, and the shaderFromSourceCodeFile: method is used instead.
 *
 * If you do use this method directly, before invoking this method, you can invoke the class-side
 * getShaderNamed: method to detemine whether a shader with the name of the specified shader source
 * already exists, and after invoking this method, you should use the class-side addShader: method
 * to add the new shader instance to the shader cache.
 *
 * If you want to set properties prior to compiling the source code, you can create an
 * instance without compiling code by using one of the initialization methods defined by
 * the superclass (eg- initWithName:), set properties such as the shaderPreamble, and then
 * invoke the compileFromSource: method to compile this shader from GLSL source code.
 */
-(id) initFromSourceCode: (CC3ShaderSourceCode*) shSrcCode;

/**
 * Initializes this instance with the specified name and compiles this instance from the
 * specified GLSL source code. The value of the shaderPreambleString property is prepended
 * to the specified source code prior to compiling.
 *
 * The specified shader source code may contain #import or #include directives to load additional
 * source code from other files. The #import and #include directives perform identically.
 * Regardless of which you choose to use, if the same file is imported or included more than once
 * (perhaps through nesting), the loader will ensure that only one copy of each source file is loaded.
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
-(id) initWithName: (NSString*) name fromSourceCode: (NSString*) srcCodeString;

/**
 * Returns an instance with the specified name and compiled from specified GLSL source code.
 *
 * The specified shader source code may contain #import or #include directives to load additional
 * source code from other files. The #import and #include directives perform identically.
 * Regardless of which you choose to use, if the same file is imported or included more than once
 * (perhaps through nesting), the loader will ensure that only one copy of each source file is loaded.
 *
 * Shaders loaded through this method are cached. If a shader with the specified name is already
 * in the cache, it is retrieved and returned. If the shader has not in the cache, it is compiled
 * from the specified source code, placed into the cache, and returned. It is therefore safe to
 * invoke this method any time the shader is needed, without having to worry that the shader will
 * be repeatedly compiled.
 *
 * To clear a shader instance from the cache, use the removeShader: method.
 *
 * To instantiate and compile a new shader directly, bypassing the cache, use the alloc and
 * initWithName:fromSourceCode: methods.
 *
 * If you want to set properties prior to compiling the source code, you can create an
 * instance without compiling code by using one of the initialization methods defined by
 * the superclass (eg- initWithName:), set properties such as the shaderPreamble, and then
 * invoke the compileFromSource: method to compile this shader from GLSL source code. Once
 * compiled, you can add the shader to the cache using the addShader: method.
 */
+(id) shaderWithName: (NSString*) name fromSourceCode: (NSString*) srcCodeString;

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
 * The specified shader source code may contain #import or #include directives to load additional
 * source code from other files. The #import and #include directives perform identically.
 * Regardless of which you choose to use, if the same file is imported or included more than once
 * (perhaps through nesting), the loader will ensure that only one copy of each source file is loaded.
 *
 * Since a single shader can be used by many shader programs, shaders are cached. Typically,
 * this method is not invoked directly, and the shaderFromSourceCodeFile: method is used instead.
 *
 * If you do use this method directly, before invoking this method, you can invoke the class-side
 * getShaderNamed: method to detemine whether a shader with the specified filename already exists,
 * and after invoking this method, you should use the class-side addShader: method to add the new
 * shader instance to the shader cache.
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
 * The specified shader source code may contain #import or #include directives to load additional
 * source code from other files. The #import and #include directives perform identically.
 * Regardless of which you choose to use, if the same file is imported or included more than once
 * (perhaps through nesting), the loader will ensure that only one copy of each source file is loaded.
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

/** @deprecated Use the CC3ShaderSourceCode shaderSourceCodeNameFromFilePath: method instead. */
+(NSString*) shaderNameFromFilePath: (NSString*) aFilePath DEPRECATED_ATTRIBUTE;

/**
 * Indicates whether this shader was loaded from a file.
 *
 * The value of this property is automatically set by the allocation and instantiation
 * methods that load this shader from a file.
 */
@property(nonatomic, readonly) BOOL wasLoadedFromFile;

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
 * Depending on the value of the isPreloading property, the shader may be held within this cache
 * as a weak reference. As a result, the specified shader may automatically be deallocated and
 * removed from this cache once all external strong references to it have been released.
 */
+(void) addShader: (CC3Shader*) shader;

/** Returns the shader with the specified name, or nil if a shader with that name has not been added. */
+(CC3Shader*) getShaderNamed: (NSString*) name;

/** 
 * Removes the specified shader from the shader cache. If the shader is not strongly referenced
 * elsewhere, it will be deallocated, and will be removed from the GL engine.
 *
 * Removing a shader from the GL engine does not affect the operation of shaders that have
 * been linked into a CC3ShaderProgram. It is common to remove shaders after you have created
 * all of the CC3ShaderPrograms that will use that shader.
 */
+(void) removeShader: (CC3Shader*) shader;

/**
 * Removes the shader with the specified name from the shader cache. If the shader is not
 * strongly referenced elsewhere, it will be deallocated, and will be removed from the GL engine.
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
 * Returns a description of the shaders in this cache that were loaded from files,
 * with each entry formatted as a source-code line for loading the shader from a file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code, if you want to load shaders individually. However, normally,
 * your shaders will be loaded, compiled, and cached as a result of creating a shader program.
 */
+(NSString*) loadedShadersDescription;

@end


#pragma mark -
#pragma mark CC3VertexShader

/** A CC3Shader used as a vertex shader within a shader program. */
@interface CC3VertexShader : CC3Shader
@end


#pragma mark -
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
 * Since a single shader program can be used by many nodes and materials, shader programs are cached.
 * The most common, and recommended way to create shader programs is to use the
 * programFromVertexShaderFile:andFragmentShaderFile: method, which automatically manages the
 * cache, and only loads, compiles and links the shader program if it is not already cached.
 */
@interface CC3ShaderProgram : CC3Identifiable {
	CC3VertexShader* _vertexShader;
	CC3FragmentShader* _fragmentShader;
	id<CC3ShaderSemanticsDelegate> _semanticDelegate;
	NSMutableArray* _attributes;
	NSMutableArray* _uniformsSceneScope;
	NSMutableArray* _uniformsNodeScope;
	NSMutableArray* _uniformsDrawScope;
	GLuint _programID;
	GLint _maxUniformNameLength;
	GLint _maxAttributeNameLength;
	GLuint _texture2DCount;
	GLuint _textureCubeCount;
	BOOL _shouldAllowDefaultVariableValues : 1;
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
@property(nonatomic, retain) id<CC3ShaderSemanticsDelegate> semanticDelegate;

/** Returns the length of the largest uniform name in this program. */
@property(nonatomic, readonly) GLint maxUniformNameLength;

/** Returns the length of the largest attribute name in this program. */
@property(nonatomic, readonly) GLint maxAttributeNameLength;

/** Returns the number of uniforms declared and in use by this program. */
@property(nonatomic, readonly) GLuint uniformCount;

/** Returns a read-only array of the GLSL uniforms declared and used by this shader program. */
@property(nonatomic, retain, readonly) NSArray* uniforms;

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

/** Returns the number of 2D textures supported by this shader program. */
@property(nonatomic, readonly) GLuint texture2DCount;

/** Returns the number of cube-map textures supported by this shader program. */
@property(nonatomic, readonly) GLuint textureCubeCount;

/** Returns the number of vertex attributes declared and in use by this program. */
@property(nonatomic, readonly) GLuint attributeCount;

/** Returns a read-only array of the GLSL attributes declared and used by this shader program. */
@property(nonatomic, readonly) NSArray* attributes;

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

/**
 * Each uniform used by this shader program must have a valid value. This property can be used to 
 * indicate whether a uniform, whose value cannot be determined, will use its standard default value.
 *
 * If the value of this property is YES, and the value of a uniform has not been set via either
 * a semantic mapping, or a uniform override in the shader context in a mesh node, a default value
 * will be used for the variable. The default value depends on the variable type. It will be zero
 * for scalars, (0,0,0,1) for vectors, or an identity matrix for matrices.
 *
 * If the value of this property is NO, and the value of a uniform has not been set via either
 * a semantic mapping, or a uniform override in the shader context in a mesh node, an assertion
 * error will be raised. This ensures that unexpected missing uniform variables are detected
 * directly and early in the development cycle.
 *
 * The initial value of this property is determined by the value of the class-side
 * defaultShouldAllowDefaultVariableValues property. By default, this will be NO, indicating
 * that an assertion error will be raised if the value of a uniform cannot be determined.
 */
@property(nonatomic, assign) BOOL shouldAllowDefaultVariableValues;

/**
 * Indicates the initial value of the shouldAllowDefaultVariableValues for each instance.
 *
 * See the notes for the shouldAllowDefaultVariableValues property for a full discussion.
 *
 * The initial value of this property is NO.
 */
+(BOOL) defaultShouldAllowDefaultVariableValues;

/**
 * Indicates the initial value of the shouldAllowDefaultVariableValues for each instance.
 *
 * See the notes for the shouldAllowDefaultVariableValues property for a full discussion.
 *
 * The initial value of this property is NO.
 */
+(void) setDefaultShouldAllowDefaultVariableValues: (BOOL) shouldAllow;


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
 * semanticDelegate property of the program matcher in the class-side shaderMatcher property.
 *
 * This method uses the programNameFromVertexShaderName:andFragmentShaderName: method to
 * set the name of this instance from the names of the vertex and fragment shaders.
 *
 * Since a single shader program can be used by many nodes and materials, shader programs are cached.
 * Typically, this method is not invoked directly, and the programWithVertexShader:andFragmentShader:
 * method is used instead.
 *
 * If you do use this method directly, before invoking this method, you can invoke the class-side
 * getProgramNamed: method, to detemine whether a shader program with a name derived from the
 * programNameFromVertexShaderName:andFragmentShaderName: method already exists, and after invoking
 * this method, you should use the class-side addProgram: method to add the new shader program
 * instance to the program cache.
 */
-(id) initWithVertexShader: (CC3VertexShader*) vertexShader
		 andFragmentShader: (CC3FragmentShader*) fragmentShader;

/**
 * Returns an instance by setting the vertexShader and programShader properties to the
 * specified shaders, and invoking the link and prewarm methods to prepare the instance for use.
 *
 * The semanticDelegate property is set to the default semantic delegate returned from the
 * semanticDelegate property of the program matcher in the class-side shaderMatcher property.
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
 * Initializes this instance by compiling and linking the GLSL source code loaded from the
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
 * semanticDelegate property of the program matcher in the class-side shaderMatcher property.
 *
 * This method uses the programNameFromVertexShaderName:andFragmentShaderName: method to
 * set the name of this instance from the names of the vertex and fragment shaders.
 *
 * Since a single shader program can be used by many nodes and materials, shaders are cached.
 * Typically, this method is not invoked directly, and the programFromVertexShaderFile:andFragmentShaderFile:
 * method is used instead.
 
 * If you do use this method directly, before invoking this method, you can invoke the class-side
 * getProgramNamed: method to detemine whether a shader program with with a name derived from the
 * programNameFromVertexShaderName:andFragmentShaderName: method already exists, and after invoking
 * this method, you should use the class-side addProgram: method to add the new shader program
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
 * semanticDelegate property of the program matcher in the class-side shaderMatcher property.
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
 * Since a single shader program can be used by many nodes and materials, shader programs are cached.
 * Typically, this method is not invoked directly, and the programWithVertexShader:andFragmentShader:
 * method is used instead.
 *
 * If you do use this method directly, before invoking this method, you can invoke the class-side
 * getProgramNamed: method, to detemine whether a shader program with a name derived from the
 * programNameFromVertexShaderName:andFragmentShaderName: method already exists, and after invoking
 * this method, you should use the class-side addProgram: method to add the new shader program
 * instance to the program cache.
 */
-(id) initWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
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
+(id) programWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
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
 * Since a single shader program can be used by many nodes and materials, shaders are cached.
 * Typically, this method is not invoked directly, and the programFromVertexShaderFile:andFragmentShaderFile:
 * method is used instead.
 
 * If you do use this method directly, before invoking this method, you can invoke the class-side
 * getProgramNamed: method to detemine whether a shader program with with a name derived from the
 * programNameFromVertexShaderName:andFragmentShaderName: method already exists, and after invoking
 * this method, you should use the class-side addProgram: method to add the new shader program
 * instance to the program cache.
 */
-(id) initWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
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
+(id) programWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
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

/**
 * Indicates whether this shader program was loaded from files.
 *
 * Returns YES if both the vertex and fragment shaders were loaded from files, otherwise returns NO.
 */
@property(nonatomic, readonly) BOOL wasLoadedFromFile;

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
 * Depending on the value of the isPreloading property, the shader program may be held within
 * this cache as a weak reference. As a result, the specified shader program may automatically
 * be deallocated and removed from this cache once all external strong references to it have
 * been released.
 *
 * If the value of both the shouldAutomaticallyPreloadMatchingPureColorPrograms and isPreloading
 * properties are set to YES, this method will ensure that a matching pure-color program is
 * added to the cache for each regular program that is added. The pureColorProgramMatching:
 * method, of the program matcher found in the class-side shaderMatcher property, is used
 * to create the matching pure-color program.
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
 * Returns whether this shader program cache should automatically add a matching pure-color
 * shader program for each normal shader program that is added to this cache during shader
 * program preloading.
 *
 * If both this property and the isPreloading property are set to YES, the addProgram method
 * will ensure that a matching pure-color shader program is added for each normal shader
 * program that is added using that method.
 *
 * If pre-loading is not active, each shader program is loaded dynamically the first time it is
 * needed, and is added to the cache at that time. For such dynamically-loaded shader programs,
 * the corresponding pure-color shader program will be dynamically loaded when it is needed,
 * in turn. Typically this will be the first time node is involved in node picking as a result
 * of a touch event.
 *
 * The initial value of this property is YES, ensuring that a matching pure-color program will
 * be added for each normal shader program that is added during pre-loading. Pure-color shader
 * programs are used when rendering a node for picking from a touch-event. You should therefore
 * leave the value of this property at its default value, unless your app does not use touch
 * events to pick nodes.
 */
+(BOOL) shouldAutomaticallyPreloadMatchingPureColorPrograms;

/**
 * Sets whether this shader program cache should automatically add a matching pure-color
 * shader program for each normal shader program that is added to this cache during shader
 * program preloading.
 *
 * If both this property and the isPreloading property are set to YES, the addProgram method
 * will ensure that a matching pure-color shader program is added for each normal shader
 * program that is added using that method.
 *
 * If pre-loading is not active, each shader program is loaded dynamically the first time it is
 * needed, and is added to the cache at that time. For such dynamically-loaded shader programs,
 * the corresponding pure-color shader program will be dynamically loaded when it is needed,
 * in turn. Typically this will be the first time node is involved in node picking as a result
 * of a touch event.
 *
 * The initial value of this property is YES, ensuring that a matching pure-color program will
 * be added for each normal shader program that is added during pre-loading. Pure-color shader
 * programs are used when rendering a node for picking from a touch-event. You should therefore
 * leave the value of this property at its default value, unless your app does not use touch
 * events to pick nodes.
 */
+(void) setShouldAutomaticallyPreloadMatchingPureColorPrograms: (BOOL) shouldAdd;

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
 * Returns a description of the shader programs in this cache that were loaded from files,
 * with each entry formatted as a source-code line to load the shader program from a file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code to pre-load the shader programs for later use.
 */
+(NSString*) loadedProgramsDescription;


#pragma mark Shader matching

/**
 * This property contains a helper delegate object that determines which shaders to use when
 * rendering a particular CC3MeshNode.
 *
 * Rendering a mesh node requires a shader program. Typically, the shader program is assigned
 * to the mesh node when the node is created or loaded from a model resource. This is either
 * done by the resource loader, based on configuration information, or by the application 
 * directly, via the shaderProgram or shaderContext properties on the mesh node.
 *
 * As a convenience, once a mesh node has been constructed and configured, the application can use
 * the shader matcher in this property to retrieve a shader program suitable for rendering that node.
 *
 * If the application does not assign a specific shader program to a mesh node, the shader
 * matcher in this property will be accessed automatically to assign a shader program when
 * the node is first rendered.
 *
 * If desired, the application can set a custom shader matcher into this property. If the 
 * value of this property is not explicitly set by the application, it is lazily initialized
 * to an instance of CC3ShaderMatcherBase, the first time it is accessed.
 */
+(id<CC3ShaderMatcher>) shaderMatcher;

/**
 * This property contains a helper delegate object that determines which shaders to use when
 * rendering a particular CC3MeshNode.
 *
 * Rendering a mesh node requires a shader program. Typically, the shader program is assigned
 * to the mesh node when the node is created or loaded from a model resource. This is either
 * done by the resource loader, based on configuration information, or by the application
 * directly, via the shaderProgram or shaderContext properties on the mesh node.
 *
 * As a convenience, once a mesh node has been constructed and configured, the application can use
 * the shader matcher in this property to retrieve a shader program suitable for rendering that node.
 *
 * If the application does not assign a specific shader program to a mesh node, the shader
 * matcher in this property will be accessed automatically to assign a shader program when
 * the node is first rendered.
 *
 * If desired, the application can set a custom shader matcher into this property. If the
 * value of this property is not explicitly set by the application, it is lazily initialized
 * to an instance of CC3ShaderMatcherBase, the first time it is accessed.
 */
+(void) setShaderMatcher: (id<CC3ShaderMatcher>) shaderMatcher;

/** @deprecated Renamed to shaderMatcher. */
+(id<CC3ShaderMatcher>) programMatcher DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to setShaderMatcher:. */
+(void) setProgramMatcher: (id<CC3ShaderMatcher>) programMatcher DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3ShaderSourceCode

/**
 * A CC3ShaderSourceCode instance contains shader source code.
 *
 * CC3ShaderSourceCode is the visible class of a class-cluster. The actual class created
 * and returned during instantitation from source code will depend on the structure of
 * the source code.
 *
 * Modular shader code is supported through the use of #import and #include statements.
 * Shader source code loaded using this class cluster may contain #import and #include
 * statements to load additional code in-place from other source code files. Importing
 * may be nested to any level. The loading mechanism ensures that each source code file
 * is only imported once, so the same source code library file may be imported into
 * several files within the same load.
 *
 * Since a single source code file can be imported by multiple other source code files, 
 * shader source code instances are cached, and are retrieved automatically from the cache
 * when another instance imports it. In this way, source code text does not need to be
 * duplicated in order to be imported into multiple, nested source code trees.
 */
@interface CC3ShaderSourceCode : CC3Identifiable {
	BOOL _wasLoadedFromFile : 1;
}

/** Returns the number of lines in this source code. */
@property(nonatomic, readonly) GLuint lineCount;

/** Returns the source code as a string. */
@property(nonatomic, readonly) NSString* sourceCodeString;

/** 
 * If the value of the wasLoadedFromFile property is NO, returns the value of the
 * sourceCodeString property. If the value of the wasLoadedFromFile property is YES,
 * returns an equivalent #import "filename" directive.
 */
@property(nonatomic, readonly) NSString* importableSourceCodeString;

/** Returns the number of source code strings that will be submitted to the shader compiler.  */
@property(nonatomic, readonly) GLuint sourceStringCount;

/** 
 * Appends the specified source code section to the source code managed by this instance.
 * Depending on how the source code is being parsed, the specfied string may contain any
 * amount of source code, but will typically contain a single line of code.
 * 
 * The mechansim for organizing the various source code sections submitted through this
 * method is defined by each subclass.
 */
-(void) appendSourceCodeString: (NSString*) srcCode;

/**
 * Returns the collection of source code subsections. 
 * 
 * Each member of the returned collection is an instance of CC3ShaderSourceCode.
 *
 * This property will return nil if the source code contains no subsections.
 */
@property(nonatomic, readonly) NSArray* subsections;

/**
 * Indicates whether this source code was loaded from a file.
 *
 * The value of this property is automatically set by the allocation and instantiation
 * methods that load this source code from a file.
 */
@property(nonatomic, assign) BOOL wasLoadedFromFile;


#pragma mark Visiting

/**
 * Uses the specified visitor to accumulate the collection of source code strings that will
 * be submitted to the shader compiler. Invokes the addSourceCompilationString: method on
 * the visitor for each source code string managed by this instance.
 *
 * The mechanism for managing the source code sections depends on the subclass.
 */
-(void) accumulateSourceCompilationStringsWithVisitor: (CC3ShaderSourceCodeCompilationStringVisitor*) visitor;

/**
 * Uses the specified visitor to accumulate the total number of source code strings that will be
 * submitted to the shader compiler. Invokes the addSourceCompilationStringCount: method on the 
 * visitor to provide the number of source code strings that are being managed by this instance.
 *
 * The mechanism for managing the source code sections depends on the subclass.
 */
-(void) accumulateSourceCompilationStringCountWithVisitor: (CC3ShaderSourceCodeCompilationStringCountVisitor*) visitor;

/**
 * This callback method is invoked during error handling, to determine the file and location
 * within that file at which the error occurred.
 *
 * If this instance contains the source of the error, the lineNumber and localizedSourceCode
 * properties of the visitor are set, and this method returns YES. Otherwise, this method
 * adjusts other properties within the visitor, to manage the traversal of the sourcde code,
 * and returns NO.
 */
-(BOOL) localizeLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor;


#pragma mark Allocation and initialization

/**
 * Returns an instance with the specified name and containing the specified GLSL source code.
 *
 * The specified shader source code may contain #import or #include directives to load additional
 * source code from other files. The #import and #include directives perform identically.
 * Regardless of which you choose to use, if the same file is imported or included more than once
 * (perhaps through nesting), the loader will ensure that only one copy of each source file is loaded.
 *
 * Source code instances created through this method are cached. If source code with the 
 * specified name is already in the cache, it is retrieved and returned. If the source code
 * is not in the cache, it is created from the specified source code, placed into the cache,
 * and returned. It is therefore safe to invoke this method any time the source code is needed,
 * without having to worry that the shader will be repeatedly loaded.
 *
 * To clear a source code instance from the cache, use the removeShaderSourceCode: method.
 *
 * CC3ShaderSourceCode is the abstract head of a class cluster. The class of the object returned
 * will be a subclass of CC3ShaderSourceCode, depending on the structure of the source code.
 */
+(id) shaderSourceCodeWithName: (NSString*) name fromSourceCodeString: (NSString*) srcCodeString;

/**
 * Returns an instance containing GLSL source code loaded from the file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * The specified shader source code may contain #import or #include directives to load additional
 * source code from other files. The #import and #include directives perform identically.
 * Regardless of which you choose to use, if the same file is imported or included more than once
 * (perhaps through nesting), the loader will ensure that only one copy of each source file is loaded.
 *
 * Source code loaded through this method is cached. If the source code was already loaded 
 * and is in the cache, it is retrieved and returned. If the source code is not in the cache,
 * it is loaded from the specified file, placed into the cache, and returned. It is therefore
 * safe to invoke this method any time the source code is needed, without having to worry that
 * it will be repeatedly loaded from file.
 *
 * To clear a source code instance from the cache, use the removeShaderSourceCode: method.
 *
 * CC3ShaderSourceCode is the abstract head of a class cluster. The class of the object returned
 * will be a subclass of CC3ShaderSourceCode, depending on the structure of the source code.
 */
+(id) shaderSourceCodeFromFile: (NSString*) aFilePath;

/**
 * Returns a shader source code name derived from the specified file path.
 *
 * This method is used to standardize the naming of shader source code instances, to ease 
 * in adding and retrieving shader source code to and from the cache, and is used to create
 * the name for each shader source code instance that is loaded from a file.
 *
 * This implementation returns the lastComponent of the specified file path.
 */
+(NSString*) shaderSourceCodeNameFromFilePath: (NSString*) aFilePath;

/**
 * As shader source code is parsed and assembled using #import and #include directives,
 * sections of code that do not require importing other code, are wrapped in an instance
 * of a CC3ShaderSourceCode subclass. This class-side property indicates the class to
 * instantiate for each section of GLSL code.
 *
 * This propery must be set to a CC3ShaderSourceCode subclass.
 *
 * The initial value of this property is the CC3ShaderSourceCodeString class.
 */
+(Class) sourceCodeSubsectionClass;

/**
 * As shader source code is parsed and assembled using #import and #include directives,
 * sections of code that do not require importing other code, are wrapped in an instance
 * of a CC3ShaderSourceCode subclass. This class-side property indicates the class to
 * instantiate for each section of GLSL code.
 *
 * This propery must be set to a CC3ShaderSourceCode subclass.
 *
 * The initial value of this property is the CC3ShaderSourceCodeString class.
 */
+(void) setSourceCodeSubsectionClass: (Class) sourceCodeSubsectionClass;

/**
 * Returns a description formatted as a source-code line for loading this shader from a source code file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code, if you want to load shader sources individually. However, normally,
 * your shader sources will be loaded, compiled, and cached as a result of creating a shader program.
 */
-(NSString*) constructorDescription;


#pragma mark Shader source cache

/** Removes this shader source instance from the cache. */
-(void) remove;

/**
 * Adds the specified shader source to the collection of loaded shader sources.
 *
 * Shader sources are accessible via their names through the getShaderSourceNamed: method,
 * and each shader source name should be unique. If a shader source with the same name as
 * the specified shader already exists in this cache, an assertion error is raised.
 *
 * Depending on the value of the isPreloading property, the shader source may be held within this
 * cache as a weak reference. As a result, the specified shader source may automatically be deallocated
 * and removed from this cache once all external strong references to it have been released.
 */
+(void) addShaderSourceCode: (CC3ShaderSourceCode*) shader;

/**
 * Returns the shader source with the specified name, or nil if a shader source with that
 * name has not been added.
 */
+(CC3ShaderSourceCode*) getShaderSourceCodeNamed: (NSString*) name;

/**
 * Removes the specified shader source from the shader cache. If the shader source is not 
 * strongly referenced elsewhere, it will be deallocated, and will be removed from the GL engine.
 *
 * Removing a shader from the GL engine does not affect the operation of shaders that have
 * been linked into a CC3ShaderProgram. It is common to remove shaders after you have created
 * all of the CC3ShaderPrograms that will use that shader.
 */
+(void) removeShaderSourceCode: (CC3ShaderSourceCode*) shader;

/**
 * Removes the shader source with the specified name from the shader source cache. If the shader is
 * not strongly referenced elsewhere, it will be deallocated, and will be removed from the GL engine.
 *
 * Removing a shader from the GL engine does not affect the operation of that shader if
 * it has been linked into a CC3ShaderProgram. It is common to remove shaders after you have
 * created all of the CC3ShaderPrograms that will use that shader.
 */
+(void) removeShaderSourceCodeNamed: (NSString*) name;

/**
 * Removes from the cache all shader sources that are instances of any subclass of the receiver.
 *
 * Removing cached shader sources does not affect the operation of shaders that have been
 * compiled into a CC3Shader. It is common to invoke this method after you have compiled all
 * of your CC3Shaders that use the currently loaded shader sources.
 *
 * You can use this method to selectively remove specific types of shaders, based on the shader
 * class, by invoking this method on that class. If you invoke this method on the CC3ShaderSourceCode
 * class, this cache will be compltely cleared. However, if you invoke this method on one of its
 * subclasses, only those shaders that are instances of that subclass (or one of its subclasses
 * in turn) will be removed, leaving the remaining shaders in the cache.
 */
+(void) removeAllShaderSourceCode;

/**
 * Returns whether shader sources are being pre-loaded.
 *
 * See the setIsPreloading setter method for a description of how and when to use this property.
 */
+(BOOL) isPreloading;

/**
 * Sets whether shader sources are being pre-loaded.
 *
 * Shader sources that are added to this cache while the value of this property is YES will
 * be strongly cached and cannot be deallocated until specifically removed from this cache.
 * You must manually remove any shader sources added to this cache while the value of this
 * property is YES.
 *
 * Shader sources that are added to this cache while the value of this property is NO will
 * be weakly cached, and will automatically be deallocated and removed from this cache once
 * all references to the shader program outside this cache are released.
 *
 * You can set the value of this property at any time, and can vary it between YES and NO
 * to accomodate your specific loading patterns.
 *
 * The initial value of this property is NO, meaning that shader sources will be weakly cached
 * in this cache, and will automatically be removed if not compiled into a shader. You can set
 * this property to YES in order to pre-load shader sources that will not be immediately used
 * in the scene, but which you wish to keep in the cache for later use.
 */
+(void) setIsPreloading: (BOOL) isPreloading;

/**
 * Returns a description of the source code in this cache that was loaded from files,
 * with each entry formatted as a source-code line for loading the file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code, if you want to load shader source code individually. However, 
 * normally, your source code will be loaded and cached as a result of creating a shader program.
 */
+(NSString*) loadedShaderSourceCodeDescription;

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeString

/**
 * A member of the CC3ShaderSourceCode class cluster that contains a single string of source code.
 * The contained source code may have come from a single source code string (or file) that contained
 * no #import or #include statements, or it may represent a segment of a source code string or file
 * before, between, or after an #import or #include directive.
 */
@interface CC3ShaderSourceCodeString : CC3ShaderSourceCode {
	NSMutableString* _sourceCodeString;
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeLines

/**
 * A member of the CC3ShaderSourceCode class cluster that contains source code as a collection of
 * individual source code lines. The contained source code may have come from a single source code
 * string (or file) that contained no #import or #include statements, or it may represent a segment
 * of a source code string or file before, between, or after an #import or #include directive.
 */
@interface CC3ShaderSourceCodeLines : CC3ShaderSourceCode {
	NSMutableArray* _sourceCodeLines;
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeGroup

/**
 * A member of the CC3ShaderSourceCode class cluster that contains instances of CC3ShaderSource
 * class-cluster subclasses, assembled into a source code tree. When source code is organized
 * into files that contain references to other files using #import or #include statements, an
 * instance of this class will contain instances of CC3ShaderSource class-cluster subclasses
 * that each contain the source code for a segment of a file before, between, or after #import
 * or #include statements, and other instances of CC3ShaderSource class-cluster subclasses that
 * contain the source code of the imported files, all assembled into a nested structure.
 *
 * Typically, within the nested structure of CC3ShaderSource subclass instances, an instance
 * of this class represents a single source code file, either stand-alone, or imported by
 * another file.
 */
@interface CC3ShaderSourceCodeGroup : CC3ShaderSourceCode {
	NSMutableArray* _subsections;
}

/** 
 * Adds the specified subsection of source code to the source code tree. Depending on the
 * class of the specified source code, it may contain a section of code before, between,
 * or after an #import directive, or it may contain the source code from the file identified
 * by an #import or #include directive.
 */
-(void) addSubsection: (CC3ShaderSourceCode*) shSrcCode;

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeVisitor

/**
 * This is an abstract parent of a class hierarchy that is used to visit a source code
 * tree, in order to retrieve information about the source code tree.
 *
 * A new instance should be created for each visitation run, in order to ensure the 
 * visitor state is initialized correctly at the beginning of each visitation run.
 */
@interface CC3ShaderSourceCodeVisitor : NSObject {
	NSMutableSet* _sourceCodeNamesTraversed;
}

/**
 * Tests whether the specified CC3ShaderSourceCode class-cluster instance has already been
 * traversed by this visitor, and remembers and returns the result.
 */
-(BOOL) hasAlreadyVisited: (CC3ShaderSourceCode*) srcCode;


#pragma mark Allocation and initialization

/** Allocates and initializes an instance. */
+(id) visitor;

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeCompilationStringCountVisitor

/** 
 * Visits an assembly of nested CC3ShaderSourceCode instances to determine the number
 * of source code strings that will be submitted to the compiler, in order to compile 
 * the source code contained within the assembly of CC3ShaderSourceCode instances.
 */
@interface CC3ShaderSourceCodeCompilationStringCountVisitor : CC3ShaderSourceCodeVisitor {
	GLuint _sourceCompilationStringCount;
}

/** Returns the total number of source code strings that will be submitted to the compiler. */
@property(nonatomic, readonly) GLuint sourceCompilationStringCount;

/**
 * Invoked by each CC3ShaderSourceCode instances that contains source code, to indicate the
 * number source code strings are contained within that instance. This visitor accumulates
 * the total of all values submitted by invocations of this method, and makes that total
 * accessible via the sourceCompilationStringCount property.
 */
-(void) addSourceCompilationStringCount: (GLuint) sourceStringCount;

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeCompilationStringVisitor

/**
 * Visits an assembly of nested CC3ShaderSourceCode instances to populate an array of source
 * code strings to be submitted to the compiler, in order to compile the source code contained
 * within the assembly of CC3ShaderSourceCode instances.
 *
 * The source code strings are accumulated in the sourceCompilationStrings array property, and
 * the number of strings added to that array is contained within the sourceCompilationStringCount 
 * superclass property.
 */
@interface CC3ShaderSourceCodeCompilationStringVisitor : CC3ShaderSourceCodeCompilationStringCountVisitor {
	const GLchar** _sourceCompilationStrings;
}

/** Returns the pointer to the array of source code strings that is populated by this visitor. */
@property(nonatomic, readonly) const GLchar** sourceCompilationStrings;

/**
 * Adds the specified source code string to the array in the sourceCompilationStrings property,
 * and increments the value of the sourceCompilationStringCount property.
 */
-(void) addSourceCompilationString: (const GLchar*) sourceCompilationString;


#pragma mark Allocation and initialization

/** Initializes this instance to populate the specified compilation strings. */
-(id) initWithCompilationStrings: (const GLchar**) sourceCompilationStrings;

/** Allocates and initializes an instance that populates the specified compilation strings. */
+(id) visitorWithCompilationStrings: (const GLchar**) sourceCompilationStrings;

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeLineNumberLocalizingVisitor

/**
 * Visits an assembly of nested CC3ShaderSourceCode instances to determine in which source
 * code group a particular global line number exists.
 *
 * The GLSL compiler treats the GLSL source code as a monolithic block, and errors are
 * attributed to source code lines as if all of the submitted source code came from a single
 * string or file.
 *
 * When a GLSL compiler error is reported, this visitor can be used to map the global line
 * number, reported by the compiler, to a local line number within a particular source
 * code segment, taking into consideration any import nesting that has occurred during
 * soruce code loading.
 *
 * To keep track of line numbers within nested import/includes, this instance maintains a
 * stack of line number offsets as it traverses the source code tree.
 */
@interface CC3ShaderSourceCodeLineNumberLocalizingVisitor : CC3ShaderSourceCodeVisitor {
	CC3ShaderSourceCode* _localizedSourceCode;
	NSMutableArray* _lineNumberOffsets;
	GLuint _lineNumber;
}

/** 
 * The source code group that contains the line of code reported as bad by the compiler.
 *
 * The value of this property will be nil until the visitation run has finished, after which
 * it will contain the source code group that contains the error.
 */
@property(nonatomic, retain) CC3ShaderSourceCode* localizedSourceCode;

/**
 * The line number of the source code line that originated the error.
 *
 * During instantiation, this line number is initialized to the global line number reported
 * by the compiler. After the source code tree has been visited by this visitor, this property
 * will contain the local line number, within the source code segment indicated by the
 * localizedSourceCode property, at which the reported error occurred.
 */
@property(nonatomic, assign) GLuint lineNumber;

/**
 * The line number offset of the beginning of the source code that originated the error.
 *
 * While traversing the source code stucture, this property is set to zero at the start of
 * each shader source group. As each subsection of source bytes is traversed, this value is
 * incremented by the line count. 
 *
 * When the subsection that contains the error is found, this offset value is added to the
 * lineNumber to determine the actual line number in the original file.
 */
@property(nonatomic, readonly) GLuint lineNumberOffset;

/** 
 * Pushes the specified line number offset to the stack of offsets.
 *
 * This method is invoked at the start of each source code group, to reset the line number
 * offset back to zero.
 */
-(void) pushLineNumberOffset: (GLuint) lineNumberOffset;

/**
 * Adds the specified offset to the current line number offset at the top of the line number
 * offsets stack.
 *
 * This method is invoked for each section of source code that is traversed prior to the
 * source code section that contains the error.
 */
-(void) addLineNumberOffset: (GLuint) offset;

/**
 * Pops the current line number offset from the stack of offsets.
 *
 * This method is invoked at the end of each source code group, as the visitor transfers
 * up one level in the source code tree.
 */
-(void) popLineNumberOffset;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with the specified global line number, which is the line
 * number reported by the compiler when a compilation error occurs.
 */
-(id) initWithLineNumber: (GLuint) lineNumber;

/**
 * Allocates and initializes an instance with the specified global line number, which is
 * the line number reported by the compiler when a compilation error occurs.
 */
+(id) visitorWithLineNumber: (GLuint) lineNumber;

@end


#pragma mark -
#pragma mark CC3ShaderPrewarmer

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
@interface CC3ShaderPrewarmer : CC3Identifiable {
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
