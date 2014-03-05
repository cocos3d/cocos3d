/*
 * CC3Shaders.m
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
 * 
 * See header file CC3Shaders.h for full API documentation.
 */

#import "CC3Shaders.h"
#import "CC3ShaderContext.h"
#import "CC3ShaderMatcher.h"
#import "CC3NodeVisitor.h"
#import "CC3Material.h"
#import "CC3RenderSurfaces.h"
#import "CC3ParametricMeshNodes.h"


#pragma mark -
#pragma mark CC3Shader

@implementation CC3Shader

@synthesize shaderPreamble=_shaderPreamble;
@synthesize wasLoadedFromFile=_wasLoadedFromFile;

-(void) dealloc {
	[self remove];		// remove this instance from the cache
	[self deleteGLShader];
	[_shaderPreamble release];
	
	[super dealloc];
}

-(GLuint) shaderID {
	if ( !_shaderID ) _shaderID = [CC3OpenGL.sharedGL createShader: self.shaderType];
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
	self.shaderPreamble = [CC3ShaderSourceCode shaderSourceCodeWithName: preambleName
												   fromSourceCodeString: shaderPreambleString];
}

-(NSString*) defaultShaderPreambleString { return CC3OpenGL.sharedGL.defaultShaderPreamble; }

static CC3ShaderSourceCode* _defaultShaderPreamble = nil;

-(CC3ShaderSourceCode*) defaultShaderPreamble {
	if ( !_defaultShaderPreamble ) {
		_defaultShaderPreamble = [[CC3ShaderSourceCode shaderSourceCodeWithName: @"DefaultShaderPreamble"
														   fromSourceCodeString: self.defaultShaderPreambleString] retain];
	}
	return _defaultShaderPreamble;
}


#pragma mark Compiling

-(void) compileFromSourceCode: (CC3ShaderSourceCode*) shSrcCode {
	CC3Assert(shSrcCode, @"%@ cannot complile NULL GLSL source.", self);
	
	MarkRezActivityStart();
	
	_wasLoadedFromFile = shSrcCode.wasLoadedFromFile;

	// Allocate an array of source code strings
	GLuint scCnt = self.shaderPreamble.sourceStringCount + shSrcCode.sourceStringCount;
	const GLchar* scStrings[scCnt];

	// Populate the source code strings from the preamble and specified source code
	CC3ShaderSourceCodeCompilationStringVisitor* visitor = [CC3ShaderSourceCodeCompilationStringVisitor visitorWithCompilationStrings: scStrings];
	[self.shaderPreamble accumulateSourceCompilationStringsWithVisitor: visitor];
	[shSrcCode accumulateSourceCompilationStringsWithVisitor: visitor];
	
	// Double-check the accummulation logic
	CC3Assert(visitor.sourceCompilationStringCount == scCnt,
			  @"%@ mismatch between sourceStringCount %u and number of accumulated source stings %u",
			  self, scCnt, visitor.sourceCompilationStringCount);
	
	// Submit the source code strings to the compiler
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
	for (NSString* line in logTxt.lines) {
		BOOL isErrLine = NO;
		NSArray* fields = [line componentsSeparatedByString: fieldSeparatorStr];
		NSUInteger fieldCount = fields.count;
		for (NSUInteger fieldIdx = 0; fieldIdx < fieldCount; fieldIdx++) {
			NSString* field = [fields objectAtIndex: fieldIdx];
			
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
				visitor = [CC3ShaderSourceCodeLineNumberLocalizingVisitor visitorWithLineNumber: [field intValue]];
				if ([self.shaderPreamble localizeLineNumberWithVisitor: visitor] ||
					[shSrcCode localizeLineNumberWithVisitor: visitor])
					[localizedLogTxt appendFormat: @"(at %@)", visitor.description];
			}
			
			// Write the log field separator at the end of each field
			[localizedLogTxt appendString: fieldSeparatorStr];
		}
		
		// Strip the last field separator and append a newline
		NSUInteger fieldSepLen = fieldSeparatorStr.length;
		[localizedLogTxt deleteCharactersInRange: NSMakeRange(localizedLogTxt.length - fieldSepLen, fieldSepLen)];
		[localizedLogTxt appendString: @"\n"];
	}
	
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
	
	shader = [[[self alloc] initFromSourceCode: shSrcCode] autorelease];
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
	
	shader = [[[self alloc] initWithName: name fromSourceCode: srcCodeString] autorelease];
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
	
	shader = [[[self alloc] initFromSourceCodeFile: aFilePath] autorelease];
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
	if ( !_shaderCache ) _shaderCache = [[CC3Cache weakCacheForType: @"shader"] retain];
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
#pragma mark CC3ShaderProgram

@implementation CC3ShaderProgram

@synthesize attributes=_attributes;
@synthesize semanticDelegate=_semanticDelegate;
@synthesize maxUniformNameLength=_maxUniformNameLength;
@synthesize maxAttributeNameLength=_maxAttributeNameLength;
@synthesize texture2DCount=_texture2DCount;
@synthesize textureCubeCount=_textureCubeCount;
@synthesize shouldAllowDefaultVariableValues=_shouldAllowDefaultVariableValues;

-(void) dealloc {
	[self remove];					// remove this instance from the cache

	self.vertexShader = nil;		// use setter to detach shader from program
	self.fragmentShader = nil;		// use setter to detach shader from program
	self.semanticDelegate = nil;
	
	[self deleteGLProgram];
	
	[_attributes release];
	[_uniformsSceneScope release];
	[_uniformsNodeScope release];
	[_uniformsDrawScope release];

	[super dealloc];
}

-(GLuint) programID {
	if ( !_programID ) _programID = [CC3OpenGL.sharedGL createShaderProgram];
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

static BOOL _defaultShouldAllowDefaultVariableValues = NO;

+(BOOL) defaultShouldAllowDefaultVariableValues { return _defaultShouldAllowDefaultVariableValues; }

+(void) setDefaultShouldAllowDefaultVariableValues: (BOOL) shouldAllow {
	_defaultShouldAllowDefaultVariableValues = shouldAllow;
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
	[self clearUniforms];

	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint progID = self.programID;
	GLint varCnt = [gl getIntegerParameter: GL_ACTIVE_UNIFORMS forShaderProgram: progID];
	_maxUniformNameLength = [gl getIntegerParameter: GL_ACTIVE_UNIFORM_MAX_LENGTH forShaderProgram: progID];
	for (GLint varIdx = 0; varIdx < varCnt; varIdx++) {
		CC3GLSLUniform* var = [CC3GLSLUniform variableInProgram: self atIndex: varIdx];
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program uniforms for this platform has not been exceeded.", var.fullDescription);
		if (var.semantic != kCC3SemanticRedundant) {
			[self configureUniform: var];
			[self addUniform: var];
		} else {
			LogRez(@"%@ is redundant and was not added to %@", var, self);
		}
	}
	LogRez(@"%@ configured %u uniforms in %.3f ms", self, varCnt, GetRezActivityDuration() * 1000);
}

-(void) clearUniforms {
	[_uniformsSceneScope removeAllObjects];
	[_uniformsNodeScope removeAllObjects];
	[_uniformsDrawScope removeAllObjects];
	_texture2DCount = 0;
	_textureCubeCount = 0;
}

/** Let the delegate configure the uniform, and then update the texture counts. */
-(void) configureUniform: (CC3GLSLUniform*) var {
	[_semanticDelegate configureVariable: var];
	
	if (var.semantic == kCC3SemanticTextureSampler) _texture2DCount += var.size;
	if (var.semantic == kCC3SemanticTexture2DSampler) _texture2DCount += var.size;
	if (var.semantic == kCC3SemanticTextureCubeSampler) _textureCubeCount += var.size;
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
	[self clearAttributes];
	
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint progID = self.programID;
	GLint varCnt = [gl getIntegerParameter: GL_ACTIVE_ATTRIBUTES forShaderProgram: progID];
	_maxAttributeNameLength = [gl getIntegerParameter: GL_ACTIVE_ATTRIBUTE_MAX_LENGTH forShaderProgram: progID];
	for (GLint varIdx = 0; varIdx < varCnt; varIdx++) {
		CC3GLSLAttribute* var = [CC3GLSLAttribute variableInProgram: self atIndex: varIdx];
		CC3Assert(var.location >= 0, @"%@ has an invalid location. Make sure the maximum number of program attributes for this platform has not been exceeded.", var.fullDescription);
		if (var.semantic != kCC3SemanticRedundant) {
			[self configureAttribute: var];
			[self addAttribute: var];
		} else {
			LogRez(@"%@ is redundant and was not added to %@", var, self);
		}
	}
	LogRez(@"%@ configured %u attributes in %.3f ms", self, varCnt, GetRezActivityDuration() * 1000);
}

-(void) clearAttributes { [_attributes removeAllObjects]; }

/** Let the delegate configure the attribute. */
-(void) configureAttribute: (CC3GLSLAttribute*) var { [_semanticDelegate configureVariable: var]; }

/** Adds the specified attribute to the internal collection. */
-(void) addAttribute: (CC3GLSLAttribute*) var { [_attributes addObject: var]; }

-(void) prewarm {
	MarkRezActivityStart();
	[CC3OpenGL.sharedGL.shaderProgramPrewarmer prewarmShaderProgram: self];
	LogRez(@"%@ pre-warmed in %.3f ms", self, GetRezActivityDuration() * 1000);
}


#pragma mark Binding

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@ with %@", visitor.currentMeshNode, self);
	CC3OpenGL* gl = visitor.gl;
	
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
	CC3ShaderContext* progCtx = visitor.currentMeshNode.shaderContext;
	for (CC3GLSLUniform* var in uniforms) {
		BOOL wasSet = ([progCtx populateUniform: var withVisitor: visitor] ||
					   [_semanticDelegate populateUniform: var withVisitor: visitor]);

		if ( !wasSet ) {
			CC3Assert(self.shouldAllowDefaultVariableValues,
					  @"%@ could not resolve the value of uniform %@ with semantic %@."
					  @" If this is a valid uniform, you should create a uniform override in the"
					  @" shader context in your mesh node to set the value of the uniform directly."
					  @" Or you can allow a default uniform value to be used, and avoid this message,"
					  @" by setting the shouldAllowDefaultVariableValues property of the shader program to YES.",
					  self, var.name, NSStringFromCC3Semantic(var.semantic));
		}
		
		[var updateGLValueWithVisitor: visitor];
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	CC3Assert(aName, @"%@ cannot be created without a name", [self class]);
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_attributes = [NSMutableArray new];				// retained
		_uniformsSceneScope = [NSMutableArray new];		// retained
		_uniformsNodeScope = [NSMutableArray new];		// retained
		_uniformsDrawScope = [NSMutableArray new];		// retained
		_vertexShader = nil;
		_fragmentShader = nil;
		_maxUniformNameLength = 0;
		_maxAttributeNameLength = 0;
		_texture2DCount = 0;
		_textureCubeCount = 0;
		_isSceneScopeDirty = YES;	// start out dirty for auto-loaded programs
		_semanticDelegate = nil;
		_shouldAllowDefaultVariableValues = self.class.defaultShouldAllowDefaultVariableValues;
	}
	return self;
}

-(id) initWithVertexShader: (CC3VertexShader*) vertexShader
		 andFragmentShader: (CC3FragmentShader*) fragmentShader {
	return [self initWithSemanticDelegate: self.class.shaderMatcher.semanticDelegate
						 withVertexShader: vertexShader
						andFragmentShader: fragmentShader];
}

+(id) programWithVertexShader: (CC3VertexShader*) vertexShader
			andFragmentShader: (CC3FragmentShader*) fragmentShader {
	return [self programWithSemanticDelegate: self.shaderMatcher.semanticDelegate
							withVertexShader: vertexShader
						   andFragmentShader: fragmentShader];
}

-(id) initFromVertexShaderFile: (NSString*) vshFilePath
		 andFragmentShaderFile: (NSString*) fshFilePath {
	return [self initWithSemanticDelegate: self.class.shaderMatcher.semanticDelegate
					 fromVertexShaderFile: vshFilePath
					andFragmentShaderFile: fshFilePath];
}

+(id) programFromVertexShaderFile: (NSString*) vshFilePath
			andFragmentShaderFile: (NSString*) fshFilePath {
	return [self programWithSemanticDelegate: self.shaderMatcher.semanticDelegate
						fromVertexShaderFile: vshFilePath
					   andFragmentShaderFile: fshFilePath];
}

-(id) initWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
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

+(id) programWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
				 withVertexShader: (CC3VertexShader*) vertexShader
				andFragmentShader: (CC3FragmentShader*) fragmentShader {
	NSString* progName = [self programNameFromVertexShaderName: vertexShader.name
										 andFragmentShaderName: fragmentShader.name];
	id program = [self getProgramNamed: progName];
	if (program) return program;
	
	program = [[[self alloc] initWithSemanticDelegate: semanticDelegate
									 withVertexShader: vertexShader
									andFragmentShader: fragmentShader] autorelease];
	[self addProgram: program];
	return program;
}

-(id) initWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
		  fromVertexShaderFile: (NSString*) vshFilePath
		 andFragmentShaderFile: (NSString*) fshFilePath {
	return [self initWithSemanticDelegate: semanticDelegate
						 withVertexShader: [CC3VertexShader shaderFromSourceCodeFile: vshFilePath]
						andFragmentShader: [CC3FragmentShader shaderFromSourceCodeFile: fshFilePath]];
}

+(id) programWithSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate
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
	if ( !_programCache ) _programCache = [[CC3Cache weakCacheForType: @"shader program"] retain];
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
		[self.shaderMatcher pureColorProgramMatching: program];
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

static id<CC3ShaderMatcher> _shaderMatcher = nil;

+(id<CC3ShaderMatcher>) shaderMatcher {
	if ( !_shaderMatcher ) self.shaderMatcher = [[CC3ShaderMatcherBase new] autorelease];
	return _shaderMatcher;
}

+(void) setShaderMatcher: (id<CC3ShaderMatcher>) shaderMatcher {
	if (shaderMatcher == _shaderMatcher) return;
	[_shaderMatcher release];
	_shaderMatcher = [shaderMatcher retain];
}

// Deprecated
+(id<CC3ShaderMatcher>) programMatcher { return [self shaderMatcher]; }
+(void) setProgramMatcher: (id<CC3ShaderMatcher>) programMatcher { [self setShaderMatcher: programMatcher]; }

@end


#pragma mark -
#pragma mark CC3ShaderSourceCode

@implementation CC3ShaderSourceCode

@synthesize wasLoadedFromFile=_wasLoadedFromFile;

-(void) dealloc {
	[self remove];		// remove this instance from the cache
	[super dealloc];
}

-(GLuint) lineCount {
	CC3AssertUnimplemented(@"lineCount");
	return 0;
}

-(GLuint) sourceStringCount {
	CC3ShaderSourceCodeCompilationStringCountVisitor* visitor = [CC3ShaderSourceCodeCompilationStringCountVisitor visitor];
	[self accumulateSourceCompilationStringCountWithVisitor: visitor];
	return visitor.sourceCompilationStringCount;
}

-(NSString*) sourceCodeString {
	CC3AssertUnimplemented(@"sourceCodeString");
	return nil;
}

-(NSString*) importableSourceCodeString {
	return (self.wasLoadedFromFile
				? [NSString stringWithFormat:@"#import \"%@\"\n", self.name]
				: self.sourceCodeString);
}

-(NSArray*) subsections { return nil; }

-(void) appendSourceCodeString: (NSString*) srcCode { CC3AssertUnimplemented(@"appendSourceCodeString:"); }


#pragma mark Visiting

-(void) accumulateSourceCompilationStringsWithVisitor: (CC3ShaderSourceCodeCompilationStringVisitor*) visitor {
	CC3AssertUnimplemented(@"accumulateSourceCompilationStringsWithVisitor:");
}

-(void) accumulateSourceCompilationStringCountWithVisitor: (CC3ShaderSourceCodeCompilationStringCountVisitor*) visitor {
	CC3AssertUnimplemented(@"accumulateSourceCompilationStringCountWithVisitor:");
}

-(BOOL) localizeLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor {
	GLuint lineCount = self.lineCount;
	if (visitor.lineNumber <= lineCount) {
		return YES;
	} else {
		visitor.lineNumber -= lineCount;
		[visitor addLineNumberOffset: lineCount];
		return NO;
	}
}


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
	
	MarkRezActivityStart();

	CC3ShaderSourceCodeGroup* srcGroup = [[[CC3ShaderSourceCodeGroup alloc] initWithName: name] autorelease];
	CC3ShaderSourceCode* srcSection = nil;

	GLuint lineCount = 1;			// Running count of the lines parsed
	GLuint sectionCount = 0;		// Running count of the number of compilable sections within this file.
	NSArray* srcLines = srcCodeString.terminatedLines;
	for (NSString* srcLine in srcLines) {
		if ( [self lineContainsImportDirective: srcLine] ) {
 			NSArray* importLineComponents = [srcLine componentsSeparatedByString: @"\""];
			CC3Assert(importLineComponents.count > 1, @"Shader source file %@ missing import target at line %u", name, lineCount);

			// Add the source code read since the previous import directive
			[srcGroup addSubsection: srcSection];
			srcSection = nil;

			// Add the source code from the imported file
			NSString* importFileName = [importLineComponents objectAtIndex: 1];
			[srcGroup addSubsection: [self shaderSourceCodeFromFile: importFileName]];
		} else {
			if ( !srcSection ) {
				NSString* sectionName = [name stringByAppendingFormat: @"-Section-%u", ++sectionCount];
				srcSection = [[[self.sourceCodeSubsectionClass alloc] initWithName: sectionName] autorelease];
			}
			[srcSection appendSourceCodeString: srcLine];
		}
		lineCount++;
	}
	
	// Add the source code read since the final import directive
	[srcGroup addSubsection: srcSection];
	
	// Add extracted source code group to the cache and return it.
	[self addShaderSourceCode: srcGroup];
	
	LogRez(@"Parsed GLSL source named %@ in %.3f ms", name, GetRezActivityDuration() * 1000);
	
	return srcGroup;
}

/** Returns whether the specified source code line contains an #import or #include directive. */
+(BOOL) lineContainsImportDirective: (NSString*) srcLine {
	NSString* trimmedLine = [srcLine stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	return [trimmedLine hasPrefix: @"#import"] || [trimmedLine hasPrefix: @"#include"];
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

static Class _sourceCodeSubsectionClass = nil;

+(Class) sourceCodeSubsectionClass {
	if ( !_sourceCodeSubsectionClass ) self.sourceCodeSubsectionClass = CC3ShaderSourceCodeString.class;
	return _sourceCodeSubsectionClass;
}

+(void) setSourceCodeSubsectionClass: (Class) sourceCodeSubsectionClass {
	if (sourceCodeSubsectionClass == _sourceCodeSubsectionClass) return;
	[_sourceCodeSubsectionClass release];
	_sourceCodeSubsectionClass = [sourceCodeSubsectionClass retain];
}

-(NSString*) constructorDescription {
	return [NSString stringWithFormat: @"[%@ shaderSourceCodeFromFile: @\"%@\"];", [self class], self.name];
}


#pragma mark Shader source cache

-(void) remove { [self.class removeShaderSourceCode: self]; }

static CC3Cache* _shaderSourceCodeCache = nil;

+(void) ensureCache {
	if ( !_shaderSourceCodeCache ) _shaderSourceCodeCache = [[CC3Cache weakCacheForType: @"shader source"] retain];
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
#pragma mark CC3ShaderSourceCodeString

@implementation CC3ShaderSourceCodeString

-(void) dealloc {
	[_sourceCodeString release];
	[super dealloc];
}

-(NSString*) sourceCodeString { return _sourceCodeString; }

-(GLuint) lineCount { return (GLuint)_sourceCodeString.lineCount; }

-(void) appendSourceCodeString: (NSString*) srcCode { [_sourceCodeString appendString: srcCode]; }


#pragma mark Visiting

-(void) accumulateSourceCompilationStringsWithVisitor: (CC3ShaderSourceCodeCompilationStringVisitor*) visitor {
	if ( [visitor hasAlreadyVisited: self] ) return;
	[visitor addSourceCompilationString: _sourceCodeString.UTF8String];
}

-(void) accumulateSourceCompilationStringCountWithVisitor: (CC3ShaderSourceCodeCompilationStringCountVisitor*) visitor {
	if ( [visitor hasAlreadyVisited: self] ) return;
	[visitor addSourceCompilationStringCount: 1];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) tag withName: (NSString*) name {
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_sourceCodeString = [NSMutableString new];		// retained
	}
	return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ of length %lu bytes", [super description], (unsigned long)_sourceCodeString.length];
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeLines

@implementation CC3ShaderSourceCodeLines

-(void) dealloc {
	[_sourceCodeLines release];
	[super dealloc];
}

-(NSString*) sourceCodeString {
	NSMutableString* srcCodeString = [NSMutableString stringWithCapacity: 1000];
	for (NSData* srcLine in _sourceCodeLines)
		[srcCodeString appendString: [NSString stringWithUTF8String: srcLine.bytes]];
	return srcCodeString;
}

-(GLuint) lineCount { return (GLuint)_sourceCodeLines.count; }

-(void) appendSourceCodeString: (NSString*) srcCode {
	[_sourceCodeLines addObject: [NSData dataWithBytes: srcCode.UTF8String
												length: (srcCode.length + 1)]];	// Plus null-terminator
}


#pragma mark Visiting

-(void) accumulateSourceCompilationStringsWithVisitor: (CC3ShaderSourceCodeCompilationStringVisitor*) visitor {
	if ( [visitor hasAlreadyVisited: self] ) return;
	for (NSData* srcLine in _sourceCodeLines) [visitor addSourceCompilationString: srcLine.bytes];
}

-(void) accumulateSourceCompilationStringCountWithVisitor: (CC3ShaderSourceCodeCompilationStringCountVisitor*) visitor {
	if ( [visitor hasAlreadyVisited: self] ) return;
	[visitor addSourceCompilationStringCount: (GLuint)_sourceCodeLines.count];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) tag withName: (NSString*) name {
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_sourceCodeLines = [NSMutableArray new];	// retained
	}
	return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ in %lu lines", [super description], (unsigned long)_sourceCodeLines.count];
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeGroup

@implementation CC3ShaderSourceCodeGroup

-(void) dealloc {
	[_subsections release];
	[super dealloc];
}

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
	for (CC3ShaderSourceCode* shSrc in _subsections)
		[srcCode appendString: shSrc.importableSourceCodeString];
	return srcCode;
}

-(void) appendSourceCodeString: (NSString*) srcCode {
	CC3ShaderSourceCode* sscs = [[CC3ShaderSourceCodeString alloc] init];	// release below
	[sscs appendSourceCodeString: srcCode];
	[self addSubsection: sscs];
	[sscs release];
}


#pragma mark Visiting

-(void) accumulateSourceCompilationStringsWithVisitor: (CC3ShaderSourceCodeCompilationStringVisitor*) visitor {
	if ( [visitor hasAlreadyVisited: self] ) return;
	for (CC3ShaderSourceCode* shSrc in _subsections)
		[shSrc accumulateSourceCompilationStringsWithVisitor: visitor];
}

-(void) accumulateSourceCompilationStringCountWithVisitor: (CC3ShaderSourceCodeCompilationStringCountVisitor*) visitor {
	if ( [visitor hasAlreadyVisited: self] ) return;
	for (CC3ShaderSourceCode* shSrc in _subsections)
		[shSrc accumulateSourceCompilationStringCountWithVisitor: visitor];
}

-(BOOL) localizeLineNumberWithVisitor: (CC3ShaderSourceCodeLineNumberLocalizingVisitor*) visitor {

	// Increment the line offset to compensate for the #import/include statement that is being skipped.
	if ( [visitor hasAlreadyVisited: self] ) {
		[visitor addLineNumberOffset: 1];
		return NO;
	}

	// Traverse the subsections, and return right away if the line number was resolved.
	// If the subsection did not claim to be the source of the line number, identify it as this file.
	[visitor pushLineNumberOffset: 0];
	for (CC3ShaderSourceCode* shSrc in _subsections)
		if ( [shSrc localizeLineNumberWithVisitor: visitor] ) {
			if ( !visitor.localizedSourceCode ) visitor.localizedSourceCode = self;
			return YES;
		}

	// Done with this group, so pop up to the next level for line number offset tracking,
	// and increment to cover the #import/include statement that invoked this group.
	[visitor popLineNumberOffset];
	[visitor addLineNumberOffset: 1];
	return NO;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) tag withName: (NSString*) name {
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_subsections = [NSMutableArray new];	// retained
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

-(void) dealloc {
	[_sourceCodeNamesTraversed release];
	[super dealloc];
}

-(BOOL) hasAlreadyVisited: (CC3ShaderSourceCode*) srcCode {
	NSString* ssName = srcCode.name;
	if ( !ssName || [_sourceCodeNamesTraversed containsObject: ssName] ) return YES;
	[_sourceCodeNamesTraversed addObject: ssName];
	return NO;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_sourceCodeNamesTraversed = [NSMutableSet new];		// retained
	}
	return self;
}

+(id) visitor { return [[[self alloc] init] autorelease]; }

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeCompilationStringCountVisitor

@implementation CC3ShaderSourceCodeCompilationStringCountVisitor

@synthesize sourceCompilationStringCount=_sourceCompilationStringCount;

-(void) addSourceCompilationStringCount: (GLuint) sourceStringCount {
	_sourceCompilationStringCount += sourceStringCount;
};


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_sourceCompilationStringCount = 0;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeCompilationStringVisitor

@implementation CC3ShaderSourceCodeCompilationStringVisitor

@synthesize sourceCompilationStrings=_sourceCompilationStrings;

-(void) addSourceCompilationString: (const GLchar*) sourceCompilationString {
	_sourceCompilationStrings[_sourceCompilationStringCount++] = sourceCompilationString;
}


#pragma mark Allocation and initialization

-(id) initWithCompilationStrings: (const GLchar**) sourceCompilationStrings {
	if ( (self = [super init]) ) {
		_sourceCompilationStrings = sourceCompilationStrings;
	}
	return self;
}

+(id) visitorWithCompilationStrings: (const GLchar**) sourceCompilationStrings {
	return [[[self alloc] initWithCompilationStrings: sourceCompilationStrings] autorelease];
}

@end


#pragma mark -
#pragma mark CC3ShaderSourceCodeLineNumberLocalizingVisitor

@implementation CC3ShaderSourceCodeLineNumberLocalizingVisitor

@synthesize lineNumber=_lineNumber, localizedSourceCode=_localizedSourceCode;

-(void) dealloc {
	[_localizedSourceCode release];
	[_lineNumberOffsets release];
	[super dealloc];
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
		_lineNumberOffsets = [NSMutableArray new];		// retained
		[self pushLineNumberOffset: 0];					// Init stack with a base value
	}
	return self;
}

+(id) visitorWithLineNumber: (GLuint) lineNumber {
	return [[[self alloc] initWithLineNumber: lineNumber] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:%u", _localizedSourceCode.name, _lineNumber + self.lineNumberOffset];
}

@end


#pragma mark -
#pragma mark CC3ShaderPrewarmer

@implementation CC3ShaderPrewarmer

@synthesize prewarmingSurface=_prewarmingSurface;
@synthesize prewarmingMeshNode=_prewarmingMeshNode;
@synthesize drawingVisitor=_drawingVisitor;

-(void) dealloc {
	[_prewarmingSurface release];
	[_prewarmingMeshNode release];
	[_drawingVisitor release];
	[super dealloc];
}

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
		
		// Populate the mesh as a single triangular face of zero dimensions
		CC3Face triangle = CC3FaceMake(kCC3VectorZero, kCC3VectorZero, kCC3VectorZero);
		ccTex2F texCoords[3] = { {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0} };				// unused
		[_prewarmingMeshNode populateAsTriangle: triangle withTexCoords: texCoords andTessellation: 1];

		_prewarmingMeshNode.shaderContext.shouldEnforceCustomOverrides = NO;
		_prewarmingMeshNode.shaderContext.shouldEnforceVertexAttributes = NO;
	}
	return _prewarmingMeshNode;
}

-(CC3NodeDrawingVisitor*) drawingVisitor {
	if ( !_drawingVisitor ) self.drawingVisitor = [CC3NodeDrawingVisitor visitor];
	return _drawingVisitor;
}

-(void) prewarmShaderProgram: (CC3ShaderProgram*) program {
	LogRez(@"Prewarming %@", program);
	CC3MeshNode* pwNode = self.prewarmingMeshNode;
	id<CC3RenderSurface> pwSurface = self.prewarmingSurface;
	CC3NodeDrawingVisitor* pwVisitor = self.drawingVisitor;

	pwNode.shaderProgram = program;
	pwVisitor.renderSurface = pwSurface;
	[pwSurface activate];
	[pwVisitor visit: pwNode];
	
	// Release visitor state so it won't interfere with later deallocations
	pwVisitor.renderSurface = nil;
	[pwVisitor clearGL];
	
	pwNode.shaderProgram = nil;	// Release the program immediately, since it is only used once.
	[program resetGLState];		// Reset GL state. Needed if pre-warming in background context...
								// ...since state is different between contexts.
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_prewarmingSurface = nil;
		_prewarmingMeshNode = nil;
		_drawingVisitor = nil;
	}
	return self;
}

+(id) prewarmerWithName: (NSString*) name {
	return [[[self alloc] initWithName: name] autorelease];
}

@end

