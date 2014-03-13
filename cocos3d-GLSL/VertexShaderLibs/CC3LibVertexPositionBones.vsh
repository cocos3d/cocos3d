/*
 * CC3LibVertexPositionBones.vsh
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
 * This vertex shader library establishes the position and normal of a vertex based on the movement
 * of underlying bones. Bones may be moved, rotated, and scaled. This allows very flexible movement
 * of each bone, however it does require that the app provide a full matrix (16 floats) for each bone,
 * which limits the number of bones that can be used per batch (skin section).
 *
 * If the bones can be restricted to rigid motion, more bones per batch can be accommodated
 * by using the CC3LibVertexPositionRigidBones.vsh library instead.
 *
 * The vertices are considered part of a skin that covers the bones, and moves along with them.
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - attribute highp vec4	a_cc3Position;						// Vertex position.
 *   - attribute vec3		a_cc3Normal;						// Vertex normal.
 *   - attribute vec3		a_cc3Tangent;						// Vertex tangent
 *   - attribute vec4		a_cc3BoneWeights;					// Vertex skinning bone weights (each an array of length specified by u_cc3VertexBoneCount).
 *   - attribute vec4		a_cc3BoneIndices;					// Vertex skinning bone indices (each an array of length specified by u_cc3VertexBoneCount).
 *
 *   - uniform lowp int		u_cc3VertexBoneCount;				// Number of bones influencing each vertex.
 *   - uniform highp mat4	u_cc3BoneMatricesModel[];			// Array of bone matrices in the current mesh skin section in model space.
 *   - uniform mat3			u_cc3BoneMatricesInvTranModel[];	// Array of inverse-transposes of the bone matrices in the current mesh skin section in model space.
 *
 *   - uniform bool			u_cc3VertexHasTangent;				// Whether the vertex tangent is available.
 *   - uniform bool			u_cc3VertexShouldNormalizeNormal;	// Whether the vertex normal should be normalized.
 *   - uniform bool			u_cc3VertexShouldRescaleNormal;		// Whether the vertex normal should be rescaled.
 *
 * This library declares and outputs the following variables:
 *   - highp vec4			vtxPosition;						// The vertex position. High prec to match vertex attribute.
 *   - vec3					vtxNormal;							// The vertex normal.
 *   - vec3					vtxTangent;							// The vertex tangent.
 *   - glPosition
 */


#import "CC3LibConstants.vsh"
#import "CC3LibModelMatrices.vsh"


#define MAX_BONES_PER_BATCH		12
#define MAX_BONES_PER_VERTEX	4

attribute highp vec4	a_cc3Position;		/**< Vertex position. */
attribute vec3			a_cc3Normal;		/**< Vertex normal. */
attribute vec3			a_cc3Tangent;		/**< Vertex tangent. */
attribute vec4			a_cc3BoneWeights;	/**< Vertex skinning bone weights (each an array of length specified by u_cc3VertexBoneCount). */
attribute vec4			a_cc3BoneIndices;	/**< Vertex skinning bone indices (each an array of length specified by u_cc3VertexBoneCount). */

uniform lowp int		u_cc3VertexBoneCount;								/**< Number of bones influencing each vertex. */
uniform highp mat4		u_cc3BoneMatricesModel[MAX_BONES_PER_BATCH];		/**< Array of bone matrices in the current mesh skin section in model space. */
uniform mat3			u_cc3BoneMatricesInvTranModel[MAX_BONES_PER_BATCH];	/**< Array of inverse-transposes of the bone matrices in the current mesh skin section in model space. */

uniform bool			u_cc3VertexHasTangent;				/**< Whether the vertex tangent is available (used downstream). */
uniform bool			u_cc3VertexShouldNormalizeNormal;	/**< Whether the vertex normal should be normalized. */
uniform bool			u_cc3VertexShouldRescaleNormal;		/**< Whether the vertex normal should be rescaled. */

highp vec4				vtxPosition;		/**< The vertex position. High prec to match vertex attribute. */
vec3					vtxNormal;			/**< The vertex normal. */
vec3					vtxTangent;			/**< The vertex tangent. */

/** 
 * Transforms the vertex position, normal, and tangent with the transform matrices of the bones.
 * To improve performance, since vertex tangents are not common, we perform a test before transforming
 * them, but since vertex normals are very common, we don't waste time checking.
 *
 * If most models will have vertex tangents, consider removing the u_cc3VertexHasTangent tests
 * here. The a_cc3Normal and a_cc3Tangent vertex attributes will contain default values (0, 0, 0, 1)
 * if the mesh doesn't actually have those attributes, so the running the calculations unnecessarily
 * will not harm anything other than performance.
 */
void positionVertex() {
	
	// Copy the indices and weights attibutes so the components can be indexed.
	ivec4 boneIndices = ivec4(a_cc3BoneIndices);
	vec4 boneWeights = a_cc3BoneWeights;

	vtxPosition = kVec4Zero;				// Start at zero to accumulate weighted values
	vtxNormal = kVec3Zero;
	vtxTangent = kVec3Zero;
	for (lowp int i = 0; i < MAX_BONES_PER_VERTEX; ++i) {
		if (i < u_cc3VertexBoneCount) {

			// Get the index and weight of this bone
			int boneIdx = boneIndices[i];
			float boneWeight = boneWeights[i];

			// Rotate and translate the vertex position and add its weighted contribution.
			vtxPosition += u_cc3BoneMatricesModel[boneIdx] * a_cc3Position * boneWeight;

			// Rotate the vertex normal and tangent and add their weighted contributions.
			vtxNormal += u_cc3BoneMatricesInvTranModel[boneIdx] * a_cc3Normal * boneWeight;
			if (u_cc3VertexHasTangent) vtxTangent += u_cc3BoneMatricesInvTranModel[boneIdx] * a_cc3Tangent * boneWeight;
		}
	}

	if (u_cc3VertexShouldNormalizeNormal) {
		vtxNormal = normalize(vtxNormal);
		if (u_cc3VertexHasTangent) vtxTangent = normalize(vtxTangent);
	} else if (u_cc3VertexShouldRescaleNormal) {
		vtxNormal = normalize(vtxNormal);								// TODO - rescale without having to normalize
		if (u_cc3VertexHasTangent) vtxTangent = normalize(vtxTangent);	// TODO - rescale without having to normalize
	}

	gl_Position = u_cc3MatrixModelViewProj * vtxPosition;
}
