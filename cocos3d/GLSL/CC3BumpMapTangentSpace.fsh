/*
 * CC3BumpMapTangentSpace.fsh
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
 * This fragment shader performs tangent-space bump-mapping.
 *
 * The texture in texture unit 0 contains a map of tangent-space normals, encoded in the
 * texel RGB colors.
 *
 * An optional second texture in texture unit 1 contains the visible texture to be applied on
 * top of the bump-mapped texture. If this texture is not available, the fragment color is used.
 *
 * CC3BumpMapTangentSpace.vsh is the vertex shader paired with this fragment shader.
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3GLProgramSemanticsByVarName instance.
 */

// Increase this if more textures are desired.
#define MAX_TEXTURES			2

// Fog modes.
#define GL_LINEAR                 0x2601
#define GL_EXP                    0x0800
#define GL_EXP2                   0x0801


precision mediump float;

//-------------- STRUCTURES ----------------------

/**
 * The parameters that define a material.
 *
 * When using this structure as the basis of a simpler implementation, you can comment-out
 * or remove any elements that are not used by either your vertex or fragment shaders, to
 * reduce the number of values that need to be retrieved and passed to your shader.
 */
struct Material {
	vec4	ambientColor;					/**< Ambient color of the material. */
	vec4	diffuseColor;					/**< Diffuse color of the material. */
	vec4	specularColor;					/**< Specular color of the material. */
	vec4	emissionColor;					/**< Emission color of the material. */
	float	shininess;						/**< Shininess of the material. */
	float	minimumDrawnAlpha;				/**< Minimum alpha value to be drawn, otherwise fragment will be discarded. */
};

/**
 * The parameters that define the scene fog.
 *
 * When using this structure as the basis of a simpler implementation, you can comment-out
 * or remove any elements that are not used by either your vertex or fragment shaders, to
 * reduce the number of values that need to be retrieved and passed to your shader.
 */
struct Fog {
	bool		isEnabled;					/**< Whether scene fogging is enabled. */
	lowp vec4	color;						/**< Fog color. */
	int			attenuationMode;			/**< Fog attenuation mode (one of GL_LINEAR, GL_EXP or GL_EXP2). */
	highp float	density;					/**< Fog density. */
	highp float	startDistance;				/**< Distance from camera at which fogging effect starts. */
	highp float	endDistance;				/**< Distance from camera at which fogging effect ends. */
};


//-------------- UNIFORMS ----------------------

uniform Material u_cc3Material;					/**< The material being applied to the mesh. */
uniform Fog u_cc3Fog;							/**< Scene fog. */
uniform lowp int u_cc3TextureCount;				/**< Number of textures. */
uniform sampler2D s_cc3Textures[MAX_TEXTURES];	/**< Texture samplers. */

//-------------- VARYING VARIABLE INPUTS ----------------------
varying vec2 v_texCoord[MAX_TEXTURES];		/**< Fragment texture coordinates. */

varying lowp vec4 v_color;					/**< Fragment base color. */
varying highp float v_distEye;				/**< Fragment distance in eye coordinates. */
varying vec3 v_bumpMapLightDir;				/**< Direction to the first light in tangent space. */

//-------------- CONSTANTS ----------------------
const vec3 kVec3Half = vec3(0.5, 0.5, 0.5);

//-------------- LOCAL VARIABLES ----------------------
vec4 fragColor;


//-------------- FUNCTIONS ----------------------

/** 
 * Applies the texel from the bump map texture.
 *
 * Transforms the normal from range [0, 1] to [-1, 1], takes dot product with light direction
 * for interaction between normal and light vector, sets it into each of the RGB components,
 * and modulates the fragment color.
 */
void applyBumpMapTexel(vec4 texColor) {
	fragColor.rgb *= vec3(2.0 * dot(texColor.rgb - kVec3Half, v_bumpMapLightDir));
}

/** Applies the texel from the visible texture by applying simple modulation. */
void applyVisibleTexel(vec4 texColor) { fragColor *= texColor; }

/** Applies fog to the specified color and returns the adjusted color. */
vec4 fogify(vec4 aColor) {
	if (u_cc3Fog.isEnabled) {
		int mode = u_cc3Fog.attenuationMode;
		float vtxVisibility = 1.0;
		
		if (mode == GL_LINEAR) {
			vtxVisibility = (u_cc3Fog.endDistance - v_distEye) / (u_cc3Fog.endDistance - u_cc3Fog.startDistance);
		} else if (mode == GL_EXP) {
			float d = u_cc3Fog.density * v_distEye;
			vtxVisibility = exp(-d);
		} else if (mode == GL_EXP2) {
			float d = u_cc3Fog.density * v_distEye;
			vtxVisibility = exp(-(d * d));
		}
		vtxVisibility = clamp(vtxVisibility, 0.0, 1.0);
		aColor.rgb =  mix(u_cc3Fog.color.rgb, aColor.rgb, vtxVisibility);
	}
	return aColor;
}

//-------------- ENTRY POINT ----------------------
void main() {
	fragColor = v_color;
	if (u_cc3TextureCount > 0) applyBumpMapTexel(texture2D(s_cc3Textures[0], v_texCoord[0]));
	if (u_cc3TextureCount > 1) applyVisibleTexel(texture2D(s_cc3Textures[1], v_texCoord[1]));
	gl_FragColor = fogify(fragColor);
}
