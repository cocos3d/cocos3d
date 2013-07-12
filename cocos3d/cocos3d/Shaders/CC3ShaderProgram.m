/*
 * CC3ShaderProgram.m
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
 * See header file CC3ShaderProgram.h for full API documentation.
 */

#import "CC3ShaderProgram.h"
#import "CC3ShaderProgramContext.h"
#import "CC3ShaderProgramMatcher.h"
#import "CC3NodeVisitor.h"
#import "CC3Material.h"


#pragma mark -
#pragma mark CC3Shader

@implementation CC3Shader

@synthesize shaderPreamble=_shaderPreamble;

-(void) dealloc {
	[self remove];		// remove this instance from the cache
	[self deleteGLShader];
	[_shaderPreamble release];
	[super dealloc];
}

-(GLuint) shaderID {
	if ( !_shaderID ) _shaderID = [CC3OpenGL.sharedGL generateShader: self.shaderType];
	return _shaderID;
}

-(void) deleteGLShader {
	[CC3OpenGL.sharedGL deleteShader: _shaderID];
	_shaderID = 0;
}

-(GLenum) shaderType {
	CC3AssertUnimplemented(@"shaderType");
	return GL_ZERO;
}


#pragma mark Compiling

-(void) compileFromSource: (NSString*) glslSource {
	CC3Assert(glslSource, @"%@ cannot complile NULL GLSL source.", self);
	
	MarkRezActivityStart();
	
	// Construct an array of source strings from the preamble and specified GLSL and compile
	NSString* preambleSrc = _shaderPreamble ? _shaderPreamble : @"";
	NSMutableArray* sources = [NSMutableArray new];
	[sources addObject: preambleSrc];
	[sources addObject: glslSource];
	[CC3OpenGL.sharedGL compileShader: self.shaderID fromSourceCodeStrings: sources];
	[sources release];

	CC3Assert([CC3OpenGL.sharedGL getShaderWasCompiled: self.shaderID],
			  @"%@ failed to compile because:\n%@", self,
			  [CC3OpenGL.sharedGL getLogForShader: self.shaderID]);
	LogRez(@"Compiled %@ in %.4f seconds", self, GetRezActivityDuration());
}

-(NSString*) platformPreamble { return CC3OpenGL.sharedGL.defaultShaderPreamble; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	CC3Assert(aName, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.shaderPreamble = self.platformPreamble;
	}
	return self;
}

-(id) initWithName: (NSString*) name fromSourceCode: (NSString*) glslSource {
	if ( (self = [self initWithName: name]) ) {
		[self compileFromSource: glslSource];
	}
	return self;
}

-(id) initFromSourceCodeFile: (NSString*) aFilePath {
	return [self initWithName: [self.class shaderNameFromFilePath: aFilePath]
			   fromSourceCode: [self glslSourceFromFile: aFilePath]];
}

+(id) shaderFromSourceCodeFile: (NSString*) aFilePath {
	id shader = [self getShaderNamed: [self shaderNameFromFilePath: aFilePath]];
	if (shader) return shader;
	
	shader = [[self alloc] initFromSourceCodeFile: aFilePath];
	[self addShader: shader];
	return [shader autorelease];
}

-(NSString*) glslSourceFromFile: (NSString*) aFilePath {
	MarkRezActivityStart();
	NSError* err = nil;
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
	CC3Assert([[NSFileManager defaultManager] fileExistsAtPath: absFilePath],
			  @"Could not load GLSL file '%@' because it could not be found", absFilePath);
	NSString* glslSrcStr = [NSString stringWithContentsOfFile: absFilePath encoding: NSUTF8StringEncoding error: &err];
	CC3Assert(!err, @"Could not load GLSL file '%@' because %@, (code %li), failure reason %@",
			  absFilePath, err.localizedDescription, (long)err.code, err.localizedFailureReason);
	LogRez(@"Loaded GLSL source from file %@ in %.4f seconds", aFilePath, GetRezActivityDuration());
	return glslSrcStr;
}

+(NSString*) shaderNameFromFilePath: (NSString*) aFilePath { return aFilePath.lastPathComponent; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (ID: %u)", [super description], _shaderID];
}


#pragma mark Tag allocation

static GLuint _lastAssignedShaderTag = 0;

-(GLuint) nextTag { return ++_lastAssignedShaderTag; }

+(void) resetTagAllocation { _lastAssignedShaderTag = 0; }


#pragma mark Shader cache

static NSMutableDictionary* _shadersByName = nil;

+(void) addShader: (CC3Shader*) shader {
	if ( !shader ) return;
	CC3Assert(shader.name, @"%@ cannot be added to the shader cache because its name property is nil.", shader);
	CC3Assert( ![self getShaderNamed: shader.name], @"%@ already contains a shader named %@. Remove it first before adding another.", self, shader.name);
	if ( !_shadersByName ) _shadersByName = [NSMutableDictionary new];		// retained
	[_shadersByName setObject: [CC3WeakCacheWrapper wrapperWith: shader] forKey: shader.name];
}

+(id<CC3Cacheable>) cacheEntryAt: (NSString*) name { return [_shadersByName objectForKey: name]; }

+(CC3Shader*) getShaderNamed: (NSString*) name { return [self cacheEntryAt: name].cachedObject; }

+(void) removeShader: (CC3Shader*) shader { [self removeShaderNamed: shader.name]; }

+(void) removeShaderNamed: (NSString*) name {
	LogRez(@"Removing shader named %@ from cache.", name);
	[_shadersByName removeObjectForKey: name];
}

+(void) removeAllShaders { [_shadersByName removeAllObjects]; }

-(void) remove { [self.class removeShader: self]; }

@end


#pragma mark CC3VertexShader

@implementation CC3VertexShader

-(GLenum) shaderType { return GL_VERTEX_SHADER; }

@end


#pragma mark CC3FragmentShader

@implementation CC3FragmentShader

-(GLenum) shaderType { return GL_FRAGMENT_SHADER; }

@end


#pragma mark -
#pragma mark CC3ShaderProgram

@implementation CC3ShaderProgram

@synthesize semanticDelegate=_semanticDelegate;
@synthesize maxUniformNameLength=_maxUniformNameLength;
@synthesize maxAttributeNameLength=_maxAttributeNameLength;

-(void) dealloc {
	[self remove];					// remove this instance from the cache
	self.vertexShader = nil;		// use setter to detach shader from program
	self.fragmentShader = nil;		// use setter to detach shader from program
	[self deleteGLProgram];
	[_uniformsSceneScope release];
	[_uniformsNodeScope release];
	[_uniformsDrawScope release];
	[_attributes release];
	[super dealloc];
}

-(GLuint) programID {
	if ( !_programID ) _programID = [CC3OpenGL.sharedGL generateShaderProgram];
	return _programID;
}

-(void) deleteGLProgram {
	[CC3OpenGL.sharedGL deleteShaderProgram: _programID];
	_programID = 0;
}

-(CC3VertexShader*) vertexShader { return _vertexShader; }

-(void) setVertexShader: (CC3VertexShader*) vertexShader {
	if (vertexShader == _vertexShader) return;
	
	[self detachShader: _vertexShader];
	[_vertexShader release];
	_vertexShader = [vertexShader retain];
	[self attachShader: _vertexShader];
}

-(CC3FragmentShader*) fragmentShader { return _fragmentShader; }

-(void) setFragmentShader: (CC3FragmentShader*) fragmentShader {
	if (fragmentShader == _fragmentShader) return;
	
	[self detachShader: _fragmentShader];
	[_fragmentShader release];
	_fragmentShader = [fragmentShader retain];
	[self attachShader: _fragmentShader];
}

-(void) attachShader: (CC3Shader*) shader {
	[CC3OpenGL.sharedGL attachShader: shader.shaderID toShaderProgram: self.programID];
}

-(void) detachShader: (CC3Shader*) shader {
	[CC3OpenGL.sharedGL detachShader: shader.shaderID fromShaderProgram: self.programID];
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


#pragma mark Linking

-(void) link {
	CC3Assert(_vertexShader && _fragmentShader, @"%@ requires both vertex and fragment shaders to be assigned before linking.", self);
	CC3Assert(_semanticDelegate, @"%@ requires the semanticDelegate property be set before linking.", self);
	
	MarkRezActivityStart();

	[CC3OpenGL.sharedGL linkShaderProgram: self.programID];

	CC3Assert([CC3OpenGL.sharedGL getShaderProgramWasLinked: self.programID],
			  @"%@ could not be linked because:\n%@", self,
			  [CC3OpenGL.sharedGL getLogForShaderProgram: self.programID]);
	LogRez(@"Linked %@ in %.4f seconds", self, GetRezActivityDuration());	// Timing before config vars
	
	[self configureUniforms];
	[self configureAttributes];
	
	LogRez(@"Completed %@", self.fullDescription);
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
	
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint progID = self.programID;
	GLint varCnt = [gl getIntegerParameter: GL_ACTIVE_UNIFORMS forShaderProgram: progID];
	_maxUniformNameLength = [gl getIntegerParameter: GL_ACTIVE_UNIFORM_MAX_LENGTH forShaderProgram: progID];
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
	
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint progID = self.programID;
	GLint varCnt = [gl getIntegerParameter: GL_ACTIVE_ATTRIBUTES forShaderProgram: progID];
	_maxAttributeNameLength = [gl getIntegerParameter: GL_ACTIVE_ATTRIBUTE_MAX_LENGTH forShaderProgram: progID];
	for (GLint varIdx = 0; varIdx < varCnt; varIdx++) {
		CC3GLSLAttribute* var = [CC3GLSLAttribute variableInProgram: self atIndex: varIdx];
		[_semanticDelegate configureVariable: var];
		[_attributes addObject: var];
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program attributes for this platform has not been exceeded.", var.fullDescription);
	}
	LogRez(@"%@ configured %u attributes in %.4f seconds", self, varCnt, GetRezActivityDuration());
}


#pragma mark Binding

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@ with %@", visitor.currentMeshNode, self);
	CC3OpenGL* gl = visitor.gl;
	
	visitor.currentShaderProgram = self;

	[gl useShaderProgram: self.programID];
	
	[gl clearUnboundVertexAttributes];
	[self populateVertexAttributesWithVisitor: visitor];
	[gl enableBoundVertexAttributes];
	
	[self populateNodeScopeUniformsWithVisitor: visitor];
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
	CC3ShaderProgramContext* progCtx = visitor.currentMaterial.shaderContext;
	for (CC3GLSLUniform* var in uniforms)
		if ([progCtx populateUniform: var withVisitor: visitor] ||
			[_semanticDelegate populateUniform: var withVisitor: visitor]) {
			[var updateGLValueWithVisitor: visitor];
		} else
			CC3Assert(NO, @"%@ could not resolve the value of uniform %@ with semantic %@."
					  " If this is a valid uniform, you should create a uniform override in the"
					  " program context in your material in order to set the value of the uniform directly.",
					  self, var.name, NSStringFromCC3Semantic(var.semantic));
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	CC3Assert(aName, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_uniformsSceneScope = [CCArray new];	// retained
		_uniformsNodeScope = [CCArray new];		// retained
		_uniformsDrawScope = [CCArray new];		// retained
		_attributes = [CCArray new];			// retained
		_vertexShader = nil;
		_fragmentShader = nil;
		_maxUniformNameLength = 0;
		_maxAttributeNameLength = 0;
		_isSceneScopeDirty = YES;	// start out dirty for auto-loaded programs
		_semanticDelegate = nil;
	}
	return self;
}

-(id) initWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
			  withVertexShader: (CC3VertexShader*) vertexShader
			withFragmentShader: (CC3FragmentShader*) fragmentShader {
	NSString* progName = [self.class programNameFromVertexShaderName: vertexShader.name
											   andFragmentShaderName: fragmentShader.name];
	if ( (self = [self initWithName: progName]) ) {
		self.semanticDelegate = semanticDelegate;
		self.vertexShader = vertexShader;
		self.fragmentShader = fragmentShader;
		[self link];
	}
	return self;
}

+(id) programWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
				 withVertexShader: (CC3VertexShader*) vertexShader
			   withFragmentShader: (CC3FragmentShader*) fragmentShader {
	NSString* progName = [self programNameFromVertexShaderName: vertexShader.name
										 andFragmentShaderName: fragmentShader.name];
	id program = [self getProgramNamed: progName];
	if (program) return program;
	
	program = [[self alloc] initWithSemanticDelegate: semanticDelegate
									withVertexShader: vertexShader
								  withFragmentShader: fragmentShader];
	[self addProgram: program];
	return [program autorelease];
}

-(id) initWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
		  fromVertexShaderFile: (NSString*) vshFilePath
		 andFragmentShaderFile: (NSString*) fshFilePath {
	return [self initWithSemanticDelegate: semanticDelegate
						 withVertexShader: [CC3VertexShader shaderFromSourceCodeFile: vshFilePath]
					   withFragmentShader: [CC3FragmentShader shaderFromSourceCodeFile: fshFilePath]];
}

+(id) programWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
			 fromVertexShaderFile: (NSString*) vshFilePath
			andFragmentShaderFile: (NSString*) fshFilePath {
	return [self programWithSemanticDelegate: semanticDelegate
							withVertexShader: [CC3VertexShader shaderFromSourceCodeFile: vshFilePath]
						  withFragmentShader: [CC3FragmentShader shaderFromSourceCodeFile: fshFilePath]];
}

+(NSString*) programNameFromVertexShaderName: (NSString*) vertexShaderName
					   andFragmentShaderName: (NSString*) fragmentShaderName {
	return [NSString stringWithFormat: @"%@-%@", vertexShaderName, fragmentShaderName];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ named: %@", [self class], self.name]; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@ with %@ and %@", self, _vertexShader, _fragmentShader];
	[desc appendFormat: @". declaring %lu attributes and %lu uniforms:",
	 (unsigned long)_attributes.count, (unsigned long)(_uniformsSceneScope.count + _uniformsNodeScope.count + _uniformsDrawScope.count)];
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

+(void) addProgram: (CC3ShaderProgram*) program {
	if ( !program ) return;
	CC3Assert(program.name, @"%@ cannot be added to the program cache because its name property is nil.", program);
	CC3Assert( ![self getProgramNamed: program.name], @"%@ already contains a program named %@. Remove it first before adding another.", self, program.name);
	if ( !_programsByName ) _programsByName = [NSMutableDictionary new];		// retained
	[_programsByName setObject: [CC3WeakCacheWrapper wrapperWith: program] forKey: program.name];
}

+(id<CC3Cacheable>) cacheEntryAt: (NSString*) name { return [_programsByName objectForKey: name]; }

+(CC3ShaderProgram*) getProgramNamed: (NSString*) name { return [self cacheEntryAt: name].cachedObject; }

+(void) removeProgram: (CC3ShaderProgram*) program { [self removeProgramNamed: program.name]; }

+(void) removeProgramNamed: (NSString*) name {
	LogRez(@"Removing shader program named %@ from cache.", name);
	[_programsByName removeObjectForKey: name];
}

+(void) removeAllPrograms { [_programsByName removeAllObjects]; }

-(void) remove { [self.class removeProgram: self]; }

+(void) willBeginDrawingScene {
	[_programsByName enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		[[obj cachedObject] willBeginDrawingScene];
	}];
}


#pragma mark Program matching

static id<CC3ShaderProgramMatcher> _programMatcher = nil;

+(id<CC3ShaderProgramMatcher>) programMatcher {
	if ( !_programMatcher ) _programMatcher = [CC3ShaderProgramMatcherBase new];	// retained
	return _programMatcher;
}

+(void) setProgramMatcher: (id<CC3ShaderProgramMatcher>) programMatcher {
	id old = _programMatcher;
	_programMatcher = [programMatcher retain];
	[old release];
}

@end

