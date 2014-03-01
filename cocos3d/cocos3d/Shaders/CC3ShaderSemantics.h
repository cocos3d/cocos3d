/*
 * CC3ShaderSemantics.h
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
 */

/** @file */	// Doxygen marker

#import "CC3OpenGLFoundation.h"
#import "CC3OSExtensions.h"

// Legacy naming support
#define CC3GLProgramSemanticsDelegate			CC3ShaderSemanticsDelegate
#define CC3ShaderProgramSemanticsDelegate		CC3ShaderSemanticsDelegate
#define CC3GLProgramSemanticsBase				CC3ShaderSemanticsBase
#define CC3ShaderProgramSemanticsBase			CC3ShaderSemanticsBase
#define CC3GLProgramSemanticsByVarName			CC3ShaderSemanticsByVarName
#define CC3ShaderProgramSemanticsByVarName		CC3ShaderSemanticsByVarName

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
	
	// CONTROL SEMANTICS -----------
	kCC3SemanticRedundant,						/**< Semantic usage is redundant. Typically used to identify repeated or redundant GLSL variables. */

	// VERTEX CONTENT --------------
	kCC3SemanticVertexLocation,					/**< Vertex location. */
	kCC3SemanticVertexNormal,					/**< Vertex normal. */
	kCC3SemanticVertexTangent,					/**< Vertex tangent. */
	kCC3SemanticVertexBitangent,				/**< Vertex bitangent (aka binormals). */
	kCC3SemanticVertexColor,					/**< Vertex color. */
	kCC3SemanticVertexBoneWeights,				/**< Vertex skinning bone weights. */
	kCC3SemanticVertexBoneIndices,				/**< Vertex skinning bone indices. */
	kCC3SemanticVertexPointSize,				/**< Vertex point size. */
	kCC3SemanticVertexTexture,					/**< Vertex texture coordinate for one texture unit. */
	
	kCC3SemanticHasVertexNormal,				/**< (bool) Whether a vertex normal is available. */
	kCC3SemanticShouldNormalizeVertexNormal,	/**< (bool) Whether vertex normals should be normalized. */
	kCC3SemanticShouldRescaleVertexNormal,		/**< (bool) Whether vertex normals should be rescaled. */
	kCC3SemanticHasVertexTangent,				/**< (bool) Whether a vertex tangent is available. */
	kCC3SemanticHasVertexBitangent,				/**< (bool) Whether a vertex bitangent is available. */
	kCC3SemanticHasVertexColor,					/**< (bool) Whether a vertex color is available. */
	kCC3SemanticHasVertexWeight,				/**< (bool) Whether a vertex weight is available. */
	kCC3SemanticHasVertexMatrixIndex,			/**< (bool) Whether a vertex matrix index is available. */
	kCC3SemanticHasVertexTextureCoordinate,		/**< (bool) Whether a vertex texture coordinate is available. */
	kCC3SemanticHasVertexPointSize,				/**< (bool) Whether a vertex point size is available. */
	kCC3SemanticIsDrawingPoints,				/**< (bool) Whether the vertices are being drawn as points. */
	kCC3SemanticShouldDrawFrontFaces,			/**< (bool) Whether the front side of each face is to be drawn. */
	kCC3SemanticShouldDrawBackFaces,			/**< (bool) Whether the back side of each face is to be drawn. */
	
	// ENVIRONMENT MATRICES --------------
	kCC3SemanticModelLocalMatrix,				/**< (mat4) Current model-to-parent matrix. */
	kCC3SemanticModelLocalMatrixInv,			/**< (mat4) Inverse of current model-to-parent matrix. */
	kCC3SemanticModelLocalMatrixInvTran,		/**< (mat3) Inverse-transpose of current model-to-parent matrix. */

	kCC3SemanticModelMatrix,					/**< (mat4) Current model-to-world matrix. */
	kCC3SemanticModelMatrixInv,					/**< (mat4) Inverse of current model-to-world matrix. */
	kCC3SemanticModelMatrixInvTran,				/**< (mat3) Inverse-transpose of current model-to-world matrix. */

	kCC3SemanticViewMatrix,						/**< (mat4) Camera view matrix. */
	kCC3SemanticViewMatrixInv,					/**< (mat4) Inverse of camera view matrix. */
	kCC3SemanticViewMatrixInvTran,				/**< (mat3) Inverse-transpose of camera view matrix. */

	kCC3SemanticModelViewMatrix,				/**< (mat4) Current model-view matrix. */
	kCC3SemanticModelViewMatrixInv,				/**< (mat4) Inverse of current model-view matrix. */
	kCC3SemanticModelViewMatrixInvTran,			/**< (mat3) Inverse-transpose of current model-view matrix. */

	kCC3SemanticProjMatrix,						/**< (mat4) Camera projection matrix. */
	kCC3SemanticProjMatrixInv,					/**< (mat4) Inverse of camera projection matrix. */
	kCC3SemanticProjMatrixInvTran,				/**< (mat3) Inverse-transpose of camera projection matrix. */

	kCC3SemanticViewProjMatrix,					/**< (mat4) Camera view and projection matrix. */
	kCC3SemanticViewProjMatrixInv,				/**< (mat4) Inverse of camera view and projection matrix. */
	kCC3SemanticViewProjMatrixInvTran,			/**< (mat3) Inverse-transpose of camera view and projection matrix. */

	kCC3SemanticModelViewProjMatrix,			/**< (mat4) Current model-view-projection matrix. */
	kCC3SemanticModelViewProjMatrixInv,			/**< (mat4) Inverse of current model-view-projection matrix. */
	kCC3SemanticModelViewProjMatrixInvTran,		/**< (mat3) Inverse-transpose of current model-view-projection matrix. */
	
	// BONE SKINNING ----------------
	kCC3SemanticVertexBoneCount,				/**< (int) Number of bones influencing each vertex (ie- number of weights/matrices specified on each vertex) */
	kCC3SemanticBatchBoneCount,					/**< (int) Length of the bone arrays for the current skin section. */
	
	// BONE SKINNING MATRICES ----------------
	kCC3SemanticBoneMatricesGlobal,				/**< (mat4[]) Array of bone matrices in the current mesh skin section in global coordinates (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneMatricesInvTranGlobal,		/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in global coordinates (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneMatricesEyeSpace,			/**< (mat4[]) Array of bone matrices in the current mesh skin section in eye space (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneMatricesInvTranEyeSpace,	/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in eye space (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneMatricesModelSpace,			/**< (mat4[]) Array of bone matrices in the current mesh skin section in local coordinates of model (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneMatricesInvTranModelSpace,	/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in local coordinates of model (length of array is specified by kCC3SemanticBatchBoneCount). */

	// BONE SKINNING DISCRETE TRANSFORMS
	kCC3SemanticBoneQuaternionsGlobal,			/**< (vec4[]) Array of bone quaternions in the current mesh skin section in global coordinates (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneTranslationsGlobal,			/**< (vec3[]) Array of bone translations in the current mesh skin section in global coordinates (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneScalesGlobal,				/**< (vec3[]) Array of bone scales in the current mesh skin section in global coordinates (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneQuaternionsEyeSpace,		/**< (vec4[]) Array of bone quaternions in the current mesh skin section in eye space (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneTranslationsEyeSpace,		/**< (vec3[]) Array of bone translations in the current mesh skin section in eye space (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneScalesEyeSpace,				/**< (vec3[]) Array of bone scales in the current mesh skin section in eye space (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneQuaternionsModelSpace,		/**< (vec4[]) Array of bone quaternions in the current mesh skin section in local coordinates of model (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneTranslationsModelSpace,		/**< (vec3[]) Array of bone translations in the current mesh skin section in local coordinates of model (length of array is specified by kCC3SemanticBatchBoneCount). */
	kCC3SemanticBoneScalesModelSpace,			/**< (vec3[]) Array of bone scales in the current mesh skin section in local coordinates of model (length of array is specified by kCC3SemanticBatchBoneCount). */
	
	// CAMERA -----------------
	kCC3SemanticCameraLocationGlobal,			/**< (vec3) Location of the camera in global coordinates. */
	kCC3SemanticCameraLocationModelSpace,		/**< (vec3) Location of the camera in local coordinates of model (not camera). */
	kCC3SemanticCameraFrustum,					/**< (vec4) Dimensions of the camera frustum (FOV width (radians), FOV height (radians), near clip, far clip). */
	kCC3SemanticCameraFrustumDepth,				/**< (vec4) The depth of the camera frustum (far clip, near clip, -(f+n)/(f-n), -2nf/(f-n)). */
	kCC3SemanticViewport,						/**< (int4) The viewport rectangle in pixels (x, y, width, height). */
	
	// MATERIALS --------------
	kCC3SemanticColor,							/**< (vec4) Color when lighting & materials are not in use. */
	kCC3SemanticMaterialColorAmbient,			/**< (vec4) Ambient color of the material. */
	kCC3SemanticMaterialColorDiffuse,			/**< (vec4) Diffuse color of the material. */
	kCC3SemanticMaterialColorSpecular,			/**< (vec4) Specular color of the material. */
	kCC3SemanticMaterialColorEmission,			/**< (vec4) Emission color of the material. */
	kCC3SemanticMaterialOpacity,				/**< (float) Opacity of the material. */
	kCC3SemanticMaterialShininess,				/**< (float) Shininess of the material (0 <> 128). */
	kCC3SemanticMaterialReflectivity,			/**< (float) Reflectivity of the material (0 <> 1). */
	kCC3SemanticMinimumDrawnAlpha,				/**< (float) Minimum alpha value to be drawn, otherwise will be discarded. */

	// LIGHTING
	kCC3SemanticIsUsingLighting,				/**< (bool) Whether any lighting is enabled. */
	kCC3SemanticSceneLightColorAmbient,			/**< (vec4) Ambient light color of the scene. */

	kCC3SemanticLightIsEnabled,					/**< (bool) Whether a light is enabled. */
	kCC3SemanticLightPositionGlobal,			/**< (vec4) Homogeneous position (location or direction) of a light in global coordinates. */
	kCC3SemanticLightPositionEyeSpace,			/**< (vec4) Homogeneous position (location or direction) of a light in eye space. */
	kCC3SemanticLightPositionModelSpace,		/**< (vec4) Homogeneous position (location or direction) of a light in local coordinates of model (not light). */
	kCC3SemanticLightInvertedPositionGlobal,	/**< (vec4) Inverted homogeneous position (from opposite direction) of a light in global coordinates. */
	kCC3SemanticLightInvertedPositionEyeSpace,	/**< (vec4) Inverted homogeneous position (from opposite direction) of a light in eye space. */
	kCC3SemanticLightInvertedPositionModelSpace,/**< (vec4) Inverted homogeneous position (from opposite direction) of a light in local coordinates of model (not light). */
	kCC3SemanticLightColorAmbient,				/**< (vec4) Ambient color of a light. */
	kCC3SemanticLightColorDiffuse,				/**< (vec4) Diffuse color of a light. */
	kCC3SemanticLightColorSpecular,				/**< (vec4) Specular color of a light. */
	kCC3SemanticLightAttenuation,				/**< (vec3) Distance attenuation coefficients for a light. */
	kCC3SemanticLightSpotDirectionGlobal,		/**< (vec3) Direction of a spotlight in global coordinates. */
	kCC3SemanticLightSpotDirectionEyeSpace,		/**< (vec3) Direction of a spotlight in eye space. */
	kCC3SemanticLightSpotDirectionModelSpace,	/**< (vec3) Direction of a spotlight in local coordinates of the model (not light). */
	kCC3SemanticLightSpotExponent,				/**< (float) Fade-off exponent of a spotlight. */
	kCC3SemanticLightSpotCutoffAngle,			/**< (float) Cutoff angle of a spotlight. */
	kCC3SemanticLightSpotCutoffAngleCosine,		/**< (float) Cosine of cutoff angle of a spotlight. */

	kCC3SemanticFogIsEnabled,					/**< (bool) Whether scene fogging is enabled. */
	kCC3SemanticFogColor,						/**< (vec4) Fog color. */
	kCC3SemanticFogAttenuationMode,				/**< (int) Fog attenuation mode (one of GL_LINEAR, GL_EXP or GL_EXP2). */
	kCC3SemanticFogDensity,						/**< (float) Fog density. */
	kCC3SemanticFogStartDistance,				/**< (float) Distance from camera at which fogging effect starts. */
	kCC3SemanticFogEndDistance,					/**< (float) Distance from camera at which fogging effect ends. */

	// TEXTURES
	kCC3SemanticTextureCount,					/**< (int) Number of active textures of any types. */
	kCC3SemanticTextureSampler,					/**< (sampler2D/sampler3D) Texture sampler of any type. */
	kCC3SemanticTexture2DCount,					/**< (int) Number of active 2D textures. */
	kCC3SemanticTexture2DSampler,				/**< (sampler2D) 2D texture sampler. */
	kCC3SemanticTextureCubeCount,				/**< (int) Number of active cube-map textures. */
	kCC3SemanticTextureCubeSampler,				/**< (sampler2D) Cube-map texture sampler. */
	
	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in code.
	kCC3SemanticTexUnitConstantColor,			/**< (vec4) Constant color of a texture unit. */
	kCC3SemanticTexUnitMode,					/**< (int) Environment mode of a texture unit. */
	kCC3SemanticTexUnitCombineRGBFunction,		/**< (int) RBG combiner function of a texture unit. */
	kCC3SemanticTexUnitSource0RGB,				/**< (int) RGB of source 0 of a texture unit. */
	kCC3SemanticTexUnitSource1RGB,				/**< (int) RGB of source 1 of a texture unit. */
	kCC3SemanticTexUnitSource2RGB,				/**< (int) RGB of source 2 of a texture unit. */
	kCC3SemanticTexUnitOperand0RGB,				/**< (int) RGB combining operand of source 0 of a texture unit. */
	kCC3SemanticTexUnitOperand1RGB,				/**< (int) RGB combining operand of source 1 of a texture unit. */
	kCC3SemanticTexUnitOperand2RGB,				/**< (int) RGB combining operand of source 2 of a texture unit. */
	kCC3SemanticTexUnitCombineAlphaFunction,	/**< (int) Alpha combiner function of a texture unit. */
	kCC3SemanticTexUnitSource0Alpha,			/**< (int) Alpha of source 0 of a texture unit. */
	kCC3SemanticTexUnitSource1Alpha,			/**< (int) Alpha of source 1 of a texture unit. */
	kCC3SemanticTexUnitSource2Alpha,			/**< (int) Alpha of source 2 of a texture unit. */
	kCC3SemanticTexUnitOperand0Alpha,			/**< (int) Alpha combining operand of source 0 of a texture unit. */
	kCC3SemanticTexUnitOperand1Alpha,			/**< (int) Alpha combining operand of source 1 of a texture unit. */
	kCC3SemanticTexUnitOperand2Alpha,			/**< (int) Alpha combining operand of source 2 of a texture unit. */
	
	// MODEL ----------------
	kCC3SemanticCenterOfGeometry,				/**< (vec3) Center of geometry of the model in the model's local coordinates. */
	kCC3SemanticBoundingBoxMin,					/**< (vec3) Minimum corner of the model's bounding box in the model's local coordinates. */
	kCC3SemanticBoundingBoxMax,					/**< (vec3) Maximum corner of the model's bounding box in the model's local coordinates. */
	kCC3SemanticBoundingBoxSize,				/**< (vec3) Dimensions of the model's bounding box in the model's local coordinates. */
	kCC3SemanticBoundingRadius,					/**< (float) Radius of the model's bounding sphere in the model's local coordinates. */
	kCC3SemanticAnimationFraction,				/**< (float) Fraction of the model's animation that has been viewed (range 0-1). */
	
	// PARTICLES ------------
	kCC3SemanticPointSize,						/**< (float) Default size of points, if not specified per-vertex in a vertex attribute array. */
	kCC3SemanticPointSizeAttenuation,			/**< (vec3) Point size distance attenuation coefficients. */
	kCC3SemanticPointSizeMinimum,				/**< (float) Minimum size points will be allowed to shrink to. */
	kCC3SemanticPointSizeMaximum,				/**< (float) Maximum size points will be allowed to grow to. */
	kCC3SemanticPointSpritesIsEnabled,			/**< (bool) Whether points should be interpeted as textured sprites. */

	// TIME ------------------
	kCC3SemanticFrameTime,						/**< (float) Time in seconds since the last frame. */
	kCC3SemanticSceneTime,						/**< (vec2) The real time, in seconds, since the scene was opened, and the fractional part of that time (T, fmod(T, 1)). */
	kCC3SemanticSceneTimeSine,					/**< (vec4) Sine of the scene time (sin(T), sin(T/2), sin(T/4), sin(T/8)). */
	kCC3SemanticSceneTimeCosine,				/**< (vec4) Cosine of the scene time (cos(T), cos(T/2), cos(T/4), cos(T/8)). */
	kCC3SemanticSceneTimeTangent,				/**< (vec4) Tangent of the scene time (tan(T), tan(T/2), tan(T/4), tan(T/8)). */
	
	// MISC ENVIRONMENT -------
	kCC3SemanticDrawCountCurrentFrame,			/**< (int) Number of draw calls so far in this frame. */
	kCC3SemanticRandomNumber,					/**< (float) A random number between 0 and 1. */
	
	kCC3SemanticAppBase,						/**< First semantic of app-specific custom semantics. */
	kCC3SemanticMax = 0xFFFF,					/**< Maximum value for an app-specific custom semantic. */
	
	// DEPRECATED
	kCC3SemanticVertexWeights DEPRECATED_ATTRIBUTE = kCC3SemanticVertexBoneWeights,			/**< @deprecated Renamed to kCC3SemanticVertexBoneWeights. */
	kCC3SemanticVertexMatrixIndices DEPRECATED_ATTRIBUTE = kCC3SemanticVertexBoneIndices,	/**< @deprecated Renamed to kCC3SemanticVertexBoneIndices. */
	kCC3SemanticBonesPerVertex DEPRECATED_ATTRIBUTE = kCC3SemanticVertexBoneCount,			/**< @deprecated Renamed to kCC3SemanticVertexBoneCount. */
	kCC3SemanticBoneCount DEPRECATED_ATTRIBUTE = kCC3SemanticBatchBoneCount,				/**< @deprecated Renamed to kCC3SemanticBatchBoneCount. */

} CC3Semantic;

/** Returns a string representation of the specified semantic. */
NSString* NSStringFromCC3Semantic(CC3Semantic semantic);


#pragma mark -
#pragma mark CC3ShaderSemanticsDelegate protocol

/**
 * Defines the behaviour required for an object that manages the semantics for a CC3ShaderProgram.
 *
 * Each CC3ShaderProgram delegates to an object that implements this protocol when it needs to
 * populate the current value of a uniform variable from content within the 3D scene.
 */
@protocol CC3ShaderSemanticsDelegate <CC3Object>

/**
 * Configures the specified GLSL variable.
 *
 * Implementers should attempt to match the specified uniform variable with a semantic and,
 * if found, should set the semantic property on the specified variable, and return YES.
 * If an impementation cannot determine the appropriate semantic, it should avoid setting
 * the semantic property of the uniform and should return NO.
 *
 * Implementers should also set the scope property of the specified variable. Typically this
 * is derived from the semantic.
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
 * Populates the specified uniform, if possible, and returns whether the uniform was populated.
 *
 * The semantic, semanticIndex and size properties of the specified uniform can be used to
 * determine what content is expected by the GLSL program for that uniform. The implementation
 * then retrieves the required content from the scene content accessed via the specified visitor.
 *
 * To permit access to content within the scene, the specified visitor contains several 
 * convenience properties for accessing typical content, including currentMeshNode,
 * currentMaterial, textureCount, camera, and scene properties, and a lightAt: method.
 *
 * Implementers of this method can use the various set... methods on the specified uniform
 * to set the content into the specified uniform variable. The implementor does not need to
 * manage the current value of the uniform, as it is managed automatically, and the GL engine
 * is only updated if the value has changed.
 *
 * Implementers should return YES if a value was set into the specified uniform variable,
 * and NO if otherwise. When delegating to superclasses or other delegates, implementers
 * can use this return value to determine whether or not to continue attempting to determine
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
 * An implementation of the CC3ShaderSemanticsDelegate protocol will typically contain a
 * collection of instances of this class, or a subclass, to configure the variables associated
 * with a CC3ShaderProgram.
 *
 * This base implementation maps a variable name to a semantic value. Subclasses may add
 * additional variable configuration information.
 */
@interface CC3GLSLVariableConfiguration : NSObject {
	NSString* _name;
	GLenum _semantic : 16;
	GLuint _semanticIndex : 8;
}

/**
 * The name of the variable.
 *
 * Typically this is the name of the variable as declared in the GLSL program source code.
 */
@property(nonatomic, retain) NSString* name;

/**
 * A symbolic constant indicating the semantic meaning of this variable. See the description
 * of the same property on the CC3GLSLVariable class for a full description.
 *
 * The initial value of this property is kCC3SemanticNone.
 */
@property(nonatomic, assign) GLenum semantic;

/**
 * When the semantic refers to an element of a structure that may have multiple instances,
 * this property indicates to which instance this variable refers. See the description of
 * the same property on the CC3GLSLVariable class for a full description.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) GLuint semanticIndex;

@end


#pragma mark -
#pragma mark CC3ShaderSemanticsBase

/**
 * CC3ShaderSemanticsBase is an abstract implementation of the CC3ShaderSemanticsDelegate
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
@interface CC3ShaderSemanticsBase : NSObject<CC3ShaderSemanticsDelegate> {}

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
#pragma mark CC3ShaderSemanticsByVarName

/**
 * CC3ShaderSemanticsByVarName extends CC3ShaderSemanticsBase to add the assignment of
 * semantics to uniform and attribute variables based on matching specific variable names
 * within the GLSL source code.
 *
 * Since the semantics are determined by GLSL variable name, it is critical that the GLSL
 * shader code use very specific attribute and uniform variable names.
 */
@interface CC3ShaderSemanticsByVarName : CC3ShaderSemanticsBase {
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
 * Adds a variable configruation that maps the specified variable name to the specified semantic
 * and semantic index.
 *
 * This implementation creates an instance of CC3GLSLVariableConfiguration configured with the
 * specified name, semantic and semantic index, and invokes the addVariableConfiguration: method.
 *
 * The value of the semantic parameter is typically one of values in the CC3Semantic enumeration,
 * but an application can define and use additional semantics beyond the values defined by
 * CC3Semantic. Additional semantics defined by the application should fall with the range
 * defined by the kCC3SemanticAppBase and kCC3SemanticMax constants, inclusively.
 */
-(void) mapVarName: (NSString*) name toSemantic: (GLenum) semantic at: (GLuint) semanticIndex;

/**
 * Adds a variable configruation that maps the specified variable name to the specified semantic
 * at semantic index zero.
 *
 * This is a convenience method that invokes the mapVarName:toSemantic:at: method, passing a value
 * of zero for the semanticIndex argument. See the description of that method for more info.
 */
-(void) mapVarName: (NSString*) name toSemantic: (GLenum) semantic;

@end


#pragma mark -
#pragma mark CC3ShaderSemanticsByVarName default mappings extension

/**
 * This extension to CC3ShaderSemanticsByVarName establishes a cocos3d default
 * mappings between variable names and semantics.
 *
 * An application can use the mappings defined in this extension as the basis for its own mappings
 * and add or change a few of its own additional mappings, or an application may ignore this
 * extension and may instead provide its own extensions to populate completely different mappings.
 */
@interface CC3ShaderSemanticsByVarName (DefaultMappings)

/**
 * Populates this instance with the default cocos3d mappings between variable names and semantics.
 *
 * An application wishing to add additional semantic mappings, or override any of the default
 * mappings can invoke this method, and then invoke the mapVarName:toSemantic: or
 * addVariableConfiguration: methods to add or change any of the mappings.
 *
 * An application wishing to define a completely different semantic mapping may instantiate
 * an instance of this class, will avoid invoking this method, and will typically add its
 * own population methods in a class extension category.
 */
-(void) populateWithDefaultVariableNameMappings;

/**
 * @deprecated
 * Populates this instance with the default cocos3d mappings between variable names and
 * semantics that are based on uniforms collected together into structures.
 *
 * Structure-based mapping provides an organized approach to managing uniform names, but are
 * not compatible with current OSX implementations of GLSL. Current OSX drivers do not handle
 * structure-based uniforms correctly.
 *
 * If you have developed GLSL shaders under iOS, that use this structure-based approach to
 * uniform naming, you can use this method to populate a semantic mapping that supports this
 * approach. For new iOS applications, and for all OSX applications, you should use the semantic
 * uniform name mappings defined by the populateWithDefaultVariableNameMappings method.
 */
-(void) populateWithStructuredVariableNameMappings DEPRECATED_ATTRIBUTE;

/**
 * @deprecated
 * Populates this instance with the default cocos3d mappings initially included with early
 * versions of cocos3d 2.0.
 *
 * These legacy mappings use less efficient uniform mappings, including use of the
 * array-of-structures paradigm. For GLSL under OpenGL ES, each element of each structure in
 * an array of structures is assigned to its own uniform variable for the purpose of managing
 * and populating the uniforms. This can significantly increase the number of actual uniforms,
 * and results in a corresponding increase in the overhead of managing and populating the
 * larger number of uniforms.
 *
 * It recommended that the array-of-structure approach offered by this method be avoided.
 * It is provided here to provide backwards compatibility for shaders already developed
 * using these legacy mappings.
 */
-(void) populateWithLegacyVariableNameMappings DEPRECATED_ATTRIBUTE;

@end

/** 
 * Macro for asserting that the specified uniform is large enough
 * to represent the number of bones in the specified skin section.
 */
#define CC3AssertBoneUniformForSkinSection(uniform, skinSection)						\
	CC3Assert(skinSection.boneCount <= uniform.size,						\
		@"%@ in %@ supports %i bones, which is not enough for %@.",			\
		uniform, uniform.program, uniform.size, skinSection);

