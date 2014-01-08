/*
 * CC3LibVertexPositionNoBones.vsh
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
 *   - attribute vec3		a_cc3Tangent;				// Vertex tangent
 *
 *   - uniform bool			u_cc3VertexHasTangent;		// Whether the vertex tangent is available.
 *
 * This library declares and outputs the following variables:
 *   - highp vec4			vtxPosition;				// The vertex position. High prec to match vertex attribute.
 *   - vec3					vtxNormal;					// The vertex normal.
 *   - vec3					vtxTangent;					// The vertex tangent.
 *   - glPosition
 */


#import "CC3LibModelMatrices.vsh"


attribute highp vec4	a_cc3Position;			/**< Vertex position. */
attribute vec3			a_cc3Normal;			/**< Vertex normal. */
attribute vec3			a_cc3Tangent;			/**< Vertex tangent. */

uniform bool			u_cc3VertexHasTangent;	/**< Whether the vertex tangent is available (used downstream). */

highp vec4				vtxPosition;			/**< The vertex position. High prec to match vertex attribute. */
vec3					vtxNormal;				/**< The vertex normal. */
vec3					vtxTangent;				/**< The vertex tangent. */


void positionVertex() {
	
	vtxPosition = a_cc3Position;
	vtxNormal = a_cc3Normal;
	vtxTangent = a_cc3Tangent;

	gl_Position = u_cc3MatrixModelViewProj * vtxPosition;
}

