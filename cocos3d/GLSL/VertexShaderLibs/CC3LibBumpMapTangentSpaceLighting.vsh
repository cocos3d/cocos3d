/*
 * CC3LibBumpMapTangentSpaceLighting.vsh
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
 * This vertex shader library determines the lighting direction for use with tangent-space bump-mapping.
 *
 * This library requires the following local variables be declared and populated outside this library:
 *   - highp vec4			vtxPosition;					// The vertex position. High prec to match vertex attribute.
 *   - vec3					vtxNormal;						// The vertex normal.
 *   - vec3					vtxTangent;						// The vertex tangent.
 *
 * This library requires the following attribute and uniform variables be declared and populated outside this library:
 *   - uniform bool			u_cc3VertexHasTangent;			// Whether the vertex tangent is available.
 *   - uniform bool			u_cc3LightIsUsingLighting;		// Indicates whether any lighting is enabled
 *   - uniform highp vec4	u_cc3LightPositionModel[];		// Position or normalized direction in the local coords of the model of each light.
 *
 * This library declares and outputs the following variables:
 *   - varying vec3			v_bumpMapLightDir;				// Direction to the first light in either tangent space or model space.
 */

varying vec3		v_bumpMapLightDir;				/**< Direction to the first light in either tangent space or model space. */

/**
 * If material is using lighting and mesh has vertex tangents, sets the lighting direction to the specified
 * light in tangent space coordinates. The associated normal-map texture must match this and specify its 
 * normals in tangent-space. If not using lighting or if no vertex tangents, simply return a zero vector.
 */
void setBumpMapTangentSpaceLightDirection() {
	if ( !(u_cc3LightIsUsingLighting && u_cc3VertexHasTangent) ) return;
	
	// Get the light direction in model space. If the light is positional
	// calculate the normalized direction from the light and vertex positions.
	int ltIdx = 0;
	vec3 ltDir = u_cc3LightPositionModel[ltIdx].xyz;
	if (u_cc3LightPositionModel[ltIdx].w != 0.0) ltDir = normalize(ltDir - vtxPosition.xyz);
	
	// Create a matrix that transforms from model space to tangent space, and transform light direction.
	vec3 bitangent = cross(vtxNormal, vtxTangent);
	mat3 tangentSpaceXfm = mat3(vtxTangent, bitangent, vtxNormal);

	v_bumpMapLightDir = ltDir * tangentSpaceXfm;
}



