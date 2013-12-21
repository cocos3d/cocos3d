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
#import "CC3RenderSurfaces.h"
#import "CC3ParametricMeshNodes.h"


#pragma mark -
#pragma mark CC3ShaderProgram

@implementation CC3ShaderProgram

@synthesize attributes=_attributes;
@synthesize semanticDelegate=_semanticDelegate;
@synthesize maxUniformNameLength=_maxUniformNameLength;
@synthesize maxAttributeNameLength=_maxAttributeNameLength;

-(void) dealloc {
	[self remove];					// remove this instance from the cache
	self.vertexShader = nil;		// use setter to detach shader from program
	self.fragmentShader = nil;		// use setter to detach shader from program
	[self deleteGLProgram];
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
	_vertexShader = vertexShader;
	[self attachShader: _vertexShader];
}

-(CC3FragmentShader*) fragmentShader { return _fragmentShader; }

-(void) setFragmentShader: (CC3FragmentShader*) fragmentShader {
	if (fragmentShader == _fragmentShader) return;
	
	[self detachShader: _fragmentShader];
	_fragmentShader = fragmentShader;
	[self attachShader: _fragmentShader];
}

-(void) attachShader: (CC3Shader*) shader {
	[CC3OpenGL.sharedGL attachShader: shader.shaderID toShaderProgram: self.programID];
}

-(void) detachShader: (CC3Shader*) shader {
	[CC3OpenGL.sharedGL detachShader: shader.shaderID fromShaderProgram: self.programID];
}


#pragma mark Variables

-(GLuint) uniformCount {
	return (GLuint)(_uniformsSceneScope.count + _uniformsNodeScope.count + _uniformsDrawScope.count);
}

-(NSArray*) uniforms {
	NSMutableArray* uniforms = [NSMutableArray arrayWithCapacity: self.uniformCount];
	[uniforms addObjectsFromArray: _uniformsSceneScope];
	[uniforms addObjectsFromArray: _uniformsNodeScope];
	[uniforms addObjectsFromArray: _uniformsDrawScope];
	return uniforms;
}

-(GLuint) uniformStorageElementCount {
	GLuint seCnt = 0;
	for (CC3GLSLUniform* var in _uniformsSceneScope) seCnt += var.storageElementCount;
	for (CC3GLSLUniform* var in _uniformsNodeScope) seCnt += var.storageElementCount;
	for (CC3GLSLUniform* var in _uniformsDrawScope) seCnt += var.storageElementCount;
	return seCnt;
}

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

-(GLuint) attributeCount { return (GLuint)_attributes.count; }

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

-(void) resetGLState {
	for (CC3GLSLUniform* var in _uniformsSceneScope) var.isGLStateKnown = NO;
	for (CC3GLSLUniform* var in _uniformsNodeScope) var.isGLStateKnown = NO;
	for (CC3GLSLUniform* var in _uniformsDrawScope) var.isGLStateKnown = NO;
}

#pragma mark Linking

-(void) link {
	CC3Assert(_vertexShader && _fragmentShader, @"%@ requires both vertex and fragment shaders to be assigned before linking.", self);
	CC3Assert(_semanticDelegate, @"%@ requires the semanticDelegate property be set before linking.", self);
	
	MarkRezActivityStart();
	
	[CC3OpenGL.sharedGL linkShaderProgram: self.programID];
	
	CC3Assert([CC3OpenGL.sharedGL getShaderProgramWasLinked: self.programID],
			  @"%@ could not be linked because:\n%@", self,
			  [CC3OpenGL.sharedGL getLogForShaderProgram: self.programID]);
	
#if LOGGING_REZLOAD
	NSString* linkLog = [CC3OpenGL.sharedGL getLogForShaderProgram: self.programID];
	LogRez(@"Linked %@ in %.3f ms%@", self, GetRezActivityDuration() * 1000,
		   (linkLog ? [NSString stringWithFormat: @" with the following warnings:\n%@", linkLog] : @""));
#endif	// LOGGING_REZLOAD
	
	[self configureUniforms];
	[self configureAttributes];
	
#if LOGGING_REZLOAD
	LogRez(@"Completed %@:", self.fullDescription);
	
	NSArray* vars;
	NSComparator varSorter = ^(CC3GLSLVariable* var1, CC3GLSLVariable* var2) {
		return [var1.name compare: var2.name];
	};
	
	// Include the full description of each attribute, sorted by name.
	vars = [self.attributes sortedArrayUsingComparator: varSorter];
	for (CC3GLSLVariable* var in vars) LogRez(@"%@", var.fullDescription);
	
	// Include the full description of each uniform, sorted by name.
	vars = [self.uniforms sortedArrayUsingComparator: varSorter];
	for (CC3GLSLVariable* var in vars) LogRez(@"%@", var.fullDescription);
#endif	// LOGGING_REZLOAD
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
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program uniforms for this platform has not been exceeded.", var.fullDescription);
		if (var.semantic != kCC3SemanticRedundant) {
			[_semanticDelegate configureVariable: var];
			[self addUniform: var];
		} else {
			LogRez(@"%@ is redundant and was not added to %@", var, self);
		}
	}
	LogRez(@"%@ configured %u uniforms in %.3f ms", self, varCnt, GetRezActivityDuration() * 1000);
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
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program attributes for this platform has not been exceeded.", var.fullDescription);
		if (var.semantic != kCC3SemanticRedundant) {
			[_semanticDelegate configureVariable: var];
			[_attributes addObject: var];
		} else {
			LogRez(@"%@ is redundant and was not added to %@", var, self);
		}
	}
	LogRez(@"%@ configured %u attributes in %.3f ms", self, varCnt, GetRezActivityDuration() * 1000);
}

-(void) prewarm {
	MarkRezActivityStart();
	[CC3OpenGL.sharedGL.shaderProgramPrewarmer prewarmShaderProgram: self];
	LogRez(@"%@ pre-warmed in %.3f ms", self, GetRezActivityDuration() * 1000);
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

-(void) populateUniforms: (NSArray*) uniforms withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3ShaderProgramContext* progCtx = visitor.currentMaterial.shaderContext;
	for (CC3GLSLUniform* var in uniforms) {
		if ([progCtx populateUniform: var withVisitor: visitor] ||
			[_semanticDelegate populateUniform: var withVisitor: visitor]) {
			[var updateGLValueWithVisitor: visitor];
		} else {
			CC3Assert(NO, @"%@ could not resolve the value of uniform %@ with semantic %@."
					  " If this is a valid uniform, you should create a uniform override in the"
					  " program context in your material in order to set the value of the uniform directly.",
					  self, var.name, NSStringFromCC3Semantic(var.semantic));
		}
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	CC3Assert(aName, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_uniformsSceneScope = [NSMutableArray array];
		_uniformsNodeScope = [NSMutableArray array];
		_uniformsDrawScope = [NSMutableArray array];
		_attributes = [NSMutableArray array];
		_vertexShader = nil;
		_fragmentShader = nil;
		_maxUniformNameLength = 0;
		_maxAttributeNameLength = 0;
		_isSceneScopeDirty = YES;	// start out dirty for auto-loaded programs
		_semanticDelegate = nil;
	}
	return self;
}

-(id) initWithVertexShader: (CC3VertexShader*) vertexShader
		 andFragmentShader: (CC3FragmentShader*) fragmentShader {
	return [self initWithSemanticDelegate: self.class.programMatcher.semanticDelegate
						 withVertexShader: vertexShader
						andFragmentShader: fragmentShader];
}

+(id) programWithVertexShader: (CC3VertexShader*) vertexShader
			andFragmentShader: (CC3FragmentShader*) fragmentShader {
	return [self programWithSemanticDelegate: self.programMatcher.semanticDelegate
							withVertexShader: vertexShader
						   andFragmentShader: fragmentShader];
}

-(id) initFromVertexShaderFile: (NSString*) vshFilePath
		 andFragmentShaderFile: (NSString*) fshFilePath {
	return [self initWithSemanticDelegate: self.class.programMatcher.semanticDelegate
					 fromVertexShaderFile: vshFilePath
					andFragmentShaderFile: fshFilePath];
}

+(id) programFromVertexShaderFile: (NSString*) vshFilePath
			andFragmentShaderFile: (NSString*) fshFilePath {
	return [self programWithSemanticDelegate: self.programMatcher.semanticDelegate
						fromVertexShaderFile: vshFilePath
					   andFragmentShaderFile: fshFilePath];
}

-(id) initWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
			  withVertexShader: (CC3VertexShader*) vertexShader
			 andFragmentShader: (CC3FragmentShader*) fragmentShader {
	NSString* progName = [self.class programNameFromVertexShaderName: vertexShader.name
											   andFragmentShaderName: fragmentShader.name];
	if ( (self = [self initWithName: progName]) ) {
		self.semanticDelegate = semanticDelegate;
		self.vertexShader = vertexShader;
		self.fragmentShader = fragmentShader;
		[self link];
		[self prewarm];
	}
	return self;
}

+(id) programWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
				 withVertexShader: (CC3VertexShader*) vertexShader
				andFragmentShader: (CC3FragmentShader*) fragmentShader {
	NSString* progName = [self programNameFromVertexShaderName: vertexShader.name
										 andFragmentShaderName: fragmentShader.name];
	id program = [self getProgramNamed: progName];
	if (program) return program;
	
	program = [[self alloc] initWithSemanticDelegate: semanticDelegate
									withVertexShader: vertexShader
								   andFragmentShader: fragmentShader];
	[self addProgram: program];
	return program;
}

-(id) initWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
		  fromVertexShaderFile: (NSString*) vshFilePath
		 andFragmentShaderFile: (NSString*) fshFilePath {
	return [self initWithSemanticDelegate: semanticDelegate
						 withVertexShader: [CC3VertexShader shaderFromSourceCodeFile: vshFilePath]
						andFragmentShader: [CC3FragmentShader shaderFromSourceCodeFile: fshFilePath]];
}

+(id) programWithSemanticDelegate: (id<CC3ShaderProgramSemanticsDelegate>) semanticDelegate
			 fromVertexShaderFile: (NSString*) vshFilePath
			andFragmentShaderFile: (NSString*) fshFilePath {
	return [self programWithSemanticDelegate: semanticDelegate
							withVertexShader: [CC3VertexShader shaderFromSourceCodeFile: vshFilePath]
						   andFragmentShader: [CC3FragmentShader shaderFromSourceCodeFile: fshFilePath]];
}

+(NSString*) programNameFromVertexShaderName: (NSString*) vertexShaderName
					   andFragmentShaderName: (NSString*) fragmentShaderName {
	return [NSString stringWithFormat: @"%@-%@", vertexShaderName, fragmentShaderName];
}

-(BOOL) wasLoadedFromFile {
	return _vertexShader.wasLoadedFromFile && _fragmentShader.wasLoadedFromFile;
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ (ID: %u)", [super description], _programID]; }

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ with %@ and %@, declaring %u attributes and %u uniforms"
			" (requiring at least %u uniform storage elements, from %u platform storage elements)",
			self, _vertexShader, _fragmentShader, self.attributeCount, self.uniformCount,
			self.uniformStorageElementCount, (CC3OpenGL.sharedGL.maxNumberOfVertexShaderUniformVectors * 4)];
}

-(NSString*) constructorDescription {
	return [NSString stringWithFormat: @"[%@ programFromVertexShaderFile: @\"%@\" andFragmentShaderFile: @\"%@\"];",
			[self class], self.vertexShader.name, self.fragmentShader.name];
}


#pragma mark Tag allocation

static GLuint _lastAssignedProgramTag = 0;

-(GLuint) nextTag { return ++_lastAssignedProgramTag; }

+(void) resetTagAllocation { _lastAssignedProgramTag = 0; }


#pragma mark Program cache

-(void) remove { [self.class removeProgram: self]; }

static CC3Cache* _programCache = nil;

+(void) ensureCache {
	if ( !_programCache ) _programCache = [CC3Cache weakCacheForType: @"shader program"];
}

+(void) addProgram: (CC3ShaderProgram*) program {
	if ( !self.isPreloading ) {
		LogInfo(@"%@ is likely being compiled and linked outside of a pre-load stage, which"
				@" may cause a short, unexpected pause in the drawing of the scene, while the"
				@" final stages of compilation and configuration are carried out. If this is"
				@" the case, consider pre-loading this shader program during scene initialization."
				@" See the notes of the %@ setIsPreloading: class-side method for more information"
				@" on pre-loading.", program, self);
	}
	[self ensureCache];
	[_programCache addObject: program];
	
	// If appropriate, ensure that a matching pure-color program is added as well.
	if (self.isPreloading && self.shouldAutomaticallyPreloadMatchingPureColorPrograms)
		[self.programMatcher pureColorProgramMatching: program];
}

+(CC3ShaderProgram*) getProgramNamed: (NSString*) name {
	return (CC3ShaderProgram*)[_programCache getObjectNamed: name];
}

+(void) removeProgram: (CC3ShaderProgram*) program { [_programCache removeObject: program]; }

+(void) removeProgramNamed: (NSString*) name { [_programCache removeObjectNamed: name]; }

+(void) removeAllPrograms { [_programCache removeAllObjectsOfType: self];}

static BOOL _shouldAutomaticallyPreloadMatchingPureColorPrograms = YES;

+(BOOL) shouldAutomaticallyPreloadMatchingPureColorPrograms { return _shouldAutomaticallyPreloadMatchingPureColorPrograms; }

+(void) setShouldAutomaticallyPreloadMatchingPureColorPrograms: (BOOL) shouldAdd {
	_shouldAutomaticallyPreloadMatchingPureColorPrograms = shouldAdd;
}

+(BOOL) isPreloading { return _programCache ? !_programCache.isWeak : NO; }

+(void) setIsPreloading: (BOOL) isPreloading {
	[self ensureCache];
	_programCache.isWeak = !isPreloading;
}

+(void) willBeginDrawingScene {
	[_programCache enumerateObjectsUsingBlock: ^(CC3ShaderProgram* prog, BOOL* stop) {
		[prog willBeginDrawingScene];
	}];
}

+(NSString*) loadedProgramsDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	NSArray* sortedCache = [_programCache objectsSortedByName];
	for (CC3ShaderProgram* prog in sortedCache) {
		if ( [prog isKindOfClass: self] && prog.wasLoadedFromFile )
			[desc appendFormat: @"\n\t%@", prog.constructorDescription];
	}
	return desc;
}


#pragma mark Program matching

static id<CC3ShaderProgramMatcher> _programMatcher = nil;

+(id<CC3ShaderProgramMatcher>) programMatcher {
	if ( !_programMatcher ) _programMatcher = [CC3ShaderProgramMatcherBase new];
	return _programMatcher;
}

+(void) setProgramMatcher: (id<CC3ShaderProgramMatcher>) programMatcher {
	_programMatcher = programMatcher;
}

@end


#pragma mark -
#pragma mark CC3Shader

@implementation CC3Shader

@synthesize shaderPreamble=_shaderPreamble;
@synthesize wasLoadedFromFile=_wasLoadedFromFile;

-(void) dealloc {
	[self remove];		// remove this instance from the cache
	[self deleteGLShader];
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

-(NSString*) shaderPreambleString { return self.shaderPreamble.sourceCodeString; }

-(void) setShaderPreambleString: (NSString*) shaderPreambleString {
	NSString* preambleName = [NSString stringWithFormat: @"%@-Preamble", self.name];
	_shaderPreamble = [CC3ShaderSourceCode shaderSourceCodeWithName: preambleName
												 fromSourceCodeString: shaderPreambleString];
}

-(NSString*) defaultShaderPreambleString { return CC3OpenGL.sharedGL.defaultShaderPreamble; }

static CC3ShaderSourceCode* _defaultShaderPreamble = nil;

-(CC3ShaderSourceCode*) defaultShaderPreamble {
	if ( !_defaultShaderPreamble ) {
		_defaultShaderPreamble = [CC3ShaderSourceCode shaderSourceCodeWithName: @"DefaultShaderPreamble"
														  fromSourceCodeString: self.defaultShaderPreambleString];
	}
	return _defaultShaderPreamble;
}


#pragma mark Compiling

-(void) compileFromSourceCode: (CC3ShaderSourceCode*) shSrcCode {
	CC3Assert(shSrcCode, @"%@ cannot complile NULL GLSL source.", self);
	
	MarkRezActivityStart();
	
	_wasLoadedFromFile = shSrcCode.wasLoadedFromFile;
	
	// Use a visitor to extract an array of source code strings from the preamble and specified source code
	CC3ShaderSourceCodeSegmentAccumulatingVisitor* visitor = [CC3ShaderSourceCodeSegmentAccumulatingVisitor visitor];
	[visitor visit: _shaderPreamble];
	[visitor visit: shSrcCode];

	// Submit the source code strings to the compiler
	GLuint scCnt = visitor.sourceCodeSegmentCount;
	const GLchar* scStrings[scCnt];
	[visitor populateSourceCodeStrings: scStrings];
	[CC3OpenGL.sharedGL compileShader: self.shaderID from: scCnt sourceCodeStrings: scStrings];
	
	CC3Assert([CC3OpenGL.sharedGL getShaderWasCompiled: self.shaderID],
			  @"%@ failed to compile because:\n%@", self,
			  [self localizeCompileErrors: [CC3OpenGL.sharedGL getLogForShader: self.shaderID]
						 fromShaderSource: shSrcCode]);
	
#if LOGGING_REZLOAD
	NSString* compLog = [CC3OpenGL.sharedGL getLogForShader: self.shaderID];
	LogRez(@"Compiled %@ in %.3f ms%@", self, GetRezActivityDuration() * 1000,
		   (compLog ? [NSString stringWithFormat: @" with the following warnings:\n%@", compLog] : @""));
#endif	// LOGGING_REZLOAD
	
}

-(void) compileFromSourceCodeString: (NSString*) glslSource {
	[self compileFromSourceCode: [CC3ShaderSourceCode shaderSourceCodeWithName: self.name
														  fromSourceCodeString: glslSource]];
}

/**
 * Inserts a reference to the original source file and line number for each compile error found
 * in the specified error text.
 *
 * The compiler concatenates all of the shader source code into one long string when referencing line
 * numbers. However, the source code can originate from multiple imported source files. This method 
 * extracts the line number referenced in the shader compiler error log, determines which original
 * source file that line number refereneces, inserts the name of that source file and the corresponding
 * line number within that source file into the error text, and returns the modified error text.
 */
-(NSString*) localizeCompileErrors: (NSString*) logTxt fromShaderSource: (CC3ShaderSourceCode*) shSrcCode {

	// Platform-dependent content
	NSString* fieldSeparatorStr = @":";
	NSString* errIndicatorStr = @"ERROR";
	NSUInteger errIndicatorFieldIdx = 0;
	NSUInteger lineNumFieldIdx = 2;

	// Create a new log string to contain the localized error text
	NSMutableString* localizedLogTxt = [NSMutableString stringWithCapacity: logTxt.length + 100];

	// Proceed line by line
	[logTxt enumerateLinesUsingBlock: ^(NSString* line, BOOL* lineStop) {
		BOOL __block isErrLine = NO;
		
		// Separate the line into fields
		[[line componentsSeparatedByString: fieldSeparatorStr] enumerateObjectsUsingBlock: ^(NSString* field, NSUInteger fieldIdx, BOOL* segStop) {

			// Write the existing field out to the new log entry
			[localizedLogTxt appendString: field];

			// If the first field contains the error indicator, this line is a compile error
			if (fieldIdx == errIndicatorFieldIdx &&
				([field rangeOfString: errIndicatorStr
							  options: NSCaseInsensitiveSearch].location != NSNotFound) )
				isErrLine = YES;

			// If this line does contain an error, extract the global line number from the
			// third field, and localize it, first to the preamble, and then to the specified
			// shader source, and write the localized line number to the new log entry.
			if (isErrLine && fieldIdx == lineNumFieldIdx) {
				CC3ShaderSourceCodeLineNumberLocalizingVisitor* visitor;
				visitor = [CC3ShaderSourceCodeLineNumberLocalizingVisitor lineNumberWithLineNumber: [field intValue]];
				if ([visitor visit: _shaderPreamble] || [visitor visit: shSrcCode])
					[localizedLogTxt appendFormat: @"(%@)", visitor.description];
			}

			// Write the log field separator at the end of each field
			[localizedLogTxt appendString: fieldSeparatorStr];
		}];
		
		// Strip the last field separator and append a newline
		NSUInteger fieldSepLen = fieldSeparatorStr.length;
		[localizedLogTxt deleteCharactersInRange: NSMakeRange(localizedLogTxt.length - fieldSepLen, fieldSepLen)];
		[localizedLogTxt appendString: @"\n"];
	}];
	
	return localizedLogTxt;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	CC3Assert(aName, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_shaderID = 0;
		_wasLoadedFromFile = NO;
		self.shaderPreamble = self.defaultShaderPreamble;
	}
	return self;
}

-(id) initFromSourceCode: (CC3ShaderSourceCode*) shSrcCode {
	if ( (self = [self initWithName: shSrcCode.name]) ) {
		[self compileFromSourceCode: shSrcCode];
	}
	return self;
}

+(id) shaderFromSourceCode: (CC3ShaderSourceCode*) shSrcCode {
	id shader = [self getShaderNamed: shSrcCode.name];
	if (shader) return shader;
	
	shader = [[self alloc] initFromSourceCode: shSrcCode];
	[self addShader: shader];
	return shader;
}

-(id) initWithName: (NSString*) name fromSourceCode: (NSString*) glslSource {
	return [self initFromSourceCode: [CC3ShaderSourceCode shaderSourceCodeWithName: name
															  fromSourceCodeString: glslSource]];
}

// We don't delegate to shaderFromShaderSource: by retrieving the shader source, because the
// shader source may have been dropped from its cache, even though the shader is still in its
// cache. The result would be to constantly create and cache the shader source unnecessarily.
+(id) shaderWithName: (NSString*) name fromSourceCode: (NSString*) srcCodeString {
	id shader = [self getShaderNamed: name];
	if (shader) return shader;
	
	shader = [[self alloc] initWithName: name fromSourceCode: srcCodeString];
	[self addShader: shader];
	return shader;
}

-(id) initFromSourceCodeFile: (NSString*) aFilePath {
	return [self initFromSourceCode: [CC3ShaderSourceCode shaderSourceCodeFromFile: aFilePath]];
}

// We don't delegate to shaderFromShaderSource: by retrieving the shader source, because the
// shader source may have been dropped from its cache, even though the shader is still in its
// cache. The result would be to constantly create and cache the shader source unnecessarily.
+(id) shaderFromSourceCodeFile: (NSString*) aFilePath {
	id shader = [self getShaderNamed: [CC3ShaderSourceCode shaderSourceCodeNameFromFilePath: aFilePath]];
	if (shader) return shader;
	
	shader = [[self alloc] initFromSourceCodeFile: aFilePath];
	[self addShader: shader];
	return shader;
}

// Deprecated
+(NSString*) shaderNameFromFilePath: (NSString*) aFilePath {
	return [CC3ShaderSourceCode shaderSourceCodeNameFromFilePath: aFilePath];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (ID: %u)", [super description], _shaderID];
}

-(NSString*) constructorDescription {
	return [NSString stringWithFormat: @"[%@ shaderFromSourceCodeFile: @\"%@\"];", [self class], self.name];
}


#pragma mark Tag allocation

static GLuint _lastAssignedShaderTag = 0;

-(GLuint) nextTag { return ++_lastAssignedShaderTag; }

+(void) resetTagAllocation { _lastAssignedShaderTag = 0; }


#pragma mark Shader cache

-(void) remove { [self.class removeShader: self]; }

static CC3Cache* _shaderCache = nil;

+(void) ensureCache {
	if ( !_shaderCache ) _shaderCache = [CC3Cache weakCacheForType: @"shader"];
}

+(void) addShader: (CC3Shader*) shader {
	[self ensureCache];
	[_shaderCache addObject: shader];
}

+(CC3Shader*) getShaderNamed: (NSString*) name {
	return (CC3Shader*)[_shaderCache getObjectNamed: name];
}

+(void) removeShader: (CC3Shader*) shader { [_shaderCache removeObject: shader]; }

+(void) removeShaderNamed: (NSString*) name { [_shaderCache removeObjectNamed: name]; }

+(void) removeAllShaders { [_shaderCache removeAllObjectsOfType: self];}

+(BOOL) isPreloading { return _shaderCache ? !_shaderCache.isWeak : NO; }

+(void) setIsPreloading: (BOOL) isPreloading {
	[self ensureCache];
	_shaderCache.isWeak = !isPreloading;
}

+(NSString*) loadedShadersDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	NSArray* sortedCache = [_shaderCache objectsSortedByName];
	for (CC3Shader* shdr in sortedCache) {
		if ( [shdr isKindOfClass: self] && shdr.wasLoadedFromFile )
			[desc appendFormat: @"\n\t%@", shdr.constructorDescription];
	}
	return desc;
}

@end


#pragma mark -
#pragma mark CC3VertexShader

@implementation CC3VertexShader

-(GLenum) shaderType { return GL_VERTEX_SHADER; }

@end


#pragma mark -
#pragma mark CC3FragmentShader

@implementation CC3FragmentShader

-(GLenum) shaderType { return GL_FRAGMENT_SHADER; }

@end


#pragma mark -
#pragma mark CC3ShaderSourceCode

@implementation CC3ShaderSourceCode

@synthesize wasLoadedFromFile=_wasLoadedFromFile;

-(void) dealloc {
	[self remove];		// remove this instance from the cache
}

-(GLuint) lineCount {
	CC3AssertUnimplemented(@"lineCount");
	return 0;
}

-(NSString*) sourceCodeString {
	CC3AssertUnimplemented(@"sourceCode");
	return nil;
}

-(NSString*) importableSourceCodeString {
	return (self.wasLoadedFromFile
				? [NSString stringWithFormat:@"#import \"%@\"", self.name]
				: self.sourceCodeString);
}

-(NSArray*) subsections { return nil; }


#pragma mark Visiting

-(BOOL) localizeLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor { return NO; }

-(BOOL) finishLocalizingLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor { return NO; }

-(BOOL) addSourceCodeSegmentsToVisitor: (CC3ShaderSourceCodeSegmentAccumulatingVisitor*) visitor { return NO; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) tag withName: (NSString*) name {
	CC3Assert(name, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_wasLoadedFromFile = NO;
	}
	return self;
}

+(id) shaderSourceCodeWithName: (NSString*) name fromSourceCodeString: (NSString*) srcCodeString {
	CC3ShaderSourceCode* shSrc = [self getShaderSourceCodeNamed: name];
	if (shSrc) return shSrc;
	
	NSUInteger srcStrLen = srcCodeString.length;
	
	CC3ShaderSourceCodeGroup* shSrcGrp = [[CC3ShaderSourceCodeGroup alloc] initWithName: name];
	CC3ShaderSourceCodeBytes* shSrcStr = nil;
	NSUInteger cursorPos = 0;		// Start at the beginning of the source code string
	GLuint sectionCount = 0;		// Running count of the number of compilable sections within this file.
	
	// We now have the entire contents of the source code in a string. We loop through the file
	// contents looking for any occurrences of #import or #include statements. The source code
	// before the statement is added to the source code group, and then the contents of the
	// imported/included file is loaded and added to the source code group.
	while (cursorPos < srcStrLen) {
		NSRange srcCodeRange;
		NSString* importFileName;
		
		// Look for the next occurence of an #import or #include statement
		NSRange importMatchRange = [srcCodeString rangeOfString: @"(?im)^[ \\t]*#[ \\t]*(import|include)"
														options: NSRegularExpressionSearch
														  range: NSMakeRange(cursorPos, srcStrLen - cursorPos)];
		// Determine whether a match was found.
		BOOL importWasFound = (importMatchRange.location != NSNotFound);
		if (importWasFound) {
			
			// Get the range of source code that appears prior to the import statement in this file.
			srcCodeRange = NSMakeRange(cursorPos, importMatchRange.location - cursorPos);
			
			// Extract the full line of text containing the import/include statement.
			// Break the line into components deliniated by double-quote marks (").
			// The file name to import will be the second of these components.
			// Finally, set the cursor to the end of the line containing the import/include statement.
			NSRange importLineRange = [srcCodeString lineRangeForRange: importMatchRange];
			NSString* importLine = [srcCodeString substringWithRange: importLineRange];
 			NSArray* importLineComponents = [importLine componentsSeparatedByString: @"\""];
			if (importLineComponents.count > 1) importFileName = [importLineComponents objectAtIndex: 1];
			cursorPos = NSMaxRange(importLineRange);
			
		} else {
			// No further import/include statements found. Get the range for all remaining
			// source code in this file, and place the cursor at the end of the file.
			srcCodeRange = NSMakeRange(cursorPos, srcStrLen - cursorPos);
			importFileName = nil;
			cursorPos = srcStrLen;
		}
		
		// Get the block of source code that appears between the current cursor position in the file
		// and the import/include statement (or end of file), and create a uncached source code bytes
		// instance from it. If a shader source group has been created, add the new shader source to it.
		// Exclude source code that is empty (eg- between two consecutive import lines), but do include
		// all other code (even comments and whitespace), to retain line numbering for error reporting.
		NSString* srcCode = [srcCodeString substringWithRange: srcCodeRange];
		if (srcCode.length > 0) {
			NSString* shSrcStrName = [name stringByAppendingFormat: @"-Section-%u", ++sectionCount];
			shSrcStr = [[CC3ShaderSourceCodeBytes alloc] initWithName: shSrcStrName fromSourceCodeString: srcCode];
			[shSrcGrp addSubsection: shSrcStr];
		}

		// If an import/include file name was extracted, load the file into a shader source object,
		// and add it to the root shader source object for this file.
		if (importFileName) [shSrcGrp addSubsection: [self shaderSourceCodeFromFile: importFileName]];
	}
	
	// Add extracted source code group to the cache and return it.
	[self addShaderSourceCode: shSrcGrp];
	return shSrcGrp;
}

+(id) shaderSourceCodeFromFile: (NSString*) aFilePath {
	NSString* shSrcName = [self shaderSourceCodeNameFromFilePath: aFilePath];
	CC3ShaderSourceCode* shSrc = [self getShaderSourceCodeNamed: shSrcName];
	if (shSrc) return shSrc;
	
	MarkRezActivityStart();
	
	NSError* err = nil;
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
	CC3Assert([[NSFileManager defaultManager] fileExistsAtPath: absFilePath],
			  @"Could not load GLSL file '%@' because it could not be found", absFilePath);
	NSString* srcCodeString = [NSString stringWithContentsOfFile: absFilePath encoding: NSUTF8StringEncoding error: &err];
	CC3Assert(!err, @"Could not load GLSL file '%@' because %@, (code %li), failure reason %@",
			  absFilePath, err.localizedDescription, (long)err.code, err.localizedFailureReason);
	
	shSrc = [self shaderSourceCodeWithName: shSrcName fromSourceCodeString: srcCodeString];
	shSrc.wasLoadedFromFile = YES;
	
	LogRez(@"Loaded GLSL source from file %@ in %.3f ms", aFilePath, GetRezActivityDuration() * 1000);
	return shSrc;
}


+(NSString*) shaderSourceCodeNameFromFilePath: (NSString*) aFilePath { return aFilePath.lastPathComponent; }

-(NSString*) constructorDescription {
	return [NSString stringWithFormat: @"[%@ shaderSourceCodeFromFile: @\"%@\"];", [self class], self.name];
}


#pragma mark Shader source cache

-(void) remove { [self.class removeShaderSourceCode: self]; }

static CC3Cache* _shaderSourceCodeCache = nil;

+(void) ensureCache {
	if ( !_shaderSourceCodeCache ) _shaderSourceCodeCache = [CC3Cache weakCacheForType: @"shader source"];
}

+(void) addShaderSourceCode: (CC3ShaderSourceCode*) shSrcCode {
	[self ensureCache];
	[_shaderSourceCodeCache addObject: shSrcCode];
}

+(CC3ShaderSourceCode*) getShaderSourceCodeNamed: (NSString*) name {
	return (CC3ShaderSourceCode*)[_shaderSourceCodeCache getObjectNamed: name];
}

+(void) removeShaderSourceCode: (CC3ShaderSourceCode*) shSrcCode { [_shaderSourceCodeCache removeObject: shSrcCode]; }

+(void) removeShaderSourceCodeNamed: (NSString*) name { [_shaderSourceCodeCache removeObjectNamed: name]; }

+(void) removeAllShaderSourceCode { [_shaderSourceCodeCache removeAllObjectsOfType: self];}

+(BOOL) isPreloading { return _shaderSourceCodeCache ? !_shaderSourceCodeCache.isWeak : NO; }

+(void) setIsPreloading: (BOOL) isPreloading {
	[self ensureCache];
	_shaderSourceCodeCache.isWeak = !isPreloading;
}

+(NSString*) loadedShaderSourceCodeDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	NSArray* sortedCache = [_shaderSourceCodeCache objectsSortedByName];
	for (CC3ShaderSourceCode* shSrc in sortedCache) {
		if ( [shSrc isKindOfClass: self] && shSrc.wasLoadedFromFile )
			[desc appendFormat: @"\n\t%@", shSrc.constructorDescription];
	}
	return desc;
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeBytes

@implementation CC3ShaderSourceCodeBytes

-(GLuint) sourceStringCount { return 1; }

-(const GLchar*) sourceCodeBytes { return _sourceCode.bytes; }

-(GLuint) lineCount {
	GLuint lineCnt = 0;
	GLuint charCnt = (GLuint)_sourceCode.length;
	const GLchar* scBytes = self.sourceCodeBytes;
	for (GLuint charIdx = 0; charIdx < charCnt; charIdx++)
		if (scBytes[charIdx] == '\n') lineCnt++;
	return lineCnt;
}


#pragma mark Visiting

/**
 * If the line number is within my range, this is the source of the line number. Set the
 * shSrcCode of the line number to this object and return YES. Otherwise, subtract the
 * number of lines in this source from the line number and return NO.
 */
-(BOOL) localizeLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor {
	GLuint lineCount = self.lineCount;
	if (visitor.lineNumber <= lineCount) {
		visitor.localizedSourceCode = self;
		return YES;
	} else {
		visitor.lineNumber -= lineCount;
		[visitor addLineNumberOffset: lineCount];
		return NO;
	}
}

-(BOOL) addSourceCodeSegmentsToVisitor: (CC3ShaderSourceCodeSegmentAccumulatingVisitor*) visitor {
	[visitor addSourceCodeSegment: self];
	return NO;
}

-(NSString*) sourceCode { return [NSString stringWithUTF8String: _sourceCode.bytes]; }


#pragma mark Allocation and initialization

-(id) initWithName: (NSString*) name fromSourceCodeString: (NSString*) srcCodeString {
	CC3Assert(srcCodeString, @"%@ cannot complile NULL source code.", self);
	if ( (self = [self initWithName: name]) ) {
		_sourceCode = [NSData dataWithBytes: srcCodeString.UTF8String
									 length: (srcCodeString.length + 1)];	// Don't forget the null-terminator
	}
	return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ of length %lu bytes", [super description], (unsigned long)_sourceCode.length];
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeGroup

@implementation CC3ShaderSourceCodeGroup

-(NSArray*) subsections { return _subsections; }

-(void) addSubsection: (CC3ShaderSourceCode*) shSrcCode {
	if (shSrcCode) [_subsections addObject: shSrcCode];
}

-(GLuint) lineCount {
	GLuint lineCnt = 0;
	for (CC3ShaderSourceCode* shSrc in _subsections) lineCnt += shSrc.lineCount;
	return lineCnt;
}

-(NSString*) sourceCodeString {
	NSMutableString* srcCode = [NSMutableString stringWithCapacity: 500];
	for (CC3ShaderSourceCode* shSrc in _subsections) {
		[srcCode appendString: shSrc.importableSourceCodeString];
		[srcCode appendString: @"\n"];
	}
	return srcCode;
}


#pragma mark Visiting

/** Starting a new group, so reset line number offset to zero. */
-(BOOL) localizeLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor {
	[visitor pushLineNumberOffset: 0];
	return NO;
}

/** 
 * Done with this group, so pop up to the next level for line number offset tracking, 
 * and increment to cover the #import/include statement that invoked this group. 
 */
-(BOOL) finishLocalizingLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor {
	[visitor popLineNumberOffset];
	[visitor addLineNumberOffset: 1];
	return NO;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) tag withName: (NSString*) name {
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_subsections = [NSMutableArray array];
	}
	return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %lu subsections", [super description], (unsigned long)_subsections.count];
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeVisitor

@implementation CC3ShaderSourceCodeVisitor

-(BOOL) visit: (CC3ShaderSourceCode*) srcCode {
	NSString* ssName = srcCode.name;
	if ( !ssName || [_sourceCodeNamesTraversed containsObject: ssName] ) return [self skip: srcCode];
	
	[_sourceCodeNamesTraversed addObject: ssName];
	
	if ( [self process: srcCode] ) return YES;
	
	for (CC3ShaderSourceCode* ss in srcCode.subsections) if ( [self visit: ss] ) return YES;
	
	return [self finish: srcCode];
}

-(BOOL) skip: (CC3ShaderSourceCode*) srcCode { return NO; }

-(BOOL) process: (CC3ShaderSourceCode*) srcCode { return NO; }

-(BOOL) finish: (CC3ShaderSourceCode*) srcCode { return NO; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_sourceCodeNamesTraversed = [NSMutableSet set];
	}
	return self;
}

+(id) visitor { return [[self alloc] init]; }

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeLineNumberLocalizingVisitor

@implementation CC3ShaderSourceCodeLineNumberLocalizingVisitor

@synthesize lineNumber=_lineNumber, localizedSourceCode=_localizedSourceCode;

/** Increment the line offset to compensate for the #import/include statement that is being skipped. */
-(BOOL) skip: (CC3ShaderSourceCode*) srcCode {
	[self addLineNumberOffset: 1];
	return NO;
}

-(BOOL) process: (CC3ShaderSourceCode*) srcCode {
	return [srcCode localizeLineNumberWithVisitor: self];
}

-(BOOL) finish: (CC3ShaderSourceCode*) srcCode {
	return [srcCode finishLocalizingLineNumberWithVisitor: self];
}

-(GLuint) lineNumberOffset { return ((NSNumber*)_lineNumberOffsets.lastObject).unsignedIntValue; }

-(void) pushLineNumberOffset: (GLuint) lineNumberOffset {
	[_lineNumberOffsets addObject: [NSNumber numberWithUnsignedInt: lineNumberOffset]];
}

-(void) popLineNumberOffset { [_lineNumberOffsets removeLastObject]; }

-(void) addLineNumberOffset: (GLuint) lineNumberOffset {
	GLuint currOffset = self.lineNumberOffset;
	[self popLineNumberOffset];
	[self pushLineNumberOffset: (currOffset + lineNumberOffset)];
}


#pragma mark Allocation and initialization

-(id) initWithLineNumber: (GLuint) lineNumber {
	if ( (self = [super init]) ) {
		_lineNumber = lineNumber;
		_lineNumberOffsets = [NSMutableArray array];
		[self pushLineNumberOffset: 0];		// Init stack with a base value
	}
	return self;
}

+(id) lineNumberWithLineNumber: (GLuint) lineNumber {
	return [[self alloc] initWithLineNumber: lineNumber];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:%u", _localizedSourceCode.name, _lineNumber + self.lineNumberOffset];
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeSegmentAccumulatingVisitor

@implementation CC3ShaderSourceCodeSegmentAccumulatingVisitor

-(GLuint) sourceCodeSegmentCount { return (GLuint)_sourceCodeSegments.count; }

-(BOOL) process: (CC3ShaderSourceCode*) srcCode {
	return [srcCode addSourceCodeSegmentsToVisitor: self];
}

-(void) addSourceCodeSegment: (CC3ShaderSourceCodeBytes*) srcCodeBytes {
	[_sourceCodeSegments addObject: srcCodeBytes];
}

-(void) populateSourceCodeStrings: (const GLchar**) sourceCodeSegmentStrings {
	GLuint segIdx = 0;
	for (CC3ShaderSourceCodeBytes* seg in _sourceCodeSegments)
		sourceCodeSegmentStrings[segIdx++] = seg.sourceCodeBytes;
}

#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_sourceCodeSegments = [NSMutableArray array];
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3ShaderProgramPrewarmer

@implementation CC3ShaderProgramPrewarmer

@synthesize prewarmingSurface=_prewarmingSurface;
@synthesize prewarmingMeshNode=_prewarmingMeshNode;
@synthesize drawingVisitor=_drawingVisitor;

-(id<CC3RenderSurface>) prewarmingSurface {
	if ( !_prewarmingSurface ) {
		self.prewarmingSurface = [CC3GLFramebuffer surfaceWithSize: CC3IntSizeMake(4, 4)];
		_prewarmingSurface.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: GL_RGBA4];
		[_prewarmingSurface validate];
	}
	return _prewarmingSurface;
}

-(CC3MeshNode*) prewarmingMeshNode {
	if ( !_prewarmingMeshNode ) {
		
		// Create mesh node that only has vertex locations
		self.prewarmingMeshNode = [CC3MeshNode nodeWithName: @"ShaderPrewarmer"];
		_prewarmingMeshNode.vertexContentTypes = kCC3VertexContentLocation;
		
		// Populate the mesh as a single triangular face
		CC3Face triangle = CC3FaceMake(kCC3VectorZero, kCC3VectorUnitXPositive, kCC3VectorUnitYPositive);
		ccTex2F texCoords[3] = { {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0} };				// unused
		[_prewarmingMeshNode populateAsTriangle: triangle withTexCoords: texCoords andTessellation: 1];

		// Create VBOs in the GL engine and release the mesh from memory
		[_prewarmingMeshNode createGLBuffers];
		[_prewarmingMeshNode releaseRedundantContent];
	}
	return _prewarmingMeshNode;
}

-(CC3NodeDrawingVisitor*) drawingVisitor {
	if ( !_drawingVisitor ) self.drawingVisitor = [CC3NodeDrawingVisitor visitor];
	return _drawingVisitor;
}

-(void) prewarmShaderProgram: (CC3ShaderProgram*) program {
	CC3MeshNode* pwNode = self.prewarmingMeshNode;
	id<CC3RenderSurface> pwSurface = self.prewarmingSurface;
	CC3NodeDrawingVisitor* pwVisitor = self.drawingVisitor;

	pwNode.shaderProgram = program;
	pwNode.shaderContext.shouldEnforceCustomOverrides = NO;
	pwNode.shaderContext.shouldEnforceVertexAttributes = NO;
	pwVisitor.renderSurface = pwSurface;
	[pwSurface activate];
	[pwVisitor visit: pwNode];
	[program resetGLState];		// Reset GL state. Needed if pre-warming in background...
								// ... GL context, since state is different between contexts.
}


#pragma mark Allocation and initialization

+(id) prewarmerWithName: (NSString*) name { return [[self alloc] initWithName: name]; }

@end

