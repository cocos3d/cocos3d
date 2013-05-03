/*
 * CC3PointSprites.vsh
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
 * This vertex shader handles point sprites.
 *
 * This vertex shader can be paired with the following fragment shaders:
 *   - CC3PointSprites.fsh
 *   - CC3PointSpritesAlphaTest.fsh
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3GLProgramSemanticsByVarName instance.
 */

// Increase these if more lights are desired.
#define MAX_LIGHTS				4

precision mediump float;

//-------------- UNIFORMS ----------------------

uniform highp mat4	u_cc3MatrixModelView;			/**< Current modelview matrix. */
uniform mat3		u_cc3MatrixModelViewInvTran;	/**< Inverse-transpose of current modelview rotation matrix. */
uniform highp mat4	u_cc3MatrixProj;				/**< Projection matrix. */

uniform vec4		u_cc3Color;						/**< Color when lighting & materials are not in use. */
uniform vec4		u_cc3MaterialAmbientColor;		/**< Ambient color of the material. */
uniform vec4		u_cc3MaterialDiffuseColor;		/**< Diffuse color of the material. */
uniform vec4		u_cc3MaterialSpecularColor;		/**< Specular color of the material. */
uniform vec4		u_cc3MaterialEmissionColor;		/**< Emission color of the material. */
uniform float		u_cc3MaterialShininess;			/**< Shininess of the material. */

uniform bool		u_cc3LightIsUsingLighting;						/**< Indicates whether any lighting is enabled */
uniform lowp vec4	u_cc3LightSceneAmbientLightColor;				/**< Ambient light color of the scene. */
uniform bool		u_cc3LightIsLightEnabled[MAX_LIGHTS];			/**< Indicates whether each light is enabled. */
uniform vec4		u_cc3LightPositionEyeSpace[MAX_LIGHTS];			/**< Position or normalized direction in eye space of each light. */
uniform lowp vec4	u_cc3LightAmbientColor[MAX_LIGHTS];				/**< Ambient color of each light. */
uniform lowp vec4	u_cc3LightDiffuseColor[MAX_LIGHTS];				/**< Diffuse color of each light. */
uniform lowp vec4	u_cc3LightSpecularColor[MAX_LIGHTS];			/**< Specular color of each light. */
uniform vec3		u_cc3LightAttenuation[MAX_LIGHTS];				/**< Coefficients of the attenuation equation of each light. */
uniform vec3		u_cc3LightSpotDirectionEyeSpace[MAX_LIGHTS];	/**< Direction of spotlight in eye space of each light. */
uniform float		u_cc3LightSpotExponent[MAX_LIGHTS];				/**< Directional attenuation factor, if spotlight, of each light. */
uniform float		u_cc3LightSpotCutoffAngleCosine[MAX_LIGHTS];	/**< Cosine of spotlight cutoff angle of each light. */

uniform bool u_cc3VertexHasNormal;				/**< Whether the vertex normal is available. */
uniform bool u_cc3VertexHasColor;				/**< Whether the vertex color is available. */
uniform bool u_cc3VertexShouldNormalizeNormal;	/**< Whether the vertex normal should be normalized. */
uniform bool u_cc3VertexShouldRescaleNormal;	/**< Whether the vertex normal should be rescaled. */

uniform bool	u_cc3IsDrawingPoints;				/**< Whether the vertices are being drawn as points. */
uniform bool	u_cc3VertexHasPointSize;			/**< Whether vertex point size attribute is available. */
uniform bool	u_cc3PointShouldDisplayAsSprites;	/**< Whether points should be interpeted as textured sprites. */
uniform float	u_cc3PointSize;						/**< Default size of points, if not specified per-vertex. */
uniform float	u_cc3PointMinimumSize;				/**< Minimum size to which points will be allowed to shrink. */
uniform float	u_cc3PointMaximumSize;				/**< Maximum size to which points will be allowed to grow. */
uniform vec3	u_cc3PointSizeAttenuation;			/**< Coefficients of the size attenuation equation. */

//-------------- VERTEX ATTRIBUTES ----------------------
attribute highp vec4 a_cc3Position;		/**< Vertex position. */
attribute vec3 a_cc3Normal;				/**< Vertex normal. */
attribute vec4 a_cc3Color;				/**< Vertex color. */
attribute float a_cc3PointSize;			/**< Vertex point size. */

//-------------- VARYING VARIABLE OUTPUTS ----------------------
varying lowp vec4 v_color;				/**< Fragment base color. */
varying highp float v_distEye;			/**< Fragment distance in eye coordinates. */

//-------------- CONSTANTS ----------------------
const vec3 kVec3Zero = vec3(0.0);
const vec4 kVec4Zero = vec4(0.0);
const vec3 kAttenuationNone = vec3(1.0, 0.0, 0.0);
const vec3 kHalfPlaneOffset = vec3(0.0, 0.0, 1.0);

//-------------- LOCAL VARIABLES ----------------------
highp vec4 vtxPosEye;		/**< The vertex position in eye coordinates. High prec to match vertex attribute. */
vec3 vtxNormEye;			/**< The vertex normal in eye coordinates. */
vec4 matColorAmbient;		/**< Ambient color of material...from either material or vertex colors. */
vec4 matColorDiffuse;		/**< Diffuse color of material...from either material or vertex colors. */


//-------------- FUNCTIONS ----------------------

/** Transforms the vertex position and normal to eye space. Sets the vtxPosEye and vtxNormEye variables. */
void vertexToEyeSpace() {
	vtxPosEye = u_cc3MatrixModelView * a_cc3Position;
	vtxNormEye = u_cc3MatrixModelViewInvTran * a_cc3Normal;
	if (u_cc3VertexShouldRescaleNormal) vtxNormEye = normalize(vtxNormEye);	// TODO - rescale without having to normalize
	if (u_cc3VertexShouldNormalizeNormal) vtxNormEye = normalize(vtxNormEye);
}

/** 
 * Returns the portion of vertex color attributed to illumination of the material by the light at the
 * specified index, taking into consideration attenuation due to distance and spotlight dispersion.
 *
 * The use of highp on the floats is required due to the sensitivity of the calculations.
 * Compiler can crash when attempting to cast back and forth.
 */
vec4 illuminateWith(int ltIdx) {
	highp vec3 ltDir;
	highp float intensity = 1.0;
	
	if (u_cc3LightPositionEyeSpace[ltIdx].w != 0.0) {
		// Positional light. Find the direction from vertex to light.
		ltDir = (u_cc3LightPositionEyeSpace[ltIdx] - vtxPosEye).xyz;
		
		// Calculate intensity due to distance attenuation (must be performed in high precision)
		if (u_cc3LightAttenuation[ltIdx] != kAttenuationNone) {
			highp float ltDist = length(ltDir);
			highp vec3 distAtten = vec3(1.0, ltDist, ltDist * ltDist);
			highp float distIntensity = 1.0 / dot(distAtten, u_cc3LightAttenuation[ltIdx]);	// needs highp
			intensity *= min(abs(distIntensity), 1.0);
		}
		ltDir = normalize(ltDir);
		
		// Determine intensity due to spotlight component
		highp float spotCutoffCos = u_cc3LightSpotCutoffAngleCosine[ltIdx];
		if (spotCutoffCos >= 0.0) {
			highp vec3  spotDirEye = u_cc3LightSpotDirectionEyeSpace[ltIdx];
			highp float cosEyeDir = -dot(ltDir, spotDirEye);
			if (cosEyeDir >= spotCutoffCos){
				highp float spotExp = u_cc3LightSpotExponent[ltIdx];
				intensity *= pow(cosEyeDir, spotExp);
			} else {
				intensity = 0.0;
			}
		}
    } else {
		// Directional light. Vector is expected to be normalized!
		ltDir = u_cc3LightPositionEyeSpace[ltIdx].xyz;
    }
	
	// If no light intensity, short-circuit and return no color
	if (intensity <= 0.0) return kVec4Zero;
	
	// Employ lighting equation to calculate vertex color
	vec4 vtxColor = (u_cc3LightAmbientColor[ltIdx] * matColorAmbient);
	vtxColor += (u_cc3LightDiffuseColor[ltIdx] * matColorDiffuse * max(0.0, dot(vtxNormEye, ltDir)));
	
	// Project normal onto half-plane vector to determine specular component
	float specProj = dot(vtxNormEye, normalize(ltDir + kHalfPlaneOffset));
	if (specProj > 0.0) {
		vtxColor += (pow(specProj, u_cc3MaterialShininess) *
					 u_cc3MaterialSpecularColor *
					 u_cc3LightSpecularColor[ltIdx]);
	}
	
	// Return the attenuated vertex color
	return vtxColor * intensity;
}

/**
 * Returns the vertex color by starting with material emission and ambient scene lighting,
 * and then illuminating the material with each enabled light.
 */
vec4 illuminate() {
	vec4 vtxColor = u_cc3MaterialEmissionColor + (matColorAmbient * u_cc3LightSceneAmbientLightColor);

	for (int ltIdx = 0; ltIdx < MAX_LIGHTS; ltIdx++)
		if (u_cc3LightIsLightEnabled[ltIdx]) vtxColor += illuminateWith(ltIdx);
	
	vtxColor.a = matColorDiffuse.a;
	
	return vtxColor;
}

/** 
 * If this vertices are being drawn as points, returns the size of the point for the current vertex.
 * If the size is not needed, or if the size cannot be determined, returns the value one.
 */
float pointSize() {
	float size = 1.0;
	if (u_cc3IsDrawingPoints) {
		size = u_cc3VertexHasPointSize ? a_cc3PointSize : u_cc3PointSize;
		if (u_cc3PointSizeAttenuation != kAttenuationNone) {
			float ptDist = length(vtxPosEye.xyz);
			vec3 attenuationEquation = vec3(1.0, ptDist, ptDist * ptDist);
			size /= sqrt(dot(attenuationEquation, u_cc3PointSizeAttenuation));
		}
		size = clamp(size, u_cc3PointMinimumSize, u_cc3PointMaximumSize);
	}
	return size;
}

//-------------- ENTRY POINT ----------------------
void main() {

	// If vertices have individual colors, use them for ambient and diffuse material colors.
	matColorAmbient = u_cc3VertexHasColor ? a_cc3Color : u_cc3MaterialAmbientColor;
	matColorDiffuse = u_cc3VertexHasColor ? a_cc3Color : u_cc3MaterialDiffuseColor;

	// Transform vertex position and normal to eye space, in vtxPosEye and vtxNormEye, respectively.
	vertexToEyeSpace();
	
	// Distance from vertex to eye. Used for fog effect.
	v_distEye = length(vtxPosEye.xyz);
	
	// Determine the color of the vertex by applying material & lighting, or using a pure color
	if (u_cc3LightIsUsingLighting)
		v_color = illuminate();
	else
		v_color = u_cc3VertexHasColor ? a_cc3Color : u_cc3Color;
	
	gl_Position = u_cc3MatrixProj * vtxPosEye;
	
	gl_PointSize = pointSize();
}

