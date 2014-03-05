/*
 * CC3PFXResource.mm
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3PFXResource.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}
#import "CC3PFXResource.h"
#import "CC3PVRTPFXParser.h"
#import "CC3PVRShamanShaderSemantics.h"
#import "CC3PODResource.h"
#import "CC3ShaderMatcher.h"


#pragma mark -
#pragma mark CC3PFXResource

@implementation CC3PFXResource

@synthesize semanticDelegateClass=_semanticDelegateClass;

-(void) dealloc {
	[_texturesByName release];
	[_effectsByName release];
	[_semanticDelegateClass release];
	
	[super dealloc];
}

-(CC3PFXEffect*) getEffectNamed: (NSString*) effectName {
	if ( !effectName ) return nil;
	
	CC3PFXEffect* pfxEffect = [_effectsByName objectForKey: effectName];
	if ( !pfxEffect ) LogError(@"%@ could not find PFX effect named %@."
							   @" Mesh nodes using this PFX effect will revert to default shaders and textures.",
							   self, effectName);
	return pfxEffect;
}

+(CC3PFXEffect*) getEffectNamed: (NSString*) effectName inPFXResourceNamed: (NSString*) rezName {
	if ( !(effectName && rezName) ) return nil;
	
	CC3PFXResource* pfxRez = (CC3PFXResource*)[self getResourceNamed: rezName];
	if ( !pfxRez ) LogError(@"%@ could not find cached PFX resource named %@ to apply effect named %@."
							@" Mesh nodes using this PFX effect will revert to default shaders and textures.",
							self, rezName, effectName);
	return [pfxRez getEffectNamed: effectName];
}

+(CC3PFXEffect*) getEffectNamed: (NSString*) effectName inPFXResourceFile: (NSString*) aFilePath {
	if ( !(effectName && aFilePath) ) return nil;
	
	CC3PFXResource* pfxRez = (CC3PFXResource*)[self resourceFromFile: aFilePath];
	if ( !pfxRez ) LogError(@"%@ could not load PFX resource file %@ to apply effect named %@."
							@" Mesh nodes using this PFX effect will revert to default shaders and textures.",
							self, aFilePath, effectName);
	return [pfxRez getEffectNamed: effectName];
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_effectsByName = [NSMutableDictionary new];		// retained
		_texturesByName = [NSMutableDictionary new];	// retained
		_semanticDelegateClass = [self.class.defaultSemanticDelegateClass retain];		// retained
	}
	return self;
}

/** Load the file, and if successful build this resource from the contents. */
-(BOOL) processFile: (NSString*) anAbsoluteFilePath {

	// Split the path into directory and file names and set the PVR read path to the directory and
	// pass the unqualified file name to the parser. This allows the parser to locate any additional
	// files that might be read as part of the parsing. For PFX, this will include any shader files
	// referenced by the PFX file.
	NSString* fileName = anAbsoluteFilePath.lastPathComponent;
	NSString* dirName = anAbsoluteFilePath.stringByDeletingLastPathComponent;

	CPVRTResourceFile::SetReadPath([dirName stringByAppendingString: @"/"].UTF8String);

	CPVRTString	error;
	CPVRTPFXParser* pfxParser = new CPVRTPFXParser();
	BOOL wasLoaded = (pfxParser->ParseFromFile(fileName.UTF8String, &error) == PVR_SUCCESS);
	if (wasLoaded)
		[self buildFromPFXParser: pfxParser];
	else
		LogError(@"Could not load %@ because %@", anAbsoluteFilePath.lastPathComponent,
				 [NSString stringWithUTF8String: error.c_str()]);

	delete pfxParser;

	return wasLoaded;
}

/** Build this instance from the contents of the resource. */
-(void) buildFromPFXParser: (CPVRTPFXParser*) pfxParser  {
	[self buildTexturesFromPFXParser: pfxParser];
	[self buildEffectsFromPFXParser: pfxParser];
	[self buildRenderPassesFromPFXParser: pfxParser];
}

/** Extracts the texture definitions and loads them from files. */
-(void) buildTexturesFromPFXParser: (CPVRTPFXParser*) pfxParser {
	GLuint texCnt = pfxParser->GetNumberTextures();
	for (GLuint texIdx = 0; texIdx < texCnt; texIdx++) {
		const SPVRTPFXParserTexture* pfxTex = pfxParser->GetTexture(texIdx);
		LogRez(@"Adding texture %@", NSStringFromSPVRTPFXParserTexture((SPVRTPFXParserTexture*)pfxTex));

		CC3Assert(!pfxTex->bRenderToTexture, @"%@ rendering to a texture is not supported", self);
		
		// Load texture and set texture parameters
		NSString* texName = [NSString stringWithUTF8String: pfxTex->Name.c_str()];
		NSString* texFile = [NSString stringWithUTF8String: pfxTex->FileName.c_str()];
		CC3Texture* tex = [CC3Texture textureFromFile: texFile];
		tex.horizontalWrappingFunction = GLTextureWrapFromETextureWrap(pfxTex->nWrapS);
		tex.verticalWrappingFunction = GLTextureWrapFromETextureWrap(pfxTex->nWrapT);
		tex.minifyingFunction = GLMinifyingFunctionFromMinAndMipETextureFilters(pfxTex->nMin, pfxTex->nMIP);
		tex.magnifyingFunction = GLMagnifyingFunctionFromETextureFilter(pfxTex->nMag);
		if (tex)
			[_texturesByName setObject: tex forKey: texName];	// Add to texture dictionary
		else
			LogError(@"%@ cannot load texture named %@ from file %@", self, texName, texFile);
	}
}

/** Builds the effects from the shaders and textures defined in this resource. */
-(void) buildEffectsFromPFXParser: (CPVRTPFXParser*) pfxParser {
	GLuint eCnt = pfxParser->GetNumberEffects();
	for (GLuint eIdx = 0; eIdx < eCnt; eIdx++) {
		const SPVRTPFXParserEffect& pfxEffect = pfxParser->GetEffect(eIdx);
		CC3PFXEffect* effect = [[CC3PFXEffect alloc] initFromSPVRTPFXParserEffect: (SPVRTPFXParserEffect*)&pfxEffect
																	fromPFXParser: pfxParser
																	inPFXResource: self];
		[_effectsByName setObject: effect forKey: effect.name];
		[effect release];
	}
}

/** Returns the texture that was assigned the specified name in the PFX resource file. */
-(CC3Texture*) getTextureNamed: (NSString*) texName { return [_texturesByName objectForKey: texName]; }

/**
 * Builds the rendering passes.
 *
 * Multi-pass rendering is not currently supported.
 * For now, just log the render passes described by this PFX resource.
 */
-(void) buildRenderPassesFromPFXParser: (CPVRTPFXParser*) pfxParser {
	GLuint rpCnt = pfxParser->GetNumberRenderPasses();
	for (GLuint rpIdx = 0; rpIdx < rpCnt; rpIdx++) {
		const SPVRTPFXRenderPass rendPass = pfxParser->GetRenderPass(rpIdx);
		LogRez(@"Describing render pass %@", NSStringFromSPVRTPFXRenderPass((SPVRTPFXRenderPass*)&rendPass));
	}
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"%@", self];
	[desc appendFormat: @" containing %lu effects", (unsigned long)_effectsByName.count];
	[desc appendFormat: @", %lu textures", (unsigned long)_texturesByName.count];
	return desc;
}

static Class _defaultSemanticDelegateClass = nil;

+(Class) defaultSemanticDelegateClass {
	if ( !_defaultSemanticDelegateClass)
		self.defaultSemanticDelegateClass = [CC3PVRShamanShaderSemantics class];
	return _defaultSemanticDelegateClass;
}

+(void) setDefaultSemanticDelegateClass: (Class) aClass {
	[_defaultSemanticDelegateClass release];
	_defaultSemanticDelegateClass = [aClass retain];
}

@end


#pragma mark -
#pragma mark CC3PFXEffect

@implementation CC3PFXEffect

@synthesize name=_name, shaderProgram=_shaderProgram, textures=_textures, variables=_variables;

-(void) dealloc {
	[_name release];
	[_shaderProgram release];
	[_textures release];
	[_variables release];
	
	[super dealloc];
}


#pragma mark Populating materials

// Set the GL program into the mesh node
-(void) populateMeshNode: (CC3MeshNode*) meshNode { meshNode.shaderProgram = _shaderProgram; }

// Set each texture into its associated texture unit
// After parsing, the ordering might not be consecutive, so look each up by texture unit index
-(void) populateMaterial: (CC3Material*) material {
	NSUInteger tuCnt = _textures.count;
	for (GLuint tuIdx = 0; tuIdx < tuCnt; tuIdx++) {
		CC3PFXEffectTexture* pfxTex = [self getEffectTextureForTextureUnit: tuIdx];
		if (pfxTex)
			[material setTexture: pfxTex.texture forTextureUnit: tuIdx];
		else
			LogRez(@"%@ contains no texture for texture unit %u", self, tuIdx);
	}
}

/**
 * Returns the effect texture to be applied to the specified texture unit,
 * or nil if no texture is defined for that texture unit.
 */
-(CC3PFXEffectTexture*) getEffectTextureForTextureUnit: (GLuint) tuIdx {
	for (CC3PFXEffectTexture* effectTex in _textures)
		if (effectTex.textureUnitIndex == tuIdx) return effectTex;
	return nil;
}


#pragma mark Allocation and initialization

-(id) initFromSPVRTPFXParserEffect: (PFXClassPtr) pSPVRTPFXParserEffect
					 fromPFXParser: (PFXClassPtr) pCPVRTPFXParser
					 inPFXResource: (CC3PFXResource*) pfxRez {
	LogRez(@"Creating %@ from: %@", [self class], NSStringFromSPVRTPFXParserEffect(pSPVRTPFXParserEffect));
	if ( (self = [self init]) ) {
		CPVRTPFXParser* pfxParser = (CPVRTPFXParser*)pCPVRTPFXParser;
		SPVRTPFXParserEffect* pfxEffect = (SPVRTPFXParserEffect*)pSPVRTPFXParserEffect;
		_name = [[NSString alloc] initWithUTF8String: pfxEffect->Name.c_str()];		// retained
		[self initTexturesForPFXEffect: pfxEffect fromPFXParser: pfxParser inPFXResource: pfxRez];
		[self initVariablesForPFXEffect: pfxEffect fromPFXParser: pfxParser inPFXResource: pfxRez];
		[self initShaderProgramForPFXEffect: pfxEffect fromPFXParser: pfxParser inPFXResource: pfxRez];
	}
	return self;
}

/** Initializes the effect textures in the textures property.  */
-(void) initTexturesForPFXEffect: (SPVRTPFXParserEffect*) pfxEffect
				   fromPFXParser: (CPVRTPFXParser*) pfxParser
				   inPFXResource: (CC3PFXResource*) pfxRez  {
	_textures = [NSMutableArray new];	// retained
	
	CPVRTArray<SPVRTPFXParserEffectTexture> effectTextures = pfxEffect->Textures;
	GLuint texCount = effectTextures.GetSize();
	for(GLuint texIdx = 0; texIdx < texCount; texIdx++) {
		// Extract the texture and texture unit index from the SPVRTPFXParserEffectTexture
		NSString* texName = [NSString stringWithUTF8String: effectTextures[texIdx].Name.c_str()];
		GLuint tuIdx = effectTextures[texIdx].nNumber;
		
		// Retrieve the texture from the PFX resource and add a CC3PFXEffectTexture
		// linking the texture to the texture unit
		CC3Texture* tex = [pfxRez getTextureNamed: texName];
		if (tex) {
			CC3PFXEffectTexture* effectTex = [CC3PFXEffectTexture new];
			effectTex.texture = tex;
			effectTex.name = texName;
			effectTex.textureUnitIndex = tuIdx;
			[_textures addObject: effectTex];
			[effectTex release];
		} else {
			LogError(@"%@ could not find texture named %@ in %@", self, texName, pfxRez);
		}
	}
}

/** Initializes the variables configurations in the variables property. */
-(void) initVariablesForPFXEffect: (SPVRTPFXParserEffect*) pfxEffect
					fromPFXParser: (CPVRTPFXParser*) pfxParser
					inPFXResource: (CC3PFXResource*) pfxRez  {
	_variables = [NSMutableArray new];		// retained
	[self addVariablesFrom: pfxEffect->Attributes];
	[self addVariablesFrom: pfxEffect->Uniforms];
}

/** Adds a variable configuration for each semantic spec in the specified array. */
-(void) addVariablesFrom: (CPVRTArray<SPVRTPFXParserSemantic>) pfxVariables {
	GLuint varCount = pfxVariables.GetSize();
	for(GLuint varIdx = 0; varIdx < varCount; varIdx++) {
		CC3PFXGLSLVariableConfiguration* varConfig = [CC3PFXGLSLVariableConfiguration new];
		varConfig.name = [NSString stringWithUTF8String: pfxVariables[varIdx].pszName];
		varConfig.pfxSemanticName = [NSString stringWithUTF8String: pfxVariables[varIdx].pszValue];
		varConfig.semanticIndex = pfxVariables[varIdx].nIdx;
		[_variables addObject: varConfig];
		[varConfig release];
	}
}

/** Initializes the CC3ShaderProgram built from the shaders defined for this effect. */
-(void) initShaderProgramForPFXEffect: (SPVRTPFXParserEffect*) pfxEffect
						fromPFXParser: (CPVRTPFXParser*) pfxParser
						inPFXResource: (CC3PFXResource*) pfxRez {
#if CC3_GLSL
	// Retrieve or create the vertex shader
	SPVRTPFXParserShader* pfxVtxShader = [self getPFXVertexShaderForPFXEffect: pfxEffect
																fromPFXParser: pfxParser];
	CC3VertexShader* vtxShader = [CC3VertexShader shaderFromPFXShader: pfxVtxShader
														inPFXResource: pfxRez];

	// Retrieve or create the fragment shader
	SPVRTPFXParserShader* pfxFragShader = [self getPFXFragmentShaderForPFXEffect: pfxEffect
																   fromPFXParser: pfxParser];
	CC3FragmentShader* fragShader = [CC3FragmentShader shaderFromPFXShader: pfxFragShader
															 inPFXResource: pfxRez];
	
	CC3PFXShaderSemantics* semanticDelegate = [self semanticDelegateFrom: pfxEffect
															  fromPFXParser: pfxParser
															  inPFXResource: pfxRez];

	_shaderProgram = [[self.shaderProgramClass programWithSemanticDelegate: semanticDelegate
														 withVertexShader: vtxShader
														andFragmentShader: fragShader] retain];
#endif	// CC3_GLSL
}

/**
 * Template property to determine the class of shader program to instantiate.
 * The returned class must be a subclass of CC3ShaderProgram.
 */
-(Class) shaderProgramClass { return [CC3ShaderProgram class]; }

/** Template method to create, populate, and return the semantic delegate to use in the GL program. */
-(CC3PFXShaderSemantics*) semanticDelegateFrom: (SPVRTPFXParserEffect*) pfxEffect
								 fromPFXParser: (CPVRTPFXParser*) pfxParser
								 inPFXResource: (CC3PFXResource*) pfxRez {
	CC3PFXShaderSemantics* semanticDelegate = [pfxRez.semanticDelegateClass new];
	[semanticDelegate populateWithVariableNameMappingsFromPFXEffect: self];
	return [semanticDelegate autorelease];
}

/** Returns the PFX vertex shader that was assigned the specified name in the PFX resource file. */
-(SPVRTPFXParserShader*) getPFXVertexShaderForPFXEffect: (SPVRTPFXParserEffect*) pfxEffect
										  fromPFXParser: (CPVRTPFXParser*) pfxParser {
	const char* sName = pfxEffect->VertexShaderName.c_str();
	GLuint sCnt = pfxParser->GetNumberVertexShaders();
	for (GLuint sIdx = 0; sIdx < sCnt; sIdx++) {
		const SPVRTPFXParserShader& pfxShader = pfxParser->GetVertexShader(sIdx);
		if (strcmp(pfxShader.Name.c_str(), sName) == 0) return (SPVRTPFXParserShader*)&pfxShader;
	}
	return NULL;
}

/** Returns the PFX fragment shader that was assigned the specified name in the PFX resource file. */
-(SPVRTPFXParserShader*) getPFXFragmentShaderForPFXEffect: (SPVRTPFXParserEffect*) pfxEffect
											fromPFXParser: (CPVRTPFXParser*) pfxParser  {
	const char* sName = pfxEffect->FragmentShaderName.c_str();
	GLuint sCnt = pfxParser->GetNumberFragmentShaders();
	for (GLuint sIdx = 0; sIdx < sCnt; sIdx++) {
		const SPVRTPFXParserShader& pfxShader = pfxParser->GetFragmentShader(sIdx);
		if (strcmp(pfxShader.Name.c_str(), sName) == 0) return (SPVRTPFXParserShader*)&pfxShader;
	}
	return NULL;
}

/** Returns the shader code for the specified shader. */
-(GLchar*) getShaderCode: (SPVRTPFXParserShader*) pfxShader { return pfxShader->pszGLSLcode; }

/** Returns a string description of this effect. */
-(NSString*) description { return [NSString stringWithFormat: @"%@ named %@", [self class], _name]; }

@end


#pragma mark -
#pragma mark CC3PFXEffectTexture

@implementation CC3PFXEffectTexture

@synthesize texture=_texture, name=_name, textureUnitIndex=_textureUnitIndex;

-(void) dealloc {
	[_texture release];
	[_name release];
	[super dealloc];
}

@end


#pragma mark -
#pragma mark CC3PFXGLSLVariableConfiguration

@implementation CC3PFXGLSLVariableConfiguration

@synthesize pfxSemanticName=_pfxSemanticName;

-(void) dealloc {
	[_pfxSemanticName release];
	[super dealloc];
}

-(id) init {
	if ( (self = [super init]) ) {
		_pfxSemanticName = nil;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3PFXShaderSemantics

@implementation CC3PFXShaderSemantics

/** Overridden to allow default naming semantics to be combined with PFX-defined semantics. */
-(BOOL) configureVariable: (CC3GLSLVariable*) variable {
	return ([super configureVariable: variable] ||
			[CC3ShaderProgram.shaderMatcher.semanticDelegate configureVariable: variable]);
}

-(void) populateWithVariableNameMappingsFromPFXEffect: (CC3PFXEffect*) pfxEffect {
	for (CC3PFXGLSLVariableConfiguration* pfxVarConfig in pfxEffect.variables) {
		[self resolveSemanticForVariableConfiguration: pfxVarConfig];
		[self addVariableConfiguration: pfxVarConfig];
	}
}

-(BOOL) resolveSemanticForVariableConfiguration: (CC3PFXGLSLVariableConfiguration*) pfxVarConfig {
	if (pfxVarConfig.semantic != kCC3SemanticNone) return YES;		// Only do it once!
	
	GLenum semantic = [self semanticForPFXSemanticName: pfxVarConfig.pfxSemanticName];
	if (semantic == kCC3SemanticNone) return NO;
	pfxVarConfig.semantic = semantic;
	return YES;
}

-(GLenum) semanticForPFXSemanticName: (NSString*) semanticName { return kCC3SemanticNone; }

@end


#pragma mark -
#pragma mark CC3Material extension to support PFX effects

@implementation CC3Material (PFXEffects)

-(void) applyEffectNamed: (NSString*) effectName inPFXResourceNamed: (NSString*) rezName {
	CC3PFXEffect* pfxEffect = [CC3PFXResource getEffectNamed: effectName inPFXResourceNamed: rezName];
	CC3Assert(pfxEffect, @"%@ could not apply effect named %@ from PFX resource named %@."
			  @"See previously logged error.", self, effectName, rezName);

	[pfxEffect populateMaterial: self];
}

-(void) applyEffectNamed: (NSString*) effectName inPFXResourceFile: (NSString*) filePath {
	CC3PFXEffect* pfxEffect = [CC3PFXResource getEffectNamed: effectName inPFXResourceFile: filePath];
	CC3Assert(pfxEffect, @"%@ could not apply effect named %@ from PFX resource file %@."
			  @"See previously logged error.", self, effectName, filePath);
	
	[pfxEffect populateMaterial: self];
}

@end


#pragma mark -
#pragma mark CC3Node extension to support PFX effects

@implementation CC3Node (PFXEffects)

-(void) applyEffectNamed: (NSString*) effectName inPFXResourceNamed: (NSString*) rezName {
	for (CC3Node* child in _children) [child applyEffectNamed: effectName inPFXResourceNamed: rezName];
}

-(void) applyEffectNamed: (NSString*) effectName inPFXResourceFile: (NSString*) aFilePath {
	for (CC3Node* child in _children) [child applyEffectNamed: effectName inPFXResourceFile: aFilePath];
}

@end


#pragma mark -
#pragma mark CC3MeshNode extension to support PFX effects

@interface CC3MeshNode (TemplateMethods)
-(void) alignTextureUnits;
@end

@implementation CC3MeshNode (PFXEffects)

-(void) applyEffectNamed: (NSString*) effectName inPFXResourceNamed: (NSString*) rezName {
	CC3PFXEffect* pfxEffect = [CC3PFXResource getEffectNamed: effectName inPFXResourceNamed: rezName];
	CC3Assert(pfxEffect, @"%@ could not apply effect named %@ from PFX resource named %@."
			  @"See previously logged error.", self, effectName, rezName);

	[pfxEffect populateMeshNode: self];
	[pfxEffect populateMaterial: self.ensureMaterial];
	[self alignTextureUnits];
	[super applyEffectNamed: effectName inPFXResourceNamed: rezName];
}

-(void) applyEffectNamed: (NSString*) effectName inPFXResourceFile: (NSString*) filePath {
	CC3PFXEffect* pfxEffect = [CC3PFXResource getEffectNamed: effectName inPFXResourceFile: filePath];
	CC3Assert(pfxEffect, @"%@ could not apply effect named %@ from PFX resource file %@."
			  @"See previously logged error.", self, effectName, filePath);
	
	[pfxEffect populateMeshNode: self];
	[pfxEffect populateMaterial: self.ensureMaterial];
	[self alignTextureUnits];
	[super applyEffectNamed: effectName inPFXResourceFile: filePath];
}

@end


#pragma mark -
#pragma mark CC3Shader extension to support PFX effects

@implementation CC3Shader (PFXEffects)

+(id) shaderFromPFXShader: (PFXClassPtr) pSPVRTPFXParserShader inPFXResource: (CC3PFXResource*) pfxRez {
	SPVRTPFXParserShader* pfxShader = (SPVRTPFXParserShader*)pSPVRTPFXParserShader;
	if (pfxShader->bUseFileName) {
		// Load the shader from the file
		NSString* shaderFilePath = [NSString stringWithUTF8String: pfxShader->pszGLSLfile];
		return [self shaderFromSourceCodeFile: shaderFilePath];
	} else {
		// Derive the shader name as a combination of the PFX resource name and the local shader name.
		NSString* shaderName = [NSString stringWithFormat: @"%@-%@", pfxRez.name,
								[NSString stringWithUTF8String: pfxShader->Name.c_str()]];
		NSString* shSrcStr = [NSString stringWithUTF8String: pfxShader->pszGLSLcode];
		return [self shaderWithName: shaderName fromSourceCode: shSrcStr];
	}
}

@end

