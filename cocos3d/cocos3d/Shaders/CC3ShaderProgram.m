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

#if LOGGING_REZLOAD
	NSString* compLog = [CC3OpenGL.sharedGL getLogForShader: self.shaderID];
	LogRez(@"Compiled %@ in %.3f ms%@", self, GetRezActivityDuration() * 1000,
		   (compLog ? [NSString stringWithFormat: @" with the following warnings:\n%@", compLog] : @""));
#endif	// LOGGING_REZLOAD

}

-(NSString*) defaultShaderPreamble { return CC3OpenGL.sharedGL.defaultShaderPreamble; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	CC3Assert(aName, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.shaderPreamble = self.defaultShaderPreamble;
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
	LogRez(@"Loaded GLSL source from file %@ in %.3f ms", aFilePath, GetRezActivityDuration() * 1000);
	return glslSrcStr;
}

+(NSString*) shaderNameFromFilePath: (NSString*) aFilePath { return aFilePath.lastPathComponent; }

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
	if ( !_shaderCache ) _shaderCache = [[CC3Cache weakCacheForType: @"shader"] retain];	// retained
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

+(NSString*) cachedShadersDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[_shaderCache enumerateObjectsUsingBlock: ^(CC3Shader* shdr, BOOL* stop) {
		if ( [shdr isKindOfClass: self] ) [desc appendFormat: @"\n\t%@", shdr.constructorDescription];
	}];
	return desc;
}

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

-(GLuint) uniformCount {
	return (GLuint)(_uniformsSceneScope.count + _uniformsNodeScope.count + _uniformsDrawScope.count);
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
		[_semanticDelegate configureVariable: var];
		[_attributes addObject: var];
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program attributes for this platform has not been exceeded.", var.fullDescription);
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

-(void) populateUniforms: (CCArray*) uniforms withVisitor: (CC3NodeDrawingVisitor*) visitor {
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
	return [program autorelease];
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

-(NSString*) description { return [NSString stringWithFormat: @"%@ named: %@", [self class], self.name]; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@ with %@ and %@", self, _vertexShader, _fragmentShader];
	[desc appendFormat: @". declaring %u attributes and %u uniforms, requiring at least"
	 @" %u uniform storage elements (of %u platform storage elements):",
	 self.attributeCount, self.uniformCount, self.uniformStorageElementCount,
	 (CC3OpenGL.sharedGL.maxNumberOfVertexShaderUniformVectors * 4)];
	for (CC3GLSLVariable* var in _attributes) [desc appendFormat: @"\n\t %@", var.fullDescription];
	for (CC3GLSLVariable* var in _uniformsSceneScope) [desc appendFormat: @"\n\t %@", var.fullDescription];
	for (CC3GLSLVariable* var in _uniformsNodeScope) [desc appendFormat: @"\n\t %@", var.fullDescription];
	for (CC3GLSLVariable* var in _uniformsDrawScope) [desc appendFormat: @"\n\t %@", var.fullDescription];
	return desc;
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
	if ( !_programCache ) _programCache = [[CC3Cache weakCacheForType: @"shader program"] retain];	// retained
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
}

+(CC3ShaderProgram*) getProgramNamed: (NSString*) name {
	return (CC3ShaderProgram*)[_programCache getObjectNamed: name];
}

+(void) removeProgram: (CC3ShaderProgram*) program { [_programCache removeObject: program]; }

+(void) removeProgramNamed: (NSString*) name { [_programCache removeObjectNamed: name]; }

+(void) removeAllPrograms { [_programCache removeAllObjectsOfType: self];}

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

+(NSString*) cachedProgramsDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[_programCache enumerateObjectsUsingBlock: ^(CC3ShaderProgram* prog, BOOL* stop) {
		if ( [prog isKindOfClass: self] ) [desc appendFormat: @"\n\t%@", prog.constructorDescription];
	}];
	return desc;
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


#pragma mark -
#pragma mark CC3ShaderProgramPrewarmer

@implementation CC3ShaderProgramPrewarmer

@synthesize prewarmingSurface=_prewarmingSurface;
@synthesize prewarmingMeshNode=_prewarmingMeshNode;
@synthesize drawingVisitor=_drawingVisitor;

-(id<CC3RenderSurface>) prewarmingSurface {
	if ( !_prewarmingSurface ) {
		self.prewarmingSurface = [CC3GLFramebuffer surfaceWithSize: CC3IntSizeMake(4, 4)];	// retained
		_prewarmingSurface.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: GL_RGBA4];
		[_prewarmingSurface validate];
	}
	return _prewarmingSurface;
}

-(CC3MeshNode*) prewarmingMeshNode {
	if ( !_prewarmingMeshNode ) {
		
		// Create mesh node that only has vertex locations
		self.prewarmingMeshNode = [CC3MeshNode nodeWithName: @"ShaderPrewarmer"];	// retained
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

+(id) prewarmerWithName: (NSString*) name { return [[[self alloc] initWithName: name] autorelease]; }

@end

