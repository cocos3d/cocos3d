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


@class CC3GLSLUniform, CC3GLSLAttribute, CC3NodeDrawingVisitor;

/**
 * Indicates the semantic usage for a particular vertex array type.
 *
 * Under OpenGL ES 2, these values are used to match a vertex array to its semantic usage
 * within a GLSL vertex shader.
 *
 * The semantic value kCC3VertexContentSemanticAppBase and kCC3VertexContentSemanticMax define
 * a range of values that can be used by the application to match custom app-specific semantics.
 * The framework will not automatically assign or use values within this range, so it can be
 * used by the app to indicate an app-specific semantic usage.
 */
typedef enum {
	kCC3VertexContentSemanticNone = 0,		/**< No defined semantic usage. */
	kCC3VertexContentSemanticLocations,		/**< Vertex locations. */
	kCC3VertexContentSemanticNormals,		/**< Vertex normals. */
	kCC3VertexContentSemanticColors,		/**< Vertex colors. */
	kCC3VertexContentSemanticPointSizes,	/**< Vertex point sizes. */
	kCC3VertexContentSemanticWeights,		/**< Vertex skinning weights. */
	kCC3VertexContentSemanticMatrices,		/**< Vertex skinning matrices. */
	kCC3VertexContentSemanticTexture0,		/**< Vertex texture coordinates for texture unit 0. */
	kCC3VertexContentSemanticTexture1,		/**< Vertex texture coordinates for texture unit 1. */
	kCC3VertexContentSemanticTexture2,		/**< Vertex texture coordinates for texture unit 2. */
	kCC3VertexContentSemanticTexture3,		/**< Vertex texture coordinates for texture unit 3. */
	kCC3VertexContentSemanticTexture4,		/**< Vertex texture coordinates for texture unit 4. */
	kCC3VertexContentSemanticTexture5,		/**< Vertex texture coordinates for texture unit 5. */
	kCC3VertexContentSemanticTexture6,		/**< Vertex texture coordinates for texture unit 6. */
	kCC3VertexContentSemanticTexture7,		/**< Vertex texture coordinates for texture unit 7. */
	kCC3VertexContentSemanticAppBase,		/**< First semantic of app-specific custom semantics. */
	kCC3VertexContentSemanticMax = 0xFF		/**< The maximum value for an app-specific custom semantic. */
} CC3VertexContentSemantic;


typedef enum {
	kCC3SemanticNone = 0,						/**< No defined semantic usage. */
	
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

/** Returns a string representation of the specified vertex content semantic. */
NSString* NSStringFromCC3VertexContentSemantic(CC3VertexContentSemantic semantic);

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
 * Assigns the semantic property for the specified uniform.
 *
 * Implementers should attempt to match the specified uniform variable with a semantic and,
 * if found, should set the semantic property on the uniform variable, and return YES. If an
 * impementation cannot determine the appropriate semantic, it should avoid setting the semantic
 * property of the uniform and should return NO.
 *
 * Returns whether the semantic could be assigned. When delegating to superclasses or other
 * delegates, implementers can use this return code to determine whether or not to continue
 * attempting to determine the semantic for the specified variable.
 *
 * This method is invoked automatically after the GLSL program has been compiled and linked.
 */
-(BOOL) assignUniformSemantic: (CC3GLSLUniform*) uniform;

/** 
 * Assigns the semantic property for the specified attribute.
 *
 * Implementers should attempt to match the specified attribute variable with a semantic and,
 * if found, should set the semantic property on the attribute variable, and return YES. If an
 * impementation cannot determine the appropriate semantic, it should avoid setting the semantic
 * property of the attribute and should return NO.
 *
 * Returns whether the semantic could be assigned. When delegating to superclasses or other
 * delegates, implementers can use this return code to determine whether or not to continue
 * attempting to determine the semantic for the specified variable.
 *
 * The value set into the semantic property must follow the guidelines described
 * in the notes for the CC3VertexContentSemantic enumeration.
 *
 * This method is invoked automatically after the GLSL program has been compiled and linked.
 */
-(BOOL) assignAttributeSemantic: (CC3GLSLAttribute*) attribute;

/**
 * Populates the specified uniform.
 *
 * The semantic property of the specified uniform can be used to determine what content is
 * expected by the GLSL program for that uniform. The implementor then retrieves the required
 * content from the GL state caches found via the CC3OpenGLESEngine state machine structures,
 * or from the scene content accessed via the specified visitor.
 *
 * In the specified visitor, the camera property contains the active camera, the currentNode
 * property contains the node currently being drawn, the startingNode property contains the
 * CC3Scene, and the textureUnitCount property contains the number of texture units being
 * drawn for the current node.
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

/** Returns a string description of the specified uniform semantic. */
-(NSString*) nameOfUniformSemantic: (GLenum) semantic;

/** Returns a string description of the specified attribute semantic. */
-(NSString*) nameOfAttributeSemantic: (GLenum) semantic;

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateBase

/**
 * CC3GLProgramSemanticsDelegateBase is an abstract implementation of the CC3GLProgramSemanticsDelegate
 * protocol, that retrieves common uniform values from the scene based on those semantics.
 *
 * This implementation does not provide any behaviour for the assignUniformSemantic: and
 * assignAttributeSemantic:. Both method implementations do nothing, and always return NO.
 *
 * This implementation can be used as a superclass for other implementations. Semantic assigment
 * heuristics may be radically different across implementations, but there is much commonality in
 * the retrieval and assignement of uniform variables using the populateUniform:withVisitor: method.
 * In many cases, subclassing this implementation, and using the inherited populateUniform:withVisitor:
 * method, possibly overriding to provide additional variable assignment behaviour, can provide
 * significant useful functionality.
 */
@interface CC3GLProgramSemanticsDelegateBase : NSObject<CC3GLProgramSemanticsDelegate> {
}

/** Allocates and initializes an autoreleased instance. */
+(id) semanticsDelegate;

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
}

@end

/**
 * Convenience macro for testing and setting a semantic in a CC3GLSLVariable.
 *
 * Given a CC3GLSLVariable "variable", If the variable's name matches "name", the variable's
 * semantic property is set to "sem", and returns YES all the way out of the method or function
 * that invokes this macro (this last part is why this is a macro and not an inline).
 */
#define CC3SetSemantic(_name, _sem)						\
	if ( [variable.name isEqualToString: (_name)] ) {	\
		variable.semantic = (_sem);						\
		return YES;										\
	}
