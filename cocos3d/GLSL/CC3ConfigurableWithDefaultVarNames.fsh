/*
 * CC3ConfigurableWithDefaultVarNames.fsh
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
 */

/**
 * This fragment shader provides a general configurable shader that replicates much of the
 * functionality of the fixed-pipeline of OpenGL ES 1.1. As such, this shader is suitable
 * for use as a default when a CC3Material has not been assigned a specific GL shader
 * program, and can make use of the configurability of CC3Material and CC3MeshNode.
 *
 * CC3ConfigurableWithDefaultVarNames.vsh is the vertx shader paired with this fragment shader.
 *
 * When using this shader, be aware that the general nature and high-level of configurability
 * available with this shader means that it cannot be optimized to the same degree that a more
 * deliberately dedicated shader can be optimized. This shader may be used during early stages
 * of development, but for optimal performance, it is recommended that the application provide
 * specialized shaders that have been tuned and optimized to a specific needs of each model.
 *
 * The semantics of the variables in this shader can be mapped using the
 * CC3GLProgramSemanticsByVarName sharedDefaultDelegate instance.
 *
 * In order to reduce the number of uniform variables, this shader supports two texture units.
 * This can be increased by changing the MAX_TEXTURES macro definition below.
 */

// Increase this if more textures are desired. In order to improve performance, it has been
// kept low to limit the number of uniforms. This definition should not be set larger than
// the CC3GLProgramSemanticsByVarName class-side maxDefaultMappingTextureUnitVariables
// property (defaults to 4). See the description of those properties for more info.
#define MAX_TEXTURES			2

// Texture constants to support OpenGL ES 1.1 conformant multi-texturing.
#define GL_REPLACE                        0x1E01
#define GL_MODULATE                       0x2100
#define GL_DECAL                          0x2101
#define GL_BLEND                          0x0BE2
#define GL_ADD                            0x0104
#define GL_COMBINE                        0x8570
#define GL_ADD_SIGNED                     0x8574
#define GL_INTERPOLATE                    0x8575
#define GL_SUBTRACT                       0x84E7
#define GL_DOT3_RGB                       0x86AE
#define GL_DOT3_RGBA                      0x86AF
#define GL_TEXTURE                        0x1702
#define GL_CONSTANT                       0x8576
#define GL_PREVIOUS                       0x8578


precision mediump float;

//-------------- STRUCTURES ----------------------

/**
 * The parameters that define a material.
 *
 * When using this structure as the basis of a simpler implementation, remove any elements
 * that your shader does not use, to reduce the number of uniforms that need to be retrieved
 * and pased to your shader (uniform structure elements are passed individually in GLSL).
 */
struct Material {
	vec4	ambientColor;						/**< Ambient color of the material. */
	vec4	diffuseColor;						/**< Diffuse color of the material. */
	vec4	specularColor;						/**< Specular color of the material. */
	vec4	emissionColor;						/**< Emission color of the material. */
	float	shininess;							/**< Shininess of the material. */
	float	minimumDrawnAlpha;					/**< Minimum alpha value to be drawn, otherwise fragment will be discarded. */
};

/**
 * The parameters of a single texture unit used to mimic OpenGL ES 1.1 functionality for
 * combining textures using texture units. In most advanced shaders, these parameters will
 * be ignored completely, in favor of customized texture combining shader code.
 *
 * The structure here is provided as a reference. When using this structure as the basis of
 * a simpler implementation, remove any elements that your shader does not use, to reduce the
 * number of uniforms that need to be retrieved and pased to your shader (uniform structure
 * elements are passed individually in GLSL).
 *
 * This example shader does not use all of the elements of this structure. The compiler will
 * optimize away any elements of this structure that are not used within the shader source code.
 */
struct TextureUnit {
	vec4	color;								/**< Constant color of this texure unit (often used for normal mapping). */
	int		mode;								/**< Texture environment mode for this texture unit. */
	int		combineRGBFunction;					/**< RGB combiner function for this texture unit. */
	int		rgbSource0;							/**< The source of the RGB components for arg0 of the combiner function in this texture unit. */
	int		rgbSource1;							/**< The source of the RGB components for arg1 of the combiner function in this texture unit. */
	int		rgbSource2;							/**< The source of the RGB components for arg2 of the combiner function in this texture unit. */
	int		rgbOperand0;						/**< The operand on the RGB components for arg0 of the combiner function in this texture unit. */
	int		rgbOperand1;						/**< The operand on the RGB components for arg1 of the combiner function in this texture unit. */
	int		rgbOperand2;						/**< The operand on the RGB components for arg2 of the combiner function in this texture unit. */
	int		combineAlphaFunction;				/**< Alpha combiner function for this texture unit. */
	int		alphaSource0;						/**< The source of the alpha components for arg0 of the combiner function in this texture unit. */
	int		alphaSource1;						/**< The source of the alpha components for arg1 of the combiner function in this texture unit. */
	int		alphaSource2;						/**< The source of the alpha components for arg2 of the combiner function in this texture unit. */
	int		alphaOperand0;						/**< The operand on the alpha components for arg0 of the combiner function in this texture unit. */
	int		alphaOperand1;						/**< The operand on the alpha components for arg1 of the combiner function in this texture unit. */
	int		alphaOperand2;						/**< The operand on the alpha components for arg2 of the combiner function in this texture unit. */
};

/**
 * The parameters to use when displaying vertices as points.
 *
 * When using this structure as the basis of a simpler implementation, remove any elements
 * that your shader does not use, to reduce the number of uniforms that need to be retrieved
 * and pased to your shader (uniform structure elements are passed individually in GLSL).
 */
struct Point {
	float	size;							/**< Default size of points, if not specified per-vertex. */
	float	minimumSize;					/**< Minimum size to which points will be allowed to shrink. */
	float	maximumSize;					/**< Maximum size to which points will be allowed to grow. */
	vec3	sizeAttenuation;				/**< Coefficients of the size attenuation equation. */
	float	sizeFadeThreshold;				/**< Alpha fade threshold for smaller points. */
	bool	isDrawingPoints;				/**< Whether the vertices are being drawn as points. */
	bool	hasVertexPointSize;				/**< Whether vertex point size attribute is available. */
	bool	shouldDisplayAsSprites;			/**< Whether points should be interpeted as textured sprites. */
};


//-------------- UNIFORMS ----------------------

// Uniforms describing vertex attributes.
uniform bool u_cc3HasVertexTangent;						/**< Whether vertex tangent attribute is available. */

// Material properties
uniform Material u_cc3Material;							/**< The material being applied to the mesh. */

// Textures
uniform lowp int u_cc3TextureCount;						/**< Number of textures. */
uniform sampler2D s_cc3Textures[MAX_TEXTURES];			/**< Texture samplers. */
uniform TextureUnit u_cc3TextureUnits[MAX_TEXTURES];	/**< Texture unit parameters. */

// Points
uniform Point u_cc3Points;								/**< Point parameters. */

//-------------- VARYING VARIABLES INPUTS ----------------------
varying vec2 v_texCoord[MAX_TEXTURES];
varying lowp vec4 v_color;
varying vec3 v_bumpMapLightDir;				/**< Direction to the first light in tangent space. */

//-------------- CONSTANTS ----------------------
const vec3 kVec3Half = vec3(0.5, 0.5, 0.5);

//-------------- LOCAL VARIABLES ----------------------
vec4 fragColor;


//-------------- FUNCTIONS ----------------------

/**
 * Provide texture combining functionality similar to OpenGL ES 1.1, to combine the texel
 * from the specified texture unit with the existing fragment color.
 *
 * This function is called from applyTexture when the texture unit mode is set to GL_COMBINE.
 *
 * The implementation of this function is a simplification of some of the OpenGL ES 1.1
 * configuration options. It only uses two source channels (and therefore does not support
 * the triple-source GL_INTERPOLATE function), and assumes that all source operands reference
 * the source component directly (ie- no (1 - src)).
 */
void combineTexture(int tuIdx, vec4 texColor) {
	int func, src0, src1;
	
	// Extract the RGB components from the appropriate sources
	func = u_cc3TextureUnits[tuIdx].combineRGBFunction;
	src0 = u_cc3TextureUnits[tuIdx].rgbSource0;
	src1 = u_cc3TextureUnits[tuIdx].rgbSource1;

	vec3 rgb0 = texColor.rgb;		// GL_TEXTURE
	if (src0 == GL_PREVIOUS) rgb0 = fragColor.rgb;
	if (src0 == GL_CONSTANT) rgb0 = u_cc3TextureUnits[tuIdx].color.rgb;
	
	vec3 rgb1 = fragColor.rgb;		// GL_PREVIOUS
	if (src1 == GL_TEXTURE) rgb1 = texColor.rgb;
	if (src1 == GL_CONSTANT) rgb1 = u_cc3TextureUnits[tuIdx].color.rgb;

	// Combine the RGB components
	if (func == GL_MODULATE)
		fragColor.rgb = rgb0 * rgb1;
	else if (func == GL_DOT3_RGBA) {
		if (u_cc3HasVertexTangent)		// Bump-map using tangent-space light dir
			fragColor = vec4(2.0 * dot(rgb0 - kVec3Half, v_bumpMapLightDir));
		else							// Bump-map using model-space light dir (from const color)
			fragColor = vec4(4.0 * dot(rgb0 - kVec3Half, rgb1 - kVec3Half));
	}
	else if (func == GL_DOT3_RGB) {
		if (u_cc3HasVertexTangent)		// Bump-map using tangent-space light dir
			fragColor.rgb = vec3(2.0 * dot(rgb0 - kVec3Half, v_bumpMapLightDir));
		else							// Bump-map using model-space light dir (from const color)
			fragColor.rgb = vec3(4.0 * dot(rgb0 - kVec3Half, rgb1 - kVec3Half));
	}
	else if (func == GL_ADD)
		fragColor.rgb = rgb0 + rgb1;
	else if (func == GL_ADD_SIGNED)
		fragColor.rgb = rgb0 + rgb1 - 0.5;
	else if (func == GL_REPLACE)
		fragColor.rgb = rgb0;
	else if (func == GL_SUBTRACT)
		fragColor.rgb = rgb0 - rgb1;
	
	// Extract the alpha components from the appropriate sources
	func = u_cc3TextureUnits[tuIdx].combineAlphaFunction;
	src0 = u_cc3TextureUnits[tuIdx].alphaSource0;
	src1 = u_cc3TextureUnits[tuIdx].alphaSource1;

	float a0 = texColor.a;			// GL_TEXTURE
	if (src0 == GL_PREVIOUS) a0 = fragColor.a;
	if (src0 == GL_CONSTANT) a0 = u_cc3TextureUnits[tuIdx].color.a;
	
	float a1 = fragColor.a;			// GL_PREVIOUS
	if (src1 == GL_TEXTURE) a1 = texColor.a;
	if (src1 == GL_CONSTANT) a1 = u_cc3TextureUnits[tuIdx].color.a;

	// Combine the alpha components
	if (func == GL_MODULATE)
		fragColor.a = a0 * a1;
	else if (func == GL_ADD)
		fragColor.a = a0 + a1;
	else if (func == GL_ADD_SIGNED)
		fragColor.a = a0 + a1 - 0.5;
	else if (func == GL_REPLACE)
		fragColor.a = a0;
	else if (func == GL_SUBTRACT)
		fragColor.a = a0 - a1;
}

/**
 * Applies the texture assigned to the specified texture unit index, combining it with
 * the fragment color already applied as defined by the texture unit parameters.
 */
void applyTexture(int tuIdx) {
	vec4 texColor = texture2D(s_cc3Textures[tuIdx], v_texCoord[tuIdx]);
	int tuMode = u_cc3TextureUnits[tuIdx].mode;
	
	if (tuMode == GL_MODULATE) {
		fragColor *= texColor;
	} else if (tuMode == GL_REPLACE) {
		fragColor = texColor;
	} else if (tuMode == GL_COMBINE) {
		combineTexture(tuIdx, texColor);
	} else if (tuMode == GL_ADD) {
		fragColor.rgb += texColor.rgb;
		fragColor.a *= texColor.a;
	} else if (tuMode == GL_DECAL) {
		fragColor.rgb = (texColor.rgb * texColor.a) + (fragColor.rgb * (1.0 - texColor.a));
	} else if (tuMode == GL_BLEND) {
		fragColor.rgb =  (fragColor.rgb * (1.0 - texColor.rgb)) + (u_cc3TextureUnits[tuIdx].color.rgb * texColor.rgb);
		fragColor.a *= texColor.a;
	}
}

/**
 * Applies any textures to the fragment, combining them as defined by the texture units,
 * and returns the resulting fragment color. If there are no textures, returns the fragment
 * color from the v_color varying input variable.
 */
void applyTextures() {
	for (int tuIdx = 0; tuIdx < MAX_TEXTURES; tuIdx++) {
		if (tuIdx >= u_cc3TextureCount) return;		// Break out once we've applied all the textures
		applyTexture(tuIdx);
	}
}

//-------------- ENTRY POINT ----------------------
void main() {
	fragColor = v_color;
	if (u_cc3Points.isDrawingPoints && u_cc3Points.shouldDisplayAsSprites)
		fragColor = texture2D(s_cc3Textures[0], gl_PointCoord) * v_color;
	else
		applyTextures();

	// If the fragment passes the alpha test, draw it, otherwise discard
	if (fragColor.a >= u_cc3Material.minimumDrawnAlpha)
		gl_FragColor = fragColor;
	else
		discard;
}

// ------------- ALTERNATE PERFORMANCE TESTING FUNCTIONS --------------

// This is a dummy alternate to the applyTextures function. It deliberately applies zero textures.
// By pretending to make use of the applyTexture() function, all of the uniforms remain active,
// allowing the testing of the CPU overhead when setting large numbers of uniforms.
void applyNoTextures() { for (int tuIdx = 0; tuIdx < 0; tuIdx++) applyTexture(tuIdx); }

// Alternate main function that deliberately applies no textures and directly assigns the fragment
// color from the varying variable. The applyNoTextures function fools the compiler into thinking
// that textures will be applied, thereby causing the compiler to keep all of the uniforms active.
// This permits analysis of the overhead on the CPU of a large number of uniforms. To see the effect,
// comment out the normal main function and uncomment this version. For even better performance,
// comment out the call to applyNoTextures below, to avoid the binding of the additional uniforms.
/*
void main() {
	applyNoTextures();
	gl_FragColor = v_color;
}
*/
