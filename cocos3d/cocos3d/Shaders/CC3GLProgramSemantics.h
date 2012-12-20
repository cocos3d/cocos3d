/*
 * CC3GLProgramSemantics.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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


@class CC3GLSLVariable, CC3GLSLUniform, CC3NodeDrawingVisitor;


#pragma mark Semantic enumerations

/**
 * Indicates the semantic usage for scene content.
 *
 * Under OpenGL ES 2, these values are used to match an GLSL program variable to its semantic
 * usage within a GLSL shader.
 *
 * The semantic value kCC3SemanticAppBase and kCC3SemanticMax define a range of values that
 * can be used by the application to define and match custom app-specific semantics. The
 * framework will not automatically assign or use values within this range, so it can be
 * used by the app to indicate an app-specific semantic usage.
 */
typedef enum {
	kCC3SemanticNone = 0,						/**< No defined semantic usage. */

	// VERTEX CONTENT --------------
	kCC3SemanticVertexLocations,				/**< Vertex locations. */
	kCC3SemanticVertexNormals,					/**< Vertex normals. */
	kCC3SemanticVertexColors,					/**< Vertex colors. */
	kCC3SemanticVertexPointSizes,				/**< Vertex point sizes. */
	kCC3SemanticVertexWeights,					/**< Vertex skinning weights. */
	kCC3SemanticVertexMatrices,					/**< Vertex skinning matrices. */
	kCC3SemanticVertexTexture0,					/**< Vertex texture coordinates for texture unit 0. */
	kCC3SemanticVertexTexture1,					/**< Vertex texture coordinates for texture unit 1. */
	kCC3SemanticVertexTexture2,					/**< Vertex texture coordinates for texture unit 2. */
	kCC3SemanticVertexTexture3,					/**< Vertex texture coordinates for texture unit 3. */
	kCC3SemanticVertexTexture4,					/**< Vertex texture coordinates for texture unit 4. */
	kCC3SemanticVertexTexture5,					/**< Vertex texture coordinates for texture unit 5. */
	kCC3SemanticVertexTexture6,					/**< Vertex texture coordinates for texture unit 6. */
	kCC3SemanticVertexTexture7,					/**< Vertex texture coordinates for texture unit 7. */
	
	// ENVIRONMENT MATRICES --------------
	kCC3SemanticModelMatrix,					/**< Current model-to-world matrix. */
	kCC3SemanticModelMatrixInv,					/**< Inverse of current model-to-world matrix. */
	kCC3SemanticModelMatrixInvTran,				/**< Inverse-transpose of current model-to-world matrix. */
	kCC3SemanticViewMatrix,						/**< Camera view matrix. */
	kCC3SemanticViewMatrixInv,					/**< Inverse of camera view matrix. */
	kCC3SemanticViewMatrixInvTran,				/**< Inverse-transpose of camera view matrix. */
	kCC3SemanticModelViewMatrix,				/**< Current modelview matrix. */
	kCC3SemanticModelViewMatrixInv,				/**< Inverse of current modelview matrix. */
	kCC3SemanticModelViewMatrixInvTran,			/**< Inverse-transpose of current modelview matrix. */
	kCC3SemanticProjMatrix,						/**< Camera projection matrix. */
	kCC3SemanticProjMatrixInv,					/**< Inverse of camera projection matrix. */
	kCC3SemanticProjMatrixInvTran,				/**< Inverse-transpose of camera projection matrix. */
	kCC3SemanticModelViewProjMatrix,			/**< Current modelview-projection matrix. */
	kCC3SemanticModelViewProjMatrixInv,			/**< Inverse of current modelview-projection matrix. */
	kCC3SemanticModelViewProjMatrixInvTran,		/**< Inverse-transpose of current modelview-projection matrix. */
	
	// MATERIALS --------------
	kCC3SemanticColor,							/**< Color when lighting is not in use. */
	kCC3SemanticMaterialColorAmbient,			/**< Ambient color of the material. */
	kCC3SemanticMaterialColorDiffuse,			/**< Diffuse color of the material. */
	kCC3SemanticMaterialColorSpecular,			/**< Specular color of the material. */
	kCC3SemanticMaterialColorEmission,			/**< Emission color of the material. */
	kCC3SemanticMaterialOpacity,				/**< Opacity of the material. */
	kCC3SemanticMaterialShininess,				/**< Shininess of the material. */

	// LIGHTING - Each category of light enums are consecutive to allow conversion to an index
	kCC3SemanticIsUsingLighting,				/**< Whether any lighting is enabled. */
	kCC3SemanticSceneLightColorAmbient,			/**< Ambient light color of the scene. */

	kCC3SemanticLightIsEnabled0,				/**< Whether light 0 is enabled. */
	kCC3SemanticLightIsEnabled1,				/**< Whether light 1 is enabled. */
	kCC3SemanticLightIsEnabled2,				/**< Whether light 2 is enabled. */
	kCC3SemanticLightIsEnabled3,				/**< Whether light 3 is enabled. */
	kCC3SemanticLightIsEnabled4,				/**< Whether light 4 is enabled. */
	kCC3SemanticLightIsEnabled5,				/**< Whether light 5 is enabled. */
	kCC3SemanticLightIsEnabled6,				/**< Whether light 6 is enabled. */
	kCC3SemanticLightIsEnabled7,				/**< Whether light 7 is enabled. */

	kCC3SemanticLightPosition0,					/**< Position of light 0. */
	kCC3SemanticLightPosition1,					/**< Position of light 1. */
	kCC3SemanticLightPosition2,					/**< Position of light 2. */
	kCC3SemanticLightPosition3,					/**< Position of light 3. */
	kCC3SemanticLightPosition4,					/**< Position of light 4. */
	kCC3SemanticLightPosition5,					/**< Position of light 5. */
	kCC3SemanticLightPosition6,					/**< Position of light 6. */
	kCC3SemanticLightPosition7,					/**< Position of light 7. */
	
	kCC3SemanticLightColorAmbient0,				/**< Ambient color of light 0. */
	kCC3SemanticLightColorAmbient1,				/**< Ambient color of light 1. */
	kCC3SemanticLightColorAmbient2,				/**< Ambient color of light 2. */
	kCC3SemanticLightColorAmbient3,				/**< Ambient color of light 3. */
	kCC3SemanticLightColorAmbient4,				/**< Ambient color of light 4. */
	kCC3SemanticLightColorAmbient5,				/**< Ambient color of light 5. */
	kCC3SemanticLightColorAmbient6,				/**< Ambient color of light 6. */
	kCC3SemanticLightColorAmbient7,				/**< Ambient color of light 7. */

	kCC3SemanticLightColorDiffuse0,				/**< Diffuse color of light 0. */
	kCC3SemanticLightColorDiffuse1,				/**< Diffuse color of light 1. */
	kCC3SemanticLightColorDiffuse2,				/**< Diffuse color of light 2. */
	kCC3SemanticLightColorDiffuse3,				/**< Diffuse color of light 3. */
	kCC3SemanticLightColorDiffuse4,				/**< Diffuse color of light 4. */
	kCC3SemanticLightColorDiffuse5,				/**< Diffuse color of light 5. */
	kCC3SemanticLightColorDiffuse6,				/**< Diffuse color of light 6. */
	kCC3SemanticLightColorDiffuse7,				/**< Diffuse color of light 7. */

	kCC3SemanticLightColorSpecular0,			/**< Specular color of light 0. */
	kCC3SemanticLightColorSpecular1,			/**< Specular color of light 1. */
	kCC3SemanticLightColorSpecular2,			/**< Specular color of light 2. */
	kCC3SemanticLightColorSpecular3,			/**< Specular color of light 3. */
	kCC3SemanticLightColorSpecular4,			/**< Specular color of light 4. */
	kCC3SemanticLightColorSpecular5,			/**< Specular color of light 5. */
	kCC3SemanticLightColorSpecular6,			/**< Specular color of light 6. */
	kCC3SemanticLightColorSpecular7,			/**< Specular color of light 7. */

	kCC3SemanticLightAttenuationCoefficients0,	/**< AttenuationCoefficients for light 0. */
	kCC3SemanticLightAttenuationCoefficients1,	/**< AttenuationCoefficients for light 1. */
	kCC3SemanticLightAttenuationCoefficients2,	/**< AttenuationCoefficients for light 2. */
	kCC3SemanticLightAttenuationCoefficients3,	/**< AttenuationCoefficients for light 3. */
	kCC3SemanticLightAttenuationCoefficients4,	/**< AttenuationCoefficients for light 4. */
	kCC3SemanticLightAttenuationCoefficients5,	/**< AttenuationCoefficients for light 5. */
	kCC3SemanticLightAttenuationCoefficients6,	/**< AttenuationCoefficients for light 6. */
	kCC3SemanticLightAttenuationCoefficients7,	/**< AttenuationCoefficients for light 7. */

	kCC3SemanticLightSpotDirection0,			/**< Direction of spotlight 0. */
	kCC3SemanticLightSpotDirection1,			/**< Direction of spotlight 1. */
	kCC3SemanticLightSpotDirection2,			/**< Direction of spotlight 2. */
	kCC3SemanticLightSpotDirection3,			/**< Direction of spotlight 3. */
	kCC3SemanticLightSpotDirection4,			/**< Direction of spotlight 4. */
	kCC3SemanticLightSpotDirection5,			/**< Direction of spotlight 5. */
	kCC3SemanticLightSpotDirection6,			/**< Direction of spotlight 6. */
	kCC3SemanticLightSpotDirection7,			/**< Direction of spotlight 7. */
	
	kCC3SemanticLightSpotExponent0,				/**< Fade-off exponent of spotlight 0. */
	kCC3SemanticLightSpotExponent1,				/**< Fade-off exponent of spotlight 1. */
	kCC3SemanticLightSpotExponent2,				/**< Fade-off exponent of spotlight 2. */
	kCC3SemanticLightSpotExponent3,				/**< Fade-off exponent of spotlight 3. */
	kCC3SemanticLightSpotExponent4,				/**< Fade-off exponent of spotlight 4. */
	kCC3SemanticLightSpotExponent5,				/**< Fade-off exponent of spotlight 5. */
	kCC3SemanticLightSpotExponent6,				/**< Fade-off exponent of spotlight 6. */
	kCC3SemanticLightSpotExponent7,				/**< Fade-off exponent of spotlight 7. */
	
	kCC3SemanticLightSpotCutoffAngle0,			/**< Cutoff angle of spotlight 0. */
	kCC3SemanticLightSpotCutoffAngle1,			/**< Cutoff angle of spotlight 1. */
	kCC3SemanticLightSpotCutoffAngle2,			/**< Cutoff angle of spotlight 2. */
	kCC3SemanticLightSpotCutoffAngle3,			/**< Cutoff angle of spotlight 3. */
	kCC3SemanticLightSpotCutoffAngle4,			/**< Cutoff angle of spotlight 4. */
	kCC3SemanticLightSpotCutoffAngle5,			/**< Cutoff angle of spotlight 5. */
	kCC3SemanticLightSpotCutoffAngle6,			/**< Cutoff angle of spotlight 6. */
	kCC3SemanticLightSpotCutoffAngle7,			/**< Cutoff angle of spotlight 7. */
	
	kCC3SemanticLightSpotCutoffAngleCosine0,	/**< Cosine of cutoff angle of spotlight 0. */
	kCC3SemanticLightSpotCutoffAngleCosine1,	/**< Cosine of cutoff angle of spotlight 1. */
	kCC3SemanticLightSpotCutoffAngleCosine2,	/**< Cosine of cutoff angle of spotlight 2. */
	kCC3SemanticLightSpotCutoffAngleCosine3,	/**< Cosine of cutoff angle of spotlight 3. */
	kCC3SemanticLightSpotCutoffAngleCosine4,	/**< Cosine of cutoff angle of spotlight 4. */
	kCC3SemanticLightSpotCutoffAngleCosine5,	/**< Cosine of cutoff angle of spotlight 5. */
	kCC3SemanticLightSpotCutoffAngleCosine6,	/**< Cosine of cutoff angle of spotlight 6. */
	kCC3SemanticLightSpotCutoffAngleCosine7,	/**< Cosine of cutoff angle of spotlight 7. */

	// TEXTURES --------------
	kCC3SemanticTextureCount,					/**< Number of active texture units. */
	kCC3SemanticTexture0,						/**< Texture unit 0. */
	kCC3SemanticTexture1,						/**< Texture unit 1. */
	kCC3SemanticTexture2,						/**< Texture unit 2. */
	kCC3SemanticTexture3,						/**< Texture unit 3. */
	kCC3SemanticTexture4,						/**< Texture unit 4. */
	kCC3SemanticTexture5,						/**< Texture unit 5. */
	kCC3SemanticTexture6,						/**< Texture unit 6. */
	kCC3SemanticTexture7,						/**< Texture unit 7. */

	kCC3SemanticHasVertexNormal,				/**< Whether a vertex normal array is available. */
	kCC3SemanticShouldNormalizeVertexNormal,	/**< Whether vertex normals should be normalized. */
	kCC3SemanticShouldRescaleVertexNormal,		/**< Whether vertex normals should be rescaled. */
	kCC3SemanticHasVertexColor,					/**< Whether a vertex normal array is available. */
	kCC3SemanticTexCoordCount,					/**< Number of texture coordinate attributes. */
	
	kCC3SemanticAppBase,						/**< First semantic of app-specific custom semantics. */
	kCC3SemanticMax = 0xFFFF					/**< The maximum value for an app-specific custom semantic. */
} CC3Semantic;

/** Returns a string representation of the specified state semantic. */
NSString* NSStringFromCC3Semantic(CC3Semantic semantic);


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegate protocol

/**
 * Defines the behaviour required for an object that manages the semantics for a CC3GLProgram.
 *
 * Each CC3GLProgram delegates to an object that implements this protocol when it needs to
 * populate the current value of a uniform variable from content within the 3D scene.
 */
@protocol CC3GLProgramSemanticsDelegate <NSObject>

/**
 * Configures the specified GLSL variable.
 *
 * Implementers should attempt to match the specified uniform variable with a semantic and,
 * if found, should set the semantic property on the specified variable, and return YES.
 * If an impementation cannot determine the appropriate semantic, it should avoid setting
 * the semantic property of the uniform and should return NO.
 *
 * In addition, implementers may perform additional configuration behaviour for the specified
 * variable.
 *
 * Returns whether the variable was successfully configured. When delegating to superclasses
 * or other delegates, implementers can use this return code to determine whether or not to
 * continue attempting to configure the specified variable.
 *
 * This method is invoked automatically after the GLSL program has been compiled and linked.
 */
-(BOOL) configureVariable: (CC3GLSLVariable*) variable;

/**
 * Populates the specified uniform.
 *
 * The semantic property of the specified uniform can be used to determine what content is
 * expected by the GLSL program for that uniform. The implementor then retrieves the required
 * content from the GL state caches found via the CC3OpenGLESEngine state machine structures,
 * or from the scene content accessed via the specified visitor.
 *
 * The specified visitor can be used to access content within the scene, and contains several
 * convenience properties for accessing typical content, including currentMeshNode,
 * currentMaterial, textureUnitCount, camera, and scene properties, and a lightAt: method.
 *
 * Implementers of this method can use the various set... methods on the specified uniform
 * to set the content into the specified uniform variable. The implementor does not need to
 * manage the current value of the uniform, as it is managed automatically, and the GL engine
 * is only updated if the value has changed.
 *
 * Implementers should return YES if a value was set into the specified uniform variable,
 * and NO if otherwise. When delegating to superclasses or other delegates, implementers
 * can use this return code to determine whether or not to continue attempting to determine
 * and set the value of the uniform variable.
 *
 * This method is invoked automatically on every rendering loop. Keep it tight.
 */
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Returns a string description of the specified semantic. */
-(NSString*) nameOfSemantic: (GLenum) semantic;

@end


#pragma mark -
#pragma mark CC3GLSLVariableConfiguration

/**
 * A CC3GLSLVariableConfiguration carries information for configuring a single CC3GLSLVariable.
 *
 * An implementation of the CC3GLProgramSemanticsDelegate protocol will typically contain a
 * collection of instances of this class, or a subclass, to configure the variables associated
 * with a CC3GLProgram.
 *
 * This base implementation maps a variable name to a semantic value. Subclasses may add
 * additional variable configuration information.
 */
@interface CC3GLSLVariableConfiguration : NSObject {
	NSString* _name;
	GLenum _semantic;
}

/**
 * The name of the variable.
 *
 * Typically this is the name of the variable as declared in the GLSL program source code.
 */
@property(nonatomic, retain) NSString* name;

/**
 * A symbolic constant indicating the semantic meaning of this variable.
 *
 * The value of this property is typically one of values in the CC3Semantic enumeration,
 * but an application can define and use additional semantics beyond the values defined
 * by CC3Semantic. Additional semantics defined by the application should fall with the
 * range defined by the kCC3SemanticAppBase and kCC3SemanticMax constants, inclusively.
 *
 * The initial value of this property is kCC3SemanticNone.
 */
@property(nonatomic, assign) GLenum semantic;

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateBase

/**
 * CC3GLProgramSemanticsDelegateBase is an abstract implementation of the CC3GLProgramSemanticsDelegate
 * protocol, that retrieves common uniform values from the scene based on those semantics.
 *
 * This implementation can be used as a superclass for other implementations. Semantic assigment
 * heuristics may be radically different across implementations, but there is much commonality in
 * the retrieval and assignment of uniform variables using the populateUniform:withVisitor: method.
 * In many cases, subclassing this implementation, and using the inherited populateUniform:withVisitor:
 * method, possibly overriding to provide additional variable assignment behaviour, can provide
 * significant useful functionality.
 *
 * This implementation does not provide any behaviour for the configureVariable: method, which
 * simply returns NO.
 *
 * The nameOfSemantic: method returns a name for each standard semantics defined in the CC3Semantic
 * enumeration. If a subclass adds additional semantic definitions of its own, it should override
 * that method to provide a string representation of the semantic value.
 */
@interface CC3GLProgramSemanticsDelegateBase : NSObject<CC3GLProgramSemanticsDelegate> {}

/** Allocates and initializes an autoreleased instance. */
+(id) semanticsDelegate;

/**
 * Populates the specified uniform from standard content extracted from the scene.
 *
 * This implementation provides significant standard behaviour for most standard semantics.
 * Subclasses can use this as a starting point, and add content extraction for customized
 * semantics, or can override the behaviour of this method for specific uniforms or semantics.
 */
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * This implementation does not provide any configuration behaviour, and simply returns NO.
 *
 * Subclasses will add behaviour to configure variables according to customized semantic mapping.
 */
-(BOOL) configureVariable: (CC3GLSLVariable*) variable;

/**
 * Returns a string description of the specified semantic.
 *
 * This implementation calls the NSStringFromCC3Semantic method to return a name for each of
 * the standard semantics defined in the CC3Semantic enumeration. If a subclass adds additional
 * semantic definitions of its own, it should override this method to provide a string
 * representation of any new semantic values.
 */
-(NSString*) nameOfSemantic: (GLenum) semantic;

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateByVarNames

/**
 * CC3GLProgramSemanticsDelegateByVarNames extends CC3GLProgramSemanticsDelegateBase to add
 * the assignment of semantics to uniform and attribute variables based on matching specific
 * variable names within the GLSL source code.
 *
 * Since the semantics are determined by GLSL variable name, it is critical that the GLSL shader
 * code use very specific attribute and uniform variable names.
 */
@interface CC3GLProgramSemanticsDelegateByVarNames : CC3GLProgramSemanticsDelegateBase {
	NSMutableDictionary* _varConfigsByName;
}

/**
 * This implementation uses the name property of the specified variable to look up a
 * configuration, and sets the semantic property of the specified variable to that of
 * the retrieved configuration.
 *
 * Returns YES if a configuration was found and the semantic was assigned, or NO if
 * a configuration could not be found for the variable.
 */
-(BOOL) configureVariable: (CC3GLSLVariable*) variable;

/**
 * Adds the specified variable configuration to the configuration lookup.
 *
 * Configurations added via this method are used to configure the variables submitted
 * to the configureVariable: method.
 *
 * Configurations are added to the lookup by name. If a configuration with the same name
 * already exists in the lookup, it is replaced with the specified configuration.
 */
-(void) addVariableConfiguration: (CC3GLSLVariableConfiguration*) varConfig;

/**
 * Adds a variable configruation that maps the specified variable name to the specified semantic.
 *
 * This implementation creates an instance of CC3GLSLVariableConfiguration configured with
 * the specified name and semantic, and invokes the addVariableConfiguration: method.
 *
 * The value of the semantic parameter is typically one of values in the CC3Semantic enumeration,
 * but an application can define and use additional semantics beyond the values defined by
 * CC3Semantic. Additional semantics defined by the application should fall with the range
 * defined by the kCC3SemanticAppBase and kCC3SemanticMax constants, inclusively.
 */
-(void) mapVariableName: (NSString*) name toSemantic: (GLenum) semantic;

/**
 * Populates this instance with the default cocos3d mappings between names and semantics.
 *
 * An application wishing to add additional semantic mappings, or override any of the default
 * mappings can invoke this method, and then invoke the addVariableConfiguration: method to
 * add or change any of the mappings.
 */
-(void) populateWithDefaultSemanticMappings;

/** 
 * Populates this instance with the simple mappings between names and semantics
 * used for painting nodes in a solid, pure color, including during node picking.
 */
-(void) populateWithPureColorSemanticMappings;


#pragma mark Allocation and initialization

/**
 * Returns a shared default semantic delegate, that can be used to map the standard variables
 * to their default semantics.
 *
 * The delegate returned by this property is lazily created and automatically populated using
 * the populateWithDefaultSemanticMappings method to create the standard default mappings.
 *
 * The default CC3DefaultByVarNames.vsh and CC3DefaultByVarNames.fsh shaders are designed to
 * use the standard default mappings provided by the delegate returned by this property.
 *
 * This property returns a shared instance. Making changes to the delegate returned by this
 * property will affect all CC3GLPrograms that have been assigned this delegate. Handle with care.
 */
+(CC3GLProgramSemanticsDelegateByVarNames*) sharedDefaultDelegate;

@end
