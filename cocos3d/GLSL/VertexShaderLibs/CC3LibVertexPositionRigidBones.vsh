/*
 * CC3LibVertexPositionRigidBones.vsh
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
 * This vertex shader library establishes the position and normal of a vertex based on the rigid
 * movement of underlying bones. Rigid bones are moved and rotated, but are not scaled. This allows
 * the movement of each bone to be described as a single quaternion and translation, which is much
 * more concise than using a matrix (7 floats per bone instead of 16), which allows many more bones
 * to be used per skin section (batch), resulting in fewer draw calls. The use of quaternion and
 * translation math can also reduce the number of calculations that are performed per vertex, which
 * improves performance, when compared to using matrices, even for the same number of bones.
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
 *   - uniform highp vec4	u_cc3BoneQuaternionsModelSpace[];	// Array of bone quaternions in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount).
 *   - uniform highp vec3	u_cc3BoneTranslationsModelSpace[];	// Array of bone translations in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount).
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


#define MAX_BONES_PER_BATCH		36
#define MAX_BONES_PER_VERTEX	4

attribute highp vec4	a_cc3Position;		/**< Vertex position. */
attribute vec3			a_cc3Normal;		/**< Vertex normal. */
attribute vec3			a_cc3Tangent;		/**< Vertex tangent. */
attribute vec4			a_cc3BoneWeights;	/**< Vertex skinning bone weights (each an array of length specified by u_cc3VertexBoneCount). */
attribute vec4			a_cc3BoneIndices;	/**< Vertex skinning bone indices (each an array of length specified by u_cc3VertexBoneCount). */

uniform lowp int		u_cc3VertexBoneCount;									/**< Number of bones influencing each vertex. */
uniform highp vec4		u_cc3BoneQuaternionsModelSpace[MAX_BONES_PER_BATCH];	/**< Array of bone quaternions in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount). */
uniform highp vec3		u_cc3BoneTranslationsModelSpace[MAX_BONES_PER_BATCH];	/**< Array of bone translations in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount). */

uniform bool			u_cc3VertexHasTangent;				/**< Whether the vertex tangent is available (used downstream). */
uniform bool			u_cc3VertexShouldNormalizeNormal;	/**< Whether the vertex normal should be normalized. */
uniform bool			u_cc3VertexShouldRescaleNormal;		/**< Whether the vertex normal should be rescaled. */

highp vec4				vtxPosition;		/**< The vertex position. High prec to match vertex attribute. */
vec3					vtxNormal;			/**< The vertex normal. */
vec3					vtxTangent;			/**< The vertex tangent. */


/**
 * Returns the specified vector rotated by the specified quaternion.
 *
 * This uses a highly optimized version of the basic quaternion rotation equation: qvq(-1):
 *
 *   v' = v + (2 * cross(cross(v, q.xyz) + (q.w * v), q.xyz))
 *
 * Derivation of this algorithm can be found in the following Wikipedia article:
 * http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Performance_comparisons
 * which describes the algo in terms of a left-handed coordinate system. It has been modified
 * here for the right-handed coordinate system of OpenGL.
 *
 * The right-handed algo is also described here:
 * http://twistedpairdevelopment.wordpress.com/2013/02/11/rotating-a-vector-by-a-quaternion-in-glsl/
 *
 * A related algo can be found derived (for left-handed coordinates) here:
 * http://mollyrocket.com/forums/viewtopic.php?t=833&sid=3a84e00a70ccb046cfc87ac39881a3d0
 */
highp vec3 rotateWithQuaternion(highp vec3 v, highp vec4 q) {
	return v + (2.0 * cross(cross(v, q.xyz) + (q.w * v), q.xyz));
}

/**
 * Rigidly transforms the vertex position, normal, and tangent with the rotations and translations of the bones.
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
	
	vtxPosition = kVec4ZeroLoc;				// Start at zero to accumulate weighted values
	vtxNormal = kVec3Zero;
	for (lowp int i = 0; i < MAX_BONES_PER_VERTEX; ++i) {
		if (i < u_cc3VertexBoneCount) {
			
			// Get the index and weight of this bone
			int boneIdx = boneIndices[i];
			float boneWeight = boneWeights[i];
			
			// Get the bone rotation quaternion and translation
			highp vec4 q = u_cc3BoneQuaternionsModelSpace[boneIdx];
			highp vec3 t = u_cc3BoneTranslationsModelSpace[boneIdx];
			
			// Rotate and translate the vertex position and add its weighted contribution.
			vtxPosition.xyz += (rotateWithQuaternion(a_cc3Position.xyz, q) + t) * boneWeight;
			
			// Rotate the vertex normal and tangent and add their weighted contributions.
			vtxNormal += rotateWithQuaternion(a_cc3Normal, q) * boneWeight;
			if (u_cc3VertexHasTangent) vtxTangent += rotateWithQuaternion(a_cc3Tangent, q) * boneWeight;
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

