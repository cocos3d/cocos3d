/*
 * CC3PFXResource.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Resource.h"
#import "CC3PVRFoundation.h"
#import "CC3MeshNode.h"
#import "CC3ShaderProgram.h"


/**
 * CC3PFXResource is a CC3Resource that wraps a PVR PFX data structure loaded from a file.
 * It handles loading object data from PFX files, and creating content from that data.
 * This class is the cornerstone of PFX file management.
 */
@interface CC3PFXResource : CC3Resource {
	NSMutableDictionary* _texturesByName;
	NSMutableDictionary* _effectsByName;
	Class _semanticDelegateClass;
}

/** Populates the specfied material from the PFX effect with the specified name. */
-(void) populateMaterial: (CC3Material*) material fromEffectNamed: (NSString*) effectName;

/**
 * Populates the specfied material from the PFX effect with the specified name, found in the
 * cached CC3PFXResource with the specifed name. Raises an assertion error if a PFX resource
 * with the specified name cannot be found in the cache.
 */
+(void) populateMaterial: (CC3Material*) material
		 fromEffectNamed: (NSString*) effectName
	  inPFXResourceNamed: (NSString*) rezName;

/**
 * Populates the specfied material from the PFX effect with the specified name, found in the
 * CC3PFXResource loaded from the specfied file. Raises an assertion error if the PFX resource
 * file is not already in the resource cache and could not be loaded.
 */
+(void) populateMaterial: (CC3Material*) material
		 fromEffectNamed: (NSString*) effectName
	   inPFXResourceFile: (NSString*) aFilePath;

/** 
 * The class used to instantiate the semantic delegate for the GLSL programs created for
 * the PFX effects defined in this PFX resource. The returned class must be a subclass of
 * CC3PFXGLProgramSemantics.
 *
 * The initial value is set from the class-side defaultSemanticDelegateClass property.
 */
@property(nonatomic, assign) Class semanticDelegateClass;

/**
 * The default class used to instantiate the semantic delegate for the GLSL programs created
 * for the PFX effects defined in instances of this class. The value of this property determines
 * the initial value of the semanticDelegateClass property of any instances. The returned class
 * must be a subclass of CC3PFXGLProgramSemantics.
 *
 * The initial value is the CC3PVRShamanGLProgramSemantics class.
 */
+(Class) defaultSemanticDelegateClass;

/**
 * The default class used to instantiate the semantic delegate for the GLSL programs created
 * for the PFX effects defined in instances of this class. The value of this property determines
 * the initial value of the semanticDelegateClass property of any instances. The class must be
 * a subclass of CC3PFXGLProgramSemantics.
 *
 * The initial value is the CC3PVRShamanGLProgramSemantics class.
 */
+(void) setDefaultSemanticDelegateClass: (Class) aClass;

@end


#pragma mark -
#pragma mark CC3PFXEffect

/**
 * CC3PFXEffect represents a single effect within a PFX resource file. It combines the shader
 * code referenced by the effect into a CC3ShaderProgram, and the textures used by that program.
 */
@interface CC3PFXEffect : NSObject {
	NSString* _name;
	CC3ShaderProgram* _shaderProgram;
	CCArray* _textures;
	CCArray* _variables;
}

/** Returns the name of this effect. */
@property(nonatomic, retain, readonly) NSString* name;

/** The shader program used to render this effect. */
@property(nonatomic, retain, readonly) CC3ShaderProgram* shaderProgram;

/**
 * The textures used in this effect. Each element of this array is an instance of CC3PFXEffectTexture
 * that contains the texture and the index of the texture unit to which the texture should be applied.
 */
@property(nonatomic, retain, readonly) CCArray* textures;

/**
 * This array contains a configuration spec for each attribute and uniform variable used in
 * the shaders. Each element of this array is an instance of CC3PFXGLSLVariableConfiguration.
 */
@property(nonatomic, retain, readonly) CCArray* variables;

/**
 * Initializes this instance from the specified SPVRTPFXParserEffect C++ class, retrieved
 * from the specified CPVRTPFXParser C++ class as loaded from the specfied PFX resource.
 */
-(id) initFromSPVRTPFXParserEffect: (PFXClassPtr) pSPVRTPFXParserEffect
					 fromPFXParser: (PFXClassPtr) pCPVRTPFXParser
					 inPFXResource: (CC3PFXResource*) pfxRez;

/** Populates the specfied material with the GL program and textures. */
-(void) populateMaterial: (CC3Material*) material;

@end


#pragma mark -
#pragma mark CC3PFXGLSLVariableConfiguration

/** A CC3PFXGLSLVariableConfiguration that includes a semantic name retrieved from a PFX effect. */
@interface CC3PFXGLSLVariableConfiguration : CC3GLSLVariableConfiguration {
	NSString* _pfxSemanticName;
}

/** The semantic name as retrieved from the PFX effect. */
@property(nonatomic, retain) NSString* pfxSemanticName;

@end


#pragma mark -
#pragma mark CC3PFXGLProgramSemantics

/**
 * CC3PFXGLProgramSemantics provides a mapping from the PFX semantic names declared in a PFX
 * effect within a PFX effects file, and the standard semantics from the CC3Semantic enumeration.
 *
 * GLSL shader code loaded from a PFX effect can mix custom semantics defined within the PFX effect
 * with standard default semantics defined by the semantic delegate associated with the program matcher.
 * If a GLSL variable cannot be configured based on a semantic definition for its name within the
 * PFX effect, configuration of the variable is delegated to the standard semantic delegate at
 * CC3ShaderProgram.programMatcher.semanticDelegate. It is even possible to load shaders that use only
 * standard semantic naming, without having to define any semantics within the PFX effect.
 *
 * This is an abstract implementation. Subclasses can override the semanticForPFXSemanticName:
 * method for simple name-based mapping, or can override the resolveSemanticForVariableConfiguration:
 * for more complex mapping.
 */
@interface CC3PFXGLProgramSemantics : CC3ShaderProgramSemanticsByVarName

/**
 * Populates this instance with the mappings between variable names and semantics defined
 * in the specified PFX effect. In the process of doing so, the semantic of each variable
 * is resolved from the PFX semantic name of the variable configuration.
 *
 * For each variable configuration in the variables property of the specified PFX effect, this
 * method invokes the resolveSemanticForVariableConfiguration: and addVariableConfiguration:
 * methods to resolve the variable configuration and add it to this semantic mapping.
 *
 * This method is invoked automatically during the parsing of the PFX file.
 */
-(void) populateWithVariableNameMappingsFromPFXEffect: (CC3PFXEffect*) pfxEffect;

/**
 * If the semantic property of the specified variable configuration has not already been set,
 * it is set by resolving it from the PFX semantic name of the specified variable configuration.
 *
 * Returns whether the semantic has been resolved. Subclasses that override this method can first
 * invoke this superclass implementation, and then use the return value to resolve any custom semantics.
 *
 * The default behaviour is to invoke the semanticForPFXSemanticName: method with the value of
 * the pfxSemanticName property of the specified variable configuration, and if it returns a
 * valid semantic value, the semantic value is set in the specified variable configuration and
 * this method returns YES. If the semanticForPFXSemanticName: method returns kCC3SemanticNone,
 * the semantic of the specified variable configuration is not set, and this method returns NO.
 */
-(BOOL) resolveSemanticForVariableConfiguration: (CC3PFXGLSLVariableConfiguration*) pfxVarConfig;

/**
 * Returns the semantic value corresponding the the specified PFX semantic name, or returns
 * kCC3SemanticNone if the semantic could not be determined from the PFX semantic name.
 *
 * This implementation does nothing and simply returns kCC3SemanticNone. Subclasses will override.
 */
-(GLenum) semanticForPFXSemanticName: (NSString*) semanticName;

@end


#pragma mark -
#pragma mark CC3PFXEffectTexture

/** CC3PFXEffectTexture is a simple object that links a texture with a particular texture unit. */
@interface CC3PFXEffectTexture : NSObject {
	CC3Texture* _texture;
	NSString* _name;
	NSUInteger _textureUnitIndex;
}

/** The texture being linked to a particular texture unit. */
@property(nonatomic, retain) CC3Texture* texture;

/** The name of the texture as declared in the PFX file. */
@property(nonatomic, retain) NSString* name;

/** The index of the texture unit to which the texture should be applied. */
@property(nonatomic, assign) NSUInteger textureUnitIndex;

@end


#pragma mark -
#pragma mark CC3Material extension to support PFX effects

/** Extension to support PFX effects. */
@interface CC3Material (PFXEffects)

/**
 * Applies the PFX effect with the specified name, found in the cached CC3PFXResource with the
 * specifed name, to this material. Raises an assertion error if a PFX resource with the specified
 * name cannot be found in the cache.
 */
-(void) applyEffectNamed: (NSString*) effectName inPFXResourceNamed: (NSString*) rezName;

/**
 * Applys the PFX effect with the specified name, found in the CC3PFXResource loaded from the
 * specfied file, to this material. Raises an assertion error if the PFX resource file is not
 * already in the resource cache and could not be loaded.
 */
-(void) applyEffectNamed: (NSString*) effectName inPFXResourceFile: (NSString*) aFilePath;

@end


#pragma mark -
#pragma mark CC3Node extension to support PFX effects

/** Extension to support PFX effects. */
@interface CC3Node (PFXEffects)

/**
 * Applies the PFX effect with the specified name, found in the cached CC3PFXResource with the
 * specifed name, to all descendant nodes. Raises an assertion error if a PFX resource with the
 * specified name cannot be found in the cache.
 */
-(void) applyEffectNamed: (NSString*) effectName inPFXResourceNamed: (NSString*) rezName;

/**
 * Applys the PFX effect with the specified name, found in the CC3PFXResource loaded from the
 * specfied file, to all descendant nodes. Raises an assertion error if the PFX resource file
 * is not already in the resource cache and could not be loaded.
 */
-(void) applyEffectNamed: (NSString*) effectName inPFXResourceFile: (NSString*) aFilePath;

@end


#pragma mark -
#pragma mark CC3Shader extension to support PFX effects

/** Extension to support PFX effects. */
@interface CC3Shader (PFXEffects)

/**
 * Returns an instance compiled from GLSL source code identified by the specified PFX shader
 * specification in the specified PFX resource loader.
 *
 * Shaders loaded through this method are cached. If the shader was already loaded and is in
 * the cache, it is retrieved and returned. If the shader has not in the cache, it is created
 * compiled from GLSL code identified by the specified PFX shader specification, and added to
 * the shader cache. It is safe to invoke this method any time the shader is needed, without
 * having to worry that the shader will be repeatedly loaded and compiled.
 *
 * If the shader is created and compiled, the GLSL code may be embedded in the PFX file, or
 * may be contained in a separate GLSL source code file, as defined by the PFX shader spec.
 *
 * To clear a shader instance from the cache, use the removeShader: method.
 */
+(id) shaderFromPFXShader: (PFXClassPtr) pSPVRTPFXParserShader inPFXResource: (CC3PFXResource*) pfxRez;

@end

