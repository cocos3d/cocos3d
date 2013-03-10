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
#define MAX_BONES_PER_VERTEX	20

precision mediump float;

//-------------- STRUCTURES ----------------------

/**
 * The various transform matrices.
 *
 * When using this structure as the basis of a simpler implementation, you can comment-out
 * or remove any elements that are not used by either your vertex or fragment shaders, to
 * reduce the number of values that need to be retrieved and passed to your shader.
 */
struct Matrices {
//	highp mat4	modelLocal;				/**< Current model-to-parent matrix. */
//	mat4		modelLocalInv;			/**< Inverse of current model-to-parent matrix. */
//	mat3		modelLocalInvTran;		/**< Inverse-transpose of current model-to-parent rotation matrix. */
	
//	highp mat4	model;					/**< Current model-to-world matrix. */
//	mat4		modelInv;				/**< Inverse of current model-to-world matrix. */
//	mat3		modelInvTran;			/**< Inverse-transpose of current model-to-world rotation matrix. */
	
//	highp mat4	view;					/**< Camera view matrix. */
//	mat4		viewInv;				/**< Inverse of camera view matrix. */
//	mat3		viewInvTran;			/**< Inverse-transpose of camera view rotation matrix. */
	
	highp mat4	modelView;				/**< Current modelview matrix. */
//	mat4		modelViewInv;			/**< Inverse of current modelview matrix. */
//	mat3		modelViewInvTran;		/**< Inverse-transpose of current modelview rotation matrix. */
	
	highp mat4	proj;					/**< Projection matrix. */
//	mat4		projInv;				/**< Inverse of projection matrix. */
//	mat3		projInvTran;			/**< Inverse-transpose of projection rotation matrix. */
	
//	highp mat4	viewProj;				/**< Camera view and projection matrix. */
//	mat4		viewProjInv;			/**< Inverse of camera view and projection matrix. */
//	mat3		viewProjInvTran;		/**< Inverse-transpose of camera view and projection rotation matrix. */
	
//	highp mat4	modelViewProj;			/**< Current modelview-projection matrix. */
//	mat4		modelViewProjInv;		/**< Inverse of current modelview-projection matrix. */
//	mat3		modelViewProjInvTran;	/**< Inverse-transpose of current modelview-projection rotation matrix. */
};

/**
 * The parameters to use when deforming vertices using bones.
 *
 * When using this structure as the basis of a simpler implementation, you can comment-out
 * or remove any elements that are not used by either your vertex or fragment shaders, to
 * reduce the number of values that need to be retrieved and passed to your shader.
 */
struct Bones {
	lowp int	bonesPerVertex;									/**< Number of bones influencing each vertex. */
	highp mat4	matricesEyeSpace[MAX_BONES_PER_VERTEX];			/**< Array of bone matrices in the current mesh skin section in eye space. */
	mat3		matricesInvTranEyeSpace[MAX_BONES_PER_VERTEX];	/**< Array of inverse-transposes of the bone matrices in the current mesh skin section in eye space. */
//	highp mat4	matricesGlobal[MAX_BONES_PER_VERTEX];			/**< Array of bone matrices in the current mesh skin section in global coordinates. */
//	mat3		matricesInvTranGlobal[MAX_BONES_PER_VERTEX];	/**< Array of inverse-transposes of the bone matrices in the current mesh skin section in global coordinates. */
};

/**
 * The parameters to use when displaying vertices as points.
 *
 * When using this structure as the basis of a simpler implementation, you can comment-out
 * or remove any elements that are not used by either your vertex or fragment shaders, to
 * reduce the number of values that need to be retrieved and passed to your shader.
 */
struct Point {
	float	size;							/**< Default size of points, if not specified per-vertex. */
	float	minimumSize;					/**< Minimum size to which points will be allowed to shrink. */
	float	maximumSize;					/**< Maximum size to which points will be allowed to grow. */
	vec3	sizeAttenuation;				/**< Coefficients of the size attenuation equation. */
	bool	isDrawingPoints;				/**< Whether the vertices are being drawn as points. */
	bool	hasVertexPointSize;				/**< Whether vertex point size attribute is available. */
	bool	shouldDisplayAsSprites;			/**< Whether points should be interpeted as textured sprites. */
};


//-------------- UNIFORMS ----------------------

uniform Matrices u_cc3Matrices;			/**< The transform matrices. */
uniform Point u_cc3Points;				/**< Point parameters. */
uniform Bones u_cc3Bones;				/**< Bone transforms. */

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
	if (u_cc3Bones.bonesPerVertex > 0) {		// Mesh is bone-rigged for vertex skinning
		// Copies of the indices and weights attibutes so they can be "rotated"
		mediump ivec4 boneIndices = ivec4(a_cc3BoneIndices);
		mediump vec4 boneWeights = a_cc3BoneWeights;
		
		vtxPosEye = vec4(0.0);		// Start at zero to accumulate weighted values
		for (lowp int i = 0; i < 4; ++i) {		// Max 4 bones per vertex
			if (i < u_cc3Bones.bonesPerVertex) {
				// Add position contribution from this bone
				vtxPosEye += u_cc3Bones.matricesEyeSpace[boneIndices.x] * a_cc3Position * boneWeights.x;
				
				// "Rotate" the vector components to the next vertex bone index
				boneIndices = boneIndices.yzwx;
				boneWeights = boneWeights.yzwx;
			}
		}
	} else {		// No vertex skinning
		vtxPosEye = u_cc3Matrices.modelView * a_cc3Position;
	}
}

/**
 * If this vertices are being drawn as points, returns the size of the point for the current vertex.
 * If the size is not needed, or if the size cannot be determined, returns the value one.
 */
float pointSize() {
	float size = 1.0;
	if (u_cc3Points.isDrawingPoints) {
		size = u_cc3Points.hasVertexPointSize ? a_cc3PointSize : u_cc3Points.size;
		if (u_cc3Points.sizeAttenuation != kAttenuationNone) {
			float ptDist = length(vtxPosEye.xyz);
			vec3 attenuationEquation = vec3(1.0, ptDist, ptDist * ptDist);
			size /= sqrt(dot(attenuationEquation, u_cc3Points.sizeAttenuation));
		}
		size = clamp(size, u_cc3Points.minimumSize, u_cc3Points.maximumSize);
	}
	return size;
}


//-------------- ENTRY POINT ----------------------
void main() {

	// Transform vertex position to eye space, in vtxPosEye.
	vertexToEyeSpace();

	gl_Position = u_cc3Matrices.proj * vtxPosEye;
	
	gl_PointSize = pointSize();
}

