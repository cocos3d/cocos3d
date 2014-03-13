/*
 * CC3LibVertexPositionPointSprite.vsh
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
 * This vertex shader library establishes the position and normal of a vertex based on a 
 * static mesh where the vertices are not deformed by the movement of bones.
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - attribute highp vec4	a_cc3Position;				// Vertex position.
 *   - attribute vec3		a_cc3Normal;				// Vertex normal.
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - attribute highp vec4	a_cc3Position;				// Vertex position.
 *   - attribute float		a_cc3PointSize;				// Vertex point size.
 *
 *   - uniform bool			u_cc3VertexHasPointSize;	// Whether vertex point size attribute is available.
 *   - uniform float		u_cc3PointSize;				// Default size of points, if not specified per-vertex.
 *   - uniform float		u_cc3PointMinimumSize;		// Minimum size to which points will be allowed to shrink.
 *   - uniform float		u_cc3PointMaximumSize;		// Maximum size to which points will be allowed to grow.
 *   - uniform vec3			u_cc3PointSizeAttenuation;	// Coefficients of the size attenuation equation.
 *
 * This library declares and outputs the following variables:
 *   - highp vec4			vtxPosition;				// The vertex position. High prec to match vertex attribute.
 *   - vec3					vtxNormal;					// The vertex normal.
 *   - glPosition
 */


#import "CC3LibConstants.vsh"
#import "CC3LibModelMatrices.vsh"
#import "CC3LibCameraPosition.vsh"


attribute highp vec4	a_cc3Position;				/**< Vertex position. */
attribute float			a_cc3PointSize;				/**< Vertex point size. */

uniform bool			u_cc3VertexHasPointSize;	/**< Whether vertex point size attribute is available. */
uniform float			u_cc3PointSize;				/**< Default size of points, if not specified per-vertex. */
uniform float			u_cc3PointMinimumSize;		/**< Minimum size to which points will be allowed to shrink. */
uniform float			u_cc3PointMaximumSize;		/**< Maximum size to which points will be allowed to grow. */
uniform highp vec3		u_cc3PointSizeAttenuation;	/**< Coefficients of the size attenuation equation. */

highp vec4				vtxPosition;				/**< The vertex position. High prec to match vertex attribute. */
vec3					vtxNormal;					/**< The vertex normal. */

void positionVertex() {
	
	vtxPosition = a_cc3Position;

	// Since points always face the camera, the normal of each vertex always points towards the camera
	vtxNormal = normalize(u_cc3CameraPositionModel - a_cc3Position.xyz);

	gl_Position = u_cc3MatrixModelViewProj * vtxPosition;
}

/**
 * Sets the point size. If distance attenuation is needed, the distance to the vertex in
 * eye-space is determined and used to attenuate the point size.
 */
void sizePoint() {
	float size = u_cc3VertexHasPointSize ? a_cc3PointSize : u_cc3PointSize;

	if (u_cc3PointSizeAttenuation != kAttenuationNone) {
		highp vec3 vtxPosEye = (u_cc3MatrixModelView * vtxPosition).xyz;
		highp float vtxDistEye = length(vtxPosEye);
		highp vec3 attenuationEquation = highp vec3(1.0, vtxDistEye, vtxDistEye * vtxDistEye);
		size /= sqrt(dot(attenuationEquation, u_cc3PointSizeAttenuation));
	}

	gl_PointSize = clamp(size, u_cc3PointMinimumSize, u_cc3PointMaximumSize);
}

