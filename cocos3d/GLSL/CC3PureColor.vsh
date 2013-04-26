/*
 * CC3PureColor.vsh
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
 * When running under OpenGL ES 2, this vertex shader is used to paint a node with a pure color.
 *
 * This shader is used during node picking and when a node does not have a material.
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3GLProgramSemanticsByVarName instance.
 */

// Maximum bones per skin section (batch).
// Set this fairly high because this shader is used for touch detection painting
// for all other shaders. Apps with large skinned models might use many bones.
#define MAX_BONES_PER_BATCH		24

precision mediump float;

//-------------- UNIFORMS ----------------------

uniform highp mat4	u_cc3MatrixModelView;		/**< Current modelview matrix. */
uniform highp mat4	u_cc3MatrixProj;			/**< Projection matrix. */

uniform bool		u_cc3IsDrawingPoints;		/**< Whether the vertices are being drawn as points. */
uniform bool		u_cc3VertexHasPointSize;	/**< Whether vertex point size attribute is available. */
uniform float		u_cc3PointSize;				/**< Default size of points, if not specified per-vertex. */
uniform float		u_cc3PointMinimumSize;		/**< Minimum size to which points will be allowed to shrink. */
uniform float		u_cc3PointMaximumSize;		/**< Maximum size to which points will be allowed to grow. */
uniform vec3		u_cc3PointSizeAttenuation;	/**< Coefficients of the size attenuation equation. */

uniform lowp int	u_cc3BonesPerVertex;							/**< Number of bones influencing each vertex. */
uniform highp mat4	u_cc3BoneMatricesEyeSpace[MAX_BONES_PER_BATCH];	/**< Array of bone matrices in the current mesh skin section in eye space. */

//-------------- VERTEX ATTRIBUTES ----------------------
attribute highp vec4 a_cc3Position;		/**< Vertex position. */
attribute vec4 a_cc3BoneWeights;		/**< Vertex skinning bone weights (up to 4). */
attribute vec4 a_cc3BoneIndices;		/**< Vertex skinning bone matrix indices (up to 4). */
attribute float a_cc3PointSize;			/**< Vertex point size. */

//-------------- CONSTANTS ----------------------
const vec3 kVec3Zero = vec3(0.0, 0.0, 0.0);
const vec3 kAttenuationNone = vec3(1.0, 0.0, 0.0);

//-------------- LOCAL VARIABLES ----------------------
highp vec4 vtxPosEye;		/**< The position of the vertex, in eye coordinates. High prec required for point sizing calcs. */


//-------------- FUNCTIONS ----------------------

/**
 * Transforms the vertex position to eye space. Sets the vtxPosEye variable.
 * This function takes into consideration vertex skinning, if it is specified.
 */
void vertexToEyeSpace() {
	if (u_cc3BonesPerVertex > 0) {		// Mesh is bone-rigged for vertex skinning
		// Copies of the indices and weights attibutes so they can be "rotated"
		mediump ivec4 boneIndices = ivec4(a_cc3BoneIndices);
		mediump vec4 boneWeights = a_cc3BoneWeights;
		
		vtxPosEye = vec4(0.0);		// Start at zero to accumulate weighted values
		for (lowp int i = 0; i < 4; ++i) {		// Max 4 bones per vertex
			if (i < u_cc3BonesPerVertex) {
				// Add position contribution from this bone
				vtxPosEye += u_cc3BoneMatricesEyeSpace[boneIndices.x] * a_cc3Position * boneWeights.x;
				
				// "Rotate" the vector components to the next vertex bone index
				boneIndices = boneIndices.yzwx;
				boneWeights = boneWeights.yzwx;
			}
		}
	} else {		// No vertex skinning
		vtxPosEye = u_cc3MatrixModelView * a_cc3Position;
	}
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

	// Transform vertex position to eye space, in vtxPosEye.
	vertexToEyeSpace();

	gl_Position = u_cc3MatrixProj * vtxPosEye;
	
	gl_PointSize = pointSize();
}

