/*
 * CC3GLProgram.m
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
 * 
 * See header file CC3GLProgram.h for full API documentation.
 */

#import "CC3GLProgram.h"
#import "CC3GLProgramContext.h"
#import "CC3GLProgramMatchers.h"
#import "CC3NodeVisitor.h"
#import "CC3Material.h"


#pragma mark -
#pragma mark CC3GLProgram

@implementation CC3GLProgram

@synthesize programID=_programID;
@synthesize semanticDelegate=_semanticDelegate;
@synthesize maxUniformNameLength=_maxUniformNameLength;
@synthesize maxAttributeNameLength=_maxAttributeNameLength;
@synthesize vertexShaderPreamble=_vertexShaderPreamble;
@synthesize fragmentShaderPreamble=_fragmentShaderPreamble;

-(void) dealloc {
	[self deleteGLProgram];
	[_uniformsSceneScope release];
	[_uniformsNodeScope release];
	[_uniformsDrawScope release];
	[_attributes release];
	[_vertexShaderPreamble release];
	[_fragmentShaderPreamble release];
	[super dealloc];
}


#pragma mark Variables

-(CC3GLSLUniform*) uniformNamed: (NSString*) varName {
	for (CC3GLSLUniform* var in _uniformsSceneScope) if ( [var.name isEqualToString: varName] ) return var;
	for (CC3GLSLUniform* var in _uniformsNodeScope) if ( [var.name isEqualToString: varName] ) return var;
	for (CC3GLSLUniform* var in _uniformsDrawScope) if ( [var.name isEqualToString: varName] ) return var;
	return nil;
}

-(CC3GLSLUniform*) uniformAtLocation: (GLint) uniformLocation {
	for (CC3GLSLUniform* var in _uniformsSceneScope) if (var.location == uniformLocation) return var;
	for (CC3GLSLUniform* var in _uniformsNodeScope) if (var.location == uniformLocation) return var;
	for (CC3GLSLUniform* var in _uniformsDrawScope) if (var.location == uniformLocation) return var;
	return nil;
}

-(CC3GLSLUniform*) uniformForSemantic: (GLenum) semantic {
	return [self uniformForSemantic: semantic at: 0];
}

-(CC3GLSLUniform*) uniformForSemantic: (GLenum) semantic at: (GLuint) semanticIndex {
	for (CC3GLSLUniform* var in _uniformsSceneScope)
		if (var.semantic == semantic && var.semanticIndex == semanticIndex) return var;
	for (CC3GLSLUniform* var in _uniformsNodeScope)
		if (var.semantic == semantic && var.semanticIndex == semanticIndex) return var;
	for (CC3GLSLUniform* var in _uniformsDrawScope)
		if (var.semantic == semantic && var.semanticIndex == semanticIndex) return var;
	return nil;
}

-(CC3GLSLAttribute*) attributeNamed: (NSString*) varName {
	for (CC3GLSLAttribute* var in _attributes) if ( [var.name isEqualToString: varName] ) return var;
	return nil;
}

-(CC3GLSLAttribute*) attributeAtLocation: (GLint) attrLocation {
	for (CC3GLSLAttribute* var in _attributes) if (var.location == attrLocation) return var;
	return nil;
}

-(CC3GLSLAttribute*) attributeForSemantic: (GLenum) semantic {
	return [self attributeForSemantic: semantic at: 0];
}

-(CC3GLSLAttribute*) attributeForSemantic: (GLenum) semantic at: (GLuint) semanticIndex {
	for (CC3GLSLAttribute* var in _attributes)
		if (var.semantic == semantic && var.semanticIndex == semanticIndex) return var;
	return nil;
}

-(void) markSceneScopeDirty { _isSceneScopeDirty = YES; }

-(void) willBeginDrawingScene { [self markSceneScopeDirty]; }


#pragma mark Compiling and linking

-(NSString*) platformPreamble { return CC3OpenGL.sharedGL.defaultShaderPreamble; }

-(GLchar*) glslSourceFromFile: (NSString*) glslFilename {
	MarkRezActivityStart();
	NSError* err = nil;
	NSString* filePath = CC3EnsureAbsoluteFilePath(glslFilename);
	CC3Assert([[NSFileManager defaultManager] fileExistsAtPath: filePath],
			  @"Could not load GLSL file '%@' because it could not be found", filePath);
	NSString* glslSrcStr = [NSString stringWithContentsOfFile: filePath encoding: NSUTF8StringEncoding error: &err];
	CC3Assert(!err, @"Could not load GLSL file '%@' because %@, (code %li), failure reason %@",
			  glslFilename, err.localizedDescription, (long)err.code, err.localizedFailureReason);
	LogRez(@"Loaded GLSL source from file %@ in %.4f seconds", glslFilename, GetRezActivityDuration());
	return (GLchar*)glslSrcStr.UTF8String;
}

#if CC3_GLSL

-(void) compileAndLinkVertexShaderBytes: (const GLchar*) vshBytes
				 andFragmentShaderBytes: (const GLchar*) fshBytes {
	CC3Assert( !_programID, @"%@ already compliled and linked.", self);

	_programID = glCreateProgram();
	LogGLErrorTrace(@"glCreateProgram() in %@", self);

	[self compileShader: GL_VERTEX_SHADER
			  fromBytes: vshBytes
			withPremble: self.vertexShaderPreamble.UTF8String];
	
	[self compileShader: GL_FRAGMENT_SHADER
			  fromBytes: fshBytes
			withPremble: self.fragmentShaderPreamble.UTF8String];
	
	[self link];
}

-(void) compileAndLinkVertexShaderFile: (NSString*) vshFilename
				 andFragmentShaderFile: (NSString*) fshFilename {
	[self compileAndLinkVertexShaderBytes: [self glslSourceFromFile: vshFilename]
				   andFragmentShaderBytes: [self glslSourceFromFile: fshFilename]];
}

/** 
 * Compiles the specified shader type from the specified GLSL source code plus the specified
 * source code preamble, and returns the ID of the GL shader object. Neither the source or
 * the preamble may be NULL.
 */
-(void) compileShader: (GLenum) shaderType
			fromBytes: (const GLchar*) source
		  withPremble: (const GLchar*) preambleSource {
	CC3Assert(source, @"%@ cannot complile NULL GLSL source.", self);
	CC3Assert(source, @"%@ cannot complile NULL GLSL source preamble.", self);

	MarkRezActivityStart();
	
    GLuint shaderID = glCreateShader(shaderType);
	LogGLErrorTrace(@"glCreateShader(%@) in %@", NSStringFromGLEnum(shaderType), self);

	const GLchar* sources[] = {preambleSource, source};
    glShaderSource(shaderID, 2, sources, NULL);
	LogGLErrorTrace(@"glShaderSource(%u, %u, %p, %p)", shaderID, 2, sources, NULL);
	
    glCompileShader(shaderID);
	LogGLErrorTrace(@"glCompileShader(%u)", shaderID);

	CC3Assert([self getWasCompiled: shaderID], @"%@ failed to compile shader %@ because:\n%@",
			  self, NSStringFromGLEnum(shaderType), [self getShaderLog: shaderID]);

	glAttachShader(_programID, shaderID);
	LogGLErrorTrace(@"glAttachShader(%u, %u)", _programID, shaderID);

    glDeleteShader(shaderID);
	LogGLErrorTrace(@"glDeleteShader(%u)", shaderID);
	
	LogRez(@"Compiled and attached %@ shader %@ in %.4f seconds", self, NSStringFromGLEnum(shaderType), GetRezActivityDuration());
}

/** Queries the GL engine and returns whether the shader with the specified GL ID was successfully compiled. */
-(BOOL) getWasCompiled: (GLuint) shaderID {
    GLint status;
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, &status);
	LogGLErrorTrace(@"glGetShaderiv(%u, %@, %i) in %@", shaderID, NSStringFromGLEnum(GL_COMPILE_STATUS), status, self);
	return (status > 0);
}

/** Links the compiled vertex and fragment shaders into the GL program. */
-(void) link {
	CC3Assert(_programID, @"%@ requires the shaders to be compiled before linking.", self);
	CC3Assert(_semanticDelegate, @"%@ requires the semanticDelegate property be set before linking.", self);

	MarkRezActivityStart();
	
    glLinkProgram(_programID);
	LogGLErrorTrace(@"glLinkProgram(%u) in %@", _programID, self);
	
	CC3Assert(self.getWasLinked, @"%@ could not be linked because:\n%@", self, self.getProgramLog);

	LogRez(@"Linked %@ in %.4f seconds", self, GetRezActivityDuration());	// Timing before config vars

	[self configureUniforms];
	[self configureAttributes];

	LogRez(@"Completed %@", self.fullDescription);
}

/** Queries the GL engine and returns whether the program was successfully linked. */
-(BOOL) getWasLinked {
    GLint status;
    glGetProgramiv(_programID, GL_LINK_STATUS, &status);
	LogGLErrorTrace(@"glGetProgramiv(%u, %@, %i) in %@", _programID, NSStringFromGLEnum(GL_LINK_STATUS), status, self);
	return (status > 0);
}

/** 
 * Extracts information about the program uniform variables from the GL engine
 * and creates a configuration instance for each.
 */
-(void) configureUniforms {
	MarkRezActivityStart();
	[_uniformsSceneScope removeAllObjects];
	[_uniformsNodeScope removeAllObjects];
	[_uniformsDrawScope removeAllObjects];
	
	GLint varCnt;
	glGetProgramiv(_programID, GL_ACTIVE_UNIFORMS, &varCnt);
	LogGLErrorTrace(@"glGetProgramiv(%u, %@, %i) in %@", _programID, NSStringFromGLEnum(GL_ACTIVE_UNIFORMS), varCnt, self);
	glGetProgramiv(_programID, GL_ACTIVE_UNIFORM_MAX_LENGTH, &_maxUniformNameLength);
	LogGLErrorTrace(@"glGetProgramiv(%u, %@, %i)", _programID, NSStringFromGLEnum(GL_ACTIVE_UNIFORM_MAX_LENGTH), _maxUniformNameLength);
	for (GLint varIdx = 0; varIdx < varCnt; varIdx++) {
		CC3GLSLUniform* var = [CC3GLSLUniform variableInProgram: self atIndex: varIdx];
		[_semanticDelegate configureVariable: var];
		[self addUniform: var];
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program uniforms for this platform has not been exceeded.", var.fullDescription);
	}
	LogRez(@"%@ configured %u uniforms in %.4f seconds", self, varCnt, GetRezActivityDuration());
}

/** Adds the specified uniform to the appropriate internal collection, based on variable scope. */
-(void) addUniform: (CC3GLSLUniform*) var {
	switch (var.scope) {
		case kCC3GLSLVariableScopeScene:
			[_uniformsSceneScope addObject: var];
			return;
		case kCC3GLSLVariableScopeDraw:
			[_uniformsDrawScope addObject: var];
			return;
		default:
			[_uniformsNodeScope addObject: var];
			return;
	}
}

/**
 * Extracts information about the program vertex attribute variables from the GL engine
 * and creates a configuration instance for each.
 */
-(void) configureAttributes {
	MarkRezActivityStart();
	[_attributes removeAllObjects];
	
	GLint varCnt;
	glGetProgramiv(_programID, GL_ACTIVE_ATTRIBUTES, &varCnt);
	LogGLErrorTrace(@"glGetProgramiv(%u, %@, %i) in %@", _programID, NSStringFromGLEnum(GL_ACTIVE_ATTRIBUTES), varCnt, self);
	glGetProgramiv(_programID, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &_maxAttributeNameLength);
	LogGLErrorTrace(@"glGetProgramiv(%u, %@, %i)", _programID, NSStringFromGLEnum(GL_ACTIVE_ATTRIBUTE_MAX_LENGTH), _maxAttributeNameLength);
	for (GLint varIdx = 0; varIdx < varCnt; varIdx++) {
		CC3GLSLAttribute* var = [CC3GLSLAttribute variableInProgram: self atIndex: varIdx];
		[_semanticDelegate configureVariable: var];
		[_attributes addObject: var];
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program attributes for this platform has not been exceeded.", var.fullDescription);
	}
	LogRez(@"%@ configured %u attributes in %.4f seconds", self, varCnt, GetRezActivityDuration());
}

// GL functions for retrieving log info
typedef void ( GLInfoFunction (GLuint program, GLenum pname, GLint* params) );
typedef void ( GLLogFunction (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog) );

/**
 * Returns a string retrieved from the specified object, using the specified functions
 * and length parameter name to retrieve the length and content.
 */
-(NSString*) getGLStringFor: (GLuint) glObjID
		usingLengthFunction: (GLInfoFunction*) lengthFunc
					  named: (NSString*) lenFuncName
		 andLengthParameter: (GLenum) lenParamName
		 andContentFunction: (GLLogFunction*) contentFunc
					  named: (NSString*) contentFuncName {
	GLint strLength = 0, charsRetrieved = 0;
	
	lengthFunc(glObjID, lenParamName, &strLength);
	LogGLErrorTrace(@"%@(%u, %@, %i)", lenFuncName, glObjID, NSStringFromGLEnum(lenParamName), strLength);
	if (strLength < 1) return nil;
	
	GLchar contentBytes[strLength];
	contentFunc(glObjID, strLength, &charsRetrieved, contentBytes);
	LogGLErrorTrace(@"%@(%u, %i, %i, \"%s\")", contentFuncName, glObjID, strLength, charsRetrieved, contentBytes);
	
	return [NSString stringWithUTF8String: contentBytes];
}

/** Returns the GL source for the specified shader. */
-(NSString*) getShaderSource: (GLuint) shaderID {
	return [self getGLStringFor: shaderID
			usingLengthFunction: glGetShaderiv named: @"glGetShaderiv"
			 andLengthParameter: GL_SHADER_SOURCE_LENGTH
			 andContentFunction: glGetShaderSource named: @"glGetShaderSource"];
}

/** Returns the GL log for the specified shader. */
-(NSString*) getShaderLog: (GLuint) shaderID {
	return [self getGLStringFor: shaderID
			usingLengthFunction: glGetShaderiv named: @"glGetShaderiv"
			 andLengthParameter: GL_INFO_LOG_LENGTH
			 andContentFunction: glGetShaderInfoLog named: @"glGetShaderInfoLog"];
}

/** Returns the GL status log for the GL program. */
-(NSString*) getProgramLog {
	return [self getGLStringFor: _programID
			usingLengthFunction: glGetProgramiv named: @"glGetProgramiv"
			 andLengthParameter: GL_INFO_LOG_LENGTH
			 andContentFunction: glGetProgramInfoLog named: @"glGetProgramInfoLog"];
}


#pragma mark Binding

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Binding program %@ for %@", self, visitor.currentNode);
	visitor.currentShaderProgram = self;
	ccGLUseProgram(_programID);
}

-(void) populateVertexAttributesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	for (CC3GLSLAttribute* var in _attributes)
		[gl bindVertexAttribute: var withVisitor: visitor];
}

-(void) populateSceneScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (_isSceneScopeDirty) {
		LogTrace(@"%@ populating scene scope", self);
		[self populateUniforms: _uniformsSceneScope withVisitor: visitor];
		_isSceneScopeDirty = NO;
	}
}

-(void) populateNodeScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[self populateSceneScopeUniformsWithVisitor: visitor];
	LogTrace(@"%@ populating node scope", self);
	[self populateUniforms: _uniformsNodeScope withVisitor: visitor];
}

-(void) populateDrawScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ populating draw scope", self);
	[self populateUniforms: _uniformsDrawScope withVisitor: visitor];
}

-(void) populateUniforms: (CCArray*) uniforms withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3GLProgramContext* progCtx = visitor.currentMaterial.shaderContext;
	for (CC3GLSLUniform* var in uniforms)
		if ([progCtx populateUniform: var withVisitor: visitor] ||
			[_semanticDelegate populateUniform: var withVisitor: visitor]) {
			[var updateGLValue];
		} else {
			CC3Assert(NO, @"%@ could not resolve the value of uniform %@ with semantic %@."
					  " If this is a valid uniform, you should create a uniform override in the"
					  " program context in your material in order to set the value of the uniform directly.",
					  self, var.name, NSStringFromCC3Semantic(var.semantic));
		}
}

-(void) deleteGLProgram { if (_programID) ccGLDeleteProgram(_programID); }

#else		// !CC3_GLSL
-(void) compileAndLinkVertexShaderBytes: (const GLchar*) vshBytes andFragmentShaderBytes: (const GLchar*) fshBytes {}
-(void) compileAndLinkVertexShaderFile: (NSString*) vshFilename andFragmentShaderFile: (NSString*) fshFilename {}
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {}
-(void) deleteGLProgram {}
-(void) populateVertexAttributesWithVisitor: (CC3NodeDrawingVisitor*) visitor {}
-(void) populateSceneScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor {}
-(void) populateNodeScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor {}
-(void) populateDrawScopeUniformsWithVisitor: (CC3NodeDrawingVisitor*) visitor {}
#endif		// CC3_GLSL


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	CC3Assert(aName, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_uniformsSceneScope = [CCArray new];	// retained
		_uniformsNodeScope = [CCArray new];		// retained
		_uniformsDrawScope = [CCArray new];		// retained
		_attributes = [CCArray new];			// retained
		self.vertexShaderPreamble = self.platformPreamble;
		self.fragmentShaderPreamble = self.platformPreamble;
		_maxUniformNameLength = 0;
		_maxAttributeNameLength = 0;
		_isSceneScopeDirty = YES;	// start out dirty for auto-loaded programs
		_semanticDelegate = nil;
	}
	return self;
}

-(id) initWithName: (NSString*) name
andSemanticDelegate: (id<CC3GLProgramSemanticsDelegate>) semanticDelegate
fromVertexShaderBytes: (const GLchar*) vshBytes
andFragmentShaderBytes: (const GLchar*) fshBytes {
	if ( (self = [super initWithName: name]) ) {
		self.semanticDelegate = semanticDelegate;
		[self compileAndLinkVertexShaderBytes: vshBytes andFragmentShaderBytes: fshBytes];
	}
	return self;
}

-(id) initWithName: (NSString*) name
andSemanticDelegate: (id<CC3GLProgramSemanticsDelegate>) semanticDelegate
fromVertexShaderFile: (NSString*) vshFilename
andFragmentShaderFile: (NSString*) fshFilename {
	LogRez(@"");
	LogRez(@"--------------------------------------------------");
	LogRez(@"Loading GLSL program named %@ from vertex shader file '%@' and fragment shader file '%@'", name, vshFilename, fshFilename);

	return [self initWithName: name
		  andSemanticDelegate: semanticDelegate
		fromVertexShaderBytes: [self glslSourceFromFile: vshFilename]
	   andFragmentShaderBytes: [self glslSourceFromFile: fshFilename]];
}

+(NSString*) programNameFromVertexShaderFile: (NSString*) vshFilename
					   andFragmentShaderFile: (NSString*) fshFilename {
	return [NSString stringWithFormat: @"%@-%@", vshFilename, fshFilename];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ named: %@", [self class], self.name]; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@ declaring %lu attributes and %lu uniforms:",
	 self.description, (unsigned long)_attributes.count, (unsigned long)(_uniformsSceneScope.count + _uniformsNodeScope.count + _uniformsDrawScope.count)];
	for (CC3GLSLVariable* var in _attributes) [desc appendFormat: @"\n\t %@", var.fullDescription];
	for (CC3GLSLVariable* var in _uniformsSceneScope) [desc appendFormat: @"\n\t %@", var.fullDescription];
	for (CC3GLSLVariable* var in _uniformsNodeScope) [desc appendFormat: @"\n\t %@", var.fullDescription];
	for (CC3GLSLVariable* var in _uniformsDrawScope) [desc appendFormat: @"\n\t %@", var.fullDescription];
	return desc;
}


#pragma mark Tag allocation

static GLuint _lastAssignedProgramTag = 0;

-(GLuint) nextTag { return ++_lastAssignedProgramTag; }

+(void) resetTagAllocation { _lastAssignedProgramTag = 0; }


#pragma mark Program cache

static NSMutableDictionary* _programsByName = nil;

+(void) addProgram: (CC3GLProgram*) program {
	if ( !program ) return;
	CC3Assert( ![self getProgramNamed: program.name], @"%@ already contains a program named %@. Remove it first before adding another.", self, program.name);
	if ( !_programsByName ) _programsByName = [NSMutableDictionary new];		// retained
	[_programsByName setObject: program forKey: program.name];
}

+(CC3GLProgram*) getProgramNamed: (NSString*) name { return [_programsByName objectForKey: name]; }

+(void) removeProgram: (CC3GLProgram*) program { [self removeProgramNamed: program.name]; }

+(void) removeProgramNamed: (NSString*) name { [_programsByName removeObjectForKey: name]; }

+(void) willBeginDrawingScene {
	[_programsByName enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		[obj willBeginDrawingScene];
	}];
}


#pragma mark Program matching

static id<CC3GLProgramMatcher> _programMatcher = nil;

+(id<CC3GLProgramMatcher>) programMatcher {
	if ( !_programMatcher ) _programMatcher = [CC3GLProgramMatcherBase new];	// retained
	return _programMatcher;
}

+(void) setProgramMatcher: (id<CC3GLProgramMatcher>) programMatcher {
	id old = _programMatcher;
	_programMatcher = [programMatcher retain];
	[old release];
}

@end

