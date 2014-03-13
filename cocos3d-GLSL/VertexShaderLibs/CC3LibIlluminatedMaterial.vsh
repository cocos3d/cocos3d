/*
 * CC3LibIlluminatedMaterial.vsh
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

/**
 * This vertex shader library adds a material that is illuminated by lights.
 *
 * This library requires the following local variables be declared and populated outside this library:
 *   - highp vec4			vtxPosition;						// The vertex position. High prec to match vertex attribute.
 *   - vec3					vtxNormal;							// The vertex normal.
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - attribute vec4		a_cc3Color;							// Vertex color.
 *
 *   - uniform lowp vec4	u_cc3Color;							// Color when lighting & materials are not in use.
 *   - uniform lowp vec4	u_cc3MaterialAmbientColor;			// Ambient color of the material.
 *   - uniform lowp vec4	u_cc3MaterialDiffuseColor;			// Diffuse color of the material.
 *   - uniform lowp vec4	u_cc3MaterialSpecularColor;			// Specular color of the material.
 *   - uniform lowp vec4	u_cc3MaterialEmissionColor;			// Emission color of the material.
 *   - uniform float		u_cc3MaterialShininess;				// Shininess of the material.
 *   - uniform bool			u_cc3LightIsUsingLighting;			// Indicates whether any lighting is enabled
 *   - uniform lowp vec4	u_cc3LightSceneAmbientLightColor;	// Ambient light color of the scene.
 *   - uniform bool			u_cc3LightIsLightEnabled[];			// Indicates whether each light is enabled.
 *   - uniform highp vec4	u_cc3LightPositionModel[];			// Position or normalized direction in the local coords of the model of each light.
 *   - uniform lowp vec4	u_cc3LightAmbientColor[];			// Ambient color of each light.
 *   - uniform lowp vec4	u_cc3LightDiffuseColor[];			// Diffuse color of each light.
 *   - uniform lowp vec4	u_cc3LightSpecularColor[];			// Specular color of each light.
 *   - uniform highp vec3	u_cc3LightAttenuation[];			// Coefficients of the attenuation equation of each light.
 *   - uniform highp vec3	u_cc3LightSpotDirectionModel[];		// Direction of each spotlight in local coordinates of the model (not light).
 *   - uniform float		u_cc3LightSpotExponent[];			// Directional attenuation factor, if spotlight, of each light.
 *   - uniform float		u_cc3LightSpotCutoffAngleCosine[];	// Cosine of spotlight cutoff angle of each light.
 *   - uniform bool			u_cc3VertexHasColor;				// Whether the vertex color is available.
 *   - uniform bool			u_cc3VertexShouldDrawFrontFaces;	// Whether the front side of each face is to be drawn.
 *   - uniform bool			u_cc3VertexShouldDrawBackFaces;		// Whether the back side of each face is to be drawn.
 *   - uniform highp mat4	u_cc3MatrixModel;					// Current model-to-world matrix.
 *
 * This library declares and outputs the following variables:
 *   - varying lowp vec4	v_color;							// Fragment front-face color.
 *   - varying lowp vec4	v_colorBack;						// Fragment back-face color.
 */


#import "CC3LibConstants.vsh"
#import "CC3LibModelMatrices.vsh"
#import "CC3LibCameraPosition.vsh"


#define MAX_LIGHTS	4

attribute vec4		a_cc3Color;										/**< Vertex color. */

uniform lowp vec4	u_cc3Color;										/**< Color when lighting & materials are not in use. */
uniform lowp vec4	u_cc3MaterialDiffuseColor;						/**< Diffuse color of the material. */
uniform lowp vec3	u_cc3MaterialAmbientColor;						/**< Ambient color of the material. */
uniform lowp vec3	u_cc3MaterialSpecularColor;						/**< Specular color of the material. */
uniform lowp vec3	u_cc3MaterialEmissionColor;						/**< Emission color of the material. */
uniform float		u_cc3MaterialShininess;							/**< Shininess of the material. */

uniform bool		u_cc3LightIsUsingLighting;						/**< Indicates whether any lighting is enabled */
uniform lowp vec3	u_cc3LightSceneAmbientLightColor;				/**< Ambient light color of the scene. */
uniform bool		u_cc3LightIsLightEnabled[MAX_LIGHTS];			/**< Indicates whether each light is enabled. */
uniform highp vec4	u_cc3LightPositionModel[MAX_LIGHTS];			/**< Position or normalized direction in the local coords of the model of each light. */
uniform lowp vec3	u_cc3LightAmbientColor[MAX_LIGHTS];				/**< Ambient color of each light. */
uniform lowp vec3	u_cc3LightDiffuseColor[MAX_LIGHTS];				/**< Diffuse color of each light. */
uniform lowp vec3	u_cc3LightSpecularColor[MAX_LIGHTS];			/**< Specular color of each light. */
uniform highp vec3	u_cc3LightAttenuation[MAX_LIGHTS];				/**< Coefficients of the attenuation equation of each light. */
uniform highp vec3	u_cc3LightSpotDirectionModel[MAX_LIGHTS];		/**< Direction of each spotlight in local coordinates of the model (not light). */
uniform float		u_cc3LightSpotExponent[MAX_LIGHTS];				/**< Directional attenuation factor, if spotlight, of each light. */
uniform float		u_cc3LightSpotCutoffAngleCosine[MAX_LIGHTS];	/**< Cosine of spotlight cutoff angle of each light. */

uniform bool		u_cc3VertexHasColor;							/**< Whether the vertex color is available. */
uniform bool		u_cc3VertexShouldDrawFrontFaces;				/**< Whether the front side of each face is to be drawn. */
uniform bool		u_cc3VertexShouldDrawBackFaces;					/**< Whether the back side of each face is to be drawn. */

lowp vec4			matColorDiffuse;								/**< Diffuse color of material...from either material or vertex colors. */
lowp vec3			matColorAmbient;								/**< Ambient color of material...from either material or vertex colors. */
lowp vec3			frontColor;										/**< Fragment front-face color. */
lowp vec3			backColor;										/**< Fragment back-face color. */

varying lowp vec4	v_color;										/**< Fragment front-face color. */
varying lowp vec4	v_colorBack;									/**< Fragment back-face color. */

/**
 * Returns a vector the contains the direction and intensity of light from the light at the
 * specified index, taking into consideration attenuation due to distance and spotlight dispersion.
 *
 * The use of highp on the floats is required due to the sensitivity of the calculations.
 * Compiler can crash when attempting to cast back and forth.
 */
highp vec4 illuminationFrom(int ltIdx) {
	
	// Position vector from light. Use high precision for accuracy.
	highp vec3 ltPos = u_cc3LightPositionModel[ltIdx].xyz;
	
	// Directional light. Position is expected to be a normalized direction!
	if (u_cc3LightPositionModel[ltIdx].w == 0.0) return highp vec4(ltPos, 1.0);
	
	// Positional light. Find the directional vector from vertex to light, but don't normalize yet.
	ltPos -= vtxPosition.xyz;
	highp float intensity = 1.0;
	
	// Calculate intensity due to distance attenuation (must be performed in high precision)
	// Light-vertex vector is transformed to global-space to take length measurement in global coords.
	if (u_cc3LightAttenuation[ltIdx] != kAttenuationNone) {
		highp float ltDist = length(u_cc3MatrixModel* vec4(ltPos, 0.0));
		highp vec3 distAtten = highp vec3(1.0, ltDist, ltDist * ltDist);
		highp float distIntensity = 1.0 / dot(distAtten, u_cc3LightAttenuation[ltIdx]);	// needs highp
		intensity *= min(abs(distIntensity), 1.0);
	}
	
	ltPos = normalize(ltPos);	// Now normalize into a unit direction vector.
	
	// Determine intensity due to spotlight component
	highp float spotCutoffCos = u_cc3LightSpotCutoffAngleCosine[ltIdx];
	if (spotCutoffCos >= 0.0) {
		highp vec3 spotDir = u_cc3LightSpotDirectionModel[ltIdx];
		highp float cosDir = -dot(ltPos, spotDir);
		if (cosDir >= spotCutoffCos){
			highp float spotExp = u_cc3LightSpotExponent[ltIdx];
			intensity *= pow(cosDir, spotExp);
		} else {
			intensity = 0.0;
		}
	}
	
	return highp vec4(ltPos, intensity);	// Return combined light direction & intensity
}

/**
 * Returns the portion of vertex color attributed to the specified illumination, which
 * contains the direction and intensity of the light at the specified index. The color is
 * determined by the interaction between the illumination and the specified vertex normal.
 *
 * The use of highp on the illumination is required due to the sensitivity of the
 * calculations, as the compiler can crash when attempting to cast back and forth.
 * Similarly, the use of the default mediump for the return value, instead of lowp,
 * avoids a strange execution stalling during drawing if lowp is returned!
 */
vec3 illuminateWith(highp vec4 illumination, int ltIdx, vec3 vNorm) {
	
	highp float intensity = illumination.w;
	if (intensity <= 0.0) return kVec3Zero;		// If no intensity, short-circuit to no color
	
	highp vec3 ltDir = illumination.xyz;
	
	// Employ lighting equation to calculate vertex color, using mediump for accuracy.
	vec3 vtxColor = (u_cc3LightAmbientColor[ltIdx] * matColorAmbient);
	vtxColor += (u_cc3LightDiffuseColor[ltIdx] * matColorDiffuse.rgb * max(0.0, dot(vNorm, ltDir)));
	
	// Project normal onto half-plane vector (between ltDir & camDir) to determine specular component.
	// This is an efficient proxy for projecting the reflection vector onto the eye-direction.
	highp vec3 camDir = normalize(u_cc3CameraPositionModel - vtxPosition.xyz);
	highp vec3 halfPlane = normalize(ltDir + camDir);
	highp float specProj = dot(vNorm, halfPlane);
	if (specProj > 0.0) vtxColor += (pow(specProj, u_cc3MaterialShininess) *
									 u_cc3MaterialSpecularColor *
									 u_cc3LightSpecularColor[ltIdx]);
	
	return vtxColor * intensity;	// Return the attenuated vertex color
}

/** Adjusts the vertex color by illuminating the material with each enabled light. */
void illuminateVertex() {
	for (int ltIdx = 0; ltIdx < MAX_LIGHTS; ltIdx++) {
		if (u_cc3LightIsLightEnabled[ltIdx]) {
			highp vec4 illum = illuminationFrom(ltIdx);
			if (u_cc3VertexShouldDrawFrontFaces) frontColor += illuminateWith(illum, ltIdx, vtxNormal);
			if (u_cc3VertexShouldDrawBackFaces) backColor += illuminateWith(illum, ltIdx, -vtxNormal);
		}
	}
}

/** Sets the color of the vertex by applying material & lighting, or using a pure color. */
void paintVertex() {
	if (u_cc3LightIsUsingLighting) {

		// If vertices have individual colors, use them for ambient and diffuse material colors.
		if (u_cc3VertexHasColor) {
			matColorDiffuse = a_cc3Color;
			matColorAmbient = a_cc3Color.rgb;
		} else {
			matColorDiffuse = u_cc3MaterialDiffuseColor;
			matColorAmbient = u_cc3MaterialAmbientColor.rgb;
		}
		
		frontColor = u_cc3MaterialEmissionColor + (matColorAmbient * u_cc3LightSceneAmbientLightColor);
		backColor = frontColor;
		
		illuminateVertex();
		
		v_color = vec4(frontColor, matColorDiffuse.a);
		v_colorBack = vec4(backColor, matColorDiffuse.a);
		
	} else {
		v_color = (u_cc3VertexHasColor ? a_cc3Color : u_cc3Color);
		v_colorBack = v_color;
	}
}

