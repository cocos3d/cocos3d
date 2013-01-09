/*
 * CC3PFXResource.mm
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3OpenGLESEngine.h"


@implementation CC3PFXResource

-(void) dealloc {
	[_effectsByName release];
	[_texturesByName release];
	[super dealloc];
}


#pragma mark Populating materials

-(void) populateMaterial: (CC3Material*) material fromEffectNamed: (NSString*) effectName {
	CC3PFXEffect* effect = [_effectsByName objectForKey: effectName];
	if (effect) {
		[effect populateMaterial: material];
		return;
	}
	LogError(@"%@ could not find PFX effect named %@ to apply to %@. Reverting to default shaders.",
			 self, effectName, material);
}

+(void) populateMaterial: (CC3Material*) material
		 fromEffectNamed: (NSString*) effectName
	  inPFXResourceNamed: (NSString*) rezName {
	CC3PFXResource* pfxRez = (CC3PFXResource*)[self getResourceNamed: rezName];
	if (pfxRez) {
		[pfxRez populateMaterial: material fromEffectNamed: effectName];
		return;
	}
	LogError(@"%@ could not find cached PFX resource named %@ to apply to %@. Reverting to default shaders.",
			 self, rezName, material);
}

+(void) populateMaterial: (CC3Material*) material
		 fromEffectNamed: (NSString*) effectName
	   inPFXResourceFile: (NSString*) aFilePath {
	CC3PFXResource* pfxRez = (CC3PFXResource*)[self resourceFromFile: aFilePath];
	if (pfxRez) {
		[pfxRez populateMaterial: material fromEffectNamed: effectName];
		return;
	}
	LogError(@"%@ could not load PFX resource file %@ to apply to %@. Reverting to default shaders.",
			 self, aFilePath, material);
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_effectsByName = [NSMutableDictionary new];		// retained
		_texturesByName = [NSMutableDictionary new];	// retained
	}
	return self;
}

/** Load the file, and if successful build this resource from the contents. */
-(BOOL) processFile: (NSString*) anAbsoluteFilePath {
	CPVRTString	error;
	CPVRTPFXParser* pfxParser = new CPVRTPFXParser();

	_wasLoaded = (pfxParser->ParseFromFile([anAbsoluteFilePath cStringUsingEncoding: NSUTF8StringEncoding], &error) == PVR_SUCCESS);
	if (_wasLoaded) [self buildFromPFXParser: pfxParser];

	delete pfxParser;

	return _wasLoaded;
}

/** Build this instance from the contents of the resource. */
-(void) buildFromPFXParser: (CPVRTPFXParser*) pfxParser  {
	[self buildTexturesFromPFXParser: pfxParser];
	[self buildEffectsFromPFXParser: pfxParser];
	[self buildRenderPassesFromPFXParser: pfxParser];
}

/** Extracts the texture definitions and loads them from files. */
-(void) buildTexturesFromPFXParser: (CPVRTPFXParser*) pfxParser {
	NSUInteger texCnt = pfxParser->GetNumberTextures();
	for (NSUInteger texIdx = 0; texIdx < texCnt; texIdx++) {
		const SPVRTPFXParserTexture* pfxTex = pfxParser->GetTexture(texIdx);
		LogRez(@"Adding texture %@", NSStringFromSPVRTPFXParserTexture((SPVRTPFXParserTexture*)pfxTex));

		NSAssert1(!pfxTex->bRenderToTexture, @"%@ rendering to a texture is not supported", self);
		
		// Load texture
		NSString* texName = [NSString stringWithUTF8String: pfxTex->Name.c_str()];
		NSString* texFile = [NSString stringWithUTF8String: pfxTex->FileName.c_str()];
		CC3Texture* tex = [CC3Texture textureWithName: texName fromFile: texFile];
		NSAssert3(tex, @"%@ cannot load texture named %@ from file %@", self, texName, texFile);
		
		// Set texture parameters
		tex.horizontalWrappingFunction = GLTextureWrapFromETextureWrap(pfxTex->nWrapS);
		tex.verticalWrappingFunction = GLTextureWrapFromETextureWrap(pfxTex->nWrapT);
		tex.minifyingFunction = GLMinifyingFunctionFromMinAndMipETextureFilters(pfxTex->nMin, pfxTex->nMIP);
		tex.magnifyingFunction = GLMagnifyingFunctionFromETextureFilter(pfxTex->nMag);
		
		[_texturesByName setObject: tex forKey: texName];	// Add to texture dictionary
	}
}

/** Builds the effects from the shaders and textures defined in this resource. */
-(void) buildEffectsFromPFXParser: (CPVRTPFXParser*) pfxParser {
	NSUInteger eCnt = pfxParser->GetNumberEffects();
	for (NSUInteger eIdx = 0; eIdx < eCnt; eIdx++) {
		const SPVRTPFXParserEffect& pfxEffect = pfxParser->GetEffect(eIdx);
		CC3PFXEffect* effect = [[CC3PFXEffect alloc] initFromSPVRTPFXParserEffect: (SPVRTPFXParserEffect*)&pfxEffect
																	fromPFXParser: pfxParser
																	inPFXResource: self];
		[_effectsByName setObject: effect forKey: effect.name];
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
	NSUInteger rpCnt = pfxParser->GetNumberRenderPasses();
	for (NSUInteger rpIdx = 0; rpIdx < rpCnt; rpIdx++) {
		const SPVRTPFXRenderPass rendPass = pfxParser->GetRenderPass(rpIdx);
		LogRez(@"Describing render pass %@", NSStringFromSPVRTPFXRenderPass((SPVRTPFXRenderPass*)&rendPass));
	}
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"%@", self];
	[desc appendFormat: @" containing %u effects", _effectsByName.count];
	[desc appendFormat: @", %u textures", _texturesByName.count];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3PFXEffect

@implementation CC3PFXEffect

@synthesize name=_name, glProgram=_glProgram, textures=_textures;

-(void) dealloc {
	[_name release];
	[_glProgram release];
	[_textures release];
	[super dealloc];
}


#pragma mark Populating materials

-(void) populateMaterial: (CC3Material*) material {

	// Set the GL program into a program context with the material
	if (_glProgram) material.shaderContext = [CC3GLProgramContext contextForProgram: _glProgram];

	// Set each texture into its associated texture unit
	NSUInteger texCnt = _textures.count;
	for (NSUInteger texIdx = 0; texIdx < texCnt; texIdx++) {
		CC3PFXEffectTexture* effectTex = [_textures objectAtIndex: texIdx];
		[material setTexture: effectTex.texture
			  forTextureUnit: effectTex.textureUnitIndex];
	}
}


#pragma mark Allocation and initialization

-(id) initFromSPVRTPFXParserEffect: (PFXClassPtr) pSPVRTPFXParserEffect
					 fromPFXParser: (PFXClassPtr) pCPVRTPFXParser
					 inPFXResource: (CC3PFXResource*) pfxRez {
	LogRez(@"Creating %@ from: %@", [self class], NSStringFromSPVRTPFXParserEffect(pSPVRTPFXParserEffect));
	if ( (self = [self init]) ) {
		CPVRTPFXParser* pfxParser = (CPVRTPFXParser*)pCPVRTPFXParser;
		SPVRTPFXParserEffect* pfxEffect = (SPVRTPFXParserEffect*)pSPVRTPFXParserEffect;
		_name = [[NSString stringWithUTF8String: pfxEffect->Name.c_str()] retain];	// retained
		[self initTexturesFrom: pfxEffect fromPFXParser: pfxParser inPFXResource: pfxRez];
		[self initGLProgramFrom: pfxEffect fromPFXParser: pfxParser inPFXResource: pfxRez];
	}
	return self;
}

-(void) initTexturesFrom: (SPVRTPFXParserEffect*) pfxEffect
		   fromPFXParser: (CPVRTPFXParser*) pfxParser
		   inPFXResource: (CC3PFXResource*) pfxRez  {
	_textures = [CCArray new];	// retained
	
	CPVRTArray<SPVRTPFXParserEffectTexture> effectTextures = pfxEffect->Textures;
	NSUInteger texCount = effectTextures.GetSize();
	for(NSUInteger texIdx = 0; texIdx < texCount; texIdx++) {
		// Extract the texture and texture unit index from the SPVRTPFXParserEffectTexture
		NSString* texName = [NSString stringWithUTF8String: effectTextures[texIdx].Name.c_str()];
		NSUInteger tuIdx = effectTextures[texIdx].nNumber;
		
		// Retrieve the texture from the PFX resource
		CC3Texture* tex = [pfxRez getTextureNamed: texName];
		NSAssert2(tex, @"Could not find texture named %@ in %@", texName, pfxRez);
		
		// Add a CC3PFXEffectTexture linking the texture to the texture unit
		CC3PFXEffectTexture* effectTex = [CC3PFXEffectTexture new];
		effectTex.texture = tex;
		effectTex.textureUnitIndex = tuIdx;
		[_textures addObject: effectTex];
		[effectTex release];
	}
}

-(void) initGLProgramFrom: (SPVRTPFXParserEffect*) pfxEffect
			fromPFXParser: (CPVRTPFXParser*) pfxParser
			inPFXResource: (CC3PFXResource*) pfxRez {
	SPVRTPFXParserShader* vShader = [self getVertexShaderNamed: pfxEffect->VertexShaderName.c_str()
												 fromPFXParser: pfxParser];
	SPVRTPFXParserShader* fShader = [self getFragmentShaderNamed: pfxEffect->FragmentShaderName.c_str()
												   fromPFXParser: pfxParser];
	NSString* progName = [self getProgramNameFromVertexShader: vShader andFragmentShader: fShader];
	
	// Fetch and return program from cache if it has already been loaded
	CC3OpenGLESShaders* glesShaders = CC3OpenGLESEngine.engine.shaders;
	_glProgram = [[glesShaders getProgramNamed: progName] retain];		// retained
	if (_glProgram) {
		LogRez(@"Attached cached GL program named %@", progName);
		return;
	}
	
	LogRez(@"Attaching GL program named %@ compiled from\n\tvertex shader %@\n\tfragment shader %@",
		   progName, NSStringFromSPVRTPFXParserShader(vShader), NSStringFromSPVRTPFXParserShader(fShader));

	// Compile, link and cache the program
	_glProgram = [[CC3GLProgram alloc] initWithName: progName
							  fromVertexShaderBytes: [self getShaderCode: vShader]
							 andFragmentShaderBytes: [self getShaderCode: fShader]];	// retained
	_glProgram.semanticDelegate = [CC3GLProgramSemanticsDelegateByVarNames sharedDefaultDelegate];
	[_glProgram link];
	[glesShaders addProgram: _glProgram];		// Add the new program to the cache
}

/** Returns the vertex shader that was assigned the specified name in the PFX resource file. */
-(SPVRTPFXParserShader*) getVertexShaderNamed: (const char*) cName fromPFXParser: (CPVRTPFXParser*) pfxParser {
	NSUInteger sCnt = pfxParser->GetNumberVertexShaders();
	for (NSUInteger sIdx = 0; sIdx < sCnt; sIdx++) {
		const SPVRTPFXParserShader& pfxShader = pfxParser->GetVertexShader(sIdx);
		if (strcmp(pfxShader.Name.c_str(), cName) == 0) return (SPVRTPFXParserShader*)&pfxShader;
	}
	return NULL;
}

/** Returns the fragment shader that was assigned the specified name in the PFX resource file. */
-(SPVRTPFXParserShader*) getFragmentShaderNamed: (const char*) cName fromPFXParser: (CPVRTPFXParser*) pfxParser  {
	NSUInteger sCnt = pfxParser->GetNumberFragmentShaders();
	for (NSUInteger sIdx = 0; sIdx < sCnt; sIdx++) {
		const SPVRTPFXParserShader& pfxShader = pfxParser->GetFragmentShader(sIdx);
		if (strcmp(pfxShader.Name.c_str(), cName) == 0) return (SPVRTPFXParserShader*)&pfxShader;
	}
	return NULL;
}

/** Returns a program name as a combination of the identifier keys from the specified vertex and fragment shaders. */
-(NSString*) getProgramNameFromVertexShader: (SPVRTPFXParserShader*) vShader
						  andFragmentShader: (SPVRTPFXParserShader*) fShader  {
	return [NSString stringWithFormat: @"%@-%@", [self getShaderKey: vShader], [self getShaderKey: fShader]];
}

/** 
 * Returns a unique identifier key for the specified shader. For a file-based shader, this will be just
 * the file name. For embedded shader code, it is a combination of the effect name and shader name.
 */
-(NSString*) getShaderKey: (SPVRTPFXParserShader*) pfxShader {
	return (pfxShader->bUseFileName)
				? [NSString stringWithUTF8String: pfxShader->pszGLSLfile]
				: [NSString stringWithFormat: @"%@-%@", self.name, [NSString stringWithUTF8String: pfxShader->Name.c_str()]];
}

/** 
 * Retrieves the shader code for the specified shader, either
 * loading it from file, or extracting the embedded GLSL code.
 */
-(GLchar*) getShaderCode: (SPVRTPFXParserShader*) pfxShader {
	return (pfxShader->bUseFileName)
				? [CC3GLProgram glslSourceFromFile: [NSString stringWithUTF8String: pfxShader->pszGLSLfile]]
				: pfxShader->pszGLSLcode;
}

@end



#pragma mark -
#pragma mark CC3PFXEffectTexture

@implementation CC3PFXEffectTexture

@synthesize texture=_texture, textureUnitIndex=_textureUnitIndex;

-(void) dealloc {
	[_texture release];
	[super dealloc];
}

@end

