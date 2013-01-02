/*
 * CC3DefaultByVarNames.vsh
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

/**
 * When running under OpenGL ES 2, this vertex shader is used as a default when a
 * CC3Material has not been assigned a specific GL shader program.
 *
 * CC3DefaultByVarNames.fsh is the fragment shader associated with this vertex shader.
 *
 * The semantics of the variables in this shader can be mapped using the
 * CC3GLProgramSemanticsDelegateByVarNames sharedDefaultDelegate instance.
 */

#define MAX_TEXTURES			4
#define MAX_LIGHTS				4

precision mediump float;

//-------------- STRUCTURES ----------------------

/**
 * The parameters that define a single light.
 *
 * When using this structure as the basis of a simpler implementation, remove any elements
 * that your shader does not use, to reduce the number of uniforms that need to be retrieved
 * and pased to your shader (uniform structure elements are passed individually in GLSL).
 */
struct Light {
	vec4	position;							/**< Position or normalized direction in eye space. */
	vec4	colorAmbient;						/**< Ambient color of light. */
	vec4	colorDiffuse;						/**< Diffuse color of light. */
	vec4	colorSpecular;						/**< Specular color of light. */
	vec3	attenuation;						/**< Coefficients of the attenuation equation. */
	vec3	spotDirection;						/**< Direction if spotlight in eye space. */
	float	spotExponent;						/**< Directional attenuation factor if spotlight. */
	float	spotCutoffAngleCosine;				/**< Cosine of spotlight cutoff angle. */
	bool	isEnabled;							/**< Whether light is enabled. */
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

// Environment matrices
uniform mat4 u_cc3MtxMV;						/**< Current modelview matrix. */
uniform mat3 u_cc3MtxMVIT;						/**< Inverse-transpose of current modelview rotation matrix. */
uniform mat4 u_cc3MtxMVP;						/**< Current modelview-projection matrix. */

// Material properties
uniform vec4 u_cc3MatColorAmbient;				/**< Ambient color of the material. */
uniform vec4 u_cc3MatColorDiffuse;				/**< Diffuse color of the material. */
uniform vec4 u_cc3MatColorSpecular;				/**< Specular color of the material. */
uniform vec4 u_cc3MatColorEmission;				/**< Emission color of the material. */
uniform float u_cc3MatShininess;					/**< Shininess of the material. */

// Lighting properties
uniform bool u_cc3IsUsingLighting;				/**< Indicates whether any lighting is in use. */
uniform vec4 u_cc3SceneLightColorAmbient;		/**< Ambient light color of the scene. */
uniform Light u_cc3Lights[MAX_LIGHTS];			/**< Array of lights. */

// Uniforms describing vertex attributes.
uniform bool u_cc3HasVertexNormal;				/**< Whether vertex normal attribute is available. */
uniform bool u_cc3ShouldNormalizeNormal;		/**< Whether vertex normals should be normalized. */
uniform bool u_cc3ShouldRescaleNormal;			/**< Whether vertex normals should be rescaled. */
uniform bool u_cc3HasVertexColor;				/**< Whether vertex color attribute is available. */
uniform lowp int u_cc3TextureCount;				/**< Number of textures. */
uniform Point u_cc3Points;						/**< Point parameters. */


//-------------- VERTEX ATTRIBUTES ----------------------
attribute highp vec4 a_cc3Position;				/**< Vertex position. */
attribute vec3 a_cc3Normal;						/**< Vertex normal. */
attribute vec4 a_cc3Color;						/**< Vertex color. */
attribute float a_cc3PointSize;					/**< Vertex point size. */
attribute vec2 a_cc3TexCoord0;					/**< Vertex texture coordinate for texture unit 0. */
attribute vec2 a_cc3TexCoord1;					/**< Vertex texture coordinate for texture unit 1. */
attribute vec2 a_cc3TexCoord2;					/**< Vertex texture coordinate for texture unit 2. */
attribute vec2 a_cc3TexCoord3;					/**< Vertex texture coordinate for texture unit 3. */

//-------------- VARYING VARIABLES OUTPUTS ----------------------
varying vec2 v_texCoord[MAX_TEXTURES];			/**< Fragment texture coordinates. */
varying lowp vec4 v_color;						/**< Fragment base color. */

//-------------- LOCAL VARIABLES ----------------------
vec4 matColorAmbient;		/**< Ambient color of material...from either material or vertex colors. */
vec4 matColorDiffuse;		/**< Diffuse color of material...from either material or vertex colors. */
vec3 vtxPosEye;				/**< The position of the vertex, in eye coordinates. */
vec3 vtxNormal;				/**< The vertex normal. */

//-------------- CONSTANTS ----------------------
const vec3 kVec3Zero = vec3(0.0, 0.0, 0.0);
const vec3 kAttenuationNone = vec3(1.0, 0.0, 0.0);
const vec3 kHalfPlaneOffset = vec3(0.0, 0.0, 1.0);


//-------------- FUNCTIONS ----------------------

/** Returns the vertex position in eye space, if it is needed. Otherwise, returns the zero vector. */
vec3 vertexPositionInEyeSpace() {
	if((u_cc3IsUsingLighting && u_cc3HasVertexNormal) ||
	   (u_cc3Points.isDrawingPoints && u_cc3Points.sizeAttenuation != kAttenuationNone))
		return (u_cc3MtxMV * a_cc3Position).xyz;
	else
		return kVec3Zero;
}

/** 
 * Returns the portion of vertex color attributed to illumination of
 * the material by the light at the specified index.
 */
vec4 illuminateWith(int ltIdx) {
	vec3 ltDir;
	float attenuation = 1.0;
	
	if (u_cc3Lights[ltIdx].position.w != 0.0) {
		// Positional light. Find direction to vertex.
		ltDir = u_cc3Lights[ltIdx].position.xyz - vtxPosEye;
		
		if (u_cc3Lights[ltIdx].attenuation != kAttenuationNone) {
			float ltDist = length(ltDir);
			vec3 attenuationEquation = vec3(1.0, ltDist, ltDist * ltDist);
			attenuation = 1.0 / dot(attenuationEquation, u_cc3Lights[ltIdx].attenuation);
		}
		ltDir = normalize(ltDir);
		
		// Determine attenuation due to spotlight component
		if (u_cc3Lights[ltIdx].spotCutoffAngleCosine >= 0.0) {
			float spotAttenuation = dot(-ltDir, u_cc3Lights[ltIdx].spotDirection);
			spotAttenuation = (spotAttenuation >= u_cc3Lights[ltIdx].spotCutoffAngleCosine)
									? pow(spotAttenuation, u_cc3Lights[ltIdx].spotExponent)
									: 0.0;
			attenuation *= spotAttenuation;
		}
    } else {
		// Directional light. Vector is expected to be normalized!
		ltDir = u_cc3Lights[ltIdx].position.xyz;
    }
	
	// Employ lighting equation to calculate vertex color
	vec4 vtxColor = vec4(0.0);
    if(attenuation > 0.0) {
		vtxColor += (u_cc3Lights[ltIdx].colorAmbient * matColorAmbient);
		vtxColor += (u_cc3Lights[ltIdx].colorDiffuse * matColorDiffuse * max(0.0, dot(vtxNormal, ltDir)));
		
		// Project normal onto half-plane vector to determine specular component
		float specProj = dot(vtxNormal, normalize(ltDir + kHalfPlaneOffset));
		if (specProj > 0.0) {
			vtxColor += (pow(specProj, u_cc3MatShininess) *
						 u_cc3MatColorSpecular *
						 u_cc3Lights[ltIdx].colorSpecular);
		}
		vtxColor *= attenuation;
    }
    return vtxColor;
}

/**
 * Returns the vertex color by starting with material emission and ambient scene lighting,
 * and then illuminating the material with each enabled light.
 */
vec4 illuminate() {
	vec4 vtxColor = u_cc3MatColorEmission + (matColorAmbient * u_cc3SceneLightColorAmbient);

	for (int ltIdx = 0; ltIdx < MAX_LIGHTS; ltIdx++)
		if (u_cc3Lights[ltIdx].isEnabled) vtxColor += illuminateWith(ltIdx);
	
	vtxColor.a = matColorDiffuse.a;
	return vtxColor;
}

/** 
 * If this vertices are being drawn as points, returns the size of the point for the current vertex.
 * If the size is not needed, or if the size cannot be determined, returns the value one.
 */
float pointSize() {
	float size = 1.0;
	if (u_cc3Points.isDrawingPoints) {
		size = u_cc3Points.hasVertexPointSize ? a_cc3PointSize : u_cc3Points.size;
		if (u_cc3Points.sizeAttenuation != kAttenuationNone && u_cc3Points.sizeAttenuation != kVec3Zero) {
			float ptDist = length(vtxPosEye);
			vec3 attenuationEquation = vec3(1.0, ptDist, ptDist * ptDist);
			size /= sqrt(dot(attenuationEquation, u_cc3Points.sizeAttenuation));
		}
		size = clamp(size, u_cc3Points.minimumSize, u_cc3Points.maximumSize);
	}
	return size;
}


//-------------- ENTRY POINT ----------------------
void main() {

	// If vertices have individual colors, use them for ambient and diffuse material colors.
	matColorAmbient = u_cc3HasVertexColor ? a_cc3Color : u_cc3MatColorAmbient;
	matColorDiffuse = u_cc3HasVertexColor ? a_cc3Color : u_cc3MatColorDiffuse;

	// The vertex position in eye space. If not needed, it is simply set to the zero vector.
	vtxPosEye = vertexPositionInEyeSpace();

	// Material & lighting
	if (u_cc3IsUsingLighting && u_cc3HasVertexNormal) {
		// Transform vertex normal using inverse-transpose of modelview and renormalize if needed.
		vtxNormal = u_cc3MtxMVIT * a_cc3Normal;
		if (u_cc3ShouldRescaleNormal) vtxNormal = normalize(vtxNormal);	// TODO - rescale without having to normalize
		if (u_cc3ShouldNormalizeNormal) vtxNormal = normalize(vtxNormal);

		v_color = illuminate();
	} else {
		v_color = matColorDiffuse;
	}

	// Fragment texture coordinates
	if (u_cc3TextureCount > 0) v_texCoord[0] = a_cc3TexCoord0;
	if (u_cc3TextureCount > 1) v_texCoord[1] = a_cc3TexCoord1;
	if (u_cc3TextureCount > 2) v_texCoord[2] = a_cc3TexCoord2;
	if (u_cc3TextureCount > 3) v_texCoord[3] = a_cc3TexCoord3;
	
	gl_Position = u_cc3MtxMVP * a_cc3Position;
	
	gl_PointSize = pointSize();
}

